%Class containing constants used in the scripts
%TODO: A list of all experiment names
%TODO: A list of all test names within each experiment (Maybe a map containing them all?)
%	key = experiment (string)
%	value = tests (vector of strings)
classdef Const
	properties (Constant)
		DATA_DIRECTORY =	'C:\Users\labuser 2\Documents\MATLAB\CSDData\';
		FIGURE_DIRECTORY =	'C:\Users\labuser 2\Documents\MATLAB\Figures\';
		RESULT_DIRECTORY =	'C:\Users\labuser 2\Documents\MATLAB\Results\';

		%TODO
		ALL_EXPERIMENTS = {'12mv1211'};

		MEOW = Const.DATA_DIRECTORY;
	end
	methods
		function this=Const()
		end
	end
	methods (Static)
		function ret=ALL_TESTS(expName)
			%FIXME: Temporary, for debugging purposes
			ret={'065'};
			%ret={'137'};
			return;
			%Actual function starts here
			if strcmp(expName, '12mv1211')
				ret={'024', '025', '033', '034', '035', '038', '042', '043', '044', '045', ... %Insertion 1
					'046', '048', '049', '050', '053', '054', ... %Insertion 2
					'056', '057', '058', '059', '060', '061', ... %Insertion 4
					'062', '063', '065', '066', '067', '068', ... %Insertion 5
					'143', '144', '145', '146', '147', '148'}; %Insertion 12
				return;
			end
			ret={'000'};
		end
	end
end
