url='http://teamcolors.arc90.com/';

doc=urlread(url);
clc
[leagues_i leagues]=regexpi(doc,'<ul id=.(\w+). class=','start','tokens');
[teamnames_i teamnames]=regexpi(doc,'<h3[^>]*>([^<]+)</h3>','start','tokens');
[colors_i colors]=regexpi(doc,'<span[^>]*hex[^>]*>#([^<]+)</span>','start','tokens');

teams=cell(size(teamnames));

teamnames_i=[teamnames_i Inf];
for i=1:length(teams)
    teams{i}.name=teamnames{i}{1};
    teams{i}.league=leagues{find(teamnames_i(i)>leagues_i,1,'last')}{1};
    cols={colors{colors_i>teamnames_i(i)&colors_i<teamnames_i(i+1)}};
    teams{i}.colors=[];
    for j=1:length(cols)
        curcol=cols{j}{1};
        [hex2dec(curcol(1:2)) hex2dec(curcol(3:4)) hex2dec(curcol(5:6))]/255
        teams{i}.colors=[teams{i}.colors;[hex2dec(curcol(1:2)) hex2dec(curcol(3:4)) hex2dec(curcol(5:6))]/255];
    end
end

