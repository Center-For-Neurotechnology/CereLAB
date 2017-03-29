addpath(genpath('C:/Stimulation'))
cerestim = BStimulator();
connect(cerestim);

amplitudes = zeros(3,35);
for i = 1:7
    res = configureStimulusPattern(cerestim, 2*i-1, 'AF', 1, 500*i, 500*i, 90, 90, 1000, 53);
    res = configureStimulusPattern(cerestim, 2*i, 'CF', 1, 500*i, 500*i, 90, 90, 1000, 53);
end
for tr = 1:5
    order = randperm(7);
    cerestim.beginningOfSequence();
    for amp = 1:7
        cerestim.beginningOfGroup();
        cerestim.autoStimulus(1,order(amp)*2-1);
        cerestim.autoStimulus(2,order(amp)*2);
        cerestim.endOfGroup();
        cerestim.wait(2500+randi(500));
        amplitudes(1,(tr-1)*7+amp) = 500*order(amp);
    end
    cerestim.endOfSequence();
    cerestim.play(1);
end
save MG101_amplitudes.mat amplitudes
for i = 1:7
    res = configureStimulusPattern(cerestim, 2*i-1, 'AF', 1, 3500 + 500*i, 3500 + 500*i, 90, 90, 1000, 53);
    res = configureStimulusPattern(cerestim, 2*i, 'CF', 1, 3500 + 500*i, 3500 + 500*i, 90, 90, 1000, 53);
end
for tr = 1:5
    order = randperm(7);
    cerestim.beginningOfSequence();
    for amp = 1:7
        cerestim.beginningOfGroup();
        cerestim.autoStimulus(1,order(amp)*2-1);
        cerestim.autoStimulus(2,order(amp)*2);
        cerestim.endOfGroup();
        cerestim.wait(2500+randi(500));
        amplitudes(2,(tr-1)*7+amp) = 3500 + 500*order(amp);
    end
    cerestim.endOfSequence();
    cerestim.play(1);
end
save MG101_amplitudes.mat amplitudes
for i = 1:6
    res = configureStimulusPattern(cerestim, 2*i-1, 'AF', 1, 7000 + 500*i, 7000 + 500*i, 90, 90, 1000, 53);
    res = configureStimulusPattern(cerestim, 2*i, 'CF', 1, 7000 + 500*i, 7000 + 500*i, 90, 90, 1000, 53);
end
for tr = 1:5
    order = randperm(6);
    cerestim.beginningOfSequence();
    for amp = 1:6
        cerestim.beginningOfGroup();
        cerestim.autoStimulus(1,order(amp)*2-1);
        cerestim.autoStimulus(2,order(amp)*2);
        cerestim.endOfGroup();
        cerestim.wait(2500+randi(500));
        amplitudes(3,(tr-1)*6+amp) = 7000 + 500*order(amp);
    end
    cerestim.endOfSequence();
    cerestim.play(1);
end

%%CHANGE THE NAME HERE PLEASE
save MG104_amplitudes_RMT1011.mat amplitudes

disconnect(cerestim);
delete(cerestim);
