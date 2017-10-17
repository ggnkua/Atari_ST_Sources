#include "radeonfb.h"
#include "vidix.h"
#include "fourcc.h"

#ifdef RADEON_THEATRE

#define METHOD_BOB 0
#define METHOD_SINGLE 1
#define METHOD_WEAVE 2
#define METHOD_ADAPTIVE 3

#define OFF_TIMER       0x01
#define FREE_TIMER      0x02
#define CLIENT_VIDEO_ON 0x04

typedef struct
{
	int num;
	char *name;
	int width;
	int height;
	int hz;
} VideoEncodingRec;

static void RADEONReadMM_TABLE(struct radeonfb_info *rinfo);
static int RADEONSetupTheatre(struct radeonfb_info *rinfo, TheatrePtr t);
static void RADEON_RT_SetEncoding(struct radeonfb_info *rinfo);
static void RADEONSetupImageVideo(struct radeonfb_info *rinfo);
extern void make_default_gamma_correction(void); /* from radeon_vid.c */

static VideoEncodingRec InputVideoEncodings[] =
{
	{ 0, "IMAGE", 2048, 2048, 1 },        
	{ 1, "pal-composite", 720, 288, 50 },
	{ 2, "pal-tuner", 720, 288, 50 },
	{ 3, "pal-svideo", 720, 288, 50 },
	{ 4, "ntsc-composite", 640, 240, 60 },
	{ 5, "ntsc-tuner", 640, 240, 60 },
	{ 6, "ntsc-svideo", 640, 240, 60 },
	{ 7, "secam-composite", 720, 288, 50 },
	{ 8, "secam-tuner", 720, 288, 50 },
	{ 9, "secam-svideo", 720, 288, 50 },
	{ 10,"pal_60-composite", 768, 288, 50 },
	{ 11,"pal_60-tuner", 768, 288, 50 },
	{ 12,"pal_60-svideo", 768, 288, 50 }
};

void RADEONInitVideo(struct radeonfb_info *rinfo)
{
	DPRINT("radeonfb: RADEONInitVideo\r\n");
	vixProbe(0,0);
	vixInit();
	rinfo->encoding = 8; /* secam-tuner */
	RADEONSetupImageVideo(rinfo);
}

void RADEONShutdownVideo(struct radeonfb_info *rinfo)
{
	DPRINT("radeonfb: RADEONShutdownVideo\r\n");
//	if(rinfo->videoStatus & CLIENT_VIDEO_ON)
//		vixPlaybackOff();
	if(rinfo->theatre!=NULL)
	{
		ShutdownTheatre(rinfo->theatre);
		Mfree(rinfo->theatre);
		rinfo->theatre=NULL;
	}
	rinfo->videoLinear = NULL;
	vixDestroy();
}

void RADEONResetVideo(struct radeonfb_info *rinfo)
{
	DPRINT("radeonfb: RADEONResetVideo\r\n");
	RADEONWaitForIdleMMIO(rinfo);
	OUTREG(OV0_SCALE_CNTL, 0x80000000);
	OUTREG(OV0_AUTO_FLIP_CNTL, 0);   /* maybe */
	OUTREG(OV0_EXCLUSIVE_HORZ, 0);
	OUTREG(OV0_FILTER_CNTL, 0x0000000f);
	OUTREG(OV0_KEY_CNTL, GRAPHIC_KEY_FN_EQ | VIDEO_KEY_FN_FALSE | CMP_MIX_OR);
	OUTREG(OV0_TEST, 0);
	OUTREG(FCP_CNTL, FCP0_SRC_GND);
	OUTREG(CAP0_TRIG_CNTL, 0);
	make_default_gamma_correction();
	RADEONVIP_reset(rinfo);
	if(rinfo->theatre != NULL)
		InitTheatre(rinfo->theatre);
}

void RADEONLeaveVT_Video(struct radeonfb_info *rinfo)
{
	if(rinfo->theatre)
		ShutdownTheatre(rinfo->theatre);
	RADEONResetVideo(rinfo);
}

void RADEONEnterVT_Video(struct radeonfb_info *rinfo)
{
	RADEONResetVideo(rinfo);
}

static unsigned long RADEONVIP_idle(struct radeonfb_info *rinfo)
{
	unsigned long timeout;
	RADEONWaitForIdleMMIO(rinfo);
	timeout = INREG(VIPH_TIMEOUT_STAT);
	if(timeout & VIPH_TIMEOUT_STAT__VIPH_REG_STAT) /* lockup ?? */
	{
		RADEONWaitForFifo(rinfo, 2);
		OUTREG(VIPH_TIMEOUT_STAT, (timeout & 0xffffff00) | VIPH_TIMEOUT_STAT__VIPH_REG_AK);
		RADEONWaitForIdleMMIO(rinfo);
		return((INREG(VIPH_CONTROL) & 0x2000) ? VIP_BUSY : VIP_RESET);
	}
	RADEONWaitForIdleMMIO(rinfo);
	return((INREG(VIPH_CONTROL) & 0x2000) ? VIP_BUSY : VIP_IDLE);
}

