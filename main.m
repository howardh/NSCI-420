function ret=main()
	addpath '\\132.216.58.64\f\SummerStudents\Howard\Scripts';

	%convertAllData();

	run('test2');
	%x=test2;
	%x.run;

	cd '\\132.216.58.64\f\SummerStudents\Howard\Scripts';
end

function ret=run(scriptName)
	x=eval([scriptName]);
	x.run();
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Data conversion (To my own format)

function convertAllData()
	for e=1:length(Const.ALL_EXPERIMENTS);
		expName=Const.ALL_EXPERIMENTS{e};
		x=Const.ALL_TESTS(expName);
		for i=3:length(x)
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
