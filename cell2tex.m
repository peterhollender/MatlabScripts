function t = cell2tex(c);
[c1 hasdata] = padcells(c);
for i = 1:size(c1,1)
    for j = 1:size(c1,2)
        if ischar(c1{i,j})
            if strfind(c1{i,j},'{}')
                if j == 1
                    c1{i,j} = strrep(c1{i,j},'{|c|}','{c|}');
                elseif j == size(c1,2);
                    c1{i,j} = strrep(c1{i,j},'{|c|}','{c}');
                end
            else
                if j>1
                    c1{i,j} = strrep(c1{i,j},'{|c|}','{c|}');
                end
            end     
        end
    end
end
%     if ~isempty(c1{i,1}) && ischar(c1{i,1})
%         c1{i,1} = strrep(c1{i,1},'{|c','{c');
%     end
%     if ~isempty(c1{i,end}) && ischar(c1{i,end})
%         c1{i,1} = strrep(c1{i,1},'c|}','c}');
%     end
%     for j = 2:size(c1,2)-1
%        if ~isempty(c1{i,j}) && ischar(c1{i,j})
%         c1{i,j} = strrep(c1{i,j},'{|c|}','{c}');
%        end
%     end
% end
t = genLatexTable(c1,hasdata);
end

function [c1 hasdata] = padcells(c,toplevel);
if ~exist('toplevel','var')
    toplevel = true;
end
[sz] = calcsz(c);
c1 = cell(sz);
hasdata = zeros(sz);
c1(:) = {[]};
for i = 1:size(c,1);
    rowszi = calcsz(c(i,:));
    rowsz(i) = rowszi(1);
end
for j = 1:size(c,2);
    colszj = calcsz(c(:,j));
    colsz(j) = colszj(2);
end
if isa(c,'double') && isempty(c);
    c1 = NaN;
    hasdata = 0;
    return
elseif iscell(c)
    for i = 1:size(c,1)
        for j = 1:size(c,2)
            I = sum(rowsz(1:i-1))+[1:rowsz(i)];
            J = sum(colsz(1:j-1))+[1:colsz(j)];
            [cij, hasdataij] = padcells(c{i,j},false);
            if iscell(cij)
                c1(I,J) = cij;
                hasdata(I,J) = hasdataij;
            else
                if length(I)==1 && length(J)>1
                    c1{I(1),J(1)} = sprintf('\\multicolumn{%g}{|c|}{%s}',length(J),cij);
                    hasdata(I(1),J) = hasdataij(1);
                    c1(I(1),J(2:end)) = {[]};
                elseif length(I)>1 && length(J)==1
                    c1{I(1),J(1)} = sprintf('\\multirow{%g}{*}{%s}',length(I),cij);
                    hasdata(I(1),J(1)) = hasdataij(1);
                    c1(I(2:end),J(1)) = {NaN};
                elseif length(I)>1 && length(J)>1
                    if isnan(cij)
                        c1{I(1),J(1)} = sprintf('\\multicolumn{%g}{|c|}{\\multirow{%g}{*}{%s}}',length(J),length(I),'');
                    else
                        c1{I(1),J(1)} = sprintf('\\multicolumn{%g}{|c|}{\\multirow{%g}{*}{%s}}',length(J),length(I),cij);
                    end
                    c1(I(1),J(2:end)) = {[]};
                    hasdata(I(1),J) = hasdataij(1);
                    c1(I(2:end),J(1)) = {sprintf('\\multicolumn{%g}{|c|}{}',length(J))};
                    for jj = 2:length(J)
                        c1(I(2:end),J(jj)) = {[]};
                    end
                else
                    c1{I(1),J(1)} = cij;
                    hasdata(I(1),J(1)) = hasdataij;
                end
                    
            end
        end
    end
