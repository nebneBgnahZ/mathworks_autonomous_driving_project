function [v, p] = sig_int_computeCAVProfiles(veh, i)

global L
global initial_speed
global initial_time
global gamma


cycle = 30; % Traffic light cycle
phase = 10; % Past green period on West-East

L = 400;
gamma = 0.1;
green = 1;
red = 2;
vmax = 13;

% vmax = 13;
% umax = 2;
% umin = -5;
% timestep = 0.01;

k = sig_int_find_k(veh, i);

initial_speed = veh(i, 2);
lane = veh(i, 1);
initial_position = veh(i, 3);
% NOTICE: modify the model name to reflect the current simulatino time
initial_time = get_param('Mcity', 'SimulationTime');


if k == 0 % CAV #1
    estimated_terminal_time = initial_time + 30;
    b = fixedtm_freevm(initial_time, estimated_terminal_time, initial_position, ...
        initial_speed, L);
    [c,fval,exitflag]=fsolve(@no_constraint_active,[b, estimated_terminal_time]);

    v = @(t) (1/2 * c(1) * t^2 + c(2) * t + c(3)) * (initial_time <= t && t <= c(5)) ...
        + vmax * (t > c(5));
    p = @(t) (1/6 * c(1) * t^3 + 1/2 * c(2) * t^2 + c(3) * t + c(4)) ...
        * (initial_time <= t && t <= c(5))...
        + (L + vmax * (t - c(5))) * (t > c(5));
    rem = mod(c(5) + phase, cycle);
    if mod(lane, 2) == 1 % lane 1,3
        if 0 <= rem && rem < 12
            light = green;
        else
            light = red;
        end
    else % lane 2,4
        if 15 <= rem && rem < 27
            light = green;
        else
            light = red;
        end
    end
    
    %% change to fixed time
    if light == red
        lower_bound = floor((c(5) + phase + 3) / cycle) * cycle ...
            - phase - 3 + mod(lane, 2) * (cycle / 2);
        
        c = fixedtm_freevm(initial_time, lower_bound, initial_position, ...
            initial_speed, L);
        v = @(t) (1/2 * c(1) * t^2 + c(2) * t + c(3)) ...
            * (initial_time <= t && t <= lower_bound) ...
            + vmax * (t > lower_bound);
        p = @(t) (1/6 * c(1) * t^3 + 1/2 * c(2) * t^2 + c(3) * t + c(4)) ...
            * (initial_time <= t && t <= lower_bound) ...
            + (L + vmax * (t - lower_bound)) * (t > lower_bound);
    end
else
    % free terminal time with penalization
    estimated_terminal_time = initial_time + 30;
    b = fixedtm_freevm(initial_time, estimated_terminal_time, initial_position, ...
        initial_speed, L);
    [c,fval,exitflag]=fsolve(@no_constraint_active,[b, estimated_terminal_time]);
    v = @(t) (1/2 * c(1) * t^2 + c(2) * t + c(3)) ...
        * (initial_time <= t && t <= c(5)) ...
        + vmax * (t > c(5));
    p = @(t) (1/6 * c(1) * t^3 + 1/2 * c(2) * t^2 + c(3) * t + c(4)) ...
        * (initial_time <= t && t <= c(5)) ...
        + (L + vmax * (t - c(5))) * (t > c(5));
    
    rem = mod(c(5) + phase, cycle);
    if mod(lane, 2) == 1 % lane 1,3
        if 0 <= rem && rem < 12
            light = green;
        else
            light = red;
        end
    else % lane 2,4
        if 15 <= rem && rem < 27
            light = green;
        else
            light = red;
        end
    end
    temp = c(5);
    
    if light == red
        lower_bound = floor((c(5) + phase + 3) / cycle) * cycle ...
            - phase - 3 + mod(lane, 2) * (cycle / 2);
        c(5) = lower_bound;
    end
    
    if c(5) ~= temp
        temp = c(5);
        c = fixedtm_freevm(initial_time, temp, initial_position, ...
            initial_speed, L);
        v = @(t) (1/2 * c(1) * t^2 + c(2) * t + c(3)) ...
            * (initial_time <= t && t <= temp) ...
            + vmax * (t > temp);
        p = @(t) (1/6 * c(1) * t^3 + 1/2 * c(2) * t^2 + c(3) * t + c(4)) ...
            * (initial_time <= t && t <= temp) ...
            + (L + vmax * (t - temp)) * (t > temp);
    end
end
end
