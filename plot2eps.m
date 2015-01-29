%PLOT2EPS Move figure window to EPS and display
function plot2eps(h)
if ~exist('h','var')
h = gcf;
end
figure(h)
print('-deps','/home/pjh7/matlab/scripts/scratch.eps')
!evince /home/pjh7/matlab/scripts/scratch.eps &