static unsigned long RADEONVIP_fifo_idle(struct radeonfb_info *rinfo, unsigned char channel)
{
	unsigned long timeout;                               
	RADEONWaitForIdleMMIO(rinfo);
	timeout = INREG(VIPH_TIMEOUT_STAT);
	if((timeout & 0x0000000f) & channel) /* lockup ?? */
	{
		RADEONWaitForFifo(rinfo, 2);
		OUTREG(VIPH_TIMEOUT_STAT, (timeout & 0xfffffff0) | channel);
		RADEONWaitForIdleMMIO(rinfo);
		return((INREG(VIPH_CONTROL) & 0x2000) ? VIP_BUSY : VIP_RESET);
	}
	RADEONWaitForIdleMMIO(rinfo);
	return((INREG(VIPH_CONTROL) & 0x2000) ? VIP_BUSY : VIP_IDLE);
}

/* address format: ((device & 0x3)<<14)   | (fifo << 12) | (addr) */

#define VIP_WAIT_FOR_IDLE() {			\
	int i2ctries = 0;				\
	while(i2ctries < 10) {			\
		status = RADEONVIP_idle(rinfo);		\
		if(status==VIP_BUSY)			\
		{						\
			udelay(1000);				\
			i2ctries++;				\
		} else break;				\
	}						\
} 

int RADEONVIP_read(struct radeonfb_info *rinfo, unsigned long address, unsigned long count, unsigned char *buffer)
{
	unsigned long status, tmp;
	if((count!=1) && (count!=2) && (count!=4))
	{
		DPRINT("Attempt to access VIP bus with non-stadard transaction length\r\n");
		return FALSE;
	}
	RADEONWaitForFifo(rinfo, 2);
	OUTREG(VIPH_REG_ADDR, address | 0x2000);
//	while(VIP_BUSY == (status = RADEONVIP_idle(rinfo)));
	VIP_WAIT_FOR_IDLE();
	if(VIP_IDLE != status)
		return FALSE;
	/*
	Disable VIPH_REGR_DIS to enable VIP cycle
	The LSB of VIPH_TIMEOUT_STAT are set to 0 because 1 would have
	acknowledged various VIP interrupts unexpectedly 
	*/      
	RADEONWaitForIdleMMIO(rinfo);
	OUTREG(VIPH_TIMEOUT_STAT, INREG(VIPH_TIMEOUT_STAT) & (0xffffff00 & ~VIPH_TIMEOUT_STAT__VIPH_REGR_DIS) );
	/* The value returned here is garbage. The read merely initiates a register cycle */
	RADEONWaitForIdleMMIO(rinfo);
	INREG(VIPH_REG_DATA);
//	while(VIP_BUSY == (status = RADEONVIP_idle(rinfo)));
	VIP_WAIT_FOR_IDLE();
	if(VIP_IDLE != status)
		return FALSE;
	/* set VIPH_REGR_DIS so that the read won't take too long */
	RADEONWaitForIdleMMIO(rinfo);
	tmp=INREG(VIPH_TIMEOUT_STAT);
	OUTREG(VIPH_TIMEOUT_STAT, (tmp & 0xffffff00) | VIPH_TIMEOUT_STAT__VIPH_REGR_DIS);         
	RADEONWaitForIdleMMIO(rinfo);
	switch(count)
	{
		case 1: *buffer=(unsigned char)(INREG(VIPH_REG_DATA) & 0xff); break;
		case 2: *(unsigned short *)buffer=(unsigned short)(INREG(VIPH_REG_DATA) & 0xffff); break;
		case 4: *(unsigned long *)buffer=(unsigned long)(INREG(VIPH_REG_DATA) & 0xffffffff); break;
	}
//	while(VIP_BUSY == (status = RADEONVIP_idle(rinfo)));
	VIP_WAIT_FOR_IDLE();
	if(VIP_IDLE != status)
		return FALSE;
	/* so that reading VIPH_REG_DATA would not trigger unnecessary vip cycles */
	OUTREG(VIPH_TIMEOUT_STAT, (INREG(VIPH_TIMEOUT_STAT) & 0xffffff00) | VIPH_TIMEOUT_STAT__VIPH_REGR_DIS);
	return TRUE;
}

int RADEONVIP_fifo_read(struct radeonfb_info *rinfo, unsigned long address, unsigned long count, unsigned char *buffer)
{
	unsigned long status, tmp;
	if(count!=1)
		return FALSE;
	RADEONWaitForFifo(rinfo, 2);
	OUTREG(VIPH_REG_ADDR, address | 0x3000);
	while(VIP_BUSY == (status = RADEONVIP_fifo_idle(rinfo, 0xff)));
	if(VIP_IDLE != status)
		return FALSE;
	/*
	Disable VIPH_REGR_DIS to enable VIP cycle
	The LSB of VIPH_TIMEOUT_STAT are set to 0
         because 1 would have acknowledged various VIP
         interrupts unexpectedly 
	*/      
	RADEONWaitForIdleMMIO(rinfo);
	OUTREG(VIPH_TIMEOUT_STAT, INREG(VIPH_TIMEOUT_STAT) & (0xffffff00 & ~VIPH_TIMEOUT_STAT__VIPH_REGR_DIS) );
	/* The value returned here is garbage. The read merely initiates a register cycle */
	RADEONWaitForIdleMMIO(rinfo);
	INREG(VIPH_REG_DATA);
	while(VIP_BUSY == (status = RADEONVIP_fifo_idle(rinfo, 0xff)));
	if(VIP_IDLE != status)
		return FALSE;
	/* set VIPH_REGR_DIS so that the read won't take too long */
	RADEONWaitForIdleMMIO(rinfo);
	tmp=INREG(VIPH_TIMEOUT_STAT);
	OUTREG(VIPH_TIMEOUT_STAT, (tmp & 0xffffff00) | VIPH_TIMEOUT_STAT__VIPH_REGR_DIS);         
	RADEONWaitForIdleMMIO(rinfo);
	switch(count)
	{
		case 1: *buffer=(unsigned char)(INREG(VIPH_REG_DATA) & 0xff); break;
		case 2: *(unsigned short *)buffer=(unsigned short)(INREG(VIPH_REG_DATA) & 0xffff); break;
		case 4: *(unsigned long *)buffer=(unsigned long)(INREG(VIPH_REG_DATA) & 0xffffffff); break;
	}
	while(VIP_BUSY == (status = RADEONVIP_fifo_idle(rinfo, 0xff)));
	if(VIP_IDLE != status)
		return FALSE;
	/* so that reading VIPH_REG_DATA would not trigger unnecessary vip cycles */
	OUTREG(VIPH_TIMEOUT_STAT, (INREG(VIPH_TIMEOUT_STAT) & 0xffffff00) | VIPH_TIMEOUT_STAT__VIPH_REGR_DIS);
	return TRUE;
}

