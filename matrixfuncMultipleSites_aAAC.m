function matrixfuncMultipleSites_aAAC(T_StimParam,...
    numtrials,stimchans,frequencies,delays,...
    stimamplitude,trainlength, pulsewidth,interphase,intertrialinterval, ... % unitary params
    randomize_presentation_order_inTrial,param_sort_order,...% other params
    MatrixDirectory,filename,logfileTxt,matfile_log,diaryfile)
    %
    %% Setup diary and logfiles
    if isempty(filename)
        filename = datestr(now);
        filename = strrep(filename,' ','_');
        filename = strrep(filename,':','-');
    end
    %
    diaryOn = strcmp(get(0, 'Diary'), 'on');
    if ~diaryOn 
        if isempty(diaryfile)
            diaryfile = fullfile(MatrixDirectory,['MatrixDiary-' filename]);
        end
        diary(diaryfile)
        fprintf('Diary file is opened: %s\n', diaryfile);
    else
        current_diaryFile = get(0, 'DiaryFile');
        if ~isempty(diaryfile)
            if ~strcmp(current_diaryFile, diaryfile)
                fprintf('Diary file is already open: %s\n', current_diaryFile);
                diary off
                fprintf('Diary file is closed: %s\n', current_diaryFile);
                
            end
        else
            
        end
        diary(diaryfile)
        %
    end
    %
    if (isnumeric(logfileTxt) && logfileTxt > 0)
        if ~any(fopen('all') == logfileTxt)
            logfileTxt = fopen(fullfile(MatrixDirectory,sprintf('%s_log.txt',filename)),'a');
        end
    else
        if ~isempty(logfileTxt) %exist(logfileTxt,'file')
            logfileTxt = fopen(logfileTxt,'a');
        else
            % creat the logfile
            logfileTxt = fopen([MatrixDirectory,'/Matrix-',num2str(stimamplitude/1000),'-ma', filename '.txt'], 'a');
        end
    end
    
    %% Table for stim parameters
    %
    if isempty(T_StimParam)
        %
        varsInStimParam = {'Repeat','ChanPair','Frequency','Delay'};
        %
        c_stimchans = arrayfun(@(x) stimchans(x,:),1:size(stimchans,1),'UniformOutput',false);
        T_StimParam = cell2table(CombVec(num2cell(1:numtrials),c_stimchans,num2cell(forceColumn_ZY(frequencies)),num2cell(forceColumn_ZY(delays))),...
                        'variablenames',varsInStimParam);
        if iscell(T_StimParam.Repeat)
            T_StimParam.Repeat = cellfun(@(x) x, T_StimParam.Repeat);
        end
        if iscell(T_StimParam.Frequency)
            T_StimParam.Frequency = cellfun(@(x) x, T_StimParam.Frequency);
        end
        if iscell(T_StimParam.Delay)
            T_StimParam.Delay = cellfun(@(x) x, T_StimParam.Delay);
        end
        %
    else
        varsInStimParam = T_StimParam.Properties.VariableNames;
        assert(all(ismember({'ChanPair','Frequency','Delay','Repeat'},varsInStimParam)),...
            'T_StimParam must contain ChanPair, Frequency, Delay, and Repeat columns');
    end
    if ~ismember('OrderInRepeat',varsInStimParam)
        if randomize_presentation_order_inTrial
            uniRepeats = unique(T_StimParam.Repeat);
            for iRpt = 1:length(uniRepeats)
                vEntry_this_trial = find(T_StimParam.Repeat == uniRepeats(iRpt));
                if randomize_presentation_order_inTrial
                    v_ = randperm(length(vEntry_this_trial));
                else
                    v_ = 1:length(vEntry_this_trial);
                end
                T_StimParam.OrderInRepeat(vEntry_this_trial) = v_';
            end
        end
    end
    if isempty(param_sort_order)
        param_sort_order_def = {'Repeat','OrderInRepeat'};
        param_sort_order = param_sort_order_def;
    end
    T_StimParam = sortrows(T_StimParam,param_sort_order);
    if ~ismember('TrialID',varsInStimParam)
        T_StimParam.TrialID = (1:height(T_StimParam))'; 
        T_StimParam=movevars(T_StimParam,'TrialID','Before',1);
    end
    %
    %% Update the matfile log
    if ~isempty(matfile_log) && isa(matfile_log, 'matlab.io.MatFile')
        % do nothing, already a matfile object
        varsInMAT = who(matfile_log);
    else
        %$
        if ~exist(matfile_log,'file')
            fpath_matfile_log = fullfile(MatrixDirectory,['Matrix-',char(filename),'.mat']);
        end
        matfile_log = matfile(fpath_matfile_log,'Writable',true);
        varsInMAT = [];
    end
    %
    if ~ismember('T_StimParam',varsInMAT)
        matfile_log.T_StimParam = T_StimParam;
        TotalTrials = height(T_StimParam);
    else
        TotalTrials = height(matfile_log.T_StimParam);
    end
    %% initialize Cerestim
    cerestim = BStimulator();
    connx = connect(cerestim);

    if connx < 0
        error('Can''t connect to cerestim')
    end
    %
    c = onCleanup(@()cleanupfunction(cerestim,logfileTxt));
    %
    %%
    pause on
    % 'prime' the Cerestim/Cerelab connection and res object that's used to command the Cerestim
    % ZY note: the necessity of this is not clear, but it is recommended by ACP based on legacy codes
    % ZY note 2: for priming, shouldn't we prime to a lower current level?
    pulses  = 1;
    frequency = 1000;
    res = configureStimulusPattern(cerestim, 1, 'AF', pulses, ...
            stimamplitude, stimamplitude, pulsewidth, pulsewidth, frequency, interphase);
    res = configureStimulusPattern(cerestim, 2, 'CF', pulses, ...
            stimamplitude, stimamplitude, pulsewidth, pulsewidth, frequency, interphase);
    %
    if ismember('stimMatrix',varsInMAT)
        stimMatrix_all = matfile_log.stimMatrix;
    else
        stimMatrix_all = [];
    end
    stimMatrix = nan(height(T_StimParam),8);
    %
    uniRepeats = unique(T_StimParam.Repeat);
    for iRpt = 1:length(uniRepeats)
        T_Rpt = T_StimParam(T_StimParam.Repeat==uniRepeats(iRpt),:);
        for iStim = 1:height(T_Rpt)
            T_ = T_Rpt(iStim,:);
            %%
            trial= T_.TrialID;
            frequency_desire = T_.Frequency;
            delay = T_.Delay;
            stimchans = T_.ChanPair{1};
            numtrials = 1;
            %%
            if (frequency_desire > 15)
                pulses = floor(frequency_desire*trainlength/1000);
                frequency = frequency_desire;
                res = configureStimulusPattern(cerestim, 3, 'AF', ...
                    pulses, stimamplitude, stimamplitude, ...
                    pulsewidth, pulsewidth,frequency, interphase);
                res = configureStimulusPattern(cerestim, 4, 'CF', ...
                    pulses, stimamplitude, stimamplitude, ...
                    pulsewidth, pulsewidth, frequency, interphase);
                %
                res = beginningOfSequence(cerestim);
                res = beginningOfGroup(cerestim);
                res = autoStimulus(cerestim, stimchans(1), 3);
                res = autoStimulus(cerestim, stimchans(2), 4);
                res = endOfGroup(cerestim);
                res = endOfSequence(cerestim);
                res = play(cerestim,1);

            else
                pulses = 1;
                frequency = 1000/(1000/frequency_desire - floor(1000/frequency_desire)+1);
                res = configureStimulusPattern(cerestim, 3, 'AF', ...
                    pulses, stimamplitude, stimamplitude, ...
                    pulsewidth, pulsewidth, frequency, interphase);
                res = configureStimulusPattern(cerestim, 4, 'CF', ...
                    pulses, stimamplitude, stimamplitude, ...
                    pulsewidth, pulsewidth, frequency, interphase);
                %
                res = beginningOfSequence(cerestim);
                res = beginningOfGroup(cerestim);
                res = autoStimulus(cerestim, stimchans(1), 3);
                res = autoStimulus(cerestim, stimchans(2), 4);
                res = endOfGroup(cerestim);
                res = wait(cerestim, floor(1000/frequency_desire)-1);
                res = endOfSequence(cerestim);
                
                res = play(cerestim,floor(frequency_desire*trainlength/1000));
                
                status = readSequenceStatus(cerestim);
                while (status == 2)
                    status = readSequenceStatus(cerestim);
                end
                
            end
            %     stimMatrix(trial,:) = [tr stimchans numtrials stimamplitude trainlength frequency_desire delay];  
            stimMatrix(trial,:) = [trial stimchans numtrials stimamplitude trainlength frequency_desire delay];
            %     fprintf(logfileTxt,'%d\t%d\t%d\n\r',trial,frequency_desire,delay);
            fprintf(logfileTxt,'%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n\r',trial,stimchans(1),stimchans(2),pulses,stimamplitude,trainlength,frequency_desire,delay);
            fprintf(logfileTxt,'\n\r');
            fprintf('Trial %d of %d, Frequency %d, duration %d ms, Delay %d, Stim-CHs @ [%d(-),%d(+)]\n\n',...
                trial,TotalTrials,frequency_desire,trainlength, delay,stimchans(1),stimchans(2))
            %
            pause(intertrialinterval+(2*rand-1)*1.0);
        end
        %
    end
    
    %%
    %{
    disconnect(cerestim);
    delete(cerestim);
    fclose(logfileTxt);
    %}
    %%
    % save to matfile_log
    stimMatrix_all = cat(1,stimMatrix_all,stimMatrix);
    matfile_log.stimMatrix = stimMatrix_all;
    %
    diary off

