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
#include "main.h"


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

int8 normal_vol_adj[65] =
{
   0,   1,   2,   3,   4,   5,   6,   7,
   8,   9,  10,  11,  12,  13,  14,  15,
  16,  17,  18,  19,  20,  21,  22,  23,
  24,  25,  26,  27,  28,  29,  30,  31,
  32,  33,  34,  35,  36,  37,  38,  39,
  40,  41,  42,  43,  44,  45,  46,  47,
  48,  49,  50,  51,  52,  53,  54,  55,
  56,  57,  58,  59,  60,  61,  62,  63,
  63
};

int8 loud_vol_adj[65] =
{
   0,   0,   1,   2,   2,   3,   3,   4,   
   5,   6,   7,   8,   9,  10,  12,  14,
  16,  18,  20,  22,  24,  26,  28,  30,
  32,  34,  36,  38,  40,  42,  44,  46,
  47,  48,  49,  50,  51,  52,  53,  53,
  54,  55,  55,  56,  56,  57,  57,  58,
  58,  59,  59,  60,  60,  61,  61,  61,
  62,  62,  62,  63,  63,  63,  63,  63,
  63
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
track_info              old_tracks[MAX_TRACKS];
uint32                  mixspeed = 22000;
int16                   mod_done;
uint8                   loop_mod = 1;

union vol_union vol;

void beattrack(register track_info_ptr track)
{
  track->playing_volume = track->volume;
  track->playing_period = track->period;

  if (track->effect & EFF_VOL_SLIDE)
  {
    track->volume += track->vol_slide;
    if (track->volume < 0) track->volume = 0;
    if (track->volume > 64) track->volume = 64;

    track->playing_volume = track->volume;
  } 


  if (track->effect & EFF_PORT_DOWN)
  {
    /* Portamento Down */
    if ((track->period += track->port_down) > track->period_high_limit)
      track->period = track->period_high_limit;
    track->pitch = track->finetune_rate / track->period;

    track->playing_period = track->period;
  }

  if (track->effect & EFF_PORT_UP)
  {
    /* Portamento Up */
    if ((track->period -= track->port_up) < track->period_low_limit)
    {
      if (mod.s3m)
         track->period = track->period_high_limit;
         else
         track->period = track->period_low_limit;
    }
    track->pitch = track->finetune_rate / track->period;

    track->playing_period = track->period;
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
    track->playing_period = track->period;
  }


  if (track->effect & EFF_VIBRATO)
  {
    /* Vibrato */
    track->vibpos += (track->vib_rate) << 2;
    track->playing_period =
      ((uint16)sintable[(track->vibpos >> 2) & 0x1F] *
         (track->vib_depth)) >> 7;
    if (track->vibpos & 0x80) 
      track->playing_period = -track->playing_period;
    track->playing_period += track->period;
    if (track->playing_period < track->period_low_limit) 
      track->playing_period = track->period_low_limit;
    if (track->playing_period > track->period_high_limit) 
      track->playing_period = track->period_high_limit;
    track->pitch = track->finetune_rate / track->playing_period;
  }
  if (track->effect & EFF_ARPEGGIO)
  {
    /* Arpeggio */
    track->pitch = track->finetune_rate / track->arp[track->arpindex];
    track->playing_period = track->arp[track->arpindex++];
    if (track->arpindex >= 3) 
      track->arpindex = 0;
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
    track->note_hit = 1;

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
  param = *(*pattern)++;
  track->effect = 0;

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
    if ((effect != 3) && (effect != 5))
    {
      track->start_period = track->period = period;
      track->pitch = track->finetune_rate / period;
      track->position = 0;
      track->note_hit = 1;
    }
  } 
  if ((effect) || (param))
  {
#ifdef DEBUG
    printf("effect %02X param %02X period %02X track %p\n",
            effect,param,period,track);
#endif
    switch (effect)
    {
      /* Set the three periodtable amounts for each */
      /* half note pitch for arpeggio */
      case 0: for (i=12;i<48;i++)
                 if (track->period >= period_set[i]) break;
              track->arp[0] = period_set[i];
              track->arp[1] = period_set[i+(param & 0x0F)];
              track->arp[2] = period_set[i+((param & 0xF0) >> 4)];
              track->arpindex = 0;
	      track->effect |= EFF_ARPEGGIO;
              break;
      case 1: track->effect |= EFF_PORT_UP;
	      if (param)
                 track->port_up = param;
	      break;
      case 2: track->effect |= EFF_PORT_DOWN;
	      if (param) 
                 track->port_down = param;
	      break;
      /* Sets up portamento to for new note */
      case 3: if (param)
	         track->port_inc = param;
	      track->effect |= EFF_PORT_TO;
              break;
      /* Initialize vibrato effect */
      case 4: if (param & 0x0F)
	           track->vib_depth = param & 0x0F;
              if (param & 0xF0) 
	           track->vib_rate = (param & 0xF0) >> 4;
              if (period)
                   track->vibpos = 0;
	      track->effect |= EFF_VIBRATO;
              break;
      /* Choose and offset starting into the sample */
      case 9: if (!param)
                   param = track->oldsampofs;
              track->oldsampofs = param;
              track->position = ((uint16)param) << 8;
              break;
      case 5:    track->effect |= EFF_PORT_TO;
      case 6:    if (effect == 6)
  	           track->effect |= EFF_VIBRATO;
      case 0x0A: track->vol_slide = ((param & 0xF0) >> 4) - (param & 0x0F);
#ifdef DEBUG
	         printf("vol slide %d param %02X\n",track->vol_slide,param);
#endif
	         track->effect |= EFF_VOL_SLIDE;
	         break;
      /* Jump to a different position */
      case 0x0B: if (!loop_mod) break;
	         order_pos = param;
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
      /* Set song speed */
      case 0x0F: if (param)
                 {
		   set_speed(param);

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

void startplaying(int loud)
{
  uint16 i;
  track_info_ptr track;
  uint32 pitch_const;
  int16 j;
  int8 *vol_adj = loud ? loud_vol_adj : normal_vol_adj;

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
    track->portto = 0;
    track->vibpos = 0;
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
      mod.period_low_limit[i] = 0xE;
      mod.period_high_limit[i] = 0x6B0;
/*
      printf("mod period low limit %d %u %u %u\n",i,mod.period_low_limit[i],
	      min_length,mod.finetune_rate[i]);

      uint32 min_period;
      uint16 min_length;

      if (mod.sample_length[i])
      {
         min_length = mod.sample_length[i];
         if (mod.repeat_length[i] > 2)
            min_length = mod.repeat_length[i];
         min_period = (mod.finetune_rate[i] / min_length)+1;
         if (min_period < 40)
            min_period = 40;
         mod.period_low_limit[i] = min_period;
      }
*/
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
           vol.vol_table16[j] = (vol_adj[(j >> 8)] * ((j-0x80) & 0xFF)); 
     else
     for (j=0;j<16640;j++)
     {
           vol.vol_table16[j] = (vol_adj[(j >> 8)] * ((j-0x80) & 0xFF)) >> 1;
       }
  } else
  {
    if (mod.tracks < 5)
     for (j=0;j<16640;j++)
         vol.vol_table[j] = (vol_adj[(j >> 8)] * (int)((char)j) ) >> 8;
     else
     for (j=0;j<16640;j++)
         vol.vol_table[j] = (vol_adj[(j >> 8)] * (int)((char)j) ) >> 9;
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

int load_mod(char *filename, song_data *data, int8 noprint)
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
  if (!noprint)
  {
    printf("Protracker Module name = \"");
    print_name_nice(data->name,20);
    printf("\"\n");
  }
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


  /********************************************
   *            load instruments              *
   ********************************************/


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
/*
    if (data->repeat_length[i] > data->sample_length[i])
       data->repeat_length[i] = data->sample_length[i];
 */
    if (data->repeat_point[i] > data->sample_length[i])
       data->repeat_point[i] = data->sample_length[i];
    if ((data->repeat_point[i] + data->repeat_length[i]) >
         data->sample_length[i])
      data->repeat_length[i] = data->sample_length[i] - data->repeat_point[i];

    if (!noprint)
    {
      printf("%-2d %05u ",i,data->sample_length[i]);
#ifdef DEBUG
      printf(" %05u %05u ",data->repeat_point[i],data->repeat_length[i]);
#endif
      print_name_nice(mod_v.sample_name,22);
      printf("  ");
      if (i & 0x01) printf("\n");
    }


  }
  if (!noprint)
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


      if ((gus_dev != -1) && data->sample_length[i])
	{
	  struct patch_info *patch;

	  patch = (struct patch_info *) 
	    malloc( sizeof(*patch) + (uint16)data->sample_length[i]);
	  
	  patch->key = GUS_PATCH;
	  patch->device_no = gus_dev;
	  patch->instr_no = i;

	  if (data->repeat_length[i] >= 4)
	    patch->mode = WAVE_LOOPING; 
          else 
            patch->mode = 0;

	  patch->len  = data->sample_length[i];
	  patch->loop_start = data->repeat_point[i];
	  patch->loop_end = data->repeat_point[i] + data->repeat_length[i];
	  patch->base_note = 261630; /* middle C */
	  patch->base_freq = base_freq_table[data->finetune_value[i] & 0xf]; 
	  patch->low_note = 0;
	  patch->high_note = 20000000;
	  patch->volume = 120;
	  patch->panning = 16;

	  /* ok, now copy the data into patch->data */

	  memcpy(patch->data,data->samples[i],data->sample_length[i]);

	  gus_patch_load(patch,i);

	  /* there was some sample volume adjustment stuff here */

	  free(patch);
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
  data->tempo = options.def_tempo;
  data->bpm = options.def_bpm;
  data->s3m = 0;
  return (0);
}




