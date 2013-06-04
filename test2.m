classdef test2
	properties
		expName='12mv1211';
		testName='065';

		timeWindow=1000:1200;
		channelWindow=1:32;

		timeSubdiv=20; %Size of subdivisions of blocks of data to be analyzed

		figFormat='png';
		
		alpha=0.000000001;
	end
	methods
		%Runs everything
		function run(this)
			divs=[10,20,40,50,100,200];
			%Every experiment
			for en=1:length(Const.ALL_EXPERIMENTS)
				this.expName = Const.ALL_EXPERIMENTS{en};
				testNames=Const.ALL_TESTS(this.expName);
				%Every test within that experiment
				for tn=1:length(testNames)
					this.testName = testNames{tn};
					%Every possible time subdivision
					for d=1:length(divs)
						this.timeSubdiv=divs(d);
						%Every alpha value
						for a=2:10
							this.alpha = 10^-a;
   							this.runOnce();
						end
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
			dir = [Const.RESULT_DIRECTORY pathname(class(this), this.expName, this.testName, num2str(this.timeSubdiv), num2str(-log10(this.alpha))) ];
			cdforce(dir);

			%If we haven't already done the analysis, then do them
			if (~exist('ret.mat','file'))
				disp('compute stuff');
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
				ret=this.analyze(csd,this.timeSubdiv);
			else
				disp(['load stuff ' pwd]);
				load('ret.mat');
			end

			%Load the color map
			load('colormap.mat');

			%Produce 8 figures, one for each orientation
			for x=1:8
				%Format the data for the figures
				output=mean(ret,4);
				output=squeeze(output(x,:,:,:));
				output=transpose(output);

				%Create and save the figures
				h=figure;
				set(h,'Visible','off');
				imagesc(output,[-1 1]);
				colormap(cmap);
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
			imagesc(transpose(output), [-1 1]);
			colormap(cmap);
			title([this.expName ' ' this.testName ' mean']);
			xlabel('Orientation');
			ylabel('Channel');
			colorbar;
			saveas(h,['mean.' this.figFormat], this.figFormat);
		end
	end
	methods (Access = private)
		function ret=analyze(this,csd, div)
			% Col 1: 32
			%   Channels
			% Col 2: 3501
			%   Time in ms?
			% Col 3: 10? variable size
			%   Trials
			% Col 4: 16
			%   Conditions

			%Default arguments
			if (nargin == 1)
				disp('CSDStatAnalysis: div not specified. Defaulting to 20');
				div=20;
			end

			csd.data=csd.trim();
			%csd.data=csd.mergeConditions();
			csd.data=csd.avgConditions();
			sizes=size(csd.data);

			ret=zeros(sizes(4),sizes(4),sizes(1),floor(sizes(2)/div));
			for cond1=1:sizes(4)
				for cond2=cond1:sizes(4)
					disp([num2str(cond1) '-' num2str(cond2)]);
					tic
					for ch=1:sizes(1)
						t=[1:div];
						tCount=1;
						while (t(end)<=sizes(2))
							dist1 = csd.data(ch,t,:,cond1);
							dist2 = csd.data(ch,t,:,cond2);
							ret(cond1,cond2,ch,tCount) = this.test(dist1(:),dist2(:));
							ret(cond2,cond1,ch,tCount) = -ret(cond1,cond2,ch,tCount);

							t=t+div;
							tCount=tCount+1;
						end
					end
					toc
				end
			end
		end
		function ret=test(this,dist1,dist2)
			mean1=mean(dist1);
			mean2=mean(dist2);
			if (mean1 > mean2)
				ret=ttest2(dist1,dist2,this.alpha,'right');
			else
				ret=-ttest2(dist1,dist2,this.alpha,'left');
			end
		end
	end
end
