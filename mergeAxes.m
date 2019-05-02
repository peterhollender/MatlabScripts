%MERGEAXES Replace multiple axes with a single, larger axis
%
% H = mergeAxes(H0)
% Inputs:
%   H0 - array of subplot handles
%
% Output:
%   H - merged subplot handle
%
function H = mergeAxes(H0)
pos = cell2mat(get(H0,'Position'));
bottomLeft = min(pos(:,1:2));
topRight = max(pos(:,1:2)+pos(:,3:4));
set(H0(1),'position',[bottomLeft topRight-bottomLeft]);
delete(H0(2:end));
H = H0(1);