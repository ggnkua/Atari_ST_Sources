/*
 * Driver for the PSC of the Freescale MCF548X configured as AC97 interface
 *
 * Copyright (C) 2009-2011 Didier Mequignon.
 *
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include "config.h"
#include <string.h>
#include <osbind.h>
#include <mint/falcon.h>
#ifdef LWIP
#include "../../include/ramcf68k.h"
#undef Setexc                 
#define Setexc(num, vect) \
   *(unsigned long *)(((num) * 4) + coldfire_vector_base) = (unsigned long)vect
#include "../lwip/net.h"
#include "../freertos/FreeRTOS.h"
#include "../freertos/task.h"
extern unsigned long save_imrh;
#else
#include "../net/net.h"
#endif /* LWIP */
#include "mcf548x.h"

#define USE_DMA
#undef USE_VRA /* not works with DMA because there are a delay between TX and RX */

#include "ac97_codec.h"
#include "ac97_id.h"
#include "mcf548x_ac97.h"

#ifdef USE_DMA
#include "../mcdapi/MCD_dma.h"
#include "../dma_utils/dma_utils.h"
#endif

#undef DEBUG
#undef PERIOD
#define EMUL_DMA_STE

#ifdef SOUND_AC97
#ifdef NETWORK /* for DMA API */

/* ======================================================================== */
/* Structs / Defines                                                        */
/* ======================================================================== */

#define MCF_PSC0_VECTOR                 (64 + 35)
#define MCF_PSC1_VECTOR                 (64 + 34)
#define MCF_PSC2_VECTOR                 (64 + 33)
#define MCF_PSC3_VECTOR                 (64 + 32)

#define MCF_GPT3_VECTOR                 (64 + 59)

#ifdef USE_DMA
#define AC97_INTC_LVL 4
#define AC97_INTC_PRI 6
#else
#define AC97_INTC_LVL 7
#define AC97_INTC_PRI 0
#endif

#define AC97_SLOTS 13
#define AC97_SAMPLES_BY_BUFFER 48
#define AC97_SAMPLES_BY_FIFO 7 /* 8 MAX */

#define AC97_RETRY_WRITE 1000
#define AC97_TIMEOUT_REGISTERS (100000*SYSTEM_CLOCK) /* 200 mS */
#define AC97_TIMEOUT_SHUTDOWN 30000 /* 30 seconds with AC97_SAMPLES_BY_BUFFER at 48 */

#define SNDRV_PCM_RATE_5512		(1<<0)		/* 5512Hz */
#define SNDRV_PCM_RATE_8000		(1<<1)		/* 8000Hz */
#define SNDRV_PCM_RATE_11025		(1<<2)		/* 11025Hz */
#define SNDRV_PCM_RATE_16000		(1<<3)		/* 16000Hz */
#define SNDRV_PCM_RATE_22050		(1<<4)		/* 22050Hz */
#define SNDRV_PCM_RATE_32000		(1<<5)		/* 32000Hz */
#define SNDRV_PCM_RATE_44100		(1<<6)		/* 44100Hz */
#define SNDRV_PCM_RATE_48000		(1<<7)		/* 48000Hz */
#define SNDRV_PCM_RATE_64000		(1<<8)		/* 64000Hz */
#define SNDRV_PCM_RATE_88200		(1<<9)		/* 88200Hz */
#define SNDRV_PCM_RATE_96000		(1<<10)		/* 96000Hz */
#define SNDRV_PCM_RATE_176400		(1<<11)		/* 176400Hz */

#ifdef EMUL_DMA_STE

#define DMA_CONTROL (*(volatile unsigned char *)0xFFFF8901)
#define DMA_START_ADDRESS_HIGH (*(volatile unsigned char *)0xFFFF8903)
#define DMA_START_ADDRESS_MID (*(volatile unsigned char *)0xFFFF8905)
#define DMA_START_ADDRESS_LOW (*(volatile unsigned char *)0xFFFF8907) 
#define DMA_COUNTER_ADDRESS_HIGH (*(volatile unsigned char *)0xFFFF8909)
#define DMA_COUNTER_ADDRESS_MID (*(volatile unsigned char *)0xFFFF890B)
#define DMA_COUNTER_ADDRESS_LOW (*(volatile unsigned char *)0xFFFF890D) 
#define DMA_END_ADDRESS_HIGH (*(volatile unsigned char *)0xFFFF890F)
#define DMA_END_ADDRESS_MID (*(volatile unsigned char *)0xFFFF8911)
#define DMA_END_ADDRESS_LOW (*(volatile unsigned char *)0xFFFF8913) 
#define DMA_MODE_CONTROL (*(volatile unsigned char *)0xFFFF8921) 

#endif /* EMUL_DMA_STE */

#ifdef USE_DMA

#define AC97_DMA_SIZE (4 * AC97_SLOTS * AC97_SAMPLES_BY_BUFFER)
#define AC97_TX_NUM_BD 20 
#define AC97_RX_NUM_BD 20

#define AC97_TX_TIMEOUT (((1000000 * AC97_SAMPLES_BY_BUFFER) / 48000) * (AC97_TX_NUM_BD - 2))
#define GPT_TIMER 3

#define DMA_PSC_RX(x)   ((x == 0) ? DMA_PSC0_RX : ((x == 1) ? DMA_PSC1_RX : ((x == 2) ? DMA_PSC2_RX : DMA_PSC3_RX)))
#define DMA_PSC_TX(x)   ((x == 0) ? DMA_PSC0_TX : ((x == 1) ? DMA_PSC1_TX : ((x == 2) ? DMA_PSC2_TX : DMA_PSC3_TX)))

#define MCF_PSC_RFDR(x) (*(vuint32*)(&__MBAR[0x008660+((x)*0x100)]))
#define MCF_PSC_TFDR(x) (*(vuint32*)(&__MBAR[0x008680+((x)*0x100)]))
#define MCF_PSC_RFDR_ADDR(x) ((void*)(&__MBAR[0x008660+((x)*0x100)]))
#define MCF_PSC_TFDR_ADDR(x) ((void*)(&__MBAR[0x008680+((x)*0x100)]))

#define PSCRX_DMA_PRI 5
#define PSCTX_DMA_PRI 6

#define AC97_TIMER_INTC_LVL 7
#define AC97_TIMER_INTC_PRI 0

#endif /* USE_DMA */

/* Private structure */
struct mcf548x_ac97_priv {
#ifdef PERIOD
	unsigned long time_get_frame;
	unsigned long time_build_frame;
	unsigned long period_get_frame;
	unsigned long period_build_frame;
	unsigned long period_get_frame_min;
	unsigned long period_build_frame_min;
	unsigned long period_get_frame_max;
	unsigned long period_build_frame_max;
	unsigned long previous_get_frame;
	unsigned long previous_build_frame;
#ifdef LWIP
	unsigned long period_tick_count;
	unsigned long period_tick_count_max;
	unsigned long previous_tick_count;
#endif
#endif /* PERIOD */
	unsigned long cnt_rx;
	unsigned long cnt_tx;
	unsigned long cnt_error_fifo_rx;
	unsigned long cnt_error_fifo_tx;
	unsigned short last_error_fifo_rx;
	unsigned short last_error_fifo_tx;
	unsigned long cnt_error_sync;
	unsigned long cnt_error_empty_tx;
	int psc_channel;
	int aclink_stopped;
	int timeout_shutdown;
	int tx_sem;
	int rx_sem;
	int open_play;
	int open_record;
	volatile int ctrl_mode;
	int ctrl_rw;
	int ctrl_address;
	int ctrl_data;
	int status_data;
#ifndef USE_DMA
	unsigned long cnt_rx_frame;
	unsigned long pos_rx_frame;
	unsigned long cnt_tx_frame;
	unsigned long pos_tx_frame;
	unsigned long tx_frame[AC97_SLOTS * AC97_SAMPLES_BY_BUFFER];
	unsigned long rx_frame[AC97_SLOTS * AC97_SAMPLES_BY_BUFFER];
#endif
	int play_record_mode;
	int play_res;
	int record_res;
	volatile int codec_ready;
	long freq_codec;
	long freq_dac;
	long play_frequency;
	long freq_adc;
	long record_frequency;
#ifdef USE_VRA
	int cnt_slot_rx;
	unsigned char slotreq[AC97_SAMPLES_BY_BUFFER];
#endif
	unsigned char incr_offsets_play[AC97_SAMPLES_BY_BUFFER+1];
	unsigned char incr_offsets_record[AC97_SAMPLES_BY_BUFFER+1];
	void *play_samples;
	void *play_start_samples;
	void *play_end_samples;
	void *new_play_start_samples;
	void *new_play_end_samples;
	void *record_samples;
	void *record_start_samples;
	void *record_end_samples;
	void *new_record_start_samples;
	void *new_record_end_samples;
#ifdef EMUL_DMA_STE
	unsigned long dma_start_address;
	unsigned long dma_end_address;
	int dma_control;
	int timer;
#endif
	int cause_inter;
	int	callback_play_to_call;
	int	callback_record_to_call;
	void (*callback_play)();
	void (*callback_record)();
#ifdef USE_DMA
	MCD_bufDesc *txbd;
	MCD_bufDesc *rxbd;
	void *buffer;
	int tx_bd_idx;
	int rx_bd_idx;
#endif
	unsigned long id;	/* identification of codec */
	unsigned short caps;	/* capabilities (register 0) */
	unsigned short ext_id;	/* extended feature identification (register 28) */
	unsigned short powerdown;
	unsigned short imr;
	unsigned int rates[6];	/* see AC97_RATES_* defines */
	int master;
	int mono;
	int tone;
	int ctrl_gene;
	int input_gains[8];
};

extern unsigned char __MBAR[];
extern unsigned char __MCDAPI_START[];
#ifdef USE_DMA
static MCD_bufDesc *Descriptors = (MCD_bufDesc *)(__MBAR+0x17000);
#endif
static struct mcf548x_ac97_priv *Devices[4];
static long old_timer_vector;

extern int asm_set_ipl(int level);
extern void udelay(long usec);
extern void call_timer_a(void);
extern void call_io7_mfp(void);
extern void display_string(char *string);
extern void ltoa(char *buf, long n, unsigned long base);
extern void psc0_ac97_interrupt(void);
extern void psc1_ac97_interrupt(void);
extern void psc2_ac97_interrupt(void);
extern void psc3_ac97_interrupt(void);
extern void timer_ac97_interrupt(void);
#ifdef USE_DMA
extern void timeout_ac97_interrupt(void);
#if (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_MEM_NO_CACHE)
extern int usb_mem_init(void);
extern void *usb_malloc(long amount);
extern int usb_free(void *addr);
#endif
#endif /* USE_DMA */
extern long install_xbra(short vector, void *handler);
extern void *mcf548x_ac97_playback_resample(long play_frequency, int play_res, int num_frames, void *source, long *target);
extern void *mcf548x_ac97_record_resample(long record_frequency, int record_res, int num_samples, void *target, long *source);
#if defined(COLDFIRE) && defined(NETWORK) && defined(LWIP) 
extern void board_printf(const char *fmt, ...);
#endif

static void mcf548x_ac97_warnreset(struct mcf548x_ac97_priv *priv);
static void mcf548x_ac97_hwstop(struct mcf548x_ac97_priv *priv);
static int mcf548x_ac97_hwinit(struct mcf548x_ac97_priv *priv);

static int mcf548x_ac97_swap_record_buffers(struct mcf548x_ac97_priv *priv)
{
	int ret = 0;
	if(priv->play_record_mode & SB_REC_RPT)
	{
		if((priv->new_record_start_samples != NULL)
		 && (priv->new_record_end_samples != NULL))
		{
			priv->record_samples = priv->record_start_samples = priv->new_record_start_samples;
			priv->record_end_samples = priv->new_record_end_samples;
			priv->new_record_start_samples = NULL;
			priv->new_record_end_samples = NULL;
		}
		else // loop
			priv->record_samples = priv->record_start_samples;
		ret = 1; // swap => continue record
	}
	else
	{
		priv->record_samples = NULL;
		priv->play_record_mode &= ~SB_REC_ENA;
	}
	priv->callback_record_to_call = 1;
	return(ret);
}

