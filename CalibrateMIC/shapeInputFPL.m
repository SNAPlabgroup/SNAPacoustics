function y = shapeInputFPL(x, Pfor, card2volts)
% Function to reshape a given input signal to provide a flat FPL in the ear
% that was just calibrated
%
% INPUTS:
%   x - Input waveform (should be long enough for filtering to be possible,
%   zero pad on both sides as necessary)
%   Pfor - The voltage to FPL transfer function (complex) from calibEar
%   card2volts - The scaling between MATLAB values and D/A voltage
%
% Important Note:
%   (1) If you only care about flatness in a certain frequency range,
%   make Pfor = 1 for all other frequencies before using this function.
%   (2) The probe mic calibration, including phase is important for this
%   to work well.

h_inv = irfft(1./Pfor);
y = filter(h_inv, 1, x) / card2volts;

