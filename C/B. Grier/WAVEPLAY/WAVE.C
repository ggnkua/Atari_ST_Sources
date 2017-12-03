/**************************************************************
*       this program will play a "wave" file on an ATARI TT   *
*                                                             *
*  Algorithm:                                                 *
*      open file                                              *
*      Read the header of the file.                           *
*      if the header is not valid report that and exit        *
*      If file is an "RIFF" file convert to motorola integers *
*      allocate memory (ST-RAM) for PCM data                  *
*      Read the PCM data                                      *
*      close the file                                         *
*      If sample is 8 bit then convert data to ATARI format   *
*      play the Sample                                        *
*      wait until sample is completed                         *
*      free memory                                            *
*      exit                                                   *
*                                                             *
*                                                             *
*  Change History:                                            *
*                                                             *
*  12/10/92	Added ability to accept filenames from stdin      *
*  12/13/92 Corrected Error msgs relating to memory allocs    *
*                                                             *
**************************************************************/
/*
    The correct method of reading a WAV file is to
    read in the RIFF/RIFX chunk id and size along with
    the WAVE identifier.
    while not the end of the file (WAV files can contain multiple samples)
    Begin
      Read in the next chunk identifier
      while the identifier is not "fmt\0"
      Begin       (typically this section willnever be used)
        report type of chunk encountered.
        skip this chunk.
        read in the next chunk identifier
        End (ckID not "fmt\0")
      read in the "fmt\0" chunk data
      Read in the next chunk identifier
      while the identifier is not "data"
      Begin
        report type of chunk encountered.
        skip this chunk.
        read in the next chunk identifier
        End (ckID not "data")
      read in the data
      one second of sample at a time
      Begin
        re-sample the data (if needed otherwise copy)
        play the 1 second
        End (One second at a time)
      End (Not end of file)
*/

/*
  Things to be added:
    1) take filenames from STDIN
    2) optionally supress messages to stdout/stderr
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include "stereo.h"
#include "riff.h"

#define FALSE 0
#define TRUE  1
#define MAX_FNAME_LENGTH 132
#define FROM_START_OF_FILE 0
#define FROM_END_OF_FILE   2
void FatalError (char * id) ;
void MSC_cnvrt_int(INTEGER * i) ;
void MSC_cnvrt_long(LONG * i) ;
void Convert_MSC_ATARI_8_Bit(unsigned char * c, unsigned long i) ;
long Play_PCM_Sample() ;
void process_file(char * fname) ;
int  locate_chunk(char * id_fmt, CHK_DEF * Chk, FILE * fp) ;

char cmd[132] ;
char *id_riff = "RIFF";
char *id_rifx = "RIFX";
char *id_wave = "WAVE";
char *id_fmt  = "fmt ";
char *id_data = "data" ;
WAVE_DEFINITION  *wave ;
PCM_Samples       origSample ;
int               motorola_fmt ;

main(argc, argv)
int argc ;
char *argv[] ;
{
unsigned long   i ;
char            fname[MAX_FNAME_LENGTH] ;

  strcpy(cmd, argv[0]) ;
  fname[0] = '\0' ;
  if (argc > 1)
    for (i = 1; i < argc; i++) 
    {
      if (argv[i][0] != '-')
      {
        printf("%s -", argv[i]) ;
        process_file(argv[i]) ;
      }
    }
  else
  while (fgets(fname, MAX_FNAME_LENGTH, stdin) != NULL)
    process_file(fname) ;
  return 0 ;
}

void process_file(char * fname)
{
long            num_read ;
unsigned long   nSamples ;
double          Sample_length ;
long            BytesPerSample ;
long            file_size ;
long            file_pos ;
PCM_Samples     Dest ;
WAVE_FILE       riffChk ;
CHK_DEF         fmtChk ;
FILE          * fp ;

  motorola_fmt = FALSE ;
  if (strcmp(fname,"-")==0) 
  { 
    fp = stdin;  
    fname = "<stdin>"; 
  }
  else 
    fp = fopen(fname,"rb");

  fseek(fp,0l, FROM_END_OF_FILE) ;
  file_size = ftell(fp) ;
  fseek(fp,0l, FROM_START_OF_FILE) ;
  if (fp == NULL)
    FatalError("could not open file.") ;    

  wave = (WAVE_DEFINITION *) malloc(sizeof(WAVE_DEFINITION)) ;
  if (!wave)
    FatalError("not enough memory to read '*.WAV' file header");

  num_read = fread(&riffChk, 1, sizeof(WAVE_FILE), fp) ;
  if (num_read != sizeof(WAVE_FILE))
    FatalError("WAV 'riff' header read failed");

  if (strncmp(riffChk.riffStr, id_riff, 4))
  {
    if (strncmp(riffChk.riffStr, id_rifx, 4))
      FatalError("not an RIFF/RIFX file");
    else
      motorola_fmt = TRUE ;
  }
  if (strncmp(riffChk.waveStr, id_wave, 4))
    FatalError("not a WAVE file");

/*
   We now are going to have to possible loop through
   many "chunks" of information to locate the format
   "fmt" chunk for this WAVe file.
*/
  if (locate_chunk(id_fmt, &fmtChk, fp) == -1)
  {
    FatalError("EOF encountered before 'fmt' chunk") ;
  }

  num_read = fread(&(wave->hdr),1, sizeof(WAVE_HDR), fp) ;
  if (num_read != sizeof(WAVE_HDR))
    FatalError("WAVE header read failed");

  if (locate_chunk(id_data, &(wave->data), fp) == -1)
  {
    FatalError("EOF encountered before 'data' chunk") ;
  }
