function [speed, position, type] = sig_int_getStatus_Mixed(veh, i, type, profiles)
t = get_param('Mcity', 'SimulationTime');

cycle = 30; % Traffic light cycle
phase = 10; % Past green period on West-East

L = 400;
S = 30;
sigma = 1;
theta = 2;
threshold = 15;

vmax = 13;
umax = 2;
umin = -5;
timestep = 0.01;


k = sig_int_find_k(veh, i);
% check if CAV needs to follow IDM
if type == 1 && ((k ~= 0 && veh(k, 3) - veh(i, 3) < threshold))
    type = 0; % change to IDM
end

if type == 0
    current_light = sig_int_computeLightStatus(t, phase, cycle, veh(i, 1));
    vi = veh(i, 2); pi = veh(i, 3);
    p_next_light = sig_int_computeLightPosition(pi, L, S);
    if k == 0 % no preceding vehicle
        if current_light == 1 || pi > L % green
            u = umax * (1 - (vi / vmax)^4);
        else
            s_star = theta + sigma * vi + vi * vi/(2 * sqrt(-umax * umin));
            u = umax * (1 - (vi / vmax)^4 - (s_star / (p_next_light - pi))^2);
        end
    else % leading vehicle exists
        vk = veh(k, 2); pk = veh(k, 3);
        if current_light == 1 || pi >= L% green
            s_star = theta + sigma * vi + vi * (vi - vk)/(2 * sqrt(-umax * umin));
            u = umax * (1 - (vi / vmax)^4 - (s_star / (pk - pi))^2);
        else
            s_star_k = theta + sigma * vi + vi * (vi - vk)/(2 * sqrt(-umax * umin));
            dec_k = (s_star_k / (pk - pi))^2;
            s_star_light = theta + sigma * vi + vi * vi/(2 * sqrt(-umax * umin));
            dec_light = (s_star_light / (p_next_light - pi))^2;
            
            u = umax * (1 - (vi / vmax)^4 - max(dec_k, dec_light));
        end
    end
    v_next = vi + u * timestep;
    if v_next < 0
        v_next = 0; u = (v_next - vi) / timestep;
    end
    position = pi + vi * timestep + 1/2*u*timestep^2;
    % if light == 0 && position >= L
    %     v_next = 0;
    %     position = L - 10e-9;
    % end
    speed = v_next;
    
else
    v = profiles(i).speed;
    p = profiles(i).position;
    speed = v(t + timestep);
    position = p(t + timestep);
end

end

