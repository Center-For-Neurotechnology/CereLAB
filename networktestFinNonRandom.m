function stimchans = networktestFinNonRandom(pairs, ntrials,intertrialinterval,amplitude,pulses,pulsewidth,frequency,interphase,trainlength,jitterinterval,intervalburstduration,delay)
%function stimchans = networktest(pairs, ntrials)
%
%   Runs the "network" experiment, where it pseudo-randomly selects
%   channels from the pairs list to stimulate with single pulses.  Assuming
%   20 trials (the standard), the program will take one minute per
%   stimulation pair to run.
%
%   INPUTS
%
%   pairs       an nx2 matrix with the channel pairs to be stimulated
%   ntrials     an integer with the number of trials to run (usually 20)

cerestim = BStimulator();
connx = connect(cerestim);

if connx < 0
    error('Can''t connect to cerestim')
end

filename = datestr(now);
filename = strrep(filename,' ','_');
filename = strrep(filename,':','-');
logfile = fopen(['C:/Stimulation/Network-' filename '.txt'], 'a');

c = onCleanup(@()cleanupfunction(cerestim,logfile));

pause on

% res = configureStimulusPattern(cerestim, 1, 'AF', 1, ...
%     7000, 7000, 90, 90, 100, 53);
% res = configureStimulusPattern(cerestim, 2, 'CF', 1, ...
%     7000, 7000, 90, 90, 100, 53);
res = configureStimulusPattern(cerestim, 1, 'AF', pulses, ...
    amplitude, amplitude, pulsewidth, pulsewidth, frequency, interphase);
res = configureStimulusPattern(cerestim, 2, 'CF', pulses, ...
    amplitude, amplitude, pulsewidth, pulsewidth, frequency, interphase);


stimchans = zeros(ntrials*size(pairs,1),13);
currtrial = 1;

fprintf(logfile,'Logfile for Network %s\n\r',filename);
fprintf(logfile,'\n\r');
fprintf(logfile,'\n\r');
fprintf(logfile,'Trial\tChannel1\tChannel2\tPulses\tAmplitude\tPulsewidth\tFrequency\tInterphase\tTrialInterval\n\r');
fprintf(logfile,'\n\r');
TrialTotal=ntrials*size(pairs,1);
count=1;
for n = 1:ntrials
    fprintf('Trial %g.\n',n);
    j = randperm(size(pairs,1)); 
    j = 1:size(pairs,1);
    for k = 1:length(j) % p = randperm(size(pairs,1))     
        
        p = j(k);
        trialinterval=intertrialinterval+jitterinterval*(2*rand-1)*0.2;
        
        res = beginningOfSequence(cerestim);
        res = beginningOfGroup(cerestim);
        res = autoStimulus(cerestim, pairs(p,1), 1);
        res = autoStimulus(cerestim, pairs(p,2), 2); 
        res = endOfGroup(cerestim);
        res = endOfSequence(cerestim);
        
        fprintf('Stimulating at pair %g - %g.\n',pairs(p,1),pairs(p,2))
        fprintf('at %g microA.\n',amplitude)
%             'at %g microA.\n',amplitude,...
%             'with %g pulses per trial.\n',pulses,...
%             'with %g ms pulsewidth.\n',pulsewidth,...
%             'with %g Hz frequency.\n',frequency,...
%             'with %g ms interphase.\n',interphase,...
%             'with %g sec average inter-trial interval.\n',trialinterval);
        fprintf(logfile,'%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%g\n\r',n,pairs(p,1),pairs(p,2),pulses,amplitude,pulsewidth,frequency,interphase,trialinterval);
        fprintf(logfile,'\n\r');
        stimchans(currtrial,:) = [n pairs(p,:) pulses amplitude pulsewidth frequency interphase trialinterval trainlength jitterinterval intervalburstduration delay];
        currtrial = currtrial + 1;
        res = cerestim.play(1);
        
        disp([ num2str(count),' of ',num2str(TrialTotal),' trials ',num2str(pairs(p,1)),'-',num2str(pairs(p,2))])
count=count+1;
        fprintf('Pausing for %g s.\n',trialinterval)
                pause(trialinterval);

        
        fprintf('\n')
        
    end
end
        
end

function cleanupfunction(cerestim,logfile)

disconnect(cerestim);
delete(cerestim);
fclose(logfile);

end

