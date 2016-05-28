/*
#include <dos.h>
#include "d:\gods\library\rg_c.lib\base.h"
*/

typedef struct
{
void * trk_amiga_sample_ptr;
U16 trk_amiga_sample_length;
U16 trk_amiga_sample_period;
U16 trk_amiga_sample_volume;
void * trk_amiga_sample_loop_ptr;
U16 trk_amiga_sample_loop_flag;
} TRKAMIGA_STRUCT;

typedef struct
{
U16 trk_tat_stereo;
U16 trk_tat_volume;
U16 trk_tat_panning;
U32 trk_tat_jump;
U32 trk_tat_sent;
U32 trk_tat_freq;
U32 trk_tat_bobbins[5];
} TRKTAT_STRUCT;

typedef struct
{
void * sampleq_start_ptr;
U16 sampleq_word_size;
U16 sampleq_period;
U16 sampleq_volume;
U16 sampleq_stereo;
} SAMPLEQ_STRUCT;

TRKAMIGA_STRUCT * rltrk_amiga_track_ptrs[6];
TRKTAT_STRUCT * rltrk_tat_track_ptrs[6];
SAMPLEQ_STRUCT rltrk_sampleq[16];
U16 rltrk_sampleq_entries;

void rltrk_open_tracker();
void rltrk_close_tracker();
S8 rltrk_get_free_channel();
void rltrk_play_samples();
void rltrk_play_a_sample();
void rltrk_init_new_sample(void *, U16, U16, U16);
void rltrk_clear_free_channels();

extern void rltrk_begin_tracker();
extern void rltrk_open_module(void *);
extern void rltrk_set_master_volume(U16);
extern void rltrk_set_sample_volume(U16);
extern void rltrk_set_track_ptrs(void *, void *);
extern void rltrk_start_sample(U8);
extern void rltrk_end_sample(U8);
extern U16 rltrk_read_master_volume();
extern U16 rltrk_read_sample_volume();
extern void rltrk_close_module();
extern void rltrk_end_tracker();

void rltrk_open_tracker()
{
	rltrk_begin_tracker();
	rltrk_set_track_ptrs(&rltrk_amiga_track_ptrs[0],&rltrk_tat_track_ptrs[0]);
	rltrk_amiga_track_ptrs[4]->trk_amiga_sample_loop_flag=1;   
	rltrk_amiga_track_ptrs[5]->trk_amiga_sample_loop_flag=1;   
}

void rltrk_close_tracker()
{
	rltrk_end_tracker();
}

/* Assumes sample is .AVR format! */

void rltrk_init_new_sample(void * s_ptr, U16 period, U16 volume, U16 stereo)
{
 U16 i;
 U32 k;
 U8 * avr_ptr;
 U32 * long_ptr;

 avr_ptr=(U8 *)s_ptr;
 long_ptr=(U32 *)&avr_ptr[0x1A]; 

 i=rltrk_sampleq_entries;
 if(i<16)
 {
  rltrk_sampleq[i].sampleq_start_ptr=&avr_ptr[0x80];
  k=(*long_ptr)>>1;
  rltrk_sampleq[i].sampleq_word_size=(U16)k;
  rltrk_sampleq[i].sampleq_period=period;
  rltrk_sampleq[i].sampleq_volume=volume;
  rltrk_sampleq[i].sampleq_stereo=stereo;
  rltrk_sampleq_entries++;
 }
}

void rltrk_play_samples()
{
 rltrk_clear_free_channels();
 rltrk_play_a_sample();
 rltrk_play_a_sample();
}

void rltrk_play_a_sample()
{
 S8 i, j;
 if(rltrk_sampleq_entries>0)
 {
  i=rltrk_get_free_channel();
  if(i!=-1)
  {
   rltrk_sampleq_entries--;
   j=rltrk_sampleq_entries;

   rltrk_tat_track_ptrs[i]->trk_tat_stereo=rltrk_sampleq[j].sampleq_stereo;
   rltrk_amiga_track_ptrs[i]->trk_amiga_sample_loop_ptr=rltrk_sampleq[j].sampleq_start_ptr;
   rltrk_amiga_track_ptrs[i]->trk_amiga_sample_ptr=rltrk_sampleq[j].sampleq_start_ptr;
   rltrk_amiga_track_ptrs[i]->trk_amiga_sample_period=rltrk_sampleq[j].sampleq_period;
   rltrk_amiga_track_ptrs[i]->trk_amiga_sample_volume=rltrk_sampleq[j].sampleq_volume;
   rltrk_amiga_track_ptrs[i]->trk_amiga_sample_loop_flag=0;  
   rltrk_amiga_track_ptrs[i]->trk_amiga_sample_length=rltrk_sampleq[j].sampleq_word_size;
   rltrk_start_sample(i);
  }
 }
}

S8 rltrk_get_free_channel()
{
	if (rltrk_amiga_track_ptrs[4]->trk_amiga_sample_loop_flag==1) return(4);
	if (rltrk_amiga_track_ptrs[5]->trk_amiga_sample_loop_flag==1) return(5);
	return(-1);
}

void rltrk_clear_free_channels()
{
	U8 i;

	for(i=4;i<6;i++)
	{
		if(rltrk_amiga_track_ptrs[i]->trk_amiga_sample_loop_flag==1)
		{
			rltrk_amiga_track_ptrs[i]->trk_amiga_sample_volume=0;
			rltrk_end_sample(i);
		}
	}
}
		