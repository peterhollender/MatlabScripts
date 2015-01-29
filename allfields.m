function allfields(s,expr)
if ~exist('expr','var');
    expr = '^.';
end
fnames = fieldnames(s);
for i = 1:length(fnames)
   if ~isempty(regexp(fnames{i},expr))
    eval(sprintf('%s = s.%s',fnames{i},fnames{i}));
   end
end