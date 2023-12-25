
/**  Copyright 2022 Pawel Goralski
    
    This file is part of AMIDILIB.
    See license.txt for licensing information.
*/

#include "amidilib.h"
#include "config.h"
#include "midi_in.h"

#include "fileio.h"
#include "core/amprintf.h"
#include "input/scancode.h"	
#include "input/ikbd.h"
#include "opl3.h"

#define MIDI_IN_BUFFER_SIZE 1024

void printHelpScreen(const uint8 midiInChannel)
{
  amPrintf("==============================================="NL);
  amPrintf("/|\\ opl2/3 sound output test.."NL);

#if AMIDILIB_USE_LIBC
    amPrintf("build date: %s %s"NL,__DATE__,__TIME__);
#else  
    amPrintf("build date: %s %s nolibc"NL,__DATE__,__TIME__);
#endif

  amPrintf("[q-h] - play note"NL);
  
  amPrintf("[i] - show this help screen "NL);
  amPrintf("[spacebar] - turn off all sounds "NL);
  amPrintf("[Esc] - quit"NL);
  amPrintf("[listening midi data on [%u] channel]"NL, midiInChannel);
  amPrintf("(c)Nokturnal 2022"NL);
  amPrintf("================================================"NL);
}

void increaseGlobalMasterVolume(void)
{
  amPrintf("Increase global Master volume"NL);
}

void decreaseGlobalMasterVolume(void)
{
  amPrintf("Decrease global Master volume"NL);
}

static AM_NOINLINE void amOplNoteOffCb(const sMidiInCommon *common, const sNoteOff_t *eventData, void *userData)
{
	amTrace("event: Note Off ch: %u\tnote: %u(%s)\tvel: %u"NL,common->channelId + 1,eventData->noteNb, getMidiNoteName(eventData->noteNb),eventData->velocity);
}

static AM_NOINLINE void amOplNoteOnCb(const sMidiInCommon *common, const sNoteOn_t *eventData, void *userData)
{
	amTrace("event: Note On ch: %u\tnote: %u(%s)\tvel: %u"NL, common->channelId + 1, eventData->noteNb, getMidiNoteName(eventData->noteNb), eventData->velocity);
}

static AM_NOINLINE void amOplNoteAftCb(const sMidiInCommon *common, const sNoteAft_t *eventData, void *userData)
{
	amTrace("event: Note Aftertouch ch: [%u] note: %u, pressure: %u"NL, common->channelId + 1, eventData->noteNb, eventData->pressure);
}

static AM_NOINLINE void amOplControllerCb(const sMidiInCommon *common, const sController_t *eventData, void *userData)
{
	amTrace("event: Controller ch: %u, nb:%u name: %s\tvalue: %u"NL, common->channelId + 1, eventData->controllerNb, getMidiControllerName(eventData->controllerNb), eventData->value);
}

static AM_NOINLINE void amOplProgramChangeCb(const sMidiInCommon *common, const sProgramChange_t *eventData, void *userData)
{
	amTrace("event: Program change ch: %u\t program nb: %u"NL, common->channelId + 1, eventData->programNb);
}

static AM_NOINLINE void amOplChannelAftCb(const sMidiInCommon *common, const sChannelAft_t *eventData, void *userData)
{
	amTrace("event: Channel [%u] aftertouch pressure: %u"NL, common->channelId + 1, eventData->pressure);
}

static AM_NOINLINE void amOplPitchBendCb(const sMidiInCommon *common, const sPitchBend_t *eventData, void *userData)
{
	amTrace("event: Pitch bend channel: [%u] LSB: %d, MSB: %d"NL, common->channelId + 1, eventData->LSB, eventData->MSB);
}

int32 main(int32 argc, int8 *argv[]) 
{
	const uint8 fileNameLen = strlen(argv[1]);
  uint8 filepath[AM_MAX_FILEPATH] = {0};
  (void)amMemCpy((void*)filepath, argv[1], fileNameLen);

	int16 retCode = amInit();
 
  if(retCode != AM_OK)
  {
  	return retCode;
  }

  turnOffKeyclick();
  
	if( ((argc>=1) && (fileNameLen!=0) ))
  {
		amPrintf("Trying to load %s"NL, filepath);
	}
  else
  {
		amPrintf("No instrument set filename (*.opl2) specified! exiting."NL);
		return AM_ERR;
  }

  sOplInstrumentSet oplInstrumentData = oplLoadDmxInstrumentSet((uint8 *)filepath, TRUE);

  AssertMsg(oplInstrumentData.isValid==TRUE,"Dmx Instrument set not valid!");
  
  if(oplInstrumentData.isValid!=TRUE)
  {
  	amPrintf("Instrument set file %s is not valid! exiting."NL, filepath);
  	amDeinit();
  	return AM_ERR;
  }

  // config stores midi channels in 1..16 range
  uint8 currentMidiInputChannel = amConfigGet()->midiInChannel - 1;  

  AssertMsg(currentMidiInputChannel<MIDI_MAXCHANNELS, "Midi Input channel out of range 0-15");

  printHelpScreen(currentMidiInputChannel);

  IkbdClearState();

  // init OPL3LPT interface in supervisor
  uint32 usp = Super(0L);
  int32 retval = oplInit(OPL_PORT_LPT, TRUE);
  SuperToUser(usp);

  if(retval != OPL_OK)
  {
		amPrintf("OPL initialisation error. Exiting."NL);
		amDeinit();
		return AM_ERR;
  }

	// Install our asm handler
	Supexec(IkbdInstall);
	
	// setup midi in event callbacks
	const sAmMidiEventCallbacks midiInCallbacks =
	{
		.cbNoteOff = amOplNoteOffCb,
		.cbNoteOn = amOplNoteOnCb,
		.cbNoteAft = amOplNoteAftCb,
		.cbController = amOplControllerCb,
		.cbProgramChange = amOplProgramChangeCb,
		.cbChannelAft = amOplChannelAftCb,
		.cbPitchBend = amOplPitchBendCb,
		.cbUserData = 0
	};

	uint8 midiInBuffer[MIDI_IN_BUFFER_SIZE] = {0};

  uint16 quitFlag = 0;
  
  while(quitFlag != 1)
  {
 		// poll midi input and send output to synth
		amHandleMidiInInput(midiInBuffer, MIDI_IN_BUFFER_SIZE, 0, &midiInCallbacks);

		for (uint16 i=0; i<IKBD_KBD_TABLE_SIZE; ++i) 
		{
			const uint8 keyState = Ikbd_keyboard[i];
			
			if (keyState == KEY_PRESSED) 
			{
			  Ikbd_keyboard[i] = KEY_UNDEFINED;
				
				switch(i)
				{
				  // quit
				  case SC_ESC:
				  {
				    quitFlag = 1;
				  } break;
				};
			}

			if (keyState == KEY_RELEASED)
			{

			  Ikbd_keyboard[i] = KEY_UNDEFINED;
  
			}
  		} //end for
	} // end while

	// Uninstall our asm handler
	Supexec(IkbdUninstall);

	Supexec(oplDeinit);

   (void)oplDestroyInstrumentSet(&oplInstrumentData);
  
  // clean up, free internal library buffers etc..
	amDeinit();

	return 0;
}
