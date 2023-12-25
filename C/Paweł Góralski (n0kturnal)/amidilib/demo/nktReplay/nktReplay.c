
#include "nkt.h"

#include "input/ikbd.h"
#include "timing/mfp.h"
#include "midi_send.h"

#include "core/amprintf.h"
#include "core/machine.h"

#if AMIDILIB_USE_LIBC
#include <string.h>
#else
#include "amstring.h"
#endif

#if ((NKT_MANUAL_STEP==1) && defined DEBUG_BUILD)
AM_EXTERN void nktUpdateStep(void);
#endif

void printInfoScreen(void);

void mainLoop(sNktSeq *sequencePtr);

int32 main(int32 argc, int8 *argv[])
{
    int16 retcode = AM_OK;

    if( (argc>=1) && strlen(argv[1])!='0' )
    {
        amPrintf("Trying to load %s"NL, argv[1]);
    }
    else
    {
        amPrintf("No specified nkt filename! exiting"NL);
        return AM_ERR;
    }

    Supexec(checkMachine);

    // hardcoded, todo: set config from commandline
    const eMidiDeviceType devType = DT_GS_SOUND_SOURCE;

    switch(devType)
    {
        case DT_LA_SOUND_SOURCE:
        {
            amPrintf("Configuring MT-32 compatible midi device."NL);
        } break;     /* native MT32 */
        case DT_LA_SOUND_SOURCE_EXT:
        {
            amPrintf("Configuring extended MT-32 compatible midi device(CM-32L/CM-64)."NL);
        } break;   /* for extended MT 32 modules with extra patches like CM-32L/CM-64 */
        case DT_GS_SOUND_SOURCE:
        {
            amPrintf("Configuring GS compatible midi device."NL);
        } break;       /* for pure GS/GM sound source */
        case DT_LA_GS_MIXED:
        {
            amPrintf("Configuring GS compatible midi device with LA module."NL);
        } break;           /* if both LA/GS sound sources are available, like in CM-500 */
        case DT_GM_SOUND_SOURCE:
        {
            amPrintf("Configuring General MIDI compatible device."NL);
        } break;
        case DT_MT32_GM_EMULATION:
        {
            amPrintf("Configuring MT-32 compatible midi device with GM instrument patch set."NL);
        } break;     /* before loading midi data MT32 sound banks has to be patched */
        case DT_XG_GM_YAMAHA:
        {
            amPrintf("Configuring XG Yamaha GM device (currently unsupported)."NL);
        } break;
        case DT_ADLIB:
        {
            amPrintf("Configuring Adlib device via OPL2/3 LPT (currently unsupported)."NL);
        } break;
        default:
        {
            amPrintf("Configuring Generic GM/GS compatible midi device."NL);
        } break;
    }

    // set GS / GM source, channel
    nktInit(devType,1);

    sNktSeq *sequencePtr = nktSequenceLoad(argv[1]);

    if(sequencePtr!=NULL)
    {
      printInfoScreen();
      mainLoop(sequencePtr);
      nktSequenceStop(sequencePtr);
      nktSequenceDestroy(sequencePtr);
      sequencePtr = NULL;
      nktDeinit();
    }
    else
    {
      amPrintf("Error: Loading %s failed."NL, argv[1]);
      retcode = AM_ERR;
    }

  return retcode;
}

void printInfoScreen(void)
{
  amPrintf(NL "===== NKT replay demo v.1.25 ============="NL);
#if ((NKT_MANUAL_STEP==1) && defined DEBUG_BUILD)
  amPrintf("debug manual update step build"NL);
#endif

#if AMIDILIB_USE_LIBC
    amPrintf("build date: %s %s"NL,__DATE__,__TIME__);
#else  
    amPrintf("build date: %s %s nolibc"NL,__DATE__,__TIME__);
#endif

  amPrintf("    [p] - play loaded tune"NL);
  amPrintf("    [r] - pause/unpause played sequence"NL);
  amPrintf("    [m] - toggle play once/loop mode"NL);
  amPrintf("    [arrow up/down] - adjust master volume"NL);
  amPrintf("    [arrow left/right] - adjust master balance"NL);
  amPrintf("    [i] - display tune info"NL);
  amPrintf("    [h] - show this help screen"NL);
#if ((NKT_MANUAL_STEP==1) && defined DEBUG_BUILD)
  amPrintf("    [enter] - sequence step update"NL);
#endif
  amPrintf(NL "   [spacebar] - stop sequence replay"NL);
  amPrintf("    [Esc] - quit"NL);
  amPrintf("(c) Nokturnal 2007-22"NL);   
  amPrintf("=========================================="NL);
  amPrintf("Ready..."NL);
}

