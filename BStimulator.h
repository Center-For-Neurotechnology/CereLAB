/*!
	@file 
	@brief CereStim 96 API Primary Header File

	The Main Header file for the CereStim 96 API.  User code will need to include this file.
	The file Declares all Structures, Enums, macros, class, and functions that the user will 
	need in order to interface with Blackrock Microsystems CereStim 96

	@author Rudy Wilcox
	@version 4.01.00
	@date 7.6.2013
**/

#if !defined(BSTIMULATOR)
#define BSTIMULATOR

#ifdef BSTIM_EXPORTS
#define BSTIMAPI __declspec(dllexport)
#else
#ifndef STATIC_BSTIM_LINK
#define BSTIMAPI __declspec(dllimport)
#else
#define BSTIMAPI
#endif
#endif

// ----------------------------- BStimulator Defines -------------------------------------- //
/*!
	@typedef signed char INT8
	@brief -128 to 127

	@typedef unsigned char UINT8
	@brief 0 to 255

	@typedef signed char INT16
	@brief -32,768 to 32,767

	@typedef signed char UINT16
	@brief 0 to 65,535

	@typedef signed char INT32
	@brief -2,147,483,648 to 2,147,483,647

	@typedef signed char UINT32
	@brief 0 to 4,294,967,296

	@typedef UINT32 BStimHandle
	@brief Handle to the Blackrock Stimulator object
**/
#ifndef INT8
typedef signed char     INT8;					
#endif
#ifndef UINT8
typedef unsigned char   UINT8;					
#endif
#ifndef INT16
typedef signed short    INT16;					
#endif
#ifndef UINT16
typedef unsigned short  UINT16;					
#endif
#ifndef INT32
typedef signed int      INT32;					
#endif
#ifndef UINT32
typedef unsigned int    UINT32;					
#endif

typedef UINT32 BStimHandle;						

/*!
	@var const UINT8 MAXMODULES
	@brief The maximum number of current modules in a CereStim 96
**/
const UINT8		MAXMODULES=16;					

/*!
	@var const UINT8 MAXCHANNELS
	@brief Maximum number of channels in the CereStim 96, Channel 0 is internal and 1-96 are external
**/
const UINT8		MAXCHANNELS=97;

/*!
	@var const UINT8 BANKSIZE
	@brief Maximum number of channels per bank
**/
const UINT8		BANKSIZE=32;

/*!
	@var const UINT 8 EEPROM_SIZE
	@brief Size of EEProm on the Microcontroller is 256
**/
const INT32		EEPROM_SIZE=256;				

/*!
	@var const UINT8 NUMBER_VOLT_MEAS
	@brief Number of voltage measurements taken for every stimulation pulse
**/
const UINT8		NUMBER_VOLT_MEAS=5;			

/*!
	@var const UINT8 MAXCONFIGURATIONS
	@brief Maximum number of stimulation waveforms that can be stored on the device is 16
	
	@attention Only 15 configurations are available to the user
**/
const UINT8		MAXCONFIGURATIONS=16;			

// ----------------------------- BStimulator Enumerations ------------------------------------- //

/*!
	@brief Interface Types for connecting to the Stimulator
	
	The Stimulator is designed to be communicated via USB or RS232, and will be functional on 
	multiple platforms.  The Interface Type determines the OS and Communication method desired.

	@attention The only current implemented interface is the USB connection on a windows platform.
	This implies that the two valid options are BINTERFACE_DEFAULT or BINTERFACE_WUSB.
	The RS232 interfaces are no longer valid as the CereStim 96 design does not include a Com Port.
	It is anticipated that this API will be ported over to Unix but the timeframe is unknown.
**/
enum BInterfaceType
{
    BINTERFACE_DEFAULT	= 0,	//!<Default interface (windows USB)
    BINTERFACE_WUSB,			//!<Windows USB interface
	BINTERFACE_COUNT			//!<Number of Interfaces, always the last one
};

