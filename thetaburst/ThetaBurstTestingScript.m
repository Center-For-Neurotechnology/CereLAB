frequencies = [200 ...
    ];
burstfrequency=200;    
intervalduration=117;    
delays = [0];       
intertrialinterval = 20; % in seconds
numtrials = 10; 
stimamplitude = 2000; %in uA
trainlength = 0; % in mss

stimchans1 = [60 61];
stimchans2 = [3 4]; 

filename = datestr(now);
filename = strrep(filename,' ','_');
filename = strrep(filename,':','-');

logfile = fopen(['C:/Stimulation/ThetaBurstTesting',num2str(stimamplitude/1000),'maLocs-' filename '.txt'], 'a');
fprintf(logfile,'Logfile for ThetaBurstTesting %s\n\r',filename);
fprintf(logfile,'\n\r');
fprintf(logfile,'\n\r');
fprintf(logfile,'Frequencies:\n\r');
fprintf(logfile,'\n\r');
for i = 1:length(frequencies)
    fprintf(logfile,'%d\t',frequencies(i));
end
fprintf(logfile,'\n\r');
fprintf(logfile,'\n\r');
fprintf(logfile,'Delays\n\r');
fprintf(logfile,'\n\r');
for i = 1:length(delays)
    fprintf(logfile,'%d\t',delays(i));
end
fprintf(logfile,'\n\r');
fprintf(logfile,'\n\r');
fprintf(logfile,'Inter-trial Interval is %d seconds.\n\r',intertrialinterval);
fprintf(logfile,'\n\r');
fprintf(logfile,'Number of trials per condition is %d.\n\r',numtrials);
fprintf(logfile,'\n\r');
fprintf(logfile,'Stimulation amplitude is %d mA.\n\r',stimamplitude);
fprintf(logfile,'\n\r');
fprintf(logfile,'Stimulation channels are %d-%d.\n\r',stimchans1(1), stimchans1(2));
fprintf(logfile,'\n\r');
fprintf(logfile,'2nd stimulation channels are %d-%d.\n\r',stimchans2(1), stimchans2(2));
fprintf(logfile,'\n\r');
fprintf(logfile,'Stimulation pulse length is %d ms.\n\r\n\r',trainlength);
fprintf(logfile,'\n\r');
fprintf(logfile,'\n\r');
fprintf(logfile,'Trial\tFrequency\tDelay\tChannel1\tChannel2\n\r');
fprintf(logfile,'\n\r');

stimchans=[];

for tri=1:10
res = thetaburst(stimamplitude,  stimchans1, burstfrequency, intervalduration)
stimchans=[stimchans;tri stimchans1 stimamplitude burstfrequency intervalduration intertrialinterval];
pause(intertrialinterval+2*randn)
 fprintf(logfile,'%d\t%d\t%d\t%d\t%d\t%d\t%d\n\r',tri,burstfrequency,stimamplitude,stimchans1(1),stimchans1(2),intervalduration,intertrialinterval);
    fprintf(logfile,'\n\r');
end
save(['C:/Stimulation/thetabursttesting-',char(filename),'.mat'],'stimchans')