/*
  because some sample wave files are incomplete the next few
  lines will make adjustments to try and fix that.
*/
  file_pos = ftell(fp) ;
  if ((file_pos + wave->data.ckSize) > file_size)
  {
    wave->data.ckSize = file_size - file_pos ;
  }
/* do we need to change the integer storage format to motorola? */
  if (motorola_fmt == FALSE)
  {
    MSC_cnvrt_long(&riffChk.ckSize) ;
/*
    MSC_cnvrt_long(&fmtChk.ckSize) ;
*/
    MSC_cnvrt_int(&wave->hdr.formatTag) ;
    MSC_cnvrt_int(&wave->hdr.nChannels) ;
    MSC_cnvrt_long(&wave->hdr.nSamplesPerSec) ;
    MSC_cnvrt_long(&wave->hdr.nAvgBytesPerSec) ;
    MSC_cnvrt_int(&wave->hdr.nBlockAlign) ;
    MSC_cnvrt_int(&wave->hdr.nBitsPerSample) ;
/*
    MSC_cnvrt_long(&wave->data.ckSize) ;
*/
  }
  if (wave->hdr.nChannels > 2)
    FatalError("can not accept more than 2 channels in file") ;


/* 
    Since the STe/TT only support 8 bit PCM codes
    We need to determine the correct amount of memory.
    We also must take into consideration that that WAVE
    file may not be sampled at the same rate the STe/TT
    can play it back. So we may need to peform a little
    DSP to reconstruct the sample so the Atari can play it
    correctly.
*/

/* Determine memory requirements */
  BytesPerSample = (wave->hdr.nBitsPerSample + 7) / 8 ;
  if (BytesPerSample > 2)
    FatalError("can not accept more than 2 bytes per sample") ;

  if ( wave->hdr.nSamplesPerSec <= SSS_RATE_50kHz )
    wave->Target_SpS = SSS_RATE_50kHz ;
  if ( wave->hdr.nSamplesPerSec <= SSS_RATE_25kHz )
    wave->Target_SpS = SSS_RATE_25kHz ;
  if ( wave->hdr.nSamplesPerSec <= SSS_RATE_12kHz )
    wave->Target_SpS = SSS_RATE_12kHz ;
  if ( wave->hdr.nSamplesPerSec <= SSS_RATE_6kHz )
    wave->Target_SpS = SSS_RATE_6kHz ;

