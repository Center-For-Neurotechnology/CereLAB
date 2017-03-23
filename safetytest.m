function res = safetytest(frequency, duration, amplitudes, trials, waitperiod, pairs)
%function res = safetytest(frequency, duration, amplitudes, trials, waitperiod, npairs)
%SAFETYTEST automatic safety testing for DARPA stimulation tasks
%   Takes the parameters for the desired safety testing and implements the
%   safety testing.  The procedure is fairly automatic, requiring manual
%   intervention (Ctrl+C or using the emergency stop on the cerestim
%   device) to stop prematurely.  The program will run through the vector
%   of amplitudes provided.
%
%   Inputs:
%       frequency   the stimulation frequency at which the biphasic pulses
%                   should repeat.  4-5000 Hz
%       duration    the duration, in ms, of each train of stimulation.
%                   This parameter can be any whole, positive integer, but
%                   the total number of pulses delivered cannot exceed 255.  
%                   For example, 200Hz stimulation trains can be at maximum 
%                   1275 ms long.
%       amplitudes  a vector of integers containing the desired amplitudes
%                   for stimulation, between 100 and 10000 uA.  The total
%                   number of trials will be the number of amplitudes
%                   specified (i.e. the length of the amplitudes vector)
%                   times the number of trials.
%       trials      the total number of trials for each amplitude.  This
%                   input parameter can be a vector the same length as the 
%                   amplitudes input parameter for a unique number of
%                   trials per amplitude.  Otherwise, the program will take
%                   the first value for every amplitude.
%       waitperiod  the total number of whole seconds to wait in between 
%                   each stimulation train.  This input parameter can be a 
%                   vector the same length as the amplitudes input 
%                   parameter for a unique number of trials per amplitude.  
%                   Otherwise, the program will take the first value for 
%                   every amplitude.
%       pairs       a nx2 matrix with the electrode pair numbers to be
%                   stimulated.
%   Outputs:
%       res         a BResult status.  Returns 0 if everything was
%                   successful.  Otherwise, check BStimulator.h for
%                   corresponding error messages.


if (size(pairs,2) ~= 2)
    error('pairs must be an nx2 matrix')
end

cerestim = BStimulator();
connx = connect(cerestim);

if connx < 0
    error('Can''t connect to cerestim')
end

pause on

npairs = size(pairs,1);

for a = 1:length(amplitudes)
    if length(frequency) == length(amplitudes)
        freq = frequency(a);
    else
        freq = frequency(1);
    end
    if (length(duration) == length(amplitudes))
        dur = duration(a);
    else
        dur = duration(1);
    end
    npulse = floor(freq.*dur/1000);
    res = configureStimulusPattern(cerestim, 1, 'AF', npulse, ...
        amplitudes(a), amplitudes(a), 90, 90, freq, 53);
    res = configureStimulusPattern(cerestim, 2, 'CF', npulse, ...
        amplitudes(a), amplitudes(a), 90, 90, freq, 53);
    
    if (length(trials) == length(amplitudes))
        ntrial = trials(a);
    else
        ntrial = trials(1);
    end
    
    if (length(waitperiod) == length(amplitudes))
        nsecs = waitperiod(a);
    else
        nsecs = waitperiod(1);
    end
    
    if npairs == 1;
        res = beginningOfSequence(cerestim);
        res = beginningOfGroup(cerestim);
        res = autoStimulus(cerestim, pairs(1,1), 1);
        res = autoStimulus(cerestim, pairs(1,2), 2);
        res = endOfGroup(cerestim);
        res = endOfSequence(cerestim);
    elseif npairs == 2;
        res = beginningOfSequence(cerestim);
        res = beginningOfGroup(cerestim);
        res = autoStimulus(cerestim, pairs(1,1), 1);
        res = autoStimulus(cerestim, pairs(1,2), 2);
        res = autoStimulus(cerestim, pairs(1,3), 1);
        res = autoStimulus(cerestim, pairs(1,4), 2);
        res = endOfGroup(cerestim);
        res = endOfSequence(cerestim);
    else
        error('The number of pairs of electrodes can either be 1 or 2');
    end
        
    for t = 1:ntrial
        fprintf('Stimulating at %g mA and %g Hz for %g s.\n',amplitudes(a)/1000,freq,dur/1000)
        res = cerestim.play(1);
        pause(dur/1000);
        fprintf('Pausing for %g s.\n',nsecs)
        pause(nsecs);
    end
    
    fprintf('\n')
    
end

disconnect(cerestim);
delete(cerestim);
        
    
end

