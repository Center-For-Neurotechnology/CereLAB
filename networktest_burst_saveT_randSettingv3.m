function [stim_parameters, T2save] = networktest_burst_saveT_randSettingv3(settings, ntrials, stimamplitude)
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
% logfile = fopen(['D:\MGH Chu Lab Dropbox\Spike Ripple Projects\Spike Ripple R01 Aim1B Analysis' ...
%     '\SR_STIM_data\MatlabCode_StimExperiment\TestRun\NetworkParameter-' filename '.txt'], 'a');
c = onCleanup(@()cleanupfunction(cerestim,logfile));

pause on

% TrialTotal=ntrials * Nsettings;
stim_parameters = zeros(3*ntrials*10 + 2*ntrials*5,3);

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
        n_samefreqRounds = setting_current(4); % the 4th para is the stim rounds within a 10-sec trial
        burstduration = setting_current(5); % the 5th para is the burst duration of each stim
        pauseLength = setting_current(6); % the 6th para is the pause duration after each stim burst
        if Nsettings>2
            if s<=2
                loc_cur = 'in Thalamus';
            elseif s<=4
                loc_cur = 'in EZ';
            else
                loc_cur = 'Control';
            end
        else
            loc_cur = 'testing';
        end
        %         fprintf('Frequency %g Hz.\n',freq_current);

        n_pulses = floor(burstduration / (1/freq_current)); % number of pulses sent within 100ms
        disp([ 'Pending trial ',num2str(n), '. Stim Freq: ',num2str(freq_current),' Hz. Stim Loc: ', loc_cur,...
            '. Pulses sent within ', num2str(burstduration*1000),'ms: ',num2str(n_pulses)])

        %         if (freq_current > 15)
        res = configureStimulusPattern(cerestim, 1, 'AF', n_pulses, ...
            stimamplitude, stimamplitude, 100, 100, freq_current, 53);
        res = configureStimulusPattern(cerestim, 2, 'CF', n_pulses, ...
            stimamplitude, stimamplitude, 100, 100, freq_current, 53);

        %         for p = randperm(length(pairs))
        count_round = 1;
        for k = 1:n_samefreqRounds
            tic;
            res = beginningOfSequence(cerestim);
            res = beginningOfGroup(cerestim);
            res = autoStimulus(cerestim, pair_current(1), 1);
            res = autoStimulus(cerestim, pair_current(2), 2);
            res = endOfGroup(cerestim);
            %                 res = wait(cerestim, pauseLength*1000);
            res = endOfSequence(cerestim);
            fprintf(['Trial %g: Stimulating ',loc_cur, ' ch [%g - %g] at %gHz. %d of %d round %dms stims.\n'], n,pair_current(1),pair_current(2), freq_current, count_round, n_samefreqRounds, burstduration*1000);
            currTime = datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSSSSS');
            res = cerestim.play(1);
            ElapsedTime = toc;tic
            fprintf(logfile,'%d\t%d\t%d\t%d\t%d\t%s\t%.6f\n\r',n,freq_current, count_round, pair_current(1),pair_current(2), currTime, ElapsedTime);
            fprintf(logfile,'\n\r');

            stim_parameters(currtrial,1:2) = pair_current(:); % record for channels
            stim_parameters(currtrial,3) = freq_current; % record for frequency
            currtrial = currtrial + 1;

%             disp([ num2str(count_round),' of ',num2str(10),' round ', num2str(burstduration*1000),'ms stims ',num2str(pair_current(1)),'-',num2str(pair_current(2))])
            fprintf('Pausing for %gms.\n',(pauseLength-burstduration)*1000)
            pause on
            pause(pauseLength);
            %                 pauseTime = toc; fprintf('Paused for %gms.\n',pauseTime*1000)
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

        fprintf('Pausing for %g s.\n',5)
        pause(5);
        fprintf('\n')

    end
    disp([ num2str(count),' of ',num2str(ntrials),' trials ',num2str(pair_current(1)),'-',num2str(pair_current(2))])
    count=count+1;
    save(['C:/Stimulation/ChulablogfileT-' filename '.mat'],'T2save')
%         save(['D:\MGH Chu Lab Dropbox\Spike Ripple Projects\Spike Ripple R01 Aim1B Analysis' ...
%             '\SR_STIM_data\MatlabCode_StimExperiment\TestRun\ChulablogfileT-' filename '.mat'],'T2save')

    fprintf('\n')
end

end

function cleanupfunction(cerestim,logfile)

disconnect(cerestim);
delete(cerestim);
fclose(logfile);

end

