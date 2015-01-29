function [Xf Yf] = axToFigCoords(x,y,axisHandle)
if ~exist('axisHandle','var')
    axisHandle = gca;
end
axPos = get(axisHandle,'Position');
yRev = strcmpi(get(gca,'YDir'),'reverse');
xRev = strcmpi(get(gca,'XDir'),'reverse');
xLim = get(axisHandle,'xlim');
yLim = get(axisHandle,'ylim');
 if xRev
     Xf = (1-((x-xLim(1))/diff(xLim)))*axPos(3)+axPos(1);    
 else
    Xf = ((x-xLim(1))/diff(xLim))*axPos(3)+axPos(1);
end
if yRev
    Yf = (1-((y-yLim(1))/diff(yLim)))*axPos(4)+axPos(2);
else
    Yf = ((y-yLim(1))/diff(yLim))*axPos(4)+axPos(2);
end
