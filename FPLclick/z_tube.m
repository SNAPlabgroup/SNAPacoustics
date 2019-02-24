% characteristic impedance
function zo = z_tube(CavTemp, CavDiam)
c = 3.4723e4 * (1 + 0.00166 * ( - 26.85));
rho = 1.1769e-3 * (1 - 0.00335 * (CavTemp - 26.85));
zo = (rho * c) / (pi * (CavDiam / 2)^2);
return