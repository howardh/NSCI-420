function ret=main()
	addpath(Const.SCRIPT_DIRECTORY);
	onCleanup(@() cd(Const.SCRIPT_DIRECTORY));

	%dir2 = [Const.RESULT_DIRECTORY pathname('test5', '12mv1211', 'Covariance')];
	%load([dir2 'results.mat']);
	%results('044')

	%x=test4;
	%x.testName='071';
	%x.stdViewer();
	%x.pcsdViewer();
	%x.testName='071';
	%x.alignmentViewer();

	run('test6');

	%createImages();

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
				elseif csd.isCSDMapping()
					%Create figure (CSD)
					h=figure;
					set(h,'Visible','off');
					imagesc(mean(csd.data,3), [-45 45]);
					title(['CSDMapping ' x{i}]);
					ylabel('Channels');
					xlabel('Time (ms)');
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
