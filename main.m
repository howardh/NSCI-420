function ret=main()
	addpath '\\132.216.58.64\f\SummerStudents\Howard\Scripts';

	%convertAllData();

	createTuningCurveImages();

	%run('test2');

	cd '\\132.216.58.64\f\SummerStudents\Howard\Scripts';
end

function ret=run(scriptName)
	x=eval([scriptName]);
	x.run();
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Data to images

function createTuningCurveImages()
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
					h=figure;
					imagesc(tuningCurve);
					zlabel('Spike Rate in spikes/sec')
					ylabel('Channels')
					xlabel('Condition')
					colorbar;
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

function createGratingCSDImages()
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
            ret(name)=CSDMappingAligner2(csdi,csdj,name);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do everything
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ret=runAll()
	convertAllData();
	run('test1');
	run('test2');
end
