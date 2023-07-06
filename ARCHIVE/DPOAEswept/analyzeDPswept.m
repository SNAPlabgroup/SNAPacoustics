function [freq, coeffs] = analyzeDPswept(stim, windowdur, npoints, usederivs, noisefloor)

% Analyze swept tone DPOAE data using least-squares fit of chirp model
if ~exist('windowdur', 'var')
    windowdur = 0.5;
end

if ~exist('npoints', 'var')
    npoints = 2048;
end

if ~exist('usederivs', 'var')
    usederivs = 0;
end

if ~exist('noisefloor', 'var')
    noisefloor = 1;
end

phi1_inst = 2 * pi * stim.phi1_inst;
phi2_inst = 2 * pi * stim.phi2_inst;
phi_dp_inst = 2*phi1_inst - phi2_inst;


rdp = 2 / stim.ratio - 1; % f_dp = f2 * rdp
freq = 2 .^ linspace(log2(stim.fmin * rdp), log2(stim.fmax * rdp), npoints);


if usederivs
    coeffs = zeros(npoints, 12);
else
    coeffs = zeros(npoints, 6);
end


t = stim.t;

if stim.speed > 0
    t_freq = log2(freq/(stim.fmin * rdp))/stim.speed + stim.buffdur;
else
    t_freq = log2((stim.fmax * rdp)./freq)/abs(stim.speed) + stim.buffdur;
end

for k = 1:npoints
    fprintf(1, 'Running window %d / %d\n', k, npoints);
    
    win = find( (t > (t_freq(k) - windowdur/2)) & ...
        (t < (t_freq(k) + windowdur/2)));
    %     taper = dpss(numel(win), 1, 1)';
    %     taper = taper - taper(1);
    taper = hanning(numel(win))';
    model = [cos(phi1_inst(win)) .* taper;
        sin(phi1_inst(win)) .* taper;
        cos(phi2_inst(win)) .* taper;
        sin(phi2_inst(win)) .* taper;
        cos(phi_dp_inst(win)) .* taper;
        sin(phi_dp_inst(win)) .* taper];
    
    if usederivs
        derivs = [t(win) .* cos(phi1_inst(win)) .* taper;
            t(win) .* sin(phi1_inst(win)) .* taper;
            t(win) .* cos(phi2_inst(win)) .* taper;
            t(win) .* sin(phi2_inst(win)) .* taper;
            t(win) .* cos(phi_dp_inst(win)) .* taper;
            t(win) .* sin(phi_dp_inst(win)) .* taper];
        model = [model; derivs]; %#ok<AGROW>
    end
    
    if noisefloor
        resp = stim.noise_Pa(win).* taper;
    else
        resp = stim.respavg_Pa(win).* taper;
    end
    coeffs(k, :) = model' \ resp';
end
a = coeffs(:, 5);
b = -coeffs(:, 6); % Note, FFT convention dictates - instead of plus
dp = complex(a, b);
semilogx(freq / rdp, db(abs(dp)), 'linew', 2); xlim([stim.fmin, stim.fmax]);
xlabel('DPOAE Frequency (Hz)', 'FontSize', 16);
ylabel('DPOAE level (dB SPL)', 'FontSize', 16);
set(gca, 'FontSize', 16, 'XTick', [1000, 2000, 4000, 8000]);
end