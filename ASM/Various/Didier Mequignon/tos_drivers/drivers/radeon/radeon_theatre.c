#include "radeonfb.h"
#include <string.h>

#ifdef RADEON_THEATRE

extern unsigned long len_theatre_dsp;
extern unsigned char theatre_dsp[];
extern unsigned long swap_long(unsigned long val);
extern unsigned int LZ_Uncompress(unsigned char *in, unsigned char *out, unsigned int insize);

static int theatre_read(TheatrePtr t,unsigned long reg, unsigned long *data)
{
	if(t->theatre_num<0)
		return FALSE;
	return(RADEONVIP_read(t->rinfo, ((t->theatre_num & 0x3)<<14) | reg, 4, (unsigned char *) data));
}

static int theatre_write(TheatrePtr t,unsigned long reg, unsigned long data)
{
	if(t->theatre_num<0)
		return FALSE;
	return(RADEONVIP_write(t->rinfo, ((t->theatre_num & 0x03)<<14) | reg, 4, (unsigned char *) &data));
}

static int theatre_fifo_read(TheatrePtr t, unsigned long fifo, unsigned char *data)
{
	if(t->theatre_num<0)
		return FALSE;
	return(RADEONVIP_fifo_read(t->rinfo, ((t->theatre_num & 0x3)<<14) | fifo, 1, (unsigned char *) data));
}

static int theatre_fifo_write(TheatrePtr t, unsigned long fifo, unsigned long count, unsigned char *buffer)
{
	if(t->theatre_num<0)
		return FALSE;
	return(RADEONVIP_fifo_write(t->rinfo, ((t->theatre_num & 0x03)<<14) | fifo,count, (unsigned char *)buffer));
}

#define RT_regr(reg,data)	theatre_read(t,(reg),(data))
#define RT_regw(reg,data)	theatre_write(t,(reg),(data))
#define RT_fifor(fifo,data)			theatre_fifo_read(t,(fifo),(data))
#define RT_fifow(fifo,count,data)	theatre_fifo_write(t,(fifo),(count),(data))

static int microc_load(struct rt200_microc_data *microc_datap)
{
	struct rt200_microc_head *microc_headp = &microc_datap->microc_head;
	struct rt200_microc_seg *seg_list = NULL;
	struct rt200_microc_seg *curr_seg = NULL;
	struct rt200_microc_seg *prev_seg = NULL;
	int i;
	char *temp_buf, *buf;
	unsigned long *ptr;
	temp_buf = (char *)Mxalloc(*(long *)theatre_dsp + 4, 2);
	DPRINTVALHEX("Rage Theatre: Uncompress microcode at ", (long)(theatre_dsp+4));
	DPRINTVAL(" (", len_theatre_dsp);
	DPRINTVALHEX(") to ", (long)temp_buf);
	DPRINTVAL(" (", *(long *)theatre_dsp);
	DPRINT(")\r\n");
	if(temp_buf == NULL)
	{
		DPRINT("Rage Theatre: Cannot allocate memory\r\n");
		return -1;
	}
	LZ_Uncompress(theatre_dsp+4, temp_buf, len_theatre_dsp);
	buf = temp_buf;
	microc_headp->device_id = swap_long(*(unsigned long *)&buf[0]);
	microc_headp->vendor_id = swap_long(*(unsigned long *)&buf[4]);
	microc_headp->revision_id = swap_long(*(unsigned long *)&buf[8]);
	microc_headp->num_seg = swap_long(*(unsigned long *)&buf[12]);
	buf += 16;
	DPRINTVALHEX("Rage Theatre: Microcode: num_seg: ", microc_headp->num_seg);
	DPRINT("\r\n");
	if(microc_headp->num_seg == 0)
		goto fail_exit;
	for(i = 0; i < microc_headp->num_seg; i++)
	{
		curr_seg = (struct rt200_microc_seg*)Mxalloc(sizeof(struct rt200_microc_seg), 2);
		if(curr_seg == NULL)
		{
			DPRINT("Rage Theatre: Cannot allocate memory\r\n");
			goto fail_exit;
		}
		curr_seg->num_bytes = swap_long(*(unsigned long *)&buf[0]);
		curr_seg->download_dst = swap_long(*(unsigned long *)&buf[4]);
		curr_seg->crc_val = swap_long(*(unsigned long *)&buf[8]);
		buf += 12;
		curr_seg->data = (unsigned char*)Mxalloc(curr_seg->num_bytes, 2);
		if(curr_seg->data == NULL)
		{
			DPRINT("Rage Theatre: Cannot allocate memory\r\n");
			goto fail_exit;
		}
		DPRINTVALHEX("Rage Theatre: Microcode: segment number: ", i);
		DPRINTVALHEX("\r\nRage Theatre: Microcode: curr_seg->num_bytes: ", curr_seg->num_bytes);
		DPRINTVALHEX("\r\nRage Theatre: Microcode: curr_seg->download_dst: ", curr_seg->download_dst);
		DPRINTVALHEX("\r\nRage Theatre: Microcode: curr_seg->crc_val: ", curr_seg->crc_val);
		DPRINT("\r\n");
		if(seg_list)
		{
			prev_seg->next = curr_seg;
			curr_seg->next = NULL;
			prev_seg = curr_seg;
		}
		else
			seg_list = prev_seg = curr_seg;
	}
	curr_seg = seg_list;
	while(curr_seg)
	{
		i = (int)curr_seg->num_bytes >>	2;
		ptr = (unsigned long *)curr_seg->data;
		while(--i >= 0)
		{
			*ptr++ = swap_long(*(unsigned long *)buf);
			buf += 4;
		}
		curr_seg = curr_seg->next;
	}
	microc_datap->microc_seg_list = seg_list;
	Mfree(temp_buf);
	return 0;
fail_exit:
	curr_seg = seg_list;
	while(curr_seg)
	{
		Mfree(curr_seg->data);
		prev_seg = curr_seg;
		curr_seg = curr_seg->next;
		Mfree(prev_seg);
	}
	Mfree(temp_buf);
	return -1;
}

static void microc_clean(struct rt200_microc_data *microc_datap)
{
	struct rt200_microc_seg *seg_list = microc_datap->microc_seg_list;
	struct rt200_microc_seg *prev_seg;
	while(seg_list)
	{
		Mfree(seg_list->data);
		prev_seg = seg_list;
		seg_list = seg_list->next;
		Mfree(prev_seg);
	}
}

static int dsp_init(TheatrePtr t, struct rt200_microc_data *microc_datap)
{
	unsigned long data;
	int i = 0;
	/* Map FIFOD to DSP Port I/O port */
	RT_regr(VIP_HOSTINTF_PORT_CNTL, &data);
	RT_regw(VIP_HOSTINTF_PORT_CNTL, data & (~VIP_HOSTINTF_PORT_CNTL__FIFO_RW_MODE));
	/* The default endianess is LE. It matches the ost one for x86 */
	RT_regr(VIP_HOSTINTF_PORT_CNTL, &data);
	RT_regw(VIP_HOSTINTF_PORT_CNTL, data & (~VIP_HOSTINTF_PORT_CNTL__FIFOD_ENDIAN_SWAP));
	/* Wait until Shuttle bus channel 14 is available */
	RT_regr(VIP_TC_STATUS, &data);
	while(((data & VIP_TC_STATUS__TC_CHAN_BUSY) & 0x00004000) && (i++ < 10000))
		RT_regr(VIP_TC_STATUS, &data);
	DPRINT("Rage Theatre: Microcode: dsp_init: channel 14 available\r\n"); 
	return 0;
}

static unsigned long dsp_send_command(TheatrePtr t, unsigned long fb_scratch1, unsigned long fb_scratch0)
{
	unsigned long data;
	int i;
	/* Clear the FB_INT0 bit in INT_CNTL */
	RT_regr(VIP_INT_CNTL, &data);
	RT_regw(VIP_INT_CNTL, data | VIP_INT_CNTL__FB_INT0_CLR);
	/* Write FB_SCRATCHx registers. If FB_SCRATCH1==0 then we have a DWORD command */
	RT_regw(VIP_FB_SCRATCH0, fb_scratch0);
	if (fb_scratch1 != 0)
		RT_regw(VIP_FB_SCRATCH1, fb_scratch1);	
	/* Attention DSP. We are talking to you */
	RT_regr(VIP_FB_INT, &data);
	RT_regw(VIP_FB_INT, data | VIP_FB_INT__INT_7);
	/* Wait (by polling) for the DSP to process the command */
	i = 0;
	RT_regr(VIP_INT_CNTL, &data);
	while((!(data & VIP_INT_CNTL__FB_INT0)) /*&& (i++ < 10000)*/)
		RT_regr(VIP_INT_CNTL, &data);
	/* The return code is in FB_SCRATCH0 */
	RT_regr(VIP_FB_SCRATCH0, &fb_scratch0);
	/* If we are here it means we got an answer. Clear the FB_INT0 bit */
	RT_regr(VIP_INT_CNTL, &data);
	RT_regw(VIP_INT_CNTL, data | VIP_INT_CNTL__FB_INT0_CLR);
	return fb_scratch0;
}

static int dsp_load(TheatrePtr t, struct rt200_microc_data* microc_datap)
{
	struct rt200_microc_seg *seg_list = microc_datap->microc_seg_list;
	unsigned char	data8;
	unsigned long data, fb_scratch0, fb_scratch1;
	unsigned long i;
	unsigned long tries = 0;
	unsigned long result = 0;
	unsigned long seg_id = 0;
	DPRINTVALHEX("Rage Theatre: Microcode: before everything: ", data8);
	DPRINT("\r\n");
	if(RT_fifor(0x000, &data8))
	{
		DPRINTVALHEX("Rage Theatre: Microcode: FIFO status0: ", data8);
		DPRINT("\r\n");
	}
	else
	{
		DPRINT("Rage Theatre: Microcode: error reading FIFO status0\r\n");
		return -1;
	}
	if(RT_fifor(0x100, &data8))
	{
		DPRINTVALHEX("Rage Theatre: Microcode: FIFO status1: ", data8);
		DPRINT("\r\n");
	}
	else
	{
		DPRINT("Rage Theatre: Microcode: error reading FIFO status1\r\n");
		return -1;
	}
	/* Download the Boot Code and CRC Checking Code (first segment) */
	seg_id = 1;
	while(result != DSP_OK && tries < 10)
	{
		/* Put DSP in reset before download (0x02) */
		RT_regr(VIP_TC_DOWNLOAD, &data);
		RT_regw(VIP_TC_DOWNLOAD, (data & ~VIP_TC_DOWNLOAD__TC_RESET_MODE) | (0x02 << 17));		 
		/* Configure shuttle bus for tranfer between DSP I/O "Program Interface"
		   and Program Memory at address 0 */
		RT_regw(VIP_TC_SOURCE, 0x90000000);
		RT_regw(VIP_TC_DESTINATION, 0x00000000);
		RT_regw(VIP_TC_COMMAND, 0xe0000044 | ((seg_list->num_bytes - 1) << 7));
		/* Load first segment */
		DPRINT("Rage Theatre: Microcode: Loading first segment\r\n");
		if(!RT_fifow(0x700, seg_list->num_bytes, seg_list->data))
		{
			DPRINT("Rage Theatre: Microcode: write to FIFOD failed\r\n");
			return -1;
		}
		/* Wait until Shuttle bus channel 14 is available */
		i = data = 0;
		RT_regr(VIP_TC_STATUS, &data);
		while(((data & VIP_TC_STATUS__TC_CHAN_BUSY) & 0x00004000) && (i++ < 10000))
			RT_regr(VIP_TC_STATUS, &data);
		if(i >= 10000)
		{
			DPRINT("Rage Theatre: Microcode: channel 14 timeout\r\n");
			return -1;
		}
		DPRINT("Rage Theatre: Microcode: dsp_load: checkpoint 1\r\n");
		DPRINTVALHEX("Rage Theatre: Microcode: TC_STATUS: ", data);
		DPRINT("\r\n");
		/* transfer the code from program memory to data memory */
		RT_regw(VIP_TC_SOURCE, 0x00000000);
		RT_regw(VIP_TC_DESTINATION, 0x10000000);
		RT_regw(VIP_TC_COMMAND, 0xe0000006 | ((seg_list->num_bytes - 1) << 7));
		/* Wait until Shuttle bus channel 14 is available */
		i = data = 0;
		RT_regr(VIP_TC_STATUS, &data);
		while(((data & VIP_TC_STATUS__TC_CHAN_BUSY) & 0x00004000) && (i++ < 10000))
			RT_regr(VIP_TC_STATUS, &data);			 
		if(i >= 10000)
		{
			DPRINT("Rage Theatre: Microcode: channel 14 timeout\r\n");
			return -1;
		}
		DPRINT("Rage Theatre: Microcode: dsp_load: checkpoint 2\r\n");
		DPRINTVALHEX("Rage Theatre: Microcode: TC_STATUS: ", data);
		DPRINT("\r\n");
		/* Take DSP out from reset (0x0) */
		data = 0;
		RT_regr(VIP_TC_DOWNLOAD, &data);
		RT_regw(VIP_TC_DOWNLOAD, data & ~VIP_TC_DOWNLOAD__TC_RESET_MODE);
		RT_regr(VIP_TC_STATUS, &data);
		DPRINT("Rage Theatre: Microcode: dsp_load: checkpoint 3\r\n");
		DPRINTVALHEX("Rage Theatre: Microcode: TC_STATUS: ", data);
		DPRINT("\r\n");
		/* send dsp_download_check_CRC */
		fb_scratch0 = ((seg_list->num_bytes << 16) & 0xffff0000) | ((seg_id << 8) & 0xff00) | (0xff & 193);
		fb_scratch1 = (unsigned int)seg_list->crc_val;			 
		result = dsp_send_command(t, fb_scratch1, fb_scratch0);
		DPRINT("Rage Theatre: Microcode: dsp_load: checkpoint 4\r\n");
	}
	if(tries >= 10)
	{
		DPRINT("Rage Theatre: Microcode: Download of boot degment failed\r\n");
		return -1;
	}
	DPRINT("Rage Theatre: Microcode: Download of boot code succeeded\r\n");
	while((seg_list = seg_list->next) != NULL)
	{
		seg_id++;
		result = tries = 0;
		while(result != DSP_OK && tries < 10)
		{
			/* Configure shuttle bus for tranfer between DSP I/O "Program Interface"
			   and Data Memory at address 0 */
			RT_regw(VIP_TC_SOURCE, 0x90000000);
			RT_regw(VIP_TC_DESTINATION, 0x10000000);
			RT_regw(VIP_TC_COMMAND, 0xe0000044 | ((seg_list->num_bytes - 1) << 7));
			if(!RT_fifow(0x700, seg_list->num_bytes, seg_list->data))
			{
				DPRINT("Rage Theatre: Microcode: write to FIFOD failed\r\n");
				return -1;
			}								
			i = data = 0;
			RT_regr(VIP_TC_STATUS, &data);
			while(((data & VIP_TC_STATUS__TC_CHAN_BUSY) & 0x00004000) && (i++ < 10000))
				RT_regr(VIP_TC_STATUS, &data);								
			/* send dsp_download_check_CRC */
			fb_scratch0 = ((seg_list->num_bytes << 16) & 0xffff0000) | ((seg_id << 8) & 0xff00) | (0xff & 193);
			fb_scratch1 = (unsigned int)seg_list->crc_val;
			result = dsp_send_command(t, fb_scratch1, fb_scratch0);
		}
		if(i >=10)
		{
			DPRINTVALHEX("Rage Theatre: Microcode: DSP failed to move seg: ", seg_id);
			DPRINT(" from data to code memory\r\n");
			return -1;
		}
		DPRINTVALHEX("Rage Theatre: Microcode: segment: ", seg_id);
		DPRINT(" loaded\r\n");
		/* The segment is downloaded correctly to data memory. Now move it to code memory
		   by using dsp_download_code_transfer command */
		fb_scratch0 = ((seg_list->num_bytes << 16) & 0xffff0000) | ((seg_id << 8) & 0xff00) | (0xff & 194);
		fb_scratch1 = (unsigned int)seg_list->download_dst;						
		result = dsp_send_command(t, fb_scratch1, fb_scratch0);
		if(result != DSP_OK)
		{
			DPRINTVALHEX("Rage Theatre: Microcode: DSP failed to move seg: ", seg_id);
			DPRINT(" from data to code memory\r\n");
			return -1;
		}
	}
	DPRINT("Rage Theatre: Microcode: download complete\r\n");
	/* The last step is sending dsp_download_check_CRC with "download complete" */
	fb_scratch0 = ((165 << 8) & 0xff00) | (0xff & 193);
	fb_scratch1 = (unsigned int)0x11111;					
	result = dsp_send_command(t, fb_scratch1, fb_scratch0);
	if(result == DSP_OK)
		DPRINT("Rage Theatre: Microcode: DSP microcode successfully loaded\r\n");
	else
	{
		DPRINT("Rage Theatre: Microcode: DSP microcode UNsuccessfully loaded\r\n");
		return -1;
	}
	return 0;
}

static unsigned long dsp_set_video_input_connector(TheatrePtr t, unsigned long connector)
{
	unsigned long fb_scratch0 = 0;
	unsigned long result;
	fb_scratch0 = ((connector << 8) & 0xff00) | (55 & 0xff);
	result = dsp_send_command(t, 0, fb_scratch0);
	DPRINTVALHEX("Rage Theatre: dsp_set_video_input_connector: ", connector);
	DPRINTVALHEX(", result: ", result);
	DPRINT("\r\n");
	return result;
}

#if 0
static unsigned long dsp_reset(TheatrePtr t)
{
	unsigned long fb_scratch0 = 0;
	unsigned long result;
	fb_scratch0 = ((2 << 8) & 0xff00) | (8 & 0xff);
	result = dsp_send_command(t, 0, fb_scratch0);
	DPRINTVALHEX("Rage Theatre: dsp_reset: ", result);
	DPRINT("\r\n");
	return result;
}
#endif

static unsigned long dsp_set_lowpowerstate(TheatrePtr t, unsigned long pstate)
{
	unsigned long fb_scratch0 = 0;
	unsigned long result;
	fb_scratch0 = ((pstate << 8) & 0xff00) | (82 & 0xff);
	result = dsp_send_command(t, 0, fb_scratch0);
	DPRINTVALHEX("Rage Theatre: dsp_set_lowpowerstate: ", result);
	DPRINT("\r\n");
	return result;
}
static unsigned long dsp_set_video_standard(TheatrePtr t, unsigned long standard)
{
	unsigned long fb_scratch0 = 0;
	unsigned long result;
	fb_scratch0 = ((standard << 8) & 0xff00) | (52 & 0xff);
	result = dsp_send_command(t, 0, fb_scratch0);
	DPRINTVALHEX("Rage Theatre: dsp_set_video_standard: ", result);
	DPRINT("\r\n");
	return result;
}

