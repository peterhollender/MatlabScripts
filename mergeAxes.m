function H = mergeAxes(H0,H1);
if nargin == 2
    H = [H0 H1];
else
    H = H0;
end
pos = cell2mat(get(H,'Position'));
bottomLeft = min(pos(:,1:2));
topRight = max(pos(:,1:2)+pos(:,3:4));
set(H(1),'position',[bottomLeft topRight-bottomLeft]);
delete(H(2:end));
H = H(1);