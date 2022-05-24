/***************************************************/
/* S3m/Mod player by Daniel Marks                  */
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
#include <stdlib.h>
#include <string.h>
#include <bytesex.h>
#include "mod.h"

const char voice_mk[] = "M.K.";
const char voice_mk2[] = "M!K!";
const char voice_mk3[] = "M&K!";
const char voice_flt4[] = "FLT4";
const char voice_flt8[] = "FLT8";
const char voice_8chn[] = "8CHN";
const char voice_6chn[] = "6CHN";

const char *voice_31_list[] =
{
  voice_mk, voice_mk2, voice_mk3, voice_flt4, voice_flt8, voice_8chn, 
  voice_6chn, NULL
};

uint8 sintable[] =
{
   0,25,50,74,98,120,142,162,180,197,212,225,
   236,244,250,254,255,254,250,244,236,225,
   212,197,180,162,142,120,98,74,50,25
};

uint16 period_set[] =
  {
      0x06B0,0x0650,0x05F5,0x05A0,0x054F,0x0503,0x04BB,0x0477,0x0436,0x03FA,0x03C1,0x038B  ,
      0x0358,0x0328,0x02FB,0x02D0,0x02A7,0x0281,0x025D,0x023B,0x021B,0x01FD,0x01E0,0x01C5  ,
      0x01AC,0x0194,0x017D,0x0168,0x0154,0x0141,0x012F,0x011E,0x010E,0x00FE,0x00F0,0x00E3  ,
      0x00D6,0x00CA,0x00BF,0x00B4,0x00AA,0x00A0,0x0097,0x008F,0x0087,0x007F,0x0078,0x0071  ,
      0x006B,0x0065,0x005F,0x005A,0x0055,0x0050,0x004C,0x0047,0x0043,0x0040,0x003C,0x0039  ,
      0x0035,0x0032,0x0030,0x002D,0x002A,0x0028,0x0026,0x0024,0x0022,0x0020,0x001E,0x001C  ,
      0x001B,0x0019,0x0018,0x0016,0x0015,0x0014,0x0013,0x0012,0x0011,0x0010,0x000F,0x000E
  };

uint16 period_set_step[] =
{
    0x0680,0x0622,0x05CA,0x0577,0x0529,0x04DF,0x0499,0x0456,0x0418,0x03DD,0x03A6,0x0371,
    0x0340,0x0311,0x02E5,0x02BB,0x0294,0x026F,0x024C,0x022B,0x020C,0x01EE,0x01D2,0x01B8,
    0x01A0,0x0188,0x0172,0x015E,0x014A,0x0138,0x0126,0x0116,0x0106,0x00F7,0x00E9,0x00DC,
    0x00D0,0x00C4,0x00B9,0x00AF,0x00A5,0x009B,0x0093,0x008B,0x0083,0x007B,0x0074,0x006E,
    0x0068,0x0062,0x005C,0x0057,0x0052,0x004E,0x0049,0x0045,0x0041,0x003E,0x003A,0x0037,
    0x0033,0x0031,0x002E,0x002B,0x0029,0x0027,0x0025,0x0023,0x0021,0x001F,0x001D,0x001B,
    0x001A,0x0018,0x0017,0x0015,0x0014,0x0013,0x0012,0x0011,0x0010,0x000F,0x000E,0x000E
};

song_data               mod;
uint8                   order_pos;
uint8                   tempo;
uint8                   tempo_wait;
uint8                   bpm;
uint8                   row;
uint8                   break_row;
uint16                  bpm_samples;
uint8                  *buf_ptr;
uint16                  buf_len;
uint16                  buf_rep;
pattern_ptr             note;
track_info              tracks[MAX_TRACKS];
uint32                  mixspeed = 22000;
int16                   mod_done;

union
{
  int8                   vol_table[16640];
  int16                  vol_table16[16640];
} vol;

