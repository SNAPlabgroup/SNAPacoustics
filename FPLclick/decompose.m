function [Rl,R0,Rx,pp,pm,p0,px,zo,zi,zx]=decompose(zl,zs,pc,ps,fdw,CavTemp,CavDiam)
[zo,zi,zx]=surge(zl,z_tube(CavTemp,CavDiam),fdw);
Rl=reflect(zl,zo);
Rx=reflect(zl,zx);
R0=reflect(zs,zo);
R0(1)=Rl(1);
pp=pc./(1+Rl);
pm=pp.*Rl;
p0=pp.*(1-R0.*Rl);
px=ps.*(1-R0)/2;
return