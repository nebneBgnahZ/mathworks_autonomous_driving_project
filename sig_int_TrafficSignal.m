classdef sig_int_TrafficSignal < matlab.DiscreteEventSystem & ...
        matlab.system.mixin.Propagates & ...
        matlab.system.mixin.CustomIcon
    
    properties (Nontunable)
        capacity = 100; % Information processing capability
        simulation_step = 0.01; % Simulation step
        light_cycle = 30; % Traffic light cycle
        light_phase = 10; % Past green period on West-East
    end
    
    
    properties (DiscreteState)        
        current_light;
    end
    
    
    methods (Access=protected)
        
        function num = getNumInputsImpl(~)
            % Define number of inputs for system with optional inputs
            num = 0;
        end
        
        
        function num = getNumOutputsImpl(~)
            % Define number of outputs for system with optional outputs
            num = 0;
        end

        
        function icon = getIconImpl(~)
            icon = sprintf('TRAFFIC SIGNAL');
        end
        
        
        function entityTypes = getEntityTypesImpl(obj)
            % Define entity types being used in this model
            entityTypes = obj.entityType('INFO', 'INFO', 1, false);
        end
        
        
        function [sz, dt, cp] = getDiscreteStateSpecificationImpl(~, ~)
            sz = 1;
            dt = 'double';
            cp = false;
        end
        
        
        function [storageSpec, I, O] = getEntityStorageImpl(obj)
            % Input queue for entities
            storageSpec = obj.queueFIFO('INFO', obj.capacity);
            I = [];
            O = [];
        end
        
        
        function setupImpl(obj)
            obj.current_light = 0; % current light status (E-W)
            sig_int_plotBGIMAGE();
        end
        
        
        function events = setupEventsImpl(obj)
            events = obj.eventGenerate(1, 'trigger_traffic_light_update', 0, 1);
        end
        
        
        function [entity, events] = INFOGenerateImpl(obj, storage, entity, tag)
            switch tag  
                case 'trigger_traffic_light_update' 
                    if storage == 1
                        events = obj.eventTimer('update_traffic_light', ...
                            obj.simulation_step);
                    end
            end
        end
        
        
        function [entity, events] = INFOTimerImpl(obj, storage, entity, tag)
            events = [];
            switch tag                    
                case 'update_traffic_light'
                    obj.current_light = sig_int_updateTrafficLights(obj.light_phase, ...
                        obj.light_cycle, obj.current_light);
                    events = obj.eventTimer('update_traffic_light', obj.simulation_step);
            end
            
        end
        
    end
end
