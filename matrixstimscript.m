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
% 46,47; pul
% 61,62; ant
% 66,67; pul
% 81,82; ant
% ];

% thalamic leads only - MG216
% pairs =[
% 50,51; pul
% 65,66; ant
% 34,35; CM
% ];

trainlength = 400; % in ms

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

matrixfunc(frequencies,delays,intertrialinterval,numtrials,stimamplitude,stimchans,trainlength)