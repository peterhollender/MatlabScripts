%IMG2TXT print a 2-D image as unicode characters to the display
%str = img2txt(im,ds,clim)
function str = img2txt(im,ds,clim)
ramp = ['ÆÆÑÑÑÑÑMMMØWWËËÂæÉÉÄÄBÀÁ®®#ĞğRKøã©ÖŞ8äÿàG¼¼û9k$eTaú«òV&YÌ33±uJoîjjItrïíl¿i77?)<<;ª+°×!¡::º¬|?,,¯²-³¦¦~~¹¹??...????¸¸¸`·····     '];
if ds<0
    ramp = fliplr(ramp);
end
if ~exist('clim','var')
    clim = [min(im(:)) max(im(:))];
end
im = nanmin(1,nanmax(0,(im - clim(1))/diff(clim)));
if abs(ds) == 1
    im2 = im;
else
    im1 = [];
    for i = 1:size(im,2)
        im1(:,i) = resample(im(:,i),1,2*abs(ds));
    end
    im2 = [];
    for i = 1:size(im1,1)
        im2(i,:) = resample(im1(i,:),1,abs(ds));
    end
    im2(:) = nanmin(1,nanmax(0,im2(:)));
end
str0 = ramp(round(im2*(length(ramp)-1))+1);
str0 = reshape([str0 repmat(sprintf('\n'),size(str0,1),1)]',[],1)';
if nargout == 0
    disp(str0)
else
    str = str0;
end
