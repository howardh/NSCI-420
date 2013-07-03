%GetDataInfo
ExpName= '12mv1211';
TestName = '067';

% DataFolder
DataFolder =['\\132.216.58.64\f\Martin\' ExpName '\Electro\Analyzed Data\'];
GroupName = 'Conditions';
% Stimulus Folder
%cd \\132.216.58.171\Desktop\Vision' Experiments'\11mv0531\StimulusObjects 
cd(['\\132.216.58.64\f\Martin\' ExpName '\Electro\StimulusObjects\'])
load (TestName); loops = P.Loops;
if strcmp(class(P),'CSDmapping')==0;
    TotCond=P.TotNumCond;
end
cd(['\\132.216.58.64\f\Martin\' ExpName '\Electro\Analyzed Data\'])
cd (TestName);
load Master
eval(['NbChan = M' TestName '.PF.NumChNeur;'])
eval(['Probe = M' TestName '.PF.ProbeNumber;'])
ShowChannel = 1:NbChan;
%%%%
clc
disp(['%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%']);
disp(['ExpName: ' num2str(ExpName)]);
disp([ 'TestName: ' num2str(TestName)]);
disp([ 'Probe: ' num2str(Probe)]);
if strcmp(class(P),'CSDmapping')==0;
    disp([ 'Totale of Condition = ' num2str(TotCond)]);
end

disp([ 'Nb of loops = '  num2str(loops)]);
disp(['Nb of channels = ' num2str(NbChan)]);
disp(['Type of Stimuli = ' num2str(class(P))]);
disp(['Viewing Distance (cm) = ' num2str(P.ViewingDistance_cm)]);
if strcmp(class(P),'Gratings')==1;
    if length(P.Directions)>=2
       disp([ 'Num of Direction: ' num2str(length(P.Directions))]);
    else 
        disp([ '1 Direction: ' num2str(P.Directions)]);
    end
    disp(['SF = ' num2str(P.Spatialfreqs)]);
    disp(['TF = ' num2str(P.Temporalfreqs)]);
    disp(['Number of Contrasts = ' num2str(length(P.Contrast))]);
end 
disp(['%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%']);
