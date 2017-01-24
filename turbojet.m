function map = turbojet(N)
if ~exist('N','var')
    N = size(get(gcf,'Colormap'),1);
end

colorList1 = [...
    0.502 0 0;...
    0.79 0.795 0;...
    0.5 1 0.5];
map1 = genColorMap(colorList1,ceil(N/2));

colorList2 = [...
    0.0407 0.0407 1;...
    0.5 1 0.5;...
    0.006 1 1];
map2 = genColorMap(colorList2,ceil(N/2));
if mod(N,2)
    map2 = map2(1:end-1,:);
end
map = flipud([map1;flipud(map2)]);
end