void displayTuneInfo(const sNktSeq *sequence)
{
  amPrintf("PPQN: %u\t",sequence->timeDivision);
  amPrintf("Tempo default: %u [uS] last: %u [uS]"NL, sequence->defaultTempo.upqn, sequence->currentTempo.upqn);
}

void mainLoop(sNktSeq *sequencePtr)
{

#if ((NKT_MANUAL_STEP==1) && defined DEBUG_BUILD)
    nktSequenceInitManual(sequence, NKT_PLAY_ONCE);
#else
    nktSequenceInit(sequencePtr, NKT_PLAY_ONCE, TRUE);
#endif

      IkbdClearState();

      // Install our asm ikbd handler 
      Supexec(IkbdInstall);

      uint16 quitFlag=0;

      while(quitFlag!=1)
      {
        // check keyboard input
        for (uint16 i=0; i<IKBD_KBD_TABLE_SIZE; ++i) 
        {
          const uint8 keyState = Ikbd_keyboard[i];
          
          if (keyState == KEY_PRESSED) 
          {
            Ikbd_keyboard[i]=KEY_UNDEFINED;

            switch(i)
            {
                case SC_ESC:
                {
                    quitFlag=1;
                    // stop sequence
                    nktSequenceStop(sequencePtr);
                } break;
                case SC_P:
                {
                    // starts playing sequence if is stopped
                    nktSequencePlay(sequencePtr);
                } break;
                case SC_R:
                {
                    // pauses sequence when is playing
                    nktSequencePause(sequencePtr);
                } break;
                case SC_M:
                {
                    // toggles between play once and play in loop
                    nktToggleReplayMode(sequencePtr);
                } break;
                case SC_I:
                {
                    // displays current track info
                    displayTuneInfo(sequencePtr);
                } break;
                case SC_H:
                {
                    // displays help/startup screen
                    printInfoScreen();
                } break;

                // adjust master volume
                case SC_ARROW_UP:
                {
                    uint8 midiMasterVolume = getMidiMasterVolume();

                    if(midiMasterVolume<127)
                    {
                        ++midiMasterVolume;
                        setMidiMasterVolume(midiMasterVolume);
                        amPrintf("[Master Volume]: %d"NL, midiMasterVolume);
                    }
                } break;

                case SC_ARROW_DOWN:
                {
                    uint8 midiMasterVolume = getMidiMasterVolume();

                    if(midiMasterVolume>0)
                    {
                      --midiMasterVolume;
                      setMidiMasterVolume(midiMasterVolume);
                      amPrintf("[Master Volume]: %d"NL, midiMasterVolume);
                    }
                } break;

                // adjust balance
                case SC_ARROW_LEFT:
                {
                  uint8 midiMasterBalance = getMidiMasterBalance();

                  if(midiMasterBalance>0)
                  {
                    --midiMasterBalance;
                    setMidiMasterBalance(midiMasterBalance);
                    amPrintf("<< [Master Pan]: %d"NL, midiMasterBalance);
                  }
                } break;

                case SC_ARROW_RIGHT:
                {
                    uint8 midiMasterBalance=getMidiMasterBalance();

                    if(midiMasterBalance<127)
                    {
                        ++midiMasterBalance;
                        setMidiMasterBalance(midiMasterBalance);
                        amPrintf("[Master Pan] >>: %d"NL, midiMasterBalance);
                    }

                } break;

#if ((NKT_MANUAL_STEP==1) && defined DEBUG_BUILD)
                case SC_ENTER:
                {
                    for(uint16 i=0;i<200;++i)
                    {
                        nktUpdateStep();
                    }

                    nktSequencePrintState();

                    // clear buffer after each update step
                    Supexec(flushMidiSendBuffer);

                } break;
#endif
                case SC_SPACEBAR:
                {
                    nktSequenceStop(sequencePtr);
                } break;

          }; // end of switch
        } // end if

        if (keyState == KEY_RELEASED)
        {
          Ikbd_keyboard[i]=KEY_UNDEFINED;
        }

       } //end of for
      } //end while

    // Uninstall our ikbd handler 
    Supexec(IkbdUninstall);
}
