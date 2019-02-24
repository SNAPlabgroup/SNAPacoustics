function [zs,ps] = thvsrc(zc,pc)

[nf,~]=size(pc);
zs=zeros(nf,1);
ps=zeros(nf,1);
for  k=1:nf
   z = zc(k,:).';
   p = pc(k,:).';
   x = [z   -p] \ (z .* p);
   ps(k) = x(1);
   zs(k) = x(2);
end
return