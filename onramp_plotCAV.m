function onramp_plotCAV(pos, lane, id)
global p
global p_color
% p.Visible = 'on';
switch lane
    case 1
        if p_color(id) == 0
            p(id).MarkerEdgeColor = [0 0.4470 0.7410];
            p(id).MarkerFaceColor = [0 0.4470 0.7410];
            p_color(id) = 1;
        end
        p(id).XData = pos;
        p(id).YData = 0;
        
    case 2
        if p_color(id) == 0
            p(id).MarkerEdgeColor = [0.8500 0.3250 0.0980];
            p(id).MarkerFaceColor = [0.8500 0.3250 0.0980];
            p_color(id) = 1;
        end
        pos_y = (20 + pos) * 0.5;
        pos_x = (20 + pos) * sqrt(3)/2;
        p(id).XData = 36.27 + pos_x;
        p(id).YData = -210 + pos_y;
end
end