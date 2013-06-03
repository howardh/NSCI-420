function ret=main()
	addpath '\\132.216.58.64\f\SummerStudents\Howard\Scripts';

	%loader=CSDLoader;
	%csd=loader.load('065');
	%csd.data=csd.trim();
	%csd.data=csd.mergeConditions();
	%dist1=csd.data(4,1:20,:,2);
	%dist2=csd.data(4,1:20,:,6);

	%scatter(dist1(:),zeros(1,length(dist1(:))));

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
	x=ls('\\132.216.58.64\f\Martin\12mv1211\Electro\Analyzed Data');

	files=size(x);
	files=files(1);
	for i=3:files
		disp(['Converting test ' x(i,1:3)]);
		try
			convertData('12mv1211',x(i,1:3));
		catch exception
			disp(' some error occurred');
			disp(getReport(exception));
			%Meh. No biggie.
		end
	end

	%x={'065', '143', '144', '145'};
	%for i=1:length(x)
	%	disp(['Converting test ' x{i}]);
	%	try
	%		convertData('12mv1211',x{i});
	%	catch exception
	%		disp(' some error occurred');
	%		disp(getReport(exception));
	%		%Meh. No biggie.
	%	end
	%end

	%convertData('12mv1211','065');
	%convertData('12mv1211','145');
end

function ret=convertData(experiment, testName)
	loader=CSDLoader;
	loader.expName=experiment;
	csd=loader.load(testName);
	csd.save();
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ret=foo()
    loader=CSDLoader;
    csd=loader.load('065');
    ret=CSDStatAnalysis(csd);
end

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
	test1();
end