static int mcf548x_ac97_get_frame(struct mcf548x_ac97_priv *priv, int num_frames)
{
	int i, j;
#ifdef PERIOD
	unsigned long start_time = MCF_SLT_SCNT(1);
#endif
	int ctrl_mode = priv->ctrl_mode;
#ifdef USE_VRA
	unsigned char *ps1 = &priv->slotreq[priv->cnt_slot_rx];
	unsigned char *ps2 = &priv->slotreq[AC97_SAMPLES_BY_BUFFER];
#endif
#ifdef USE_DMA
	unsigned long *status = (unsigned long *)priv->rxbd[priv->rx_bd_idx].destAddr;
#else
	unsigned long pos = priv->pos_rx_frame;
	unsigned long *status = &priv->rx_frame[pos];
	if(num_frames <= 0)
		return(-1);
	pos += ((unsigned long)num_frames * AC97_SLOTS);
	pos %= (AC97_SLOTS * AC97_SAMPLES_BY_BUFFER);
	priv->pos_rx_frame = pos;
#endif
#ifdef PERIOD
	if(priv->previous_get_frame)
	{
		unsigned long period = (priv->previous_get_frame - start_time) / SYSTEM_CLOCK;
		priv->period_get_frame = period;
		if(period < priv->period_get_frame_min)
			priv->period_get_frame_min = period;
		if(period > priv->period_get_frame_max)
			priv->period_get_frame_max = period;
	}
	priv->previous_get_frame = start_time;
#endif /* PERIOD */
	if(!((priv->play_record_mode & SB_REC_ENA) && (priv->record_samples != NULL)))
	{
		unsigned long tag, addr, data;
		for(i = 0; i < num_frames; i++)
		{	
			tag = status[AC97_SLOT_TAG];
			if(!(tag & MCF_PSC_TB_AC97_SOF))
			{
				status += AC97_SLOTS;
				continue;
			}
			addr = status[AC97_SLOT_CMD_ADDR];
			data = status[AC97_SLOT_CMD_DATA];
#ifdef USE_VRA
			*ps1++ = (unsigned char)(addr >> 16);
			if(ps1 >= ps2)
				ps1 = priv->slotreq;
#endif
			if(ctrl_mode && priv->ctrl_rw // read
			 && ((tag >> 29) == 7) // codec ready && Slot #1 && Slot #2
			 && (((addr >> 24) & 0x7f) == priv->ctrl_address))
			{
				priv->status_data = data >> 16;
				ctrl_mode = 0; // OK
			}	
			status += AC97_SLOTS;
		}	
	}
	else /* record */
	{	
		unsigned long tag, addr, data, pcm_left, pcm_right;
		char *cptr = (char *)priv->record_samples;
		short *sptr = (short *)cptr;
		void *end_ptr = priv->record_end_samples;
		char cl = 0, cr = 0;
		short sl = 0, sr = 0;
		int incr = 0, vra = 1;
		int index = (int)(priv->cnt_rx % AC97_SAMPLES_BY_BUFFER);
		if((priv->record_frequency != priv->freq_adc))
		{
			int coeff = priv->freq_adc / AC97_SAMPLES_BY_BUFFER;
			int new_samples_by_buffer = priv->record_frequency / coeff;
			if((priv->record_frequency % coeff) >= (coeff >> 1))
				new_samples_by_buffer++;
			vra = 0;		
			if(new_samples_by_buffer > AC97_SAMPLES_BY_BUFFER)
				incr = new_samples_by_buffer - AC97_SAMPLES_BY_BUFFER; /* required frequency > 48000 Hz => add last sample(s) */
#if defined(USE_DMA) && !defined(USE_VRA) /* try to resample for better quality exceped at the end of the source buffer */
			if((priv->freq_adc == 48000) && (priv->record_frequency < 48000) && num_frames)
			{
				int ok = 0;
				switch(priv->record_res)
				{
					case RECORD_STEREO8:
						if((void *)&cptr[num_frames<<1] >= end_ptr)
							break;
						ok = 1;
				 		break;
					case RECORD_STEREO16:
						if((void *)&sptr[num_frames<<1] >= end_ptr)
							break;
						ok = 1;
						break;
					case RECORD_MONO8:
						if((void *)&cptr[num_frames] >= end_ptr)
							break;
						ok = 1;
						break;
					case RECORD_MONO16:
						if((void *)&sptr[num_frames] >= end_ptr)
							break;
						ok = 1;
						break;
					default:
						break;
				}
				if(ok)
				{
					long *src = (long *)&status[AC97_SLOT_PCM_LEFT];
					int frames_ok = 0;			
					for(i = 0; i < num_frames; i++)
					{
						tag = status[AC97_SLOT_TAG];
						if(!(tag & MCF_PSC_TB_AC97_SOF))
						{
							status += AC97_SLOTS;
							continue;
						}
						addr = status[AC97_SLOT_CMD_ADDR];
						data = status[AC97_SLOT_CMD_DATA];
						pcm_left = status[AC97_SLOT_PCM_LEFT];
						pcm_right = status[AC97_SLOT_PCM_RIGHT];
						if(ctrl_mode && priv->ctrl_rw // read
						 && ((tag >> 29) == 7) // codec ready && Slot #1 && Slot #2
						 && (((addr >> 24) & 0x7f) == priv->ctrl_address))
						{
							priv->status_data = data >> 16;
							ctrl_mode = 0; // OK
						}
						if(((tag >> 27) & 3) == 3) /* input slots valid */
							frames_ok++;
						status += AC97_SLOTS;
					}
					if(num_frames == frames_ok) /* all input slots valid */
						priv->record_samples = mcf548x_ac97_record_resample(priv->record_frequency, priv->record_res, num_frames, priv->record_samples, src);
					priv->cnt_rx += num_frames;
					priv->ctrl_mode = ctrl_mode;
#ifdef PERIOD
					start_time = (start_time - MCF_SLT_SCNT(1)) / SYSTEM_CLOCK;
					if(start_time > priv->time_get_frame)
						priv->time_get_frame = start_time;
#endif
					return(0);
				}
			}
#endif /* defined(USE_DMA) && !defined(USE_VRA) */
		}
		for(i = 0; i < num_frames; i++)
		{	
			tag = status[AC97_SLOT_TAG];
			if(!(tag & MCF_PSC_TB_AC97_SOF))
			{
				status += AC97_SLOTS;
				continue;
			}
			addr = status[AC97_SLOT_CMD_ADDR];
			data = status[AC97_SLOT_CMD_DATA];
			pcm_left = status[AC97_SLOT_PCM_LEFT];
			pcm_right = status[AC97_SLOT_PCM_RIGHT];
#ifdef USE_VRA
			*ps1++ = (unsigned char)(addr >> 16);
			if(ps1 >= ps2)
				ps1 = priv->slotreq;
#endif
			if(ctrl_mode && priv->ctrl_rw // read
			 && ((tag >> 29) == 7) // codec ready && Slot #1 && Slot #2
			 && (((addr >> 24) & 0x7f) == priv->ctrl_address))
			{
				priv->status_data = data >> 16;
				ctrl_mode = 0; // OK
			}
			if(((tag >> 27) & 3) == 3)
			{
				switch(priv->record_res)
				{
					case RECORD_STEREO8:
						if(cptr == NULL)
							break;
						if(vra) // variable rate or 48KHz
						{
							*cptr++ = (char)(pcm_left >> 24);
							*cptr++ = (char)(pcm_right >> 24);
						}
						else
						{
							cl = cptr[0] = (char)(pcm_left >> 24);
							cr = cptr[1] = (char)(pcm_right >> 24);
					  	cptr += priv->incr_offsets_record[index];
					  	if(!index && incr) // required frequency > 48000 Hz => add sample(s)
					  	{
					  		j = incr;
								while(--j > 0)
								{
									*cptr++ = cl;
									*cptr++ = cr;
								  if((void *)cptr >= end_ptr)
								  {
										if(!mcf548x_ac97_swap_record_buffers(priv));
										{
											cptr = NULL;
											break;
										}
										cptr = (char *)priv->record_samples;
										end_ptr = priv->record_end_samples;
									}
								}
					  	}
						}
				  	if((void *)cptr >= end_ptr)
				  	{
							mcf548x_ac97_swap_record_buffers(priv);
							cptr = (char *)priv->record_samples;
							end_ptr = priv->record_end_samples;
						}
					  break;
					case RECORD_STEREO16:
						if(sptr == NULL)
							break;
						if(vra) // variable rate or 48KHz
						{
							*sptr++ = (short)(pcm_left >> 16);
							*sptr++ = (short)(pcm_right >> 16);
						}
						else
						{
							sl = sptr[0] = (short)(pcm_left >> 16);
							sr = sptr[1] = (short)(pcm_right >> 16);
					  	sptr += priv->incr_offsets_record[index];
					  	if(!index && incr) // required frequency > 48000 Hz => add sample(s)
					  	{
								j = incr;
								while(--j > 0)
								{
									*sptr++ = sl;
									*sptr++ = sr;
								  if((void *)sptr >= end_ptr)
								  {
										if(!mcf548x_ac97_swap_record_buffers(priv));
										{
											sptr = NULL;
											break;
										}
										sptr = (short *)priv->record_samples;
										end_ptr = priv->record_end_samples;
									}
								}					  	
					  	}
						}
					  if((void *)sptr >= end_ptr)
					  {
							mcf548x_ac97_swap_record_buffers(priv);
							sptr = (short *)priv->record_samples;
							end_ptr = priv->record_end_samples;
						}
						break;
					case RECORD_MONO8:
						if(cptr == NULL)
							break;
						if(vra) // variable rate or 48KHz
							*cptr++ = (char)(pcm_right >> 24);
						else
						{
							cr = *cptr = (char)(pcm_right >> 24);
					  	cptr += priv->incr_offsets_record[index];
					  	if(!index && incr) // required frequency > 48000 Hz => add sample(s)
					  	{
								j = incr;
								while(--j > 0)
								{
									*cptr++ = cr;
								  if((void *)cptr >= end_ptr)
								  {
										if(!mcf548x_ac97_swap_record_buffers(priv));
										{
											cptr = NULL;
											break;
										}
										cptr = (char *)priv->record_samples;
										end_ptr = priv->record_end_samples;
									}
								}					  	
					  	}
						}
						if((void *)cptr >= end_ptr)
					  {
							mcf548x_ac97_swap_record_buffers(priv);
							cptr = (char *)priv->record_samples;
							end_ptr = priv->record_end_samples;
						}
						break;
					case RECORD_MONO16:
						if(sptr == NULL)
							break;
						if(vra) // variable rate or 48KHz
							*sptr++ = (short)(pcm_right >> 16);
						else
						{
							sr = *sptr = (short)(pcm_right >> 16);
					  	sptr += priv->incr_offsets_record[index];
					  	if(!index && incr) // required frequency > 48000 Hz => add sample(s)
					  	{
								j = incr;
								while(--j > 0)
								{
									*sptr++ = sr;
								  if((void *)sptr >= end_ptr)
								  {
										if(!mcf548x_ac97_swap_record_buffers(priv));
										{
											sptr = NULL;
											break;
										}
										sptr = (short *)priv->record_samples;
										end_ptr = priv->record_end_samples;
									}
								}
					  	}
						}
						if((void *)sptr >= end_ptr)
					  {
							mcf548x_ac97_swap_record_buffers(priv);
							sptr = (short *)priv->record_samples;
							end_ptr = priv->record_end_samples;
						}
						break;
				}
			}
			status += AC97_SLOTS;
			index++;
			if(index >= AC97_SAMPLES_BY_BUFFER)
				index = 0;
		}
		if((priv->record_res == RECORD_MONO16)
		 || (priv->record_res == RECORD_STEREO16))
			priv->record_samples = (void *)sptr;
		else
			priv->record_samples = (void *)cptr;
	}
	priv->cnt_rx += num_frames;
#ifdef USE_VRA
	priv->cnt_slot_rx = (int)(ps1 - priv->slotreq);
#endif
	priv->ctrl_mode = ctrl_mode;
#ifdef PERIOD
	start_time = (start_time - MCF_SLT_SCNT(1)) / SYSTEM_CLOCK;
	if(start_time > priv->time_get_frame)
		priv->time_get_frame = start_time;
#endif
	return(0);
}

static int mcf548x_ac97_swap_play_buffers(struct mcf548x_ac97_priv *priv)
{
	int ret = 0;
	if(priv->play_record_mode & SB_PLA_RPT)
	{
		if((priv->new_play_start_samples != NULL)
		 && (priv->new_play_end_samples != NULL))
		{
			priv->play_samples = priv->play_start_samples = priv->new_play_start_samples;
			priv->play_end_samples = priv->new_play_end_samples;
			priv->new_play_start_samples = NULL;
			priv->new_play_end_samples = NULL;
		}
		else // loop
			priv->play_samples = priv->play_start_samples;
		ret = 1; // swap => continue play
	}
	else
	{
#ifdef EMUL_DMA_STE
		if(priv->play_samples != NULL)
		{
			DMA_COUNTER_ADDRESS_HIGH = (unsigned char)((unsigned long)priv->play_samples >> 16);
			DMA_COUNTER_ADDRESS_MID = (unsigned char)((unsigned long)priv->play_samples >> 8);
			DMA_COUNTER_ADDRESS_LOW = (unsigned char)((unsigned long)priv->play_samples); 
		}
		DMA_CONTROL &= ~SB_PLA_ENA;
#endif
		priv->play_samples = NULL;
		priv->play_record_mode &= ~SB_PLA_ENA;
	}
	priv->callback_play_to_call = 1;
	return(ret);
}

/*
 * Sound data memory layout - samples are all signed values
 *
 * 				(each char = 1 byte, 2 chars = 1 word)
 * 1 16 bit stereo track:	LLRRLLRRLLRRLLRR
 * 1 8 bit stereo track:	LRLRLRLR  
 * 2 16 bit stereo tracks:	L0R0L1R1L0R0L1R1
 *  etc...
 */
	
