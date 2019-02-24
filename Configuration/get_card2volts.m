%% A script to play a 1 kHz sinusoid out of the sound card
% Use this to measure MATLAB vector to voltage scaling. Note that this
% assumes that the RPvdsEx circuit used will be configured the same way as
% the one used in this program

% ----------------------
% Set this before playing
driver = 1; % 1 or 2 for the two channels
Nreps = 20;
% -----------------------

% Initializing TDT
card = initializeCard;


% Make 1 second long 1 kHz sinewave
Fs = 48828.125;
t = 0:(1/Fs):(1 - 1/Fs);
vo = scaleSound(rampsound(sin(2*pi*1000*t), Fs, 0.05));
% Note that max of scaleSound function is 0.95



buffdata = zeros(2, numel(vo));
buffdata(driver, :) = vo; % The other source plays nothing
drop = 0; %dB

playCapture(buffdata, card, Nreps, drop);

closeCard(card);

%% Enter results
V = input('Enter the peak to peak voltage measured:');
card2volts = V / (2*0.95);
fprintf(1, 'Card to volts conversion is: %f V /unit\n', card2volts);
