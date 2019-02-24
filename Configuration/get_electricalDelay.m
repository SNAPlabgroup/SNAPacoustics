%% A script to play clicks out of the sound card and record back
% Use this to measure A/D and D/A total delay. Note that this
% assumes that the RPvdsEx circuit used will be configured the same way as
% the one used in this program. Make a direct electrical connection between
% the output and input of the card (TDT)

% ----------------------
% Set this before playing
driver = 1; % 1 or 2 for the two channels
Nreps = 10;
gain = 0; % dB, depends on setting on the box and port being used
% -----------------------

% Initializing TDT
% Specify path to cardAPI here
pcard = genpath('C:\Experiments\cardAPI\');
addpath(pcard);
card = initializeCard;


% Make 1 sample clicks
Fs = card.Fs;
t = 0:(1/Fs):0.05; % 100 ms buffer
vo = zeros(size(t));
vo(100) = 0.95; % Arbitrarily choose 100th sample as click position
% Note that max of scaleSound function is 0.95

buffdata = zeros(2, numel(vo));
buffdata(driver, :) = vo; % The other source plays nothing

drop = 0;
vins = playCapture(buffdata, card, Nreps, drop, drop, 1);
closeCard(card);
rmpath(pcard);

%% plot results
figure;
plot(t, vo, 'b', 'linew', 2);
hold on;
vins = demean(vins, 2);
plot(t, mean(vins, 1), 'r', 'linew', 2);
[~, indo] = max(abs(vo));
[~, indi] = max(abs(mean(vins, 1)));
delay = indi - indo;
delaystr = ['Delay = ', num2str(delay), ' samples at ', num2str(Fs), ' Hz'];
text(max(t)/3, 0.95, delaystr);


