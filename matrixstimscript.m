%%%%%%%% edit these values %%%%%%%%

frequencies = [ 10 ...
                40  ...
                80  ...
                130 ...
                160 ...
                200 ...   
 ];
         
delays = [ 0 ];
       
intertrialinterval = 5; % in seconds

numtrials = 10; 

stimamplitude = 2000; %in uA

stimchans = [1,2];

% thalamic leads only
% pairs =[
% ];



trainlength = 400; % in ms

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

matrixfunc(frequencies,delays,intertrialinterval,numtrials,stimamplitude,stimchans,trainlength)