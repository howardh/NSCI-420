classdef test6 < handle
	properties
		expName='12mv1211';

		figFormat='png';
	end
	methods
		%Runs everything
		function run(this)
			for en=1:length(Const.ALL_EXPERIMENTS)
				this.expName = Const.ALL_EXPERIMENTS{en};

				this.runOnce();
			end
		end

		function runOnce(this)
			[x,y]=this.generateDataSet(2,18,0); %Training set
			save('tsx.mat','x');
			save('tsy.mat','y');
			%load('tsx.mat');
			%load('tsy.mat');
			obj = ClassificationDiscriminant.fit(x,y);

			label = transpose(predict(obj,x));

			disp(['sum: ' num2str(sum(label))]);
			disp(['actual sum: ' num2str(sum(y))]);
			err=label-y;
			err=err.*err;
			disp(['Squared error: ' num2str(sum(err))]);
			disp(['Mean Squared error: ' num2str(sum(err)/length(err))]);
			x=(label==y & label==1);
			disp(['Correct positives: ' num2str(sum(x))]);
			x=(label==y & label==0);
			disp(['Correct negatives: ' num2str(sum(x))]);


			%for i=1:18
			%	for j=i+1:18
			%		h=figure;
			%		set(h,'Visible','off');
			%		gscatter(x(:,i),x(:,j),y,'rb','^o',[]);
			%		%gscatter(x(:,i),x(:,j),y);
			%		legend('non-prefered','prefered');
			%		dir=[Const.RESULT_DIRECTORY pathname(class(this), 'scatter plots')];
			%		mkdir(dir);
			%		saveas(h,[dir num2str(i) '-' num2str(j) '.' this.figFormat], this.figFormat);
			%	end
			%end

			[x,y]=this.generateDataSet(2,18,1); %Validation set
			save('vsx.mat','x');
			save('vsy.mat','y');
			%load('vsx.mat');
			%load('vsy.mat');
			label = transpose(predict(obj,x))

			disp(['sum: ' num2str(sum(label))]);
			disp(['actual sum: ' num2str(sum(y))]);
			err=label-y;
			err=err.*err;
			disp(['Squared error: ' num2str(sum(err))]);
			disp(['Mean Squared error: ' num2str(sum(err)/length(err))]);
			x=(label==y & label==1);
			disp(['Correct positives: ' num2str(sum(x))]);
			x=(label==y & label==0);
			disp(['Correct negatives: ' num2str(sum(x))]);
		end

		% @param above
		%		The number of channels to keep above the brain (Excluding first channel in the brain)
		%		If there isn't enough data, the matrix will be padded by NaN
		% @param total
		% 		Total number of channels to keep
		% @param fValidation
		%		Booleam value
		%		If true, creates the validation set. Otherwise, creates the training set.
		function [retX,retY]=generateDataSet(this, above, total, fValidation)
			%Default arguments
			if nargin == 1
				above=2;
				total=18;
			end

			tests = Const.ALL_TESTS(this.expName);

			loader=CSDLoader;

			retX = [];
			retY = [];
			for t=1:length(tests)
				csd=loader.load(tests{t});

				if ~csd.isGrating()
					continue;
				end

				%Cut out the window in time
				tWindow=1001:1200;
				csd.data = csd.avgConditions();
				csd.data = csd.data(:,tWindow,:,:);

				%Cut out the window in channels
				top=csd.alignment.firstChannel-above;
				if (top < 1)
					s=size(csd.data);
					cat(1,nan(1-top,s(2),s(3)),csd.data);
					top=1;
				end
				csd.data = csd.data(top:end,:,:,:);
				csd.data = csd.data(1:total,:,:,:);

				%Cut out the window in trials
				if (fValidation)
					csd.data = csd.data(:,:,[1 end],:); %Use the first and last trial for validation
				else
					csd.data = csd.data(:,:,2:end-1,:);
				end

				%Subdivide time into smaller chunks
				div=35; %parameter (Size of time subdivisions)
				inc=30;
				tWindow=[1:div];
				temp=[];
				while (tWindow(end) <= 200)
					temp = cat(1,temp,csd.data(:,tWindow,:,:));
					tWindow = tWindow + inc;
				end

				%Average over time
				temp=squeeze(mean(temp,2));

				s = size(temp) % channels x trials x 8

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
			end
			retX = transpose(retX);
		end
	end
end
