
/**  Copyright 2007-2022 Pawel Goralski
    
    This file is part of AMIDILIB.
    See license.txt for licensing information.
*/

#include "vartypes.h"
#include "amidilib.h"
#include "config.h"
#include "roland.h"
#include "rolinstr.h"
#include "midi_in.h"

#include "core/amprintf.h"
#include "input/scancode.h"	// scancode definitions
#include "input/ikbd.h"

#define MIDI_IN_BUFFER_SIZE 1024

void printHelpScreen(const uint8 midiOutChannel, const uint8 midiInChannel)
{
  amPrintf(NL "==============================================="NL);
  amPrintf("/|\\ midi output test.."NL);

#if AMIDILIB_USE_LIBC
    amPrintf("build date: %s %s"NL,__DATE__,__TIME__);
#else  
    amPrintf("build date: %s %s nolibc"NL,__DATE__,__TIME__);
#endif   

  amPrintf("[q-h] - play note"NL);
  amPrintf("[1-8] - choose octave"NL);
  amPrintf("'[' or ']' - change program nb on active midi channel -/+"NL);
  amPrintf(" [Arrow Up/Down] - adjust bank select -/+"NL);
  amPrintf(" [B] - set instrument on active midi channel"NL);
  amPrintf("'<' or '>' - change active channel/part -/+"NL);
  amPrintf("'z' or 'x' - change note velocity -/+"NL);
  amPrintf("[C] - change chorus settings for all channels"NL);
  amPrintf("[V] - change reverb settings for all channels"NL);
  amPrintf("[HELP] - show this help screen "NL);
  amPrintf("[Backspace] - switch between [LA] / [GS/GM] mode"NL);
  
  switch(amConfigGet()->connectedDeviceType)
  {
    case DT_LA_SOUND_SOURCE:     
    case DT_LA_SOUND_SOURCE_EXT:
    {
      amPrintf("[current mode] - LA synth  "NL);
    } break;
    
    case DT_GS_SOUND_SOURCE:       // for pure GS/GM sound source
    case DT_LA_GS_MIXED:           // if both LA/GS sound sources are available, like in CM-500
    case DT_MT32_GM_EMULATION:     // before loading midi data MT32 sound banks has to be patched
    case DT_XG_GM_YAMAHA:
    {
     amPrintf("[current mode] - GS/GM synth"NL);
    } break;
    case DT_ADLIB:
    {
     amPrintf("[current mode] - AdLib"NL);
    } break;
    default:
    {
    	AssertFatal(FALSE,"Unsupported device type"NL);
    }break;
   };

  amPrintf("[spacebar] - turn off all sounds"NL);
  amPrintf("[Esc] - quit"NL);
  amPrintf("[sending midi data through [%u] channel]"NL, midiOutChannel);
  amPrintf("[listening midi data on [%u] channel]"NL, midiInChannel);

  amPrintf("(c) Nokturnal 2007-22"NL);
  amPrintf("================================================"NL);
}

void changeCurrentInstrument(const uint8 channel,const uint8 bank, const uint8 pn)
{  
  switch(amConfigGet()->connectedDeviceType)
  {
    case DT_LA_SOUND_SOURCE:     
    case DT_LA_SOUND_SOURCE_EXT:
    {
      amPrintf(NL "Setting LA instrument pn: [%u] on ch: [%u]"NL, pn, channel);
      program_change(channel, pn);
    } break;
		
    case DT_GS_SOUND_SOURCE:       // for pure GS/GM sound source
    case DT_LA_GS_MIXED:           // if both LA/GS sound sources are available, like in CM-500
    case DT_MT32_GM_EMULATION:     // before loading midi data MT32 sound banks has to be patched
    case DT_XG_GM_YAMAHA:
    {
      amPrintf(NL "Setting GS/GM instrument bank:[%u]: pn [%u]: on [ch]: %u"NL, bank, pn, channel);

      control_change(C_BANK_SELECT, channel, bank,0x00);
      program_change(channel, pn);
    } break;
		case DT_ADLIB:
		{
			amTrace("TODO: ADLIB changeCurrentInstrument()"NL,0);
			AssertFatal(FALSE,"AdLib changeCurrentInstrument()"NL);
		} break;
		default:
		{
			AssertFatal(FALSE,"Unsupported device type"NL);
		}break;
   }  
  
#ifdef IKBD_MIDI_SEND_DIRECT
    Supexec(flushMidiSendBuffer);
#endif
}