/*!
	@brief Polarity of First Stimulus Phase
	
	The Stimulator is capable of outputting a biphasic current pulse. the BWFType enumerator
	allows the user to determine what the polarity is of the first phase of the biphasic pulse.
**/
enum BWFType
{
    BWF_ANODIC_FIRST = 0,		//!<The first phase is anodic
    BWF_CATHODIC_FIRST,			//!<The first phase is cathodic
    BWF_INVALID					//!<Invalid Selection, always the last one
};

/*!
	@brief Stimulators Internal Status

	The Stimulator has internal states, and based on those states the stimulator is allowed to
	perform different functions.  The SeqType enumerator lists all the valid states.
**/
enum BSeqType
{
    BSEQ_STOP = 0,				//!<The stimulator is stopped
    BSEQ_PAUSE,					//!<The stimulator is paused
	BSEQ_PLAYING,				//!<The stimulator is actively delivering a stimulus
    BSEQ_WRITING,				//!<A stimulus sequence is being written to the stimulator
	BSEQ_TRIGGER,				//!<The stimulator is waiting for a trigger on its trigger line
    BSEQ_INVALID				//!<Invalid Sequence, Always the last value
};

/*!
	@brief Possible Triggering Modes

	The stimulator is able to begin stimulating based on an external TTL logic.  The Trigger type defines
	the possible trigger methods.  It can be set to trigger on a low to high transistion, a high to low
	transistion, or any transistion.
**/
enum BTriggerType
{
	BTRIGGER_DISABLED = 0,		//!<Trigger mode is currently turned off
	BTRIGGER_RISING,			//!<Trigger on a low to high transistion
	BTRIGGER_FALLING,			//!<Trigger on a high to low transistion
	BTRIGGER_CHANGE,			//!<Trigger on any transistion
	BTRIGGER_INVALID			//!<Invalid Trigger, Always the last value
};

/*!
	@brief Status of the Current Modules

	The stimulator is capable of housing up to 16 current modules.  Each current module can have several states
	based on how the user has configured the stimulator.  The current modules are also capable of returning problem
	statuses based on the hardware.
**/
enum BModuleStatus
{
	BMODULE_UNAVAILABLE = 0,	//!<No current module in the specified position
	BMODULE_ENABLED,			//!<Current module in the specified position is enabled
	BMODULE_DISABLED,			//!<Current Module in the specified position is disabled
	BMODULE_OK,					//!<Voltage levels on the current module are normal
	BMODULE_VOLTAGELIMITATION,	//!<Voltage levels on the current module are below normal, Module is bad.
	BMODULE_COUNT				//!<Number of Status's, Always the Last one
};

/*!
	@brief The Configured Stimulus Waveforms

	The stimulator is capable of storing up to 16 stimulus waveforms that can then be used in any stimulus.
	Each waveform is indepently configured by the user.  The user can use different stimulus waveforms based
	on some predetermined signal based on feedback from the neural signals.

	@attention Configuration 0 is used internally by the stimulator for calibration and measurement purposes.
	the user should not try to change this configuration as it may cause incorrect reportings on output measurements.
**/
enum BConfig
{
	BCONFIG_0 = 0,				//!<Stimulation waveform configuration 0 
	BCONFIG_1,					//!<Stimulation waveform configuration 1
	BCONFIG_2,					//!<Stimulation waveform configuration 2
	BCONFIG_3,					//!<Stimulation waveform configuration 3
	BCONFIG_4,					//!<Stimulation waveform configuration 4
	BCONFIG_5,					//!<Stimulation waveform configuration 5
	BCONFIG_6,					//!<Stimulation waveform configuration 6
	BCONFIG_7,					//!<Stimulation waveform configuration 7
	BCONFIG_8,					//!<Stimulation waveform configuration 8
	BCONFIG_9,					//!<Stimulation waveform configuration 9
	BCONFIG_10,					//!<Stimulation waveform configuration 10
	BCONFIG_11,					//!<Stimulation waveform configuration 11
	BCONFIG_12,					//!<Stimulation waveform configuration 12
	BCONFIG_13,					//!<Stimulation waveform configuration 13
	BCONFIG_14,					//!<Stimulation waveform configuration 14
	BCONFIG_15,					//!<Stimulation waveform configuration 15
	BCONFIG_COUNT				//!<Total Configurations, Always the Last one
};

