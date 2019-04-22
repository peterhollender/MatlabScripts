function circ = getcirc(varargin)
%GETCIRC Select circangle with mouse.
%   CIRC = GETCIRC lets you select a circle in the current axes using
%   the mouse.  Use the mouse to click and drag the desired circle.
%   CIRC is a three-element vector with the form [x y radius].
%
%   CIRC = GETCIRC(FIG) lets you select a circle in the current axes of
%   figure FIG using the mouse.
%
%   CIRC = GETCIRC(AX) lets you select a circle in the axes specified by
%   the handle AX.
%
%   Example
%   --------
%       imshow('moon.tif')
%       circ = getcirc
%
%   See also GETRECT, GETLINE, GETPTS.

%   Callback syntaxes:
%        getcirc('ButtonDown')
%        getcirc('ButtonMotion')
%        getcirc('ButtonUp')

%   Copyright 1993-2011 The MathWorks, Inc.

global GETCIRC_FIG GETCIRC_AX GETCIRC_H1 GETCIRC_H2
global GETCIRC_PT1

if ((nargin >= 1) && (ischar(varargin{1})))
    % Callback invocation: 'ButtonDown', 'ButtonMotion', or 'ButtonUp'
    feval(varargin{:});
    return;
end

if (nargin < 1)
    GETCIRC_AX = gca;
    GETCIRC_FIG = ancestor(GETCIRC_AX, 'figure');
else
    if ~ishghandle(varargin{1})
        CleanGlobals;
        error(message('images:getcirc:expectedHandle'));
    end
    
    switch get(varargin{1}, 'Type')
    case 'figure'
        GETCIRC_FIG = varargin{1};
        GETCIRC_AX = get(GETCIRC_FIG, 'CurrentAxes');
        if isempty(GETCIRC_AX)
            GETCIRC_AX = axes('Parent', GETCIRC_FIG);
        end

    case 'axes'
        GETCIRC_AX = varargin{1};
        GETCIRC_FIG = ancestor(GETCIRC_AX, 'figure');

    otherwise
        CleanGlobals;
        error(message('images:getcirc:expectedFigureOrAxesHandle'));
    end
end

% Remember initial figure state
state = uisuspend(GETCIRC_FIG);

% Set up initial callbacks for initial stage
set(GETCIRC_FIG, ...
    'Pointer', 'crosshair', ...
    'WindowButtonDownFcn', 'getcirc(''ButtonDown'');');

% Set axes limit modes to manual, so that the presence of lines used to
% draw the circangles doesn't change the axes limits.
original_modes = get(GETCIRC_AX, {'XLimMode', 'YLimMode', 'ZLimMode'});
set(GETCIRC_AX,'XLimMode','manual', ...
               'YLimMode','manual', ...
               'ZLimMode','manual');

% Bring target figure forward
figure(GETCIRC_FIG);

% Initialize the lines to be used for the drag
GETCIRC_H1 = line('Parent', GETCIRC_AX, ...
                  'XData', [0 0 0 0 0], ...
                  'YData', [0 0 0 0 0], ...
                  'Visible', 'off', ...
                  'Clipping', 'off', ...
                  'Color', 'k', ...
                  'LineStyle', '-');

GETCIRC_H2 = line('Parent', GETCIRC_AX, ...
                  'XData', [0 0 0 0 0], ...
                  'YData', [0 0 0 0 0], ...
                  'Visible', 'off', ...
                  'Clipping', 'off', ...
                  'Color', 'w', ...
                  'LineStyle', ':');


% We're ready; wait for the user to do the drag
% Wrap the waitfor call in try-catch so
% that if the user Ctrl-C's we get a chance to
% clean up the figure.
errCatch = 0;
try
    waitfor(GETCIRC_H1, 'UserData', 'Completed');
catch %#ok<CTCH>
    errCatch = 1;
end

% After the waitfor, if GETCIRC_H1 is still valid
% and its UserData is 'Completed', then the user
% completed the drag.  If not, the user interrupted
% the action somehow, perhaps by a Ctrl-C in the
% command window or by closing the figure.

if (errCatch == 1)
    errStatus = 'trap';
    
elseif (~ishghandle(GETCIRC_H1) || ...
            ~strcmp(get(GETCIRC_H1, 'UserData'), 'Completed'))
    errStatus = 'unknown';
    
else
    errStatus = 'ok';
    x = GETCIRC_PT1(1);
    y = GETCIRC_PT1(2);
    r = GETCIRC_PT1(3);
end

% Delete the animation objects
if (ishghandle(GETCIRC_H1))
    delete(GETCIRC_H1);
end
if (ishghandle(GETCIRC_H2))
    delete(GETCIRC_H2);
end

% Restore the figure state
if (ishghandle(GETCIRC_FIG))
   uirestore(state);
   
   if ishghandle(GETCIRC_AX)
       set(GETCIRC_AX, {'XLimMode','YLimMode','ZLimMode'}, original_modes);
   end
end

CleanGlobals;

