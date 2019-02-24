function w = blacktop(N,p)
% function w = blacktop(N,p)
% returns an N-point window in which the central portion 
% (consisting of p percent of the total window length) 
% is flat, and the rise and fall segments are half Blackman windows
  
  p = max(0,min(100,p))/100;
  
  n = round(N*(1-p));
  if mod(n, 2) == 1
      n = n + 1;
  end
  bw = blackman(n,'symmetric');
  bw(1) = 0; bw(end) = 0;

  n = n/2;
  rise = bw(1:n);
  fall = bw((n+1):end);
  w = ones([1,N]);
  w(1:n) = rise;
  w((end-n+1):end) = fall;
  
  return