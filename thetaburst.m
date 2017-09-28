function res = thetaburst(amplitude,  pair)
%function res = thetaburst(amplitude, pair)
%THETABURST automatic delivery of "theta burst" pulses - six trains of 200
%   Hz, 50 ms duration each, with 117 ms in between.  The procedure is 
%   fairly automatic, requiring manual intervention (Ctrl+C or using the 
%   emergency stop on the cerestim device) to stop prematurely.  
%
%   Inputs:
%       amplitude   an integer containing the desired amplitude for 
%                   stimulation, between 100 and 10000 uA.
%       pair        a 1x2 matrix with the electrode pair to be stimulated.
%   Outputs:
%       res         a BResult status.  Returns 0 if everything was
%                   successful.  Otherwise, check BStimulator.h for
%                   corresponding error messages.


if (length(pairs,2) ~= 2)
    error('pairs must be a 1x2 matrix')
end

cerestim = BStimulator();
connx = connect(cerestim);

if connx < 0
    error('Can''t connect to cerestim')
end

c = onCleanup(@()cleanupfunction(cerestim));

pause on

res = configureStimulusPattern(cerestim, 1, 'AF', 10, ...
    amplitude, amplitude, 90, 90, 200, 53);
res = configureStimulusPattern(cerestim, 2, 'CF', 10, ...
    amplitude, amplitude, 90, 90, 200, 53);

res = beginningOfSequence(cerestim);
res = beginningOfGroup(cerestim);
res = autoStimulus(cerestim, pair(1,1), 1);
res = autoStimulus(cerestim, pair(1,2), 2);
res = endOfGroup(cerestim);
res = wait(cerestim, 117);
res = endOfSequence(cerestim);

fprintf('Stimulating at %g mA on channels %d - %d.\n',amplitude(1)/1000,pair(1),pair(2))

for t = 1:6
    res = cerestim.play(1);
end

disconnect(cerestim);
delete(cerestim);
        
    
end

function cleanupfunction(cerestim)

disconnect(cerestim);
delete(cerestim);

end

