function imHandle = imagestats(imHandle)
imHandle.UserData.ROI= [];
imHandle.UserData.Comparison = [];
c = uicontextmenu('UserData',struct('imHandle',imHandle));
imHandle.UIContextMenu = c;
uimenu(c,'Label','Draw New ROI','Callback',@drawNewROI);
uimenu(c,'Label','Clear All ROIs','Callback',@clearAllROI);
addlistener(imHandle,'CData','PostSet',@cDataChange)
end

function ROI = updateROI(ROI)
for i = 1:length(ROI);
    index = findROI(ROI(i).imHandle,ROI(i).patchHandle(1));
    ColorOrder = get(ancestor(ROI(i).patchHandle(1),'axes'),'ColorOrder');
    set(ROI(i).patchHandle(:),'FaceColor',ColorOrder(mod(index-1,size(ColorOrder,1))+1,:),'EdgeColor',ColorOrder(mod(index-1,size(ColorOrder,1))+1,:));
end
for k = 1:length(ROI);
    index = findROI(ROI(k).imHandle,ROI(k).patchHandle(1));
    mask = getROImask(ROI(k).imHandle,ROI(k).patchHandle);
    ROI1 = getROIdata(ROI(k).imHandle,mask);
    fnames = fieldnames(ROI1);
    for i = 2:length(fnames)
        ROI(k).(fnames{i}) = ROI1.(fnames{i});
    end
    if ~isempty(ROI(k).statTable) && ishandle(ROI(k).statTable)
        set(ROI(k).statTable,'Data',ROI2cell(ROI(k)));
    end
    for i = 1:length(ROI(k).patchHandle)
        UIMenu = ROI(k).patchHandle(i).UIContextMenu;
        UIMenu.Children(end).Label = ROI(k).Name;
        compareIndex = find(strcmp({UIMenu.Children.Label},'Compare Against...'));
        compareMenu = UIMenu.Children(compareIndex);
        if ~isempty(compareMenu.Children)
            delete(compareMenu.Children);
        end
        for j = [1:index-1 index+1:length(ROI(k).imHandle.UserData.ROI)];
            uimenu('Parent',compareMenu,'Label',ROI(k).imHandle.UserData.ROI(j).Name,'Callback',@compareAgainst,'ForeGroundColor',ROI(k).imHandle.UserData.ROI(j).patchHandle(1).FaceColor);
        end
    end
    imHandle = ROI(k).imHandle;
    if ~isempty(imHandle.UserData.Comparison)
        if strcmp(ROI(k).Name,imHandle.UserData.Comparison.fgROI) || strcmp(ROI(k).Name,imHandle.UserData.Comparison.bgROI)
            index0 = find(strcmp({imHandle.UserData.ROI.Name},imHandle.UserData.Comparison.fgROI));
            index1 = find(strcmp({imHandle.UserData.ROI.Name},imHandle.UserData.Comparison.bgROI));
            Comparison = getComparison(imHandle,index0,index1);
            if isfield(imHandle.UserData.Comparison,'compTable')
                Comparison.compTable = imHandle.UserData.Comparison.compTable;
                if  ~isempty(Comparison.compTable) && ishandle(Comparison.compTable)
                    set(Comparison.compTable,'Data',comp2cell(Comparison));
                end
            else
                Comparison.compTable = [];
            end
            imHandle.UserData.Comparison = Comparison;
        end
    end
end
end

function cDataChange(hObject,eventdata)
imHandle = eventdata.AffectedObject;
imHandle.UserData.ROI = updateROI(imHandle.UserData.ROI);
end

function clearAllROI(hObject,eventdata)
imHandle = hObject.Parent.UserData.imHandle;
for i = 1:length(imHandle.UserData.ROI)
    if ishandle(imHandle.UserData.ROI(i).statTable)
        delete(ancestor(imHandle.UserData.ROI(i).statTable,'figure'))
    end
    delete(imHandle.UserData.ROI(i).patchHandle);
end
imHandle.UserData.ROI = [];
if isfield(imHandle.UserData.Comparison,'compTable') && ishandle(imHandle.UserData.Comparison.compTable)
    delete(ancestor(imHandle.UserData.Comparison.compTable,'figure'));
end
imHandle.UserData.Comparison = [];
end

function deleteROI(hObject,eventdata);
imHandle = hObject.Parent.UserData.imHandle;
patchHandle = hObject.Parent.UserData.patchHandle;
[index, patchindex] = findROI(imHandle,patchHandle);
delete(patchHandle);
if length(imHandle.UserData.ROI(index).patchHandle) == 1
    if ~isempty(imHandle.UserData.ROI(index).statTable) && ishandle(imHandle.UserData.ROI(index).statTable)
        delete(ancestor(imHandle.UserData.ROI(index).statTable,'figure'));
    end
    if ~isempty(imHandle.UserData.Comparison)
        if strcmp(imHandle.UserData.ROI(index).Name,imHandle.UserData.Comparison.fgROI) || strcmp(imHandle.UserData.ROI(index).Name,imHandle.UserData.Comparison.bgROI)
            if ~isempty(imHandle.UserData.Comparison.compTable) && ishandle(imHandle.UserData.Comparison.compTable)
                delete(ancestor(imHandle.UserData.Comparison.compTable,'figure'));
            end
            imHandle.UserData.Comparison = [];
        end
    end
    imHandle.UserData.ROI = imHandle.UserData.ROI([1:index-1 index+1:end]);
    imHandle.UserData.ROI = updateROI(imHandle.UserData.ROI);
