
% pair(1,:) is the main stim site,pair(2,:) is the active control site
pairs = [...
    29,30;
    19,20;
    ];

    disp('pausing for 3 minutes rest')
    pause(60*3)

for runs=1:7

    amplitude = 4000; %current amplitude in microamps
    pulses=1; %number of pulses per trial
    pulsewidth=100; % single pulse width per phase in microseconds
    intertrialinterval= 3; %interval (in seconds) between trials
    ntrials = 20; %Number of trials
    jitterinterval=1; %Randomly jitter inter-trial intervals in time (1- jitter, 0- no jitter)
    frequency=100; %Frequency of the biphasic pulses
    interphase=53; %Interphase of the biphasic pulses
    trainlength=pulses*(pulsewidth+pulsewidth+interphase);
    intervalburstduration=0;
    delay=0;

    stimchans = networktestFin(pairs(1,:), ntrials,intertrialinterval,amplitude,pulses,pulsewidth,frequency,interphase,trainlength,jitterinterval,intervalburstduration,delay);

    diary off

    filename = datestr(now);
    filename = strrep(filename,' ','_');
    filename = strrep(filename,':','-');

    save(['C:/Stimulation/CCEP_low1-',char(filename),'.mat'],'stimchans',...
        'pairs','ntrials','intertrialinterval','amplitude','pulses','pulsewidth','frequency',...
        'interphase','trainlength','jitterinterval','intervalburstduration','delay')

    amplitude = 7000; %current amplitude in microamps
    pulses=1; %number of pulses per trial
    pulsewidth=100; % single pulse width per phase in microseconds
    intertrialinterval= 3; %interval (in seconds) between trials
    ntrials = 20; %Number of trials
    jitterinterval=1; %Randomly jitter inter-trial intervals in time (1- jitter, 0- no jitter)
    frequency=100; %Frequency of the biphasic pulses
    interphase=53; %Interphase of the biphasic pulses
    trainlength=pulses*(pulsewidth+pulsewidth+interphase);
    intervalburstduration=0;
    delay=0;

    stimchans = networktestFin(pairs(1,:), ntrials,intertrialinterval,amplitude,pulses,pulsewidth,frequency,interphase,trainlength,jitterinterval,intervalburstduration,delay);

    diary off

    filename = datestr(now);
    filename = strrep(filename,' ','_');
    filename = strrep(filename,':','-');

    save(['C:/Stimulation/CCEP_high1-',char(filename),'.mat'],'stimchans',...
        'pairs','ntrials','intertrialinterval','amplitude','pulses','pulsewidth','frequency',...
        'interphase','trainlength','jitterinterval','intervalburstduration','delay')

    disp('pausing for 3 minutes rest')
    disp(['run ',num2str(runs)])
    pause(60*3)

    amplitude = 4000; %current amplitude in microamps
    pulses=1; %number of pulses per trial
    pulsewidth=100; % single pulse width per phase in microseconds
    intertrialinterval= 3; %interval (in seconds) between trials
    ntrials = 20; %Number of trials
    jitterinterval=1; %Randomly jitter inter-trial intervals in time (1- jitter, 0- no jitter)
    frequency=100; %Frequency of the biphasic pulses
    interphase=53; %Interphase of the biphasic pulses
    trainlength=pulses*(pulsewidth+pulsewidth+interphase);
    intervalburstduration=0;
    delay=0;

    stimchans = networktestFin(pairs(1,:), ntrials,intertrialinterval,amplitude,pulses,pulsewidth,frequency,interphase,trainlength,jitterinterval,intervalburstduration,delay);

    diary off

    filename = datestr(now);
    filename = strrep(filename,' ','_');
    filename = strrep(filename,':','-');

    save(['C:/Stimulation/CCEP_low2-',char(filename),'.mat'],'stimchans',...
        'pairs','ntrials','intertrialinterval','amplitude','pulses','pulsewidth','frequency',...
        'interphase','trainlength','jitterinterval','intervalburstduration','delay')


    amplitude = 7000; %current amplitude in microamps
    pulses=1; %number of pulses per trial
    pulsewidth=100; % single pulse width per phase in microseconds
    intertrialinterval= 3; %interval (in seconds) between trials
    ntrials = 20; %Number of trials
    jitterinterval=1; %Randomly jitter inter-trial intervals in time (1- jitter, 0- no jitter)
    frequency=100; %Frequency of the biphasic pulses
    interphase=53; %Interphase of the biphasic pulses
    trainlength=pulses*(pulsewidth+pulsewidth+interphase);
    intervalburstduration=0;
    delay=0;

    stimchans = networktestFin(pairs(1,:), ntrials,intertrialinterval,amplitude,pulses,pulsewidth,frequency,interphase,trainlength,jitterinterval,intervalburstduration,delay);

    diary off

    filename = datestr(now);
    filename = strrep(filename,' ','_');
    filename = strrep(filename,':','-');

    save(['C:/Stimulation/CCEP_high2-',char(filename),'.mat'],'stimchans',...
        'pairs','ntrials','intertrialinterval','amplitude','pulses','pulsewidth','frequency',...
        'interphase','trainlength','jitterinterval','intervalburstduration','delay')

    disp('pausing for 3 minutes rest')
    disp(['run ',num2str(runs)])
    pause(60*3)

    if runs==1 || runs==3 || runs==5

        disp('pausing for 3 minutes sham')
