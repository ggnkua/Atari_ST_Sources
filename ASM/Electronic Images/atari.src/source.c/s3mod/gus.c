/***************************************************/
/* S3m/Mod player by Daniel Marks                  */
/*    GUS support by David Jeske                   */
/* (C) 1994 By Daniel Marks and David Jeske        */
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
#include <sys/soundcard.h>
#include <sys/ultrasound.h>
#include <unistd.h>
#include "gus.h"
#include "mod.h"
#include "s3m.h"
#include "play.h"
#include <sys/types.h>
#include <stdio.h>
#include <fcntl.h>
#include "tables.h"

/* /dev/sequencer  information:
 *
 * /dev/sequencer was a mystery to me when I began this project
 * so I will attempt to explain what I have learned about it so far.
 * 
 * First, you must define a sequencer buffer (SEQ_DEFINEBUF(XXXX))
 * for your sequencer commands.
 *
 * the sequencer commands can be found in "soundcard.h", with some
 * GUS specific commands being found in "ultrasound.h". 
 * When you want to do stuff with /dev/sequencer, you need to have a
 * time synchronization so that things happen at the right time. 
 * Convinently, /dev/sequencer provides this as well.
 * the "sync_time" function, along with "this_time" and "next_time"
 * sync this program up with /dev/sequencer. You setup your "this_time"
 * to be now, and then set your next_time into the future and then
 * sync_time() and it'll wait until time catches up. 
 * 
 * You can see how this is applied if you look in "play_mod_gus" in
 * play.c. the look where "beattrack" and "update_notes" are called
 * uses this synchronication. There is no call to "sync_time()" here
 * because it should be as close as possible to the actual sequencer 
 * commands. There are calls to sync_time() in both update_notes and
 * prepare_notes.
 */


SEQ_DEFINEBUF(2048);

int sample_ok[MAX_TRACKS];

extern int gus_dev;
int seqfd;

int ticks_per_division;
double tick_duration;
double this_time,next_time;
double clock_rate;


unsigned int gus_total_mem=0;

/* GUS SETUP VARS
 * this is sort of a hack, not all things should have these
 * variables set this way. (i.e. other mod file formats need a 
 * different clock rate) but I'll get to it later 
 */

void gus_setup_vars()
{
   clock_rate = 50.0; /* for mods */

   tick_duration = 100.0 / clock_rate;
}

/* GUS GET DEVICE
 * this checks for /dev/sequencer, and then checks to make sure there
 * is a GUS in there somewhere. If not, then it returns (0) telling
 * the init routines in "play.c" that there is no GUS available and it
 * should look for something else.
 * If it finds a GUS it clears out the RAM on the GUS, and then finds
 * out how much total free memory is available on it.
 */

int get_gus_device(void)
{
  uint32 i,n;
  
  struct synth_info info;

  if ((seqfd = open ("/dev/sequencer", O_WRONLY, 0)) == -1)
    {
      /* perror ("/dev/sequencer");*/
      return (0);
    }

  if (ioctl (seqfd, SNDCTL_SEQ_NRSYNTHS, &n) == -1)
    {
      /* perror ("/dev/sequencer"); */
      return (0);
    }

  for (i = 0; i < n; i++)
    {
      info.device = i;

      if (ioctl (seqfd, SNDCTL_SYNTH_INFO, &info) == -1)
	{
	  /* perror ("/dev/sequencer"); */
	  return (0);
	}

      if (info.synth_type == SYNTH_TYPE_SAMPLE
	  && info.synth_subtype == SAMPLE_TYPE_GUS)
	gus_dev = i;
    }

  if (gus_dev == -1)
    {
    /*  fprintf (stderr, "Gravis Ultrasound not detected\n"); */
      return (0);
    }

/*
  if ((mixerfd = open ("/dev/mixer", O_RDWR, 0)) == -1)
    printf ("Mixer not available.\n");
 */


  ioctl (seqfd, SNDCTL_SEQ_SYNC, 0);
  ioctl (seqfd, SNDCTL_SEQ_RESETSAMPLES, &gus_dev);


  gus_total_mem = gus_mem_free(gus_dev);

  return (1);
}

/* GUS MEM FREE
 * this checks to see how much memory is available on the
 * GUS which is on /dev/sequencer
 */

int gus_mem_free (int dev)
{
  ioctl (seqfd, SNDCTL_SYNTH_MEMAVL, &dev);
  return (dev);
}
 
unsigned char dump_enabled=1;

/* SEQBUF DUMP
 * borrowed from gmod (see README for thanks)
 * this dumps all the current 
 * sequencer information to /dev/sequencer
 */

