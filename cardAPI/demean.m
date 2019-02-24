function y = demean(x, dim)

sz = size(x);
ntime = sz(dim);
sznew = ones(size(sz));
sznew(dim) = ntime;
mx = mean(x, dim);

y = x - repmat(mx, sznew);
