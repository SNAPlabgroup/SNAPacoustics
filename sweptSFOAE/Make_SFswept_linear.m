function stim = Make_SFswept_linear()

% rawstim (structure) should contain fields fmin, fmax, speed, Fs, ratio,
% VtoPforH

stim.cf = 4000;
stim.fmin = 500; %stim.cf/sqrt(2); % 1/2 octave below
stim.speed = -2000; %Hz per second
stim.diff = 50; % Hz (Fprobe - 50 = Fsupp; Probe is higher)
stim.Fs = 48828.125;
stim.fmax = 16000; %stim.cf*sqrt(2); % 1/2 octave above 

stim.drop_Probe = 60;
stim.drop_Supp = 40;
stim.ThrowAway = 2;
stim.Averages = 100;
buffdur = 0.1; %seconds; for either side of sweep 
stim.buffdur = buffdur; 

if stim.speed < 0 %downsweep
    f1 = stim.fmax; 
    f2 = stim.fmin; 
else 
    f1 = stim.fmin; 
    f2 = stim.fmax; 
end 

Fs = stim.Fs;
dur = abs(f1 - f2) / abs(stim.speed) + (2*buffdur);
t = 0: (1/Fs): (dur - 1/Fs);
stim.t = t;

buffinst1 = find(t < buffdur, 1, 'last');
buffinst2 = find(t > (dur-buffdur) , 1, 'first');

% Create probe
start_probe = f1*t(1:buffinst1);
buffdur_exact = t(buffinst1);
phiProbe_inst = f1*(t-buffdur_exact) + stim.speed*((t-buffdur_exact).^2)/2 + start_probe(end); % Cycles 
end_probe = f2*t(1:(length(t)-buffinst2+1)) + phiProbe_inst(buffinst2); 
phiProbe_inst(1:buffinst1) = start_probe;
phiProbe_inst(buffinst2:end) = end_probe;

% Create suppressor (from probe)
s1 = f1 - stim.diff; 
s2 = f2 - stim.diff; 
start_supp = s1*t(1:buffinst1); 
phiSupp_inst = s1*(t-buffdur_exact) + stim.speed*((t-buffdur_exact).^2)/2 + start_supp(end); % Cycles 
end_supp = s2*t(1:(length(t)-buffinst2+1)) + phiSupp_inst(buffinst2); 
phiSupp_inst(1:buffinst1) = start_supp;
phiSupp_inst(buffinst2:end) = end_supp;

stim.yProbe = scaleSound(rampsound(cos(2 * pi * phiProbe_inst), stim.Fs, 0.005));
stim.ySupp = scaleSound(rampsound(cos(2 * pi * phiSupp_inst), stim.Fs, 0.005));
stim.phiProbe_inst = phiProbe_inst;
stim.phiSupp_inst = phiSupp_inst;