static unsigned long dsp_set_videostreamformat(TheatrePtr t, unsigned long format)
{
	unsigned long fb_scratch0 = 0;
	unsigned long result;
	fb_scratch0 = ((format << 8) & 0xff00) | (65 & 0xff);
	result = dsp_send_command(t, 0, fb_scratch0);
	DPRINTVALHEX("Rage Theatre: dsp_set_videostreamformat: ", result);
	DPRINT("\r\n");
	return result;
}

static unsigned long dsp_video_standard_detection(TheatrePtr t)
{
	unsigned long fb_scratch0 = 0;
	unsigned long result;
	fb_scratch0 = 0 | (54 & 0xff);
	result = dsp_send_command(t, 0, fb_scratch0);
	DPRINTVALHEX("Rage Theatre: dsp_video_standard_detection: ", result);
	DPRINT("\r\n");
	return result;
}

#if 0
static unsigned long dsp_get_signallockstatus(TheatrePtr t)
{
	unsigned long fb_scratch1 = 0;
	unsigned long fb_scratch0 = 0;
	unsigned long result;
	fb_scratch0 = 0 | (77 & 0xff);
	result = dsp_send_command(t, fb_scratch1, fb_scratch0);
	DPRINTVALHEX("Rage Theatre: dsp_get_signallockstatus: ", result);
	DPRINTVALHEX(", h_pll: ", (result >> 8) & 0xff);
	DPRINTVALHEX(", v_pll: ", (result >> 16) & 0xff);
	DPRINT("\r\n");
	return result;
}
#endif

#if 0
static unsigned long dsp_get_signallinenumber(TheatrePtr t)
{
	unsigned long fb_scratch1 = 0;
	unsigned long fb_scratch0 = 0;
	unsigned long result;
	fb_scratch0 = 0 | (78 & 0xff);
	result = dsp_send_command(t, fb_scratch1, fb_scratch0);
	DPRINTVALHEX("Rage Theatre: dsp_get_signallinenumber: ", result);
	DPRINTVALHEX(", linenum: ", (result >> 8) & 0xffff);
	DPRINT("\r\n");
	return result;
}
#endif

static unsigned long dsp_set_brightness(TheatrePtr t, unsigned char brightness)
{
	unsigned long fb_scratch1 = 0;
	unsigned long fb_scratch0 = 0;
	unsigned long result;
	fb_scratch0 = ((brightness << 8) & 0xff00) | (67 & 0xff);
	result = dsp_send_command(t, fb_scratch1, fb_scratch0);
	DPRINTVALHEX("Rage Theatre: dsp_set_brightness: ", result);
	DPRINT("\r\n");
	return result;
}

static unsigned long dsp_set_contrast(TheatrePtr t, unsigned char contrast)
{
	unsigned long fb_scratch1 = 0;
	unsigned long fb_scratch0 = 0;
	unsigned long result;
	fb_scratch0 = ((contrast << 8) & 0xff00) | (71 & 0xff);
	result = dsp_send_command(t, fb_scratch1, fb_scratch0);
	DPRINTVALHEX("Rage Theatre: dsp_set_contrast: ", result);
	DPRINT("\r\n");
	return result;
}

#if 0
static unsigned long dsp_set_sharpness(TheatrePtr t, int sharpness)
{
	unsigned long fb_scratch1 = 0;
	unsigned long fb_scratch0 = 0;
	unsigned long result;
	fb_scratch0 = 0 | (73 & 0xff);
	result = dsp_send_command(t, fb_scratch1, fb_scratch0);
	DPRINTVALHEX("Rage Theatre: dsp_set_sharpness: ", result);
	DPRINT("\r\n");
	return result;
}
#endif

static unsigned long dsp_set_tint(TheatrePtr t, unsigned char tint)
{
	unsigned long fb_scratch1 = 0;
	unsigned long fb_scratch0 = 0;
	unsigned long result;
	fb_scratch0 = ((tint << 8) & 0xff00) | (75 & 0xff);
	result = dsp_send_command(t, fb_scratch1, fb_scratch0);
	DPRINTVALHEX("Rage Theatre: dsp_set_tint: ", result);
	DPRINT("\r\n");
	return result;
}

static unsigned long dsp_set_saturation(TheatrePtr t, unsigned char saturation)
{
	unsigned long fb_scratch1 = 0;
	unsigned long fb_scratch0 = 0;
	unsigned long result;
	fb_scratch0 = ((saturation << 8) & 0xff00) | (69 & 0xff);
	result = dsp_send_command(t, fb_scratch1, fb_scratch0);
	DPRINTVALHEX("Rage Theatre: dsp_set_saturation: ", result);
	DPRINT("\r\n");
	return result;
}

static unsigned long dsp_set_video_scaler_horizontal(TheatrePtr t, unsigned short output_width, unsigned short horz_start, unsigned short horz_end)
{
	unsigned long fb_scratch1 = 0;
	unsigned long fb_scratch0 = 0;
	unsigned long result;
	fb_scratch0 = ((output_width << 8) & 0x00ffff00) | (195 & 0xff);
	fb_scratch1 = ((horz_end << 16) & 0xffff0000) | (horz_start & 0xffff);
	result = dsp_send_command(t, fb_scratch1, fb_scratch0);
	DPRINTVALHEX("Rage Theatre: dsp_set_video_scaler_horizontal: ", result);
	DPRINT("\r\n");
	return result;
}

static unsigned long dsp_set_video_scaler_vertical(TheatrePtr t, unsigned short output_height, unsigned short vert_start, unsigned short vert_end)
{
	unsigned long fb_scratch1 = 0;
	unsigned long fb_scratch0 = 0;
	unsigned long result;
	fb_scratch0 = ((output_height << 8) & 0x00ffff00) | (196 & 0xff);
	fb_scratch1 = ((vert_end << 16) & 0xffff0000) | (vert_start & 0xffff);
	result = dsp_send_command(t, fb_scratch1, fb_scratch0);
	DPRINTVALHEX("Rage Theatre: dsp_set_video_scaler_vertical: ", result);
	DPRINT("\r\n");
	return result;
}

static unsigned long dsp_audio_mute(TheatrePtr t, unsigned char left, unsigned char right)
{
	unsigned long fb_scratch1 = 0;
	unsigned long fb_scratch0 = 0;
	unsigned long result;
	fb_scratch0 = ((right << 16) & 0xff0000) | ((left << 8) & 0xff00) | (21 & 0xff);
	result = dsp_send_command(t, fb_scratch1, fb_scratch0);
	DPRINTVALHEX("Rage Theatre: dsp_audio_mute: ", result);
	DPRINT("\r\n");
	return result;
}

static unsigned long dsp_set_audio_volume(TheatrePtr t, unsigned char left, unsigned char right, unsigned char auto_mute)
{
	unsigned long fb_scratch1 = 0;
	unsigned long fb_scratch0 = 0;
	unsigned long result;
	fb_scratch0 = ((auto_mute << 24) & 0xff000000) | ((right << 16) & 0xff0000) | ((left << 8) & 0xff00) | (22 & 0xff);
	result = dsp_send_command(t, fb_scratch1, fb_scratch0);
	DPRINTVALHEX("Rage Theatre: dsp_set_audio_volume: ", result);
	DPRINT("\r\n");
	return result;
}

static unsigned long dsp_audio_detection(TheatrePtr t, unsigned char option)
{
	unsigned long fb_scratch1 = 0;
	unsigned long fb_scratch0 = 0;
	unsigned long result;
	fb_scratch0 = ((option << 8) & 0xff00) | (16 & 0xff);
	result = dsp_send_command(t, fb_scratch1, fb_scratch0);
	DPRINTVALHEX("Rage Theatre: dsp_audio_detection: ", result);
	DPRINT("\r\n");
	return result;
}

static unsigned long dsp_configure_i2s_port(TheatrePtr t, unsigned char tx_mode, unsigned char rx_mode, unsigned char clk_mode)
{
	unsigned long fb_scratch1 = 0;
	unsigned long fb_scratch0 = 0;
	unsigned long result;
	fb_scratch0 = ((clk_mode << 24) & 0xff000000) | ((rx_mode << 16) & 0xff0000) | ((tx_mode << 8) & 0xff00) | (40 & 0xff);
	result = dsp_send_command(t, fb_scratch1, fb_scratch0);
	DPRINTVALHEX("Rage Theatre: dsp_configure_i2s_port: ", result);
	DPRINT("\r\n");
	return result;
}

static unsigned long dsp_configure_spdif_port(TheatrePtr t, unsigned char state)
{
	unsigned long fb_scratch1 = 0;
	unsigned long fb_scratch0 = 0;
	unsigned long result;
	fb_scratch0 = ((state << 8) & 0xff00) | (41 & 0xff);
	result = dsp_send_command(t, fb_scratch1, fb_scratch0);
	DPRINTVALHEX("Rage Theatre: dsp_configure_spdif_port: ", result);
	DPRINT("\r\n");
	return result;
}

enum
{
fld_tmpReg1=0,
fld_tmpReg2,
fld_tmpReg3,
fld_LP_CONTRAST,
fld_LP_BRIGHTNESS,
fld_CP_HUE_CNTL,
fld_LUMA_FILTER,
fld_H_SCALE_RATIO,
fld_H_SHARPNESS,
fld_V_SCALE_RATIO,
fld_V_DEINTERLACE_ON,
fld_V_BYPSS,
fld_V_DITHER_ON,
fld_EVENF_OFFSET,
fld_ODDF_OFFSET,
fld_INTERLACE_DETECTED,
fld_VS_LINE_COUNT,
fld_VS_DETECTED_LINES,
fld_VS_ITU656_VB,
fld_VBI_CC_DATA,
fld_VBI_CC_WT,
fld_VBI_CC_WT_ACK,
fld_VBI_CC_HOLD,
fld_VBI_DECODE_EN,
fld_VBI_CC_DTO_P,
fld_VBI_20BIT_DTO_P,
fld_VBI_CC_LEVEL,
fld_VBI_20BIT_LEVEL,
fld_VBI_CLK_RUNIN_GAIN,
fld_H_VBI_WIND_START,
fld_H_VBI_WIND_END,
fld_V_VBI_WIND_START,
fld_V_VBI_WIND_END,
fld_VBI_20BIT_DATA0,
fld_VBI_20BIT_DATA1,
fld_VBI_20BIT_WT,
fld_VBI_20BIT_WT_ACK,
fld_VBI_20BIT_HOLD,
fld_VBI_CAPTURE_ENABLE,
fld_VBI_EDS_DATA,
fld_VBI_EDS_WT,
fld_VBI_EDS_WT_ACK,
fld_VBI_EDS_HOLD,
fld_VBI_SCALING_RATIO,
fld_VBI_ALIGNER_ENABLE,
fld_H_ACTIVE_START,
fld_H_ACTIVE_END,
fld_V_ACTIVE_START,
fld_V_ACTIVE_END,
fld_CH_HEIGHT,
fld_CH_KILL_LEVEL,
fld_CH_AGC_ERROR_LIM,
fld_CH_AGC_FILTER_EN,
fld_CH_AGC_LOOP_SPEED,
fld_HUE_ADJ,
fld_STANDARD_SEL,
fld_STANDARD_YC,
fld_ADC_PDWN,
fld_INPUT_SELECT,
fld_ADC_PREFLO,
fld_H_SYNC_PULSE_WIDTH,
fld_HS_GENLOCKED,
fld_HS_SYNC_IN_WIN,
fld_VIN_ASYNC_RST,
fld_DVS_ASYNC_RST,
fld_VIP_VENDOR_ID,
fld_VIP_DEVICE_ID,
fld_VIP_REVISION_ID,
fld_BLACK_INT_START,
fld_BLACK_INT_LENGTH,
fld_UV_INT_START,
fld_U_INT_LENGTH,
fld_V_INT_LENGTH,
fld_CRDR_ACTIVE_GAIN,
fld_CBDB_ACTIVE_GAIN,
fld_DVS_DIRECTION,
fld_DVS_VBI_CARD8_SWAP,
fld_DVS_CLK_SELECT,
fld_CONTINUOUS_STREAM,
fld_DVSOUT_CLK_DRV,
fld_DVSOUT_DATA_DRV,
fld_COMB_CNTL0,
fld_COMB_CNTL1,
fld_COMB_CNTL2,
fld_COMB_LENGTH,
fld_SYNCTIP_REF0,
fld_SYNCTIP_REF1,
fld_CLAMP_REF,
fld_AGC_PEAKWHITE,
fld_VBI_PEAKWHITE,
fld_WPA_THRESHOLD,
fld_WPA_TRIGGER_LO,
fld_WPA_TRIGGER_HIGH,
fld_LOCKOUT_START,
fld_LOCKOUT_END,
fld_CH_DTO_INC,
fld_PLL_SGAIN,
fld_PLL_FGAIN,
fld_CR_BURST_GAIN,
fld_CB_BURST_GAIN,
fld_VERT_LOCKOUT_START,
fld_VERT_LOCKOUT_END,
fld_H_IN_WIND_START,
fld_V_IN_WIND_START,
fld_H_OUT_WIND_WIDTH,
fld_V_OUT_WIND_WIDTH,
fld_HS_LINE_TOTAL,
fld_MIN_PULSE_WIDTH,
fld_MAX_PULSE_WIDTH,
fld_WIN_CLOSE_LIMIT,
fld_WIN_OPEN_LIMIT,
fld_VSYNC_INT_TRIGGER,
fld_VSYNC_INT_HOLD,
fld_VIN_M0,
fld_VIN_N0,
fld_MNFLIP_EN,
fld_VIN_P,
fld_REG_CLK_SEL,
fld_VIN_M1,
fld_VIN_N1,
fld_VIN_DRIVER_SEL,
fld_VIN_MNFLIP_REQ,
fld_VIN_MNFLIP_DONE,
fld_TV_LOCK_TO_VIN,
fld_TV_P_FOR_WINCLK,
fld_VINRST,
fld_VIN_CLK_SEL,
fld_VS_FIELD_BLANK_START,
fld_VS_FIELD_BLANK_END,
fld_VS_FIELD_IDLOCATION,
fld_VS_FRAME_TOTAL,
fld_SYNC_TIP_START,
fld_SYNC_TIP_LENGTH,
fld_GAIN_FORCE_DATA,
fld_GAIN_FORCE_EN,
fld_I_CLAMP_SEL,
fld_I_AGC_SEL,
fld_EXT_CLAMP_CAP,
fld_EXT_AGC_CAP,
fld_DECI_DITHER_EN,
fld_ADC_PREFHI,
fld_ADC_CH_GAIN_SEL,
fld_HS_PLL_SGAIN,
fld_NREn,
fld_NRGainCntl,
fld_NRBWTresh,
fld_NRGCTresh,
fld_NRCoefDespeclMode,
fld_GPIO_5_OE,
fld_GPIO_6_OE,
fld_GPIO_5_OUT,
fld_GPIO_6_OUT,

regRT_MAX_REGS
} a;

typedef struct
{
	unsigned char size;
	unsigned long fld_id;
	unsigned long dwRegAddrLSBs;
	unsigned long dwFldOffsetLSBs;
	unsigned long dwMaskLSBs;
	unsigned long addr2;
	unsigned long offs2;
	unsigned long mask2;
	unsigned long dwCurrValue;
	unsigned long rw;
} RTREGMAP;

#define READONLY 1
#define WRITEONLY 2
#define READWRITE 3

