function listTests(ExpName)
	currentDirectory=pwd;

	%GetDataInfo
	if (nargin == 0)
		ExpName= '12mv1211';
	end

	for i = 10:148
		if i < 100;
			TestName = ['0' int2str(i)];
		else
			TestName = [int2str(i)];
		end
		
		% DataFolder
		DataFolder =['\\132.216.58.64\f\Martin\' ExpName '\Electro\Analyzed Data\'];
		GroupName = 'Conditions';
		% Stimulus Folder
		cd(['\\132.216.58.64\f\Martin\' ExpName '\Electro\StimulusObjects\'])

		%Check if the file exists
		if ~exist([TestName '.mat'], 'file');
			continue; %Doesn't exist
		end

		%Load the data
		load (TestName);
		loops = P.Loops;

		%If it's a grating stimulus
		%if strcmp(class(P),'Gratings')~=0;
		%    disp([TestName ' ' class(P)]);
		%end
		disp([TestName ' ' class(P)]);
	end

	cd(currentDirectory);
end