void beattrack(register track_info_ptr track)
{
  int16 t;
  uint8 te = track->effect;
  uint8 param = track->param;

  if (!te)
  {
    if (!param) return;
    /* Arpeggio */
    track->pitch = track->arp[track->arpindex++];
    if (track->arpindex == 3) track->arpindex = 0;
    return;
  }
  if (te == 1)
  {
    /* Portamento Up */
    if ((track->period -= param) < track->period_low_limit)
      track->period = track->period_low_limit;
    track->pitch = track->finetune_rate / track->period;
    return;
  }
  if (te == 2)
  {
    /* Portamento Down */
    if ((track->period += param) > track->period_high_limit)
      track->period = track->period_high_limit;
    track->pitch = track->finetune_rate / track->period;
    return;
  }
  if ((te == 5) || (te == 6) || (te == 10))
  {
    /* Portamento and volume slide,  vibrato and volume slide, or just volume slide */
    track->volume -= ((param & 0x0F) - ((param & 0xF0) >> 4));
    if (track->volume < 0) track->volume = 0;
    if (track->volume > 64) track->volume = 64;
    if (te == 5)    /* For portamento slide */
    {
      te = 3;
      param = track->portparm;
    } else
    if (te == 6)    /* For vibrato slide */
    {
      te = 4;
      param = track->vibparm;
    }
  }
  if (te == 3)
  {
    if (track->portto < track->period)
    {
      if ((track->period += param) > track->portto)
        track->period = track->portto;
    } else if (track->portto > track->period)
    {
      if ((track->period -= param) < track->portto)
        track->period = track->portto;
    } else return;
    track->pitch = track->finetune_rate / track->period;
  }
  if (te == 4)
  {
    /* Vibrato */
    track->vibpos += (param & 0xF0) >> 2;
    t =  ((uint16)sintable[(track->vibpos >> 2) & 0x1F] *
         (param & 0x0F)) >> 7;
    if (track->vibpos & 0x80) t = -t;
    t += track->period;
    if (t < 113) t = 113;
    if (t > 856) t = 856;
    track->pitch = track->finetune_rate / t;
  }
}

void beattrack_s3m(register track_info_ptr track)
{
  int16 t;

  if (track->effect & EFF_VOL_SLIDE)
  {
    track->volume += track->vol_slide;
    if (track->volume < 0) track->volume = 0;
    if (track->volume > 64) track->volume = 64;
  }
  if (track->effect & EFF_PORT_DOWN)
  {
    /* Portamento Down */
    if ((track->period += track->port_down) > track->period_high_limit)
      track->period = track->period_high_limit;
    track->pitch = track->finetune_rate / track->period;
  }
  if (track->effect & EFF_PORT_UP)
  {
    /* Portamento Up */
    if ((track->period -= track->port_up) < track->period_low_limit)
      track->period = track->period_low_limit;
    track->pitch = track->finetune_rate / track->period;
  }
  if (track->effect & EFF_VIBRATO)
  {
    /* Vibrato */
    track->vibpos += (track->vib_rate) << 2;
    t =  ((uint16)sintable[(track->vibpos >> 2) & 0x1F] *
         (track->vib_depth)) >> 7;
    if (track->vibpos & 0x80) t = -t;
    t += track->period;
    if (t < track->period_low_limit) t = track->period_low_limit;
    if (t > track->period_high_limit) t = track->period_high_limit;
    track->pitch = track->finetune_rate / t;
  }
  if (track->effect & EFF_ARPEGGIO)
  {
    /* Arpeggio */
    track->pitch = track->arp[track->arpindex++];
    if (track->arpindex == 3) track->arpindex = 0;
  }
  if (track->effect & EFF_PORT_TO)
  {
    if (track->portto < track->period)
    {
      if ((track->period += track->port_inc) > track->portto)
        track->period = track->portto;
    } else if (track->portto > track->period)
    {
      if ((track->period -= track->port_inc) < track->portto)
        track->period = track->portto;
    }
    track->pitch = track->finetune_rate / track->period;
  }
/* if (track->effect & EFF_TREMOLO)
  {
    track->trempos += (track->trem_rate) >> 2;
    t =  ((uint16)sintable[(track->trempos >> 2) & 0x1F] *
         (track->trem_depth)) >> 7;
    if (track->trempos & 0x80) t = -t;
    t = track->volume;
    if (t < 0) t = 0;
    if (t > 63) t = 63;
    track->volume = t;
  }
  if (track->effect & EFF_RETRIG)
  {
    if (tempo_wait == track->retrig)
      track->position = 0;
  } */
}

