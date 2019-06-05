function F = no_constraint_active(c)
% terminal constraints specified at an unspecified terminal time
global L
global initial_speed
global initial_time
global gamma
% c
% 1-4: cofficients
% 5: terminal time
F = [
    % p(t0) = 0
    1/6*c(1)*initial_time^3 + 1/2*c(2)*initial_time^2 + c(3)*initial_time + c(4); 
    % v(t0)
    1/2*c(1)*initial_time^2 + c(2)*initial_time + c(3) - initial_speed;
    % p(tm) = L
    1/6*c(1)*c(5)^3 + 1/2*c(2)*c(5)^2 + c(3)*c(5) + c(4) - L;
    % transversality lambda
    c(1)*c(5) + c(2);
    % transversality -> H(tm) = 0
    gamma - 1/2 * c(2)^2 + c(1) * c(3);
    ];

end

