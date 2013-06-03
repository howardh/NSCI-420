%% CSDViewer
% shows the CSD and save the image with FileName in eps in ResultFolder
ExpName='12mv1211';
TestName = '104';
% FileName= 'CSD_054.eps';
%Conditions = [1:16];
Conditions = [1:16];
Range = [-45 45]; 
window=(1000:1200); 
Trials = []; %if empty it just computes the mean
% BadChannels=[10 18 22];
BadChannels=[17,23]; %065

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

Mat = mean(CSDMeanMat,3);
figure
%imagesc(Mat(:, window),Range);
imagesc(Mat(:, window));
title([num2str(ExpName) 'test ' num2str(TestName)]);
xlabel('Time (msec)');
ylabel('Channels');
colorbar;

