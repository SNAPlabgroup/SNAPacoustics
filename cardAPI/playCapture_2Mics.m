function [data1, data2] = playCapture_2Mics(buffdata, card, Nreps, throwAway, attA,...
    attB, delayComp)
% USAGE:
%    data = playCapture(buffdata, card, Nreps, attA, attB, delayComp);
%
% INPUTS:
%    buffdata - Input data (channels(two) x samples)
%    card - AD card structure from initializeCard()
%    Nreps - Number of repetitions of the stimulus
%    throwAway - Number of beginning trials to throw away
%    [attA] - Analog attenuation to use on channel #1 (dB, default = 45)
%    [attB] - Analog attenuation to use on channel #2 (dB, default = attA)
%    [delayComp] - Whether to compensate for AD delay (default = 1)
%
% OUTPUTS:
%    data1 - Capured data  (Nreps x samples) acquired synchronously with
%    input data being played out for the first Mic (channel A of RZ6)
%    data2 - Similar to data1 but for the second Mic (channel B of RZ6)
%
% -------------------------
% Copyright Hari Bharadwaj. All rights reserved.
% hbharadwaj@purdue.edu
% -------------------------

if ~exist('attA', 'var')
    attA = 45;
end

if ~exist('attB', 'var')
    attB = attA;
end

if ~exist('delayComp', 'var')
    delayComp = 1;
end


% Check for clipping and load to buffer
if(any(abs(buffdata(:)) > 1))
    error('What did you do!? Sound is clipping!! Cannot Continue!!\n');
end


playrecTrigger = 1;

if delayComp
    delay = card.ADdelay; % Samples
else
    delay = 0;
end

resplength = size(buffdata, 2) + delay; % How many samples to read from OAE buffer
pol = -1;
invoke(card.RZ, 'SetTagVal', 'nsamps', resplength);
invoke(card.RZ, 'WriteTagVEX', 'datainL', 0, 'F32', pol*buffdata(1, :));
invoke(card.RZ, 'WriteTagVEX', 'datainR', 0, 'F32', pol*buffdata(2, :));
%% Set attenuation and play

invoke(card.RZ, 'SetTagVal', 'attA', attA);
invoke(card.RZ, 'SetTagVal', 'attB', attB);
% Play chirp and measure response
data1 = zeros(Nreps, size(buffdata,2));
data2 = zeros(Nreps, size(buffdata,2));
fprintf(1, '\nRunning play sound and capture response...\n');
for n = 1: (Nreps + throwAway)
    %Start playing from the buffer:
    invoke(card.RZ, 'SoftTrg', playrecTrigger);
    currindex = invoke(card.RZ, 'GetTagVal', 'indexinA');
    while(currindex < resplength)
        currindex=invoke(card.RZ, 'GetTagVal', 'indexinA');
    end
    
    vinA = invoke(card.RZ, 'ReadTagVex', 'dataoutA', 0, resplength,...
        'F32','F64',1);
    vinB = invoke(card.RZ, 'ReadTagVex', 'dataoutB', 0, resplength,...
        'F32','F64',1);
    %Accumluate the time waveform - no artifact rejection
    if (n > throwAway)
        data1(n-throwAway, :) = vinA((delay + 1):end);
        data2(n-throwAway, :) = vinB((delay + 1):end);
    end
    
    % Print something every 128 reps
    if mod(n, 128) == 0
        fprintf(1, 'Dont with %d / %d reps ...\n', n, Nreps + throwAway);
    end
    % Get ready for next trial
    invoke(card.RZ, 'SoftTrg', 8); % Stop and clear "OAE" buffer
end
%compute the average
