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

addpath(genpath('C:/Stimulation'))

filename = datestr(now);
filename = strrep(filename,' ','_');
filename = strrep(filename,':','-');
diary(['C:/Stimulation/NetworkSweepLog-' filename]);

%% Network 
% pairs =[
% ];

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

stimchans = networktestFin(pairs, ntrials,intertrialinterval,amplitude,pulses,pulsewidth,frequency,interphase,trainlength,jitterinterval,intervalburstduration,delay);

diary off

save(['C:/Stimulation/NetworkSweepBipolChans-',char(filename),'.mat'],'stimchans',...
    'pairs','ntrials','intertrialinterval','amplitude','pulses','pulsewidth','frequency',...
    'interphase','trainlength','jitterinterval','delay')


