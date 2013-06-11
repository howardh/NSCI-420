function ret=main()
	addpath '\\132.216.58.64\f\SummerStudents\Howard\Scripts';

	%convertAllData();

	%createImages();

	%clr('test2');
	%run('test2');
	%run('test3');
	run('test4');

	%runAll();

	cd '\\132.216.58.64\f\SummerStudents\Howard\Scripts';
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
			disp(['Creating tuning curve ' x{i}]);
			try
				csd=loader.load(x{i});
				if csd.isGrating()
					%Create figure (Tuning curve)
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
					imagesc(output);
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
					imagesc(csd.data);
					ylabel('Channels');
					xlabel('Time (ms)');
					colorbar;
					%Save figure
					path=[Const.RESULT_DIRECTORY pathname('CSD Mapping', expName)];
					mkdir(path);
					saveas(h, [path x{i} '.fig'], 'fig');
					saveas(h, [path x{i} '.png'], 'png');
				else
					disp('Not grating. Skipping.');
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
%	Alignment (Incomplete)

function ret=bar()
    data={'143', '145'};

    loader=CSDLoader;

    ret=containers.Map;
    name='name';
    for i=1:length(data)
        csdi=loader.load(data{i});
        for j=i+1:length(data)
            csdj=loader.load(data{j});
            ret(name)=CSDMappingAligner(csdi,csdj,name);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do everything
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ret=runAll()
	convertAllData();
	createImages();
	run('test1');
	run('test2');
end
