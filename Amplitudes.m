function amps = Amplitudes(stimchans)

cerestim = BStimulator();
connect(cerestim);

if connx < 0
    error('Can''t connect to cerestim')
end

filename = datestr(now);
filename = strrep(filename,' ','_');
filename = strrep(filename,':','-');
logfile = fopen(['C:/Stimulation/Amplitudes-' filename '.txt'], 'a');

c = onCleanup(@()cleanupfunction(cerestim,logfile));

fprintf(logfile,'Logfile for Amplitudes %s\n\r',filename);
fprintf(logfile,'\n\r');
fprintf(logfile,'\n\r');
fprintf(logfile,'Stimulation channels are %d-%d.\n\r',stimchans(1), stimchans(2));
fprintf(logfile,'\n\r');
fprintf(logfile,'Trial\tAmplitude\n\r');
fprintf(logfile,'\n\r');

amps = zeros(1,100);
for i = 1:7
    res = configureStimulusPattern(cerestim, 2*i-1, 'AF', 1, 500*i, 500*i, 90, 90, 1000, 53);
    res = configureStimulusPattern(cerestim, 2*i, 'CF', 1, 500*i, 500*i, 90, 90, 1000, 53);
end
for tr = 1:5
    order = randperm(7);
    cerestim.beginningOfSequence();
    for amp = 1:7
        cerestim.beginningOfGroup();
        cerestim.autoStimulus(stimchans(1),order(amp)*2-1);
        cerestim.autoStimulus(stimchans(2),order(amp)*2);
        cerestim.endOfGroup();
        cerestim.wait(2500+randi(500));
        amps(1,(tr-1)*7+amp) = 500*order(amp);
        fprintf(logfile,'%d\t%d\n\r',(tr-1)*7+amp,500*order(amp));
        fprintf(logfile,'\n\r');
    end
    cerestim.endOfSequence();
    cerestim.play(1);
end

for i = 1:7
    res = configureStimulusPattern(cerestim, 2*i-1, 'AF', 1, 3500 + 500*i, 3500 + 500*i, 90, 90, 1000, 53);
    res = configureStimulusPattern(cerestim, 2*i, 'CF', 1, 3500 + 500*i, 3500 + 500*i, 90, 90, 1000, 53);
end
for tr = 1:5
    order = randperm(7);
    cerestim.beginningOfSequence();
    for amp = 1:7
        cerestim.beginningOfGroup();
        cerestim.autoStimulus(stimchans(1),order(amp)*2-1);
        cerestim.autoStimulus(stimchans(2),order(amp)*2);
        cerestim.endOfGroup();
        cerestim.wait(2500+randi(500));
        amps(1,35+(tr-1)*7+amp) = 3500 + 500*order(amp);
        fprintf(logfile,'%d\t%d\n\r',35+(tr-1)*7+amp,500*order(amp));
        fprintf(logfile,'\n\r');
    end
    cerestim.endOfSequence();
    cerestim.play(1);
end

for i = 1:6
    res = configureStimulusPattern(cerestim, 2*i-1, 'AF', 1, 7000 + 500*i, 7000 + 500*i, 90, 90, 1000, 53);
    res = configureStimulusPattern(cerestim, 2*i, 'CF', 1, 7000 + 500*i, 7000 + 500*i, 90, 90, 1000, 53);
end
for tr = 1:5
    order = randperm(6);
    cerestim.beginningOfSequence();
    for amp = 1:6
        cerestim.beginningOfGroup();
        cerestim.autoStimulus(stimchans(1),order(amp)*2-1);
        cerestim.autoStimulus(stimchans(2),order(amp)*2);
        cerestim.endOfGroup();
        cerestim.wait(2500+randi(500));
        amps(1,70+(tr-1)*6+amp) = 7000 + 500*order(amp);
        fprintf(logfile,'%d\t%d\n\r',70+(tr-1)*7+amp,500*order(amp));
        fprintf(logfile,'\n\r');
    end
    cerestim.endOfSequence();
    cerestim.play(1);
end

end

function cleanupfunction(cerestim,logfile)

disconnect(cerestim);
delete(cerestim);
fclose(logfile);

end
