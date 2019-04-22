function str = rawstr(instr)
str = strrep(instr,'\','\\');
str = strrep(str,'_','\_');