disp(['run ',num2str(runs)])
        pause(60*3) %sham
    elseif runs==2 || runs==4 || runs==6

        amplitude=2000;
        intervalburstduration=126; %Interval between bursts
        pulses=3; %number of pulses per trial
        pulsewidth=100; % single pulse width per phase in microseconds
        intertrialinterval= 8.1; %interval (in seconds) between trials
        ntrials = 20; %Number of trials
        jitterinterval=0; %Randomly jitter inter-trial intervals in time (1- jitter, 0- no jitter)
        burstfrequency=50;
        frequency=burstfrequency; %Frequency of the biphasic pulses per burst
        interphase=53; %Interphase of the biphasic pulses
        numberofbursts=10;
        trainlength=10*pulses*(pulsewidth+pulsewidth+interphase);
        delays = [ 0];

        stimchans1 = pairs(1,:);
disp(['run ',num2str(runs)])
        ThetaBurstParadigmVariableScript

    elseif runs==7

        amplitude=2000;
        intervalburstduration=126; %Interval between bursts
        pulses=3; %number of pulses per trial
        pulsewidth=100; % single pulse width per phase in microseconds
        intertrialinterval= 8.1; %interval (in seconds) between trials
        ntrials = 20; %Number of trials
        jitterinterval=0; %Randomly jitter inter-trial intervals in time (1- jitter, 0- no jitter)
        burstfrequency=50;
        frequency=burstfrequency; %Frequency of the biphasic pulses per burst
        interphase=53; %Interphase of the biphasic pulses
        numberofbursts=10;
        trainlength=10*pulses*(pulsewidth+pulsewidth+interphase);
        delays = [ 0];

        stimchans1 = pairs(2,:);
disp(['run ',num2str(runs)])
        ThetaBurstParadigmVariableScript

    end





end



amplitude = 4000; %current amplitude in microamps
pulses=1; %number of pulses per trial
pulsewidth=100; % single pulse width per phase in microseconds
intertrialinterval= 2.5; %interval (in seconds) between trials
ntrials = 20; %Number of trials
jitterinterval=1; %Randomly jitter inter-trial intervals in time (1- jitter, 0- no jitter)
frequency=100; %Frequency of the biphasic pulses
interphase=53; %Interphase of the biphasic pulses
trainlength=pulses*(pulsewidth+pulsewidth+interphase);
intervalburstduration=0;
delay=0;

stimchans = networktestFin(pairs(1,:), ntrials,intertrialinterval,amplitude,pulses,pulsewidth,frequency,interphase,trainlength,jitterinterval,intervalburstduration,delay);

diary off

filename = datestr(now);
filename = strrep(filename,' ','_');
filename = strrep(filename,':','-');

