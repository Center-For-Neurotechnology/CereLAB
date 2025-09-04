% script to probe effect of Thalamic Stimulation on SOZ Interictal activity

% Stimulation consists of three blocks:
% 1. Single pulses at an SOZ location. (SOZ_ntrials)
% 2. Thalamic Stimulation with either 10 Hz trains or Single pulses (Thal_ntrials)
% 3. Single pulses again at the SOZ location (SOZ_ntrials).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% hook up instructions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cerestim needs:
% % a power supply
% % a USB cable, plugged into the presentation computer on the rig
% % three NO GROUND blue cables from the back of the cerestim to the splitter boxes
% % a patient ground cable connected to a scalp electrode and attached to the back of the cerestim with a jumper cable
% % a BNC cable from the cerestim to the rig (SYNC)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% Set Configuration for the three blocks

% first for SOZ
SOZ_pair = [,]; % Bipolar pair corresponding to SOZ location

SOZ_amplitude          = 7000; %current amplitude in microamps 
SOZ_pulsewidth         = 90; % single pulse width per phase in microseconds
SOZ_intertrialinterval = 5; %interval (in seconds) between trials 
SOZ_ntrials            = 20; %Number of trials
SOZ_jitterinterval     = 1; %Randomly jitter inter-trial intervals in time (1- jitter, 0- no jitter)


% Thalamic location
Thal_pair = [22,23]; % Bipolar pair corresponding to Thalamic Site

Thal_stimTypeTrains     = 1; % Use 10 Hz trains if set to 1, else use SPES
Thal_freq               = [10]; % 10 Hz trains 
Thal_trainLen           = 400; % in ms
delays                  = [0];

Thal_amplitude          = 2000; %current amplitude in microamps 
Thal_pulsewidth         = 90; % single pulse width per phase in microseconds
Thal_intertrialinterval = 5; %interval (in seconds) between trials 
Thal_ntrials            = 20; %Number of trials
Thal_jitterinterval     = 1; %Randomly jitter inter-trial intervals in time (1- jitter, 0- no jitter)

interBlockTime = 20; % Time between SOZ SPES block and Thalamic Stim block

%% Run Stimulation

% create a log
addpath(genpath('C:/Stimulation'))

filename = datestr(now);
filename = strrep(filename,' ','_');
filename = strrep(filename,':','-');
diary(['C:/Stimulation/SOZ_Thalamic_IEA-Block1-' filename]);

% 1. Run Block 1

% storing parameters for matlab log file
pair = SOZ_pair;
ntrials = SOZ_ntrials;
intertrialinterval = SOZ_intertrialinterval;
amplitude = SOZ_amplitude;
pulses = 1;
pulsewidth = SOZ_pulsewidth;
frequency = 100;
interphase = 53;
trainlength = SOZ_pulsewidth+SOZ_pulsewidth+interphase;
jitterinterval = SOZ_jitterinterval;
delay = 0;

stimchans = runSPES(SOZ_pair, SOZ_ntrials, SOZ_intertrialinterval, SOZ_amplitude, SOZ_pulsewidth, SOZ_jitterinterval);

diary off;
save(['C:/Stimulation/SPES-',char(filename),'.mat'],'stimchans',...
    'pair','ntrials','intertrialinterval','amplitude','pulses','pulsewidth','frequency',...
    'interphase','trainlength','jitterinterval','delay')

pause(interBlockTime)
% 2. Run Block 2



if (Thal_stimTypeTrains == 1)
    
    % storing parameters for matlab log file
    pair = Thal_pair;      
    ntrials = Thal_ntrials;
    intertrialinterval = Thal_intertrialinterval;
    amplitude = Thal_amplitude;
    pulses = floor(Thal_freq*Thal_trainLen/1000);
    pulsewidth = Thal_pulsewidth;
    frequency = Thal_freq;
    interphase = 53;
    trainlength = Thal_trainLen;
    jitterinterval = Thal_jitterinterval;
    delay = 0;

    stimMatrix = runStimTrains(Thal_pair, Thal_freq, Thal_intertrialinterval, Thal_ntrials, Thal_amplitude, Thal_trainLen, Thal_pulsewidth, Thal_jitterinterval);
    diary off;

    
else
    filename = datestr(now);
    filename = strrep(filename,' ','_');
    filename = strrep(filename,':','-');
    diary(['C:/Stimulation/SOZ_Thalamic_IEA-Block2-' filename]);

    % storing parameters for matlab log file
    pair = Thal_pair;
    ntrials = Thal_ntrials;
    intertrialinterval = Thal_intertrialinterval;
    amplitude = Thal_amplitude;
    pulses = 1;
    pulsewidth = Thal_pulsewidth;
    frequency = 100;
    interphase = 53;
    trainlength = Thal_pulsewidth+Thal_pulsewidth+interphase;
    jitterinterval = Thal_jitterinterval;
    delay = 0;
    
    stimchans = runSPES(Thal_pair, Thal_ntrials, Thal_intertrialinterval, Thal_amplitude, Thal_pulsewidth, Thal_jitterinterval);
    diary off;
    save(['C:/Stimulation/SPES-',char(filename),'.mat'],'stimchans',...
    'pair','ntrials','intertrialinterval','amplitude','pulses','pulsewidth','frequency',...
    'interphase','trainlength','jitterinterval','delay')
end

pause(interBlockTime)
% 3. Block 3

filename = datestr(now);
filename = strrep(filename,' ','_');
filename = strrep(filename,':','-');
diary(['C:/Stimulation/SOZ_Thalamic_IEA-Block3-' filename]);

% storing parameters for matlab log file
pair = SOZ_pair;
ntrials = SOZ_ntrials;
intertrialinterval = SOZ_intertrialinterval;
amplitude = SOZ_amplitude;
pulses = 1;
pulsewidth = SOZ_pulsewidth;
frequency = 100;
interphase = 53;
trainlength = SOZ_pulsewidth+SOZ_pulsewidth+interphase;
jitterinterval = SOZ_jitterinterval;
delay = 0;

stimchans = runSPES(SOZ_pair, SOZ_ntrials, SOZ_intertrialinterval, SOZ_amplitude, SOZ_pulsewidth, SOZ_jitterinterval);
diary off;
save(['C:/Stimulation/SPES-',char(filename),'.mat'],'stimchans',...
    'pair','ntrials','intertrialinterval','amplitude','pulses','pulsewidth','frequency',...
    'interphase','trainlength','jitterinterval','delay')


