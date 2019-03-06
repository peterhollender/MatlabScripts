%setfields Add Field-Value pairs to structure
%
%S = setfields(S0,'field1',value1,'field2',value2,...)
%S = setfields(S0,{'field1',value1,'field2',value2,...})
%S = setfields(S0,'{'field1','field2',...},{value1,value2,...})
%S = setfields(S0,S1)
%       where S1 = struct('field1',value1,'field2',value2,...)
%
%sets the field-value pairs in the structure S0, and errors if the fields
%do not exist. The values value1, value2 etc. will be assigned to the
%fields field1, field2, etc in the structure S0, and returned as S. The
%field-value pairs may be specified as arguments, cell arrays, or a
%structure
%
%Modification History
%Created 2011.05.19 Peter Hollender
% 2014.04.16 Added recursive structure adding
%
% See also fieldnames getfield setfield rmfield orderfields

function [s o] = setopts(s0,varargin)
s = s0;

if nargin == 1 % Pass through
    o = {};
elseif nargin == 2 && isstruct(varargin{1}) % Structure
    s1 = varargin{1};
    o = s1;
    tgtfields = fieldnames(s1);
    for i = 1:length(tgtfields)
        tgtfield = tgtfields{i};
        [s, oi] = setopts(s,tgtfield,s1.(tgtfield));
        if isempty(oi)
           o = rmfield(o,tgtfield);
        else
           o = o;
           %o.(tgtfield) = addfields(struct,oi);
        end
    end
    
elseif nargin == 3 && iscell(varargin{1}) && iscell(varargin{2}) % Cell of parameters, cell of values
    tgtfields = varargin{1};
    values = varargin{2};
    o = {};
    for i = 1:length(tgtfields)
        tgtfield = tgtfields{i};
        [s oi] = setopts(s,tgtfield,values{i}); 
        if ~isempty(oi)
            o = [o oi];
        end
    end
    
elseif nargin == 2 && iscell(varargin{1}) && length(varargin{1})==1 %Cell of other inputs
    [s, o] = setopts(s,varargin{1}{1});

elseif nargin == 2 && iscell(varargin{1}) && mod(length(varargin{1}),2) == 0 %Cell {P1,V1,P2,V2...}
    tgtfields = varargin{1}(1:2:end);
    values = varargin{1}(2:2:end);
    o = {};
    for i = 1:length(tgtfields)
        tgtfield = tgtfields{i};
        [s, oi] = setopts(s,tgtfield,values{i});
        if ~isempty(oi)
            o = [o oi];
        end
    end
    
elseif mod(nargin,2) % P1,V1,P2,V2,...
    tgtfields = varargin(1:2:end);
    values = varargin(2:2:end);
    o = {};
    for i = 1:length(tgtfields)
        tgtfield = tgtfields{i};
        dots = strfind(tgtfield,'.');
        if isempty(dots)
            [s oi] = caseInsensitiveAdd(s,tgtfield,values{i});
            if ~isempty(oi)
                if isstruct(oi)
                    o = addfields(o,oi);
                else
                    o = [o oi];
                end
            end
        else
            subfield = tgtfield(dots(1)+1:end);
            tgtfield = tgtfield(1:dots(1)-1);
            fields = fieldnames(s);
            matchi = find(strcmpi(fields,tgtfield));
            match = find(strcmp(fields,tgtfield));
            if isempty(match) && ~isempty(matchi)
                warning(sprintf('Case-Insensitive Match for structure ''%s'' found. Assigning value specified for ''%s'' to ''%s''',fields{matchi},tgtfield,fields{matchi}));
                tgtfield = fields{matchi};
            end
            if ~isfield(s,tgtfield)
                oi = {[tgtfield '.' subfield],values{i}};
                o = [o oi];
            else
                [s.(tgtfield) oi] = setopts(s.(tgtfield),subfield,values{i});
                if ~isempty(oi)
                    oi{1} = [tgtfield '.' subfield];
                    o = [o oi];
                end
            end
        end
    end

else %Invalid Syntax
    error('Unable to parse field-value pairs')
end
end

function [s o]= caseInsensitiveAdd(s0,tgtfield,value)
s = s0;
fields = fieldnames(s0);
match = find(strcmp(fields,tgtfield));
matchi = find(strcmpi(fields,tgtfield));
if isempty(matchi)
    o = {tgtfield, value};
    %error('Field ''%s'' not found',tgtfield);
    %s.(tgtfield) = value;
else
    o = {};
    if isempty(match)
       warning(sprintf('Case-Insensitive Match for option ''%s'' found. Assigning value specified for ''%s'' to ''%s''',fields{matchi},tgtfield,fields{matchi}));
    end
    if isstruct(value) && isstruct(s.(fields{matchi}))
        [s.(fields{matchi}) o] = setopts(s.(fields{matchi}),value);
    else
        s.(fields{matchi}) = value;
    end
end
end