classdef onramp_Coordinator_Dummy < matlab.DiscreteEventSystem & ...
        matlab.system.mixin.Propagates & ...
        matlab.system.mixin.CustomIcon
    % The coordinator can communicate with the vehicles traveling inside the control zone and receive information from the environment. Note that the coordinator is not involved in any decision making for any CAV and only enables communication of appropriate information among CAVs.
    
    properties (Nontunable)
        % Information processing capability
        capacity = 100;
    end
    
    properties (DiscreteState)
        nums;
    end
    
    
    methods (Access=protected)
        
        function num = getNumInputsImpl(~)
            % Define number of inputs for system with optional inputs
            num = 1;
        end
        
        function num = getNumOutputsImpl(~)
            % Define number of outputs for system with optional outputs
            num =1;
        end
        
        function sz = getOutputSizeImpl(~)
            % Return size for each output port
            sz = 1;
        end
        
        function dt = getOutputDataTypeImpl(~)
            % Return data type for each output port
            dt = 'INFO';
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
            icon = sprintf('COORDINATOR DUMMY');
        end
        
        function entityTypes = getEntityTypesImpl(obj)
            % Define entity types being used in this model
            entityTypes(1) = obj.entityType('INFO', 'INFO', 1, false);
        end
        
        function [input, output] = getEntityPortsImpl(~)
            % Define data types for entity ports
            input = {'INFO'};
            output = {'INFO'};
        end
        
        function [sz, dt, cp] = getDiscreteStateSpecificationImpl(~, ~)
            sz = 1;
            dt = 'double';
            cp = false;
        end
        
        function [storageSpec, I, O] = getEntityStorageImpl(obj)
            % Input queue for entities
            storageSpec(1) = obj.queueFIFO('INFO', obj.capacity);
            I = 1;
            O = 1;
        end

    end
end
