function x = irfft_CS(X,nfft)
%IRFFT inverse (scaled) real fft (complex to real).
%  irfft(X) is the inverse discrete Fourier transform of vector X which
%     is known to be symmetric so that the result has to be real. 
%  irfft(X,N) is the corresponding N-point inverse transform.
% X is assumed scaled as in rfft().
% See also FAST(), FSST() by G. Kubin 08-28-92, Jont Allen 9-25-92
% C.A.Shera 6-19-02

  [m,n] = size(X);
  if (m == 1)
    nf=n;
    % zero out DC imag part...
    X(:,1) = real(X(:,1));
    if (isreal(X(:,end)))               % numel(x) is even
      X = [X,conj(X(:,nf-1:-1:2))];
    else                                % numel(x) is odd
      X = [X,conj(X(:,nf:-1:2))];
    end
  else
    nf = m;
    % zero out DC imag part...
    X(1,:) = real(X(1,:));
    if (isreal(X(end,:)))
      X = [X;conj(X(nf-1:-1:2,:))];
    else
      X = [X;conj(X(nf:-1:2,:))];
    end
  end

  if (nargin == 2)
    x = ifft(X,nfft);
  else
    x = ifft(X);
  end
  x = real(x) + imag(x);
  
  [m,n] = size(x);
  if (m == 1)
    m = n;
  end
  x = (m/2) * x;
  return
  
function bool = isapproxreal(z,thresh)
  
  if (nargin<2)
    thresh = 1e-9;
  end
  angle(z)

  bool = abs(angle(z))<thresh;
  return
  