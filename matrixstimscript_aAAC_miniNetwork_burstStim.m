
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% hook up instructions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Cerestim needs:
% % a power supply
% % a USB cable, plugged into the presentation computer on the rig
% % three NO GROUND blue cables from the back of the cerestim to the splitter boxes
% % a patient ground cable connected to a scalp electrode and attached to the back of the cerestim with a jumper cable
% % a BNC cabled from the audio task to both the rig and the cerestim (TRIG)
% % a BNC cable from the cerestim to the rig (SYNC)

%%%%%%%%% some tips %%%%%%%%%%%%

% pick either the right or the left side to run
%
% feel free to reduce the number of electrodes by 
% removing them from the "pairs" variable
%
% set ntrials to something large so that it runs
% continuously - use ctrl+c to quit
%
% be sure to run the audio task first - it emits
% triggers on startup that will cause stimulation to 
% be triggered inappropriately


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% NETWORK STIMULATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% plug the NO GROUND blue cables from the cerestim into the 
% splitter boxes as follows:
% A: Splitter Box 1 Bank 1
% B: Splitter Box 1 Bank 2

%%
addpath(genpath('C:\Stimulation'))
%fclose('all')
%% Contact Pairs
%{
% Network mini MG218
% connecting Box 1A => Cerestim A
% connecting Box 2A => Cerestim B
SubjID = '';
pairs = [
];

% Network mini 
% connecting Box 1A => Cerestim A
% connecting Box 2A => Cerestim B
% connecting Box 2B => Cerestim C
%
SubjID = '';
pairs = [
    
];
filename_add = ''; % add a string to the filename if you want to distinguish between different runs of the same script

%% Stimulation Parameters
%%%%%%%% edit these values %%%%%%%%

param_matrix = struct();

param_matrix.ChanPair = pairs; % pairs of channels to stimulate
randomize_chan_order = false; % true or false, whether to randomize presentation order of stimChan

param_matrix.Frequency = [ 130 ];

delays = [0]; assert(length(delays)==1,'Only one delay is allowed for this script');
param_matrix.Delay = delays; 

ntrials = 10;
param_matrix.Repeat = 1:ntrials;

param_sort_order = {'Repeat','OrderInRepeat'};

%>> unitary params
stimamplitude = 6000 ; %current amplitude in microamps

trainlength = 600; % in ms

intertrialinterval = 10; % in seconds

pulsewidth = 90; % in microseconds

interphase = 53; % in microseconds

%<< unitary params

%% Form Full Stimulation Matrix
TrialTotal = ntrials*size(param_matrix.ChanPair,1)*length(param_matrix.Frequency);
T_StimParam=cell2table(cell(TrialTotal,4),'VariableNames',{'Repeat','ChanPair','Frequency','OrderInRepeat'});

iEntry = 0;
for iRpt = 1:ntrials
    vEntry_this_trial = [];
    for iPair=1:size(pairs,1)
        for iFreq=1:size(param_matrix.Frequency,2)
            iEntry = iEntry + 1;
            vEntry_this_trial = cat(1,vEntry_this_trial,iEntry);
            T_StimParam.Repeat{iEntry} = iRpt;
            T_StimParam.ChanPair(iEntry) = {pairs(iPair,:)};
            T_StimParam.Frequency{iEntry} = param_matrix.Frequency(iFreq);
            %pairsFreq= cat(1,pairsFreq, [pairs(un,:) frequencies(fun)]);
        end
    end
    if randomize_chan_order
        T_StimParam.OrderInRepeat(vEntry_this_trial) =  num2cell(randperm(length(vEntry_this_trial)));
    else
        T_StimParam.OrderInRepeat(vEntry_this_trial) = num2cell(1:length(vEntry_this_trial))';
    end
end
T_StimParam.Repeat = cellfun(@(x) x, T_StimParam.Repeat);
T_StimParam.Frequency = cellfun(@(x) x, T_StimParam.Frequency);
T_StimParam.OrderInRepeat = cellfun(@(x) x, T_StimParam.OrderInRepeat);
T_StimParam = sortrows(T_StimParam,param_sort_order);
T_StimParam.Delay(:) = delays(1); % only one delay is allowed for this script;
T_StimParam.TrialID = (1:height(T_StimParam))'; T_StimParam=movevars(T_StimParam,'TrialID','Before',1);
%
%% Create LogFile
SubjDirectory= fullfile('C:\Stimulation\',SubjID);
if ~exist(SubjDirectory,'dir'), mkdir(SubjDirectory); end
filename = datestr(now);
filename = strrep(filename,' ','_');
filename = strrep(filename,':','-');

fbase_log = sprintf('%s_aAAC-miniNetwork_BurstStim-%02.0f-mA%s_%s',SubjID,stimamplitude/1000,filename_add,char(filename));
fname_log = sprintf('%s_log.txt',fbase_log);
fpath_log = fullfile(SubjDirectory,fname_log);

fname_diary = sprintf('%s_diary',fbase_log);
fpath_diary = fullfile(SubjDirectory,fname_diary);
%
logfile = fopen(fpath_log, 'a');
fprintf(logfile,'Logfile for aAAC-miniNetwork_BurstStim %s\n\r',filename);
fprintf(logfile,'\n\r');
fprintf(logfile,'\n\r');
fprintf(logfile,'Frequencies:\n\r');
fprintf(logfile,'\n\r');
for i = 1:length(param_matrix.Frequency)
    fprintf(logfile,'%d\t',param_matrix.Frequency(i));
end
fprintf(logfile,'\n\r');
fprintf(logfile,'\n\r');
fprintf(logfile,'Delays\n\r');
fprintf(logfile,'\n\r');
for i = 1:length(param_matrix.Delay)
    fprintf(logfile,'%d\t',param_matrix.Delay(i));
end
fprintf(logfile,'\n\r');
fprintf(logfile,'\n\r');
fprintf(logfile,'Inter-trial Interval is %d seconds.\n\r',intertrialinterval);
fprintf(logfile,'\n\r');
fprintf(logfile,'Number of trials per condition is %d.\n\r',ntrials);
fprintf(logfile,'\n\r');
fprintf(logfile,'Stimulation amplitude is %d mA.\n\r',stimamplitude);
fprintf(logfile,'\n\r');
fprintf(logfile,'Stimulation channels vary');
fprintf(logfile,'\n\r');
fprintf(logfile,'Stimulation train length is %d ms.\n\r\n\r',trainlength);
fprintf(logfile,'\n\r');
fprintf(logfile,'\n\r');
fprintf(logfile,'Trial\tChannel1\tChannel2\tPulses\tAmplitude\tTrainLength\tFrequency\tDelay\n\r');
%fprintf(logfile,'Trial\tFrequency\tDelay\n\r');
fprintf(logfile,'\n\r');
% Start diary
diary(fpath_diary)
%
fpath_mat = fullfile(SubjDirectory,sprintf('%s_stimParam.mat',fbase_log));
matfile_log = matfile(fpath_mat,'Writable',true);
matfile_log.T_StimParam = T_StimParam;
%% Execute BurstStim
uniRpts = unique(T_StimParam.Repeat);
for iRpt = 1:length(uniRpts)
    T_Rpt = T_StimParam(T_StimParam.Repeat==uniRpts(iRpt),:);
    %
    [numtrials_,stimchans_,frequencies_,delays_] = deal([]);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    matrixfuncMultipleSites_aAAC(T_Rpt,...
        numtrials_,stimchans_,frequencies_,delays_,...
        stimamplitude,trainlength,pulsewidth,interphase,intertrialinterval,...
        randomize_chan_order,param_sort_order,...
        SubjDirectory,fbase_log,logfile,matfile_log,fpath_diary)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%%
fclose('all')