void get_track(register track_info_ptr track, pattern_ptr *pattern)
{
  uint8 sample = *(*pattern) & 0xF0;
  uint16 period;
  uint8 effect;
  uint8 param;
  int16 i;

  period = (uint16)((*(*pattern)++) & 0x0F) << 8;
  period |= *(*pattern)++;
  effect = *(*pattern) & 0x0F;
  sample |= (*(*pattern)++ & 0xF0) >> 4;
  track->param = param = *(*pattern)++;

  if (sample)
  {
    sample--;
    track->samp = sample;
    track->volume = mod.volume[sample];
    track->length = mod.sample_length[sample];
    track->repeat = mod.repeat_point[sample];
    track->replen = mod.repeat_length[sample];
    track->finetune_rate = mod.finetune_rate[sample];
    track->samples = mod.samples[sample];
    track->period_low_limit = mod.period_low_limit[sample];
    track->period_high_limit = mod.period_high_limit[sample];
  }
  if (period)
  {
    track->portto = period;
    if (effect != 3)
    {
      track->period = period;
      track->pitch = track->finetune_rate / period;
      track->position = 0;
    }
  } 
  if ((effect) || (param))
  {
    switch (effect)
    {
      /* Set the three periodtable amounts for each half note pitch for arpeggio */
      case 0: for (i=12;i<48;i++)
                 if (track->period >= period_set[i]) break;
              track->arp[0] = track->finetune_rate / 
                                period_set[i];
              track->arp[1] = track->finetune_rate / 
                                period_set[i+(param & 0x0F)];
              track->arp[2] = track->finetune_rate / 
                                period_set[i+((param & 0xF0) >> 4)];
              track->arpindex = 0;
              break;
      /* Sets up portamento to for new note */
      case 3: if (param) track->portparm = param;
              track->effect = 3;                    /* This is probably redundant */
              track->param = param;
              break;
      /* Initialize vibrato effect */
      case 4: if (param & 0x0F) 
                   track->vibparm = (track->vibparm & 0xF0) | (param & 0x0F);
              if (param & 0xF0) 
                   track->vibparm = (track->vibparm & 0x0F) | (param & 0xF0);
              track->effect = 4;
              track->param = track->vibparm;
              if (period) track->vibpos = 0;
              break;
      /* Choose and offset starting into the sample */
      case 9: if (!param) param = track->oldsampofs;
              track->oldsampofs = param;
              track->position = ((uint16)param) << 8;
              break;
      /* Jump to a different position */
      case 0x0B: order_pos = param;
                 row = 64;
                 break;
      /* Set volume of this track */
      case 0x0C: if (param > 64) track->volume = 64;
                   else track->volume = param;
                 break;
      /* Jumps to specified pattern-position in next song position */
      case 0x0D: break_row = ((param & 0xF0) >> 4) * 10 + (param & 0x0F);
                 row = 64;
                 break;
      /* Set song speed */
      case 0x0E: i = param & 0xF0;
                 param &= 0x0F;
                 switch (i)
                 {
                   case 1: track->period += param;
                           if (track->period > track->period_high_limit)
			      track->period = track->period_high_limit;
                           track->pitch = track->finetune_rate / track->period;
                           break;
                   case 2: track->period -= param;
                           if (track->period < track->period_low_limit)
			      track->period = track->period_low_limit;
                           track->pitch = track->finetune_rate / track->period;
                           break;
                 }
                 break;
      case 0x0F: if (param)
                 {
                   if (param < 32)
                   {
                     tempo = param;
                     tempo_wait = param;
                     break;
                   }
                   bpm = param;
                   bpm_samples = mixspeed / ((103 * param) >> 8);
                                          /*  103 */
                 }
                 break;
    }
  }
}

