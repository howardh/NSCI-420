%% Tuning Curves
%%add SetPath C:Martin\Matlab

ExpName='12mv1211';
TestName = '065';
 %'088'; %'115'; %'109'; %'005'; '091', '084', '079', '073', '064', '057', '050'
% ShowChannel = 22;
ShowChannel = [1:32];
Conditions = [1:16];
% Conditions = [1:16];%1:4; %
Amplitude = 100;
FigureName = 'Tuning';
% DoSave =0; %0 do not save the output figure, 1 save the output figure

FigureFolder= ['\\132.216.58.64\f\Martin\' ExpName '\Electro\figures'];
%FigureFolder= ['C:\Martin\Electro\' ExpName '\ElectroFigs\'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
GroupName = 'Conditions';
% GroupName = 'ConditionsLFP2200';
Which = 'Stim'; %either Stim , InterStim, or PriorStim
Trials = 'Mean';% 1:50; %either a set of trial number or 'Mean'
titre =  strcat(TestName,'\_', FigureName);
 DataFolder =['\\132.216.58.64\f\Martin\' ExpName '\Electro\Analyzed Data\'];
% DataFolder = 'C:\Martin\Electro\11mv1222\Electro\Analyzed Data\';
% DataFolder = 'C:\Martin\Electro\12zy0206\Electro\Analyzed Data\Probe_1\';
% DataFolder = 'C:\Martin\Electro\12zy0206\Electro\Analyzed Data\Probe_2\';
% DataFolder= 'C:\';

%% Load the data object
% if ~exist(['M' TestName], 'var')
    TempObj = load(fullfile(DataFolder, TestName, 'Master.mat'), strcat('M', TestName));
    names = fieldnames(TempObj);
    M = TempObj.(names{1});
    clear('TempObj', 'names')
% else
%     eval(strcat('M = M', TestName,';'))
% end
BlankCond = find(Conditions == 0);
if ~isempty(BlankCond)
    Conditions(BlankCond) = M.DataG.(GroupName).Specifications.BlankCond;
end
    
%% Get Rates
RateMat = zeros(length(ShowChannel), length(Conditions));
RateStd = zeros(length(ShowChannel), length(Conditions));

if ischar(Trials)
    Trials = 1:M.DataG.(GroupName).DOA{Conditions(1)}.NumChunks;
end
    
for i = 1:length(Conditions)
   
    Cond = Conditions(i);
    switch upper(Which)
        case 'STIM'
            
            RateMat(:,i) =  mean(M.DataG.(GroupName).DOA{Cond}.StimSpikeRate(ShowChannel, Trials),2);
            RateStd(:,i) = std(M.DataG.(GroupName).DOA{Cond}.StimSpikeRate(ShowChannel, Trials), 1,2)./sqrt(length(Trials));
            
%         case 'INTERSTIM'
%             
%             RateMat(:,i) =  mean(M.DataG.(GroupName).DOA{Cond}.InterStimSpikeRate(ShowChannel, Trials),2);
%             RateStd(:,i) = std(M.DataG.(GroupName).DOA{Cond}.InterStimSpikeRate(ShowChannel, Trials), 1,2)./sqrt(length(Trials));
%             
%         case 'PRIOSTIM'
%             
%             RateMat(:,i) =  mean(M.DataG.(GroupName).DOA{Cond}.PriorTrigSpikeRate(ShowChannel, Trials),2);
%             RateStd(:,i) = std(M.DataG.(GroupName).DOA{Cond}.PriorTrigSpikeRate(ShowChannel, Trials), 1,2)./sqrt(length(Trials));
    end
end

RateMatSmooth=interp1(1:32,RateMat,1:(31/309):32);
if length(ShowChannel) > 1
    hF = figure('Name', 'Tuning Curve');
%     subplot(121),
    imagesc(RateMat, [0 Amplitude]);
    set(gca,'XTick',1:length(Conditions))
    set(gca,'XTickLabel',Conditions)
    set(gca,'YTick',1:length(ShowChannel))
    set(gca,'YTickLabel',ShowChannel)
    axis('tight')
    title(titre)
    zlabel('Spike Rate in spikes/sec')
    ylabel('Channels')
    xlabel('Condition')
    colorbar;
%     subplot(122),
%     imagesc(RateMatSmooth, [0 Amplitude]);
%     imagesc(RateMat)
   
else
    hF = figure('Name', ['Tuning Curve for Channel ' num2str(ShowChannel) ' and Trials ' num2str(Trials)]);
    plot(RateMat)
    errorbar(RateMat, RateStd);
    set(gca,'XTick',1:length(Conditions))
    set(gca,'XTickLabel',Conditions)
    axis('tight')
    title(titre)
    ylabel('Spike Rate in spikes/sec')
    xlabel('Condition')
end
% 
% if DoSave == 1
%    if ~strcmp(FigureFolder, filesep)
%         FigureFolder = [FigureFolder filesep];
%    end
%    if ~isdir(FigureFolder)
%        try
%            mkdir(FigureFolder)
%        catch
%             disp('Figure cannot be saved because the directory is invalid')
%        end
%    end
% %    saveas(hF, strcat(FigureFolder, TestName,'_', FigureName), 'jpg'); 
% %    clc
% %    disp('Figure was saved.')
% end
% % eval(strcat('M', TestName, '= M'))
%  clear('Which', 'DataFolder');
% clear('M', 'RateMat', 'RateStd', 'GroupName', 'Conditions', 'Cond', 'ShowChannel','Trials', 'ShowChannel')
