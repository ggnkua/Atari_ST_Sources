
/**  Copyright 2007-2022 Pawel Goralski
    
    This file is part of AMIDILIB.
    See license.txt for licensing information.
*/

/////// timing test program /////////////////////////////////////////////////
// program reads delta times / notes from table and outputs sound through  //
// ym2149 / midi out port with adjustable tempo                            //
/////////////////////////////////////////////////////////////////////////////

#if AMIDILIB_USE_LIBC
#include <string.h>
#else
#include "amstring.h"
#endif

#include "midi.h"

#include "core/amprintf.h"
#include "core/logger.h"
#include "core/ostimer.h"

#include "input/ikbd.h"
#include "timing/miditim.h"
#include "timing/mfp.h"

#include "ym2149.h"
#include "sampleSequence.h"

#define MIDI_MASTER_VOL_MAX_GM   127
#define MIDI_MASTER_VOL_MAX_MT32 100
#define MIDI_MASTER_VOL_DEFAULT_GM (MIDI_MASTER_VOL_MAX_GM/2)
#define MIDI_MASTER_VOL_DEFAULT_MT32 (MIDI_MASTER_VOL_MAX_MT32/2)
#define MIDI_MASTER_VOL_MIN    0
#define MIDI_MASTER_PAN_MAX    127
#define MIDI_MASTER_PAN_CENTER 64
#define MIDI_MASTER_PAN_MIN    0
#define TEMPO_STEP 10000

#include "mcommands.h"

// sequence replay routine 
AM_EXTERN void customSeqReplay(void);

// installs sequence replay routine (hooked to timer B atm) 
AM_EXTERN void installReplayRoutGeneric(const sMfpTimerData timer, funcPtrVoidVoid func);

// deinstalls sequence replay routine (hooked to timer B atm) 
AM_EXTERN void deinstallReplayRoutGeneric(void);

// functions
void onTempoUp(sCurrentSequenceState *pSeqPtr);
void onTempoDown(sCurrentSequenceState *pSeqPtr);
Bool onToggleMidiEnable(const Bool midiOutputState);
Bool onToggleYmEnable(const Bool ymOutputState);
uint16 onTogglePlayMode(const uint16 playMode);
ePlayModeStates onTogglePlayPauseSequence(const ePlayModeStates state);
void onStopSequence(sCurrentSequenceState *pSeqPtr);
Bool isEndSeq(sEvent *pEvent);
void playNote(const uint8 channel,const uint8 noteNb, const Bool bMidiOutput, const Bool bYmOutput); // plays given note and outputs it to midi/ym2149
void setMidiMasterVolume(const uint8 vol);
void setMidiMasterBalance(const uint8 bal);
uint8 getMidiMasterVolume(void);
uint8 getMidiMasterBalance(void);
uint8 amMidiDeviceGetDefaultMasterVolume(const eMidiDeviceType device);

// plays sample sequence 
int initSampleSequence(sEvent *ch1,sEvent *ch2,sEvent *ch3, sCurrentSequenceState *pSeqPtr);
void updateSequenceStep(void); 
void onEndSeq(void);                  //end sequence handler
void printHelpScreen(void);

#ifndef IKBD_MIDI_SEND_DIRECT
uint8 g_arMidiBuffer[MIDI_SENDBUFFER_SIZE];
#endif

sCurrentSequenceState g_CurrentState; //current sequence

volatile sMidiModuleSettings moduleSettings;
volatile uint8 requestedMasterVolume;
volatile uint8 requestedMasterBalance;

volatile Bool handleTempoChange;
volatile Bool midiOutputEnabled;
volatile Bool ymOutputEnabled;
  