void get_track_s3m(pattern_ptr *pattern)
{
  uint8 op_code;
  register track_info_ptr track;
  uint8 data;
  uint8 samp;
  uint16 period;
  int16 a;

  track = tracks;
  for (a=0;a<mod.tracks;a++)
  {
    track->oldperiod = track->period;
    track->effect = 0;
    track++;
  }
  while (op_code = (*(*pattern)++))
  {
    track = &tracks[a=(op_code & 0x1F)];
    if (op_code & 0x20)
    {
      data = *(*pattern)++;
      samp = *(*pattern)++;
      if (samp)
      {
        samp--;
        track->samp = samp;
        track->volume = mod.volume[samp];
        track->length = mod.sample_length[samp];
        track->repeat = mod.repeat_point[samp];
        track->replen = mod.repeat_length[samp];
        track->samples = mod.samples[samp];
        track->finetune_rate = mod.finetune_rate[samp];
        track->period_low_limit = mod.period_low_limit[samp];
        track->period_high_limit = mod.period_high_limit[samp];
      }
      if (data)
      {
        if ((data < 0x90) && (data >= 0x20) && ((data & 0x0F) <= 0x0B))
        {
          track->step = 12*((data >> 4)-2)+(data & 0x0F);
          period = period_set[track->step];
          if (track->period_low_limit < period)
          {
            track->pitch =
                track->finetune_rate /
                (track->portto = track->period = period);
            track->position = 0;
          }
        }
      }
    }
    if (op_code & 0x40)
    {
      data = *(*pattern)++;
#ifdef DEBUG
      printf("%02X-%02X*volume %02X\n",a,track->samp,data);
#endif
      if (data > 63) data = 63;
      track->volume = data;
    }
    if (op_code & 0x80)
    {
      op_code = *(*pattern)++;
      data = *(*pattern)++;
      switch (op_code)
      {
        /* retrig */
/*      case  0: printf("retrig %02X\n",data);
                 if (data)
                 {
                   track->effect |= EFF_RETRIG;
                   track->retrig = data;
                 }
                 break; */
        /* set tempo */
        case  1:
#ifdef DEBUG
                 printf("%02X-%02X*set tempo %02X\n",a,track->samp,data);
#endif
                 if (data)
                 {
                   if (data < 0x30)
                   {
                     tempo = data;
                     tempo_wait = data;
                     break;
                   }
                   bpm = data;
                   bpm_samples = mixspeed / ((103 * data) >> 8);
                                          /*  103 */
                 }
                 break;
        case 2:
#ifdef DEBUG
                 printf("%02X-%02X*jump pattern %02X\n",a,track->samp,data);
#endif
                 order_pos = data;
                 row = 64;
                 break_row = 0;
                 break;
        case 3:  break_row = 0;
                 row = 64;
                 return;
        case 12:
        case 7:  track->effect |= EFF_PORT_TO;
                 if ((data) && (op_code != 12))
                 {
                   track->portto = track->period;
                   track->pitch = track->finetune_rate /
                                  (track->period = track->oldperiod);
                   track->port_inc = data;
                 }
#ifdef DEBUG
                 printf("%02X-%02X*port to %02X\n",a,track->samp,data);
#endif
                 if (op_code == 7) break;
        case 11: if (op_code == 11) track->effect |= EFF_VIBRATO;
        case 4:  if (data > 0xF0)
                 {
                   track->vol_slide = -(data & 0x0F);
                   if ( (track->volume += track->vol_slide) < 0)
                     track->volume = 0;
                   break;
                 }
                 if (((data & 0x0F) == 0x0F) && (data & 0xF0))
                 {
                   track->vol_slide = (data >> 4);
                   if ( (track->volume += track->vol_slide) > 63)
                     track->volume = 63;
                   break;
                 }
                 track->effect |= EFF_VOL_SLIDE;
		 if (data & 0xF0) track->vol_slide = (data & 0xF0) >> 4;
		 if (data & 0x0F) track->vol_slide = -(data & 0x0F);
#ifdef DEBUG
                 printf("%02X-%02X*volume slide %02X %02X %02X\n",a,track->samp,data,track->vol_slide,track->volume);
#endif
                 break;
        case 5:
#ifdef DEBUG
                 printf("%02X-%02X*port down %02X\n",a,track->samp,data);
#endif
                 if (data > 0xF0)
                 {
                   if ( (track->period += (data & 0x0F)) > 
		        track->period_high_limit)
                     track->period = track->period_high_limit;
                   track->pitch =
                        track->finetune_rate / track->period;
                   break;
                 }
                 track->effect |= EFF_PORT_DOWN;
                 if (data) track->port_down = data;
                 break;
        case 6:
#ifdef DEBUG
                 printf("%02X-%02X*port up %02X\n",a,track->samp,data);
#endif
                 if (data > 0xF0)
                 {
                   if ( (track->period -= (data & 0x0F)) < track->period_low_limit)
                     track->period = track->period_low_limit;
                   track->pitch =
                       track->finetune_rate / track->period;
                   break;
                 }
                 track->effect |= EFF_PORT_UP;
                 if (data) track->port_up = data;
                 break;
        case 8:
#ifdef DEBUG
                 printf("%02X-%02X*vibrato %02X\n",a,track->samp,data);
#endif
                 track->effect |= EFF_VIBRATO;
                 if (data & 0xF0)
                    track->vib_rate = data >> 4;
                 if (data & 0x0F)
                    track->vib_depth = data & 0x0F;
                 if (track->period != track->oldperiod)
                    track->vibpos = 0;
                 break;
        case 10:
#ifdef DEBUG
                 printf("%02X-%02X*arpeggio %02X\n",a,track->samp,data);
#endif
                 for (a=0;a<83;a++)
                   if (track->period >= period_set[a]) break;
                 track->arp[0] = track->finetune_rate / period_set[a];
                 track->arp[1] = track->finetune_rate /
                                        period_set[a+(data & 0x0F)];
                 track->arp[2] = track->finetune_rate /
                                        period_set[a+((data & 0xF0) >> 4)];
                 track->arpindex = 0;
                 track->effect |= EFF_ARPEGGIO;
                 break;
/*      case 11: printf("tremolo %02X\n",data);
                 track->effect |= EFF_TREMOLO;
                 if (data & 0xF0)
                    track->trem_rate = data >> 4;
                 if (data & 0x0F)
                    track->trem_depth = data & 0x0F;
                 if (track->period != track->oldperiod)
                    track->trempos = 0;
                 break; */
        case 15:
#ifdef DEBUG
                 printf("sample offset %02X\n",data);
#endif
                 track->position = ((uint16)data) << 8;
                 break;
        default:
#ifdef DEBUG
                 printf("%02X-%02X*effect %02X data %02X pattern %u row %u\n",a,track->samp,op_code,data,order_pos,row);
#endif
                 break;
      }
    }
  }
}

