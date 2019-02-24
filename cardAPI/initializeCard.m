function card = initializeCard()

% Initializing TDT
fig_num=99;
GB_ch=1;
FS_tag = 3;
[card.f1RZ,card.RZ,card.Fs]=load_play_circuit(FS_tag,fig_num,GB_ch);
card.ADdelay = 98; % Samples: measured using get_electricalDelay.m
card.mat2volts = 5.0; % measures using get_card2volts.m