/* Rage Theatre's Register Mappings, including the default values: */
RTREGMAP RT_RegMap[regRT_MAX_REGS]={
/*
{size, fidname, AddrOfst, Ofst, Mask, Addr, Ofst, Mask, Cur, R/W
*/
{32 , fld_tmpReg1       ,0x151                          , 0, 0x0, 0, 0,0, 0,READWRITE },
{1  , fld_tmpReg2       ,VIP_VIP_SUB_VENDOR_DEVICE_ID   , 3, 0xFFFFFFFF, 0, 0,0, 0,READWRITE },
{1  , fld_tmpReg3       ,VIP_VIP_COMMAND_STATUS         , 3, 0xFFFFFFFF, 0, 0,0, 0,READWRITE },
{8  , fld_LP_CONTRAST   ,VIP_LP_CONTRAST            ,  0, 0xFFFFFF00, 0, 0,0, fld_LP_CONTRAST_def       ,READWRITE  },
{14 , fld_LP_BRIGHTNESS ,VIP_LP_BRIGHTNESS          ,  0, 0xFFFFC000, 0, 0,0, fld_LP_BRIGHTNESS_def     ,READWRITE  },
{8  , fld_CP_HUE_CNTL   ,VIP_CP_HUE_CNTL            ,  0, 0xFFFFFF00, 0, 0,0, fld_CP_HUE_CNTL_def       ,READWRITE  },
{1  , fld_LUMA_FILTER   ,VIP_LP_BRIGHTNESS          , 15, 0xFFFF7FFF, 0, 0,0, fld_LUMA_FILTER_def       ,READWRITE  },
{21 , fld_H_SCALE_RATIO ,VIP_H_SCALER_CONTROL       ,  0, 0xFFE00000, 0, 0,0, fld_H_SCALE_RATIO_def     ,READWRITE  },
{4  , fld_H_SHARPNESS   ,VIP_H_SCALER_CONTROL       , 25, 0xE1FFFFFF, 0, 0,0, fld_H_SHARPNESS_def       ,READWRITE  },
{12 , fld_V_SCALE_RATIO ,VIP_V_SCALER_CONTROL       ,  0, 0xFFFFF000, 0, 0,0, fld_V_SCALE_RATIO_def     ,READWRITE  },
{1  , fld_V_DEINTERLACE_ON,VIP_V_SCALER_CONTROL     , 12, 0xFFFFEFFF, 0, 0,0, fld_V_DEINTERLACE_ON_def  ,READWRITE  },
{1  , fld_V_BYPSS       ,VIP_V_SCALER_CONTROL       , 14, 0xFFFFBFFF, 0, 0,0, fld_V_BYPSS_def           ,READWRITE  },
{1  , fld_V_DITHER_ON   ,VIP_V_SCALER_CONTROL       , 15, 0xFFFF7FFF, 0, 0,0, fld_V_DITHER_ON_def       ,READWRITE  },
{11 , fld_EVENF_OFFSET  ,VIP_V_DEINTERLACE_CONTROL  ,  0, 0xFFFFF800, 0, 0,0, fld_EVENF_OFFSET_def      ,READWRITE  },
{11 , fld_ODDF_OFFSET   ,VIP_V_DEINTERLACE_CONTROL  , 11, 0xFFC007FF, 0, 0,0, fld_ODDF_OFFSET_def       ,READWRITE  },
{1  , fld_INTERLACE_DETECTED    ,VIP_VS_LINE_COUNT  , 15, 0xFFFF7FFF, 0, 0,0, fld_INTERLACE_DETECTED_def,READONLY   },
{10 , fld_VS_LINE_COUNT     ,VIP_VS_LINE_COUNT      ,  0, 0xFFFFFC00, 0, 0,0, fld_VS_LINE_COUNT_def     ,READONLY   },
{10 , fld_VS_DETECTED_LINES ,VIP_VS_LINE_COUNT      , 16, 0xFC00FFFF, 0, 0,0, fld_VS_DETECTED_LINES_def ,READONLY   },
{1  , fld_VS_ITU656_VB  ,VIP_VS_LINE_COUNT          , 13, 0xFFFFDFFF, 0, 0,0, fld_VS_ITU656_VB_def  ,READONLY   },
{16 , fld_VBI_CC_DATA   ,VIP_VBI_CC_CNTL            ,  0, 0xFFFF0000, 0, 0,0, fld_VBI_CC_DATA_def       ,READWRITE  },
{1  , fld_VBI_CC_WT     ,VIP_VBI_CC_CNTL            , 24, 0xFEFFFFFF, 0, 0,0, fld_VBI_CC_WT_def         ,READWRITE  },
{1  , fld_VBI_CC_WT_ACK ,VIP_VBI_CC_CNTL            , 25, 0xFDFFFFFF, 0, 0,0, fld_VBI_CC_WT_ACK_def     ,READONLY   },
{1  , fld_VBI_CC_HOLD   ,VIP_VBI_CC_CNTL            , 26, 0xFBFFFFFF, 0, 0,0, fld_VBI_CC_HOLD_def       ,READWRITE  },
{1  , fld_VBI_DECODE_EN ,VIP_VBI_CC_CNTL            , 31, 0x7FFFFFFF, 0, 0,0, fld_VBI_DECODE_EN_def     ,READWRITE  },
{16 , fld_VBI_CC_DTO_P  ,VIP_VBI_DTO_CNTL           ,  0, 0xFFFF0000, 0, 0,0, fld_VBI_CC_DTO_P_def      ,READWRITE  },
{16 ,fld_VBI_20BIT_DTO_P,VIP_VBI_DTO_CNTL           , 16, 0x0000FFFF, 0, 0,0, fld_VBI_20BIT_DTO_P_def   ,READWRITE  },
{7  ,fld_VBI_CC_LEVEL   ,VIP_VBI_LEVEL_CNTL         ,  0, 0xFFFFFF80, 0, 0,0, fld_VBI_CC_LEVEL_def      ,READWRITE  },
{7  ,fld_VBI_20BIT_LEVEL,VIP_VBI_LEVEL_CNTL         ,  8, 0xFFFF80FF, 0, 0,0, fld_VBI_20BIT_LEVEL_def   ,READWRITE  },
{9  ,fld_VBI_CLK_RUNIN_GAIN,VIP_VBI_LEVEL_CNTL      , 16, 0xFE00FFFF, 0, 0,0, fld_VBI_CLK_RUNIN_GAIN_def,READWRITE  },
{11 ,fld_H_VBI_WIND_START,VIP_H_VBI_WINDOW          ,  0, 0xFFFFF800, 0, 0,0, fld_H_VBI_WIND_START_def  ,READWRITE  },
{11 ,fld_H_VBI_WIND_END,VIP_H_VBI_WINDOW            , 16, 0xF800FFFF, 0, 0,0, fld_H_VBI_WIND_END_def    ,READWRITE  },
{10 ,fld_V_VBI_WIND_START,VIP_V_VBI_WINDOW          ,  0, 0xFFFFFC00, 0, 0,0, fld_V_VBI_WIND_START_def  ,READWRITE  },
{10 ,fld_V_VBI_WIND_END,VIP_V_VBI_WINDOW            , 16, 0xFC00FFFF, 0, 0,0, fld_V_VBI_WIND_END_def    ,READWRITE  }, /* CHK */
{16 ,fld_VBI_20BIT_DATA0,VIP_VBI_20BIT_CNTL         ,  0, 0xFFFF0000, 0, 0,0, fld_VBI_20BIT_DATA0_def   ,READWRITE  },
{4  ,fld_VBI_20BIT_DATA1,VIP_VBI_20BIT_CNTL         , 16, 0xFFF0FFFF, 0, 0,0, fld_VBI_20BIT_DATA1_def   ,READWRITE  },
{1  ,fld_VBI_20BIT_WT   ,VIP_VBI_20BIT_CNTL         , 24, 0xFEFFFFFF, 0, 0,0, fld_VBI_20BIT_WT_def      ,READWRITE  },
{1  ,fld_VBI_20BIT_WT_ACK   ,VIP_VBI_20BIT_CNTL     , 25, 0xFDFFFFFF, 0, 0,0, fld_VBI_20BIT_WT_ACK_def  ,READONLY   },
{1  ,fld_VBI_20BIT_HOLD ,VIP_VBI_20BIT_CNTL         , 26, 0xFBFFFFFF, 0, 0,0, fld_VBI_20BIT_HOLD_def    ,READWRITE  },
{2  ,fld_VBI_CAPTURE_ENABLE ,VIP_VBI_CONTROL        ,  0, 0xFFFFFFFC, 0, 0,0, fld_VBI_CAPTURE_ENABLE_def,READWRITE  },
{16 ,fld_VBI_EDS_DATA   ,VIP_VBI_EDS_CNTL           ,  0, 0xFFFF0000, 0, 0,0, fld_VBI_EDS_DATA_def      ,READWRITE  },
{1  ,fld_VBI_EDS_WT     ,VIP_VBI_EDS_CNTL           , 24, 0xFEFFFFFF, 0, 0,0, fld_VBI_EDS_WT_def        ,READWRITE  },
{1  ,fld_VBI_EDS_WT_ACK ,VIP_VBI_EDS_CNTL           , 25, 0xFDFFFFFF, 0, 0,0, fld_VBI_EDS_WT_ACK_def    ,READONLY   },
{1  ,fld_VBI_EDS_HOLD   ,VIP_VBI_EDS_CNTL           , 26, 0xFBFFFFFF, 0, 0,0, fld_VBI_EDS_HOLD_def      ,READWRITE  },
{17 ,fld_VBI_SCALING_RATIO  ,VIP_VBI_SCALER_CONTROL ,  0, 0xFFFE0000, 0, 0,0, fld_VBI_SCALING_RATIO_def ,READWRITE  },
{1  ,fld_VBI_ALIGNER_ENABLE ,VIP_VBI_SCALER_CONTROL , 17, 0xFFFDFFFF, 0, 0,0, fld_VBI_ALIGNER_ENABLE_def,READWRITE  },
{11 ,fld_H_ACTIVE_START ,VIP_H_ACTIVE_WINDOW        ,  0, 0xFFFFF800, 0, 0,0, fld_H_ACTIVE_START_def    ,READWRITE  },
{11 ,fld_H_ACTIVE_END   ,VIP_H_ACTIVE_WINDOW        , 16, 0xF800FFFF, 0, 0,0, fld_H_ACTIVE_END_def      ,READWRITE  },
{10 ,fld_V_ACTIVE_START ,VIP_V_ACTIVE_WINDOW        ,  0, 0xFFFFFC00, 0, 0,0, fld_V_ACTIVE_START_def    ,READWRITE  },
{10 ,fld_V_ACTIVE_END   ,VIP_V_ACTIVE_WINDOW        , 16, 0xFC00FFFF, 0, 0,0, fld_V_ACTIVE_END_def      ,READWRITE  },
{8  ,fld_CH_HEIGHT          ,VIP_CP_AGC_CNTL        ,  0, 0xFFFFFF00, 0, 0,0, fld_CH_HEIGHT_def         ,READWRITE  },
{8  ,fld_CH_KILL_LEVEL      ,VIP_CP_AGC_CNTL        ,  8, 0xFFFF00FF, 0, 0,0, fld_CH_KILL_LEVEL_def     ,READWRITE  },
{2  ,fld_CH_AGC_ERROR_LIM   ,VIP_CP_AGC_CNTL        , 16, 0xFFFCFFFF, 0, 0,0, fld_CH_AGC_ERROR_LIM_def  ,READWRITE  },
{1  ,fld_CH_AGC_FILTER_EN   ,VIP_CP_AGC_CNTL        , 18, 0xFFFBFFFF, 0, 0,0, fld_CH_AGC_FILTER_EN_def  ,READWRITE  },
{1  ,fld_CH_AGC_LOOP_SPEED  ,VIP_CP_AGC_CNTL        , 19, 0xFFF7FFFF, 0, 0,0, fld_CH_AGC_LOOP_SPEED_def ,READWRITE  },
{8  ,fld_HUE_ADJ            ,VIP_CP_HUE_CNTL        ,  0, 0xFFFFFF00, 0, 0,0, fld_HUE_ADJ_def           ,READWRITE  },
{2  ,fld_STANDARD_SEL       ,VIP_STANDARD_SELECT    ,  0, 0xFFFFFFFC, 0, 0,0, fld_STANDARD_SEL_def      ,READWRITE  },
{1  ,fld_STANDARD_YC        ,VIP_STANDARD_SELECT    ,  2, 0xFFFFFFFB, 0, 0,0, fld_STANDARD_YC_def       ,READWRITE  },
{1  ,fld_ADC_PDWN           ,VIP_ADC_CNTL           ,  7, 0xFFFFFF7F, 0, 0,0, fld_ADC_PDWN_def          ,READWRITE  },
{3  ,fld_INPUT_SELECT       ,VIP_ADC_CNTL           ,  0, 0xFFFFFFF8, 0, 0,0, fld_INPUT_SELECT_def      ,READWRITE  },
{2  ,fld_ADC_PREFLO         ,VIP_ADC_CNTL           , 24, 0xFCFFFFFF, 0, 0,0, fld_ADC_PREFLO_def        ,READWRITE  },
{8  ,fld_H_SYNC_PULSE_WIDTH ,VIP_HS_PULSE_WIDTH     ,  0, 0xFFFFFF00, 0, 0,0, fld_H_SYNC_PULSE_WIDTH_def,READONLY   },
{1  ,fld_HS_GENLOCKED       ,VIP_HS_PULSE_WIDTH     ,  8, 0xFFFFFEFF, 0, 0,0, fld_HS_GENLOCKED_def      ,READONLY   },
{1  ,fld_HS_SYNC_IN_WIN     ,VIP_HS_PULSE_WIDTH     ,  9, 0xFFFFFDFF, 0, 0,0, fld_HS_SYNC_IN_WIN_def    ,READONLY   },
{1  ,fld_VIN_ASYNC_RST      ,VIP_MASTER_CNTL        ,  5, 0xFFFFFFDF, 0, 0,0, fld_VIN_ASYNC_RST_def     ,READWRITE  },
{1  ,fld_DVS_ASYNC_RST      ,VIP_MASTER_CNTL        ,  7, 0xFFFFFF7F, 0, 0,0, fld_DVS_ASYNC_RST_def     ,READWRITE  },
{16 ,fld_VIP_VENDOR_ID      ,VIP_VIP_VENDOR_DEVICE_ID, 0, 0xFFFF0000, 0, 0,0, fld_VIP_VENDOR_ID_def     ,READONLY   },
{16 ,fld_VIP_DEVICE_ID      ,VIP_VIP_VENDOR_DEVICE_ID,16, 0x0000FFFF, 0, 0,0, fld_VIP_DEVICE_ID_def     ,READONLY   },
{16 ,fld_VIP_REVISION_ID    ,VIP_VIP_REVISION_ID    ,  0, 0xFFFF0000, 0, 0,0, fld_VIP_REVISION_ID_def   ,READONLY   },
{8  ,fld_BLACK_INT_START    ,VIP_SG_BLACK_GATE      ,  0, 0xFFFFFF00, 0, 0,0, fld_BLACK_INT_START_def   ,READWRITE  },
{4  ,fld_BLACK_INT_LENGTH   ,VIP_SG_BLACK_GATE      ,  8, 0xFFFFF0FF, 0, 0,0, fld_BLACK_INT_LENGTH_def  ,READWRITE  },
{8  ,fld_UV_INT_START       ,VIP_SG_UVGATE_GATE     ,  0, 0xFFFFFF00, 0, 0,0, fld_UV_INT_START_def      ,READWRITE  },
{4  ,fld_U_INT_LENGTH       ,VIP_SG_UVGATE_GATE     ,  8, 0xFFFFF0FF, 0, 0,0, fld_U_INT_LENGTH_def      ,READWRITE  },
{4  ,fld_V_INT_LENGTH       ,VIP_SG_UVGATE_GATE     , 12, 0xFFFF0FFF, 0, 0,0, fld_V_INT_LENGTH_def      ,READWRITE  },
{10 ,fld_CRDR_ACTIVE_GAIN   ,VIP_CP_ACTIVE_GAIN     ,  0, 0xFFFFFC00, 0, 0,0, fld_CRDR_ACTIVE_GAIN_def  ,READWRITE  },
{10 ,fld_CBDB_ACTIVE_GAIN   ,VIP_CP_ACTIVE_GAIN     , 16, 0xFC00FFFF, 0, 0,0, fld_CBDB_ACTIVE_GAIN_def  ,READWRITE  },
{1  ,fld_DVS_DIRECTION      ,VIP_DVS_PORT_CTRL      ,  0, 0xFFFFFFFE, 0, 0,0, fld_DVS_DIRECTION_def     ,READWRITE  },
{1  ,fld_DVS_VBI_CARD8_SWAP  ,VIP_DVS_PORT_CTRL      ,  1, 0xFFFFFFFD, 0, 0,0, fld_DVS_VBI_CARD8_SWAP_def ,READWRITE  },
{1  ,fld_DVS_CLK_SELECT     ,VIP_DVS_PORT_CTRL      ,  2, 0xFFFFFFFB, 0, 0,0, fld_DVS_CLK_SELECT_def    ,READWRITE  },
{1  ,fld_CONTINUOUS_STREAM  ,VIP_DVS_PORT_CTRL      ,  3, 0xFFFFFFF7, 0, 0,0, fld_CONTINUOUS_STREAM_def ,READWRITE  },
{1  ,fld_DVSOUT_CLK_DRV     ,VIP_DVS_PORT_CTRL      ,  4, 0xFFFFFFEF, 0, 0,0, fld_DVSOUT_CLK_DRV_def    ,READWRITE  },
{1  ,fld_DVSOUT_DATA_DRV    ,VIP_DVS_PORT_CTRL      ,  5, 0xFFFFFFDF, 0, 0,0, fld_DVSOUT_DATA_DRV_def   ,READWRITE  },
{32 ,fld_COMB_CNTL0         ,VIP_COMB_CNTL0         ,  0, 0x00000000, 0, 0,0, fld_COMB_CNTL0_def        ,READWRITE  },
{32 ,fld_COMB_CNTL1         ,VIP_COMB_CNTL1         ,  0, 0x00000000, 0, 0,0, fld_COMB_CNTL1_def        ,READWRITE  },
{32 ,fld_COMB_CNTL2         ,VIP_COMB_CNTL2         ,  0, 0x00000000, 0, 0,0, fld_COMB_CNTL2_def        ,READWRITE  },
{32 ,fld_COMB_LENGTH        ,VIP_COMB_LINE_LENGTH   ,  0, 0x00000000, 0, 0,0, fld_COMB_LENGTH_def       ,READWRITE  },
{8  ,fld_SYNCTIP_REF0       ,VIP_LP_AGC_CLAMP_CNTL0 ,  0, 0xFFFFFF00, 0, 0,0, fld_SYNCTIP_REF0_def      ,READWRITE  },
{8  ,fld_SYNCTIP_REF1       ,VIP_LP_AGC_CLAMP_CNTL0 ,  8, 0xFFFF00FF, 0, 0,0, fld_SYNCTIP_REF1_def      ,READWRITE  },
{8  ,fld_CLAMP_REF          ,VIP_LP_AGC_CLAMP_CNTL0 , 16, 0xFF00FFFF, 0, 0,0, fld_CLAMP_REF_def          ,READWRITE  },
{8  ,fld_AGC_PEAKWHITE      ,VIP_LP_AGC_CLAMP_CNTL0 , 24, 0x00FFFFFF, 0, 0,0, fld_AGC_PEAKWHITE_def     ,READWRITE  },
{8  ,fld_VBI_PEAKWHITE      ,VIP_LP_AGC_CLAMP_CNTL1 ,  0, 0xFFFFFF00, 0, 0,0, fld_VBI_PEAKWHITE_def     ,READWRITE  },
{11 ,fld_WPA_THRESHOLD      ,VIP_LP_WPA_CNTL0       ,  0, 0xFFFFF800, 0, 0,0, fld_WPA_THRESHOLD_def     ,READWRITE  },
{10 ,fld_WPA_TRIGGER_LO     ,VIP_LP_WPA_CNTL1       ,  0, 0xFFFFFC00, 0, 0,0, fld_WPA_TRIGGER_LO_def    ,READWRITE  },
{10 ,fld_WPA_TRIGGER_HIGH   ,VIP_LP_WPA_CNTL1       , 16, 0xFC00FFFF, 0, 0,0, fld_WPA_TRIGGER_HIGH_def  ,READWRITE  },
{10 ,fld_LOCKOUT_START      ,VIP_LP_VERT_LOCKOUT    ,  0, 0xFFFFFC00, 0, 0,0, fld_LOCKOUT_START_def     ,READWRITE  },
{10 ,fld_LOCKOUT_END        ,VIP_LP_VERT_LOCKOUT    , 16, 0xFC00FFFF, 0, 0,0, fld_LOCKOUT_END_def       ,READWRITE  },
{24 ,fld_CH_DTO_INC         ,VIP_CP_PLL_CNTL0       ,  0, 0xFF000000, 0, 0,0, fld_CH_DTO_INC_def        ,READWRITE  },
{4  ,fld_PLL_SGAIN          ,VIP_CP_PLL_CNTL0       , 24, 0xF0FFFFFF, 0, 0,0, fld_PLL_SGAIN_def         ,READWRITE  },
{4  ,fld_PLL_FGAIN          ,VIP_CP_PLL_CNTL0       , 28, 0x0FFFFFFF, 0, 0,0, fld_PLL_FGAIN_def         ,READWRITE  },
{9  ,fld_CR_BURST_GAIN      ,VIP_CP_BURST_GAIN      ,  0, 0xFFFFFE00, 0, 0,0, fld_CR_BURST_GAIN_def     ,READWRITE  },
{9  ,fld_CB_BURST_GAIN      ,VIP_CP_BURST_GAIN      , 16, 0xFE00FFFF, 0, 0,0, fld_CB_BURST_GAIN_def     ,READWRITE  },
{10 ,fld_VERT_LOCKOUT_START ,VIP_CP_VERT_LOCKOUT    ,  0, 0xFFFFFC00, 0, 0,0, fld_VERT_LOCKOUT_START_def,READWRITE  },
{10 ,fld_VERT_LOCKOUT_END   ,VIP_CP_VERT_LOCKOUT    , 16, 0xFC00FFFF, 0, 0,0, fld_VERT_LOCKOUT_END_def  ,READWRITE  },
{11 ,fld_H_IN_WIND_START    ,VIP_SCALER_IN_WINDOW   ,  0, 0xFFFFF800, 0, 0,0, fld_H_IN_WIND_START_def   ,READWRITE  },
{10 ,fld_V_IN_WIND_START    ,VIP_SCALER_IN_WINDOW   , 16, 0xFC00FFFF, 0, 0,0, fld_V_IN_WIND_START_def   ,READWRITE  },
{10 ,fld_H_OUT_WIND_WIDTH   ,VIP_SCALER_OUT_WINDOW ,  0, 0xFFFFFC00, 0, 0,0, fld_H_OUT_WIND_WIDTH_def   ,READWRITE  },
{9  ,fld_V_OUT_WIND_WIDTH   ,VIP_SCALER_OUT_WINDOW , 16, 0xFE00FFFF, 0, 0,0, fld_V_OUT_WIND_WIDTH_def   ,READWRITE  },
{11 ,fld_HS_LINE_TOTAL      ,VIP_HS_PLINE          ,  0, 0xFFFFF800, 0, 0,0, fld_HS_LINE_TOTAL_def      ,READWRITE  },
{8  ,fld_MIN_PULSE_WIDTH    ,VIP_HS_MINMAXWIDTH    ,  0, 0xFFFFFF00, 0, 0,0, fld_MIN_PULSE_WIDTH_def    ,READWRITE  },
{8  ,fld_MAX_PULSE_WIDTH    ,VIP_HS_MINMAXWIDTH    ,  8, 0xFFFF00FF, 0, 0,0, fld_MAX_PULSE_WIDTH_def    ,READWRITE  },
{11 ,fld_WIN_CLOSE_LIMIT    ,VIP_HS_WINDOW_LIMIT   ,  0, 0xFFFFF800, 0, 0,0, fld_WIN_CLOSE_LIMIT_def    ,READWRITE  },
{11 ,fld_WIN_OPEN_LIMIT     ,VIP_HS_WINDOW_LIMIT   , 16, 0xF800FFFF, 0, 0,0, fld_WIN_OPEN_LIMIT_def     ,READWRITE  },
{11 ,fld_VSYNC_INT_TRIGGER  ,VIP_VS_DETECTOR_CNTL   ,  0, 0xFFFFF800, 0, 0,0, fld_VSYNC_INT_TRIGGER_def ,READWRITE  },
{11 ,fld_VSYNC_INT_HOLD     ,VIP_VS_DETECTOR_CNTL   , 16, 0xF800FFFF, 0, 0,0, fld_VSYNC_INT_HOLD_def        ,READWRITE  },
{11 ,fld_VIN_M0             ,VIP_VIN_PLL_CNTL      ,  0, 0xFFFFF800, 0, 0,0, fld_VIN_M0_def             ,READWRITE  },
{11 ,fld_VIN_N0             ,VIP_VIN_PLL_CNTL      , 11, 0xFFC007FF, 0, 0,0, fld_VIN_N0_def             ,READWRITE  },
{1  ,fld_MNFLIP_EN          ,VIP_VIN_PLL_CNTL      , 22, 0xFFBFFFFF, 0, 0,0, fld_MNFLIP_EN_def          ,READWRITE  },
{4  ,fld_VIN_P              ,VIP_VIN_PLL_CNTL      , 24, 0xF0FFFFFF, 0, 0,0, fld_VIN_P_def              ,READWRITE  },
{2  ,fld_REG_CLK_SEL        ,VIP_VIN_PLL_CNTL      , 30, 0x3FFFFFFF, 0, 0,0, fld_REG_CLK_SEL_def        ,READWRITE  },
{11 ,fld_VIN_M1             ,VIP_VIN_PLL_FINE_CNTL  ,  0, 0xFFFFF800, 0, 0,0, fld_VIN_M1_def            ,READWRITE  },
{11 ,fld_VIN_N1             ,VIP_VIN_PLL_FINE_CNTL  , 11, 0xFFC007FF, 0, 0,0, fld_VIN_N1_def            ,READWRITE  },
{1  ,fld_VIN_DRIVER_SEL     ,VIP_VIN_PLL_FINE_CNTL  , 22, 0xFFBFFFFF, 0, 0,0, fld_VIN_DRIVER_SEL_def    ,READWRITE  },
{1  ,fld_VIN_MNFLIP_REQ     ,VIP_VIN_PLL_FINE_CNTL  , 23, 0xFF7FFFFF, 0, 0,0, fld_VIN_MNFLIP_REQ_def    ,READWRITE  },
{1  ,fld_VIN_MNFLIP_DONE    ,VIP_VIN_PLL_FINE_CNTL  , 24, 0xFEFFFFFF, 0, 0,0, fld_VIN_MNFLIP_DONE_def   ,READONLY   },
{1  ,fld_TV_LOCK_TO_VIN     ,VIP_VIN_PLL_FINE_CNTL  , 27, 0xF7FFFFFF, 0, 0,0, fld_TV_LOCK_TO_VIN_def    ,READWRITE  },
{4  ,fld_TV_P_FOR_WINCLK    ,VIP_VIN_PLL_FINE_CNTL  , 28, 0x0FFFFFFF, 0, 0,0, fld_TV_P_FOR_WINCLK_def   ,READWRITE  },
{1  ,fld_VINRST             ,VIP_PLL_CNTL1          ,  1, 0xFFFFFFFD, 0, 0,0, fld_VINRST_def            ,READWRITE  },
{1  ,fld_VIN_CLK_SEL        ,VIP_CLOCK_SEL_CNTL     ,  7, 0xFFFFFF7F, 0, 0,0, fld_VIN_CLK_SEL_def       ,READWRITE  },
{10 ,fld_VS_FIELD_BLANK_START,VIP_VS_BLANKING_CNTL  ,  0, 0xFFFFFC00, 0, 0,0, fld_VS_FIELD_BLANK_START_def  ,READWRITE  },
{10 ,fld_VS_FIELD_BLANK_END,VIP_VS_BLANKING_CNTL    , 16, 0xFC00FFFF, 0, 0,0, fld_VS_FIELD_BLANK_END_def    ,READWRITE  },
{9  ,fld_VS_FIELD_IDLOCATION,VIP_VS_FIELD_ID_CNTL   ,  0, 0xFFFFFE00, 0, 0,0, fld_VS_FIELD_IDLOCATION_def   ,READWRITE  },
{10 ,fld_VS_FRAME_TOTAL     ,VIP_VS_FRAME_TOTAL     ,  0, 0xFFFFFC00, 0, 0,0, fld_VS_FRAME_TOTAL_def    ,READWRITE  },
{11 ,fld_SYNC_TIP_START     ,VIP_SG_SYNCTIP_GATE    ,  0, 0xFFFFF800, 0, 0,0, fld_SYNC_TIP_START_def    ,READWRITE  },
{4  ,fld_SYNC_TIP_LENGTH    ,VIP_SG_SYNCTIP_GATE    , 12, 0xFFFF0FFF, 0, 0,0, fld_SYNC_TIP_LENGTH_def   ,READWRITE  },
{12 ,fld_GAIN_FORCE_DATA    ,VIP_CP_DEBUG_FORCE     ,  0, 0xFFFFF000, 0, 0,0, fld_GAIN_FORCE_DATA_def   ,READWRITE  },
{1  ,fld_GAIN_FORCE_EN      ,VIP_CP_DEBUG_FORCE     , 12, 0xFFFFEFFF, 0, 0,0, fld_GAIN_FORCE_EN_def ,READWRITE  },
{2  ,fld_I_CLAMP_SEL        ,VIP_ADC_CNTL           ,  3, 0xFFFFFFE7, 0, 0,0, fld_I_CLAMP_SEL_def   ,READWRITE  },
{2  ,fld_I_AGC_SEL          ,VIP_ADC_CNTL           ,  5, 0xFFFFFF9F, 0, 0,0, fld_I_AGC_SEL_def     ,READWRITE  },
{1  ,fld_EXT_CLAMP_CAP      ,VIP_ADC_CNTL           ,  8, 0xFFFFFEFF, 0, 0,0, fld_EXT_CLAMP_CAP_def ,READWRITE  },
{1  ,fld_EXT_AGC_CAP        ,VIP_ADC_CNTL           ,  9, 0xFFFFFDFF, 0, 0,0, fld_EXT_AGC_CAP_def       ,READWRITE  },
{1  ,fld_DECI_DITHER_EN     ,VIP_ADC_CNTL           , 12, 0xFFFFEFFF, 0, 0,0, fld_DECI_DITHER_EN_def ,READWRITE },
{2  ,fld_ADC_PREFHI         ,VIP_ADC_CNTL           , 22, 0xFF3FFFFF, 0, 0,0, fld_ADC_PREFHI_def        ,READWRITE  },
{2  ,fld_ADC_CH_GAIN_SEL    ,VIP_ADC_CNTL           , 16, 0xFFFCFFFF, 0, 0,0, fld_ADC_CH_GAIN_SEL_def   ,READWRITE  },
{4  ,fld_HS_PLL_SGAIN       ,VIP_HS_PLLGAIN         ,  0, 0xFFFFFFF0, 0, 0,0, fld_HS_PLL_SGAIN_def      ,READWRITE  },
{1  ,fld_NREn               ,VIP_NOISE_CNTL0        ,  0, 0xFFFFFFFE, 0, 0,0, fld_NREn_def      ,READWRITE  },
{3  ,fld_NRGainCntl         ,VIP_NOISE_CNTL0        ,  1, 0xFFFFFFF1, 0, 0,0, fld_NRGainCntl_def        ,READWRITE  },
{6  ,fld_NRBWTresh          ,VIP_NOISE_CNTL0        ,  4, 0xFFFFFC0F, 0, 0,0, fld_NRBWTresh_def     ,READWRITE  },
{5  ,fld_NRGCTresh          ,VIP_NOISE_CNTL0       ,  10, 0xFFFF83FF, 0, 0,0, fld_NRGCTresh_def     ,READWRITE  },
{1  ,fld_NRCoefDespeclMode  ,VIP_NOISE_CNTL0       ,  15, 0xFFFF7FFF, 0, 0,0, fld_NRCoefDespeclMode_def     ,READWRITE  },
{1  ,fld_GPIO_5_OE      ,VIP_GPIO_CNTL      ,  5, 0xFFFFFFDF, 0, 0,0, fld_GPIO_5_OE_def     ,READWRITE  },
{1  ,fld_GPIO_6_OE      ,VIP_GPIO_CNTL      ,  6, 0xFFFFFFBF, 0, 0,0, fld_GPIO_6_OE_def     ,READWRITE  },
{1  ,fld_GPIO_5_OUT     ,VIP_GPIO_INOUT    ,   5, 0xFFFFFFDF, 0, 0,0, fld_GPIO_5_OUT_def        ,READWRITE  },
{1  ,fld_GPIO_6_OUT     ,VIP_GPIO_INOUT    ,   6, 0xFFFFFFBF, 0, 0,0, fld_GPIO_6_OUT_def        ,READWRITE  },
};

