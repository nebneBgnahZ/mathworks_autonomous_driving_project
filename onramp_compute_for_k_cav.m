function [pi, vi, u] = onramp_compute_for_k_cav(veh, i)


global beta
global delta
global eta
global upsilon
global timestep
global vmax
global vmin
global umax
global umin


vi = veh(i, 2); pi = veh(i, 3);
k = i - 1;

vk = veh(k, 2); pk = veh(k, 3);
v_ref = vmax;
H = [2, 0; 0, 2*upsilon];
f = [0;0];
A_cbf_lim = [1, 0; -1, 0; 1, 0; -1, 0];
b_cbf_lim = [vmax - vi; vi - vmin; umax; -umin];
A_cbf_safety = [beta / (pk - pi - beta*vi - delta)^2, 0];
b_cbf_safety = (vk - vi) / (pk - pi - beta*vi - delta)^2 + pk - pi - beta*vi - delta;
A_clf = [vi - v_ref, -1];
b_clf = -eta * (vi - v_ref)^2;
A = [A_cbf_lim; A_cbf_safety; A_clf];
b = [b_cbf_lim; b_cbf_safety; b_clf];
[x, fval, exitflag, output, lambda] = quadprog(H, f, A, b);
u = x(1);
pi = pi + vi * timestep + 1/ 2 * u * timestep^2;
vi = vi + timestep * u;

end