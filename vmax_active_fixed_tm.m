function F = vmax_active_fixed_tm(c)
% terminal constraints specified at an unspecified terminal time
global L
global initial_speed
global initial_time
global vmax
global terminal_time
maximum_speed = vmax;
% c
% 1-4: cofficients
% 5: tau
F = [
    % p(t0) = 0
    1/6*c(1)*initial_time^3 + 1/2*c(2)*initial_time^2 + c(3)*initial_time + c(4); 
    % v(t0)
    1/2*c(1)*initial_time^2 + c(2)*initial_time + c(3) - initial_speed;
    % v(tm) free -> lambda^v(tm) = 0
    c(1)*c(5) + c(2);
    % v(tau) = vmax
    1/2*c(1)*c(5)^2 + c(2)*c(5) + c(3) - maximum_speed;
    % p(tm) = L
    (terminal_time - c(5))*maximum_speed +  1/6*c(1)*c(5)^3 + 1/2*c(2)*c(5)^2 + c(3)*c(5) + c(4) - L;
    ];

end