// program entry
// TODO: override midi device, channel setup from commandline
int main(int argc, char *argv[])
{
  sYmChannelData ch[3];
  midiOutputEnabled=TRUE;
  ymOutputEnabled=FALSE;

  //set up ym2149 sound
  /////////////////////////////////////

  ch[YM_CHN_A].amp=16;
  ch[YM_CHN_A].oscFreq=getEnvelopeId(0);
  ch[YM_CHN_A].oscStepSize=15;  
  ch[YM_CHN_A].toneEnable=1;
  ch[YM_CHN_A].noiseEnable=0;
  
  ch[YM_CHN_B].amp=16;
  ch[YM_CHN_B].oscFreq=getEnvelopeId(0);
  ch[YM_CHN_B].oscStepSize=8;
  ch[YM_CHN_B].toneEnable=1;
  ch[YM_CHN_B].noiseEnable=0;
  
  ch[YM_CHN_C].amp=16;
  ch[YM_CHN_C].oscFreq=getEnvelopeId(0);
  ch[YM_CHN_C].oscStepSize=6;
  ch[YM_CHN_C].toneEnable=1;
  ch[YM_CHN_C].noiseEnable=0;
  ////////////////////////////////////////

#ifndef IKBD_MIDI_SEND_DIRECT
 // clear our new XBIOS buffer 
 (void)amMemSet(g_arMidiBuffer,0,MIDI_SENDBUFFER_SIZE);

 const uint32 usp=Super(0L);
 g_psMidiBufferInfo=(_IOREC*)Iorec(XB_DEV_MIDI);
    
 /* copy old MIDI buffer info */
 g_sOldMidiBufferInfo.ibuf=(*g_psMidiBufferInfo).ibuf;
 g_sOldMidiBufferInfo.ibufsiz=(*g_psMidiBufferInfo).ibufsiz;
 g_sOldMidiBufferInfo.ibufhd=(*g_psMidiBufferInfo).ibufhd;
 g_sOldMidiBufferInfo.ibuftl=(*g_psMidiBufferInfo).ibuftl;
 g_sOldMidiBufferInfo.ibuflow=(*g_psMidiBufferInfo).ibuflow;
 g_sOldMidiBufferInfo.ibufhi=(*g_psMidiBufferInfo).ibufhi;

 /* set up new MIDI buffer */
 (*g_psMidiBufferInfo).ibuf = (char *)g_arMidiBuffer;
 (*g_psMidiBufferInfo).ibufsiz = MIDI_SENDBUFFER_SIZE;
 (*g_psMidiBufferInfo).ibufhd=0;  /* first byte index to write */
 (*g_psMidiBufferInfo).ibuftl=0;  /* first byte to read(remove) */
 (*g_psMidiBufferInfo).ibuflow=(uint16) MIDI_LWM;
 (*g_psMidiBufferInfo).ibufhi=(uint16) MIDI_HWM;
 SuperToUser(usp);
#endif

  // now depending on the connected device type and chosen operation mode
  // set appropriate channel
  // prepare device for receiving messages
  moduleSettings = amMidiDeviceSetup(DT_LA_SOUND_SOURCE_EXT,1);
  requestedMasterVolume = amMidiDeviceGetDefaultMasterVolume(DT_LA_SOUND_SOURCE_EXT);
  requestedMasterBalance = MIDI_MASTER_PAN_CENTER;
    
  setMidiMasterVolume(requestedMasterVolume);        
  setMidiMasterBalance(requestedMasterBalance);      // center

  printHelpScreen();
  turnOffKeyclick();

  //prepare sequence
  sEvent *ch1 = getTestSequenceChannel(0);
  sEvent *ch2 = getTestSequenceChannel(1);
  sEvent *ch3 = getTestSequenceChannel(2);

  (void)initSampleSequence(ch1,ch2,ch3,&g_CurrentState);

  IkbdClearState();
    
  // Install our asm ikbd handler 
  Supexec(IkbdInstall);
  
  int32 ticksStart=0;
  int32 ticksDelta=0;

  uint16 quitFlag=0;

  // enter main loop
  while(quitFlag!=1)
  {

    ticksStart = amUserGetSystemTimerTicks();

    for (uint16 i=0; i<IKBD_KBD_TABLE_SIZE; ++i) 
    {

     const uint8 keyState = Ikbd_keyboard[i];
     
     if (keyState==KEY_PRESSED) 
     {
	     Ikbd_keyboard[i]=KEY_UNDEFINED;
	
       switch(i)
       {
         case SC_ESC:
         {
           quitFlag=1;
         } break;
         case SC_1:
         {
           midiOutputEnabled = onToggleMidiEnable(midiOutputEnabled);
         } break;
         case SC_2:
         {
           ymOutputEnabled = onToggleYmEnable(ymOutputEnabled);
         } break;
         case SC_ARROW_UP:
         {
           onTempoUp(&g_CurrentState);
         } break;
         case SC_ARROW_DOWN:
         {
           onTempoDown(&g_CurrentState);
         } break;
         case SC_I:
         {
           printHelpScreen();
         } break;
         case SC_M:
         {
           g_CurrentState.playMode = onTogglePlayMode(g_CurrentState.playMode);
         } break;
         case SC_P:
         {
           g_CurrentState.state = onTogglePlayPauseSequence(g_CurrentState.state);
         } break;
         case SC_SPACEBAR:
         {
           onStopSequence(&g_CurrentState);
           sEvent *ch1 = getTestSequenceChannel(0);
           sEvent *ch2 = getTestSequenceChannel(1);
           sEvent *ch3 = getTestSequenceChannel(2);
           (void)initSampleSequence(ch1,ch2,ch3,&g_CurrentState);
         } break;
	     } // end switch
     } // end if
    } // end for

    ticksDelta = amUserGetSystemTimerTicksDelta(ticksStart);

    //amPrintf(CR "ticks/frame: %d",ticksDelta);
    //Vsync();
  }// end while

  allNotesOff(MIDI_MAXCHANNELS);
  Supexec(flushMidiSendBufferCr);
  
  ymSoundOff();
  deinstallReplayRoutGeneric();

  /* Uninstall our asm handler */
  Supexec(IkbdUninstall);
   
 return 0;
}

