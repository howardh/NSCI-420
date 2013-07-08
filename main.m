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

	run('test5');
	%ret = ClassificationDiscriminant.fit(rand(10,20),[zeros(1,7) ones(1,3)])
	%load('tsx.mat');
	%load('tsy.mat');
	%y = transpose(y);

	%gscatter(x(:,13),x(:,17),y);
	%legend('non-prefered','prefered');

	%obj = ClassificationDiscriminant.fit(x,y);
	%%load('vsx.mat');
	%%load('vsy.mat');
	%[label,score,cost] = predict(obj,x);
	%cost
	%size(y)
	%size(label)

	%Meeting 2013.06.27
	%x=test4
	%x.testName='071';
	%x.stdViewer()
	%x.pcsdViewer();
	%x.alignmentViewer();

	%loader=CSDLoader;
	%csd1=loader.load('077');
	%csd2=loader.load('082');
	%combineCSD(csd1,csd2);

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

					%Create figure (CSD)
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
