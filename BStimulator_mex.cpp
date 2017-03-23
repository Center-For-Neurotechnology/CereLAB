/**
Britni Crocker 03.10.2016

3.14.16 - rewrote connect() to have a defined end point

 **/


#include <stdlib.h>
#include "class_handle.hpp"
#include "BStimulator.h"
#include <iostream>
#include <math.h>
#include "mex.h"

INT8 connect(BStimulator *cerestim)
{
#ifdef _WIN32
    mexPrintf("\nAttempting to connect to Cerestim...\n");
#else
    cout << "\nAttempting to connect to Cerestim...\n";
#endif
//  BStimulator cerestim; // Create a  MyData object
    
    int attempt = 0;
    
    while (attempt < 100)
    {
        if (!cerestim->connect(BINTERFACE_DEFAULT,0))
            break;
#ifdef _WIN32
        mexPrintf("Waiting...\n");
#else
        cout << "Waiting...\n";
#endif
        attempt++;
    }
    
    if (cerestim->isConnected())
    {
#ifdef _WIN32
    mexPrintf("Connected!\n");
#else
    cout << "Connected!\n";
#endif
    }
    else
    {
#ifdef _WIN32
    mexPrintf("Not connected - please try again.\n");
#else
    cout << "Not connected - please try again.\n";
#endif        
    }
    
    
    return cerestim->isConnected();
}

BResult disconnect(BStimulator *cerestim)
{
    BResult res;
    res = cerestim->disconnect();
    
#ifdef _WIN32
    mexPrintf("Disconnected!\n");
#else
    cout << "Disconnected!\n";
#endif
    
    return res;
}

BResult manualStimulus(BStimulator* cerestim, UINT8 electrode, BConfig configID)
{
    BResult res = BSUCCESS;
    res = cerestim->manualStimulus(electrode, configID);
    return res;
}

BResult beginningOfSequence(BStimulator *cerestim)
{
    BResult res;
    res = cerestim->beginningOfSequence();
    return res;
}

BResult endOfSequence(BStimulator *cerestim)
{
    BResult res;
    res = cerestim->endOfSequence();
    return res;
}

BResult beginningOfGroup(BStimulator *cerestim)
{
    BResult res;
    res = cerestim->beginningOfGroup();
    return res;
}

BResult endOfGroup(BStimulator *cerestim)
{
    BResult res;
    res = cerestim->endOfGroup();
    return res;
}

BResult autoStimulus(BStimulator* cerestim, UINT8 electrode, BConfig configID)
{
    BResult res = BSUCCESS;
    res = cerestim->autoStimulus(electrode, configID);
    return res;
}

BResult play(BStimulator* cerestim, UINT16 times)
{
    BResult res = BSUCCESS;
    res = cerestim->play(times);
    return res;
}

BResult wait(BStimulator* cerestim, UINT16 milliSeconds)
{
    BResult res = BSUCCESS;
    res = cerestim->wait(milliSeconds);
    return res;
}

BResult stop(BStimulator* cerestim)
{
    BResult res = BSUCCESS;
    res = cerestim->stop();
    return res;
}

BResult pause(BStimulator* cerestim)
{
    BResult res = BSUCCESS;
    res = cerestim->pause();
    return res;
}

BResult configureStimulusPattern(BStimulator* cerestim, BConfig configID, 
        BWFType afcf, UINT8 pulses, UINT16 amp1, UINT16 amp2, 
        UINT16 width1, UINT16 width2, UINT32 frequency, UINT16 interphase)
{
    BMaximumValues maxValues;
    BResult res = BSUCCESS;    
    res = cerestim->stimulusMaxValues(&maxValues, 1, BOCVOLT9_5, 10000, 20000000, 5154);
    res = cerestim->configureStimulusPattern(configID, afcf, pulses, amp1, 
            amp2, width1, width2, frequency, interphase);
    return res;
}

