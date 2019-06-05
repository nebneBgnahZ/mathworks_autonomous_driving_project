function [v, p] = unsig_int_12_computeCAVProfiles(v0, vm, tm, p0)

L = 400;
t0 = get_param('Mcity', 'SimulationTime');
b = fixedtm_fixedvm(v0, vm, t0, tm, p0, L);
v = @(t) (1/2 * b(1) * t^2 + b(2) * t + b(3)) * (t0 <= t && t < tm) ...
    + vm * (t >= tm);
p = @(t) (1/6 * b(1) * t^3 + 1/2 * b(2) * t^2 + b(3) * t + b(4)) ...
    * (t0 <= t && t < tm) + (L + vm * (t - tm)) * (t >= tm);
end