int RADEONVIP_write(struct radeonfb_info *rinfo, unsigned long address, unsigned long count, unsigned char *buffer)
{
	unsigned long status;
	if(count!=4)
	{
		DPRINT("Attempt to access VIP bus with non-stadard transaction length\r\n");
		return FALSE;
	}
	RADEONWaitForFifo(rinfo, 2);
	OUTREG(VIPH_REG_ADDR, address & (~0x2000));
	while(VIP_BUSY == (status = RADEONVIP_idle(rinfo)));
	if(VIP_IDLE != status)
		return FALSE;
	RADEONWaitForFifo(rinfo, 2);
	switch(count)
	{
		case 4: OUTREG(VIPH_REG_DATA, *(unsigned long *)buffer); break;
	}
	while(VIP_BUSY == (status = RADEONVIP_idle(rinfo)));
	if(VIP_IDLE != status)
		return FALSE;
	return TRUE;
}

int RADEONVIP_fifo_write(struct radeonfb_info *rinfo, unsigned long address, unsigned long count, unsigned char *buffer)
{
	unsigned long status, i;
	RADEONWaitForFifo(rinfo, 2);
	OUTREG(VIPH_REG_ADDR, (address & (~0x2000)) | 0x1000);
	while(VIP_BUSY == (status = RADEONVIP_fifo_idle(rinfo, 0x0f)));
	if(VIP_IDLE != status)
		return FALSE;
	RADEONWaitForFifo(rinfo, 2);
	for(i = 0; i < count; i+=4)
	{
		OUTREG(VIPH_REG_DATA, *(unsigned long *)(buffer + i));
		while(VIP_BUSY == (status = RADEONVIP_fifo_idle(rinfo, 0x0f)));
		if(VIP_IDLE != status)
			return FALSE;
	}
	return TRUE;
}

void RADEONVIP_reset(struct radeonfb_info *rinfo)
{
	RADEONWaitForIdleMMIO(rinfo);
	switch(rinfo->family)
	{
		case CHIP_FAMILY_RV250:
			OUTREG(VIPH_CONTROL, 0x003F0009); /* slowest, timeout in 16 phases */
			OUTREG(VIPH_TIMEOUT_STAT, (INREG(VIPH_TIMEOUT_STAT) & 0xFFFFFF00) | VIPH_TIMEOUT_STAT__VIPH_REGR_DIS);
			OUTREG(VIPH_DV_LAT, 0x444400FF); /* set timeslice */
			OUTREG(VIPH_BM_CHUNK, 0x0);
			OUTREG(TEST_DEBUG_CNTL, INREG(TEST_DEBUG_CNTL) & (~TEST_DEBUG_CNTL__TEST_DEBUG_OUT_EN));
			break;
		default:
			OUTREG(VIPH_CONTROL, 0x003F0004); /* slowest, timeout in 16 phases */
			OUTREG(VIPH_TIMEOUT_STAT, (INREG(VIPH_TIMEOUT_STAT) & 0xFFFFFF00) | VIPH_TIMEOUT_STAT__VIPH_REGR_DIS);
			OUTREG(VIPH_DV_LAT, 0x444400FF); /* set timeslice */
			OUTREG(VIPH_BM_CHUNK, 0x151);
			OUTREG(TEST_DEBUG_CNTL, INREG(TEST_DEBUG_CNTL) & (~TEST_DEBUG_CNTL__TEST_DEBUG_OUT_EN));
	} 
}

static void RADEONSetupImageVideo(struct radeonfb_info *rinfo)
{
	RADEONWaitForIdleMMIO(rinfo);
	RADEONReadMM_TABLE(rinfo);
	RADEONVIP_reset(rinfo);
	rinfo->theatre=NULL;
	rinfo->videoLinear=NULL;
	switch(rinfo->chipset)
	{
		case PCI_DEVICE_ID_ATI_RADEON_LY:
		case PCI_DEVICE_ID_ATI_RADEON_LZ:
		case PCI_DEVICE_ID_ATI_RADEON_LW: 
			break;		
		default:
			if(!rinfo->MM_TABLE_valid)
	    	DPRINT("radeonfb: Multimedia table is not valid and no forced settings have been specified\r\n");
			else
				rinfo->theatre=DetectTheatre(rinfo);
			break;
	}
	if((rinfo->theatre!=NULL) && !RADEONSetupTheatre(rinfo,rinfo->theatre))
	{
		Mfree(rinfo->theatre);
		rinfo->theatre=NULL;
		DPRINT("Failed to initialize Rage Theatre, chip disabled\r\n");
	}
	if(rinfo->theatre)
	{
		InitTheatre(rinfo->theatre);
		ResetTheatreRegsForNoTVout(rinfo->theatre);
		RT_SetTint(rinfo->theatre, rinfo->dec_hue);
		RT_SetSaturation(rinfo->theatre, rinfo->dec_saturation);
		RT_SetSharpness(rinfo->theatre, RT_NORM_SHARPNESS);
		RT_SetContrast(rinfo->theatre, rinfo->dec_contrast);
		RT_SetBrightness(rinfo->theatre, rinfo->dec_brightness);
		RADEON_RT_SetEncoding(rinfo);  
	}
	
	RADEONResetVideo(rinfo);
}

