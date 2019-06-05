classdef sig_int_TrafficSignal_Dummy < matlab.DiscreteEventSystem & ...
        matlab.system.mixin.Propagates & ...
        matlab.system.mixin.CustomIcon
    
    properties (Nontunable)
        capacity = 100; % Information processing capability
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
            icon = sprintf('TRAFFIC SIGNAL DUMMY');
        end

        
        function [sz, dt, cp] = getDiscreteStateSpecificationImpl(~, ~)
            sz = 1;
            dt = 'double';
            cp = false;
        end

    end
end
