function noise = makeEqExNoise(bw,fc,tmax,fs,rampSize,playplot)
% USAGE:
%    noise = makeEqExNoiseFFT(bw,fc,tmax,fs,rampSize,playplot);
%  e.g.:
%    noise = makeNBNoiseFFT(50,1000,0.6,48828.125,0.025,1);
% Makes notched noise with different bandwidths. RMS is 0.1 always.
%  bw - Bandwidth of noise in Hz (two-side)
%  tmax - Duration of noise in seconds
%  fs - Sampling rate
%  fc - center frequency in Hz
%  rampSize - seconds
%  playplot - Whether to play the noise (using sound(.)) and plot it's
%                 waveform and spectrum
%-----------------------------------------------------
%% Settings

if(~exist('fs','var'))
    fs = 48828.125; % Sampling Rate
end

if(~exist('tmax','var'))
    tmax = 0.6; % Duration in Seconds
end

if(~exist('rampSize','var'))
    rampSize = 0.025; %In seconds
end

if(~exist('fc','var'))
    fc = 1000;
end


fmin = fc - bw/2;
fmax = fc + bw/2;

if(~exist('playplot','var'))
    playplot = 0;
end

%-----------------------------------------------------
t = 0:(1/fs):(tmax - 1/fs);


%% Making Noise
order = floor(numel(t)/2);
noisetemp = randn(1, numel(t) + order + 1);
f1 = fmin * 2 / fs;
f2 = fmax * 2 / fs;
f = linspace(0, 1.0, 2048);
a = zeros(size(f));
ind = find((f>=f1) & (f <= f2));
a(ind) = (f(ind)/f1).^(-0.65);
b = fir2(order,f,a);
noise = fftfilt(b, noisetemp);
noise = noise((order+1):(order+numel(t)));

if(playplot)
    plot(t,noise);
    [pxx,f] = pmtm(noise,4,[],fs);
    figure; semilogx(f,pow2db(pxx)); xlim([500, 20e3]);
    soundsc(noise,fs);
end

