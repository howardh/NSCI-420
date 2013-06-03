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

		%TODO
		function ret=ALL_TESTS(expName)
			ret={'065'};
		end
	end
end
