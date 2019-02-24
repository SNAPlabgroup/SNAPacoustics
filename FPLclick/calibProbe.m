%% Sound Source, Microphone Probe Thevenin Calibration
% Note: Calibartions need to be run seperatley for each sound source

try
    % Initialize ER-10X  (Also needed for ER-10C for calibrator)
    initializeER10X;
    
    % Initializing TDT
    % Specify path to cardAPI here
    pcard = genpath('C:\Users\snaplab\Desktop\SNAPacoustics\cardAPI\');
    addpath(pcard);
    card = initializeCard;
    
    
    % Initializing Calibration
    calib = calibSetDefaults();
    Fs = calib.SamplingRate * 1000;
    
    deviceflag = 1;
    while deviceflag == 1
        device = input('Please enter X or C for ER-10X/ER-10C respectively:', 's');
        switch device
            case {'X', 'x'}
                device = 'ER-10X';
                deviceflag = 0;
            case {'C', 'c'}
                device = 'ER-10C';
                deviceflag = 0;
                % ER-10C has more distortion, hence attenuate by another 15 dB
                calib.Attenuation = calib.Attenuation + 15;
            otherwise
                fprintf(2, 'Unrecognized device! Try again!');
        end
    end
    
    driverflag = 1;
    while driverflag == 1
        driver = input('Please enter whether you want driver 1, 2 or 3 (Aux on ER-10X):');
        switch driver
            case {1, 2}
                drivername = strcat('Ph',num2str(driver));
                driverflag = 0;
            case 3
                if strcmp(device, 'ER-10X')
                    drivername = 'PhAux';
                    driverflag = 0;
                else
                    fprintf(2, 'Unrecognized driver! Try again!');
                end
            otherwise
                fprintf(2, 'Unrecognized driver! Try again!');
        end
    end
    calib.device = device;
    calib.drivername = drivername;
    calib.driver = driver;
    
    
    % Make click
    vo = clickStimulus(calib.BufferSize);
    buffdata = zeros(2, numel(vo));
    buffdata(driver, :) = vo; % The other source plays nothing
    calib.vo = vo;
    vins = zeros(calib.CavNumb, calib.Averages, calib.BufferSize);
    calib.vavg = zeros(calib.CavNumb, calib.BufferSize);
    
    
    
    err = er10x_move_to_position_and_wait(ER10XHandle, 0, 20000);
    fprintf(1, 'Result of moving to position 1: %s\n', err);
    if strcmp(err, 'ER10X_ERR_OK')
        fprintf('Continuing...\n');
    else
        error('Something wrong! Calibration aborted!');
    end
    
    for m = 1:calib.CavNumb
        drop = calib.Attenuation;
        vins(m, :, :) = playCapture2(buffdata, card,...
            calib.Averages, calib.ThrowAway, drop, drop, 1);
        
        %compute the average
        
        if calib.doFilt
            % High pass at 100 Hz using IIR filter
            [b, a] = butter(4, 100 * 2 * 1e-3/calib.SamplingRate, 'high');
            vins(m, :, :) = filtfilt(b, a, squeeze(vins(m, :, :))')';
        end
        vins(m, :, :) = demean(squeeze(vins(m, :, :)), 2);
        energy = squeeze(sum(vins(m, :, :).^2, 3));
        good = energy < median(energy) + 2*mad(energy);
        vavg = squeeze(mean(vins(m, good, :), 2));
        calib.vavg(m, :) = vavg;
        Vavg = rfft(vavg);
        
        % Apply calibartions to convert voltage to pressure
        % For ER-10X, this is approximate
        mic_sens = 50e-3; % mV/Pa. TO DO: change after calibration
        mic_gain = db2mag(gain + 6); % +6 for balanced cable
        P_ref = 20e-6;
        DR_onesided = 1;
        mic_output_V = Vavg / (DR_onesided * mic_gain);
        output_Pa = mic_output_V/mic_sens;
        outut_Pa_20uPa_per_Vpp = output_Pa / P_ref; % unit: 20 uPa / Vpeak
        
        freq = 1000*linspace(0,calib.SamplingRate/2,length(Vavg))';
        calib.freq = freq;
        
       
        Vo = rfft(calib.vo)*card.mat2volts*db2mag(-1 * calib.Attenuation);
        calib.CavRespH(:,m) =  outut_Pa_20uPa_per_Vpp ./ Vo; %save for later
        
        if m < calib.CavNumb
            err = er10x_move_to_position_and_wait(ER10XHandle, m, 20000);
            fprintf(1, 'Result of moving to position %d: %s\n', m+1, err);
            if strcmp(err, 'ER10X_ERR_OK')
                fprintf('Continuing...\n');
            else
                error('Something wrong! Calibration aborted!');
            end
            
        else
            if (calib.doInfResp == 1)
                out2 = input(['Done with ER-10X cavities.. Move to infinite tube!\n',...
                    'Continue? Press n to stop or any other key to go on:'], 's');
            end
        end
    end
    
    if(calib.doInfResp == 1)
        % FINISH AFTER CHECKING
        calib.InfRespH = outut_Pa_20uPa_per_Vpp ./ Vo; %save for later
    end
    
    
    %% Plot data
    figure(1);
    ax(1) = subplot(2, 1, 1);
    semilogx(calib.freq, db(abs(calib.CavRespH)) + 20, 'linew', 2);
    ylabel('Response (dB re: 20 \mu Pa / V_{peak})', 'FontSize', 16);
    ax(2) = subplot(2, 1, 2);
    semilogx(calib.freq, unwrap(angle(calib.CavRespH), [], 1), 'linew', 2);
    xlabel('Frequency (Hz)', 'FontSize', 16);
    ylabel('Phase (rad)', 'FontSize', 16);
    linkaxes(ax, 'x');
    legend('show');
    xlim([20, 24e3]);
    %% Compute Thevenin Equivalent Pressure and Impedance
    
    %set up some variables
    irr = 1; %ideal cavity reflection
    
    %  calc the cavity length
    calib.CavLength = cavlen(calib.SamplingRate,calib.CavRespH, calib.CavTemp);
    if (irr)
        la = [calib.CavLength 1]; %the one is reflection fo perfect cavit
    else
        la = calib.CavLength; %#ok<UNRCH>
    end
    
    df=freq(2)-freq(1);
    jef1=1+round(calib.f_err(1)*1000/df);
    jef2=1+round(calib.f_err(2)*1000/df);
    ej=jef1:jef2; %limit freq range for error calc
    
    calib.Zc = cavimp(freq, la, irr, calib.CavDiam, calib.CavTemp); %calc cavity impedances
    
    %% Plot impedances
    % It's best to have the set of half-wave resonant peaks (combined across
    % all cavities and including all harmonics) distributed as uniformly as
    % possible across the frequency range of interest.
    figure(2)
    plot(calib.freq/1000,dB(calib.Zc)); hold on
    xlabel('Frequency kHz')
    ylabel('Impedance dB')
    %
    pcav = calib.CavRespH;
    options = optimset('TolFun', 1e-12, 'MaxIter', 1e5, 'MaxFunEvals', 1e5);
    la=fminsearch(@ (la) thverr(la,ej, freq, pcav, irr, calib.CavDiam, calib.CavTemp),la, options);
    calib.Error = thverr(la, ej, freq, pcav, irr, calib.CavDiam, calib.CavTemp);
    
    calib.Zc=cavimp(freq,la, irr, calib.CavDiam, calib.CavTemp);  % calculate cavity impedances
    [calib.Zs,calib.Ps]=thvsrc(calib.Zc,pcav); % estimate zs & ps
    
    plot(freq/1000,dB(calib.Zc),'--'); %plot estimated Zc
    
    calib.CavLength = la;
    
    if ~(calib.Error >= 0 && calib.Error <=1)
        h = warndlg ('Calibration error out of range!');
        waitfor(h);
    end
    
    %% Save calib.Zs and Ps - you can measure them weekly/daily and load
    
    datetag = datestr(clock);
    calib.date = datetag;
    datetag(strfind(datetag,' ')) = '_';
    datetag(strfind(datetag,':')) = '_';
    fname = strcat('./PROBECAL/Calib_',drivername,device,datetag, '.mat');
    save(fname,'calib');
    
    %% Close TDT, ER-10X connections etc. and cleanup
    closeCard(card);
    closeER10X;
    
    % just before the subject arrives
    
catch me
    closeCard(card);
    closeER10X;
    rethrow(me);
end