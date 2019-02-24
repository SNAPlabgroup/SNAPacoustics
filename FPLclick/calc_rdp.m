function [S C] = calc_rdp(D,C,d_type,zo_ratio)

% calculate reverse dp wave (the inital outgoing DPOAE wave at the drum)
% C contains calibration parameters 
%d_type - how the delay of the ear canal is estimated
if nargin<3
    d_type = 'tec_fres';
end

if nargin<4
    zo_ratio = []; % ratio of surge impedance at the OAE probe mic and at the TM 
end

if isfield(D,'fdp') %DPOAE
    f = D.fdp;
    Pdp = D.Pdp;
elseif  isfield(D,'f') %SFOAE or TEOAE
    f = D.f;
    Pdp = D.Z; 
elseif  isfield(D,'faxis') %SFOAE or TEOAE
    f = D.faxis';
    Pdp = D.Pdp; 
    S = D;
end

   if ~(numel(f) == numel(C.Rs)) %need to interpolate first
        
        C.H = C.Rec;
        Out = CALIB_InterpH(C,f); %interpolate
        Rec = Out.H;
%             
        C.H = C.Rs;
        Out = CALIB_InterpH(C,f); %interpolate
        Rs = Out.H;
   else
       Rec = C.Rec;
       Rs = C.Rs;
   end
   %% calculate the delay
   if strcmp(d_type, 'tec') %tec from TDR
       delay = exp(-i*2*pi*f*C.tec); %C.tec is one way travel time from time domain reflectance
   elseif strcmp(d_type, 'tec_fres') %%C.tec_fres is one way travel time from the half wave resonsnt frequency estimate
       delay = exp(-i*2*pi*f*C.tec_fres); 
   elseif strcmp(d_type, 'tec_R') %delay form the phase of R (souza et al 2014)
       ok1 = find(f > 0.2 & f <=C.fres);
       p1 = polyfit(f(ok1),cycs(Rec(ok1)),1);
       C.tec_R(1) = -p1(1)/2;
       
       ok2 = find(f > C.fres & f <=C.fres2);
       p2 = polyfit(f(ok2),cycs(Rec(ok2)),1);
       C.tec_R(2) = -p2(1)/2;
       
       delay(1:ok1-1) = NaN;
       delay(ok1) = exp(-i*2*pi*f(ok1)*C.tec_R(1));
       delay(ok2) = exp(-i*2*pi*f(ok2)*C.tec_R(2));
       delay(ok2(end)+1:length(f)) = NaN;
       
   end
   
   
   
  S.Pdp_for = Pdp./(1+Rs); %swap Rs and Rec
  S.Pdp_rev = S.Pdp_for.*Rs;
  S.Pdp_inc=  S.Pdp_for.*(1-Rs.*Rec)./delay; %EPL
  if ~isempty(zo_ratio)
       delay2 = sqrt(zo_ratio).*delay;
       S.Pdp_inc_zo=  S.Pdp_for.*(1-Rs.*Rec)./delay2; %EPL corrected for chnage in surge impedance
   end
  
  S.Pdp_s = 2.*S.Pdp_inc./(1-Rec./delay.^2); %Thevenin eq source pressure at the drum
%   S.Pdp_inc_nf= D.NF.*(1-Rs.*Rec)./(1+Rs); %does it make sense to apply to NF?
  S.Pdp = Pdp;
  if isfield(D,'NF')
     S.Pdp_nf = D.NF;
  end
       
  S.Pconv_jon = 1./(1-Rec.*Rs); %ass in Jon Siegel ARO 2016
  S.Pdp_jon=  Pdp./S.Pconv_jon; %%correct only magnitude
  
%   S.I_epl = (abs(S.Pdp_inc)).^2./(2*C.Z0); %must be rms p/sqrt(2)
% Pdp are already in rms units per 20uPa 
%   S.I_epl = (abs(S.Pdp_inc*(20^-6))).^2./(C.Z0)/(10^-12); %ref level is 10^-12 W/m^2 this simplify to 
  S.I_epl = (abs(S.Pdp_inc*20)).^2./(C.Z0); %in anechoic chamber the dB SIL and dB SPL should be equal since i calulate it for the anechoic condtion i should get them equal too. right now the SIL is 6 dB avobe the SPL I am not sure why. if i divided it by 2 that would be 3 db difference but i am pretty sure the unit of presure is already rms 
  
 
 return
        
        
        
        