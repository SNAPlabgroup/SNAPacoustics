% frequency-domain window
% usage: H = fd_window(H,srf,fdw)
% H   - transfer function
% srf - sampling-rate factor
% fdw - bandwidth / Nyquist_frequency
function H=fd_window(H,srf,fdw)
if (fdw<=0)
    return;
end
n=length(H)-1;
p=pi*(0:n)'/n/fdw;
a=0.16;                 % Blackman window
w=(1-a+cos(p)+a*cos(2*p))/2;
w(p>pi)=0;
Z=zeros((srf-1)*n,1);   % zero padding
H=[H.*w;Z];
return