void changeGlobalChorusSettings(void)
{
  amPrintf("Change global chorus settings:"NL);
}

void changeGlobalReverbSettings(void)
{
  amPrintf("Change global reverb settings:"NL);
}

void increaseGlobalMasterVolume(void)
{
  amPrintf("Increase global Master volume"NL);
}

void decreaseGlobalMasterVolume(void)
{
  amPrintf("Decrease global Master volume"NL);
}

static AM_NOINLINE void amNoteOffCb(const sMidiInCommon *common, const sNoteOff_t *eventData, void *userData)
{
	amTrace("event: Note Off ch: %u\tnote: %u(%s)\tvel: %u"NL,common->channelId + 1,eventData->noteNb, getMidiNoteName(eventData->noteNb),eventData->velocity);
}

static AM_NOINLINE void amNoteOnCb(const sMidiInCommon *common, const sNoteOn_t *eventData, void *userData)
{
	amTrace("event: Note On ch: %u\tnote: %u(%s)\tvel: %u"NL, common->channelId + 1, eventData->noteNb, getMidiNoteName(eventData->noteNb), eventData->velocity);
}

static AM_NOINLINE void amNoteAftCb(const sMidiInCommon *common, const sNoteAft_t *eventData, void *userData)
{
	amTrace("event: Note Aftertouch ch: [%u] note: %u, pressure: %u"NL, common->channelId + 1, eventData->noteNb, eventData->pressure);
}

static AM_NOINLINE void amControllerCb(const sMidiInCommon *common, const sController_t *eventData, void *userData)
{
	amTrace("event: Controller ch: %u, nb:%u name: %s\tvalue: %u"NL, common->channelId + 1, eventData->controllerNb, getMidiControllerName(eventData->controllerNb), eventData->value);
}

static AM_NOINLINE void amProgramChangeCb(const sMidiInCommon *common, const sProgramChange_t *eventData, void *userData)
{
	amTrace("event: Program change ch: %u\t program nb: %u"NL, common->channelId + 1, eventData->programNb);
}

static AM_NOINLINE void amChannelAftCb(const sMidiInCommon *common, const sChannelAft_t *eventData, void *userData)
{
	amTrace("event: Channel [%u] aftertouch pressure: %u"NL, common->channelId + 1, eventData->pressure);
}

static AM_NOINLINE void amPitchBendCb(const sMidiInCommon *common, const sPitchBend_t *eventData, void *userData)
{
	amTrace("event: Pitch bend channel: [%u] LSB: %d, MSB: %d"NL, common->channelId + 1, eventData->LSB, eventData->MSB);
}

