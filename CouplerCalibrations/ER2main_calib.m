%% Define measurement frequency points
f = [
    250
    500
    1000
    2000
    3000
    4000
    6000
    8000
    9000
    10000
    11200
    12500
    14000
    16000
    ];

%% Make measurements using BK 4157 coupler

% Measured on: Jul 28, 2023
% Measured by: Hari Bharadwaj
% Comments about setup: Main ER-2 inserts at Pitt after shielding (not
% tiptodes)

Pa_rms_L = [
    1.46
    1.18
    1.20
    1.34
    1.35
    1.39
    1.12
    0.883
    0.738
    0.655
    0.584
    0.498
    0.830
    0.888
    ];

Pa_rms_R = [
    1.36
    1.21
    1.19
    1.34
    1.28
    1.41
    1.1
    0.876
    0.774
    0.645
    0.530
    0.487
    0.778
    0.912
    ];


V_rms_input = 0.5;
P_ref = 20e-6;  % Pascals
dB_SPL_L = db(Pa_rms_L / P_ref) - db(V_rms_input);
dB_SPL_R = db(Pa_rms_R / P_ref) - db(V_rms_input);

%% Plot results
f_ticks = [0.25, 0.5, 1, 2, 4, 8, 16];
figure;
plot(f/1000, dB_SPL_L, 'bx-', 'LineWidth', 2);
hold on;
plot(f/1000, dB_SPL_R, 'ro-', 'LineWidth', 2);
xlabel('Frequency (kHz)', 'FontSize', 16);
ylabel('dB SPL in BK4157 / 1V rms', 'FontSize', 16);
set(gca, 'XScale', 'log', 'FontSize', 16, ...
    'XTick', f_ticks, 'XTickLabel', num2str(f_ticks'));
ylim([70, 120]);
xlim([0.2, 16.5]);
legend('Left', 'Right');
title('ER2 FT5011 Shielded');