static int mcf548x_ac97_build_frame(struct mcf548x_ac97_priv *priv, int num_frames)
{
	int i;
	unsigned long tag;
#ifdef PERIOD
	unsigned long start_time = MCF_SLT_SCNT(1);
#endif
	int ctrl_mode = priv->ctrl_mode;
	unsigned long cnt_tx = priv->cnt_tx;
#ifdef USE_DMA
	unsigned long *cmd;
	if(num_frames < 0)
		cmd = (unsigned long *)priv->txbd[priv->tx_bd_idx].srcAddr;
	else /* index */
		cmd = (unsigned long *)priv->txbd[num_frames].srcAddr;
	num_frames = AC97_SAMPLES_BY_BUFFER;
#else
	unsigned long pos = priv->pos_tx_frame;
	unsigned long *cmd = &priv->tx_frame[pos];
	if(num_frames <= 0)
		return(-1);
#endif /* USE_DMA */
#ifdef PERIOD
	if(priv->previous_build_frame)
	{
		unsigned long period = (priv->previous_build_frame - start_time) / SYSTEM_CLOCK;
		priv->period_build_frame = period;
		if(period < priv->period_build_frame_min)
			priv->period_build_frame_min = period;
		if(period > priv->period_build_frame_max)
			priv->period_build_frame_max = period;
	}
	priv->previous_build_frame = start_time;
#endif /* PERIOD */
	if(!((priv->play_record_mode & SB_PLA_ENA) && (priv->play_samples != NULL)))
	{
		for(i = 0; i < num_frames; i++)
		{
			tag = MCF_PSC_TB_AC97_TB(1<<19) | MCF_PSC_TB_AC97_SOF; /* 1st slot is 16 bits length */
			cnt_tx++;
			if(ctrl_mode && (cnt_tx & 1))
			{
				if(priv->ctrl_rw) /* read */
				{
					/* Tag - Slot #0 */
					cmd[AC97_SLOT_TAG] = MCF_PSC_TB_AC97_TB(1<<18) | tag;
					/* Control Address - Slot #1 */
					cmd[AC97_SLOT_CMD_ADDR] = MCF_PSC_TB_AC97_TB((1<<19) | ((priv->ctrl_address & 0x7f) << 12));
					/* Control data - Slot #2 */
					cmd[AC97_SLOT_CMD_DATA] = MCF_PSC_TB_AC97_TB(0);
				}
				else /* write */
				{
					/* Tag - Slot #0 */
					cmd[AC97_SLOT_TAG] = MCF_PSC_TB_AC97_TB(3<<17) | tag;
					/* Control Address - Slot #1 */
					cmd[AC97_SLOT_CMD_ADDR] = MCF_PSC_TB_AC97_TB((priv->ctrl_address & 0x7f) << 12);
					/* Control data - Slot #2 */
					cmd[AC97_SLOT_CMD_DATA] = MCF_PSC_TB_AC97_TB(priv->ctrl_data << 4);
					priv->ctrl_rw = 1; /* read after write for get an ack */
				}
			}
			else
			{
				/* Tag - Slot #0 */
				cmd[AC97_SLOT_TAG] = tag;
				/* Control Address - Slot #1 */
				cmd[AC97_SLOT_CMD_ADDR] = 0;
				/* Control data - Slot #2 */
				cmd[AC97_SLOT_CMD_DATA] = 0;
			}
			cmd[AC97_SLOT_PCM_RIGHT] = 0;
			cmd[AC97_SLOT_PCM_LEFT] = 0;
/*
			cmd[AC97_SLOT_MODEM_LINE1] = 0;
			cmd[AC97_SLOT_PCM_CENTER] = 0;
			cmd[AC97_SLOT_PCM_SLEFT] = 0;
			cmd[AC97_SLOT_PCM_SRIGHT] = 0;
			cmd[AC97_SLOT_LFE] = 0;
			cmd[AC97_SLOT_MODEM_LINE2] = 0;
			cmd[AC97_SLOT_HANDSET] = 0;
			cmd[AC97_SLOT_MODEM_GPIO] =	0;
*/
#ifndef USE_DMA
		  pos += AC97_SLOTS;
		  cmd += AC97_SLOTS;
		  if(pos >= (AC97_SLOTS * AC97_SAMPLES_BY_BUFFER))
		  {
				pos = 0;
				cmd = priv->tx_frame;
			}
#else /* USE_DMA */
			cmd += AC97_SLOTS;	
#endif /* USE_DMA */
		}
	}
	else /* play */
	{
		char *cptr = (char *)priv->play_samples;
		short *sptr = (short *)cptr;
		void *end_ptr = priv->play_end_samples;
		int vra = 1, incr = 0;
		int index = (int)(cnt_tx % AC97_SAMPLES_BY_BUFFER);
		if(priv->play_frequency != priv->freq_dac)
		{
			int coeff = priv->freq_dac / AC97_SAMPLES_BY_BUFFER;
			int new_samples_by_buffer = priv->play_frequency / coeff;
			if((priv->play_frequency % coeff) >= (coeff >> 1))
				new_samples_by_buffer++;
			vra = 0;		
			if(new_samples_by_buffer > AC97_SAMPLES_BY_BUFFER)
				incr = new_samples_by_buffer - AC97_SAMPLES_BY_BUFFER; /* required frequency > 48000 Hz => jump last sample(s) */
#if defined(USE_DMA) && !defined(USE_VRA) /* try to resample for better quality exceped at the end of the source buffer */
			if((priv->freq_dac == 48000) && (priv->play_frequency < 48000) && num_frames)
			{
				int ok = 0;
				switch(priv->play_res)
				{
					case STEREO8:
						if((void *)&cptr[num_frames<<1] >= end_ptr)
							break;
						ok = 1;
				 		break;
					case STEREO16:
						if((void *)&sptr[num_frames<<1] >= end_ptr)
							break;
						ok = 1;
						break;
					case MONO8:
						if((void *)&cptr[num_frames] >= end_ptr)
							break;
						ok = 1;
						break;
					case MONO16:
						if((void *)&sptr[num_frames] >= end_ptr)
							break;
						ok = 1;
						break;
					default:
						break;
				}
				if(ok)
				{
					priv->play_samples = mcf548x_ac97_playback_resample(priv->play_frequency, priv->play_res, num_frames, priv->play_samples, (long *)&cmd[AC97_SLOT_PCM_LEFT]);
					for(i = 0; i < num_frames; i++)
					{
						tag = MCF_PSC_TB_AC97_TB(1<<19) | MCF_PSC_TB_AC97_TB(3<<15) | MCF_PSC_TB_AC97_SOF; /* 1st slot is 16 bits length */
						cnt_tx++;
						if(ctrl_mode && (cnt_tx & 1))
						{
							if(priv->ctrl_rw) /* read */
							{
								/* Tag - Slot #0 */
								cmd[AC97_SLOT_TAG] = MCF_PSC_TB_AC97_TB(1<<18) | tag;
								/* Control Address - Slot #1 */
								cmd[AC97_SLOT_CMD_ADDR] = MCF_PSC_TB_AC97_TB((1<<19) | ((priv->ctrl_address & 0x7f) << 12));
								/* Control data - Slot #2 */
								cmd[AC97_SLOT_CMD_DATA] = MCF_PSC_TB_AC97_TB(0);
							}
							else /* write */
							{
								/* Tag - Slot #0 */
								cmd[AC97_SLOT_TAG] = MCF_PSC_TB_AC97_TB(3<<17) | tag;
								/* Control Address - Slot #1 */
								cmd[AC97_SLOT_CMD_ADDR] = MCF_PSC_TB_AC97_TB((priv->ctrl_address & 0x7f) << 12);
								/* Control data - Slot #2 */
								cmd[AC97_SLOT_CMD_DATA] = MCF_PSC_TB_AC97_TB(priv->ctrl_data << 4);
								priv->ctrl_rw = 1; /* read after write for get an ack */
							}
						}
						else
						{
							/* Tag - Slot #0 */
							cmd[AC97_SLOT_TAG] = tag;
							/* Control Address - Slot #1 */
							cmd[AC97_SLOT_CMD_ADDR] = 0;
							/* Control data - Slot #2 */
							cmd[AC97_SLOT_CMD_DATA] = 0;
						}
						cmd += AC97_SLOTS;	
					}
					priv->cnt_tx = cnt_tx;
#ifdef EMUL_DMA_STE
					if(priv->play_samples != NULL)
					{
						DMA_COUNTER_ADDRESS_HIGH = (unsigned char)((unsigned long)priv->play_samples >> 16);
						DMA_COUNTER_ADDRESS_MID = (unsigned char)((unsigned long)priv->play_samples >> 8);
						DMA_COUNTER_ADDRESS_LOW = (unsigned char)((unsigned long)priv->play_samples);
					}
#endif
#ifdef PERIOD
					start_time = (start_time - MCF_SLT_SCNT(1)) / SYSTEM_CLOCK;
					if(start_time > priv->time_build_frame)
						priv->time_build_frame = start_time;
#endif
					return(0);
				}
			}
#endif /* defined(USE_DMA) && !defined(USE_VRA) */
		}
		for(i = 0; i < num_frames; i++)
		{
#ifdef USE_VRA
			int valid = 0;
			tag = MCF_PSC_TB_AC97_TB(1<<19) | MCF_PSC_TB_AC97_SOF; /* 1st slot is 16 bits length */
			if(vra)
			{
				if(!(priv->slotreq[index] & 0xc0)) /* PCM left/right channel */
				{
					tag |=  MCF_PSC_TB_AC97_TB(3<<15);
					valid = 1;
				}
			}
			else /* variable rate impossible */
			{
				tag |= MCF_PSC_TB_AC97_TB(3<<15);
				valid = 1;
			}
#else /* !USE_VRA */
			tag = MCF_PSC_TB_AC97_TB(1<<19) | MCF_PSC_TB_AC97_TB(3<<15) | MCF_PSC_TB_AC97_SOF; /* 1st slot is 16 bits length */
#endif
			cnt_tx++;
			if(ctrl_mode && (cnt_tx & 1))
			{
				if(priv->ctrl_rw) /* read */
				{
					/* Tag - Slot #0 */
					cmd[AC97_SLOT_TAG] = MCF_PSC_TB_AC97_TB(1<<18) | tag;
					/* Control Address - Slot #1 */
					cmd[AC97_SLOT_CMD_ADDR] = MCF_PSC_TB_AC97_TB((1<<19) | ((priv->ctrl_address & 0x7f) << 12));
					/* Control data - Slot #2 */
					cmd[AC97_SLOT_CMD_DATA] = MCF_PSC_TB_AC97_TB(0);
				}
				else /* write */
				{
					/* Tag - Slot #0 */
					cmd[AC97_SLOT_TAG] = MCF_PSC_TB_AC97_TB(3<<17) | tag;
					/* Control Address - Slot #1 */
					cmd[AC97_SLOT_CMD_ADDR] = MCF_PSC_TB_AC97_TB((priv->ctrl_address & 0x7f) << 12);
					/* Control data - Slot #2 */
					cmd[AC97_SLOT_CMD_DATA] = MCF_PSC_TB_AC97_TB(priv->ctrl_data << 4);
					priv->ctrl_rw = 1; /* read after write for get an ack */
				}
			}
			else
			{
				/* Tag - Slot #0 */
				cmd[AC97_SLOT_TAG] = tag;
				/* Control Address - Slot #1 */
				cmd[AC97_SLOT_CMD_ADDR] = 0;
				/* Control data - Slot #2 */
				cmd[AC97_SLOT_CMD_DATA] = 0;
			}
			if(vra) /* variable rate or 48KHz */
			{
#ifdef USE_VRA
				if(valid)
				{
#endif
					unsigned long val;
					switch(priv->play_res)
					{
						case STEREO8:
							if(cptr == NULL)
							{
								cmd[AC97_SLOT_PCM_LEFT] = 0;
								cmd[AC97_SLOT_PCM_RIGHT] = 0;
								break;
							}
						  cmd[AC97_SLOT_PCM_LEFT] = MCF_PSC_TB_AC97_TB((long)*cptr++ << 12);
						  cmd[AC97_SLOT_PCM_RIGHT] = MCF_PSC_TB_AC97_TB((long)*cptr++ << 12);
							if((void *)cptr >= end_ptr)
							{
								mcf548x_ac97_swap_play_buffers(priv);
								cptr = (char *)priv->play_samples;
								end_ptr = priv->play_end_samples;
							}
					 		break;
						case STEREO16:
							if(sptr == NULL)
							{
								cmd[AC97_SLOT_PCM_LEFT] = 0;
								cmd[AC97_SLOT_PCM_RIGHT] = 0;
								break;
							}
					  	cmd[AC97_SLOT_PCM_LEFT] = MCF_PSC_TB_AC97_TB((long)*sptr++ << 4);
					  	cmd[AC97_SLOT_PCM_RIGHT] = MCF_PSC_TB_AC97_TB((long)*sptr++ << 4);
							if((void *)sptr >= end_ptr)
							{
								mcf548x_ac97_swap_play_buffers(priv);
								sptr = (short *)priv->play_samples;
								end_ptr = priv->play_end_samples;
							}
							break;
						case MONO8:
							if(cptr == NULL)
							{
								cmd[AC97_SLOT_PCM_LEFT] = 0;
								cmd[AC97_SLOT_PCM_RIGHT] = 0;
								break;
							}
							val = MCF_PSC_TB_AC97_TB((long)*cptr++ << 12);
						  cmd[AC97_SLOT_PCM_LEFT] = val;
						  cmd[AC97_SLOT_PCM_RIGHT] = val;
							if((void *)cptr >= end_ptr)
							{
								mcf548x_ac97_swap_play_buffers(priv);
								cptr = (char *)priv->play_samples;
								end_ptr = priv->play_end_samples;
							}
							break;
						case MONO16:
							if(sptr == NULL)
							{
								cmd[AC97_SLOT_PCM_LEFT] = 0;
								cmd[AC97_SLOT_PCM_RIGHT] = 0;
								break;
							}
							val = MCF_PSC_TB_AC97_TB((long)*sptr++ << 4);
						  cmd[AC97_SLOT_PCM_LEFT] = val;
						  cmd[AC97_SLOT_PCM_RIGHT] = val;
							if((void *)sptr >= end_ptr)
							{
								mcf548x_ac97_swap_play_buffers(priv);
								sptr = (short *)priv->play_samples;
								end_ptr = priv->play_end_samples;
							}
							break;
						default:
							cmd[AC97_SLOT_PCM_LEFT] = 0;
							cmd[AC97_SLOT_PCM_RIGHT] = 0;
							break;
					}
#ifdef USE_VRA
				}
				else /* !valid */
				{
					cmd[AC97_SLOT_PCM_RIGHT] = 0;
					cmd[AC97_SLOT_PCM_LEFT] = 0;
				}
#endif
			}
			else /* variable rate impossible */
			{
#ifdef USE_VRA
				if(valid)
				{
#endif
					unsigned long val;
					switch(priv->play_res)
					{
						case STEREO8:
							if(cptr == NULL)
							{
								cmd[AC97_SLOT_PCM_LEFT] = 0;
								cmd[AC97_SLOT_PCM_RIGHT] = 0;
								break;
							}
						  cmd[AC97_SLOT_PCM_LEFT] = MCF_PSC_TB_AC97_TB((long)cptr[0] << 12);
						  cmd[AC97_SLOT_PCM_RIGHT] = MCF_PSC_TB_AC97_TB((long)cptr[1] << 12);
							cptr += priv->incr_offsets_play[index];
						  if((void *)cptr >= end_ptr)
						  {
								if(!mcf548x_ac97_swap_play_buffers(priv))
								{
									cptr = NULL;
									break;
								}			
								cptr = (char *)priv->play_samples;
								end_ptr = priv->play_end_samples;
							}
							if(!index && incr)
							{
						   	cptr = &cptr[incr<<1];
								if((void *)cptr >= end_ptr)
								{
									mcf548x_ac97_swap_play_buffers(priv);
									cptr = (char *)priv->play_samples;
									end_ptr = priv->play_end_samples;
								}
		 	 				}
					 		break;
						case STEREO16:
							if(sptr == NULL)
							{
								cmd[AC97_SLOT_PCM_LEFT] = 0;
								cmd[AC97_SLOT_PCM_RIGHT] = 0;
								break;
							}
							cmd[AC97_SLOT_PCM_LEFT] = MCF_PSC_TB_AC97_TB((long)sptr[0] << 4);
						 	cmd[AC97_SLOT_PCM_RIGHT] = MCF_PSC_TB_AC97_TB((long)sptr[1] << 4);
							sptr += priv->incr_offsets_play[index];
							if((void *)sptr >= end_ptr)
							{
								if(!mcf548x_ac97_swap_play_buffers(priv))
								{
									sptr = NULL;
									break;
								}			
								sptr = (short *)priv->play_samples;
								end_ptr = priv->play_end_samples;			
							}
							if(!index && incr)
							{
						    sptr = &sptr[incr<<1];
 								if((void *)sptr >= end_ptr)
								{
									mcf548x_ac97_swap_play_buffers(priv);
									sptr = (short *)priv->play_samples;
									end_ptr = priv->play_end_samples;			
								}
							}
							break;
						case MONO8:
							if(cptr == NULL)
							{
								cmd[AC97_SLOT_PCM_LEFT] = 0;
								cmd[AC97_SLOT_PCM_RIGHT] = 0;
								break;
							}
							val = MCF_PSC_TB_AC97_TB((long)cptr[0] << 12);
							cmd[AC97_SLOT_PCM_LEFT] = val;
 							cmd[AC97_SLOT_PCM_RIGHT] = val;
							cptr += priv->incr_offsets_play[index];
						  if((void *)cptr >= end_ptr)
						  {
								if(!mcf548x_ac97_swap_play_buffers(priv))
								{
									cptr = NULL;
									break;
								}			
								cptr = (char *)priv->play_samples;
								end_ptr = priv->play_end_samples;
							}
							if(!index && incr)
							{
						    cptr = &cptr[incr];
								if((void *)cptr >= end_ptr)
								{
									mcf548x_ac97_swap_play_buffers(priv);
									cptr = (char *)priv->play_samples;
									end_ptr = priv->play_end_samples;
								}
							}
							break;
						case MONO16:
							if(sptr == NULL)
							{
								cmd[AC97_SLOT_PCM_LEFT] = 0;
								cmd[AC97_SLOT_PCM_RIGHT] = 0;
								break;
							}
							val = MCF_PSC_TB_AC97_TB((long)sptr[0] << 4);
							cmd[AC97_SLOT_PCM_LEFT] = val;
 							cmd[AC97_SLOT_PCM_RIGHT] = val;
							sptr += priv->incr_offsets_play[index];
						  if((void *)sptr >= end_ptr)
						  {
								if(!mcf548x_ac97_swap_play_buffers(priv))
								{
									sptr = NULL;
									break;
								}							
								sptr = (short *)priv->play_samples;
								end_ptr = priv->play_end_samples;
							}
							if(!index && incr)
							{
						    sptr = &sptr[incr];
								if((void *)sptr >= end_ptr)
								{
									mcf548x_ac97_swap_play_buffers(priv);
									sptr = (short *)priv->play_samples;
									end_ptr = priv->play_end_samples;
								}
							}
							break;
						default:
							cmd[AC97_SLOT_PCM_LEFT] = 0;
							cmd[AC97_SLOT_PCM_RIGHT] = 0;
							break;
					}
#ifdef USE_VRA
				}
				else /* !valid */
				{
					cmd[AC97_SLOT_PCM_RIGHT] = 0;
					cmd[AC97_SLOT_PCM_LEFT] = 0;
				}
#endif
			}
/*
			cmd[AC97_SLOT_MODEM_LINE1] = 0;
			cmd[AC97_SLOT_PCM_CENTER] = 0;
			cmd[AC97_SLOT_PCM_SLEFT] = 0;
			cmd[AC97_SLOT_PCM_SRIGHT] = 0;
			cmd[AC97_SLOT_LFE] = 0;
			cmd[AC97_SLOT_MODEM_LINE2] = 0;
			cmd[AC97_SLOT_HANDSET] = 0;
			cmd[AC97_SLOT_MODEM_GPIO] =	0;
*/
#ifndef USE_DMA
		  pos += AC97_SLOTS;
		  cmd += AC97_SLOTS;
		  if(pos >= (AC97_SLOTS * AC97_SAMPLES_BY_BUFFER))
		  {
				pos = 0;
				cmd = priv->tx_frame;
			}
#else /* USE_DMA */
			cmd += AC97_SLOTS;	
#endif /* USE_DMA */
			index++;
			if(index >= AC97_SAMPLES_BY_BUFFER)
				index = 0;
		}
		if(priv->play_res == STEREO16)
			priv->play_samples = (void *)sptr;
		else
			priv->play_samples = (void *)cptr;
#ifdef EMUL_DMA_STE
		if(priv->play_samples != NULL)
		{
			DMA_COUNTER_ADDRESS_HIGH = (unsigned char)((unsigned long)priv->play_samples >> 16);
			DMA_COUNTER_ADDRESS_MID = (unsigned char)((unsigned long)priv->play_samples >> 8);
			DMA_COUNTER_ADDRESS_LOW = (unsigned char)((unsigned long)priv->play_samples);
		}
#endif
	}
	priv->cnt_tx = cnt_tx;
#ifndef USE_DMA
	priv->pos_tx_frame = pos;
#endif
#ifdef PERIOD
	start_time = (start_time - MCF_SLT_SCNT(1)) / SYSTEM_CLOCK;
	if(start_time > priv->time_build_frame)
		priv->time_build_frame = start_time;
#endif
	return(0);
}
 
#ifdef USE_DMA

static int mcf548x_ac97_semaphore(int *addr)
{
  register int ret __asm__("d0");
  asm volatile (
		" move.l %1,A0\n\t"
		" bset #7,(A0)\n\t"
		" sne.b D0\n\t"
		" extb.l D0" : "=d" (ret) : "d" (addr) : "a0", "memory", "cc" );
  return(ret);
}

static void mcf548x_ac97_rx_frame(int channel)
{
	struct mcf548x_ac97_priv *priv = Devices[channel];
	if(priv == NULL)
		return;
	if(!mcf548x_ac97_semaphore(&priv->rx_sem))
	{
		int dma_channel = dma_get_channel(DMA_PSC_RX(channel));
		MCD_bufDesc *ptdesc = &priv->rxbd[priv->rx_bd_idx];
		MCD_XferProg progRep;
		if((dma_channel != -1) && (MCD_XferProgrQuery(dma_channel, &progRep) == MCD_OK))
		{
#if 0 // #ifdef DEBUG
			char buf[10];
			display_string("mcf548x_ac97_rx_frame bytes: ");
			ltoa(buf, (long)progRep.dmaSize, 10);
			display_string(buf);
			display_string(", addr: 0x");
			ltoa(buf, (long)progRep.lastDestAddr, 16);
			display_string(buf);
			display_string("\r\n");
#endif /* DEBUG */
			/* progRep.currBufDesc seems bad */
 			/* Check to see if the ring of BDs is full */
			while(!(ptdesc->flags & MCD_BUF_READY))
			{
				mcf548x_ac97_get_frame(priv, AC97_SAMPLES_BY_BUFFER);
				priv->codec_ready = 1;
				/* increment the circular index */
				priv->rx_bd_idx = (priv->rx_bd_idx + 1) % AC97_RX_NUM_BD;
				/* Re-initialize the buffer descriptor */
				ptdesc->flags |= MCD_BUF_READY;
				ptdesc = ptdesc->next;
			}
		}
		priv->rx_sem = 0;
	}
}

static void mcf548x_psc0_rx_frame(void)
{
  mcf548x_ac97_rx_frame(0);
}

static void mcf548x_psc1_rx_frame(void)
{
  mcf548x_ac97_rx_frame(1);
}

static void mcf548x_psc2_rx_frame(void)
{
  mcf548x_ac97_rx_frame(2);
}

static void mcf548x_psc3_rx_frame(void)
{
  mcf548x_ac97_rx_frame(3);
}

static int mcf548x_ac97_rx_start(struct mcf548x_ac97_priv *priv)
{
	unsigned long initiator;
	int dma_channel;
	int psc_channel = priv->psc_channel;
#ifdef DEBUG
	char buf[10];
	display_string("mcf548x_ac97_rx_start channel: ");
	ltoa(buf, (long)psc_channel, 10);
	display_string(buf);
	display_string(", rxbd: 0x");
	ltoa(buf, (long)priv->rxbd, 16);
	display_string(buf);
	display_string("\r\n");
#endif
	/* Make the initiator assignment */
	dma_set_initiator(DMA_PSC_RX(psc_channel));
	/* Grab the initiator number */
	initiator = dma_get_initiator(DMA_PSC_RX(psc_channel));
	/* Determine the DMA channel running the task for the selected PSC */
	dma_channel = dma_set_channel(DMA_PSC_RX(psc_channel), (psc_channel == 0) ? mcf548x_psc0_rx_frame : ((psc_channel == 1) ? mcf548x_psc1_rx_frame : ((psc_channel == 2) ? mcf548x_psc2_rx_frame : mcf548x_psc3_rx_frame)));
	/* Start the Rx DMA task */
	return((MCD_startDma(dma_channel, (char *)priv->rxbd, 0, NULL, 4, AC97_DMA_SIZE, 4, initiator, PSCRX_DMA_PRI,
	 MCD_INTERRUPT | MCD_TT_FLAGS_CW | MCD_TT_FLAGS_RL | MCD_TT_FLAGS_SP, MCD_NO_CSUM | MCD_NO_BYTE_SWAP) == MCD_OK) ? 0 : -1);
}

static void mcf548x_ac97_rx_stop(struct mcf548x_ac97_priv *priv)
{
	int psc_channel = priv->psc_channel;
	int dma_channel = dma_get_channel(DMA_PSC_RX(psc_channel));
	if(dma_channel != -1)
		MCD_killDma(dma_channel);
	dma_free_initiator(DMA_PSC_RX(psc_channel));
	/* Free up the DMA channel */
	dma_free_channel(DMA_PSC_RX(psc_channel));
}

