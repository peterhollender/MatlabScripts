function H = surfStack(Z,X,Y,V,A,dim,DownSampleVolume,DownSampleImage);
%SURFSTACK show volume of data as stack of surfaces
% H = surfStack(Z,X,Y,V,A,dim,DownSample)
% surfStack takes the volumetric data specified in V and the transparency
% (alpha) data stored in A, in displays it in 3-D according to the axis
% vectors Z,X,and Y, corresponding to the 1st, 2nd, and 3rd dimensions of
% V.
%
% INPUTS:
%   Z: axis vector in the first (axial) direction (Mx1)
%   X: axis vector in the second (lateral) direction (Nx1)
%   Y: axis vector in the third (elevational) direction (Px1)
%   V: volumetric data, scaled (MxNxP) or RGB (MxNxPx3)
%   A: transparency data, scaled {0,1}, (MxNxP).
%   dim: data dimension normal to each plane (1,2, or 3) - defaults to 3
%   DownSample: downsampling factor applying to entire volume 
%       Three element vector [ds_z ds_z ds_y] specifies per dimension, and
%       a single value will specifiy all three dimensions
%
% OUTPUTS:
%   H: Handle vector pointing to the surfaces
%
% BE AWARE THAT RENDERING TIMES CAN BE VERY LONG FOR LARGE DATASETS!
% USING SEMI-TRANSPARENCY (0<VALUE<1) ALSO INCREASES RENDERING TIME!
%
% Use 'cameratoolbar show' to get more advanced camera control to specify
% a new CameraUpVector for easier rotation of complex volumes
%
% See also CAMERATOOLBAR

% Version History
% Created 09/02/2013
% Peter Hollender

if ~exist('dim','var')
    dim = 3;
end
if ~exist('DownSampleVolume','var')
    DownSampleVolume = [1 1 1];
end
if length(DownSampleVolume) == 1
    DownSampleVolume = DownSampleVolume*[1 1 1];
end
if ~exist('DownSampleImage','var')
    DownSampleImage = DownSampleVolume;
end
if length(DownSampleImage) == 1
    DownSampleImage= DownSampleImage*[1 1 1];
end
holdState = get(gca,'nextPlot');
if numel(V)==3;
    V = permute(V(:),[2 3 4 1]);
end
[sz(1) sz(2) sz(3) rgbn] = size(V);
[sz1(1) sz1(2) sz1(3)] = size(A);
if any(sz>sz1)
A = repmat(A,[sz./sz1]);
elseif any(sz1>sz)
V = repmat(V,[sz1./sz 1]);
sz = sz1;
end
A(isnan(V)) = 0;

idx1v = (1:DownSampleVolume(1):length(Z));idx1v = floor(idx1v-mean(idx1v)+((length(Z)+1)/2));
idx2v = (1:DownSampleVolume(2):length(X));idx2v = floor(idx2v-mean(idx2v)+((length(X)+1)/2));
idx3v = (1:DownSampleVolume(3):length(Y));idx3v = floor(idx3v-mean(idx3v)+((length(Y)+1)/2));
z = Z(idx1v);
x = X(idx2v);
y = Y(idx3v);
dx = mean(diff(X));
dy = mean(diff(Y));
dz = mean(diff(Z));

for dimidx = 1:length(dim)
if dimidx>1
    set(gca,'nextPlot','add');
