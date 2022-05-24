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

#include <stdio.h>
#include <string.h>
#include <sys/soundcard.h>
#include <sys/ultrasound.h>
#include <fcntl.h>
#include <bytesex.h>
#include "mod.h"
#include "s3m.h"
#include "play.h"
#include "gus.h"
#include "main.h"

int                     audio;
union
{
  uint8                   rot_buf[ROT_BUF_SIZE];
  uint16                  rot_buf16[ROT_BUF_SIZE];
} buf;

int                     stereo = 0;
int                     bit16 = 0;



void updatetracks(void)
{
  track_info_ptr track;
  int16 count;

  tempo_wait = tempo;
  if (row >= 64)
  {
    if (order_pos >= mod.song_length_patterns)
    {
      order_pos = mod.song_repeat_patterns;
      if (order_pos >= mod.song_length_patterns)
      {
        order_pos = 0;
        mod_done = 1;
      }
    }
    row = break_row;
    break_row = 0;
    if (mod.positions[order_pos] == 0xFF)
    {
      mod_done = 1;
      return;
    }
    if (mod.s3m)
      note = mod.patterns[mod.positions[order_pos]];
      else
      note = mod.patterns[mod.positions[order_pos]] + 
             (((uint16)row) * sizeof(uint8) * 4 * mod.tracks);
    order_pos++;
  }
  row++;
  if (mod.s3m)
    get_track_s3m(&note);
    else
    {
      track = tracks;
      for (count=0;count<mod.tracks;count++)
        get_track(track++,&note);
     
    }
  track = tracks;
  for (count=0;count<mod.tracks;count++)
  {
    track->playing_period = track->period;
    track->playing_volume = track->volume;
    track++;
  }

#ifdef DEBUG
  printf("00-01-02-03-04-05-06-07-pattern %d row %d\n",order_pos,row);
#endif
  return;
}


void play_mod(int loud)
{
  register uint8 *c;
  register uint16 *d;
  int16 i;
  track_info_ptr track;
  int16 count;

  startplaying(loud);
  mod_done = 0;
  while (!mod_done)
  {
    if (--tempo_wait)
      {
	track = tracks;
	for (count=0;count<mod.tracks;count++)
	  beattrack(track++);
      }
    else
      updatetracks();

    track = tracks;
    if (bit16)
    {
      if (stereo)
         for (d=&buf.rot_buf16[bpm_samples << 1];d > buf.rot_buf16;*(--d) = 0x8000);
         else
         for (d=&buf.rot_buf16[bpm_samples];d > buf.rot_buf16;*(--d) = 0x8000);
    } else
    {
      if (stereo)
         for (c=&buf.rot_buf[bpm_samples << 1];c > buf.rot_buf;*(--c) = 0x80);
         else
         for (c=&buf.rot_buf[bpm_samples];c > buf.rot_buf;*(--c) = 0x80);
    }
    for (i=0;i<mod.tracks;i++)
    {

      if (bit16)
      {
        if (stereo)
          mixtrack_16_stereo(track,buf.rot_buf16,bpm_samples,
                             i & 0x01);
          else
          mixtrack_16_mono(track,buf.rot_buf16,bpm_samples);
      } else
      {
        if (stereo)
          mixtrack_8_stereo(track,buf.rot_buf,bpm_samples,
                             i & 0x01);
          else
          mixtrack_8_mono(track,buf.rot_buf,bpm_samples);
      }
      track++;
    }
    c = (uint8 *) buf.rot_buf;
    if (stereo)
    {
      if (bit16)
        d = (uint16 *) &c[bpm_samples << 2];
        else
        d = (uint16 *) &c[bpm_samples << 1];
    } else
    {
      if (bit16)
        d = (uint16 *) &c[bpm_samples << 1];
        else
        d = (uint16 *) &c[bpm_samples];
    }
    while (c < ((uint8 *)d))
    {
      if (audio_curptr >= audio_end_buffer)
      {
        write(audio,audio_start_buffer,audio_buffer_size);
        audio_curptr = audio_start_buffer;
      }
      *audio_curptr++ = *c++;
    }
  } 
}

void play_mod_gus(int loud)
{

  int16 i;
  int extra_ticks, tick;
  track_info_ptr track;
  track_info_ptr old_track;
  uint8 *c;
  uint16 *d;

 
  gus_setup_vars();

  startplaying(loud);

  stop_all_voices();

  SEQ_START_TIMER();

  if (mod.tracks < 14)
    {
      GUS_NUMVOICES (gus_dev, 14);
    }
  else
    {
      GUS_NUMVOICES (gus_dev, mod.tracks);
    }
    

  for(i=0;i<mod.tracks;i++)
    {
      SEQ_BENDER_RANGE(gus_dev,i,8191);
      SEQ_EXPRESSION(gus_dev,i,options.main_volume);
      SEQ_MAIN_VOLUME(gus_dev,i,100);
      SEQ_PANNING (gus_dev,i,0);
      SEQ_PITCHBEND(gus_dev,i,0);
    }


  next_time = 0.0;
  set_speed(mod.tempo); 
  set_speed(mod.bpm); 
    
  this_time = 0.0;
  next_time += tick_duration;
  sync_time();

  mod_done = 0;
  
  while (!mod_done)
    {
      /* save the old track info for "prepare_notes" */

      memcpy(old_tracks,tracks,sizeof(*tracks) * MAX_TRACKS);

      updatetracks();

      track = tracks;
      old_track = old_tracks;
      this_time = 0.0;  /* reset the time */

      /* now setup the voices for the current row */

      for (i=0;i<mod.tracks;i++)
	{
	  prepare_notes(i,old_track++,track++);
	}

      /* now that the voices are setup, we need to "modulate" them
	 as necessary for the different effects */

      extra_ticks = 0; /* check this out */

      tempo_wait = tempo;
      
      for(tick = 0; tick < ticks_per_division + extra_ticks;tick++)
	{
	  track = tracks;

	  for(i=0;i<mod.tracks;i++)
	    {
	      beattrack(track);
	      update_notes(i,track);
	      track++;
	    }
	  tempo_wait--;
	  next_time += tick_duration;
	}
      
    }

}

