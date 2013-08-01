classdef test6 < handle
	properties
		expName='12mv1211';
		testName='065';

		figFormat='png';
	end
	methods
		%Runs everything
		function run(this)
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

			%Generate data
			channels = [-3:-1 1:20];
			[xAll,yAll]=this.generateDataSet(channels,0); %Entire data set

			%Computations (Genetic algorithm)
			indAll = [1:length(channels)];

			popSize = 15;
			mutationChance = 1;
			crossOverChance = 1;
			pop={}; %pop{:,1} = gene, pop{:,2} = fitness (smaller = better)

			%Initialize population
			for i=1:popSize
				temp = rand(1,length(indAll));
				temp(temp < 0.5) = 0;
				temp(temp ~= 0) = 1;
				pop{i,1} = temp;

				%Get channels
				indices = indAll.*pop{i,1};
				indices(indices==0)=[];

				%Compute fitness
				pop{i,2} = this.crossValidate(xAll(:,indices), yAll);
			end

			%Run GA
			while 1
				%Sort population based on fitness
				[Y,I] = sort(cell2mat(pop(:,2)));
				pop = pop(I,:);

				%Remove duplicates
				pop=this.removeDup(pop);

				%Cut down population
				m=min(length(pop),popSize);
				pop = pop(1:m, :);

				%Display results so far
				pop
				for i=1:3
					indices = indAll.*pop{i,1};
					indices(indices==0)=[];
					channels(indices)
				end

				%Mutation
				disp('Mutations');
				%for i = 1:length(pop)
				i=0;
				while i<length(pop)
					i=i+1;

					%Am I radioactive?
					if (rand() > mutationChance*(1-i/length(pop)))
						continue;
					end

					%Find a point of mutation
					pom = ceil(rand() * length(indAll));

					%Create a new mutated dude
					temp = pop{i,1};
					temp(pom) = xor(temp(pom),1);
					pop{length(pop)+1,1} = temp;

					%Compute fitness
					indices = indAll.*pop{end,1};
					indices(indices==0)=[];
					pop{end,2} = this.crossValidate(xAll(:,indices), yAll);
				end

				%Cross over
				disp('Cross Overs');
				%for i = 1:length(pop)
				i=0;
				while i<length(pop)
					i=i+1;

					%Sex? Y/N (More likely to breed if fitter)
					if (rand() > crossOverChance*(1-i/length(pop)))
						continue;
					end

					%Find a mate (not myself)
					j=i;
					while j==i
						j = ceil(rand()*length(pop));
					end

					%Find a point of cross over (Cut after poc)
					poc = ceil(rand() * (length(indAll)-1));

					%Make babies
					tempi = pop{i,1};
					tempj = pop{j,1};
					temp = [tempi(1:poc) tempj((poc+1):end)];
					pop{length(pop)+1,1} = temp;

					%Compute fitness
					indices = indAll.*pop{end,1};
					indices(indices==0)=[];
					pop{end,2} = this.crossValidate(xAll(:,indices), yAll);
				end
			end
			save([this.testName '.mat'], 'err');
		end

		function ret=removeDup(this, pop)
			dup = zeros(1,length(pop));
			for i=1:length(pop)
				if dup(i)
					continue;
				end

				for j=i+1:length(pop)
					if (isequal(pop{i,1},pop{j,1}))
						dup(j) = 1;
					end
				end
			end
			ind = (1:length(pop)).*xor(dup,1);
			ind(ind == 0) = [];
			ret=pop(ind,:);
		end

		function totalError = crossValidate(this, xAll, yAll)
			totalError=0;
			
			%For each validation set/point
			for vsInd = 1:length(yAll)
				%Training set
				tsInd = 1:length(yAll); %Training set indices
				tsInd(ismember(tsInd,vsInd)) = []; %Everything but validation set indices

				%Train
				x=xAll(tsInd,:);
				y=yAll(tsInd);
				obj = ClassificationDiscriminant.fit(x,y);

				%Validate
				x=xAll(vsInd,:);
				y=yAll(vsInd);
				label = transpose(predict(obj,x));
				
				%Display results
				%disp(['sum: ' num2str(sum(label))]);
				%disp(['actual sum: ' num2str(sum(y))]);
				err=label-y;
				err=err.*err;
				%disp(['Squared error: ' num2str(sum(err))]);
				%disp(['Mean Squared error: ' num2str(sum(err)/length(err))]);
				totalError = totalError + sum(err)/length(err);
				x=(label==y & label==1);
				%disp(['Correct positives: ' num2str(sum(x))]);
				x=(label==y & label==0);
				%disp(['Correct negatives: ' num2str(sum(x))]);
			end
			totalError = totalError/length(yAll);
			disp(['Total error: ' num2str(totalError)]);

			%save('obj.mat','obj');
		end

		% @param channels
		%		Channels to use, relative to the surface of the brain (surface is 0 and does not represent a channel)
		%		If there isn't enough data, the matrix will be padded by NaN
		% @param fValidation
		%		Booleam value
		%		If true, creates the validation set. Otherwise, creates the training set.
		function [retX,retY]=generateDataSet(this, channels, fValidation)
			%Default arguments
			if nargin == 1
				channels = [-2 -1 1:16];
			end

			%Just to make computations easier
			channels(channels < 0) = channels(channels < 0) + 1;
			channels = channels-1;

			tests = Const.ALL_TESTS(this.expName);
			%tests = {'all'};

			loader=CSDLoader;
			loader.expName = this.expName;

			retX = [];
			retY = [];
			%for t=1:length(tests)
				%csd=loader.load(tests{t});
				csd=loader.load(this.testName);

				if ~csd.isGrating()
					disp(['Error: test6.generateDataSet(), Not a grating stimulus']);
					retX=[];
					retY=[];
					return;
				end

				%Cut out the window in time
				tWindow=1000+40:1200-120;
				csd.data = csd.avgConditions();
				csd.data = csd.data(:,tWindow,:,:);

				%Cut out the window in channels
				ch = channels + csd.alignment.firstChannel;
				top=min(ch);
				if (top < 1)
					s=size(csd.data);
					cat(1,nan(1-top,s(2),s(3),s(4)),csd.data);
					ch = ch - top + 1;
				end
				csd.data = csd.data(ch,:,:,:);

				%Subdivide time into smaller chunks
				limit=length(tWindow);
				div=length(tWindow); %parameter (Size of time subdivisions)
				inc=div;
				tWindow=[1:div];
				temp=[];
				while (tWindow(end) <= limit)
					temp = cat(1,temp,csd.data(:,tWindow,:,:));
					tWindow = tWindow + inc;
				end

				%Average over time
				temp=squeeze(mean(temp,2));

				s = size(temp); % channels x trials x 8

				po = csd.getPrefOrientation();	%Prefered orientation
				npo = mod(po+4-1,8)+1;			%Non-prefered orientation
				for trial=1:s(2)
					for cond=[po npo]
						%tempX = squeeze(csd.data(:,trial,cond));
						tempX = squeeze(temp(:,trial,cond));
						tempY = (cond == po);

						retX = cat(2,retX, tempX);
						retY = [retY tempY];
					end
				end
			%end
			retX = transpose(retX);
		end

		% Computes separability, Fisher score, weights, and creates a figure for them
		function analyze(this)
			dir = [Const.RESULT_DIRECTORY pathname(class(this), this.expName) ];
			cdforce(dir);

			channelsAbove = 3;
			totalChannels = 19;
			%[xAll,yAll]=this.generateDataSet(channelsAbove,totalChannels,0);
			[xAll,yAll]=this.generateDataSet([-channelsAbove:-1 1:(totalChannels-channelsAbove)],0);
			%xAll = [4 1; 2 4; 2 3; 3 6; 4 4; ...
			%		9 10; 6 8; 9 5; 8 7; 10 8];
			%yAll = [0 0 0 0 0 1 1 1 1 1];
			%xAll = [1 2 3; 2 3 4; 3 4 5; 8 9 10; 9 10 11; 5 6 7; 4 5 6; 6 7 8; 7 8 9; 10 11 12];
			%xAll = xAll + (rand(size(xAll))-0.5)/100
			%yAll = [0 0 0 1 1 0 0 1 1 1];

			size(xAll)
			size(yAll)

			x0=[];
			x1=[];

			for i=1:length(yAll)
				if (yAll(i) == 0)
					x0 = cat(1,x0,xAll(i,:));
				else
					x1 = cat(1,x1,xAll(i,:));
				end
			end

			mu0=mean(x0,1);
			mu1=mean(x1,1);
			muAll=mean(xAll,1);

			var0=var(x0,1);
			var1=var(x1,1);
			varAll=var(xAll,1); %Total variance
			varB = length(x0)*(mu0-muAll).^2+length(x1)*(mu1-muAll).^2; %Between group variance
			varW = var0+var1; %Within group variance
			var0'
			var1'
			varAll'
			(varB+varW)'
			(varAll-varW)'

			cov0 = (cov(x0));
			cov1 = (cov(x1));
			covAll = (cov(xAll));

			s0=0;
			for i=1:length(x0)
				s0 = s0 + (x0(i,:)-mu0)'*(x0(i,:)-mu0);
			end
			%s0

			s1=0;
			for i=1:length(x1)
				s1 = s1 + (x1(i,:)-mu1)'*(x1(i,:)-mu1);
			end
			%s1

			sw = s0+s1; %Within class scatter matrix

			w = inv(sw)*(mu0-mu1)';
			w = inv(cov0+cov1)*(mu1-mu0)';

			%s = ((w*(mu1-mu0))^2)/(w'*(cov0+cov1)*w)
			%s = (dot(w,(mu1-mu0)')^2)/(w'*(cov0+cov1)*w)
			s1 = ((w.*(mu1-mu0)').^2)/(w'*(cov0+cov1)*w);
			s = varB./varW;
			s1./s';

			c = w'*(mu0+mu1)'/2;

			fisherScore = (mu0-mu1).^2./(var0+var1);

			%Display results
			ch=[-channelsAbove:-1 1:(totalChannels-channelsAbove)]';
			for i=1:length(w)
				disp(['Channel ' num2str(ch(i)) ':  ' 9 num2str(w(i), '%+1.3e')  9 ' fs ' num2str(fisherScore(i), '%+1.3e')]);
			end

			%Output sorted results
			fisherScore = [ch s1 fisherScore' w];

			disp('Sorted by separation');
			[Y,I] = sort(fisherScore(:,2));
			fisherScore(I,:)
			disp('Sorted by Fisher score');
			[Y,I] = sort(fisherScore(:,3));
			fisherScore(I,:)
			disp('Sorted by weight');
			[Y,I] = sort(abs(fisherScore(:,4)));
			fisherScore(I,:)

			%Plot results
			h = figure;
			set(h, 'position', [0 0 900 500]);
			set(h,'Visible','off');

			hs=subplot(1,3,1);
			barh(fisherScore(:,1),log(fisherScore(:,2)/min(fisherScore(:,2))));
			set(hs, 'YDir', 'reverse');
			title({'Separation', '(divided by min, log transformed)'});
			ylabel('Channel (relative to surface)');

			hs=subplot(1,3,2);
			barh(fisherScore(:,1),fisherScore(:,3));
			set(hs, 'YDir', 'reverse');
			title('Fisher Score');

			hs=subplot(1,3,3);
			barh(fisherScore(:,1),fisherScore(:,4));
			hold on;
			hb=barh(fisherScore(:,1),-fisherScore(:,4));
			set(hs, 'YDir', 'reverse');
			set(hb, 'facecolor', [1 1 1]);
			set(hb, 'edgecolor', [1 1 1]*0.75);
			title('Weight');

			%pwd
			saveas(h,['fisher' '.' this.figFormat], this.figFormat);
		end

	end

	methods (access = private)
	end
end
