function [dydx] = linregx(X,Y,klen,dim);
if ~exist('dim','var')
    dim = find(size(Y)>1,1,'first');
end
sz = 1:numel(size(Y));
sz(dim) = 1;
sz(1) = dim;
kavg = ones(klen,1);
kavg = permute(kavg,sz);
X1 = ones(size(X));
N = convn(X1,kavg,'same');
Xbar = convn(X,kavg,'same')./N;
Ybar = convn(Y,kavg,'same')./N;
dydx = convn((X-Xbar).*(Y-Ybar),kavg,'same')./convn((X-Xbar).^2,kavg,'same');