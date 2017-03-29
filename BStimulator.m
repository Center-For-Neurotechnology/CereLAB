classdef BStimulator < handle
    %BStimulator: MATLAB class wrapper to the underlying C++ class BStimulator
    %   Go to http://www.mathworks.com/matlabcentral/fileexchange/38964-example-matlab-class-wrapper-for-a-c++-class
    %   for more details on the "handle" implementation here.
    %
    %   The BStimulator command will create a BStimulator object, which can
    %   then be used to reference the Cerestim (once connected).  
    %   
    %   Example:
    %   cerestim = BStimulator();
    %   res = connect(cerestim);
    %
    %%%%%%%%%%%%%%%   List of Implemented Methods   %%%%%%%%%%%%%%%
    %   BStimulator()           
    %       - Constructs and returns a cerestim handle
    %   delete(BStimulator)     
    %       - Deletes a cerestim handle
    %   connect(BStimulator)    
    %       - Connects to a cerestim, if possible
    %   disconnect(BStimulator) 
    %       - Disconnects from cerestim
    %   manualStimulus(BStimulator, electrode, waveformID)
    %       - Send a single stimulation
    %   beginningOfSequence(BStimulator)
    %       - First command of a stimulation script
    %   endOfSequence(BStimulator)
    %       - Last command of a stimulation script
    %   beginningOfGroup(BStimulator)
    %       - Begin simultaneous stimulation commands
    %   endOfGroup(BStimulator)
    %       - End simultaneous stimulation commands
    %   autoStimulus(BStimulator, electrode, waveformID)
    %       - Stimulus command to be used within a stimulation script
    %   wait(BStimulator, milliseconds)
    %       - Adds a wait to a stimulation script
    %   play(BStimulator, times)
    %       - Number of repetitions to run the stimulation script
    %   stop(BStimulator)
    %       - Stops a stimulation script from running
    %   pause(BStimulator)
    %       - Pauses a stimulation script
    %   configureStimulusPattern(BStimulator, waveformID, polarity, pulses, amp1, amp2, width1, width2, frequency, interphase)
    %       - Configures a stimulation waveform
    %   readSequenceStatus(BStimulator)
    %       - Reads current status of stimulator
    %   readStimulusPattern(BStimulator, waveformID)
    %       - Reads back a stimulation waveform
    %   triggerStimulus(BStimulator, triggertype)
    %       - Set the stimulator to wait for a trigger
    %   stopTriggerStimulus(BStimulator)
    %       - Stops waiting for a trigger
    %   simplestim(BStimulator)
    %       - Test stimulation, useful for debugging and sanity checks
    %
    %   For more information on any of these methods, type "help BStimulator.[method]"
    %
    %   Britni Crocker 03.10.2016
    %
    %   3.14.16 - fixed typos
    
    
    properties (SetAccess = private, Hidden = true)
        objectHandle; % Handle to the underlying C++ class instance
    end
    
    methods
        %% Constructor - creates a BStimulator object and connects to cerestim
        function this = BStimulator(varargin)
        % function cerestim = BStimulator()
        %   Creates a stimulator object that is able to bind to an actual
        %   CereStim 96 that is connected to the host PC
        %
        %   Inputs: none
        %   
        %   Outputs:
        %       cerestim    a matlab handle class with a pointer to the C++
        %                   BStimulator class.  If created, this object 
        %                   must be deleted by delete(cerestim) in order to 
        %                   guarantee memory safety
        %
        %   Example:
        %       cerestim = BStimulator();
            this.objectHandle = BStimulator_mex('new',varargin{:});
        end
        
        %% Destructor - Destroy the BStimulator object, for good memory management
        function delete(this)
        % function delete(cerestim)
        %   Deletes a stimulator object created by the BStimulator() method
        %
        %   Inputs:
        %       cerestim    a stimulator object created by the
        %                   BStimulator() method.
        %
        %   Outputs: none
        %
        %   Example:
        %       delete(cerestim)
            BStimulator_mex('delete', this.objectHandle);
        end
        
        %% Connect - To connect to the Cerestim
        function connx = connect(this)
        % function connect(cerestim)
        %   Tries to establish a connection with a CereStim 96 device that
        %   is connected to the host PC
        %
        %   Inputs:
        %       cerestim    a stimulator object created by the
        %                   BStimulator() method.
        %
        %   Outputs:
        %       connx       returns 0 if connected and -1 if not connected.
        %
        %   Example:
        %       cerestim = BStimulator();
        %       connect(cerestim)
            connx = BStimulator_mex('connect',this.objectHandle);
            connx = connx - 1;
        end
        
        %% Disconnect - To disconnect the Cerestim
        function res = disconnect(this)
        % function res = disconnect(cerestim)
        %   Disconnects from a connected CereStim 96 device
        %
        %   Inputs:
        %       cerestim    a stimulator object created by the
        %                   BStimulator() method.
        %
        %   Outputs: none
        %
        %   Example:
        %       cerestim = BStimulator();
        %       connect(cerestim)
        %       disconnect(cerestim)
            res = BStimulator_mex('disconnect',this.objectHandle);
        end
        
        %% Manual Stimulus - stimulate on any electrode with a preconfigured stimulus pattern
        function res = manualStimulus(this,varargin)
        % function res = manualStimulus(cerestim, electrodeNum, waveformID)
        %   Allows the user to send a single stimulus pulse of one of the
        %   stimulation waveforms to a specified electrode.
        %
        %   Inputs:
        %       cerestim    a stimulator object created by the
        %                   BStimulator() method and connected with
        %                   connect()
        %       electrode   the electrode that should be stimulated.  Valid
        %                   values are from 1 - 96
        %       waveformID  The stimulation waveform to use.  Valid values
        %                   are from 1 - 15
        %
        %   Outputs:
        %       res         a BResult status.  Returns 0 if everything was
        %                   successful.  Otherwise, check BStimulator.h for
        %                   corresponding error messages.
        %
        %   Example:
        %       cerestim = BStimulator();
        %       connect(cerestim)
        %       res = configureStimulusPattern(cerestim, 1, 'AF', 1, 7000, 7000, 90, 90, 1000, 53);
        %       res = manualStimulus(cerestim, 1, 1);
            res = BStimulator_mex('manualStimulus',this.objectHandle,varargin{:});
        end
        
        %% beginningOfSequence
        function res = beginningOfSequence(this)
        % function res = beginningOfSequence(cerestim)
        %   This is the first command that must be called when creating a
        %   stimulation script.  After calling this you are able to call
        %   wait, autoStimulus, beginningOfGroup, and endOfGroup commands.
        %   The stimulation script can have up to 128 commands, excluding
        %   beginningOfSequence and endOfsequence.
        %
        %   Inputs: none
        %
        %   Outputs:
        %       res         a BResult status.  Returns 0 if everything was
        %                   successful.  Otherwise, check BStimulator.h for
        %                   corresponding error messages.
        %
        %   Example:
        %       cerestim = BStimulator();
        %       connect(cerestim)
        %       res = configureStimulusPattern(cerestim, 1, 'AF', 1, 7000, 7000, 90, 90, 1000, 53);
        %       res = beginningOfSequence(cerestim);
        %       res = autoStimulus(cerestim, 1, 1);
        %       res = wait(cerestim, 100);
        %       res = endOfSequence(cerestim);
        %       res = play(cerestim, 3);
            res = BStimulator_mex('beginningOfSequence',this.objectHandle);
        end
        
        %% endOfSequence
        function res = endOfSequence(this)
        % function res = endOfSequence(cerestim)
        %   This is the last command that must be called when creating a
        %   stimulation script.  It does not count towards the maximum of
        %   128 commands.
        %
        %   Inputs: none
        %
        %   Outputs:
        %       res         a BResult status.  Returns 0 if everything was
        %                   successful.  Otherwise, check BStimulator.h for
        %                   corresponding error messages.
        %
        %   Example:
        %       cerestim = BStimulator();
        %       connect(cerestim)
        %       res = configureStimulusPattern(cerestim, 1, 'AF', 1, 7000, 7000, 90, 90, 1000, 53);
        %       res = beginningOfSequence(cerestim);
        %       res = autoStimulus(cerestim, 1, 1);
        %       res = wait(cerestim, 100);
        %       res = endOfSequence(cerestim);
        %       res = play(cerestim, 3);
            res = BStimulator_mex('endOfSequence',this.objectHandle);
        end
        
        %% beginningOfGroup
        function res = beginningOfGroup(this)
        % function res = beginningOfGroup(cerestim)
        %   This command signifies that the following commands up to the
        %   endOfGroup command should all occur simultaneously.  The only
        %   commands that are valid are the autoStimulus commands.  You can
        %   only have as many stimulations as the number of current modules
        %   installed.  Can't be called on the last of the 128 instructions
        %   since it needs to have a closing endOfGroup command.
        %
        %   Inputs: none
        %
        %   Outputs:
        %       res         a BResult status.  Returns 0 if everything was
        %                   successful.  Otherwise, check BStimulator.h for
        %                   corresponding error messages.
        %
        %   Example:
        %       cerestim = BStimulator();
        %       connect(cerestim)
        %       res = configureStimulusPattern(cerestim, 1, 'AF', 1, 7000, 7000, 90, 90, 1000, 53);
        %       res = configureStimulusPattern(cerestim, 2, 'CF', 1, 7000, 7000, 90, 90, 1000, 53);
        %       res = beginningOfSequence(cerestim);
        %       res = beginningOfGroup(cerestim);
        %       res = autoStimulus(cerestim, 1, 1);
        %       res = autoStimulus(cerestim, 2, 2);
        %       res = endOfGroup(cerestim);
        %       res = wait(cerestim, 100);
        %       res = endOfSequence(cerestim);
        %       res = play(cerestim, 3);
            res = BStimulator_mex('beginningOfGroup',this.objectHandle);
        end
        
        %% endofGroup
        function res = endOfGroup(this)
        % function res = endOfGroup(cerestim)
        %   This command closes off a group of simultaneous stimulations.
        %   If beginningOfGroup is called during a sequence of commands,
        %   then there must be an endOfGroup otherwise the user will get a
        %   sequence error as a return value.
        %
        %   Inputs: none
        %
        %   Outputs:
        %       res         a BResult status.  Returns 0 if everything was
        %                   successful.  Otherwise, check BStimulator.h for
        %                   corresponding error messages.
        %
        %   Example:
        %       cerestim = BStimulator();
        %       connect(cerestim)
        %       res = configureStimulusPattern(cerestim, 1, 'AF', 1, 7000, 7000, 90, 90, 1000, 53);
        %       res = configureStimulusPattern(cerestim, 2, 'CF', 1, 7000, 7000, 90, 90, 1000, 53);
        %       res = beginningOfSequence(cerestim);
        %       res = beginningOfGroup(cerestim);
        %       res = autoStimulus(cerestim, 1, 1);
        %       res = autoStimulus(cerestim, 2, 2);
        %       res = endOfGroup(cerestim);
        %       res = wait(cerestim, 100);
        %       res = endOfSequence(cerestim);
        %       res = play(cerestim, 3);
            res = BStimulator_mex('endOfGroup',this.objectHandle);
        end  
        
        %% AutoStimulus - stimulate on any electrode with a preconfigured stimulus pattern
        function res = autoStimulus(this,varargin)  
        % function res = autoStimulus(cerestim, electrodeNum, waveformID)
        %   This command tells the stimulator when to send a stimulus to an
        %   electrode in a stimulation script.  It can be used as a many
        %   times as needed so long as the total number of commands does
        %   not exceed 128.  It should also be used within beginningOfGroup
        %   and endOfGroup commands to allow for simultaneous stimulations.
        %
        %   Inputs:
        %       cerestim    a stimulator object created by the
        %                   BStimulator() method and connected with
        %                   connect()
        %       electrode   the electrode that should be stimulated.  Valid
        %                   values are from 1 - 96
        %       waveformID  The stimulation waveform to use.  Valid values
        %                   are from 1 - 15
        %
        %   Outputs:
        %       res         a BResult status.  Returns 0 if everything was
        %                   successful.  Otherwise, check BStimulator.h for
        %                   corresponding error messages.
        %
        %   Example:
        %       cerestim = BStimulator();
        %       connect(cerestim)
        %       res = configureStimulusPattern(cerestim, 1, 'AF', 1, 7000, 7000, 90, 90, 1000, 53);
        %       res = configureStimulusPattern(cerestim, 2, 'CF', 1, 7000, 7000, 90, 90, 1000, 53);
        %       res = beginningOfSequence(cerestim);
        %       res = beginningOfGroup(cerestim);
        %       res = autoStimulus(cerestim, 1, 1);
        %       res = autoStimulus(cerestim, 2, 2);
        %       res = endOfGroup(cerestim);
        %       res = wait(cerestim, 100);
        %       res = endOfSequence(cerestim);
        %       res = play(cerestim, 3);
            res = BStimulator_mex('autoStimulus',this.objectHandle,varargin{:});
        end
        
        %% wait
        function res = wait(this, varargin)
        % function res = wait(cerestim, milliS)
        %   This command can only be used within a stimulation script and
        %   is capable of adding a wait of up to 65,535 milliseconds.
        %
        %   Inputs:
        %       cerestim    a stimulator object created by the
        %                   BStimulator() method and connected with
        %                   connect()
        %       milliS      the number of milliseconds to wait before
        %                   executing the next command
        %
        %   Outputs:
        %       res         a BResult status.  Returns 0 if everything was
        %                   successful.  Otherwise, check BStimulator.h for
        %                   corresponding error messages.
        %
        %   Example:
        %       cerestim = BStimulator();
        %       connect(cerestim)
        %       res = configureStimulusPattern(cerestim, 1, 'AF', 1, 7000, 7000, 90, 90, 1000, 53);
        %       res = configureStimulusPattern(cerestim, 2, 'CF', 1, 7000, 7000, 90, 90, 1000, 53);
        %       res = beginningOfSequence(cerestim);
        %       res = beginningOfGroup(cerestim);
        %       res = autoStimulus(cerestim, 1, 1);
        %       res = autoStimulus(cerestim, 2, 2);
        %       res = endOfGroup(cerestim);
        %       res = wait(cerestim, 100);
        %       res = endOfSequence(cerestim);
        %       res = play(cerestim, 3);
            res = BStimulator_mex('wait',this.objectHandle,varargin{:});
        end   
        
        %% play
        function res = play(this, varargin)
        % function res = play(cerestim, times)
        %   Tells the stimulator the number of times that it should run the
        %   stimulation script.  A zero passed in will tell it to run
        %   indefinitely until it is either stopped or paused by the user.
        %   Other values include between 1 and 65,535 repetitions.  Cannot
        %   be called during a beginningOfSequence and endOfSequence
        %   command call.
        %
        %   Inputs:
        %       cerestim    a stimulator object created by the
        %                   BStimulator() method and connected with
        %                   connect()
        %       times       number of times to execute the stimulation
        %                   script. 0 means indefinitely
        %
        %   Outputs:
        %       res         a BResult status.  Returns 0 if everything was
        %                   successful.  Otherwise, check BStimulator.h for
        %                   corresponding error messages.
        %
        %   Example:
        %       cerestim = BStimulator();
        %       connect(cerestim)
        %       res = configureStimulusPattern(cerestim, 1, 'AF', 1, 7000, 7000, 90, 90, 1000, 53);
        %       res = configureStimulusPattern(cerestim, 2, 'CF', 1, 7000, 7000, 90, 90, 1000, 53);
        %       res = beginningOfSequence(cerestim);
        %       res = beginningOfGroup(cerestim);
        %       res = autoStimulus(cerestim, 1, 1);
        %       res = autoStimulus(cerestim, 2, 2);
        %       res = endOfGroup(cerestim);
        %       res = wait(cerestim, 100);
        %       res = endOfSequence(cerestim);
        %       res = play(cerestim, 3);
            res = BStimulator_mex('play',this.objectHandle,varargin{:});
        end
        
        %% stop
        function res = stop(this)
        % function res = stop(cerestim)
        %   This will stop a currently running stimulation script and reset
        %   it so when played again it will begin from the first command.
        %   Can only be called while the stimulator has a status of
        %   stimulating or paused.
        %
        %   Inputs:
        %       cerestim    a stimulator object created by the
        %                   BStimulator() method and connected with
        %                   connect()
        %
        %   Outputs:
        %       res         a BResult status.  Returns 0 if everything was
        %                   successful.  Otherwise, check BStimulator.h for
        %                   corresponding error messages.
        %
        %   Example:
        %       cerestim = BStimulator();
        %       connect(cerestim)
        %       res = configureStimulusPattern(cerestim, 1, 'AF', 1, 7000, 7000, 90, 90, 1000, 53);
        %       res = configureStimulusPattern(cerestim, 2, 'CF', 1, 7000, 7000, 90, 90, 1000, 53);
        %       res = beginningOfSequence(cerestim);
        %       res = beginningOfGroup(cerestim);
        %       res = autoStimulus(cerestim, 1, 1);
        %       res = autoStimulus(cerestim, 2, 2);
        %       res = endOfGroup(cerestim);
        %       res = wait(cerestim, 100);
        %       res = endOfSequence(cerestim);
        %       res = play(cerestim, 100);
        %       res = stop(cerestim);
            res = BStimulator_mex('stop',this.objectHandle);
        end
        
        %% pause
        function res = pause(this)        
        % function res = pause(cerestim)
        %   This will pause a currently running stimulation script and keep
        %   track of the next command that needs to be executed so if it
        %   receives a play command it can pick up where it left off.
        %
        %   Inputs:
        %       cerestim    a stimulator object created by the
        %                   BStimulator() method and connected with
        %                   connect()
        %
        %   Outputs:
        %       res         a BResult status.  Returns 0 if everything was
        %                   successful.  Otherwise, check BStimulator.h for
        %                   corresponding error messages.
        %
        %   Example:
        %       cerestim = BStimulator();
        %       connect(cerestim)
        %       res = configureStimulusPattern(cerestim, 1, 'AF', 1, 7000, 7000, 90, 90, 1000, 53);
        %       res = configureStimulusPattern(cerestim, 2, 'CF', 1, 7000, 7000, 90, 90, 1000, 53);
        %       res = beginningOfSequence(cerestim);
        %       res = beginningOfGroup(cerestim);
        %       res = autoStimulus(cerestim, 1, 1);
        %       res = autoStimulus(cerestim, 2, 2);
        %       res = endOfGroup(cerestim);
        %       res = wait(cerestim, 20);
        %       res = endOfSequence(cerestim);
        %       res = play(cerestim, 100);
        %       res = pause(cerestim);
        %       res = play(cerestim, 100);
            res = BStimulator_mex('pause',this.objectHandle);
        end
        
        %% Configure Stimulus Pattern - set one of 16 possible stimulus patterns
        function res = configureStimulusPattern(this,varargin)
        % function res = configureStimulusPattern(cerestim, waveformID, polarity, pulses, amp1, amp2, width1, width2, frequency, interphase)
        %   Takes all of the parameters needed in order to create a custom
        %   biphasic stimulation waveform.  The device is capable of
        %   handling 16 different waveforms, but waveform 0 is reserved and
        %   used for testing in getting measurements from electrodes and
        %   current modules.  While the widths and interphases have quite a
        %   range, the user needs to somewhat understand how they interact
        %   with the frequency chosen.  You don't want a stimulus waveform
        %   that is longer than the time between repeats.
        %
        %   Also note that there is a hidden limitation.  The time between
        %   pulses must be shorter than 65,535 uS (both the interphase and
        %   the implicit time until the next pulse).  Therefore, if your
        %   interphase is very short, you will not be able to have very low
        %   frequencies.  Practically speaking, the lower bound on
        %   frequencies is usually around 20 Hz.
        %
        %   Inputs:
        %       cerestim    a stimulator object created by the
        %                   BStimulator() method and connected with
        %                   connect()
        %       waveformID  the stimulation waveform that is being
        %                   configured.  1-15
        %       polarity    what polarity should the first phase be:
        %                   cathodic or anodic?  Enter 'CF' for cathodic
        %                   and 'AF' for anodic
        %       pulses      the number of stimulation pulses.  1-255
        %       amp1        the amplitude of the first phase. 100-10000 uA
        %       amp2        the amplitude of the second phase. 100-10000 uA
        %       width1      the width of the first phase in the
        %                   stimulation. 1-65,535 uS
        %       width2      the width of the second phase in the
        %                   stimulation. 1-65,535 uS
        %       frequency   the stimulation frequency at which the biphasic
        %                   pulses should repeat. 4-5000 Hz
        %       interphase  the period of time between the first and second
        %                   phases.  53-65,535 uS
        %
        %   Outputs:
        %       res         a BResult status.  Returns 0 if everything was
        %                   successful.  Otherwise, check BStimulator.h for
        %                   corresponding error messages.
        %
        %   Example:
        %       cerestim = BStimulator();
        %       connect(cerestim)
        %       res = configureStimulusPattern(cerestim, 1, 'AF', 1, 7000, 7000, 90, 90, 1000, 53);
        %       res = configureStimulusPattern(cerestim, 2, 'CF', 1, 7000, 7000, 90, 90, 1000, 53);
        %       res = beginningOfSequence(cerestim);
        %       res = beginningOfGroup(cerestim);
        %       res = autoStimulus(cerestim, 1, 1);
        %       res = autoStimulus(cerestim, 2, 2);
        %       res = endOfGroup(cerestim);
        %       res = wait(cerestim, 20);
        %       res = endOfSequence(cerestim);
        %       res = play(cerestim, 100);
        %       res = pause(cerestim);
        %       res = play(cerestim, 100);
            res = BStimulator_mex('configureStimulusPattern',this.objectHandle,varargin{:});
        end
        
        %% Read Sequence Status - read one of 
        function status = readSequenceStatus(this,verbose)
        % function stimconfig = readStimulusPattern(cerestim)
        %   Queries the cerestim and determines its current status
        %
        %   Inputs:
        %       cerestim    a stimulator object created by the
        %                   BStimulator() method and connected with
        %                   connect()
        %       verbose     optional flag for debugging.  If verbose = 1,
        %                   the function will output a written description 
        %                   of the stimulator status
        %
        %   Outputs:
        %       status      an integer with values corresponding to the
        %                   stimulator status as follows:
        %                   0   STOP    The stimulator is stopped
        %                   1   PAUSE   The stimulator is paused
        %                   2   PLAYING The stimulator is actively
        %                               delivering a stimulus
        %                   3   WRITING A sequence is being written to the
        %                               stimulator
        %                   4   TRIGGER The stimulator is waiting for a
        %                               trigger on its trigger line
        %                   5   INVALID Invalid Sequence
        %
        %   Example:
        %       cerestim = BStimulator();
        %       connect(cerestim)
        %       status = readSequenceStatus(cerestim)
            if (nargin < 2)
                verbose = 0;
            end            
            status = BStimulator_mex('readSequenceStatus',this.objectHandle);
            
            if (verbose == 1)
                switch status
                    case 0
                        disp('The stimulator is stopped.')
                    case 1
                        disp('The stimulator is paused.')
                    case 2
                        disp('The stimulator is playing.')
                    case 3
                        disp('The stimulator is writing.')
                    case 4
                        disp('The stimulator is waiting for a trigger.')
                    case 5
                        disp('Invalid Sequence.')
                    otherwise
                        disp('Error: unknown status.')
                end
            end
        end
        
        %% Read Stimulus Pattern - read one of 16 possible stimulus patterns
        function stimconfig = readStimulusPattern(this,varargin)
        % function stimconfig = readStimulusPattern(cerestim, waveformID)
        %   Reads back all of the parameters associated with a specific
        %   stimulation waveform and stores it in a matlab structure
        %
        %   Inputs:
        %       cerestim    a stimulator object created by the
        %                   BStimulator() method and connected with
        %                   connect()
        %       waveformID  The stimulation waveform to use.  Valid values
        %                   are from 1 - 15
        %
        %   Outputs:  a matlab struct containing the following properties:
        %       cerestim    a stimulator object created by the
        %                   BStimulator() method and connected with
        %                   connect()
        %       polarity    'CF' for cathodic and 'AF' for anodic
        %       pulses      the number of stimulation pulses.
        %       amp1        the amplitude of the first phase.
        %       amp2        the amplitude of the second phase.
        %       width1      the width of the first phase in the
        %                   stimulation. 
        %       width2      the width of the second phase in the
        %                   stimulation.
        %       frequency   the stimulation frequency at which the biphasic
        %                   pulses should repeat.
        %       interphase  the period of time between the first and second
        %                   phases.
        %
        %   Example:
        %       cerestim = BStimulator();
        %       connect(cerestim)
        %       res = configureStimulusPattern(cerestim, 1, 'AF', 1, 7000, 7000, 90, 90, 1000, 53);
        %       stimconfig = readStimulusPattern(cerestim, 1)
            stimconfig = BStimulator_mex('readStimulusPattern',this.objectHandle,varargin{:});
        end
        
        %% Trigger  Stimulus 
        function res = triggerStimulus(this,varargin)
        % function res = triggerStimulus(cerestim, triggertype)
        %   Allows the stimulator to wait for a trigger event before
        %   executing a stimulation script.  The stimulator has an external
        %   TTL Trigger input port that uses TTL logic levels to determine
        %   whether the input is high or low.  The stimulator can be set to
        %   fire on a rising edge, falling edge, or both.  Once in trigger
        %   mode, the stimulator is locked down from other function calls
        %   except for stopTriggerStimulus.
        %
        %   Inputs:
        %       cerestim    a stimulator object created by the
        %                   BStimulator() method and connected with
        %                   connect()
        %       triggertype the type of transition to use as the signal.
        %                   Enter 'rising' for a rising edge, 'falling' for
        %                   a falling edge, or 'change' for both
        %
        %   Outputs:
        %       res         a BResult status.  Returns 0 if everything was
        %                   successful.  Otherwise, check BStimulator.h for
        %                   corresponding error messages.
        %
        %   Example:
        %       cerestim = BStimulator();
        %       connect(cerestim)
        %       res = configureStimulusPattern(cerestim, 1, 'AF', 1, 7000, 7000, 90, 90, 1000, 53);
        %       res = configureStimulusPattern(cerestim, 2, 'CF', 1, 7000, 7000, 90, 90, 1000, 53);
        %       res = beginningOfSequence(cerestim);
        %       res = beginningOfGroup(cerestim);
        %       res = autoStimulus(cerestim, 1, 1);
        %       res = autoStimulus(cerestim, 2, 2);
        %       res = endOfGroup(cerestim);
        %       res = wait(cerestim, 20);
        %       res = endOfSequence(cerestim);
        %       res = triggerStimulus(cerestim, 'rising');
            res = BStimulator_mex('triggerStimulus',this.objectHandle,varargin{:});
        end
        
        %% Stop Trigger Stimulus
        function res = stopTriggerStimulus(this)
        % function res = stopTriggerStimulus(cerestim)
        %   Changes the state of the stimulator so that it is no longer
        %   waiting for a trigger.  Frees up the stimulator for other
        %   commands to be called.
        %
        %   Inputs:
        %       cerestim    a stimulator object created by the
        %                   BStimulator() method and connected with
        %                   connect()
        %
        %   Outputs:
        %       res         a BResult status.  Returns 0 if everything was
        %                   successful.  Otherwise, check BStimulator.h for
        %                   corresponding error messages.
        %
        %   Example:
        %       cerestim = BStimulator();
        %       connect(cerestim)
        %       res = configureStimulusPattern(cerestim, 1, 'AF', 1, 7000, 7000, 90, 90, 1000, 53);
        %       res = configureStimulusPattern(cerestim, 2, 'CF', 1, 7000, 7000, 90, 90, 1000, 53);
        %       res = beginningOfSequence(cerestim);
        %       res = beginningOfGroup(cerestim);
        %       res = autoStimulus(cerestim, 1, 1);
        %       res = autoStimulus(cerestim, 2, 2);
        %       res = endOfGroup(cerestim);
        %       res = wait(cerestim, 20);
        %       res = endOfSequence(cerestim);
        %       res = triggerStimulus(cerestim, 'rising');
        %       res = stopTriggerStimulus(cerestim);
            res = BStimulator_mex('stopTriggerStimulus',this.objectHandle);
        end
        
        %% Test Stim program - to see if I am a crazy person
        function res = simplestim(this)
        % function res = simplestim(cerestim)
        %   I just made this function for a sanity check during testing.  I
        %   doubt it will be very useful, but it's here just in case for
        %   debugging etc.
            res = BStimulator_mex('simplestim',this.objectHandle);
        end
    end
    
end

