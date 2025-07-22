%%%%%%%% edit these values %%%%%%%%

frequencies = [ 160 ...
 ];
            
delays = [ 0];
       
intertrialinterval = 10; % in seconds

numtrials = 5; 

% amplitudes to test 
% 2000, 4000, 6000
stimamplitude = 6000; %in uA, one at a time

% LFSa01-02: 1-2, Network 1
% LFSa02-03: 2-3, Network 1
%stimchans = [1,2]; % use single channel
% MG216
stimchans = [56,57];

trainlength = 600; % in ms

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

matrixfunc(frequencies,delays,intertrialinterval,numtrials,stimamplitude,stimchans,trainlength)