void seqbuf_dump ()
{
  int result;

  while (_seqbufptr && dump_enabled)
    {
      if ((result = write (seqfd, _seqbuf, _seqbufptr)) == -1)
        {
          perror ("write /dev/sequencer");
          exit (ERR_SEQUENCER);
        }
      else if (result != _seqbufptr)
        {
          _seqbufptr -= result;
          memmove (_seqbuf, &(_seqbuf[result]), _seqbufptr);
        }
      else
        _seqbufptr = 0;
    }
}

/* GUS PATCH LOAD 
 * this loads a patch onto the GUS. 
 * if the patch will not load, then it sets "sample_ok[sample_num]"
 * to 0. This makes it so the GUS sound support wont try and play
 * that instrument later.
 * For some reason, if too many patches fail to load, I think the
 * kernel drivers get confused.
 */

void gus_patch_load (struct patch_info *patch, int sample_num)
{
  int bytes_read;
  int len = patch->len;
  unsigned short loop_flags = patch->mode;
  int loop_start = patch->loop_start;
  int loop_end = patch->loop_end;
  int mem_avail;

  /* try to remove loop clicking */

  if ((loop_flags & WAVE_LOOPING) && (loop_end >= 2) &&
      !(loop_flags & WAVE_16_BITS))
    {
      patch->data[loop_end] = patch->data[loop_start];

      if (loop_flags & WAVE_UNSIGNED)
	patch->data[loop_end - 1] =
	  ((unsigned char) (patch->data[loop_end - 2]) +
	   (unsigned char) (patch->data[loop_end])) / 2;
      else
	patch->data[loop_end - 1] =
	  ((signed char) (patch->data[loop_end - 2]) +
	   (signed char) (patch->data[loop_end])) / 2;
    }

  mem_avail = gus_mem_free (gus_dev);	/* XXX */

  if (mem_avail < len)
    {
      printf ("*** Skipping patch - %d needed, %d available ***\n",
	      len, mem_avail);
      /* set sample to be OFF */
      sample_ok[sample_num]=0;
    }
  else
    {
      SEQ_WRPATCH (patch, sizeof (*patch) + len);
      /* set sample to be ON */
      sample_ok[sample_num] = 1;
    }
}

/* SYNC TIME
 * borrowed from gmod (See README for thanks)
 * this is part of the timing mechanism for talking to /dev/sequencer
 * see the top of this file for a more complete description
 */

void sync_time(void)
{
   if(next_time > this_time)
     {
       SEQ_WAIT_TIME ((long) next_time);
       this_time = next_time;
     }

}

/* STOP ALL VOICES
 * this stops all the voices which are currently playing on the
 * GUS.
 */

void stop_all_voices(void)
{
  int j;
  GUS_NUMVOICES(gus_dev,32);

  for(j=0;j<32;j++)
    {
      GUS_VOICEOFF(gus_dev,j);
      GUS_RAMPOFF(gus_dev,j);
    }

  SEQ_DUMPBUF();

}

/* SET PANNING 
 * borrowed from gmod (see README for thanks)
 * this functions generates a /dev/sequencer panning value from a number
 * between -127 to 127. It sends that command to the GUS
 */

void set_panning (int channel, signed char panning, unsigned char hw_flag)
{
  int pan_val;
  
  pan_val = panning * 2;
  if (pan_val > 127)
    pan_val = 127;
  else if (pan_val < -127)
    pan_val = -127;
  sync_time ();
  SEQ_PANNING (gus_dev, channel, (signed char) pan_val);
  if (hw_flag == PAN_HARDWARE)
    {
      pan_val = (pan_val + 16) / 32 + 7;
      GUS_VOICEBALA (gus_dev, channel, pan_val);
    }
  
}

/* SET SPEED
 * borrowed from gmod (see README for thanks)
 * this makes speed changes based on the set speed commands
 * in MOD and S3M files. if the number is equal to or below
 * the threshold then it is a "tempo" change, if not, then it's a 
 * "bpm" change. The threshold for MODs is 32, while the 
 * threshold for S3Ms is 48.
 */

void set_speed(int parm)
{
  if (!parm)
    parm = 1;

  if (parm < (mod.s3m ? 49 : 33))
    ticks_per_division = parm;
  else
    tick_duration = (250.0 / parm);

}

/* PERIOD TO NOTE
 * written by the authors of gmod (see README for thanks)
 * this routine takes a period for a note and turns it into a midi note/bend
 * pair. You can see how this note/bend pair is used to generate a 
 * "start note"/"pitchbend" pair of commands in the "prepare_notes" and 
 * "update_notes" command. 
 * this uses a period table which is in "tables.h"
 */