//======================================================================================================
int32 main(void)
{
  uint8 noteBaseArray[]={24,36,48,60,72,84,96,108};
  uint8 currentOctave=3;	
  uint8 currentVelocity=127;
  uint8 currentPN=1;
  uint8 currentBankSelect=0;

  turnOffKeyclick();

  /* init library */
  int16 retCode = amInit();
 
  if(retCode != AM_OK)
  {
  	return -1;
  }
  
#ifdef IKBD_MIDI_SEND_DIRECT
    Supexec(flushMidiSendBuffer);
#endif
  
  // config stores midi channels in 1..16 range
  uint8 currentMidiOutputChannel = amConfigGet()->midiOutChannel - 1;  
  uint8 currentMidiInputChannel = amConfigGet()->midiInChannel - 1;  

  AssertMsg(currentMidiOutputChannel<MIDI_MAXCHANNELS, "Midi Output channel out of range 0-15");
  AssertMsg(currentMidiInputChannel<MIDI_MAXCHANNELS, "Midi Input channel out of range 0-15");

  printHelpScreen(currentMidiOutputChannel, currentMidiInputChannel);

	IkbdClearState();

	// Install our asm handler
	Supexec(IkbdInstall);
	
	// setup midi in event callbacks
	const sAmMidiEventCallbacks midiInCallbacks =
	{
		.cbNoteOff = amNoteOffCb,
		.cbNoteOn = amNoteOnCb,
		.cbNoteAft = amNoteAftCb,
		.cbController = amControllerCb,
		.cbProgramChange = amProgramChangeCb,
		.cbChannelAft = amChannelAftCb,
		.cbPitchBend = amPitchBendCb,
		.cbUserData = 0
	};

	uint8 midiInBuffer[MIDI_IN_BUFFER_SIZE] = {0};

	// Wait till ESC key pressed
	uint16 quit = 0;

	while (!quit) 
	{
		// poll midi input and send output to synth
		amHandleMidiInInput(midiInBuffer, MIDI_IN_BUFFER_SIZE, currentMidiOutputChannel, &midiInCallbacks);

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
				    quit=1;
				  } break;
				  
				  // change octave
				  case SC_1:
				  {
				    amPrintf("octave: -3 set"NL);
				    currentOctave=0;
				  } break;
				  
				  // change octave
				  case SC_2:
				  {
				  	amPrintf("octave: -2 set"NL);
				    currentOctave=1;
				  } break;
				  
				  //change octave
				  case SC_3:
				  {
				  	amPrintf("octave: -1 set"NL);
				    currentOctave=2;
				  } break;
				  
				  // change octave
				  case SC_4:
				  {
				    amPrintf("octave: 0 set"NL);
				    currentOctave=3;
				  } break;
				  
				  // change octave
				  case SC_5:
				  {
				    amPrintf("octave: 1 set"NL);
				    currentOctave=4;
				  } break;
				  
				  //change octave
				  case SC_6:
				  {
				    amPrintf("octave: 2 set"NL);
				    currentOctave=5;
				  } break;
				  
				  // change octave
				  case SC_7:
				  {
				    amPrintf("octave: 3 set"NL);
				    currentOctave=6;
				  } break;
				  
				  // change octave
				  case SC_8:
				  {
				    amPrintf("octave: 4 set"NL);
				    currentOctave=7;
				  } break;
				  
				  // note on handling
				  case SC_Q:
				  {
				    note_on(currentMidiOutputChannel,noteBaseArray[currentOctave]+0,currentVelocity);
				    amPrintf("%s"NL,getNoteName(currentMidiOutputChannel,currentPN,noteBaseArray[currentOctave]+0));
				  } break;
				  case SC_A:
				  {
				    note_on(currentMidiOutputChannel,noteBaseArray[currentOctave]+1,currentVelocity);
    				amPrintf("%s"NL,getNoteName(currentMidiOutputChannel,currentPN,noteBaseArray[currentOctave]+1));
				  } break;
				  case SC_W:
				  {
				    note_on(currentMidiOutputChannel,noteBaseArray[currentOctave]+2,currentVelocity);
       			amPrintf("%s"NL,getNoteName(currentMidiOutputChannel,currentPN,noteBaseArray[currentOctave]+2));
				  } break;
				  case SC_S:
				  {
				    note_on(currentMidiOutputChannel,noteBaseArray[currentOctave]+3,currentVelocity);
       			amPrintf("%s"NL,getNoteName(currentMidiOutputChannel,currentPN,noteBaseArray[currentOctave]+3));
				  } break;
				  case SC_E:
				  {
				    note_on(currentMidiOutputChannel,noteBaseArray[currentOctave]+4,currentVelocity);
       			amPrintf("%s"NL,getNoteName(currentMidiOutputChannel,currentPN,noteBaseArray[currentOctave]+4));
				  } break;
				  case SC_D:
				  {
				    note_on(currentMidiOutputChannel,noteBaseArray[currentOctave]+5,currentVelocity);
       			amPrintf("%s"NL,getNoteName(currentMidiOutputChannel,currentPN,noteBaseArray[currentOctave]+5));
				  } break;
				  
				  case SC_R:
				  {
				    note_on(currentMidiOutputChannel,noteBaseArray[currentOctave]+6,currentVelocity);
       			amPrintf("%s"NL,getNoteName(currentMidiOutputChannel,currentPN,noteBaseArray[currentOctave]+6));
				  } break;
				  
				  case SC_F:
				  {
				    note_on(currentMidiOutputChannel,noteBaseArray[currentOctave]+7,currentVelocity);
       			amPrintf("%s"NL,getNoteName(currentMidiOutputChannel,currentPN,noteBaseArray[currentOctave]+7));
				  } break;
				  
				  case SC_T:
				  {
				    note_on(currentMidiOutputChannel,noteBaseArray[currentOctave]+8,currentVelocity);
       			amPrintf("%s"NL,getNoteName(currentMidiOutputChannel,currentPN,noteBaseArray[currentOctave]+8));
				  } break;
				  
				  case SC_G:
				  {
				    note_on(currentMidiOutputChannel,noteBaseArray[currentOctave]+9,currentVelocity);				        				    
				    amPrintf("%s"NL,getNoteName(currentMidiOutputChannel,currentPN,noteBaseArray[currentOctave]+9));
				  } break;
				  
				  case SC_Y:
				  {
				    note_on(currentMidiOutputChannel,noteBaseArray[currentOctave]+10,currentVelocity);
       			amPrintf("%s"NL,getNoteName(currentMidiOutputChannel,currentPN,noteBaseArray[currentOctave]+10));
				  } break;
				  
				  case SC_H:
				  {
				     note_on(currentMidiOutputChannel,noteBaseArray[currentOctave]+11,currentVelocity);
       			 amPrintf("%s"NL,getNoteName(currentMidiOutputChannel,currentPN,noteBaseArray[currentOctave]+11));
				  } break;
				  
				  // change program number
				  case SC_SQ_LEFT_BRACE:
				  {
				    if(currentPN!=1)
				    {
				      currentPN--;
				    }
				    else
				    {
				      currentPN=128;
				    }
				  } break;
				  
				  case SC_SQ_RIGHT_BRACE:
				  {
				  	if(currentPN!=128)
				  	{
				      currentPN++;
				    }
				    else
				    {
				      currentPN=1;
				    }
				  } break;
				  
				  // change velocity
				  case SC_Z:
				  {
				    if(currentVelocity!=0)
				    {
				      currentVelocity--;
				    }
				    else
				    {
				      currentVelocity=127;
				    }

				    amPrintf("Current note velocity: %d"NL,currentVelocity);
				  } break;
		
				  case SC_X:
				  {
				    if(currentVelocity!=127)
				    {
				      currentVelocity++;
				    }
				    else
				    {
				      currentVelocity=0;
				    }
				    
				    amPrintf("Current note velocity: %d"NL,currentVelocity);
				  } break;
				  
				  // change active channel/part 0-15
				  case SC_LT:
				  {
				    if(currentMidiOutputChannel>0)
				    {
				      amAllNotesOff(MIDI_MAXCHANNELS);
				      --currentMidiOutputChannel;
				      program_change(currentMidiOutputChannel, currentPN);
              amPrintf("active channel: %d"NL,currentMidiOutputChannel+1);
				    }
				  } break;
				 
				  case SC_GT:
				  {
				    if(currentMidiOutputChannel<MIDI_MAXCHANNELS)
						{
							amAllNotesOff(MIDI_MAXCHANNELS);
							++currentMidiOutputChannel;
							program_change(currentMidiOutputChannel, currentPN);
							amPrintf("Current channel: %d"NL,currentMidiOutputChannel+1);
						}
				  } break;

				  case SC_ARROW_UP:
				  {
				    if(currentBankSelect!=127)
				    {
				      currentBankSelect++;
				    }
				    else
				    {
				      currentBankSelect=0;
				    }
				   amPrintf("Current bank: %d"NL,currentBankSelect);
				  } break;

				  case SC_ARROW_DOWN:
				  {
				    if(currentBankSelect!=0)
				    {
				      currentBankSelect--;
				    }
				    else
				    {
				      currentBankSelect=127;
				    }
				    
				    amPrintf("Current bank: %d "NL,currentBankSelect);
				  } break;
				  
				  case SC_B:
				  {
				    changeCurrentInstrument(currentMidiOutputChannel,currentBankSelect,currentPN);
				  } break;
				  
				  case SC_HELP:
				  {
				     printHelpScreen(currentMidiOutputChannel, currentMidiInputChannel);
				  } break;
				  
				  case SC_BACKSPACE:
				  {
				    switch(amConfigGet()->connectedDeviceType)
				    {
				      case DT_LA_SOUND_SOURCE:     
				      case DT_LA_SOUND_SOURCE_EXT:
				      {
                amConfigSetConnectedDeviceType(DT_GS_SOUND_SOURCE);
                amPrintf("Set MT32 mode."NL);
				      } break;
				      case DT_GS_SOUND_SOURCE:       
				      case DT_LA_GS_MIXED:           
				      case DT_MT32_GM_EMULATION:     
				      case DT_XG_GM_YAMAHA:
				      {
								amConfigSetConnectedDeviceType(DT_LA_SOUND_SOURCE_EXT);
								amPrintf("Set GS/GM mode."NL);
				    	} break;
				    	case DT_ADLIB:
				    	{
				    		amPrintf("Set AdLib mode."NL);
				    	} break;
				    	default:
				    	{
				    		AssertFatal(FALSE,"Unsupported device type"NL);
				    	} break;
				    };  
				  } break;
				}
