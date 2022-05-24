/***************************************************/
/*                    S3M.C                        */
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
#include "s3m.h"
#include "gus.h"
#include <sys/soundcard.h>
#include <sys/ultrasound.h>



void beattrack_s3m(register track_info_ptr track)
{
  int16 t;

  if (track->effect & S3M_VOL_SLIDE)
  {
    track->volume += ((track->vol_slide & 0xF0) >> 4) -
                     (track->vol_slide & 0x0F);
    if (track->volume < 0) track->volume = 0;
    if (track->volume > 64) track->volume = 64;
  }
  if (track->effect & S3M_PORT_DOWN)
  {
    /* Portamento Down */
    if ((track->period += track->port_down) > 0x6B0)
      track->period = 0x6B0;
    track->pitch = track->finetune_rate / track->period;
  }
  if (track->effect & S3M_PORT_UP)
  {
    /* Portamento Up */
    if ((track->period -= track->port_up) < track->period_limit)
      track->period = track->period_limit;
    track->pitch = track->finetune_rate / track->period;
  }
  if (track->effect & S3M_VIBRATO)
  {
    /* Vibrato */
    track->vibpos += (track->vib_rate) << 2;
    t =  ((uint16)sintable[(track->vibpos >> 2) & 0x1F] *
         (track->vib_depth)) >> 7;
    if (track->vibpos & 0x80) t = -t;
    t += track->period;
    if (t < track->period_limit) t = track->period_limit;
    if (t > 0x6B0) t = 0x6B0;
    track->pitch = track->finetune_rate / t;
  }
  if (track->effect & S3M_ARPEGGIO)
  {
    /* Arpeggio */
    track->pitch = track->arp[track->arpindex++];
    if (track->arpindex == 3) track->arpindex = 0;
  }
  if (track->effect & S3M_PORT_TO)
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
/* if (track->effect & S3M_TREMOLO)
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
  if (track->effect & S3M_RETRIG)
  {
    if (tempo_wait == track->retrig)
      track->position = 0;
  } */
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
    track->have_samp = 0;
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
        track->period_limit = mod.period_limit[samp];
      }

      if (data)
      {
        if ((data < 0x90) && (data >= 0x20) && ((data & 0x0F) <= 0x0B))
        {
          track->step = 12*((data >> 4)-2)+(data & 0x0F);
          period = period_set[track->step];
          if (track->period_limit < period)
          {
            track->pitch =
                track->finetune_rate /
                (track->portto = track->period = period);
	    track->have_samp=1;
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
                   track->effect |= S3M_RETRIG;
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
        case 7:  track->effect |= S3M_PORT_TO;
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
        case 11: if (op_code == 11) track->effect |= S3M_VIBRATO;
        case 4:
                 if (data > 0xF0)
                 {
                   track->vol_slide = (data &= 0x0F);
                   if ( (track->volume -= data) < 0)
                     track->volume = 0;
                   break;
                 }
                 if (((data & 0x0F) == 0x0F) && (data & 0xF0))
                 {
                   track->vol_slide = data & 0xF0;
                   if ( (track->volume += (data >> 4)) > 63)
                     track->volume = 63;
                   break;
                 }
                 track->effect |= S3M_VOL_SLIDE;
                 if (data) track->vol_slide = data;
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
                   if ( (track->period += (data & 0x0F)) > 0x6B0)
                     track->period = 0x6B0;
                   track->pitch =
                        track->finetune_rate / track->period;
                   break;
                 }
                 track->effect |= S3M_PORT_DOWN;
                 if (data) track->port_down = data;
                 break;
        case 6:
#ifdef DEBUG
                 printf("%02X-%02X*port up %02X\n",a,track->samp,data);
#endif
                 if (data > 0xF0)
                 {
                   if ( (track->period -= (data & 0x0F)) < track->period_limit)
                     track->period = track->period_limit;
                   track->pitch =
                       track->finetune_rate / track->period;
                   break;
                 }
                 track->effect |= S3M_PORT_UP;
                 if (data) track->port_up = data;
                 break;
        case 8:
#ifdef DEBUG
                 printf("%02X-%02X*vibrato %02X\n",a,track->samp,data);
#endif
                 track->effect |= S3M_VIBRATO;
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
                 track->effect |= S3M_ARPEGGIO;
                 break;
/*      case 11: printf("tremolo %02X\n",data);
                 track->effect |= S3M_TREMOLO;
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



/**********************************************************
 * now , load the instruments                             *
 **********************************************************/



  for (i=0;i<s3h.n_instr;i++)
  {
    uint16 gus_loop_flags = 0;



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
	  gus_loop_flags |= WAVE_LOOPING;
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

      if (gus_dev != -1)
	{
	  struct patch_info *patch;

	  /* total_mem += len */
	  patch = (struct patch_info *) malloc( sizeof(*patch) + (uint16)data->sample_length[i]);
	  
	  patch->key = GUS_PATCH;
	  patch->device_no = gus_dev;
	  patch->instr_no = i;
	  patch->mode = gus_loop_flags;
	  patch->len  = data->sample_length[i];
	  patch->loop_start = data->repeat_point[i];
	  patch->loop_end = data->repeat_point[i] + data->repeat_length[i];
	  patch->base_note = 261630; /* middle C */
	  patch->base_freq = 8448;
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

    }
  }
  printf("\n");
  fclose(fp);
  data->s3m = 1;
  return (0);
}

