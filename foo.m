%% CSDViewer
ExpName='12mv1211';
TestName = '065';
Conditions = [1:16];
Range = [-45 45]; 
window=(1000:1200); 
Trials = []; %if empty it just computes the mean
BadChannels=[23];

GroupName = 'Conditions';
DataFolder =['\\132.216.58.64\f\Martin\' ExpName '\Electro\Analyzed Data\'];

if ~exist(['M' TestName], 'var')
    TempObj = load(fullfile(DataFolder, TestName, 'Master.mat'), strcat('M', TestName));
    names = fieldnames(TempObj);
    M = TempObj.(names{1});
    clear('TempObj', 'names')
else
    eval(strcat('M = M', TestName,';'))
end

for i = 1:length(Conditions)
    if isempty(Trials)
        M.DataG.(GroupName).DOA{(Conditions(i))}.BadChannels = BadChannels;
        M.DataG.(GroupName).DOA{Conditions(i)}.LoadFlag.Data = true;
        M.DataG.(GroupName).DOA{Conditions(i)}.ComputeFlag.TrialMean = true;
        M.DataG.(GroupName).DOA{Conditions(i)}.ComputeFlag.CSD = true;
        M.DataG.(GroupName).DOA{Conditions(i)}.ComputeFlag.CSDMean = true;
        Temp = M.DataG.(GroupName).DOA{Conditions(i)}.CSDMean;
        M.DataG.(GroupName).DOA{Conditions(i)}.LoadFlag.Data = false;
        M.DataG.(GroupName).DOA{Conditions(i)}.ComputeFlag.TrialMean = false;
        M.DataG.(GroupName).DOA{Conditions(i)}.ComputeFlag.CSD = false;
        M.DataG.(GroupName).DOA{Conditions(i)}.ComputeFlag.MeanCSD = false;
        M.DataG.(GroupName).DOA{(Conditions(i))}.LoadFlag.Data = 1;
        M.DataG.(GroupName).DOA{(Conditions(i))}.ComputeFlag.CSD = 1;
        
        CSD = M.DataG.(GroupName).DOA{(Conditions(i))}.CSD;
    else
        M.DataG.(GroupName).DOA{(Conditions(i))}.BadChannels = BadChannels;
        M.DataG.(GroupName).DOA{Conditions(i)}.View('CSD', Trials);
        CSD=M.DataG.(GroupName).DOA{(Conditions(i))}.CSD;
    end
    if i == 1;
        CSDMeanMat = Temp;
        CSDALL=CSD;
    else
        CSDMeanMat = cat(3, CSDMeanMat, Temp);
        CSDALL=cat(4,CSDALL,CSD);
    end
end

% Col 1: 32
%   Channels
% Col 2: 3501
%   Time in ms?
% Col 3: 10? variable size
%   Trials
% Col 4: 16
%   Conditions

%{
    Pick a channel
    Pick a time
    Pick two conditions (excluding the no stimulus condition)
    Compare the distribution of data for every trial during that time
%}

numChannels = size(CSDALL,1);
numTimes = size(CSDALL,2);
numConditions = size(CSDALL,4);
result = zeros(numChannels, numTimes, numConditions, numConditions);

%TODO: I don't know if the variances are equal or not. Maybe I should check that?
%for channel=1:numChannels
%    disp(['Channel ' num2str(channel)]);
%    for time=window
%        disp([' Time ' num2str(time)]);
%        for cond1=1:numConditions
%            for cond2=cond1+1:numConditions
%                dist1 = CSDALL(channel,time,:,cond1);
%                dist2 = CSDALL(channel,time,:,cond2);
%                %unpaired two sample t-test
%                %Returns 0 if the null hypothesis can't be rejected (i.e. means are the same)
%                %Otherwise, it returns 1
%                h = ttest2(dist1,dist2);
%                %disp(h);
%                result(channel,time,cond1,cond2) = result(channel,time,cond1,cond2) + h;
%                %disp(result(channel,time,cond1,cond2));
%            end
%        end
%    end
%end

%%Display results
%output = mean(result, 1);
%output = mean(output, 2);
%output = squeeze(output);
%imagesc(output);
%xlabel('Condition 1');
%ylabel('Condition 2');
%colorbar;

%cd '\\132.216.58.64\f\SummerStudents\Howard\'
%load results

output = mean(CSDALL,3);
output = squeeze(output);
imagesc(output(:,[1050:1100],2), Range);
