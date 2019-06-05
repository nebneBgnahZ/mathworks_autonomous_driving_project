function [profiles, tk, vk] = onramp_computeCAVProfiles(profiles, v0, t0, p0, vk, tk, id)
global initial_speed
global L
global initial_time
global initial_position
global terminal_time
global previous_terminal_time
global previous_terminal_speed
global vmax
global vmin
global umax
global umin
global gamma

vmax = 15;
vmin = 0;
umax = 2;
umin = -5;

gamma = 1;
initial_position = p0;
L = 400;
previous_terminal_time = tk;
previous_terminal_speed = vk;

delta_0 = 10;
if tk == 0
    tf = -Inf;
else
    tf = tk + delta_0 / vk;
end

%% unconstrained
b = no_constraint_active_fixed_tm(t0, t0 + 30, p0, v0, L);
initial_time = t0;
initial_speed = v0;
[c,fval,exitflag]=fsolve(@no_constraint_active,[b(1),b(2),b(3),b(4), t0 + 30]);
lower_bound = getLowerBound(v0, t0, p0, L, vmax, umax);
upper_bound = getUpperBound(v0, t0, p0, L, vmin, umin);
if c(5) > lower_bound && c(5) < upper_bound
    if c(5) > tf
        tf = c(5);
    else
        c = no_constraint_active_fixed_tm(t0, tf, p0, v0, L);
    end
    vm = 1 / 2 * c(1) * tf^2 + c(2) * tf + c(3);
    u_CZ = @(t) c(1) * t + c(2);
    v_CZ = @(t) (1 / 2 * c(1) * t^2 + c(2) * t + c(3)) * (t <= tf) ...
        + vm * (t > tf);
    p_CZ = @(t) (1/6 * c(1) * t^3 + 1/2 * c(2) * t^2 + c(3) * t + c(4)) * (t <= tf) ...
        + (L + vm *(t - tf)) * (t > tf);
    
    
    %% check u and v
    u = @(t) - u_CZ(t);
    v = @(t) - v_CZ(t);
    u_max_ind = fminbnd(u,t0, tf);
    u_max_val = abs(u(u_max_ind));
    v_max_ind = fminbnd(v,t0, tf);
    v_max_val = abs(v(v_max_ind));
    terminal_time = tf;
    if u_max_val > umax && v_max_val > vmax
        [c,fval,exitflag]=fsolve(@uvmax_active_fixed_tm,[c(1),c(2),c(3),c(4), 12, 35]);
        v_CZ = @(t) (v0 + umax*(t - t0)) * (t <= c(5)) ...
            + (1/2 * c(1) * t^2 + c(2) * t + c(3)) * (c(5) < t & t <= c(6))...
            + vmax * (t > c(6));
        u_CZ = @(t) umax * (t <= c(5)) ...
            + (c(1) * t + c(2)) * (c(5) < t & t <= c(6))...
            + 0 * (t > c(6));
        p_CZ = @(t) (v0 * (t - t0) + 1/2*umax*(t - t0)^2)* (t0 <= t & t <= c(5)) ...
            + (1/6 * c(1) * t^3 + 1/2 * c(2) * t^2 + c(3)*t + c(4)) * (c(5) < t & t <= c(6))...
            + (L + vmax * (t - tf)) * (t > c(6));
    else
        if u_max_val > umax
            [c,fval,exitflag]=fsolve(@umax_active_fixed_tm,[c(1),c(2),c(3),c(4), t0 + 5]);
            v_CZ = @(t) (v0 + umax*(t - t0)) * (t0 <= t & t <= c(5)) ...
                + (1/2 * c(1) * t^2 + c(2) * t + c(3)) * (c(5) < t);
            u_CZ = @(t) umax * (t0 <= t & t <= c(5)) ...
                + (c(1) * t + c(2)) * (c(5) < t);
            p_CZ = @(t) (v0 * (t - t0) + 1/2*umax*(t - t0)^2)* (t0 <= t & t <= c(5)) ...
                + (1/6 * c(1) * t^3 + 1/2 * c(2) * t^2 + c(3)*t + c(4)) * (c(5) < t);
        elseif v_max_val > vmax
            [c,fval,exitflag]=fsolve(@vmax_active_fixed_tm,[c(1),c(2),c(3),c(4), tf - 3]);
            v_CZ = @(t) (1/2 * c(1) * t^2 + c(2) * t + c(3))*(t0 <= t & t <= c(5))...
                + vmax * (t > c(5));
            u_CZ = @(t) (c(1) * t + c(2)) * (t0 <= t & t <= c(5)) + 0 * (t > c(5));
            p_CZ = @(t) (1/6 * c(1) * t^3 + 1/2 * c(2) * t^2 + c(3) * t + c(4))*(t0 <= t & t <= c(5))...
                + (L + vmax* (t - tf))* (t > c(5));
        end
    end

else
    if c(5) <= lower_bound
        terminal_time = lower_bound;
        t1 = t0 + (vmax - v0) / umax;
        v_CZ = @(t) (v0 + umax * (t - t0))*(t0 <= t & t <= t1)...
                + vmax * (t > t1);
        u_CZ = @(t) umax * (t0 <= t & t <= t1) + 0 * (t > t1);
        p1 = p0 + v0 * (t1 - t0) + 1/2*umax*(t1 - t0)^2;
        p_CZ = @(t) (v0 * (t - t0) + 1/2*umax*(t -t0)^2)*(t0 <= t & t <= t1)...
            + (p1 + vmax* (t - t1))* (t > t1);
    else
        terminal_time = upper_bound;
        t1 = t0 + (vmin - v0) / umin;
        v_CZ = @(t) (v0 + umin * (t - t0))*(t0 <= t & t <= t1)...
                + vmin * (t > t1);
        u_CZ = @(t) umin * (t0 <= t & t <= t1) + 0 * (t > t1);
        p1 = p0 + v0 * (t1 - t0) + 1/2*umin*(t1 - t0)^2;
        p_CZ = @(t) (v0 * (t - t0) + 1/2*umin*(t -t0)^2)*(t0 <= t & t <= t1)...
            + (p1 + vmin* (t - t1))* (t > t1);
    end
end
profiles(id).position = p_CZ;
profiles(id).speed = v_CZ;
profiles(id).control = u_CZ;
tk = terminal_time;
vk = v_CZ(tk);
end