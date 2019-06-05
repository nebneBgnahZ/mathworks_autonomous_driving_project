function sig_int_plotCAV(pos, lane, id)
global p
global p_color
% p.Visible = 'on';
switch lane
    case 1
        if p_color(id) == 0
            p(id).MarkerEdgeColor = [0 0.4470 0.7410];
            p(id).MarkerFaceColor = [0 0.4470 0.7410];
            p_color(id) = 1;
            p(id).YData = -7.5;
        end
        p(id).XData = pos - 415;
%         if (direction == 3) % right turn
%             p(id).YData = -11.25;
%         else
%             p(id).YData = -3.75;
%         end   
    case 2
        if p_color(id) == 0
            p(id).MarkerEdgeColor = [0.8500 0.3250 0.0980];
            p(id).MarkerFaceColor = [0.8500 0.3250 0.0980];
            p_color(id) = 1;
            p(id).XData = 7.5;
        end
        p(id).YData = pos - 415;
%         if (direction == 3)
%             p(id).XData = 11.25;
%         else
%             p(id).XData = 3.75;
%         end     
    case 3
        if p_color(id) == 0
            p(id).MarkerEdgeColor = [0.9290 0.6940 0.1250];
            p(id).MarkerFaceColor= [0.9290 0.6940 0.1250];
            p_color(id) = 1;
            p(id).YData = 7.5;
        end
        p(id).XData = - pos + 415;
%         if (direction == 3)
%             p(id).YData = 11.25;
%         else
%             p(id).YData = 3.75;
%         end   
    case 4
        if p_color(id) == 0
            p(id).MarkerEdgeColor = [0.4940 0.1840 0.5560];
            p(id).MarkerFaceColor = [0.4940 0.1840 0.5560];
            p_color(id) = 1;
            p(id).XData = -7.5;
        end
        p(id).YData = - pos + 415;
%         if (direction == 3)
%             p(id).XData = -11.25;
%         else
%             p(id).XData = -3.75;
%         end     
end
end