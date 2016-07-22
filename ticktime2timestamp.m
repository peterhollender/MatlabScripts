function ticktime2timestamp(ax,datetime0,fmt);

xTick = get(ax,'XTick');
xTickLabel = cell(1,length(xTick));
seconds_to_date = mod(datenum('01','SS'),1);
for i = 1:length(xTick)
    if ~exist('fmt','var')
        xTickLabel{i} = datestr(seconds_to_date*xTick(i)+datetime0);
    else
        xTickLabel{i} = datestr(seconds_to_date*xTick(i)+datetime0,fmt);
    end
end
set(ax,'XTickLabel',xTickLabel)