/*!
	@brief Output Compliance Voltage Level of the Stimulator

	The Stimulator is capable of setting different output compliance voltage levels based on the users
	needs and safety considerations.
**/
enum BOCVolt
{
	BOCVOLT4_7 = 7,				//!<Output Voltage Level 4.7V
	BOCVOLT5_3,					//!<Output Voltage Level 5.3V
	BOCVOLT5_9,					//!<Output Voltage Level 5.9V
	BOCVOLT6_5,					//!<Output Voltage Level 6.5V
	BOCVOLT7_1,					//!<Output Voltage Level 7.1V
	BOCVOLT7_7,					//!<Output Voltage Level 7.7V
	BOCVOLT8_3,					//!<Output Voltage Level 8.3V
	BOCVOLT8_9,					//!<Output Voltage Level 8.9V
	BOCVOLT9_5,					//!<Output Voltage Level 9.5V
	BOCVOLT_INVALID				//!<Invalid Compliance Voltage, Always the Last One
};

/*!
	@brief Stimulator Part Numbers

	There are many versions of the stimulator.  There are research versions of micro and macro stimulators, each with
	varying number of installed current modules; and there is a clinical version of the macro stimulator with a single 
	current module.  The part number of the device sets internal safety levels of what stimulation parameters are allowed.
**/
enum BPartNumbers
{
	PN6425 = 0,					//!<CereStim R96 Micro Stimulator Beta Unit, May be either a 3 or 16 current module unit
	PN7008,						//!<CereStim R96 Micro Stimulator 3 current module unit
	PN7039,						//!<CereStim R96 Micro Stimulator 16 current module unit
	PN7169,						//!<CereStim R96 Micro Stimulator 1 current module unit
	PN8543,						//!<CereStim R96 Micro Stimulator Customer Specified Configuration
	PN7655,						//!<CereStim R96 Macro Stimulator 3 current module unit
	PN7656,						//!<CereStim M96 Macro Stimulator Clinical 1 current module unit
	PN7875,						//!<CereStim R96 Macro Stimulator 16 current module unit
	PN8544,						//!<CereStim R96 Macro Stimulator Customer Specified Configuration
	PN_INVALID					//!<Invalid part number
};

enum BStimulatorType
{
	MICRO_STIM = 0,				//!<Micro Stimulator 
	MACRO_STIM,					//!<Macro Stimulator
	INVALID_STIM				//!<Invalid
};

/*!
	@brief USB Events

	Since the stimulator is a HID, it can be plugged in and unplugged from the Host PC at will.  The USB events
	capture the status of wheather the device is attached or not.
**/
enum BEventType
{
    BEVENT_DEVICE_ATTACHED = 0,		//!<CereStim 96 is Attached to Host PC
    BEVENT_DEVICE_DETACHED,			//!<CereStim 96 is Detached from Host PC
    BEVENT_COUNT					//!<Number of Events, Always the last value
};

/*!
	@brief Event Monitoring

	Once a connection with the stimulator has been made over the USB and a stimulator object is created, that object
	needs to be notified of any events that take place.  This is handled through a callback function.
**/
enum BCallbackType
{
    BCALLBACK_ALL = 0,				//!<Monitor all events
    BCALLBACK_DEVICE_ATTACHMENT,	//!<Monitor device attachment
    BCALLBACK_COUNT					//!<Number of Callback Types, Always the last value
};

/*!
	@brief Callback function

	The callback function serves to notify the stimulator object of wheather or not the stimulator has been detached or 
	reattached to the Host PC.
**/
typedef void (* BCallback)(BEventType type, void* pCallbackData);


