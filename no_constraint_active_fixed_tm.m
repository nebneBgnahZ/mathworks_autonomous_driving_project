function b = no_constraint_active_fixed_tm(t0, tf, x_t0, v_t0, x_tf)
% no terminal constraints given fixed terminal time
Q = [x_t0, v_t0, x_tf, 0];
T = [1/6*t0^3 1/2*t0^2 t0 1;
    1/2*t0^2 t0 1 0;
    1/6*tf^3 1/2*tf^2 tf 1;
    tf 1 0 0];
b = T^-1 *Q';
end

