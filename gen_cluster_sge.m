function sgefilename = gen_cluster_sge(Function_Name,Scratch_Dir,Max_Index,UniqueID,Memory_Limit,varargin)
nargs = length(varargin);

fid = fopen('cluster_template.sge','rt');
s = fread(fid);
fclose(fid);
if ~exist('UniqueID','var')
[pth UniqueID] = fileparts(tempname('.'));
end
if ~exist('Memory_Limit','var')
Memory_Limit = 1048576;
end
s1 = strrep(char(s'),'MAX_INDEX',num2str(Max_Index));
s1 = strrep(s1,'MEM_FREEGB',sprintf('%0.0fG',Memory_Limit/(2^20)));
s1 = strrep(s1,'MEMORY_LIMIT',num2str(Memory_Limit));
s1 = strrep(s1,'UNIQUEID',UniqueID);
s1 = strrep(s1,'FUNCTION_NAME',Function_Name);
s1 = strrep(s1,'SCRATCHDIR',Scratch_Dir);
expar = '';
if nargs>0
    for i = 1:nargs
        if ischar(varargin{i})
            expar = [expar ',''' varargin{i} , ''''];
        else
            expar = [expar ',' num2str(varargin{i})];
        end
    end
end 
s1 = strrep(s1,',EXTRAPARAMS',expar);
s2 = double(s1)';
sgefilename = sprintf('%s_SGE.sge',UniqueID);
fid = fopen(sgefilename,'wt');
fwrite(fid,s2);
fclose(fid);