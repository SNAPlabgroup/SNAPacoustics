function [zc,z0] = cavimp(f,L,irr,dcav,Tcav)
if (irr == 1)
    rc=L(end);
    L=L(1:(end-1));
else
    rc=1;
end

[z0,gam] = cav0(f,dcav,Tcav);
R = rc * exp(-2 * gam * L);
zc = z0 .* (1 + R) ./ (1 - R);
% if (irr)
%    L=L(1:(end-1));
%    rc=L(end);
% else
%    L=L;
%    rc=1e9;
% end
%
% [z0,gam] = cav0(f);
% tn = tanh(gam * L);
% zc = z0 .* (rc + z0 .* tn) ./ (z0 + rc .* tn);
return