/* Radeon AIW 7500 has i2s_config 2b not 29 as Radeon AIW */
/* Radeon AIW 7500:

(--) RADEON(0): Chipset: "ATI Radeon 7500 QW (AGP)" (ChipID = 0x5157)
(II) RADEON(0): VIDEO BIOS TABLE OFFSETS: bios_header=0x011c mm_table=0x04ae
(II) RADEON(0): MM_TABLE: 01-0c-06-18-06-80-2b-66-02-05-00-06-00-07
*/

static void RADEONReadMM_TABLE(struct radeonfb_info *rinfo)
{
	unsigned short mm_table;
	unsigned short bios_header;
	char *ptr = (char *)&rinfo->MM_TABLE;
	int size = sizeof(_MM_TABLE);
	if((rinfo->bios_seg == NULL) || ((bios_header=BIOS_IN16(0)) != 0xaa55))
	{
		DPRINT("radeonfb: Cannot access BIOS or it is not valid\r\n");
		rinfo->MM_TABLE_valid = FALSE;
	}
	else
	{
		bios_header=BIOS_IN16(0x48);
		mm_table=(unsigned short)BIOS_IN8(bios_header+0x38);
		if(mm_table==0)
		{
			DPRINTVALHEX("radeonfb: No MM_TABLE found bios_header=", bios_header);
			DPRINTVALHEX(" mm_table=", mm_table);
			DPRINT("\r\n");
			rinfo->MM_TABLE_valid = FALSE;
			goto forced_settings;
		}
		mm_table+=(((int)BIOS_IN8(bios_header+0x39)<<8)-2);
		DPRINTVALHEX("radeonfb: VIDEO BIOS TABLE OFFSETS: bios_header=", bios_header);
		DPRINTVALHEX(" mm_table=", mm_table);
		DPRINT("\r\n");
		if(mm_table>0)
		{
			while(--size >= 0)
				*ptr++ = BIOS_IN8(mm_table++);
			DPRINTVALHEXBYTE("radeonfb: MM_TABLE: ", rinfo->MM_TABLE.table_revision);
			DPRINTVALHEXBYTE("-", rinfo->MM_TABLE.table_size);
			DPRINTVALHEXBYTE("-", rinfo->MM_TABLE.tuner_type);
			DPRINTVALHEXBYTE("-", rinfo->MM_TABLE.audio_chip);
			DPRINTVALHEXBYTE("-", rinfo->MM_TABLE.product_id);
			DPRINTVALHEXBYTE("-", rinfo->MM_TABLE.tuner_voltage_teletext_fm);
			DPRINTVALHEXBYTE("-", rinfo->MM_TABLE.i2s_config);
			DPRINTVALHEXBYTE("-", rinfo->MM_TABLE.video_decoder_type);
			DPRINTVALHEXBYTE("-", rinfo->MM_TABLE.video_decoder_host_config);
			DPRINTVALHEXBYTE("-", rinfo->MM_TABLE.input[0]);
			DPRINTVALHEXBYTE("-", rinfo->MM_TABLE.input[1]);
			DPRINTVALHEXBYTE("-", rinfo->MM_TABLE.input[2]);
			DPRINTVALHEXBYTE("-", rinfo->MM_TABLE.input[3]);
			DPRINTVALHEXBYTE("-", rinfo->MM_TABLE.input[4]);
			DPRINT("\r\n");
			rinfo->MM_TABLE_valid = TRUE;
		}
		else
		{
			DPRINTVALHEX("radeonfb: No MM_TABLE found bios_header=", bios_header);
			DPRINTVALHEX(" mm_table=", mm_table);
			DPRINT("\r\n");
			rinfo->MM_TABLE_valid = FALSE;
		}    
	}
forced_settings:     
	if(rinfo->tunerType>=0)
		rinfo->MM_TABLE.tuner_type=rinfo->tunerType;
	/* enough information was provided in the options */
	if(!rinfo->MM_TABLE_valid
	 && (rinfo->tunerType>=0) && (rinfo->RageTheatreCrystal>=0) && (rinfo->RageTheatreTunerPort>=0)
	 && (rinfo->RageTheatreCompositePort>=0) && (rinfo->RageTheatreSVideoPort>=0))
		rinfo->MM_TABLE_valid = TRUE;
}

