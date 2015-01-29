function axPosCode = getAxisPosCode(H)
props = {'CameraPosition','CameraTarget','CameraUpVector','CameraViewAngle'};
if ~exist('H','var')
    p = get(gca);
    axPosCode = 'set(gca,';
else
    p = get(H);
    axPostCode = sprintf('set(%0.0f,',H);
end
for i = 1:length(props);
    axPosCode = sprintf('%s''%s'',[%s\b],',axPosCode,props{i},sprintf('%0.0f ',p.(props{i})));
end
axPosCode = sprintf('%s''Projection'',''%s'');',axPosCode,p.Projection);
