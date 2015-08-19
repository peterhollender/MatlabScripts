function [is_diff] = filediff(file1,file2)
if nargin < 2
    error('not enough input arguments')
end
file_1 = javaObject('java.io.File',file1);
file_2 = javaObject('java.io.File',file2);
is_diff = ~javaMethod('contentEquals','org.apache.commons.io.FileUtils',file_1, file_2);
end

