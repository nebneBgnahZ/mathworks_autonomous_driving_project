function [pi, vi, ui] = onramp_getStatus_OC(profiles, i)

u = profiles(i).control;
v = profiles(i).speed;
p = profiles(i).position;

t = get_param('Mcity', 'SimulationTime');

pi = p(t);
vi = v(t);
ui = u(t);

end