function [stim_parameters, T2save] = networktest_burst_saveT_PreStim(settings, ntrials, n_samefreqRounds, stimamplitude)
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
% logfile = fopen(['D:\Dropbox (MGH Chu Lab)\Spike Ripple Projects\Spike Ripple R01 Aim1B Analysis' ...
%     '\SR_STIM_data\MatlabCode_StimExperiment\TestRun\NetworkParameter-' filename '.txt'], 'a');
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
        if s==1
            loc_cur = 'in EZ';
        else
            loc_cur = 'in Thalamus';
        end
%         fprintf('Frequency %g Hz.\n',freq_current);
%         n_pulses = burstduration / (1/freq_current); % number of pulses sent within 100ms
        disp([ 'Pending trial ',num2str(n), '. Stim Freq: ',num2str(freq_current),' Hz. Stim Amplitude: ', ...
            num2str(stimamplitude/1000),'mA. Stim Loc: ', loc_cur, '.  '])

        %% stims with 1Hz -- repeat 100 times for each location
            res = configureStimulusPattern(cerestim, 3, 'AF', ...
                1, stimamplitude, stimamplitude, ...
                500, 500, 900/(1000/freq_current - floor(1000/freq_current)+1), 53);
            res = configureStimulusPattern(cerestim, 4, 'CF', ...
                1, stimamplitude, stimamplitude, ...
                500, 500, 900/(1000/freq_current - floor(1000/freq_current)+1), 53);
            count_round = 1;
            for k = 1:n_samefreqRounds
                res = beginningOfSequence(cerestim);
                res = beginningOfGroup(cerestim);
                res = autoStimulus(cerestim, pair_current(1), 3);
                res = autoStimulus(cerestim, pair_current(2), 4);
                res = endOfGroup(cerestim);
                res = wait(cerestim, floor(900/freq_current)-1);
                res = endOfSequence(cerestim);
                res = cerestim.play(1);
                %                 res = play(cerestim,floor(freq_current*burstduration));
                ElapsedTime = toc;tic;
%                 fprintf('Stimulating at pair %g - %g at frequency %gHz. %d of 10 round %dms stims.\n',pair_current(1),pair_current(2), freq_current, count_round, burstduration*1000);
                fprintf(['Trial %g: Stimulating ',loc_cur, ' ch [%g - %g] at %gHz. %d of %d stims.\n'], n,pair_current(1),pair_current(2), freq_current, count_round, n_samefreqRounds);
                currTime = datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSSSSS');
                fprintf(logfile,'%d\t%d\t%d\t%d\t%d\t%s\t%.6f\n\r',n,freq_current, count_round, pair_current(1),pair_current(2), currTime, ElapsedTime);
                fprintf(logfile,'\n\r');
                stim_parameters(currtrial,1:2) = pair_current(:); % record for channels
                stim_parameters(currtrial,3) = freq_current; % record for frequency
                currtrial = currtrial + 1;

%                 disp([ num2str(count_round),' of ',num2str(10),' round ', num2str(burstduration*1000),'ms stims ',num2str(pair_current(1)),'-',num2str(pair_current(2))])
                
%                 fprintf('Pausing for %gs.\n',0.2)
%                 pause(1.9);
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
%%

        fprintf('Pausing for %g s.\n',30)
        pause(30);
        fprintf('\n')

    end
    disp([ num2str(count),' of ',num2str(ntrials),' trials ',num2str(pair_current(1)),'-',num2str(pair_current(2))])
    count=count+1;
    save(['C:/Stimulation/ChulablogfileT-' filename '.mat'],'T2save')
%     save(['D:\Dropbox (MGH Chu Lab)\Spike Ripple Projects\Spike Ripple R01 Aim1B Analysis' ...
%         '\SR_STIM_data\MatlabCode_StimExperiment\TestRun\ChulablogfileT-' filename '.mat'],'T2save')

    fprintf('\n')
end

end

function cleanupfunction(cerestim,logfile)

disconnect(cerestim);
delete(cerestim);
fclose(logfile);

end

