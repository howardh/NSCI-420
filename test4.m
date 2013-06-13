%Aligns the CSD mapping data in the spatial dimension
classdef test4 < handle
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
			for en=1:length(Const.ALL_EXPERIMENTS)
				this.expName = Const.ALL_EXPERIMENTS{en};
				testNames=Const.ALL_TESTS(this.expName);
				%Every test within that experiment
				for tn=1:length(testNames)
					this.testName = testNames{tn};
					this.runOnce();
				end
			end
		end

		function ret=runOnce(this)
			dir = [Const.RESULT_DIRECTORY pathname(class(this), this.expName) ];
			cdforce(dir);

			loader=CSDLoader;
			loader.expName=this.expName;
			csd=loader.load(this.testName);

			%Check if it's a CSDMapping run
			if csd.isCSDMapping()
				csd.data=(csd.data(:,1:500,:,:)+csd.data(:,501:1000,:,:)+csd.data(:,1001:1500,:,:)+csd.data(:,1501:2000,:,:))/4;
				this.align(csd);
			end
		end

		function clear(this)
			dir = [Const.RESULT_DIRECTORY pathname(class(this)) ];
			rmdir(dir,'s');
		end
	end
	methods (Access = private)
		function loadPrototype(this)
			%If it's already loaded, then don't do anything
			if ~isempty(this.pcsd)
				return;
			end

			dir = [Const.RESULT_DIRECTORY pathname(class(this), this.expName) ];
			cdforce(dir);

			%%Insertion 7
			%this.pcsda=CSDAlignment;
			%this.pcsda.expName='12mv1211';
			%this.pcsda.testName='095';
			%this.pcsda.chWindow=[6:16];
			%this.pcsda.tWindow=[1000:1200];
			%this.pcsda.firstChannel=6;
			%ret=this.pcsda;
			%save('095.mat','ret');

			%loader=CSDLoader;
			%this.pcsd=loader.load('095');
			%this.pcsd.data=this.pcsd.data(this.pcsda.chWindow, this.pcsda.tWindow, :);

			%Insertion 5
			this.pcsda=CSDAlignment;
			this.pcsda.expName='12mv1211';
			this.pcsda.testName='068';
			this.pcsda.chWindow=[3:16];
			this.pcsda.tWindow=490:580;
			this.pcsda.firstChannel=5;
			ret=this.pcsda;
			save('068.mat','ret');

			loader=CSDLoader;
			this.pcsd=loader.load('068');
			this.pcsd.data=this.pcsd.data(this.pcsda.chWindow, this.pcsda.tWindow, :);
		end

		% @param csd
		% 	CSD data to be aligned
		% @return
		% 	A CSDAlignment representing the alignment of the provided CSD data
		function ret=align(this,csd)
			%Initialize variables
			size1=size(this.pcsd.data);
			size2=size(csd.data);
			times=size2(2)-size1(2);
			channels=size2(1)-size1(1);
			trials=min(size1(3),size2(3));
			%Average over trials
			csd.data=mean(csd.data,3);

			%Prototypical CSD
			tempCsd1=mean(this.pcsd.data,3);
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
					tempCsd2=csd.data(chWindow,tWindow);
					tempCsd2=tempCsd2(:);

					%Compute correlation
					corrValues(ch,t)=this.computeCorrelation(tempCsd1,tempCsd2);

					%Check if it's a better match
					if (mean(corrValues(ch,t)) > mean(corrValues(bestCh,bestT)))
						bestCh=ch;
						bestT=t;
					end
				end
				toc
			end

			%Create alignment object to be returned
			ret=CSDAlignment;
			ret.chWindow=this.pcsda.chWindow-this.pcsda.chWindow-bestCh;
			ret.firstChannel=bestCh+(this.pcsda.firstChannel-this.pcsda.chWindow(1)); %TODO: Check math

			%Make pretties and save it to a file
			name=[this.pcsd.testName '-' csd.testName];
			fig=figure;
			set(fig,'Visible','off');
			imagesc(corrValues);
			title([name ' (' num2str(bestCh) ',' num2str(bestT) ', fc: ' num2str(ret.firstChannel) ', Insertion ' num2str(Const.INSERTION(this.expName, this.testName)) ')']); %TODO: Put this in the caption rather than the title
			xlabel('\Delta t (ms)');
			ylabel('\Delta channel');
			colorbar;
			saveas(fig,name,'png');
		end

		function ret=computeCorrelation(this,x,y)
			lx=length(x);
			ly=length(y);
			if (lx ~= ly)
				disp(['Error: test4.computeCorrelation(), x and y do not match in size. ' num2str(lx) ' ' num2str(ly)]);
				l=min(lx,ly);
				x=x(1:l);
				y=y(1:l);
			end
			ret=mean((x-mean(x)).*(y-mean(y)))/(std(x)*std(y));
		end
	end
end