static void mcf548x_ac97_tx_frame(int channel)
{
	struct mcf548x_ac97_priv *priv = Devices[channel];
	if(priv == NULL)
		return;
	if(!mcf548x_ac97_semaphore(&priv->tx_sem))
	{
		int dma_channel = dma_get_channel(DMA_PSC_TX(channel));
		MCD_bufDesc *ptdesc = &priv->txbd[priv->tx_bd_idx];
		MCD_XferProg progRep;
		/* Stop the timer */
		MCF_GPT_GMS(GPT_TIMER) = MCF_GPT_GMS_GPIO_OUTHI | MCF_GPT_GMS_TMS_GPIO;
		if(!priv->aclink_stopped && priv->codec_ready && !priv->ctrl_mode /* Wait for it to be ready */
		 && !(priv->play_record_mode & (SB_REC_ENA|SB_PLA_ENA))) /* no playback / record */
		{
			priv->timeout_shutdown++;
			if(priv->timeout_shutdown >= AC97_TIMEOUT_SHUTDOWN)
 			{
			 	priv->ctrl_address = AC97_POWERDOWN;
				priv->ctrl_data = (int)priv->powerdown | AC97_PD_PR4; /* AC-link */
				priv->status_data = (int)~priv->ctrl_data;
				priv->ctrl_rw = 0; /* write */
				priv->ctrl_mode = 1;
				priv->aclink_stopped = 1;
				priv->codec_ready = 0;
				priv->timeout_shutdown = 0;
			}		
		}
		if(!priv->aclink_stopped)
		{
			/* Reinitialize the periodic timer timeout interrupt. */
			MCF_GPT_GCIR(GPT_TIMER) = AC97_TX_TIMEOUT | (SYSTEM_CLOCK << 16);
			MCF_GPT_GMS(GPT_TIMER) = MCF_GPT_GMS_GPIO_OUTHI | MCF_GPT_GMS_TMS_GPIO | MCF_GPT_GMS_IEN | MCF_GPT_GMS_SC | MCF_GPT_GMS_CE;
		}
		if((dma_channel != -1) && (MCD_XferProgrQuery(dma_channel, &progRep) == MCD_OK))
		{
			MCD_bufDesc *ptdesc_end = progRep.currBufDesc;
#if 0 // #ifdef DEBUG
			char buf[10];
			display_string("mcf548x_ac97_tx_frame bytes: ");
			ltoa(buf, (long)progRep.dmaSize, 10);
			display_string(buf);
			display_string(", addr: 0x");
			ltoa(buf, (long)progRep.lastSrcAddr, 16);
			display_string(buf);
			display_string("\r\n");
#endif
			/* Check to see if the ring of BDs is empty */
			while((ptdesc != ptdesc_end) && !(ptdesc->flags & MCD_BUF_READY))
			{
				mcf548x_ac97_build_frame(priv, -AC97_SAMPLES_BY_BUFFER);
				/* increment the circular index */
				priv->tx_bd_idx = (priv->tx_bd_idx + 1) % AC97_TX_NUM_BD;
				/* Re-initialize the buffer descriptor */
				ptdesc->flags |= MCD_BUF_READY;
				ptdesc = ptdesc->next;
			}	
		}
		priv->tx_sem = 0;
	}
}

static void mcf548x_psc0_tx_frame(void)
{
  mcf548x_ac97_tx_frame(0);
}

static void mcf548x_psc1_tx_frame(void)
{
  mcf548x_ac97_tx_frame(1);
}

static void mcf548x_psc2_tx_frame(void)
{
  mcf548x_ac97_tx_frame(2);
}

static void mcf548x_psc3_tx_frame(void)
{
  mcf548x_ac97_tx_frame(3);
}

static int mcf548x_ac97_tx_start(struct mcf548x_ac97_priv *priv)
{
	unsigned long initiator;
	int dma_channel;
	int psc_channel = priv->psc_channel;
#ifdef DEBUG
	char buf[10];
	display_string("mcf548x_ac97_tx_start channel: ");
	ltoa(buf, (long)psc_channel, 10);
	display_string(buf);
	display_string(", txbd: 0x");
	ltoa(buf, (long)priv->txbd, 16);
	display_string(buf);
	display_string("\r\n");
#endif
	/* Make the initiator assignment */
	dma_set_initiator(DMA_PSC_TX(psc_channel));
	/* Grab the initiator number */
	initiator = dma_get_initiator(DMA_PSC_TX(psc_channel));
	/* Determine the DMA channel running the task for the selected PSC */
	dma_channel = dma_set_channel(DMA_PSC_TX(psc_channel), (psc_channel == 0) ? mcf548x_psc0_tx_frame : ((psc_channel == 1) ? mcf548x_psc1_tx_frame : ((psc_channel == 2) ? mcf548x_psc2_tx_frame : mcf548x_psc3_tx_frame)));
	/* Start the Tx DMA task */
	return((MCD_startDma(dma_channel, (char *)priv->txbd, 4, NULL, 0, AC97_DMA_SIZE, 4, initiator, PSCTX_DMA_PRI,
	 MCD_INTERRUPT | MCD_TT_FLAGS_CW | MCD_TT_FLAGS_RL | MCD_TT_FLAGS_SP, MCD_NO_CSUM | MCD_NO_BYTE_SWAP) == MCD_OK) ? 0 : -1);
}

static void mcf548x_ac97_tx_stop(struct mcf548x_ac97_priv *priv)
{
	int psc_channel = priv->psc_channel;
	int dma_channel = dma_get_channel(DMA_PSC_TX(psc_channel));
	if(dma_channel != -1)
		MCD_killDma(dma_channel);
	dma_free_initiator(DMA_PSC_TX(psc_channel));
	/* Free up the DMA channel */
	dma_free_channel(DMA_PSC_TX(psc_channel));
}

void mcf548x_ac97_timeout_interrupt(void)
{
  asm volatile (
		"_timeout_ac97_interrupt:\n\t"
		" move.w #0x2700,SR\n\t"
		" lea -24(SP),SP\n\t"
		" movem.l D0-D2/A0-A2,(SP)\n\t"
		" jsr _mcf548x_ac97_tx_timeout_interrupt_handler\n\t"
		" movem.l (SP),D0-D2/A0-A2\n\t"
		" lea 24(SP),SP\n\t"
		" rte\n\t" );
}

void mcf548x_ac97_tx_timeout_interrupt_handler(void) /* unmasked interrupt */
{
	int channel;
	for(channel = 0; channel < 4; channel++)
	{
		struct mcf548x_ac97_priv *priv = Devices[channel];
	  if(priv == NULL)
	  	continue;
	  if(!priv->tx_sem)
			mcf548x_ac97_tx_frame(channel); /* emergency send for avoid tx empty */
		if(!priv->rx_sem && priv->codec_ready)
			mcf548x_ac97_rx_frame(channel); /* there are no timeout control on rx, hope that is enough */
	}
  MCF_GPT_GSR(GPT_TIMER) |= MCF_GPT_GSR_TEXP;
}

static void mcf548x_ac97_fill_fifo(struct mcf548x_ac97_priv *priv)
{
	int i;
	int dma_channel = dma_get_channel(DMA_PSC_TX(priv->psc_channel));
	for(i = 0; i < AC97_TX_NUM_BD; priv->txbd[i++].flags |= MCD_BUF_READY);
  /* Continue/restart the DMA task */
  if(dma_channel != -1)
  {
    MCD_continDma(dma_channel);
		/* Stop the timer */
		MCF_GPT_GMS(GPT_TIMER) = MCF_GPT_GMS_GPIO_OUTHI | MCF_GPT_GMS_TMS_GPIO;
		/* Initialize the periodic timer timeout interrupt. */
		MCF_GPT_GCIR(GPT_TIMER) = AC97_TX_TIMEOUT | (SYSTEM_CLOCK << 16);
		MCF_GPT_GMS(GPT_TIMER) = MCF_GPT_GMS_GPIO_OUTHI | MCF_GPT_GMS_TMS_GPIO | MCF_GPT_GMS_IEN | MCF_GPT_GMS_SC | MCF_GPT_GMS_CE;
		if(!priv->aclink_stopped)
		{
			Setexc(MCF_GPT3_VECTOR, timeout_ac97_interrupt);
			/* Configure interrupt priority and level and unmask interrupt. */
			MCF_INTC_ICR59 = MCF_INTC_ICRn_IL(AC97_TIMER_INTC_LVL) | MCF_INTC_ICRn_IP(AC97_TIMER_INTC_PRI);
			MCF_INTC_IMRH &= ~MCF_INTC_IMRH_INT_MASK59;
#ifdef LWIP
			save_imrh &= ~MCF_INTC_IMRH_INT_MASK59; // for all tasks
#endif
		}
	}
}

static int mcf548x_ac97_bdinit(struct mcf548x_ac97_priv *priv)
{ 
#ifdef DEBUG
	display_string("mcf548x_ac97_bdinit\r\n");
#endif
#if (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_MEM_NO_CACHE)
	usb_mem_init();
	priv->buffer = (void *)usb_malloc((AC97_DMA_SIZE * (AC97_TX_NUM_BD + AC97_RX_NUM_BD)) + 15);
#else
	priv->buffer = (void *)Mxalloc((AC97_DMA_SIZE * (AC97_TX_NUM_BD + AC97_RX_NUM_BD)) + 15, 0);
#endif
	if(priv->buffer != NULL)
	{
		int i;
		unsigned long aligned_buffer = ((unsigned long)priv->buffer + 15) & ~15;
		priv->txbd = &Descriptors[0]; 
		for(i = 0; i < AC97_TX_NUM_BD; i++)
		{
			Descriptors[i].flags = MCD_INTERRUPT;
			Descriptors[i].csumResult = 0;
			Descriptors[i].srcAddr = (char *)aligned_buffer;
			Descriptors[i].destAddr = (char *)(MCF_PSC_TFDR_ADDR(priv->psc_channel));
			Descriptors[i].lastDestAddr = Descriptors[i].destAddr;
			Descriptors[i].dmaSize = AC97_DMA_SIZE;
			if(i == AC97_TX_NUM_BD - 1)
				Descriptors[i].next = &Descriptors[0];
			else
				Descriptors[i].next = &Descriptors[i+1];
			Descriptors[i].info = 0;
			memset((void *)aligned_buffer, 0, AC97_DMA_SIZE);
			priv->tx_bd_idx = i;
			mcf548x_ac97_build_frame(priv, -AC97_SAMPLES_BY_BUFFER);
			aligned_buffer += AC97_DMA_SIZE;
		}
		priv->tx_bd_idx = 0;
		priv->rxbd = &Descriptors[AC97_TX_NUM_BD]; 
		priv->rx_bd_idx = 0;
		for(i = AC97_TX_NUM_BD; i < AC97_TX_NUM_BD + AC97_RX_NUM_BD; i++)
		{
			Descriptors[i].flags = MCD_INTERRUPT | MCD_BUF_READY;
			Descriptors[i].csumResult = 0;
			Descriptors[i].srcAddr = (char *)(MCF_PSC_RFDR_ADDR(priv->psc_channel));
			Descriptors[i].destAddr = (char *)aligned_buffer;
			Descriptors[i].lastDestAddr = (char *)(aligned_buffer + AC97_DMA_SIZE);
			Descriptors[i].dmaSize = AC97_DMA_SIZE;
			if(i == AC97_TX_NUM_BD + AC97_RX_NUM_BD - 1)
				Descriptors[i].next = &Descriptors[AC97_TX_NUM_BD];
			else
				Descriptors[i].next = &Descriptors[i+1];
			Descriptors[i].info = 0;
			memset((void *)aligned_buffer, 0, AC97_DMA_SIZE);
			aligned_buffer += AC97_DMA_SIZE;
		}
		return(0);
	}
	return(-1);
}

static int mcf548x_fast_tx_update(struct mcf548x_ac97_priv *priv)
{
	if(!(priv->play_record_mode & (SB_REC_ENA|SB_PLA_ENA))) /* just for read/ write registers faster */
	{
		int dma_channel = dma_get_channel(DMA_PSC_TX(priv->psc_channel));
		MCD_XferProg progRep;
		if((dma_channel != -1) && (MCD_XferProgrQuery(dma_channel, &progRep) == MCD_OK))
		{
			MCD_bufDesc *ptdesc = progRep.currBufDesc;
			mcf548x_ac97_build_frame(priv, (int)(ptdesc->next - priv->txbd));
			return(1);
		}
	}
	return(0);
}

#else /* !USE_DMA */

static void mcf548x_ac97_fill_fifo(struct mcf548x_ac97_priv *priv)
{
	int channel = priv->psc_channel;
	unsigned long cnt = priv->cnt_tx_frame;
	unsigned long pos = priv->pos_tx_frame;
	unsigned long *p1 = &priv->tx_frame[cnt];
	unsigned long *p2 = &priv->tx_frame[AC97_SLOTS * AC97_SAMPLES_BY_BUFFER];
	long empty_bytes = (long)MCF_PSC_TFAR_ALARM(0xFFFF) - (long)MCF_PSC_TFCNT(channel);
	long count;
	if(pos >= cnt)
		empty_bytes -= (long)(pos - cnt);
	else
		empty_bytes -= (long)((AC97_SLOTS * AC97_SAMPLES_BY_BUFFER) - cnt + pos);
	if(empty_bytes < 0)
		empty_bytes = 0;
	mcf548x_ac97_build_frame(priv, ((empty_bytes >> 2) / AC97_SLOTS) + 1);
	count = ((long)MCF_PSC_TFAR_ALARM(0xFFFF) - (long)MCF_PSC_TFCNT(channel)) >> 2;
	switch(channel)
	{
		case 2:
			while(--count)
			{
				MCF_PSC_TB2_AC97 = *p1++;
				if(p1 >= p2)
					p1 = priv->tx_frame;				
			}	
			break;
		default:
			while(--count)
			{
				MCF_PSC_TB_AC97(channel) = *p1++;
				if(p1 >= p2)
					p1 = priv->tx_frame;				
			}
			break;
	}
	priv->cnt_tx_frame = (unsigned long)(p1 - priv->tx_frame);
}

#endif /* USE_DMA */

void mcf548x_ac97_psc0_interrupt(void)
{
  asm volatile (
		"_psc0_ac97_interrupt:\n\t"
		" move.w #0x2700,SR\n\t"
		" lea -24(SP),SP\n\t"
		" movem.l D0-D2/A0-A2,(SP)\n\t"
		" pea.l 0\n\t"
		" jsr _mcf548x_ac97_interrupt_handler\n\t"
		" addq.l #4,SP\n\t"
		" movem.l (SP),D0-D2/A0-A2\n\t"
		" lea 24(SP),SP\n\t"
		" rte\n\t" );
}

void mcf548x_ac97_psc1_interrupt(void)
{
  asm volatile (
		"_psc1_ac97_interrupt:\n\t"
		" move.w #0x2700,SR\n\t"
		" lea -24(SP),SP\n\t"
		" movem.l D0-D2/A0-A2,(SP)\n\t"
		" pea.l 1\n\t"
		" jsr _mcf548x_ac97_interrupt_handler\n\t"
		" addq.l #4,SP\n\t"
		" movem.l (SP),D0-D2/A0-A2\n\t"
		" lea 24(SP),SP\n\t"
		" rte\n\t" );
}

void mcf548x_ac97_psc2_interrupt(void)
{
  asm volatile (
		"_psc2_ac97_interrupt:\n\t"
		" move.w #0x2700,SR\n\t"
		" lea -24(SP),SP\n\t"
		" movem.l D0-D2/A0-A2,(SP)\n\t"
		" pea.l 2\n\t"
		" jsr _mcf548x_ac97_interrupt_handler\n\t"
		" addq.l #4,SP\n\t"
		" movem.l (SP),D0-D2/A0-A2\n\t"
		" lea 24(SP),SP\n\t"
		" rte\n\t" );
}

void mcf548x_ac97_psc3_interrupt(void)
{
  asm volatile (
		"_psc3_ac97_interrupt:\n\t"
		" move.w #0x2700,SR\n\t"
		" lea -24(SP),SP\n\t"
		" movem.l D0-D2/A0-A2,(SP)\n\t"
		" pea.l 3\n\t"
		" jsr _mcf548x_ac97_interrupt_handler\n\t"
		" addq.l #4,SP\n\t"
		" movem.l (SP),D0-D2/A0-A2\n\t"
		" lea 24(SP),SP\n\t"
		" rte\n\t" );
}

void mcf548x_ac97_interrupt_handler(int channel)
{
	struct mcf548x_ac97_priv *priv = Devices[channel];
	short int_status = MCF_PSC_ISR(channel);
#if AC97_INTC_LVL == 7
	MCF_PSC_IMR(channel) = 0;
#endif
#ifndef USE_DMA
	if(priv != NULL)
	{
		if(int_status & MCF_PSC_ISR_RXRDY_FU) /* RxFIFO full (RxFIFO threshold) */
		{
			unsigned long cnt = priv->cnt_rx_frame;
			unsigned long pos = priv->pos_rx_frame;
			unsigned long *p1 = &priv->rx_frame[cnt];
			unsigned long *p2 = &priv->rx_frame[AC97_SLOTS * AC97_SAMPLES_BY_BUFFER];
			unsigned long *p3 = priv->rx_frame;
			if(!(*p3 & MCF_PSC_TB_AC97_SOF)) /* buffer must begin by SOF else there are problem with the FIFO */
			{
				p1 = p3;
				priv->pos_rx_frame = pos = 0;
				while(MCF_PSC_SR(channel) & MCF_PSC_SR_RXRDY)
				{
					unsigned long tag = MCF_PSC_TB_AC97(channel);
					if(tag & MCF_PSC_TB_AC97_SOF)
					{
						*p1++ = tag;
						break;
					}
				}
			}
			while(MCF_PSC_SR(channel) & MCF_PSC_SR_RXRDY)
			{
				*p1++ = MCF_PSC_TB_AC97(channel);
					if(p1 >= p2)
						p1 = p3;
			}							
			if(*p3 & MCF_PSC_TB_AC97_SOF)
			{
				priv->cnt_rx_frame = cnt = (unsigned long)(p1 - p3);
				if(cnt >= pos) /* new contiguous frames inside the rx_buffer */
				{
					if(!mcf548x_ac97_get_frame(priv, (cnt - pos) / AC97_SLOTS))
						priv->codec_ready = 1;					
				}
				else /* 2 blocks */
				{
					if(!mcf548x_ac97_get_frame(priv, ((AC97_SLOTS * AC97_SAMPLES_BY_BUFFER) - pos) / AC97_SLOTS))
						priv->codec_ready = 1;		
					if(!mcf548x_ac97_get_frame(priv, cnt / AC97_SLOTS))
						priv->codec_ready = 1;		
				}
			}
		}
		if(int_status & MCF_PSC_ISR_TXRDY) /* TxFIFO empty (TxFIFO threshold) */
			mcf548x_ac97_fill_fifo(priv);
	}
#endif /* USE_DMA */
	if(int_status & MCF_PSC_ISR_ERR)
	{
		if(MCF_PSC_SR(channel) & MCF_PSC_SR_TXEMP_URERR)
		{
			MCF_PSC_CR(channel) = MCF_PSC_CR_RESET_ERROR;
			if(priv != NULL) /* sync is lost, the best is to restart all */
			{
#ifdef USE_DMA
				int dma_channel = dma_get_channel(DMA_PSC_TX(priv->psc_channel));
				mcf548x_ac97_tx_frame(channel);
			  /* Continue/restart the DMA task */
			  if(dma_channel != -1)
			    MCD_continDma(dma_channel);
#else
				priv->cnt_tx_frame = priv->pos_tx_frame = 0;
				mcf548x_ac97_fill_fifo(priv);
#endif
				priv->codec_ready = 0;
				priv->cnt_error_empty_tx++;
			}
		}
		if(MCF_PSC_SR(channel) & MCF_PSC_SR_ERR)
		{
			if(priv != NULL)
			{
				if(MCF_PSC_TFSR(channel) & 0xC0F0)
				{
					priv->last_error_fifo_tx = (short)MCF_PSC_TFSR(channel);
					priv->cnt_error_fifo_tx++;
				}
				if(MCF_PSC_RFSR(channel) & 0xC0F0)
				{
					priv->last_error_fifo_rx = (short)MCF_PSC_RFSR(channel);
					priv->cnt_error_fifo_rx++;
				}
			}		
			MCF_PSC_TFSR(channel) &= 0xC0F0;
			MCF_PSC_RFSR(channel) &= 0xC0F0;
			MCF_PSC_CR(channel) = MCF_PSC_CR_RESET_ERROR;
		}
	}
#if AC97_INTC_LVL == 7
	MCF_PSC_IMR(channel) = priv->imr;
#endif
}