else
    imHandle.UserData.ROI(index).patchHandle = imHandle.UserData.ROI(index).patchHandle([1:patchindex-1 patchindex+1:end]);
    imHandle.UserData.ROI = updateROI(imHandle.UserData.ROI);
end
end

function addNewROI(hObject,eventdata);
imHandle = hObject.Parent.UserData.imHandle;
patchHandle = hObject.Parent.UserData.patchHandle;
axH = ancestor(imHandle,'Axes');
index = findROI(imHandle,patchHandle);
patchindex = length(imHandle.UserData.ROI(index).patchHandle)+1;
[mask, x, y] = roipoly;
imHandle.UserData.ROI(index).patchHandle(patchindex) = newPatch(imHandle,x,y,index);
imHandle.UserData.ROI = updateROI(imHandle.UserData.ROI);
end

function editROI(hObject,eventdata);
imHandle = hObject.Parent.UserData.imHandle;
patchHandle = hObject.Parent.UserData.patchHandle;
axH = ancestor(imHandle,'Axes');
[index patchindex] = findROI(imHandle,patchHandle);
im = impoly(axH,patchHandle.Vertices);
wait(im);
delete(patchHandle);
[xy] = im.getPosition;
delete(im);
patchHandle = newPatch(imHandle,xy(:,1),xy(:,2),index);
imHandle.UserData.ROI(index).patchHandle(patchindex) = patchHandle;
imHandle.UserData.ROI = updateROI(imHandle.UserData.ROI);
end

function mask = getROImask(imHandle,patchHandle)
for i = 1:length(patchHandle);
    xy = patchHandle(i).Vertices;
    mask(:,:,i) = roipoly(imHandle.XData,imHandle.YData,imHandle.CData,xy(:,1),xy(:,2));
end
mask = any(mask,3);
end

function [roiindex, patchindex] = findROI(imHandle,patchHandle)
if ~isnumeric(patchHandle)
    patchHandle = double(patchHandle);
end
for i = 1:length(imHandle.UserData.ROI)
    patchID = double(imHandle.UserData.ROI(i).patchHandle);
    if any(find(patchID == patchHandle))
        roiindex = i;
        patchindex = find(patchID==patchHandle);
    end
end
end

function patchHandle = newPatch(imHandle,x,y,index)
axH = ancestor(imHandle,'Axes');
ColorOrder = get(axH,'ColorOrder');
patchHandle = patch(x,y,get(axH,'XColor'),'edgecolor',ColorOrder(mod(index-1,size(ColorOrder,1))+1,:),'linewidth',2,'facecolor',ColorOrder(mod(index-1,size(ColorOrder,1))+1,:),'facealpha',0.1,'Tag','ROI');
c = uicontextmenu('UserData',struct('imHandle',imHandle,'patchHandle',patchHandle));
patchHandle.UIContextMenu = c;
uimenu(c,'Label','NAME','Callback',@renameROI);
uimenu(c,'Label','Delete','Callback',@deleteROI);
uimenu(c,'Label','Edit','Callback',@editROI);
uimenu(c,'Label','Add To ROI','Callback',@addNewROI);
%uimenu(c,'Label','Stats');
uimenu(c,'Label','Show Stats Window','Callback',@toggleStatsWindow);
uimenu(c,'Label','Compare Against...');
end

function toggleStatsWindow(hObject,eventdata)
imHandle = hObject.Parent.UserData.imHandle;
axH = ancestor(imHandle,'axes');
figH = ancestor(imHandle,'figure');
patchHandle = hObject.Parent.UserData.patchHandle;
[index] = findROI(imHandle,patchHandle);
ROI = imHandle.UserData.ROI(index);
st = ROI.statTable;
if isempty(st) || any(~ishandle(st))
    fpos = get(figH,'position');
    f = figure;
    set(f,'Position',[fpos(1) fpos(2) 200 170]);
    set(f,'ToolBar','none','MenuBar','none','NumberTitle','off','Name','Stats','Resize','off')
    C = ROI2cell(ROI);
    imHandle.UserData.ROI(index).statTable = uitable('Units','pixels','Position',[0 0 210 170],'ColumnWidth',{80,120},'RowStriping','on','Data',C,'ColumnName',[],'RowName',[],'FontSize',14);
end
end

