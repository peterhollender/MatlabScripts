function cb = colorbaroutside
                    oldaxesposition = get(gca,'position');
                    cb = colorbar('EastOutside');
                    shiftedaxesposition = get(gca,'position');
                    cbshift = oldaxesposition(3)-shiftedaxesposition(3);
                    cbpos = get(cb,'position');
                    cbpos(1) = cbpos(1)+cbshift;
                    set(cb,'position',cbpos);
                    set(gca,'position',oldaxesposition)
                    