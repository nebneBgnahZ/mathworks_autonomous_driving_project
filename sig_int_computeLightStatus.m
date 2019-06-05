function green = sig_int_computeLightStatus(time, phase, cycle, lane)

rem = mod(time + phase, cycle);
if (rem <= 12 && (lane == 1 || lane == 3)) || (15 <= rem && rem < 27 && (lane == 2 || lane == 4))
    green = 1;
else
    green = 0;
end
end