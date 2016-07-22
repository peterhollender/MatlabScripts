function tick2timestamp(ax,fmt);

xTick = get(ax,'XTick');
xTickLabel = cell(1,length(xTick));
for i = 1:length(xTick)
    if ~exist('fmt','var')
        xTickLabel{i} = datestr(xTick(i));
    else
        xTickLabel{i} = datestr(xTick(i),fmt);
    end
end
set(ax,'XTickLabel',xTickLabel)