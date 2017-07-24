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
diary(['C:/Stimulation/NetworkSweepLog-' filename]);

pairs = [33 41; ... % GR 33 41
        49 57; ... % GR 49 57
        34 42; ... % GR 34 42
        50 58; ... % GR 50 58
        35 43; ... % GR 35 43
        51 59; ... % GR 51 59
        36 44; ... % GR 36 44
        52 60; ... % GR 52 60
        37 45; ... % GR 37 45
        53 61; ... % GR 53 61
        54 62; ... % GR 54 62
        39 47; ... % GR 39 47
        55 63; ... % GR 55 63
        56 64; ... % GR 56 64
	 ];

ntrials = 20;

stimchans = networktest(pairs, ntrials);

diary off

save(['C:/Stimulation/NetworkSweepChans-' filename '.mat'],stimchans)
