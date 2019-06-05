function [pi, vi, u] = onramp_compute_for_1st_cav(veh, i)

global eta % relaxation variable for Ly
global upsilon % penalty term for relaxation
global vmax
global vmin
global umax
global umin
global timestep

vi = veh(i, 2); pi = veh(i, 3);

v_ref = vmax;
H = [2, 0; 0, 2*upsilon];
f = [0;0];
A_cbf_lim = [1, 0; -1, 0; 1, 0; -1, 0];
b_cbf_lim = [vmax - vi; vi - vmin; umax; -umin];
A_clf = [vi - v_ref, -1];
b_clf = -eta * (vi - v_ref)^2;
A = [A_cbf_lim; A_clf];
b = [b_cbf_lim; b_clf];
[x, fval, exitflag, output, lambda] = quadprog(H, f, A, b);
u = x(1);
pi = pi + vi * timestep + 1/ 2 * u * timestep^2;
vi = vi + timestep * u;

end