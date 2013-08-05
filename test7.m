classdef test7 < handle
	properties
		expName='12mv1211';
		testName='065';

		figFormat='png';
	end
	methods
		%Runs everything
		function run(this)
			addpath(Const.MI_DIRECTORY);
			for en=1:length(Const.ALL_EXPERIMENTS)
				this.expName = Const.ALL_EXPERIMENTS{en};

				tests = Const.ALL_TESTS(this.expName);

				for t=1:length(tests)
					this.testName = tests{t};
					this.runOnce();
				end
			end
		end

		function runOnce(this)
			dir = [Const.RESULT_DIRECTORY pathname(class(this), this.expName) ];
			cdforce(dir);

			channelsAbove = 3;
			totalChannels = 20;
			t6 = test6;
			t6.expName = this.expName;
			t6.testName = this.testName;
			%[xAll,yAll]=t6.generateDataSet(channelsAbove,totalChannels,0); %TODO: Should move this out of test 6
			[xAll,yAll]=t6.generateDataSet([-channelsAbove:-1 1:(totalChannels-channelsAbove)],0);

			s = size(xAll);
			channels = s(2);
			mi=[-channelsAbove:-1 1:(totalChannels-channelsAbove)]';
			for ch=1:totalChannels
				x = xAll(:,ch);
				y = yAll;

				%[x y']
				mi(ch,2) = mutualinfo(x,y');
				mi(ch,3) = MutualInformation(x,y');
			end
			[Y,I] = sort(mi(:,2));
			mi(I,:)
			mi

			h=figure;
			set(h,'visible','off');
			ha=axes;
			barh(mi(:,1),mi(:,2));
			hold on; showLayers();
			set(ha, 'YDir', 'reverse');
			xlabel('Mutual information');
			ylabel('Channel (Relative to surface)');
			saveas(h, ['mi-' this.testName '.' this.figFormat], this.figFormat);

			save([this.testName '.mat'],'mi');
		end
	end
end
