function F = umax_active_fixed_tm(c)
% terminal constraints specified at an unspecified terminal time
global L
global initial_speed
global initial_time
global umax
global terminal_time
maximum_acc = umax;
% c
% 1-4: cofficients
% 5: tau
F = [
    % p(tau)
    initial_speed * (c(5) - initial_time) + 1/2*maximum_acc*(c(5) - initial_time)^2 - (1/6*c(1)*c(5)^3 + 1/2*c(2)*c(5)^2 + c(3)*c(5) + c(4)); 
    % v(tau)
    initial_speed + maximum_acc*(c(5) - initial_time) - (1/2*c(1)*c(5)^2 + c(2)*c(5) + c(3));
    % u(tau)
    maximum_acc - (c(1)*c(5) + c(2));
    % p(tm)
    1/6*c(1)*terminal_time^3 + 1/2*c(2)*terminal_time^2 + c(3)*terminal_time + c(4) - L;
    % v(tm) free -> lambda^v(tm) = 0
    c(1)*terminal_time + c(2);
    ];

end

