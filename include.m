function include(package_name,git_path)
if ~exist('git_path','var')
    git_path = fileparts(fileparts(mfilename('fullpath')));
end
cmd = sprintf('addpath(genpath(''%s''));',fullfile(git_path,package_name));
evalin('caller',cmd);