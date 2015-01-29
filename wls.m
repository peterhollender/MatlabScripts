function P = wls(x,y,w,order)
if ~all(size(x)==size(y)) || ~all(size(w)==size(y))
    error('x,y,and w must be the same size')
end
if ~exist('order','var')
    order = 1;
end
if length(order) == 1
    exp = (0:order);
else
    exp = order;
end
msk = isnan(y)|isnan(x);
y1 = y(~msk);
w1 = w(~msk);
x1 = x(~msk);
for i = 1:length(exp)
    X(:,i) = x1.^exp(i);
end

W = diag(w1);
P = inv(X.'*W*X)*(X.'*W*y1);