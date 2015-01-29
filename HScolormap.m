function map = HScolormap(map0)
hsv = rgb2hsv(permute(map0,[1 3 2]));
hsv = hsv(:,:,[1 3 2]);
hsv(:,:,3) = hsv(:,:,2);
map = squeeze(hsv2rgb(hsv));
