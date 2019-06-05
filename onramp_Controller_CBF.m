classdef onramp_Controller_CBF < matlab.DiscreteEventSystem & ...
        matlab.system.mixin.Propagates & ...
        matlab.system.mixin.CustomIcon
    % Control zone with optimal control applied.
    
    
    properties (Nontunable)
        capacity = 400; % Control zone capacity
        simulation_step = 0.01; % Simulation step
        L = 400; % Length of control zone
    end
    
    
    properties (DiscreteState)
        % info waiting to be exchanged with the coordinator
        current_id;
        
        numVehiclesDeparted;
        CurrentFinalTime; % enter MZ
        CurrentExitTime; % exit MZ
        CurrentLane;
        Parallel;
        
        maintainWaitFirstVehicle;
        maintainCZFirstVehicle;
        maintainMZFirstVehicle;
        maintainFirstVehicle;
        
        first_vehicle_ID;
        first_vehicle_Lane;
        first_vehicle_Position;
        first_vehicle_Speed;
        first_vehicle_FinalSpeed;
        first_vehicle_ArrivalTime;
        first_vehicle_FuelCOnsumption;
        
        AverageFuelConsumption;
        AverageTravelTime;   
    end
    
    
    properties
        % optimal speed/position profiles
        profiles = repmat(struct('speed', @(t) 1, 'position', @(t) 1), 1001, 1);
        % iteration start mark
        storageVisited = zeros(5,1);
        % check if info is received by CAV i
        info_received = zeros(1000, 1);
        % maintain a table with vehicle info
        veh = zeros(1000, 4);
         % lane, cur v, cur p, cur u
        veh_next = zeros(1000, 4)
        p_val = zeros(1000, 1);
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
            % Input queue for entities / main lane after merging
            storageSpec(4) = obj.queueFIFO('CAV', obj.capacity);
            

            I = [3 2];
            O = [4,2];
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
            icon = sprintf('FREEWAY ON-RAMP');
        end
        
        function [sz, dt, cp] = getDiscreteStateSpecificationImpl(~, ~)
            sz = 1;
            dt = 'double';
            cp = false;
        end
        
        function setupImpl(obj)
            obj.current_id = 0;
            obj.numVehiclesDeparted = 0;
            obj.maintainWaitFirstVehicle = 0;
            obj.maintainCZFirstVehicle = 0;
            obj.maintainMZFirstVehicle = 0;
            obj.maintainFirstVehicle = 0;
            obj.Parallel = 0;
            obj.AverageFuelConsumption = 0;
            obj.AverageTravelTime = 0; 

        end
       
        function [entity, events] = INFOEntry(obj, storage, entity, tag)
            if storage == 2
                obj.info_received(entity.data.ID) = 1;
                events = obj.eventDestroy();
            end
        end
        
        
        function [entity, events] = INFOGenerate(obj, storage, entity, tag)
            switch tag
                case 'arrival' % INFO entity
                    entity.data.ID = obj.current_id;
                    events = obj.eventForward('output', 2, 0);
            end
        end
        
        function [entity, events] = CAVGenerate(obj, storage, entity, tag)
            switch tag
                case 'copy_wait_first_vehicle'
                    entity.data.ID = obj.first_vehicle_ID;
                    entity.data.Lane = obj.first_vehicle_Lane;
                    entity.data.Speed = obj.first_vehicle_Speed;
                    entity.data.Position = obj.first_vehicle_Position;
                    entity.data.FinalSpeed = obj.first_vehicle_FinalSpeed;
                    entity.data.ArrivalTime = obj.first_vehicle_ArrivalTime;
                    entity.data.FuelConsumption = obj.first_vehicle_FuelCOnsumption;
                    events = obj.eventForward('storage', 1, 0);
                   
                case 'copy_CZ_first_vehicle'
                    entity.data.ID = obj.first_vehicle_ID;
                    entity.data.Lane = obj.first_vehicle_Lane;
                    entity.data.Speed = obj.first_vehicle_Speed;
                    entity.data.Position = obj.first_vehicle_Position;
                    entity.data.ArrivalTime = obj.first_vehicle_ArrivalTime;
                    entity.data.FuelConsumption = obj.first_vehicle_FuelCOnsumption;
                    events = obj.eventForward('storage', 4, 0);
                    
                case 'copy_first_vehicle'
                    % generate a entity and copy the properties of CAV #1
                    entity.data.ID = obj.first_vehicle_ID;
                    entity.data.Lane = obj.first_vehicle_Lane;
                    entity.data.Speed = obj.first_vehicle_Speed;
                    entity.data.Position = obj.first_vehicle_Position;
                    events = obj.eventForward('output', 1, 0);
            end
        end
        
        function [entity, events] = CAVEntry(obj, storage, entity, ~)
            %% Sending arrival info, requesting for traffic signal information
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
            
            %% Eeceiving the info, start to implement control
            if storage == 1
                if obj.storageVisited(1) == 0
                    obj.storageVisited(1) = 1;
                    events = obj.eventTimer('apply_control',obj.simulation_step);
                else
                    events = [];
                end
            end
            
            
             %% Entering the main lane after merging
            if storage == 4 
                entity.data.Lane = 1; % main lane
                if entity.data.ID == 1
                    events = obj.eventTimer('nextCZ',0.01);
                else
                    events = [];
                end
                
                %% Calculate performance metric in real time:
                % Average Fuel Consumption and Average Travel Time over the control zone for the whole network
                obj.AverageFuelConsumption = obj.AverageFuelConsumption * obj.numVehiclesDeparted + entity.data.FuelConsumption;
                entity.data.FinalTime = get_param('Mcity', 'SimulationTime');
                obj.AverageTravelTime = obj.AverageTravelTime * obj.numVehiclesDeparted + entity.data.FinalTime - entity.data.ArrivalTime;
                obj.numVehiclesDeparted = obj.numVehiclesDeparted + 1;
                obj.AverageFuelConsumption = obj.AverageFuelConsumption / obj.numVehiclesDeparted;
                obj.AverageTravelTime = obj.AverageTravelTime / obj.numVehiclesDeparted;
                
                %Plot the performance metric in real time
                onramp_plotPerformanceMetrics(obj.AverageFuelConsumption, obj.AverageTravelTime); 
            end

        end
        
        
        function [entity, events] = CAVTimer(obj, storage, entity, tag)
            events = [];
            
            switch tag
                case 'wait_for_info' % control zone - control
                    events = [obj.eventIterate(3, 'wait', 1), ...
                        obj.eventTimer('wait_for_info',obj.simulation_step)];
                    
                case 'apply_control' % control zone - control
                    obj.veh = obj.veh_next;
                    events = [obj.eventIterate(1, 'CZ', 1), ...
                        obj.eventTimer('apply_control',obj.simulation_step)];
                    
                case 'nextCZ'
                    events =  [obj.eventIterate(4, 'cruise', 1),  ...
                        obj.eventTimer('nextCZ',obj.simulation_step)] ;

            end
        end
        
        
        function [entity, events, next] = CAVIterate(obj, storage, entity, tag, status)
            events = [];
            switch tag
                case 'wait'
                    % cruising while waiting for info
                    if entity.data.ID ~= 1001
                        [entity.data.Position, entity.data.Speed, entity.data.Acceleration] = ...
                            onramp_getCruiseStatus(entity.data.Position, entity.data.Speed, ...
                            obj.simulation_step);
                        obj.veh_next(entity.data.ID, :) = [entity.data.Lane, ...
                            entity.data.Speed, entity.data.Position, entity.data.Acceleration];
                        onramp_plotCAV(entity.data.Position, entity.data.Lane, entity.data.ID);
                        
                        entity.data.FuelConsumption = onramp_computeFuelConsumption(entity.data.FuelConsumption, ...
                        entity.data.Speed, entity.data.Acceleration, obj.simulation_step);
                    
                        % entering the optimal control state
                        if obj.info_received(entity.data.ID) == 1
                            if obj.maintainWaitFirstVehicle == 0
                                obj.first_vehicle_ID = entity.data.ID;
                                obj.first_vehicle_Lane = entity.data.Lane;
                                obj.first_vehicle_Speed = entity.data.Speed;
                                obj.first_vehicle_Position = entity.data.Position;
                                obj.first_vehicle_FinalSpeed = entity.data.FinalSpeed;
                                obj.first_vehicle_ArrivalTime = entity.data.ArrivalTime;
                                obj.first_vehicle_FuelCOnsumption = entity.data.FuelConsumption;
                                entity.data.ID = 1001;
                                obj.maintainWaitFirstVehicle = 1;
                                events = obj.eventGenerate(3, 'copy_wait_first_vehicle', 0, 1);
                            else
                                events = obj.eventForward('storage', 1, 0);
                            end
                        end
                    end
                    next = true;
                    
                case 'CZ'
                    % compute the dynamics based on the latest control
                    if entity.data.ID ~= 1001
                        [entity.data.Position, entity.data.Speed, entity.data.Acceleration, obj.p_val] ...
                            = onramp_getStatus_CBF(obj.veh, entity.data.ID, obj.p_val);
                        obj.veh_next(entity.data.ID, :) = [entity.data.Lane, ...
                            entity.data.Speed, entity.data.Position, entity.data.Acceleration];
                        onramp_plotCAV(entity.data.Position, entity.data.Lane, entity.data.ID);
                        
                        entity.data.FuelConsumption = onramp_computeFuelConsumption(entity.data.FuelConsumption, ...
                        entity.data.Speed, entity.data.Acceleration, obj.simulation_step);
                        % entering the merging zone
                        if entity.data.Position >= obj.L
                            if obj.maintainCZFirstVehicle == 0
                                obj.first_vehicle_ID = entity.data.ID;
                                obj.first_vehicle_Lane = entity.data.Lane;
                                obj.first_vehicle_Speed = entity.data.Speed;
                                obj.first_vehicle_Position = entity.data.Position;
                                obj.first_vehicle_ArrivalTime = entity.data.ArrivalTime;
                                obj.first_vehicle_FuelCOnsumption = entity.data.FuelConsumption;
                                entity.data.ID = 1001;
                                obj.maintainCZFirstVehicle = 1;
                                events = obj.eventGenerate(1, 'copy_CZ_first_vehicle', 0, 1);
                            else
                                events = obj.eventForward('storage', 4, 0);
                            end
                        end
                    end
                    next = true;
                    
                case 'cruise'
                    if entity.data.ID ~= 1001
                        [entity.data.Position, entity.data.Speed, entity.data.Acceleration, obj.p_val] ...
                            = onramp_getStatus_CBF(obj.veh, entity.data.ID, obj.p_val);
                        obj.veh_next(entity.data.ID, :) = [entity.data.Lane, ...
                            entity.data.Speed, entity.data.Position, entity.data.Acceleration];
                        onramp_plotCAV(entity.data.Position, entity.data.Lane, entity.data.ID);

                        if entity.data.Position > 501
                            if entity.data.ID == 1 && obj.maintainFirstVehicle == 0
                                obj.first_vehicle_ID = entity.data.ID;
                                obj.first_vehicle_Lane = entity.data.Lane;
                                obj.first_vehicle_Position = entity.data.Position;
                                obj.first_vehicle_Speed = entity.data.Speed;
                                entity.data.ID = 1001;
                                obj.maintainFirstVehicle = 1;
                                events = obj.eventGenerate(4, 'copy_first_vehicle', 0, 1);
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
