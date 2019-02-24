% thverr - calculate error between measured and calculated pressure
function err = thverr(la, ej, freq, pcav,irr, dcav,Tcav)
f = freq(ej);
pc = pcav (ej,:);
xtk = 1; %estimate cros talk?
if (la(end)>1.001)
    err=1e6;
    return;
end
% if (min(pa)<0)   err=1e9; return; end
% if (max(pa)>1e9) err=1e9; return; end
[~,nc] = size(pc);         % number of cavities
[zc,~] = cavimp(f,la,irr, dcav,Tcav);     % calculate cavity impedances

[zs,ps] = thvsrc(zc,pc);    % estimate zs & ps
ps = ps(:) * ones(1,nc);
zs = zs(:) * ones(1,nc);
pd = pc - ps .* zc ./ (zs + zc);
pd(1,:) = 0;
s1 = sum(sum(abs(pd).^2));
s2 = sum(sum(abs(pc).^2));
if (xtk)
    s1 = s1 - sum(abs(sum(pd,2)).^2) / nc;
end
err = 1e4 * s1 / s2;
return