/*!
	@brief Return values from calls to the Stimulator object

	A stimulator object creates a USB connection with the actual CereStim 96 and calls are made to it through the
	stimulator object.  The stimulator object can return an error message (Software Error) or the CereStim 96 can
	return an error message (Hardware Error).
**/
enum BResult
{
    BRETURN                 =     1, //!<Software Error: Early returned warning
    BSUCCESS                =     0, //!<Software Error: Successful operation
    BNOTIMPLEMENTED         =    -1, //!<Software Error: Not implemented
    BUNKNOWN                =    -2, //!<Software Error: Unknown error
    BINVALIDHANDLE          =    -3, //!<Software Error: Invalid handle
    BNULLPTR                =    -4, //!<Software Error: Null pointer
    BINVALIDINTERFACE       =    -5, //!<Software Error: Invalid intrface specified or interface not supported
    BINTERFACETIMEOUT       =    -6, //!<Software Error: Timeout in creating the interface
	BDEVICEREGISTERED		=	 -7, //!<Software Error: Device with that address already connected.
    BINVALIDPARAMS          =    -8, //!<Software Error: Invalid parameters
    BDISCONNECTED           =    -9, //!<Software Error: Stim is disconnected, invalid operation
    BCONNECTED              =   -10, //!<Software Error: Stim is connected, invalid operation
	BSTIMATTACHED			=	-11, //!<Software Error: Stim is attached, invalid operation
	BSTIMDETACHED			=	-12, //!<Software Error: Stim is detached, invalid operation
    BDEVICENOTIFY           =   -13, //!<Software Error: Cannot register for device change notification
    BINVALIDCOMMAND         =   -14, //!<Software Error: Invalid command
    BINTERFACEWRITE         =   -15, //!<Software Error: Cannot open interface for write
    BINTERFACEREAD          =   -16, //!<Software Error: Cannot open interface for read
    BWRITEERR               =   -17, //!<Software Error: Cannot write command to the interface
    BREADERR                =   -18, //!<Software Error: Cannot read command from the interface
    BINVALIDMODULENUM       =   -19, //!<Software Error: Invalid module number specified
    BINVALIDCALLBACKTYPE    =   -20, //!<Software Error: Invalid callback type
    BCALLBACKREGFAILED      =   -21, //!<Software Error: Callback register/unregister failed
	BLIBRARYFIRMWARE		=	-22, //!<Software Error: CereStim Firmware version not supported by SDK Library Version
	BFREQPERIODZERO			=	-23, //!<Software Error: Frequency or Period is zero and unable to be converted

