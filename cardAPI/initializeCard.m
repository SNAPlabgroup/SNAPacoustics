function card = initializeCard()

% Initializing TDT
fig_num=99;
USB_ch=1;
FS_tag = 3;
[card.f1RZ,card.RZ,card.Fs]=load_play_circuit_Pitt(FS_tag,fig_num,USB_ch);
card.ADdelay = 98; % Samples: measured using get_electricalDelay.m
card.mat2volts = 5.0; % measures using get_card2volts.m
