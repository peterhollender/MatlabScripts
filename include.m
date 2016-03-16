function include(package_name,git_path)
if ~exist('git_path','var')
    git_path = fileparts(fileparts(mfilename('fullpath')));
end
path_def_file = fullfile(git_path,package_name,'pathdef.m');
if exist(path_def_file,'file')
    evalin('caller',sprintf('run %s;',path_def_file));
else
    cmd = sprintf('addpath(genpath(''%s''));',fullfile(git_path,package_name));
    evalin('caller',cmd);
end