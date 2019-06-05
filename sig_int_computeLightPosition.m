function p_next_light = sig_int_computeLightPosition(p, L, S)

if p < L
    p_next_light = L;
else
    p_next_light = L * 2 + S;
end

end