% smooth load impedance by restricting TDR via LR
function zl=zsmo(zl,zo,rate)
fr=[0.020 24.414];   % frequency range (kHz)
ti=[-0.5   2];   % time interval (ms)
nf=length(zl);
nt=2*(nf-1);
rk=rate/1000;
fr=round(fr/rk*nt);
ti=round(ti*rk);
f=(fr(1):fr(2))';
t=(ti(1):ti(2))/nt;
ii=f+1;
A=exp(-1i*2*pi*f*t);
AA=[real(A);imag(A)];
rl=(zl(ii)-zo)./(zl(ii)+zo);
rt=AA\[real(rl);imag(rl)];
rf=zeros(size(zl));
rf(ii)=A*rt;
zl=zo*(1+rf)./(1-rf);
return