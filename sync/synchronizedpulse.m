%%%%%%%% edit these values %%%%%%%%

frequencies = [ 1 ...
    ];
            
delays = [ 0];
       
intertrialinterval = 5; % in seconds

numtrials = 10; 

stimamplitude = 7000; %in uA

stimchans1 = [3 4]; 
stimchans2 = [3 4;50 51]; 

SyncTrialNum=1:10;

trainlength = 0; % in mss
TotTrials=length(SyncTrialNum)+numtrials*4;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

freqs = repmat(frequencies,[1 length(delays)*numtrials*size(stimchans2,1)]);
dels = zeros(1, length(delays)*length(frequencies)*numtrials*size(stimchans2,1));
chans2a = zeros(2, length(delays)*length(frequencies)*numtrials*size(stimchans2,1));
chans2=zeros(2, length(delays)*length(frequencies)*numtrials*size(stimchans2,1));
chanspaired=zeros(4, length(delays)*length(frequencies)*numtrials*size(stimchans2,1));
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

chanspaired(1,1:size(chans2,2))=stimchans2(1,1);
chanspaired(2,1:size(chans2,2))=stimchans2(1,2);
chanspaired(3,1:size(chans2,2))=stimchans2(2,1);
chanspaired(4,1:size(chans2,2))=stimchans2(2,2);

MatrixCheck=[freqs' dels' chans2' chanspaired'];

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
randidx = randperm(length(chans2(1,:)));

cerestim = BStimulator();
connx = connect(cerestim);

if connx < 0
    error('Can''t connect to cerestim')
end

filename = datestr(now);
filename = strrep(filename,' ','_');
filename = strrep(filename,':','-');
logfile = fopen(['C:/Stimulation/SyncPulseMulti',num2str(stimamplitude/1000),'maLocs-' filename '.txt'], 'a');
fprintf(logfile,'Logfile for SyncPulse %s\n\r',filename);
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
res = configureStimulusPattern(cerestim, 1, 'AF', 1, ...
        stimamplitude, stimamplitude, 90, 90, 100, 53);
res = configureStimulusPattern(cerestim, 2, 'CF', 1, ...
        stimamplitude, stimamplitude, 90, 90, 100, 53);
    
    stimPairedPulse=[];

trial = 1;
for tr = randidx


        res = beginningOfSequence(cerestim);
        res = beginningOfGroup(cerestim);
        res = autoStimulus(cerestim, chans2(1,tr), 1);
        res = autoStimulus(cerestim, chans2(2,tr), 2);
        res = endOfGroup(cerestim);
        res = endOfSequence(cerestim);

        res = play(cerestim,1);
   
    stimPairedPulse(trial,:) = [tr stimchans1 chans2(1,tr) chans2(2,tr) numtrials stimamplitude trainlength freqs(tr) dels(tr)];  
 
    fprintf(logfile,'%d\t%d\t%d\t%d\t%d\t%d\t%d\n\r',trial,freqs(tr),dels(tr),chans2(1,tr),chans2(2,tr),0,0);
    fprintf(logfile,'\n\r');
    disp(sprintf('Trial %d, of %d, Single site, Frequency %d, Delay %d, Pulse pair 1: %d, Pulse pair 2: %d\n',trial,TotTrials,freqs(tr),dels(tr), chans2(1,tr),chans2(2,tr)))
    trial = trial+1;
    
    pause(intertrialinterval+(2*rand-1)*1.0);
    
end

cerestim = BStimulator();
connx = connect(cerestim);

res = configureStimulusPattern(cerestim, 1, 'AF', 1, ...
        stimamplitude, stimamplitude, 90, 90, 100, 53);
res = configureStimulusPattern(cerestim, 2, 'CF', 1, ...
        stimamplitude, stimamplitude, 90, 90, 100, 53);
res = configureStimulusPattern(cerestim, 3, 'AF', 1, ...
        stimamplitude, stimamplitude, 90, 90, 100, 53);