static int mcf548x_ac97_sync_period(struct mcf548x_ac97_priv *priv)
{
	int period = 0;
	int level = asm_set_ipl(7); /* mask interrupts */
	unsigned char sync = MCF_PSC_IP(priv->psc_channel) & MCF_PSC_IP_TGL;
	unsigned long start_timer = MCF_SLT_SCNT(1);
	while((MCF_PSC_IP(priv->psc_channel) & MCF_PSC_IP_TGL) == sync)
	{
	  if((start_timer - MCF_SLT_SCNT(1)) > (100*SYSTEM_CLOCK))
	  {
	  	asm_set_ipl(level);
	  	return(0);
	  }
	}
	sync = MCF_PSC_IP(priv->psc_channel) & MCF_PSC_IP_TGL;
	start_timer = MCF_SLT_SCNT(1);
	while((MCF_PSC_IP(priv->psc_channel) & MCF_PSC_IP_TGL) == sync)
	{
	  if((start_timer - MCF_SLT_SCNT(1)) > (100*SYSTEM_CLOCK))
	  {
	  	asm_set_ipl(level);
	  	return(0);
	  }
	}
	period = (int)(start_timer - MCF_SLT_SCNT(1));
	asm_set_ipl(level);
	return(period);	
}

static unsigned short mcf548x_ac97_read(struct mcf548x_ac97_priv *priv, unsigned short reg)
{
	unsigned long start_timer;
#ifdef DEBUG
	unsigned long measure_timer;
#endif
	int level;
	priv->timeout_shutdown = 0;
//	if(!(MCF_PSC_IP(priv->psc_channel) & MCF_PSC_IP_LWPR_B)) /* low power */
	if(priv->aclink_stopped)
		mcf548x_ac97_warnreset(priv);
	start_timer = MCF_SLT_SCNT(1);
#ifdef DEBUG
	measure_timer = start_timer;
#endif
	/* Wait for it to be ready */
	while(!priv->codec_ready || priv->ctrl_mode)
	{
	  if((start_timer - MCF_SLT_SCNT(1)) >= AC97_TIMEOUT_REGISTERS)
		{
#ifdef DEBUG
			char buf[10];
			display_string("mcf548x_ac97_read reg: 0x");
			ltoa(buf, (long)reg & 0xffff, 16);
			display_string(buf);
			display_string(", ");
			if(priv->ctrl_mode)
				display_string("no answer\r\n");
			else
				display_string("codec not ready\r\n");
#endif
			priv->ctrl_mode = 0;
			return(0xffff); /* timeout */
		}
	}
	/* Do the read - Control Address - Slot #1 */
	level = asm_set_ipl(7); /* mask interrupts */
	priv->ctrl_address = (int)reg;
	priv->ctrl_rw = 1; /* read */
	priv->ctrl_mode = 1;
	start_timer = MCF_SLT_SCNT(1);
	asm_set_ipl(level);
#ifdef USE_DMA
	mcf548x_fast_tx_update(priv);
#endif
	/* Wait for the answer */
	while(priv->ctrl_mode)
	{
	  if((start_timer - MCF_SLT_SCNT(1)) >= AC97_TIMEOUT_REGISTERS)
		{
#ifdef DEBUG
			char buf[10];
			display_string("mcf548x_ac97_read reg: 0x");
			ltoa(buf, (long)reg & 0xffff, 16);
			display_string(buf);
			display_string(", timeout\r\n");
#endif
			priv->ctrl_mode = 0;
			return(0xffff); /* timeout */
		}
	}
#ifdef DEBUG
	{
		char buf[10];
		measure_timer -= MCF_SLT_SCNT(1);
		measure_timer /= SYSTEM_CLOCK;
		display_string("mcf548x_ac97_read reg: 0x");
		ltoa(buf, (long)reg & 0xffff, 16);
		display_string(buf);
		display_string(", value: 0x");
		ltoa(buf, (long)priv->status_data & 0xffff, 16);
		display_string(buf);
		display_string(" (");
		ltoa(buf, measure_timer, 10);
		display_string(buf);
		display_string(" uS)\r\n");
	}
#endif
	return((unsigned short)priv->status_data);
}

static void mcf548x_ac97_write(struct mcf548x_ac97_priv *priv, unsigned short reg, unsigned short val)
{
	unsigned long start_timer;
#ifdef DEBUG
	unsigned long measure_timer;
#endif
	int level;
	int count = 0;
	priv->timeout_shutdown = 0;
//	if(!(MCF_PSC_IP(priv->psc_channel) & MCF_PSC_IP_LWPR_B)) /* low power */
	if(priv->aclink_stopped)
		mcf548x_ac97_warnreset(priv);
#ifdef DEBUG
	measure_timer = MCF_SLT_SCNT(1);
#endif
	do
	{
		start_timer = MCF_SLT_SCNT(1);
		/* Wait for it to be ready */
		while(!priv->codec_ready || priv->ctrl_mode)
		{
		  if((start_timer - MCF_SLT_SCNT(1)) >= AC97_TIMEOUT_REGISTERS)
			{
#ifdef DEBUG
				char buf[10];
				display_string("mcf548x_ac97_write reg: 0x");
				ltoa(buf, (long)reg & 0xffff, 16);
				display_string(buf);
				display_string(", timeout\r\n");
#endif
				priv->ctrl_mode = 0;
				return; /* timeout */
			}
		}
		/* Write data */
		level = asm_set_ipl(7); /* mask interrupts */
		priv->ctrl_address = (int)reg;
		priv->ctrl_data = (int)val;
		priv->status_data = (int)~val;
		priv->ctrl_rw = 0; /* write */
		priv->ctrl_mode = 1;
		asm_set_ipl(level);
#ifdef USE_DMA
		mcf548x_fast_tx_update(priv);
#endif
		/* Wait for the answer */
		while(priv->ctrl_mode)
		{
		  if((start_timer - MCF_SLT_SCNT(1)) >= AC97_TIMEOUT_REGISTERS)
			{
#ifdef DEBUG
				char buf[10];
				display_string("mcf548x_ac97_write reg: 0x");
				ltoa(buf, (long)reg & 0xffff, 16);
				display_string(buf);
				display_string(", timeout\r\n");
#endif
				priv->ctrl_mode = 0;
				return; /* timeout */
			}
		}
		count++;
	}
#ifdef EMUL_DME_STE
	while(!priv->timer && (priv->ctrl_data != priv->status_data) && (count < AC97_RETRY_WRITE));
#else
	while((priv->ctrl_data != priv->status_data) && (count < AC97_RETRY_WRITE));
#endif
#ifdef DEBUG
	{
		char buf[10];
		measure_timer -= MCF_SLT_SCNT(1);
		measure_timer /= SYSTEM_CLOCK;
		display_string("mcf548x_ac97_write reg: 0x");
		ltoa(buf, (long)reg & 0xffff, 16);
		display_string(buf);
		display_string(", value: 0x");
		ltoa(buf, (long)priv->ctrl_data & 0xffff, 16);
		display_string(buf);
		display_string(" => 0x");
		ltoa(buf, (long)priv->status_data, 16);
		display_string(buf);
		display_string(" (");
		ltoa(buf, measure_timer, 10);
		display_string(buf);
		display_string(" uS)\r\n");
	}
#endif
}

static void mcf548x_ac97_powerdown(struct mcf548x_ac97_priv *priv)
{
 	priv->ctrl_address = AC97_POWERDOWN;
	priv->ctrl_data = (int)priv->powerdown | AC97_PD_PR4; /* AC-link */
	priv->status_data = (int)~priv->ctrl_data;
	priv->ctrl_rw = 0; /* write */
	priv->ctrl_mode = 1;
	priv->aclink_stopped = 1;
	priv->codec_ready = 0;
	priv->timeout_shutdown = 0;
}

 /* seems works only with dma else sync is lost after a warnreset from an AC-link powerdown */
static void mcf548x_ac97_warnreset(struct mcf548x_ac97_priv *priv)
{
	int i;
#ifdef DEBUG
	display_string("mcf548x_ac97_warnreset\r\n");
#endif
	mcf548x_ac97_hwstop(priv);
#ifdef USE_DMA
	for(i = 0; i < AC97_TX_NUM_BD; memset(priv->txbd[i].srcAddr, 0, AC97_DMA_SIZE), priv->txbd[i].flags &= ~MCD_BUF_READY, i++);
	for(i = 0; i < AC97_RX_NUM_BD; memset(priv->rxbd[i].destAddr, 0, AC97_DMA_SIZE), priv->rxbd[i].flags |= MCD_BUF_READY, i++);
#endif /* USE_DMA */
	priv->codec_ready = 0;
	priv->timeout_shutdown = 0;
	priv->ctrl_mode = 0;
	priv->cnt_rx = 0;
	priv->cnt_tx = 0;
#ifdef USE_DMA
	priv->tx_bd_idx = 0;
	priv->rx_bd_idx = 0;
#else
	priv->cnt_slot_rx = 0;
#endif
	priv->cnt_error_fifo_rx = 0;
	priv->cnt_error_fifo_tx = 0;
	priv->last_error_fifo_rx = 0;
	priv->last_error_fifo_tx = 0;
	priv->cnt_error_sync = 0;
	priv->cnt_error_empty_tx = 0;
#ifdef PERIOD
	priv->time_get_frame = 0;
	priv->time_build_frame = 0;
	priv->period_get_frame = 0;
	priv->period_build_frame = 0;
	priv->period_get_frame_min = 0xffffffff;
	priv->period_build_frame_min = 0xffffffff;
	priv->period_get_frame_max = 0;
	priv->period_build_frame_max = 0;
	priv->previous_get_frame = 0;
	priv->previous_build_frame = 0;
#endif
	mcf548x_ac97_hwinit(priv);
}

void mcf548x_ac97_timer(void)
{
	int channel;
	for(channel = 0; channel < 4; channel++)
	{
		struct mcf548x_ac97_priv *priv = Devices[channel];
	  if(priv == NULL)
	  	continue;
		if(priv->callback_play_to_call)
		{
			switch(priv->cause_inter)
			{
				case 0:
					if(priv->callback_play != NULL)
						priv->callback_play();
					break;
				/* Timer A */
				case SI_PLAY:
				case SI_BOTH:
					call_timer_a(); // XBIOS
					break;
				/* IO7 */
				case SI_PLAY + 0x100:
				case SI_BOTH + 0x100:		
					call_io7_mfp(); // XBIOS
					break;	
			}
			priv->callback_play_to_call = 0;			
		}
		if(priv->callback_record_to_call)
		{
			switch(priv->cause_inter)
			{
				case 0:
					if(priv->callback_record != NULL)
						priv->callback_record();
					break;
				/* Timer A */
				case SI_RECORD:
				case SI_BOTH:
					call_timer_a(); // XBIOS
					break;
				/* IO7 */
				case SI_RECORD + 0x100:
				case SI_BOTH + 0x100:		
					call_io7_mfp(); // XBIOS
					break;	
			}
			priv->callback_record_to_call = 0;			
		}
#ifdef EMUL_DMA_STE
		if(DMA_CONTROL != 0xff) /* valid ? */
		{
			if((int)DMA_CONTROL != priv->dma_control)
			{
				if(!priv->open_play)
				{
					if(DMA_CONTROL & SB_PLA_ENA)
					{
						long frequency[4] = { 6258, 12517, 25033, 50066 };
						unsigned long dma_start_address = (((unsigned long)DMA_START_ADDRESS_HIGH) << 16) + (((unsigned long)DMA_START_ADDRESS_MID) << 8) + (unsigned long)DMA_START_ADDRESS_LOW;
						unsigned long dma_end_address = (((unsigned long)DMA_END_ADDRESS_HIGH) << 16) + (((unsigned long)DMA_END_ADDRESS_MID) << 8) + (unsigned long)DMA_END_ADDRESS_LOW;
						priv->timer = 1;
						priv->open_play = 1;
						if(!mcf548x_ac97_playback_prepare(channel, frequency[(int)DMA_MODE_CONTROL & 3], (DMA_MODE_CONTROL & 0x80) ? MONO8 : STEREO8, (long)DMA_CONTROL & 3)
						 && (dma_start_address != 0xffffff) && (dma_end_address != 0xffffff) && dma_start_address && dma_end_address)
						{
							priv->cause_inter = SI_PLAY;
							priv->dma_start_address = dma_start_address;
							priv->dma_end_address = dma_end_address;
							priv->play_samples = priv->play_start_samples = (void *)dma_start_address;
							priv->play_end_samples = (void *)dma_end_address;
							priv->play_record_mode |= SB_PLA_ENA; /* play enable */
							DMA_COUNTER_ADDRESS_HIGH = (unsigned char)(dma_start_address >> 16);
							DMA_COUNTER_ADDRESS_MID = (unsigned char)(dma_start_address >> 8);
							DMA_COUNTER_ADDRESS_LOW = (unsigned char)dma_start_address; 
						}
						else
						{
							priv->play_record_mode &= ~SB_PLA_ENA;
							DMA_CONTROL &= ~SB_PLA_ENA;
							priv->open_play = 0;
						}
						priv->timer = 0;
						priv->dma_control = (int)DMA_CONTROL;
					}
				}
				else
				{
					if(!(DMA_CONTROL & SB_PLA_ENA))
					{
						priv->play_record_mode &= ~SB_PLA_ENA;
						priv->open_play = 0;
					}
					priv->dma_control = (int)DMA_CONTROL;
				}
			}	
			if(priv->open_play)
			{
				unsigned long dma_start_address = (((unsigned long)DMA_START_ADDRESS_HIGH) << 16) + (((unsigned long)DMA_START_ADDRESS_MID) << 8) + (unsigned long)DMA_START_ADDRESS_LOW;
				unsigned long dma_end_address = (((unsigned long)DMA_END_ADDRESS_HIGH) << 16) + (((unsigned long)DMA_END_ADDRESS_MID) << 8) + (unsigned long)DMA_END_ADDRESS_LOW;
				if((dma_start_address != 0xffffff) && (dma_end_address != 0xffffff) /* valid ? */
				 && (dma_start_address != priv->dma_start_address) && (dma_end_address != priv->dma_end_address)
				 && dma_start_address && dma_end_address && (dma_start_address < dma_end_address))
				{
					priv->dma_start_address = dma_start_address;
					priv->dma_end_address = dma_end_address;
					if(priv->play_record_mode & SB_PLA_ENA)
					{	
						priv->new_play_start_samples = (void *)dma_start_address;
						priv->new_play_end_samples = (void *)dma_end_address;
					}
				}
			}
		}
#endif /* EMUL_DMA_STE */
	}
}

void mcf548x_ac97_timer_interrupt(void)
{
  asm volatile (
  	"_timer_ac97_interrupt:\n\t"
  	" move.w #0x2700,SR\n\t"
  	" lea -24(SP),SP\n\t"
  	" movem.l D0-D2/A0-A2,(SP)\n\t"
		" jsr _mcf548x_ac97_timer\n\t"
		" movem.l (SP),D0-D2/A0-A2\n\t"
		" lea 24(SP),SP\n\t"
		" move.l _old_timer_vector,-(SP)\n\t"
		" rts\n\t" );
}