void updatetracks(void)
{
  track_info_ptr track = tracks;
  int16 count;

  if (--tempo_wait)
  {
    if (mod.s3m)
      for (count=0;count<mod.tracks;count++)
         beattrack_s3m(track++);
      else
      for (count=0;count<mod.tracks;count++)
         beattrack(track++);
    return;
  }
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
  return;
}

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

void startplaying(void)
{
  uint16 i;
  track_info_ptr track;
  uint32 pitch_const;
  int16 j;

  order_pos = 0;
  tempo_wait = tempo = mod.tempo;
  bpm = mod.bpm;
  row = 64;
  break_row = 0;
  bpm_samples = mixspeed / ((24*bpm)/60);
                        /*   24*DEF_BPM  */

  track = tracks;
  for (i=0;i<MAX_TRACKS;i++)
  {
    track->samples = 0;
    track->position = 0;
    track->length = 0;
    track->repeat = 0;
    track->replen = 0;
    track->volume = 0;
    track->error = 0;
    track->period = 0;
    track->pitch = 0;
    track->effect = 0;
    track->param = 0;
    track->portto = 0;
    track->portparm = 0;
    track->vibpos = 0;
    track->vibparm = 0;
    track->oldsampofs = 0;
    track->oldperiod = 1;
    track->arp[0] = 0;
    track->arp[1] = 0;
    track->arp[2] = 0;
    track->arpindex = 0;
    track++;
  }
  buf_ptr = 0;
  buf_len = 0;

  if (mod.s3m)
  {
    for (i=0;i<MAX_SAMPLES;i++)
    {
      mod.finetune_rate[i] =
          (((428l * mod.finetune_value[i]) << 8) / mixspeed);
      mod.period_low_limit[i] = (mod.finetune_rate[i] >> 16)+1;
      mod.period_high_limit[i] = 0x6B0;
    }
  } else
  {
    for (i=0;i<MAX_SAMPLES;i++)
    {
      mod.finetune_rate[i] = (((((uint32)428ul) * ((uint32)MIDCRATE))
	                      << 8) / (uint32)mixspeed);
      mod.period_low_limit[i] = 113;
      mod.period_high_limit[i] = 856;
    }
  }

  if (bit16)
  {
    if (mod.tracks < 5)
     for (j=0;j<16640;j++)
           vol.vol_table16[j] = ((j >> 8) * ((j-0x80) & 0xFF)); 
     else
     for (j=0;j<16640;j++)
     {
           vol.vol_table16[j] = ((j >> 8) * ((j-0x80) & 0xFF)) >> 1;
       }
  } else
  {
    if (mod.tracks < 5)
     for (j=0;j<16640;j++)
         vol.vol_table[j] = ((j >> 8) * (int)((char)j) ) >> 8;
     else
     for (j=0;j<16640;j++)
         vol.vol_table[j] = ((j >> 8) * (int)((char)j) ) >> 9;
  }
}

void dump_mod(song_data *data)
{
  int16 i;

  for (i=0;i<128;i++)
    if (data->patterns[i])
    {
      free(data->patterns[i]);
      data->patterns[i] = NULL;
    }
  for (i=0;i<MAX_SAMPLES;i++)
    if (data->samples[i])
    {
      free(data->samples[i]);
      data->samples[i] = NULL;
    }
}

void print_name_nice(char *string, int len)
{
  while ((len>0) && (*string))
  {
    if ((*string < ' ') || (*string > '~'))
      putchar(' ');
      else putchar(*string);
    string++;
    len--;
  }
  while (len>0) 
  {
    putchar(' ');
    len--;
  }
}