static int RADEONSetupTheatre(struct radeonfb_info *rinfo, TheatrePtr t)
{
	unsigned char a;
	unsigned short bios_header, pll_info_block;
	int i;
	bios_header=BIOS_IN16(0x48);
	pll_info_block=BIOS_IN16(bios_header+0x30);
	t->video_decoder_type=BIOS_IN16(pll_info_block+0x08);
	DPRINTVALHEX("radeonfb: video decoder type is ", t->video_decoder_type);
	DPRINTVALHEX(" versus ", rinfo->pll.ref_clk);
	DPRINT("\r\n");
	if(!rinfo->MM_TABLE_valid)
	{
		DPRINT("radeonfb: no multimedia table present, not using Rage Theatre for input\r\n");
		return FALSE;
	}
	for(i=0;i<5;i++)
	{
		a=rinfo->MM_TABLE.input[i];
		switch(a & 0x3)
		{
			case 1:
				t->wTunerConnector=i;
				DPRINTVAL("radeonfb: Tuner is on port ", i);
				DPRINT("\r\n");
				break;
			case 2:
				if(a & 0x4)
					t->wComp0Connector=RT_COMP2;
				else
        	t->wComp0Connector=RT_COMP1;
				DPRINTVAL("radeonfb: Composite connector is port ", (int)t->wComp0Connector);
				DPRINT("\r\n");
				break;
			case 3:
				if(a & 0x4)
        	t->wSVideo0Connector=RT_YCR_COMP4;
				else
					t->wSVideo0Connector=RT_YCF_COMP4;
				DPRINTVAL("radeonfb: Video connector is port ", (int)t->wSVideo0Connector);
				DPRINT("\r\n");
				break;
			default:
				break;
		}
	}
	/* this is fiction, we should read MM table instead 
	t->wTunerConnector=0;
	t->wComp0Connector=5;
	t->wSVideo0Connector=3;
	*/
	DPRINTVAL("radeonfb: Rage Theatre: Connectors (detected): tuner=", (int)t->wTunerConnector);
	DPRINTVAL(", composite=", (int)t->wComp0Connector);
	DPRINTVAL(", svideo=", (int)t->wSVideo0Connector);
	DPRINT("\r\n");
	if(rinfo->RageTheatreTunerPort>=0)
		t->wTunerConnector=rinfo->RageTheatreTunerPort;
	if(rinfo->RageTheatreCompositePort>=0)
		t->wComp0Connector=rinfo->RageTheatreCompositePort;
	if(rinfo->RageTheatreSVideoPort>=0)
		t->wSVideo0Connector=rinfo->RageTheatreSVideoPort;
	DPRINTVAL("radeonfb: RageTheatre: Connectors (using): tuner=", (int)t->wTunerConnector);
	DPRINTVAL(", composite=", (int)t->wComp0Connector);
	DPRINTVAL(", svideo=", (int)t->wSVideo0Connector);
	DPRINT("\r\n");
	switch((rinfo->RageTheatreCrystal>=0) ? rinfo->RageTheatreCrystal : rinfo->pll.ref_clk)
	{
		case 2700: t->video_decoder_type=RT_FREF_2700; break;
		case 2950: t->video_decoder_type=RT_FREF_2950; break;
		default:
			DPRINT("radeonfb: Unsupported reference clock frequency, Rage Theatre disabled\r\n");
			t->theatre_num=-1;
			return FALSE;
	}
	DPRINTVALHEX("radeonfb: video decoder type used: ", t->video_decoder_type);
	DPRINT("\r\n");
	return TRUE;
}

void RADEONStopVideo(struct radeonfb_info *rinfo, int cleanup)
{
	DPRINT("radeonfb: RADEONStopVideo\r\n"); 
	if(cleanup)
	{
		if(rinfo->videoStatus & CLIENT_VIDEO_ON)
		{
//			RADEONWaitForFifo(rinfo, 2);
//			OUTREG(OV0_SCALE_CNTL, 0);
//			vixPlaybackOff();
		}
		if(rinfo->video_stream_active)
		{
			RADEONWaitForFifo(rinfo, 2);
			OUTREG(FCP_CNTL, FCP0_SRC_GND);
			OUTREG(CAP0_TRIG_CNTL, 0);
			RADEONResetVideo(rinfo);
			rinfo->video_stream_active = FALSE;
		}
		rinfo->videoLinear = NULL;
		rinfo->videoStatus = 0;
	}
	else
	{
		if(rinfo->videoStatus & CLIENT_VIDEO_ON)
		{
			rinfo->videoStatus |= OFF_TIMER;
//			rinfo->offTime = currentTime.milliseconds + OFF_DELAY;
		}
	}
}

