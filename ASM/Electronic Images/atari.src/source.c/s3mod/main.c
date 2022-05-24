/***************************************************/
/* S3m/Mod player by Daniel Marks                  */
/*    GUS support by David Jeske                   */
/* (C) 1994 By Daniel Marks                        */
/* While we retain the copyright to this code,     */
/* this source code is FREE. You may NOT steal     */
/* the copyright of this code from us.             */
/* You may use it in any way you wish, in          */
/* any product you wish. We respectfully ask that  */
/* you email one of us, if possible, if you        */
/* produce something significant with this code,   */
/* or if you have any bug fixes to contribute.     */
/* We also request that you give credit where      */
/* credit is due if you include part of this code  */
/* in a program of your own.                       */
/*                                                 */
/* email: dlm40629@uxa.cso.uiuc.edu		   */
/*        jeske@intlink.net			   */
/*                                                 */
/* See the associated README file for Thanks       */
/***************************************************/

/* MAIN.C */

#include <stdio.h>
#include <string.h>
#include <linux/soundcard.h>
#include <fcntl.h>
#include <bytesex.h>
#include "mod.h"
#include "s3m.h"
#include "play.h"
#include "main.h"
#include "gus.h"
#include "cmdline.h"



struct option_struct options;

int gus_dev=-1;
int use_gus=1;


void help(void)
{
  printf("\nS3MOD - S3M/MOD tracker (%s) for Linux by Daniel Marks\n",VERSION);
  printf("                             GUS Support by David Jeske\n");
  printf("dlm40629@uxa.cso.uiuc.edu\n");
  printf("jeske@intlink.net\n\n");
  printf("(C) Copyright 1994 by Daniel L. Marks and David Jeske\n");
  printf("See README file for Copyright details.\n\n");
  printf("s3mod [-sbfqnl] [sampling frequency] filename\n");
  printf("     -s stereo\n");
  printf("     -b 16 bit samples\n");
  printf("     -f set frequency\n");
  printf("     -q quiet (don't print anything)\n");
  printf("     -n don't loop\n");
  printf("     -l loud mode (shift voices louder)\n");
  printf("     -g do NOT use GUS native mode\n");
  printf("     -p PAL speed adjustment (145bpm start)\n");
  printf("s3mod -sbf 44100 foobar.mod\n");
  printf("   plays in stereo, 16 bits, 44.1 kHz\n\n");
  printf("This player plays Screamtracker 3 files, and\n");
  printf("4,6,or 8 track MODs.\n\n");
  printf("NOTE: GUS native mode is in it's ALPHA stages\n\n");
  exit(1);
}



int get_dsp_device(void);
int get_gus_device(void);

void get_audio_device(void)
{
  int found_gus=0;

  if (use_gus)
    {
      found_gus = get_gus_device();
    }

 if (!found_gus)
   {gus_dev=-1;
    get_dsp_device();
   }

}


int get_dsp_device(void)
{
  uint32 j;

  audio=open("/dev/dsp",O_WRONLY,0);
  if (audio < 1)
  {
    printf("Could not open audio device!\n");
    exit(1);
  }
  if (stereo)
  { 
    if (ioctl(audio,SNDCTL_DSP_STEREO,&stereo) == -1)
      stereo = 0;
  }
  if (bit16)
  {
    j = 16;
    if (ioctl(audio,SNDCTL_DSP_SAMPLESIZE,&j) == -1) bit16 = 0;
    if (j != 16) bit16 = 0;
  }
  j = mixspeed;
  if (ioctl(audio,SNDCTL_DSP_SPEED,&j) == -1) 
  { 
    printf("Error setting sample speed\n");
    exit(1);
  }
  mixspeed = j;
  if (ioctl(audio,SNDCTL_DSP_GETBLKSIZE, &audio_buffer_size) == -1)
  {
    printf("Unable to get audio blocksize\n");
    exit(1);
  }
  if ((audio_buffer_size < 4096) || (audio_buffer_size > 131072))
  {
    printf("Invalid audio buffer size: %d\n",audio_buffer_size);
    exit(1);
  }
  if (!(audio_start_buffer = (uint8 *) malloc(audio_buffer_size)))
  {
    printf("Could not get audio buffer memory!\n");
    exit(1);
  }
  audio_end_buffer = &audio_start_buffer[audio_buffer_size];
  audio_curptr = audio_start_buffer;  




}






void main(int argc, char **argv)
{
  uint32 j;
  char *filename;
  long int frequency;
  int quiet = 0;
  int loud = 0;
  int use_pal = 0;

  mixspeed = DSP_SPEED;

  if (argc < 2) 
    { help();
      exit(1);
    }
 
  parm_setup(argc,argv,"","SsBbQqNnLlGgPp","Ff");

  if (read_parm(NON_FLAGGED, &filename, NULL) != 1)
  {
    help();
    printf("No executable filename found!\n");
    exit(1);
  }

  if (read_parm('S',NULL,NULL))
    stereo=1;
  else
    stereo=0;
  if (read_parm('B',NULL,NULL))
    bit16=1;
  else
    bit16=0;
  if (read_parm('Q',NULL,NULL))
    quiet=1;
  else
    quiet=0;
  if (read_parm('N',NULL,NULL))
    loop_mod = 0;
  else
    loop_mod = 1;
  if (read_parm('L',NULL,NULL))
    loud = 1;
  else
    loud = 0;
  if (read_parm('G',NULL,NULL))
    use_gus = 0;
  else
    use_gus = 1;
  if (read_parm('P',NULL,NULL))
    use_pal = 1;
  else
    use_pal = 0;

  if (read_parm('F',NULL,&frequency))
    {
      mixspeed = (frequency);
      if ((mixspeed < 8000) || (mixspeed > 44100))
	{ help();
	  printf("Invalid Frequency: %ld",frequency);
	  exit(1);
	}
    }
    
  if (use_pal)
    { options.def_tempo = DEF_TEMPO_PAL; 
      options.def_bpm   = DEF_BPM_PAL;
    }
  else
    { options.def_tempo = DEF_TEMPO_NTSC;
      options.def_bpm   = DEF_BPM_NTSC;
    }


  get_audio_device();

  if (load_s3m(filename,&mod,quiet))
    if (load_mod(filename,&mod,quiet))
    {
      printf("File is not a valid mod or s3m!\n");
      exit(1);
    }

  if (!quiet) 
  {

    if (gus_dev==-1)
      printf("Playing \"%s\"\nAt rate %d, %d bits, %s, blocksize %d\n",
	     filename,
	     mixspeed,
	     bit16 ? 16 : 8,
	     stereo ? "stereo" : "mono",
	     audio_buffer_size);
    
    else
      printf("GUS (ALPHA support) Playing \"%s\" \nUsing %d of %d bytes of GUS RAM\n",
	     filename,(gus_total_mem - gus_mem_free(gus_dev)),
	     (gus_total_mem));

  }
  if (gus_dev!=-1)
     play_mod_gus(loud);
  else
     play_mod(loud);


  free(audio_start_buffer);
  close(audio);
}
















