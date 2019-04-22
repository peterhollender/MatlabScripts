function M = autocrop(M0,cropcolor,borderpixels)
if ~exist('cropcolor','var')
    cropcolor = [0 0 0];
end
if ~exist('borderpixels','var')
    borderpixels = 5;
end
cData = reshape([M0.cdata],size(M0(1).cdata,1),size(M0(1).cdata,2),length(M0),3);
matches = (cData(:,:,:,1)==cropcolor(1)) & (cData(:,:,:,2)==cropcolor(2)) & (cData(:,:,:,3)==cropcolor(3));
allmatches = all(matches,3);
zidx = max(1,find(~all(allmatches,2),1,'first')-borderpixels):min(size(M0(1).cdata,1),find(~all(allmatches,2),1,'last')+borderpixels);
xidx = max(1,find(~all(allmatches,1),1,'first')-borderpixels):min(size(M0(1).cdata,2),find(~all(allmatches,1),1,'last')+borderpixels);
for i = 1:length(M0);
    M(i) = M0(i);
    M(i).cdata = M(i).cdata(zidx,xidx,:);
end

