
/**  Copyright 2007-2022 Pawel Goralski
    
    This file is part of AMIDILIB.
    See license.txt for licensing information.
*/

#if AMIDILIB_USE_LIBC
#include <string.h>
#include <stdlib.h>
#include <limits.h>
#else
#include "amstring.h"
#endif

#include "core/amprintf.h"

#include "amidilib.h"
#include "amidiseq.h"       
#include "timing/mfp.h"
#include "timing/miditim.h"
#include "fileio.h"

// nkt conversion
#include "nkt.h"
#include "seq2nkt.h"

#ifdef MIDI_PARSER_TEST
#include "eventlist.h"
#endif

#include "input/ikbd.h"

#if ((AM_MANUAL_STEP==1) && defined DEBUG_BUILD)
AM_EXTERN void updateStepSingle(void);
AM_EXTERN void updateStepMulti(void);
#endif

// display info screen
void printInfoScreen(void); 
void displayTuneInfo(void);
void mainLoop(sSequence_t *pSequence, const char *pFileName);

#ifdef MIDI_PARSER_TEST
void midiParserTest(sSequence_t *pSequence);
#endif

/**
 * main program entry
 */

int32 main(int32 argc, int8 *argv[])
{
    amPrintf(NL "==============================================="NL);
    amPrintf("midi player"NL);
#if AMIDILIB_USE_LIBC
    amPrintf("build date: %s %s"NL,__DATE__,__TIME__);
#else  
    amPrintf("build date: %s %s nolibc"NL,__DATE__,__TIME__);
#endif
    amPrintf("(c) Nokturnal 2007-22"NL);   
    amPrintf("==============================================="NL);

    if( ((argc>=1) && strlen(argv[1])!=0))
    {
      amPrintf("Trying to load %s"NL,argv[1]);
    }
    else
    {
      amPrintf("No specified midi filename! exiting."NL);
      return 0;
    }
    
    /* init library */
    int16 retVal = amInit();
    
    if(retVal != AM_OK) 
    {
        amPrintf("Library initialisation error."NL);
        return -1;
    }

    // load midi file into memory 
    uint32 fileLenght = 0;
    void *pMidiData = amFileLoad((uint8 *)argv[1], MF_PREFER_FASTRAM, &fileLenght, FILE_RO);

    if(pMidiData!=NULL)
    {
        
     amPrintf("Midi file loaded, size: %d bytes."NL,fileLenght);
     
     /* process MIDI*/
     amPrintf("Please wait..."NL);

     sSequence_t *pMusicSeq = amProcessMidiFileData(argv[1], pMidiData, fileLenght);

     /* free up buffer with loaded midi file, we don't need it anymore */
     amFree(pMidiData,0);

     if(pMusicSeq != 0)
     {
	    amPrintf("Sequence name: %s"NL,pMusicSeq->pSequenceName);
	    amPrintf("Nb of tracks: %d"NL,pMusicSeq->ubNumTracks);
        amPrintf("Ticks per beat/PPQN: %u"NL,pMusicSeq->timeDivision);
	  
#ifdef MIDI_PARSER_TEST
        // output loaded midi file to screen / log
        midiParserTest(pMusicSeq);
#endif

	    printInfoScreen();    
        mainLoop(pMusicSeq,argv[1]);
	  
	    // unload sequence
	    amSequenceDestroy(&pMusicSeq);
     } 
     else 
     {
        amTrace("Error while parsing. Exiting... "NL,0);
    
        // unload sequence
        amSequenceDestroy(&pMusicSeq);
        amDeinit(); //deinit our stuff
        return -1;
     }
     
    } 
    else 
    { 
      /* MIDI loading failed */
      amTrace("Error: Couldn't read %s file..."NL,argv[1]);
      amPrintf("Error: Couldn't read %s file..."NL,argv[1]);
      amDeinit();	//deinit our stuff
      return -1;
    }

 deinstallReplayRout();   
 amDeinit();
 return 0;
}


