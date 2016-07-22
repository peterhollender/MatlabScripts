function status = gitcheck(repopath,threshold_seconds);
%GITCHECK check to see if a repository is out of date
%msg = gitcheck(repopath,threshold_seconds);
if ~exist('threshold_seconds','var')
    threshold_seconds = 60*60*24;
end
return_path = pwd;
cd (repopath)
fetch_head = fullfile(repopath,'.git','FETCH_HEAD');
if ~exist(fetch_head,'file')
    fprintf('Unable to locate GIT info\n');
    status = -1;
    return
end
f = dir(fetch_head);
seconds_since_fetch = (now-f.datenum)*24*60*60;
if seconds_since_fetch>threshold_seconds
    try
        [status fmsg] = system('git fetch');
        [status msg] = system('git status');
        MSG = textscan(msg,'%s','delimiter',sprintf('\n'));
        up2date = MSG{1}{2};
        if ~isempty(strfind(up2date,'up-to-date'));
            status = 0;
        else
            fprintf('%s:\n%s\n',repopath,up2date);
            status = 1;
        end
    catch
        fprintf('Unable to obtain GIT status from the remote\n');
        status = -1;
        return
    end
else
    status = 0;
end
cd(return_path);