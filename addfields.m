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

function S = addfields(S0,varargin)
S = S0;
if nargin == 2 && isstruct(varargin{1}) % Structure
    S1 = varargin{1};
    fields = fieldnames(S1);
    for i = 1:length(fields)
        field = fields{i};
        S = addfields(S,field,S1.(field));
%        if isstruct(S.(field)) && isstruct(S1.(field))
%        S.(field) = addfields(S.(field),S1.(field));
%        else
%        S.(field) = S1.(field);
%        end
    end
elseif nargin == 3 && iscell(varargin{1}) && iscell(varargin{2}) % Cells
    fields = varargin{1};
    values = varargin{2};
    for i = 1:length(fields)
        field = fields{i};
        S = addfields(S,field,values{i}); 
    end
elseif mod(nargin,2) % Argument List
    fields = varargin(1:2:end);
    values = varargin(2:2:end);
    for i = 1:length(fields)
        field = fields{i};
        dotidx = strfind(field,'.');
        if isempty(dotidx)
            S = caseInsensitiveAdd(S,field,values{i});
        else
            substructname = field(1:dotidx(1)-1);
            substructargname = field(dotidx(1)+1:end);
            existingstructs = fieldnames(S);
            matchi = find(strcmpi(existingstructs,substructname));
            match = find(strcmp(existingstructs,substructname));
            if ~isempty(matchi) && isempty(match)
                warning(sprintf('Case-Insensitive Match for structure ''%s'' found. Assigning value specified for ''%s'' to ''%s''',existingstructs{matchi},substructname,existingstructs{matchi}));
                substructname = existingstructs{matchi};
            end
            if ~isfield(S,substructname)
            S.(substructname) = struct;
            end
            S.(substructname) = addfields(S.(substructname),substructargname,values{i});
        end
    end
elseif nargin == 2 && iscell(varargin{1}) && mod(length(varargin{1}{1}),2) == 0
    fields = varargin{1}{1}(1:2:end);
    values = varargin{1}{1}(2:2:end);
    for i = 1:length(fields)
        field = fields{i};
        S = addfields(S,field,values{i});
    end
elseif nargin == 2 && iscell(varargin{1}) && mod(length(varargin{1}),2) == 0
    fields = varargin{1}(1:2:end);
    values = varargin{1}(2:2:end);
    for i = 1:length(fields)
        field = fields{i};
        S = addfields(S,field,values{i});
    end
else %Invalid Syntax
    error('Unable to parse field-value pairs')
end
end

function S = caseInsensitiveAdd(S0,targetField,value)
S = S0;
fields = fieldnames(S0);
match = find(strcmp(fields,targetField));
matchi = find(strcmpi(fields,targetField));
if isempty(matchi)
    S.(targetField) = value;
else
    if isempty(match)
       warning(sprintf('Case-Insensitive Match for option ''%s'' found. Assigning value specified for ''%s'' to ''%s''',fields{matchi},targetField,fields{matchi}));
    end
    if isstruct(value)
        S.(fields{matchi}) = addfields(S.(fields{matchi}),value);
    else
        S.(fields{matchi}) = value;
    end
end
end