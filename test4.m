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
		end
	end
	methods (Access = private)
		function ret=loadPrototype(this)
			%If it's already loaded, then don't do anything
			if ~isempty(this.pcsd)
				return;
			end

			dir = [Const.RESULT_DIRECTORY pathname(class(this), this.expName, this.testName) ];
			cdforce(dir);

			%Insertion 7
			ret=CSDAlignment;
			ret.expName='12mv1211';
			ret.testName='095';
			ret.firstChannel=6;
			save('095.mat','ret');

			loader=CSDLoader;
			%ret=loader.load('095');
			%ret.data=ret.data([6:16],[1000:1200],:);
			this.pcsd=loader.load('095');
			this.pcsd.data=this.pcsd.data([6:16],[1000:1200],:);
		end
		function ret=align(csd1,csd2)
			%Initialize variables
			%csd1.data=csd1.data([4:16],[1000:1200],:);
			size1=size(csd1.data);
			size2=size(csd2.data);
			times=size2(2)-size1(2);
			channels=size2(1)-size1(1);
			trials=min(size1(3),size2(3));
			csd1.data=csd1.data(:,:,[1:trials]); %TODO: Try averaging over the trials instead
			csd2.data=csd2.data(:,:,[1:trials]);
			tempCsd1=csd1.data(:);

			corrValues=zeros(channels,times);
			bestCh=1;
			bestT=1;
			for ch=1:channels
				disp(['Channel: ' num2str(ch)]);
				tic;
				for t=1:times
					channel=[4:16]-3+ch;
					time=[1000:1200]-999+t;
					tempCsd2=csd2.data(channel,time,:);
					tempCsd2=tempCsd2(:);
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
			name=[csd1.testName '-' csd2.testName];
			saveas(fig,name,'png');

			ret=CSDAlignment;
			ret.firstChannel=bestCh;
			return;

			ret=[bestCh bestT];
		end
	end
end
