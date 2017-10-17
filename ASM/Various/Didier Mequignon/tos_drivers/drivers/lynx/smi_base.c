/*
 * (C) Copyright 1997-2002 ELTEC Elektronik AG
 * Frank Gottschling <fgottschling@eltec.de>
 *
 * See file CREDITS for list of people who contributed to this
 * project.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 * MA 02111-1307 USA
 */

/*
 * smiLynxEM.c
 *
 * Silicon Motion graphic interface for sm810/sm710/sm712 accelerator
 *
 * modification history
 * --------------------
 * 04-18-2002 - Rewritten for U-Boot <fgottschling@eltec.de>.
 *
 * 18-03-2004 - Unify videomodes handling with the ct69000
 *            - The video output can be set via the variable "videoout"
 *              in the environment.
 *              videoout=1 output on LCD
 *              videoout=2 output on CRT (default value)
 *	                <p.aubert@staubli.com>
 * 16-10-2009 - Rewrited for TOS <aniplay@wanadoo.fr>
 */

#include "config.h"
#include "smi.h"

#ifdef CONFIG_VIDEO_SMI_LYNXEM

#ifndef INT_MAX
#define INT_MAX ((int)(~0U>>1))
#endif

#define MIN_MAPPED_VRAM	(1024*768*4)

/*
 * Video processor control
 */
typedef struct {
	unsigned int   control;
	unsigned int   colorKey;
	unsigned int   colorKeyMask;
	unsigned int   start;
	unsigned short offset;
	unsigned short width;
	unsigned int   fifoPrio;
	unsigned int   fifoERL;
	unsigned int   YUVtoRGB;
} SmiVideoProc;

/*
 * Video window control
 */
typedef struct {
	unsigned short top;
	unsigned short left;
	unsigned short bottom;
	unsigned short right;
	unsigned int   srcStart;
	unsigned short width;
	unsigned short offset;
	unsigned char  hStretch;
	unsigned char  vStretch;
} SmiVideoWin;

/*
 * Capture port control
 */
typedef struct {
	unsigned int   control;
	unsigned short topClip;
	unsigned short leftClip;
	unsigned short srcHeight;
	unsigned short srcWidth;
	unsigned int   srcBufStart1;
	unsigned int   srcBufStart2;
	unsigned short srcOffset;
	unsigned short fifoControl;
} SmiCapturePort;

#define CHIP_DEF(id, flags)					\
	{ PCI_VENDOR_ID_SMI, id, PCI_ANY_ID, PCI_ANY_ID, 0, 0, flags }

struct pci_device_id lynxfb_pci_table[] = {
	CHIP_DEF(PCI_DEVICE_ID_SMI_910, 0), /* Lynx */
	CHIP_DEF(PCI_DEVICE_ID_SMI_810, 0), /* LynxE */
	CHIP_DEF(PCI_DEVICE_ID_SMI_820, 0), /* Lynx3D */
	CHIP_DEF(PCI_DEVICE_ID_SMI_710, 0), /* LynxEM */
	CHIP_DEF(PCI_DEVICE_ID_SMI_712,	0), /* LynxEM+ */
	CHIP_DEF(PCI_DEVICE_ID_SMI_720,	0), /* Lynx3DM */
	{ 0, 0, 0, 0, 0, 0, 0 }
};

static struct fb_var_screeninfo lynxfb_default_var = {
	.xres		= 640,
	.yres		= 480,
	.xres_virtual	= 640,
	.yres_virtual	= 480,
	.bits_per_pixel = 8,
	.red		= { .length = 8 },
	.green		= { .length = 8 },
	.blue		= { .length = 8 },
	.activate	= FB_ACTIVATE_NOW,
	.height		= -1,
	.width		= -1,
	.pixclock	= 39721,
	.left_margin	= 40,
	.right_margin	= 24,
	.upper_margin	= 32,
	.lower_margin	= 11,
	.hsync_len	= 96,
	.vsync_len	= 2,
	.vmode		= FB_VMODE_NONINTERLACED
};

/*
 * Register values for common video modes
 */
static char SMI_SCR[] = {
	/* all modes */
	0x10, 0xff, 0x11, 0xff, 0x12, 0xff, 0x13, 0xff, 0x15, 0x90,
	0x17, 0x20, 0x18, 0xb1, 0x19, 0x00,
};
static char SMI_EXT_CRT[] = {
	0x31, 0x00, 0x32, 0x00, 0x33, 0x00, 0x34, 0x00, 0x35, 0x00,
	0x36, 0x00, 0x3b, 0x00, 0x3c, 0x00, 0x3d, 0x00, 0x3e, 0x00, 0x3f, 0x00,
};
static char SMI_ATTR [] = {
	0x00, 0x00, 0x01, 0x01, 0x02, 0x02, 0x03, 0x03, 0x04, 0x04, 0x05, 0x05,
	0x06, 0x06, 0x07, 0x07, 0x08, 0x08, 0x09, 0x09, 0x0a, 0x0a, 0x0b, 0x0b,
	0x0c, 0x0c, 0x0d, 0x0d, 0x0e, 0x0e, 0x0f, 0x0f, 0x10, 0x41, 0x11, 0x00,
	0x12, 0x0f, 0x13, 0x00, 0x14, 0x00,
};
static char SMI_GCR[18] = {
	0x00, 0x00, 0x01, 0x00, 0x02, 0x00, 0x03, 0x00, 0x04, 0x00, 0x05, 0x40,
	0x06, 0x05, 0x07, 0x0f, 0x08, 0xff,
};
static char SMI_SEQR[] = {
	0x00, 0x00, 0x01, 0x01, 0x02, 0x0f, 0x03, 0x03, 0x04, 0x0e, 0x00, 0x03,
};
static char SMI_PCR [] = {
	0x20, 0x04, 0x21, 0x30, 0x22, 0x00, 0x23, 0x00, 0x24, 0x00,
};
static char SMI_MCR[] = {
	0x60, 0x01, 0x61, 0x00,
#ifdef CONFIG_HMI1001
	0x62, 0x74, /* Memory type is not configured by pins on HMI1001 */
#endif
};

static char SMI_HCR[] = {
	0x80, 0xff, 0x81, 0x07, 0x82, 0x00, 0x83, 0xff, 0x84, 0xff, 0x88, 0x00,
	0x89, 0x02, 0x8a, 0x80, 0x8b, 0x01, 0x8c, 0xff, 0x8d, 0x00,
};

extern void board_printf(const char *fmt, ...);

