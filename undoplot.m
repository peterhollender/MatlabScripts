%UNDOPLOT Kills the youngest child on the current axis
function undoplot(n)
if ~exist('n','var')
    n = 1;
end
k = get(gca,'Children');
delete(k(1:n));