classdef unsig_int_2_Controller_OC < matlab.DiscreteEventSystem & ...
        matlab.system.mixin.Propagates & ...
        matlab.system.mixin.CustomIcon
    % Control zone with optimal control applied.
    
    properties (Nontunable)
        capacity = 400; % Control zone capacity
        simulation_step = 0.01; % Simulation step
        S = 30; % Length of merging zone
        L = 400; % Length of control zone
        delta = 10; % Minimum safety following distance
    end
    
    properties (DiscreteState)
        % info waiting to be exchanged with the coordinator
        current_id;
        
        CurrentFinalTime; % enter MZ
        CurrentExitTime; % exit MZ
        CurrentLane;
        Parallel;
        
        maintainWaitFirstVehicle;
        maintainFirstVehicle;
        
        first_vehicle_ID;
        first_vehicle_Lane;
        first_vehicle_Position;
        first_vehicle_Speed;
        first_vehicle_Intersection;
        
    end
    
    
    properties
        % optimal speed/position profiles
        profiles = repmat(struct('speed', @(t) 1, 'position', @(t) 1), 1001, 1);
        % iteration start mark
        storageVisited = zeros(5,1);
        % check if info is received by CAV i
        info_received = zeros(1000, 1);
    end
    
    
    methods (Access=protected)
        
        function num = getNumInputsImpl(~)
            % Define number of inputs for system with optional inputs
            num = 2;
        end
        
        function num = getNumOutputsImpl(~)
            % Define number of outputs for system with optional outputs
            num = 2;
        end
        
        function entityTypes = getEntityTypesImpl(obj)
            % Define entity types being used in this model
            entityTypes(1) = obj.entityType('CAV', 'CAV', 1, false);
            entityTypes(2) = obj.entityType('INFO', 'INFO', 1, false);
        end
        
        function [input, output] = getEntityPortsImpl(~)
            % Define data types for entity ports
            input = {'CAV','INFO'};
            output = {'CAV','INFO'};
        end
        
        function [storageSpec, I, O] = getEntityStorageImpl(obj)
            % CAV -> optimal control implemented
            storageSpec(1) = obj.queueFIFO('CAV', obj.capacity);
            % INFO
            storageSpec(2) = obj.queueFIFO('INFO', obj.capacity);
            % CAV -> wait for coordinator
            storageSpec(3) = obj.queueFIFO('CAV', obj.capacity);
            I = [3 2];
            O = [1,2];
        end
        
        function sz = getOutputSizeImpl(~)
            % Return size for each output port
            sz(1) = 1;
            sz(2) = 1;
        end
        function dt = getOutputDataTypeImpl(~)
            % Return data type for each output port
            dt(1) = 'CAV';
            dt(2) = 'INFO';
        end
        
        function cp = isOutputComplexImpl(~)
            % Return true for each output port with complex data
            cp(1) = false;
            cp(2) = false;
        end
        
        function [name1, name2] = getInputNamesImpl(~)
            % Return input port names for System block
            name1 = 'IN';
            name2 = 'INFO';
            
        end
        
        function [name1, name2] = getOutputNamesImpl(~)
            % Return input port names for System block
            name1 = 'OUT';
            name2 = 'INFO';
            
        end
        function icon = getIconImpl(~)
            icon = sprintf('CONTROL ZONE');
        end
        
        function [sz, dt, cp] = getDiscreteStateSpecificationImpl(~, ~)
            sz = 1;
            dt = 'double';
            cp = false;
        end
        
        function setupImpl(obj)
            obj.current_id = 0;
            obj.maintainWaitFirstVehicle = 0;
            obj.maintainFirstVehicle = 0;
            obj.Parallel = 0;
            %plotBGIMAGE();
        end
        
        
        function [entity, events] = INFOEntryImpl(obj, storage, entity, tag)
            if storage == 2
                obj.info_received(entity.data.ID) = 1;
                events = obj.eventDestroy();
            end
        end
        
        
        function [entity, events] = INFOGenerateImpl(obj, storage, entity, tag)
            switch tag
                case 'arrival' % INFO entity
                    entity.data.ID = obj.current_id;
                    events = obj.eventForward('output', 2, 0);
            end
        end
        
        function [entity, events] = CAVGenerateImpl(obj, storage, entity, tag)
            switch tag
                case 'copy_wait_first_vehicle'
                    entity.data.ID = obj.first_vehicle_ID;
                    entity.data.Lane = obj.first_vehicle_Lane;
                    entity.data.Position = obj.first_vehicle_Position;
                    entity.data.Speed = obj.first_vehicle_Speed;
                    entity.data.FinalSpeed = 10;
                    entity.data.Intersection = obj.first_vehicle_Intersection;
                    events = obj.eventForward('storage', 1, 0);
                    
                case 'copy_first_vehicle'
                    % generate a entity and copy the properties of CAV #1
                    entity.data.ID = obj.first_vehicle_ID;
                    entity.data.Lane = obj.first_vehicle_Lane;
                    entity.data.Position = obj.first_vehicle_Position;
                    entity.data.Speed = obj.first_vehicle_Speed;
                    entity.data.FinalSpeed = 10;
                    entity.data.Intersection = obj.first_vehicle_Intersection;
                    events = obj.eventForward('output', 1, 0);
            end
        end
        
        function [entity, events] = CAVEntryImpl(obj, storage, entity, ~)
            % CAV waiting for ID assigned by the coordinator
            if storage == 3 % CAV enters the CZ
                obj.current_id = entity.data.ID;
                
                % send info packet to the coordinator
                if obj.storageVisited(3) == 0
                    obj.storageVisited(3) = 1;
                    events = [obj.eventGenerate(2, 'arrival', 0, 1), ...
                        obj.eventTimer('wait_for_info',obj.simulation_step)];
                else
                    events = obj.eventGenerate(2, 'arrival', 0, 1);
                end
            end
            
            %% receiving the info, start to implement control
            if storage == 1
                % compute terminal time
                % Vehicle Coordination Structure
                if (entity.data.ID == 1) % first vehicle entering the network
                    entity.data.FinalTime = entity.data.ArrivalTime + obj.L / entity.data.Speed;
                    obj.CurrentFinalTime = entity.data.FinalTime;
                    entity.data.ExitTime = entity.data.FinalTime + obj.S / entity.data.FinalSpeed;
                    obj.CurrentLane = entity.data.Lane;
                    obj.CurrentExitTime = entity.data.ExitTime;
                    obj.Parallel = 0;
                else
                    if (entity.data.Lane == obj.CurrentLane)
                        entity.data.FinalTime = entity.data.ArrivalTime + obj.L / entity.data.Speed;
                        if entity.data.FinalTime < obj.CurrentFinalTime + obj.delta / entity.data.FinalSpeed
                            entity.data.FinalTime = obj.CurrentFinalTime + obj.delta / entity.data.FinalSpeed;
                        end
                        entity.data.ExitTime = entity.data.FinalTime + obj.S / entity.data.FinalSpeed;  
                        obj.CurrentLane = entity.data.Lane;
                        obj.CurrentFinalTime = entity.data.FinalTime;
                        obj.CurrentExitTime = entity.data.ExitTime;
                        obj.Parallel = 0;
                    elseif (entity.data.Lane == mod(obj.CurrentLane + 2,4) && obj.Parallel == 0)
                        entity.data.FinalTime = entity.data.ArrivalTime + obj.L / entity.data.Speed;
                        if entity.data.FinalTime < obj.CurrentFinalTime + obj.delta / entity.data.FinalSpeed
                            entity.data.FinalTime = obj.CurrentFinalTime;
                            obj.Parallel = 1;
                        end
                        entity.data.ExitTime = entity.data.FinalTime + obj.S / entity.data.FinalSpeed;
                        obj.CurrentLane = entity.data.Lane;
                        obj.CurrentFinalTime = entity.data.FinalTime;
                        obj.CurrentExitTime = entity.data.ExitTime;
                    elseif (entity.data.Lane == mod(obj.CurrentLane + 2,4) && obj.Parallel == 1)
                        entity.data.FinalTime = entity.data.ArrivalTime + obj.L / entity.data.Speed;
                        if entity.data.FinalTime < obj.CurrentFinalTime + obj.delta / entity.data.FinalSpeed
                            entity.data.FinalTime = obj.CurrentFinalTime + obj.delta / entity.data.FinalSpeed;
                        end
                        entity.data.ExitTime = entity.data.FinalTime + obj.S / entity.data.FinalSpeed;
                        obj.CurrentLane = entity.data.Lane;
                        obj.CurrentFinalTime = entity.data.FinalTime;
                        obj.CurrentExitTime = entity.data.ExitTime;
                        obj.Parallel = 0;
                    else
                        entity.data.FinalTime = obj.CurrentFinalTime + obj.S / entity.data.FinalSpeed;
                        entity.data.ExitTime = entity.data.FinalTime + obj.S / entity.data.FinalSpeed;
                        obj.CurrentLane = entity.data.Lane;
                        obj.CurrentFinalTime = entity.data.FinalTime;
                        obj.CurrentExitTime = entity.data.ExitTime;
                        obj.Parallel = 0;
                    end
                end
                % compute the optimal control
                [obj.profiles(entity.data.ID).speed, obj.profiles(entity.data.ID).position] ...
                    = unsig_int_12_computeCAVProfiles(entity.data.Speed, entity.data.FinalSpeed, ...
                    entity.data.FinalTime, entity.data.Position);
                
                if obj.storageVisited(1) == 0
                    obj.storageVisited(1) = 1;
                    events = obj.eventTimer('apply_control',obj.simulation_step);
                else
                    events = [];
                end
            end
            
            
        end
        
        function [entity, events] = CAVTimerImpl(obj, storage, entity, tag)
            events = [];
            
            switch tag
                case 'wait_for_info' % control zone - control
                    events = [obj.eventIterate(3, 'wait', 1), ...
                        obj.eventTimer('wait_for_info',obj.simulation_step)];
                    
                case 'apply_control' % control zone - control
                    events = [ obj.eventIterate(1, 'CZ', 1), ...
                        obj.eventTimer('apply_control',obj.simulation_step) ];
            end
        end
        
        function [entity, events, next] = CAVIterateImpl(obj, storage, entity, tag, status)
            events = [];
            switch tag
                case 'wait'
                    if entity.data.ID ~= 1001
                        % cruising while waiting for info
                        [entity.data.Position, entity.data.Speed] = ...
                            getCruiseStatus(entity.data.Position, entity.data.Speed, ...
                            obj.simulation_step);
                        unsig_int_12_plotCAV(entity.data.Position, entity.data.Lane, ...
                            entity.data.ID, entity.data.Intersection);
                        
                        % entering the optimal control state
                        if obj.info_received(entity.data.ID) == 1
                            if obj.maintainWaitFirstVehicle == 0
                                obj.first_vehicle_ID = entity.data.ID;
                                obj.first_vehicle_Intersection = entity.data.Intersection;
                                obj.first_vehicle_Lane = entity.data.Lane;
                                obj.first_vehicle_Speed = entity.data.Speed;
                                obj.first_vehicle_Position = entity.data.Position;
                                entity.data.ID = 1001;
                                obj.maintainWaitFirstVehicle = 1;
                                events = obj.eventGenerate(1, 'copy_wait_first_vehicle', 0, 1);
                            else
                                events = obj.eventForward('storage', 1, 0);
                            end
                        end
                    end
                    next = true;
                    
                case 'CZ'
                    if entity.data.ID ~= 1001
                        [entity.data.Speed, entity.data.Position] ...
                            = getStatus_OC(obj.profiles(entity.data.ID).speed, ...
                            obj.profiles(entity.data.ID).position);
                        unsig_int_12_plotCAV(entity.data.Position, entity.data.Lane, ...
                            entity.data.ID, entity.data.Intersection);
                        
                        % entering the merging zone
                        if entity.data.Position >= obj.L
                            if  obj.maintainFirstVehicle == 0
                                obj.first_vehicle_ID = entity.data.ID;
                                obj.first_vehicle_Intersection = entity.data.Intersection;
                                obj.first_vehicle_Lane = entity.data.Lane;
                                obj.first_vehicle_Position = entity.data.Position;
                                obj.first_vehicle_Speed = entity.data.Speed;
                                entity.data.ID = 1001;
                                events = obj.eventGenerate(1, 'copy_first_vehicle', 0, 1);
                                obj.maintainFirstVehicle = 1;
                            else
                                events = obj.eventForward('output', 1, 0);
                            end
                        end
                    end
                    next = true;
            end
        end
    end
end