static void RADEON_RT_SetEncoding(struct radeonfb_info *rinfo)
{
	int width, height;
	RADEONWaitForIdleMMIO(rinfo);
	/* Disable VBI capture for anything but TV tuner */
	if(rinfo->encoding==5)
		rinfo->capture_vbi_data=1;
	else
		rinfo->capture_vbi_data=0;
	switch(rinfo->encoding)
	{
		case 1: /* pal-composite */
			RT_SetConnector(rinfo->theatre,DEC_COMPOSITE, 0);
			RT_SetStandard(rinfo->theatre,DEC_PAL | extPAL);
			rinfo->v=25;
			break;
		case 2: /* pal-tuner */
			RT_SetConnector(rinfo->theatre,DEC_TUNER,0);
			RT_SetStandard(rinfo->theatre,DEC_PAL | extPAL);
			rinfo->v=25;
			break;
		case 3: /* pal-svideo */
			RT_SetConnector(rinfo->theatre,DEC_SVIDEO,0);
			RT_SetStandard(rinfo->theatre,DEC_PAL | extPAL);
			rinfo->v=25;
			break;
		case 4: /* ntsc-composite */
			RT_SetConnector(rinfo->theatre, DEC_COMPOSITE,0);
			RT_SetStandard(rinfo->theatre,DEC_NTSC | extNONE);
			rinfo->v=23;
			break;
		case 5: /* ntsc-tuner */
			RT_SetConnector(rinfo->theatre, DEC_TUNER, 0);
			RT_SetStandard(rinfo->theatre,DEC_NTSC | extNONE);
			rinfo->v=23;
			break;
		case 6: /* ntsc-svideo */
			RT_SetConnector(rinfo->theatre, DEC_SVIDEO, 0);
			RT_SetStandard(rinfo->theatre,DEC_NTSC | extNONE);
			rinfo->v=23;
			break;
		case 7: /* secam-composite */
			RT_SetConnector(rinfo->theatre, DEC_COMPOSITE, 0);
			RT_SetStandard(rinfo->theatre,DEC_SECAM | extNONE);
			rinfo->v=25;
			break;
		case 8: /* secam-tuner */ 
			RT_SetConnector(rinfo->theatre, DEC_TUNER, 0);
			RT_SetStandard(rinfo->theatre,DEC_SECAM | extNONE);
			rinfo->v=25;
			break;
		case 9: /* secam-svideo */
			RT_SetConnector(rinfo->theatre, DEC_SVIDEO, 0);
			RT_SetStandard(rinfo->theatre,DEC_SECAM | extNONE);
			rinfo->v=25;
			break;
		case 10: /* pal_60-composite */
			RT_SetConnector(rinfo->theatre,DEC_COMPOSITE, 0);
			RT_SetStandard(rinfo->theatre,DEC_PAL | extPAL_60);
			rinfo->v=25;
			break;
		case 11: /* pal_60-tuner */
			RT_SetConnector(rinfo->theatre,DEC_TUNER,0);
			RT_SetStandard(rinfo->theatre,DEC_PAL | extPAL_60);
			rinfo->v=25;
			break;
		case 12: /* pal_60-svideo */
			RT_SetConnector(rinfo->theatre,DEC_SVIDEO,0);
			RT_SetStandard(rinfo->theatre,DEC_PAL | extPAL_60);
			rinfo->v=25;
			break;
		default:
			rinfo->v=0;
			return;
	}       
	RT_SetInterlace(rinfo->theatre, 1);
	width = InputVideoEncodings[rinfo->encoding].width;
	height = InputVideoEncodings[rinfo->encoding].height;
	RT_SetOutputVideoSize(rinfo->theatre, width, height*2, 0, rinfo->capture_vbi_data);   
}

/* capture config constants */
#define BUF_TYPE_FIELD          0
#define BUF_TYPE_ALTERNATING    1
#define BUF_TYPE_FRAME          2

#define BUF_MODE_SINGLE         0
#define BUF_MODE_DOUBLE         1
#define BUF_MODE_TRIPLE         2
/* CAP0_CONFIG values */

#define FORMAT_BROOKTREE        0
#define FORMAT_CCIR656          1
#define FORMAT_ZV               2
#define FORMAT_VIP16            3
#define FORMAT_TRANSPORT        4

#define ENABLE_RADEON_CAPTURE_WEAVE (CAP0_CONFIG_CONTINUOS \
                        | (BUF_MODE_DOUBLE <<7) \
                        | (BUF_TYPE_FRAME << 4) \
                        | ( (rinfo->theatre !=NULL) ? (FORMAT_CCIR656<<23) : (FORMAT_BROOKTREE<<23)) \
                        | CAP0_CONFIG_HORZ_DECIMATOR \
                        | (rinfo->capture_vbi_data ? CAP0_CONFIG_VBI_EN : 0) \
                        | CAP0_CONFIG_VIDEO_IN_VYUY422)

#define ENABLE_RADEON_CAPTURE_BOB (CAP0_CONFIG_CONTINUOS \
                        | (BUF_MODE_SINGLE <<7)  \
                        | (BUF_TYPE_ALTERNATING << 4) \
                        | ( (rinfo->theatre !=NULL) ? (FORMAT_CCIR656<<23) : (FORMAT_BROOKTREE<<23)) \
                        | CAP0_CONFIG_HORZ_DECIMATOR \
                        | (rinfo->capture_vbi_data ? CAP0_CONFIG_VBI_EN : 0) \
                        | CAP0_CONFIG_VIDEO_IN_VYUY422)

