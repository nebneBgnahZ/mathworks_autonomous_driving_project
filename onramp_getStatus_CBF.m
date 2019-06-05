function [pi, vi, ui, p_val] = onramp_getStatus_CBF(veh, i, p_val)

global L
global beta % reaction time
global delta % standstill inter-vehicle distance
global gamma % coefficient for travel time in cost functional
global eta % relaxation variable for Ly
global upsilon % penalty term for relaxation
global vmax
global vmin
global umax
global umin
global timestep

L = 400;
beta = 1;
delta = 0;
eta = 10;
gamma = 0.1;
upsilon = 10;
vmax = 15;
vmin = 0;
umax = 2;
umin = -5;
timestep = 0.01;

if i == 1 || (i-1 ~= 0 && veh(i-1,3) > 501) 
    % first vehicle or preceding vehicle exits the merging area
    [pi, vi, ui] = onramp_compute_for_1st_cav(veh, i);
else
    [pi, vi, ui] = onramp_compute_for_k_cav(veh, i);
end

end