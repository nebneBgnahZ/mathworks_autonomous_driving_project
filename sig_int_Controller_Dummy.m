classdef sig_int_Controller_Dummy < matlab.DiscreteEventSystem & ...
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
            icon = sprintf('CONTROL ZONE DUMMY');
        end
        
        
        function [sz, dt, cp] = getDiscreteStateSpecificationImpl(~, ~)
            sz = 1;
            dt = 'double';
            cp = false;
        end
        
        
        function [entity, events] = CAVEntryImpl(obj, storage, entity, ~)
            events = obj.eventForward('output', 1, 0);
        end
    end
end