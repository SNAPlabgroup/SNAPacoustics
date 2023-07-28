% Plays a tone of a set voltage. Just a convenience script for
% calibrations.
try

    % Initializing TDT
    % Specify path to cardAPI here
    pcard = genpath('C:\Experiments\SNAPacoustics\cardAPI');
    addpath(pcard);
    card = initializeCard;

    fs = card.Fs;

    % Make a tone
    dur = 2;
    f0 = 16000;
    volts_rms = 0.5;
    amplitude = volts_rms * sqrt(2) / card.mat2volts;
    t = 0:(1/fs):dur;
    Nreps = 10;
    risetime = 0.025;

    x = rampsound(sin(2*pi*f0*t) * amplitude, fs, risetime);
    buffdata = zeros(2, numel(t));

    % Decide which channel and set drops accordingly
    buffdata(2, :) = x;
    drop1 = 120;
    drop2 = 0;

    delayComp = true;


    vins = playCapture2(buffdata, card, Nreps, 0, drop1, drop2, delayComp);
    closeCard(card);
    rmpath(pcard);
catch me
    closeCard(card);
    rmpath(pcard);
    rethrow(me);
end