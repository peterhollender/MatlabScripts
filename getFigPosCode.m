function figPosCode = getFigPosCode(H)
if exist('H','var')
figPosCode = sprintf('set(%0.0f,''position'',[%s\b]);\n',H,sprintf('%0.0f ',get(H,'position')));
else
figPosCode = sprintf('set(gcf,''position'',[%s\b]);\n',sprintf('%0.0f ',get(gcf,'position')));
end