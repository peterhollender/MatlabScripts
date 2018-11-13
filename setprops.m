%setprops Add Field-Value pairs to structure
%
%S = setprops(S0,'field1',value1,'field2',value2,...)
%S = setprops(S0,{'field1',value1,'field2',value2,...})
%S = setprops(S0,'{'field1','field2',...},{value1,value2,...})
%S = setprops(S0,S1)
%       where S1 = struct('field1',value1,'field2',value2,...)
%
%Adds the field-value pairs to the structure S0, overwriting existing
%props in S0 if the props occur in the argument list.
%The values value1, value2 etc. will be assigned to the props field1,
%field2, etc in the structure S0, and returned as S. The field-value pairs
%may be specified as arguments, cell arrays, or a structure
%
%Modification History
%Created 2011.05.19 Peter Hollender
% 2014.04.16 Added recursive structure adding
%
% See also properties getfield setfield rmfield orderprops

function s1 = setprops(s0,varargin)
s = s0;

if nargin == 1 % Pass through
    %
elseif nargin == 2 && isstruct(varargin{1}) % Structure
    s1 = varargin{1};
    tgtprops = fields(s1);
    for i = 1:length(tgtprops)
        tgtprop = tgtprops{i};
        s = setprops(s,tgtprop,s1.(tgtprop));
    end
    
elseif nargin == 3 && iscell(varargin{1}) && iscell(varargin{2}) % Cell of parameters, cell of values
    tgtprops = varargin{1};
    values = varargin{2};
    for i = 1:length(tgtprops)
        tgtprop = tgtprops{i};
        s = setprops(s,tgtprop,values{i}); 
    end
    
elseif nargin == 2 && iscell(varargin{1}) && length(varargin{1})==1 %Cell of other inputs
    s = setprops(s,varargin{1}{1});

elseif nargin == 2 && iscell(varargin{1}) && mod(length(varargin{1}),2) == 0 %Cell {P1,V1,P2,V2...}
    tgtprops = varargin{1}(1:2:end);
    values = varargin{1}(2:2:end);
    for i = 1:length(tgtprops)
        tgtprop = tgtprops{i};
        s = setprops(s,tgtprop,values{i});
    end
    
elseif mod(nargin,2) % P1,V1,P2,V2,...
    tgtprops = varargin(1:2:end);
    values = varargin(2:2:end);
    for i = 1:length(tgtprops)
        tgtprop = tgtprops{i};
        dots = strfind(tgtprop,'.');
        if isempty(dots)
            s = caseInsensitiveAdd(s,tgtprop,values{i});
        else
            subfield = tgtprop(dots(1)+1:end);
            tgtprop = tgtprop(1:dots(1)-1);
            props = properties(s);
            matchi = find(strcmpi(props,tgtprop));
            match = find(strcmp(props,tgtprop));
            if isempty(match) && ~isempty(matchi)
                warning(sprintf('Case-Insensitive Match for structure ''%s'' found. Assigning value specified for ''%s'' to ''%s''',props{matchi},tgtprop,props{matchi}));
                tgtprop = props{matchi};
            end
            if ~isprop(s,tgtprop)
                error('%s is not a property',tgtprop);
            s.(tgtprop) = struct;
            end
            s.(tgtprop) = setprops(s.(tgtprop),subfield,values{i});
        end
    end

else %Invalid Syntax
    error('Unable to parse field-value pairs')
end
if nargout>0
    s1 = s;
end
end

function s = caseInsensitiveAdd(s0,tgtprop,value)
s = s0;
props = properties(s0);
match = find(strcmp(props,tgtprop));
matchi = find(strcmpi(props,tgtprop));
if isempty(matchi)
    if isprop(s,tgtprop)
        warning('Setting Hidden Property %s',tgtprop)
    else
        error('Field ''%s'' not found',tgtprop);
    end
    s.(tgtprop) = value;
else
    if isempty(match)
       warning(sprintf('Case-Insensitive Match for option ''%s'' found. Assigning value specified for ''%s'' to ''%s''',props{matchi},tgtprop,props{matchi}));
    end
    if isstruct(value)
        if isstruct(s.(props{matchi}))
            s.(props{matchi}) = setfields(s.(props{matchi}),value);
        else
            s.(props{matchi}) = setprops(s.(props{matchi}),value);
        end
    else
        s.(props{matchi}) = value;
    end
end
end