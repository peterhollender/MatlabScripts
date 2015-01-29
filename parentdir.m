%PARENTDIR Returns Parent Directory Path
function pdir = parentdir(d)
if ~exist('d','var')
d = pwd;
end
if d(end) == 47
d = d(1:end-1);
end
pdir = d(1:find(d==47,1,'last'));

