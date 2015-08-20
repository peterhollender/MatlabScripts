%getTeamColors.m - Get team colors in RGB format parsed from website
%
% Usage: [colors name league] = getTeamColors(teamname,league,filename)
%
% inputs:
% teamname - Any part of a team name (case insensitive)
% league - (optional) League abbreviation of team
% filename - (optional) Path to team database file
%
% outputs:
% colors - n x 3 matrix of team colors
% name - Team name
% league - League name
%
% Will give an error if more than one team matches the search criteria
%
% Nick Bottenus - 7/23/14

function [colors name league] = getTeamColors(teamname,leaguename,filename)

if(~exist('filename','var'))
    filename=fullfile(fileparts(mfilename('fullpath')),'teamColors');
end
load(filename)

teamname=lower(teamname);
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
        colors=teams{i}.colors;
        name=teams{i}.name;
        league=teams{i}.league;
        count=count+1;
    end
end
if(count>1)
    warning('Matches:Multi',sprintf('Ambiguity in team name. Using %s (%s).',name,league));
elseif(count==0)
    error('No team found')
end

end