uint16 onTogglePlayMode(const uint16 playMode)
{
  // toggle play mode PLAY ONCE / LOOP
	if(playMode == S_PLAY_LOOP)
  {
	  amPrintf("Play sequence once."NL);
	  return S_PLAY_ONCE;
	}
	else if(playMode == S_PLAY_ONCE)
  {
	  amPrintf("Play sequence in loop."NL);
	  return S_PLAY_LOOP;
	}

 return playMode;
}

void onTempoUp(sCurrentSequenceState *seqState)
{
  if(handleTempoChange==TRUE) return;
  if(g_CurrentState.state == PS_STOPPED) return;

  uint32 upqn = seqState->upqn;
  uint32 updateStep=0;
  
  if(upqn<=0) 
  {
    seqState->upqn=0;
    return;
  }
    
  if( ((upqn<=50000) && (upqn>5000)) )
  {
    updateStep=5000;
  }
  else if(upqn <= 5000)
  {
    updateStep=100;
  }
  else
  { 
    updateStep = TEMPO_STEP;
  }
  
  if(!((upqn-updateStep)<=0))
  {
    upqn -= updateStep;
    seqState->upqn = upqn;
  }

  amPrintf(NL "qn duration: %u [uS]"NL,upqn);
  handleTempoChange=TRUE;    
}

void onTempoDown(sCurrentSequenceState *seqState)
{
  if(handleTempoChange==TRUE) return;
  
  if(g_CurrentState.state == PS_STOPPED) return;
  
  uint32 upqn = seqState->upqn;
  uint32 updateStep=0;
  
  if(upqn<=50000)
  {
    updateStep=5000;
  }
  else if(upqn>50000)
  {
    updateStep=TEMPO_STEP;  
  } 
    
  upqn+=updateStep;
  seqState->upqn = upqn;
    
  amPrintf(NL "qn duration: %u [uS]"NL,upqn);
  handleTempoChange=TRUE;
}

Bool onToggleMidiEnable(Bool midiOutputState)
{
  amPrintf("MIDI output ");
  if(midiOutputState==TRUE)
  {
    allNotesOff(MIDI_MAXCHANNELS);
    amPrintf("disabled."NL);
    return FALSE;
  }

  amPrintf("enabled."NL);
  return TRUE;
}

Bool onToggleYmEnable(const Bool ymOutputState)
{
  amPrintf("ym2149 output ");
  
  if(ymOutputState==TRUE)
  {
    ymSoundOff();
    amPrintf("disabled."NL);
    return FALSE;
  }

  amPrintf("enabled."NL);
  return TRUE;
}

ePlayModeStates onTogglePlayPauseSequence(const ePlayModeStates state)
{
  amPrintf("Pause/Resume sequence"NL);
  
  if(state == PS_STOPPED)
  {
    return PS_PLAYING;
  }
  else if(state == PS_PLAYING)
  {
    return PS_PAUSED;
  }
  else if(state == PS_PAUSED)
  {
    return PS_PLAYING;
  }

  return state;
}

