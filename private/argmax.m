function ret=argmax(matrix)
	[m i] = max(matrix(:));
	if isvector(matrix)
		ret=i;
	else
		n=ndims(matrix);
		ret=cell(1,n);
		[ret{:}]=ind2sub(size(matrix),i);
		ret=cell2mat(ret);
	end
end