/* I/O Functions */
unsigned char VGAIN8_INDEX(struct smifb_info *smiinfo, int indexPort, int dataPort, unsigned char index)
{
	unsigned char ret;
	board_printf("VGAIN8_INDEX(0x%X,0x%X,0x%02X)=", indexPort, dataPort, index & 0xFF);
	indexPort -= 0x300;
	dataPort -= 0x300;
	if(smiinfo->mmio_base_phys != 0xFFFFFFFF)
	{
		MMIO_OUT8(smiinfo->mmio_base_phys, indexPort, index);
		ret = MMIO_IN8(smiinfo->mmio_base_phys, dataPort);
	}
	else
	{
		outb(smiinfo->io_base_phys + indexPort, index);
		ret = inb(smiinfo->io_base_phys + dataPort);
	}
	board_printf("0x%02X\r\n", ret & 0xFF);
	return(ret);
}

void VGAOUT8_INDEX(struct smifb_info *smiinfo, int indexPort, int dataPort, unsigned char index, unsigned char data)
{
	board_printf("VGAOUT8_INDEX(0x%X,0x%X,0x%02X,0x%02X)\r\n", indexPort, dataPort, index & 0xFF, data & 0xFF);
	indexPort -= 0x300;
	dataPort -= 0x300;
	if(smiinfo->mmio_base_phys != 0xFFFFFFFF)
	{
		MMIO_OUT8(smiinfo->mmio_base_phys, indexPort, index);
		MMIO_OUT8(smiinfo->mmio_base_phys, dataPort, data);
	}
	else
	{
		outb(smiinfo->io_base_phys + indexPort, index);
		outb(smiinfo->io_base_phys + dataPort, data);
	}
}

unsigned char VGAIN8(struct smifb_info *smiinfo, int port)
{
	unsigned char ret;
	board_printf("VGAIN8(0x%X)=", port);
	port -= 0x300;
	if(smiinfo->mmio_base_phys != 0xFFFFFFFF)
		ret = MMIO_IN8(smiinfo->mmio_base_phys, port);
	else
		ret = inb(smiinfo->io_base_phys + port);
	board_printf("0x%02X\r\n", ret & 0xFF);
	return(ret);
}

void VGAOUT8(struct smifb_info *smiinfo, int port, unsigned char data)
{
	board_printf("VGAOUT8(0x%X,0x%02X)\r\n", port, data);
	port -= 0x300;
	if(smiinfo->mmio_base_phys != 0xFFFFFFFF)
		MMIO_OUT8(smiinfo->mmio_base_phys, port, data);
	else
		outb(smiinfo->io_base_phys + port, data);
}

/* Write a table of SMI ISA register */
static void smiLoadRegs(struct smifb_info *smiinfo, unsigned int iReg, unsigned int dReg, char	*regTab, unsigned int tabSize)
{
	int i;
	DPRINT("lynxfb: smiLoadRegs\r\n");
	for(i=0; i<tabSize; i+=2)
	{
		if(iReg == SMI_INDX_ATTR)
		{
			/* Reset the Flip Flop */
			VGAIN8(smiinfo, SMI_ISR1);
			VGAOUT8(smiinfo, iReg, regTab[i]);
			VGAOUT8(smiinfo, iReg, regTab[i+1]);
		}
		else
		{
			VGAOUT8(smiinfo, iReg, regTab[i]);
			VGAOUT8(smiinfo, dReg, regTab[i+1]);
		}
	}
}

/* Init capture port registers */
static void smiInitCapturePort(struct smifb_info *smiinfo)
{
	SmiCapturePort smiCP = { 0x01400600, 0x30, 0x40, 480, 640, 0, 0, 2560, 6 };
	SmiCapturePort *pCP = (SmiCapturePort *)&smiCP;
	DPRINT("lynxfb: smiInitCapturePort\r\n");
	WRITE_CPR(smiinfo, 0x04, ((pCP->topClip<<16)   | pCP->leftClip));
	WRITE_CPR(smiinfo, 0x08, ((pCP->srcHeight<<16) | pCP->srcWidth));
	WRITE_CPR(smiinfo, 0x0c, pCP->srcBufStart1/8);
	WRITE_CPR(smiinfo, 0x10, pCP->srcBufStart2/8);
	WRITE_CPR(smiinfo, 0x14, pCP->srcOffset/8);
	WRITE_CPR(smiinfo, 0x18, pCP->fifoControl);
	WRITE_CPR(smiinfo, 0x00, pCP->control);
}

/* Init video processor registers */
static void smiInitVideoProcessor(struct smifb_info *smiinfo)
{
	SmiVideoProc smiVP;
	SmiVideoWin smiVW;
	SmiVideoProc *pVP = (SmiVideoProc *)&smiVP;
	SmiVideoWin *pVWin = (SmiVideoWin *)&smiVW;
	DPRINT("lynxfb: smiInitVideoProcessor\r\n");
	pVP->control  = (smiinfo->gdfIndex << 16) | 0x100000;
	pVP->colorKey = pVP->colorKeyMask = pVP->start = 0;
  pVP->offset   = 0; 
	pVP->width    = smiinfo->plnSizeX * smiinfo->gdfBytesPP;
	pVP->fifoPrio = 0x1200543;
	pVP->fifoERL  = 4;
	pVP->YUVtoRGB = 0xededed;
	pVWin->top = pVWin->left = pVWin->hStretch = pVWin->offset = 0;
	pVWin->srcStart = 0;
	pVWin->hStretch = pVWin->vStretch = 0;
	pVWin->bottom = smiinfo->winSizeY - 1;
	pVWin->right  = smiinfo->winSizeX - 1;
	pVWin->width  = pVP->width;
	/* color key */
	WRITE_VPR(smiinfo, 0x04, pVP->colorKey);
	/* color key mask */
	WRITE_VPR(smiinfo, 0x08, pVP->colorKeyMask);
	/* data src start adrs */
	WRITE_VPR(smiinfo, 0x0c, pVP->start / 8);
	/* data width and offset */
	WRITE_VPR(smiinfo, 0x10, ((pVP->offset / 8 * smiinfo->gdfBytesPP) << 16) | (smiinfo->plnSizeX / 8 * smiinfo->gdfBytesPP));
	/* video window 1 */
	WRITE_VPR(smiinfo, 0x14, ((pVWin->top << 16) | pVWin->left));
	WRITE_VPR(smiinfo, 0x18, ((pVWin->bottom << 16) | pVWin->right));
	WRITE_VPR(smiinfo, 0x1c, pVWin->srcStart / 8);
	WRITE_VPR(smiinfo, 0x20, (((pVWin->offset / 8) << 16) | (pVWin->width / 8)));
	WRITE_VPR(smiinfo, 0x24, (((pVWin->hStretch) << 8) | pVWin->vStretch));
	/* video window 2 */
	WRITE_VPR(smiinfo, 0x28, ((pVWin->top << 16) | pVWin->left));
	WRITE_VPR(smiinfo, 0x2c, ((pVWin->bottom << 16) | pVWin->right));
	WRITE_VPR(smiinfo, 0x30, pVWin->srcStart / 8);
	WRITE_VPR(smiinfo, 0x34, (((pVWin->offset / 8) << 16) | (pVWin->width / 8)));
	WRITE_VPR(smiinfo, 0x38, (((pVWin->hStretch) << 8) | pVWin->vStretch));
	/* fifo prio control */
	WRITE_VPR(smiinfo, 0x54, pVP->fifoPrio);
	/* fifo empty request levell */
	WRITE_VPR(smiinfo, 0x58, pVP->fifoERL);
	/* conversion constant */
	WRITE_VPR(smiinfo, 0x5c, pVP->YUVtoRGB);
	/* vpr control word */
	WRITE_VPR(smiinfo, 0x0000, pVP->control);
}

