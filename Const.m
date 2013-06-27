%Class containing constants used in the scripts
classdef Const
	properties (Constant)
		SCRIPT_DIRECTORY =	'\\132.216.58.64\f\SummerStudents\Howard\Scripts';
		DATA_DIRECTORY =	'C:\Users\labuser 2\Documents\MATLAB\CSDData\';
		FIGURE_DIRECTORY =	'C:\Users\labuser 2\Documents\MATLAB\Figures\';
		RESULT_DIRECTORY =	'C:\Users\labuser 2\Documents\MATLAB\Results\';

		ALIGNMENT_DIRECTORY = [Const.DATA_DIRECTORY 'test4\'];

		%SCRIPT_DIRECTORY =	'~/Documents/MATLAB/Scripts/';
		%DATA_DIRECTORY =	'~/Documents/MATLAB/CSDData/';
		%FIGURE_DIRECTORY =	'~/Documents/MATLAB/Figures/';
		%RESULT_DIRECTORY =	'~/Documents/MATLAB/Results/';

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
				%TODO: Removed 034, 059, 066, 074, 075, 086, 088, 091, 092, 093, 094, 096, 105, 113, 115, 125, 138, 146. Don't know why it won't load.
				%	130 gave a different error when loading after it was done interpolating
				ret={'024', '025', '033', '035', '038', '042', '043', '044', '045', ... %Insertion 1
					'046', '048', '049', '050', '053', '054', ... %Insertion 2
					'056', '057', '058', '060', '061', ... %Insertion 4
					'062', '063', '065', '067', '068', ... %Insertion 5
					'070', '071', '073', '076', '077', '078', '079', '080', '081', '082', '083', ... %Insertion 6
					'084', '085', '087', '089', '095', '097', '098', '099', '100', '101', ... %Insertion 7
					'102', '103', '104', '106', '107', '108', '109', ... %Insertion 8
					'110', '111', '112', '114', '116', '117', '118', '119', ... %Insertion 9
					'120', '121', '122', '123', '124', '126', '127', '128', '129', '131', '132', ... %Insertion 10
					'133', '134', '135', '136', '137', '140', '141', ... %Insertion 11
					'143', '144', '145', '147', '148'}; %Insertion 12
				return;
			end
			ret={'000'};
		end

		function ret=ALL_INSERTIONS(expName)
			switch expName
				case '12mv1211'
					ret=[1 2 4:12];
			end
		end

		% Returns the insertion number for the experiment and test
		function ret=INSERTION(expName, testName)
			%Get the list of where each insertion ends
			switch expName
				case '12mv1211'
					%  1  2  3  4  5  6  7   8   9   10  11  12
					x=[45,54,54,61,68,83,101,109,119,132,141,148];
			end

			tn=str2num(testName);
			for ret=1:length(x)
				if tn <= x(ret)
					return;
				end
			end
		end

		function ret=TESTS_IN_INSERTION(expName, insertion)
			tests=Const.ALL_TESTS(expName);
			ret=[];
			for i=1:length(tests)
				ins=Const.INSERTION(expName,tests{i});
				if ins==insertion
					ret=[ret tests(i)];
				elseif ins>insertion
					return;
				end
			end
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
