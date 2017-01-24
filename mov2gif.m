function mov2gif(M,filename,fps,loopcount)
if ~exist('fps','var')
    fps = 20;
end
if ~exist('loopcount','var')
    loopcount = inf;
end
RGB = [M.cdata];
[X map] = rgb2ind(RGB,255);
X = reshape(X,size(M(1).cdata,1),size(M(1).cdata,2),1,[]);
[pth fname ext] = fileparts(filename);
imwrite(X,map,fullfile(pth,[fname '.gif']),'gif','LoopCount',inf,'DelayTime',1/fps);