% Depending on the error status, return the answer or generate
% an error message.
switch errStatus
case 'ok'
    % Return the answer
    circ =  [x y r];
    
case 'trap'
    % An error was trapped during the waitfor
    error(message('images:getcirc:interruptedMouseSelection'));
    
case 'unknown'
    % User did something to cause the circangle drag to
    % terminate abnormally.  For example, we would get here
    % if the user closed the figure in the drag.
    error(message('images:getcirc:interruptedMouseSelection'));
end

%--------------------------------------------------
% Subfunction ButtonDown
%--------------------------------------------------
function ButtonDown %#ok

global GETCIRC_FIG GETCIRC_AX GETCIRC_H1 GETCIRC_H2
global GETCIRC_PT1

set(GETCIRC_FIG, 'Interruptible', 'off', ...
                 'BusyAction', 'cancel');
             
x1 = GETCIRC_AX.CurrentPoint(1,1);
y1 = GETCIRC_AX.CurrentPoint(1,2);
GETCIRC_PT1 = [x1 y1 0];
%GETCIRC_TYPE = get(GETCIRC_FIG, 'SelectionType');
x2 = x1;
y2 = y1;
r = sqrt((x2-x1)^2+(y2-y1)^2);
theta = [0:360];
xdata = x1+r*cosd(theta);
ydata = y1+r*sind(theta);

set(GETCIRC_H1, 'XData', xdata, ...
                'YData', ydata, ...
                'Visible', 'on');
set(GETCIRC_H2, 'XData', xdata, ...
                'YData', ydata, ...
                'Visible', 'on');

% Let the motion functions take over.
set(GETCIRC_FIG, 'WindowButtonMotionFcn', 'getcirc(''ButtonMotion'');', ...
                 'WindowButtonUpFcn', 'getcirc(''ButtonUp'');');


%-------------------------------------------------
% Subfunction ButtonMotion
%-------------------------------------------------
function ButtonMotion %#ok

global GETCIRC_AX GETCIRC_H1 GETCIRC_H2
global GETCIRC_PT1

x2 = GETCIRC_AX.CurrentPoint(1,1);
y2 = GETCIRC_AX.CurrentPoint(1,2);
x1 = GETCIRC_PT1(1);
y1 = GETCIRC_PT1(2);
r = sqrt((x2-x1)^2+(y2-y1)^2);
GETCIRC_PT1(3) = r;
theta = [0:360];
xdata = x1+r*cosd(theta);
ydata = y1+r*sind(theta);

%if (~strcmp(GETCIRC_TYPE, 'normal'))
%    [xdata, ydata] = Constrain(xdata, ydata);
%end

set(GETCIRC_H1, 'XData', xdata, ...
                'YData', ydata);
set(GETCIRC_H2, 'XData', xdata, ...
                'YData', ydata);

%--------------------------------------------------
% Subfunction ButtonUp
%--------------------------------------------------
function ButtonUp %#ok

global GETCIRC_FIG GETCIRC_AX GETCIRC_H1 GETCIRC_H2
global GETCIRC_PT1

% Kill the motion function and discard pending events
set(GETCIRC_FIG, 'WindowButtonMotionFcn', '', ...
                 'Interruptible', 'off');

% Set final line data
x2 = GETCIRC_AX.CurrentPoint(1,1);
y2 = GETCIRC_AX.CurrentPoint(1,2);
x1 = GETCIRC_PT1(1);
y1 = GETCIRC_PT1(2);
r = sqrt((x2-x1)^2+(y2-y1)^2);
GETCIRC_PT1(3) = r;
theta = [0:360];
xdata = x1+r*cosd(theta);
ydata = y1+r*sind(theta);

%if (~strcmp(GETCIRC_TYPE, 'normal'))
%    [xdata, ydata] = Constrain(xdata, ydata);
%end

set(GETCIRC_H1, 'XData', xdata, ...
                'YData', ydata);
set(GETCIRC_H2, 'XData', xdata, ...
                'YData', ydata);

% Unblock execution of the main routine
set(GETCIRC_H1, 'UserData', 'Completed');

%-----------------------------------------------
% Subfunction Constrain
% 
% constrain circangle to be a square in
% axes coordinates
%-----------------------------------------------
% function [xdata_out, ydata_out] = Constrain(xdata, ydata)
% 
% x1 = xdata(1);
% x2 = xdata(2);
% y1 = ydata(1);
% y2 = ydata(3);
% ydis = abs(y2 - y1);
% xdis = abs(x2 - x1);
% 
% if (ydis > xdis)
%    x2 = x1 + sign(x2 - x1) * ydis;
% else
%    y2 = y1 + sign(y2 - y1) * xdis;
% end
% 
% xdata_out = [x1 x2 x2 x1 x1];
% ydata_out = [y1 y1 y2 y2 y1];

%---------------------------------------------------
% Subfunction CleanGlobals
%--------------------------------------------------
function CleanGlobals

% Clean up the global workspace
clear global GETCIRC_FIG GETCIRC_AX GETCIRC_H1 GETCIRC_H2
clear global GETCIRC_PT1 GETCIRC_TYPE



