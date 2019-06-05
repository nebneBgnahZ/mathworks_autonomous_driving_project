function fuel = onramp_computeFuelConsumption(f, v, u, step_size)
% fuel consumption model
b = [0.1569, 0.02450,-0.0007415,0.00005975];
c = [0.07224, 0.09681,0.001075];
fuel = f + step_size * (u * (c(1) + c(2)*v + c(3)*v^2) +(b(1) + b(2)*v + b(3)*v^2 + b(4)*v^3));
end
