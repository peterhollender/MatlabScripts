%GENCOLORMAP create grayscale-safe color map
%
% map = genColorMap(colorSpec,N)
% genColorMap creates a colormap of size Nx3 that linearly interpolates
% between the specified colors. The colors are sorted by their NTSC
% luminance value (using RGB2GRAY), and a color map is built by linearly
% interpolating between the colors, spacing them so that the luminance
% value is a linear function between the overall minimum and maximum
% luminance. This means that when converted to grayscale, or printed on a
% non-color printer, the colors will map to a linear grayscale. 
%
% Inputs
%   colorSpec: color specification. colorspec can be:
%       an M x 3 array of double or single precision RGB values [0,1]
%       an M x 3 array of uint8 values [0,255]
%       a character array specifying one of the preset custom color maps
%           'brazil','duke','easter','grass','hotter','ncstate','primary',
%           'rocket', or 'sunset'
%       a 1 x M character array specifying built-in MATLAB colors
%           'r','g','b','c','m','y','k','w'
%       a 1 x M or M x 1 cell array, whose elements are RGB values or
%       characters specifying built-in MATLAB colors
%   N: the length of the color map. If not included, the length of the
%       colormap from the current figure will be used.
%
% Outputs
%   map: N x 3 color array that can be fed into the COLORMAP function
%
% see also COLORMAP RGB2GRAY RGB2NTSC

% Revision History
% Created 07/10/14 Peter Hollender

function map = genColorMap(colorSpec,N)
if ~exist('N','var')
    N = size(get(gcf,'Colormap'),1);
end
colorList = parseColorSpec(colorSpec);
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
for i = 1:size(colorList,1)
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

function colorList = parseColorSpec(colorSpec)
builtInColors = {'y','m','c','r','g','b','w','k'};
builtInRGB = {[1 1 0],[1 0 1],[0 1 1],[1 0 0],[0 1 0],[0 0 1],[1 1 1],[0 0 0]};
switch class(colorSpec)
    case {'double','single'}
        colorList = squeeze(double(colorSpec));
    case 'uint8'
        colorList = squeeze(double(colorSpec)/255);
    case 'char'
        switch lower(colorSpec)
            case 'brazil'
                colorList = [0 0 0;0 0 0.9;0 .9 0;1 1 0;1 1 1];
            case 'duke'
                colorList = [0 0 0;0 0 0.9;1 1 1];
            case 'easter'
                colorList = [0 0 0;.714 0 .714;1 0.7 0;1 1 0;1 1 1];
            case 'grass'
                colorList = [0 0 0;0 0.5 0;1 1 .4;1 1 1];
            case {'hotter','hot'}
                colorList = [0 0 0;1 0 0;1 1 0;1 1 1];
            case 'ncstate'
                colorList = [0 0 0;1 0 0;1 1 1];
            case 'primary'
                colorList = [0 0 0;1 0 0;0 0 1;0.3 0 0.9;1 1 0;1 1 1];
            case 'rocket'
                colorList = [0 0 0;0 0 1;1 0 0;0 0.85 0;1 0.6 0;1 1 0;1 1 1];
            case 'sunset'
                colorList = [0 0 0;0.25 0 .5;1 0.15 0;1 0.8 0;1 1 1];

            otherwise
                colorList = nan(length(colorSpec),3);
                for i = 1:length(colorSpec)
                   matches = strcmpi(colorSpec(i),builtInColors);
                   if ~any(matches)
                       error('couldn''t interpret colorSpec %s.',colorSpec);
                   end
                   colorList(i,:) = builtInRGB{matches};
                end
        end
    case 'cell'
        colorList = nan(length(colorSpec),3);
        for i = 1:length(colorSpec)
            colorList(i,:) = parseColorSpec(colorSpec{i});
        end
end
end
            
    