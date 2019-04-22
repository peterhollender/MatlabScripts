function H = surfStack2(Z,X,Y,V,A,dim,DownSampleVolume,DownSampleImage);
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
if sum(size(Z)>1)==1
    Z = repmat(permute(Z(:),[1 2 3]),[1 size(V,2) size(V,3)]);
end
if sum(size(X)>1)==1
    X = repmat(permute(X(:),[2 1 3]),[size(V,1) 1 size(V,3)]);
end
if sum(size(Y)>1)==1
    Y = repmat(permute(Y(:),[3 2 1]),[size(V,1) size(V,2) 1]);
end

WB = waitbar(0,'Interpolating...');
ii = 0;
nInterps = 15*length(dim);
for dimidx = 1:length(dim)
    switch dim(dimidx);
        case 1
            v = V;
            v = permute(interp1(1:size(v,1),permute(v,[1 2 3 4]),linspace(1,size(v,1),ceil(size(v,1)/DownSampleVolume(1))+1),'linear'),[1 2 3 4]);ii = ii+1;waitbar(ii/nInterps,WB);
            v = permute(interp1(1:size(v,2),permute(v,[2 1 3 4]),linspace(1,size(v,2),ceil(size(v,2)/DownSampleImage(2))),'linear'),[2 1 3 4]);ii = ii+1;waitbar(ii/nInterps,WB);
            v = permute(interp1(1:size(v,3),permute(v,[3 2 1 4]),linspace(1,size(v,3),ceil(size(v,3)/DownSampleImage(3))),'linear'),[3 2 1 4]);ii = ii+1;waitbar(ii/nInterps,WB);

            a = A;
            a = permute(interp1(1:size(a,1),permute(a,[1 2 3]),linspace(1,size(a,1),ceil(size(a,1)/DownSampleVolume(1))+1),'linear'),[1 2 3]);ii = ii+1;waitbar(ii/nInterps,WB);
            a = permute(interp1(1:size(a,2),permute(a,[2 1 3]),linspace(1,size(a,2),ceil(size(a,2)/DownSampleImage(2))),'linear'),[2 1 3]);ii = ii+1;waitbar(ii/nInterps,WB);
            a = permute(interp1(1:size(a,3),permute(a,[3 2 1]),linspace(1,size(a,3),ceil(size(a,3)/DownSampleImage(3))),'linear'),[3 2 1]);ii = ii+1;waitbar(ii/nInterps,WB);
            
            z1 = Z;
            z1 = permute(interp1(1:size(z1,1),permute(z1,[1 2 3]),linspace(0.5,size(z1,1)+0.5,ceil(size(z1,1)/DownSampleVolume(1))+1),'linear','extrap'),[1 2 3]);ii = ii+1;waitbar(ii/nInterps,WB);
            z1 = permute(interp1(1:size(z1,2),permute(z1,[2 1 3]),linspace(0.5,size(z1,2)+0.5,ceil(size(z1,2)/DownSampleVolume(2))+1),'linear','extrap'),[2 1 3]);ii = ii+1;waitbar(ii/nInterps,WB);
            z1 = permute(interp1(1:size(z1,3),permute(z1,[3 2 1]),linspace(0.5,size(z1,3)+0.5,ceil(size(z1,3)/DownSampleVolume(3))+1),'linear','extrap'),[3 2 1]);ii = ii+1;waitbar(ii/nInterps,WB);
            
            x1 = X;
            x1 = permute(interp1(1:size(x1,1),permute(x1,[1 2 3]),linspace(0.5,size(x1,1)+0.5,ceil(size(x1,1)/DownSampleVolume(1))+1),'linear','extrap'),[1 2 3]);ii = ii+1;waitbar(ii/nInterps,WB);
            x1 = permute(interp1(1:size(x1,2),permute(x1,[2 1 3]),linspace(0.5,size(x1,2)+0.5,ceil(size(x1,2)/DownSampleVolume(2))+1),'linear','extrap'),[2 1 3]);ii = ii+1;waitbar(ii/nInterps,WB);
            x1 = permute(interp1(1:size(x1,3),permute(x1,[3 2 1]),linspace(0.5,size(x1,3)+0.5,ceil(size(x1,3)/DownSampleVolume(3))+1),'linear','extrap'),[3 2 1]);ii = ii+1;waitbar(ii/nInterps,WB);

            y1 = Y;
            y1 = permute(interp1(1:size(y1,1),permute(y1,[1 2 3]),linspace(0.5,size(y1,1)+0.5,ceil(size(y1,1)/DownSampleVolume(1))+1),'linear','extrap'),[1 2 3]);ii = ii+1;waitbar(ii/nInterps,WB);
            y1 = permute(interp1(1:size(y1,2),permute(y1,[2 1 3]),linspace(0.5,size(y1,2)+0.5,ceil(size(y1,2)/DownSampleVolume(2))+1),'linear','extrap'),[2 1 3]);ii = ii+1;waitbar(ii/nInterps,WB);
            y1 = permute(interp1(1:size(y1,3),permute(y1,[3 2 1]),linspace(0.5,size(y1,3)+0.5,ceil(size(y1,3)/DownSampleVolume(3))+1),'linear','extrap'),[3 2 1]);ii = ii+1;waitbar(ii/nInterps,WB);

            
            for i = 1:size(z1,1)
                cdata = squeeze(v(i,:,:,:));
                adata = squeeze(a(i,:,:));
                xdata = squeeze(x1(i,:,:));
                ydata = squeeze(y1(i,:,:));
                zdata = squeeze(z1(i,:,:));
                
                H{dimidx}(i) = surf(xdata,ydata,zdata,...
                    'facecolor','texture','cdata',cdata,...
                    'edgecolor','none','alphadata',adata,...
                    'facealpha','texture','alphadatamapping','none');
            end
        case 2
            v = V;
            v = permute(interp1(1:size(v,1),permute(v,[1 2 3 4]),linspace(1,size(v,1),ceil(size(v,1)/DownSampleImage(1))),'linear'),[1 2 3 4]);ii = ii+1;waitbar(ii/nInterps,WB);
            v = permute(interp1(1:size(v,2),permute(v,[2 1 3 4]),linspace(1,size(v,2),ceil(size(v,2)/DownSampleVolume(2))+1),'linear'),[2 1 3 4]);ii = ii+1;waitbar(ii/nInterps,WB);
            v = permute(interp1(1:size(v,3),permute(v,[3 2 1 4]),linspace(1,size(v,3),ceil(size(v,3)/DownSampleImage(3))),'linear'),[3 2 1 4]);ii = ii+1;waitbar(ii/nInterps,WB);

            a = A;
            a = permute(interp1(1:size(a,1),permute(a,[1 2 3]),linspace(1,size(a,1),ceil(size(a,1)/DownSampleImage(1))),'linear'),[1 2 3]);ii = ii+1;waitbar(ii/nInterps,WB);
            a = permute(interp1(1:size(a,2),permute(a,[2 1 3]),linspace(1,size(a,2),ceil(size(a,2)/DownSampleVolume(2))+1),'linear'),[2 1 3]);ii = ii+1;waitbar(ii/nInterps,WB);
            a = permute(interp1(1:size(a,3),permute(a,[3 2 1]),linspace(1,size(a,3),ceil(size(a,3)/DownSampleImage(3))),'linear'),[3 2 1]);ii = ii+1;waitbar(ii/nInterps,WB);
            
            
            z1 = Z;
            z1 = permute(interp1(1:size(z1,1),permute(z1,[1 2 3]),linspace(0.5,size(z1,1)+0.5,ceil(size(z1,1)/DownSampleVolume(1))+1),'linear','extrap'),[1 2 3]);ii = ii+1;waitbar(ii/nInterps,WB);
            z1 = permute(interp1(1:size(z1,2),permute(z1,[2 1 3]),linspace(0.5,size(z1,2)+0.5,ceil(size(z1,2)/DownSampleVolume(2))+1),'linear','extrap'),[2 1 3]);ii = ii+1;waitbar(ii/nInterps,WB);
            z1 = permute(interp1(1:size(z1,3),permute(z1,[3 2 1]),linspace(0.5,size(z1,3)+0.5,ceil(size(z1,3)/DownSampleVolume(3))+1),'linear','extrap'),[3 2 1]);ii = ii+1;waitbar(ii/nInterps,WB);
            
            x1 = X;
            x1 = permute(interp1(1:size(x1,1),permute(x1,[1 2 3]),linspace(0.5,size(x1,1)+0.5,ceil(size(x1,1)/DownSampleVolume(1))+1),'linear','extrap'),[1 2 3]);ii = ii+1;waitbar(ii/nInterps,WB);
            x1 = permute(interp1(1:size(x1,2),permute(x1,[2 1 3]),linspace(0.5,size(x1,2)+0.5,ceil(size(x1,2)/DownSampleVolume(2))+1),'linear','extrap'),[2 1 3]);ii = ii+1;waitbar(ii/nInterps,WB);
            x1 = permute(interp1(1:size(x1,3),permute(x1,[3 2 1]),linspace(0.5,size(x1,3)+0.5,ceil(size(x1,3)/DownSampleVolume(3))+1),'linear','extrap'),[3 2 1]);ii = ii+1;waitbar(ii/nInterps,WB);

            y1 = Y;
            y1 = permute(interp1(1:size(y1,1),permute(y1,[1 2 3]),linspace(0.5,size(y1,1)+0.5,ceil(size(y1,1)/DownSampleVolume(1))+1),'linear','extrap'),[1 2 3]);ii = ii+1;waitbar(ii/nInterps,WB);
            y1 = permute(interp1(1:size(y1,2),permute(y1,[2 1 3]),linspace(0.5,size(y1,2)+0.5,ceil(size(y1,2)/DownSampleVolume(2))+1),'linear','extrap'),[2 1 3]);ii = ii+1;waitbar(ii/nInterps,WB);
            y1 = permute(interp1(1:size(y1,3),permute(y1,[3 2 1]),linspace(0.5,size(y1,3)+0.5,ceil(size(y1,3)/DownSampleVolume(3))+1),'linear','extrap'),[3 2 1]);ii = ii+1;waitbar(ii/nInterps,WB);

            

                        
            for i = 1:size(x1,2)

                cdata = squeeze(v(:,i,:,:));
                adata = squeeze(a(:,i,:));
                xdata = squeeze(x1(:,i,:));
                ydata = squeeze(y1(:,i,:));
                zdata = squeeze(z1(:,i,:));
                
                H{dimidx}(i) = surf(xdata,ydata,zdata,...
                    'facecolor','texture','cdata',cdata,...
                    'edgecolor','none','alphadata',adata,...
                    'facealpha','texture','alphadatamapping','none');
            end
            
        case 3
            v = V;
            v = permute(interp1(1:size(v,1),permute(v,[1 2 3 4]),linspace(1,size(v,1),ceil(size(v,1)/DownSampleImage(1))),'linear'),[1 2 3 4]);ii = ii+1;waitbar(ii/nInterps,WB);
            v = permute(interp1(1:size(v,2),permute(v,[2 1 3 4]),linspace(1,size(v,2),ceil(size(v,2)/DownSampleImage(2))),'linear'),[2 1 3 4]);ii = ii+1;waitbar(ii/nInterps,WB);
            v = permute(interp1(1:size(v,3),permute(v,[3 2 1 4]),linspace(1,size(v,3),ceil(size(v,3)/DownSampleVolume(3))+1),'linear'),[3 2 1 4]);ii = ii+1;waitbar(ii/nInterps,WB);

            a = A;
            a = permute(interp1(1:size(a,1),permute(a,[1 2 3]),linspace(1,size(a,1),ceil(size(a,1)/DownSampleImage(1))),'linear'),[1 2 3]);ii = ii+1;waitbar(ii/nInterps,WB);
            a = permute(interp1(1:size(a,2),permute(a,[2 1 3]),linspace(1,size(a,2),ceil(size(a,2)/DownSampleImage(2))),'linear'),[2 1 3]);ii = ii+1;waitbar(ii/nInterps,WB);
            a = permute(interp1(1:size(a,3),permute(a,[3 2 1]),linspace(1,size(a,3),ceil(size(a,3)/DownSampleVolume(3))+1),'linear'),[3 2 1]);ii = ii+1;waitbar(ii/nInterps,WB);
            
            z1 = Z;
            z1 = permute(interp1(1:size(z1,1),permute(z1,[1 2 3]),linspace(0.5,size(z1,1)+0.5,ceil(size(z1,1)/DownSampleVolume(1))+1),'linear','extrap'),[1 2 3]);ii = ii+1;waitbar(ii/nInterps,WB);
            z1 = permute(interp1(1:size(z1,2),permute(z1,[2 1 3]),linspace(0.5,size(z1,2)+0.5,ceil(size(z1,2)/DownSampleVolume(2))+1),'linear','extrap'),[2 1 3]);ii = ii+1;waitbar(ii/nInterps,WB);
            z1 = permute(interp1(1:size(z1,3),permute(z1,[3 2 1]),linspace(0.5,size(z1,3)+0.5,ceil(size(z1,3)/DownSampleVolume(3))+1),'linear','extrap'),[3 2 1]);ii = ii+1;waitbar(ii/nInterps,WB);
            
            x1 = X;
            x1 = permute(interp1(1:size(x1,1),permute(x1,[1 2 3]),linspace(0.5,size(x1,1)+0.5,ceil(size(x1,1)/DownSampleVolume(1))+1),'linear','extrap'),[1 2 3]);ii = ii+1;waitbar(ii/nInterps,WB);
            x1 = permute(interp1(1:size(x1,2),permute(x1,[2 1 3]),linspace(0.5,size(x1,2)+0.5,ceil(size(x1,2)/DownSampleVolume(2))+1),'linear','extrap'),[2 1 3]);ii = ii+1;waitbar(ii/nInterps,WB);
            x1 = permute(interp1(1:size(x1,3),permute(x1,[3 2 1]),linspace(0.5,size(x1,3)+0.5,ceil(size(x1,3)/DownSampleVolume(3))+1),'linear','extrap'),[3 2 1]);ii = ii+1;waitbar(ii/nInterps,WB);

            y1 = Y;
            y1 = permute(interp1(1:size(y1,1),permute(y1,[1 2 3]),linspace(0.5,size(y1,1)+0.5,ceil(size(y1,1)/DownSampleVolume(1))+1),'linear','extrap'),[1 2 3]);ii = ii+1;waitbar(ii/nInterps,WB);
            y1 = permute(interp1(1:size(y1,2),permute(y1,[2 1 3]),linspace(0.5,size(y1,2)+0.5,ceil(size(y1,2)/DownSampleVolume(2))+1),'linear','extrap'),[2 1 3]);ii = ii+1;waitbar(ii/nInterps,WB);
            y1 = permute(interp1(1:size(y1,3),permute(y1,[3 2 1]),linspace(0.5,size(y1,3)+0.5,ceil(size(y1,3)/DownSampleVolume(3))+1),'linear','extrap'),[3 2 1]);ii = ii+1;waitbar(ii/nInterps,WB);

            
            for i = 1:size(y1,3)
                cdata = squeeze(v(:,:,i,:));
                adata = squeeze(a(:,:,i));
                xdata = squeeze(x1(:,:,i));
                ydata = squeeze(y1(:,:,i));
                zdata = squeeze(z1(:,:,i));

                H{dimidx}(i) = surf(xdata,ydata,zdata,...
                    'facecolor','texture','cdata',cdata,...
                    'edgecolor','none','alphadata',adata,...
                    'facealpha','texture','alphadatamapping','none');
                
            end
            
    end
end
close(WB)
set(gca,'nextPlot',holdState);
end