#ifdef IKBD_MIDI_SEND_DIRECT
        Supexec(flushMidiSendBuffer);
#endif
			}

			if (keyState == KEY_RELEASED)
			{

			  Ikbd_keyboard[i] = KEY_UNDEFINED;
				
				switch(i)
				{
				  // note off handling
				  case SC_Q:
				  {
				  	note_off(currentMidiOutputChannel,noteBaseArray[currentOctave]+0,currentVelocity);
				  } break;
				  
				  case SC_A:
				  {
				    note_off(currentMidiOutputChannel,noteBaseArray[currentOctave]+1,currentVelocity);
				  } break;
				  
				  case SC_W:
				  {
				    note_off(currentMidiOutputChannel,noteBaseArray[currentOctave]+2,currentVelocity);
				  } break;
				  
				  case SC_S:
				  {
				    note_off(currentMidiOutputChannel,noteBaseArray[currentOctave]+3,currentVelocity);
          } break;
				  
				  case SC_E:
				  {
				    note_off(currentMidiOutputChannel,noteBaseArray[currentOctave]+4,currentVelocity);
				  } break;
				  
				  case SC_D:
				  {
				    note_off(currentMidiOutputChannel,noteBaseArray[currentOctave]+5,currentVelocity);
          } break;
				  
				  case SC_R:
				  {
				    note_off(currentMidiOutputChannel,noteBaseArray[currentOctave]+6,currentVelocity);
				  } break;
				  
				  case SC_F:
				  {
				    note_off(currentMidiOutputChannel,noteBaseArray[currentOctave]+7,currentVelocity);
          } break;
				  
				  case SC_T:
				  {
				    note_off(currentMidiOutputChannel,noteBaseArray[currentOctave]+8,currentVelocity);
				  } break;
				  
				  case SC_G:
				  {
				    note_off(currentMidiOutputChannel,noteBaseArray[currentOctave]+9,currentVelocity);
				  } break;
				  
				  case SC_Y:
				  {
				    note_off(currentMidiOutputChannel,noteBaseArray[currentOctave]+10,currentVelocity);
				  } break;
				  
				  case SC_H:
				  {
				    note_off(currentMidiOutputChannel,noteBaseArray[currentOctave]+11,currentVelocity);
				  } break;
		
				  // send chosen program number
				  case SC_SQ_LEFT_BRACE:
				  case SC_SQ_RIGHT_BRACE:
				  {
            switch(amConfigGet()->connectedDeviceType)
            {
			      	case DT_LA_SOUND_SOURCE:     
			      	case DT_LA_SOUND_SOURCE_EXT:
			      	{
                amPrintf("ch: [%d] [%s] (#PC %d)"NL,currentMidiOutputChannel + 1, getCM32LInstrName(currentPN), currentPN);
                program_change(currentMidiOutputChannel, currentPN);
			      	} break;
			      	case DT_GS_SOUND_SOURCE:       /* for pure GS/GM sound source */
			      	case DT_LA_GS_MIXED:           /* if both LA/GS sound sources are available, like in CM-500 */
			      	case DT_MT32_GM_EMULATION:     /* before loading midi data MT32 sound banks has to be patched */
			      	case DT_XG_GM_YAMAHA:
              case DT_GM_SOUND_SOURCE:
			      	{
                amPrintf("ch: [%d] b: [%d] [%s] (#PC %d)"NL,currentMidiOutputChannel + 1,currentBankSelect, getCM32LInstrName(currentPN), currentPN);
                control_change(C_BANK_SELECT, currentMidiOutputChannel,currentBankSelect,0x00);
                program_change(currentMidiOutputChannel, currentPN);
			      	} break;
							case DT_ADLIB:
							{
								amPrintf("ch: [%d] [%s] (#PC %d)"NL,currentMidiOutputChannel + 1,"[TODO adlib]", currentPN);
							}break;
  		      	default:
				    	{
				    		AssertFatal(FALSE,"Unsupported device type"NL);
				    	} break;
			    	};
				  } break;
				
				  case SC_SPACEBAR:
				  {
				    amPrintf("Silence..."NL);
				    amAllNotesOff(MIDI_MAXCHANNELS);
				  } break;
				};
			  
#ifdef IKBD_MIDI_SEND_DIRECT
        Supexec(flushMidiSendBuffer);
#endif
			} // endif
		}
	}

  /* Uninstall our asm handler */
	Supexec(IkbdUninstall);

 /* clean up, free internal library buffers etc..*/
 amDeinit();
 return 0;
}
