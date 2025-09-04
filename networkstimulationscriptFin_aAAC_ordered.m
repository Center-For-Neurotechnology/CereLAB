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


%% Contact Pairs
%{
% Network mini 
% connecting Box 1A => Cerestim A
% connecting Box 2A => Cerestim B
SubjID = '';
pairs = [

];

% add a string to the filename if you want to distinguish between different runs of the same script
% filename_add = 'pass-test'; % 20 trials
filename_add = 'pass-01'; % 20 trials
%filename_add = 'pass-02'; % 10 trials focus on AOIs only
%%
addpath(genpath('C:/Stimulation'))

filename = datestr(now,'yyyymmdd-HHMMSS'); %create a filename based on the current date and time
%filename = strrep(filename,' ','_');
%filename = strrep(filename,':','-');

SubjDirectory= fullfile('C:\Stimulation\',SubjID);
if ~exist(SubjDirectory,'dir'), mkdir(SubjDirectory); end

diary(fullfile(SubjDirectory,sprintf('NetworkSweepLog-aAAC-miniNetwork-%s-%s',SubjID,filename)));

%% Stimulation Parameters
amplitude = 7000; %current amplitude in microamps 

pulses=1; %number of pulses per trial

pulsewidth=90; % single pulse width per phase in microseconds

intertrialinterval= 4; %interval (in seconds) between trials 

ntrials = 20; %Number of trials

jitterinterval=1; %Randomly jitter inter-trial intervals in time (1- jitter, 0- no jitter)

frequency=100; %Frequency of the biphasic pulses

interphase=53; %Interphase of the biphasic pulses

trainlength=pulses*(pulsewidth+pulsewidth+interphase);

intervalburstduration=0;

delay=0;

%% Execute Network Stim
stimchans = networktestFinNonRandom(pairs, ntrials,intertrialinterval,amplitude,pulses,pulsewidth,frequency,interphase,...
                                    trainlength,jitterinterval,intervalburstduration,delay);


diary off

save(fullfile(SubjDirectory,sprintf('NetworkSweepBipolChans_%s_aAAC-miniNetwork%s_%s.mat',SubjID,char(filename),filename_add)),...
    'SubjID',...    
    'stimchans',...
    'pairs','ntrials','intertrialinterval','amplitude','pulses','pulsewidth','frequency',...
    'interphase','trainlength','jitterinterval','delay')


