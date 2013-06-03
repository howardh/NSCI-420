function ret=argmax(matrix)
	matrix=matrix(:);
	ret=1;
	for i=2:length(matrix)
		if (matrix(i) > matrix(ret))
			ret=i;
		end
	end
	%ret=am(matrix);
end

function ret=am(matrix)
	dim=size(matrix);

	currMax=1;
	for i=2:length(matrix)
		if (matrix(i) > matrix(currMax))
			currMax=i;
		end
	end
	ret=currMax;

	i=length(dim);
	while (i >= 1)
		dim(i)=prod(dim(1:i-1));
		i=i-1;
	end

end

function ret=isVector(matrix)
	dim = size(matrix);
	ret = dim(1)==1 && length(dim)==2;
end
