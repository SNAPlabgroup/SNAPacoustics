function data = playCapture2(buffdata, card, Nreps, throwAway, attA,...
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
%    data - Capured data (Nreps x samples) acquired synchronously with
%    input data being played out
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
data = zeros(Nreps, size(buffdata,2));
for n = 1: (Nreps + throwAway)
    %Start playing from the buffer:
    invoke(card.RZ, 'SoftTrg', playrecTrigger);
    currindex = invoke(card.RZ, 'GetTagVal', 'indexin');
    while(currindex < resplength)
        currindex=invoke(card.RZ, 'GetTagVal', 'indexin');
    end
    
    vin = invoke(card.RZ, 'ReadTagVex', 'dataout', 0, resplength,...
        'F32','F64',1);
    %Accumluate the time waveform - no artifact rejection
    if (n > throwAway)
        data(n-throwAway, :) = vin((delay + 1):end);
    end
    
    % Get ready for next trial
    invoke(card.RZ, 'SoftTrg', 8); % Stop and clear "OAE" buffer
end
%compute the average
