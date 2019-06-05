function F = uvmax_active_fixed_tm(c)
% terminal constraints specified at an unspecified terminal time
global L
global initial_speed
global initial_time
global umax
global vmax
global terminal_time
maximum_speed = vmax;
maximum_acc = umax;

% c
% 1-4: cofficients
% 5: tau1
% 6: tau2
F = [
    % p(tau1)
    initial_speed * (c(5) - initial_time) + 1/2*maximum_acc*(c(5) - initial_time)^2 - (1/6*c(1)*c(5)^3 + 1/2*c(2)*c(5)^2 + c(3)*c(5) + c(4)); 
    % v(tau1)
    initial_speed + maximum_acc*(c(5) - initial_time) - (1/2*c(1)*c(5)^2 + c(2)*c(5) + c(3));
    % u(tau1)
    maximum_acc - (c(1)*c(5) + c(2));
    % u(tau2)
    c(1)*c(6) + c(2);
    % v(tau2) = vmax
    1/2*c(1)*c(6)^2 + c(2)*c(6) + c(3) - maximum_speed;
    % p(tm) = L
    (terminal_time - c(6))*maximum_speed +  1/6*c(1)*c(6)^3 + 1/2*c(2)*c(6)^2 + c(3)*c(6) + c(4) - L;
    ];
end