res = configureStimulusPattern(cerestim, 4, 'CF', 1, ...
        stimamplitude, stimamplitude, 90, 90, 100, 53);
    
    
for tr = SyncTrialNum


        res = beginningOfSequence(cerestim);
        res = beginningOfGroup(cerestim);
        res = autoStimulus(cerestim, chanspaired(1,tr), 1);
        res = autoStimulus(cerestim, chanspaired(2,tr), 2);
        res = autoStimulus(cerestim, chanspaired(3,tr), 3);
        res = autoStimulus(cerestim, chanspaired(4,tr), 4);
        res = endOfGroup(cerestim);
        res = endOfSequence(cerestim);

        res = play(cerestim,1);
   
    stimPairedPulse(trial,:) = [tr chanspaired(1,tr) chanspaired(2,tr) chanspaired(3,tr) chanspaired(4,tr) numtrials stimamplitude trainlength freqs(tr) dels(tr)];  
 
    fprintf(logfile,'%d\t%d\t%d\t%d\t%d\t%d\t%d\n\r',trial,freqs(tr),dels(tr),chanspaired(1,tr),chanspaired(2,tr),chanspaired(3,tr),chanspaired(4,tr));
    fprintf(logfile,'\n\r');
    disp(sprintf('Trial %d, of %d, Paired sites, Frequency %d, Delay %d, Sync pulse pair 1: %d, Sync pulse pair 2: %d\n',trial,TotTrials,freqs(tr),dels(tr), chanspaired(1,tr),chanspaired(3,tr)))
    trial = trial+1;
    pause(intertrialinterval+(2*rand-1)*2.0);
    
end

cerestim = BStimulator();
connx = connect(cerestim);

res = configureStimulusPattern(cerestim, 1, 'AF', 1, ...
        stimamplitude, stimamplitude, 90, 90, 100, 53);
res = configureStimulusPattern(cerestim, 2, 'CF', 1, ...
        stimamplitude, stimamplitude, 90, 90, 100, 53);
res = configureStimulusPattern(cerestim, 1, 'AF', 1, ...
        stimamplitude, stimamplitude, 90, 90, 100, 53);
res = configureStimulusPattern(cerestim, 2, 'CF', 1, ...
        stimamplitude, stimamplitude, 90, 90, 100, 53);
    
for tr = randidx


        res = beginningOfSequence(cerestim);
        res = beginningOfGroup(cerestim);
        res = autoStimulus(cerestim, chans2(1,tr), 1);
        res = autoStimulus(cerestim, chans2(2,tr), 2);
        res = endOfGroup(cerestim);
        res = endOfSequence(cerestim);

        res = play(cerestim,1);
   
    stimPairedPulse(trial,:) = [tr stimchans1 chans2(1,tr) chans2(2,tr) numtrials stimamplitude trainlength freqs(tr) dels(tr)];  
 
    fprintf(logfile,'%d\t%d\t%d\t%d\t%d\t%d\t%d\n\r',trial,freqs(tr),dels(tr),chans2(1,tr),chans2(2,tr),0,0);
    fprintf(logfile,'\n\r');
    disp(sprintf('Trial %d, of %d, Single site, Frequency %d, Delay %d, Pulse pair 1: %d, Pulse pair 2: %d\n',trial,TotTrials,freqs(tr),dels(tr), chans2(1,tr),chans2(2,tr)))
    trial = trial+1;
    
    pause(intertrialinterval+(2*rand-1)*1.0);
    
end

randidx = randperm(length(chans2(1,:)));

disconnect(cerestim);
delete(cerestim);
fclose(logfile);
save(['C:\Stimulation\SyncPulseMulti',num2str(stimamplitude/1000),'maLocs-' filename],...
    'dels','freqs','stimchans1','stimchans2','chans2','tr','stimamplitude','stimPairedPulse')
% save(['C:/Stimulation/PairedPulseMulti-',char(filename),'.mat'])


