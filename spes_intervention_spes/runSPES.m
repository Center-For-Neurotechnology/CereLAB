function stimchans = runSPES(pair, ntrials, intertrialinterval, amplitude, pulsewidth, jitterinterval)
%   Runs the SPES experiment, where it stimulates the given bipolar site
%   with single pulses.  Assuming 20 trials (the standard), the program
%   will take 100 seconds to run.
%
%   INPUTS
%  pair               a 1x2 matrix with the channel pair to be stimulated
%  ntrials            an integer with the number of trials to run (usually 20)
%  intertrialinterval an integar with delay between each trial (in seconds)
%  amplitude          an integar with amplitude of stimulation pulse in uA
%  pulsewidth         an integar with width of the pulse in one phase in uS
%  jitterinterval     an integar flag, taking 1 or 0 as input. 1
%                     corresponds to addition of a small jitter between
%                     trials.

cerestim = BStimulator();
connx = connect(cerestim);

if connx < 0
    error('Can''t connect to cerestim')
end

filename = datestr(now);
filename = strrep(filename,' ','_');
filename = strrep(filename,':','-');
logfile = fopen(['C:/Stimulation/SPES-' filename '.txt'], 'a');

c = onCleanup(@()cleanupfunction(cerestim,logfile));

pause on


% Hard coded config for SPES
pulses  = 1; % since we are running single pulses
interphase = 53;  % gap between the positive and negative phase of the
% bipolar pulse in us. Set at hardware min of 53 us.
trainlength= pulses*(pulsewidth+pulsewidth+interphase);
% unused params
frequency = 100; % is needed for underlying function to work, meaningless here.
intervalburstduration = 0;
delay = 0;


res = configureStimulusPattern(cerestim, 1, 'AF', pulses, ...
    amplitude, amplitude, pulsewidth, pulsewidth, frequency, interphase);
res = configureStimulusPattern(cerestim, 2, 'CF', pulses, ...
    amplitude, amplitude, pulsewidth, pulsewidth, frequency, interphase);




stimchans = zeros(ntrials,13);
currtrial = 1;

fprintf(logfile,'Logfile for SPES %s\n\r',filename);
fprintf(logfile,'\n\r');
fprintf(logfile,'\n\r');
fprintf(logfile,'Trial\tChannel1\tChannel2\tPulses\tAmplitude\tPulsewidth\tFrequency\tInterphase\tTrialInterval\n\r');
fprintf(logfile,'\n\r');
TrialTotal=ntrials;
count=1;
for n = 1:ntrials
    fprintf('Trial %g.\n',n);
    
    trialinterval=intertrialinterval+jitterinterval*(2*rand-1)*0.2;
    
    res = beginningOfSequence(cerestim);
    res = beginningOfGroup(cerestim);
    res = autoStimulus(cerestim, pair(1), 1);
    res = autoStimulus(cerestim, pair(2), 2);
    res = endOfGroup(cerestim);
    res = endOfSequence(cerestim);
    
    fprintf('Stimulating at pair %g - %g.\n',pair(1),pair(2))
    fprintf('at %g microA.\n',amplitude)
    
    fprintf(logfile,'%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%g\n\r',n,pair(1),pair(2),pulses,amplitude,pulsewidth,frequency,interphase,trialinterval);
    fprintf(logfile,'\n\r');
    stimchans(currtrial,:) = [n pair(1,:) pulses amplitude pulsewidth frequency interphase trialinterval trainlength jitterinterval intervalburstduration delay];
    currtrial = currtrial + 1;
    res = cerestim.play(1);
    
    disp([ num2str(count),' of ',num2str(TrialTotal),' trials ',num2str(pair(1)),'-',num2str(pair(2))])
    count=count+1;
    fprintf('Pausing for %g s.\n',trialinterval)
    pause(trialinterval);

    fprintf('\n')
    
    
end

end

function cleanupfunction(cerestim,logfile)

disconnect(cerestim);
delete(cerestim);
fclose(logfile);

end

