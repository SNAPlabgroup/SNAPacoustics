% surge impedance 
% usage: [zo,zi,zx]=surge(zl,zo,fdw)
% zl  - load impedance
% zo  - tube impedance
% fdw - bandwidth / Nyquist_frequency
function [zo,zi,zx]=surge(zl,zo,fdw)
nf=length(zl);
w=2*pi*(0:(nf-1))'/(nf-1);
s=1i*w;
v0=fd_window(ones(size(zl)),1,fdw);
v1=fd_window(sin(w),1,fdw);
v0=v0/sum(v0);
v1=v1/sum(v1);
z1=-sum(imag(zl).*v1);
zn=z1/2;
zi=abs(sum(imag(zl).*w)/sum(w.*w))/4;
zx=zo+zn+zi*s;
for k=1:40        % iterate
   rl=(zl-zx)./(zl+conj(zx));
   zo=zo*(1+sum(real(rl).*v0));
   zi=zi*(1+sum(imag(rl).*v1));
   zx=zo+zn+zi.*s;
end
return