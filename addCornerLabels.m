function [txt ptch] = addCornerLabels(sp,fontSize,location);
if ~exist('location','var')
    location = 'northeast';
end
if ~exist('fontSize','var')
    fontSize = get(sp(1),'fontSize');
end
axcolor = get(sp(1),'Color');
white = mean(axcolor)>0.5;

    pxW = fontSize*1.3;
    pxH = fontSize*1.5;
    for i = 1:size(sp(:));
    subplot(sp(i));
    ydir = get(sp(i),'ydir');
    pos = get(sp(i),'position');
    fpos = get(get(sp(i),'Parent'),'position');
    xlim = get(sp(i),'xlim');
    ylim = get(sp(i),'ylim');
    szX = diff(xlim)*(pxW/(fpos(3)*pos(3)));
    szY = diff(ylim)*(pxH/(fpos(4)*pos(4)));
    
    switch lower(location)
        case 'northeast'
            xi = -1;
            yi = -1;
        case 'northwest'
            xi = 1;
            yi = -1;
        case 'southwest'
            xi = 1;
            yi = 1;
        case 'southeast'
            xi = -1;
            yi = 1;
        otherwise
            error('location "%s" is unknown.\n',location);
    end
    if strcmpi(get(sp(i),'ydir'),'reverse');
        yi = -1*yi;
    end
    if strcmpi(get(sp(i),'xdir'),'reverse');
        xi = -1*xi;
    end
            x0 = xlim(1.5-0.5*xi) + xi*szX/2;
            y0 = ylim(1.5-0.5*yi) + yi*szY/2;
    
    ptch(i) = patch(x0+[-1 1 1 -1]*szX/2,y0+[-1 -1 1 1]*szY/2,'k-','FaceColor',[1 1 1]*white);
    txt(i) = text(x0,y0,char('A'+i-1),'FontSize',fontSize,'FontWeight','bold','Color',[1 1 1]*(~white),'horizontalalignment','center','verticalalignment','middle');
   end