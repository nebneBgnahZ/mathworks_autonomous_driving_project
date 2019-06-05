global p
global p_color

global speed_legend

% plot the vehicles
N = 1001;
y = zeros(N, N) + 1000; %1000: number of CAVs
%y = zeros(1,1);
p = plot(y,'o','MarkerSize',5);
p_color = zeros(1, N); % check if a CAV has determined its color
hold on

%% plot the speed for 4 and 5
t_val = num2str(0);
txt1 = ['Speed [m/s]: ' , t_val];
speed_legend = text(1000, 1000, txt1);
hold on
