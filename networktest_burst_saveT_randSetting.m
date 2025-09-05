function [stim_parameters, T2save] = networktest_burst_saveT_randSetting(settings, ntrials, n_samefreqRounds, stimamplitude, burstduration)
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
Nsettings = size(settings,1);
cerestim = BStimulator();
connx = connect(cerestim);

%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% % uncomment the following three lines on actual test/run %%%%%
if connx < 0
    error('Can''t connect to cerestim')
end

filename = datestr(now);
filename = strrep(filename,' ','_');
filename = strrep(filename,':','-');
filename = strcat(filename, 'Chulab');
logfile = fopen(['C:/Stimulation/NetworkLogWen-' filename '.txt'], 'a');
c = onCleanup(@()cleanupfunction(cerestim,logfile));

pause on

TrialTotal=ntrials * Nsettings;
stim_parameters = zeros(TrialTotal*n_samefreqRounds,3);

fprintf(logfile,'Logfile for Network %s\n\r',filename);
fprintf(logfile,'\n\r');
fprintf(logfile,'\n\r');
fprintf(logfile,'Trial\tFreq\tRound\tChannel1\tChannel2\tCurrentTime\tElapsedTime\n\r');
fprintf(logfile,'\n\r');
T2save = table();
T2save_k = 0;

currtrial = 1;
count=1;
tic;
for n = 1:ntrials
    fprintf('Trial %g start.\n',n);
    RandOrder_current = randperm(Nsettings);
    disp(['Random order: ', num2str(RandOrder_current)])
    for s = RandOrder_current
        setting_current = settings(s,:);
        pair_current = setting_current(1:2); % the first two para are the stim contacts
        freq_current = setting_current(3); % the third para is the stim frequency
        if s<=2
            loc_cur = 'in EZ';
        elseif s<=4
            loc_cur = 'in Thalamus';
        else
            loc_cur = 'Control';
        end
%         fprintf('Frequency %g Hz.\n',freq_current);
        n_pulses = floor(burstduration / (1/freq_current)); % number of pulses sent within 100ms
        disp([ 'Pending trial ',num2str(n), '. Stim Freq: ',num2str(freq_current),' Hz. Stim Loc: ', loc_cur,...
            '. Pulses sent within ', num2str(burstduration*1000),'ms: ',num2str(n_pulses)])

        if (freq_current > 15)
            res = configureStimulusPattern(cerestim, 1, 'AF', n_pulses, ...
                stimamplitude, stimamplitude, 100, 100, freq_current, 53);
            res = configureStimulusPattern(cerestim, 2, 'CF', n_pulses, ...
                stimamplitude, stimamplitude, 100, 100, freq_current, 53);

            %         for p = randperm(length(pairs))
            count_round = 1;
            for k = 1:n_samefreqRounds
                res = beginningOfSequence(cerestim);
                res = beginningOfGroup(cerestim);
                res = autoStimulus(cerestim, pair_current(1), 1);
                res = autoStimulus(cerestim, pair_current(2), 2);
                res = endOfGroup(cerestim);
                res = endOfSequence(cerestim);
                ElapsedTime = toc;tic;
%                 fprintf('Stimulating at pair %g - %g at frequency %gHz. %d of 10 round %dms stims.\n',pair_current(1),pair_current(2), freq_current, count_round, burstduration*1000);
                fprintf(['Trial %g: Stimulating ',loc_cur, ' ch [%g - %g] at %gHz. %d of 10 round %dms stims.\n'], n,pair_current(1),pair_current(2), freq_current, count_round, burstduration*1000);
                currTime = datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSSSSS');
                fprintf(logfile,'%d\t%d\t%d\t%d\t%d\t%s\t%.6f\n\r',n,freq_current, count_round, pair_current(1),pair_current(2), currTime, ElapsedTime);
                fprintf(logfile,'\n\r');
                stim_parameters(currtrial,1:2) = pair_current(:); % record for channels
                stim_parameters(currtrial,3) = freq_current; % record for frequency
                currtrial = currtrial + 1;
                res = cerestim.play(1);