static void mcf548x_ac97_hwstop(struct mcf548x_ac97_priv *priv)
{
	int level;
	if(!priv->aclink_stopped)
		mcf548x_ac97_powerdown(priv);
	level = asm_set_ipl(7); /* mask interrupts */
	/* Stop the PSC */
	MCF_PSC_CR(priv->psc_channel) = MCF_PSC_CR_RESET_RX;
	MCF_PSC_CR(priv->psc_channel) = MCF_PSC_CR_RESET_TX;	
	MCF_PSC_CR(priv->psc_channel) = MCF_PSC_CR_RESET_ERROR;
	MCF_PSC_CR(priv->psc_channel) = MCF_PSC_CR_RESET_MR; /* acces to MR1 */
	if(!priv->aclink_stopped)
	{
		switch(priv->psc_channel)
		{
			case 0: MCF_INTC_IMRH &= ~MCF_INTC_IMRH_INT_MASK35; break;
			case 1: MCF_INTC_IMRH &= ~MCF_INTC_IMRH_INT_MASK34; break;
			case 2: MCF_INTC_IMRH &= ~MCF_INTC_IMRH_INT_MASK33; break;
			case 3: MCF_INTC_IMRH &= ~MCF_INTC_IMRH_INT_MASK32; break;
		}
#ifdef LWIP
		save_imrh = MCF_INTC_IMRH; // for all tasks
#endif
	}
#ifdef USE_DMA
	/* Stop the timer */
	MCF_GPT_GMS(GPT_TIMER) = MCF_GPT_GMS_GPIO_OUTHI | MCF_GPT_GMS_TMS_GPIO;
	if(!priv->aclink_stopped)
	{
		MCF_INTC_IMRH |= MCF_INTC_IMRH_INT_MASK59;
#ifdef LWIP
		save_imrh |= MCF_INTC_IMRH_INT_MASK59; // for all tasks
#endif
	}
	/* Stop the DMA */
	mcf548x_ac97_rx_stop(priv);
	mcf548x_ac97_tx_stop(priv);
#endif /* USE_DMA */
	asm_set_ipl(level);
}

static int mcf548x_ac97_hwinit(struct mcf548x_ac97_priv *priv)
{
	int level;
	long period;
#ifdef DEBUG
	char buf[10];
	display_string("mcf548x_ac97_hwinit priv: 0x");
	ltoa(buf, (long)priv, 16);
	display_string(buf);
#ifndef USE_DMA
	display_string(", tx_frame: 0x");
	ltoa(buf, (long)&priv->tx_frame, 16);
	display_string(buf);
	display_string(", rx_frame: 0x");
	ltoa(buf, (long)&priv->rx_frame, 16);
	display_string(buf);
#endif
#ifdef USE_VRA
	display_string(", slotreq: 0x");
	ltoa(buf, (long)&priv->slotreq, 16);
	display_string(buf);
#endif
	display_string(", incr_offsets_play: 0x");
	ltoa(buf, (long)&priv->incr_offsets_play, 16);
	display_string(buf);
	display_string("\r\n");	
#endif
#ifdef USE_DMA
	if(mcf548x_ac97_tx_start(priv))
		return(-1);
	if(mcf548x_ac97_rx_start(priv))
	{
		mcf548x_ac97_tx_stop(priv);
		return(-1);
	}
#endif
	level = asm_set_ipl(7); /* mask interrupts */
	/* Configure AC97 enhanced mode */
	MCF_PSC_SICR(priv->psc_channel) = MCF_PSC_SICR_ACRB | MCF_PSC_SICR_SIM_AC97;
	/* Reset everything first by safety */
	MCF_PSC_CR(priv->psc_channel) = MCF_PSC_CR_RESET_RX;
	MCF_PSC_CR(priv->psc_channel) = MCF_PSC_CR_RESET_TX;	
	MCF_PSC_CR(priv->psc_channel) = MCF_PSC_CR_RESET_ERROR;
	MCF_PSC_CR(priv->psc_channel) = MCF_PSC_CR_RESET_MR; /* acces to MR1 */
	/* Do a warm reset of codec - 1uS min */
	MCF_PSC_SICR(priv->psc_channel) |= MCF_PSC_SICR_AWR;
	udelay(10);
	MCF_PSC_SICR(priv->psc_channel) &= ~MCF_PSC_SICR_AWR;
#ifdef DEBUG
	if(!(MCF_PSC_IP(priv->psc_channel) & MCF_PSC_IP_LWPR_B))
		display_string("CODEC is in low power mode\r\n");
#endif
	if(!priv->aclink_stopped)
	{
		if((period = (long)mcf548x_ac97_sync_period(priv)) == 0)
		{
			asm_set_ipl(level);
			display_string("CODEC, no SYNC\r\n");
			return(-1); /* no clock */			
		}
		else
		{ 	
			char buf[10];
			priv->freq_codec = (long)((1000000UL * SYSTEM_CLOCK) / (unsigned long)period);
			display_string("CODEC SYNC frequency: ");
			ltoa(buf, priv->freq_codec, 10);
			display_string(buf);
			display_string(" Hz\r\n");
		}
	}
	/* IRQ */
	MCF_PSC_MR(priv->psc_channel) = MCF_PSC_MR_RXIRQ;
	MCF_PSC_CR(priv->psc_channel) = MCF_PSC_CR_RESET_MR; /* acces to MR1 */
#ifdef USE_DMA
	priv->imr = MCF_PSC_IMR(priv->psc_channel) = MCF_PSC_IMR_ERR;
#else
	priv->imr = MCF_PSC_IMR(priv->psc_channel) = MCF_PSC_IMR_TXRDY | MCF_PSC_IMR_RXRDY_FU | MCF_PSC_IMR_ERR; 
#endif
	MCF_PSC_IRCR1(priv->psc_channel) = MCF_PSC_IRCR1_FD;
	MCF_PSC_IRCR2(priv->psc_channel) = 0;	
	/* FIFO levels */
	MCF_PSC_RFCR(priv->psc_channel) = MCF_PSC_RFCR_FRMEN | MCF_PSC_RFCR_GR(4);
	MCF_PSC_TFCR(priv->psc_channel) = MCF_PSC_TFCR_FRMEN | MCF_PSC_TFCR_GR(7);
	switch(priv->psc_channel)
	{
		case 0: /* => used by serial 0 !!! */
			MCF_PSC0_RFAR = MCF_PSC_RFAR_ALARM(0xFFFF) - MCF_PSC_RFAR_ALARM(AC97_SLOTS * AC97_SAMPLES_BY_FIFO * 4);
			MCF_PSC0_TFAR = MCF_PSC_TFAR_ALARM(0xFFFF) - MCF_PSC_TFAR_ALARM(AC97_SLOTS * AC97_SAMPLES_BY_FIFO * 4);
			MCF_GPIO_PAR_PSC0 = MCF_GPIO_PAR_PSC0_PAR_CTS0_BCLK | MCF_GPIO_PAR_PSC0_PAR_RTS0_RTS | MCF_GPIO_PAR_PSC0_PAR_RXD0 | MCF_GPIO_PAR_PSC0_PAR_TXD0;
			if(!priv->aclink_stopped)
			{
				Setexc(MCF_PSC0_VECTOR, psc0_ac97_interrupt);
				MCF_INTC_ICR35 = MCF_INTC_ICRn_IL(AC97_INTC_LVL) | MCF_INTC_ICRn_IP(AC97_INTC_PRI);
				MCF_INTC_IMRH &= ~MCF_INTC_IMRH_INT_MASK35;
#ifdef LWIP
				save_imrh &= ~MCF_INTC_IMRH_INT_MASK35; // for all tasks
#endif
			}
			break;
		case 1: /* used by IKBD (Eiffel) */
			MCF_PSC1_RFAR = MCF_PSC_RFAR_ALARM(0xFFFF) - MCF_PSC_RFAR_ALARM(AC97_SLOTS * AC97_SAMPLES_BY_FIFO * 4);
			MCF_PSC1_TFAR = MCF_PSC_TFAR_ALARM(0xFFFF) - MCF_PSC_TFAR_ALARM(AC97_SLOTS * AC97_SAMPLES_BY_FIFO * 4);
			MCF_GPIO_PAR_PSC1 = MCF_GPIO_PAR_PSC1_PAR_CTS1_BCLK | MCF_GPIO_PAR_PSC1_PAR_RTS1_RTS | MCF_GPIO_PAR_PSC1_PAR_RXD1 | MCF_GPIO_PAR_PSC1_PAR_TXD1;
			if(!priv->aclink_stopped)
			{
				Setexc(MCF_PSC1_VECTOR, psc1_ac97_interrupt);
				MCF_INTC_ICR34 = MCF_INTC_ICRn_IL(AC97_INTC_LVL) | MCF_INTC_ICRn_IP(AC97_INTC_PRI);
				MCF_INTC_IMRH &= ~MCF_INTC_IMRH_INT_MASK34;
#ifdef LWIP
				save_imrh &= ~MCF_INTC_IMRH_INT_MASK34; // for all tasks 
#endif
			}
			break;
		case 2: /* AC97 codec */
			MCF_PSC2_RFAR = MCF_PSC_RFAR_ALARM(0xFFFF) - MCF_PSC_RFAR_ALARM(AC97_SLOTS * AC97_SAMPLES_BY_FIFO * 4);
			MCF_PSC2_TFAR = MCF_PSC_TFAR_ALARM(0xFFFF) - MCF_PSC_TFAR_ALARM(AC97_SLOTS * AC97_SAMPLES_BY_FIFO * 4);
			MCF_GPIO_PAR_PSC2 = MCF_GPIO_PAR_PSC2_PAR_CTS2_BCLK | MCF_GPIO_PAR_PSC2_PAR_RTS2_RTS | MCF_GPIO_PAR_PSC2_PAR_RXD2 | MCF_GPIO_PAR_PSC2_PAR_TXD2;
			if(!priv->aclink_stopped)
			{
				Setexc(MCF_PSC2_VECTOR, psc2_ac97_interrupt);
				MCF_INTC_ICR33 = MCF_INTC_ICRn_IL(AC97_INTC_LVL) | MCF_INTC_ICRn_IP(AC97_INTC_PRI);
				MCF_INTC_IMRH &= ~MCF_INTC_IMRH_INT_MASK33;
#ifdef LWIP
				save_imrh &= ~MCF_INTC_IMRH_INT_MASK33; // for all tasks 
#endif
			}
			break;
		case 3:
			MCF_PSC3_RFAR = MCF_PSC_RFAR_ALARM(0xFFFF) - MCF_PSC_RFAR_ALARM(AC97_SLOTS * AC97_SAMPLES_BY_FIFO * 4);
			MCF_PSC3_TFAR = MCF_PSC_TFAR_ALARM(0xFFFF) - MCF_PSC_TFAR_ALARM(AC97_SLOTS * AC97_SAMPLES_BY_FIFO * 4);
			MCF_GPIO_PAR_PSC3 = MCF_GPIO_PAR_PSC3_PAR_CTS3_BCLK | MCF_GPIO_PAR_PSC3_PAR_RTS3_RTS | MCF_GPIO_PAR_PSC3_PAR_RXD3 | MCF_GPIO_PAR_PSC3_PAR_TXD3;
			if(!priv->aclink_stopped)
			{
				Setexc(MCF_PSC3_VECTOR, psc3_ac97_interrupt);
				MCF_INTC_ICR32 = MCF_INTC_ICRn_IL(AC97_INTC_LVL) | MCF_INTC_ICRn_IP(AC97_INTC_PRI);
				MCF_INTC_IMRH &= ~MCF_INTC_IMRH_INT_MASK32;
#ifdef LWIP
				save_imrh &= ~MCF_INTC_IMRH_INT_MASK32; // for all tasks 
#endif
			}
			break;
	}
	mcf548x_ac97_fill_fifo(priv);
	priv->aclink_stopped = 0;
	/* Go */
	MCF_PSC_CR(priv->psc_channel) = MCF_PSC_CR_TX_ENABLED | MCF_PSC_CR_RX_ENABLED;
	asm_set_ipl(level);
#ifdef USE_DMA
#ifdef DEBUG
	{
		char buf[10];
		MCD_XferProg progRep;
		long bytes = 0;
		int dma_channel = dma_get_channel(DMA_PSC_RX(priv->psc_channel));
		display_string("mcf548x_ac97_rx_frame bytes: ");
		if((dma_channel != -1) && (MCD_XferProgrQuery(dma_channel, &progRep) == MCD_OK))
			bytes = (long)progRep.dmaSize;   
		ltoa(buf, bytes, 10);
		display_string(buf);
		display_string(", addr: 0x");
		ltoa(buf, (long)progRep.lastDestAddr, 16);
		display_string(buf);
		display_string(", status: ");
		ltoa(buf, (long)MCD_dmaStatus(dma_channel), 10);
		display_string(buf);
		display_string("\r\n");
		bytes = 0;
		dma_channel = dma_get_channel(DMA_PSC_TX(priv->psc_channel));
		display_string("mcf548x_ac97_tx_frame bytes: ");
		if((dma_channel != -1) && (MCD_XferProgrQuery(dma_channel, &progRep) == MCD_OK))
			bytes = (long)progRep.dmaSize;   
		ltoa(buf, bytes, 10);
		display_string(buf);
		display_string(", addr: 0x");
		ltoa(buf, (long)progRep.lastSrcAddr, 16);
		display_string(buf);
		display_string(", status: ");
		ltoa(buf, (long)MCD_dmaStatus(dma_channel), 10);
		display_string(buf);
		display_string("\r\n");
	}
#endif /* DEBUG */
#endif
	return(0);
}

/* ======================================================================== */
/* PCM interface                                                            */
/* ======================================================================== */

static void mcf548x_ac97_create_offsets(long frequency, long nearest_freq, int mode, unsigned char *tab_incr_offsets)
{
	if(frequency != nearest_freq)
	{ // VRA not works => create soft offsets
		long tab_offsets[AC97_SAMPLES_BY_BUFFER+1];
    int i;
    long incr, offset = 0;
		int coeff = nearest_freq / AC97_SAMPLES_BY_BUFFER;
		int new_samples_by_buffer = frequency / coeff;
		if((frequency % coeff) >= (coeff >> 1))
			new_samples_by_buffer++;
		if(new_samples_by_buffer > AC97_SAMPLES_BY_BUFFER)
			new_samples_by_buffer = AC97_SAMPLES_BY_BUFFER;
		incr = (long)((new_samples_by_buffer << 16) / AC97_SAMPLES_BY_BUFFER);
		switch(mode)
		{
			case STEREO8:
			case STEREO16:
				for(i = 0; i <= AC97_SAMPLES_BY_BUFFER; i++)
				{
					tab_offsets[i] = (offset >> 16) << 1;
					offset += incr;
				}
				break;
			default:
				for(i = 0; i <= AC97_SAMPLES_BY_BUFFER; i++)
				{
					tab_offsets[i] = offset >> 16;
					offset += incr;
				}
				break;
		}
		for(i = 0; i < AC97_SAMPLES_BY_BUFFER; i++)
			tab_incr_offsets[i] = (unsigned char)(tab_offsets[i+1] - tab_offsets[i]);
	}
}

static void mcf548x_ac97_clear_playback(struct mcf548x_ac97_priv *priv)
{
	int level = asm_set_ipl(7);
	priv->play_record_mode &= ~(SB_PLA_RPT|SB_PLA_ENA); 
	priv->play_samples = NULL;
	priv->play_start_samples = NULL;
	priv->play_end_samples = NULL;
	priv->new_play_start_samples = NULL;
	priv->new_play_end_samples = NULL;
	priv->cause_inter &= ~SI_PLAY;
	if(!priv->open_play)
	{
		priv->callback_play_to_call = 0;
		priv->callback_play = NULL;
  }
	asm_set_ipl(level);
}

int mcf548x_ac97_playback_open(long psc_channel)
{
	struct mcf548x_ac97_priv *priv;
	if((psc_channel < 0) || (psc_channel >= 4))
		return(-1); // error
	priv = Devices[psc_channel];
	if(priv == NULL)
		return(-1); // error
	if(priv->open_play)
		return(-1); // error
#ifdef DEBUG
	display_string("mcf548x_ac97_playback_open\r\n");
#endif
	priv->open_play = 1;
	mcf548x_ac97_clear_playback(priv);
	return(0); // OK
}

int mcf548x_ac97_playback_close(long psc_channel)
{
	struct mcf548x_ac97_priv *priv;
	if((psc_channel < 0) || (psc_channel >= 4))
		return(-1); // error
	priv = Devices[psc_channel];
	if(priv == NULL)
		return(-1); // error
	if(!priv->open_play)
		return(-1); // error
#ifdef DEBUG
		{
			char buf[10];
			display_string("mcf548x_ac97_playback_close, ptr: 0x");
			ltoa(buf, (long)priv->play_samples, 16);
			display_string(buf);
			display_string("\r\n");
		}
#endif
	priv->open_play = 0;
	mcf548x_ac97_clear_playback(priv);
	return(0); // OK
}

