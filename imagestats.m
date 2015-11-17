function H = imagestats(imHandle);
axH = ancestor(imHandle,'Axes');
figH = ancestor(imHandle,'Figure');
x = get(imHandle,'xdata');
y = get(imHandle,'ydata');
xlim = get(axH,'xlim');
ylim = get(axH,'ylim');
imHandle.UserData.existROI = [0 0];
switch axH.YDir
    case 'normal'
        tva = 'bottom';
    case 'reverse'
        tva = 'top';
end
colorOrder = get(axH,'ColorOrder');
fpos = get(figH,'position');
axPosPx = plotboxpos(axH).*fpos([3 4 3 4]);
FontSize = get(axH,'FontSize');
imHandle.UserData.statsHandle(1) = text(xlim(1),ylim(1),'ROI 1','VerticalAlignment',tva,'color',colorOrder(1,:),'FontSize',FontSize);
imHandle.UserData.statsHandle(2) = text(xlim(1),ylim(1)+(FontSize*1.5)/axPosPx(4)*diff(ylim),'ROI 2','VerticalAlignment',tva,'color',colorOrder(2,:),'FontSize',FontSize);
imHandle.UserData.statsHandle(3) = text(xlim(1),ylim(1)+(FontSize*3)/axPosPx(4)*diff(ylim),'Difference','VerticalAlignment',tva,'color',colorOrder(3,:),'FontSize',FontSize);
imHandle.UserData.ROI1 = [];
imHandle.UserData.ROI2 = [];
imHandle.UserData.Stats = [];
set(imHandle,'deletefcn',@clearButtons);
H(1) = uicontrol('Style', 'pushbutton','Tag','ROIButton','String', 'Set ROI 1','Position', round([axPosPx(1)+axPosPx(3)/100 axPosPx(2)+axPosPx(4)/100 FontSize*8 FontSize*1.5]) ,'Callback', @drawROI,'FontSize',FontSize,'ForeGroundColor',colorOrder(1,:));
H(1).UserData = struct('index',1,'imHandle',imHandle,'patchHandle',[],'N',[],'mean',[],'median',[],'std',[],'position',[10 10 FontSize*8 FontSize*1.5]);
H(2) = uicontrol('Style', 'pushbutton','Tag','ROIButton','String', 'Set ROI 2','Position', round([axPosPx(1)+axPosPx(3)/100 axPosPx(2)+axPosPx(4)/100+FontSize*1.5 FontSize*8 FontSize*1.5]) ,'Callback', @drawROI,'FontSize',FontSize,'ForeGroundColor',colorOrder(2,:));
H(2).UserData = struct('index',2,'imHandle',imHandle,'patchHandle',[],'N',[],'mean',[],'median',[],'std',[],'position',[10 10+FontSize*2 FontSize*8 FontSize*1.5]);
set(figH,'SizeChangedFcn',@updateButtonPositions);
c = uicontextmenu;
imHandle.UIContextMenu = c;
uimenu(c,'Label','Draw ROI 1','Callback',{@drawROI,H(1)});
uimenu(c,'Label','Draw ROI 2','Callback',{@drawROI,H(2)});
end

function clearButtons(hObject,eventdata)
H = findobj(ancestor(hObject,'figure'),'Tag','ROIButton');
delete(H);
end

function updateButtonPositions(hObject,eventdata)
drawnow
H = findobj(hObject,'Tag','ROIButton');
for i = 1:length(H)
    if ~isempty(H(i).UserData.imHandle)
        if ~ishandle(H(i).UserData.imHandle)
            delete(H(i))
        else
            axH = ancestor(H(i).UserData.imHandle,'axes');
            fpos = get(hObject,'Position');
            FontSize = get(axH,'FontSize');
            axPosPx = plotboxpos(axH).*fpos([3 4 3 4]);
            set(H(i),'Position',round([axPosPx(1)+H(i).UserData.position(1) axPosPx(2)+H(i).UserData.position(2) H(i).UserData.position(3) H(i).UserData.position(4)]));
        end
            
    end
end
end


function stats = drawROI(hObject,eventdata,directObject);
if exist('directObject','var')
   hObject = directObject;
end
index = hObject.UserData.index;
imHandle = hObject.UserData.imHandle;
if ~isempty(hObject.UserData.patchHandle)
    if ishandle(hObject.UserData.patchHandle)
        delete(hObject.UserData.patchHandle)
    end
end    
[bw, x, y] = roipoly;
hObject.UserData.patchHandle = patch(x,y,'k','facecolor',get(hObject,'ForeGroundColor'),'facealpha',0.3);
cData = get(imHandle,'cData');
c = cData(bw);
hObject.UserData.N = numel(c);
hObject.UserData.mean = nanmean(c);
hObject.UserData.std = nanstd(c);
hObject.UserData.median = nanmedian(c);
hObject.UserData.existROI(index) = 1;
set(imHandle.UserData.statsHandle(index),'String',sprintf('ROI %g: N=%g, Mean=%0.3g, Median=%0.3g, StdDev=%0.3g',index,hObject.UserData.N,hObject.UserData.mean,hObject.UserData.median,hObject.UserData.std));
H = findobj(ancestor(hObject,'figure'),'Tag','ROIButton');
udata = get(H,'UserData');
props = {'N','mean','std','median'};
for i = 1:length(props)
stats.(props{i}) = hObject.UserData.(props{i});
end
end
