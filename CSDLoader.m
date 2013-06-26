classdef CSDLoader
    properties
        expName='12mv1211';
        conditions = [1:16];
        %range = [-45 45]; 
        %window=(1000:1200); 
        trials = []; %if empty it just computes the mean
        %badChannels=[23];
    end
    methods
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%	Loads everything
        function ret=load(this,testName)
			%If the file already exists, then load it
			fileName=[Const.DATA_DIRECTORY pathname(this.expName) testName '.mat'];
			if exist(fileName, 'file')
				disp(['File ' testName ' already exists. Loading from file.']);
				x=load(fileName);
				ret=x.this;
				return;
			end

			%Otherwise, load the data from Martin's script and save it
			disp(['File ' testName ' does not exist. Creating file.']);
            ret=CSDData;
            ret.testName=testName;
			ret.expName=this.expName;
            ret.data=this.loadData(testName);
            ret.stimulus=this.loadStimulus(testName);
            ret.stimulusObject=this.loadStimulusObject(testName);
			if (strcmp(ret.stimulus, 'Gratings') == 1)
				ret.tuningCurve=this.loadTuningCurve(testName);
			end
			ret.alignment=this.loadAlignment(testName);
			ret.save();
        end
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%	Loads alignment for all tests in this experiment
		function ret=loadAlignment(this,testName)
			%TODO: Directory shouldn't be hard-coded
			%dir = Const.ALIGNMENT_DIRECTORY;
			dir1 = [Const.RESULT_DIRECTORY pathname('test4', this.expName, 'Covariance')];
			dir2 = [Const.RESULT_DIRECTORY pathname('test5', this.expName, 'Covariance')];
			
			%Load alignment data for CSD mapping
			if ~exist([dir1 'results.mat'],'file')
				disp(['Alignment data not available for ' this.expName ' test ' testName '.']);
				disp(['Run test4 first to obtain the data, then try loading again.']);
				ret=[];
				return;
			end
			load([dir1 'results.mat']);

			%If the data exists for that test, return it
			if results.isKey(testName)
				ret=results(testName);
				return;
			end

			%Otherwise, check the alignment data for grating stimuli
			if ~exist([dir2 'results.mat'],'file')
				disp(['Alignment data not available for ' this.expName ' test ' testName '.']);
				disp(['Run test4 and test5 first to obtain the data, then try loading again.']);
				ret=[];
				return;
			end
			load([dir2 'results.mat']);

			ret=results(testName);
			return;
		end
	end
	methods (Access = private)
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%	Methods that only load part of the data

        function ret=loadData(this,testName)
            groupName = 'Conditions';
            dataFolder = ['\\132.216.58.64\f\Martin\' this.expName '\Electro\Analyzed Data\'];

            if ~exist(['M' testName], 'var')
                tempObj = load(fullfile(dataFolder, testName, 'Master.mat'), strcat('M', testName));
                names = fieldnames(tempObj);
                M = tempObj.(names{1});
                clear('TempObj', 'names')
            else
                eval(strcat('M = M', testName,';'))
            end
            
            %TODO: Why does this give me an error for CSDMapping?
            try
                for i = 1:length(this.conditions)
                    if isempty(this.trials)
                        M.DataG.(groupName).DOA{(this.conditions(i))}.BadChannels = Const.BAD_CHANNELS(this.expName,testName);
                        M.DataG.(groupName).DOA{this.conditions(i)}.LoadFlag.Data = true;
                        M.DataG.(groupName).DOA{this.conditions(i)}.ComputeFlag.TrialMean = true;
                        M.DataG.(groupName).DOA{this.conditions(i)}.ComputeFlag.CSD = true;
                        M.DataG.(groupName).DOA{this.conditions(i)}.ComputeFlag.CSDMean = true;
                        temp = M.DataG.(groupName).DOA{this.conditions(i)}.CSDMean;
                        M.DataG.(groupName).DOA{this.conditions(i)}.LoadFlag.Data = false;
                        M.DataG.(groupName).DOA{this.conditions(i)}.ComputeFlag.TrialMean = false;
                        M.DataG.(groupName).DOA{this.conditions(i)}.ComputeFlag.CSD = false;
                        M.DataG.(groupName).DOA{this.conditions(i)}.ComputeFlag.MeanCSD = false;
                        M.DataG.(groupName).DOA{(this.conditions(i))}.LoadFlag.Data = 1;
                        M.DataG.(groupName).DOA{(this.conditions(i))}.ComputeFlag.CSD = 1;
                        
                        CSD = M.DataG.(groupName).DOA{(this.conditions(i))}.CSD;
                    else
                        M.DataG.(groupName).DOA{(this.conditions(i))}.BadChannels = BadChannels;
                        M.DataG.(groupName).DOA{this.conditions(i)}.View('CSD', Trials);
                        CSD=M.DataG.(groupName).DOA{(this.conditions(i))}.CSD;
                    end
                    if i == 1;
                        CSDMeanMat = temp;
                        CSDALL=CSD;
                    else
                        CSDMeanMat = cat(3, CSDMeanMat, temp);
                        CSDALL=cat(4,CSDALL,CSD);
                    end
                end
            catch exception
                disp('Some error occurred. Figure out why this happened and if it concerns me.');
            end
            ret = CSDALL;
        end
        function ret=loadStimulus(this,testName)
            %DataFolder =['\\132.216.58.64\f\Martin\' expName '\Electro\Analyzed Data\'];
            %cd(['\\132.216.58.64\f\Martin\' this.expName '\Electro\StimulusObjects\'])

            %Load the data
            load(['\\132.216.58.64\f\Martin\' this.expName '\Electro\StimulusObjects\' testName])
            %load (testName);
            ret=class(P);
        end
        function ret=loadStimulusObject(this,testName)
            %cd(['\\132.216.58.64\f\Martin\' this.expName '\Electro\StimulusObjects\'])
            load(['\\132.216.58.64\f\Martin\' this.expName '\Electro\StimulusObjects\' testName])
            %load (testName);
            ret=P;
        end
		function ret=loadTuningCurve(this,testName)
			ShowChannel = [1:32];
			Conditions = [1:16];
			% Conditions = [1:16];%1:4; %
			Amplitude = 100;

			GroupName = 'Conditions';
			Which = 'Stim'; %either Stim , InterStim, or PriorStim
			Trials = 'Mean';% 1:50; %either a set of trial number or 'Mean'
			DataFolder =['\\132.216.58.64\f\Martin\' this.expName '\Electro\Analyzed Data\'];

			%% Load the data object
			TempObj = load(fullfile(DataFolder, testName, 'Master.mat'), strcat('M', testName));
			names = fieldnames(TempObj);
			M = TempObj.(names{1});
			clear('TempObj', 'names')

			BlankCond = find(Conditions == 0);
			if ~isempty(BlankCond)
				Conditions(BlankCond) = M.DataG.(GroupName).Specifications.BlankCond;
			end
				
			%% Get Rates
			RateMat = zeros(length(ShowChannel), length(Conditions));

			if ischar(Trials)
				Trials = 1:M.DataG.(GroupName).DOA{Conditions(1)}.NumChunks;
			end
				
			for i = 1:length(Conditions)
				Cond = Conditions(i);
				RateMat(:,i) = mean(M.DataG.(GroupName).DOA{Cond}.StimSpikeRate(ShowChannel, Trials),2);
			end

			ret=RateMat;
		end
    end
end
