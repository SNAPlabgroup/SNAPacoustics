function y = rampsound_samples(x,Nramp)
% Function to ramp a sound file using a dpss ramp
% USAGE:
% y = rampsound_samples(x,Nramp)
%
% risetime in samples
% Hari Bharadwaj

w = dpss(2*Nramp,1,1);

w = w - w(1);
w = w/max(w);
sz = size(x);

wbig = [w(1:Nramp); ones(numel(x)- 2*Nramp,1); w((end-Nramp+1):end)];

if(sz(1)== numel(x))
    y = x.*wbig;
else
    y = x.*wbig';
end