void period_to_note (int period, int *note, int *pitchbend)
{
  int low = 0, middle = 0, high = NUM_PERIODS - 1;
  int diff, diff_high, diff_low;

  *pitchbend = 0;

  if (period > period_table[0])
    period = period_table[0];
  else if (period < period_table[NUM_PERIODS - 1])
    period = period_table[NUM_PERIODS - 1];

  while (high >= low)
    {
      middle = (high + low) / 2;
      if (period == period_table[middle])
	break;
      else if (period < period_table[middle])
	low = middle + 1;
      else
	high = middle - 1;
    }

  if (period != period_table[middle])
    {
      diff_high = abs (period - period_table[high]);
      diff_low = abs (period - period_table[low]);

      if (diff_low < diff_high)
	middle = low;
      else
	middle = high;

      if (period < period_table[middle])
	diff = period_table[middle] - period_table[middle + 1];
      else
	diff = period_table[middle - 1] - period_table[middle];

      *pitchbend = (period_table[middle] - period) * 100 / diff;
    }

  *note = middle + NOTE_BASE;
}

/* PREPARE NOTES
 * this sets up the notes which will be played during the next row for one
 * track. If you are all familiar with mods, (or want to be) you should
 * know that mods can only change the "note" on the beginning of a
 * row. During that "row", however long it lasts according to the song
 * tempo, every 1/50 of a second, the effects are updated. When you have
 * a DSP playing the song, then the computer mixes a new "sample buf"
 * every 1/50 of a second. On the gus, all you have to do is adjust the
 * notes every 1/50 of a second. The routine called "update_notes" does
 * this
 */

void prepare_notes(int channel,track_info_ptr old_track,track_info_ptr track)
{
  int note=0,vol=0,samp,bend=0;
  int pitchbender=0,old_note;

  samp = track->samp;

  
  if (!sample_ok[samp])
    return;

  period_to_note(old_track->playing_period,&old_note,&bend);
  period_to_note(track->playing_period,&note,&bend);
  track->note = note;
  vol = track->playing_volume;

  /* if the patch is not loaded yet, then load it */
  
  if ((track->note_hit) || (old_track->samp != track->samp)) 
    {
      if (sample_ok[track->samp])
	{
	  sync_time();
	  SEQ_SET_PATCH(gus_dev,channel,track->samp); 
	}
    }
  
  sync_time();
  if (sample_ok[samp])
    {
      
      if (channel & 1)
	track->panning = -127;
      else
	track->panning = 127;
      
      if (old_track->panning != track->panning)
	set_panning(channel,track->panning, PAN_HARDWARE);
      
      
      if (track->note_hit)  
	{   
	  pitchbender = (note * 100 + bend) - (note * 100);
	  sync_time();
	  SEQ_START_NOTE(gus_dev,channel,note,vol);

	  SEQ_PITCHBEND(gus_dev,channel,pitchbender + 1);      
        }
      else
	{
	  /* check the volume and set it if necessary */
	  
	  if ((vol != old_track->playing_volume) && sample_ok[track->samp])
	    {
	      sync_time();
	      SEQ_START_NOTE(gus_dev,channel,255,vol);
	    }
	  
	  pitchbender = (note * 100 + bend) - (old_note * 100);

	  sync_time();
	  SEQ_PITCHBEND(gus_dev,channel,pitchbender + 1);      
	}
      
    }  
  else
    GUS_VOICEOFF(gus_dev,channel);
  
  track->note_hit = 0;
}

/* UPDATE NOTES
 * this routine updates the current characteristics of the notes which
 * are playing on the GUS. Instead of mixing a "sample buffer" and sending
 * it to the DSP every 1/50 of a second (like a /dev/dsp player does)
 * the GUS just needs to have it's voice information updated every 1/50
 * of a second and it does all the rest of the work for us.
 */

void update_notes(int channel,register track_info_ptr track)
{
  int16 t;
  int note,bend;
  int old_note,old_bend;
  int vol = track->playing_volume;
  int retrig=0,pitchbender=0;

  if (!sample_ok[track->samp])
     return;
  
  period_to_note(track->start_period,&old_note,&old_bend);

  period_to_note(track->playing_period,&note,&bend);

  sync_time();

  /* set the volume */
  SEQ_START_NOTE(gus_dev,channel,255,vol);
  
  /* retrigger if necessary */
  if (track->note_hit)
    {
      SEQ_START_NOTE(gus_dev,channel,note,vol);
      track->note_hit = 0;
    }
  
  pitchbender = (note * 100 + bend) - (old_note * 100);

  SEQ_PITCHBEND(gus_dev,channel,pitchbender + 1);      
   
}























