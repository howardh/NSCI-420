function ret=main()
	addpath '\\132.216.58.64\f\SummerStudents\Howard\Scripts';

	%convertAllData();

	x=test2;
	x.run;

	cd '\\132.216.58.64\f\SummerStudents\Howard\Scripts';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Data analysis

%TODO: Documentation
%Produces 8 images
%	x axis = orientation
%	y axis = channel
%Mean figure
%	x axis = orientation (each represents one of the 8 figures above, averaged across orientations)
%	y axis = channel
function ret=test1()
	cd([Const.RESULT_DIRECTORY 'test1']);

	%If we haven't already done the analysis, then do them
	if (~exist('ret.mat','file'))
		%Load the data
		loader=CSDLoader;
		csd=loader.load('065');
		%Analyze the data
		ret=CSDStatAnalysis(csd,10);
		save('ret.mat','ret');
	else
		load('ret.mat');
	end

	%Produce 8 figures, one for each orientation
	for x=1:8
		%Format the data for the figures
		output=mean(ret,4);
		output=squeeze(output(x,:,:,:));
		for i=1:length(output(:))
			if (output(i) ~= 1)
				output(i)=0;
			end
		end
		output=transpose(output);

		%Create and save the figures
		h=figure;
		set(h,'Visible','off');
		imagesc(output);
		title(['065\_' num2str(x)]);
		xlabel('Orientation');
		ylabel('Channel');
		colorbar;
		%saveas(h,[num2str(x) '.png'], 'png');
		saveas(h,[num2str(x) '.fig'], 'fig');
	end

	%Average over orientations
	output=mean(ret,2);
	output=mean(output,4);
	output=squeeze(output);
	h=figure;
	imagesc(transpose(output));
	title(['065 mean']);
	xlabel('Orientation');
	ylabel('Channel');
	colorbar;
	saveas(h,['mean.png'], 'png');
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

	x=test1;
	x.run;

	x=test2;
	x.run;
end
