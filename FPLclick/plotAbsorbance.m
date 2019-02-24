% Plot absorbance Titan style
% Load calib file before running
semilogx(calib.freq * 1e-3, 100*(1 - abs(calib.Rec).^2), 'linew', 2);
xlabel('Frequency (Hz)', 'FontSize', 16);
ylabel('Absorbance (%)', 'FontSize', 16);
xlim([0.2, 10]); ylim([0, 100]);
set(gca, 'FontSize', 16, 'XTick',[0.25, 0.5, 1, 2, 4, 8]);