/* Rage Theatre's register fields default values: */
unsigned long RT_RegDef[regRT_MAX_REGS]=
{
fld_tmpReg1_def,
fld_tmpReg2_def,
fld_tmpReg3_def,
fld_LP_CONTRAST_def,
fld_LP_BRIGHTNESS_def,
fld_CP_HUE_CNTL_def,
fld_LUMA_FILTER_def,
fld_H_SCALE_RATIO_def,
fld_H_SHARPNESS_def,
fld_V_SCALE_RATIO_def,
fld_V_DEINTERLACE_ON_def,
fld_V_BYPSS_def,
fld_V_DITHER_ON_def,
fld_EVENF_OFFSET_def,
fld_ODDF_OFFSET_def,
fld_INTERLACE_DETECTED_def,
fld_VS_LINE_COUNT_def,
fld_VS_DETECTED_LINES_def,
fld_VS_ITU656_VB_def,
fld_VBI_CC_DATA_def,
fld_VBI_CC_WT_def,
fld_VBI_CC_WT_ACK_def,
fld_VBI_CC_HOLD_def,
fld_VBI_DECODE_EN_def,
fld_VBI_CC_DTO_P_def,
fld_VBI_20BIT_DTO_P_def,
fld_VBI_CC_LEVEL_def,
fld_VBI_20BIT_LEVEL_def,
fld_VBI_CLK_RUNIN_GAIN_def,
fld_H_VBI_WIND_START_def,
fld_H_VBI_WIND_END_def,
fld_V_VBI_WIND_START_def,
fld_V_VBI_WIND_END_def,
fld_VBI_20BIT_DATA0_def,
fld_VBI_20BIT_DATA1_def,
fld_VBI_20BIT_WT_def,
fld_VBI_20BIT_WT_ACK_def,
fld_VBI_20BIT_HOLD_def,
fld_VBI_CAPTURE_ENABLE_def,
fld_VBI_EDS_DATA_def,
fld_VBI_EDS_WT_def,
fld_VBI_EDS_WT_ACK_def,
fld_VBI_EDS_HOLD_def,
fld_VBI_SCALING_RATIO_def,
fld_VBI_ALIGNER_ENABLE_def,
fld_H_ACTIVE_START_def,
fld_H_ACTIVE_END_def,
fld_V_ACTIVE_START_def,
fld_V_ACTIVE_END_def,
fld_CH_HEIGHT_def,
fld_CH_KILL_LEVEL_def,
fld_CH_AGC_ERROR_LIM_def,
fld_CH_AGC_FILTER_EN_def,
fld_CH_AGC_LOOP_SPEED_def,
fld_HUE_ADJ_def,
fld_STANDARD_SEL_def,
fld_STANDARD_YC_def,
fld_ADC_PDWN_def,
fld_INPUT_SELECT_def,
fld_ADC_PREFLO_def,
fld_H_SYNC_PULSE_WIDTH_def,
fld_HS_GENLOCKED_def,
fld_HS_SYNC_IN_WIN_def,
fld_VIN_ASYNC_RST_def,
fld_DVS_ASYNC_RST_def,
fld_VIP_VENDOR_ID_def,
fld_VIP_DEVICE_ID_def,
fld_VIP_REVISION_ID_def,
fld_BLACK_INT_START_def,
fld_BLACK_INT_LENGTH_def,
fld_UV_INT_START_def,
fld_U_INT_LENGTH_def,
fld_V_INT_LENGTH_def,
fld_CRDR_ACTIVE_GAIN_def,
fld_CBDB_ACTIVE_GAIN_def,
fld_DVS_DIRECTION_def,
fld_DVS_VBI_CARD8_SWAP_def,
fld_DVS_CLK_SELECT_def,
fld_CONTINUOUS_STREAM_def,
fld_DVSOUT_CLK_DRV_def,
fld_DVSOUT_DATA_DRV_def,
fld_COMB_CNTL0_def,
fld_COMB_CNTL1_def,
fld_COMB_CNTL2_def,
fld_COMB_LENGTH_def,
fld_SYNCTIP_REF0_def,
fld_SYNCTIP_REF1_def,
fld_CLAMP_REF_def,
fld_AGC_PEAKWHITE_def,
fld_VBI_PEAKWHITE_def,
fld_WPA_THRESHOLD_def,
fld_WPA_TRIGGER_LO_def,
fld_WPA_TRIGGER_HIGH_def,
fld_LOCKOUT_START_def,
fld_LOCKOUT_END_def,
fld_CH_DTO_INC_def,
fld_PLL_SGAIN_def,
fld_PLL_FGAIN_def,
fld_CR_BURST_GAIN_def,
fld_CB_BURST_GAIN_def,
fld_VERT_LOCKOUT_START_def,
fld_VERT_LOCKOUT_END_def,
fld_H_IN_WIND_START_def,
fld_V_IN_WIND_START_def,
fld_H_OUT_WIND_WIDTH_def,
fld_V_OUT_WIND_WIDTH_def,
fld_HS_LINE_TOTAL_def,
fld_MIN_PULSE_WIDTH_def,
fld_MAX_PULSE_WIDTH_def,
fld_WIN_CLOSE_LIMIT_def,
fld_WIN_OPEN_LIMIT_def,
fld_VSYNC_INT_TRIGGER_def,
fld_VSYNC_INT_HOLD_def,
fld_VIN_M0_def,
fld_VIN_N0_def,
fld_MNFLIP_EN_def,
fld_VIN_P_def,
fld_REG_CLK_SEL_def,
fld_VIN_M1_def,
fld_VIN_N1_def,
fld_VIN_DRIVER_SEL_def,
fld_VIN_MNFLIP_REQ_def,
fld_VIN_MNFLIP_DONE_def,
fld_TV_LOCK_TO_VIN_def,
fld_TV_P_FOR_WINCLK_def,
fld_VINRST_def,
fld_VIN_CLK_SEL_def,
fld_VS_FIELD_BLANK_START_def,
fld_VS_FIELD_BLANK_END_def,
fld_VS_FIELD_IDLOCATION_def,
fld_VS_FRAME_TOTAL_def,
fld_SYNC_TIP_START_def,
fld_SYNC_TIP_LENGTH_def,
fld_GAIN_FORCE_DATA_def,
fld_GAIN_FORCE_EN_def,
fld_I_CLAMP_SEL_def,
fld_I_AGC_SEL_def,
fld_EXT_CLAMP_CAP_def,
fld_EXT_AGC_CAP_def,
fld_DECI_DITHER_EN_def,
fld_ADC_PREFHI_def,
fld_ADC_CH_GAIN_SEL_def,
fld_HS_PLL_SGAIN_def,
fld_NREn_def,
fld_NRGainCntl_def,
fld_NRBWTresh_def,
fld_NRGCTresh_def,
fld_NRCoefDespeclMode_def,
fld_GPIO_5_OE_def,
fld_GPIO_6_OE_def,
fld_GPIO_5_OUT_def,
fld_GPIO_6_OUT_def,
};

