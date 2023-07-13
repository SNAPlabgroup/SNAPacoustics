clear;
close all;
clc;

[FileName,PathName,FilterIndex] = uigetfile(strcat('MEMR_*.mat'),...
    'Please pick MEM data file to analyze');
MEMfile = fullfile(PathName, FileName);
load(MEMfile);

endsamps = ceil(stim.clickwin*stim.Fs*1e-3);

freq = linspace(200, 8000, 1024);
MEMband = [500, 2000];
ind = (freq >= MEMband(1)) & (freq <= MEMband(2));

if stim.nLevels == 11
    stim.nLevels = 10;
end

n = stim.nLevels;
for k = 1:stim.nLevels
    fprintf(1, 'Analyzing level # %d / %d ...\n', k, stim.nLevels);
    temp = reshape(squeeze(stim.resp(k, :, 2:end, 1:endsamps)),...
        (stim.nreps-1)*stim.Averages, endsamps);
    tempf = pmtm(temp', 4, freq, stim.Fs)';
    resp_freq(k, :) = median(tempf, 1); %#ok<*SAGROW>
    

    blevs = k; % Which levels to use as baseline (consider 1:k)
    temp2 = squeeze(stim.resp(blevs, :, 1, 1:endsamps));
    
    if(numel(blevs) > 1)
        temp2 = reshape(temp2, size(temp2, 2)*numel(blevs), endsamps);
    end
    
    temp2f = pmtm(temp2', 4, freq, stim.Fs)';
    bline_freq(k, :) = median(temp2f, 1);
end



% Accounting for the existence of four different versions of MEMR script
% with varying attenuations values being subselected
alllevels = 34:6:94;
switch n
    case 10
        elicitor = alllevels(1:10);
    case 8
        elicitor = alllevels(3:10);
    case 5
        elicitor = alllevels(2:2:10);
    case 11
        elicitor = alllevels;
    otherwise
            elicitor = 94 - stim.noiseatt;
end

elicitor = elicitor(1:n);

MEM = pow2db(resp_freq ./ bline_freq);


cols = getDivergentColors(n);

axes('NextPlot','replacechildren', 'ColorOrder',cols);

smoothmem = true;
plotorig = false;
if smoothmem
    for k = 1:n
        MEMs(k, :) = sgolayfilt(MEM(k, :), 2, 35);
    end
else
    MEMs = MEM; %#ok<UNRCH> 
end

semilogx(freq / 1e3, MEMs, 'linew', 2);
xlim([0.3, 8]);
ticks = [0.25, 0.5, 1, 2, 4];
set(gca, 'XTick', ticks, 'XTickLabel', num2str(ticks'), 'FontSize', 16);
legend(num2str(elicitor'), 'location', 'best');

if plotorig
    hold on; %#ok<UNRCH> 
    semilogx(freq / 1e3, MEM, '--', 'linew', 2);
end
xlabel('Frequency (kHz)', 'FontSize', 16);
ylabel('Ear canal pressure (dB re: Baseline)', 'FontSize', 16);



figure;
plot(elicitor, mean(abs(MEM(:, ind)), 2)*5 , 'ok-', 'linew', 2);
hold on;
xlabel('Elicitor Level (dB SPL)', 'FontSize', 16);
ylabel('\Delta Absorbed Power (dB)', 'FontSize', 16);
set(gca,'FontSize', 16);


