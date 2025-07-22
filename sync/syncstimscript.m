%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% hook up instructions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Cerestim needs:
% % a power supply
% % a USB cable, plugged into the presentation computer on the rig
% % three NO GROUND blue cables from the back of the cerestim to the splitter boxes
% % a patient ground cable connected to a scalp electrode and attached to the back of the cerestim with a jumper cable
% % a BNC cable from the audio task to both the rig and the cerestim (TRIG)
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

path = 'C:/Stimulation';

addpath(genpath(path))

filename = datestr(now);
filename = strrep(filename,' ','_');
filename = strrep(filename,':','-');
diary([path '/SyncStim-' filename]);

pair_A = [31, 32]; %RFMa1-2
pair_B = [34,35]; %RFMcCM3-4
pair_C = [56, 57]; %RFSa8-9

pairs = [pair_A;pair_B;pair_C];

ntrials = 20;
intertrialinterval = 5;
amplitude = 4000;

pulses = 1;
pulsewidth = 90;
frequency = 100;
interphase = 53;
jitterinterval = 1; % no jitter

% redundant params - only for consistency
trainlength = 0; 
intervalburstduration = 0;
delay = 0;

stimchans = syncfunc(path ,pairs, ntrials, intertrialinterval, amplitude, pulses,pulsewidth,frequency,interphase,trainlength,jitterinterval,intervalburstduration,delay);


diary off

save([path '/SyncStim-' filename '.mat'],'stimchans')