TheatrePtr DetectTheatre(struct radeonfb_info *rinfo)
{
	TheatrePtr t;  
	unsigned long i, val;
	t = (TheatrePtr)Mxalloc(sizeof(TheatreRec)+sizeof(RT_RegMap),2);
	if(t == NULL)
		return(NULL);
	t->rinfo = rinfo;
	t->theatre_num = -1;
	t->mode=MODE_UNINITIALIZED;
	RADEONVIP_read(rinfo, VIP_VIP_VENDOR_DEVICE_ID, 4, (unsigned char *)&val);
	for(i=0;i<4;i++)
	{
		if(RADEONVIP_read(rinfo, ((i & 0x03)<<14) | VIP_VIP_VENDOR_DEVICE_ID, 4, (unsigned char *)&val))
		{
			if(val)
			{
				DPRINTVAL("Device ", i);
				DPRINTVALHEX(" on VIP bus ids as ", val);
				DPRINT("\r\n");	
			}
			if(t->theatre_num>=0)
				continue; /* already found one instance */
			switch(val)
			{
				case RT100_ATI_ID: t->theatre_num=i; t->theatre_id=RT100_ATI_ID; break;
				case RT200_ATI_ID: t->theatre_num=i; t->theatre_id=RT200_ATI_ID; break;
			}
		}
		else
		{
			DPRINTVAL("No response from device ", i);
			DPRINT(" on VIP bus\r\n");	
		}
	}
	if(t->theatre_num>=0)
	{
		DPRINTVAL("Detected Rage Theatre as device ", t->theatre_num);
		DPRINTVALHEX(" on VIP bus with id ", t->theatre_id);
		DPRINT("\r\n");
	}
	if(t->theatre_num < 0)
	{
		Mfree(t);
		return(NULL);
	}
	memcpy((char *)t+sizeof(TheatreRec), (void *)RT_RegMap, sizeof(RT_RegMap)); 
	RT_regr(VIP_VIP_REVISION_ID, &val);
	DPRINTVALHEX("Detected Rage Theatre revision ", val);
	DPRINT("\r\n");
	return(t);
}

/****************************************************************************
 * WriteRT_fld (unsigned long dwReg, unsigned long dwData)                  *
 *  Function: Writes a register field within Rage Theatre                   *
 *    Inputs: unsigned long dwReg = register field to be written            *
 *            unsigned long dwData = data that will be written to the reg field *
 *   Outputs: NONE                                                          *
 ****************************************************************************/
static void WriteRT_fld1(TheatrePtr t, unsigned long dwReg, unsigned long dwData)
{
	unsigned long dwResult=0, dwValue=0;
	RTREGMAP *RT_RegMap = (RTREGMAP *)((char *)t+sizeof(TheatreRec));
	if(RT_regr(RT_RegMap[dwReg].dwRegAddrLSBs, &dwResult) == TRUE)
	{
		dwValue = (dwResult & RT_RegMap[dwReg].dwMaskLSBs) | (dwData << RT_RegMap[dwReg].dwFldOffsetLSBs);
		if(RT_regw (RT_RegMap[dwReg].dwRegAddrLSBs, dwValue) == TRUE)
			/* update the memory mapped registers */
			RT_RegMap[dwReg].dwCurrValue = dwData;
	}
}

/****************************************************************************
 * ReadRT_fld (unsigned long dwReg)                                         *
 *  Function: Reads a register field within Rage Theatre                    *
 *    Inputs: unsigned long dwReg = register field to be read               *
 *   Outputs: unsigned long - value read from register field                *
 ****************************************************************************/
static unsigned long ReadRT_fld1(TheatrePtr t, unsigned long dwReg)
{
	unsigned long dwResult=0;
	RTREGMAP *RT_RegMap = (RTREGMAP *)((char *)t+sizeof(TheatreRec));
	if(RT_regr(RT_RegMap[dwReg].dwRegAddrLSBs, &dwResult) == TRUE)
	{
		RT_RegMap[dwReg].dwCurrValue = ((dwResult & ~RT_RegMap[dwReg].dwMaskLSBs) >> RT_RegMap[dwReg].dwFldOffsetLSBs);
		return (RT_RegMap[dwReg].dwCurrValue);
	}
	return(0xFFFFFFFF);
}

#define WriteRT_fld(a,b)   WriteRT_fld1(t, (a), (b))
#define ReadRT_fld(a)	   ReadRT_fld1(t, (a))

/****************************************************************************
 * RT_SetVINClock (unsigned short wStandard)                                *
 *  Function: to set the VIN clock for the selected standard                *
 *    Inputs: unsigned short wStandard - input standard (NTSC, PAL, SECAM)  *
 *   Outputs: NONE                                                          *
 ****************************************************************************/
static void RT_SetVINClock(TheatrePtr t, unsigned short wStandard)
{
	unsigned long dwM0=0, dwN0=0, dwP=0;
	unsigned char ref_freq;
	/* Determine the reference frequency first. This can be obtained
	   from the MMTABLE.video_decoder_type field (bits 4:7)
	   The Rage Theatre currently only supports reference frequencies of 27 or 29.49 MHz
	*/
	ref_freq = (t->video_decoder_type & 0xF0) >> 4; 
	switch(wStandard & 0x00FF)
	{
		case (DEC_NTSC): /* NTSC GROUP - 480 lines */
			switch (wStandard & 0xFF00)
			{
				case (extNONE):
				case (extNTSC):
				case (extNTSC_J):
					if(ref_freq == RT_FREF_2950)
					{
						dwM0 = 0x39;
						dwN0 = 0x14C;
						dwP  = 0x6;
					}
					else
					{
						dwM0 = 0x0B;
						dwN0 = 0x46;
						dwP  = 0x6;
					}
					break;
				case (extNTSC_443):
					if(ref_freq == RT_FREF_2950)
					{
						dwM0 = 0x23;
						dwN0 = 0x88;
						dwP  = 0x7;
					}
					else
					{
						dwM0 = 0x2C;
						dwN0 = 0x121;
						dwP  = 0x5;
					}
					break;
				case (extPAL_M):
					if(ref_freq == RT_FREF_2950)
					{
						dwM0 = 0x2C;
						dwN0 = 0x12B;
						dwP  = 0x7;
					}
					else
					{
						dwM0 =  0x0B;
						dwN0 =  0x46;
						dwP  =  0x6;
					}
					break;
				default:
					return;
			}
			break;
		case (DEC_PAL):
			switch (wStandard & 0xFF00)
			{
				case (extPAL):
				case (extPAL_N):
				case (extPAL_BGHI):
				case (extPAL_60):
					if(ref_freq == RT_FREF_2950)
					{
						dwM0 = 0x0E;
						dwN0 = 0x65;
						dwP  = 0x6;
					}
					else
					{
						dwM0 = 0x2C;
						dwN0 = 0x0121;
						dwP  = 0x5;
					}
					break;
				case (extPAL_NCOMB):
					if(ref_freq == RT_FREF_2950)
					{
						dwM0 = 0x23;
						dwN0 = 0x88;
						dwP  = 0x7;
					}
					else
					{
						dwM0 = 0x37;
						dwN0 = 0x1D3;
						dwP  = 0x8;
					}
					break;
				default:
					return;
			}
			break;
		case (DEC_SECAM):
			if(ref_freq == RT_FREF_2950)
			{
				dwM0 = 0xE;
				dwN0 = 0x65;
				dwP  = 0x6;
			}
			else
			{
				dwM0 = 0x2C;
				dwN0 = 0x121;
				dwP  = 0x5;
			}
			break;
	}
	/* VIN_PLL_CNTL */
	WriteRT_fld(fld_VIN_M0, dwM0);
	WriteRT_fld(fld_VIN_N0, dwN0);
	WriteRT_fld(fld_VIN_P, dwP);
}

/****************************************************************************
 * RT_SetTint (int hue)                                                     *
 *  Function: sets the tint (hue) for the Rage Theatre video in             *
 *    Inputs: int hue - the hue value to be set.                            *
 *   Outputs: NONE                                                          *
 ****************************************************************************/
void RT_SetTint(TheatrePtr t, int hue)
{
	unsigned long nhue = 0;
	/* Validate Hue level */
	if(hue < -1000)
		hue = -1000;
	else if(hue > 1000)
		hue = 1000;
	t->iHue=hue;
	switch(t->theatre_id)
	{
		case RT100_ATI_ID:
			/* Scale hue value from -1000<->1000 to -180<->180 */
			hue = (double)(hue+1000) * 0.18 - 180;
			/* Validate Hue level */
			if(hue < -180)
				hue = -180;
			else if(hue > 180)
				hue = 180;
			/* save the "validated" hue, but scale it back up to -1000<->1000 */
			t->iHue = (int)((double)hue/0.18);
			switch (t->wStandard & 0x00FF)
			{
				case (DEC_NTSC): /* original ATI code had _empty_ section for PAL/SECAM... which did not work, obviously */
				case (DEC_PAL):
				case (DEC_SECAM):
					if(hue >= 0)
						nhue = (unsigned long)(256 * hue) / 360;
					else
						nhue = (unsigned long)(256 * (hue + 360)) / 360;
					break;
			}
			WriteRT_fld(fld_CP_HUE_CNTL, nhue);
			break;
		case RT200_ATI_ID:
			dsp_set_tint(t, (unsigned char)((hue*255)/2000 + 128));
			break;
	}
}

/****************************************************************************
 * RT_SetSaturation (int Saturation)                                        *
 *  Function: sets the saturation level for the Rage Theatre video in       *
 *    Inputs: int Saturation - the saturation value to be set.              *
 *   Outputs: NONE                                                          *
 ****************************************************************************/
void RT_SetSaturation(TheatrePtr t, int Saturation)
{
	unsigned short wSaturation_V, wSaturation_U;
	double dbSaturation = 0.0, dbCrGain = 0.0, dbCbGain = 0.0;
	/* VALIDATE SATURATION LEVEL */
	if(Saturation < -1000)
		Saturation = -1000;
	else if(Saturation > 1000)
		Saturation = 1000;
	t->iSaturation = Saturation;
	switch(t->theatre_id)
	{
		case RT100_ATI_ID:
			if(Saturation > 0)
				/* Scale saturation up, to use full allowable register width */
				Saturation = (double)(Saturation) * 4.9;
			dbSaturation = (double)(Saturation+1000.0) / 1000.0;
			CalculateCrCbGain(t, &dbCrGain, &dbCbGain, t->wStandard);
			wSaturation_U = (unsigned short)((long)((dbCrGain * dbSaturation * 128.0) + 0.5));
			wSaturation_V = (unsigned short)((long)((dbCbGain * dbSaturation * 128.0) + 0.5));
			/* SET SATURATION LEVEL */
			WriteRT_fld(fld_CRDR_ACTIVE_GAIN, wSaturation_U);
			WriteRT_fld(fld_CBDB_ACTIVE_GAIN, wSaturation_V);
			t->wSaturation_U = wSaturation_U;
			t->wSaturation_V = wSaturation_V;
			break;
		case RT200_ATI_ID:
			/* RT200 has saturation in range 0 to 255 with nominal value 128 */
			dsp_set_saturation(t, (unsigned char)((Saturation*255)/2000 + 128));
			break;
	}
}

/****************************************************************************
 * RT_SetBrightness (int Brightness)                                        *
 *  Function: sets the brightness level for the Rage Theatre video in       *
 *    Inputs: int Brightness - the brightness value to be set.              *
 *   Outputs: NONE                                                          *
 ****************************************************************************/
void RT_SetBrightness(TheatrePtr t, int Brightness)
{
	double dbSynctipRef0=0.0, dbContrast=1.0;
	double dbYgain=0.0, dbBrightness=0.0, dbSetup=0.0;
	unsigned short wBrightness=0;
	/* VALIDATE BRIGHTNESS LEVEL */
	if(Brightness < -1000)
		Brightness = -1000;
	else if(Brightness > 1000)
		Brightness = 1000;
	/* Save value */
	t->iBrightness = Brightness;
	t->dbBrightnessRatio = (double)(Brightness+1000.0) / 10.0;
	switch(t->theatre_id)
	{
		case RT100_ATI_ID:
			dbBrightness = (double)(Brightness)/10.0;
			dbSynctipRef0 = ReadRT_fld(fld_SYNCTIP_REF0);
			if(t->dbContrast == 0)
				t->dbContrast = 1.0; /*NTSC default; */
			dbContrast = (double) t->dbContrast;
			/* Use the following formula to determine the brightness level */
			switch(t->wStandard & 0x00FF)
			{
				case (DEC_NTSC):
					if((t->wStandard & 0xFF00) == extNTSC_J)
						dbYgain = 219.0 / ( 100.0 * (double)(dbSynctipRef0) /40.0);
					else
					{
						dbSetup = 7.5 * (double)(dbSynctipRef0) / 40.0;
						dbYgain = 219.0 / (92.5 * (double)(dbSynctipRef0) / 40.0);
					}
					break;
				case (DEC_PAL):
				case (DEC_SECAM):
					dbYgain = 219.0 / ( 100.0 * (double)(dbSynctipRef0) /43.0);
					break;
			}
			wBrightness = (unsigned short)((long)(16.0 * ((dbBrightness-dbSetup) + (16.0 / (dbContrast * dbYgain)))));
			WriteRT_fld(fld_LP_BRIGHTNESS, wBrightness);
			/* RT_SetSaturation (t->iSaturation); */
			break;
		case RT200_ATI_ID:
			 /* RT200 is having brightness level from 0 to 255  with 128 nominal value */
			 dsp_set_brightness(t, (unsigned char)((Brightness*255)/2000 + 128));
			break;	
	}
}

/****************************************************************************
 * RT_SetSharpness (unsigned short wSharpness)                              *
 *  Function: sets the sharpness level for the Rage Theatre video in        *
 *    Inputs: unsigned short wSharpness - the sharpness value to be set.    *
 *   Outputs: NONE                                                          *
 ****************************************************************************/
void RT_SetSharpness(TheatrePtr t, unsigned short wSharpness)
{
	switch(wSharpness)
	{
		case DEC_SMOOTH :
			WriteRT_fld(fld_H_SHARPNESS, RT_NORM_SHARPNESS);
			t->wSharpness = RT_NORM_SHARPNESS;
			break;
		case DEC_SHARP  :
			WriteRT_fld(fld_H_SHARPNESS, RT_HIGH_SHARPNESS);
			t->wSharpness = RT_HIGH_SHARPNESS;
			break;
		default:
			break;
	}
}

/****************************************************************************
 * RT_SetContrast (int Contrast)                                            *
 *  Function: sets the contrast level for the Rage Theatre video in         *
 *    Inputs: int Contrast - the contrast value to be set.                  *
 *   Outputs: NONE                                                          *
 ****************************************************************************/
void RT_SetContrast(TheatrePtr t, int Contrast)
{
	double dbSynctipRef0=0.0, dbContrast=0.0, dbYgain=0.0;
	unsigned char bTempContrast=0;
	/* VALIDATE CONTRAST LEVEL */
	if(Contrast < -1000)
		Contrast = -1000;
	else if(Contrast > 1000)
		Contrast = 1000;
	/* Save contrast value */
	t->iContrast = Contrast;
	switch(t->theatre_id)
	{
		case RT100_ATI_ID:
			dbSynctipRef0 = ReadRT_fld(fld_SYNCTIP_REF0);	
			dbContrast = (double)(Contrast+1000.0) / 1000.0;
			switch(t->wStandard & 0x00FF)
			{
				case (DEC_NTSC):
					if((t->wStandard & 0xFF00) == (extNTSC_J))
						dbYgain = 219.0 / (100.0 * (double)(dbSynctipRef0) /40.0);
					else
						dbYgain = 219.0 / (92.5 * (double)(dbSynctipRef0) /40.0);
					break;
				case (DEC_PAL):
				case (DEC_SECAM):
					dbYgain = 219.0 / (100.0 * (double)(dbSynctipRef0) /43.0);
					break;
			}
			bTempContrast = (unsigned char)((long)((dbContrast * dbYgain * 64) + 0.5));
			WriteRT_fld(fld_LP_CONTRAST, (unsigned long)bTempContrast);
			/* Save value for future modification */
			t->dbContrast = dbContrast;
			break;
		case RT200_ATI_ID:
    	t->dbContrast = (double)(Contrast+1000.0) / 1000.0;
			/* RT200 has contrast values between 0 to 255 with nominal value at 128 */
			dsp_set_contrast(t, (unsigned char)((Contrast*255)/2000 + 128));
			break;
	}
}

/****************************************************************************
 * RT_SetInterlace (unsigned char bInterlace)                               *
 *  Function: to set the interlacing pattern for the Rage Theatre video in  *
 *    Inputs: unsigned char bInterlace                                      *
 *   Outputs: NONE                                                          *
 ****************************************************************************/
void RT_SetInterlace(TheatrePtr t, unsigned char bInterlace)
{
	switch(bInterlace)
	{
		case (TRUE):    /*DEC_INTERLACE */
			WriteRT_fld(fld_V_DEINTERLACE_ON, 0x1);
			t->wInterlaced = (unsigned short) RT_DECINTERLACED;
			break;
		case (FALSE):   /*DEC_NONINTERLACE */
			WriteRT_fld(fld_V_DEINTERLACE_ON, RT_DECNONINTERLACED);
			t->wInterlaced = (unsigned short)RT_DECNONINTERLACED;
			break;
		default:
			break;
	}
}

/****************************************************************************
 * GetStandardConstants (double *LPeriod, double *FPeriod,                  *
 *                          double *Fsamp, unsigned short wStandard)        *
 *  Function: return timing values for a given standard                     *
 *    Inputs: double *LPeriod -                                             *
 *            double *FPeriod -                                             *
 *            double *Fsamp - sampling frequency used for a given standard  *
 *            unsigned short wStandard - input standard (NTSC, PAL, SECAM)  *
 *   Outputs: NONE                                                          *
 ****************************************************************************/
static void GetStandardConstants(double *LPeriod, double *FPeriod, double *Fsamp, unsigned short wStandard)
{
	*LPeriod = *FPeriod = *Fsamp = 0.0;
	switch(wStandard & 0x00FF)
	{
		case (DEC_NTSC): /*NTSC GROUP - 480 lines*/
			switch (wStandard & 0xFF00)
			{
				case (extNONE):
				case (extNTSC):
				case (extNTSC_J):
					*LPeriod = 63.5555;
					*FPeriod = 16.6833;
					*Fsamp = 28.63636;
					break;
				case (extPAL_M):
					*LPeriod = 63.492;
					*FPeriod = 16.667;
					*Fsamp = 28.63689192;
					break;
				default:
					return;
			}
			break;
		case (DEC_PAL):
			if((wStandard & 0xFF00) == extPAL_N)
			{
				*LPeriod = 64.0;
				*FPeriod = 20.0;
				*Fsamp = 28.65645;
			}
			else
			{
				*LPeriod = 64.0;
				*FPeriod = 20.0;
				*Fsamp = 35.46895;
			}
			break;
		case (DEC_SECAM):
			*LPeriod = 64.0;
			*FPeriod = 20.0;
			*Fsamp = 35.46895;
			break;
	}
}

/****************************************************************************
 * RT_SetStandard (unsigned short wStandard)                                *
 *  Function: to set the input standard for the Rage Theatre video in       *
 *    Inputs: unsigned short wStandard - input standard (NTSC, PAL, SECAM)  *
 *   Outputs: NONE                                                          *
 ****************************************************************************/