static void smiLoadMsr(struct smifb_info *smiinfo, struct fb_var_screeninfo *mode)
{
	unsigned char h_synch_high, v_synch_high;
	DPRINT("lynxfb: smiLoadMsr\r\n");
	h_synch_high = (mode->sync & FB_SYNC_HOR_HIGH_ACT) ? 0 : 0x40;	/* horizontal Synch High active */
	v_synch_high = (mode->sync & FB_SYNC_VERT_HIGH_ACT) ? 0 : 0x80;	/* vertical Synch High active */
	VGAOUT8(smiinfo, SMI_MISC_REG, (h_synch_high | v_synch_high | 0x29));
	/* upper64K==0x20, CLC2select==0x08, RAMenable==0x02!(todo), CGA==0x01
	 * Selects the upper 64KB page.Bit5=1
	 * CLK2 (left reserved in standard VGA) Bit3|2=1|0
	 * Disables CPU access to frame buffer. Bit1=0
	 * Sets the I/O address decode for ST01, FCR, and all CR registers
	 * to the 3Dx I/O address range (CGA emulation). Bit0=1
	 */
}

static void smiLoadCrt(struct smifb_info *smiinfo, struct fb_var_screeninfo *var)
{
	unsigned char cr[0x7a];
	int i;
	unsigned int hd, hs, he, ht, hbs, hbe;	/* Horizontal.	*/
	unsigned int vd, vs, ve, vt, vbs, vbe;	/* vertical */
	unsigned int bpp, wd, dblscan, interlaced;
	const int LineCompare = 0x3ff;
	unsigned int TextScanLines = 1;	/* this is in fact a vertical zoom factor   */
	DPRINT("lynxfb: smiLoadCrt\r\n");
	/* Horizontal */
	hd = (var->xres) / 8;	/* HDisp.  */
	hs = (var->xres + var->right_margin) / 8;	/* HsStrt  */
	he = (var->xres + var->right_margin + var->hsync_len) / 8;	/* HsEnd   */
	ht = (var->left_margin + var->xres + var->right_margin + var->hsync_len) / 8;	/* HTotal  */
	/* Blank */
	hbs = hd;
	hbe = 0; /* Blank end at 0 */
	/* Vertical */
	vd = var->yres;		/* VDisplay   */
	vs = var->yres + var->lower_margin;	/* VSyncStart */
	ve = var->yres + var->lower_margin + var->vsync_len;	/* VSyncEnd */
	vt = var->upper_margin + var->yres + var->lower_margin + var->vsync_len;	/* VTotal  */
	vbs = vd;
	vbe = 0;
	bpp = smiinfo->bpp;
	dblscan = (var->vmode & FB_VMODE_DOUBLE) ? 1 : 0;
	interlaced = var->vmode & FB_VMODE_INTERLACED;
	if(bpp == 15)
		bpp = 16;
	wd = var->xres * bpp / 64;	/* double words per line */
	if(interlaced)
	{	/* we divide all vertical timings, exept vd */
		vs >>= 1;
		vbs >>= 1;
		ve >>= 1;
		vt >>= 1;
	}
	memset(cr, 0, sizeof (cr));
	cr[0x00] = ht - 5;
	cr[0x01] = hd - 1;
	cr[0x02] = hbs - 1;
	cr[0x03] = (hbe & 0x1F);
	cr[0x04] = hs;
	cr[0x05] = ((hbe & 0x20) << 2) | (he & 0x1f);
	cr[0x06] = (vt - 2) & 0xFF;
	cr[0x07] = (((vt - 2) & 0x100) >> 8)
		| (((vd - 1) & 0x100) >> 7)
		| ((vs & 0x100) >> 6)
		| (((vbs - 1) & 0x100) >> 5)
		| ((LineCompare & 0x100) >> 4)
		| (((vt - 2) & 0x200) >> 4)
		| (((vd - 1) & 0x200) >> 3)
		| ((vs & 0x200) >> 2);
	cr[0x30] = ((vt - 2) & 0x400) >> 7
		| (((vd - 1) & 0x400) >> 8)
		| (((vbs - 1) & 0x400) >> 9)
		| ((vs & 0x400) >> 10)
		| (interlaced) ? 0x80 : 0;
	cr[0x08] = 0x00;
	cr[0x09] = (dblscan << 7)
		| ((LineCompare & 0x200) >> 3)
		| (((vbs - 1) & 0x200) >> 4)
		| (TextScanLines - 1);
	cr[0x10] = vs & 0xff;	/* VSyncPulseStart */
	cr[0x11] = (ve & 0x0f);
	cr[0x12] = (vd - 1) & 0xff;	/* LineCount  */
	cr[0x13] = wd & 0xff;
	cr[0x14] = 0x40;
	cr[0x15] = (vbs - 1) & 0xff;
	cr[0x16] = vbe & 0xff;
	cr[0x17] = 0xe3;	/* but it does not work */
	cr[0x18] = 0xff & LineCompare;
	cr[0x22] = 0x00;	/* todo? */
	/* now set the registers */
	for(i = 0; i <= 0x18; i++)
	{	/*CR00 .. CR18 */
		VGAOUT8_INDEX(smiinfo, SMI_INDX_D4, SMI_DATA_D5, i, cr[i]);
	}
	VGAOUT8_INDEX(smiinfo, SMI_INDX_D4, SMI_DATA_D5, 0x22, cr[0x22]); /* CR22 */
	VGAOUT8_INDEX(smiinfo, SMI_INDX_D4, SMI_DATA_D5, 0x30, cr[0x30]); /* CR30 */
}

#define REF_FREQ	14318180
#define PMIN		1
#define PMAX		255
#define QMIN		1
#define QMAX		63

static unsigned int FindPQ(unsigned int freq, unsigned int *pp, unsigned int *pq)
{
	unsigned int n = QMIN, m = 0;
	double L = 0, P = (double)freq, Q = REF_FREQ, H = P / 2.0;
	double D = (double)0x7ffffffffffffffLL;
	DPRINT("lynxfb: FindPQ\r\n");
	for(n = QMIN; n <= QMAX; n++)
	{
		m = PMIN;	/* p/q ~ freq/ref -> p*ref-freq*q ~ 0 */
		L = P * n - m * Q;
		while(L > 0 && m < PMAX)
		{
			L -= REF_FREQ;	/* difference is greater as 0 subtract fref */
			m++;	/* and increment m */
		}
		/* difference is less or equal than 0 or m > maximum */
		if(m > PMAX)
			break;	/* no solution: if we increase n we get the same situation */
		/* L is <= 0 now */
		if(-L > H && m > PMIN)
		{	/* if difference > the half fref */
			L += REF_FREQ;	/* we take the situation before */
			m--;	/* because its closer to 0 */
		}
		L = (L < 0) ? -L : +L;	/* absolute value */
		if(D < L)	/* if last difference was better take next n */
			continue;
		D = L;
		*pp = m;
		*pq = n;	/*  keep improved data */
		if((unsigned int)D == 0)
			break;	/* best result we can get */
	}
	return((unsigned int)D);
}