void onStopSequence(sCurrentSequenceState *pSeqPtr)
{
  amPrintf("Stop sequence"NL);
  
  pSeqPtr->state = PS_STOPPED;
  pSeqPtr->bpm = DEFAULT_BPM;
  pSeqPtr->upqn = DEFAULT_MPQN;
  pSeqPtr->ppqn = DEFAULT_PPQN;
  pSeqPtr->timeElapsedFrac=0;

  pSeqPtr->timeStep = amCalculateTimeStep(g_CurrentState.bpm, g_CurrentState.ppqn, SEQUENCER_UPDATE_HZ);
  amTrace("[tempo/ppqn/update freq](%d/%d/%d)->timestep:%d" NL,g_CurrentState.upqn,g_CurrentState.ppqn,SEQUENCER_UPDATE_HZ,pSeqPtr->timeStep);

  for (uint16 i=0;i<3;++i)
  {
      pSeqPtr->tracks[i].seqPosIdx=0;
      pSeqPtr->tracks[i].timeElapsedInt=0;
  }  
  
  allNotesOff(MIDI_MAXCHANNELS);
  ymSoundOff();
}

Bool isEndSeq(sEvent *pEvent)
{
  if((pEvent->delta==0 && pEvent->note==0))
    return TRUE;
   
    return FALSE;
}

void AM_INLINE printHelpScreen(void)
{
  amPrintf("==============================================="NL);
  amPrintf("/|\\ delta timing and sound output test.."NL);

#if AMIDILIB_USE_LIBC
    amPrintf("build date: %s %s"NL,__DATE__,__TIME__);
#else  
    amPrintf("build date: %s %s nolibc"NL,__DATE__,__TIME__);
#endif
 
  amPrintf("[arrow up/ arrow down] - change tempo " NL "\t500 ms/PQN and 96PPQN"NL);
  amPrintf("[1/2] - enable/disable midi out/ym2149 output "NL);
  amPrintf("[m] - toggle [PLAY ONCE/LOOP] sequence replay mode "NL);
  amPrintf("[p] - pause/resume sequence "NL);
  amPrintf("[i] - show this help screen "NL);
  
  amPrintf("[spacebar] - turn off all sounds / stop sequence "NL);
  amPrintf("[Esc] - quit"NL);
  amPrintf("(c) Nokturnal 2007-22"NL);
  amPrintf("================================================"NL);
}

// plays sample sequence 
int initSampleSequence(sEvent *ch1,sEvent *ch2,sEvent *ch3, sCurrentSequenceState *pSeqPtr)
{
  static Bool bPlayModeInit=FALSE;

  handleTempoChange=FALSE;
  funcPtrVoidVoid replayRout = customSeqReplay;
 
  pSeqPtr->tracks[0].seqPtr=ch1;	
  pSeqPtr->tracks[0].state.bIsActive=TRUE;
  pSeqPtr->tracks[0].seqPosIdx=0;
  pSeqPtr->tracks[0].timeElapsedInt=0;
  
  pSeqPtr->tracks[1].seqPtr=ch2;	
  pSeqPtr->tracks[1].state.bIsActive=TRUE;
  pSeqPtr->tracks[1].seqPosIdx=0;
  pSeqPtr->tracks[1].timeElapsedInt=0;
   
  pSeqPtr->tracks[2].seqPtr=ch3;	
  pSeqPtr->tracks[2].state.bIsActive=TRUE;
  pSeqPtr->tracks[2].seqPosIdx=0;  
  pSeqPtr->tracks[2].timeElapsedInt=0;
 
  pSeqPtr->state=PS_STOPPED;
  pSeqPtr->ppqn=DEFAULT_PPQN;
  pSeqPtr->upqn=DEFAULT_MPQN;
  pSeqPtr->bpm=DEFAULT_BPM;
 
  pSeqPtr->timeElapsedFrac=0;
  pSeqPtr->timeStep = amCalculateTimeStep(DEFAULT_BPM, DEFAULT_PPQN, SEQUENCER_UPDATE_HZ);
  
   if(bPlayModeInit!=TRUE)
   {
     //init but only once, user can switch this option during runtime
      bPlayModeInit=TRUE;
      g_CurrentState.playMode=S_PLAY_LOOP; 
    }
  
  const sMfpTimerData td = getMfpTimerSettings(SEQUENCER_UPDATE_HZ);
  
  // install replay routine 
  installReplayRoutGeneric(td, replayRout);

  return 0;
}

