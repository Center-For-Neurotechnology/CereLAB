function res = networktest(pairs, ntrials)


cerestim = BStimulator();
connx = connect(cerestim);

if connx < 0
    error('Can''t connect to cerestim')
end

pause on

res = configureStimulusPattern(cerestim, 1, 'AF', 1, ...
    7000, 7000, 90, 90, 100, 53);
res = configureStimulusPattern(cerestim, 2, 'CF', 1, ...
    7000, 7000, 90, 90, 100, 53);


for n = 1:ntrials
    for p = 1:length(pairs)
        

        
        res = beginningOfSequence(cerestim);
        res = beginningOfGroup(cerestim);
        res = autoStimulus(cerestim, pairs(p,1), 1);
        res = autoStimulus(cerestim, pairs(p,2), 2);
        res = endOfGroup(cerestim);
        res = endOfSequence(cerestim);
        
        fprintf('Stimulating at pair %g.\n',p)
        res = cerestim.play(1);
        fprintf('Pausing for %g s.\n',3)
        pause(3);
        
        fprintf('\n')
        
    end
end

disconnect(cerestim);
delete(cerestim);
        
    
end