static void smiLoadCcr(struct smifb_info *smiinfo, struct fb_var_screeninfo *var)
{
	unsigned int p = 0;
	unsigned int q = 0;
	double freq = 1000000000000.0 / (double)var->pixclock; /* Hz */
	DPRINT("lynxfb: smiLoadCcr\r\n");
	VGAOUT8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x65, 0);
	VGAOUT8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x66, 0);
	VGAOUT8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x68, 0x50);
	if(smiinfo->chipset == PCI_DEVICE_ID_SMI_810)
		VGAOUT8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x69, 0x3);
	else
		VGAOUT8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x69, 0x0);
	/* Memory clock */
	switch(smiinfo->chipset)
	{
		case PCI_DEVICE_ID_SMI_710: VGAOUT8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x6a, 0x75); break;
		case PCI_DEVICE_ID_SMI_712: VGAOUT8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x6a, 0x80); break;
		default: VGAOUT8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x6a, 0x53); break;
	}
	VGAOUT8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x6b, 0x15);
	/* VCLK */
	FindPQ((unsigned int)freq, &p, &q);
	VGAOUT8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x6c, p);
	VGAOUT8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x6d, q);
}

static int lynx_parse_monitor_layout(struct smifb_info *smiinfo, const char *monitor_layout)
{
#define MT_NONE 0
#define MT_CRT 1
#define MT_LCD 2 
	int mon1_type = MT_CRT, mon2_type = MT_CRT;
	char s1[5], s2[5];
	int i = 0, second = 0;
	const char *s;
	/* 0:none 1:LCD 2:CRT 3:CRT/LCD 4:TV 5:TV/LCD */
	smiinfo->videoout = 2;	    /* Default output is CRT */
	if((monitor_layout == NULL) || (*monitor_layout == '\0'))
		return 0;
	s = monitor_layout;
	do
	{
		switch(*s)
		{
			case ',':
				s1[i] = '\0';
				i = 0;
				second = 1;
				break;
			case ' ':
			case '\0':
				break;
			default:
				if(i >= 4)
					break;
				if(second)
					s2[i] = *s;
				else
					s1[i] = *s;
				i++;
				break;				
		}
	}
	while(*s++);
	if(second)
		s2[i] = '\0';
	else
	{
		s1[i] = '\0';
		s2[0] = '\0';
	}
	if(Funcs_equal(s1, "CRT"))
		mon1_type = MT_CRT;
	else if(Funcs_equal(s1, "LVDS"))
		mon1_type = MT_LCD;
	if(Funcs_equal(s2, "CRT"))
		mon2_type = MT_CRT;
	else if(Funcs_equal(s2, "LVDS"))
		mon2_type = MT_LCD;
	if((mon1_type == MT_NONE) && (mon2_type == MT_NONE))
		smiinfo->videoout = 0; /* NONE */
	else if(((mon1_type == MT_LCD) && (mon2_type == MT_NONE))
	 || ((mon1_type == MT_NONE) && (mon2_type == MT_LCD)))
		smiinfo->videoout = 1; /* LCD */
	else if(((mon1_type == MT_CRT) && (mon2_type == MT_NONE))
   || ((mon1_type == MT_NONE) && (mon2_type == MT_CRT)))
		smiinfo->videoout = 2; /* CRT */
	else
		smiinfo->videoout = 2; /* CRT */ // 3; /* LCD/CRT */
	return(1);
}

static void lynx_probe_screens(struct smifb_info *smiinfo, const char *monitor_layout, int ignore_edid)
{
	if(lynx_parse_monitor_layout(smiinfo, monitor_layout))
	{
		/* If user specified a monitor_layout option, use it instead of auto-detecting */
		if(!ignore_edid)
		{
			if(smiinfo->videoout != 0)
			{
				switch(lynx_probe_i2c_connector(smiinfo, 1, &smiinfo->mon1_EDID))
				{
					case 1: /* LCD */
					case 2: /* CRT */
					default:
						break;
				}
			}
		}
	}
	else
	{
		if(smiinfo->videoout == 0)
		{
			switch(lynx_probe_i2c_connector(smiinfo, 1, &smiinfo->mon1_EDID))
			{
				case 1: /* LCD */
				case 2: /* CRT */
					smiinfo->videoout = 2; /* CRT */ 		
					break;
				default:
					break;
			}			
			goto bail;
		}
	}
	if(ignore_edid)
	{
		Funcs_free(smiinfo->mon1_EDID);
		smiinfo->mon1_EDID = NULL;
	}
bail:
	if(smiinfo->mon1_EDID)
	{
		DPRINT("lynxfb: EDID probed\r\n");
	}
}

static int var_to_depth(const struct fb_var_screeninfo *var)
{
	if(var->bits_per_pixel != 16)
		return var->bits_per_pixel;
	return(var->green.length == 5) ? 15 : 16;
}

static void lynx_videomode_to_var(struct fb_var_screeninfo *var, const struct fb_videomode *mode)
{
	var->xres = mode->xres;
	var->yres = mode->yres;
	var->xres_virtual = mode->xres;
	var->yres_virtual = mode->yres;
	var->xoffset = 0;
	var->yoffset = 0;
	var->pixclock = mode->pixclock;
	var->left_margin = mode->left_margin;
	var->right_margin = mode->right_margin;
	var->upper_margin = mode->upper_margin;
	var->lower_margin = mode->lower_margin;
	var->hsync_len = mode->hsync_len;
	var->vsync_len = mode->vsync_len;
	var->sync = mode->sync;
	var->vmode = mode->vmode;
}

