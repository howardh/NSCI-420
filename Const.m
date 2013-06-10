%Class containing constants used in the scripts
classdef Const
	properties (Constant)
		DATA_DIRECTORY =	'C:\Users\labuser 2\Documents\MATLAB\CSDData\';
		FIGURE_DIRECTORY =	'C:\Users\labuser 2\Documents\MATLAB\Figures\';
		RESULT_DIRECTORY =	'C:\Users\labuser 2\Documents\MATLAB\Results\';

		%TODO: A list of all experiment names
		ALL_EXPERIMENTS = {'12mv1211'};

		MEOW = Const.DATA_DIRECTORY; %Not used anywhere. Kept for reference purposes.
	end
	methods
		function this=Const()
		end
	end
	methods (Static)
		function ret=ALL_TESTS(expName)
			%FIXME: Temporary, for debugging purposes
			ret={'065'};
			%ret={'044'};
			%ret={'137'};
			return;
			%Actual function starts here
			if strcmp(expName, '12mv1211')
				%TODO: Removed 034. Don't know why it won't load.
				ret={'024', '025', '033', '035', '038', '042', '043', '044', '045', ... %Insertion 1
					'046', '048', '049', '050', '053', '054', ... %Insertion 2
					'056', '057', '058', '059', '060', '061', ... %Insertion 4
					'062', '063', '065', '066', '067', '068', ... %Insertion 5
					'070', '071', '073', '074', '075', '076', '077', '078', '079', '080', '081', '082', '083', ... %Insertion 6
					'084', '085', '086', '087', '088', '089', '091', '092', '093', '094', '095', '096', '097', '098', '099', '100', '101', ... %Insertion 7
					'102', '103', '104', '105', '106', '107', '108', '109', ... %Insertion 8
					'110', '111', '112', '113', '114', '115', '116', '117', '118', '119', ... %Insertion 9
					'120', '121', '122', '123', '124', '125', '126', '127', '128', '129', '130', '131', '132', ... %Insertion 10
					'133', '134', '135', '136', '137', '138', '140', '141', ... %Insertion 11
					'143', '144', '145', '146', '147', '148'}; %Insertion 12
				return;
			end
			ret={'000'};
		end

		function ret=BAD_CHANNELS(expName, testName)
			switch(expName)
				case '12mv1211'
					switch (testName)
						case '044'
							%ret=[23 25 27 30];
							%ret=[23 25];
							%ret=[21 23 25];
							ret=[30];
						case '104'
							ret=[17];
						otherwise
							ret=[23];
					end
				otherwise
					ret=[];
			end
		end
	end
end
