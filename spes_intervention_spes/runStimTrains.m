function stimMatrix = runStimTrains(pair,freq,intertrialinterval,ntrials,amplitude,trainlength, pulsewidth, jitterinterval)
%   Runs the stimulation trains experiment, where it stimulates the given bipolar site
%   with trains of pulses.  Assuming 20 trials (the standard), the program 
%   will take 108 seconds to run.
%
%   INPUTS
%  pair               a 1x2 matrix with the channel pair to be stimulated
%  freq               an integer with frequency of train stimulation
%  ntrials            an integer with the number of trials to run (usually 20)
%  intertrialinterval an integar with delay between each trial (in seconds)
%  amplitude          an integar with amplitude of stimulation pulse in uA
%  trainlength        an integar specifying length of pulse train in us
%  pulsewidth         an integar with width of the pulse in one phase in uS
%  jitterinterval     an integar flag which is 0 or 1, signifying presence
%                     of a jitter. 1- jitter, 0 - no jitter.

% hard coded config
interphase  = 53;

cerestim = BStimulator();
connx = connect(cerestim);

if connx < 0
    error('Can''t connect to cerestim')
end

filename = datestr(now);
filename = strrep(filename,' ','_');
filename = strrep(filename,':','-');
diary(['C:/Stimulation/StimTrainsDiary-' filename]);

logfile = fopen(['C:/Stimulation/StimTrains-',num2str(amplitude/1000),'-ma', filename '.txt'], 'a');
fprintf(logfile,'Logfile for Stim Trains %s\n\r',filename);
fprintf(logfile,'\n\r');
fprintf(logfile,'\n\r');
fprintf(logfile,'Frequncy:\n\r');
fprintf(logfile,'\n\r');
fprintf(logfile,'%d\t',freq);
fprintf(logfile,'\n\r');
fprintf(logfile,'\n\r');
fprintf(logfile,'\n\r');
fprintf(logfile,'Inter-trial Interval is %d seconds.\n\r',intertrialinterval);
fprintf(logfile,'\n\r');
fprintf(logfile,'Number of trials per condition is %d.\n\r',ntrials);
fprintf(logfile,'\n\r');
fprintf(logfile,'Stimulation amplitude is %d mA.\n\r',amplitude);
fprintf(logfile,'\n\r');
fprintf(logfile,'Stimulation channels are %d-%d.\n\r',pair(1), pair(2));
fprintf(logfile,'\n\r');
fprintf(logfile,'Stimulation train length is %d ms.\n\r\n\r',trainlength);
fprintf(logfile,'\n\r');
fprintf(logfile,'\n\r');
fprintf(logfile,'Trial\tChannel1\tChannel2\tPulses\tAmplitude\tTrainLength\tFrequency\n\r');

fprintf(logfile,'\n\r');
%%
pause on
pulses  = 1;
frequency = 1000;
res = configureStimulusPattern(cerestim, 1, 'AF', pulses, ...
        amplitude, amplitude, pulsewidth, pulsewidth, frequency, interphase);
res = configureStimulusPattern(cerestim, 2, 'CF', pulses, ...
        amplitude, amplitude, pulsewidth, pulsewidth, frequency, interphase);
stimMatrix=[];
trial = 1;

for tr = 1:ntrials
    
    % for freq> 15, we can use inbuilt functions to deliver pulse trains
    if (freq > 15)
        pulses = floor(freq*trainlength/1000);
        frequency = freq;
        res = configureStimulusPattern(cerestim, 3, 'AF', ...
            pulses, amplitude, amplitude, ...
            pulsewidth, pulsewidth,frequency, interphase);
        res = configureStimulusPattern(cerestim, 4, 'CF', ...
            pulses, amplitude, amplitude, ...
            pulsewidth, pulsewidth, frequency, interphase);

        res = beginningOfSequence(cerestim);
        res = beginningOfGroup(cerestim);
        res = autoStimulus(cerestim, pair(1), 3);
        res = autoStimulus(cerestim, pair(2), 4);
        res = endOfGroup(cerestim);
        res = endOfSequence(cerestim);
        res = play(cerestim,1);

    else
    % for freq <15, we need to deliver pulse trains by timing delivery of 
    % single pulses. This is because the inbuilt function cannot handle
    % low frequency stimulation.
        pulses = 1;
%         frequency = 1000/(1000/freq - floor(1000/freq)+1);
        frequency = 100;
        res = configureStimulusPattern(cerestim, 3, 'AF', ...
            pulses, amplitude, amplitude, ...
            pulsewidth, pulsewidth, frequency, interphase);
        res = configureStimulusPattern(cerestim, 4, 'CF', ...
            pulses, amplitude, amplitude, ...
            pulsewidth, pulsewidth, frequency, interphase);
        
        res = beginningOfSequence(cerestim);
        res = beginningOfGroup(cerestim);
        res = autoStimulus(cerestim, pair(1), 3);
        res = autoStimulus(cerestim, pair(2), 4);
        res = endOfGroup(cerestim);
        res = wait(cerestim, floor(1000/freq)-1);
        res = endOfSequence(cerestim);
        
        res = play(cerestim,floor(freq*trainlength/1000));
        
        status = readSequenceStatus(cerestim);
        while (status == 2)
            status = readSequenceStatus(cerestim);
        end
        
    end

    stimMatrix(trial,:) = [trial pair ntrials amplitude trainlength freq ];
%     fprintf(logfile,'%d\t%d\t%d\n\r',trial,freq,dels(tr));
    fprintf(logfile,'%d\t%d\t%d\t%d\t%d\t%d\t%d\n\r',trial,pair(1),pair(2),pulses,amplitude,trainlength,freq);
    fprintf(logfile,'\n\r');
    fprintf('Trial %d of %d, Frequency %d \n\n',trial,ntrials,freq)
    trial = trial+1;
    
   pause(intertrialinterval+(2*rand-1)*0.2*jitterinterval);
    
end


disconnect(cerestim);
delete(cerestim);
fclose(logfile);

save(['C:/Stimulation/StimTrains-',char(filename),'.mat'],'stimMatrix')

end