int16 load_s3m(char *filename, song_data *data)
{
  FILE *fp;
  int16 i,j, nopat = 0;
  s3m_header s3h;
  s3m_instr s3i;
  uint16 len;
  uint16 t_offsets[256];
  uint16 t_patts[256];
  uint8 t_instrflags[256];

  for (i=0;i<MAX_SAMPLES;i++)
  {
    data->samples[i] = NULL;
    data->sample_length[i] = 0;
  }
  if (!(fp=fopen(filename,"rb")))
  {
#ifdef DEBUG
    printf("Could not open file '%s'\n",filename);
#endif
    return (1);
  }
  if (fread(&s3h,sizeof(s3m_header),1,fp) != 1)
  {
#ifdef DEBUG
    printf("Could not read s3m header\n");
#endif
    fclose(fp);
    return (1);
  }
  s3h.s3m_magic_1 = little_endian(s3h.s3m_magic_1);
  s3h.npi1 = little_endian(s3h.npi1);
  s3h.seq_len = little_endian(s3h.seq_len);
  s3h.n_instr = little_endian(s3h.n_instr);
  s3h.n_patts = little_endian(s3h.n_patts);
#ifdef DEBUG
  printf("Name: %s / %04X\n",s3h.name,s3h.s3m_magic_1);

  printf("N_Instr: %04X  N_Patts: %04X\n",s3h.n_instr,s3h.n_patts);
  printf("s3m magic_2: %c%c%c%c\n",s3h.s3m_magic_2[0],s3h.s3m_magic_2[1],s3h.s3m_magic_2[2],s3h.s3m_magic_2[3]);
  printf("volume: %02X  tempo: %02X  bpm:  %02X\n",s3h.volume,s3h.tempo,s3h.bpm);
  printf("channel maps: ");
#endif

  data->tracks = 0;
  for (i=0;i<31;i++)
    if (s3h.channel_maps[i] == 0xFF) break;
      else data->tracks++;

#ifdef DEBUG
  printf("num tracks: %d\n",data->tracks);
#endif

#ifdef DEBUG
  for (i=0;i<31;i++) printf("%02X ",s3h.channel_maps[i]);
  printf("\n");
#endif

  if (memcmp(s3h.s3m_magic_2,S3M_MAGIC2,4))
  {
#ifdef DEBUG
    printf("S3m magic numbers not found!\n");
#endif
    fclose(fp);
    return (1);
  }
  data->tempo = s3h.tempo;
  data->bpm = s3h.bpm;

  printf("Screamtracker 3 module name: \"");
  print_name_nice(s3h.name,28);
  printf("\"\n");

  if (fread(data->positions,sizeof(char),s3h.seq_len,fp) != s3h.seq_len)
  {
#ifdef DEBUG
    printf("S3m positions are not there!\n");
#endif
    fclose(fp);
    return (1);
  }

#ifdef DEBUG
  printf("positions: ");
  for (i=0;i<s3h.seq_len;i++)
     printf("%02X ",data->positions[i]);
  printf("\n");
#endif

  for (i=0;i<128;i++)
  {
    if (nopat < data->positions[i])
      nopat = data->positions[i];
    data->patterns[i] = NULL;
  }
  data->song_length_patterns = nopat;
  
  if (fread(t_offsets,sizeof(uint16),s3h.n_instr,fp) != s3h.n_instr)
  {
#ifdef DEBUG
    printf("could not read offsets\n");
#endif
    fclose(fp);
    return (1);
  }

#ifdef DEBUG
  printf("instruments: ");
  for (i=0;i<s3h.n_instr;i++)
     printf("%04X ",t_offsets[i]);
  printf("\n");
#endif

  if (fread(t_patts,sizeof(uint16),s3h.n_patts,fp) != s3h.n_patts)
  {
#ifdef DEBUG
    printf("could not read patterns \n");
#endif
    fclose(fp);
    return (1);
  }

#ifdef DEBUG
  printf("patterns: ");
  for (i=0;i<s3h.n_patts;i++)
     printf("%04X ",t_patts[i]);
  printf("\n");
#endif

  for (i=0;i<128;i++) data->patterns[i] = NULL;

  for (i=0;i<s3h.n_patts;i++)
  {
    if (!t_patts[i])
    {
      if (!(data->patterns[i] = malloc(1)))
      {
#ifdef DEBUG
        printf("Can't allocate a byte!\n");
#endif
        fclose(fp);
        dump_mod(data);
        return (1);
      }
      *data->patterns[i] = 0;
      continue;
    }
    fseek(fp,(((uint32)t_patts[i]) << 4),SEEK_SET);
    if (fread(&len,sizeof(uint16),1,fp) != 1)
    {
#ifdef DEBUG
      printf("Can't read pattern %d\n",i);
#endif
      fclose(fp);
      dump_mod(data);
      return (1);
    }
    len = little_endian(len);
    if (!(data->patterns[i] = malloc(len)))
    {
#ifdef DEBUG
      printf("Can't allocate memory (%d bytes)!\n",len);
#endif
      fclose(fp);
      dump_mod(data);
      return(1);
    }
    if (fread(data->patterns[i],sizeof(char),len,fp) != len)
    {
#ifdef DEBUG
      printf("Can't read pattern data for %d\n",i);
#endif
      fclose (fp);
      dump_mod(data);
      return (1);
    }
#ifdef DEBUG
    printf("Loaded pattern %d with %d bytes\n",i,len);
#endif
  }

  for (i=0;i<s3h.n_instr;i++)
  {
    fseek(fp,(((uint32)t_offsets[i]) << 4),SEEK_SET);
    if (fread(&s3i,sizeof(s3m_instr),1,fp) != 1)
    {
#ifdef DEBUG
      printf("Can't read instrument %d\n",i);
#endif
      fclose(fp);
      dump_mod(data);
      return (1);
    }
    s3i.position = little_endian(s3i.position);
    s3i.size = long_little_endian(s3i.size);
    s3i.rep_start = long_little_endian(s3i.rep_start);
    s3i.rep_end = long_little_endian(s3i.rep_end);
    s3i.volume = little_endian(s3i.volume);
    s3i.period_fine = little_endian(s3i.period_fine);  
    printf("%02d %05u ",i,s3i.size);
    print_name_nice(s3i.comment,28);
    printf("   ");
    if (i & 0x01) printf("\n");
    if (s3i.flag)
    {
      if (!memcmp(s3i.id,S3M_INSTR2,4))
      {
        uint16 rep_len;

        if (s3i.size > 65535l) s3i.size = 65535;
        if (s3i.looped)
        {
          if (s3i.rep_start >= s3i.size)
            s3i.rep_start = s3i.size - 1;
          if (s3i.rep_end >= s3i.size)
            s3i.rep_end = s3i.size - 1;
          if (s3i.rep_end < s3i.rep_start)
            s3i.rep_end = s3i.rep_start;
          rep_len = s3i.rep_end - s3i.rep_start;
#ifdef DEBUG
          if (!rep_len)
          {
             printf("Error looped instrument with no loop!\n");
          }
#endif
        } else rep_len = 0;
        data->sample_length[i] = s3i.size;
        data->repeat_point[i] = s3i.rep_start;
        data->repeat_length[i] = rep_len;
        data->volume[i] = s3i.volume;
        data->finetune_value[i] = s3i.period_fine;

        if (!(data->samples[i] = malloc(s3i.size)))
        {
#ifdef DEBUG
          printf("Can't allocate memory for sample (%d bytes)!\n",s3i.size);
#endif
          fclose(fp);
          dump_mod(data);
          return(1);
        }
        fseek(fp,(((uint32)s3i.position) << 4),SEEK_SET);
        if (fread(data->samples[i],sizeof(char),s3i.size,fp) != s3i.size)
        {
#ifdef DEBUG
          printf("Can't read sample data for %d\n",i);
#endif
          fclose (fp);
          dump_mod(data);
          return (1);
        }
        {
#ifdef NEAR_FAR_PTR
          unsigned int save_ds = _DS;
          register uint8 near *r1 = data->samples[i];
          uint8 near *r2 = r1 + data->sample_length[i];
#else
		  register uint8 *r1 = data->samples[i];
		  uint8 		 *r2 = r1 + data->sample_length[i];
#endif

#ifdef NEAR_FAR_PTR
          _DS = FP_SEG(data->samples[i]);
#endif
           while (r1 < r2) *r1++ -= 0x80;
#ifdef NEAR_FAR_PTR
          _DS = save_ds;
#endif
        }
      }
#ifdef DEBUG
      printf("Loaded sample %d with %u bytes at location %p\n",i,(uint16)s3i.size,data->samples[i]);
      printf("Sample length %u, repeat_point %u, repeat_length %u fine tune %u, volume %u\n",
              (uint16)data->sample_length[i],
              (uint16)data->repeat_point[i],
              (uint16)data->repeat_length[i],
              (uint16)data->finetune_value[i],
              data->volume[i]);
#endif
    }
  }
  printf("\n");
  fclose(fp);
  data->s3m = 1;
  return (0);
}

