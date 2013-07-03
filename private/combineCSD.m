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

	%Trim above
	delta = abs(csd1.alignment.firstChannel - csd2.alignment.firstChannel);
	if (csd1.alignment.firstChannel > csd2.alignment.firstChannel)
		csd1.data = csd1.data(delta:end,:,:,:);
		csd1.alignment.firstChannel = csd2.alignment.firstChannel;
	else
		csd2.data = csd2.data(delta:end,:,:,:);
		csd2.alignment.firstChannel = csd1.alignment.firstChannel;
	end

	%Trim below
	s1=size(csd1.data);
	s2=size(csd2.data);
	s=min(s1(1),s2(1));

	csd1.data=csd1.data(1:s,:,:,:);
	csd2.data=csd2.data(1:s,:,:,:);

	ret.alignment.firstChannel = csd1.alignment.firstChannel;
	ret.data = cat(3, csd1.data, csd2.data);
	size(ret.data)

	ret.data = mean(ret.data,4);
	ret.data = mean(ret.data,3);
	ret.data = ret.data(:,1000:1200);
	figure;
	imagesc(ret.data);
end
