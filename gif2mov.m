function [M, info]= gif2mov(filename)
[path, fname] = fileparts(filename);
filename = fullfile(path,[fname '.gif']);
[im,map] = imread(filename);
M = struct('cdata',[],'colormap',[]);
for i = 1:size(im,4)
    M(i).cdata = uint8(255*ind2rgb(im(:,:,1,i),map));
end
if nargout>1
    info = imfinfo(filename);
    info = info(1);
end