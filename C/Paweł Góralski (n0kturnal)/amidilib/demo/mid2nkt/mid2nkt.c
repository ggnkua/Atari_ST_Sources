
#if AMIDILIB_USE_LIBC
#include <string.h>
#else
#include "amstring.h"
#endif

#include "dmus.h"           // MUS->MID conversion
#include "midi.h"           // midi
#include "midi2nkt.h"
#include "fileio.h"
#include "core/amprintf.h"
#include "core/logger.h"    // logging
#include "core/machine.h"

#include <osbind.h>

static const uint32 MIDI_OUT_TEMP = 100*1024; // temporary buffer for MUS->MID conversion

void printInfoScreen(void);

int32 main(int32 argc, int8 *argv[])
{
  Bool bEnableCompression=FALSE;
  uint8 *filePath=0;

  Supexec(checkMachine);
  amSetDefaultUserMemoryCallbacks();

  (void)amFilesystemInit();

  amLoggerInit("mid2nkt.log");

  printInfoScreen();

  // check parameters for compression
  if( ((argc==2) && (strlen(argv[1])!=0)))
  {
      amPrintf("Trying to load %s"NL,argv[1]);
      filePath = argv[1];

  }
#if ENABLE_LZO_COMPRESSION
  else if((argc==3) && (strlen(argv[1])!=0)&&(strlen(argv[2])!=0))
  {

      if( ( (strcmp("-c",argv[1])==0) || (strcmp("--compress", argv[1])==0) ))
      {
       bEnableCompression = TRUE;
      }

      amPrintf("Trying to load %s"NL,argv[2]);
      filePath=argv[2];

  }
#endif  
  else
  {
      amPrintf("No specified mid / mus filename or bad parameters! Exiting ..."NL);
      amLoggerDeinit();

#if AMIDILIB_USE_LIBC
#else   
   (void)Cconin();
#endif

    return 0;
  }

  // load midi file into memory
  uint32 ulFileLenght=0;
  
  void *pMidi = amFileLoad(filePath, MF_PREFER_FASTRAM, &ulFileLenght,FILE_RO);

   if(pMidi!=NULL)
   {
        char tempName[AM_MAX_FILEPATH];

       // check MUS file
       MUSheader_t *pMusHeader=(MUSheader_t *)pMidi;

       if(((pMusHeader->ID)>>8)==MUS_ID)
       {
           // convert it to midi format
           amTrace("Converting MUS -> MID ..."NL,0);

           // allocate working buffer for midi output
           uint8 *pOut = (uint8 *)amMalloc(MIDI_OUT_TEMP, MF_PREFER_FASTRAM,NULL);
           (void)amMemSet(tempName, 0, AM_MAX_FILEPATH);

           // set midi output name
           strncpy(tempName,filePath,AM_MAX_FILEPATH-1);

           uint8 *fileExtPtr = strrchr(tempName,(int)'.');

           if(fileExtPtr!=NULL)
           {
               uint32 len=0;
               amMemCpy(fileExtPtr+1,"mid",4);
               amPrintf("[Please Wait] [MUS->MID] Processing midi data.."NL);
               int32 ret = amConvertMusToMidi(pMidi, (unsigned char *)pOut, 0, &len);

               if(ret!=AM_OK)
               {
                amPrintf("[Error] [MUS->MID] conversion failed."NL);
               }
           } 
           else 
           {
               amPrintf("[ Error ] Filename update failed."NL);

               /* free up buffer and quit */
               amFree(pMidi,0);
               return 0;
           }

           /* free up buffer with loaded MUS file, we don't need it anymore */
           amFree(pMidi,0);
           pMidi=(void *)pOut;
       }

       uint32 delta=0;

       // check mid 0,1 no quit
       if(((sMThd *)pMidi)->id==ID_MTHD && ((sMThd *)pMidi)->headLenght==6L&& (((sMThd *)pMidi)->format==0||((sMThd *)pMidi)->format==1))
       {
          amPrintf("Midi file loaded, size: %u bytes."NL, ulFileLenght);
          
          (void)amMemSet(tempName, 0, AM_MAX_FILEPATH-1);
          strncpy(tempName, filePath, AM_MAX_FILEPATH-1);

          uint8 *fileExtPtr = strrchr(tempName,'.');

          if(fileExtPtr!=NULL)
          {
           amMemCpy(fileExtPtr+1,"nkt",4);
           amPrintf("[ Please wait ] Converting MIDI %d to %s. Compress: %s"NL,((sMThd *)pMidi)->format, tempName, bEnableCompression?"YES":"NO");

           // convert
           sNktSeq* pSeq = nktConvertMidiToNkt(pMidi,tempName, bEnableCompression);

           if(pSeq)
           {
                // release sequence
                nktSequenceDestroy(pSeq);
           }
           else
           {
               amPrintf("[Error] [MID->NKT] conversion failed. Exiting."NL);
           }
          }
          else
          {
               amPrintf("[ Error ] Output filename update failed."NL);
          }
       }
       else
       {
           amPrintf("[ Error ] File is not in MIDI 0 or 1 format. Exiting... "NL);
       }

       /* free up buffer with loaded midi file, we don't need it anymore */
       amFree(pMidi,0);

    }

   //done..
   amLoggerDeinit();

   (void)amFilesystemDeinit();

   amPrintf(NL "Done. Press any key... "NL);

#if AMIDILIB_USE_LIBC
#else   
   (void)Cconin();
#endif

   return 0;
}

void printInfoScreen(void)
{
    amPrintf(NL "== MID / MUS to NKT converter v.1.4 ======"NL);
 #if AMIDILIB_USE_LIBC
    amPrintf("build date: %s %s"NL,__DATE__,__TIME__);
 #else  
    amPrintf("build date: %s %s nolibc"NL,__DATE__,__TIME__);
 #endif
    amPrintf("(c)Nokturnal 2007-22"NL);   
    amPrintf("=========================================="NL);
}
