function B = prctilefilt(A,kernel,frac)
Atmp = repmat(A,[1 1 kernel]);
shifts = [-(kernel-1)/2:(kernel-1)/2];
for i = 1:kernel;
    zidx = (1:size(A,1)) + shifts(i);
    A0 = A;
    nanidx = find(zidx<1 | zidx>size(A,1));
    for rowidx = 1:length(nanidx);
        A0(nanidx(rowidx),:) = ((-1)^mod(rowidx,2))*inf;
    end
    A0(zidx>=1 & zidx<=size(A,1),:) = A(zidx(zidx>=1 & zidx<=size(A,1)),:);
    Atmp(:,:,i) = A0;
end
prct = linspace(0,1,kernel);
Atmp = sort(Atmp,3);
idx = find(prct>=frac,1,'first');
if idx<kernel
ifrac = (frac-prct(idx))/(prct(idx+1)-prct(idx));
B = Atmp(:,:,idx)*(1-ifrac) + Atmp(:,:,idx+1)*ifrac;
else
B = Atmp(:,:,idx);
end
