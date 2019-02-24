function y = softclip(x, rail)
if ~exist('rail', 'var')
    rail = 6;
end
k = 2/rail; % So that slope is 1
y = 2*rail*(1./(1+exp(-k*x)) - 0.5);