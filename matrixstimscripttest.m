%%%%%%%% edit these values %%%%%%%%

frequencies = [ 10 ...
                40  ...
                80  ...
                130 ...
                160 ...
                200 ...
 ];
            
delays = [ 0];
       
intertrialinterval = 7; % in seconds

numtrials = 10; 

stimamplitude = 500; %in uA

stimchans = [18,19];

trainlength = 1000; % in ms

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

matrixfunc(frequencies,delays,intertrialinterval,numtrials,stimamplitude,stimchans,trainlength)