void mainLoop(sSequence_t *pSequence, const char *pFileName)
{
      // install replay rout
#if ((AM_MANUAL_STEP==1) && defined DEBUG_BUILD)
    amSequenceInitManual(pSequence);
#else
    amSequenceInit(pSequence,MFP_TiC);
#endif

	  IkbdClearState();

      // Install our asm ikbd handler 
      Supexec(IkbdInstall);

	  uint16 quitFlag = 0;
	  
      while(quitFlag!=1)
      {
	    // check keyboard input  
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
                  // stop sequence
                  amSequenceStop();
                } break;
                case SC_P:
                {
                  // starts playing sequence if is stopped
                  amSequencePlay();
                } break;
                case SC_R:
                {
                   // pauses sequence when is playing
                   amSequencePause();
                 } break;
                case SC_M:
                {
                   // toggles between play once and play in loop
                   amSequenceToggleReplayMode();
                } break;
                case SC_I:
                {
                  // displays current track info
                  displayTuneInfo();
                } break;

                case SC_D:
                {
                    // dumps loaded sequence to NKT file
                    amPrintf("Convert sequence to NKT format..."NL);
                    char tempName[128]={0};
                    char *pTempPtr=0;
                    sNktSeq *pNktSeq=0;

                    // set midi output name
                    strncpy(tempName,pFileName,128);
                    pTempPtr = strrchr(tempName,'.');
                    memcpy(pTempPtr+1,"NKT",4);

                    if(Seq2NktFile(pSequence, tempName, FALSE)!=AM_OK)
                    {
                        amPrintf("Error during NKT format conversion.."NL);
                    } else
                    {
                        amPrintf("File saved: %s."NL,tempName);
                    }
                } break;
                case SC_H:
                {
                  // displays help/startup screen
                  printInfoScreen();
                } break;
                case SC_SPACEBAR:
                {
                  amSequenceStop();
                } break;

#if ((AM_MANUAL_STEP==1) && defined DEBUG_BUILD)
                case SC_ENTER:
                {
                    for(uint16 i=0;i<SEQUENCER_UPDATE_HZ;++i)
                    {
                        if(pSequence->seqType==ST_SINGLE)
                        {
                            updateStepSingle();
                        }
                        else if(pSequence->seqType==ST_MULTI)
                        {
                            updateStepMulti();
                        }else if(pSequence->seqType==ST_MULTI_SUB)
                        {
                           AssertMsg(false,"!!! ST_MULTI_SUB update TODO..."NL);
                        }
                        else
                        {
                            AssertMsg(false,"Unknown sequence type."NL);
                        }
                    }

                    amSequencePrintState();

                    // clear buffer after each update step
                    MIDIbytesToSend = 0;
                    (void)amMemSet(MIDIsendBuffer,0,32*1024);

                } break;
#endif
	       };//end of switch
	     } // end if
	    
	    if (keyState==KEY_RELEASED)
        {
	      Ikbd_keyboard[i]=KEY_UNDEFINED;
	    }
	      
	   } //end of for 	  
	
	  } // while
	// Uninstall our ikbd handler 
	Supexec(IkbdUninstall);
}


void printInfoScreen(void)
{
  const sAMIDI_version version = amGetVersionInfo();
  
  amPrintf(NL "========================================="NL);
  amPrintf(LIB_NAME NL);
  amPrintf("v.%d.%d.%d\t", version.major, version.minor, version.patch);
  amPrintf("date: %s %s"NL, __DATE__, __TIME__);
  
  amPrintf("    [i] - display tune info"NL);
  amPrintf("    [p] - play loaded tune"NL);
  amPrintf("    [r] - pause/unpause played sequence"NL);
  amPrintf("    [m] - toggle play once / loop mode "NL);
  amPrintf("    [d] - Convert sequence to NKT format."NL);
  amPrintf("    [h] - show this help screen "NL);
  amPrintf(NL "    [spacebar] - stop sequence replay "NL);
  amPrintf("    [Esc] - quit"NL);
  amPrintf(AMIDI_INFO NL);
  amPrintf("=========================================="NL);
  amPrintf("Ready..."NL);
} 

void displayTuneInfo(void)
{
  const sSequence_t *pPtr = amSequenceGetActive();
  
  const uint32 upqn = pPtr->arTracks[0]->currentState.upqn;
  const uint16 td = pPtr->timeDivision;
  const uint16 numTrk = pPtr->ubNumTracks;
  
  amPrintf("Sequence name %s"NL,pPtr->pSequenceName);
  amPrintf("td/ppqn: %u\t",td);
  amPrintf("upqn: %u [uS]"NL,upqn);
  
  amPrintf("Number of tracks: %d"NL,numTrk);
  
  for(uint16 i=0;i<numTrk;++i)
  {
    uint8 *pTrkName = pPtr->arTracks[i]->pTrackName;
    amPrintf("[Track no. %d] %s"NL,(i+1),pTrkName);
  }
  
  amPrintf(NL "Ready..."NL);
}

#ifdef MIDI_PARSER_TEST
void midiParserTest(sSequence_t *pSequence)
{
   amTrace("Parsed MIDI read test"NL,0);
   amTrace("Sequence name: %s"NL,pSequence->pSequenceName);
   amTrace("Nb of tracks: %d"NL,pSequence->ubNumTracks);
   amTrace("Ticks per beat/PPQN: %u"NL,pSequence->timeDivision);
   amTrace("Active track: %d"NL,pSequence->ubActiveTrack);
	  
  //output data loaded in each track
  for (uint16 i=0;i<pSequence->ubNumTracks;++i)
  {
    sTrack_t *p=pSequence->arTracks[i];
    
    if(p!=0)
    {
        amTrace("Track #[%d] \t",i+1);
        amTrace("Track name: %s"NL,p->pTrackName);
        amTrace("Track ptr %p"NL,p->pTrkEventList);
        
        //print out all events
        if(p->pTrkEventList!=0)
        {
          sEventList *pEventList=p->pTrkEventList;
        
          while(pEventList!=0)
          {
            printEventBlock(&(pEventList->eventBlock));
            pEventList=pEventList->pNext;
          }
        }
    }
  }
}
#endif