int mcf548x_ac97_playback_prepare(long psc_channel, long frequency, long res, long mode)
{
	long tab_freq[] = { 8000,11025,16000,22050,32000,44100,48000 };
	long nearest_freq;
	struct mcf548x_ac97_priv *priv;
	long d, mini = 999999;
	int i = 0, index = 0;
	int level;
	if((psc_channel < 0) || (psc_channel >= 4))
		return(-1); // error
	priv = Devices[psc_channel];
	if(priv == NULL)
		return(-1); // error
	if(!priv->open_play)
		return(-1); // closed => error
	while(i < sizeof(tab_freq)/sizeof(tab_freq[0]))
	{
		d = tab_freq[i++] - frequency;
		if(d < 0)
			d = -d;
		if(d < mini)
		{
			mini = d;
			index = i - 1;
		}
	}
	nearest_freq = tab_freq[index];
	switch(nearest_freq)
	{
		case 8000:
			if(priv->rates[AC97_RATES_FRONT_DAC] & SNDRV_PCM_RATE_8000)
				break;
			nearest_freq = 48000;
			break;
		case 11025:
			if(priv->rates[AC97_RATES_FRONT_DAC] & SNDRV_PCM_RATE_11025)
				break;
			nearest_freq = 48000;
			break;
		case 16000:
			if(priv->rates[AC97_RATES_FRONT_DAC] & SNDRV_PCM_RATE_16000)
				break;
			nearest_freq = 48000;
			break;
		case 22050:
			if(priv->rates[AC97_RATES_FRONT_DAC] & SNDRV_PCM_RATE_22050)
				break;
			nearest_freq = 48000;
			break;
		case 32000:
			if(priv->rates[AC97_RATES_FRONT_DAC] & SNDRV_PCM_RATE_32000)
				break;
			nearest_freq = 48000;
			break;
		case 44100:
			if(priv->rates[AC97_RATES_FRONT_DAC] & SNDRV_PCM_RATE_44100)
				break;
			nearest_freq = 48000;
			break;
		case 48000:
			if(priv->rates[AC97_RATES_FRONT_DAC] & SNDRV_PCM_RATE_48000)
				break;
			return(-1); // error
	}
	mcf548x_ac97_create_offsets(frequency, nearest_freq, res, priv->incr_offsets_play);
	mcf548x_ac97_write(priv, AC97_PCM_FRONT_DAC_RATE, nearest_freq);
	level = asm_set_ipl(7);
	priv->play_frequency = frequency;
	priv->freq_dac = nearest_freq;
	priv->play_record_mode &= ~SB_PLA_RPT; 
	priv->play_record_mode |= ((int)mode & SB_PLA_RPT);
	priv->play_res = res & 0xff;
	asm_set_ipl(level);
#ifdef DEBUG
	{
		char buf[10];
		display_string("mcf548x_ac97_playback_prepare, frequency: ");
		ltoa(buf, frequency, 10);
		display_string(buf);
		display_string(", res: ");
		ltoa(buf, res, 10);
		display_string(buf);
		display_string(", mode: ");
		ltoa(buf, mode, 10);
		display_string(buf);
		display_string(" => play_frequency: ");
		ltoa(buf, priv->play_frequency, 10);
		display_string(buf);
		display_string(", freq_dac: ");
		ltoa(buf, priv->freq_dac, 10);
		display_string(buf);
		display_string(", rates: 0x");
		ltoa(buf, priv->rates[AC97_RATES_FRONT_DAC], 16);
		display_string(buf);
		display_string("\r\n");
	}
#endif
	return(0); // OK
}

int mcf548x_ac97_playback_callback(long psc_channel, void (*callback)())
{
	struct mcf548x_ac97_priv *priv;
	if((psc_channel < 0) || (psc_channel >= 4))
		return(-1); // error
	priv = Devices[psc_channel];
	if(priv == NULL)
		return(-1); // error
	priv->callback_play = callback;
#ifdef DEBUG
	{
		char buf[10];
		display_string("mcf548x_ac97_playback_callback, callback: 0x");
		ltoa(buf, (long)callback, 16);
		display_string(buf);
		display_string("\r\n");
	}
#endif
	return(0); // OK
}

int mcf548x_ac97_playback_trigger(long psc_channel, long cmd)
{
	struct mcf548x_ac97_priv *priv;
	int level;
	if((psc_channel < 0) || (psc_channel >= 4))
		return(-1); // error
	priv = Devices[psc_channel];
	if(priv == NULL)
		return(-1); // error
	if(!priv->open_play)
		return(-1); // closed => error
	level = asm_set_ipl(7);
	if(cmd && (priv->play_samples != NULL))
		priv->play_record_mode |= SB_PLA_ENA; /* play enable */
	else
		priv->play_record_mode &= ~SB_PLA_ENA;
	asm_set_ipl(level);
#ifdef DEBUG
	{
		char buf[10];
		display_string("mcf548x_ac97_playback_trigger, cmd: ");
		ltoa(buf, cmd, 10);
		display_string(buf);
		display_string(" => play_record_mode: ");
		ltoa(buf, priv->play_record_mode, 10);
		display_string(buf);
		display_string("\r\n");
	}
#endif
	return(0); // OK
}

int mcf548x_ac97_playback_pointer(long psc_channel, void **ptr, long set)
{
	struct mcf548x_ac97_priv *priv;
	if((psc_channel < 0) || (psc_channel >= 4))
		return(-1); // error
	if(ptr == NULL)
		return(-1); // error
	priv = Devices[psc_channel];
	if(priv == NULL)
		return(-1); // error
	if(!priv->open_play)
	{
		if(!set)
			*ptr = NULL;
		return(-1); // closed => error
	}
	if(set)
	{
		if(priv->play_record_mode & SB_PLA_ENA)
		{	
			priv->new_play_start_samples = ptr[0];
			priv->new_play_end_samples = ptr[1];
		}
		else
		{
			priv->play_samples = priv->play_start_samples = ptr[0];
			priv->play_end_samples = ptr[1];
		}
#ifdef DEBUG
		{
			char buf[10];
			display_string("mcf548x_ac97_playback_pointer, ptrs: 0x");
			ltoa(buf, (long)ptr[0], 16);
			display_string(buf);
			display_string(", 0x");
			ltoa(buf, (long)ptr[1], 16);
			display_string(buf);
			display_string("\r\n");
		}
#endif
	}
	else
	{
		if(priv->play_record_mode & SB_PLA_ENA)
			*ptr = priv->play_samples;
		else
			*ptr = NULL;
#if 0 // #ifdef DEBUG
		{
			char buf[10];
			display_string("mcf548x_ac97_playback_pointer, ptr: 0x");
			ltoa(buf, (long)*ptr, 16);
			display_string(buf);
			display_string("\r\n");
		}
#endif
	}
	return(0); // OK
}

static void mcf548x_ac97_clear_capture(struct mcf548x_ac97_priv *priv)
{
	int level = asm_set_ipl(7);
	priv->play_record_mode &= ~(SB_REC_RPT|SB_REC_ENA);
	priv->record_samples = NULL;
	priv->record_start_samples = NULL;
	priv->record_end_samples = NULL;
	priv->new_record_start_samples = NULL;
	priv->new_record_end_samples = NULL;
	priv->cause_inter &= ~SI_RECORD;
#ifdef LWIP
	priv->callback_record_to_call = 0;
#endif
	priv->callback_record = NULL;
	asm_set_ipl(level);
}

int mcf548x_ac97_capture_open(long psc_channel)
{
	struct mcf548x_ac97_priv *priv;
	if((psc_channel < 0) || (psc_channel >= 4))
		return(-1); // error
	priv = Devices[psc_channel];
	if(priv == NULL)
		return(-1); // error
	if(priv->open_record)
		return(-1); // error
#ifdef DEBUG
	display_string("mcf548x_ac97_capture_open\r\n");
#endif
	priv->open_record = 1;
	mcf548x_ac97_clear_capture(priv);
	return(0); // OK
}

int mcf548x_ac97_capture_close(long psc_channel)
{
	struct mcf548x_ac97_priv *priv;
	if((psc_channel < 0) || (psc_channel >= 4))
		return(-1); // error
	priv = Devices[psc_channel];
	if(priv == NULL)
		return(-1); // error
	if(!priv->open_record)
		return(-1); // error
#ifdef DEBUG
		{
			char buf[10];
			display_string("mcf548x_ac97_capture_close, ptr: 0x");
			ltoa(buf, (long)priv->record_samples, 16);
			display_string(buf);
			display_string("\r\n");
		}
#endif
	priv->open_record = 0;
	mcf548x_ac97_clear_capture(priv);
	return(0); // OK
}

int mcf548x_ac97_capture_prepare(long psc_channel, long frequency, long res, long mode)
{
	long tab_freq[] = { 8000,11025,16000,22050,32000,44100,48000 };
	long nearest_freq;
	struct mcf548x_ac97_priv *priv;
	long d, mini = 999999;
	int i = 0, index = 0;
	int level;
	if((psc_channel < 0) || (psc_channel >= 4))
		return(-1); // error
	priv = Devices[psc_channel];
	if(priv == NULL)
		return(-1); // error
	if(!priv->open_record)
		return(-1); // error
	while(i < sizeof(tab_freq)/sizeof(tab_freq[0]))
	{
		d = tab_freq[i++] - frequency;
		if(d < 0)
			d = -d;
		if(d < mini)
		{
			mini = d;
			index = i - 1;
		}
	}
	nearest_freq = tab_freq[index];
	switch(nearest_freq)
	{
		case 8000:
			if(priv->rates[AC97_RATES_ADC] & SNDRV_PCM_RATE_8000)
				break;
			nearest_freq = 48000;
			break;
		case 11025:
			if(priv->rates[AC97_RATES_ADC] & SNDRV_PCM_RATE_11025)
				break;
			nearest_freq = 48000;
			break;
		case 16000:
			if(priv->rates[AC97_RATES_ADC] & SNDRV_PCM_RATE_16000)
				break;
			nearest_freq = 48000;
			break;
		case 22050:
			if(priv->rates[AC97_RATES_ADC] & SNDRV_PCM_RATE_22050)
				break;
			nearest_freq = 48000;
			break;
		case 32000:
			if(priv->rates[AC97_RATES_ADC] & SNDRV_PCM_RATE_32000)
				break;
			nearest_freq = 48000;
			break;
		case 44100:
			if(priv->rates[AC97_RATES_ADC] & SNDRV_PCM_RATE_44100)
					break;
			nearest_freq = 48000;
			break;
		case 48000:
			if(priv->rates[AC97_RATES_ADC] & SNDRV_PCM_RATE_48000)
				break;
			return(-1); // error
	}
	mcf548x_ac97_create_offsets(frequency, nearest_freq, res, priv->incr_offsets_record);
	mcf548x_ac97_write(priv, AC97_PCM_LR_ADC_RATE, nearest_freq);
	level = asm_set_ipl(7);
	priv->record_frequency = frequency;
	priv->freq_adc = nearest_freq;
	priv->play_record_mode &= ~SB_REC_RPT; 
	priv->play_record_mode |= ((int)mode & SB_REC_RPT);
	priv->record_res = res & 0xff00;
	mcf548x_ac97_write(priv, AC97_PCM_LR_ADC_RATE, nearest_freq);
	asm_set_ipl(level);
#ifdef DEBUG
	{
		char buf[10];
		display_string("mcf548x_ac97_capture_prepare, frequency: ");
		ltoa(buf, frequency, 10);
		display_string(buf);
		display_string(", res: ");
		ltoa(buf, res, 10);
		display_string(buf);
		display_string(", mode: ");
		ltoa(buf, mode, 10);
		display_string(buf);
		display_string(" => record_frequency: ");
		ltoa(buf, priv->record_frequency, 10);
		display_string(buf);
		display_string(", freq_adc: ");
		ltoa(buf, priv->freq_adc, 10);
		display_string(buf);
		display_string(", rates: 0x");
		ltoa(buf, priv->rates[AC97_RATES_ADC], 16);
		display_string(buf);
		display_string("\r\n");
	}
#endif
	return(0); // OK
}

int mcf548x_ac97_capture_callback(long psc_channel, void (*callback)())
{
	struct mcf548x_ac97_priv *priv;
	if((psc_channel < 0) || (psc_channel >= 4))
		return(-1); // error
	priv = Devices[psc_channel];
	if(priv == NULL)
		return(-1); // error
	priv->callback_record = callback;
#ifdef DEBUG
	{
		char buf[10];
		display_string("mcf548x_ac97_capture_callback, callback: 0x");
		ltoa(buf, (long)callback, 16);
		display_string(buf);
		display_string("\r\n");
	}
#endif
	return(0); // OK
}

int mcf548x_ac97_capture_trigger(long psc_channel, long cmd)
{
	struct mcf548x_ac97_priv *priv;
	int level;
	if((psc_channel < 0) || (psc_channel >= 4))
		return(-1); // error
	priv = Devices[psc_channel];
	if(priv == NULL)
		return(-1); // error
	if(!priv->open_record)
		return(-1); // error
	level = asm_set_ipl(7);
	if(cmd && (priv->record_samples != NULL))
		priv->play_record_mode |= SB_REC_ENA; /* record enable */
	else
		priv->play_record_mode &= ~SB_REC_ENA; 
	asm_set_ipl(level);
#ifdef DEBUG
	{
		char buf[10];
		display_string("mcf548x_ac97_capture_trigger, cmd: ");
		ltoa(buf, cmd, 10);
		display_string(buf);
		display_string(" => play_record_mode: ");
		ltoa(buf, priv->play_record_mode, 10);
		display_string(buf);
		display_string("\r\n");
	}
#endif
	return(0); // OK
}

int mcf548x_ac97_capture_pointer(long psc_channel, void **ptr, long set)
{
	struct mcf548x_ac97_priv *priv;
	if((psc_channel < 0) || (psc_channel >= 4))
		return(-1); // error
	if(ptr == NULL)
		return(-1); // error
	priv = Devices[psc_channel];
	if(priv == NULL)
		return(-1); // error
	if(!priv->open_record)
	{
		if(!set)
			*ptr = NULL;
		return(-1); // closed => error
	}
	if(set)
	{
		if(priv->play_record_mode & SB_REC_ENA)
		{	
			priv->new_record_start_samples = ptr[0];
			priv->new_record_end_samples = ptr[1];
		}
		else
		{
			priv->record_samples = priv->record_start_samples = ptr[0];
			priv->record_end_samples = ptr[1];
		}
#ifdef DEBUG
		{
			char buf[10];
			display_string("mcf548x_ac97_capture_pointer, ptr: 0x");
			ltoa(buf, (long)ptr[0], 16);
			display_string(buf);
			display_string(", 0x");
			ltoa(buf, (long)ptr[1], 16);
			display_string(buf);
			display_string("\r\n");
		}
#endif
	}
	else
	{
		if(priv->play_record_mode & SB_REC_ENA)
			*ptr = priv->record_samples;
		else
			*ptr = NULL;
#if 0 // #ifdef DEBUG
		{
			char buf[10];
			display_string("mcf548x_ac97_capture_pointer, ptr: 0x");
			ltoa(buf, (long)*ptr, 16);
			display_string(buf);
			display_string("\r\n");
		}
#endif
	}
	return(0); // OK
}

