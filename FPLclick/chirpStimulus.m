function y = chirpStimulus (N,dutycycle)
% function y = chirp_stimulus (N,?dutycycle=1?)
% Generates a windowed chirp of length N (column vector) with
% frequencies varying linearly from DC up to the Nyquist rate.
% The chirp has maximum amplitude 0.95.  The chirp is compressed
% and zero padded to that it has the given approximate duty cycle.
% Duty cycles less than 1 effectively provide drain time when the
% chirp is used to measure impulse responses.

if (nargin < 2)
    dutycycle = 1;
end

if ~(dutycycle >= 0 && dutycycle <= 1)
    error ('duty cycle out of range');
end

Nc = round(dutycycle*N);
t = 0:(Nc-1);
y = zeros(1,N);

yc = chirp(t,0,t(end),0.5,'linear',-90);

% scale and window...
%y(1:Nc) = scaleSound(yc.* blacktop(Nc, 95));
y(1:Nc) = scaleSound(rampsound_samples(yc, 32));
y = y(:);
