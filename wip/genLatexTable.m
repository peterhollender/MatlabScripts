function t = genLatexTable(c,varargin)
opts = struct('label',[],'caption',[],'alignment',[]);
opts = setopts(opts,varargin);
if ~ischar(opts.alignment)
    opts.alignment = ['|' repmat('c|',1,size(c,2))];
end
t = sprintf('\\begin{table}[h]\n');
if ischar(opts.caption)
    t = sprintf('%s%s\n',t,sprintf('\\caption{%s}',opts.caption));
end
t = sprintf('%s%s\n',t,'\resizebox{\linewidth}{!}{');
t = sprintf('%s\\begin{tabular}{%s}\n',t,opts.alignment);
for i = 1:size(c,1)
    rowtxt = '';
    for j = 1:size(c,2);
        if ischar(c{i,j})
            rowtxt = sprintf('%s %s &',rowtxt,c{i,j});
        else
            if ~(isa(c{i,j},'double') && isempty(c{i,j}))
                rowtxt = sprintf('%s %g &',rowtxt,c{i,j});
            end
        end
    end
    t = sprintf('%s\\hline%s\\\\\n',t,rowtxt(1:end-1));
end
t = sprintf('%s\\hline\n',t);
t = sprintf('%s\\end{tabular}\n',t);
t = sprintf('%s}\n',t);
if ischar(opts.label);
    t = sprintf('%s%s\n',t,sprintf('\\label{tab:%s}',opts.label));
end
t = sprintf('%s\\end{table}\n',t);
end
    