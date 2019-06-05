classdef sig_int_Controller_OC < matlab.DiscreteEventSystem & ...
        matlab.system.mixin.Propagates & ...
        matlab.system.mixin.CustomIcon
    % Control zone with optimal control applied.
    
    
    properties (Nontunable)
        capacity = 400; % Control zone capacity
        simulation_step = 0.01; % Simulation step
        S = 30; % Width of merging zone
        L = 400; % Length of control zone
        delta = 10; % Minimum safety following distance
    end
    
    
    properties (DiscreteState)
        current_id;

        light_cycle;
        light_phase;
        
        maintainWaitFirstVehicle;
        maintainCZFirstVehicle;
        maintainMZFirstVehicle;
        maintainFirstVehicle;
        
        first_vehicle_ID;
        first_vehicle_Lane;
        first_vehicle_Speed;
        first_vehicle_Position;
    end
    
  
    properties
        % optimal speed/position profiles
        profiles = repmat(struct('speed', @(t) 1, 'position', @(t) 1), 1001, 1);
        % previous terminal time on all lane segments (4)
        previous_terminal_time = zeros(4,1);
        % previous terminal speed on all lane segments (4)
        previous_terminal_speed = zeros(4,1);
        % iteration start mark
        storageVisited = zeros(5,1);
        % check if info is received by CAV i
        info_received = zeros(1000, 1);
        % maintain iteration
        lane = zeros(4,1);
    end
    
    
    methods (Access=protected)
        
        function num = getNumInputsImpl(~)
            % Define number of inputs for system with optional inputs
            num = 1;
        end
        
        
        function num = getNumOutputsImpl(~)
            % Define number of outputs for system with optional outputs
            num = 1;
        end
        
        
        function entityTypes = getEntityTypesImpl(obj)
            % Define entity types being used in this model
            entityTypes = obj.entityType('CAV', 'CAV', 1, false);
        end
        
        
        function [input, output] = getEntityPortsImpl(~)
            % Define data types for entity ports
            input = {'CAV'};
            output = {'CAV'};
        end
        
        
        function [storageSpec, I, O] = getEntityStorageImpl(obj)
            %  control implemented
            storageSpec(1) = obj.queueFIFO('CAV', obj.capacity);
            % Input queue for entities / merging zone
            storageSpec(2) = obj.queueFIFO('CAV', obj.capacity);
            % Input queue for entities / next lane
            storageSpec(3) = obj.queueFIFO('CAV', obj.capacity);
            
            I = 1;
            O = 3;
            
        end
        
        
        function sz = getOutputSizeImpl(~)
            % Return size for each output port
            sz = 1;
        end
        
        
        function dt = getOutputDataTypeImpl(~)
            % Return data type for each output port
            dt = 'CAV';
        end
        
        
        function cp = isOutputComplexImpl(~)
            % Return true for each output port with complex data
            cp = false;
        end
        
        
        function name = getInputNamesImpl(~)
            % Return input port names for System block
            name = 'IN';
        end
        
        
        function name = getOutputNamesImpl(~)
            % Return input port names for System block
            name = 'OUT';
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
            obj.maintainCZFirstVehicle = 0;
            obj.maintainMZFirstVehicle = 0;
            obj.maintainFirstVehicle = 0;
            sig_int_plotCAVs();
        end
        
        
        function [entity, events] = CAVGenerateImpl(obj, storage, entity, tag)
            switch tag           
                case 'copy_CZ_first_vehicle'
                    entity.data.ID = obj.first_vehicle_ID;
                    entity.data.Lane = obj.first_vehicle_Lane;
                    entity.data.Position = obj.first_vehicle_Position;
                    entity.data.Speed = 10;
                    events = obj.eventForward('storage', 2, 0);
                    
                case 'copy_MZ_first_vehicle'
                    entity.data.ID = obj.first_vehicle_ID;
                    entity.data.Lane = obj.first_vehicle_Lane;
                    entity.data.Speed = obj.first_vehicle_Speed;
                    entity.data.Position = obj.first_vehicle_Position;
                    events = obj.eventForward('storage', 3, 0);
                    
                case 'copy_first_vehicle'
                    % generate a entity and copy the properties of CAV #1
                    entity.data.ID = obj.first_vehicle_ID;
                    entity.data.Lane = obj.first_vehicle_Lane;
                    entity.data.Speed = obj.first_vehicle_Speed;
                    entity.data.Position = obj.first_vehicle_Position;
                    events = obj.eventForward('output', 1, 0);
            end
        end
        
        
        function [entity, events] = CAVEntryImpl(obj, storage, entity, ~)            
            %% Receiving the info, start to implement control
            if storage == 1
                [obj.profiles(entity.data.ID).speed, obj.profiles(entity.data.ID).position,  ...
                    obj.previous_terminal_time(entity.data.Lane), obj.previous_terminal_speed(entity.data.Lane)] ...
                    = sig_int_computeCAVProfilesGivenK(entity.data.Speed, ...
                    entity.data.Position, obj.previous_terminal_time(entity.data.Lane), ...
                    obj.previous_terminal_speed(entity.data.Lane), entity.data.Lane);
                
                if obj.storageVisited(1) == 0
                    obj.storageVisited(1) = 1;
                    events = obj.eventTimer('apply_control',obj.simulation_step);
                else
                    events = [];
                end 
            end
            
            %% Entering the Merging Zone
            if storage == 2
                if obj.storageVisited(4) == 0
                    obj.storageVisited(4) = 1;
                    events = obj.eventTimer('cross_MZ', obj.simulation_step);
                else
                    events = [];
                end
            end
            
            %% Entering the next intersection
            if storage == 3 % leave the merging zone and enter the next lane
                if obj.storageVisited(5) == 0
                    obj.storageVisited(5) = 1;
                    events = obj.eventTimer('cruise_exit',obj.simulation_step);
                else
                    events = [];
                end
            end
            
        end
        
        
        function [entity, events] = CAVTimerImpl(obj, storage, entity, tag)
            events = [];
            
            switch tag
                case 'apply_control' % control zone - control
                    events = [obj.eventIterate(1, 'CZ', 1), ...
                        obj.eventTimer('apply_control',obj.simulation_step)];
                    
                case 'cross_MZ' % merging zone
                    events = [obj.eventIterate(2, 'MZ', 1), ...
                        obj.eventTimer('cross_MZ',obj.simulation_step)];
                    
                case 'cruise_exit'
                    events = [obj.eventIterate(3, 'NextRoad', 1), ...
                        obj.eventTimer('cruise_exit',obj.simulation_step)];
            end
            
        end
        
        
        function [entity, events, next] = CAVIterateImpl(obj, storage, entity, tag, status)
            events = [];
            switch tag                    
                case 'CZ'
                    % compute the dynamics based on the latest control
                    if entity.data.ID ~= 1001
                        [entity.data.Speed, entity.data.Position] ...
                            = sig_int_getStatus_OC(obj.profiles(entity.data.ID).speed, ...
                            obj.profiles(entity.data.ID).position);
                        sig_int_plotCAV(entity.data.Position, entity.data.Lane, entity.data.ID);
                        
                        % entering the merging zone
                        if entity.data.Position >= obj.L
                            if obj.maintainCZFirstVehicle == 0
                                obj.first_vehicle_ID = entity.data.ID;
                                obj.first_vehicle_Lane = entity.data.Lane;
                                obj.first_vehicle_Speed = entity.data.Speed;
                                obj.first_vehicle_Position = entity.data.Position;
                                entity.data.ID = 1001;
                                obj.maintainCZFirstVehicle = 1;
                                events = obj.eventGenerate(1, 'copy_CZ_first_vehicle', 0, 1);
                            else
                                events = obj.eventForward('storage', 2, 0);
                            end
                        end
                    end
                    next = true;
                    
                case 'MZ'
                    if entity.data.ID ~= 1001
                        [entity.data.Speed, entity.data.Position] ...
                            = getStatus_OC(obj.profiles(entity.data.ID).speed, ...
                            obj.profiles(entity.data.ID).position);
                        sig_int_plotCAV(entity.data.Position, entity.data.Lane, entity.data.ID);
                        
                        if entity.data.Position >= obj.L + obj.S
                            if obj.maintainMZFirstVehicle == 0
                                obj.first_vehicle_ID = entity.data.ID;
                                obj.first_vehicle_Lane = entity.data.Lane;
                                obj.first_vehicle_Speed = entity.data.Speed;
                                obj.first_vehicle_Position = entity.data.Position;
                                entity.data.ID = 1001;
                                obj.maintainMZFirstVehicle = 1;
                                events = obj.eventGenerate(2, 'copy_MZ_first_vehicle', 0, 1);
                            else
                                events = obj.eventForward('storage', 3, 0);
                            end
                        end
                    end
                    next = true;
                    
                    
                case 'NextRoad'
                    if entity.data.ID ~= 1001 
                        [entity.data.Speed, entity.data.Position] ...
                            = sig_int_getStatus_OC(obj.profiles(entity.data.ID).speed, ...
                            obj.profiles(entity.data.ID).position);
                        sig_int_plotCAV(entity.data.Position, entity.data.Lane, entity.data.ID);
                        if entity.data.Position > 840 % make sure greater than the map
                            if obj.lane(entity.data.Lane) == 0
                                obj.first_vehicle_ID = entity.data.ID;
                                obj.first_vehicle_Lane = entity.data.Lane;
                                obj.first_vehicle_Speed = entity.data.Speed;
                                obj.first_vehicle_Position = entity.data.Position;
                                entity.data.ID = 1001;
                                obj.lane(entity.data.Lane) = 1;
                                events = obj.eventGenerate(3, 'copy_first_vehicle', 0, 1);
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