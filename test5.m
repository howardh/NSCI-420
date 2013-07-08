classdef test5 < handle
	properties
		expName='12mv1211';
		insertion=1;

		alignmentData;

		figFormat='png';
	end
	methods
		%Runs everything
		function run(this)
			%Every experiment
			for en=1:length(Const.ALL_EXPERIMENTS)
				this.expName = Const.ALL_EXPERIMENTS{en};
				insertions = Const.ALL_INSERTIONS(this.expName);
				%Load alignment data for this experiment
				this.loadData();
				%Initialize results
				results=containers.Map;
				%Every insertion within that experiment
				for ins=1:length(insertions)
					this.insertion = insertions(ins);
					%Run
					ret=this.runOnce();
					%Store results
					if ~isempty(ret)
						for i=1:length(ret)
							results(ret(i).testName) = ret(i);
						end
					end
				end
				dir=[Const.RESULT_DIRECTORY pathname(class(this), this.expName, 'Covariance')];
				cdforce(dir);
				save(['results.mat'],'results');
			end
		end

		function ret=runOnce(this)
			dir=[Const.RESULT_DIRECTORY pathname(class(this), this.expName)];
			cdforce(dir);
			tests = Const.TESTS_IN_INSERTION(this.expName, this.insertion);

			t=[]; %Tests for which we have the first channel
			ch=[]; %First channels for the tests in t
			t2=[]; %All channels for which we need values
			ch2=[]; %Will contain the interpolated values
			tG=[]; %Grating tests (used for plotting)
			chG=[]; %Grating first channels (Used for plotting)
			tC=[]; %Checkerboard tests (used for plotting)
			chC=[]; %Checkerboard first channels (Used for plotting)
			tF=[]; %Fullfield tests (used for plotting)
			chF=[]; %Fullfield first channels (Used for plotting)
			for i=1:length(tests)
				if this.alignmentData.isKey(tests{i})
					t = [t str2num(tests{i})];
					ch = [ch this.alignmentData(tests{i}).firstChannel];
				else
					tG = [tG str2num(tests{i})];
				end
				t2 = [t2 str2num(tests{i})];
			end

			%Compute missing values
			ch2=interp1(t,ch,t2,'linear');
			ch2=round(ch2);

			%Extract the values we need to be returned
			ret=[];
			i=1;
			i2=1;
			while (1)
				if (i2 > length(t2))
					break;
				end

				if (t(i) == t2(i2))
					%This test was not interpolated
					i=i+1;
					i2=i2+1;
				else
					%t2(i2) was interpolated
					ret=[ret CSDAlignment];
					ret(end).expName = this.expName;
					ret(end).testName = num2testname(t2(i2));
					ret(end).insertion = this.insertion;
					ret(end).firstChannel = ch2(i2);
					%Next test
					i2=i2+1;
				end
			end

			%Make pretties and save them
			h=figure;
			set(h,'Visible','off');
			subplot(2,1,1); 
			plot(t,ch,'-s');
			title('Before Interpolation (CSDMapping only)');
			xlabel('Test Name');
			ylabel('First Channel');
			subplot(2,1,2); 
			plot(t2,ch2,'-');
			hold on;
			plot(t,ch,'s');
			title('After Interpolation (CSDMapping + Gratings)');
			xlabel('Test Name');
			ylabel('First Channel');
			saveas(h,['Insertion ' num2str(this.insertion) '.' this.figFormat],this.figFormat);
		end

		function clear(this)
			dir = [Const.RESULT_DIRECTORY pathname(class(this)) ];
			rmdir(dir,'s');
		end
	end
	methods (Access = private)
		function loadData(this)
			dir=[Const.RESULT_DIRECTORY pathname('test4', this.expName, 'Covariance')];

			load([dir 'results.mat']);

			this.alignmentData = results;
		end

		function ret=align(this,csd)
		end
	end
end
