function [C] = calc_fres(C,LLTfile,range,plotit,smooth)
% calculate quarter and half wave resonanses in the ear canal after
% normalizing for LLT response of sound source
%LLT - lossy tube response (file name)
% range - range of freq in khz where to look for first half wave resonant
% frequnecy

if nargin < 3
    range = [5 11];
    plotit = false;
end
if nargin < 4
   plotit = false;
end

if nargin < 5
    smooth = false;
end

faxis = linspace(0,C.SamplingRate/2,numel(C.EarRespH));

LLT = load(LLTfile);
L = dB(C.EarRespH./LLT.SAVED.STUFF.LLTRespH);


if smooth 
    L = sgolayfilt(L,3,15);
end

%half wave resonanse
ok = find(faxis > range(1) & faxis < range (2));
[value_peak idx_peak] = findpeaks(L(ok),'sortstr','descend');
if ~isempty(idx_peak);
    idx_peak = ok(1)+idx_peak(1)-1;
    C.fres = faxis(idx_peak); 
else
    C.fres =[];
    idx_peak =[];
end
    

% secondhalf wave resonanse %usually less than twice the first one in the
% ear canal
 ok2 = find(faxis > 1.2*C.fres & faxis <2.2*C.fres);
[value_peak idx_peak2] = findpeaks(L(ok2),'sortstr','descend');
if ~isempty(idx_peak2);
    idx_peak2 = ok2(1)+idx_peak2(1)-1;
    C.fres2 = faxis(idx_peak2); 
else
    idx_peak2 = [];
    C.fres2 = []; 
end

% quarter wave resonanse
ok3 = find(faxis > 0.3*C.fres & faxis <0.8*C.fres);
[value_peak idx_peak3] = findpeaks(-L(ok3),'sortstr','descend');

if ~isempty(idx_peak3);
    idx_peak3 = ok3(1)+idx_peak3(1)-1;
    C.fnotch = faxis(idx_peak3);
else
    idx_peak3 = [];
    C.fnotch = [];
end

if plotit
    figure
    plot(faxis,L, C.fres,L(idx_peak),'o', C.fres2,L(idx_peak2,:),'o',...
        C.fnotch,L(idx_peak3),'v')
end
return

