function calib = findHalfWaveRes(calib)
% Adds a field calib.fres for the first half wave responance


kopeak = find(calib.freq>=5000 & calib.freq<=12000);%specify the range where to look for the first half-wave resonance
EarResp = dB(calib.EarRespH);
[~, idx_peak] = findpeaks(EarResp(kopeak),'sortstr','descend');
idx_peak = kopeak(1)+idx_peak(1)-1;
calib.fres = calib.freq(idx_peak)/1000;
fprintf(1, 'Resonant Freq: %2.2f kHz\n',calib.fres);
