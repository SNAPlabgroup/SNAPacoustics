function x=irfft(X)
% IRFFT: inverse of scaled real FFT from postive frequency half, x=irfft(X)
% Takes the positive-frequency half transform from RFFT(.) and returns
% time domain signal. The normalization is consistent with RFFT, i.e.,
% if X[n] = 1 and 0 for other indices, then IRFFT(X) is a sine wave of
% unit amplitude and frequency (n-1)*df.
% Usage:    x=irfft(X)
% The returned x is always even length => avoid odd length buffers
% See also RFFT

[m,n]=size(X);
if (m==1 || n==1)
    % original...
    N=2 * (length(X) - 1);
    pad = conj(flip(X(2:(end-1))));
    if m == 1
        X = [X, pad];
    else
        X = [X; pad];
    end
    X= X* N / 2;
    x = ifft(X, [], 1, 'symmetric');
else
    % do it column-wise...
    N=2 * (m - 1);
    pad = conj(flip(X(2:(end-1), :), 1));
    X = [X; pad] * N / 2;
    x = ifft(X, [], 2, 'symmetric');
end