void RT_SetStandard(TheatrePtr t, unsigned short wStandard)
{
	double dbFsamp=0.0, dbLPeriod=0.0, dbFPeriod=0.0;
	unsigned short wFrameTotal = 0;
	double dbSPPeriod = 4.70;
	DPRINTVALHEX("Rage Theatre setting standard ", wStandard);
	DPRINT("\r\n");
	t->wStandard = wStandard;
	switch(t->theatre_id)
	{
		case RT100_ATI_ID:
			/* Get the constants for the given standard. */    
			GetStandardConstants(&dbLPeriod, &dbFPeriod, &dbFsamp, wStandard);
			wFrameTotal = (unsigned short)((long)(((2.0 * dbFPeriod) * 1000 / dbLPeriod) + 0.5));
			/* Procedures before setting the standards: */
			WriteRT_fld(fld_VIN_CLK_SEL, RT_REF_CLK);
			WriteRT_fld(fld_VINRST, RT_VINRST_RESET);
			RT_SetVINClock(t, wStandard);
			WriteRT_fld(fld_VINRST, RT_VINRST_ACTIVE);
			WriteRT_fld(fld_VIN_CLK_SEL, RT_PLL_VIN_CLK);
			/* Program the new standards: */
			switch (wStandard & 0x00FF)
			{
				case (DEC_NTSC): /* NTSC GROUP - 480 lines */
					WriteRT_fld(fld_STANDARD_SEL,     RT_NTSC);
					WriteRT_fld(fld_SYNCTIP_REF0,     RT_NTSCM_SYNCTIP_REF0);
					WriteRT_fld(fld_SYNCTIP_REF1,     RT_NTSCM_SYNCTIP_REF1);
					WriteRT_fld(fld_CLAMP_REF,         RT_NTSCM_CLAMP_REF);
					WriteRT_fld(fld_AGC_PEAKWHITE,    RT_NTSCM_PEAKWHITE);
					WriteRT_fld(fld_VBI_PEAKWHITE,    RT_NTSCM_VBI_PEAKWHITE);
					WriteRT_fld(fld_WPA_THRESHOLD,    RT_NTSCM_WPA_THRESHOLD);
					WriteRT_fld(fld_WPA_TRIGGER_LO,   RT_NTSCM_WPA_TRIGGER_LO);
					WriteRT_fld(fld_WPA_TRIGGER_HIGH, RT_NTSCM_WPA_TRIGGER_HIGH);
					WriteRT_fld(fld_LOCKOUT_START,    RT_NTSCM_LP_LOCKOUT_START);
					WriteRT_fld(fld_LOCKOUT_END,      RT_NTSCM_LP_LOCKOUT_END);
					WriteRT_fld(fld_CH_DTO_INC,       RT_NTSCM_CH_DTO_INC);
					WriteRT_fld(fld_PLL_SGAIN,        RT_NTSCM_CH_PLL_SGAIN);
					WriteRT_fld(fld_PLL_FGAIN,        RT_NTSCM_CH_PLL_FGAIN);
					WriteRT_fld(fld_CH_HEIGHT,        RT_NTSCM_CH_HEIGHT);
					WriteRT_fld(fld_CH_KILL_LEVEL,    RT_NTSCM_CH_KILL_LEVEL);
					WriteRT_fld(fld_CH_AGC_ERROR_LIM, RT_NTSCM_CH_AGC_ERROR_LIM);
					WriteRT_fld(fld_CH_AGC_FILTER_EN, RT_NTSCM_CH_AGC_FILTER_EN);
					WriteRT_fld(fld_CH_AGC_LOOP_SPEED,RT_NTSCM_CH_AGC_LOOP_SPEED);
					WriteRT_fld(fld_VS_FIELD_BLANK_START,  RT_NTSCM_VS_FIELD_BLANK_START);
					WriteRT_fld(fld_VS_FIELD_BLANK_END,   RT_NTSCM_VS_FIELD_BLANK_END);
					WriteRT_fld(fld_H_ACTIVE_START,   RT_NTSCM_H_ACTIVE_START);
					WriteRT_fld(fld_H_ACTIVE_END,   RT_NTSCM_H_ACTIVE_END);
					WriteRT_fld(fld_V_ACTIVE_START,   RT_NTSCM_V_ACTIVE_START);
					WriteRT_fld(fld_V_ACTIVE_END,   RT_NTSCM_V_ACTIVE_END);
					WriteRT_fld(fld_H_VBI_WIND_START,   RT_NTSCM_H_VBI_WIND_START);
					WriteRT_fld(fld_H_VBI_WIND_END,   RT_NTSCM_H_VBI_WIND_END);
					WriteRT_fld(fld_V_VBI_WIND_START,   RT_NTSCM_V_VBI_WIND_START);
					WriteRT_fld(fld_V_VBI_WIND_END,   RT_NTSCM_V_VBI_WIND_END);
					WriteRT_fld(fld_UV_INT_START,   (unsigned char)((long)((0.10 * dbLPeriod * dbFsamp / 2.0) + 0.5 - 32)));
					WriteRT_fld(fld_VSYNC_INT_TRIGGER , (unsigned short)RT_NTSCM_VSYNC_INT_TRIGGER);
					WriteRT_fld(fld_VSYNC_INT_HOLD, (unsigned short)RT_NTSCM_VSYNC_INT_HOLD);
					switch(wStandard & 0xFF00)
					{
						case (extPAL_M):
						case (extNONE):
						case (extNTSC):
							WriteRT_fld(fld_CR_BURST_GAIN,        RT_NTSCM_CR_BURST_GAIN);
							WriteRT_fld(fld_CB_BURST_GAIN,        RT_NTSCM_CB_BURST_GAIN);
							WriteRT_fld(fld_CRDR_ACTIVE_GAIN,     RT_NTSCM_CRDR_ACTIVE_GAIN);
							WriteRT_fld(fld_CBDB_ACTIVE_GAIN,     RT_NTSCM_CBDB_ACTIVE_GAIN);
							WriteRT_fld(fld_VERT_LOCKOUT_START,   RT_NTSCM_VERT_LOCKOUT_START);
							WriteRT_fld(fld_VERT_LOCKOUT_END,     RT_NTSCM_VERT_LOCKOUT_END);
							break;
						case (extNTSC_J):
							WriteRT_fld(fld_CR_BURST_GAIN,        RT_NTSCJ_CR_BURST_GAIN);
							WriteRT_fld(fld_CB_BURST_GAIN,        RT_NTSCJ_CB_BURST_GAIN);
							WriteRT_fld(fld_CRDR_ACTIVE_GAIN,     RT_NTSCJ_CRDR_ACTIVE_GAIN);
							WriteRT_fld(fld_CBDB_ACTIVE_GAIN,     RT_NTSCJ_CBDB_ACTIVE_GAIN);
							WriteRT_fld(fld_CH_HEIGHT,            RT_NTSCJ_CH_HEIGHT);
							WriteRT_fld(fld_CH_KILL_LEVEL,        RT_NTSCJ_CH_KILL_LEVEL);
							WriteRT_fld(fld_CH_AGC_ERROR_LIM,     RT_NTSCJ_CH_AGC_ERROR_LIM);
							WriteRT_fld(fld_CH_AGC_FILTER_EN,     RT_NTSCJ_CH_AGC_FILTER_EN);
							WriteRT_fld(fld_CH_AGC_LOOP_SPEED,    RT_NTSCJ_CH_AGC_LOOP_SPEED);
							WriteRT_fld(fld_VERT_LOCKOUT_START,   RT_NTSCJ_VERT_LOCKOUT_START);
							WriteRT_fld(fld_VERT_LOCKOUT_END,     RT_NTSCJ_VERT_LOCKOUT_END);
							break;
					}
					break;
				case (DEC_PAL):  /* PAL GROUP  - 525 lines */
					WriteRT_fld(fld_STANDARD_SEL,     RT_PAL);
					WriteRT_fld(fld_SYNCTIP_REF0,     RT_PAL_SYNCTIP_REF0);
					WriteRT_fld(fld_SYNCTIP_REF1,     RT_PAL_SYNCTIP_REF1);
					WriteRT_fld(fld_CLAMP_REF,         RT_PAL_CLAMP_REF);
					WriteRT_fld(fld_AGC_PEAKWHITE,    RT_PAL_PEAKWHITE);
					WriteRT_fld(fld_VBI_PEAKWHITE,    RT_PAL_VBI_PEAKWHITE);
					WriteRT_fld(fld_WPA_THRESHOLD,    RT_PAL_WPA_THRESHOLD);
					WriteRT_fld(fld_WPA_TRIGGER_LO,   RT_PAL_WPA_TRIGGER_LO);
					WriteRT_fld(fld_WPA_TRIGGER_HIGH, RT_PAL_WPA_TRIGGER_HIGH);
					WriteRT_fld(fld_LOCKOUT_START,RT_PAL_LP_LOCKOUT_START);
					WriteRT_fld(fld_LOCKOUT_END,  RT_PAL_LP_LOCKOUT_END);
					WriteRT_fld(fld_CH_DTO_INC,       RT_PAL_CH_DTO_INC);
					WriteRT_fld(fld_PLL_SGAIN,        RT_PAL_CH_PLL_SGAIN);
					WriteRT_fld(fld_PLL_FGAIN,        RT_PAL_CH_PLL_FGAIN);
					WriteRT_fld(fld_CR_BURST_GAIN,    RT_PAL_CR_BURST_GAIN);
					WriteRT_fld(fld_CB_BURST_GAIN,    RT_PAL_CB_BURST_GAIN);
					WriteRT_fld(fld_CRDR_ACTIVE_GAIN, RT_PAL_CRDR_ACTIVE_GAIN);
					WriteRT_fld(fld_CBDB_ACTIVE_GAIN, RT_PAL_CBDB_ACTIVE_GAIN);
					WriteRT_fld(fld_CH_HEIGHT,        RT_PAL_CH_HEIGHT);
					WriteRT_fld(fld_CH_KILL_LEVEL,    RT_PAL_CH_KILL_LEVEL);
					WriteRT_fld(fld_CH_AGC_ERROR_LIM, RT_PAL_CH_AGC_ERROR_LIM);
					WriteRT_fld(fld_CH_AGC_FILTER_EN, RT_PAL_CH_AGC_FILTER_EN);
					WriteRT_fld(fld_CH_AGC_LOOP_SPEED,RT_PAL_CH_AGC_LOOP_SPEED);
					WriteRT_fld(fld_VERT_LOCKOUT_START,   RT_PAL_VERT_LOCKOUT_START);
					WriteRT_fld(fld_VERT_LOCKOUT_END, RT_PAL_VERT_LOCKOUT_END);
					WriteRT_fld(fld_VS_FIELD_BLANK_START,  (unsigned short)RT_PALSEM_VS_FIELD_BLANK_START);
					WriteRT_fld(fld_VS_FIELD_BLANK_END,   RT_PAL_VS_FIELD_BLANK_END);
					WriteRT_fld(fld_H_ACTIVE_START,   RT_PAL_H_ACTIVE_START);
					WriteRT_fld(fld_H_ACTIVE_END,   RT_PAL_H_ACTIVE_END);
					WriteRT_fld(fld_V_ACTIVE_START,   RT_PAL_V_ACTIVE_START);
					WriteRT_fld(fld_V_ACTIVE_END,   RT_PAL_V_ACTIVE_END);
					WriteRT_fld(fld_H_VBI_WIND_START,   RT_PAL_H_VBI_WIND_START);
					WriteRT_fld(fld_H_VBI_WIND_END,   RT_PAL_H_VBI_WIND_END);
					WriteRT_fld(fld_V_VBI_WIND_START,   RT_PAL_V_VBI_WIND_START);
					WriteRT_fld(fld_V_VBI_WIND_END,   RT_PAL_V_VBI_WIND_END);
					/* Magic 0.10 is correct - according to Ivo. Also see SECAM code below */
					/* WriteRT_fld(fld_UV_INT_START,   (unsigned char)((long)((0.12 * dbLPeriod * dbFsamp / 2.0) + 0.5 - 32 ))); */
					WriteRT_fld(fld_UV_INT_START,   (unsigned char)((long)((0.10 * dbLPeriod * dbFsamp / 2.0) + 0.5 - 32 )));
					WriteRT_fld(fld_VSYNC_INT_TRIGGER , (unsigned short)RT_PALSEM_VSYNC_INT_TRIGGER);
					WriteRT_fld(fld_VSYNC_INT_HOLD, (unsigned short)RT_PALSEM_VSYNC_INT_HOLD);
					break;
				case (DEC_SECAM):  /* SECAM GROUP */
					WriteRT_fld(fld_STANDARD_SEL,     RT_SECAM);
					WriteRT_fld(fld_SYNCTIP_REF0,     RT_SECAM_SYNCTIP_REF0);
					WriteRT_fld(fld_SYNCTIP_REF1,     RT_SECAM_SYNCTIP_REF1);
					WriteRT_fld(fld_CLAMP_REF,        RT_SECAM_CLAMP_REF);
					WriteRT_fld(fld_AGC_PEAKWHITE,    RT_SECAM_PEAKWHITE);
					WriteRT_fld(fld_VBI_PEAKWHITE,    RT_SECAM_VBI_PEAKWHITE);
					WriteRT_fld(fld_WPA_THRESHOLD,    RT_SECAM_WPA_THRESHOLD);
					WriteRT_fld(fld_WPA_TRIGGER_LO,   RT_SECAM_WPA_TRIGGER_LO);
					WriteRT_fld(fld_WPA_TRIGGER_HIGH, RT_SECAM_WPA_TRIGGER_HIGH);
					WriteRT_fld(fld_LOCKOUT_START,RT_SECAM_LP_LOCKOUT_START);
					WriteRT_fld(fld_LOCKOUT_END,  RT_SECAM_LP_LOCKOUT_END);
					WriteRT_fld(fld_CH_DTO_INC,       RT_SECAM_CH_DTO_INC);
					WriteRT_fld(fld_PLL_SGAIN,        RT_SECAM_CH_PLL_SGAIN);
					WriteRT_fld(fld_PLL_FGAIN,        RT_SECAM_CH_PLL_FGAIN);
					WriteRT_fld(fld_CR_BURST_GAIN,    RT_SECAM_CR_BURST_GAIN);
					WriteRT_fld(fld_CB_BURST_GAIN,    RT_SECAM_CB_BURST_GAIN);
					WriteRT_fld(fld_CRDR_ACTIVE_GAIN, RT_SECAM_CRDR_ACTIVE_GAIN);
					WriteRT_fld(fld_CBDB_ACTIVE_GAIN, RT_SECAM_CBDB_ACTIVE_GAIN);
					WriteRT_fld(fld_CH_HEIGHT,        RT_SECAM_CH_HEIGHT);
					WriteRT_fld(fld_CH_KILL_LEVEL,    RT_SECAM_CH_KILL_LEVEL);
					WriteRT_fld(fld_CH_AGC_ERROR_LIM, RT_SECAM_CH_AGC_ERROR_LIM);
					WriteRT_fld(fld_CH_AGC_FILTER_EN, RT_SECAM_CH_AGC_FILTER_EN);
					WriteRT_fld(fld_CH_AGC_LOOP_SPEED,RT_SECAM_CH_AGC_LOOP_SPEED);
					WriteRT_fld(fld_VERT_LOCKOUT_START,   RT_SECAM_VERT_LOCKOUT_START);  /*Might not need */
					WriteRT_fld(fld_VERT_LOCKOUT_END, RT_SECAM_VERT_LOCKOUT_END);  /* Might not need */
					WriteRT_fld(fld_VS_FIELD_BLANK_START,  (unsigned short)RT_PALSEM_VS_FIELD_BLANK_START);
					WriteRT_fld(fld_VS_FIELD_BLANK_END,   RT_PAL_VS_FIELD_BLANK_END);
					WriteRT_fld(fld_H_ACTIVE_START,   RT_PAL_H_ACTIVE_START);
					WriteRT_fld(fld_H_ACTIVE_END,   RT_PAL_H_ACTIVE_END);
					WriteRT_fld(fld_V_ACTIVE_START,   RT_PAL_V_ACTIVE_START);
					WriteRT_fld(fld_V_ACTIVE_END,   RT_PAL_V_ACTIVE_END);
					WriteRT_fld(fld_H_VBI_WIND_START,   RT_PAL_H_VBI_WIND_START);
					WriteRT_fld(fld_H_VBI_WIND_END,   RT_PAL_H_VBI_WIND_END);
					WriteRT_fld(fld_V_VBI_WIND_START,   RT_PAL_V_VBI_WIND_START);
					WriteRT_fld(fld_V_VBI_WIND_END,   RT_PAL_V_VBI_WIND_END);
					WriteRT_fld(fld_VSYNC_INT_TRIGGER , (unsigned short)RT_PALSEM_VSYNC_INT_TRIGGER);
					WriteRT_fld(fld_VSYNC_INT_HOLD, (unsigned short)RT_PALSEM_VSYNC_INT_HOLD);
					/* WriteRT_fld (fld_UV_INT_START,   (unsigned char)((long)((0.12 * dbLPeriod * dbFsamp / 2.0) + 0.5 - 32 ))); */
					WriteRT_fld (fld_UV_INT_START,   (unsigned char)((long)((0.10 * dbLPeriod * dbFsamp / 2.0) + 0.5 - 32 )));
					break;
			}
			if(t->wConnector == DEC_SVIDEO)
				RT_SetCombFilter(t, wStandard, RT_SVIDEO);
			else
				/* Set up extra (connector and std) registers. */
				RT_SetCombFilter(t, wStandard, RT_COMPOSITE);
			/* Set the following values according to the formulas */
			WriteRT_fld(fld_HS_LINE_TOTAL, (unsigned short)((long)((dbLPeriod * dbFsamp / 2.0) +0.5)));
			/* According to Ivo PAL/SECAM needs different treatment */
			switch(wStandard & 0x00FF)
			{
				case DEC_PAL:
				case DEC_SECAM:
					WriteRT_fld(fld_MIN_PULSE_WIDTH, (unsigned char)((long)(0.5 * dbSPPeriod * dbFsamp/2.0)));
					WriteRT_fld(fld_MAX_PULSE_WIDTH, (unsigned char)((long)(1.5 * dbSPPeriod * dbFsamp/2.0)));
					WriteRT_fld(fld_WIN_OPEN_LIMIT, (unsigned short)((long)(((dbLPeriod * dbFsamp / 4.0) + 0.5) - 16)));
					WriteRT_fld(fld_WIN_CLOSE_LIMIT, (unsigned short)((long)(2.39 * dbSPPeriod * dbFsamp / 2.0)));
					/* WriteRT_fld(fld_VS_FIELD_IDLOCATION, (unsigned short)RT_PAL_FIELD_IDLOCATION); */
					/* According to docs the following value will work right, though the resulting stream deviates
				     slightly from CCIR..., in particular the value that was before will do nuts to VCRs in pause/rewind state */
					WriteRT_fld(fld_VS_FIELD_IDLOCATION, (unsigned short)0x01);
					WriteRT_fld(fld_HS_PLL_SGAIN, 2);
					break;
		  	case DEC_NTSC:
					WriteRT_fld(fld_MIN_PULSE_WIDTH, (unsigned char)((long)(0.75 * dbSPPeriod * dbFsamp/2.0)));
					WriteRT_fld(fld_MAX_PULSE_WIDTH, (unsigned char)((long)(1.25 * dbSPPeriod * dbFsamp/2.0)));
					WriteRT_fld(fld_WIN_OPEN_LIMIT, (unsigned short)((long)(((dbLPeriod * dbFsamp / 4.0) + 0.5) - 16)));
					WriteRT_fld(fld_WIN_CLOSE_LIMIT, (unsigned short)((long)(1.15 * dbSPPeriod * dbFsamp / 2.0)));
					/* WriteRT_fld(fld_VS_FIELD_IDLOCATION, (unsigned short)fld_VS_FIELD_IDLOCATION_def);*/
					/* I think the default value was the same as the one here.. does not hurt to hardcode it */
					WriteRT_fld(fld_VS_FIELD_IDLOCATION, (unsigned short)0x01);
					break;
			}
			WriteRT_fld(fld_VS_FRAME_TOTAL, (unsigned short)(wFrameTotal + 10));
			WriteRT_fld(fld_BLACK_INT_START, (unsigned char)((long)((0.09 * dbLPeriod * dbFsamp / 2.0) - 32 )));
			WriteRT_fld(fld_SYNC_TIP_START, (unsigned short)((long)((dbLPeriod * dbFsamp / 2.0 + 0.5) - 28)));
			break;
		case RT200_ATI_ID:
			/* Program the new standards: */
			switch (wStandard & 0x00FF)
			{
				case (DEC_NTSC): /*NTSC GROUP - 480 lines */
					switch(wStandard & 0xFF00)
					{
						case (extNONE):
						case (extNTSC): dsp_set_video_standard(t, 2); break;
						case (extNTSC_J): dsp_set_video_standard(t, RT200_NTSC_J); break;
						case (extNTSC_443): dsp_set_video_standard(t, RT200_NTSC_433); break;
						default: dsp_video_standard_detection(t); break;
					}
					break;
				case (DEC_PAL):  /*PAL GROUP  - 625 lines */
					switch (wStandard & 0xFF00)
					{
						case (extNONE):
						case (extPAL):
						case (extPAL_B):
						case (extPAL_BGHI): dsp_set_video_standard(t, RT200_PAL_B); break;
						case (extPAL_D): dsp_set_video_standard(t, RT200_PAL_D); break;
						case (extPAL_G): dsp_set_video_standard(t, RT200_PAL_G); break;
						case (extPAL_H): dsp_set_video_standard(t, RT200_PAL_H); break;
						case (extPAL_I): dsp_set_video_standard(t, RT200_PAL_D); break;
						case (extPAL_N): dsp_set_video_standard(t, RT200_PAL_N); break;
						case (extPAL_NCOMB): dsp_set_video_standard(t, RT200_PAL_Ncomb); break;
						case (extPAL_M): dsp_set_video_standard(t, RT200_PAL_M); break;
						case (extPAL_60): dsp_set_video_standard(t, RT200_PAL_60); break;
						default: dsp_video_standard_detection(t); break;
					}
					break;
			  case (DEC_SECAM):  /*SECAM GROUP*/
					switch (wStandard & 0xFF00)
					{
						case (extNONE):
						case (extSECAM): dsp_set_video_standard(t, RT200_SECAM); break;
						case (extSECAM_B): dsp_set_video_standard(t, RT200_SECAM_B); break;
						case (extSECAM_D): dsp_set_video_standard(t, RT200_SECAM_D); break;
						case (extSECAM_G): dsp_set_video_standard(t, RT200_SECAM_G); break;
						case (extSECAM_H): dsp_set_video_standard(t, RT200_SECAM_H); break;
						case (extSECAM_K): dsp_set_video_standard(t, RT200_SECAM_K); break;
						case (extSECAM_K1): dsp_set_video_standard(t, RT200_SECAM_K1); break;
						case (extSECAM_L): dsp_set_video_standard(t, RT200_SECAM_L); break;
						case (extSECAM_L1): dsp_set_video_standard(t, RT200_SECAM_L1); break;
						default: dsp_video_standard_detection(t); break;
					}
					break;
				default: dsp_video_standard_detection(t); break;
			}
			break;
	}
}

