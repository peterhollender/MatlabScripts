function figPosCode = getFigPosCode(H)
left = @(x,n)x(1:(mod(n-1,length(x))+1));
if exist('H','var')
figPosCode = sprintf('set(%0.0f,''position'',[%s]);\n',H,left(sprintf('%0.0f ',get(H,'position')),-1));
else
figPosCode = sprintf('set(gcf,''position'',[%s]);\n',left(sprintf('%0.0f ',get(gcf,'position')),-1));
end
clipboard('copy',figPosCode);