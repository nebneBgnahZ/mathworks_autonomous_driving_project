function [speed, position] = sig_int_getStatus_IDM(veh, i, cycle, phase)
t = get_param('Mcity', 'SimulationTime');

L = 400;
S = 30;
beta = 1;
delta = 2;

vmax = 13;
umax = 2;
umin = -5;
timestep = 0.01;


light = sig_int_computeLightStatus(t, phase, cycle, veh(i, 1));
k = sig_int_find_k(veh, i);
vi = veh(i, 2); pi = veh(i, 3);

p_next_light = sig_int_computeLightPosition(pi, L, S);
if k == 0 % no preceding vehicle
    if light == 1 || pi > L % green
        u = umax * (1 - (vi / vmax)^4);
    else
        s_star = delta + beta * vi + vi * vi/(2 * sqrt(-umax * umin));
        u = umax * (1 - (vi / vmax)^4 - (s_star / (p_next_light - pi))^2);
    end
else % leading vehicle exists
    vk = veh(k, 2); pk = veh(k, 3);
    if light == 1 || pi >= L% green
        s_star = delta + beta * vi + vi * (vi - vk)/(2 * sqrt(-umax * umin));
        u = umax * (1 - (vi / vmax)^4 - (s_star / (pk - pi))^2);
    else
        s_star_k = delta + beta * vi + vi * (vi - vk)/(2 * sqrt(-umax * umin));
        dec_k = (s_star_k / (pk - pi))^2;
        s_star_light = delta + beta * vi + vi * vi/(2 * sqrt(-umax * umin));
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
end