void updateSequenceStep(void)
{
static Bool endOfSequence=FALSE;
static Bool bStopped=FALSE;
  
  //check sequence state if paused do nothing
  if(g_CurrentState.state==PS_PAUSED) 
  {
    {
      allNotesOff(MIDI_MAXCHANNELS);
    }
    
    {
      ymSoundOff();
    }

    return;
  }
  
  if(g_CurrentState.state==PS_PLAYING) bStopped=FALSE;
  //check sequence state if stopped reset position on all tracks
  //and reset tempo to default, but only once
  
  if((g_CurrentState.state==PS_STOPPED && bStopped!=TRUE))
  {
    bStopped=TRUE;
    //repeat for each track
    for (uint16 i=0;i<3;++i)
    {
      g_CurrentState.tracks[i].seqPosIdx=0;
      g_CurrentState.tracks[i].timeElapsedInt=0UL;
    }

    // reset tempo to default
    g_CurrentState.ppqn  = DEFAULT_PPQN;
    g_CurrentState.upqn = DEFAULT_MPQN;
    g_CurrentState.bpm = DEFAULT_BPM;
    g_CurrentState.timeElapsedFrac  = 0;
    
    g_CurrentState.timeStep = amCalculateTimeStep(DEFAULT_BPM, DEFAULT_PPQN, SEQUENCER_UPDATE_HZ);
    
    if(midiOutputEnabled == TRUE)
    {
      allNotesOff(MIDI_MAXCHANNELS);
    }
    
    if(ymOutputEnabled==TRUE)
    { 
      ymSoundOff();
    }
    
    return;
  }
  else if(g_CurrentState.state==PS_STOPPED && bStopped==TRUE)
  {
    return;
  }
  
  if(handleTempoChange == TRUE)
  {
    g_CurrentState.bpm = MICROSECONDS_PER_MINUTE/g_CurrentState.upqn;
    g_CurrentState.timeStep = amCalculateTimeStep(g_CurrentState.bpm, g_CurrentState.ppqn, SEQUENCER_UPDATE_HZ);
    //amTrace(NL "Set new timestep:%d"NL,g_CurrentState.timeStep);
    handleTempoChange=FALSE;
  }
  
  g_CurrentState.timeElapsedFrac += g_CurrentState.timeStep;
  const uint32 TimeAdd = g_CurrentState.timeElapsedFrac >> 16;
  g_CurrentState.timeElapsedFrac &= 0xffff;
   
  // repeat for each track
  for (uint16 i=0;i<3;++i)
  {
     //for each active track
      uint32 count=g_CurrentState.tracks[i].seqPosIdx;
      sEvent *pEvent=&(g_CurrentState.tracks[i].seqPtr[count]);
      
      g_CurrentState.tracks[i].timeElapsedInt += TimeAdd;
      
      while( ((isEndSeq(pEvent)!=TRUE)&&pEvent->delta<=g_CurrentState.tracks[i].timeElapsedInt))
      {
        endOfSequence=FALSE;
        g_CurrentState.tracks[i].timeElapsedInt -= pEvent->delta;
	  
        if(g_CurrentState.tracks[i].state.bIsActive==TRUE)
        {
            playNote(i+1,pEvent->note,midiOutputEnabled,ymOutputEnabled);
        }

        ++count;
        pEvent=&(g_CurrentState.tracks[i].seqPtr[count]);
      }
      
      //check for end of sequence
      if(isEndSeq(pEvent))
      {
        endOfSequence=TRUE;
        playNote(i+1,0,midiOutputEnabled,ymOutputEnabled);
      }
      else
      {
        g_CurrentState.tracks[i].seqPosIdx=count;
      }
  }
  
  //check if we have end of sequence
  //on all tracks
  if(endOfSequence==TRUE)
  {
    onEndSeq();
    endOfSequence=FALSE;
  }
}

