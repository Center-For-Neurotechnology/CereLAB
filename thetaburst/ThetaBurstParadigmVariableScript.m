% amplitude = 2000;
% intervalburstduration=126; %Interval between bursts
% pulses=3; %number of pulses per trial
% pulsewidth=100; % single pulse width per phase in microseconds
% intertrialinterval= 8.1; %interval (in seconds) between trials
% ntrials = 20; %Number of trials
% jitterinterval=0; %Randomly jitter inter-trial intervals in time (1- jitter, 0- no jitter)
% burstfrequency=50;
% frequency=burstfrequency; %Frequency of the biphasic pulses per burst
% interphase=53; %Interphase of the biphasic pulses
% numberofbursts=10;
% trainlength=10*pulses*(pulsewidth+pulsewidth+interphase);
% delays = [ 0];

% stimchans1 = [85 86];
% pairs = [1 2];
% stimchans1 = pairs(1,:);

filename = datestr(now);
filename = strrep(filename,' ','_');
filename = strrep(filename,':','-');

logfile = fopen(['C:/Stimulation/ThetaBurstInterv',num2str(intertrialinterval),'sec',num2str(amplitude/1000),'maLocs-' filename '.txt'], 'a');
fprintf(logfile,'Logfile for ThetaBurstTesting %s\n\r',filename);
fprintf(logfile,'\n\r');
fprintf(logfile,'\n\r');
fprintf(logfile,'Frequencies:\n\r');
fprintf(logfile,'\n\r');
for i = 1:length(frequency)
    fprintf(logfile,'%d\t',frequency(i));
end
fprintf(logfile,'\n\r');
fprintf(logfile,'\n\r');
fprintf(logfile,'Delays\n\r');
fprintf(logfile,'\n\r');
for i = 1:length(delays)
    fprintf(logfile,'%d\t',delays(i));
end
fprintf(logfile,'\n\r');
fprintf(logfile,'\n\r');
fprintf(logfile,'Inter-trial Interval is %d seconds.\n\r',intertrialinterval);
fprintf(logfile,'\n\r');
fprintf(logfile,'Number of trials per condition is %d.\n\r',ntrials);
fprintf(logfile,'\n\r');
fprintf(logfile,'Stimulation amplitude is %d mA.\n\r',amplitude);
fprintf(logfile,'\n\r');
fprintf(logfile,'Stimulation channels are %d-%d.\n\r',stimchans1(1), stimchans1(2));
fprintf(logfile,'\n\r');
fprintf(logfile,'Stimulation pulse width is %d ms.\n\r\n\r',pulsewidth);
fprintf(logfile,'\n\r');
fprintf(logfile,'\n\r');
fprintf(logfile,'Trial\tChannel1\tChannel2\tPulses\tAmplitude\tPulsewidth\tFrequency\tInterphase\tBurstInterval\tTrialInterval\n\r');
fprintf(logfile,'\n\r');

stimchans=[];
%****
cerestim = BStimulator();
connx = connect(cerestim);

if connx < 0
    error('Can''t connect to cerestim')
end
%****************
for n=1:ntrials
    trialinterval=intertrialinterval+jitterinterval*2*randn;

    res = thetaburstVariableParadigms(stimchans1, amplitude,  pulses, pulsewidth, burstfrequency, interphase, intervalburstduration, numberofbursts,cerestim,connx)
    stimchans=[stimchans;n stimchans1 amplitude pulsewidth burstfrequency interphase trialinterval trainlength jitterinterval intervalburstduration delays numberofbursts];

    disp(['theta burst stim at trial ', num2str(n),' of ',num2str(ntrials),' trials ',num2str(stimchans1(1,1)),'-',num2str(stimchans1(1,2))])

    pause(trialinterval)

    fprintf(logfile,'%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n\r',n,stimchans1(1,1),stimchans1(1,2),pulses,amplitude,pulsewidth,burstfrequency,interphase,intervalburstduration,trialinterval);
    fprintf(logfile,'\n\r');


end
%*********************
disconnect(cerestim);
delete(cerestim);
%******
save(['C:/Stimulation/thetaburstInterv',num2str(intertrialinterval),'sec',num2str(amplitude/1000),'ma',char(filename),'.mat'],...
    'stimchans','amplitude','intertrialinterval','n','burstfrequency','intervalburstduration',...
    'pairs','ntrials','intertrialinterval','amplitude','pulses','pulsewidth','frequency',...
    'interphase','trainlength','jitterinterval','delays','numberofbursts')
