%PARSEINPUTS Evaluates Varargin Variable-Value Pairs
%
%parseInputs is a script (NOT A FUNCTION) that assigns values based on
%varargin. Varargin must be a cell of the form
%{VariableName1,VariableValue1,VariableName2,VariableValue2...}. The
%Variable Names are strings, and the values can be anything.
%
%Example
%{'A',1,'B',[2:10],'Cats',{'Cheshire','Siamese'},'Dogs',dogNames(10)}
%Will execute the following commands:
%
%A = 1;
%B = [2:10];
%Cats = {'Cheshire','Siamese'};
%Dogs = dogNames(10);

%A safeguard is included to prevent execution of arbitrary code- variables
%must have valid names for assignment, and cannot be for example:
%'fprintf('all your base are belong to us!\n');runVirusCode;a',1
%Without a check, the first commands would be executed and then "a" 
%assigned to 1, and a winner would not be you. I've set it up to 
%throw an error instead. Just being safe.

%Modification History:
%Created 09/23/2010 Peter Hollender

if mod(length(varargin),2)
    error('Unable to parse inputs: invalid number of parameters');
end

if exist('vararginargumentindex','var')
    warning('arg:conflict','indexing variable vararginargumentindex in use by workspace, being overwritten');
end



for vararginargumentindex = 1:2:length(varargin)-1
    if ~isvarname(varargin{vararginargumentindex});
        error('Invalid variable name "%s"\n',varargin{vararginargumentindex})
    end

    if ~any(strcmp(varargin{vararginargumentindex},who))&&any(strcmpi(varargin{vararginargumentindex},who))
        warning('arg:case','Case-insensitive match for "%s" found. Assigning to "%s".',varargin{vararginargumentindex},...
            subsref(who,struct('type','{}','subs',{{find(strcmpi(who,varargin{vararginargumentindex}),1,'first')}})));
    eval(sprintf('%s = varargin{vararginargumentindex+1};',...
        subsref(who,struct('type','{}','subs',{{find(strcmpi(who,varargin{vararginargumentindex}),1,'first')}}))));

    else    
    eval(sprintf('%s = varargin{vararginargumentindex+1};',...
        varargin{vararginargumentindex}))
    end
end

clear vararginargumentindex