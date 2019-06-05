function [p, v] = getCruiseStatus(pos, speed, step)
p = pos + speed * step;
v = speed;

   