/* Pick up the default mode */
static void lynx_check_modes(struct smifb_info *smiinfo, struct mode_option *resolution)
{
	struct fb_info *info = smiinfo->info;
	int has_default_mode = 0;
	struct fb_var_screeninfo var;
	struct fb_videomode *mode = &smiinfo->lcd_modedb;
	struct fb_info inf;
	struct mode_option xres_yres;
	DPRINT("lynxfb: lynx_check_modes\r\n");
	/* Fill default var first */
	memcpy(&info->var, &lynxfb_default_var, sizeof(struct fb_var_screeninfo));
	if(smiinfo->videoout & 1) /* LCD */
	{
    switch(VGAIN8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x30) & 0x0C)
    {
			case 0x00: smiinfo->lcdWidth = 640; smiinfo->lcdHeight = 480; break;
			case 0x04: smiinfo->lcdWidth = 800; smiinfo->lcdHeight = 600; break;
			case 0x08:
				if(VGAIN8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x74) & 0x02)
				{
					smiinfo->lcdWidth  = 1024;
					smiinfo->lcdHeight = 600;
				}
				else
				{
					smiinfo->lcdWidth  = 1024;
					smiinfo->lcdHeight = 768;
				}
				break;
			case 0x0C:
				smiinfo->lcdWidth  = 1280;
				smiinfo->lcdHeight = 1024;
				break;
		}
		var.xres = smiinfo->lcdWidth;
		var.yres = smiinfo->lcdHeight;
		mode->xres = var.xres;
		mode->yres = var.yres;
		mode->refresh = 60;
		fb_get_mode(FB_VSYNCTIMINGS | FB_IGNOREMON, mode->refresh, &var, &inf);
		mode->pixclock = var.pixclock;
		mode->left_margin = var.left_margin;
		mode->right_margin = var.right_margin;
		mode->upper_margin = var.upper_margin;
		mode->lower_margin = var.lower_margin;
		mode->hsync_len = var.hsync_len;
		mode->vsync_len = var.vsync_len;
		mode->vmode = 0;
		mode->sync = 0;
		xres_yres.used = 1;
		xres_yres.width = smiinfo->lcdWidth;
		xres_yres.height = smiinfo->lcdHeight;
		xres_yres.bpp = xres_yres.freq = 0;
		if(fb_find_mode(&info->var, info, &xres_yres, mode, 1, NULL, 8) == 0)
		{
			smiinfo->videoout = 2; /* no LCD */
			goto pickup_default;
		}
		has_default_mode = 1;
	}
pickup_default:
	/* Apply passed-in mode option if any */
	if(resolution->used)
	{
		if(fb_find_mode(&info->var, info, resolution, info->monspecs.modedb,
		 info->monspecs.modedb_len, NULL, 8) != 0)
			has_default_mode = 1;
 	}
}

/*
 * This is used when looking for modes. We assign a "distance" value
 * to a mode in the modedb depending how "close" it is from what we
 * are looking for.
 * Currently, we don't compare that much, we could do better but
 * the current fbcon doesn't quite mind ;)
 */
static int lynx_compare_modes(const struct fb_var_screeninfo *var, const struct fb_videomode *mode)
{
	int distance = 0;
	distance = mode->yres - var->yres;
	distance += (mode->xres - var->xres)/2;
	return(distance);
}

/*
 * This function is called by check_var, it gets the passed in mode parameter, and
 * outputs a valid mode matching the passed-in one as closely as possible.
 * We need something better ultimately.
 */
static int lynx_match_mode(struct smifb_info *smiinfo, struct fb_var_screeninfo *dest, const struct fb_var_screeninfo *src)
{
	const struct fb_videomode	*db = vesa_modes;
	int i, dbsize = 34, native_db = 0;
	int	distance = INT_MAX;
	const struct fb_videomode	*candidate = NULL;
//	DPRINT("lynxfb: lynx__match_mode\r\n");
	/* Start with a copy of the requested mode */
	memcpy(dest, src, sizeof(struct fb_var_screeninfo));
	/* Check if we have a modedb built from EDID */
	if(smiinfo->mon1_modedb)
	{
		db = smiinfo->mon1_modedb;
		dbsize = smiinfo->mon1_dbsize;
		native_db = 1;
	}
	/* Look for a mode in the database */
	while(db)
	{
		for(i = 0; i < dbsize; i++)
		{
			int d;
			if(db[i].yres < src->yres)
				continue;	
			if(db[i].xres < src->xres)
				continue;
			d = lynx_compare_modes(src, &db[i]);
			/* If the new mode is at least as good as the previous one,
			 * then it's our new candidate
			 */
			if(d < distance)
			{
				candidate = &db[i];
				distance = d;
			}
		}
		db = NULL;
	}
	/* If we have found a match, return it */
	if(candidate != NULL)
	{
		lynx_videomode_to_var(dest, candidate);
		return 0;
	}
	return -EINVAL;
}

static int lynxfb_check_var(struct fb_var_screeninfo *var, struct fb_info *info)
{
	struct smifb_info *smiinfo = info->par;
	struct fb_var_screeninfo v;
	long freq_khz;
	memset(&v, 0, sizeof(struct fb_var_screeninfo));
//	DPRINT("lynxfb: lynxfb_check_var\r\n");
	if(lynx_match_mode(smiinfo, &v, var))
		return(-EINVAL);
	freq_khz = 1000000000 / (long)v.pixclock;
	if(freq_khz < 20000)
		return(-EINVAL);
	switch(smiinfo->chipset)
	{
		case SMI_LYNXEM:
		case SMI_LYNXEMplus:
			if(freq_khz > 200000)
				return(-EINVAL);
			break;
		default:
			if(freq_khz > 135000)
				return(-EINVAL);
			break;
	}
	switch(v.bits_per_pixel)
	{
		case 0 ... 8:
			v.bits_per_pixel = 8;
			break;
		case 9 ... 16:
			v.bits_per_pixel = 16;
			break;
		case 17 ... 24:
			v.bits_per_pixel = 24;
			break;
		case 25 ... 32:
			v.bits_per_pixel = 32;
			break;
		default:
			return(-EINVAL);
	}
	switch(var_to_depth(&v))
	{
		case 8:
			v.red.length = v.green.length = v.blue.length = 8;
			break;
		case 15:
			v.red.offset = 10;
			v.green.offset = 5;
			v.red.length = v.green.length = v.blue.length = 5;
			break;
		case 16:
			v.red.offset = 11;
			v.green.offset = 5;
			v.red.length = 5;
			v.green.length = 6;
			v.blue.length = 5;
			break;                          
		case 24:
			v.red.offset = 16;
			v.green.offset = 8;
			v.red.length = v.blue.length = v.green.length = 8;
			break;
		case 32:
			v.red.offset = 16;
			v.green.offset = 8;
			v.red.length = v.blue.length = v.green.length = 8;
			v.transp.offset = 24;
			v.transp.length = 8;
			break;
    default:
			DPRINTVAL("lynxfb: mode ",var->xres);
			DPRINTVAL("x",var->yres);
			DPRINTVAL("x",var->bits_per_pixel);
			DPRINT(" rejected, color depth invalid\r\n");
			return(-EINVAL);
	}
	v.yres_virtual = v.yres;
	v.xres_virtual = v.xres;
	memcpy(var, &v, sizeof(v));
	return(0);	
}

