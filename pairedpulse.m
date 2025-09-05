%%%%%%%% edit these values %%%%%%%%

frequencies = [ 1 ...
    ];
            
delays = [ 50 ...
           100 ...
           150 ...
           250 ...
           500 ...
           1000];
       
intertrialinterval = 5; % in seconds

numtrials = 5; 

stimamplitude = 6000; %in uA

stimchans1 = [9 10]; 
stimchans2 = [9 10;28 29]; 

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

MatrixCheck=[freqs' dels' chans2'];

% tri=[];
% for fr=1:length(frequencies)
%     for d=1:length(delays)
%         for c=1:size(stimchans2,1)
%             MC=find(MatrixCheck(:,1)==frequencies(fr) &...
%                 MatrixCheck(:,2)==delays(d) &...
%                  MatrixCheck(:,3)==stimchans2(c,1)); 
%             tri(fr,d,c)=length(MC);
%         end
%     end
% end

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
logfile = fopen(['C:/Stimulation/PairedPulseMulti',num2str(stimamplitude/1000),'maLocs-' filename '.txt'], 'a');
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
fprintf(logfile,'Stimulation pulse length is %d ms.\n\r\n\r',trainlength);
fprintf(logfile,'\n\r');
fprintf(logfile,'\n\r');
fprintf(logfile,'Trial\tFrequency\tDelay\tChannel1\tChannel2\n\r');
fprintf(logfile,'\n\r');

pause on

res = configureStimulusPattern(cerestim, 1, 'AF', 1, ...
        stimamplitude, stimamplitude, 90, 90, 100, 53);
res = configureStimulusPattern(cerestim, 2, 'CF', 1, ...
        stimamplitude, stimamplitude, 90, 90, 100, 53);

trial = 1;
for tr = randidx


        res = beginningOfSequence(cerestim);
        res = beginningOfGroup(cerestim);
        res = autoStimulus(cerestim, stimchans1(1), 1);
        res = autoStimulus(cerestim, stimchans1(2), 2);
        res = endOfGroup(cerestim);
        res = wait(cerestim, dels(tr));
        res = beginningOfGroup(cerestim);
        res = autoStimulus(cerestim, chans2(1,tr), 1);
        res = autoStimulus(cerestim, chans2(2,tr), 2);
        res = endOfGroup(cerestim);
        res = endOfSequence(cerestim);

        res = play(cerestim,1);
   
            
    fprintf(logfile,'%d\t%d\t%d\t%d\t%d\t%d\t%d\n\r',trial,freqs(tr),dels(tr),stimchans1(1),stimchans1(2),chans2(1,tr),chans2(2,tr));
    fprintf(logfile,'\n\r');
    disp(sprintf('Trial %d, of %d, Frequency %d, Delay %d, Pulse pair 1: %d, Pulse pair 2: %d\n',trial,length(randidx),freqs(tr),dels(tr), stimchans1(1),chans2(1,tr)))
    trial = trial+1;
    
    pause(intertrialinterval+(2*rand-1)*1.0);
    
end


disconnect(cerestim);
delete(cerestim);
fclose(logfile);
save(['C:\Stimulation\PairedPulseMulti',num2str(stimamplitude/1000),'maLocs-' filename],...
    'dels','freqs','stimchans1','stimchans2','chans2','tr','stimamplitude')