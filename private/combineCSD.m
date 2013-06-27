%Combines the data for csd1 and csd2
%
%@param csd1
%	CSDData
%@param csd2
%	CSDData
%@return
%	CSDData
function ret=combineCSD(csd1, csd2)
	if (isempty(csd1.alignment) | isempty(csd2.alignment))
		disp(['Error: combineCSD(), alignment data not available. Run test4 and test5 first to obtain the data.']);
		ret=[];
		return;
	end
	ret=CSDData;
	size(csd1.data)
	size(csd2.data)
end
