function sig_int_plotStatus(lane, speed, pos)
global speed_legend

% set the y-axis back to normal.
if pos > 830
    pos = 2000;
end

t_val = num2str(speed);
txt1 = ['Speed [m/s]: ' , t_val];
speed_legend.String = txt1;
speed_legend.Position(2) = pos - 415;


switch lane
    case 1
        speed_legend.Position(1:2) = [pos - 415, -25];
    case 2
        speed_legend.Position(1:2) = [25, pos - 415];
    case 3
        speed_legend.Position(1:2) = [415 - pos, 25];
    case 4
        speed_legend.Position(1:2) = [-100, 415 - pos];
end
hold on

end