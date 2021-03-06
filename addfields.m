%addfields Add Field-Value pairs to structure
%
%S = addfields(S0,'field1',value1,'field2',value2,...)
%S = addfields(S0,{'field1',value1,'field2',value2,...})
%S = addfields(S0,'{'field1','field2',...},{value1,value2,...})
%S = addfields(S0,S1)
%       where S1 = struct('field1',value1,'field2',value2,...)
%
%Adds the field-value pairs to the structure S0, overwriting existing
%fields in S0 if the fields occur in the argument list.
%The values value1, value2 etc. will be assigned to the fields field1,
%field2, etc in the structure S0, and returned as S. The field-value pairs
%may be specified as arguments, cell arrays, or a structure
%
%Modification History
%Created 2011.05.19 Peter Hollender
% 2014.04.16 Added recursive structure adding
%
% See also fieldnames getfield setfield rmfield orderfields

function s = addfields(s0,varargin)
s = s0;

if nargin == 1 % Pass through
    %
elseif nargin == 2 && isstruct(varargin{1}) % Structure
    s1 = varargin{1};
    tgtfields = fieldnames(s1);
    for i = 1:length(tgtfields)
        tgtfield = tgtfields{i};
        s = addfields(s,tgtfield,s1.(tgtfield));
    end
    
elseif nargin == 3 && iscell(varargin{1}) && iscell(varargin{2}) % Cell of parameters, cell of values
    tgtfields = varargin{1};
    values = varargin{2};
    for i = 1:length(tgtfields)
        tgtfield = tgtfields{i};
        s = addfields(s,tgtfield,values{i}); 
    end
    
elseif nargin == 2 && iscell(varargin{1}) && length(varargin{1})==1 %Cell of other inputs
    s = addfields(s,varargin{1}{1});

elseif nargin == 2 && iscell(varargin{1}) && mod(length(varargin{1}),2) == 0 %Cell {P1,V1,P2,V2...}
    tgtfields = varargin{1}(1:2:end);
    values = varargin{1}(2:2:end);
    for i = 1:length(tgtfields)
        tgtfield = tgtfields{i};
        s = addfields(s,tgtfield,values{i});
    end
    
elseif mod(nargin,2) % P1,V1,P2,V2,...
    tgtfields = varargin(1:2:end);
    values = varargin(2:2:end);
    for i = 1:length(tgtfields)
        tgtfield = tgtfields{i};
        dots = strfind(tgtfield,'.');
        if isempty(dots)
            s = caseInsensitiveAdd(s,tgtfield,values{i});
        else
            subfield = tgtfield(dots(1)+1:end);
            tgtfield = tgtfield(1:dots(1)-1);
            fields = fieldnames(s);
            matchi = find(strcmpi(fields,tgtfield));
            match = find(strcmp(fields,tgtfield));
            if ~isempty(matchi) && isempty(match)
                warning(sprintf('Case-Insensitive Match for structure ''%s'' found. Assigning value specified for ''%s'' to ''%s''',fields{matchi},tgtfield,fields{matchi}));
                tgtfield = fields{matchi};
            end
            if ~isfield(s,tgtfield)
            s.(tgtfield) = struct;
            end
            s.(tgtfield) = addfields(s.(tgtfield),subfield,values{i});
        end
    end

else %Invalid Syntax
    error('Unable to parse field-value pairs')
end
end

function s = caseInsensitiveAdd(s0,tgtfield,value)
if isempty(s0)
    s.(tgtfield) = value;
    return
end
s = s0;
fields = fieldnames(s0);
match = find(strcmp(fields,tgtfield));
matchi = find(strcmpi(fields,tgtfield));
if isempty(matchi)
    s.(tgtfield) = value;
else
    if isempty(match)
       warning(sprintf('Case-Insensitive Match for option ''%s'' found. Assigning value specified for ''%s'' to ''%s''',fields{matchi},tgtfield,fields{matchi}));
    end
    if isstruct(value) && isstruct(s.(fields{matchi}))
        s.(fields{matchi}) = addfields(s.(fields{matchi}),value);
    else
        s.(fields{matchi}) = value;
    end
end
end