classdef test1
	properties
		expName='12mv1211';
		testName='065';

		timeWindow=1000:1200;
		channelWindow=1:32;

		timeSubdiv=200; %Size of subdivisions of blocks of data to be analyzed

		figFormat='png';
	end
	methods
		%Runs everything
		function run(this)
			divs=[10,20,40,50,100,200];
			for en=1:length(Const.ALL_EXPERIMENTS)
				this.expName = Const.ALL_EXPERIMENTS{en};
				testNames=Const.ALL_TESTS(this.expName);
				for tn=1:length(testNames)
					this.testName = testNames{tn};
					for d=1:length(divs)
						this.timeSubdiv=divs(d);
						this.runOnce();
					end
				end
			end
		end

		%Produces 8 images
		%	x axis = orientation
		%	y axis = channel
		%Mean figure
		%	x axis = orientation (each represents one of the 8 figures above, averaged across orientations)
		%	y axis = channel
		function ret=runOnce(this)
			dir = [Const.RESULT_DIRECTORY pathname(class(this), this.expName, this.testName, num2str(this.timeSubdiv)) ];
			cdforce(dir);

			%If we haven't already done the analysis, then do them
			if (~exist('ret.mat','file'))
				%Load the data
				loader=CSDLoader;
				loader.expName=this.expName;
				csd=loader.load(this.testName);
				if ~csd.isGrating()
					disp('Not a grating stimulus. Skipping.');
					return;
				end
				%Set parameters
				csd.timeWindow=this.timeWindow;
				csd.channelWindow=this.channelWindow;
				%Analyze the data
				ret=CSDStatAnalysis(csd,this.timeSubdiv);
			else
				load('ret.mat');
			end

			%Produce 8 figures, one for each orientation
			for x=1:8
				%Format the data for the figures
				output=mean(ret,4);
				output=squeeze(output(x,:,:,:));
				for i=1:length(output(:))
					if (output(i) ~= 1)
						output(i)=0;
					end
				end
				output=transpose(output);

				%Create and save the figures
				h=figure;
				set(h,'Visible','off');
				imagesc(output);
				title([this.expName ' ' this.testName '\_' num2str(x)]);
				xlabel('Orientation');
				ylabel('Channel');
				colorbar;
				saveas(h,[num2str(x) '.' this.figFormat], this.figFormat);
			end

			%Average over orientations
			output=mean(ret,2);
			output=mean(output,4);
			output=squeeze(output);
			h=figure;
			set(h,'Visible','off');
			imagesc(transpose(output));
			title([this.expName ' ' this.testName ' mean']);
			xlabel('Orientation');
			ylabel('Channel');
			colorbar;
			saveas(h,['mean.' this.figFormat], this.figFormat);

			%Difference in orientation
			x=squeeze(mean(ret,4));
			output=zeros(32,8);
			for diff=0:7
				for cond1=1:8
					cond2=mod(cond1+diff-1,8)+1;
					output(:,diff+1)=output(:,diff+1)+squeeze(x(cond1,cond2,:));
				end
			end
			h=figure;
			set(h,'Visible','off');
			imagesc(output);
			title([this.expName ' ' this.testName ' difference']);
			xlabel('Orientation difference (0-7, not 1-8)');
			ylabel('Channel');
			colorbar;
			saveas(h,['diff.' this.figFormat], this.figFormat);
		end
	end
end
