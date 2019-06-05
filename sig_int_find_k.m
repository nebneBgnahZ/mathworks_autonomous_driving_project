function k = find_k(veh, i)

j = i - 1;
while j > 0
    if veh(j, 1) ~= veh(i, 1)
        j = j - 1;
    else
        break;
    end
end
k = j;

end