save(['C:/Stimulation/CCEP_low1-',char(filename),'.mat'],'stimchans',...
    'pairs','ntrials','intertrialinterval','amplitude','pulses','pulsewidth','frequency',...
    'interphase','trainlength','jitterinterval','intervalburstduration','delay')

amplitude = 7000; %current amplitude in microamps
pulses=1; %number of pulses per trial
pulsewidth=100; % single pulse width per phase in microseconds
intertrialinterval= 2.5; %interval (in seconds) between trials
ntrials = 20; %Number of trials
jitterinterval=1; %Randomly jitter inter-trial intervals in time (1- jitter, 0- no jitter)
frequency=100; %Frequency of the biphasic pulses
interphase=53; %Interphase of the biphasic pulses
trainlength=pulses*(pulsewidth+pulsewidth+interphase);
intervalburstduration=0;
delay=0;

stimchans = networktestFin(pairs(1,:), ntrials,intertrialinterval,amplitude,pulses,pulsewidth,frequency,interphase,trainlength,jitterinterval,intervalburstduration,delay);

diary off

filename = datestr(now);
filename = strrep(filename,' ','_');
filename = strrep(filename,':','-');

save(['C:/Stimulation/CCEP_high1-',char(filename),'.mat'],'stimchans',...
    'pairs','ntrials','intertrialinterval','amplitude','pulses','pulsewidth','frequency',...
    'interphase','trainlength','jitterinterval','intervalburstduration','delay')

disp('pausing for 3 minutes rest')
disp('ending run after run 7')
pause(60*3)

amplitude = 4000; %current amplitude in microamps
pulses=1; %number of pulses per trial
pulsewidth=100; % single pulse width per phase in microseconds
intertrialinterval= 2.5; %interval (in seconds) between trials
ntrials = 20; %Number of trials
jitterinterval=1; %Randomly jitter inter-trial intervals in time (1- jitter, 0- no jitter)
frequency=100; %Frequency of the biphasic pulses
interphase=53; %Interphase of the biphasic pulses
trainlength=pulses*(pulsewidth+pulsewidth+interphase);
intervalburstduration=0;
delay=0;

stimchans = networktestFin(pairs(1,:), ntrials,intertrialinterval,amplitude,pulses,pulsewidth,frequency,interphase,trainlength,jitterinterval,intervalburstduration,delay);

diary off

filename = datestr(now);
filename = strrep(filename,' ','_');
filename = strrep(filename,':','-');

save(['C:/Stimulation/CCEP_low2-',char(filename),'.mat'],'stimchans',...
    'pairs','ntrials','intertrialinterval','amplitude','pulses','pulsewidth','frequency',...
    'interphase','trainlength','jitterinterval','intervalburstduration','delay')


amplitude = 7000; %current amplitude in microamps
pulses=1; %number of pulses per trial
pulsewidth=100; % single pulse width per phase in microseconds
intertrialinterval= 2.5; %interval (in seconds) between trials
ntrials = 20; %Number of trials
jitterinterval=1; %Randomly jitter inter-trial intervals in time (1- jitter, 0- no jitter)
frequency=100; %Frequency of the biphasic pulses
interphase=53; %Interphase of the biphasic pulses
trainlength=pulses*(pulsewidth+pulsewidth+interphase);
intervalburstduration=0;
delay=0;

stimchans = networktestFin(pairs(1,:), ntrials,intertrialinterval,amplitude,pulses,pulsewidth,frequency,interphase,trainlength,jitterinterval,intervalburstduration,delay);

diary off

filename = datestr(now);
filename = strrep(filename,' ','_');
filename = strrep(filename,':','-');

save(['C:/Stimulation/CCEP_high2-',char(filename),'.mat'],'stimchans',...
    'pairs','ntrials','intertrialinterval','amplitude','pulses','pulsewidth','frequency',...
    'interphase','trainlength','jitterinterval','intervalburstduration','delay')

disp('pausing for 3 minutes rest')
disp('All done!!!')
pause(60*3)