/* set the video mode according to info->var */
static int lynxfb_set_par(struct fb_info *info)
{
	struct smifb_info *smiinfo = info->par;
	struct fb_var_screeninfo *mode = &info->var;
	unsigned long t1, hsynch, vsynch;
	/* calculate hsynch and vsynch freq (info only) */
	t1 = (mode->left_margin + mode->xres + mode->right_margin + mode->hsync_len) / 8;
	t1 *= 8;
	t1 *= mode->pixclock;
	t1 /= 1000;
	hsynch = 1000000000L / t1;
	t1 *= (mode->upper_margin + mode->yres + mode->lower_margin + mode->vsync_len);
	t1 /= 1000;
	vsynch = 1000000000L / t1;
	/* fill in Graphic device struct */
	DPRINTVAL("lynxfb: ", mode->xres);
	DPRINTVAL("x", mode->yres);
	DPRINTVAL("x", mode->bits_per_pixel);
	DPRINTVAL(" ", hsynch / 1000);
	DPRINTVAL("kHz ", vsynch / 1000);
	DPRINT("Hz\r\n");
	smiinfo->bpp = mode->bits_per_pixel;
	smiinfo->depth = var_to_depth(mode);
	smiinfo->winSizeX = mode->xres;
	smiinfo->winSizeY = mode->yres;
	smiinfo->plnSizeX = mode->xres;
	smiinfo->plnSizeY = mode->yres;
	switch(smiinfo->bpp)
	{
		case 8:
			smiinfo->gdfBytesPP = 1;
			smiinfo->gdfIndex = GDF__8BIT_INDEX;
			break;
		case 15:
			smiinfo->gdfBytesPP = 2;
			smiinfo->gdfIndex = GDF_15BIT_555RGB;
			break;
		case 16:
			smiinfo->gdfBytesPP = 2;
			smiinfo->gdfIndex = GDF_16BIT_565RGB;
			break;
		case 24:
			smiinfo->gdfBytesPP = 3;
			smiinfo->gdfIndex = GDF_24BIT_888RGB;
			break;
		case 32:
			smiinfo->gdfBytesPP = 4;
			smiinfo->gdfIndex = GDF_32BIT_X888RGB;
			break;
	}
	/* Set up hardware : select color mode,
	   set Register base to isa 3dx for 3?x regs*/
	VGAOUT8(smiinfo, SMI_MISC_REG, 0x01);
	/* Turn off display */
	VGAOUT8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x01, 0x20);
	/* Unlock ext. crt regs */
	VGAOUT8(smiinfo, SMI_LOCK_REG, 0x40);
	/* Unlock crt regs 0-7 */
	VGAOUT8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x11, 0x0e);
	/* Sytem Control Register */
	smiLoadRegs(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, SMI_SCR, sizeof(SMI_SCR));
	/* extented CRT Register */
	smiLoadRegs(smiinfo, SMI_INDX_D4, SMI_DATA_D5, SMI_EXT_CRT, sizeof(SMI_EXT_CRT));
	/* Attributes controller registers */
	smiLoadRegs(smiinfo, SMI_INDX_ATTR, SMI_INDX_ATTR, SMI_ATTR, sizeof(SMI_ATTR));
	/* Graphics Controller Register */
	smiLoadRegs(smiinfo, SMI_INDX_CE, SMI_DATA_CF, SMI_GCR, sizeof(SMI_GCR));
	/* Sequencer Register */
	smiLoadRegs(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, SMI_SEQR, sizeof(SMI_SEQR));
	/* Power Control Register */
	smiLoadRegs(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, SMI_PCR, sizeof(SMI_PCR));
	/* Memory Control Register */
	/* Register MSR62 is a power on configurable register. We don't modify it */
	smiLoadRegs(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, SMI_MCR, sizeof(SMI_MCR));
	/* Set misc output register */
	smiLoadMsr(smiinfo, mode);
	/* Set CRT and Clock control registers */
	smiLoadCrt(smiinfo, mode);
	smiLoadCcr(smiinfo, mode);
	/* Hardware Cursor Register */
	smiLoadRegs(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, SMI_HCR, sizeof(SMI_HCR));
  /* Enable display */
	/* 0:none 1:LCD 2:CRT 3:CRT/LCD 4:TV 5:TV/LCD */
	VGAOUT8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x31, (char)smiinfo->videoout); /* FPR31 */
	/* Video processor default setup */
	smiInitVideoProcessor(smiinfo);
	/* Capture port default setup */
	smiInitCapturePort(smiinfo);
	/* Drawing engine default setup */
	lynx_engine_init(smiinfo);
	/* Turn on display */
	VGAOUT8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x01, 0x01);
	/* Clear video memory */
	memset(smiinfo->fb_base, 0, smiinfo->memSize);
	return(0);
}

static int lynxfb_setcolreg(unsigned regno, unsigned red, unsigned green, unsigned blue, unsigned transp, struct fb_info *info)
{
	struct smifb_info *smiinfo = info->par;
	if(regno > 255)
		return(1);
	if(transp);
	red >>= 8;
	green >>= 8;
	blue >>= 8;
	/* Set a RGB color in the LUT (8 bit index) */
	VGAOUT8(smiinfo, SMI_LUT_MASK,  0xff);
	VGAOUT8(smiinfo, SMI_LUT_START, (char)regno);
	VGAOUT8(smiinfo, SMI_LUT_RGB, (char)(red >> 2)); /* red */
	udelay(10);
	VGAOUT8(smiinfo, SMI_LUT_RGB, (char)(green >> 2)); /* green */
	udelay(10);
	VGAOUT8(smiinfo, SMI_LUT_RGB, (char)(blue >> 2)); /* blue */
	udelay(10);
	return(0);
}

static int lynxfb_pan_display(struct fb_var_screeninfo *var, struct fb_info *info)
{
	if(var);
	if(info);
	return(-EINVAL);
}

static int lynxfb_blank(int blank, struct fb_info *info)
{
	if(blank);
	if(info);
	return(-EINVAL);
}

static int lynxfb_ioctl(unsigned int cmd, unsigned long arg, struct fb_info *info)
{
	if(arg);
	if(info);
	switch(cmd)
	{
		default:
			return(-EINVAL);
	}
	return(-EINVAL);
}

static void lynxfb_check_modes(struct fb_info *info, struct mode_option *resolution)
{
	struct smifb_info *smiinfo = info->par;
	lynx_check_modes(smiinfo, resolution);
}

