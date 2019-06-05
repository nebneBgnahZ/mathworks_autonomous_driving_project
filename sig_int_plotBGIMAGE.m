function sig_int_plotBGIMAGE()

global p
global p_color

global speed_legend
global p_tlc

% plot the road line
plot([15, 15],[15, 415],'k', 'linewidth', 1.5)
hold on
plot([15, 15],[-15, -415],'k', 'linewidth', 1.5)
hold on
plot([-15, -15],[15, 415],'k', 'linewidth', 1.5)
hold on
plot([-15, -15],[-15, -415],'k', 'linewidth', 1.5)
hold on
plot([15, 415], [15, 15],'k', 'linewidth', 1.5)
hold on
plot([-15, -415],[15, 15],'k', 'linewidth', 1.5)
hold on
plot([15, 415], [-15, -15],'k', 'linewidth', 1.5)
hold on
plot([-15, -415],[-15, -15],'k', 'linewidth', 1.5)
hold on

% plot the centerline
plot([-415, -15],[0,0],'--k', 'linewidth', 1)
hold on 
plot([15, 415],[0,0],'--k', 'linewidth', 1)
hold on 
plot([0, 0],[15, 415],'--k', 'linewidth', 1)
hold on 
plot([0, 0],[-415, -15],'--k', 'linewidth', 1)
hold on 

% % plot the trajectory
% plot([-415, -15],[7.5, 7.5],'-.k', 'linewidth', 1)
% hold on 
% plot([15, 415],[7.5, 7.5],'-.k', 'linewidth', 1)
% hold on 
% plot([-415, -15],[-7.5, -7.5],'-.k', 'linewidth', 1)
% hold on 
% plot([15, 415],[-7.5, -7.5],'-.k', 'linewidth', 1)
% hold on 
% plot([7.5, 7.5], [-415, -15],'-.k', 'linewidth', 1)
% hold on 
% plot([7.5, 7.5], [15, 415],'-.k', 'linewidth', 1)
% hold on 
% plot([-7.5, -7.5], [-415, -15],'-.k', 'linewidth', 1)
% hold on
% plot([-7.5, -7.5], [15, 415],'-.k', 'linewidth', 1)


% plot the traffic lights
tlc = zeros(4,4);
p_tlc = plot(tlc, 's', 'MarkerSize', 8, 'MarkerEdgeColor', 'red', ...
    'MarkerFaceColor', 'red');
p_tlc(1).MarkerEdgeColor = 'green';
p_tlc(1).MarkerFaceColor = 'green';
p_tlc(3).MarkerEdgeColor = 'green';
p_tlc(3).MarkerFaceColor = 'green';
p_tlc(1).XData = -15; p_tlc(1).YData = -7.5;
p_tlc(2).XData = 7.5; p_tlc(2).YData = -15;
p_tlc(3).XData = 15; p_tlc(3).YData = 7.5;
p_tlc(4).XData = -7.5; p_tlc(4).YData = 15;

% map size
axis([-415, 415, -415, 415])

% legend

% vehicle legend
LH(1) = plot(nan, nan, 'o', 'MarkerSize',5,'MarkerEdgeColor',[0 0.4470 0.7410],...
    'MarkerFaceColor',[0 0.4470 0.7410]);
LH(2) = plot(nan, nan, 'o', 'MarkerSize',5,'MarkerEdgeColor',[0.8500 0.3250 0.0980],...
    'MarkerFaceColor',[0.8500 0.3250 0.0980]);
LH(3) = plot(nan, nan, 'o', 'MarkerSize',5,'MarkerEdgeColor',[0.9290 0.6940 0.1250],...
    'MarkerFaceColor',[0.9290 0.6940 0.1250]);
LH(4) = plot(nan, nan, 'o', 'MarkerSize',5,'MarkerEdgeColor',[0.4940 0.1840 0.5560],...
    'MarkerFaceColor',[0.4940 0.1840 0.5560]);
LH(5) = plot(nan, nan, 's', 'MarkerSize',7,'MarkerEdgeColor','green',...
    'MarkerFaceColor','green');
LH(6) = plot(nan, nan, 's', 'MarkerSize',7,'MarkerEdgeColor','red',...
    'MarkerFaceColor','red');
LH(7) = plot(nan, nan, 's', 'MarkerSize',7,'MarkerEdgeColor','yellow',...
    'MarkerFaceColor','yellow');
L(1) = "vehicle from West";
L(2) = "vehicle from South";
L(3) = "vehicle from East";
L(4) = "vehicle from North";
L(5) = "Green light";
L(6) = "Red light";
L(7) = "Amber light";
legend(LH, L);

end