/****************************************************************************
 * RT_SetCombFilter (unsigned short wStandard, unsigned short wConnector)   *
 *  Function: sets the input comb filter based on the standard and          *
 *            connector being used (composite vs. svideo)                   *
 *    Inputs: unsigned short wStandard - input standard (NTSC, PAL, SECAM)  *
 *            unsigned short wConnector - COMPOSITE, SVIDEO                 *
 *   Outputs: NONE                                                          *
 ****************************************************************************/
void RT_SetCombFilter(TheatrePtr t, unsigned short wStandard, unsigned short wConnector)
{
	unsigned long dwComb_Cntl0=0, dwComb_Cntl1=0, dwComb_Cntl2=0, dwComb_Line_Length=0;
	switch(wConnector)
	{
		case RT_COMPOSITE:
			switch(wStandard & 0x00FF)
			{
				case (DEC_NTSC):
					switch(wStandard & 0xFF00)
					{
						case (extNONE):
						case (extNTSC):
						case (extNTSC_J):
							dwComb_Cntl0= RT_NTSCM_COMB_CNTL0_COMPOSITE;
							dwComb_Cntl1= RT_NTSCM_COMB_CNTL1_COMPOSITE;
							dwComb_Cntl2= RT_NTSCM_COMB_CNTL2_COMPOSITE;
							dwComb_Line_Length= RT_NTSCM_COMB_LENGTH_COMPOSITE;
							break;
						case (extPAL_M):
							dwComb_Cntl0= RT_PALM_COMB_CNTL0_COMPOSITE;
							dwComb_Cntl1= RT_PALM_COMB_CNTL1_COMPOSITE;
							dwComb_Cntl2= RT_PALM_COMB_CNTL2_COMPOSITE;
							dwComb_Line_Length= RT_PALM_COMB_LENGTH_COMPOSITE;
							break;
						default:
							return;
					}
					break;
				case (DEC_PAL):
					switch(wStandard & 0xFF00)
					{
						case (extNONE):
						case (extPAL):
							dwComb_Cntl0=   RT_PAL_COMB_CNTL0_COMPOSITE;
							dwComb_Cntl1=   RT_PAL_COMB_CNTL1_COMPOSITE;
							dwComb_Cntl2=   RT_PAL_COMB_CNTL2_COMPOSITE;
							dwComb_Line_Length=  RT_PAL_COMB_LENGTH_COMPOSITE;
							break;
						case (extPAL_N):
							dwComb_Cntl0=   RT_PALN_COMB_CNTL0_COMPOSITE;
							dwComb_Cntl1=   RT_PALN_COMB_CNTL1_COMPOSITE;
							dwComb_Cntl2=   RT_PALN_COMB_CNTL2_COMPOSITE;
							dwComb_Line_Length=  RT_PALN_COMB_LENGTH_COMPOSITE;
							break;
						default:
							return;
					}
					break;
				case (DEC_SECAM):
					dwComb_Cntl0=   RT_SECAM_COMB_CNTL0_COMPOSITE;
					dwComb_Cntl1=   RT_SECAM_COMB_CNTL1_COMPOSITE;
					dwComb_Cntl2=   RT_SECAM_COMB_CNTL2_COMPOSITE;
					dwComb_Line_Length=  RT_SECAM_COMB_LENGTH_COMPOSITE;
					break;
				default:
					return;
			}
			break;
		case RT_SVIDEO:
			switch (wStandard & 0x00FF)
			{
				case (DEC_NTSC):
					switch(wStandard & 0xFF00)
					{
						case (extNONE):
						case (extNTSC):
							dwComb_Cntl0= RT_NTSCM_COMB_CNTL0_SVIDEO;
							dwComb_Cntl1= RT_NTSCM_COMB_CNTL1_SVIDEO;
							dwComb_Cntl2= RT_NTSCM_COMB_CNTL2_SVIDEO;
							dwComb_Line_Length= RT_NTSCM_COMB_LENGTH_SVIDEO;
							break;
						case (extPAL_M):
							dwComb_Cntl0= RT_PALM_COMB_CNTL0_SVIDEO;
							dwComb_Cntl1= RT_PALM_COMB_CNTL1_SVIDEO;
							dwComb_Cntl2= RT_PALM_COMB_CNTL2_SVIDEO;
							dwComb_Line_Length= RT_PALM_COMB_LENGTH_SVIDEO;
							break;
						default:
							return;
					}
					break;
				case (DEC_PAL):
					switch(wStandard & 0xFF00)
					{
						case (extNONE):
						case (extPAL):
							dwComb_Cntl0=   RT_PAL_COMB_CNTL0_SVIDEO;
							dwComb_Cntl1=   RT_PAL_COMB_CNTL1_SVIDEO;
							dwComb_Cntl2=   RT_PAL_COMB_CNTL2_SVIDEO;
							dwComb_Line_Length=  RT_PAL_COMB_LENGTH_SVIDEO;
							break;
						case (extPAL_N):
							dwComb_Cntl0=   RT_PALN_COMB_CNTL0_SVIDEO;
							dwComb_Cntl1=   RT_PALN_COMB_CNTL1_SVIDEO;
							dwComb_Cntl2=   RT_PALN_COMB_CNTL2_SVIDEO;
							dwComb_Line_Length=  RT_PALN_COMB_LENGTH_SVIDEO;
							break;
						default:
							return;
					}
					break;
				case (DEC_SECAM):
					dwComb_Cntl0=   RT_SECAM_COMB_CNTL0_SVIDEO;
					dwComb_Cntl1=   RT_SECAM_COMB_CNTL1_SVIDEO;
					dwComb_Cntl2=   RT_SECAM_COMB_CNTL2_SVIDEO;
					dwComb_Line_Length=  RT_SECAM_COMB_LENGTH_SVIDEO;
					break;
				default:
					return;
			}
			break;
		default:
			return;
	}
	WriteRT_fld(fld_COMB_CNTL0, dwComb_Cntl0);
	WriteRT_fld(fld_COMB_CNTL1, dwComb_Cntl1);
	WriteRT_fld(fld_COMB_CNTL2, dwComb_Cntl2);
	WriteRT_fld(fld_COMB_LENGTH, dwComb_Line_Length);
}

/****************************************************************************
 * RT_SetOutputVideoSize (unsigned short wHorzSize, unsigned short wVertSize,*
 *                          unsigned char fCC_On, unsigned char fVBICap_On) *
 *  Function: sets the output video size for the Rage Theatre video in      *
 *    Inputs: unsigned short wHorzSize - width of output in pixels          *
 *            unsigned short wVertSize - height of output in pixels (lines) *
 *            unsigned char fCC_On - enable CC output                       *
 *            unsigned char fVBI_Cap_On - enable VBI capture                *
 *   Outputs: NONE                                                          *
 ****************************************************************************/
void RT_SetOutputVideoSize(TheatrePtr t, unsigned short wHorzSize, unsigned short wVertSize, unsigned char fCC_On, unsigned char fVBICap_On)
{
	unsigned long dwHwinStart=0, dwHScaleRatio=0, dwHActiveLength=0;
	unsigned long dwVwinStart=0, dwVScaleRatio=0, dwVActiveLength=0;
	unsigned long dwTempRatio=0, dwEvenFieldOffset=0, dwOddFieldOffset=0;
	unsigned long dwXin=0, dwYin=0;
	switch(t->theatre_id)
	{
		case RT100_ATI_ID:
			if(fVBICap_On)
			{
				WriteRT_fld(fld_VBI_CAPTURE_ENABLE, 1);
				WriteRT_fld(fld_VBI_SCALING_RATIO, fld_VBI_SCALING_RATIO_def);
				switch(t->wStandard & 0x00FF)
				{
					case (DEC_NTSC):
						WriteRT_fld (fld_H_VBI_WIND_START,  RT_NTSCM_H_VBI_WIND_START);
						WriteRT_fld(fld_H_VBI_WIND_END, RT_NTSCM_H_VBI_WIND_END);
						WriteRT_fld(fld_V_VBI_WIND_START, RT_NTSCM_V_VBI_WIND_START);
						WriteRT_fld(fld_V_VBI_WIND_END, RT_NTSCM_V_VBI_WIND_END);
						break;
					case (DEC_PAL):
						WriteRT_fld(fld_H_VBI_WIND_START, RT_PAL_H_VBI_WIND_START);
						WriteRT_fld(fld_H_VBI_WIND_END, RT_PAL_H_VBI_WIND_END);
						WriteRT_fld(fld_V_VBI_WIND_START, RT_PAL_V_VBI_WIND_START);
						WriteRT_fld(fld_V_VBI_WIND_END, RT_PAL_V_VBI_WIND_END);
						break;
					case (DEC_SECAM):
						WriteRT_fld(fld_H_VBI_WIND_START, RT_PAL_H_VBI_WIND_START);
						WriteRT_fld(fld_H_VBI_WIND_END, RT_PAL_H_VBI_WIND_END);
						WriteRT_fld(fld_V_VBI_WIND_START, RT_PAL_V_VBI_WIND_START);
						WriteRT_fld(fld_V_VBI_WIND_END, RT_PAL_V_VBI_WIND_END);
						break;
				}
			}   		
			else
				WriteRT_fld (fld_VBI_CAPTURE_ENABLE, 0);
			if(t->wInterlaced != RT_DECINTERLACED)
				wVertSize *= 2;
			/* 1. Calculate Horizontal Scaling ratio: */
			switch(t->wStandard & 0x00FF)
			{
				case (DEC_NTSC):
					dwHwinStart = RT_NTSCM_H_IN_START;
					dwXin = (ReadRT_fld(fld_H_ACTIVE_END) - ReadRT_fld(fld_H_ACTIVE_START)); /*tempscaler*/
					dwXin = RT_NTSC_H_ACTIVE_SIZE;
					dwHScaleRatio = (unsigned long) ((long) dwXin * 65536L / wHorzSize);
					dwHScaleRatio = dwHScaleRatio & 0x001FFFFF; /*21 bit number;*/
					dwHActiveLength = wHorzSize;
					break;
				case (DEC_PAL):
					dwHwinStart = RT_PAL_H_IN_START;
					dwXin = RT_PAL_H_ACTIVE_SIZE;
					dwHScaleRatio = (unsigned long) ((long) dwXin * 65536L / wHorzSize);
					dwHScaleRatio = dwHScaleRatio & 0x001FFFFF; /*21 bit number;*/
					dwHActiveLength = wHorzSize;
					break;
				case (DEC_SECAM):
					dwHwinStart = RT_SECAM_H_IN_START;
					dwXin = RT_SECAM_H_ACTIVE_SIZE;
					dwHScaleRatio = (unsigned long) ((long) dwXin * 65536L / wHorzSize);
					dwHScaleRatio = dwHScaleRatio & 0x001FFFFF; /*21 bit number;*/
					dwHActiveLength = wHorzSize;
					break;
			}
			/* 2. Calculate Vertical Scaling ratio: */
			switch(t->wStandard & 0x00FF)
			{
				case (DEC_NTSC):
				dwVwinStart = RT_NTSCM_V_IN_START;
				/* dwYin = (ReadRT_fld(fld_V_ACTIVE_END) - ReadRT_fld(fld_V_ACTIVE_START)); */ /*tempscaler*/
	  	  dwYin = RT_NTSCM_V_ACTIVE_SIZE;
				dwTempRatio = (unsigned long)((long) wVertSize / dwYin);
				dwVScaleRatio = (unsigned long)((long)wVertSize * 2048L / dwYin);
				dwVScaleRatio = dwVScaleRatio & 0x00000FFF;
				dwVActiveLength = wVertSize/2;
				break;
			case (DEC_PAL):
				dwVwinStart = RT_PAL_V_IN_START;
				dwYin = RT_PAL_V_ACTIVE_SIZE;
				dwTempRatio = (unsigned long)(wVertSize/dwYin);
				dwVScaleRatio = (unsigned long)((long)wVertSize * 2048L / dwYin);
				dwVScaleRatio = dwVScaleRatio & 0x00000FFF;
				dwVActiveLength = wVertSize/2;
				break;
			case (DEC_SECAM):
				dwVwinStart = RT_SECAM_V_IN_START;
				dwYin = RT_SECAM_V_ACTIVE_SIZE;
				dwTempRatio = (unsigned long) (wVertSize / dwYin);
				dwVScaleRatio = (unsigned long) ((long)wVertSize  * 2048L / dwYin);
				dwVScaleRatio = dwVScaleRatio & 0x00000FFF;
				dwVActiveLength = wVertSize/2;
				break;
			}
			/* 3. Set up offset based on if interlaced or not: */
			if(t->wInterlaced == RT_DECINTERLACED)
			{
				dwEvenFieldOffset = (unsigned long)((long)((1.0 - ((double) wVertSize / (double) dwYin)) * 512.0));
				dwOddFieldOffset = dwEvenFieldOffset;
				WriteRT_fld(fld_V_DEINTERLACE_ON, 0x1);
			}
			else
			{
				dwEvenFieldOffset = dwTempRatio * 512;
				dwOddFieldOffset = (unsigned long)(2048 - (long)dwEvenFieldOffset);
				WriteRT_fld(fld_V_DEINTERLACE_ON, 0x0);
			}
			/* Set the registers:*/
			WriteRT_fld(fld_H_IN_WIND_START,  dwHwinStart);
			WriteRT_fld(fld_H_SCALE_RATIO,    dwHScaleRatio);
			WriteRT_fld(fld_H_OUT_WIND_WIDTH, dwHActiveLength);
			WriteRT_fld(fld_V_IN_WIND_START,  dwVwinStart);
			WriteRT_fld(fld_V_SCALE_RATIO,    dwVScaleRatio);
			WriteRT_fld(fld_V_OUT_WIND_WIDTH, dwVActiveLength);
			WriteRT_fld(fld_EVENF_OFFSET,     dwEvenFieldOffset);
			WriteRT_fld(fld_ODDF_OFFSET,      dwOddFieldOffset);
			t->dwHorzScalingRatio = dwHScaleRatio;
			t->dwVertScalingRatio = dwVScaleRatio;
			break;
		case RT200_ATI_ID:
			/* VBI is ignored now */
			/* If I pass the (wHorzSize, 0, 0) (wVertSize, 0, 0) the image does not synchronize */
			dsp_set_video_scaler_horizontal(t, 0, 0, 0);
			dsp_set_video_scaler_vertical(t, 0, 0, 0);
			break;
	}
}

/****************************************************************************
 * CalculateCrCbGain (double *CrGain, double *CbGain, unsigned short wStandard) *
 *  Function:                                                               *
 *    Inputs: double *CrGain -                                              *
 *            double *CbGain -                                              *
 *            unsigned short wStandard - input standard (NTSC, PAL, SECAM)  *
 *   Outputs: NONE                                                          *
 ****************************************************************************/
