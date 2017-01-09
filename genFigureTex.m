%genFigureTex Generate TEX file with \includegraphics
%
%TexFileName = genFigureTex(figPath,pathMode,sizeSpec)
function TexFileName = genFigureTex(figPath,pathMode,sizeSpec)
if ~exist('figPath','var')
    figPath = pwd;
end
if ~exist('pathMode','var')
    pathMode = 'relative';
end
if ~exist('sizeSpec','var')
    sizeSpec = 'width=3.5in';
end
%figPath = '/getlab/pjh7/SC2000/FullySampled12L4/data/20140108/figures/eps';
d = dir(fullfile(figPath,'*.eps'));
TexFileName = fullfile(figPath,'IncludeGraphics.tex');
fid = fopen(TexFileName,'wt');
switch lower(pathMode)
    case 'relative'
        relCom = '';
        absCom = '%%';
    case 'absolute'
        relCom = '%%';
        absCom = '';
    otherwise
        error('Unknown pathMode %s. use ''relative'' or ''absolute''')
end
for i = 1:length(d)
        fprintf(fid,sprintf('%s\n','\\begin{figure}[!htb]'));
        fprintf(fid,sprintf('%s\n','\\centering'));
        %fprintf(fid,sprintf('%s\\\\includegraphics[%s]{%s}\n',absCom,sizeSpec,fullfile(figPath,d(i).name)));
        fprintf(fid,sprintf('%s\\\\includegraphics[%s]{%s}\n',relCom,sizeSpec,d(i).name));
        fprintf(fid,sprintf('\\\\caption{%s}\n',strrep(d(i).name,'_',' ')));
        fprintf(fid,sprintf('\\\\label{fig:%s}\n',strrep(d(i).name(1:end-4),'_','')));
        fprintf(fid,sprintf('%s\n','\\end{figure}'));
        fprintf(fid,'\n\n');
        fprintf(sprintf('\\\\label{fig:%s}\n',strrep(d(i).name(1:end-4),'_','')));
end
fclose(fid);