%getTeamColors.m - Get team colors in RGB format parsed from website
%
% Usage: [colors name league] = getTeamColors(teamname,league,filename)
%
% inputs:
% teamname - Any part of a team name (case insensitive), use 'all' for a
%            complete listing
% league - (optional) League abbreviation of team
% filename - (optional) Path to team database file
%
% outputs:
% colors - n x 3 matrix of team colors
% name - Team name
% league - League name
%
% Will give a warning if more than one team matches the search criteria,
% unless team is set to 'all' and no output arguments are specified, in
% which case it will generate a series of links to set the colors.
%
% Nick Bottenus - 7/23/14
% Peter Hollender - 8/20/15

function [colors name league] = getTeamColors(teamname,leaguename,filename)

if(~exist('filename','var'))
    filename=fullfile(fileparts(mfilename('fullpath')),'teamColors');
end
load(filename)

teamname=lower(teamname);

if strcmpi(teamname,'all')
    teamname = ' ';
end

if(exist('leaguename','var'))
    leaguename=lower(leaguename);
end

count=0;
for i=1:length(teams)
    if(~isempty(strfind(lower(teams{i}.name),teamname)))
        if(exist('leaguename','var'))
            if(isempty(strfind(lower(teams{i}.league),leaguename)))
                continue
            end
        end
        count=count+1;
        Colors{count}=teams{i}.colors;
        Name{count}=teams{i}.name;
        League{count}=teams{i}.league;
    end
end
if(count>1)
    for i = 1:count        
    fprintf(sprintf('<a href="matlab:colormap(genColorMap(getTeamColors(''%s'',''%s'')));">%s (%s)</a>\n',Name{i},League{i},Name{i},League{i}));
    end
    if nargout > 0;
        warning('Matches:Multi',sprintf('Ambiguity in team name. Using %s (%s).',Name{1},League{1}));
    else
        return    
    end
elseif(count==0)
    error('No team found')
end
    colors = Colors{1};
    name = Name{1};
    League = League{1};
end