%Aligns the CSD mapping data in the spatial dimension
classdef test4 < handle
	properties
		expName='12mv1211';
		testName='065';

		figFormat='png';

		pcsd; %Prototypical csd
		pcsda; %Prototypical csd alignment
		%Full field
		pcsdff;
		pcsdffa;
		%Checker
		pcsdc;
		pcsdca;

		%Flag (1 = use correlation, 0 = use covariance)
		useCorr=0;
	end
	methods
		%Runs everything
		function run(this)
			%Load prototypical CSD
			this.loadPrototype();
			%Use both correlation and covariance
			for uc=0:1
				this.useCorr=uc; %wtf, why can't I just loop using this instead of uc?

				%Every experiment
				for en=1:length(Const.ALL_EXPERIMENTS)
					this.expName = Const.ALL_EXPERIMENTS{en};
					testNames=Const.ALL_TESTS(this.expName);
					%Initialize results
					results=containers.Map;
					%Every test within that experiment
					for tn=1:length(testNames)
						this.testName = testNames{tn};
						ret=this.runOnce();
						%Store results
						if ~isempty(ret)
							id=[this.testName];
							results(id)=ret;
						end
					end
					dir=[Const.RESULT_DIRECTORY pathname(class(this), this.expName)];
					if uc==1
						dir=[dir pathname('Correlation')];
					else
						dir=[dir pathname('Covariance')];
					end
					save([dir 'results.mat'],'results');
				end

			end
		end

		function ret=runOnce(this)
			if (this.useCorr == 1)
				dir = [Const.RESULT_DIRECTORY pathname(class(this), this.expName, 'Correlation') ];
			else
				dir = [Const.RESULT_DIRECTORY pathname(class(this), this.expName, 'Covariance') ];
			end
			cdforce(dir);

			loader=CSDLoader;
			loader.expName=this.expName;
			csd=loader.load(this.testName);

			%Check if it's a CSDMapping run
			if csd.isCSDMapping()
				if (csd.isFullField())
					this.pcsd=this.pcsdff;
					this.pcsda=this.pcsdffa;
				else
					this.pcsd=this.pcsdc;
					this.pcsda=this.pcsdca;
				end
				csd.data=(csd.data(:,1:500,:,:)+csd.data(:,501:1000,:,:)+csd.data(:,1001:1500,:,:)+csd.data(:,1501:2000,:,:))/4;
				ret=this.align(csd);
				return;
			end
			ret=[];
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

			%Full field, Insertion 5
			disp('Loading full field prototypical CSD');
			this.pcsdffa=CSDAlignment;
			this.pcsdffa.expName='12mv1211';
			this.pcsdffa.testName='068';
			this.pcsdffa.chWindow=[3:16];
			this.pcsdffa.tWindow=490:580;
			this.pcsdffa.firstChannel=5;
			ret=this.pcsdffa;
			save('068.mat','ret');

			loader=CSDLoader;
			this.pcsdff=loader.load('068');
			this.pcsdff.data=this.pcsdff.data(this.pcsdffa.chWindow, this.pcsdffa.tWindow, :);

			%Checkers, Insertion 5
			disp('Loading checkered prototypical CSD');
			this.pcsdca=CSDAlignment;
			this.pcsdca.expName='12mv1211';
			this.pcsdca.testName='067';
			this.pcsdca.chWindow=[3:16];
			this.pcsdca.tWindow=495:570;
			this.pcsdca.firstChannel=5;
			ret=this.pcsdca;
			save('067.mat','ret');

			loader=CSDLoader;
			this.pcsdc=loader.load('067');
			this.pcsdc.data=this.pcsdc.data(this.pcsdca.chWindow, this.pcsdca.tWindow, :);
		end

		% Aligns the csd and creates a figure showing the correlations.
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
			ret.expName=this.expName;
			ret.testName=this.testName;
			ret.insertion=Const.INSERTION(this.expName,this.testName);
			ret.chWindow=this.pcsda.chWindow-this.pcsda.chWindow(1)+bestCh;
			ret.tWindow=this.pcsda.tWindow-this.pcsda.tWindow(1)+bestT;
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

		%Note: Doesn't necessarily compute the correlation
		%TODO: Find a better name for this method
		function ret=computeCorrelation(this,x,y)
			lx=length(x);
			ly=length(y);
			if (lx ~= ly)
				disp(['Error: test4.computeCorrelation(), x and y do not match in size. ' num2str(lx) ' ' num2str(ly)]);
				l=min(lx,ly);
				x=x(1:l);
				y=y(1:l);
			end
			if (this.useCorr==1)
				%Correlation
				ret=mean((x-mean(x)).*(y-mean(y)))/(std(x)*std(y));
			else
				%Covariance
				ret=mean((x-mean(x)).*(y-mean(y)));
			end
		end
	end
end
