classdef sig_int_Controller_Mixed < matlab.DiscreteEventSystem & ...
        matlab.system.mixin.Propagates & ...
        matlab.system.mixin.CustomIcon
    % Control zone with optimal control applied.
    
    
    properties (Nontunable)
        capacity = 100; % Control zone capacity
        simulation_step = 0.01; % Simulation step
        S = 30; % Width of merging zone
        L = 400; % Length of control zone
        delta = 10; % Minimum safety following distance
        light_cycle = 30; % Traffic light cycle
        light_phase = 10; % Past green period on West-East
    end
    
    
    properties (DiscreteState)
        current_id;
        maintainFirstVehicle;
        storageVisited;
        first_vehicle_ID;
        first_vehicle_Lane;
        first_vehicle_Speed;
        first_vehicle_Position;
    end
    
  
    properties
        % maintain a table with vehicle info
        veh = zeros(1000, 5) % lane, current v, current p, terminal t, terminal v
        % optimal profiles for CAV
        profiles = repmat(struct('speed', @(t) 1, 'position', @(t) 1), 1001, 1);
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
            storageSpec = obj.queueFIFO('CAV', obj.capacity);
            
            I = 1;
            O = 1;
            
        end
        
        function sz = getOutputSizeImpl(~)
            % Return size for each output port
            sz = 1;
        end
        
        
        function dt = getOutputDataTypeImpl(~)
            % Return data type for each output port
            dt = ['CAV', ''];
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
            obj.maintainFirstVehicle = 0;
            obj.storageVisited = 0;
            % sig_int_plotBGIMAGE_Mixed();
            sig_int_plotCAVs();
        end
        

        function [entity, events] = CAVGenerateImpl(obj, storage, entity, tag)
            switch tag                              
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
            % proceed following IDM            
            if storage == 1
                obj.veh(entity.data.ID, 1:3) = [entity.data.Lane, entity.data.Speed, entity.data.Position];
                if entity.data.Type == 1 % CAV
                    [obj.profiles(entity.data.ID).speed, obj.profiles(entity.data.ID).position] ...
                    = sig_int_computeCAVProfiles(obj.veh, entity.data.ID);
                end
                
                if obj.storageVisited == 0
                    obj.storageVisited = 1;
                    events = obj.eventTimer('next_timestep',obj.simulation_step);
                else
                    events = [];
                end 
            end
            
        end
        
        
        function [entity, events] = CAVTimerImpl(obj, storage, entity, tag)
            events = [];
            
            switch tag
                case 'next_timestep' % control zone - control
                    events = [obj.eventIterate(1, 'iter', 1), ...
                        obj.eventTimer('next_timestep',obj.simulation_step)];
                    
            end
            
        end
        
        
        function [entity, events, next] = CAVIterateImpl(obj, storage, entity, tag, status)
            events = [];
            switch tag
                case 'iter'
                    % compute the dynamics based on the latest control
                    if entity.data.ID ~= 1001
                        [entity.data.Speed, entity.data.Position, entity.data.Type] ...
                            = sig_int_getStatus_Mixed(obj.veh, entity.data.ID, ...
                            entity.data.Type, obj.profiles);
                        % check vehicle status, e.g., speed
                        if entity.data.ID == 10
                            sig_int_plotStatus(entity.data.Lane, entity.data.Speed, ...
                                entity.data.Position);
                        end
                        obj.veh(entity.data.ID, 2:3) = [entity.data.Speed, entity.data.Position];
                        sig_int_plotCAV_Mixed(entity.data.Position, entity.data.Lane, entity.data.ID, ...
                            entity.data.Type);
                        
                        % entering the merging zone
                        if entity.data.Position >= obj.L * 2 + obj.S + 1
                            obj.veh(entity.data.ID, 1) = 0;
                            if obj.maintainFirstVehicle == 0
                                obj.first_vehicle_ID = entity.data.ID;
                                obj.first_vehicle_Lane = entity.data.Lane;
                                obj.first_vehicle_Speed = entity.data.Speed;
                                obj.first_vehicle_Position = entity.data.Position;
                                entity.data.ID = 1001;
                                obj.maintainFirstVehicle = 1;
                                events = obj.eventGenerate(1, 'copy_first_vehicle', 0, 1);
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