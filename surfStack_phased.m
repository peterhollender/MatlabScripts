function H = surfStack(r,theta,phi,apex,V,A,dim,ri,thetai,phii,textureupsample,H_in);
if ~exist('dim','var')
    dim = 1;
end
[phisort, ii] = sort(phi);
phi = phisort;
V = V(:,:,ii,:);
A = A(:,:,ii,:);
[sz(1) sz(2) sz(3) rgbn] = size(V);
[sz1(1) sz1(2) sz1(3)] = size(A);
A = repmat(A,[sz./sz1]);
V0 = V;
A0 = A;

if ~exist('textureupsample','var')
textureupsample = 1;
end
if length(textureupsample) == 1
    textureupsample = textureupsample([1 1 1]);
end

phi0 = phi;
theta0 = theta;
r0 = r;

if exist('ri','var')
    V  = interp1(r,V,ri); 
    A  = interp1(r,A,ri); 
    r = ri;
end
if exist('thetai','var')
    V = permute(interp1(theta,permute(V,[2 1 3 4]),thetai),[2 1 3 4]);
    A = permute(interp1(theta,permute(A,[2 1 3 4]),thetai),[2 1 3 4]);
    theta = thetai;
end
if exist('phii','var')
    V = permute(interp1(phi,permute(V,[3 2 1 4]),phii),[3 2 1 4]);
    A = permute(interp1(phi,permute(A,[3 2 1 4]),phii),[3 2 1 4]);
    phi = phii;
end
holdState = get(gca,'nextPlot');
set(gca,'nextPlot','add');


[R TH PHI] = ndgrid(r,theta,phi);
X = R.*sind(TH) - apex*tand(TH);
Y = R.*sind(PHI);
Z = R.*cosd(TH).*cosd(PHI);

