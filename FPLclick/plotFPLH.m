% Plot absorbance Titan style
% Load calib file before running
hold on;
plot(calib.freq * 1e-3, db(abs(calib.Pfor)), 'linew', 2);
xlabel('Frequency (kHz)', 'FontSize', 16);
ylabel('Transfer Function (dB FPL/V)', 'FontSize', 16);
xlim([0.2, 24]);
set(gca, 'FontSize', 12, 'XTick',[0.25, 0.5, 1, 2, 4, 8, 16],...
    'xscale', 'log');