elseif ischar(c)
    if numel(c)>1 && size(c,2) == 1;
        c1 = sprintf('\\rotatebox[origin=c]{90}{%s}',c);
    else
        c1 = c;
    end
    hasdata = 1;
else
    c1 = sprintf('%g',c);
    hasdata = 1;
end
end

            

function [sz] = calcsz(c);
if ~iscell(c)
    if ischar(c)
        sz = [1 1];
    else
        if length(size(c))>2
            error('cell with >2 dimensionsions detected')
        end
        sz = [size(c,1) size(c,2)];
    end
else
    sz = [0 1];
        for i = 1:size(c,1);
        rowsz = [1 0];
        for j = 1:size(c,2);
        [szij] = calcsz(c{i,j});
        rowsz(1) = max(rowsz(1),szij(1));
        rowsz(2) = rowsz(2)+szij(2);
        end
        sz(1) = sz(1)+rowsz(1);
        sz(2) = max(sz(2),rowsz(2));
        end
end
end

function t = genLatexTable(c,hasdata,varargin)
opts = struct('label',[],'caption',[],'alignment',[]);
opts = setopts(opts,varargin);
if ~ischar(opts.alignment)
    opts.alignment = ['|' repmat('c|',1,size(c,2))];
end
t = sprintf('\\begin{table}[h]\n');
if ischar(opts.caption)
    t = sprintf('%s%s\n',t,sprintf('\\caption{%s}',opts.caption));
end
%t = sprintf('%s%s\n',t,'\resizebox{\linewidth}{!}{');
t = sprintf('%s%s\n',t,'\begin{center}');

t = sprintf('%s\\begin{tabular}{%s}\n',t,opts.alignment);
for i = 1:size(c,1)
    rng0 = find(hasdata(i,:),1,'first');
    rng1 = find(hasdata(i,:),1,'last');
    rowtxt = sprintf('\\cline{%g-%g}',rng0,rng1);
    blanks = cellfun(@(x)isa(x,'double')&&isempty(x),c(i,:));
    nans = cellfun(@(x)~isempty(x)&&~ischar(x)&&isnan(x),c(i,:));
    multirow = cellfun(@(x)~isempty(x)&&ischar(x)&&(~isempty(strfind(x,'{c}{}'))),c(i,:));
    empties = [0 find(nans | multirow | blanks)];
    if numel(empties)==1
        cline = '\hline';
    else
        cline = '';
        for j = 1:length(empties)-1;
            if empties(j+1)-1 >= empties(j)+1
                cline  = [cline sprintf('\\cline{%g-%g} ',empties(j)+1,empties(j+1)-1)];
            end
        end
    end
    if all(hasdata(i,:))
        cline = '\hline';
    else
        cline = '';
        empties = [0 find(~hasdata(i,:))];
        for j = 1:length(empties)-1;
            if empties(j+1)-1 >= empties(j)+1
                cline  = [cline sprintf('\\cline{%g-%g} ',empties(j)+1,empties(j+1)-1)];
            end
        end
    end
    
    for j = 1:size(c,2);
        if ischar(c{i,j})
            rowtxt = sprintf('%s %s &',rowtxt,c{i,j});
        else
            if ~(isa(c{i,j},'double') && isempty(c{i,j}))
                if isnan(c{i,j})
                    rowtxt = sprintf('%s %g &',rowtxt,'');
                else
                    rowtxt = sprintf('%s %g &',rowtxt,c{i,j});
                end
            end
        end
    end
    t = sprintf('%s%s%s\\\\\n',t,cline,rowtxt(1:end-1));
end
t = sprintf('%s\\hline\n',t);
t = sprintf('%s\\end{tabular}\n',t);
t = sprintf('%s%s\n',t,'\end{center}');
%t = sprintf('%s}\n',t);
if ischar(opts.label);
    t = sprintf('%s%s\n',t,sprintf('\\label{tab:%s}',opts.label));
end
t = sprintf('%s\\end{table}\n',t);
end

    