function camPosCode = getCamPosCode
left = @(x,n)x(1:(mod(n-1,length(x))+1));
matattr = {'CameraPosition','CameraTarget','CameraUpVector','CameraViewAngle','Xlim','Ylim','Zlim'};
textattr = {'XDir','YDir','ZDir','Projection'};
camPosCode = ['set(gca'];
for i = 1:length(matattr)
    camPosCode = [camPosCode,sprintf(',''%s'',[%s]',matattr{i},left(sprintf('%g ',get(gca,matattr{i})),-1))];
end
for i = 1:length(textattr)
    camPosCode = [camPosCode,sprintf(',''%s'',''%s''',textattr{i},get(gca,textattr{i}))];
end
camPosCode = [camPosCode sprintf(');\n')];
clipboard('copy',camPosCode);