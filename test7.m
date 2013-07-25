classdef test7 < handle
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

		function runOnce(this)
			%[xAll,yAll]=this.generateDataSet(3,12,0); %Entire data set
			t6 = test6;
			[xAll,yAll]=t6.generateDataSet(7,30,0); %TODO: Should move this out of test 6

			%TODO
		end
end
