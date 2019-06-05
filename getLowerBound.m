function lower_bound = getLowerBound(v0, t0, p0, L, vmax, umax)
s0 = (vmax^2 - v0^2)/(2*umax) + p0;
if s0 < L 
    % can reach vmax
    lower_bound = (vmax - v0) / umax + (L - s0)/vmax;
else
    % cannot reach vmax
    vm = sqrt(2*umax*L + v0^2);
    lower_bound = (vm - v0)/umax;
end
lower_bound = lower_bound + t0;
end