function [freq, coeffs, tbest] = analyzeDPswept_delay(stim, freq, windowdur, offsetwin, fitPrims)

% Analyze swept tone DPOAE data using least-squares fit of chirp model
if ~exist('windowdur', 'var')
    windowdur = 0.5;
end

if ~exist('offsetwin', 'var')
    offsetwin = 20e-3;
end

if ~exist('fitPrims', 'var')
    fitPrims = 1;
end


phi1_inst = 2 * pi * stim.phi1_inst;
phi2_inst = 2 * pi * stim.phi2_inst;
phi_dp_inst = 2*phi1_inst - phi2_inst;


npoints = numel(freq);


coeffs = zeros(npoints, 2);
tbest = zeros(npoints, 1);



t = stim.t;

rdp = 2 / stim.ratio - 1; % f_dp = f2 * rdp

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
    model = [cos(phi_dp_inst(win)) .* taper;
        sin(phi_dp_inst(win)) .* taper];

    
    maxoffset = ceil(stim.Fs * offsetwin);
    coeff = zeros(maxoffset, size(coeffs,2));
    resid = zeros(maxoffset, 1);
    for offset = 0:maxoffset
        resp = stim.respavg_Pa(win + offset).* taper;
        if fitPrims
            modelPrim = [cos(phi1_inst(win + offset)) .* taper;
            sin(phi1_inst(win + offset)) .* taper;
            cos(phi2_inst(win + offset)) .* taper;
            sin(phi2_inst(win + offset)) .* taper;
            t(win + offset) .* cos(phi1_inst(win + offset)) .* taper;
            t(win + offset) .* sin(phi1_inst(win + offset)) .* taper;
            t(win + offset) .* cos(phi2_inst(win + offset)) .* taper;
            t(win + offset) .* sin(phi2_inst(win + offset)) .* taper];
            coeffTemp = modelPrim' \ resp';
            resp = resp - coeffTemp'*modelPrim;
        end
        coeff(offset + 1, :) = model' \ resp';
        resid(offset + 1) = sum( (resp  - coeff(offset + 1, :) * model).^2);
    end
    [~, ind] = min(resid);
    coeffs(k, :) = coeff(ind);
    tbest(k) = (ind - 1) * 1e3/stim.Fs;
end
a = coeffs(:, 1);
b = -coeffs(:, 2); % Note, FFT convention dictates - instead of plus
dp = complex(a, b);
semilogx(freq, db(abs(dp)), 'linew', 2); xlim([stim.fmin * rdp, stim.fmax * rdp]);
xlabel('DPOAE Frequency (Hz)', 'FontSize', 16);
ylabel('DPOAE level (dB SPL)', 'FontSize', 16);
set(gca, 'FontSize', 16);
end