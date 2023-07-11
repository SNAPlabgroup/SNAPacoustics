try
    % Initialize ER-10X  (Also needed for ER-10C for calibrator)

    initializeER10X;
    % initializeER10X_300Hz_Highpass;

    % Initializing TDT
    % Specify path to cardAPI here
    pcard = genpath('C:\Experiments\SNAPacoustics\cardAPI');
    addpath(pcard);
    card = initializeCard;

    % Get stimulus structure; Change to _linear for linear sweep
    stim = Make_SFswept_log;
    
    if abs(stim.speed) < 20
        sweeptype = 'log';
    else
        sweeptype = 'linear';
    end
    
    % Get subject and ear info
    subj = input('Please subject ID:', 's');
    earflag = 1;
    while earflag == 1
        ear = input('Please enter which ear (L or R):', 's');
        switch ear
            case {'L', 'R', 'l', 'r', 'Left', 'Right', 'left', 'right', 'LEFT', 'RIGHT'}
                earname = strcat(ear, 'Ear');
                earflag = 0;
            otherwise
                fprintf(2, 'Unrecognized ear type! Try again!');
        end
    end
    
    % The button section is just so you can start the program, go into the
    % booth and run yourself as the subject
    button = input('Do you want the subject to press a button to proceed? (Y or N):', 's');
    switch button
        case {'Y', 'y', 'yes', 'Yes', 'YES'}
            getResponse(card.RZ);
            fprintf(1, '\nSubject pressed a button...\nStarting Stimulation...\n');
        otherwise
            fprintf(1, '\nStarting Stimulation...\n');
            fprintf(1, '\nApproximate Duration: %d minutes\n', (stim.t(end).*3.*(stim.ThrowAway + stim.Averages)./60));
    end
    
    % Make directory to save results if it doesn't already exist
    paraDir = './Results/';
    
    addpath(genpath(paraDir));
    if(~exist(strcat(paraDir,'\',subj),'dir'))
        mkdir(strcat(paraDir,'\',subj));
    end
    respDir = strcat(paraDir,'\',subj,'\');
    
    %% Present SFOAE stimuli one trial at a time
    
    windowdur = 0.5;
    SNRcriterion = stim.SNRcriterion;
    maxTrials = stim.maxTrials;
    minTrials = stim.minTrials;
    doneWithTrials = 0;
    figure;
    
    %% Add useful info to structure
    mic_sens = 50e-3; % mV/Pa
    mic_gain = db2mag(gain + 6); % +6 for balanced cable
    P_ref = 20e-6;
    DR_onesided = 1;
    stim.VoltageToPascal = 1 / (DR_onesided * mic_gain * mic_sens);
    stim.PascalToLinearSPL = 1 /  P_ref;
    
    % Make arrays to store measured mic outputs
    ProbeBuffs = zeros(maxTrials, numel(stim.yProbe));
    SuppBuffs = zeros(maxTrials, numel(stim.yProbe));
    BothBuffs = zeros(maxTrials, numel(stim.yProbe));
    flip = -1;
    
    % variable for live analysis
    k = 0;
    t = stim.t;
    testfreq = [.75, 1, 1.5, 2, 3, 4, 6, 8, 12].* 1000;
    
    if stim.speed < 0
        f1 = stim.fmax;
        f2 = stim.fmin;
    else
        f1 = stim.fmin;
        f2 = stim.fmax;
    end
    
    if stim.speed < 20
        t_freq = log2(testfreq/f1)/stim.speed + stim.buffdur;
    else
        t_freq = (testfreq-f1)/stim.speed + stim.buffdur;
    end
    
    
    while doneWithTrials == 0
        k = k + 1;
        % alternate phase of the suppressor
        flip = flip .* -1;
        
        delayComp = 1; % Always
        % Do probe only
        dropSupp = 120;
        dropProbe = stim.drop_Probe;
        buffdata = zeros(2, numel(stim.yProbe));
        buffdata(1, :) = stim.yProbe;
        vins = playCapture2(buffdata, card, 1, 0,...
            dropProbe, dropSupp, delayComp);
        
        if k > stim.ThrowAway
            ProbeBuffs(k - stim.ThrowAway,  :) = vins;
        end
        WaitSecs(0.25);
        
        % Do suppressor only
        dropProbe = 120;
        dropSupp = stim.drop_Supp;
        buffdata = zeros(2, numel(stim.ySupp));
        buffdata(2, :) = flip.*stim.ySupp;
        vins = playCapture2(buffdata, card, 1, 0,...
            dropProbe, dropSupp, delayComp);
        if k > stim.ThrowAway
            SuppBuffs(k - stim.ThrowAway,  :) = vins;
        end
        
        WaitSecs(0.25);
        
        % Do both
        dropProbe = stim.drop_Probe;
        dropSupp = stim.drop_Supp;
        buffdata = zeros(2, numel(stim.yProbe));
        buffdata(1, :) = stim.yProbe;
        buffdata(2, :) = flip.*stim.ySupp;
        vins = playCapture2(buffdata, card, 1, 0,...
            dropProbe, dropSupp, delayComp);
        if k > stim.ThrowAway
            BothBuffs(k - stim.ThrowAway,  :) = vins;
        end
        WaitSecs(0.25);
        
        fprintf(1, 'Done with trial %d / %d\n', k,...
            (stim.ThrowAway + stim.Averages));
        
        % test OAE
        OAEtrials = ProbeBuffs(1:k-stim.ThrowAway, :) + ...
            SuppBuffs(1:k-stim.ThrowAway, :) - ...
            BothBuffs(1:k-stim.ThrowAway, :);
        OAE = median(OAEtrials,1);
        coeffs_temp = zeros(length(testfreq), 2);
        coeffs_noise = zeros(length(testfreq), 8);
        for m = 1:length(testfreq)
            win = find( (t > (t_freq(m)-windowdur/2)) & ...
                (t < (t_freq(m)+windowdur/2)));
            taper = hanning(numel(win))';
            
            oae_win = OAE(win) .* taper;
            
            phiProbe_inst = 2*pi*stim.phiProbe_inst;
            
            model_oae = [cos(phiProbe_inst(win)) .* taper;
                -sin(phiProbe_inst(win)) .* taper];


        if stim.speed < 0
            nearfreqs = [1.10, 1.12, 1.14, 1.16];
        else
            nearfreqs = [.90, .88, .86, .84];
        end
        
        model_noise = ...
            [cos(nearfreqs(1)*phiProbe_inst(win)) .* taper;
            -sin(nearfreqs(1)*phiProbe_inst(win)) .* taper;
            cos(nearfreqs(2)*phiProbe_inst(win)) .* taper;
            -sin(nearfreqs(2)*phiProbe_inst(win)) .* taper;
            cos(nearfreqs(3)*phiProbe_inst(win)) .* taper;
            -sin(nearfreqs(3)*phiProbe_inst(win)) .* taper;
            cos(nearfreqs(4)*phiProbe_inst(win)) .* taper;
            -sin(nearfreqs(4)*phiProbe_inst(win)) .* taper];
            
            coeffs_temp(m,:) = model_oae' \ oae_win';
            coeffs_noise(m,:) = model_noise' \ oae_win';
        end
        
        % for noise
        noise2 = zeros(length(testfreq),4);
        for i = 1:2:8
            noise2(:,ceil(i/2)) = abs(complex(coeffs_noise(:,i), coeffs_noise(:,i+1)));
        end
        noise = mean(noise2, 2);
        
        oae = abs(complex(coeffs_temp(:,1), coeffs_temp(:,2)));
        
        SNR_temp = db(oae) - db(noise);
        
        mult = stim.VoltageToPascal .* stim.PascalToLinearSPL;
        hold off;
        plot(testfreq./1000,db(oae.*mult), 'o', 'linew', 2);
        hold on;
        plot(testfreq./1000,db(noise.*mult), 'x', 'linew', 2);
        title('DPOAE');
        legend('DPOAE', 'NOISE');
        xlabel('Frequency (Hz)')
        ylabel('Median Amplitude dB')
        set(gca, 'XScale', 'log', 'FontSize', 14)
        xticks([.5, 1, 2, 4, 8, 16])
        xlim([0.5, 16])
        
        % if SNR is good enough and we've hit the minimum number of
        % trials, then stop.
        if SNR_temp(1:8) > SNRcriterion
            if k - stim.ThrowAway >= minTrials
                doneWithTrials = 1;
            end
        elseif k == maxTrials
            doneWithTrials = 1;
        end
        
    end
    
    stim.ProbeBuffs = ProbeBuffs(1:k-stim.ThrowAway,:);
    stim.SuppBuffs = SuppBuffs(1:k-stim.ThrowAway,:);
    stim.BothBuffs = BothBuffs(1:k-stim.ThrowAway,:);
    
    %% Save Measurements
    datetag = datestr(clock);
    click.date = datetag;
    datetag(strfind(datetag,' ')) = '_';
    datetag(strfind(datetag,':')) = '_';
    fname = strcat(respDir,'SFOAE_',sweeptype,'_',subj,earname,'_',datetag, '.mat');
    save(fname,'stim');
    
    %% Close TDT, ER-10X connections etc. and cleanup
    closeER10X;
    closeCard(card);
    rmpath(pcard);
    
catch me
    closeER10X;
    closeCard(card);
    rmpath(pcard);
    rethrow(me);
    
end

