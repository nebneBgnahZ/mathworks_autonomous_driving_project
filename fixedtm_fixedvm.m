function b = fixedtm_fixedvm(v_t0, v_tm, t0, tm, x_t0, x_tm)

Q = [x_t0, v_t0, x_tm, v_tm];
% Decentralized optimal control algorithm
T = [1/6*t0^3 1/2*t0^2 t0 1;
    1/2*t0^2 t0 1 0;
    1/6*tm^3 1/2*tm^2 tm 1;
    1/2*tm^2 tm 1 0];
b = T^-1 *Q';
b = b';
end
