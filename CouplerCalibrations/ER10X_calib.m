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
    20000
    ];

%% Make measurements using BK 4157 coupler

% Measured on: Jul 28, 2023
% Measured by: Hari Bharadwaj
% Comments about setup: ER-10X at Pitt with output limiter disabled.
% Using HB7 to deliver outputs to ER-10X with AC-DC switch in AC position,
% and diff switch in the diff (up) position

% Calling drive 1 "L" and driver 2 "R"
Pa_rms_L = [
    1.31
    1.27
    1.54
    0.808
    0.638
    1.78
    0.667
    0.65
    0.358
    0.302
    0.243
    0.072
    0.041
    0.006
    0.02];

Pa_rms_R = [
    1.49
    1.49
    2.00
    1.77
    1.42
    2.03
    0.455
    0.865
    0.665
    0.767
    0.861
    0.287
    0.288
    0.093
    0.098
    ];


V_rms_input = 0.1; % This is the output at RZ6
P_ref = 20e-6;  % Pascals
dB_SPL_L = db(Pa_rms_L / P_ref) - db(V_rms_input);
dB_SPL_R = db(Pa_rms_R / P_ref) - db(V_rms_input);

%% Plot results
f_ticks = [0.25, 0.5, 1, 2, 4, 8, 16];
figure;
f_plot = 0.25:0.05:20;
dB_SPL_L  = interp1(f/1000, dB_SPL_L, f_plot);
dB_SPL_R  = interp1(f/1000, dB_SPL_R, f_plot);
plot(f_plot, dB_SPL_L, 'b', 'LineWidth', 2);
hold on;
plot(f_plot, dB_SPL_R, 'r', 'LineWidth', 2);
xlabel('Frequency (kHz)', 'FontSize', 16);
ylabel('dB SPL/1V rms', 'FontSize', 16);
title('ER-10X Coupler Calibration', 'FontSize', 16);
legend('Driver 1', 'Driver 2');
set(gca, 'XScale', 'log', 'FontSize', 16, ...
    'XTick', f_ticks, 'XTickLabel', num2str(f_ticks'));
ylim([60, 130]);
xlim([0.2, 20.5]);

