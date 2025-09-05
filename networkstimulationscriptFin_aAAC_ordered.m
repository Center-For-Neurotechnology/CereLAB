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
% Network mini MG218
% connecting Box 1A => Cerestim A
% connecting Box 2A => Cerestim B
SubjID = 'MG218';
pairs = [
  4,5;   % Box1A 4-5;   LAMY4-5
  55,56; % Box2A 87-88; LFI-ANT9-10
  5,6;   % Box1A 5-6;   LAMY5-6
  57,58; % Box2A 89-90; LFI-ANT11-12
  7,8;   % Box3A 7-8;   LAMY7-8
  59,60; % Box2A 91-92; LFI-ANT13-14
];
pairs = [1,2;
    3,4];
%}
% Network mini MG220
% connecting Box 1A => Cerestim A
% connecting Box 2A => Cerestim B
% connecting Box 2B => Cerestim C
%
SubjID = 'MG220';
pairs = [
  49,50;   % Box2A  81- 82;   RFIa01-02; pOFC
  81,82;   % Box2B 113-114;   RFIc03-04; sgACC
  50,51;   % Box2A  82- 83;   RFIa02-03; pOFC
  79,80;   % Box2B 111-112;   RFIc01-02; sgACC
  51,52;   % Box2A  83- 84;   RFIa03-04; pOFC
  80,81;   % Box2B 112-113;   RFIc02-03; sgACC
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


