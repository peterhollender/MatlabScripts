function [status msg] = gitcheck(repopath,threshold_seconds);
%GITCHECK check to see if a repository is out of date
%msg = gitcheck(repopath,threshold_seconds);
if ~exist('threshold_seconds','var')
    threshold_seconds = 60*60*24;
end
return_path = pwd;
cd (repopath)
fetch_head = fullfile(repopath,'.git','FETCH_HEAD');
if ~exist(fetch_head,'file')
    msg = printf('%s: Unable to locate GIT info\n',repopath);
    status = -1;
    return
end
f = dir(fetch_head);
seconds_since_fetch = (now-f.datenum)*24*60*60;
fid = fopen(fetch_head,'rt');
s = fread(fid);
fclose(fid);
A = textscan(char(s'),'%s','delimiter',sprintf('\t'));
repo_name = A{1}{end};    
if seconds_since_fetch>threshold_seconds    
    try
        [status fmsg] = system('git fetch');
        [status stmsg] = system('git status');
    catch
        msg = sprintf('%s: Unable to obtain GIT status from the remote',repo_name);
        status = -1;
        return
    end
    MSG = textscan(stmsg,'%s','delimiter',sprintf('\n'));
    stmsg = MSG{1}{2};
    msg = sprintf('%s: %s',repo_name,stmsg);
    if ~isempty(strfind(stmsg,'up-to-date'));
        status = 0;
    else
        status = 1;
    end
else
    msg = sprintf('%s last fetched %0.0f seconds ago',repo_name);
    status = 0;
end
cd(return_path);