BResult readStimulusPattern(BStimulator* cerestim, BStimulusConfiguration * stimconfig, BConfig configID)
{
    BResult res = BSUCCESS;    
    res = cerestim->readStimulusPattern(stimconfig, configID);
    return res;
}

BResult triggerStimulus(BStimulator* cerestim, BTriggerType trigtype)
{
    BResult res = BSUCCESS;    
    res = cerestim->triggerStimulus(trigtype);
    return res;
}

BResult stopTriggerStimulus(BStimulator* cerestim)
{
    BResult res = BSUCCESS;    
    res = cerestim->stopTriggerStimulus();
    return res;
}

void simplestim(BStimulator* cerestim)
{
    BMaximumValues maxValues;
    BResult res = BSUCCESS;
    res = cerestim->configureStimulusPattern((BConfig)1, BWF_CATHODIC_FIRST, 20, 10000, 10000, 300, 300, 20, 53);
    res = cerestim->manualStimulus(1, (BCONFIG_1));
    return;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    char cmd[64];
    if (nrhs < 1 || mxGetString(prhs[0], cmd, sizeof(cmd)))
        mexErrMsgTxt("First input should be a command string less than 64 characters long.");
    
    // New
    if (!strcmp("new", cmd)) {
        // Check parameters
        if (nlhs != 1)
            mexErrMsgTxt("New: One output expected.");
        // Return a handle to a new C++ instance
        plhs[0] = convertPtr2Mat<BStimulator>(new BStimulator);
        return;
    }
    
    // Check there is a second input, which should be the class instance handle
    if (nrhs < 2)
        mexErrMsgTxt("Second input should be a class instance handle.");
    
    // Delete
    if (!strcmp("delete", cmd)) {
        // Destroy the C++ object
        destroyObject<BStimulator>(prhs[1]);
        // Warn if other commands were ignored
        if (nlhs != 0 || nrhs != 2)
            mexWarnMsgTxt("Delete: Unexpected arguments ignored.");
        return;
    }
    
    // Get the class instance pointer from the second input
    BStimulator *cerestim = convertMat2Ptr<BStimulator>(prhs[1]);
    BResult res;
    INT8 connx;
    
    // Call the various class methods
    
    // connect
    if (!strcmp("connect", cmd)) {
        // Check parameters
        if (nlhs < 0 || nrhs < 2)
            mexErrMsgTxt("connect: Unexpected arguments.");
        // Call the method
        connx = connect(cerestim);
        plhs[0] = mxCreateDoubleScalar(connx);
        return;
    }
    
    // disconnect
    if (!strcmp("disconnect", cmd)) {
        // Check parameters
        if (nlhs < 0 || nrhs < 2)
            mexErrMsgTxt("connect: Unexpected arguments.");
        // Call the method
        res = disconnect(cerestim);
        plhs[0] = mxCreateDoubleScalar(res);
        return;
    }
    
    // ManualStimulus
    if (!strcmp("manualStimulus", cmd)) {
        // Check parameters
        if (nlhs < 0 || nrhs < 4)
            mexErrMsgTxt("manualStimulus: Unexpected arguments.");
        UINT8 electrode = (UINT8) mxGetScalar(prhs[2]);
        BConfig configID = (BConfig) (int) mxGetScalar(prhs[3]);
        // Call the method
        res = manualStimulus(cerestim,electrode,configID);
        plhs[0] = mxCreateDoubleScalar(res);
        return;
    }
    
    // beginningOfSequence
    if (!strcmp("beginningOfSequence", cmd)) {
        // Check parameters
        if (nlhs < 0 || nrhs < 2)
            mexErrMsgTxt("beginningOfSequence: Unexpected arguments.");
        // Call the method
        res = beginningOfSequence(cerestim);
        plhs[0] = mxCreateDoubleScalar(res);
        return;
    }
    
    // endOfSequence
    if (!strcmp("endOfSequence", cmd)) {
        // Check parameters
        if (nlhs < 0 || nrhs < 2)
            mexErrMsgTxt("endOfSequence: Unexpected arguments.");
        // Call the method
        res = endOfSequence(cerestim);
        plhs[0] = mxCreateDoubleScalar(res);
        return;
    }    
    
    // beginningOfGroup
    if (!strcmp("beginningOfGroup", cmd)) {
        // Check parameters
        if (nlhs < 0 || nrhs < 2)
            mexErrMsgTxt("beginningOfGroup: Unexpected arguments.");
        // Call the method
        res = beginningOfGroup(cerestim);
        plhs[0] = mxCreateDoubleScalar(res);
        return;
    }    
    
    // endOfGroup
    if (!strcmp("endOfGroup", cmd)) {
        // Check parameters
        if (nlhs < 0 || nrhs < 2)
            mexErrMsgTxt("endOfGroup: Unexpected arguments.");
        // Call the method
        res = endOfGroup(cerestim);
        plhs[0] = mxCreateDoubleScalar(res);
        return;
    } 
    
    // AutoStimulus
    if (!strcmp("autoStimulus", cmd)) {
        // Check parameters
        if (nlhs < 0 || nrhs < 4)
            mexErrMsgTxt("autoStimulus: Unexpected arguments.");
        UINT8 electrode = (UINT8) mxGetScalar(prhs[2]);
        BConfig configID = (BConfig) (int) mxGetScalar(prhs[3]);
        // Call the method
        res = autoStimulus(cerestim,electrode,configID);
        plhs[0] = mxCreateDoubleScalar(res);
        return;
    }
    
    // wait
    if (!strcmp("wait", cmd)) {
        // Check parameters
        if (nlhs < 0 || nrhs < 3)
            mexErrMsgTxt("wait: Unexpected arguments.");
        UINT16 milliSeconds = (UINT16) mxGetScalar(prhs[2]);
        // Call the method
        res = wait(cerestim,milliSeconds);
        plhs[0] = mxCreateDoubleScalar(res);
        return;
    }
    
    // play
    if (!strcmp("play", cmd)) {
        // Check parameters
        if (nlhs < 0 || nrhs < 3)
            mexErrMsgTxt("play: Unexpected arguments.");
        UINT16 times = (UINT16) mxGetScalar(prhs[2]);
        // Call the method
        res = play(cerestim,times);
        plhs[0] = mxCreateDoubleScalar(res);
        return;
    }
    
    // stop
    if (!strcmp("stop", cmd)) {
        // Check parameters
        if (nlhs < 0 || nrhs < 2)
            mexErrMsgTxt("stop: Unexpected arguments.");
        // Call the method
        res = stop(cerestim);
        plhs[0] = mxCreateDoubleScalar(res);
        return;
    }
    
    // pause
    if (!strcmp("pause", cmd)) {
        // Check parameters
        if (nlhs < 0 || nrhs < 2)
            mexErrMsgTxt("pause: Unexpected arguments.");
        // Call the method
        res = pause(cerestim);
        plhs[0] = mxCreateDoubleScalar(res);
        return;
    }
    
    // ConfigureStimulusPattern
    if (!strcmp("configureStimulusPattern", cmd)) {
        // Check parameters
        if (nlhs < 0 || nrhs < 11)
            mexErrMsgTxt("configureStimulusPattern: Unexpected arguments.");
        BConfig configID = (BConfig) (int) mxGetScalar(prhs[2]);
        char bwf[3];
        BWFType afcf = BWF_INVALID;
        mxGetString(prhs[3], bwf, sizeof(bwf));
        if (!strcmp("AF", bwf)) afcf = BWF_ANODIC_FIRST;
        if (!strcmp("CF", bwf)) afcf = BWF_CATHODIC_FIRST;
        UINT8 pulses = (UINT8) mxGetScalar(prhs[4]);
        UINT16 amp1 = (UINT16) mxGetScalar(prhs[5]);
        UINT16 amp2 = (UINT16) mxGetScalar(prhs[6]);
        UINT16 width1 = (UINT16) mxGetScalar(prhs[7]);
        UINT16 width2 = (UINT16) mxGetScalar(prhs[8]);
        UINT32 frequency = (UINT32) mxGetScalar(prhs[9]);
        UINT16 interphase = (UINT16) mxGetScalar(prhs[10]);
        // Call the method
        res = configureStimulusPattern(cerestim, configID, afcf, pulses, 
                amp1, amp2, width1, width2, frequency, interphase);
        plhs[0] = mxCreateDoubleScalar(res);
        return;
    }
    
    // ReadStimulusPattern
    if (!strcmp("readStimulusPattern", cmd)) {
        // Check parameters
        if (nlhs < 0 || nrhs < 3)
            mexErrMsgTxt("readStimulusPattern: Unexpected arguments.");
        BConfig configID = (BConfig) (int) mxGetScalar(prhs[2]);
        BStimulusConfiguration * stimconfig;
        // Call the method
        res = readStimulusPattern(cerestim, stimconfig, configID);
        const char *field_names[] = {"anodicFirst", "pulses", "amp1", 
            "amp2", "width1", "width2", "frequency", "interphase"};
        mxArray *stimstruct = mxCreateStructMatrix(1, 1, 8, field_names);
        if (stimconfig->anodicFirst == 0x01)
        {
            mxSetField(stimstruct, 0, "anodicFirst", mxCreateString("CF"));
        }
        if (stimconfig->anodicFirst == 0x00)
        {
            mxSetField(stimstruct, 0, "anodicFirst", mxCreateString("AF"));
        }
        mxSetField(stimstruct, 0, "pulses", mxCreateDoubleScalar(stimconfig->pulses));
        mxSetField(stimstruct, 0, "amp1", mxCreateDoubleScalar(stimconfig->amp1));
        mxSetField(stimstruct, 0, "amp2", mxCreateDoubleScalar(stimconfig->amp2));
        mxSetField(stimstruct, 0, "width1", mxCreateDoubleScalar(stimconfig->width1));
        mxSetField(stimstruct, 0, "width2", mxCreateDoubleScalar(stimconfig->width2));
        mxSetField(stimstruct, 0, "frequency", mxCreateDoubleScalar(stimconfig->frequency));
        mxSetField(stimstruct, 0, "interphase", mxCreateDoubleScalar(stimconfig->interphase));
        plhs[0] = stimstruct;
        return;
    }
    
    // TriggerStimulus
    if (!strcmp("triggerStimulus", cmd)) {
        // Check parameters
        if (nlhs < 0 || nrhs < 3)
            mexErrMsgTxt("triggerStimulus: Unexpected arguments.");
        BTriggerType trigtype = BTRIGGER_INVALID;
        char bwf[10];
        mxGetString(prhs[2], bwf, sizeof(bwf));
        if (!strcmp("rising", bwf)) trigtype = BTRIGGER_RISING;
        if (!strcmp("falling", bwf)) trigtype = BTRIGGER_FALLING;
        if (!strcmp("change", bwf)) trigtype = BTRIGGER_CHANGE;
        // Call the method
        res = triggerStimulus(cerestim, trigtype);
        plhs[0] = mxCreateDoubleScalar(res);
        return;
    }
    
    // StopTriggerStimulus
    if (!strcmp("stopTriggerStimulus", cmd)) {
        // Check parameters
        if (nlhs < 0 || nrhs < 2)
            mexErrMsgTxt("stopTriggerStimulus: Unexpected arguments.");
        // Call the method
        res = stopTriggerStimulus(cerestim);
        plhs[0] = mxCreateDoubleScalar(res);
        return;
    }
    
    // SimpleStim
    if (!strcmp("simplestim", cmd)) {
        // Check parameters
        if (nlhs < 0 || nrhs < 2)
            mexErrMsgTxt("simplestim: Unexpected arguments.");
        // Call the method
        simplestim(cerestim);
        return;
    }
    
    // Got here, so command not recognized
    mexErrMsgTxt("Command not recognized.");
    
    return;
}