function C = ROI2cell(ROI)
C = [fieldnames(ROI) struct2cell(ROI)];
C = C(1:6,:);
end

function compareAgainst(hObject,eventdata)
imHandle = hObject.Parent.Parent.UserData.imHandle;
patchHandle = hObject.Parent.Parent.UserData.patchHandle;
[index0,patchindex0] = findROI(imHandle,patchHandle);
index1 = find(strcmp({imHandle.UserData.ROI.Name},hObject.Label));
Comparison = getComparison(imHandle,index0,index1);
fprintf('Comparison:\n');
disp(Comparison);
if ~isfield(imHandle.UserData.Comparison,'compTable') || isempty(imHandle.UserData.Comparison.compTable) || ~ishandle(imHandle.UserData.Comparison.compTable)
    fpos = get(ancestor(imHandle,'figure'),'position');
    f = figure;
    set(f,'Position',[fpos(1)+200 fpos(2) 230 230]);
    set(f,'ToolBar','none','MenuBar','none','NumberTitle','off','Name','Comparison','Resize','off')
    C = comp2cell(Comparison);
    Comparison.compTable = uitable('Units','pixels','Position',[0 0 235 230],'ColumnWidth',{100,130},'RowStriping','on','Data',C,'ColumnName',[],'RowName',[],'FontSize',14);
else
    Comparison.compTable = imHandle.UserData.Comparison.compTable;
end
imHandle.UserData.Comparison = Comparison;
imHandle.UserData.ROI = updateROI(imHandle.UserData.ROI);
end

function Comparison = getComparison(imHandle,index0,index1);
roidata0 = imHandle.UserData.ROI(index0);
roidata1 = imHandle.UserData.ROI(index1);
mask0 = getROImask(imHandle,roidata0.patchHandle);
mask1 = getROImask(imHandle,roidata1.patchHandle);
roidata0 = getROIdata(imHandle,mask0);
roidata1 = getROIdata(imHandle,mask1);
cdata = imHandle.CData;
[H,P,CI] = ttest2(cdata(mask0),cdata(mask1));
Comparison.fgROI = imHandle.UserData.ROI(index0).Name;
Comparison.bgROI = imHandle.UserData.ROI(index1).Name;
Comparison.ratio = roidata0.mean/roidata1.mean;
Comparison.contrast = (roidata0.mean-roidata1.mean)/roidata1.mean;
Comparison.std_joint = sqrt((roidata0.N*(roidata0.std^2)+roidata1.N*(roidata1.std^2))/(roidata0.N+roidata1.N));
Comparison.CNR = abs(roidata0.mean-roidata1.mean)/Comparison.std_joint;
Comparison.TTest_H = H;
Comparison.TTest_P = P;
Comparison.TTest_DiffMeansCI = CI;
end

function C = comp2cell(COMP)
C = [fieldnames(COMP) struct2cell(COMP)];
C = C(1:8,:);
end

function renameROI(hObject,eventdata)
NewName = input(sprintf('Enter new name for %s:',eventdata.Source.Label),'s');
imHandle = hObject.Parent.UserData.imHandle;
patchHandle = hObject.Parent.UserData.patchHandle;
[index, patchindex] = findROI(imHandle,patchHandle);
j = [1:index-1 index+1:length(imHandle.UserData.ROI)];
if ~isempty(j)
    while any(strcmp({imHandle.UserData.ROI(j).Name},NewName))
        fprintf('%s is already used as an ROI name!\n',NewName);
        NewName = input(sprintf('Enter new name for %s:',eventdata.Source.Label),'s');
    end
end
eventdata.Source.Label = NewName;
imHandle.UserData.ROI(index).Name = NewName;
imHandle.UserData.ROI = updateROI(imHandle.UserData.ROI);
end

function drawNewROI(hObject,eventdata)
imHandle = hObject.Parent.UserData.imHandle;
[mask, x, y] = roipoly;
index = length(imHandle.UserData.ROI)+1;
patchHandle = newPatch(imHandle,x,y,index);
roidata = getROIdata(imHandle,mask);
roidata.Name = sprintf('ROI %g',index);
roidata.patchHandle = patchHandle;
roidata.imHandle = imHandle;
roidata.statTable = [];
if index == 1;
    imHandle.UserData.ROI = roidata;
else
    i = 0;
    while any(strcmp({imHandle.UserData.ROI.Name},roidata.Name))
        i = i+1;
        roidata.Name = sprintf('ROI %g',index+i);
    end
    imHandle.UserData.ROI(index) = roidata;
end
imHandle.UserData.ROI = updateROI(imHandle.UserData.ROI);
end

function roidata = getROIdata(imHandle,mask)
cData = get(imHandle,'cData');
c = cData(mask);
roidata.Name = '';
roidata.N = numel(c);
roidata.mean = nanmean(c);
roidata.std = nanstd(c);
roidata.median = nanmedian(c);
roidata.snr = roidata.mean/roidata.std;
roidata.mask = mask;
end
