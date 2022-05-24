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

#undef DEBUG

#include <sys/soundcard.h>
#include <sys/ultrasound.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <bytesex.h>
#include "mod.h"
#include "gus.h"






void mixtrack_8_mono(track_info_ptr track, sample8_near buffer, uint16 buflen)
{
  register sample8_far sample;
  sample8_far endtr;
  uint16 volume;
  uint8 lopitch;
  uint8 hipitch;
  uint16 error;

  if (track->replen < 3)
  {
    sample = track->samples + track->position;
    endtr = track->samples + track->length;
    volume = ((uint16)track->volume) << 8;
    error = track->error;
    lopitch = track->pitch & 0xFF;
    hipitch = track->pitch >> 8;
    while ((sample < endtr) && (buflen > 0))
    {
      *buffer++ += vol.vol_table[*sample | volume];    
      sample += hipitch + ((error += lopitch) >> 8);
      error &= 0xFF;
      buflen--;
    }
    track->error = error;
    track->position = (uint32)sample - (uint32)track->samples;
  } else
  {
    sample = track->samples + track->position;
    endtr = track->samples + track->replen + track->repeat;
    error = track->error;
    volume = ((uint16)track->volume) << 8;
    lopitch = track->pitch & 0xFF;
    hipitch = track->pitch >> 8;
    while (buflen > 0)
    {
      if (sample > endtr) sample -= track->replen;
      *buffer++ += vol.vol_table[*sample | volume];
      sample += hipitch + ((error += lopitch) >> 8);
      error &= 0xFF;
      buflen--;
    }
    track->error = error;
    track->position = (uint32)sample - (uint32)track->samples;
  }
}

void mixtrack_8_stereo(track_info_ptr track, sample8_near buffer, 
		       uint16 buflen, uint32 channel)
{
  register sample8_far sample;
  sample8_far endtr;
  uint16 volume;
  uint8 lopitch;
  uint8 hipitch;
  uint16 error;

  if (channel) buffer++;

  if (track->replen < 3)
  {
    sample = track->samples + track->position;
    endtr = track->samples + track->length;
    volume = ((uint16)track->volume) << 8;
    error = track->error;
    lopitch = track->pitch & 0xFF;
    hipitch = track->pitch >> 8;
    while ((sample < endtr) && (buflen > 0))
    {
      *buffer++ += vol.vol_table[*sample | volume];
      buffer++;
      sample += hipitch + ((error += lopitch) >> 8);
      error &= 0xFF;
      buflen--;
    }
    track->error = error;
    track->position = (uint32)sample - (uint32)track->samples;
  } else
  {
    sample = track->samples + track->position;
    endtr = track->samples + track->replen + track->repeat;
    error = track->error;
    volume = ((uint16)track->volume) << 8;
    lopitch = track->pitch & 0xFF;
    hipitch = track->pitch >> 8;
    while (buflen > 0)
    {
      if (sample > endtr) sample -= track->replen;
      *buffer++ += vol.vol_table[*sample | volume];
      buffer++;
      sample += hipitch + ((error += lopitch) >> 8);
      error &= 0xFF;
      buflen--;
    }
    track->error = error;
    track->position = (uint32)sample - (uint32)track->samples;
  }
}

void mixtrack_16_mono(track_info_ptr track, sample16_near buffer, 
		      uint16 buflen)
{
  register sample8_far sample;
  sample8_far endtr;
  uint16 volume;
  uint8 lopitch;
  uint8 hipitch;
  uint16 error;

  if (track->replen < 3)
  {
    sample = track->samples + track->position;
    endtr = track->samples + track->length;
    volume = ((uint16)track->volume) << 8;
    error = track->error;
    lopitch = track->pitch & 0xFF;
    hipitch = track->pitch >> 8;
    while ((sample < endtr) && (buflen > 0))
    {
      *buffer++ += vol.vol_table16[*sample | volume];
      sample += hipitch + ((error += lopitch) >> 8);
      error &= 0xFF;
      buflen--;
    }
    track->error = error;
    track->position = (uint32)sample - (uint32)track->samples;
  } else
  {
    sample = track->samples + track->position;
    endtr = track->samples + track->replen + track->repeat;
    error = track->error;
    volume = ((uint16)track->volume) << 8;
    lopitch = track->pitch & 0xFF;
    hipitch = track->pitch >> 8;
    while (buflen > 0)
    {
      if (sample > endtr) sample -= track->replen;
      *buffer++ += vol.vol_table16[*sample | volume];
      sample += hipitch + ((error += lopitch) >> 8);
      error &= 0xFF;
      buflen--;
    }
    track->error = error;
    track->position = (uint32)sample - (uint32)track->samples;
  }
}

void mixtrack_16_stereo(track_info_ptr track, sample16_near buffer, uint16 buflen, uint32 channel)
{
  register sample8_far sample;
  sample8_far endtr;
  uint16 volume;
  uint8 lopitch;
  uint8 hipitch;
  uint16 error;

  if (channel) buffer++;

  if (track->replen < 3)
  {
    sample = track->samples + track->position;
    endtr = track->samples + track->length;
    volume = ((uint16)track->volume) << 8;
    error = track->error;
    lopitch = track->pitch & 0xFF;
    hipitch = track->pitch >> 8;
    while ((sample < endtr) && (buflen > 0))
    {
      *buffer++ += vol.vol_table16[*sample | volume];
      buffer++;
      sample += hipitch + ((error += lopitch) >> 8);
      error &= 0xFF;
      buflen--;
    }
    track->error = error;
    track->position = (uint32)sample - (uint32)track->samples;
  } else
  {
    sample = track->samples + track->position;
    endtr = track->samples + track->replen + track->repeat;
    error = track->error;
    volume = ((uint16)track->volume) << 8;
    lopitch = track->pitch & 0xFF;
    hipitch = track->pitch >> 8;
    while (buflen > 0)
    {
      if (sample > endtr) sample -= track->replen;
      *buffer++ += vol.vol_table16[*sample | volume];
      buffer++;
      sample += hipitch + ((error += lopitch) >> 8);
      error &= 0xFF;
      buflen--;
    }
    track->error = error;
    track->position = (uint32)sample - (uint32)track->samples;
  }
}
