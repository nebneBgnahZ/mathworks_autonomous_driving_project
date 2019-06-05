function upper_bound = getUpperBound(v0, t0, p0, L, vmin, umin)
% L1: remaining distance to travel
s0 = p0 + (vmin^2 - v0^2)/(2*umin);
if s0 < L
    % can reach vmin
    upper_bound = (vmin - v0) / umin + (L - s0)/vmin;
else
    % cannot reach vmin
    vm = sqrt(2*umin*L + v0^2);
    upper_bound = (vm - v0)/umin;
end
upper_bound = upper_bound + t0;
end