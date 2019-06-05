function unsig_int_12_plotBGIMAGE()
close all

global p1
global p1_color
global p2
global p2_color


l_center = -215;
r_center = 215;
% plot the road line
plot([l_center+15, l_center+15],[15, 415],'k', 'linewidth', 1.5)
hold on
plot([l_center+15, l_center+15],[-15, -415],'k', 'linewidth', 1.5)
hold on
plot([l_center-15, l_center-15],[15, 415],'k', 'linewidth', 1.5)
hold on
plot([l_center-15, l_center-15],[-15, -415],'k', 'linewidth', 1.5)
hold on
plot([l_center+15, l_center+415], [15, 15],'k', 'linewidth', 1.5)
hold on
plot([l_center-15, l_center-415],[15, 15],'k', 'linewidth', 1.5)
hold on
plot([l_center+15, l_center+415], [-15, -15],'k', 'linewidth', 1.5)
hold on
plot([l_center-15, l_center-415],[-15, -15],'k', 'linewidth', 1.5)
hold on
plot([r_center+15, r_center+415], [-15, -15],'k', 'linewidth', 1.5)
hold on
plot([r_center+15, r_center+415], [15, 15],'k', 'linewidth', 1.5)
hold on
plot([r_center+15, r_center+15], [-15, -415],'k', 'linewidth', 1.5)
hold on
plot([r_center-15, r_center-15], [-15, -415],'k', 'linewidth', 1.5)
hold on
plot([r_center+15, r_center+15], [15, 415],'k', 'linewidth', 1.5)
hold on
plot([r_center-15, r_center-15], [15, 415],'k', 'linewidth', 1.5)
hold on


% plot the centerline
plot([-630, l_center-15],[0,0],'--k', 'linewidth', 1)
hold on 
plot([l_center+15, l_center+415],[0,0],'--k', 'linewidth', 1)
hold on 
plot([l_center, l_center],[15, 415],'--k', 'linewidth', 1)
hold on 
plot([l_center, l_center],[-415, -15],'--k', 'linewidth', 1)
hold on 
plot([r_center+15, 630],[0,0],'--k', 'linewidth', 1)
hold on 
plot([r_center, r_center],[-415, -15],'--k', 'linewidth', 1)
hold on
plot([r_center, r_center],[15, 415],'--k', 'linewidth', 1)
hold on

% map size
axis([-630, 630, -415, 415])

% plot the vehicles
N = 1001;
y = zeros(N, N) + 1000; %1000: number of CAVs
p1 = plot(y,'o','MarkerSize',5);
p2 = plot(y,'o', 'MarkerSize',5);
p1_color = zeros(N, 1); % check if a CAV has determined its color
p2_color = zeros(N, 1); % check if a CAV has determined its color
hold on


% vehicle legend
LH(1) = plot(nan, nan, 'o', 'MarkerSize',5,'MarkerEdgeColor',[0 0.4470 0.7410],...
    'MarkerFaceColor',[0 0.4470 0.7410]);
LH(2) = plot(nan, nan, 'o', 'MarkerSize',5,'MarkerEdgeColor',[0.8500 0.3250 0.0980],...
    'MarkerFaceColor',[0.8500 0.3250 0.0980]);
LH(3) = plot(nan, nan, 'o', 'MarkerSize',5,'MarkerEdgeColor',[0.9290 0.6940 0.1250],...
    'MarkerFaceColor',[0.9290 0.6940 0.1250]);
LH(4) = plot(nan, nan, 'o', 'MarkerSize',5,'MarkerEdgeColor',[0.4940 0.1840 0.5560],...
    'MarkerFaceColor',[0.4940 0.1840 0.5560]);
LH(5) = plot(nan, nan, 'o', 'MarkerSize',5,'MarkerEdgeColor',[0.4660 0.6740 0.1880],...
    'MarkerFaceColor',[0.4660 0.6740 0.1880]);
LH(6) = plot(nan, nan, 'o', 'MarkerSize',5,'MarkerEdgeColor',[0.3010 0.7450 0.9330],...
    'MarkerFaceColor',[0.3010 0.7450 0.9330]);
L(1) = "vehicle from West";
L(2) = "vehicle from South";
L(3) = "vehicle from East";
L(4) = "vehicle from North";
L(5) = "vehicle from South";
L(6) = "vehicle from North";

legend(LH, L);
end