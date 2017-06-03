%mov2file write movie to video file using VideoWriter
%
%mov2file(M,VidName,fps,format)
function mov2file(M,VidName,fps,format,varargin)
if ~exist('format','var')
    format = 'Motion JPEG AVI';
end
VidObj = VideoWriter(VidName,format);
if ~isempty(varargin)
    VidObj = setprops(VidObj,varargin{:});
end
ext = VidObj.FileFormat;
[pth name] = fileparts(VidName);
VidName = fullfile(pth,[name '.' ext]);
fprintf('Writing %s...',VidName);
set(VidObj,'FrameRate',fps)
open(VidObj)
for i = 1:length(M);
writeVideo(VidObj,M(i));
end
close(VidObj)
fprintf('done\n');
end