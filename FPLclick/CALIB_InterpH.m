function Hi = CALIB_InterpH(H,fi,method)
% function Hi = CALIB_InterpH(H,?fi?,?method='linear'?))
% Interpolates transfer function H.H to frequency fi using the
% specified method. If fi is empty, resamples H.H to digital 
% frequencies based on the current sampling rate
% (PXI.AOAI.SamplingRate) and averaging buffer size 
% (PXI.Avg.Nfft).  Warns about possibly dangerous 
% high-frequency extrapolations.
  
  global PXI
  
  if (nargin<3), method = 'linear'; end
  if (nargin<2), fi = []; end

  Hi = H;
  
  if (numel(H.H) == 1)
    % interpret H.H as a constant function
    return
  end
  
  if (isempty(H.SamplingRate))
    warningbeep('Unspecified sampling rate; using current value');
    H.SamplingRate = PXI.AOAI.SamplingRate;
  end
  [row col] = size(H.H);
  f = linscale(0,H.SamplingRate/2,row,isrow(H.H));
  if (isempty(fi))
    Npts = floor(PXI.Avg.Nfft/2)+1;
    fi = linscale(0,PXI.AOAI.SamplingRate/2,Npts,isrow(H.H));
  end
  if (PXI.AOAI.SamplingRate>H.SamplingRate || max(fi)>H.SamplingRate/2)
    warningbeep('Extrapolating calibration beyond Nyquist rate');
  end
  
      Hi.H = interp1(f,H.H,fi,method,'extrap');
      Hi.SamplingRate = PXI.AOAI.SamplingRate;
  
  % figure
  % semilogx(f,dB(H.H),fi,dB(Hi.H),'rx-');
  
  return
  