	BNOK					=  -100, //!<Hardware Error: Comamnd result not OK
	BSEQUENCEERROR			=  -102, //!<Hardware Error: Sequence Error
	BINVALIDTRIGGER			=  -103, //!<Hardware Error: Invalid Trigger
	BINVALIDCHANNEL			=  -104, //!<Hardware Error: Invalid Channel
	BINVALIDCONFIG			=  -105, //!<Hardware Error: Invalid Configuration
	BINVALIDNUMBER			=  -106, //!<Hardware Error: Invalid Number
	BINVALIDRWR				=  -107, //!<Hardware Error: Invalid Read/Write
	BINVALIDVOLTAGE			=  -108, //!<Hardware Error: Invalid Voltage
	BINVALIDAMPLITUDE		=  -109, //!<Hardware Error: Invalid Amplitude
	BINVALIDAFCF			=  -110, //!<Hardware Error: Invalid AF/CF
	BINVALIDPULSES			=  -111, //!<Hardware Error: Invalid Pulses
	BINVALIDWIDTH			=  -112, //!<Hardware Error: Invalid Width
	BINVALIDINTERPULSE		=  -113, //!<Hardware Error: Invalid Interpulse
	BINVALIDINTERPHASE		=  -114, //!<Hardware Error: Invalid Interphase
	BINVALIDFASTDISCH		=  -115, //!<Hardware Error: Invalid Fast Discharge
	BINVALIDMODULE			=  -116, //!<Hardware Error: Invalid Module
	BSTIMULIMODULES			=  -117, //!<Hardware Error: More Stimuli than Modules
	BMODULEUNAVAILABLE		=  -118, //!<Hardware Error: Module not Available
	BCHANNELUSEDINGROUP		=  -119, //!<Hardware Error: Channel already used in Group
	BCONFIGNOTACTIVE		=  -120, //!<Hardware Error: Configuration not Active
	BEMPTYCONFIG			=  -121, //!<Hardware Error: Empty Config
	BPHASENOTBALANCED		=  -122, //!<Hardware Error: Phases not Balanced
	BPHASEGREATMAX			=  -123, //!<Hardware Error: Phase Charge Greater than Max
	BAMPGREATMAX			=  -124, //!<Hardware Error: Amplitude Greater than Max
	BWIDTHGREATMAX			=  -125, //!<Hardware Error: Width Greater than Max
	BVOLTGREATMAX			=  -126, //!<Hardware Error: Voltage Greater than Max
	BMODULEDISABLED			=  -127, //!<Hardware Error: Module already disabled can't disable it
	BMODULEENABLED			=  -128, //!<Hardware Error: Module already enabled can't reenable it
	BINVALIDFREQUENCY		=  -129, //!<Hardware Error: Invalid Frequency
	BFREQUENCYGREATMAX		=  -130, //!<Hardware Error: The frequency is greater than the max value allowed
	BDEVICELOCKED			=  -131, //!<Hardware Error: Device locked due to hardware mismatch or not being configured
	BECHOERROR				=  -132	 //!<Hardware Error: Command returned was not the same command sent
};

// --------------------------------- BStimulator Structures ---------------------------------------- //

// One-byte packing
#pragma pack(push, 1)
/*!
	@brief USB Parameters

	The USB parameters that need to be configured in order to have the stimulator object
	actually connect with the CereStim 96 over usb.
**/
struct BUsbParams{
    UINT32 size;					//!<sizeof(BStimUsbParams)
    UINT32 timeout;					//!<How long to try before timeout (mS)
    UINT32 vid;						//!<vendor ID
    UINT32 pid;						//!<product ID
};

#pragma pack(pop)

/*!
	@brief API Version

	Gives the current version of the API that is being used.
**/
struct  BVersion{
    UINT8 major;					//!<Major Version
    UINT8 minor;					//!<Minor Version
    UINT8 release;					//!<Wheather the Version is Released
    UINT8 beta;						//!<Wheather the Version is Beta
};

/*!
	@brief Measured Stimulus Voltage

	The stimulator is capable of sending out a stimulus using known values and measure the voltage
	that is returned at five locations during the course of that stimulation.  The five values in 
	order are as follows: Just before the first phase, during the first phase, in between phases,
	during the second phase, and just after the second phase.
**/
struct BOutputMeasurement
{
    INT16	measurement[NUMBER_VOLT_MEAS];			//!<Voltages are returned in millivolts
};

/*!
	@brief Measured Output Voltaged

	The Stimulator is capable of measuring what its current output compliance voltage level is using
	a known impedance and stimulus parameters.
**/
struct BMaxOutputVoltage
{
	UINT16 miliVolts;								//!<Voltages are returned in millivolts
};

/*!
	@brief CereStim 96 Device Specific Information

	The stimulator has several different micro controllers that it uses.  These are on the motherboard and current
	modules.  As a result, it is very helpful for troubleshooting and debugging to see what versions of the firmware
	are stored on the motherboard and current modules as well as what the status of how many current modules are 
	installed and what communication protocol is being used.
**/
struct BDeviceInfo
{
    UINT32	serialNo;								//!<Hardware part number, type, and serial number 0xPN TY SN SN
    UINT16	mainboardVersion;						//!<MSB = version , LSB = subversion (i.e. 0x020A = version 2.10)
    UINT16	protocolVersion;						//!<MSB = version , LSB = subversion (i.e. 0x020A = version 2.10)
    UINT8	moduleStatus[MAXMODULES];				//!<0x00 = Not available.   0x01 = Enabled.   0x02 = Disabled
    UINT16	moduleVersion[MAXMODULES];				//!<MSB = version , LSB = subversion (i.e. 0x020A = version 2.10)
};

