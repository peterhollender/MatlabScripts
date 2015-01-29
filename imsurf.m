function imh = imsurf(th,r,apex,im,cax)
th = th(:);
r = r(:);
r = [r;r(end)+diff(r(end-1:end))];
th = [th;th(end)+diff(th(end-1:end))];
r = r-mean(diff(r))/2;
th = th-mean(diff(th))/2;
[TH R] = meshgrid(th,r);
x = R.*sind(TH) - apex*tand(TH);
y = R.*cosd(TH);
imh = surf(x,y,0*y,im,'facecolor','texture');
set(imh,'edgecolor','none');
if strcmpi(get(gca,'NextPlot'),'replace');
axis ij;
axis image;
view([0 90]);
end
if exist('cax','var')
    caxis(cax);
end
