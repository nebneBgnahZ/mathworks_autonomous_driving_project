function onramp_plotPerformanceMetrics(fuel, time)
global fuel_legend
global time_legend
% set the y-axis back to normal.


% t = get_param('TrafficNetwork1110', 'SimulationTime');
% f.XData = t;
% f.YData = fuel;
%subplot(1, 3, 2)
% f = plot(t, fuel,'-o','MarkerEdgeColor','red',...
%     'MarkerFaceColor','red',...
%     'MarkerSize',3);
t_val = num2str(fuel);
txt1 = t_val;
fuel_legend.String = txt1;
% hold on
% f_opt = plot(t, fuel_opt,'-o','MarkerEdgeColor','blue',...
%     'MarkerFaceColor','blue',...
%     'MarkerSize',3);
% t_val = num2str(fuel_opt);
% txt1 = t_val;
% text(200, 200, txt1);
%
% axis([0, 200, 0, 20]);
% axis manual
% hold on

%subplot(1, 3, 3)
% d = plot(t, time,'-o','MarkerEdgeColor','red',...
%     'MarkerFaceColor','red',...
%     'MarkerSize',3);
t_val = num2str(time);
txt1 = t_val;
time_legend.String = txt1;

% axis([0, 200, 0, 60]);
% axis manual
hold on
end