/*!
	@brief Components of the Stimulus Configurations

	The stimulator is capable of custom configuring a biphasic stimulus.  The amplitudes and widths and frequency
	are all a part of the components that can be configured.  The main restriction is that the two phases are 
	balanced, i.e. width * amp of phase 1 is equal to width * amp of phase 2.
**/
struct BStimulusConfiguration
{
    UINT8	anodicFirst;							//!<0x01 = anodic first, 0x00 = cathodic first
    UINT8	pulses;									//!<Number of biphasic pulses (from 1 to 255)
    UINT16	amp1;									//!<Amplitude first phase (uA)
    UINT16	amp2;									//!<Amplitude second phase (uA)
    UINT16	width1;									//!<Width first phase (us)
    UINT16	width2;									//!<Width second phase (us)
    UINT32	frequency;								//!<Frequency of stimulation pulses (Hz)
    UINT16	interphase;								//!<Time between phases (us)
};

/*!
	@brief Status of the Stimulator

	The stimulator can always be queried to determine what state it is in.
	
	@see BSeqType
**/
struct BSequenceStatus
{
	UINT8	status;									//!<Contains status of the stimulator
};

/*!
	@brief Admin Max Values

	The stimulator has an administrative interface that allows the primary researcher to set
	additional safety levels depending on there stimulation protocols and parameters.
	
**/
struct BMaximumValues
{
	UINT8	voltage;								//!<Max voltage value @see BOCVolt
	UINT16	amplitude;								//!<Amplitude (uA)
	UINT32	phaseCharge;							//!<Charge per phase (pC)
	UINT32	frequency;								//!<Frequency (Hz)
};

/*!
	@brief Electrode Diagnostics

	The stimulator allows for diagnosising the status of the electrodes attached to it.  A known stimulus is sent to each electrode
	and the voltage is recorded for the five data points during a stimulation, i.e. before the first phase, during the first phase,
	between the two phases, during the second phase and after the second phase.  These voltage levels are then used along with
	the known stimulation to calculate the impedance of each electrode.  A 1 kHz frequency is used for the stimulation.

**/
struct BTestElectrodes
{
	INT16 electrodes[MAXCHANNELS][NUMBER_VOLT_MEAS];//!<5 voltage measurements for all 96 channels reported in millivolts
	UINT32 impedance[MAXCHANNELS];					//!<Real part of Impedance of each electrode reported in Ohms
};

/*!
	@brief Module Diagnostics

	The stimulator uses current modules to deliver stimulus through electrodes.  These modules may become damaged and so the stimulator
	uses a known load and stimulus parameter to determine if the voltage levels on the current module are as they should be.

**/
struct BTestModules
{
	INT16 modulesMV[MAXMODULES][NUMBER_VOLT_MEAS];	//!<5 voltage measurements for all current modules reported in millivolts
	BModuleStatus   modulesStatus[MAXMODULES];		//!<Status of each current module @see BModuleStatus
};

/*!
	@brief Group Stimulus

	The stimulator allows for a group of simultaneous stimulations to occur.  Two methods exist for doing this,
	first is creating a program script and issueing several different calls.  The second method saves on the USB
	overhead by allowing a single call to set up the simultaneous stimulations.

**/
struct BGroupStimulus
{
	UINT8 electrode[MAXMODULES];					//!<electrodes to stimulate
	UINT8 pattern[MAXMODULES];						//!<Configuration Pattern to use with coresponding channel
};

