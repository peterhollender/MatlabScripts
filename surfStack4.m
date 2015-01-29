function H = surfStack3(Z,X,Y,V,A,dim,DownSampleVolume,DownSampleImage);
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
if strcmpi(holdState,'replace');
    cla
end
set(gca,'nextPlot','add');
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
% x = [x-dx/2 x(end)+dx/2];
% y = [y-dy/2 y(end)+dy/2];
% z = [z-dz/2 z(end)+dz/2];


for dimidx = 1:length(dim)
switch dim(dimidx);
        case 1
        idx1i = (1:DownSampleVolume(1):length(Z));idx1i = floor(idx1i-mean(idx1i)+((length(Z)+1)/2));
        idx2i = (1:DownSampleImage(2):length(X));idx2i = floor(idx2i-mean(idx2i)+((length(X)+1)/2));
        idx3i = (1:DownSampleImage(3):length(Y));idx3i = floor(idx3i-mean(idx3i)+((length(Y)+1)/2));
        v = V(idx1i,idx2i,idx3i,:);
        a = A(idx1i,idx2i,idx3i);    

        xdata = ((x-mean(x))*(length(x)+1)/length(x))+mean(x);
        ydata = ((y-mean(y))*(length(y)+1)/length(y))+mean(y);
        %xdata = x;ydata = y;zdata = z;
        xdata = linspace(xdata(1),xdata(end),2);
        ydata = linspace(ydata(1),ydata(end),2);
        xdata = linspace(x(1)-dx/2,x(end)+dx/2,2);
        ydata = linspace(y(1)-dy/2,y(end)+dy/2,2);
        [xdata ydata] = meshgrid(xdata,ydata);        
        zdata = z;
        for i = 1:length(zdata)
        cdata = double(permute(v(i,:,:,:),[3 2 4 1]));
        adata = double(permute(a(i,:,:,:),[3 2 4 1]));
        H{dimidx}(i) = surf(xdata,ydata,zdata(i)*ones(size(ydata)),...
            'facecolor','texture','cdata',cdata,...
            'edgecolor','none','alphadata',adata,...
            'facealpha','texture','alphadatamapping','none');
        end
        case 2
        idx1i = (1:DownSampleImage(1):length(Z));idx1i = floor(idx1i-mean(idx1i)+((length(Z)+1)/2));
        idx2i = (1:DownSampleVolume(2):length(X));idx2i = floor(idx2i-mean(idx2i)+((length(X)+1)/2));
        idx3i = (1:DownSampleImage(3):length(Y));idx3i = floor(idx3i-mean(idx3i)+((length(Y)+1)/2));        v = V(idx1i,idx2i,idx3i,:);
        a = A(idx1i,idx2i,idx3i);         
        ydata = ((y-mean(y))*(length(y)+1)/length(y))+mean(y);
        zdata = ((z-mean(z))*(length(z)+1)/length(z))+mean(z);
        %xdata = x;ydata = y;zdata = z;
        ydata = linspace(ydata(1),ydata(end),2);
        zdata = linspace(zdata(1),zdata(end),2);
        ydata = linspace(y(1)-dy/2,y(end)+dy/2,2);
        zdata = linspace(z(1)-dz/2,z(end)+dz/2,2);
        
        [zdata ydata] = meshgrid(zdata,ydata);
        xdata = x;
        for i = 1:length(xdata)
        cdata = double(permute(v(:,i,:,:),[3 1 4 2]));
        adata = double(permute(a(:,i,:,:),[3 1 4 2]));
        H{dimidx}(i) = surf(xdata(i)*ones(size(ydata)),ydata,zdata,...
            'facecolor','texture','cdata',cdata,...
            'edgecolor','none','alphadata',adata,...
            'facealpha','texture','alphadatamapping','none');    
        end   
        
    case 3
        idx1i = (1:DownSampleImage(1):length(Z));idx1i = floor(idx1i-mean(idx1i)+((length(Z)+1)/2));
        idx2i = (1:DownSampleImage(2):length(X));idx2i = floor(idx2i-mean(idx2i)+((length(X)+1)/2));
        idx3i = (1:DownSampleVolume(3):length(Y));idx3i = floor(idx3i-mean(idx3i)+((length(Y)+1)/2));        v = V(idx1i,idx2i,idx3i,:);
        a = A(idx1i,idx2i,idx3i); 
        xdata = ((x-mean(x))*(length(x)+1)/length(x))+mean(x);
        zdata = ((z-mean(z))*(length(z)+1)/length(z))+mean(z);
        %xdata = x;ydata = y;zdata = z;
        xdata = linspace(xdata(1),xdata(end),2);
        zdata = linspace(zdata(1),zdata(end),2);
        xdata = linspace(x(1)-dx/2,x(end)+dx/2,2);
        zdata = linspace(z(1)-dz/2,z(end)+dz/2,2);
        [xdata zdata] = meshgrid(xdata,zdata);
        ydata = y;
        for i = 1:length(ydata)
        cdata = double(permute(v(:,:,i,:),[1 2 4 3]));
        adata = double(permute(a(:,:,i,:),[1 2 4 3])); 
        H{dimidx}(i) = surf(xdata,ydata(i)*ones(size(zdata)),zdata,...
            'facecolor','texture','cdata',cdata,...
            'edgecolor','none','alphadata',adata,...
            'facealpha','texture','alphadatamapping','none');        
        end

end
end
set(gca,'nextPlot',holdState);