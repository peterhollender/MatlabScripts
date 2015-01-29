function [H] = addCornerText(S,fontSize,location);
if ~exist('location','var')
    location = 'northeast';
end
    pxW = fontSize*1.3;
    pxH = fontSize*1.5;
    sp = gca;
    ydir = get(sp,'ydir');
    pos = get(sp,'position');
    fpos = get(get(sp,'Parent'),'position');
    xlim = get(sp,'xlim');
    ylim = get(sp,'ylim');
    szX = diff(xlim)*(pxW/(fpos(3)*pos(3)));
    szY = diff(ylim)*(pxH/(fpos(4)*pos(4)));
    
    switch lower(location)
        case 'northeast'
            xi = -1;
            yi = -1;
            hza = 'right';
        case 'northwest'
            xi = 1;
            yi = -1;
            hza = 'left';
        case 'southwest'
            xi = 1;
            yi = 1;
            hza = 'left';
        case 'southeast'
            xi = -1;
            yi = 1;
            hza = 'right';
        otherwise
            error('location "%s" is unknown.\n',location);
    end
    if strcmpi(get(sp,'ydir'),'reverse');
        yi = -1*yi;
    end
    if strcmpi(get(sp,'xdir'),'reverse');
        xi = -1*xi;
    end
    x0 = xlim(1.5-0.5*xi) + xi*szX/4;
	y0 = ylim(1.5-0.5*yi) + yi*szY/2;
    H(1) = text(x0,y0,S,'FontSize',fontSize,'FontWeight','bold','color','w','horizontalalignment',hza,'verticalalignment','middle');
    extent = get(H(1),'extent');
    H(2) = patch(x0-xi*szX/4+xi*[0 1 1 0]*extent(3)+xi*szX*[0 .75 .75 0],y0+[-1 -1 1 1]*szY/2,'k','facecolor','k');
    k = get(gca,'Children');
    set(gca,'Children',k([2 1 3:end]));
   