end
switch dim(dimidx);
        case 1
        idx1i = (1:DownSampleVolume(1):length(Z));idx1i = floor(idx1i-mean(idx1i)+((length(Z)+1)/2));
        idx2i = (1:DownSampleImage(2):length(X));idx2i = floor(idx2i-mean(idx2i)+((length(X)+1)/2));
        idx3i = (1:DownSampleImage(3):length(Y));idx3i = floor(idx3i-mean(idx3i)+((length(Y)+1)/2));
        v = V(idx1i,idx2i,idx3i,:);
        a = A(idx1i,idx2i,idx3i);    
        xdata = [x(1)-2*dx;x(1)-dx;x(:);x(end)+dx] - dx/2;
        ydata = [y(1)-2*dy;y(1)-dy;y(:);y(end)+dy] - dy/2;
        [xdata ydata] = meshgrid(xdata,ydata);
        zdata = z;
        for i = 1:length(z)
            
        cdata =  permute(squeeze(padarray(padarray(v(i,:,:,:),...
            [0 2 2 0].*[round(DownSampleVolume./DownSampleImage) 1],'pre'),...
            [0 1 1 0].*[round(DownSampleVolume./DownSampleImage) 1],'post')),[2 1 3 4]);
        adata = permute(squeeze(padarray(padarray(a(i,:,:),...
            [0 2 2].*[round(DownSampleVolume./DownSampleImage)],'pre'),...
            [0 1 1].*[round(DownSampleVolume./DownSampleImage)],'post')),[2 1 3]);
        H{dimidx}(i) = surf(xdata,ydata,zdata(i)*ones(size(ydata)),...
            'facecolor','texture','cdata',double(cdata),...
            'edgecolor','none','alphadata',double(adata),...
            'facealpha','texture','alphadatamapping','none');
        end
        case 2
        idx1i = (1:DownSampleImage(1):length(Z));idx1i = floor(idx1i-mean(idx1i)+((length(Z)+1)/2));
        idx2i = (1:DownSampleVolume(2):length(X));idx2i = floor(idx2i-mean(idx2i)+((length(X)+1)/2));
        idx3i = (1:DownSampleImage(3):length(Y));idx3i = floor(idx3i-mean(idx3i)+((length(Y)+1)/2));        v = V(idx1i,idx2i,idx3i,:);
        a = A(idx1i,idx2i,idx3i);         
        zdata = [z(1)-2*dz;z(1)-dz;z(:);z(end)+dz] - dz/2;
        ydata = [y(1)-2*dy;y(1)-dy;y(:);y(end)+dy] - dy/2;
        [zdata ydata] = meshgrid(zdata,ydata);
        xdata = x;
        for i = 1:length(x)
        cdata =  permute(squeeze(padarray(padarray(v(:,i,:,:),...
            [2 0 2 0].*[round(DownSampleVolume./DownSampleImage) 1],'pre'),...
            [1 0 1 0].*[round(DownSampleVolume./DownSampleImage) 1],'post')),[2 1 3 4]);
        adata = permute(squeeze(padarray(padarray(a(:,i,:),...
            [2 0 2].*[round(DownSampleVolume./DownSampleImage)],'pre'),...
            [1 0 1].*[round(DownSampleVolume./DownSampleImage)],'post')),[2 1 3]);
        H{dimidx}(i) = surf(xdata(i)*ones(size(ydata)),ydata,zdata,...
            'facecolor','texture','cdata',double(cdata),...
            'edgecolor','none','alphadata',double(adata),...
            'facealpha','texture','alphadatamapping','none');    
        end   
        
    case 3
        idx1i = (1:DownSampleImage(1):length(Z));idx1i = floor(idx1i-mean(idx1i)+((length(Z)+1)/2));
        idx2i = (1:DownSampleImage(2):length(X));idx2i = floor(idx2i-mean(idx2i)+((length(X)+1)/2));
        idx3i = (1:DownSampleVolume(3):length(Y));idx3i = floor(idx3i-mean(idx3i)+((length(Y)+1)/2));        v = V(idx1i,idx2i,idx3i,:);
        a = A(idx1i,idx2i,idx3i); 
        xdata = [x(1)-2*dx;x(1)-dx;x(:);x(end)+dx] - dx/2;
        zdata = [z(1)-2*dz;z(1)-dz;z(:);z(end)+dz] - dz/2;
        [xdata zdata] = meshgrid(xdata,zdata);
        ydata = y;
        for i = 1:length(y)
         cdata =  permute(squeeze(padarray(padarray(v(:,:,i,:),...
            [2 2 0 0].*[round(DownSampleVolume./DownSampleImage) 1],'pre'),...
            [1 1 0 0].*[round(DownSampleVolume./DownSampleImage) 1],'post')),[1 2 3 4]);
        adata = permute(squeeze(padarray(padarray(a(:,:,i),...
            [2 2 0].*[round(DownSampleVolume./DownSampleImage)],'pre'),...
            [1 1 0].*[round(DownSampleVolume./DownSampleImage)],'post')),[1 2 3]);
        H{dimidx}(i) = surf(xdata,ydata(i)*ones(size(zdata)),zdata,...
            'facecolor','texture','cdata',double(cdata),...
            'edgecolor','none','alphadata',double(adata),...
            'facealpha','texture','alphadatamapping','none');        
%         cdata =  padarray(padarray(...
%             permute(squeeze(v(:,:,i,:)),[1 2 3]),...
%             [2 2 0],'pre'),[1 1 0],'post');
%         adata = padarray(padarray(...
%             permute(squeeze(double(a(:,:,i))),[1 2 3]),...
%             [2 2 0],'post'),[1 1 0],'pre');
%         H{dimidx}(i) = surf(xdata,ydata(i)*ones(size(zdata)),zdata,cdata,...
%             'edgecolor','none','alphadata',adata,...
%             'facealpha','flat','alphadatamapping','none');
        end

end
end
set(gca,'nextPlot',holdState);