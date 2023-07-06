function stim = makeDPstim_twoSweeps(rawstim)

% rawstim (structure) should contain fields fmin, fmax, speed, Fs, ratio,
% VtoPforH

if ~exist('rawstim', 'var')
    stim.fmin = [1997, 4003];
    stim.speed = -0.33;
    stim.ratio = 1.225;
    stim.Fs = 48828.125;
    stim.fmax = [8011; 16001];
    stim.buffdur = 0.5;
else
    stim = rawstim;
end
stim.drop_f1 = 10;
stim.drop_f2 = 20;
stim.ThrowAway = 1;
stim.Averages = 24;

%% First sweep set
fmin = stim.fmin(1);
fmax = stim.fmax(1);
buffdur = stim.buffdur;
dur = log2(fmax/fmin) / abs(stim.speed) + 2*buffdur;
Fs = stim.Fs;
t = 0: (1/Fs): (dur - 1/Fs);
stim.t = t;
buffinst1 = find(t < buffdur, 1, 'last');
buffinst2 = find(t > (dur - buffdur), 1, 'first');

if stim.speed < 0
    f2_inst = fmax * 2.^( (t - buffdur) * stim.speed);
    f2_inst(1:buffinst1) = fmax;
    f2_inst(buffinst2:end) = fmin;
    phi2_inst = fmax * (2.^( (t - buffdur) * stim.speed) - 1) / (stim.speed * log(2));
    phi2_inst(1:buffinst1) = fmax .* (t(1:buffinst1) - buffdur);
    phi2_inst(buffinst2:end) = fmin .* (t(buffinst2:end) - t(buffinst2)) + phi2_inst(buffinst2);
else
    f2_inst = fmin * 2.^( (t - buffdur) * stim.speed);
    f2_inst(1:buffinst1) = fmin;
    f2_inst(buffinst2:end) = fmax;
    phi2_inst = fmin * (2.^( (t - buffdur) * stim.speed) - 1) / (stim.speed * log(2));
    phi2_inst(1:buffinst1) = fmin .* (t(1:buffinst1) - buffdur);
    phi2_inst(buffinst2:end) = fmax .* (t(buffinst2:end) - t(buffinst2)) + phi2_inst(buffinst2);
end

f1_inst = f2_inst / stim.ratio;
phi1_inst = phi2_inst / stim.ratio;
y11 = rampsound(cos(2 * pi * phi1_inst), stim.Fs, 0.005);
y12 = rampsound(cos(2 * pi * phi2_inst), stim.Fs, 0.005);
stim.f11_inst = f1_inst;
stim.f12_inst = f2_inst;
stim.phi11_inst = phi1_inst;
stim.phi12_inst = phi2_inst;

%% Second sweep set
fmin = stim.fmin(2);
fmax = stim.fmax(2);

if stim.speed < 0
    f2_inst = fmax * 2.^( (t - buffdur) * stim.speed);
    f2_inst(1:buffinst1) = fmax;
    f2_inst(buffinst2:end) = fmin;
    phi2_inst = fmax * (2.^( (t - buffdur) * stim.speed) - 1) / (stim.speed * log(2));
    phi2_inst(1:buffinst1) = fmax .* (t(1:buffinst1) - buffdur);
    phi2_inst(buffinst2:end) = fmin .* (t(buffinst2:end) - t(buffinst2)) + phi2_inst(buffinst2);
else
    f2_inst = fmin * 2.^( (t - buffdur) * stim.speed);
    f2_inst(1:buffinst1) = fmin;
    f2_inst(buffinst2:end) = fmax;
    phi2_inst = fmin * (2.^( (t - buffdur) * stim.speed) - 1) / (stim.speed * log(2));
    phi2_inst(1:buffinst1) = fmin .* (t(1:buffinst1) - buffdur);
    phi2_inst(buffinst2:end) = fmax .* (t(buffinst2:end) - t(buffinst2)) + phi2_inst(buffinst2);
end

f1_inst = f2_inst / stim.ratio;
phi1_inst = phi2_inst / stim.ratio;
y21 = rampsound(cos(2 * pi * phi1_inst), stim.Fs, 0.005);
y22 = rampsound(cos(2 * pi * phi2_inst), stim.Fs, 0.005);
stim.f21_inst = f1_inst;
stim.f22_inst = f2_inst;
stim.phi21_inst = phi1_inst;
stim.phi22_inst = phi2_inst;

%% Adding two sweeps together
stim.y1 = scaleSound(y11 + y21);
stim.y2 = scaleSound(y12 + y22);
