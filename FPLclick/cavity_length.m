function [lk,td]=cavity_length(pc, Tcav, rate, lmn, lmx)
% lmn=1;		% minimum cavity length (cm)
% lmx=12;		% maximum cavity length (cm)
dtc = Tcav - 26.85;
c = 3.4723e4 * (1 + 0.00166 * dtc);
%
imn=round(lmn*1000*rate*2/c)+1; %the tube length is estimated from the half-wave resonant frequency f = 2L/c, find here index of ranges of freq to look for the peaks (but in time domain)
imx=round(lmx*1000*rate*2/c)+1;
% p=irfft(abs(pc).^2);
p=irfft(log(abs(pc))); %CS 3/11/2015
[~,m]=max(p(imn:imx));m=m+imn-1;
d =(p(m-1)-p(m+1))/(p(m-1)-2*p(m)+p(m+1))/2;
td =(m+d-1)/(1000*rate);
lk=td*c/2;
return