end

function cleanupfunction(cerestim,logfile)

disconnect(cerestim);
delete(cerestim);
fclose(logfile);

end

    
function out = CombVec(varargin)
    %CombVec Generate all possible combinations of input vectors.
    %
    %   CombVec(A1,A2,...) takes any number of inputs,
    %      A1 - Matrix of N1 (column) vectors.
    %      A2 - Matrix of N2 (column) vectors.
    %      ...
    %    and returns a matrix of (N1*N2*...) column vectors, where the columns
    %    consist of all possibilities of A2 vectors, appended to
    %    A1 vectors, etc.
    %
    %  Example
    %  
    %    a1 = [1 2];
    %    a2 = [3 4; 3 4];
    %    a3 = CombVec(a1,a2)
    %    a3 = 
    %        1     2     1     2
    %        3     3     4     4
    %        3     3     4     4
    
    % 2008-08-06 DN  Wrote it, modification of CombVec in Matlab's Neural
    %                Network Toolbox
    
    if isempty(varargin)
        out = [];
    else
        out = varargin{1};
        for i=2:length(varargin)
            cur = varargin{i};
            out = [copyb(out,size(cur,2)); copyi(cur,size(out,2))];
        end
    end
end
%=========================================================
function b = copyb(mat,s)

[mr,mc] = size(mat);
inds    = 1:mc;
inds    = inds(ones(s,1),:).';
b       = mat(:,inds(:));
end

%=========================================================
function b = copyi(mat,s)

[mr,mc] = size(mat);
inds    = 1:mc;
inds    = inds(ones(s,1),:);
b       = mat(:,inds(:));
end    

function [y,flag_transposed,flag_squeezed] = forceColumn_ZY(x,varargin)
    if nargin>1
        force_transpose = varargin{1};
    else
        force_transpose = 0;
    end
    % force column major, i.e. size(1) >= size(2)
    flag_squeezed = 0;
    flag_transposed = 0;
    %
    if ndims(x)>2
        x2 = squeeze(x);
        %
        if ndims(x2)>2
            warning('forceColumn_ZY only applies to 1D or 2D arrays, input not changed')
            y = x; flag_transposed = -1;  
            return
        end
        x = x2; flag_squeezed = ndims(x2)~=ndims(x);
    end
    % 
    y=x;
    if size(x,2)>size(x,1) && ((size(x,1)==1) || force_transpose),  % only transpose when size =1
        y = x'; 
        flag_transposed = 1;
    end
end