function [h cb] = imagecolor(cmap,varargin)
k = get(gca,'Children');
if ~isempty(k) && strcmpi(get(gca,'NextPlot'),'add')
h0 = imagesc(varargin{:});
set(h0,'visible','off')
set(gca,'Children',[k;h0]);
end
h = imagesc(varargin{:});
map0 = colormap;
map = colormap(cmap);
N = size(map,1);
colormap(map0)
data = get(h,'CData');
clim = caxis;
idx = min(N,max(1,1+floor((N-1)*((data-clim(1))/diff(clim)))));
data1 = zeros(size(data,1),size(data,2),3);
if nargout == 2
    cb = colorbar;
    cbk = get(cb,'Children');
    set(cbk,'CData',permute(map,[1 3 2]));
end
    
for i = 1:3
    data1(:,:,i) = reshape(map(idx,i),size(data1,1),size(data1,2));
end
set(h,'CData',data1,'CDataMapping','direct');
