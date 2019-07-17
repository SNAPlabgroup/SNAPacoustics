%% Plays a chirp, records response, and plots RFFT
% Initialize ER-10X  (Also needed for ER-10C for calibrator)
p10x = genpath('C:\Experiments\ER-10X\MATLABAPI\Matlab\');
addpath(p10x);
loaded = ER10XConnectLoadLib('C:\Experiments\ER-10X\MATLABAPI\');
[err, ER10XHandle] = er10x_open();
fprintf(1, 'Result of ER10_X_OPEN: %s\n', err);
if strcmp(err, 'ER10X_ERR_OK')
    fprintf('Continuing...\n');
else
    error('Something wrong! Could not open ER10X!');
end
err = er10x_connect(ER10XHandle);
fprintf(1, 'Result of ER10_X_CONNECT: %s\n', err);
if strcmp(err, 'ER10X_ERR_OK')
    fprintf('Continuing...\n');
else
    error('Something wrong! Could not connect to ER10X!');
end
probeIndex = 0;
gain = 30; % dB
temperatureF = 0; % Turn off heater
er10x_set_gain(ER10XHandle,probeIndex,gain);
er10x_set_output_limiter(ER10XHandle, 1); % Enable output limiter
er10x_set_mic_response(ER10XHandle, probeIndex, 0); % High Pass
er10x_set_heater_temperature(ER10XHandle,probeIndex,temperatureF);

% Initializing TDT
fig_num=99;
GB_ch=1;
FS_tag = 3;
Fs = 48828.125;
[f1RZ,RZ,~]=load_play_circuit(FS_tag,fig_num,GB_ch);

stim = makeDPstim_twoSweeps;
buffdata = [stim.y1; stim.y2];

subj = input('Please subject ID:', 's');
earflag = 1;
while earflag == 1
    ear = input('Please enter which year (L or R):', 's');
    switch ear
        case {'L', 'R', 'l', 'r', 'Left', 'Right', 'left', 'right', 'LEFT', 'RIGHT'}
            earname = strcat(ear, 'Ear');
            earflag = 0;
        otherwise
            fprintf(2, 'Unrecognized ear type! Try again!');
    end
end

% Make directory to save results
paraDir = 'C:\Experiments\DPOAEswept\';
% whichScreen = 1;
addpath(genpath(paraDir));
if(~exist(strcat(paraDir,'\',subj),'dir'))
    mkdir(strcat(paraDir,'\',subj));
end
respDir = strcat(paraDir,'\',subj,'\');



stim.subj = subj;
stim.ear = ear;

pause(2);

% Check for clipping and load to buffer
if(any(abs(buffdata(:)) > 1))
    error('What did you do!? Sound is clipping!! Cannot Continue!!\n');
end
%Load the 2ch variable data into the RZ6:
buffdataL = buffdata(1, :);
buffdataR = buffdata(2, :);
invoke(RZ, 'WriteTagVEX', 'datainL', 0, 'F32', buffdataL);
invoke(RZ, 'WriteTagVEX', 'datainR', 0, 'F32', buffdataR);
%Set the delay of the sound
invoke(RZ, 'SetTagVal', 'onsetdel',100); % onset delay is in ms
playrecTrigger = 1;

%% Set attenuation and play

button = input('Do you want the subject to press a button to proceed? (Y or N):', 's');
switch button
    case {'Y', 'y', 'yes', 'Yes', 'YES'}
        getResponse(RZ);
        fprintf(1, '\nSubject pressed a button...\nStarting Stimulation...\n');
    otherwise
        fprintf(1, '\nStarting Stimulation...\n');
end

% stim.extraDrop = 30:-6:0;
stim.extraDrop = 18;
extraDrop = stim.extraDrop;

for L = 1:numel(extraDrop)
    drop_f1 = stim.drop_f1 + extraDrop(L);
    drop_f2 = stim.drop_f2 + extraDrop(L);
    invoke(RZ, 'SetTagVal', 'attA', drop_f1);
    invoke(RZ, 'SetTagVal', 'attB', drop_f2);
    
    
    RZ6ADdelay = 97; % Samples
    resplength = size(buffdata,2) + RZ6ADdelay; % How many samples to read from OAE buffer
    invoke(RZ, 'SetTagVal', 'nsamps', resplength);
    stim.resp = zeros(stim.Averages, size(buffdata,2));
    for n = 1: (stim.Averages + stim.ThrowAway)
        %Start playing from the buffer:
        invoke(RZ, 'SoftTrg', playrecTrigger);
        currindex = invoke(RZ, 'GetTagVal', 'indexin');
        while(currindex < resplength)
            currindex=invoke(RZ, 'GetTagVal', 'indexin');
        end
        
        vin = invoke(RZ, 'ReadTagVex', 'dataout', 0, resplength,...
            'F32','F64',1);
        %Accumluate the time waveform - no artifact rejection
        if (n > stim.ThrowAway)
            stim.resp(n-stim.ThrowAway, :) = vin((RZ6ADdelay + 1):end);
        end
        
        % Get ready for next trial
        invoke(RZ, 'SoftTrg', 8); % Stop and clear "OAE" buffer
        %Reset the play index to zero:
        invoke(RZ, 'SoftTrg', 5); %Reset Trigger
        fprintf(1, 'Done with # %d / %d trials \n', n, (stim.Averages + stim.ThrowAway));
    end
    
    
    
    %% Compute the average and convert to right units
    energy = squeeze(sum(stim.resp.^2, 2));
    good = energy < median(energy) + 2*mad(energy);
    stim.respavg = mean(stim.resp(good, :), 1);
    good = find(good);
    stim.good = good;
   
    good_2x = good(1: 2*floor(numel(good) / 2));
    stim.good_2x = good_2x;
    stim.noise = mean(stim.resp(good_2x(1:2:end), :), 1)...
        - mean(stim.resp(good_2x(2:2:end), :), 1);
    
    mic_sens = 0.05; % mV / Pa
    mic_gain = db2mag(36);
    
    P_ref = 20e-6 * sqrt(2);
    
    DR_onesided = 1;
    
    mic_output_V  = stim.respavg / (DR_onesided * mic_gain);
    
    output_Pa = mic_output_V/mic_sens;
    
    stim.respavg_Pa = output_Pa / P_ref; % 20 uPa peak units
    stim.noise_Pa = ((stim.noise / (DR_onesided * mic_gain))/mic_sens)/P_ref;
    
    %% Save results
    
    datetag = datestr(clock);
    stim.date = datetag;
    datetag(strfind(datetag,' ')) = '_';
    datetag(strfind(datetag,':')) = '_';
    fname = strcat(respDir, 'DPOAEswept_', stim.subj, '_', stim.ear,...
        '_f1drop', num2str(drop_f1),'f2_drop',num2str(drop_f2), '_',...
        datetag, '.mat');
    save(fname,'stim');

end
close_play_circuit(f1RZ, RZ);
temperatureF = 86; % 30C
er10x_set_heater_temperature(ER10XHandle,probeIndex,temperatureF);
err = er10x_disconnect(ER10XHandle);
if strcmp(err, 'ER10X_ERR_OK')
    fprintf('Continuing...\n');
else
    error('Something wrong! Could not close ER10X!');
end
[err, ER10XHandle] = er10x_close(ER10XHandle);
if strcmp(err, 'ER10X_ERR_OK')
    fprintf('Continuing...\n');
else
    error('Something wrong! Could not close ER10X!');
end
ER10XCloseAll();
ER10XConnectUnloadLib();
rmpath(p10x);