/*!
	@brief CereStim 96 Motherboard EEprom

	The EEprom on the microcontroller stores the information that should be preserved over time even when the device is off
	or unplugged.  These values can be read in order to debug or know the status of different components within the device.

**/
struct BReadEEpromOutput
{
	UINT8 eeprom[EEPROM_SIZE];						//!<eeprom values
};

/*!
	@brief  Hardware Values of the CereStim 96

	The stimulators various models have some different hardware configurations, so it is beneficial to get those hardware
	values of that particuliar CereStim 96.

**/
struct BReadHardwareValuesOutput
{
	UINT16 amp;										//!<Max phase amplitude based on hardware in uA
	UINT8  maxCompVoltage;							//!<Max output compliance voltage @see BOCVolt
	UINT8  minCompVoltage;							//!<Min output compliance voltage @see BOCVolt
	UINT32 charge;									//!<Max charge based on hardware in pC
	UINT32 maxFreq;									//!<Max Frequency based on hardware in Hz
	UINT32 minFreq;									//!<Min Frequency based on hardware in Hz
	UINT16 width;									//!<Max Width for each phase based on hardware in uS
	UINT16 interphase;								//!<Max Interphase width based on hardware in uS
	UINT8  modules;									//!<Number of modules installed in device
};

/*!
	@brief Map Channels to Electrodes

	The stimulator is capable of sending stimulation up to 96 different electrodes.  The layout of where those electrodes are mapped
	to sometimes are not a straight channel 1 to electrode 1, such as in a Blackrock .CMP file.  This struct allows the user to 
	specify a mapping for there electrodes so that they do not need to worry about what channel they need to stimulate if they want
	electrode 20 to be stimulated.

**/
struct BElectrodeChannelMap
{
	UINT8 bankA[BANKSIZE];							//!<UINT8 Array, the pin on bank A is the index, and the value is the acutal electrode number
	UINT8 bankB[BANKSIZE];							//!<UINT8 Array, the pin on bank B is the index, and the value is the acutal electrode number
	UINT8 bankC[BANKSIZE];							//!<UINT8 Array, the pin on bank C is the index, and the value is the acutal electrode number
};


/*!	@class BStimulator BStimulator.h
	@brief Creates a Stimulator Object

	The stimulator class encapsulates all the functionallity of the stimulator and allows the 
	user the ability to interface directly with Blackrock Microsystems CereStim 96 device.
	By encapsulating it in an object, multiple stimulators can be connected to a single Host PC
	and be used simultaneously.
*/
class BStimulator
{
protected:

	static UINT32 m_iStimObjects;
	struct BStimData;
	BStimData	*m_psData;			

public:
	BSTIMAPI class maxStimulatorError{};

	BSTIMAPI BStimulator();			
	BSTIMAPI ~BStimulator();		
	BSTIMAPI BResult connect(BInterfaceType stimInterface, void * params);
	BSTIMAPI BResult disconnect();	
	BSTIMAPI BResult libVersion(BVersion * output);	