int RADEONPutVideo(struct radeonfb_info *rinfo, int src_x, int src_y, int src_w, int src_h,
 int drw_x, int drw_y, int drw_w, int drw_h)
{
	unsigned int pitch, new_size, offset1, offset2, offset3, offset4, s2offset, s3offset, vbi_offset0, vbi_offset1;
	int srcPitch, srcPitch2, dstPitch, bpp;
	unsigned long display_base, offset, size;
	int width, height, mult, vbi_line_width, vbi_start, vbi_end;
	DPRINT("radeonfb: RADEONPutVideo\r\n");
	/* s2offset, s3offset - byte offsets into U and V plane of the source where copying starts
	                        Y plane is done by editing "buf"
	   offset - byte offset to the first line of the destination
	   dst_start - byte address to the first displayed pel
	 */
	s2offset = s3offset = srcPitch2 = 0;
	width = InputVideoEncodings[rinfo->encoding].width;
	height = InputVideoEncodings[rinfo->encoding].height;
	vbi_line_width = 0x326;
	vbi_line_width = 2048;
	vbi_line_width = 0x618;
	vbi_line_width = 798*2;
	if(width <= 640)
		vbi_line_width = 0x640; /* 1600 actually */
	else
		vbi_line_width = 2000; /* might need adjustment */
	bpp = rinfo->bpp >> 3;
	pitch = bpp * rinfo->info->var.yres;
	switch(rinfo->overlay_deinterlacing_method)
	{
		case METHOD_BOB:
		case METHOD_SINGLE: mult=2; break;
		case METHOD_WEAVE:
		case METHOD_ADAPTIVE: mult=4; break;
		default: DPRINT("radeonfb: Internal error: PutVideo\r\n"); mult=4; break;
	}
	dstPitch = ((width<<1) + 15) & ~15;
	new_size = ((dstPitch * height) + bpp - 1) / bpp;
	srcPitch = (width<<1);
	new_size = new_size + 0x1f; /* for aligning */
	size = (long)(new_size*mult+(rinfo->capture_vbi_data ? 2*2*vbi_line_width*21 : 0));
	if((rinfo->videoLinear != NULL) && (size != rinfo->videoLinearSize))
	{
//		vixPlaybackOff();
		rinfo->videoLinear = NULL;
	}
	if(rinfo->videoLinear == NULL)
	{
		static vidix_capability_t cap;
		static vidix_fourcc_t fourcc;
		static vidix_playback_t info;
		rinfo->videoLinearSize = size;
		vixGetCapability(&cap);
		if(!(cap.type & TYPE_CAPTURE)
		 && ((cap.flags & (FLAG_DOWNSCALER | FLAG_UPSCALER)) ==  (FLAG_DOWNSCALER | FLAG_UPSCALER)))
		{
			fourcc.fourcc = IMGFMT_YUY2; /* packed YUYV 4:2:2 */
			fourcc.srcw = src_w;
			fourcc.srch = src_h;
			if(!vixQueryFourcc(&fourcc))
			{
				memset(&info,0,sizeof(vidix_playback_t));
				info.fourcc = IMGFMT_YUY2; /* packed YUYV 4:2:2 */
				info.capability = cap.flags;
				info.src.x = src_x;
				info.src.y = src_y;
				info.src.w = src_w;
				info.src.h = src_h;
				info.dest.x = drw_x;
				info.dest.y = drw_y;
				info.dest.w = drw_w;
				info.dest.h = drw_h;
				info.num_frames = 1;
				if(!vixConfigPlayback(&info))
				{
					rinfo->videoLinear = info.dga_addr;
//					rinfo->videoLinearSize = (unsigned long)info.frame_size;
					rinfo->videoLinearOffset.y = info.offset.y;
					rinfo->videoLinearOffset.u = info.offset.u;
					rinfo->videoLinearOffset.v = info.offset.v;
					memset(info.dga_addr,0x80,info.frame_size);
				}
			}
		}
	}
	if(rinfo->videoLinear == NULL)
	{
		DPRINT("radeonfb: RADEONPutVideo: no videoLinear buffer\r\n");
		return(-1);
	}
//	offset = (unsigned long)rinfo->videoLinear - (unsigned long)rinfo->fb_base + rinfo->videoLinearOffset.y;
	offset = rinfo->videoLinearOffset.y;
	RADEONWaitForIdleMMIO(rinfo);
	display_base=0; /* INREG(DISPLAY_BASE_ADDR); */
	switch(rinfo->overlay_deinterlacing_method)
	{
		case METHOD_BOB:
		case METHOD_SINGLE:
			offset1 = (offset*bpp+0xf) & (~0xf);
			offset2 = ((offset+new_size)*bpp + 0xf) & (~0xf);
			offset3 = offset1;
			offset4 = offset2;
			break;
		case METHOD_WEAVE:
			offset1 = (offset*bpp+0xf) & (~0xf);
			offset2 = offset1+dstPitch;
			offset3 = ((offset+2*new_size)*bpp + 0xf) & (~0xf);
			offset4 = offset3+dstPitch;
			break;
		default:
			offset1 = (offset*bpp+0xf) & (~0xf);
			offset2 = ((offset+new_size)*bpp + 0xf) & (~0xf);
			offset3 = offset1;
			offset4 = offset2;
			break;
	}
	OUTREG(CAP0_BUF0_OFFSET, offset1+display_base);
	OUTREG(CAP0_BUF0_EVEN_OFFSET, offset2+display_base);
	OUTREG(CAP0_BUF1_OFFSET, offset3+display_base);
	OUTREG(CAP0_BUF1_EVEN_OFFSET, offset4+display_base);
	OUTREG(CAP0_ONESHOT_BUF_OFFSET, offset1+display_base);
	if(rinfo->capture_vbi_data)
	{
		if((rinfo->encoding==2) || (rinfo->encoding==8))
		{
			/* PAL, SECAM */
			vbi_start = 5;
			vbi_end = 21;
		}
		else
		{
			/* NTSC */
			vbi_start = 8;
			vbi_end = 20;
		}
		vbi_offset0 = ((offset+mult*new_size)*bpp+0xf) & (~0xf);
		vbi_offset1 = vbi_offset0 + dstPitch*20;
		OUTREG(CAP0_VBI0_OFFSET, vbi_offset0+display_base);
		OUTREG(CAP0_VBI1_OFFSET, vbi_offset1+display_base);
		OUTREG(CAP0_VBI2_OFFSET, 0);
		OUTREG(CAP0_VBI3_OFFSET, 0);
		OUTREG(CAP0_VBI_V_WINDOW, vbi_start | (vbi_end<<16));
		OUTREG(CAP0_VBI_H_WINDOW, 0 | (vbi_line_width)<<16);
	}
	OUTREG(CAP0_BUF_PITCH, dstPitch*mult/2);
	OUTREG(CAP0_H_WINDOW, (2*width)<<16);
	OUTREG(CAP0_V_WINDOW, (((height)+rinfo->v-1)<<16)|(rinfo->v-1));
	if(mult==2)
		OUTREG(CAP0_CONFIG, ENABLE_RADEON_CAPTURE_BOB);
	else
  	OUTREG(CAP0_CONFIG, ENABLE_RADEON_CAPTURE_WEAVE);
	OUTREG(CAP0_DEBUG, 0);
	OUTREG(VID_BUFFER_CONTROL, (1<<16) | 0x01);
	OUTREG(TEST_DEBUG_CNTL, 0);
	if(!rinfo->video_stream_active)
	{
		RADEONWaitForIdleMMIO(rinfo);
		OUTREG(VIDEOMUX_CNTL, INREG(VIDEOMUX_CNTL) | 1); 
		OUTREG(CAP0_PORT_MODE_CNTL, (rinfo->theatre != NULL) ? 1 : 0);
		OUTREG(FCP_CNTL, FCP0_SRC_PCLK);
		OUTREG(CAP0_TRIG_CNTL, 0x11);
		if(rinfo->theatre != NULL) 
			RADEON_RT_SetEncoding(rinfo);
	}
//	if(!(rinfo->videoStatus & CLIENT_VIDEO_ON))
//		vixPlaybackOn();
#if 0
	/* update cliplist */
	if(!REGION_EQUAL(pScrn->pScreen, &pPriv->clip, clipBoxes))
	{
		REGION_COPY(pScrn->pScreen, &pPriv->clip, clipBoxes);
		/* draw these */
	}
//	RADEONDisplayVideo(rinfo, pPriv, id, offset1+top*srcPitch, offset2+top*srcPitch, offset3+top*srcPitch, offset4+top*srcPitch, width, height, dstPitch*mult/2,
//                     xa, xb, ya, &dstBox, src_w, src_h*mult/2, drw_w, drw_h, pPriv->overlay_deinterlacing_method);
#endif
#if 0
	RADEONWaitForFifo(rinfo, 1);
	OUTREG(OV0_REG_LOAD_CNTL, REG_LD_CTL_LOCK);
	RADEONWaitForIdleMMIO(rinfo);
	while(!(INREG(OV0_REG_LOAD_CNTL) & REG_LD_CTL_LOCK_READBACK));
	switch(rinfo->overlay_deinterlacing_method)
	{
		case METHOD_BOB:
			OUTREG(OV0_DEINTERLACE_PATTERN, 0xAAAAA);
			OUTREG(OV0_AUTO_FLIP_CNTL, /* OV0_AUTO_FLIP_CNTL_SOFT_BUF_ODD | */ OV0_AUTO_FLIP_CNTL_SHIFT_ODD_DOWN);
			break;
		case METHOD_SINGLE:
			OUTREG(OV0_DEINTERLACE_PATTERN, 0xEEEEE | (9<<28));
			OUTREG(OV0_AUTO_FLIP_CNTL, OV0_AUTO_FLIP_CNTL_SOFT_BUF_ODD | OV0_AUTO_FLIP_CNTL_SHIFT_ODD_DOWN);
			break;
		case METHOD_WEAVE:
			OUTREG(OV0_DEINTERLACE_PATTERN, 0x11111 | (9<<28));
			OUTREG(OV0_AUTO_FLIP_CNTL, OV0_AUTO_FLIP_CNTL_SOFT_BUF_ODD | OV0_AUTO_FLIP_CNTL_P1_FIRST_LINE_EVEN 
			 /* | OV0_AUTO_FLIP_CNTL_SHIFT_ODD_DOWN | OV0_AUTO_FLIP_CNTL_SHIFT_EVEN_DOWN */
			 | OV0_AUTO_FLIP_CNTL_FIELD_POL_SOURCE);
			break;
		default:
			OUTREG(OV0_DEINTERLACE_PATTERN, 0xAAAAA);
			OUTREG(OV0_AUTO_FLIP_CNTL, OV0_AUTO_FLIP_CNTL_SOFT_BUF_ODD | OV0_AUTO_FLIP_CNTL_SHIFT_ODD_DOWN);
	}
	RADEONWaitForIdleMMIO(rinfo);
	OUTREG(OV0_AUTO_FLIP_CNTL, (INREG(OV0_AUTO_FLIP_CNTL) ^ OV0_AUTO_FLIP_CNTL_SOFT_EOF_TOGGLE ));
	OUTREG(OV0_AUTO_FLIP_CNTL, (INREG(OV0_AUTO_FLIP_CNTL) ^ OV0_AUTO_FLIP_CNTL_SOFT_EOF_TOGGLE ));
	OUTREG(OV0_REG_LOAD_CNTL, 0);
	/* OUTREG(OV0_FLAG_CNTL, 8); */
	/* OUTREG(OV0_SCALE_CNTL, 0x417f1B00); */
#endif

	rinfo->videoStatus = CLIENT_VIDEO_ON;
	rinfo->video_stream_active = TRUE;
	
//   info->VideoTimerCallback = RADEONVideoTimerCallback;

	return(0);
}

#endif /* RADEON_THEATRE */
