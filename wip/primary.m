%Gray = 0.2989 * R + 0.5870 * G + 0.1140 * B 
function map = primary(N)
if ~exist('N','var')
    N = size(get(gcf,'Colormap'),1);
end

colorList = [...
    0 0 0;...
    1 0 0;...
    0 0 1;...
    0.3 0 0.9;...
    1 1 0;...
    1 1 1];
map = genColorMap(colorList,N);
end

function map = genColorMap(colorList,N)
grayVals = rgb2gray(permute(colorList,[1 3 2]));
[sortGray, sortIdx] = sort(grayVals);
colorSort = colorList(sortIdx,:);
breakPoints = (sortGray-sortGray(1))/(sortGray(end)-sortGray(1));
brkpt0 = 0;
r0 = colorSort(1,1);
g0 = colorSort(1,2);
b0 = colorSort(1,3);
r = colorSort(end,1)*ones(N,1);
g = colorSort(end,2)*ones(N,1);
b = colorSort(end,3)*ones(N,1);
x = linspace(0,1,N)';
for i = 1:length(colorList)
    brkpt = breakPoints(i);
    idx = find(x>=brkpt0 & x<=brkpt);
    r(idx) = r0+(colorSort(i,1)-r0)*(x(idx)-brkpt0)/(brkpt-brkpt0);
    g(idx) = g0+(colorSort(i,2)-g0)*(x(idx)-brkpt0)/(brkpt-brkpt0);
    b(idx) = b0+(colorSort(i,3)-b0)*(x(idx)-brkpt0)/(brkpt-brkpt0);
    r0 = colorSort(i,1);
    g0 = colorSort(i,2);
    b0 = colorSort(i,3);
    brkpt0 = brkpt;
end
map = [r g b];
end