void onEndSeq(void)
{
  if(g_CurrentState.playMode == S_PLAY_ONCE)
  {
      // reset set state to stopped 
      // reset song position on all tracks
      g_CurrentState.state = PS_STOPPED;
      onStopSequence(&g_CurrentState);
      return;
  }
  else if(g_CurrentState.playMode == S_PLAY_LOOP)
  {
      g_CurrentState.state=PS_PLAYING;  
      
      g_CurrentState.ppqn = DEFAULT_PPQN;
      g_CurrentState.bpm = MICROSECONDS_PER_MINUTE/g_CurrentState.upqn;  //do not reset current tempo !!!!
      g_CurrentState.timeElapsedFrac=0;
      g_CurrentState.timeStep = amCalculateTimeStep(g_CurrentState.bpm, DEFAULT_PPQN, SEQUENCER_UPDATE_HZ); 
  
      for (uint16 i=0;i<3;++i)
      {
        g_CurrentState.tracks[i].seqPosIdx=0;
        g_CurrentState.tracks[i].timeElapsedInt=0;
      }
       
      if(midiOutputEnabled == TRUE)
      {
        allNotesOff(MIDI_MAXCHANNELS);
      }

      if(ymOutputEnabled == TRUE)
      {
        ymSoundOff();
      }
   }
}


sMidiModuleSettings amMidiDeviceSetup(const eMidiDeviceType device, const uint8 channel)
{
    // this will force update on first frame
    moduleSettings.reverbMode=0;
    moduleSettings.reverbLevel=0;
    moduleSettings.reverbTime=0;

    moduleSettings.masterVolume=0;
    moduleSettings.masterBalance=0;

    switch(device)
    {
     case DT_LA_SOUND_SOURCE:
     {
        amTrace(NL "Setting MT32 device on ch: %d"NL, channel);
        amMidiDeviceMt32Reset();

        moduleSettings.vendorID=ID_ROLAND;
        moduleSettings.modelID=MT32_MODEL_ID;
        moduleSettings.deviceID=0x10;

        program_change(channel, 1);
     } break;

     case DT_LA_SOUND_SOURCE_EXT:
     {
       amTrace(NL "Setting MT32 ext device on ch: %d"NL, channel);

       moduleSettings.vendorID=ID_ROLAND;
       moduleSettings.modelID=MT32_MODEL_ID;
       moduleSettings.deviceID=0x10;

       amMidiDeviceMt32Reset();
       program_change(channel, 1);
     } break;

     // for pure GS / GM sound source 
     case DT_GS_SOUND_SOURCE:
     {       
        amTrace(NL "Setting GS device on ch: %d"NL, channel);

        moduleSettings.vendorID=ID_ROLAND;
        moduleSettings.modelID=GS_MODEL_ID;
        moduleSettings.deviceID=0x10;

        amMidiDeviceEnableGm(FALSE);
        amMidiDeviceEnableGs();
        control_change(C_BANK_SELECT, channel,0,0x00);
        program_change(channel, 1);
     } break;

     // if both LA / GS sound sources are available, like in CM-500 mode A, drop it? 
     case DT_LA_GS_MIXED:
     {           
        amTrace(NL "Setting generic LA / GS device on ch: %d"NL, channel);

        moduleSettings.vendorID=ID_ROLAND;
        moduleSettings.modelID=GS_MODEL_ID;
        moduleSettings.deviceID=0x10;

        amMidiDeviceEnableGm(FALSE);
        amMidiDeviceEnableGs();

        // silence CM-32P part
        amMidiDeviceCm500AllPartsOff();

        control_change(C_BANK_SELECT, channel,0,0x00);
        program_change(channel, 1);
     } break;

     case DT_GM_SOUND_SOURCE:
     {
        amTrace(NL "Setting GM device on ch: %d"NL, channel);

        moduleSettings.vendorID=ID_ROLAND;
        moduleSettings.modelID=GS_MODEL_ID;
        moduleSettings.deviceID=0x10;

        amMidiDeviceEnableGm(TRUE);

        // no banks for GM devices
        program_change(channel, 1);
     } break;

     case DT_MT32_GM_EMULATION:
     {
        amTrace(NL "Setting GM emulation on MT32 on ch: %d"NL, channel);

        moduleSettings.vendorID=ID_ROLAND;
        moduleSettings.modelID=MT32_MODEL_ID;
        moduleSettings.deviceID=0x10;

        amMidiDeviceMt32Reset();

       /// before loading midi data MT32 sound banks has to be patched */
       // set standard drumset
       amMidiDevicePatchMt32toGm(FALSE);
       program_change(channel, 1);

     } break;
     case DT_XG_GM_YAMAHA:    // not supported yet
     {  
        amTrace(NL "Setting generic default on ch: %d"NL, channel);
        control_change(C_BANK_SELECT, channel,0,0x00);
        program_change(channel, 1);
     } break;
     case DT_ADLIB:    // not supported yet
     {
      AssertMsg(false,"ADLIB not supported yet!"NL);
     }break;
     default:
     {
        AssertFatal(false,"Unsupported device type"NL);
     } break;
    };

    // all notes off
    allNotesOff(MIDI_MAXCHANNELS);

    // reset all controllers
    for(uint8 i=0;i<MIDI_MAXCHANNELS;++i)
    {
        reset_all_controllers(i);
        omni_off(i);   // set operation omni off/poly on
    }

 #ifdef IKBD_MIDI_SEND_DIRECT
     Supexec(flushMidiSendBufferCr);
 #endif
}

