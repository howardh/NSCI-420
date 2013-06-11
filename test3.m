classdef test3
	properties
		expName='12mv1211';
		testName='065';

		timeWindow=1000:1200;
		channelWindow=1:32;

		timeSubdiv=20; %Size of subdivisions of blocks of data to be analyzed

		figFormat='png';
		
		alpha=0.001;
	end
	methods
		%Runs everything
		function run(this)
			%divs=[10,20,40,50,100,200];
			divs=[200];
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
						%for a=2:10
						%	this.alpha = 10^-a;
   						%	this.runOnce();
						%end
						%And plot the p values too
						this.alpha = 0;
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
			dir = [Const.RESULT_DIRECTORY pathname(class(this), this.expName, this.testName, num2str(this.timeSubdiv), num2str(-log10(this.alpha))) ];
			cdforce(dir);

			%If we haven't already done the analysis, then do them
			if (~exist('../ret.mat','file'))
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
				%Save the analyzed data
				save('../ret.mat','ret');
			else
				disp(['Analysis already done. Loading results from file.']);
				load('../ret.mat');
			end

			%Load the color map
			cmap=interp1([1 32 64],[0 0 1; 1 1 1; 1 0 0],1:64);

			%Plot p-values
			if (this.alpha == 0)
				ret=mean(ret,4);
				ret(:)=log(abs(ret(:))).*sign(ret(:));
				for x=1:8
					output=squeeze(ret(x,:,:));
					h=figure;
					set(h,'Visible','off');
					subplot(1,2,1); %Make room for the caption
					range=[-120 120]; %Based on a visual inspection of the results without a range
					imagesc(transpose(output), range);
					%imagesc(transpose(output));
					colormap(cmap);
					title([this.expName ' ' this.testName '\_' num2str(x)]);
					xlabel('Orientation');
					ylabel('Channel');
					zlabel('P value (log transformed)');
					colorbar;
					lb=[char(10) char(10)]; %Line break
					caption=['Color represents the p-values after a log transformation' lb ...
							 'Proximity to white = less significant difference' lb ...
							 'Orientation ' num2str(x) ' compared to every other orientation (Including itself)' lb ...
							 'red = CSD of orientation ' num2str(x) ' at that channel is larger than that of the orientation represented by that column at that channel.'];
					annotation('textbox', [.5 .1 .4 .8], 'String', caption);
					saveas(h,[num2str(x) '.' this.figFormat], this.figFormat);
				end
				return;
			end

			%Convert the p values (ret) into h (0 if hypothesis is rejected, 1 otherwise)
			ret(abs(ret) > this.alpha) = 0;
			ret(:) = sign(ret(:)); %Can be 1 or -1, depending on the direction of the difference
			%ret(abs(ret) < this.alpha & ret > 0) = 1;
			%ret(abs(ret) < this.alpha & ret < 0) = -1;

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

		function clear(this)
			dir = [Const.RESULT_DIRECTORY pathname(class(this)) ];
			rmdir(dir,'s');
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
							ret(cond1,cond2,ch,tCount) = this.test(dist1,dist2);
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
			%Get number of trials
			s=size(dist1);
			trials1=s(3);
			s=size(dist2);
			trials2=s(3);

			%Compare every trial to each other
			x=[];
			for t1=1:trials1
				for t2=1:trials2
					%Get a data point
					p=mean(dist1(:,:,t1,:)-dist2(:,:,t2,:));
					x=[x p]; %Append p to the data set
				end
			end

			%t-test
			[h,p]=ttest(x,this.alpha);

			%Set direction
			mean1=mean(dist1(:));
			mean2=mean(dist2(:));
			if (mean1 > mean2)
				ret=p;
			else
				ret=-p;
			end
		end
	end
end
