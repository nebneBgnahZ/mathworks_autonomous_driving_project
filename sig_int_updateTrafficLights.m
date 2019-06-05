function current_light = sig_int_updateTrafficLights(light_phase, light_cycle, ...
    current_light)
global p_tlc
t = get_param('Mcity', 'SimulationTime');
rem = mod(t + light_phase, light_cycle);
if 0 <= rem && rem < 12
    if current_light ~= 1
        p_tlc(1).MarkerEdgeColor = 'green';
        p_tlc(1).MarkerFaceColor = 'green';
        p_tlc(3).MarkerEdgeColor = 'green';
        p_tlc(3).MarkerFaceColor = 'green';
        p_tlc(2).MarkerEdgeColor = 'red';
        p_tlc(2).MarkerFaceColor = 'red';
        p_tlc(4).MarkerEdgeColor = 'red';
        p_tlc(4).MarkerFaceColor = 'red';
        current_light = 1;
    end
elseif 12 <= rem && rem < 15
    if current_light ~= 3
        p_tlc(1).MarkerEdgeColor = 'yellow';
        p_tlc(1).MarkerFaceColor = 'yellow';
        p_tlc(3).MarkerEdgeColor = 'yellow';
        p_tlc(3).MarkerFaceColor = 'yellow';
        p_tlc(2).MarkerEdgeColor = 'red';
        p_tlc(2).MarkerFaceColor = 'red';
        p_tlc(4).MarkerEdgeColor = 'red';
        p_tlc(4).MarkerFaceColor = 'red';
        current_light = 3;
    end
elseif 15 <= rem && rem < 27
    if current_light ~= 2
        p_tlc(1).MarkerEdgeColor = 'red';
        p_tlc(1).MarkerFaceColor = 'red';
        p_tlc(3).MarkerEdgeColor = 'red';
        p_tlc(3).MarkerFaceColor = 'red';
        p_tlc(2).MarkerEdgeColor = 'green';
        p_tlc(2).MarkerFaceColor = 'green';
        p_tlc(4).MarkerEdgeColor = 'green';
        p_tlc(4).MarkerFaceColor = 'green';
        current_light = 2;
    end
elseif 27 <= rem && rem < 30
    if current_light ~= 4
        p_tlc(1).MarkerEdgeColor = 'red';
        p_tlc(1).MarkerFaceColor = 'red';
        p_tlc(3).MarkerEdgeColor = 'red';
        p_tlc(3).MarkerFaceColor = 'red';
        p_tlc(2).MarkerEdgeColor = 'yellow';
        p_tlc(2).MarkerFaceColor = 'yellow';
        p_tlc(4).MarkerEdgeColor = 'yellow';
        p_tlc(4).MarkerFaceColor = 'yellow';
        current_light = 4;
    end
end