static struct fb_ops lynxfb_ops =
{
	.fb_check_var = lynxfb_check_var,
	.fb_setcolreg = lynxfb_setcolreg,
	.fb_set_par = lynxfb_set_par,
	.fb_pan_display = lynxfb_pan_display,
	.fb_blank = lynxfb_blank,
	.fb_sync = lynxfb_sync,
	.fb_ioctl = lynxfb_ioctl,
	.fb_check_modes = lynxfb_check_modes,
	.SetupForSolidFill = SMI_SetupForSolidFill,
	.SubsequentSolidFillRect = SMI_SubsequentSolidFillRect,
	.SetupForSolidLine = SMI_SetupForSolidFill,
	.SubsequentSolidHorVertLine = SMI_SubsequentSolidHorVertLine,
	.SubsequentSolidTwoPointLine = NULL,
	.SetupForDashedLine = NULL,
	.SubsequentDashedTwoPointLine = NULL,
	.SetupForScreenToScreenCopy = SMI_SetupForScreenToScreenCopy,
	.SubsequentScreenToScreenCopy = SMI_SubsequentScreenToScreenCopy,
	.ScreenToScreenCopy = SMI_ScreenToScreenCopy,
	.SetupForMono8x8PatternFill = SMI_SetupForMono8x8PatternFill,
	.SubsequentMono8x8PatternFillRect = SMI_SubsequentMono8x8PatternFillRect,
	.SetupForScanlineCPUToScreenColorExpandFill = SMI_SetupForCPUToScreenColorExpandFill,
	.SubsequentScanlineCPUToScreenColorExpandFill = SMI_SubsequentCPUToScreenColorExpandFill,
	.SubsequentScanline = SMI_SubsequentScanline,	
	.SetupForScanlineImageWrite = NULL,
	.SubsequentScanlineImageWriteRect = NULL,
	.SetClippingRectangle = SMI_SetClippingRectangle,
	.DisableClipping = SMI_DisableClipping,
	.SetupForCPUToScreenAlphaTexture = NULL,
	.SetupForCPUToScreenTexture = NULL,
	.SubsequentCPUToScreenTexture = NULL,
	.SetCursorColors = SMI_SetCursorColors,
	.SetCursorPosition = SMI_SetCursorPosition,
	.LoadCursorImage = SMI_LoadCursorImage,
	.HideCursor = SMI_HideCursor,
	.ShowCursor = SMI_ShowCursor,
	.CursorInit = SMI_CursorInit,
	.WaitVbl = NULL,

/*extern void SMI_SetupForColor8x8PatternFill(struct smifb_info *smiinfo, int, int, int, unsigned int, int);
extern void SMI_SubsequentColor8x8PatternFillRect(struct smifb_info *smiinfo, int, int, int, int, int, int);
extern void SMI_SetupForImageWrite(struct smifb_info *smiinfo, int, unsigned int, int, int, int);
extern void SMI_SubsequentImageWriteRect(struct smifb_info *smiinfo, int, int, int, int, int);
*/
};

