function [p, v, u] = onramp_getCruiseStatus(pos, speed, step)
p = pos + speed * step;
v = speed;
u = 0;

   