void CalculateCrCbGain(TheatrePtr t, double *CrGain, double *CbGain, unsigned short wStandard)
{
	#define UVFLTGAIN 1.5
	#define FRMAX 280000.0
	#define FBMAX 230000.0
	double dbSynctipRef0=0.0, dbFsamp=0.0, dbLPeriod=0.0, dbFPeriod=0.0;
	dbSynctipRef0 = ReadRT_fld(fld_SYNCTIP_REF0);
	GetStandardConstants (&dbLPeriod, &dbFPeriod, &dbFsamp, wStandard);
	*CrGain = *CbGain = 0.0;
	switch(wStandard & 0x00FF)
	{
		case (DEC_NTSC): /*NTSC GROUP - 480 lines*/
			switch(wStandard & 0xFF00)
			{
				case (extNONE):
				case (extNTSC):
				case (extPAL_M):
					*CrGain = (double)(40.0 / (dbSynctipRef0)) * (100.0/92.5) * (1.0/0.877) * ((112.0/70.1)/UVFLTGAIN);
					*CbGain = (double)(40.0 / (dbSynctipRef0)) * (100.0/92.5) * (1.0/0.492) * ((112.0/88.6)/UVFLTGAIN);
					break;
				case (extNTSC_J):
					*CrGain = (double)(40.0 / (dbSynctipRef0)) * (100.0/100.0) * (1.0/0.877) * ((112.0/70.1)/UVFLTGAIN);
					*CbGain = (double)(40.0 / (dbSynctipRef0)) * (100.0/100.0) * (1.0/0.492) * ((112.0/88.6)/UVFLTGAIN);
					break;
				default:
					return;
			}
			break;
		case (DEC_PAL):
			*CrGain = (double)(43.0 / (dbSynctipRef0)) * (100.0/92.5) * (1.0/0.877) * ((112.0/70.1)/UVFLTGAIN);
			*CbGain = (double)(43.0 / (dbSynctipRef0)) * (100.0/92.5) * (1.0/0.492) * ((112.0/88.6)/UVFLTGAIN);
			break;
		case (DEC_SECAM):
			*CrGain = (double) 32.0 * 32768.0 / FRMAX / (33554432.0 / dbFsamp) * (1.597 / 1.902) / UVFLTGAIN;
			*CbGain = (double) 32.0 * 32768.0 / FBMAX / (33554432.0 / dbFsamp) * (1.267 / 1.505) / UVFLTGAIN;
			break;
	}
}

/****************************************************************************
 * RT_SetConnector (unsigned short wStandard, int tunerFlag)                *
 *  Function:                                                               *
 *    Inputs: unsigned short wStandard - input standard (NTSC, PAL, SECAM)  *
 *            int tunerFlag                                                 *
 *   Outputs: NONE                                                          *
 ****************************************************************************/
void RT_SetConnector(TheatrePtr t, unsigned short wConnector, int tunerFlag)
{
	unsigned long dwTempContrast=0, data;
	int i;
	long counter;
	t->wConnector = wConnector;
	switch(t->theatre_id)
	{
		case RT100_ATI_ID:
			DPRINT("Rage Theatre Checkpoint 1\r\n");
			/* Get the contrast value - make sure we are viewing a visible line*/
			counter=0;
#if 0
			while(!((ReadRT_fld(fld_VS_LINE_COUNT)> 1) && (ReadRT_fld(fld_VS_LINE_COUNT)<20)) && (counter < 100000))
#endif
			while((ReadRT_fld(fld_VS_LINE_COUNT)<20) && (counter < 10000))
				counter++;
			dwTempContrast = ReadRT_fld(fld_LP_CONTRAST);
			DPRINTVAL("Rage Theatre Checkpoint 2, counter=", counter);
			DPRINTVAL(" (", ReadRT_fld(fld_VS_LINE_COUNT));
			DPRINT(")\r\n");
			if(counter>=10000)
			{
				DPRINTVAL("Rage Theatre: timeout waiting for line count (", ReadRT_fld(fld_VS_LINE_COUNT));
				DPRINT(")\r\n");
			}
			WriteRT_fld(fld_LP_CONTRAST, 0x0);
			switch(wConnector)
			{
				case (DEC_TUNER):   /* Tuner*/
					WriteRT_fld(fld_INPUT_SELECT, t->wTunerConnector );
					WriteRT_fld(fld_STANDARD_YC, RT_COMPOSITE);
					RT_SetCombFilter(t, t->wStandard, RT_COMPOSITE);
					break;
				case (DEC_COMPOSITE):   /* Comp*/
					WriteRT_fld(fld_INPUT_SELECT, t->wComp0Connector);
					WriteRT_fld(fld_STANDARD_YC, RT_COMPOSITE);
					RT_SetCombFilter(t, t->wStandard, RT_COMPOSITE);
					break;
				case (DEC_SVIDEO):  /* Svideo*/
					WriteRT_fld(fld_INPUT_SELECT, t->wSVideo0Connector);
					WriteRT_fld(fld_STANDARD_YC, RT_SVIDEO);
					RT_SetCombFilter(t, t->wStandard, RT_SVIDEO);
					break;
				default:
					WriteRT_fld(fld_INPUT_SELECT, t->wComp0Connector);
					WriteRT_fld(fld_STANDARD_YC, RT_COMPOSITE);
					RT_SetCombFilter(t, t->wStandard, RT_COMPOSITE);
					break;
			}
			t->wConnector = wConnector;
			WriteRT_fld(fld_COMB_CNTL1, ReadRT_fld (fld_COMB_CNTL1) ^ 0x100);
			WriteRT_fld(fld_COMB_CNTL1, ReadRT_fld (fld_COMB_CNTL1) ^ 0x100);
			/* wait at most 1 sec here 
			   VIP bus has a bandwidth of 27MB and it is 8bit.
			   A single Rage Theatre read should take at least 6 bytes (2 for address one way and 4 for data the other way)
			   However there are also latencies associated with such reads, plus latencies for PCI accesses.
			   I guess we should not be doing more than 100000 per second.. At some point 
			   I should really write a program to time this */
			i = 100000;
			DPRINT("Rage Theatre Checkpoint 3\r\n");
			while((i>=0) && (!ReadRT_fld(fld_HS_GENLOCKED)))
				i--;
			if(i<0)
				DPRINT("Rage Theatre: waiting for fld_HS_GENLOCKED failed\r\n");
			DPRINTVAL("Rage Theatre Checkpoint 4 i=", i);
			DPRINT("\r\n");
			/* now we are waiting for a non-visible line.. and there is absolutely no point to wait too long */
			counter = 0;
			while(!((ReadRT_fld(fld_VS_LINE_COUNT) > 1) && (ReadRT_fld(fld_VS_LINE_COUNT) < 20)) && (counter < 10000))
				counter++;
			WriteRT_fld(fld_LP_CONTRAST, dwTempContrast);
			DPRINTVAL("Rage Theatre Checkpoint 5 counter=", counter);
			DPRINTVAL(" (", ReadRT_fld(fld_VS_LINE_COUNT));
			DPRINT(")\r\n");
			if(counter>=10000)
			{
				DPRINTVAL("Rage Theatre: timeout waiting for line count (", ReadRT_fld(fld_VS_LINE_COUNT));
				DPRINT(")\r\n");
			}
			break;
		case RT200_ATI_ID:
			theatre_read(t, VIP_GPIO_CNTL, &data);
			DPRINTVALHEX("Rage Theatre: VIP_GPIO_CNTL: ", data);
			theatre_read(t, VIP_GPIO_INOUT, &data);
			DPRINTVALHEX("\r\nRage Theatre: VIP_GPIO_INOUT: ", data);
			DPRINT("\r\n");
			switch(wConnector)
			{
				case (DEC_TUNER):   /* Tuner */
					/* RT200 does not have any input connector 0 */
					dsp_set_video_input_connector(t, t->wTunerConnector + 1);
					/* this is to set the analog mux used for sond */
					theatre_read(t, VIP_GPIO_CNTL, &data);
					data &= ~0x10;
					theatre_write(t, VIP_GPIO_CNTL, data);
					theatre_read(t, VIP_GPIO_INOUT, &data);
					data &= ~0x10;
					theatre_write(t, VIP_GPIO_INOUT, data);
					break;
				case (DEC_COMPOSITE):   /* Comp */
					dsp_set_video_input_connector(t, t->wComp0Connector);			 
					/* this is to set the analog mux used for sond */
					theatre_read(t, VIP_GPIO_CNTL, &data);
					data |= 0x10;
					theatre_write(t, VIP_GPIO_CNTL, data);
					theatre_read(t, VIP_GPIO_INOUT, &data);
					data |= 0x10;
					theatre_write(t, VIP_GPIO_INOUT, data);
					break;
				case (DEC_SVIDEO):  /* Svideo */
					dsp_set_video_input_connector(t, t->wSVideo0Connector);
					/* this is to set the analog mux used for sond */
					theatre_read(t, VIP_GPIO_CNTL, &data);
					data |= 0x10;
					theatre_write(t, VIP_GPIO_CNTL, data);
					theatre_read(t, VIP_GPIO_INOUT, &data);
					data |= 0x10;
					theatre_write(t, VIP_GPIO_INOUT, data);
					break;
				default:
					dsp_set_video_input_connector(t, t->wComp0Connector);
			}
			theatre_read(t, VIP_GPIO_CNTL, &data);
			DPRINTVALHEX("Rage Theatre: VIP_GPIO_CNTL: ", data);
			theatre_read(t, VIP_GPIO_INOUT, &data);
			DPRINTVALHEX("\r\nRage Theatre: VIP_GPIO_INOUT: ", data);
			DPRINT("\r\n");
			dsp_configure_i2s_port(t, 0, 0, 0);
			dsp_configure_spdif_port(t, 0);
			/* dsp_audio_detection(t, 0); */
			dsp_audio_mute(t, 1, 1);
			dsp_set_audio_volume(t, 128, 128, 0);
			break;
	}
}

static int DownloadMicrocode(TheatrePtr t)
{
	struct rt200_microc_data microc_data;
	microc_data.microc_seg_list = NULL;
	if(microc_load(&microc_data) < 0)
	{
		DPRINT("Rage Theatre: Microcode: cannot load microcode\r\n");
		goto err_exit;
	}
	else
	{
		DPRINTVALHEX("Rage Theatre: Microcode: device_id: ", microc_data.microc_head.device_id);
		DPRINTVALHEX("\r\nRage Theatre: Microcode: vendor_id: ", microc_data.microc_head.vendor_id);
		DPRINTVALHEX("\r\nRage Theatre: Microcode: rev_id: ", microc_data.microc_head.revision_id);
		DPRINTVALHEX("\r\nRage Theatre: Microcode: num_seg: ", microc_data.microc_head.num_seg);
		DPRINT("\r\n");
	}
	if(dsp_init(t, &microc_data) < 0)
	{
		DPRINT("Rage Theatre: Microcode: dsp_init failed\n");
		goto err_exit;
	}
	else
		DPRINT("Rage Theatre: Microcode: dsp_init OK\r\n");
	if(dsp_load(t, &microc_data) < 0)
	{
		DPRINT("Rage Theatre: Microcode: dsp_download failed\r\n");
		goto err_exit;
	}
	else
		DPRINT("Rage Theatre: Microcode: dsp_download OK\r\n");
	microc_clean(&microc_data);
	return 0;
err_exit:
	microc_clean(&microc_data);
	return -1;
}

void InitTheatre(TheatrePtr t)
{
	unsigned long data;
	unsigned long M, N, P;
	/* this will give 108Mhz at 27Mhz reference */
	M = 28;
	N = 224;
	P = 1;
	/* 0 reset Rage Theatre */
	ShutdownTheatre(t);
	udelay(100000);
	t->mode=MODE_INITIALIZATION_IN_PROGRESS;
	switch(t->theatre_id)
	{
		case RT100_ATI_ID:
			/* 1. Set the VIN_PLL to NTSC value */
			RT_SetVINClock(t, RT_NTSC);
			/* Take VINRST and L54RST out of reset */
			RT_regr(VIP_PLL_CNTL1, &data);
			RT_regw(VIP_PLL_CNTL1, data & ~((RT_VINRST_RESET << 1) | (RT_L54RST_RESET << 3)));
			RT_regr(VIP_PLL_CNTL1, &data);
			/* Set VIN_CLK_SEL to PLL_VIN_CLK */
			RT_regr(VIP_CLOCK_SEL_CNTL, &data);
			RT_regw(VIP_CLOCK_SEL_CNTL, data | (RT_PLL_VIN_CLK << 7));
			RT_regr(VIP_CLOCK_SEL_CNTL, &data);
			/* 2. Set HW_DEBUG to 0xF000 before setting the standards registers */
			RT_regw(VIP_HW_DEBUG, 0x0000F000);
			/* wait for things to settle */
			udelay(100000);
			RT_SetStandard(t, t->wStandard);
			/* 3. Set DVS port to OUTPUT */
			RT_regr(VIP_DVS_PORT_CTRL, &data);
			RT_regw(VIP_DVS_PORT_CTRL, data | RT_DVSDIR_OUT);
			RT_regr(VIP_DVS_PORT_CTRL, &data);
			/* 4. Set default values for ADC_CNTL */
			RT_regw(VIP_ADC_CNTL, RT_ADC_CNTL_DEFAULT);
			/* 5. Clear the VIN_ASYNC_RST bit */
			RT_regr(VIP_MASTER_CNTL, &data);
			RT_regw(VIP_MASTER_CNTL, data & ~0x20);
			RT_regr(VIP_MASTER_CNTL, &data);
			/* Clear the DVS_ASYNC_RST bit */
			RT_regr(VIP_MASTER_CNTL, &data);
			RT_regw(VIP_MASTER_CNTL, data & ~(RT_DVS_ASYNC_RST));
			RT_regr(VIP_MASTER_CNTL, &data);
			/* Set the GENLOCK delay */
			RT_regw(VIP_HS_GENLOCKDELAY, 0x10);
			RT_regr(fld_DVS_DIRECTION, &data);
			RT_regw(fld_DVS_DIRECTION, data & RT_DVSDIR_OUT);
			/* WriteRT_fld(fld_DVS_DIRECTION, RT_DVSDIR_IN); */
			break;
		case RT200_ATI_ID:
			data = M | (N << 11) | (P <<24);
			RT_regw(VIP_DSP_PLL_CNTL, data);
			RT_regr(VIP_PLL_CNTL0, &data);
			data |= 0x2000;
			RT_regw(VIP_PLL_CNTL0, data);
			/* RT_regw(VIP_I2C_SLVCNTL, 0x249); */
			RT_regr(VIP_PLL_CNTL1, &data);
			data |= 0x00030003;
			RT_regw(VIP_PLL_CNTL1, data);
			RT_regr(VIP_PLL_CNTL0, &data);
			data &= 0xfffffffc;
			RT_regw(VIP_PLL_CNTL0, data);
			udelay(15000);
			RT_regr(VIP_CLOCK_SEL_CNTL, &data);
			data |= 0x1b;
			RT_regw(VIP_CLOCK_SEL_CNTL, data);
			RT_regr(VIP_MASTER_CNTL, &data);
			data &= 0xffffff07;
			RT_regw(VIP_MASTER_CNTL, data);
			data &= 0xffffff03;
			RT_regw(VIP_MASTER_CNTL, data);
			udelay(1000);
			if(DownloadMicrocode(t) < 0)
			{
				ShutdownTheatre(t);
				return;
			}
			dsp_set_lowpowerstate(t, 1);
			dsp_set_videostreamformat(t, 1);
			break;
	}
	t->mode=MODE_INITIALIZED_FOR_TV_IN;
}

void ShutdownTheatre(TheatrePtr t)
{
	WriteRT_fld(fld_VIN_ASYNC_RST, RT_ASYNC_DISABLE);
	WriteRT_fld(fld_VINRST       , RT_VINRST_RESET);
	WriteRT_fld(fld_ADC_PDWN     , RT_ADC_DISABLE);
	WriteRT_fld(fld_DVS_DIRECTION, RT_DVSDIR_IN);
	t->mode=MODE_UNINITIALIZED;
}

void ResetTheatreRegsForNoTVout(TheatrePtr t)
{
	RT_regw(VIP_CLKOUT_CNTL, 0x0); 
	RT_regw(VIP_HCOUNT, 0x0); 
	RT_regw(VIP_VCOUNT, 0x0); 
	RT_regw(VIP_DFCOUNT, 0x0); 
#if 0
	RT_regw(VIP_CLOCK_SEL_CNTL, 0x2b7);  /* versus 0x237 <-> 0x2b7 */
	RT_regw(VIP_VIN_PLL_CNTL, 0x60a6039);
#endif
	RT_regw(VIP_FRAME_LOCK_CNTL, 0x0);
}

void ResetTheatreRegsForTVout(TheatrePtr t)
{
/*	RT_regw(VIP_HW_DEBUG, 0x200);   */
/*	RT_regw(VIP_INT_CNTL, 0x0); 
	RT_regw(VIP_GPIO_INOUT, 0x10090000); 
	RT_regw(VIP_GPIO_INOUT, 0x340b0000);  */
/*	RT_regw(VIP_MASTER_CNTL, 0x6e8);  */
	RT_regw(VIP_CLKOUT_CNTL, 0x29); 
#if 1
	RT_regw(VIP_HCOUNT, 0x1d1); 
	RT_regw(VIP_VCOUNT, 0x1e3); 
#else
	RT_regw(VIP_HCOUNT, 0x322); 
	RT_regw(VIP_VCOUNT, 0x151);
#endif
	RT_regw(VIP_DFCOUNT, 0x01);
/*	RT_regw(VIP_CLOCK_SEL_CNTL, 0xb7); */  /* versus 0x237 <-> 0x2b7 */
	RT_regw(VIP_CLOCK_SEL_CNTL, 0x2b7);  /* versus 0x237 <-> 0x2b7 */
	RT_regw(VIP_VIN_PLL_CNTL, 0x60a6039);
/*	RT_regw(VIP_PLL_CNTL1, 0xacacac74); */
	RT_regw(VIP_FRAME_LOCK_CNTL, 0x0f);
/*	RT_regw(VIP_ADC_CNTL, 0x02a420a8); 
	RT_regw(VIP_COMB_CNTL_0, 0x0d438083); 
	RT_regw(VIP_COMB_CNTL_2, 0x06080102); 
	RT_regw(VIP_HS_MINMAXWIDTH, 0x462f); 
	...
*/
/*
	RT_regw(VIP_HS_PULSE_WIDTH, 0x359);
	RT_regw(VIP_HS_PLL_ERROR, 0xab6);
	RT_regw(VIP_HS_PLL_FS_PATH, 0x7fff08f8);
	RT_regw(VIP_VS_LINE_COUNT, 0x49b5e005);
*/
}

#endif /* RADEON_THEATRE */
