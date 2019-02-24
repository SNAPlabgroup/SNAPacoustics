function zl = ldimp(zs,ps,pl)
[nf,nc]=size(pl);
for k=1:nc
   zl(:,k)=zs.*pl(:,k)./(ps-pl(:,k));
end
% [nf,nc]=size(pl);
% zl = zeros(size(pl));
% m = 2:nf;
% for k=1:nc
%    zl(1,k)=zs(1);
%    zl(m,k)=zs(m).*pl(m,k)./(ps(m)-pl(m,k));
% end
return