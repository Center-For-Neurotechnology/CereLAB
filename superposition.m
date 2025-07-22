function stimchans = superposition(pairs, ntrials, intervalsec, amplitude)

if ~exist('intervalsec','var') || isempty(intervalsec)
    intervalsec=5; % default is 5 seconds between trials
end

if ~exist('amplitude','var') || isempty(amplitude)
    amplitude=7000; % default is 7mA
end

nullElectrode = 0; % this is the electrode that will not be used. for the case of A instead of A+B

% initiate cerestim
cerestim = BStimulator();
connx = connect(cerestim);

if connx < 0
    error('Can''t connect to cerestim')
end

% create log file
filename = datestr(now);
filename = strrep(filename,' ','_');
filename = strrep(filename,':','-');
logfile = fopen(['C:/Stimulation/superposition-' filename '.txt'], 'a');

c = onCleanup(@()cleanupfunction(cerestim,logfile));

pause on

% creating wave patterns - this is the initialization channels will be specified afterwards
res = configureStimulusPattern(cerestim, 1, 'AF', 1, ...
    amplitude, amplitude, 90, 90, 100, 53);
res = configureStimulusPattern(cerestim, 2, 'CF', 1, ...
    amplitude, amplitude, 90, 90, 100, 53);
res = configureStimulusPattern(cerestim, 3, 'AF', 1, ...
    amplitude, amplitude, 90, 90, 100, 53);
res = configureStimulusPattern(cerestim, 4, 'CF', 1, ...
    amplitude, amplitude, 90, 90, 100, 53);

fprintf(logfile,'Logfile for Superposition %s\n\r',filename);
fprintf(logfile,'\n\r');
fprintf(logfile,'\n\r');
fprintf(logfile,'Trial\tChannel1\tChannel2\tChannel3\tChannel4\n\r');
fprintf(logfile,'\n\r');

TrialTotal = ntrials*6;
currtrial = 1;
stimchans = zeros(TrialTotal,4);
% create base trial and iterate
for n = 1:ntrials
    % create permutation   
    posOrder = randperm(6);      % A, B, C, A+B, B+C, A+C
    for p=1:length(posOrder)
        if posOrder(p) <= 3 % A,B, C
            res = beginningOfSequence(cerestim);
            res = beginningOfGroup(cerestim);
            res = autoStimulus(cerestim, pairs(posOrder(p),1), 1);
            res = autoStimulus(cerestim, pairs(posOrder(p),2), 2);
            res = autoStimulus(cerestim, nullElectrode, 3);
            res = autoStimulus(cerestim, nullElectrode, 4);
            res = endOfGroup(cerestim);
            res = endOfSequence(cerestim);
            stimchans(currtrial,1:4) = [pairs(posOrder(p),1), pairs(posOrder(p),2), nullElectrode, nullElectrode];
            
            fprintf('Stimulating at pair %g - %g.\n',pairs(posOrder(p),1),pairs(posOrder(p),2));
            fprintf(logfile,'%d\t%d\t%d\n\r',n,pairs(posOrder(p),1),pairs(posOrder(p),2));
            fprintf(logfile,'\n\r');

        elseif posOrder(p) == 4 %A+B
            res = beginningOfSequence(cerestim);
            res = beginningOfGroup(cerestim);
            res = autoStimulus(cerestim, pairs(1,1), 1);
            res = autoStimulus(cerestim, pairs(1,2), 2);
            res = autoStimulus(cerestim, pairs(2,1), 3);
            res = autoStimulus(cerestim, pairs(2,2), 4);
            res = endOfGroup(cerestim);
            res = endOfSequence(cerestim);

            stimchans(currtrial,1:4) = [pairs(1,1),pairs(1,2),pairs(2,1),pairs(2,2)];
            fprintf('Stimulating at pairs %g - %g  AND  %g - %g.\n',pairs(1,1),pairs(1,2),pairs(2,1),pairs(2,2));
            fprintf(logfile,'%d\t%d\t%d\t%d\t%d\n\r',n,pairs(1,1),pairs(1,2),pairs(2,1),pairs(2,2));
            fprintf(logfile,'\n\r');

        elseif posOrder(p) == 5 %B+C
            res = beginningOfSequence(cerestim);
            res = beginningOfGroup(cerestim);
            res = autoStimulus(cerestim, pairs(2,1), 1);
            res = autoStimulus(cerestim, pairs(2,2), 2);
            res = autoStimulus(cerestim, pairs(3,1), 3);
            res = autoStimulus(cerestim, pairs(3,2), 4);
            res = endOfGroup(cerestim);
            res = endOfSequence(cerestim);
            
            stimchans(currtrial,1:4) = [pairs(2,1),pairs(2,2),pairs(3,1),pairs(3,2)];
            fprintf('Stimulating at pairs %g - %g  AND  %g - %g.\n',pairs(2,1),pairs(2,2),pairs(3,1),pairs(3,2));
            fprintf(logfile,'%d\t%d\t%d\t%d\t%d\n\r',n,pairs(2,1),pairs(2,2),pairs(3,1),pairs(3,2));
            fprintf(logfile,'\n\r');
  
        elseif posOrder(p) == 6 %A+C
            res = beginningOfSequence(cerestim);
            res = beginningOfGroup(cerestim);
            res = autoStimulus(cerestim, pairs(1,1), 1);
            res = autoStimulus(cerestim, pairs(1,2), 2);
            res = autoStimulus(cerestim, pairs(3,1), 3);
            res = autoStimulus(cerestim, pairs(3,2), 4);
            res = endOfGroup(cerestim);
            res = endOfSequence(cerestim);

            stimchans(currtrial,1:4) = [pairs(1,1),pairs(1,2),pairs(3,1),pairs(3,2)];
            fprintf('Stimulating at pairs %g - %g  AND  %g - %g.\n',pairs(1,1),pairs(1,2),pairs(3,1),pairs(3,2));
            fprintf(logfile,'%d\t%d\t%d\t%d\t%d\n\r',n,pairs(1,1),pairs(1,2),pairs(3,1),pairs(3,2));
            fprintf(logfile,'\n\r');
        end
        % RUN
        res = cerestim.play(1);
        currtrial = currtrial + 1;

        disp([ num2str(currtrial),' of ',num2str(TrialTotal),' trials '])
        fprintf('Pausing for %g s.\n',intervalsec+(2*rand-1)*0.1)
        pause(intervalsec+(2*rand-1)*0.1);
        
        fprintf('\n')
        
    end
end


function cleanupfunction(cerestim,logfile)
    disconnect(cerestim);
    delete(cerestim);
    fclose(logfile);
end


end

