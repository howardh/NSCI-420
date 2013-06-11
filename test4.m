%Aligns the CSD mapping data in the spatial dimension
classdef test4
	properties
		expName='12mv1211';
		testName='065';

		timeWindow=1000:1200;
		channelWindow=1:32;

		figFormat='png';

		pcsd; %Prototypical csd
		pcsda; %Prototypical csd alignment
	end
	methods
		%Runs everything
		function run(this)
			%Load prototypical CSD
			this.loadPrototype();
			this.runOnce();
			%Every experiment
			%for en=1:length(Const.ALL_EXPERIMENTS)
			%	this.expName = Const.ALL_EXPERIMENTS{en};
			%	testNames=Const.ALL_TESTS(this.expName);
			%	%Every test within that experiment
			%	for tn=1:length(testNames)
			%		this.testName = testNames{tn};
			%		this.runOnce();
			%	end
			%end
		end

		function ret=runOnce(this)
			dir = [Const.RESULT_DIRECTORY pathname(class(this), this.expName, this.testName) ];
			cdforce(dir);

			loader=CSDLoader;
			csd=loader.load(this.testName);
			this.align(csd);
		end
	end
	methods (Access = private)
		function loadPrototype(this)
			%If it's already loaded, then don't do anything
			if ~isempty(this.pcsd)
				return;
			end

			dir = [Const.RESULT_DIRECTORY pathname(class(this), this.expName, this.testName) ];
			cdforce(dir);

			%Insertion 7
			this.pcsda=CSDAlignment;
			this.pcsda.expName='12mv1211';
			this.pcsda.testName='095';
			this.pcsda.chWindow=[6:16];
			this.pcsda.tWindow=[1000:1200];
			this.pcsda.firstChannel=6;
			ret=this.pcsda;
			save('095.mat','ret');

			loader=CSDLoader;
			this.pcsd=loader.load('095');
			this.pcsd.data=this.pcsd.data(this.pcsda.chWindow, this.pcsda.tWindow, :);
		end

		% @param csd
		% 	CSD data to be aligned
		% @return
		% 	A CSDAlignment representing the alignment of the provided CSD data
		function ret=align(csd)
			%Initialize variables
			size1=size(this.pcsd.data);
			size2=size(csd.data);
			times=size2(2)-size1(2);
			channels=size2(1)-size1(1);
			trials=min(size1(3),size2(3));
			%Average over trials
			csd.data=mean(csd.data,3);

			%Prototypical CSD
			tempCsd1=mean(this.pcsd.data(:),3);
			tempCsd1=tempCsd1(:);

			%Find highest correlation
			corrValues=zeros(channels,times);
			bestCh=1;
			bestT=1;
			for ch=1:channels
				disp(['Channel: ' num2str(ch)]);
				tic;
				for t=1:times
					%Compute windows
					chWindow=this.pcsda.chWindow-this.pcsda.chWindow(1)+ch;
					tWindow=this.pcsda.tWindow-this.pcsda.tWindow(1)+t;

					%Get the data in that window
					tempCsd2=csd.data(channel,time);
					tempCsd2=tempCsd2(:);

					%Compute correlation
					corrValues(ch,t)=computeCorrelation(tempCsd1,tempCsd2);

					%Check if it's a better match
					if (mean(corrValues(ch,t)) > mean(corrValues(bestCh,bestT)))
						bestCh=ch;
						bestT=t;
					end
				end
				toc
			end

			%Make pretties and save it to a file
			fig=figure;
			imagesc(corrValues);
			colorbar;
			name=[this.pcsd.testName '-' csd.testName];
			saveas(fig,name,'png');

			%Create alignment object and return it
			ret=CSDAlignment;
			ret.chWindow=this.pcsd.chWindow-this.pcsd.chWindow-bestCh;
			ret.firstChannel=bestCh;
			return;
		end
	end
end
