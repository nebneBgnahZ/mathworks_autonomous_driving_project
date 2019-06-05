function [speed, position] = sig_int_getStatus_OC(v, p)
t = get_param('Mcity', 'SimulationTime');
speed = v(t);
position = p(t);
end