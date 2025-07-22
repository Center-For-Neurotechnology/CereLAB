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

addpath(genpath('C:/Stimulation'))

filename = datestr(now);
filename = strrep(filename,' ','_');
filename = strrep(filename,':','-');
diary(['C:/Stimulation/Superposition-' filename]);


pair_A = [15, 16]; %LTSb7-8
pair_B = [38, 39]; %LFIa13-14
pair_C = [69,70]; %LPIb3-4


pairs = [pair_A;pair_B;pair_C];
    
ntrials = 20;

intervalsec = 5;

amplitude = 7000;

stimchans = superposition(pairs, ntrials, intervalsec, amplitude);

diary off

save(['C:/Stimulation/Superposition-' filename '.mat'],'stimchans')