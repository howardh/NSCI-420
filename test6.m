classdef test6 < handle
	properties
		expName='12mv1211';

		figFormat='png';
	end
	methods
		%Runs everything
		function run(this)
			for en=1:length(Const.ALL_EXPERIMENTS)
				this.expName = Const.ALL_EXPERIMENTS{en};

				this.runOnce();
			end
		end

		function runOnce()
		end

		function ret=generateDataSet(this)
			tests = Const.ALL_TESTS(this.expName);

			loader=CSDLoader;

			for t=1:length(tests)
				csd=loader.load(tests{t});

				if ~csd.isGrating()
					continue;
				end

				%TODO: Do stuff here
			end
		end
	end
end
