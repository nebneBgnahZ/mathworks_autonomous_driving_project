classdef unsig_int_2_MergingZoneCruiser < matlab.DiscreteEventSystem & ...
         matlab.system.mixin.Propagates & ...
        matlab.system.mixin.CustomIcon
    
    properties (Nontunable)
        capacity = 200; % Control zone capacity
        simulation_step = 0.01; % Simulation step
        L = 400; % Length of control zone
        S = 30; % Length of merging zone
    end
    
    properties (DiscreteState)
        maintainFirstVehicle;
        
        first_vehicle_ID;
        first_vehicle_Lane;
        first_vehicle_Position;
        first_vehicle_Speed;
        first_vehicle_Intersection;
    end
    
    properties
        storageVisited = 0;
        INT_MAX = 2000;
    end
    
    methods (Access=protected)
        
        function num = getNumInputsImpl(~)
            % Define number of inputs for system with optional inputs
            num = 1;
        end
        
        function num = getNumOutputsImpl(~)
            % Define number of outputs for system with optional outputs
            num = 4;
        end
        
        function entityTypes = getEntityTypesImpl(obj)
            % Define entity types being used in this model
            entityTypes = obj.entityType('CAV', 'CAV', 1, false);
        end
        
        function [input, output] = getEntityPortsImpl(~)
            % Define data types for entity ports
            input = {'CAV'};
            output = {'CAV', 'CAV', 'CAV', 'CAV'};
        end
        
        function [storageSpec, I, O] = getEntityStorageImpl(obj)
            % CAV -> optimal control implemented
            storageSpec(1) = obj.queueFIFO('CAV', obj.capacity);
            I = 1;
            O = [1,1,1,1];
        end
        
        function sz = getOutputSizeImpl(~)
            % Return size for each output port
            sz(1) = 1;
            sz(2) = 1;
            sz(3) = 1;
            sz(4) = 1;
        end
        
        function dt = getOutputDataTypeImpl(~)
            % Return data type for each output port
            dt(1) = 'CAV';
            dt(2) = 'CAV';
            dt(3) = 'CAV';
            dt(4) = 'CAV';
        end
        
        function cp = isOutputComplexImpl(~)
            % Return true for each output port with complex data
            cp(1) = false;
            cp(2) = false;
            cp(3) = false;
            cp(4) = false;
        end
        
        function name = getInputNamesImpl(~)
            % Return input port names for System block
            name = 'CAV';
        end
        
        function [name1, name2, name3, name4] = getOutputNamesImpl(~)
            % Return input port names for System block
            name1 = 'TO WEST';
            name2 = 'TO SOUTH';
            name3 = 'TO EAST';
            name4 = 'TO NORTH';
        end
        
        function icon = getIconImpl(~)
            icon = sprintf('THE MERGING ZONE');
        end
        
        function [sz, dt, cp] = getDiscreteStateSpecificationImpl(~, ~)
            sz = 1;
            dt = 'double';
            cp = false;
        end
        
        function setupImpl(obj)
            obj.maintainFirstVehicle = 0;
        end
        
        
        function [entity, events] = CAVGenerateImpl(obj, storage, entity, tag)
            switch tag
                case 'copy_first_vehicle'
                    % generate a entity and copy the properties of CAV #1
                    entity.data.ID = obj.first_vehicle_ID;
                    entity.data.Lane = obj.first_vehicle_Lane;
                    entity.data.Position = obj.first_vehicle_Position;
                    entity.data.Speed = obj.first_vehicle_Speed;
                    entity.data.FinalSpeed = 10;
                    entity.data.Intersection = obj.first_vehicle_Intersection;
                    if entity.data.Lane == 3
                        entity.data.ID = 1001;
                    end
                    events = obj.eventForward('output', entity.data.Lane, 0);
            end
        end
        
        function [entity, events] = CAVEntryImpl(obj, storage, entity, ~)
            % CAV waiting for ID assigned by the coordinator
            if storage == 1 % CAV enters the CZ
                % send info packet to the coordinator
                if obj.storageVisited == 0
                    obj.storageVisited = 1;
                    events = obj.eventTimer('cruise',obj.simulation_step);
                else
                    events = [];
                end
                
            end
        end
        
        
        function [entity, events] = CAVTimerImpl(obj, storage, entity, tag)
            events = [];
            switch tag
                case 'cruise' % control zone - control
                    events = [ obj.eventIterate(1, 'MZ', 1), ...
                        obj.eventTimer('cruise',obj.simulation_step)];
            end
        end
        
        
        function [entity, events, next] = CAVIterateImpl(obj, storage, entity, tag, status)
            events = [];
            switch tag
                case 'MZ'
                    % compute the dynamics based on the latest control
                    if entity.data.Position <= obj.INT_MAX
                        % compute the dynamics based on the latest control
                        % cruising while waiting for info
                        [entity.data.Position, entity.data.Speed] = ...
                            getCruiseStatus(entity.data.Position, entity.data.Speed, ...
                            obj.simulation_step);
                        unsig_int_12_plotCAV(entity.data.Position, entity.data.Lane, ...
                            entity.data.ID, entity.data.Intersection);
                        % entering the merging zone
                        if entity.data.Position >= obj.L + obj.S ...
                                && entity.data.Position <= obj.INT_MAX
                            if  obj.maintainFirstVehicle == 0 || entity.data.Lane == 3
                                obj.first_vehicle_ID = entity.data.ID;
                                obj.first_vehicle_Lane = entity.data.Lane;
                                obj.first_vehicle_Position = entity.data.Position;
                                obj.first_vehicle_Speed = entity.data.Speed;
                                obj.first_vehicle_Intersection = entity.data.Intersection;
                                entity.data.Position = obj.INT_MAX;
                                events = obj.eventGenerate(1, 'copy_first_vehicle', 0, 1);
                                obj.maintainFirstVehicle = 1;
                            else
                                events = obj.eventForward('output', entity.data.Lane, 0);
                            end
                        end
                    end
                    next = true;
            end
        end
    end
end
