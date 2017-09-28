function res = networkstim_audiotrigger(pairs, ntrials)


cerestim = BStimulator();
connx = connect(cerestim);

if connx < 0
    error('Can''t connect to cerestim')
end

filename = datestr(now);
filename = strrep(filename,' ','_');
filename = strrep(filename,':','-');
logfile = fopen(['C:/Stimulation/ORNetwork-' filename '.txt'], 'a');

c = onCleanup(@()cleanupfunction(cerestim,logfile));

pause on

res = configureStimulusPattern(cerestim, 1, 'AF', 1, ...
    7000, 7000, 90, 90, 100, 53);
res = configureStimulusPattern(cerestim, 2, 'CF', 1, ...
    7000, 7000, 90, 90, 100, 53);


fprintf(logfile,'Logfile for OR Network %s\n\r',filename);
fprintf(logfile,'\n\r');
fprintf(logfile,'\n\r');
fprintf(logfile,'Trial\tChannel1\tChannel2\n\r');
fprintf(logfile,'\n\r');


for n = 1:ntrials
    fprintf('Trial %g.\n',n);
    
    for p = randperm(length(pairs))      
        res = beginningOfSequence(cerestim);
        res = wait(cerestim,1750+randi(500));
        %res = wait(cerestim,2000);
        res = beginningOfGroup(cerestim);
        res = autoStimulus(cerestim, pairs(p,1), 1);
        res = autoStimulus(cerestim, pairs(p,2), 2);
        res = endOfGroup(cerestim);
        res = endOfSequence(cerestim);
        
        fprintf('Loading stimulation at pair %g - %g.\n',pairs(p,1),pairs(p,2));
        fprintf(logfile,'%d\t%d\t%d\n\r',n,pairs(p,1),pairs(p,2));
        fprintf(logfile,'\n\r');
        res = cerestim.triggerStimulus('rising');
        stimd = 0;
        while (stimd == 0)
            tic
            res = cerestim.readSequenceStatus();
            if toc > 1
                stimd = 1;
                fprintf('Stimulation complete.\n');
            end
        end
            
%         fprintf('Waiting for %g s.\n',5)
%         pause(5);
        res = cerestim.stopTriggerStimulus();
        fprintf('\n')        
    end
end
        
    
end

function cleanupfunction(cerestim,logfile)

res = cerestim.stopTriggerStimulus();
disconnect(cerestim);
delete(cerestim);
fclose(logfile);

end