int mcf548x_ac97_ioctl(long psc_channel, unsigned int cmd, void *arg)
{
	struct mcf548x_ac97_priv *priv;
	int value = *(int *)arg; 
	int mono;
	if((psc_channel < 0) || (psc_channel >= 4))
		return(-1); // error
	priv = Devices[psc_channel];
	if(priv == NULL)
		return(-1); // error
#if 0 // #ifdef DEBUG
	{
		char buf[10];
		display_string("mcf548x_ac97_ioctl cmd: 0x");
		ltoa(buf, (long)cmd, 16);
		display_string(buf);
		display_string(", value: 0x");
		ltoa(buf, (long)value, 16);
		display_string(buf);
		display_string("\r\n");	
	}
#endif
	switch(cmd)
	{
		// outputs
		case SOUND_MIXER_WRITE_VOLUME:
			if(value & 0xff000000)
			{
				if((value >> 16) & 1)
				{
					priv->master &= ~0x8000;
					priv->mono &= ~0x8000;
				}
				else
				{
					priv->master |= 0x8000; /* mute */
					priv->mono |= 0x8000; /* mute */
				}
			}
			else
			{
				priv->master &= 0x8000;
				priv->mono &= 0x8000;
				mono = (LEFT_CHANNEL_VOLUME(value) + RIGHT_CHANNEL_VOLUME(value)) >> 1;
				priv->master |= (((~LEFT_CHANNEL_VOLUME(value) & 0xfC) << 6) + ((~RIGHT_CHANNEL_VOLUME(value) & 0xfC) >> 2));
				priv->mono |=  ((~mono & 0xf8) >> 3);
			}
			mcf548x_ac97_write(priv, AC97_MASTER, priv->master);
			mcf548x_ac97_write(priv, AC97_HEADPHONE, ((priv->master >> 1) & 0x1f1f) + (priv->master & 0x8000));
			mcf548x_ac97_write(priv, AC97_MASTER_MONO, priv->mono);
			return(0);
		case SOUND_MIXER_WRITE_BASS:
			if(priv->caps & AC97_BC_BASS_TREBLE)
			{
				priv->tone &= 0xf;
				priv->tone |= ((~value & 0xf0) << 4);
				mcf548x_ac97_write(priv, AC97_MASTER_TONE, priv->tone);
				return(0);
			}
			return(-1);
		case SOUND_MIXER_WRITE_TREBLE:
			if(priv->caps & AC97_BC_BASS_TREBLE)
			{
				priv->tone &= 0xf00;
				priv->tone |= ((~value & 0xf0) >> 4);
				mcf548x_ac97_write(priv, AC97_MASTER_TONE, priv->tone);
				return(0);
			}
			return(-1);
		case SOUND_MIXER_WRITE_PCM:
			if(value & 0xff000000)
			{
				if((value >> 16) & 1)
					priv->input_gains[RECORD_SOURCE_STEREO_MIX] &= ~0x8000;
				else
					priv->input_gains[RECORD_SOURCE_STEREO_MIX] |= 0x8000; /* mute */
			}
			else
			{
				priv->input_gains[RECORD_SOURCE_STEREO_MIX] &= 0x8000;
				priv->input_gains[RECORD_SOURCE_STEREO_MIX] |= (((~LEFT_CHANNEL_VOLUME(value) & 0xf8) << 5) + ((~RIGHT_CHANNEL_VOLUME(value) & 0xf8) >> 3));
			}
			mcf548x_ac97_write(priv, AC97_PCM, priv->input_gains[RECORD_SOURCE_STEREO_MIX]);
			return(0);
		case SOUND_MIXER_WRITE_SYNTH:
		case SOUND_MIXER_WRITE_SPEAKER:
			if(value & 0xff000000)
			{
				if((value >> 16) & 1)
					priv->input_gains[RECORD_SOURCE_MONO_MIX] &= ~0x8000;
				else
					priv->input_gains[RECORD_SOURCE_MONO_MIX] |= 0x8000; /* mute */
			}
			else
			{
				priv->input_gains[RECORD_SOURCE_MONO_MIX] &= 0x8000;
				priv->input_gains[RECORD_SOURCE_MONO_MIX] |= ((~value & 0xf0) >> 3);
			}
			mcf548x_ac97_write(priv, AC97_PC_BEEP, priv->input_gains[RECORD_SOURCE_MONO_MIX]);				
			return(0);
		// inputs
		case SOUND_MIXER_WRITE_LINE:
			if(value & 0xff000000)
			{
				if((value >> 16) & 1)
					priv->input_gains[RECORD_SOURCE_LINE] &= ~0x8000;
				else
					priv->input_gains[RECORD_SOURCE_LINE] |= 0x8000; /* mute */
			}
			else
			{
				priv->input_gains[RECORD_SOURCE_LINE] &= 0x8000;
				priv->input_gains[RECORD_SOURCE_LINE] |= (((~LEFT_CHANNEL_VOLUME(value) & 0xf8) << 5) + ((~RIGHT_CHANNEL_VOLUME(value) & 0xf8) >> 3));
			}		
			mcf548x_ac97_write(priv, AC97_LINE, priv->input_gains[RECORD_SOURCE_LINE]);
			return(0);
		case SOUND_MIXER_WRITE_CD:
			if(value & 0xff000000)
			{
				if((value >> 16) & 1)
					priv->input_gains[RECORD_SOURCE_CD] &= ~0x8000;
				else
					priv->input_gains[RECORD_SOURCE_CD] |= 0x8000; /* mute */
			}
			else
			{
				priv->input_gains[RECORD_SOURCE_CD] &= 0x8000;
				priv->input_gains[RECORD_SOURCE_CD] |= (((~LEFT_CHANNEL_VOLUME(value) & 0xf8) << 5) + ((~RIGHT_CHANNEL_VOLUME(value) & 0xf8) >> 3));
			}		
			mcf548x_ac97_write(priv, AC97_CD, priv->input_gains[RECORD_SOURCE_CD]);
			return(0);
		case SOUND_MIXER_WRITE_LINE1:
			if(value & 0xff000000)
			{
				if((value >> 16) & 1)
					priv->input_gains[RECORD_SOURCE_AUX] &= ~0x8000;
				else
					priv->input_gains[RECORD_SOURCE_AUX] |= 0x8000; /* mute */
			}
			else
			{
				priv->input_gains[RECORD_SOURCE_AUX] &= 0x8000;
				priv->input_gains[RECORD_SOURCE_AUX] |= (((~LEFT_CHANNEL_VOLUME(value) & 0xf8) << 5) + ((~RIGHT_CHANNEL_VOLUME(value) & 0xf8) >> 3));
			}			
			mcf548x_ac97_write(priv, AC97_AUX, priv->input_gains[RECORD_SOURCE_AUX]);
			return(0);
		case SOUND_MIXER_WRITE_LINE2:
			if(value & 0xff000000)
			{
				if((value >> 16) & 1)
					priv->input_gains[RECORD_SOURCE_VIDEO] &= ~0x8000;
				else
					priv->input_gains[RECORD_SOURCE_VIDEO] |= 0x8000; /* mute */
			}
			else
			{
				priv->input_gains[RECORD_SOURCE_VIDEO] &= 0x8000;
				priv->input_gains[RECORD_SOURCE_VIDEO] |= (((~LEFT_CHANNEL_VOLUME(value) & 0xf8) << 5) + ((~RIGHT_CHANNEL_VOLUME(value) & 0xf8) >> 3));
			}		
			mcf548x_ac97_write(priv, AC97_VIDEO, priv->input_gains[RECORD_SOURCE_VIDEO]);
			return(0);
		case SOUND_MIXER_WRITE_MIC:
			if(value & 0xff000000)
			{
				if((value >> 16) & 1)
					priv->input_gains[RECORD_SOURCE_MIC] &= ~0x8000;
				else
					priv->input_gains[RECORD_SOURCE_MIC] |= 0x8000; /* mute */
			}
			else
			{
				priv->input_gains[RECORD_SOURCE_MIC] &= 0x8000;
				mono = (LEFT_CHANNEL_VOLUME(value) + RIGHT_CHANNEL_VOLUME(value)) >> 1;
				priv->input_gains[RECORD_SOURCE_MIC] |= ((~mono & 0xf8) >> 3);
			}
			mcf548x_ac97_write(priv, AC97_MIC, priv->input_gains[RECORD_SOURCE_MIC]); /* bit 6: boost +20dB */
			return(0);
		case SOUND_MIXER_WRITE_RECLEV:
			mcf548x_ac97_write(priv, AC97_REC_GAIN, ((LEFT_CHANNEL_VOLUME(value) & 0xf0) << 4) + ((RIGHT_CHANNEL_VOLUME(value) & 0xf0) >>4));
			return(0);
		case SOUND_MIXER_WRITE_ENHANCE:
			if(priv->caps & 0x7C00)
			{
				if(value & 0xff000000)
				{
					if((value >> 16) & 1)
						priv->ctrl_gene |= 0x2000;
					else
						priv->ctrl_gene &= ~0x2000;
					mcf548x_ac97_write(priv, AC97_GENERAL_PURPOSE, priv->ctrl_gene);
				}
				else
					mcf548x_ac97_write(priv, AC97_3D_CONTROL, (value & 0xf0) >> 4);
				return(0);
			}
			return(-1);
		case SOUND_MIXER_WRITE_LOUD:
			if(priv->caps & AC97_BC_LOUDNESS)
			{
				if(value)
					priv->ctrl_gene |= 0x1000;
				else
					priv->ctrl_gene &= ~0x1000;
				mcf548x_ac97_write(priv, AC97_GENERAL_PURPOSE, priv->ctrl_gene);
				return(0);
			}
			return(-1);
		case SOUND_MIXER_WRITE_RECSRC:
			/* 0:Mic, 1:CD, 2:Video, 3:Aux, 4:Line, 5:Mix Stereo, 6:Mix Mono, 7:Phone */
			mcf548x_ac97_write(priv, AC97_REC_SEL, ((LEFT_CHANNEL_VOLUME(value) & 7) << 8) + (RIGHT_CHANNEL_VOLUME(value) & 7));
			return(0);
		case SOUND_MIXER_WRITE_POWERDOWN:
#ifdef USE_DMA
			mcf548x_ac97_powerdown(priv);
#endif
			return(0);
	}
	return(-1); // error
}

/* ======================================================================== */
/* AC97 Interface Debug                                                     */
/* ======================================================================== */

#ifdef LWIP

int mcf548x_ac97_debug_read(long psc_channel, long reg)
{
	struct mcf548x_ac97_priv *priv;
	unsigned long start_timer;
	int level;
	if((psc_channel < 0) || (psc_channel >= 4))
		return(-1); // error
	priv = Devices[psc_channel];
	if(priv == NULL)
		return(-1); // error
	if((reg < 0) || (reg >= 0x80))
		return(-1);
	if(priv->aclink_stopped)
		mcf548x_ac97_warnreset(priv);
	start_timer = MCF_SLT_SCNT(1);
	/* Wait for it to be ready */
	while(!priv->codec_ready || priv->ctrl_mode)
	{
		vTaskDelay(1);
	  if((start_timer - MCF_SLT_SCNT(1)) >= AC97_TIMEOUT_REGISTERS)
		{
			priv->ctrl_mode = 0;
			return(-1); /* timeout */
		}
	}
	/* Do the read - Control Address - Slot #1 */
	level = asm_set_ipl(7);
	priv->ctrl_address = (int)reg;
	priv->ctrl_rw = 1; /* read */
	priv->ctrl_mode = 1;
	start_timer = MCF_SLT_SCNT(1);
	asm_set_ipl(level);
	/* Wait for the answer */
	while(priv->ctrl_mode)
	{
		vTaskDelay(1);
	  if((start_timer - MCF_SLT_SCNT(1)) >= AC97_TIMEOUT_REGISTERS)
		{
			priv->ctrl_mode = 0;
			return(-1); /* timeout */
		}
	}
	return(priv->status_data);
}

int mcf548x_ac97_debug_write(long psc_channel, long reg, long val)
{
	struct mcf548x_ac97_priv *priv;
	unsigned long start_timer;
	int level, count = 0;
	if((psc_channel < 0) || (psc_channel >= 4))
		return(-1); // error
	priv = Devices[psc_channel];
	if(priv == NULL)
		return(-1); // error
	if((reg < 0) || (reg >= 0x80))
		return(-1);
	if(priv->aclink_stopped)
		mcf548x_ac97_warnreset(priv);
	do
	{
		start_timer = MCF_SLT_SCNT(1);
		/* Wait for it to be ready */
		while(!priv->codec_ready || priv->ctrl_mode)
		{
			vTaskDelay(1);
		  if((start_timer - MCF_SLT_SCNT(1)) >= AC97_TIMEOUT_REGISTERS)
			{
				priv->ctrl_mode = 0;
				return(-1); /* timeout */
			}
		}
		/* Write data */
		level = asm_set_ipl(7); /* mask interrupts */
		priv->ctrl_address = (int)reg;
		priv->ctrl_data = (int)val;
		priv->status_data = (int)~val;
		priv->ctrl_rw = 0; /* write */
		priv->ctrl_mode = 1;
		asm_set_ipl(level);
		/* Wait for the answer */
		while(priv->ctrl_mode)
		{
			vTaskDelay(1);
		  if((start_timer - MCF_SLT_SCNT(1)) >= AC97_TIMEOUT_REGISTERS)
			{
				priv->ctrl_mode = 0;
				return(-1); /* timeout */
			}
		}
		count++;
	}
	while((priv->ctrl_data != priv->status_data) && (count < AC97_RETRY_WRITE));
	return(0);
}

#endif /* LWIP */

/* ======================================================================== */
/* Sound driver setup                                                       */
/* ======================================================================== */

#ifdef USE_VRA

static int mcf548x_ac97_test_rate(struct mcf548x_ac97_priv *priv, int reg, unsigned short rate)
{
	unsigned short val;
	mcf548x_ac97_write(priv, reg, rate);
	val = mcf548x_ac97_read(priv, reg);
	return(val == rate);
}

static void mcf548x_ac97_determine_rates(struct mcf548x_ac97_priv *priv, int reg, unsigned int *r_result)
{
	unsigned int result = 0;
	/* let's try to obtain standard rates */
	if(mcf548x_ac97_test_rate(priv, reg, 8000))
		result |= SNDRV_PCM_RATE_8000;
	if(mcf548x_ac97_test_rate(priv, reg, 11025))
		result |= SNDRV_PCM_RATE_11025;
	if(mcf548x_ac97_test_rate(priv, reg, 16000))
		result |= SNDRV_PCM_RATE_16000;
	if(mcf548x_ac97_test_rate(priv, reg, 22050))
		result |= SNDRV_PCM_RATE_22050;
	if(mcf548x_ac97_test_rate(priv, reg, 32000))
		result |= SNDRV_PCM_RATE_32000;
	if(mcf548x_ac97_test_rate(priv, reg, 44100))
		result |= SNDRV_PCM_RATE_44100;
	if(mcf548x_ac97_test_rate(priv, reg, 48000))
		result |= SNDRV_PCM_RATE_48000;
	*r_result = result;
}

#endif /* USE_VRA */

int mcf548x_ac97_install(long psc_channel)
{
	if((psc_channel < 0) || (psc_channel >= 4))
		return(-1); // error
	else
	{
		struct mcf548x_ac97_priv *priv;
#if defined(COLDFIRE) && defined(NETWORK) && defined(LWIP) && defined(CONFIG_USB_MEM_NO_CACHE) && (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI))
		extern unsigned long pxCurrentTCB, tid_TOS;
		extern void *usb_malloc(long amount);
		extern int usb_free(void *addr);
		if(pxCurrentTCB != tid_TOS)
			priv = (struct mcf548x_ac97_priv *)usb_malloc(sizeof(struct mcf548x_ac97_priv));
		else
#endif
		priv = (struct mcf548x_ac97_priv *)Mxalloc(sizeof(struct mcf548x_ac97_priv),2);
		if(priv != NULL)
		{
			/* Init our private structure */
			memset(priv, 0, sizeof(struct mcf548x_ac97_priv));
			Devices[psc_channel] = priv;
			priv->psc_channel = (int)psc_channel;
#ifdef PERIOD
			priv->period_get_frame_min = 0xffffffff;
			priv->period_build_frame_min = 0xffffffff;
#endif
			/* Low level HW Init */
			if(!mcf548x_ac97_bdinit(priv) && !mcf548x_ac97_hwinit(priv))
			{
				priv->id = ((unsigned long)mcf548x_ac97_read(priv, AC97_VENDOR_ID1) << 16) + (unsigned long)mcf548x_ac97_read(priv, AC97_VENDOR_ID2);
				if(priv->id == 0xffffffff)
				{
#ifdef DEBUG
					display_string("mcf548x_ac97_install timeout for read codec ID\r\n");
#else
#if defined(COLDFIRE) && defined(NETWORK) && defined(LWIP) 
					board_printf("CODEC ID read timeout, please try again with TOS started with dBUG\r\n");
#endif
#endif /* DEBUG */
					mcf548x_ac97_uninstall(psc_channel, 1);
					return(-1); // error
				}		
				priv->id &= AC97_ID_CS_MASK;
				if(priv->id != AC97_ID_CS4299)
				{
#ifdef DEBUG
					display_string("mcf548x_ac97_install bad codec ID\r\n");
#else
#if defined(COLDFIRE) && defined(NETWORK) && defined(LWIP) 
					board_printf("BAD CODEC ID (0x%04X)\r\n", priv->id);
#endif
#endif /* DEBUG */
					mcf548x_ac97_uninstall(psc_channel, 1);
					return(-1); // error
				}			
				priv->caps = mcf548x_ac97_read(priv, AC97_RESET);
				priv->ext_id = mcf548x_ac97_read(priv, AC97_EXTENDED_ID);
				if(priv->ext_id == 0xffff)	/* invalid combination */
					priv->ext_id = 0;
#ifdef USE_VRA
				if(priv->ext_id & AC97_EI_VRA)
				{	/* VRA support */
					mcf548x_ac97_write(priv, AC97_EXTENDED_STATUS, mcf548x_ac97_read(priv, AC97_EXTENDED_STATUS) | AC97_EA_VRA);
					mcf548x_ac97_determine_rates(priv, AC97_PCM_FRONT_DAC_RATE, &priv->rates[AC97_RATES_FRONT_DAC]);
					mcf548x_ac97_determine_rates(priv, AC97_PCM_LR_ADC_RATE, &priv->rates[AC97_RATES_ADC]);
				}
				else
#endif
				{
					priv->rates[AC97_RATES_FRONT_DAC] = SNDRV_PCM_RATE_48000;
					priv->rates[AC97_RATES_ADC] = SNDRV_PCM_RATE_48000;
				}
				priv->powerdown = mcf548x_ac97_read(priv, AC97_POWERDOWN);
				if(!old_timer_vector)
				{
#if defined(COLDFIRE) && defined(NETWORK) && defined(LWIP) && defined(CONFIG_USB_MEM_NO_CACHE) && (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI))
					if(pxCurrentTCB != tid_TOS)
					{
						old_timer_vector = *(long *)(69 * 4);
						*(long *)(69 * 4) = (long)timer_ac97_interrupt; /* 200 Hz MFP timer C */
					}
					else
#endif
						old_timer_vector = install_xbra(69, timer_ac97_interrupt); /* 200 Hz MFP timer C */
				}
#ifdef PERIOD
				priv->period_get_frame_min = 0xffffffff;
				priv->period_build_frame_min = 0xffffffff;
				priv->period_get_frame_max = 0;
				priv->period_build_frame_max = 0;
#endif /* PERIOD */
#ifdef EMUL_DMA_STE
				DMA_CONTROL = 0;
				DMA_START_ADDRESS_HIGH = 0;
				DMA_START_ADDRESS_MID = 0;
				DMA_START_ADDRESS_LOW = 0; 
				DMA_END_ADDRESS_HIGH = 0;
				DMA_END_ADDRESS_MID = 0;
				DMA_END_ADDRESS_LOW = 0;
				DMA_MODE_CONTROL = 0;
#endif /* EMUL_DMA_STE */
				return(0);				
			}
		}
		if(priv != NULL)
		{
#if defined(COLDFIRE) && defined(NETWORK) && defined(LWIP) && defined(CONFIG_USB_MEM_NO_CACHE) && (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI))
			if(pxCurrentTCB != tid_TOS)
				usb_free(priv);
			else
#endif
			  Mfree(priv);
		}
		return(-1); // error
	}
}

int mcf548x_ac97_uninstall(long psc_channel, int free)
{
	struct mcf548x_ac97_priv *priv;
#if defined(COLDFIRE) && defined(NETWORK) && defined(LWIP) && defined(CONFIG_USB_MEM_NO_CACHE) && (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI))
	extern unsigned long pxCurrentTCB, tid_TOS;
	extern int usb_free(void *addr);
#endif
	if((psc_channel < 0) || (psc_channel >= 4))
		return(-1); // error
	priv = Devices[psc_channel];
	if(priv == NULL)
		return(-1); // error
	mcf548x_ac97_hwstop(priv);
	if(free)
	{
#ifdef USE_DMA
		if(priv->buffer != NULL)
#if (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_MEM_NO_CACHE)
			usb_free(priv->buffer);
#else
			Mfree(priv->buffer);
#endif
#endif /* USE_DMA */
		Devices[psc_channel] = NULL;
#if defined(COLDFIRE) && defined(NETWORK) && defined(LWIP) && defined(CONFIG_USB_MEM_NO_CACHE) && (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI))
		if(pxCurrentTCB != tid_TOS)
			usb_free(priv);
		else
#endif
			Mfree(priv);
	}
	return(0);
}

#endif /* NETWORK */
#endif /* SOUND_AC97 */
