%%%%%%%% edit these values %%%%%%%%

frequencies = [ 10 ...
                20  ...
                40  ...
                80  ...
                100 ...
                160 ...
                200 ];
            
delays = [ 150 ...
           250 ...
           500 ...
           1000];
       
intertrialinterval = 5; % in seconds

numtrials = 5; 

stimamplitude = 7000; %in mA

stimchans = [1 2]; 

trainlength = 400; % in ms

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

freqs = repmat(frequencies,[1 length(delays)*numtrials]);
dels = zeros(1, length(delays)*length(frequencies)*numtrials);
for i = 1:length(delays)
    dels((i-1)*length(frequencies)*numtrials+1:i*length(frequencies)*numtrials) ...
        = delays(i);
end

randidx = randperm(length(dels));

cerestim = BStimulator();
connx = connect(cerestim);

if connx < 0
    error('Can''t connect to cerestim')
end

filename = datestr(now);
filename = replace(filename,' ','_');
filename = replace(filename,':','-');
logfile = fopen(['C:/Stimulation/' filename '.txt'], 'a');
fprintf(logfile,'Logfile for %s\n\r\n\r',filename);
fprintf(logfile,'Frequencies:\n\r');
for i = 1:length(frequencies)
    fprintf(logfile,'%d\t',frequencies(i));
end
fprintf(logfile,'\n\r\n\rDelays\n\r');
for i = 1:length(delays)
    fprintf(logfile,'%d\t',delays(i));
end
fprintf(logfile,'\n\r\n\rInter-trial Interval is %d seconds\n\r',intertrialinterval);
fprintf(logfile,'Number of trials per condition is %d.\n\r',numtrials);
fprintf(logfile,'Stimulation amplitude is %d mA.\n\r',stimamplitude);
fprintf(logfile,'Stimulation channels are %d-%d.\n\r',stimchans(1), stimchans(2));
fprintf(logfile,'Stimulation train length is %d ms.\n\r\n\r',trainlength);
fprintf(logfile,'Trial\tFrequency\tDelay\n\r');

pause on

res = configureStimulusPattern(cerestim, 1, 'AF', 1, ...
        stimamplitude, stimamplitude, 90, 90, 1000, 53);
res = configureStimulusPattern(cerestim, 2, 'CF', 1, ...
        stimamplitude, stimamplitude, 90, 90, 1000, 53);

trial = 1;
for tr = randidx
    
    res = configureStimulusPattern(cerestim, 3, 'AF', ...
        floor(freqs(tr)*trainlength/1000), stimamplitude, stimamplitude, ...
        90, 90, freqs(tr), 53);
    res = configureStimulusPattern(cerestim, 4, 'CF', ...
        floor(freqs(tr)*trainlength/1000), stimamplitude, stimamplitude, ...
        90, 90, freqs(tr), 53);
    
    res = beginningOfSequence(cerestim);
    res = beginningOfGroup(cerestim);
    res = autoStimulus(cerestim, stimchans(1), 3);
    res = autoStimulus(cerestim, stimchans(2), 4);
    res = wait(cerestim, dels(tr));
    res = autoStimulus(cerestim, stimchans(1), 1);
    res = autoStimulus(cerestim, stimchans(2), 2);
    res = endOfGroup(cerestim);
    res = endOfSequence(cerestim);
    
    res = play(cerestim,1);
    
    fprintf(logfile,'%d\t%d\t%d\n\r',trial,freqs(tr),dels(tr));
    sprintf('Trial %d, Frequency %d, Delay %d\n',trial,freqs(tr),dels(tr))
    
    pause(intertrialinterval);
    
end


disconnect(cerestim);
delete(cerestim);
fclose(logfile);