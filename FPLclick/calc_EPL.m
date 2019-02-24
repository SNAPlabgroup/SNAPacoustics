function [S] = calc_EPL(D,C)
% calculate rthe inital outgoing OAE wave at the drum
% C contains calibration parameters 
% D contains OAE data
    
f = D.fdp; %DPOAE frequency (2f1-f2)
Pdp = D.Pdp; %complex DPOAE pressure

   if ~(numel(f) == numel(C.Rs)) %need to interpolate first
        fi = linscale(0,C.SamplingRate/2,row,isrow(C.Rec));
        Rec = interp1(fi,C.Rec,f,'linear','extrap');
        Rs = interp1(fi,C.Rs,f,'linear','extrap');
   else
       Rec = C.Rec;
       Rs = C.Rs;
   end
   % calculate the delay
   S.tec_fres = 1./(2*C.fres);
   delay = exp(-i*2*pi*f*C.tec_fres); 
     
   S.Pdp_epl = Pdp.*(1-Rs.*Rec)./(delay.*(1+Rs)); %EPL
  
  if isfield(D,'NF') %apply to noise too
     S.NF = D.NF;
     S.NF_epl = S.NF.*(1-Rs.*Rec)./(delay.*(1+Rs));
  end
 S.f = f;
 
 return
        
        
        
        