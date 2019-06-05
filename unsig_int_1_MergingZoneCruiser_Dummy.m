classdef unsig_int_1_MergingZoneCruiser_Dummy < matlab.DiscreteEventSystem & ...
        matlab.system.mixin.Propagates & ...
        matlab.system.mixin.CustomIcon
    
    properties (Nontunable)
        capacity = 200; % Control zone capacity
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
        
        function [entity, events] = CAVEntryImpl(obj, storage, entity, ~)
            events = obj.eventForward('output', entity.data.Lane, 0);
        end
               
    end
end
