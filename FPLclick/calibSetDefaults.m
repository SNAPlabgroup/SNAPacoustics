function calib = calibSetDefaults()

%set default parameters 

calib.CavNumb = 5;  %number of cavities to test for Thevenins
calib.Attenuation = 30; % MEMR click should match this
% pick whatever has good SNR but it does not distort
calib.Vref  = 1; 
calib.BufferSize = 2048;
calib.SamplingRate = 48.828125; %kHz
calib.Averages = 256;
calib.ThrowAway = 4;
calib.doInfResp = 0;
calib.positions = [68.5, 56.5, 38, 33, 27.25];
% Positions for Purdue: [68.5, 56.5, 42, 35, 27.25];
calib.doFilt = 0;
calib.RZ6ADdelay = 98; % Samples
calib.electricAcousticPolarity = -1; 

calib.CavTemp = 30; % in C degree
calib.CavDiam = 0.794; % cm 

calib.f_err = [2 8]; % range of freq over which Thevenin calibration error is computed 