int lynxfb_pci_register(long handle, const struct pci_device_id *ent)
{
	struct fb_info *info;
	struct smifb_info *smiinfo;
	PCI_RSC_DESC *pci_rsc_desc;
	unsigned char tmp, config;
	unsigned long fb_size = 0, mem_probe = 1024 * 1024;
	unsigned long mem_max = 0x400000;
	static int lynx3d_table[4]  = {  0, 2, 4, 6 };
	static int lynx3dm_table[4] = { 16, 2, 4, 8 };
	static int default_table[4] = {  1, 2, 4, 0 };
#ifndef PCI_XBIOS
  PCI_COOKIE *bios_cookie;
#endif
	info_fvdi = info = framebuffer_alloc(sizeof(struct smifb_info));
	if(!info)
		return(-ENOMEM);
	smiinfo = info->par;
	info->fbops = &lynxfb_ops;
	smiinfo->info = info;
	smiinfo->handle = handle;
	strcpy(smiinfo->name, "LynxEM ");
	smiinfo->chipset = ent->device;

	/* Set base addrs */
	DPRINT("lynxfb: lynxfb_pci_register: Set base addrs\r\n");
	smiinfo->fb_base_phys = smiinfo->mmio_base_phys = smiinfo->io_base_phys = 0xFFFFFFFF;
	smiinfo->bios_seg = NULL;
#ifdef PCI_XBIOS
	pci_rsc_desc = (PCI_RSC_DESC *)get_resource(handle);
#else
	bios_cookie = (PCI_COOKIE *)Funcs_get_cookie("_PCI",Super(1));
	if(bios_cookie == (void *)-1)   /* faster than XBIOS calls */
		return(-EIO);
	tab_funcs_pci = &bios_cookie->routine[0];
	pci_rsc_desc = (PCI_RSC_DESC *)Get_resource(handle);
#endif
	if((long)pci_rsc_desc >= 0)
	{
		unsigned short flags;
		do
		{
			DPRINTVALHEX("lynxfb: flags ", pci_rsc_desc->flags);
			DPRINTVALHEX(" start ", pci_rsc_desc->start);
			DPRINTVALHEX(" offset ", pci_rsc_desc->offset);
			DPRINTVALHEX(" length ", pci_rsc_desc->length);
			DPRINT("\r\n");
			if(!(pci_rsc_desc->flags & FLG_IO))
			{
				if((smiinfo->fb_base_phys == 0xFFFFFFFF) && (pci_rsc_desc->length >= 0x100000))
				{
					smiinfo->fb_base_phys = pci_rsc_desc->start;
					smiinfo->fb_base = (void *)(pci_rsc_desc->offset + pci_rsc_desc->start);
					fb_size = pci_rsc_desc->length;
					if((pci_rsc_desc->flags & FLG_ENDMASK) == ORD_MOTOROLA)
					{
						smiinfo->big_endian = 0; /* host bridge make swapping intel -> motorola */
						DPRINT("lynxfb: host bridge is big endian\r\n");
					}
					else
					{
						smiinfo->big_endian = 1; /* lynx make swapping intel -> motorola */
						DPRINT("lynxfb: host bridge is little endian\r\n");
					}
				}
				else if(pci_rsc_desc->length < 0x100000)
				{
					if(smiinfo->bios_seg == NULL)
					{
						smiinfo->bios_seg_phys = pci_rsc_desc->start;
						if(BIOSIN16(0) == 0xaa55)
							smiinfo->bios_seg = (void *)(pci_rsc_desc->offset + pci_rsc_desc->start);
						else
							smiinfo->bios_seg_phys = 0;
					}
				}
			}
			else
			{
				if(smiinfo->io_base_phys == 0xFFFFFFFF)
				{		
					smiinfo->io_base = (void *)(pci_rsc_desc->offset + pci_rsc_desc->start);
					smiinfo->io_base_phys = pci_rsc_desc->start;
				}
			}
			flags = pci_rsc_desc->flags;
			pci_rsc_desc = (PCI_RSC_DESC *)((unsigned long)pci_rsc_desc->next + (unsigned long)pci_rsc_desc);
		}
		while(!(flags & FLG_LAST));
	}
	else
		DPRINT("lynxfb: lynxfb_pci_register: get_resource error\r\n");
	DPRINT("lynxfb: lynxfb_pci_register: map the regions\r\n");
	if((smiinfo->io_base_phys == 0xFFFFFFFF) && (smiinfo->fb_base_phys == 0xFFFFFFFF))
	{
		DPRINT("lynxfb: cannot map ISA registers\r\n");
		framebuffer_release(info);
		return(-EIO);	
	}
	DPRINTVALHEX("lynxfb: lynxfb_pci_register: io_base_phys ", smiinfo->io_base_phys);
  DPRINTVALHEX(" io_base ", (unsigned long)smiinfo->io_base);
	DPRINT("\r\n");
	DPRINTVALHEX("lynxfb: lynxfb_pci_register: fb_base_phys ", smiinfo->fb_base_phys);
	DPRINTVALHEX(" fb_base ", (unsigned long)smiinfo->fb_base);
	DPRINT("\r\n");
	switch(smiinfo->chipset)
	{
		case SMI_LYNX3D:
	    smiinfo->dprBase = smiinfo->fb_base_phys + 0x680000 + 0x000000;
	    smiinfo->vprBase = smiinfo->fb_base_phys + 0x680000 + 0x000800;
	    smiinfo->cprBase = smiinfo->fb_base_phys + 0x680000 + 0x001000;
	    smiinfo->mmio_base_phys = smiinfo->fb_base_phys + 0x680000 + 0x040000;
	    smiinfo->DataPortBase = (unsigned char *)smiinfo->fb_base + 0x680000 + 0x080000;
	    smiinfo->DataPortSize = 0x100000;
//	    smiinfo->memSize = 0x180000;
	    break;
		case SMI_LYNXEM:
		case SMI_LYNXEMplus:
	    smiinfo->dprBase = smiinfo->fb_base_phys + 0x400000 + 0x008000;
	    smiinfo->vprBase = smiinfo->fb_base_phys + 0x400000 + 0x00C000;
	    smiinfo->cprBase = smiinfo->fb_base_phys + 0x400000 + 0x00E000;
	    smiinfo->mmio_base_phys = smiinfo->fb_base_phys + 0x400000 + 0x300000;
	    smiinfo->DataPortBase = (unsigned char *)smiinfo->fb_base + 0x400000;
	    smiinfo->DataPortSize = 0x8000;
//	    smiinfo->memSize = 0x400000;
	    break;
		case SMI_LYNX3DM:
	    smiinfo->dprBase = smiinfo->fb_base_phys + 0x400000 + 0x000000;
	    smiinfo->vprBase = smiinfo->fb_base_phys + 0x400000 + 0x000800;
	    smiinfo->cprBase = smiinfo->fb_base_phys + 0x400000 + 0x001000;
	    smiinfo->mmio_base_phys = smiinfo->fb_base_phys + 0x400000 + 0x0C0000;
	    smiinfo->DataPortBase = (unsigned char *)smiinfo->fb_base + 0x400000 + 0x100000;
	    smiinfo->DataPortSize = 0x100000;
//	    smiinfo->memSize = 0x200000;
			(char *)smiinfo->fb_base += 0x200000;
			smiinfo->fb_base_phys += 0x200000;
	    break;
		default:
	    smiinfo->dprBase = smiinfo->fb_base_phys + 0x400000 + 0x8000;
	    smiinfo->vprBase = smiinfo->fb_base_phys + 0x400000 + 0xC000;
	    smiinfo->cprBase = smiinfo->fb_base_phys + 0x400000 + 0xE000;
	    smiinfo->DataPortBase = (unsigned char *)smiinfo->fb_base + 0x400000;
	    smiinfo->DataPortSize = 0x8000;
//	    smiinfo->memSize = 0x10000;
	    break;
	}
	DPRINTVALHEX("lynxfb: lynxfb_pci_register: mmio_base_phys ", smiinfo->mmio_base_phys);
	DPRINT("\r\n");
	VGAOUT8(smiinfo, VGA_SEQ_INDEX, 0x71);
	config = VGAIN8(smiinfo, VGA_SEQ_DATA);
	switch(smiinfo->chipset)
	{
		case SMI_LYNX3D: smiinfo->memSize = lynx3d_table[config >> 6] * 1024 + 512; break;
		case SMI_LYNXEMplus:
			if(fb_size < mem_max)
				mem_max = fb_size;
			while(mem_probe <= mem_max)
			{
				MMIO_OUT32(smiinfo->fb_base_phys, mem_probe-4, 0x55555555);
				if(MMIO_IN32(smiinfo->fb_base_phys, mem_probe-4) != 0x55555555)
	    		break;
				MMIO_OUT32(smiinfo->fb_base_phys, mem_probe-4, 0xAAAAAAAA);
				if(MMIO_IN32(smiinfo->fb_base_phys, mem_probe-4) != 0xAAAAAAAA)
					break;
				mem_probe <<= 1;
			}
			smiinfo->memSize = (mem_probe >> 1) / 1024;
			break;		
		case SMI_LYNX3DM: smiinfo->memSize = lynx3dm_table[config >> 6] * 1024; break;
		default: smiinfo->memSize = default_table[config >> 6] * 1024; break;
	}
	smiinfo->memSize *= 1024;
	info->ram_base = info->screen_base = smiinfo->fb_base;
	info->screen_size = smiinfo->memSize;
	info->ram_size = smiinfo->memSize;
	if(info->screen_size > MIN_MAPPED_VRAM)
		info->screen_size = MIN_MAPPED_VRAM;
	DPRINTVALHEX("lynxfb: lynxfb_pci_register: memSize ", smiinfo->memSize);
	DPRINT("\r\n");
	/* Enable linear mode */
	VGAOUT8(smiinfo, VGA_SEQ_INDEX, 0x18);
	tmp = VGAIN8(smiinfo, VGA_SEQ_DATA);
	VGAOUT8(smiinfo, VGA_SEQ_DATA, tmp | 0x11);
	/* Enable 2D/3D Engine and Video Processor */
	VGAOUT8(smiinfo, VGA_SEQ_INDEX, 0x21);
	tmp = VGAIN8(smiinfo, VGA_SEQ_DATA);
	VGAOUT8(smiinfo, VGA_SEQ_DATA, tmp & ~0x03);
	/* Register I2C bus */
	DPRINT("lynxfb: lynxfb_pci_register: register I2C bus\r\n");
	lynx_create_i2c_busses(smiinfo);
	/* set offscreen memory descriptor */
	DPRINT("lynxfb: lynxfb_pci_register: set offscreen memory descriptor\r\n");
	offscreen_init(info);
	/* Probe screen types */
	DPRINT("lynxfb: lynxfb_pci_register: monitor_layout: ");
	DPRINT(monitor_layout);
	DPRINT("\r\n");
	lynx_probe_screens(smiinfo, monitor_layout, (int)ignore_edid);
	/* Build mode list, check out panel native model */
	DPRINT("lynxfb: lynxfb_pci_register: build mode list\r\n");
	lynx_check_modes(smiinfo, &resolution);
	return(0);
}

#if 0

void lynxfb_pci_unregister(void)
{
	struct fb_info *info = info_fvdi;
	lynx_delete_i2c_busses(info->par);
	framebuffer_release(info);
}

#endif

#endif /* CONFIG_VIDEO_SMI_LYNXEM */
