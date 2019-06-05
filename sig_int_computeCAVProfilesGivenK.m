function [v, p, tm, vm] = sig_int_computeCAVProfilesGivenK(v0, p0, tkm, vkm, lane)
% initial_speed, initial_position, terminal_time_k, terminal_speed_k, lane

global L
global initial_time
global initial_speed
global gamma

L = 400;
gamma = 0.1;
desired_speed = 10;
delta = 10;
green = 1;
red = 2;

initial_speed = v0;
initial_position = p0;
terminal_time_k = tkm;
terminal_speed_k = vkm;

light_cycle = 30; % Traffic light cycle
light_phase = 10; % Past green period on West-East


% NOTICE: modify the model name to reflect the current simulatino time
initial_time = get_param('Mcity', 'SimulationTime');

if terminal_time_k == 0 % CAV #1
    estimated_terminal_time = initial_time + 30;
    b = fixedtm_freevm(initial_time, estimated_terminal_time, initial_position, ...
        initial_speed, L);
    [c,fval,exitflag]=fsolve(@no_constraint_active,[b, estimated_terminal_time]);
    v = @(t) (1/2 * c(1) * t^2 + c(2) * t + c(3)) * (initial_time <= t && t <= c(5)) ...
        + desired_speed * (t > c(5));
    p = @(t) (1/6 * c(1) * t^3 + 1/2 * c(2) * t^2 + c(3) * t + c(4)) ...
        * (initial_time <= t && t <= c(5))...
        + (L + desired_speed * (t - c(5))) * (t > c(5));
    rem = mod(c(5) + light_phase, light_cycle);
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
    tm = c(5);
    %vm = v(tm);
    vm = desired_speed;
    %% change to fixed time
    if light == red
        lower_bound = floor((c(5) + light_phase + 3) / light_cycle) * light_cycle ...
            - light_phase - 3 + mod(lane, 2) * (light_cycle / 2);
        
        c = fixedtm_freevm(initial_time, lower_bound, initial_position, ...
            initial_speed, L);
        v = @(t) (1/2 * c(1) * t^2 + c(2) * t + c(3)) ...
            * (initial_time <= t && t <= lower_bound) ...
            + desired_speed * (t > lower_bound);
        p = @(t) (1/6 * c(1) * t^3 + 1/2 * c(2) * t^2 + c(3) * t + c(4)) ...
            * (initial_time <= t && t <= lower_bound) ...
            + (L + desired_speed * (t - lower_bound)) * (t > lower_bound);
        %     upper_bound = lower_bound + 15;
        %     c = fixedtm_freevm(initial_time, upper_bound, initial_position, ...
        %         initial_speed, L);
        %     v = @(t) 1/2 * c(1) * t^2 + c(2) * t + c(3);
        %     fplot(v, [initial_time, upper_bound]);
        %     hold on
        tm = lower_bound;
        %vm = v(tm);
        vm = desired_speed;
    end
else
    % free terminal time with penalization
    estimated_terminal_time = initial_time + 30;
    b = fixedtm_freevm(initial_time, estimated_terminal_time, initial_position, ...
        initial_speed, L);
    [c,fval,exitflag]=fsolve(@no_constraint_active,[b, estimated_terminal_time]);
    v = @(t) (1/2 * c(1) * t^2 + c(2) * t + c(3)) ...
        * (initial_time <= t && t <= c(5)) ...
        + desired_speed * (t > c(5));
    p = @(t) (1/6 * c(1) * t^3 + 1/2 * c(2) * t^2 + c(3) * t + c(4)) ...
        * (initial_time <= t && t <= c(5)) ...
        + (L + desired_speed * (t - c(5))) * (t > c(5));
    
    rem = mod(c(5) + light_phase, light_cycle);
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
    
    if light == green
        if c(5) < terminal_time_k + delta / terminal_speed_k
            c(5) = terminal_time_k + delta / terminal_speed_k;
            rem = mod(c(5) + light_phase, light_cycle);
            if mod(lane, 2) == 1 % lane 1,3
                if 0 <= rem && rem < 12
                    temp_light = green;
                else
                    temp_light = red;
                end
            else % lane 2,4
                if 15 <= rem && rem < 27
                    temp_light = green;
                else
                    temp_light = red;
                end
            end
            if temp_light == red
                c(5) = floor((c(5) + light_phase + 3) / light_cycle) * light_cycle ...
                    - light_phase + light_cycle / 2 + mod(lane, 2) * (light_cycle / 2);
            end
        end
    else
        lower_bound = floor((c(5) + light_phase + 3) / light_cycle) * light_cycle ...
            - light_phase - 3 + mod(lane, 2) * (light_cycle / 2);
        upper_bound = lower_bound + light_cycle / 2 + 3;
        if c(5) >= terminal_time_k + delta / terminal_speed_k
            if (lower_bound >= terminal_time_k + delta / terminal_speed_k)
                c(5) = lower_bound;
            else
                c(5) = upper_bound;
            end
        else
            c(5) = terminal_time_k + delta / terminal_speed_k;
            rem = mod(c(5) + light_phase, light_cycle);
            if mod(lane, 2) == 1 % lane 1,3
                if 0 <= rem && rem < 12
                    temp_light = green;
                else
                    temp_light = red;
                end
            else % lane 2,4
                if 15 <= rem && rem < 27
                    temp_light = green;
                else
                    temp_light = red;
                end
            end
            if temp_light == red
                c(5) = floor((c(5) + light_phase + 3) / light_cycle) * light_cycle ...
                   - light_phase + light_cycle / 2 + mod(lane, 2) * (light_cycle / 2);
            end
        end
    end
    
    if c(5) ~= temp
        temp = c(5);
        c = fixedtm_freevm(initial_time, temp, initial_position, ...
            initial_speed, L);
        v = @(t) (1/2 * c(1) * t^2 + c(2) * t + c(3)) ...
            * (initial_time <= t && t <= temp) ...
            + desired_speed * (t > temp);
        p = @(t) (1/6 * c(1) * t^3 + 1/2 * c(2) * t^2 + c(3) * t + c(4)) ...
            * (initial_time <= t && t <= temp) ...
            + (L + desired_speed * (t - temp)) * (t > temp);
    end
    tm = temp;
    %vm = v(temp);
    vm = desired_speed;
end
