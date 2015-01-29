function modplot(num)
%MODPLOT  One line description goes here.
%   output = modplot(input)
%
%   Example
%   modplot
%
%   See also

% Author: 
% Created: Feb 2011
% Copyright 2011

k = get(gca,'Children');
for i = 2:length(k)
    ydata = get(k(i),'YData');
    set(k(i),'YData',mod(ydata,num));
end
ydata = get(k(1),'YData');
ydata(ydata~=-1) = num+1;
    set(k(1),'YData',mod(ydata,num));
ax = axis;
axis([ax(1:2) -1 num+1]);
