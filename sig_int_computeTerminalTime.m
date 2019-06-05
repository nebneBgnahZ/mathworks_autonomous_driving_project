function [FinalTime, ExitTime] = sig_int_computeTerminalTime(cav_subsets, iCAV)
FinalSpeed = 10;
delta = 10;
MZ_time = [4, 3, 1];

% find the representative vehicle in CAV subsets
set_e = 0 ;
set_s = 0;
set_l = 0;
set_o = 0;

for k = iCAV-1 : -1 : 1
    if cav_subsets(iCAV, 2) == cav_subsets(k, 2) && cav_subsets(iCAV, 1) ~= cav_subsets(k, 1) % set e
        if set_e == 0
            set_e = k;
            continue;
        end
    else
        if cav_subsets(iCAV, 1) == cav_subsets(k, 1) && (cav_subsets(iCAV, 3) == 1 || cav_subsets(iCAV, 3) == 2)...
                && (cav_subsets(k, 3) == 1 || cav_subsets(k, 3) == 2)% set s (already excluding same lane + same destination)
            if set_s == 0
                set_s = k;
                continue;
            end
        else
            % set l
            if hasConflicts(cav_subsets(k, 1), cav_subsets(k, 2), cav_subsets(iCAV, 1), cav_subsets(iCAV, 2))
                if set_l == 0
                    set_l = k;
                    continue;
                end
            else % set o
                if set_o == 0
                    set_o = k;
                    continue;
                end
            end
        end
    end
end

%% Vehicle Coordination Structure
if (iCAV == 1) % first vehicle entering the network
    FinalTime = 40;
    ExitTime = FinalTime + MZ_time(cav_subsets(iCAV, 3));
else
    if set_e == 0
        a = 0;
    else
        a = cav_subsets(set_e, 5) + delta/FinalSpeed;
    end
    if set_s == 0
        b = 0;
        c = 0;
    else
        b = cav_subsets(set_s, 4) + delta/FinalSpeed + MZ_time(cav_subsets(iCAV, 3));
        c =  cav_subsets(set_s, 5);
    end
    if set_l == 0
        d = 0;
    else
        d = cav_subsets(set_l, 5) + MZ_time(cav_subsets(iCAV, 3));
    end
    if set_o == 0
        e = 0;
    else
        e =  cav_subsets(set_o, 5);
    end
    ExitTime = max([a, b, c, d, e]);
    
    FinalTime = ExitTime - MZ_time(cav_subsets(iCAV, 3));
end

end