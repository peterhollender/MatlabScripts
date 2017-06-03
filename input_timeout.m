function val = input_timeout(timeout)
val = false;
h = figure('NumberTitle','off','MenuBar','none','ToolBar','none','Name','waiting for input','Position',[0 0 180 40]);
h.UserData = false;
set(h,'KeyPressFcn',sprintf('set(%g,''UserData'',true);',h.Number))
t = tic;
shg
while toc(t)<timeout
    if h.UserData
        val = true;
        break
    end
    set(h,'Name',sprintf('%0.0f',timeout-toc(t)));
    pause(0.001);
end
delete(h);
end
