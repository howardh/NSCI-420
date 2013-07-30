classdef test8 < handle
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

				testNames=Const.ALL_TESTS(this.expName);

				%Every test within that experiment
				csdAll=[];
				for tn=1:length(testNames)
					this.testName = testNames{tn};
					csdAll=this.runOnce(csdAll);
				end

				size(csdAll.data)
				csdAll.testName = 'all';
				csdAll.save();
			end
		end

		% @param csdAll
		%	CSD of all well tuned tests so far
		% @return
		%	csdAll + this test if it is well tuned
		function csdAll=runOnce(this, csdAll)
			dir = [Const.RESULT_DIRECTORY pathname(class(this), this.expName) ];
			cdforce(dir);

			loader = CSDLoader;
			loader.expName = this.expName;
			csd = loader.load(this.testName);

			if (~csd.isGrating())
				disp(['Test ' this.testName ' not grating. Skipping.']);
				return;
			end

			this.viewCircVar(csd);
			if this.evaluateTuningCurve(csd)
				disp(['Good']);
				%csd.data = csd.avgConditions();

				if isempty(csdAll)
					csdAll = csd;
					return;
				end

				csdAll = combineCSD(csdAll, csd);
				size(csdAll.data)
				return;
			end
			disp(['Rejected']);
		end

		% @return
		%	true (1)  - if the CSD is well tuned (tuning curve is good)
		%	false (0) - if it is not well tuned
		function ret=evaluateTuningCurve(this,csd)
			%tc = csd.tuningCurve;
			%tc = (tc(:,1:8)+tc(:,9:16))/2;
			%tc = mean(tc,1);

			%pref = csd.getPrefOrientation() + 8;

			%tc = [tc tc tc];

			%%Defaults to a good tuning curve
			%ret = 1;

			%%Find aspects of the curve that make it not well tuned
			%x1=tc(pref-1)/tc(pref);
			%x2=tc(pref+1)/tc(pref);
			%if (x1 > .9 | x2 > .9) %Must decrease enough on both sides of the peak
			%	ret = 0;
			%end
			%x1=tc(pref-3)/tc(pref-2);
			%x2=tc(pref+4)/tc(pref+3);
			%if (x1 > 1.1 | x2 > 1.1) %Non-prefered orientation should be the min, or almost the min
			%	ret = 0;
			%end

			%%Full width at half max
			%width=0;
			%left=pref;
			%right=pref;
			%halfMax = (max(tc)+min(tc))/2;
			%while (tc(left) > halfMax)
			%	left = left-1;
			%end
			%left = left + (halfMax-tc(left))/(tc(left+1)-tc(left));
			%while (tc(right) > halfMax)
			%	right = right+1;
			%end
			%right = right + (halfMax-tc(right))/(tc(right-1)-tc(right));
			%width = right-left; %TODO: What do I do with this now?

			%%Make pretties
			%h = figure;
			%set(h,'Visible','off');
			%plot(1:length(tc), tc);
			%title(['Width: ' num2str(width)]);
			%saveas(h,['p' this.testName '.' this.figFormat], this.figFormat);
			%close(h);

			tc = csd.tuningCurve;
			tc = (tc(:,1:8)+tc(:,9:16))/2;

			v = this.circularVariance(tc,1);

			avg1 = mean(v([csd.alignment.layerII csd.alignment.layerIV]));
			avg2 = mean(v(csd.alignment.layerIV));
			avg3 = mean(v(~isnan(v)));
			if (avg3-avg1 > 0.05 | avg3-avg2 > 0.05)
				ret=1;
			else
				ret=0;
			end
		end

		function viewCircVar(this,csd)
			tc = csd.tuningCurve;
			tc = (tc(:,1:8)+tc(:,9:16))/2;

			v = this.circularVariance(tc,0);
			h = figure('Position', [0 100 200 300]);
			set(h,'Visible','off');
			imagesc(v,[0 1]);
			showLayers(csd);
			title('Spikes 0');
			colorbar;
			close(h);

			v = this.circularVariance(tc,1);
			avg1 = mean(v([csd.alignment.layerII csd.alignment.layerIV]));
			avg2 = mean(v(csd.alignment.layerIV));
			avg3 = mean(v(~isnan(v)));
			h = figure('Position', [200 100 200 300]);
			set(h,'Visible','off');
			imagesc(v);
			showLayers(csd);
			title([this.testName ' - Spikes 1, Mean: ' num2str(avg1) ', ' num2str(avg2) ', ' num2str(avg3)]);
			colorbar;
			saveas(h,[this.testName '.' this.figFormat], this.figFormat);
			close(h);

			%data = squeeze(mean(mean(csd.data(:,1000:1200,:,:),2),3));
			%data = (data(:,1:8)+data(:,9:16))/2;

			%v = this.circularVariance(data,0);
			%figure('Position', [400 100 200 300]);
			%imagesc(v);
			%title('CSD 0');
			%v = this.circularVariance(data,1);
			%figure('Position', [600 100 200 300]);
			%imagesc(v);
			%title('CSD 1');
		end

		function ret=circularVariance(this,data,fMean)
			channels=32;
			conditions=8;

			ret=zeros(channels,1);
			for ch=1:channels
				num=0;
				denom=0;
				for cond=1:conditions
					num = num + data(ch,cond)*exp(i*2*cond*pi/8);
					denom = denom + data(ch,cond);
				end
				if (fMean)
					ret(ch) = num/denom;
				else
					ret(ch) = num;
				end
			end
			if (fMean)
				ret = 1-abs(ret);
			else
				ret = abs(ret);
			end
		end
	end
end
