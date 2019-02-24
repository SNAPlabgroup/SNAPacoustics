% Keefe (1984) tube equations
function [z0,wn] = cav0(f, dcav, Tcav)
 % f must be in Hz
e=1e-9;f(f<e)=e;
r = dcav / 2;
d = Tcav - 26.85;
c = 3.4723e4 * (1 + 0.00166 * d);
rho = 1.1769e-3 * (1 - 0.00335 * d);
eta = 1.846e-4 * (1 + 0.0025 * d);
w = 2 * pi * f(:);
Rv = r * sqrt(rho * w / eta);
x = (1.045 + (1.080 + 0.750 ./ Rv) ./ Rv) ./ Rv;
y = 1 + 1.045 ./ Rv;
wn = (w / c) .* complex(x,y);
z0 = (rho * c) / (pi * r^2);  % char. imped. is constant & real
return
