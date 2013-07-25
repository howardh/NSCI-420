classdef test2
	properties
		expName='12mv1211';
		testName='065';

		timeWindow=1000:1200;
		channelWindow=1:32;

		timeSubdiv=20; %Size of subdivisions of blocks of data to be analyzed

		figFormat='png';
		
		alpha=0.001;

		fFDR = true; %If true, will correct for false discovery

		%Flags (should all be false by default)
		fRedoAnalysis = 0;
		fShowFdrPlots = 0;
	end
	methods
		%Runs everything
		function run(this)
			%divs=[10,20,40,50,100,200];
			%divs=[10,40,50,200];
			divs=[200];
			%Every experiment
			for en=1:length(Const.ALL_EXPERIMENTS)
				this.expName = Const.ALL_EXPERIMENTS{en};
				testNames=Const.ALL_TESTS(this.expName);
				%Every test within that experiment
				for tn=1:length(testNames)
					this.testName = testNames{tn};
					isGrating = 1;
					%Every possible time subdivision
					for d=1:length(divs)
						this.timeSubdiv=divs(d);
						%Every alpha value
						for a=[0.1 0.05 0.01 0.005 0.001];
							this.alpha = a;
							%Perform tests with and without false discovery correction
							for fdr=[false true]
								this.fFDR = fdr;
								isGrating=this.runOnce();
								%If the current test is not a grating stimulus, skip
								if ~isGrating
									break;
								end
							end

							%If the current test is not a grating stimulus, skip
							if (~isGrating) break; end;
						end
						%If the current test is not a grating stimulus, skip
						if ~isGrating
							break;
						end
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
		function isGrating=runOnce(this)
			isGrating=1;
			dir = [Const.RESULT_DIRECTORY pathname(class(this), this.expName, this.testName, num2str(this.timeSubdiv), num2str(this.alpha)) ];
			cdforce(dir);

			%If we haven't already done the analysis, then do them
			if (~exist('../ret.mat','file') | this.fRedoAnalysis)
				disp('compute stuff');
				%Load the data
				loader=CSDLoader;
				loader.expName=this.expName;
				csd=loader.load(this.testName);
				if ~csd.isGrating()
					disp('Not a grating stimulus. Skipping and cleaning up.');
					cd(pathname('..', '..', '..')); %Leave the directory we're deleting
					dir = [Const.RESULT_DIRECTORY pathname(class(this), this.expName, this.testName) ];
					rmdir(dir,'s');
					isGrating=0;
					return;
				end
				%Set parameters
				csd.timeWindow=this.timeWindow;
				csd.channelWindow=this.channelWindow;
				%Analyze the data
				[ret,tStat]=this.analyze(csd,this.timeSubdiv);
				%Save the analyzed data
				save('../ret.mat','ret');
				save('../tstat.mat','tStat');
			else
				disp(['Analysis already done. Loading results from file.']);
				load('../ret.mat');
				tStat=loadvar('../tstat.mat');
			end

			%Load the color map
			cmap=interp1([1 32 64],[0 0 1; 1 1 1; 1 0 0],1:64);

			%Plot p-values and t statistics
			if (this.alpha == 0)
				%p-values
				ret=mean(ret,4);
				ret(:)=log(abs(ret(:))).*sign(ret(:));
				for x=1:8
					output=squeeze(ret(x,:,:));
					h=figure;
					set(h,'Visible','off');
					subplot(1,2,1); %Make room for the caption
					range=[-9 9]; %Based on a visual inspection of the results without a range
					imagesc(transpose(output), range);
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
					saveas(h,['p' num2str(x) '.' this.figFormat], this.figFormat);
				end

				%TODO: What is this and why is this here
				%%Sort and plot p-values
				%y=sort(ret(:));
				%h=figure;
				%plot(1:length(y),y);
				%saveas(h,['pp' num2str(x) '.' this.figFormat], this.figFormat);

				%t statistics
				for x=1:8
					%size(tStat)
					tStat=mean(tStat,4);
					output=squeeze(tStat(x,:,:));
					h=figure;
					set(h,'Visible','off');
					subplot(1,2,1); %Make room for the caption
					range=[-5 5]; %Based on a visual inspection of the results without a range
					imagesc(transpose(output), range);
					colormap(cmap);
					title([this.expName ' ' this.testName '\_' num2str(x) ' t Statistics']);
					xlabel('Orientation');
					ylabel('Channel');
					zlabel('T statistics');
					colorbar;
					lb=[char(10) char(10)]; %Line break
					caption=['Color represents the t statistics' lb ...
							 'Proximity to white = less significant difference' lb ...
							 'Orientation ' num2str(x) ' compared to every other orientation (Including itself)' lb ...
							 'red = CSD of orientation ' num2str(x) ' at that channel is larger than that of the orientation represented by that column at that channel.'];
					annotation('textbox', [.5 .1 .4 .8], 'String', caption);
					saveas(h,['t' num2str(x) '.' this.figFormat], this.figFormat);
				end
				return;
			end

			%Check for false discovery
			if (this.fFDR & this.alpha ~= 0)
				this.alpha = this.correctFalseDiscovery(abs(ret(:)));
			end

			%Convert the p values (ret) into h (0 if hypothesis is rejected, 1 otherwise)
			ret(abs(ret) > this.alpha) = 0;
			%Amir wants to see the p-values along with the thresholding
			%ret(:) = sign(ret(:)); %Can be 1 or -1, depending on the direction of the difference

			%Produce 8 figures, one for each orientation
			for x=1:8
				%Format the data for the figures
				output=mean(ret,4);
				output(output ~= 0)=log(abs(output(output ~= 0))).*sign(output(output ~= 0));
				output=squeeze(output(x,:,:,:));
				output=transpose(output);

				%Create and save the figures
				h=figure;
				set(h,'Visible','off');
				imagesc(output,[-10 10]);
				colormap(cmap);
				title([this.expName ' ' this.testName '\_' num2str(x) ' \alpha=' num2str(this.alpha)]);
				xlabel('Orientation');
				ylabel('Channel');
				colorbar;
				fileName = num2str(x);
				if (this.fFDR)
					fileName = ['FDR' fileName];
				end
				saveas(h,[fileName '.' this.figFormat], this.figFormat);
			end

			%Average over orientations
			output=mean(ret,2);
			output=mean(output,4);
			output=squeeze(output);
			h=figure;
			set(h,'Visible','off');
			imagesc(transpose(output), [-1 1]);
			colormap(cmap);
			title([this.expName ' ' this.testName ' mean \alpha=' num2str(this.alpha)]);
			xlabel('Orientation');
			ylabel('Channel');
			colorbar;
			fileName = 'mean';
			if (this.fFDR)
				fileName = ['FDR' fileName];
			end
			saveas(h,[fileName '.' this.figFormat], this.figFormat);
		end

		function clear(this)
			dir = [Const.RESULT_DIRECTORY pathname(class(this)) ];
			rmdir(dir,'s');
		end
	end
	methods (Access = private)
		% Computes the p values of the statistical analysis and returns it
		% Computes the t statistics and stores it in a file 
		function [ret,tStat]=analyze(this,csd, div)
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
			tStat=zeros(sizes(4),sizes(4),sizes(1),floor(sizes(2)/div));
			for cond1=1:sizes(4)
				for cond2=1:sizes(4)
					disp([num2str(cond1) '-' num2str(cond2)]);
					tic
					for ch=1:sizes(1)
						t=[1:div];
						tCount=1;
						while (t(end)<=sizes(2))
							dist1 = mean(csd.data(ch,t,:,cond1),2);
							dist2 = mean(csd.data(ch,t,:,cond2),2);

							[p,ts] = this.test(dist1(:),dist2(:));
							ret(cond1,cond2,ch,tCount) = p;
							tStat(cond1,cond2,ch,tCount) = ts;
							%ret(cond2,cond1,ch,tCount) = -p;
							%tStat(cond2,cond1,ch,tCount) = -ts;

							t=t+div;
							tCount=tCount+1;
						end
					end
					toc
				end
			end
		end
		function [p,t]=test(this,dist1,dist2)
			mean1=mean(dist1);
			mean2=mean(dist2);
			if (mean1 > mean2)
				[h,p,c,s]=ttest2(dist1,dist2,0.05,'right');
				p=p;
			else
				[h,p,c,s]=ttest2(dist1,dist2,0.05,'left');
				p=-p;
			end
			t=-s.tstat;
		end

		%Returns the alpha value to use after false discovery rate correction
		function alpha=correctFalseDiscovery(this, p)
			p=sort(p);

			%Benjamini-Hochberg
			m=length(p);
			q=this.alpha;
			alpha=0;
			for i=fliplr(1:m)
				if (p(i) <= i/m*q)
					alpha = p(i);
					break;
				end
			end

			%Sort and plot p-values (Debugging purposes)
			if (this.fShowFdrPlots)
				y=p(:);
				h=figure;
				plot(1:length(y),y);
				title([num2str(alpha)]);
				hold on;
				plot(1:length(y),[1:length(y)]/m*q);
			end
		end
	end
end
