function stim_parameters = networktest_burst_saveT(pairs, freqs, ntrials, n_samefreqRounds, stimamplitude, burstduration)
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
filename = strcat(filename, 'Chulab');
logfile = fopen(['C:/Stimulation/NetworkLogWen-' filename '.txt'], 'a');
% logfile = fopen(['D:\Dropbox (MGH Chu Lab)\Wen\STIM\TestRun\NetworkParameter-' filename '.txt'], 'a');

c = onCleanup(@()cleanupfunction(cerestim,logfile));

pause on

stim_parameters = zeros(ntrials*length(pairs)*n_samefreqRounds,3);
currtrial = 1;

fprintf(logfile,'Logfile for Network %s\n\r',filename);
fprintf(logfile,'\n\r');
fprintf(logfile,'\n\r');
fprintf(logfile,'Trial\tFreq\tRound\tChannel1\tChannel2\tCurrentTime\tElapsedTime\n\r');
fprintf(logfile,'\n\r');
T2save = table();
T2save_k = 0;
TrialTotal=ntrials*size(pairs,1)* length(freqs);
count=1;
tic;
for n = 1:ntrials
    fprintf('Trial %g start.\n',n);
    for s = randperm(length(freqs))
        freq_current = freqs(s);
%         fprintf('Frequency %g Hz.\n',freq_current);
        n_pulses = burstduration / (1/freq_current); % number of pulses sent within 100ms
        disp([ 'Pending trial ',num2str(n), '. Stim Frequency: ',num2str(freq_current),' Hz. Number of pulses sent within ', num2str(burstduration*1000),'ms: ',num2str(n_pulses)])

        if (freq_current > 15)
            res = configureStimulusPattern(cerestim, 1, 'AF', n_pulses, ...
                stimamplitude, stimamplitude, 100, 100, freq_current, 53);
            res = configureStimulusPattern(cerestim, 2, 'CF', n_pulses, ...
                stimamplitude, stimamplitude, 100, 100, freq_current, 53);

            %         for p = randperm(length(pairs))
            count_round = 1;
            for k = 1:n_samefreqRounds
                p = 1;
                res = beginningOfSequence(cerestim);
                res = beginningOfGroup(cerestim);
                res = autoStimulus(cerestim, pairs(p,1), 1);
                res = autoStimulus(cerestim, pairs(p,2), 2);
                res = endOfGroup(cerestim);
                res = endOfSequence(cerestim);
                ElapsedTime = toc;tic;
                fprintf('Stimulating at pair %g - %g at frequency %gHz. %d of 10 round %dms stims.\n',pairs(p,1),pairs(p,2), freq_current, count_round, burstduration*1000);
                currTime = datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSSSSS');
                fprintf(logfile,'%d\t%d\t%d\t%d\t%d\t%s\t%.6f\n\r',n,freq_current, count_round, pairs(p,1),pairs(p,2), currTime, ElapsedTime);
                fprintf(logfile,'\n\r');
                stim_parameters(currtrial,1:2) = pairs(p,:); % record for channels
                stim_parameters(currtrial,3) = freq_current; % record for frequency
                currtrial = currtrial + 1;
                res = cerestim.play(1);

%                 disp([ num2str(count_round),' of ',num2str(10),' round ', num2str(burstduration*1000),'ms stims ',num2str(pairs(p,1)),'-',num2str(pairs(p,2))])
                count_round =count_round+1;
                fprintf('Pausing for %gms.\n',900)
                pause(0.9);
                T2save_k = T2save_k + 1;
                T2save.Trial(T2save_k) = n;
                T2save.Freq(T2save_k) = freq_current;
                T2save.Round(T2save_k) = count_round;
                T2save.Channel1(T2save_k) = pairs(p,1);
                T2save.Channel2(T2save_k) = pairs(p,2);
                T2save.CurrentTime(T2save_k) = currTime;
                T2save.ElapsedTime(T2save_k) = ElapsedTime;
            end
        else
            res = configureStimulusPattern(cerestim, 3, 'AF', ...
                1, stimamplitude, stimamplitude, ...
                100, 100, 1000/(1000/freq_current - floor(1000/freq_current)+1), 53);
            res = configureStimulusPattern(cerestim, 4, 'CF', ...
                1, stimamplitude, stimamplitude, ...
                100, 100, 1000/(1000/freq_current - floor(1000/freq_current)+1), 53);
            count_round = 1;
            for k = 1:n_samefreqRounds
                p = 1;
                res = beginningOfSequence(cerestim);
                res = beginningOfGroup(cerestim);
                res = autoStimulus(cerestim, pairs(p,1), 3);
                res = autoStimulus(cerestim, pairs(p,2), 4);
                res = endOfGroup(cerestim);
                res = wait(cerestim, floor(1000/freq_current)-1);
                res = endOfSequence(cerestim);
                res = cerestim.play(1);
                %                 res = play(cerestim,floor(freq_current*burstduration));
                ElapsedTime = toc;tic;
                fprintf('Stimulating at pair %g - %g at frequency %gHz. %d of 10 round %dms stims.\n',pairs(p,1),pairs(p,2), freq_current, count_round, burstduration*1000);
                currTime = datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSSSSS');
                fprintf(logfile,'%d\t%d\t%d\t%d\t%d\t%s\t%.6f\n\r',n,freq_current, count_round, pairs(p,1),pairs(p,2), currTime, ElapsedTime);
                fprintf(logfile,'\n\r');
                stim_parameters(currtrial,1:2) = pairs(p,:); % record for channels
                stim_parameters(currtrial,3) = freq_current; % record for frequency
                currtrial = currtrial + 1;

%                 disp([ num2str(count_round),' of ',num2str(10),' round ', num2str(burstduration*1000),'ms stims ',num2str(pairs(p,1)),'-',num2str(pairs(p,2))])
                count_round =count_round+1;
                fprintf('Pausing for %gms.\n',900)
                pause(0.9);
                T2save_k = T2save_k + 1;
                T2save.Trial(T2save_k) = n;
                T2save.Freq(T2save_k) = freq_current;
                T2save.Round(T2save_k) = count_round;
                T2save.Channel1(T2save_k) = pairs(p,1);
                T2save.Channel2(T2save_k) = pairs(p,2);
                T2save.CurrentTime(T2save_k) = currTime;
                T2save.ElapsedTime(T2save_k) = ElapsedTime;
            end
            fprintf(logfile,'Trial\tFreq\tRound\tChannel1\tChannel2\tCurrentTime\tElapsedTime\n\r');


        end
        fprintf('Pausing for %g s.\n',5)
        pause(5);
        fprintf('\n')

    end
    disp([ num2str(count),' of ',num2str(ntrials),' trials ',num2str(pairs(p,1)),'-',num2str(pairs(p,2))])
    count=count+1;
    save(['C:/Stimulation/ChulablogfileT-' filename '.mat'],'T2save')
    %     save(['D:\Dropbox (MGH Chu Lab)\Wen\STIM\TestRun\ChulablogfileT-' filename '.mat'],'T2save')

    fprintf('\n')
end

end

function cleanupfunction(cerestim,logfile)

disconnect(cerestim);
delete(cerestim);
fclose(logfile);

end

