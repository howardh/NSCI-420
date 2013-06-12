function ret=loadVar(fileName)
	ret=cell2mat(struct2cell(load(fileName)));
end
