function mov2gif(M,filename,fps,loopcount)
if ~exist('fps','var')
    fps = 20;
end
if ~exist('loopcount','var')
    loopcount = inf;
end
RGB = [M.cdata];
[X map] = rgb2ind(RGB,255);
[pk,idx] = max(mean(rgb2gray(map),2));
if pk>0.9
    map(idx,:) = 1.0;
end
[pk,idx] = min(mean(rgb2gray(map),2));
if pk<0.1
    map(idx,:) = 0;
end
X = reshape(X,size(M(1).cdata,1),size(M(1).cdata,2),1,[]);
[pth fname ext] = fileparts(filename);
imwrite(X,map,fullfile(pth,[fname '.gif']),'gif','LoopCount',inf,'DelayTime',1/fps);
