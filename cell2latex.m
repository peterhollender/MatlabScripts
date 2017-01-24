function t = cell2latex(c,top);
if ~exist('top','var')
    top = true;
end
if isempty(c)
    t = '';
    return
end
if ischar(c)
    if numel(c)>1 && size(c,2) == 1
        t = sprintf('\\rot{{\\tab}%s{\\tab}}',c);
    else
        t = sprintf('{\\tab}%s{\\tab}',c);
    end
return
end
if iscell(c)
    if top
        t = sprintf('\\begin{table}[h]\n');
        t = sprintf('%s\\begin{center}\n',t);
        t = sprintf('%s\\newcommand*\\tab{\\hspace{\\tabcolsep}}\n',t);
        t = sprintf('%s\\newcommand*\\rot[1]{\\rotatebox[origin=c]{90}{#1}}\n',t);
        %t = sprintf('%s\\newcommand*\\cellwidth{\\TX@col@width}\n',t);
        align = ['|' repmat('@{\hspace{0em}}c@{\hspace{0em}}|',1,size(c,2))];
        t = sprintf('%s{\\begin{tabularx}{\\linewidth}{%s}\n',t,align);
        %t = sprintf('%s{\\begin{tabular*}{\\textwidth}{%s}\n',t,align);
        t = sprintf('%s\\hline ',t);
    else
        t = '';
        align = ['|' repmat('X|',1,size(c,2))];
        %align = align(1:end-1);
        t = sprintf('%s{\\begin{tabularx}{\\cellwidth}{%s}\n',t,align);
        %t = sprintf('%s{\\begin{tabular*}{\\cellwidth}{%s}\n',t,align);

    end
    
    for i = 1:size(c,1)
        if i>0
            rowtxt = '\hline';
        else
            rowtxt = '';
        end
        for j = 1:size(c,2)
           rowtxt = sprintf('%s %s &',rowtxt,cell2latex(c{i,j},false));
        end
        t = sprintf('%s%s\\\\\n',t,rowtxt(1:end-1));
    end
    
    if top
        t = sprintf('%s\\hline\n',t);
        t = sprintf('%s\\end{tabularx}}',t);
        %t = sprintf('%s\\end{tabular*}}\n',t);
        t = sprintf('%s\\end{center}\n',t);
        t = sprintf('%s\\end{table}\n',t);
    else
        t = sprintf('%s\\hline\n',t);
        t = sprintf('%s\\end{tabularx}}',t);
        %t = sprintf('%s\\end{tabular*}}',t);
    end
end
            
    
