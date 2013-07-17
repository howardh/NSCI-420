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
			%[xAll,yAll]=this.generateDataSet(3,12,0); %Entire data set
			[xAll,yAll]=this.generateDataSet(7,30,0); %Entire data set

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
				disp(['sum: ' num2str(sum(label))]);
				disp(['actual sum: ' num2str(sum(y))]);
				err=label-y;
				err=err.*err;
				disp(['Squared error: ' num2str(sum(err))]);
				disp(['Mean Squared error: ' num2str(sum(err)/length(err))]);
				totalError = totalError + sum(err)/length(err);
				x=(label==y & label==1);
				disp(['Correct positives: ' num2str(sum(x))]);
				x=(label==y & label==0);
				disp(['Correct negatives: ' num2str(sum(x))]);
			end
			totalError = totalError/length(yAll);
			disp(['Total error: ' num2str(totalError)]);

			save('obj.mat','obj');
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
				tWindow=1000+40:1200-120;
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
				%if (fValidation)
				%	csd.data = csd.data(:,:,[1 end],:); %Use the first and last trial for validation
				%else
				%	csd.data = csd.data(:,:,2:end-1,:);
				%end

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
			end
			retX = transpose(retX);
		end

		function analyze(this)
			[xAll,yAll]=this.generateDataSet(3,19,0); %Entire data set
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

			cov0 = (cov(x0));
			cov1 = (cov(x1));
			covAll = (cov(xAll));

			w = inv(covAll)*(mu1-mu0)';

			c = w*(mu0+mu1)/2;

			%Display results
			ch = [-3:-1 1:19-3];
			for i=1:length(w)
				disp(['Channel ' num2str(ch(i)) ':  ' 9 num2str(w(i))]);
			end

			w = inv(cov0+cov1)*(mu1-mu0)';
			s1 = (w*(mu1-mu0))^2;
			s2 = w' * (cov0+cov1) * w;
			s1/s2
		end

		% @return
		%	true (1)  - if the CSD is well tuned (tuning curve is good)
		%	false (0) - if it is not well tuned
		function ret=evaluateTuningCurve(this,csd)
			tc = csd.tuningCurve;
			tc = (tc(:,1:8)+tc(:,9:16))/2;
			tc = mean(tc,1);

			pref = csd.getPrefOrientation() + 8;

			tc = [tc tc tc];

			%Defaults to a good tuning curve
			ret = 1;

			%Find aspects of the curve that make it not well tuned
			x1=tc(pref-1)/tc(pref);
			x2=tc(pref+1)/tc(pref);
			if (x1 > .9 | x2 > .9) %Must decrease enough on both sides of the peak
				ret = 0;
			end
			x1=tc(pref-3)/tc(pref-2);
			x2=tc(pref+4)/tc(pref+3);
			if (x1 > 1.1 | x2 > 1.1) %Non-prefered orientation should be the min, or almost the min
				ret = 0;
			end

			%Make pretties
			figure;
			plot(1:length(tc), tc);
		end
	end

	methods (access = private)
	end
end