/*
   determine the number of seconds the sample will play for 
*/
  nSamples = (wave->data.ckSize / wave->hdr.nChannels)/ BytesPerSample ;
  Sample_length = (double)nSamples / (double)wave->hdr.nSamplesPerSec ;

  printf("WAVE file contents:\n") ;
  printf("  %d bit", wave->hdr.nBitsPerSample) ;
  if (wave->hdr.nChannels == 2)
    printf(" Stereo\n") ;
  else
    printf(" Mono\n") ;
  printf("Sample Rate:\n   Original : %ld\n   Playback :%ld\n",
         wave->hdr.nSamplesPerSec, wave->Target_SpS) ;
  printf("  %lf seconds playing time\n", Sample_length) ;

/*
   determine the number of bytes required to hold
   sample at a rate that the Atari can play back.
*/
  wave->required_memory = (unsigned long)((double)wave->Target_SpS * Sample_length) ;
  wave->required_memory = wave->required_memory * wave->hdr.nChannels ;

/* Allocate memory for the PCM Data */
  wave->PCM.Mono8 = (unsigned char *)Mxalloc(wave->required_memory,0) ;

  if (!wave->PCM.Mono8)
    FatalError("not enough memory to play sample") ;

  if (wave->Target_SpS == wave->hdr.nSamplesPerSec)
  { /* no psuedo DSP algorithm required */
    num_read = fread(wave->PCM.Mono8,1, wave->data.ckSize, fp) ;
    if (num_read != wave->data.ckSize)
      FatalError("error reading WAVE data") ;
  }
  else
/*
  determine the amount of memory required to read in the
  entire WAVE file. Use TT-RAM if available (mode = 3)
*/
  {
    origSample.Mono8 = (unsigned char *)Mxalloc(wave->data.ckSize,3) ;
    if (!origSample.Mono8)
      FatalError("not enough memory to read in sample");

    Dest.Mono8 = wave->PCM.Mono8 ;
    num_read = fread(origSample.Mono8,1, wave->data.ckSize, fp) ;
    if (num_read != wave->data.ckSize)
    {
      FatalError("error reading source of WAVE data") ;
      wave->required_memory = (long)((float)wave->required_memory 
                                   * (float)(num_read)/(float)wave->data.ckSize) ;
      wave->data.ckSize = num_read ;
    }

/*
   If we only had object oriented programming this next section
   would have only one line
*/
    switch (wave->hdr.nChannels)
    {
      case 1 : switch ((int)BytesPerSample)
               {
                 case 1: Resample8bitMono(&Dest, &origSample, wave->required_memory, wave->data.ckSize) ;
                         break ;
                 case 2: Resample16bitMono(&Dest, &origSample, wave->required_memory, wave->data.ckSize) ;
                         break ;
                 default:
                   FatalError("can not convert this # bytes per sample") ;
               }
               break ;
      case 2 : switch ((int)BytesPerSample)
               {
                 case 1: Resample8bitStereo(&Dest, &origSample, wave->required_memory, wave->data.ckSize) ;
                         break ;
                 case 2: Resample16bitStereo(&Dest, &origSample, wave->required_memory, wave->data.ckSize) ;
                         break ;
                 default:
                   FatalError("can not convert this # bytes per sample") ;
               }
               break ;
      default :
         FatalError("Incorrect # of channels") ;
    }
  }
  Supexec(Play_PCM_Sample) ;

  free(wave->PCM.Mono8) ;
  free(wave) ;
  free(origSample.Mono8) ;
  fclose(fp) ;
}


