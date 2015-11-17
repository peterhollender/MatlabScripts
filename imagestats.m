function imHandle = imagestats(imHandle)
imHandle.UserData.ROI= [];
imHandle.UserData.Comparison = [];
c = uicontextmenu('UserData',struct('imHandle',imHandle));
imHandle.UIContextMenu = c;
uimenu(c,'Label','Draw New ROI','Callback',@drawNewROI);
uimenu(c,'Label','Clear All ROIs','Callback',@clearAllROI);
end

function clearAllROI(hObject,eventdata)
imHandle = hObject.Parent.UserData.imHandle;
for i = 1:length(imHandle.UserData.ROI)
    delete(imHandle.UserData.ROI(i).patchHandle);
end
imHandle.UserData.ROI = [];
end

function deleteROI(hObject,eventdata);
imHandle = hObject.Parent.UserData.imHandle;
patchHandle = hObject.Parent.UserData.patchHandle;
[index, patchindex] = findROI(imHandle,patchHandle);
delete(patchHandle);
if length(imHandle.UserData.ROI(index).patchHandle) == 1
    imHandle.UserData.ROI = imHandle.UserData.ROI([1:index-1 index+1:end]);
else
    imHandle.UserData.ROI(index).patchHandle = imHandle.UserData.ROI(index).patchHandle([1:patchindex-1 patchindex+1:end]);
    imHandle.UserData.ROI = updateROI(imHandle.UserData.ROI);
end
end

function ROI = updateROI(ROI)
if length(ROI)>1
    for i = 1:length(ROI);
        ROI(i) = updateROI(ROI(i));
    end
    return
end
index = findROI(ROI.imHandle,ROI.patchHandle(1));
ColorOrder = get(ancestor(ROI.patchHandle(1),'axes'),'ColorOrder');
set(ROI.patchHandle(:),'FaceColor',ColorOrder(mod(index-1,size(ColorOrder,1))+1,:));
mask = getROImask(ROI.imHandle,ROI.patchHandle);
ROI1 = getROIdata(ROI.imHandle,mask);
fnames = fieldnames(ROI1);
for i = 1:length(fnames)
    ROI.(fnames{i}) = ROI1.(fnames{i});
end
for i = 1:length(ROI.patchHandle)
    UIMenu = ROI.patchHandle(i).UIContextMenu;
    UIMenu.Children(end).Label = ROI.Name;
    statsIndex = find(strcmp({UIMenu.Children.Label},'Stats'));
    statsMenu = UIMenu.Children(statsIndex);
    if ~isempty(statsMenu.Children)
        delete(statsMenu.Children);
    end
    for j = 1:length(fnames)
        if isnumeric(ROI.(fnames{j}))
            uimenu('Parent',statsMenu,'Label',sprintf('%s: %g',fnames{j},ROI.(fnames{j})));
        end
    end
    compareIndex = find(strcmp({UIMenu.Children.Label},'Compare Against...'));
    compareMenu = UIMenu.Children(compareIndex);
    if ~isempty(compareMenu.Children)
        delete(compareMenu.Children);
    end
    for j = [1:index-1 index+1:length(ROI.imHandle.UserData.ROI)];
       uimenu('Parent',compareMenu,'Label',ROI.imHandle.UserData.ROI(j).Name,'Callback',@compareAgainst,'ForeGroundColor',ROI.imHandle.UserData.ROI(j).patchHandle(1).FaceColor); 
    end
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
patchHandle = patch(x,y,get(axH,'XColor'),'edgecolor',get(axH,'XColor'),'facecolor',ColorOrder(mod(index-1,size(ColorOrder,1))+1,:),'facealpha',0.3,'Tag','ROI');
c = uicontextmenu('UserData',struct('imHandle',imHandle,'patchHandle',patchHandle));
patchHandle.UIContextMenu = c;
uimenu(c,'Label','NAME','Callback',@renameROI);
uimenu(c,'Label','Delete','Callback',@deleteROI);
uimenu(c,'Label','Edit','Callback',@editROI);
uimenu(c,'Label','Add To ROI','Callback',@addNewROI);
uimenu(c,'Label','Stats');
uimenu(c,'Label','Compare Against...');
end

function compareAgainst(hObject,eventdata)
imHandle = hObject.Parent.Parent.UserData.imHandle;
patchHandle = hObject.Parent.Parent.UserData.patchHandle;
[index0,patchindex0] = findROI(imHandle,patchHandle);
index1 = find(strcmp({imHandle.UserData.ROI.Name},hObject.Label));
roidata0 = imHandle.UserData.ROI(index0);
roidata1 = imHandle.UserData.ROI(index1);
mask0 = getROImask(imHandle,roidata0.patchHandle);
mask1 = getROImask(imHandle,roidata1.patchHandle);
cdata = imHandle.CData;
[H,P,CI] = ttest2(cdata(mask0),cdata(mask1));
Comparison.fgROI = imHandle.UserData.ROI(index0).Name;
Comparison.bgROI = imHandle.UserData.ROI(index1).Name;
Comparison.contrast = (roidata0.mean-roidata1.mean)/roidata1.mean;
Comparison.std_joint = sqrt((roidata0.N*(roidata0.std^2)+roidata1.N*(roidata1.std^2))/(roidata0.N+roidata1.N));
Comparison.CNR = Comparison.contrast/Comparison.std_joint;
Comparison.TTest_UnequalMeans = H;
Comparison.TTest_PValue = P;
Comparison.TTest_DiffMeansCI = CI;
fprintf('Comparison:\n');
disp(Comparison);
imHandle.UserData.Comparison = Comparison;
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
roidata.N = numel(c);
roidata.mean = nanmean(c);
roidata.std = nanstd(c);
roidata.median = nanmedian(c);
roidata.snr = roidata.mean/roidata.std;
roidata.mask = mask;
end
