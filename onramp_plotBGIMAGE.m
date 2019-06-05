function onramp_plotBGIMAGE()
close all

global p
global p_color
global fuel_legend
global time_legend

% plot the road line
plot([-20,500],[10,10],'k',[-20,500],[0,0],'k--',...
    [-20,362.68],[-10,-10],'k',[402.68,500],[-10,-10],'k',...
    [24.53,362.28],[-205,-10],'k',[36.27,400],[-210,0],'k--',...
    [42.88,402.28],[-217.5,-10],'k', 'linewidth', 1.5);
hold on;


% plot the vehicles
N = 1001;
y = zeros(N, N) + 1000; %1000: number of CAVs
%y = zeros(1,1);
p = plot(y,'o','MarkerSize',5);
p_color = zeros(1, N); % check if a CAV has determined its color
hold on

axis([-20, 500, -217.5, 10])

% vehicle legend
LH(1) = plot(nan, nan, 'o', 'MarkerSize',5,'MarkerEdgeColor',[0 0.4470 0.7410],...
    'MarkerFaceColor',[0 0.4470 0.7410]);
LH(2) = plot(nan, nan, 'o', 'MarkerSize',5,'MarkerEdgeColor',[0.8500 0.3250 0.0980],...
    'MarkerFaceColor',[0.8500 0.3250 0.0980]);
L(1) = "vehicle on freeway";
L(2) = "vehicle from freeway on-ramp";
legend(LH, L, 'Location', 'southeast');

%% plot the performance display box
t_val = num2str(0);
txt1 = t_val;
text(200, -140, 'Average Fuel Consumption [ml]:');
fuel_legend = text(430, -140, txt1);
hold on
text(200, -160, 'Average Travel Time [s]:');
time_legend = text(430, -160, txt1);

end