/***********************************/
void FatalError (identifier)
       char *identifier;
{
  if (wave != NULL)
  {
    if (wave->PCM.Mono8 != NULL)
      free(wave->PCM.Mono8) ;
    free(wave) ;
  if (origSample.Mono8 != NULL)
    free(origSample.Mono8) ;
  }
  fprintf(stderr, "Fatal Error: %s: %s\n",cmd, identifier);
  exit(-1);
  return ;
}


/*
  The next two routines convert an integer and a long
  that is stored in Intel format to Motorola format
*/
void MSC_cnvrt_int(i)
INTEGER * i ;
{
char tmp ;

  tmp = i->MSC[0] ;
  i->MSC[0] = i->MSC[1] ;
  i->MSC[1] = tmp ;
} 

void MSC_cnvrt_long(LONG * i) 
{
char tmp ;

  tmp = i->MSC[0] ;
  i->MSC[0] = i->MSC[3] ;
  i->MSC[3] = tmp ;
  tmp = i->MSC[1] ;
  i->MSC[1] = i->MSC[2] ;
  i->MSC[2] = tmp ;
}

/*
  Since the following routine accesses the hardware registers
  it must be executed in supervisory mode.
*/
long Play_PCM_Sample()
{
SOUND_REGS    *hardware = (SOUND_REGS *)0xff8900l ;
unsigned int   mode ;
unsigned long  tmp ;

/*
  hardware = (SOUND_REGS *)malloc(sizeof(SOUND_REGS)) ;
*/
  switch (wave->Target_SpS)
  {
    case SSS_RATE_6kHz  : mode = SSS_RATE_06258Hz ; /* 0x0 */
                          break ;
    case SSS_RATE_12kHz : mode = SSS_RATE_12517Hz ; /* 0x1 */
                          break ;
    case SSS_RATE_25kHz : mode = SSS_RATE_25033Hz ; /* 0x2 */
                          break ;
    case SSS_RATE_50kHz : mode = SSS_RATE_50066Hz ; /* 0x3 */
                          break ;
    default : FatalError("can not play sample rate") ;
  }
 
  if (wave->hdr.nChannels == 1)
    mode = mode | SSS_MONO ;

  tmp = (unsigned long)wave->PCM.Mono8 + wave->required_memory ;

  hardware->Frame_base_high = ((unsigned long) wave->PCM.Mono8 >> 16) & 0x3f ;
  hardware->Frame_base_med = ((unsigned long) wave->PCM.Mono8 >> 8) & 0xff ;
  hardware->Frame_base_low = (unsigned long) wave->PCM.Mono8 & 0xfe ;

  hardware->Frame_end_high = ((unsigned long) tmp >> 16) & 0x3f ;
  hardware->Frame_end_med = ((unsigned long) tmp >> 8) & 0xff ;
  hardware->Frame_end_low = (unsigned long) tmp & 0xfe ;

  hardware->Mode_cntrl = mode ;
  hardware->DMA_cntrl = 0x01 ;

/* wait for the sample to complete */
  while(hardware->DMA_cntrl != 0) ;

  return 0l ;

}

int locate_chunk(char * id_fmt, CHK_DEF * Chk, FILE * fp)
{
int good_bad ;
int num_read ;
char temp[5] ;

  good_bad = 0 ; /* false */
  do
  {
    temp[4] = '\0' ;
    num_read = fread(Chk, 1, sizeof(CHK_DEF), fp) ;
    if (num_read != sizeof(CHK_DEF))
      return -1 ;
    if (motorola_fmt == FALSE)
      MSC_cnvrt_long(&Chk->ckSize) ;
    strncpy(temp, Chk->ckStr, 4) ;
    printf("Found Chunk of type : %s\n", temp) ;
    if (strncmp(id_fmt, Chk->ckStr, 4) != 0)
    {
      fseek(fp, Chk->ckSize, 1) ;
    }
    else
      good_bad = 1 ;  /* true */
  } while (good_bad == 0) ;
  return 0 ;
}