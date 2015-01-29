function mov2mpeg(M,VidName,fps)
fprintf('Writing %s...',VidName);
VidObj = VideoWriter(VidName,'MPEG-4');
set(VidObj,'FrameRate',fps)
open(VidObj)
for i = 1:length(M);
writeVideo(VidObj,M(i));
end
close(VidObj)
fprintf('done\n');
end