	BSTIMAPI BResult manualStimulus(UINT8 electrode, BConfig configID);
	BSTIMAPI BResult measureOutputVoltage(BOutputMeasurement * output, UINT8 module, UINT8 electrode);
	BSTIMAPI BResult beginningOfSequence();
	BSTIMAPI BResult endOfSequence();
	BSTIMAPI BResult beginningOfGroup();
	BSTIMAPI BResult endOfGroup();
	BSTIMAPI BResult autoStimulus(UINT8 electrode, BConfig configID);
	BSTIMAPI BResult wait(UINT16 milliSeconds);
	BSTIMAPI BResult play(UINT16 times);
	BSTIMAPI BResult stop();
	BSTIMAPI BResult pause();
	BSTIMAPI BResult maxOutputVoltage(BMaxOutputVoltage * output, UINT8 rw, BOCVolt voltage);
	BSTIMAPI BResult readDeviceInfo(BDeviceInfo * output);
	BSTIMAPI BResult enableModule(UINT8 module);
	BSTIMAPI BResult disableModule(UINT8 module);
	BSTIMAPI BResult configureStimulusPattern(BConfig configID, BWFType afcf, UINT8 pulses, UINT16 amp1, UINT16 amp2,
									 UINT16 width1, UINT16 width2, UINT32 frequency, UINT16 interphase);
	BSTIMAPI BResult readStimulusPattern(BStimulusConfiguration * output, BConfig configID);
	BSTIMAPI BResult readSequenceStatus(BSequenceStatus * output);
	BSTIMAPI BResult stimulusMaxValues(BMaximumValues * output, UINT8 rw, BOCVolt voltage, UINT16 amplitude, UINT32 phaseCharge, UINT32 frequency);
	BSTIMAPI BResult groupStimulus(UINT8 beginSeq, UINT8 play, UINT16 times, UINT8 number, BGroupStimulus * input);
	BSTIMAPI BResult triggerStimulus(BTriggerType edge);
	BSTIMAPI BResult stopTriggerStimulus();
	BSTIMAPI BResult updateElectrodeChannelMap(BElectrodeChannelMap *input);
	BSTIMAPI BResult testElectrodes(BTestElectrodes * output);
	BSTIMAPI BResult testModules(BTestModules * output);
	BSTIMAPI BResult ReadHardwareValues(BReadHardwareValuesOutput * output);
	BSTIMAPI BResult ReadEeprom(BReadEEpromOutput * output);
	BSTIMAPI BResult EraseEeprom();
	BSTIMAPI BResult WriteEEProm(UINT8 addr, UINT8 val);
	BSTIMAPI BResult DisableStimulusConfiguration(UINT8 config_id);
	BSTIMAPI BResult ResetStimulator();

	BSTIMAPI INT8 isConnected();							// Returns true if you currently have an interface established between the PC and CereStim 96
	BSTIMAPI BInterfaceType getInterface();					// Returns the type of interface that is establishded between PC and CereStim 96
	BSTIMAPI void *	getParams();							// Returns the parameters that the interface is using.
	BSTIMAPI UINT32 getSerialNumber();						// Returns the CereStim 96 Serial Number
	BSTIMAPI UINT16 getMotherboardFirmwareVersion();		// Returns the CereStim 96 motherboard firmware version
	BSTIMAPI UINT16 getProtocolVersion();					// Returns the CereStim 96 protocol version
	BSTIMAPI UINT32 getMinMaxAmplitude();					// Returns the max amplitude in upper two bytes and min amplitude in lower two bytes
	BSTIMAPI BResult getModuleFirmwareVersion(UINT16* output); // Pass in the address of an UINT16 output[MAXMODULES]
	BSTIMAPI BResult getModuleStatus(UINT8* output);			// Pass in the address of an UINT8 output[MAXMODULES]
	BSTIMAPI UINT32 getUSBAddress();						// Returns the address of the USB line its plugged into Address of 0 means not connected or not plugged in
	BSTIMAPI UINT32 getMaxHardCharge();						// Returns the Maximum charge that the hardware will allow
	BSTIMAPI UINT32 getMinHardFrequency();					// Returns the minimum Frequency that the hardware will allow
	BSTIMAPI UINT32 getMaxHardFrequency();					// Returns the maximum Frequency that the Hardware will allow
	BSTIMAPI UINT8  getNumberModules();						// Returns the number of modules installed
	BSTIMAPI UINT16 getMaxHardWidth();						// Returns the maximum width of each phase that the hardware will allow
	BSTIMAPI UINT16 getMaxHardInterphase();					// Returns the maximum interphase width that the hardware will allow
	BSTIMAPI INT8 isSafetyDisabled();						// Returns true if safety checks on stimulation parameters are disabled
	BSTIMAPI INT8 isDeviceLocked();							// Returns true if the device is locked down due to hardware configuration or current module issues
};


#endif

