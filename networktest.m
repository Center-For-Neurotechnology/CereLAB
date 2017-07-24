function stimchans = networktest(pairs, ntrials)


cerestim = BStimulator();
connx = connect(cerestim);

if connx < 0
    error('Can''t connect to cerestim')
end

c = onCleanup(@()cleanupfunction(cerestim));

pause on

res = configureStimulusPattern(cerestim, 1, 'AF', 1, ...
    7000, 7000, 90, 90, 100, 53);
res = configureStimulusPattern(cerestim, 2, 'CF', 1, ...
    7000, 7000, 90, 90, 100, 53);

stimchans = zeros(ntrials*length(pairs),2);
currtrial = 1;

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
        stimchans(currtrial,:) = pairs(p,:);
        currtrial = currtrial + 1;
        res = cerestim.play(1);
        fprintf('Pausing for %g s.\n',3)
        pause(3);
        
        fprintf('\n')
        
    end
end

disconnect(cerestim);
delete(cerestim);
        
    
end

function cleanupfunction(cerestim)

disconnect(cerestim);
delete(cerestim);

end

