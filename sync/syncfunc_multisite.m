function stimchans = syncfunc_multisite(path, pairs, ntrials, intertrialinterval, amplitude, pulses,pulsewidth,frequency,interphase,trainlength,jitterinterval,intervalburstduration,delay)


if ~exist('intertrialinterval','var') || isempty(intertrialinterval)
    intertrialinterval=5; % default is 5 seconds between trials
end

if ~exist('amplitude','var') || isempty(amplitude)
    amplitude=7000; % default is 7mA
end

nullElectrode = 0; % this is the electrode that will not be used. for the case of A instead of A+B

% initiate cerestim
cerestim = BStimulator();
connx = connect(cerestim);

if connx < 0
    error('Can''t connect to cerestim')
end

% create log file
filename = datestr(now);
filename = strrep(filename,' ','_');
filename = strrep(filename,':','-');
logfile = fopen([path '/SyncStim-' filename '.txt'], 'a');

c = onCleanup(@()cleanupfunction(cerestim,logfile));

pause on

% creating wave patterns - this is the initialization channels will be specified afterwards
res = configureStimulusPattern(cerestim, 1, 'AF', pulses, ...
    amplitude, amplitude, pulsewidth, pulsewidth, frequency, interphase);
res = configureStimulusPattern(cerestim, 2, 'CF', pulses, ...
    amplitude, amplitude, pulsewidth, pulsewidth, frequency, interphase);
res = configureStimulusPattern(cerestim, 3, 'AF', pulses, ...
    amplitude, amplitude, pulsewidth, pulsewidth, frequency, interphase);
res = configureStimulusPattern(cerestim, 4, 'CF', pulses, ...
    amplitude, amplitude, pulsewidth, pulsewidth, frequency, interphase);
res = configureStimulusPattern(cerestim, 5, 'AF', pulses, ...
    amplitude, amplitude, pulsewidth, pulsewidth, frequency, interphase);
res = configureStimulusPattern(cerestim, 6, 'CF', pulses, ...
    amplitude, amplitude, pulsewidth, pulsewidth, frequency, interphase);
res = configureStimulusPattern(cerestim, 7, 'AF', pulses, ...
    amplitude, amplitude, pulsewidth, pulsewidth, frequency, interphase);
res = configureStimulusPattern(cerestim, 8, 'CF', pulses, ...
    amplitude, amplitude, pulsewidth, pulsewidth, frequency, interphase);
res = configureStimulusPattern(cerestim, 9, 'AF', pulses, ...
    amplitude, amplitude, pulsewidth, pulsewidth, frequency, interphase);
res = configureStimulusPattern(cerestim, 10, 'CF', pulses, ...
    amplitude, amplitude, pulsewidth, pulsewidth, frequency, interphase);
res = configureStimulusPattern(cerestim, 11, 'AF', pulses, ...
    amplitude, amplitude, pulsewidth, pulsewidth, frequency, interphase);
res = configureStimulusPattern(cerestim, 12, 'CF', pulses, ...
    amplitude, amplitude, pulsewidth, pulsewidth, frequency, interphase);

fprintf(logfile,'Logfile for Superposition %s\n\r',filename);
fprintf(logfile,'\n\r');
fprintf(logfile,'\n\r');
fprintf(logfile,'Trial\tChannel1\tChannel2\tChannel3\tChannel4\tChannel5\tChannel6\tChannel7\tChannel8\tChannel9\tChannel10\tChannel11\tChannel12\tPulses\tAmplitude\tPulsewidth\tFrequency\tInterphase\tTrialInterval\n\r');
fprintf(logfile,'\n\r');

TrialTotal = ntrials;
currtrial = 1;
stimchans = zeros(TrialTotal,12);
% create base trial and iterate
for n = 1:ntrials

    trialinterval=intertrialinterval+jitterinterval*(2*rand-1)*0.2;

    res = beginningOfSequence(cerestim);
    res = beginningOfGroup(cerestim);
    res = autoStimulus(cerestim, pairs(1,1), 1);
    res = autoStimulus(cerestim, pairs(1,2), 2);
    res = autoStimulus(cerestim, pairs(2,1), 3);
    res = autoStimulus(cerestim, pairs(2,2), 4);
    res = autoStimulus(cerestim, pairs(3,1), 5);
    res = autoStimulus(cerestim, pairs(3,2), 6);
    res = autoStimulus(cerestim, pairs(4,1), 7);
    res = autoStimulus(cerestim, pairs(4,2), 8);
    res = autoStimulus(cerestim, pairs(5,1), 9);
    res = autoStimulus(cerestim, pairs(5,2), 10);
    res = autoStimulus(cerestim, pairs(6,1), 11);
    res = autoStimulus(cerestim, pairs(6,2), 12);
    res = endOfGroup(cerestim);
    res = endOfSequence(cerestim);

    stimchans(currtrial,1:12) = [pairs(1,1),pairs(1,2),pairs(2,1),pairs(2,2),pairs(3,1),pairs(3,2),pairs(4,1),pairs(4,2),pairs(5,1),pairs(5,2),pairs(6,1),pairs(6,2)];
    fprintf('Stimulating at pairs A: %g - %g  AND  B: %g - %g AND C: %g - %g AND D: %g - %g AND E: %g - %g AND F: %g - %g.\n',pairs(1,1),pairs(1,2),pairs(2,1),pairs(2,2),pairs(3,1),pairs(3,2), pairs(4,1),pairs(4,2),pairs(5,1),pairs(5,2),pairs(6,1),pairs(6,2));
    fprintf(logfile,'%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%g\n\r',n,pairs(1,1),pairs(1,2),pairs(2,1),pairs(2,2),pairs(3,1),pairs(3,2),pairs(4,1),pairs(4,2),pairs(5,1),pairs(5,2),pairs(6,1),pairs(6,2),pulses,amplitude,pulsewidth,frequency,interphase,trialinterval);
    fprintf(logfile,'\n\r');


    % RUN
    res = cerestim.play(1);


    disp([ num2str(currtrial),' of ',num2str(TrialTotal),' trials '])
    fprintf('Pausing for %g s.\n',trialinterval)
    pause(trialinterval);

    fprintf('\n')
    currtrial = currtrial + 1;

end


function cleanupfunction(cerestim,logfile)
    disconnect(cerestim);
    delete(cerestim);
    fclose(logfile);
end


end

