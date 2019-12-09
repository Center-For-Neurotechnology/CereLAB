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

numtrials = 4; 

stimamplitude = 4000; %in uA

stimchans1 = [27 28]; 
stimchans2 = [27 28;73 74]; 

trainlength = 400; % in mss

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

freqs = repmat(frequencies,[1 length(delays)*numtrials*size(stimchans2,1)]);
dels = zeros(1, length(delays)*length(frequencies)*numtrials*size(stimchans2,1));
chans2a = zeros(2, length(delays)*length(frequencies)*numtrials*size(stimchans2,1));
chans2=zeros(2, length(delays)*length(frequencies)*numtrials*size(stimchans2,1));
for i = 1:length(delays)
    dels((i-1)*length(frequencies)*size(stimchans2,1)*numtrials+1:i*length(frequencies)*size(stimchans2,1)*numtrials) ...
        = delays(i);
end

for i = 1:size(stimchans2,1)
    chans2a(1,(i-1)*length(frequencies)*numtrials*length(delays)+1:i*length(frequencies)*numtrials*length(delays)) ...
        = stimchans2(i,1);
    chans2a(2,(i-1)*length(frequencies)*numtrials*length(delays)+1:i*length(frequencies)*numtrials*length(delays)) ...
        = stimchans2(i,2);
end
chans2(1,1:2:size(chans2a,2))=chans2a(1,1:size(chans2a,2)/2);
chans2(2,1:2:size(chans2a,2))=chans2a(2,1:size(chans2a,2)/2);
chans2(1,2:2:size(chans2a,2))=chans2a(1,1+size(chans2a,2)/2:size(chans2a,2));
chans2(2,2:2:size(chans2a,2))=chans2a(2,1+size(chans2a,2)/2:size(chans2a,2));

%%
randidx = randperm(length(dels));

cerestim = BStimulator();
connx = connect(cerestim);

if connx < 0
    error('Can''t connect to cerestim')
end

filename = datestr(now);
filename = strrep(filename,' ','_');
filename = strrep(filename,':','-');
logfile = fopen(['C:/Stimulation/TrainPlusPulseMultLocs-',num2str(stimamplitude/1000),'ma', filename '.txt'], 'a');
fprintf(logfile,'Logfile for TrainPlusPulse %s\n\r',filename);
fprintf(logfile,'\n\r');
fprintf(logfile,'\n\r');
fprintf(logfile,'Frequencies:\n\r');
fprintf(logfile,'\n\r');
for i = 1:length(frequencies)
    fprintf(logfile,'%d\t',frequencies(i));
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
fprintf(logfile,'Number of trials per condition is %d.\n\r',numtrials);
fprintf(logfile,'\n\r');
fprintf(logfile,'Stimulation amplitude is %d mA.\n\r',stimamplitude);
fprintf(logfile,'\n\r');
fprintf(logfile,'Stimulation channels are %d-%d.\n\r',stimchans1(1), stimchans1(2));
fprintf(logfile,'\n\r');
fprintf(logfile,'2nd stimulation channels are %d-%d.\n\r',stimchans2(2,1), stimchans2(2,2));
fprintf(logfile,'\n\r');
fprintf(logfile,'Stimulation train length is %d ms.\n\r\n\r',trainlength);
fprintf(logfile,'\n\r');
fprintf(logfile,'\n\r');
fprintf(logfile,'Trial\tFrequency\tDelay\tChannel1\tChannel2\n\r');
fprintf(logfile,'\n\r');

pause on

res = configureStimulusPattern(cerestim, 1, 'AF', 1, ...
        stimamplitude, stimamplitude, 90, 90, 1000, 53);
res = configureStimulusPattern(cerestim, 2, 'CF', 1, ...
        stimamplitude, stimamplitude, 90, 90, 1000, 53);

trial = 1;
for tr = randidx
    
    if (freqs(tr) > 15)
        res = configureStimulusPattern(cerestim, 3, 'AF', ...
            floor(freqs(tr)*trainlength/1000), stimamplitude, stimamplitude, ...
            90, 90, freqs(tr), 53);
        res = configureStimulusPattern(cerestim, 4, 'CF', ...
            floor(freqs(tr)*trainlength/1000), stimamplitude, stimamplitude, ...
            90, 90, freqs(tr), 53);

        res = beginningOfSequence(cerestim);
        res = beginningOfGroup(cerestim);
        res = autoStimulus(cerestim, stimchans1(1), 3);
        res = autoStimulus(cerestim, stimchans1(2), 4);
        res = endOfGroup(cerestim);
        res = wait(cerestim, dels(tr));
        res = beginningOfGroup(cerestim);
        res = autoStimulus(cerestim, chans2(1,tr), 1);
        res = autoStimulus(cerestim, chans2(2,tr), 2);
        res = endOfGroup(cerestim);
        res = endOfSequence(cerestim);

        res = play(cerestim,1);
    else
        res = configureStimulusPattern(cerestim, 3, 'AF', ...
            1, stimamplitude, stimamplitude, ...
            90, 90, 1000/(1000/freqs(tr) - floor(1000/freqs(tr))+1), 53);
        res = configureStimulusPattern(cerestim, 4, 'CF', ...
            1, stimamplitude, stimamplitude, ...
            90, 90, 1000/(1000/freqs(tr) - floor(1000/freqs(tr))+1), 53);
        
        res = beginningOfSequence(cerestim);
        res = beginningOfGroup(cerestim);
        res = autoStimulus(cerestim, stimchans1(1), 3);
        res = autoStimulus(cerestim, stimchans1(2), 4);
        res = endOfGroup(cerestim);
        res = wait(cerestim, floor(1000/freqs(tr))-1);
        res = endOfSequence(cerestim);
        
        res = play(cerestim,floor(freqs(tr)*trainlength/1000));
        
        status = readSequenceStatus(cerestim);
        while (status == 2)
            status = readSequenceStatus(cerestim);
        end
        
        res = beginningOfSequence(cerestim);
        res = wait(cerestim, dels(tr));
        res = beginningOfGroup(cerestim);
        res = autoStimulus(cerestim, chans2(1,tr), 1);
        res = autoStimulus(cerestim, chans2(2,tr), 2);
        res = endOfGroup(cerestim);
        res = endOfSequence(cerestim);
        
        res = play(cerestim,1);
    end
            
 fprintf(logfile,'%d\t%d\t%d\t%d\t%d\t%d\t%d\n\r',trial,freqs(tr),dels(tr),stimchans1(1),stimchans1(2),chans2(1,tr),chans2(2,tr));
    fprintf(logfile,'\n\r');
    disp(sprintf('Trial %d, of %d, Frequency %d, Delay %d, Pulse pair 1: %d, Pulse pair 2: %d\n',trial,length(randidx),freqs(tr),dels(tr), stimchans1(1),chans2(1,tr)))
 
%         disp(sprintf('Total Trials %d\n',numtrial))

    trial = trial+1;
    
    pause(intertrialinterval+(2*rand-1)*1.0);
    
end


disconnect(cerestim);
delete(cerestim);
fclose(logfile);
save(['C:\Stimulation\TrainPlusPulseMultLocs',num2str(stimamplitude/1000),'maLocs-' filename],...
    'dels','freqs','stimchans1','stimchans2','chans2','tr','stimamplitude')