void playNote(const uint8 channel,const uint8 noteNb, const Bool bMidiOutput, const Bool bYmOutput)
{
     const sYmData noteData = ymGetMidiNoteData(noteNb);

     uint8 hByte = noteData.highbyte;
     uint8 lByte = noteData.lowbyte;
     uint16 period = noteData.period;
     
     switch(channel)
     {
      case 1:
      {
       if(bMidiOutput==TRUE)
       {
        note_on(channel,noteNb,127);  //output on channel 9, max velocity
       }
       
       if(bYmOutput==TRUE)
       {
        sYmChannelData ch[3]={0};
        ch[YM_CHN_A].oscFreq = lByte;
        ch[YM_CHN_A].oscStepSize = hByte;
        ymDoSound(ch, 4, period, 128, YM_CHN_A);
       }
       
      } break;
      case 2:
      {
        if(bMidiOutput==TRUE)
        {
          note_on(channel,noteNb,127);  //output on channel 9, max velocity
        }
   
        if(bYmOutput==TRUE)
        {
          sYmChannelData ch[3]={0};
          ch[YM_CHN_B].oscFreq=lByte;
          ch[YM_CHN_B].oscStepSize=hByte;
          ymDoSound(ch, 4, period, 128, YM_CHN_B);
        }
      } break;
      case 3:
      {
  
        if(bMidiOutput==TRUE)
        {
          note_on(channel,noteNb,127);  //output on channel 9, max velocity
        }

        if(bYmOutput==TRUE)
        {
          sYmChannelData ch[3]={0};
          ch[YM_CHN_C].oscFreq=lByte;
          ch[YM_CHN_C].oscStepSize=hByte;
          ymDoSound(ch, 4, period, 128, YM_CHN_C);
        }
   
      } break;
      default:
      {
        if(bMidiOutput==TRUE)
        {
          note_on(channel,noteNb,127);    //output on channel 9, max velocity
          note_on(channel-1,noteNb,127);  //output on channel 9, max velocity
          note_on(channel-2,noteNb,127);  //output on channel 9, max velocity
        }
        
        if(bYmOutput==TRUE)
        {
          sYmChannelData ch[3]={0};
          ch[YM_CHN_A].oscFreq=lByte;
          ch[YM_CHN_A].oscStepSize=hByte;
          ch[YM_CHN_B].oscFreq=lByte;
          ch[YM_CHN_B].oscStepSize=hByte;
          ch[YM_CHN_C].oscFreq=lByte;
          ch[YM_CHN_C].oscStepSize=hByte;
          ymDoSound(ch, 4, period, 128, YM_CHN_ALL);
        } 
      } break;
     }
}

void setMidiMasterVolume(const uint8 vol)
{
  requestedMasterVolume=vol;
}

void setMidiMasterBalance(const uint8 bal)
{
  requestedMasterBalance = bal;
}

uint8 getMidiMasterVolume(void)
{
  return moduleSettings.masterVolume;
}

uint8 getMidiMasterBalance(void)
{
  return moduleSettings.masterBalance;
}

static const uint8 midiDefaultMasterVolumeTable[DT_NUM_DEVICES]=
{
  MIDI_MASTER_VOL_DEFAULT_MT32,
  MIDI_MASTER_VOL_DEFAULT_MT32,
  MIDI_MASTER_VOL_DEFAULT_GM,
  MIDI_MASTER_VOL_DEFAULT_GM,
  MIDI_MASTER_VOL_DEFAULT_GM,
  MIDI_MASTER_VOL_DEFAULT_MT32,
  MIDI_MASTER_VOL_DEFAULT_GM,
  MIDI_MASTER_VOL_DEFAULT_GM
};

uint8 amMidiDeviceGetDefaultMasterVolume(const eMidiDeviceType device)
{
  return midiDefaultMasterVolumeTable[device];
}
