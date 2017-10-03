function stimchans = networktest(pairs, ntrials)
%function stimchans = networktest(pairs, ntrials)
%
%   Runs the "network" experiment, where it pseudo-randomly selects
%   channels from the pairs list to stimulate with single pulses.
%
%   INPUTS
%
%   pairs       an nx2 matrix with the channel pairs to be stimulated
%   ntrials     an

cerestim = BStimulator();
connx = connect(cerestim);

if connx < 0
    error('Can''t connect to cerestim')
end

filename = datestr(now);
filename = strrep(filename,' ','_');
filename = strrep(filename,':','-');
logfile = fopen(['C:/Stimulation/Network-' filename '.txt'], 'a');

c = onCleanup(@()cleanupfunction(cerestim,logfile));

pause on

res = configureStimulusPattern(cerestim, 1, 'AF', 1, ...
    7000, 7000, 90, 90, 100, 53);
res = configureStimulusPattern(cerestim, 2, 'CF', 1, ...
    7000, 7000, 90, 90, 100, 53);

stimchans = zeros(ntrials*length(pairs),2);
currtrial = 1;

fprintf(logfile,'Logfile for Network %s\n\r',filename);
fprintf(logfile,'\n\r');
fprintf(logfile,'\n\r');
fprintf(logfile,'Trial\tChannel1\tChannel2\n\r');
fprintf(logfile,'\n\r');

for n = 1:ntrials
    fprintf('Trial %g.\n',n);
    for p = randperm(length(pairs))     
        res = beginningOfSequence(cerestim);
        res = beginningOfGroup(cerestim);
        res = autoStimulus(cerestim, pairs(p,1), 1);
        res = autoStimulus(cerestim, pairs(p,2), 2);
        res = endOfGroup(cerestim);
        res = endOfSequence(cerestim);
        
        fprintf('Stimulating at pair %g - %g.\n',pairs(p,1),pairs(p,2));
        fprintf(logfile,'%d\t%d\t%d\n\r',n,pairs(p,1),pairs(p,2));
        fprintf(logfile,'\n\r');
        stimchans(currtrial,:) = pairs(p,:);
        currtrial = currtrial + 1;
        res = cerestim.play(1);
        fprintf('Pausing for %g s.\n',3)
        pause(3);
        
        fprintf('\n')
        
    end
end
        
end

function cleanupfunction(cerestim,logfile)

disconnect(cerestim);
delete(cerestim);
fclose(logfile);

end

