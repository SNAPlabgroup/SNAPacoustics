%% A script to play a 1 kHz sinusoid out of the sound card and record back
% Use this to measure voltage to MATLAB vector scaling. Note that this
% assumes that the RPvdsEx circuit used will be configured the same way as
% the one used in this program. Make a direct electrical connection between
% the output and input of the card (TDT)

% ----------------------
% Set this before playing
driver = 2; % 1 or 2 for the two channels
Nreps = 10;
card2volts = 5.0; % Measured using get_card2volts.m
gain = 0; % dB, depends on setting on the box and port being used
% -----------------------

% Initializing TDT
fig_num=99;
GB_ch=1;
FS_tag = 3;


[f1RZ,RZ,~]=load_play_circuit(FS_tag,fig_num,GB_ch);


% Make 5 second long 1 kHz sinewave
Fs = 48828.125;
t = 0:(1/Fs):(5 - 1/Fs);
vo = scaleSound(rampsound(sin(2*pi*1000*t), Fs, 0.05));
% Note that max of scaleSound function is 0.95



buffdata = zeros(2, numel(vo));
buffdata(driver, :) = vo; % The other source plays nothing

% Check for clipping and load to buffer
if(any(abs(buffdata(driver, :)) > 1))
    error('What did you do!? Sound is clipping!! Cannot Continue!!\n');
end
%Load the 2ch variable data into the RZ6:
% invoke(RZ, 'WriteTagVEX', 'datain', 0, 'I16', (buffdata*2^15));
% %Set the delay of the sound
% invoke(RZ, 'SetTagVal', 'onsetdel',100); % onset delay is in ms

playrecTrigger = 1;

resplength = numel(t);
vins = zeros(Nreps, resplength);
invoke(RZ, 'SetTagVal', 'nsamps', resplength);
invoke(RZ, 'WriteTagVEX', 'datainL', 0, 'F32', buffdata(1, :));
invoke(RZ, 'WriteTagVEX', 'datainR', 0, 'F32', buffdata(2, :));

%% Set attenuation and play

drop = 0; %dB
invoke(RZ, 'SetTagVal', 'attA', drop);
invoke(RZ, 'SetTagVal', 'attB', drop);
for k = 1:Nreps
    invoke(RZ, 'SoftTrg', playrecTrigger);
    currindex = invoke(RZ, 'GetTagVal', 'indexin');
    while(currindex < resplength)
        currindex=invoke(RZ, 'GetTagVal', 'indexin');
    end
    
    vins(k, :) = invoke(RZ, 'ReadTagVex', 'dataout', 0, resplength,...
        'F32','F64',1);
    % Get ready for next trial
    invoke(RZ, 'SoftTrg', 8); % Stop and clear "OAE" buffer
    pause(0.1);
end




%% Close TDT, ER-10X connections etc. and cleanup
close_play_circuit(f1RZ, RZ);

%% Enter results
vmaxk = max(vins, [], 2);
vmink = min(vins, [], 2);
vppk = vmaxk - vmink;
vpp = trimmean(vppk, 10); % Eclude highest and lowest 10%
volts2card = card2volts*0.95*2 / (vpp * db2mag(gain));
fprintf(1, 'Volts to card conversion is: %f units/volt/unitgain\n', volts2card);
