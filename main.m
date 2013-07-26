function ret=main()
	addpath(Const.SCRIPT_DIRECTORY);
	onCleanup(@() cd(Const.SCRIPT_DIRECTORY));

	%Meeting 2013-07-25

	%%Circular variance
	%loader=CSDLoader;
	%csd=loader.load('065');
	%x=test6;
	%x.viewCirvVar(csd);

	%%Fisher information
	%x=test6;
	%x.analyze();

	%%Mutual information
	%run('test7');

	%Grating tests: 44,48,58,65,73,77,82,85,95,104,121,137,145
	%loader=CSDLoader;
	%csd=loader.load('065');
	%x=test6;
	%x.analyze();
	%x.evaluateTuningCurve(csd);
	%ret=x.circularVariance(csd);
	%x.viewCirvVar(csd);

	run('test7');
	%run('test8');

	%runAll();
end

function ret=run(scriptName)
	x=eval([scriptName]);
	x.run();
end

function ret=clr(scriptName)
	x=eval([scriptName]);
	x.clear();
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Data to images

function createImages()
	figFormat='png';
	loader=CSDLoader;
	for e=1:length(Const.ALL_EXPERIMENTS);
		expName=Const.ALL_EXPERIMENTS{e};
		x=Const.ALL_TESTS(expName);
		loader.expName=expName;
		for i=1:length(x)
			try
				csd=loader.load(x{i});
				if csd.isGrating()
					%Create figure (Tuning curve)
					disp(['Creating tuning curve ' x{i}]);
					h=figure;
					set(h,'Visible','off');
					imagesc(csd.tuningCurve);
					zlabel('Spike Rate in spikes/sec');
					ylabel('Channels');
					xlabel('Condition');
					title(['Tuning Curve (Prefered orientation: ' num2str(csd.getPrefOrientation()) ')']);
					hold on;
					showLayers(csd);
					colorbar;
					%Save figure
					path=[Const.RESULT_DIRECTORY pathname('Tuning Curves', expName)];
					mkdir(path);
					saveas(h, [path x{i} '.' figFormat], figFormat);

					%Create figure (CSD average)
					h=figure;
					set(h,'Visible','off');
					output=mean(mean(csd.data(:,[1000:1200],:,:),3),4);
					imagesc(output, [-45 45]);
					ylabel('Channels');
					xlabel('Time (ms)');
					hold on;
					showLayers(csd);
					colorbar;
					%Save figure
					path=[Const.RESULT_DIRECTORY pathname('Grating CSD', expName)];
					mkdir(path);
					saveas(h, [path x{i} '.' figFormat], figFormat);

					%Create figure (CSD per condition)
					csd.data = csd.avgConditions();
					for cond=1:8
						h=figure;
						set(h,'Visible','off');
						output=mean(csd.data(:,[1000:1200],:,cond),3);
						imagesc(output, [-45 45]);
						ylabel('Channels');
						xlabel('Time (ms)');
						colorbar;
						%Save figure
						path=[Const.RESULT_DIRECTORY pathname('Grating CSD', expName)];
						mkdir(path);
						saveas(h, [path x{i} '-cond' num2str(cond) '.' figFormat], figFormat);
					end

					%Create a figure comparing a single channel over all 8 orientations
					for ch=1:32
						h=figure;
						set(h,'Visible','off');

						subplot(2,1,1); 
						output=squeeze(mean(csd.data(ch,[1000:1200],:,:),3))';
						imagesc(output, [-45 45]);
						ylabel('Conditions');
						xlabel('Time (ms)');
						title([num2str(ch-csd.alignment.firstChannel)]);
						colorbar;

						subplot(2,1,2); 
						output=squeeze(mean(output,2));
						plot(1:length(output),output);
						ylabel('CSD');
						xlabel('Condition');

						%Save figure
						path=[Const.RESULT_DIRECTORY pathname('Grating CSD', expName)];
						mkdir(path);
						saveas(h, [path x{i} '-ch' num2str(ch) '.' figFormat], figFormat);
					end
				elseif csd.isCSDMapping()
					%Create figure (CSD)
					h=figure;
					set(h,'Visible','off');
					imagesc(mean(csd.data,3), [-45 45]);
					title(['CSDMapping ' x{i}]);
					ylabel('Channels');
					xlabel('Time (ms)');
					hold on;
					showLayers(csd);
					colorbar;
					%Save figure
					path=[Const.RESULT_DIRECTORY pathname('CSD Mapping', expName)];
					mkdir(path);
					saveas(h, [path x{i} '.' figFormat], figFormat);
				else
					disp('Not grating or CSDMapping. Skipping.');
				end
			catch exception
				disp(' some error occurred');
				disp(getReport(exception));
				%Meh. No biggie.
			end
		end
	end
end

function showLayers(csd)
	x = repmat([-10 2010], 6, 1);
	csd.alignment
	y = [csd.alignment.layerI(1) csd.alignment.layerI(1); ...
	 	csd.alignment.layerII(1) csd.alignment.layerII(1); ...
		csd.alignment.layerIV(1) csd.alignment.layerIV(1); ...
		csd.alignment.layerV(1) csd.alignment.layerV(1); ...
		csd.alignment.layerVI(1) csd.alignment.layerVI(1); ...
		csd.alignment.layerVI(end)+1 csd.alignment.layerVI(end)+1]-0.5;
	for i=1:6
		line(x(i,:), y(i,:), ...
					'LineStyle', '--', ...
					'LineWidth', 2, ...
					'Color', [0 0 0]);
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Data conversion (To my own format)

function convertAllData()
	for e=1:length(Const.ALL_EXPERIMENTS);
		expName=Const.ALL_EXPERIMENTS{e};
		x=Const.ALL_TESTS(expName);
		for i=1:length(x)
			disp(['Converting test ' x{i}]);
			try
				convertData(expName,x{i});
			catch exception
				disp(' some error occurred');
				disp(getReport(exception));
				%Meh. No biggie.
			end
		end
	end
end

function ret=convertData(experiment, testName)
	loader=CSDLoader;
	loader.expName=experiment;
	csd=loader.load(testName);
	csd.save();
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do everything
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ret=runAll()
	convertAllData();
	createImages();
	run('test1');
	run('test2');
	run('test3');
	run('test4');
	run('test5');
end