%                 disp([ num2str(count_round),' of ',num2str(10),' round ', num2str(burstduration*1000),'ms stims ',num2str(pair_current(1)),'-',num2str(pair_current(2))])
                
                fprintf('Pausing for %gms.\n',900)
                pause(0.9);
                T2save_k = T2save_k + 1;
                T2save.Trial(T2save_k) = n;
                T2save.Freq(T2save_k) = freq_current;
                T2save.StimLoc{T2save_k} = loc_cur;
                T2save.Round(T2save_k) = count_round;
                T2save.Channel1(T2save_k) = pair_current(1);
                T2save.Channel2(T2save_k) = pair_current(2);
                T2save.CurrentTime(T2save_k) = currTime;
                T2save.ElapsedTime(T2save_k) = ElapsedTime;
                count_round =count_round+1;
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
                res = beginningOfSequence(cerestim);
                res = beginningOfGroup(cerestim);
                res = autoStimulus(cerestim, pair_current(1), 3);
                res = autoStimulus(cerestim, pair_current(2), 4);
                res = endOfGroup(cerestim);
                res = wait(cerestim, floor(1000/freq_current)-1);
                res = endOfSequence(cerestim);
                res = cerestim.play(1);
                %                 res = play(cerestim,floor(freq_current*burstduration));
                ElapsedTime = toc;tic;
%                 fprintf('Stimulating at pair %g - %g at frequency %gHz. %d of 10 round %dms stims.\n',pair_current(1),pair_current(2), freq_current, count_round, burstduration*1000);
                fprintf(['Trial %g: Stimulating ',loc_cur, ' ch [%g - %g] at %gHz. %d of 10 round %dms stims.\n'], n,pair_current(1),pair_current(2), freq_current, count_round, burstduration*1000);
                currTime = datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSSSSS');
                fprintf(logfile,'%d\t%d\t%d\t%d\t%d\t%s\t%.6f\n\r',n,freq_current, count_round, pair_current(1),pair_current(2), currTime, ElapsedTime);
                fprintf(logfile,'\n\r');
                stim_parameters(currtrial,1:2) = pair_current(:); % record for channels
                stim_parameters(currtrial,3) = freq_current; % record for frequency
                currtrial = currtrial + 1;

%                 disp([ num2str(count_round),' of ',num2str(10),' round ', num2str(burstduration*1000),'ms stims ',num2str(pair_current(1)),'-',num2str(pair_current(2))])
                
                fprintf('Pausing for %gms.\n',900)
                pause(0.9);
                T2save_k = T2save_k + 1;
                T2save.Trial(T2save_k) = n;
                T2save.Freq(T2save_k) = freq_current;
                T2save.StimLoc{T2save_k} = loc_cur;
                T2save.Round(T2save_k) = count_round;
                T2save.Channel1(T2save_k) = pair_current(1);
                T2save.Channel2(T2save_k) = pair_current(2);
                T2save.CurrentTime(T2save_k) = currTime;
                T2save.ElapsedTime(T2save_k) = ElapsedTime;
                count_round =count_round+1;
            end
            fprintf(logfile,'Trial\tFreq\tRound\tChannel1\tChannel2\tCurrentTime\tElapsedTime\n\r');


        end
        fprintf('Pausing for %g s.\n',5)
        pause(5);
        fprintf('\n')

    end
    disp([ num2str(count),' of ',num2str(ntrials),' trials ',num2str(pair_current(1)),'-',num2str(pair_current(2))])
    count=count+1;
    save(['C:/Stimulation/ChulablogfileT-' filename '.mat'],'T2save')

    fprintf('\n')
end

end

function cleanupfunction(cerestim,logfile)

disconnect(cerestim);
delete(cerestim);
fclose(logfile);

end