int load_mod(char *filename, song_data *data)
{
  FILE *fp;
  char **voice_31 = (char **) voice_31_list;
  int i,voices;
  int nopat = 0,len;
  int pattern_len = 1024;
  mod_voice mod_v;
  song_15 song_v;

  char id[5];

  for (i=0;i<MAX_SAMPLES;i++)
  {
    data->samples[i] = NULL;
    data->sample_length[i] = 0;
  }
  if (!(fp=fopen(filename,"rb")))
  {
#ifdef DEBUG
    printf("Could not open file '%s'\n",filename);
#endif
    return (1);
  }
  fseek(fp, 1080, SEEK_SET);
  if (fread((void *)id,sizeof(char),4,fp) != 4)
  {
#ifdef DEBUG
    printf("Could not read file id\n");
#endif
    fclose(fp);
    return (1);
  }
  fseek(fp, 0, SEEK_SET);
  id[4] = 0;
#ifdef DEBUG
  printf("Module ID = %s\n",id);
#endif

  while (*voice_31)
   if (memcmp((void *)*voice_31,(void *)id,4)) voice_31++;
    else break;

  if (fread(data->name,sizeof(char),20,fp) != 20)
  {
#ifdef DEBUG
    printf("Error loading name of mod!\n");
#endif
    fclose(fp);
    return (1);
  }
  data->name[19] = 0;
  printf("Protracker Module name = \"");
  print_name_nice(data->name,20);
  printf("\"\n");
  data->tracks = 4;
  data->track_shift = 4;
  if (*voice_31)
  {
    if (*voice_31 == voice_8chn)
      data->tracks = 8;
    if (*voice_31 == voice_6chn)
      data->tracks = 6;
    voices = 31;
  } else voices = 15;
  pattern_len = ((uint16)data->tracks) << 8;

  for (i=0;i<voices;i++)
  {
    if (fread(&mod_v,sizeof(mod_voice),1,fp) != 1)
    {
#ifdef DEBUG
      printf("Could not load voice #%d\n",i);
#endif
      fclose(fp);
      return (1);
    }
    data->sample_length[i] = big_endian(mod_v.sample_length) << 1;
    data->finetune_value[i] = mod_v.finetune_value;
    data->volume[i] = mod_v.volume;
    data->repeat_point[i] = big_endian(mod_v.repeat_point) << 1;
    data->repeat_length[i] = big_endian(mod_v.repeat_length) << 1;
    if (data->repeat_length[i] > data->sample_length[i])
       data->repeat_length[i] = data->sample_length[i];
    if (data->repeat_point[i] > data->sample_length[i])
       data->repeat_point[i] = data->sample_length[i];
    if ((data->repeat_point[i] + data->repeat_length[i]) >
         data->sample_length[i])
      data->repeat_length[i] = data->sample_length[i] - data->repeat_point[i];
    printf("%-2d %05u ",i,data->sample_length[i]);
#ifdef DEBUG
    printf(" %05u %05u ",data->repeat_point[i],data->repeat_length[i]);
#endif
    print_name_nice(mod_v.sample_name,22);
    printf("  ");
    if (i & 0x01) printf("\n");
  }
  printf("\n");
  if (fread(&song_v,sizeof(song_15),1,fp) != 1)
  {
#ifdef DEBUG
    printf("Could not load song data\n");
#endif
    fclose(fp);
    return (1);
  }
  data->song_length_patterns = song_v.song_length_patterns;
  data->song_repeat_patterns = song_v.song_repeat_patterns;
  for (i=0;i<256;i++) data->positions[i] = song_v.positions[i];
  if (voices != 15) fseek(fp,4,SEEK_CUR);

  if (data->song_repeat_patterns > data->song_length_patterns)
    data->song_repeat_patterns = data->song_length_patterns;
  for (i=0;i<128;i++)
  {
    if (nopat < data->positions[i])
      nopat = data->positions[i];
    data->patterns[i] = NULL;
  }
  for (i=0;i<=nopat;i++)
  {
#ifdef DEBUG
    printf("Loading pattern %d\n",i);
#endif
    data->patterns[i] = (int8*) malloc(pattern_len);
    if (data->patterns[i])
    {
      if (!fread((void *)data->patterns[i],pattern_len,1,fp))
      {
#ifdef DEBUG
        printf("Error reading pattern %d\n",i);
#endif
        fclose(fp);
        dump_mod(data);
        return (1);
      }
    } else
    {
#ifdef DEBUG
      printf("Could not allocate memory for pattern %d\n",i);
#endif
      fclose(fp);
      dump_mod(data);
      return (1);
    }
  }
  for (i=0;i<voices;i++)
  {
    if (data->sample_length[i])
    {
#ifdef DEBUG
      printf("Loading sample %d length %u\n",i,data->sample_length[i]);
#endif
      data->samples[i] = (int8 *) malloc(data->sample_length[i]);
      if (data->samples[i])
      {
        if ((len=fread((void *)data->samples[i],sizeof(char),
            data->sample_length[i],fp)) !=
            data->sample_length[i])
        {
#ifdef DEBUG
          printf("Error reading sample %d %u\n",i,len);
#endif
          fclose(fp);
          dump_mod(data);
          return (1);
        }
      } else
      {
#ifdef DEBUG
        printf("Could not allocate memory for sample %d\n",i);
#endif
        fclose(fp);
        dump_mod(data);
        return (1);
      }
    }
  }
#ifdef DEBUG
  printf("Length of file = %lu\n",ftell(fp));
  fseek(fp,0,SEEK_END);
  printf("Total length = %lu\n",ftell(fp));
#endif
  fclose(fp);
  data->tempo = DEF_TEMPO;
  data->bpm = DEF_BPM;
  data->s3m = 0;
  return (0);
}

