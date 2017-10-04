function res = singlepulses(stimchans,ntrials)

cerestim = BStimulator();
connect(cerestim);

if connx < 0
    error('Can''t connect to cerestim')
end

filename = datestr(now);
filename = strrep(filename,' ','_');
filename = strrep(filename,':','-');
logfile = fopen(['C:/Stimulation/SinglePulse-' filename '.txt'], 'a');

c = onCleanup(@()cleanupfunction(cerestim,logfile));

fprintf(logfile,'Logfile for SinglePulse %s\n\r',filename);
fprintf(logfile,'\n\r');
fprintf(logfile,'\n\r');
fprintf(logfile,'Stimulation channels are %d-%d.\n\r',stimchans(1), stimchans(2));
fprintf(logfile,'\n\r');
fprintf(logfile,'Number of trials: %d.\n\r',ntrials);
fprintf(logfile,'\n\r');

res = configureStimulusPattern(cerestim, 1, 'AF', 1, 7000, 7000, 90, 90, 1000, 53);
res = configureStimulusPattern(cerestim, 2, 'CF', 1, 7000, 7000, 90, 90, 1000, 53);

for tr = 1:ntrials
    cerestim.beginningOfSequence();
    cerestim.beginningOfGroup();
    cerestim.autoStimulus(stimchans(1),1);
    cerestim.autoStimulus(stimchans(2),2);
    cerestim.endOfGroup();
    cerestim.wait(2500+randi(500));
    cerestim.autoStimulus(stimchans(1),2);
    cerestim.autoStimulus(stimchans(2),1);
    cerestim.endOfGroup();
    cerestim.wait(2500+randi(500));
    cerestim.endOfSequence();
    cerestim.play(1);
end

end

function cleanupfunction(cerestim,logfile)

disconnect(cerestim);
delete(cerestim);
fclose(logfile);

end
