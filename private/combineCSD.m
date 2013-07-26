%Combines the data for csd1 and csd2
%Assumes that the stimulus type of csd1 and csd2 are the same
%
%@param csd1
%	CSDData
%@param csd2
%	CSDData
%@return
%	CSDData
function ret=combineCSD(csd1, csd2)
	%If the data is not aligned, we can't do anything with it
	if (isempty(csd1.alignment) | isempty(csd2.alignment))
		disp(['Error: combineCSD(), alignment data not available. Run test4 and test5 first to obtain the data.']);
		ret=[];
		return;
	end

	%Initialize
	ret=CSDData;

	%If it's a grating stimulus, rearrange data so that prefered orientations match
	if (csd1.isGrating() & csd2.isGrating())
		%csd1
		csd1.data = cat(csd1.data, csd1.data, 4);
		po = csd1.getPrefOrientation();
		csd1.data = csd1.data(:,:,:,[1:8]-1+po);

		%csd2
		csd2.data = cat(csd2.data, csd2.data, 4);
		po = csd2.getPrefOrientation();
		csd2.data = csd2.data(:,:,:,[1:8]-1+po);
	end

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

	%Update alignment data
	ret.alignment.firstChannel = csd1.alignment.firstChannel;
	ret.data = cat(3, csd1.data, csd2.data);
	size(ret.data)

	ret.data = mean(ret.data,4);
	ret.data = mean(ret.data,3);
	ret.data = ret.data(:,1000:1200);
	figure;
	imagesc(ret.data);
end
