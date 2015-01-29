%LOGNORM Log-compress matrix
function imlog = lognorm(im)
imlog = 20*log10(im./max(im(:)));