for dimidx = 1:length(dim);
switch dim(dimidx)
        case 1
           
            thetai2 = linspace(theta(1),theta(end),length(theta)*textureupsample(2));
            phii2 = linspace(phi(1),phi(end),length(phi)*textureupsample(3));
            
                if length(r0)>1
                Vdata = interp1(r0,V0,r);
                Adata = interp1(r0,A0,r);
                end
                rdata = r;
                
                if length(theta0)>1
                Vdata = permute(interp1(theta0,permute(Vdata,[2 1 3 4]),thetai2),[2 1 3 4]);
                Adata = permute(interp1(theta0,permute(Adata,[2 1 3 4]),thetai2),[2 1 3 4]);
                dth = theta(end)-theta(end-1);
                thdata = [theta(1)-2*dth;theta(1)-dth;theta(:);theta(end)+dth] - dth/2;
                else
                thdata = theta;
                end
                
                 if length(phi0)>1
                Vdata = permute(interp1(phi0,permute(Vdata,[3 2 1 4]),phii2),[3 2 1 4]);
                Adata = permute(interp1(phi0,permute(Adata,[3 2 1 4]),phii2),[3 2 1 4]);
                dphi = phi(end)-phi(end-1);
                phidata = [phi(1)-2*dphi;phi(1)-dphi;phi(:);phi(end)+dphi] - dphi/2;
                else
                phidata = phi;
                 end
                 
                 Adata(isnan(Adata)) = 0;
            
   
       
        [R, TH, PHI] = ndgrid(rdata,thdata,phidata);
        X = R.*sind(TH) - apex*tand(TH);
        Y = R.*sind(PHI);
        Z = R.*cosd(TH).*cosd(PHI);
        Vdata = padarray(padarray(Vdata,[0 2 2].*textureupsample,'pre'),[0 1 1].*textureupsample,'post');
        Adata = padarray(padarray(Adata,[0 2 2].*textureupsample,'pre'),[0 1 1].*textureupsample,'post');
        
        for i = 1:length(rdata)
        if exist('H_in','var') && ishandle(H_in{dimidx}(i))
        set(H_in{dimidx}(i),'cdata',squeeze(Vdata(i,:,:)),'alphadata',squeeze(Adata(i,:,:)));
        H{dimidx}(i) = H_in{dimidx}(i);
        else
        %H{dimidx}(i) = surf(squeeze(X(i,:,:)),squeeze(Y(i,:,:)),squeeze(Z(i,:,:)),squeeze(Vdata(i,:,:)),...
        %    'edgecolor','none','alphadata',squeeze(Adata(i,:,:)),...
        %    'facealpha','flat','alphadatamapping','none');
        H{dimidx}(i) = surf(squeeze(X(i,:,:)),squeeze(Y(i,:,:)),squeeze(Z(i,:,:)),'facecolor','texture','cdata',squeeze(Vdata(i,:,:,:)),...
            'edgecolor','none','alphadata',squeeze(Adata(i,:,:)),...
            'facealpha','texture','alphadatamapping','none');
        
        end
        end
        case 2
                ri2 = linspace(r(1),r(end),length(r)*textureupsample(1));
                phii2 = linspace(phi(1),phi(end),length(phi)*textureupsample(3));
                
                if length(r0)>1
                Vdata = interp1(r0,V0,ri2);
                Adata = interp1(r0,A0,ri2);
                dr = r(end)-r(end-1);
                rdata = [r(1)-2*dr;r(1)-dr;r(:);r(end)+dr] - dr/2;
                else
                rdata = r;
                end
        
                if length(theta0)>1
                Vdata = permute(interp1(theta0,permute(Vdata,[2 1 3 4]),theta),[2 1 3 4]);
                Adata = permute(interp1(theta0,permute(Adata,[2 1 3 4]),theta),[2 1 3 4]);
                end
                thdata = theta;
                
                if length(phi0)>1
                Vdata = permute(interp1(phi0,permute(Vdata,[3 2 1 4]),phii2),[3 2 1 4]);
                Adata = permute(interp1(phi0,permute(Adata,[3 2 1 4]),phii2),[3 2 1 4]);
                dphi = phi(end)-phi(end-1);
                phidata = [phi(1)-2*dphi;phi(1)-dphi;phi(:);phi(end)+dphi] - dphi/2;
                else
                phidata = phi;
                end
                
                Adata(isnan(Adata)) = 0;
            
        [R, TH, PHI] = ndgrid(rdata,thdata,phidata);
        X = R.*sind(TH) - apex*tand(TH);
        Y = R.*sind(PHI);
        Z = R.*cosd(TH).*cosd(PHI);
        Vdata = padarray(padarray(Vdata,[2 0 2].*textureupsample,'pre'),[1 0 1].*textureupsample,'post');
        Adata = padarray(padarray(Adata,[2 0 2].*textureupsample,'pre'),[1 0 1].*textureupsample,'post');
        for i = 1:length(thdata)
        if exist('H_in','var') && ishandle(H_in{dimidx}(i))
        set(H_in{dimidx}(i),'cdata',squeeze(Vdata(:,i,:)),'alphadata',squeeze(Adata(:,i,:)));
        H{dimidx}(i) = H_in{dimidx}(i);
        else
        %H{dimidx}(i) = surf(squeeze(X(:,i,:)),squeeze(Y(:,i,:)),squeeze(Z(:,i,:)),squeeze(Vdata(:,i,:)),...
            %'edgecolor','none','alphadata',squeeze(Adata(:,i,:)),...
            %'facealpha','flat','alphadatamapping','none');
          H{dimidx}(i) = surf(squeeze(X(:,i,:)),squeeze(Y(:,i,:)),squeeze(Z(:,i,:)),'facecolor','texture','cdata',squeeze(Vdata(:,i,:,:)),...
            'edgecolor','none','alphadata',squeeze(Adata(:,i,:)),...
            'facealpha','texture','alphadatamapping','none');
    
        
        end
        end    
            
            
        case 3
           
             ri2 = linspace(r(1),r(end),length(r)*textureupsample(1));    
             thetai2 = linspace(theta(1),theta(end),length(theta)*textureupsample(2));

                if length(r0)>1
                Vdata = interp1(r0,V0,ri2);
                Adata = interp1(r0,A0,ri2);
                dr = r(end)-r(end-1);
                rdata = [r(1)-2*dr;r(1)-dr;r(:);r(end)+dr] - dr/2;
                else
                rdata = r;
                end
                
                if length(theta0)>1
                Vdata = permute(interp1(theta0,permute(Vdata,[2 1 3 4]),thetai2),[2 1 3 4]);
                Adata = permute(interp1(theta0,permute(Adata,[2 1 3 4]),thetai2),[2 1 3 4]);
                dth = theta(end)-theta(end-1);
                thdata = [theta(1)-2*dth;theta(1)-dth;theta(:);theta(end)+dth] - dth/2;
                else
                thdata = theta;
                end
                
                if length(phi0)>1
                Vdata = permute(interp1(phi0,permute(Vdata,[3 2 1 4]),phi),[3 2 1 4]);
                Adata = permute(interp1(phi0,permute(Adata,[3 2 1 4]),phi),[3 2 1 4]);
                end
                phidata = phi;
                
                Adata(isnan(Adata)) = 0;
            
        [R, TH, PHI] = ndgrid(rdata,thdata,phidata);
        X = R.*sind(TH) - apex*tand(TH);
        Y = R.*sind(PHI);
        Z = R.*cosd(TH).*cosd(PHI);
        Vdata = padarray(padarray(Vdata,[2 2 0].*textureupsample,'pre'),[1 1 0].*textureupsample,'post');
        Adata = padarray(padarray(Adata,[2 2 0].*textureupsample,'pre'),[1 1 0].*textureupsample,'post');
        for i = 1:length(phidata)
        if exist('H_in','var') && ishandle(H_in{dimidx}(i))
        set(H_in{dimidx}(i),'cdata',squeeze(Vdata(:,:,i)),'alphadata',squeeze(Adata(:,:,i)));
        H{dimidx}(i) = H_in{dimidx}(i);
        else
    %    H{dimidx}(i) = surf(squeeze(X(:,:,i)),squeeze(Y(:,:,i)),squeeze(Z(:,:,i)),squeeze(Vdata(:,:,i)),...
    %        'edgecolor','none','alphadata',squeeze(Adata(:,:,i)),...
    %        'facealpha','flat','alphadatamapping','none');
        H{dimidx}(i) = surf(squeeze(X(:,:,i)),squeeze(Y(:,:,i)),squeeze(Z(:,:,i)),'facecolor','texture','cdata',squeeze(Vdata(:,:,i,:)),...
            'edgecolor','none','alphadata',squeeze(Adata(:,:,i)),...
            'facealpha','texture','alphadatamapping','none');
        end
        end    
            
end
end
set(gca,'nextPlot',holdState);