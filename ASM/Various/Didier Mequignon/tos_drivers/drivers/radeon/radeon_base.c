/*
 *	radeon_base.c
 *
 *	framebuffer driver for ATI Radeon chipset video boards
 *
 *	Copyright 2003	Ben. Herrenschmidt <benh@kernel.crashing.org>
 *	Copyright 2000	Ani Joshi <ajoshi@kernel.crashing.org>
 *
 *	i2c bits from Luca Tettamanti <kronos@kronoz.cjb.net>
 *	
 *	Special thanks to ATI DevRel team for their hardware donations.
 *
 *	...Insert GPL boilerplate here...
 *
 *	Significant portions of this driver apdated from XFree86 Radeon
 *	driver which has the following copyright notice:
 *
 *	Copyright 2000 ATI Technologies Inc., Markham, Ontario, and
 *                     VA Linux Systems Inc., Fremont, California.
 *
 *	All Rights Reserved.
 *
 *	Permission is hereby granted, free of charge, to any person obtaining
 *	a copy of this software and associated documentation files (the
 *	"Software"), to deal in the Software without restriction, including
 *	without limitation on the rights to use, copy, modify, merge,
 *	publish, distribute, sublicense, and/or sell copies of the Software,
 *	and to permit persons to whom the Software is furnished to do so,
 *	subject to the following conditions:
 *
 *	The above copyright notice and this permission notice (including the
 *	next paragraph) shall be included in all copies or substantial
 *	portions of the Software.
 *
 *	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * 	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 *	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 *	NON-INFRINGEMENT.  IN NO EVENT SHALL ATI, VA LINUX SYSTEMS AND/OR
 *	THEIR SUPPLIERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 *	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 *	DEALINGS IN THE SOFTWARE.
 *
 *	XFree86 driver authors:
 *
 *	   Kevin E. Martin <martin@xfree86.org>
 *	   Rickard E. Faith <faith@valinux.com>
 *	   Alan Hourihane <alanh@fairlite.demon.co.uk>
 *
 */

#define RADEON_VERSION "0.2.0"

#include <mint/errno.h>
#include "fb.h"
#include "i2c.h"
#include "radeonfb.h"
#include "edid.h"
#include "ati_ids.h"

#ifdef DRIVER_IN_ROM
extern void run_bios(struct radeonfb_info *rinfo);
#endif
extern void mdelay(long msec);
extern void udelay(long usec);

#define MAX_MAPPED_VRAM	(2048*2048*4)
#define MIN_MAPPED_VRAM	(1024*768*4)

#define CHIP_DEF(id, family, flags)					\
	{ PCI_VENDOR_ID_ATI, id, PCI_ANY_ID, PCI_ANY_ID, 0, 0, (flags) | (CHIP_FAMILY_##family) }

struct pci_device_id radeonfb_pci_table[] = {
	/* Mobility M6 */
	CHIP_DEF(PCI_CHIP_RADEON_LY, 	RV100,	CHIP_HAS_CRTC2 | CHIP_IS_MOBILITY),
	CHIP_DEF(PCI_CHIP_RADEON_LZ,	RV100,	CHIP_HAS_CRTC2 | CHIP_IS_MOBILITY),
	/* Radeon VE/7000 */
	CHIP_DEF(PCI_CHIP_RV100_QY, 	RV100,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_RV100_QZ, 	RV100,	CHIP_HAS_CRTC2),
	/* Radeon IGP320M (U1) */
	CHIP_DEF(PCI_CHIP_RS100_4336,	RS100,	CHIP_HAS_CRTC2 | CHIP_IS_IGP | CHIP_IS_MOBILITY),
	/* Radeon IGP320 (A3) */
	CHIP_DEF(PCI_CHIP_RS100_4136,	RS100,	CHIP_HAS_CRTC2 | CHIP_IS_IGP), 
	/* IGP330M/340M/350M (U2) */
	CHIP_DEF(PCI_CHIP_RS200_4337,	RS200,	CHIP_HAS_CRTC2 | CHIP_IS_IGP | CHIP_IS_MOBILITY),
	/* IGP330/340/350 (A4) */
	CHIP_DEF(PCI_CHIP_RS200_4137,	RS200,	CHIP_HAS_CRTC2 | CHIP_IS_IGP),
	/* Mobility 7000 IGP */
	CHIP_DEF(PCI_CHIP_RS250_4437,	RS200,	CHIP_HAS_CRTC2 | CHIP_IS_IGP | CHIP_IS_MOBILITY),
	/* 7000 IGP (A4+) */
	CHIP_DEF(PCI_CHIP_RS250_4237,	RS200,	CHIP_HAS_CRTC2 | CHIP_IS_IGP),
	/* 8500 AIW */
	CHIP_DEF(PCI_CHIP_R200_BB,	R200,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_R200_BC,	R200,	CHIP_HAS_CRTC2),
	/* 8700/8800 */
	CHIP_DEF(PCI_CHIP_R200_QH,	R200,	CHIP_HAS_CRTC2),
	/* 8500 */
	CHIP_DEF(PCI_CHIP_R200_QL,	R200,	CHIP_HAS_CRTC2),
	/* 9100 */
	CHIP_DEF(PCI_CHIP_R200_QM,	R200,	CHIP_HAS_CRTC2),
	/* Mobility M7 */
	CHIP_DEF(PCI_CHIP_RADEON_LW,	RV200,	CHIP_HAS_CRTC2 | CHIP_IS_MOBILITY),
	CHIP_DEF(PCI_CHIP_RADEON_LX,	RV200,	CHIP_HAS_CRTC2 | CHIP_IS_MOBILITY),
	/* 7500 */
	CHIP_DEF(PCI_CHIP_RV200_QW,	RV200,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_RV200_QX,	RV200,	CHIP_HAS_CRTC2),
	/* Mobility M9 */
	CHIP_DEF(PCI_CHIP_RV250_Ld,	RV250,	CHIP_HAS_CRTC2 | CHIP_IS_MOBILITY),
	CHIP_DEF(PCI_CHIP_RV250_Le,	RV250,	CHIP_HAS_CRTC2 | CHIP_IS_MOBILITY),
	CHIP_DEF(PCI_CHIP_RV250_Lf,	RV250,	CHIP_HAS_CRTC2 | CHIP_IS_MOBILITY),
	CHIP_DEF(PCI_CHIP_RV250_Lg,	RV250,	CHIP_HAS_CRTC2 | CHIP_IS_MOBILITY),
	/* 9000/Pro */
	CHIP_DEF(PCI_CHIP_RV250_If,	RV250,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_RV250_Ig,	RV250,	CHIP_HAS_CRTC2),
	/* Mobility 9100 IGP (U3) */
	CHIP_DEF(PCI_CHIP_RS300_5835,	RS300,	CHIP_HAS_CRTC2 | CHIP_IS_IGP | CHIP_IS_MOBILITY),
	CHIP_DEF(PCI_CHIP_RS350_7835,	RS300,	CHIP_HAS_CRTC2 | CHIP_IS_IGP | CHIP_IS_MOBILITY),
	/* 9100 IGP (A5) */
	CHIP_DEF(PCI_CHIP_RS300_5834,	RS300,	CHIP_HAS_CRTC2 | CHIP_IS_IGP),
	CHIP_DEF(PCI_CHIP_RS350_7834,	RS300,	CHIP_HAS_CRTC2 | CHIP_IS_IGP),
	/* Mobility 9200 (M9+) */
	CHIP_DEF(PCI_CHIP_RV280_5C61,	RV280,	CHIP_HAS_CRTC2 | CHIP_IS_MOBILITY),
	CHIP_DEF(PCI_CHIP_RV280_5C63,	RV280,	CHIP_HAS_CRTC2 | CHIP_IS_MOBILITY),
	/* 9200 */
	CHIP_DEF(PCI_CHIP_RV280_5960,	RV280,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_RV280_5961,	RV280,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_RV280_5962,	RV280,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_RV280_5964,	RV280,	CHIP_HAS_CRTC2),
	/* 9500 */
	CHIP_DEF(PCI_CHIP_R300_AD,	R300,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_R300_AE,	R300,	CHIP_HAS_CRTC2),
	/* 9600TX / FireGL Z1 */
	CHIP_DEF(PCI_CHIP_R300_AF,	R300,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_R300_AG,	R300,	CHIP_HAS_CRTC2),
	/* 9700/9500/Pro/FireGL X1 */
	CHIP_DEF(PCI_CHIP_R300_ND,	R300,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_R300_NE,	R300,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_R300_NF,	R300,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_R300_NG,	R300,	CHIP_HAS_CRTC2),
	/* Mobility M10/M11 */
	CHIP_DEF(PCI_CHIP_RV350_NP,	RV350,	CHIP_HAS_CRTC2 | CHIP_IS_MOBILITY),
	CHIP_DEF(PCI_CHIP_RV350_NQ,	RV350,	CHIP_HAS_CRTC2 | CHIP_IS_MOBILITY),
	CHIP_DEF(PCI_CHIP_RV350_NR,	RV350,	CHIP_HAS_CRTC2 | CHIP_IS_MOBILITY),
	CHIP_DEF(PCI_CHIP_RV350_NS,	RV350,	CHIP_HAS_CRTC2 | CHIP_IS_MOBILITY),
	CHIP_DEF(PCI_CHIP_RV350_NT,	RV350,	CHIP_HAS_CRTC2 | CHIP_IS_MOBILITY),
	CHIP_DEF(PCI_CHIP_RV350_NV,	RV350,	CHIP_HAS_CRTC2 | CHIP_IS_MOBILITY),
	/* 9600/FireGL T2 */
	CHIP_DEF(PCI_CHIP_RV350_AP,	RV350,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_RV350_AQ,	RV350,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_RV360_AR,	RV350,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_RV350_AS,	RV350,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_RV350_AT,	RV350,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_RV350_AV,	RV350,	CHIP_HAS_CRTC2),
	/* 9800/Pro/FileGL X2 */
	CHIP_DEF(PCI_CHIP_R350_AH,	R350,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_R350_AI,	R350,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_R350_AJ,	R350,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_R350_AK,	R350,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_R350_NH,	R350,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_R350_NI,	R350,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_R360_NJ,	R350,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_R350_NK,	R350,	CHIP_HAS_CRTC2),
	/* Newer stuff */
	CHIP_DEF(PCI_CHIP_RV380_3E50,	RV380,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_RV380_3E54,	RV380,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_RV380_3150,	RV380,	CHIP_HAS_CRTC2 | CHIP_IS_MOBILITY),
	CHIP_DEF(PCI_CHIP_RV380_3154,	RV380,	CHIP_HAS_CRTC2 | CHIP_IS_MOBILITY),
	CHIP_DEF(PCI_CHIP_RV370_5B60,	RV380,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_RV370_5B62,	RV380,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_RV370_5B64,	RV380,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_RV370_5B65,	RV380,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_RV370_5460,	RV380,	CHIP_HAS_CRTC2 | CHIP_IS_MOBILITY),
	CHIP_DEF(PCI_CHIP_RV370_5464,	RV380,	CHIP_HAS_CRTC2 | CHIP_IS_MOBILITY),
	CHIP_DEF(PCI_CHIP_R420_JH,	R420,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_R420_JI,	R420,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_R420_JJ,	R420,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_R420_JK,	R420,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_R420_JL,	R420,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_R420_JM,	R420,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_R420_JN,	R420,	CHIP_HAS_CRTC2 | CHIP_IS_MOBILITY),
	CHIP_DEF(PCI_CHIP_R420_JP,	R420,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_R423_UH,	R420,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_R423_UI,	R420,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_R423_UJ,	R420,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_R423_UK,	R420,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_R423_UQ,	R420,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_R423_UR,	R420,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_R423_UT,	R420,	CHIP_HAS_CRTC2),
	CHIP_DEF(PCI_CHIP_R423_5D57,	R420,	CHIP_HAS_CRTC2),
	/* Original Radeon/7200 */
	CHIP_DEF(PCI_CHIP_RADEON_QD,	RADEON,	0),
	CHIP_DEF(PCI_CHIP_RADEON_QE,	RADEON,	0),
	CHIP_DEF(PCI_CHIP_RADEON_QF,	RADEON,	0),
	CHIP_DEF(PCI_CHIP_RADEON_QG,	RADEON,	0),
	{ 0, 0, 0, 0, 0, 0, 0 }
};


typedef struct {
	unsigned short reg;
	unsigned long val;
} reg_val;


/* these common regs are cleared before mode setting so they do not
 * interfere with anything
 */
static reg_val common_regs[] = {
	{ OVR_CLR, 0 },	
	{ OVR_WID_LEFT_RIGHT, 0 },
	{ OVR_WID_TOP_BOTTOM, 0 },
	{ OV0_SCALE_CNTL, 0 },
	{ SUBPIC_CNTL, 0 },
	{ VIPH_CONTROL, 0 },
	{ I2C_CNTL_1, 0 },
	{ GEN_INT_CNTL, 0 },
	{ CAP0_TRIG_CNTL, 0 },
	{ CAP1_TRIG_CNTL, 0 },
};

#define rinfo ((struct radeonfb_info *)info_fvdi->par)

static unsigned long inreg(unsigned long addr)
{
	return(INREG(addr));
}

static void outreg(unsigned long addr, unsigned long val)
{
	OUTREG(addr,val);
}

#undef rinfo
#undef INREG
#define INREG inreg
#undef OUTREG
#define OUTREG outreg

void _OUTREGP(struct radeonfb_info *rinfo, unsigned long addr, unsigned long val, unsigned long mask)
{
	unsigned int tmp;
	tmp = INREG(addr);
	tmp &= (mask);
	tmp |= (val);
	OUTREG(addr, tmp);
}

/*
 * Note about PLL register accesses:
 *
 * I have removed the spinlock on them on purpose. The driver now
 * expects that it will only manipulate the PLL registers in normal
 * task environment, where radeon_msleep() will be called, protected
 * by a semaphore (currently the console semaphore) so that no conflict
 * will happen on the PLL register index.
 *
 * With the latest changes to the VT layer, this is guaranteed for all
 * calls except the actual drawing/blits which aren't supposed to use
 * the PLL registers anyway
 *
 * This is very important for the workarounds to work properly. The only
 * possible exception to this rule is the call to unblank(), which may
 * be done at irq time if an oops is in progress.
 */
void radeon_pll_errata_after_index(struct radeonfb_info *rinfo)
{
	if(!(rinfo->errata & CHIP_ERRATA_PLL_DUMMYREADS))
		return;
	(void)INREG(CLOCK_CNTL_DATA);
	(void)INREG(CRTC_GEN_CNTL);
}

void radeon_pll_errata_after_data(struct radeonfb_info *rinfo)
{
	if(rinfo->errata & CHIP_ERRATA_PLL_DELAY)
	{
		/* we can't deal with posted writes here ... */
		radeon_msleep(5);
	}
	if(rinfo->errata & CHIP_ERRATA_R300_CG)
	{
		unsigned long save, tmp;
		save = INREG(CLOCK_CNTL_INDEX);
		tmp = save & ~(0x3f | PLL_WR_EN);
		OUTREG(CLOCK_CNTL_INDEX, tmp);
		tmp = INREG(CLOCK_CNTL_DATA);
		OUTREG(CLOCK_CNTL_INDEX, save);
	}
}

unsigned long __INPLL(struct radeonfb_info *rinfo, unsigned long addr)
{
	unsigned long data;
	OUTREG8(CLOCK_CNTL_INDEX, addr & 0x0000003f);
	radeon_pll_errata_after_index(rinfo);
	data = INREG(CLOCK_CNTL_DATA);
	radeon_pll_errata_after_data(rinfo);
	return data;
}

void __OUTPLL(struct radeonfb_info *rinfo, unsigned int index, unsigned long val)
{
	OUTREG8(CLOCK_CNTL_INDEX, (index & 0x0000003f) | 0x00000080);
	radeon_pll_errata_after_index(rinfo);
	OUTREG(CLOCK_CNTL_DATA, val);
	radeon_pll_errata_after_data(rinfo);
}

void __OUTPLLP(struct radeonfb_info *rinfo, unsigned int index, unsigned long val, unsigned long mask)
{
	unsigned int tmp;
	tmp  = __INPLL(rinfo, index);
	tmp &= (mask);
	tmp |= (val);
	__OUTPLL(rinfo, index, tmp);
}

static int round_div(int num, int den)
{
	return(num + (den / 2)) / den;
}

#ifndef MCF5445X
static unsigned long read_vline_crnt(struct radeonfb_info *rinfo)
{
	return((INREG(CRTC_VLINE_CRNT_VLINE) >> 16) & 0x3FF);
}
#endif

static int radeon_map_ROM(struct radeonfb_info *rinfo)
{
	unsigned short dptr;
	unsigned char rom_type;
	/* If this is a primary card, there is a shadow copy of the
	 * ROM somewhere in the first meg. We will just ignore the copy
	 * and use the ROM directly.
	 */
 	/* Fix from ATI for problem with Radeon hardware not leaving ROM enabled */
	unsigned int temp;
	temp = INREG(MPP_TB_CONFIG);
	temp &= 0x00ffffffu;
	temp |= 0x04 << 24;
	OUTREG(MPP_TB_CONFIG, temp);
	temp = INREG(MPP_TB_CONFIG);                                                                                                    
	if(rinfo->bios_seg == NULL)
	{
		DPRINT("radeonfb: ROM failed to map\r\n");
		return -ENOMEM;
	}
	/* Very simple test to make sure it appeared */
	if(BIOS_IN16(0) != 0xaa55)
	{
		DPRINT("radeonfb: Invalid ROM signature");
		goto failed;
	}
	/* Look for the PCI data to check the ROM type */
	dptr = BIOS_IN16(0x18);
	/* Check the PCI data signature. If it's wrong, we still assume a normal x86 ROM
	 * for now, until I've verified this works everywhere. The goal here is more
	 * to phase out Open Firmware images.
	 *
	 * Currently, we only look at the first PCI data, we could iteratre and deal with
	 * them all, and we should use fb_bios_start relative to start of image and not
	 * relative start of ROM, but so far, I never found a dual-image ATI card
	 *
	 * typedef struct {
	 * 	u32	signature;	+ 0x00
	 * 	u16	vendor;		+ 0x04
	 * 	u16	device;		+ 0x06
	 * 	u16	reserved_1;	+ 0x08
	 * 	u16	dlen;		+ 0x0a
	 * 	u8	drevision;	+ 0x0c
	 * 	u8	class_hi;	+ 0x0d
	 * 	u16	class_lo;	+ 0x0e
	 * 	u16	ilen;		+ 0x10
	 * 	u16	irevision;	+ 0x12
	 * 	u8	type;		+ 0x14
	 * 	u8	indicator;	+ 0x15
	 * 	u16	reserved_2;	+ 0x16
	 * } pci_data_t;
	 */
	if(BIOS_IN32(dptr) !=  (('R' << 24) | ('I' << 16) | ('C' << 8) | 'P'))
	{
		DPRINTVALHEX("radeonfb: PCI DATA signature in ROM incorrect: ", BIOS_IN32(dptr));
		DPRINT("\r\n");
		goto anyway;
	}
	rom_type = BIOS_IN8(dptr + 0x14);
	switch(rom_type)
	{
	case 0:
		DPRINT("radeonfb: Found Intel x86 BIOS ROM Image\r\n");
		break;
	case 1:
		DPRINT("radeonfb: Found Open Firmware ROM Image\r\n");
		goto failed;
	case 2:
		DPRINT("radeonfb: Found HP PA-RISC ROM Image\r\n");
		goto failed;
	default:
		DPRINTVAL("radeonfb: Found unknown type ", rom_type);
		DPRINT(" ROM Image\r\n");
		goto failed;
	}
anyway:
	/* Locate the flat panel infos, do some sanity checking !!! */
	rinfo->fp_bios_start = BIOS_IN16(0x48);
//	DPRINTVALHEX("radeonfb: BIOS start offset: ", BIOS_IN16(0x48));
//	DPRINT("\r\n");
#ifdef DRIVER_IN_ROM // problem if BIOS ROM is invalid after run_bios()
	/* Save BIOS PLL informations */
	{
		unsigned short pll_info_block = BIOS_IN16(rinfo->fp_bios_start + 0x30);
//		DPRINTVALHEX("radeonfb: BIOS PLL info block offset: ", BIOS_IN16(rinfo->fp_bios_start + 0x30));
//		DPRINT("\r\n");
		rinfo->bios_pll.sclk		= BIOS_IN16(pll_info_block + 0x08);
		rinfo->bios_pll.mclk		= BIOS_IN16(pll_info_block + 0x0a);
		rinfo->bios_pll.ref_clk	= BIOS_IN16(pll_info_block + 0x0e);
		rinfo->bios_pll.ref_div	= BIOS_IN16(pll_info_block + 0x10);
		rinfo->bios_pll.ppll_min	= BIOS_IN32(pll_info_block + 0x12);
		rinfo->bios_pll.ppll_max	= BIOS_IN32(pll_info_block + 0x16);
	}
#endif
	return 0;
failed:
	rinfo->bios_seg = NULL;
	return -ENXIO;
}

/*
 * Read PLL infos from chip registers
 */
static int radeon_probe_pll_params(struct radeonfb_info *rinfo)
{
#ifdef MCF5445X /* MCF5445X has mo FPU */
	if(rinfo);
	return(-1); /* to do ... */
#else /* MCF548X or ATARI */
	unsigned char ppll_div_sel;
	unsigned Ns, Nm, M;
	unsigned sclk, mclk, tmp, ref_div;
	int hTotal, vTotal, num, denom, m, n;
	double hz, vclk;
	long xtal;
	unsigned long start_tv, stop_tv;
	int timeout=0;
	/* Ugh, we cut interrupts, bad bad bad, but we want some precision
	 * here, so... --BenH
	 */
	DPRINT("radeonfb: radeon_probe_pll_params\r\n");
	/* Flush PCI buffers ? */
	tmp = INREG16(DEVICE_ID);
#ifdef COLDFIRE
	asm volatile (
		" move.l D0,-(SP)\n\t"
		" move.w SR,D0\n\t"
		" move.w D0,save_d0\n\t"
		" or.l #0x700,D0\n\t"   /* disable interrupts */
		" move.w D0,SR\n\t"
		" move.l (SP)+,D0\n\t" );
#else
	asm volatile (
		" move.w SR,save_d0\n\t"
		" or.w #0x700,SR\n\t" );   /* disable interrupts */
#endif
	start_tv = get_timer();
	while(read_vline_crnt(rinfo) != 0)
	{
		if((get_timer() - start_tv) > US_TO_TIMER(10000000UL))    /* 10 sec */
		{
			timeout=1;
			break;
		}
	}
	if(!timeout)
	{
		start_tv = get_timer();
		while(read_vline_crnt(rinfo) == 0)
		{
			if((get_timer() - start_tv) > US_TO_TIMER(1000000UL))   /* 1 sec */
			{
				timeout=1;
				break;
			}
		}
		if(!timeout)
		{
			while(read_vline_crnt(rinfo) != 0)
			{
				if((get_timer() - start_tv) > US_TO_TIMER(10000000UL))    /* 10 sec */
				{
					timeout=1;
					break;
				}
			}
		}
	}
	stop_tv = get_timer();
#ifdef COLDFIRE
	asm volatile (
		" move.w D0,-(SP)\n\t"
		" move.w save_d0,D0\n\t"
		" move.w D0,SR\n\t"
		" move.w (SP)+,D0\n\t" );
	if(timeout)  /* 10 sec */
		return -1; /* error */
#else
	asm volatile (
		"move.w save_d0,SR\n\t" );
	if(timeout)  /* 10 sec */
		return -1; /* error */
#endif
	hz = US_TO_TIMER(1000000.0) / (double)(stop_tv - start_tv);
  DPRINTVAL("radeonfb: radeon_probe_pll_params hz ", (long)hz);
	hTotal = ((INREG(CRTC_H_TOTAL_DISP) & 0x1ff) + 1) * 8;
	vTotal = ((INREG(CRTC_V_TOTAL_DISP) & 0x3ff) + 1);
	DPRINTVAL(" hTotal ",hTotal);
	DPRINTVAL(" vTotal ",vTotal);
  vclk = (double)hTotal * (double)vTotal * hz;
  DPRINTVAL(" vclk ", (long)vclk);
	DPRINT("\r\n");
	switch((INPLL(PPLL_REF_DIV) & 0x30000) >> 16)
	{
		case 1:
			n = ((INPLL(M_SPLL_REF_FB_DIV) >> 16) & 0xff);
			m = (INPLL(M_SPLL_REF_FB_DIV) & 0xff);
			num = 2*n;
			denom = 2*m;
			break;
		case 2:
			n = ((INPLL(M_SPLL_REF_FB_DIV) >> 8) & 0xff);
			m = (INPLL(M_SPLL_REF_FB_DIV) & 0xff);
			num = 2*n;
			denom = 2*m;
			break;
		case 0:
		default:
			num = 1;
			denom = 1;
			break;
	}
	ppll_div_sel = INREG8(CLOCK_CNTL_INDEX + 1) & 0x3;
	radeon_pll_errata_after_index(rinfo);
	n = (INPLL(PPLL_DIV_0 + ppll_div_sel) & 0x7ff);
	m = (INPLL(PPLL_REF_DIV) & 0x3ff);
	num *= n;
	denom *= m;
	switch((INPLL(PPLL_DIV_0 + ppll_div_sel) >> 16) & 0x7)
	{
		case 1:
			denom *= 2;
			break;
		case 2:
			denom *= 4;
			break;
		case 3:
			denom *= 8;
			break;
		case 4:
			denom *= 3;
			break;
		case 6:
			denom *= 6;   
			break;
		case 7:
			denom *= 12;
			break;
	}
	vclk *= (double)denom;
	vclk /= (double)(1000 * num);
	xtal = (long)vclk;
	if((xtal > 26900) && (xtal < 27100))
		xtal = 2700;   /* 27 MHz */
	else if((xtal > 14200) && (xtal < 14400))
		xtal = 1432;
	else if((xtal > 29400) && (xtal < 29600))
		xtal = 2950;
	else
	{
		DPRINTVAL("radeonfb: xtal calculation failed: ",xtal);
		DPRINT("\r\n");
		return -1; /* error */
	}
	tmp = INPLL(M_SPLL_REF_FB_DIV);
	ref_div = INPLL(PPLL_REF_DIV) & 0x3ff;
	Ns = (tmp & 0xff0000) >> 16;
	Nm = (tmp & 0xff00) >> 8;
	M = (tmp & 0xff);
	sclk = round_div((2 * Ns * xtal), (2 * M));
	mclk = round_div((2 * Nm * xtal), (2 * M));
	/* we're done, hopefully these are sane values */
	rinfo->pll.ref_clk = xtal;
	rinfo->pll.ref_div = ref_div;
	rinfo->pll.sclk = sclk;
	rinfo->pll.mclk = mclk;
	return 0;
#endif /* MCF5445X */
}

/*
 * Retreive PLL infos by register probing...
 */
static void radeon_get_pllinfo(struct radeonfb_info *rinfo)
{
	/*
	 * In the case nothing works, these are defaults; they are mostly
	 * incomplete, however.  It does provide ppll_max and _min values
	 * even for most other methods, however.
	 */
	DPRINT("radeonfb: radeon_get_pllinfo\r\n");
	switch(rinfo->chipset)
	{
		case PCI_DEVICE_ID_ATI_RADEON_QW:
		case PCI_DEVICE_ID_ATI_RADEON_QX:
			rinfo->pll.ppll_max = 35000;
			rinfo->pll.ppll_min = 12000;
			rinfo->pll.mclk = 23000;
			rinfo->pll.sclk = 23000;
			rinfo->pll.ref_clk = 2700;
			break;
		case PCI_DEVICE_ID_ATI_RADEON_QL:
		case PCI_DEVICE_ID_ATI_RADEON_QN:
		case PCI_DEVICE_ID_ATI_RADEON_QO:
		case PCI_DEVICE_ID_ATI_RADEON_Ql:
		case PCI_DEVICE_ID_ATI_RADEON_BB:
			rinfo->pll.ppll_max = 35000;
			rinfo->pll.ppll_min = 12000;
			rinfo->pll.mclk = 27500;
			rinfo->pll.sclk = 27500;
			rinfo->pll.ref_clk = 2700;
			break;
		case PCI_DEVICE_ID_ATI_RADEON_Id:
		case PCI_DEVICE_ID_ATI_RADEON_Ie:
		case PCI_DEVICE_ID_ATI_RADEON_If:
		case PCI_DEVICE_ID_ATI_RADEON_Ig:
			rinfo->pll.ppll_max = 35000;
			rinfo->pll.ppll_min = 12000;
			rinfo->pll.mclk = 25000;
			rinfo->pll.sclk = 25000;
			rinfo->pll.ref_clk = 2700;
			break;
		case PCI_DEVICE_ID_ATI_RADEON_ND:
		case PCI_DEVICE_ID_ATI_RADEON_NE:
		case PCI_DEVICE_ID_ATI_RADEON_NF:
		case PCI_DEVICE_ID_ATI_RADEON_NG:
			rinfo->pll.ppll_max = 40000;
			rinfo->pll.ppll_min = 20000;
			rinfo->pll.mclk = 27000;
			rinfo->pll.sclk = 27000;
			rinfo->pll.ref_clk = 2700;
			break;
		case PCI_DEVICE_ID_ATI_RADEON_QD:
		case PCI_DEVICE_ID_ATI_RADEON_QE:
		case PCI_DEVICE_ID_ATI_RADEON_QF:
		case PCI_DEVICE_ID_ATI_RADEON_QG:
		default:
			rinfo->pll.ppll_max = 35000;
			rinfo->pll.ppll_min = 12000;
			rinfo->pll.mclk = 16600;
			rinfo->pll.sclk = 16600;
			rinfo->pll.ref_clk = 2700;
			break;
	}
	rinfo->pll.ref_div = INPLL(PPLL_REF_DIV) & PPLL_REF_DIV_MASK;
	/*
	 * Check out if we have an X86 which gave us some PLL informations
	 * and if yes, retreive them
	 */
	if(!force_measure_pll && (rinfo->bios_seg != NULL))
	{
#ifdef DRIVER_IN_ROM // problem if BIOS ROM is invalid after run_bios()
		rinfo->pll.sclk		= rinfo->bios_pll.sclk;
		rinfo->pll.mclk		= rinfo->bios_pll.mclk;
		rinfo->pll.ref_clk	= rinfo->bios_pll.ref_clk;
		rinfo->pll.ref_div	= rinfo->bios_pll.ref_div;
		rinfo->pll.ppll_min	= rinfo->bios_pll.ppll_min;
		rinfo->pll.ppll_max	= rinfo->bios_pll.ppll_max;
#else
		unsigned short pll_info_block = BIOS_IN16(rinfo->fp_bios_start + 0x30);
		rinfo->pll.sclk		= BIOS_IN16(pll_info_block + 0x08);
		rinfo->pll.mclk		= BIOS_IN16(pll_info_block + 0x0a);
		rinfo->pll.ref_clk	= BIOS_IN16(pll_info_block + 0x0e);
		rinfo->pll.ref_div	= BIOS_IN16(pll_info_block + 0x10);
		rinfo->pll.ppll_min	= BIOS_IN32(pll_info_block + 0x12);
		rinfo->pll.ppll_max	= BIOS_IN32(pll_info_block + 0x16);
#endif
		DPRINT("radeonfb: Retreived PLL infos from BIOS\r\n");
		goto found;
	}
	/*
	 * We didn't get PLL parameters from either OF or BIOS, we try to
	 * probe them
	 */
	if(radeon_probe_pll_params(rinfo) == 0)
	{
		DPRINT("radeonfb: Retreived PLL infos from registers\r\n");
		goto found;
	}
	/*
	 * Fall back to already-set defaults...
	 */
	DPRINT("radeonfb: Used default PLL infos\r\n");
found:
	/*
	 * Some methods fail to retreive SCLK and MCLK values, we apply default
	 * settings in this case (200Mhz). If that really happne often, we could
	 * fetch from registers instead...
	 */
	if(rinfo->pll.mclk == 0)
		rinfo->pll.mclk = 20000;
	if(rinfo->pll.sclk == 0)
		rinfo->pll.sclk = 20000;
	DPRINTVAL("radeonfb: Reference=",rinfo->pll.ref_clk / 100);
	DPRINTVAL(" MHz (RefDiv=",rinfo->pll.ref_div);
	DPRINTVAL(") Memory=",rinfo->pll.mclk / 100);
	DPRINTVAL(" Mhz, System=",rinfo->pll.sclk / 100);
	DPRINT(" MHz\r\n");
	DPRINTVAL("radeonfb: PLL min ",rinfo->pll.ppll_min);
	DPRINTVAL(" max ", rinfo->pll.ppll_max);
	DPRINT("\r\n");
}

static int var_to_depth(const struct fb_var_screeninfo *var)
{
	if(var->bits_per_pixel != 16)
		return var->bits_per_pixel;
	return(var->green.length == 5) ? 15 : 16;
}

int radeonfb_check_var(struct fb_var_screeninfo *var, struct fb_info *info)
{
	struct radeonfb_info *rinfo = info->par;
	struct fb_var_screeninfo v;
	int nom, den;
	unsigned int pitch;
//	DPRINT("radeonfb: radeonfb_check_var\r\n");
	/* clocks over 135 MHz have heat isues with DVI on RV100 */
	if((rinfo->mon1_type == MT_DFP) && (rinfo->family == CHIP_FAMILY_RV100) && ((100000000 / var->pixclock) > 13500))
	{
		DPRINTVAL("radeonfb: mode ",var->xres);
		DPRINTVAL("x",var->yres);
		DPRINTVAL("x",var->bits_per_pixel);
		DPRINT(" rejected, RV100 DVI clock over 135 MHz\r\n");
		return -EINVAL;
	}
	if(radeon_match_mode(rinfo, &v, var))
		return -EINVAL;
	switch(v.bits_per_pixel)
	{
		case 0 ... 8:
			v.bits_per_pixel = 8;
			break;
		case 9 ... 16:
			v.bits_per_pixel = 16;
			break;
#if 0 /* Doesn't seem to work */
		case 17 ... 24:
			v.bits_per_pixel = 24;
			break;
#endif			
		case 25 ... 32:
			v.bits_per_pixel = 32;
			break;
		default:
			return -EINVAL;
	}
	switch(var_to_depth(&v))
	{
		case 8:
			nom = den = 1;
			v.red.offset = v.green.offset = v.blue.offset = 0;
			v.red.length = v.green.length = v.blue.length = 8;
			v.transp.offset = v.transp.length = 0;
			break;
		case 15:
			nom = 2;
			den = 1;
			v.red.offset = 10;
			v.green.offset = 5;
			v.blue.offset = 0;
			v.red.length = v.green.length = v.blue.length = 5;
			v.transp.offset = v.transp.length = 0;
			break;
		case 16:
			nom = 2;
			den = 1;
			v.red.offset = 11;
			v.green.offset = 5;
			v.blue.offset = 0;
			v.red.length = 5;
			v.green.length = 6;
			v.blue.length = 5;
			v.transp.offset = v.transp.length = 0;
			break;                          
		case 24:
			nom = 4;
			den = 1;
			v.red.offset = 16;
			v.green.offset = 8;
			v.blue.offset = 0;
			v.red.length = v.blue.length = v.green.length = 8;
			v.transp.offset = v.transp.length = 0;
			break;
		case 32:
			nom = 4;
			den = 1;
			v.red.offset = 16;
			v.green.offset = 8;
			v.blue.offset = 0;
			v.red.length = v.blue.length = v.green.length = 8;
			v.transp.offset = 24;
			v.transp.length = 8;
			break;
    default:
			DPRINTVAL("radeonfb: mode ",var->xres);
			DPRINTVAL("x",var->yres);
			DPRINTVAL("x",var->bits_per_pixel);
			DPRINT(" rejected, color depth invalid\r\n");
			return -EINVAL;
	}
	if(v.yres_virtual < v.yres)
		v.yres_virtual = v.yres;
	if(v.xres_virtual < v.xres)
		v.xres_virtual = v.xres;
	/* XXX I'm adjusting xres_virtual to the pitch, that may help XFree
	 * with some panels, though I don't quite like this solution
	 */
	pitch = ((v.xres_virtual * ((v.bits_per_pixel + 1) / 8) + 0x3f) & ~(0x3f)) >> 6;
	v.xres_virtual = (pitch << 6) / ((v.bits_per_pixel + 1) / 8);
	if(((v.xres_virtual * v.yres_virtual * nom) / den) > info->screen_size)
		return -EINVAL;
	if(v.xres_virtual < v.xres)
		v.xres = v.xres_virtual;
	if(v.xoffset < 0)
		v.xoffset = 0;
	if(v.yoffset < 0)
		v.yoffset = 0;
	if(v.xoffset > v.xres_virtual - v.xres)
		v.xoffset = v.xres_virtual - v.xres - 1;
	if(v.yoffset > v.yres_virtual - v.yres)
		v.yoffset = v.yres_virtual - v.yres - 1;
	v.red.msb_right = v.green.msb_right = v.blue.msb_right = 0;
	v.transp.offset = v.transp.length = v.transp.msb_right = 0;
	memcpy(var, &v, sizeof(v));
	return 0;
}

int radeonfb_pan_display(struct fb_var_screeninfo *var, struct fb_info *info)
{
	struct radeonfb_info *rinfo = info->par;
//	DPRINT("radeonfb: radeonfb_pan_display\r\n");
	if((var->xoffset + var->xres) > var->xres_virtual)
		return -EINVAL;
	if(((var->yoffset * var->xres_virtual) + var->xoffset) >=
	 (rinfo->mapped_vram - (var->yres * var->xres * (var->bits_per_pixel / 8))))
		return -EINVAL;
	if(rinfo->asleep)
		return 0;
	radeon_fifo_wait(2);
	rinfo->fb_offset = ((var->yoffset * var->xres_virtual + var->xoffset) * var->bits_per_pixel / 8) & ~7;
	rinfo->dst_pitch_offset = (rinfo->pitch << 22) | ((rinfo->fb_local_base + rinfo->fb_offset) >> 10);
	OUTREG(CRTC_OFFSET, rinfo->fb_offset);
  return 0;
}

int radeonfb_ioctl(unsigned int cmd, unsigned long arg, struct fb_info *info)
{
	struct radeonfb_info *rinfo = info->par;
	unsigned int tmp;
	unsigned long value = 0;
	switch(cmd)
	{
		/*
		 * TODO:  set mirror accordingly for non-Mobility chipsets with 2 CRTC's
		 *        and do something better using 2nd CRTC instead of just hackish
		 *        routing to second output
		 */
		case FBIO_RADEON_SET_MIRROR:
			if(!rinfo->is_mobility)
				return -EINVAL;
			radeon_fifo_wait(2);
			if(value & 0x01)
			{
				tmp = INREG(LVDS_GEN_CNTL);
				tmp |= (LVDS_ON | LVDS_BLON);
			}
			else
			{
				tmp = INREG(LVDS_GEN_CNTL);
      	tmp &= ~(LVDS_ON | LVDS_BLON);
			}
			OUTREG(LVDS_GEN_CNTL, tmp);
			if(value & 0x02)
			{
				tmp = INREG(CRTC_EXT_CNTL);
				tmp |= CRTC_CRT_ON;
				mirror = 1;
			}
			else
			{
				tmp = INREG(CRTC_EXT_CNTL);
				tmp &= ~CRTC_CRT_ON;
				mirror = 0;
			}
			OUTREG(CRTC_EXT_CNTL, tmp);
			return 0;
		case FBIO_RADEON_GET_MIRROR:
			if(!rinfo->is_mobility)
				return -EINVAL;
			tmp = INREG(LVDS_GEN_CNTL);
			if((LVDS_ON | LVDS_BLON) & tmp)
				value |= 0x01;
			tmp = INREG(CRTC_EXT_CNTL);
			if(CRTC_CRT_ON & tmp)
				value |= 0x02;
			return 0;
		default:
			return -EINVAL;
	}
	return -EINVAL;
}

int radeon_screen_blank(struct radeonfb_info *rinfo, int blank, int mode_switch)
{
  unsigned long val;
	unsigned long tmp_pix_clks;
	int unblank = 0;
	if(rinfo->lock_blank)
		return 0;
	DPRINT("radeonfb: radeon_screen_blank\r\n");
	radeon_engine_idle();
	val = INREG(CRTC_EXT_CNTL);
	val &= ~(CRTC_DISPLAY_DIS | CRTC_HSYNC_DIS | CRTC_VSYNC_DIS);
	switch(blank)
	{
		case FB_BLANK_VSYNC_SUSPEND:
			val |= (CRTC_DISPLAY_DIS | CRTC_VSYNC_DIS);
			break;
		case FB_BLANK_HSYNC_SUSPEND:
			val |= (CRTC_DISPLAY_DIS | CRTC_HSYNC_DIS);
			break;
		case FB_BLANK_POWERDOWN:
			val |= (CRTC_DISPLAY_DIS | CRTC_VSYNC_DIS | CRTC_HSYNC_DIS);
			break;
		case FB_BLANK_NORMAL:
			val |= CRTC_DISPLAY_DIS;
			break;
		case FB_BLANK_UNBLANK:
		default:
			unblank = 1;
			break;
	}
	OUTREG(CRTC_EXT_CNTL, val);
	switch(rinfo->mon1_type)
	{
		case MT_DFP:
			if(unblank)
				OUTREGP(FP_GEN_CNTL, (FP_FPON | FP_TMDS_EN), ~(FP_FPON | FP_TMDS_EN));
			else
			{
				if(mode_switch || blank == FB_BLANK_NORMAL)
					break;
				OUTREGP(FP_GEN_CNTL, 0, ~(FP_FPON | FP_TMDS_EN));
			}
			break;
		case MT_LCD:
			rinfo->lvds_timer = 0;
			val = INREG(LVDS_GEN_CNTL);
			if(unblank)
			{
				unsigned long target_val = (val & ~LVDS_DISPLAY_DIS) | LVDS_BLON | LVDS_ON
				 | LVDS_EN | (rinfo->init_state.lvds_gen_cntl & (LVDS_DIGON | LVDS_BL_MOD_EN));
				if((val ^ target_val) == LVDS_DISPLAY_DIS)
					OUTREG(LVDS_GEN_CNTL, target_val);
				else if((val ^ target_val) != 0)
				{
					OUTREG(LVDS_GEN_CNTL, target_val & ~(LVDS_ON | LVDS_BL_MOD_EN));
					rinfo->init_state.lvds_gen_cntl &= ~LVDS_STATE_MASK;
					rinfo->init_state.lvds_gen_cntl |= target_val & LVDS_STATE_MASK;
					if(mode_switch)
					{
						radeon_msleep(rinfo->panel_info.pwr_delay);
						OUTREG(LVDS_GEN_CNTL, target_val);
					}
					else
					{
						rinfo->pending_lvds_gen_cntl = target_val;
						rinfo->lvds_timer = (long)rinfo->panel_info.pwr_delay;
					}
				}
			}
			else
			{
				val |= LVDS_DISPLAY_DIS;
				OUTREG(LVDS_GEN_CNTL, val);
				/* We don't do a full switch-off on a simple mode switch */
				if(mode_switch || blank == FB_BLANK_NORMAL)
					break;
				/* Asic bug, when turning off LVDS_ON, we have to make sure
				 * RADEON_PIXCLK_LVDS_ALWAYS_ON bit is off
				 */
				tmp_pix_clks = INPLL(PIXCLKS_CNTL);
				if(rinfo->is_mobility || rinfo->is_IGP)
					OUTPLLP(PIXCLKS_CNTL, 0, ~PIXCLK_LVDS_ALWAYS_ONb);
				val &= ~(LVDS_BL_MOD_EN);
				OUTREG(LVDS_GEN_CNTL, val);
				udelay(100);
				val &= ~(LVDS_ON | LVDS_EN);
				OUTREG(LVDS_GEN_CNTL, val);
				val &= ~LVDS_DIGON;
				rinfo->pending_lvds_gen_cntl = val;
				rinfo->lvds_timer = (long)rinfo->panel_info.pwr_delay;
				rinfo->init_state.lvds_gen_cntl &= ~LVDS_STATE_MASK;
				rinfo->init_state.lvds_gen_cntl |= val & LVDS_STATE_MASK;
				if(rinfo->is_mobility || rinfo->is_IGP)
					OUTPLL(PIXCLKS_CNTL, tmp_pix_clks);
			}
			break;
		case MT_CRT:
			// todo: powerdown DAC
		default:
			break;
	}
	/* let fbcon do a soft blank for us */
	return(blank == FB_BLANK_NORMAL) ? -EINVAL : 0;
}

int radeonfb_blank(int blank, struct fb_info *info)
{
	struct radeonfb_info *rinfo = info->par;
	if(rinfo->asleep)
		return 0;
	return radeon_screen_blank(rinfo, blank, 0);
}

static int radeon_setcolreg(unsigned regno, unsigned red, unsigned green,
                            unsigned blue, unsigned transp, struct radeonfb_info *rinfo)
{
	unsigned long pindex;
	if(regno > 255)
		return 1;
	red >>= 8;
	green >>= 8;
	blue >>= 8;
	rinfo->palette[regno].red = red;
	rinfo->palette[regno].green = green;
	rinfo->palette[regno].blue = blue;
	/* default */
	pindex = regno;
	if(!rinfo->asleep)
	{
		radeon_fifo_wait(9);
		if(rinfo->bpp == 16)
		{
			pindex = regno * 8;
			if(rinfo->depth == 16 && regno > 63)
				return 1;
			if(rinfo->depth == 15 && regno > 31)
				return 1;
			/* For 565, the green component is mixed one order
			 * below
			 */
			if(rinfo->depth == 16)
			{
				OUTREG(PALETTE_INDEX, pindex>>1);
				OUTREG(PALETTE_DATA,(rinfo->palette[regno>>1].red << 16)
				 | (green << 8) | (rinfo->palette[regno>>1].blue));
				green = rinfo->palette[regno<<1].green;
			}
		}
		if(rinfo->depth != 16 || regno < 32)
		{
			OUTREG(PALETTE_INDEX, pindex);
			OUTREG(PALETTE_DATA, (red << 16) | (green << 8) | blue);
		}
	}
	return 0;
}

int radeonfb_setcolreg(unsigned regno, unsigned red, unsigned green,
    unsigned blue, unsigned transp, struct fb_info *info)
{
	struct radeonfb_info *rinfo = info->par;
	unsigned long dac_cntl2, vclk_cntl = 0;
	int rc;
	if(!rinfo->asleep)
	{
		if(rinfo->is_mobility)
		{
			vclk_cntl = INPLL(VCLK_ECP_CNTL);
			OUTPLL(VCLK_ECP_CNTL, vclk_cntl & ~PIXCLK_DAC_ALWAYS_ONb);
		}
		/* Make sure we are on first palette */
		if(rinfo->has_CRTC2)
		{
			dac_cntl2 = INREG(DAC_CNTL2);
			dac_cntl2 &= ~DAC2_PALETTE_ACCESS_CNTL;
			OUTREG(DAC_CNTL2, dac_cntl2);
		}
	}
	rc = radeon_setcolreg(regno, red, green, blue, transp, rinfo);
	if(!rinfo->asleep && rinfo->is_mobility)
		OUTPLL(VCLK_ECP_CNTL, vclk_cntl);
	return rc;
}

static void radeon_save_state(struct radeonfb_info *rinfo, struct radeon_regs *save)
{
	/* CRTC regs */
	save->crtc_gen_cntl = INREG(CRTC_GEN_CNTL);
	save->crtc_ext_cntl = INREG(CRTC_EXT_CNTL);
	save->crtc_more_cntl = INREG(CRTC_MORE_CNTL);
	save->dac_cntl = INREG(DAC_CNTL);
	save->crtc_h_total_disp = INREG(CRTC_H_TOTAL_DISP);
	save->crtc_h_sync_strt_wid = INREG(CRTC_H_SYNC_STRT_WID);
	save->crtc_v_total_disp = INREG(CRTC_V_TOTAL_DISP);
	save->crtc_v_sync_strt_wid = INREG(CRTC_V_SYNC_STRT_WID);
	save->crtc_pitch = INREG(CRTC_PITCH);
	save->surface_cntl = INREG(SURFACE_CNTL);
	/* FP regs */
	save->fp_crtc_h_total_disp = INREG(FP_CRTC_H_TOTAL_DISP);
	save->fp_crtc_v_total_disp = INREG(FP_CRTC_V_TOTAL_DISP);
	save->fp_gen_cntl = INREG(FP_GEN_CNTL);
	save->fp_h_sync_strt_wid = INREG(FP_H_SYNC_STRT_WID);
	save->fp_horz_stretch = INREG(FP_HORZ_STRETCH);
	save->fp_v_sync_strt_wid = INREG(FP_V_SYNC_STRT_WID);
	save->fp_vert_stretch = INREG(FP_VERT_STRETCH);
	save->lvds_gen_cntl = INREG(LVDS_GEN_CNTL);
	save->lvds_pll_cntl = INREG(LVDS_PLL_CNTL);
	save->tmds_crc = INREG(TMDS_CRC);
	save->tmds_transmitter_cntl = INREG(TMDS_TRANSMITTER_CNTL);
	save->vclk_ecp_cntl = INPLL(VCLK_ECP_CNTL);
	/* PLL regs */
	save->clk_cntl_index = INREG(CLOCK_CNTL_INDEX) & ~0x3f;
	radeon_pll_errata_after_index(rinfo);
	save->ppll_div_3 = INPLL(PPLL_DIV_3);
	save->ppll_ref_div = INPLL(PPLL_REF_DIV);
}

static void radeon_write_pll_regs(struct radeonfb_info *rinfo, struct radeon_regs *mode)
{
	int i;
	DPRINT("radeonfb: radeon_write_pll_regs\r\n");
	radeon_fifo_wait(20);
#if 0
	/* Workaround from XFree */
	if(rinfo->is_mobility)
	{
	   /* A temporal workaround for the occational blanking on certain laptop
		 * panels. This appears to related to the PLL divider registers
		 * (fail to lock?). It occurs even when all dividers are the same
		 * with their old settings. In this case we really don't need to
		 * fiddle with PLL registers. By doing this we can avoid the blanking
		 * problem with some panels.
	         */
		if((mode->ppll_ref_div == (INPLL(PPLL_REF_DIV) & PPLL_REF_DIV_MASK))
		 && (mode->ppll_div_3 == (INPLL(PPLL_DIV_3) & (PPLL_POST3_DIV_MASK | PPLL_FB3_DIV_MASK))))
		{
			/* We still have to force a switch to selected PPLL div thanks to
			 * an XFree86 driver bug which will switch it away in some cases
			 * even when using UseFDev */
			OUTREGP(CLOCK_CNTL_INDEX,
				mode->clk_cntl_index & PPLL_DIV_SEL_MASK,
				~PPLL_DIV_SEL_MASK);
			radeon_pll_errata_after_index(rinfo);
			radeon_pll_errata_after_data(rinfo);
			return;
		}
	}
#endif
	/* Swich VCKL clock input to CPUCLK so it stays fed while PPLL updates*/
	OUTPLLP(VCLK_ECP_CNTL, VCLK_SRC_SEL_CPUCLK, ~VCLK_SRC_SEL_MASK);
	/* Reset PPLL & enable atomic update */
	OUTPLLP(PPLL_CNTL, PPLL_RESET | PPLL_ATOMIC_UPDATE_EN | PPLL_VGA_ATOMIC_UPDATE_EN,
	 ~(PPLL_RESET | PPLL_ATOMIC_UPDATE_EN | PPLL_VGA_ATOMIC_UPDATE_EN));
	/* Switch to selected PPLL divider */
	OUTREGP(CLOCK_CNTL_INDEX,	mode->clk_cntl_index & PPLL_DIV_SEL_MASK, ~PPLL_DIV_SEL_MASK);
	radeon_pll_errata_after_index(rinfo);
	radeon_pll_errata_after_data(rinfo);
	/* Set PPLL ref. div */
	if(rinfo->family == CHIP_FAMILY_R300 || rinfo->family == CHIP_FAMILY_RS300
	 || rinfo->family == CHIP_FAMILY_R350 || rinfo->family == CHIP_FAMILY_RV350)
	{
		if(mode->ppll_ref_div & R300_PPLL_REF_DIV_ACC_MASK)
		{
			/* When restoring console mode, use saved PPLL_REF_DIV
			 * setting.
			 */
			OUTPLLP(PPLL_REF_DIV, mode->ppll_ref_div, 0);
		}
		else
		{
			/* R300 uses ref_div_acc field as real ref divider */
			OUTPLLP(PPLL_REF_DIV,(mode->ppll_ref_div << R300_PPLL_REF_DIV_ACC_SHIFT),~R300_PPLL_REF_DIV_ACC_MASK);
		}
	}
	else
		OUTPLLP(PPLL_REF_DIV, mode->ppll_ref_div, ~PPLL_REF_DIV_MASK);
	/* Set PPLL divider 3 & post divider*/
	OUTPLLP(PPLL_DIV_3, mode->ppll_div_3, ~PPLL_FB3_DIV_MASK);
	OUTPLLP(PPLL_DIV_3, mode->ppll_div_3, ~PPLL_POST3_DIV_MASK);
	/* Write update */
	while(INPLL(PPLL_REF_DIV) & PPLL_ATOMIC_UPDATE_R);
	OUTPLLP(PPLL_REF_DIV, PPLL_ATOMIC_UPDATE_W, ~PPLL_ATOMIC_UPDATE_W);
	/* Wait read update complete */
	/* FIXME: Certain revisions of R300 can't recover here.  Not sure of
	   the cause yet, but this workaround will mask the problem for now.
	   Other chips usually will pass at the very first test, so the
	   workaround shouldn't have any effect on them. */
	for(i = 0; (i < 10000 && INPLL(PPLL_REF_DIV) & PPLL_ATOMIC_UPDATE_R); i++);
	OUTPLL(HTOTAL_CNTL, 0);
	/* Clear reset & atomic update */
	OUTPLLP(PPLL_CNTL, 0, ~(PPLL_RESET | PPLL_SLEEP | PPLL_ATOMIC_UPDATE_EN | PPLL_VGA_ATOMIC_UPDATE_EN));
	/* We may want some locking ... oh well */
	radeon_msleep(5);
	/* Switch back VCLK source to PPLL */
	OUTPLLP(VCLK_ECP_CNTL, VCLK_SRC_SEL_PPLLCLK, ~VCLK_SRC_SEL_MASK);
}

static void radeon_wait_vbl(struct fb_info *info)
{
	unsigned long cnt = INREG(CRTC_CRNT_FRAME);
	while(cnt == INREG(CRTC_CRNT_FRAME));
}

static void radeon_timer_func(void)
{
	struct fb_info *info = info_fvdi;
	struct radeonfb_info *rinfo = info->par;
	static long start_timer;
	struct fb_var_screeninfo var;
	unsigned long x, y;
	int chg, disp;
	/* delayed LVDS panel power up/down */
	if(rinfo->lvds_timer)
	{
		if(!start_timer)
			start_timer = *_hz_200;
		if(((*_hz_200 - start_timer) * 5) >= (long)rinfo->lvds_timer)
		{
			rinfo->lvds_timer = 0;
			radeon_engine_idle();
			OUTREG(LVDS_GEN_CNTL, rinfo->pending_lvds_gen_cntl);
		}
	}
	else
		start_timer = 0;
	if(rinfo->RenderCallback != NULL)
		rinfo->RenderCallback(rinfo);
	if((info->screen_mono != NULL) && info->update_mono)
	{
		long foreground = 255, background = 0;
		unsigned char *src_buf = (unsigned char *)info->screen_mono;
		int skipleft = ((int)src_buf & 3) << 3;
		int dst_x = 0;
		int w = (int)info->var.xres_virtual;
		int h = (int)info->var.yres_virtual;
//		info->fbops->SetClippingRectangle(info,0,0,w-1,h-1);
		src_buf = (unsigned char*)((long)src_buf & ~3);
		dst_x -= (long)skipleft;
		w += (long)skipleft;
		info->fbops->SetupForScanlineCPUToScreenColorExpandFill(info,(int)foreground,(int)background,3,0xffffffff);
		info->fbops->SubsequentScanlineCPUToScreenColorExpandFill(info,(int)dst_x,0,w,h,skipleft);
		while(--h >= 0)
		{
			info->fbops->SubsequentScanline(info, (unsigned long *)src_buf);
			src_buf += (info->var.xres_virtual >> 3);
		}
//		info->fbops->DisableClipping(info);
		if(info->update_mono > 0)
			info->update_mono = 0;
	}
	if((info->var.xres_virtual != info->var.xres)
	 || (info->var.yres_virtual != info->var.yres))
	{
#ifdef COLDFIRE
		asm volatile (
			" clr.l -(SP)\n\t"
			" move.l D0,-(SP)\n\t"
			" move.w SR,D0\n\t"
			" move.l D0,4(SP)\n\t"
			" or.l #0x700,D0\n\t"   /* disable interrupts */
			" move.w D0,SR\n\t"
			" move.l (SP)+,D0\n\t" );
#else
		asm volatile (
			" move.w SR,-(SP)\n\t"
			" or.w #0x700,SR\n\t" ); /* disable interrupts */
#endif
		chg = 0;
		x = info->var.xoffset;
		y = info->var.yoffset;
		if(((x + info->var.xres) < info->var.xres_virtual)
		 && (rinfo->cursor_x >= (info->var.xres - 8)))
		{
			x += 8;
			chg = 1;
		}
		else if((x >= 8) && (rinfo->cursor_x <= 8))
		{
			x -= 8;
			chg = 1;
		}
		if(((y + info->var.yres) < info->var.yres_virtual)
		 && (rinfo->cursor_y >= (info->var.yres - 8)))
		{
			y += 8;
			chg = 1;
		}
		else if((y >=8) && (rinfo->cursor_y <= 8))
		{
			y -= 8;
			chg = 1;
		}
		if(chg)
		{
			memcpy(&var, &info->var, sizeof(struct fb_var_screeninfo));
			var.xoffset = x;
			var.yoffset = y;
			disp = rinfo->cursor_show;
			if(disp)
				RADEONHideCursor(info);
			fb_pan_display(info,&var);
			if(disp)
				RADEONShowCursor(info);
		}
#ifdef COLDFIRE
		asm volatile (
			" move.l D0,-(SP)\n\t"
			" move.l 4(SP),D0\n\t"
			" move.w D0,SR\n\t"
			" move.l (SP)+,D0\n\t"
			" addq.l #4,SP\n\t" );		
#else
			asm volatile (
				" move.w (SP)+,SR\n\r" );
#endif
	}
}

/*
 * Apply a video mode. This will apply the whole register set, including
 * the PLL registers, to the card
 */
void radeon_write_mode(struct radeonfb_info *rinfo, struct radeon_regs *mode, int regs_only)
{
	int i;
	int primary_mon = PRIMARY_MONITOR(rinfo);
	DPRINT("radeonfb: radeon_write_mode\r\n");
	if(!regs_only)
		radeon_screen_blank(rinfo, FB_BLANK_NORMAL, 0);
	radeon_fifo_wait(31);
	for(i=0; i<10; i++)
		OUTREG(common_regs[i].reg, common_regs[i].val);
	/* Apply surface registers */
	for(i=0; i<8; i++)
	{
		OUTREG(SURFACE0_LOWER_BOUND + 0x10*i, mode->surf_lower_bound[i]);
		OUTREG(SURFACE0_UPPER_BOUND + 0x10*i, mode->surf_upper_bound[i]);
		OUTREG(SURFACE0_INFO + 0x10*i, mode->surf_info[i]);
	}
	OUTREG(CRTC_GEN_CNTL, mode->crtc_gen_cntl);
	OUTREGP(CRTC_EXT_CNTL, mode->crtc_ext_cntl, ~(CRTC_HSYNC_DIS | CRTC_VSYNC_DIS | CRTC_DISPLAY_DIS));
	OUTREG(CRTC_MORE_CNTL, mode->crtc_more_cntl);
	OUTREGP(DAC_CNTL, mode->dac_cntl, DAC_RANGE_CNTL | DAC_BLANKING);
	OUTREG(CRTC_H_TOTAL_DISP, mode->crtc_h_total_disp);
	OUTREG(CRTC_H_SYNC_STRT_WID, mode->crtc_h_sync_strt_wid);
	OUTREG(CRTC_V_TOTAL_DISP, mode->crtc_v_total_disp);
	OUTREG(CRTC_V_SYNC_STRT_WID, mode->crtc_v_sync_strt_wid);
	rinfo->fb_offset = 0;
	rinfo->dst_pitch_offset = (rinfo->pitch << 22) | ((rinfo->fb_local_base + rinfo->fb_offset) >> 10);
	OUTREG(CRTC_OFFSET, rinfo->fb_offset);
#ifdef RADEON_TILING
	if(rinfo->tilingEnabled)
	{
		if(rinfo->family >= CHIP_FAMILY_R300)
			OUTREG(CRTC_OFFSET_CNTL, R300_CRTC_X_Y_MODE_EN | R300_CRTC_MICRO_TILE_BUFFER_DIS | R300_CRTC_MACRO_TILE_EN);
		else
			OUTREG(CRTC_OFFSET_CNTL, CRTC_OFFSET_CNTL__CRTC_TILE_EN);
	}
	else
#endif
		OUTREG(CRTC_OFFSET_CNTL, 0);
	OUTREG(CRTC_PITCH, mode->crtc_pitch);
	OUTREG(SURFACE_CNTL, mode->surface_cntl);
	radeon_write_pll_regs(rinfo, mode);
	if((primary_mon == MT_DFP) || (primary_mon == MT_LCD))
	{
		radeon_fifo_wait(10);
		OUTREG(FP_CRTC_H_TOTAL_DISP, mode->fp_crtc_h_total_disp);
		OUTREG(FP_CRTC_V_TOTAL_DISP, mode->fp_crtc_v_total_disp);
		OUTREG(FP_H_SYNC_STRT_WID, mode->fp_h_sync_strt_wid);
		OUTREG(FP_V_SYNC_STRT_WID, mode->fp_v_sync_strt_wid);
		OUTREG(FP_HORZ_STRETCH, mode->fp_horz_stretch);
		OUTREG(FP_VERT_STRETCH, mode->fp_vert_stretch);
		OUTREG(FP_GEN_CNTL, mode->fp_gen_cntl);
		OUTREG(TMDS_CRC, mode->tmds_crc);
		OUTREG(TMDS_TRANSMITTER_CNTL, mode->tmds_transmitter_cntl);
	}
	if(!regs_only)
		radeon_screen_blank(rinfo, FB_BLANK_UNBLANK, 0);
	radeon_fifo_wait(2);
	OUTPLL(VCLK_ECP_CNTL, mode->vclk_ecp_cntl);
}

/*
 * Calculate the PLL values for a given mode
 */
static void radeon_calc_pll_regs(struct radeonfb_info *rinfo, struct radeon_regs *regs, unsigned long freq)
{
	static const struct {
		int divider;
		int bitvalue;
	} *post_div,
	post_divs[] = {
		{ 1,  0 },
		{ 2,  1 },
		{ 4,  2 },
		{ 8,  3 },
		{ 3,  4 },
		{ 16, 5 },
		{ 6,  6 },
		{ 12, 7 },
		{ 0,  0 },
	};
	int fb_div, pll_output_freq = 0;
	int uses_dvo = 0;
	/* Check if the DVO port is enabled and sourced from the primary CRTC. I'm
	 * not sure which model starts having FP2_GEN_CNTL, I assume anything more
	 * recent than an r(v)100...
	 */
#if 1
	/* XXX I had reports of flicker happening with the cinema display
	 * on TMDS1 that seem to be fixed if I also forbit odd dividers in
	 * this case. This could just be a bandwidth calculation issue, I
	 * haven't implemented the bandwidth code yet, but in the meantime,
	 * forcing uses_dvo to 1 fixes it and shouln't have bad side effects,
	 * I haven't seen a case were were absolutely needed an odd PLL
	 * divider. I'll find a better fix once I have more infos on the
	 * real cause of the problem.
	 */
	while(rinfo->has_CRTC2)
	{
		unsigned long fp2_gen_cntl = INREG(FP2_GEN_CNTL);
		unsigned long disp_output_cntl;
		int source;
		/* FP2 path not enabled */
		if((fp2_gen_cntl & FP2_ON) == 0)
			break;
		/* Not all chip revs have the same format for this register,
		 * extract the source selection
		 */
		if(rinfo->family == CHIP_FAMILY_R200 || rinfo->family == CHIP_FAMILY_R300
		 || rinfo->family == CHIP_FAMILY_R350 || rinfo->family == CHIP_FAMILY_RV350)
		{
			source = (fp2_gen_cntl >> 10) & 0x3;
			/* sourced from transform unit, check for transform unit
			 * own source
			 */
			if(source == 3)
			{
				disp_output_cntl = INREG(DISP_OUTPUT_CNTL);
				source = (disp_output_cntl >> 12) & 0x3;
			}
		}
		else
			source = (fp2_gen_cntl >> 13) & 0x1;
		/* sourced from CRTC2 -> exit */
		if(source == 1)
			break;
		/* so we end up on CRTC1, let's set uses_dvo to 1 now */
		uses_dvo = 1;
		break;
	}
#else
	uses_dvo = 1;
#endif
	if(freq > rinfo->pll.ppll_max)
		freq = rinfo->pll.ppll_max;
	if(freq*12 < rinfo->pll.ppll_min)
		freq = rinfo->pll.ppll_min / 12;
	for(post_div = &post_divs[0]; post_div->divider; ++post_div)
	{
		pll_output_freq = post_div->divider * freq;
		/* If we output to the DVO port (external TMDS), we don't allow an
		 * odd PLL divider as those aren't supported on this path
		 */
		if(uses_dvo && (post_div->divider & 1))
			continue;
		if(pll_output_freq >= rinfo->pll.ppll_min  &&
		    pll_output_freq <= rinfo->pll.ppll_max)
			break;
	}
	/* If we fall through the bottom, try the "default value"
	   given by the terminal post_div->bitvalue */
	if( !post_div->divider )
	{
		post_div = &post_divs[post_div->bitvalue];
		pll_output_freq = post_div->divider * freq;
	}
	/* If we fall through the bottom, try the "default value"
	   given by the terminal post_div->bitvalue */
	if( !post_div->divider )
	{
		post_div = &post_divs[post_div->bitvalue];
		pll_output_freq = post_div->divider * freq;
	}
	fb_div = round_div(rinfo->pll.ref_div*pll_output_freq,rinfo->pll.ref_clk);
	regs->ppll_ref_div = rinfo->pll.ref_div;
	regs->ppll_div_3 = fb_div | (post_div->bitvalue << 16); 
}

int radeonfb_set_par(struct fb_info *info)
{
	struct radeonfb_info *rinfo = info->par;
	struct fb_var_screeninfo *mode = &info->var;
	struct radeon_regs *newmode;
	int hTotal, vTotal, hSyncStart, hSyncEnd, hSyncPol, vSyncStart, vSyncEnd, vSyncPol, cSync;
	static unsigned char hsync_adj_tab[] = {0, 0x12, 9, 9, 6, 5};
	static unsigned char hsync_fudge_fp[] = {2, 2, 0, 0, 5, 5};
	unsigned long sync, h_sync_pol, v_sync_pol, dotClock, pixClock;
	int i, freq;
	int format = 0;
	int nopllcalc = 0;
	int hsync_start, hsync_fudge, bytpp, hsync_wid, vsync_wid;
	int primary_mon = PRIMARY_MONITOR(rinfo);
	int depth = var_to_depth(mode);
	int use_rmx = 0;
	newmode = (struct radeon_regs *)Funcs_malloc(sizeof(struct radeon_regs),3);
	if(!newmode)
		return -ENOMEM;
	/* We always want engine to be idle on a mode switch, even
	 * if we won't actually change the mode
	 */
	DPRINT("radeonfb: radeonfb_set_par\r\n");
	radeon_engine_idle();
	hSyncStart = mode->xres + mode->right_margin;
	hSyncEnd = hSyncStart + mode->hsync_len;
	hTotal = hSyncEnd + mode->left_margin;
	vSyncStart = mode->yres + mode->lower_margin;
	vSyncEnd = vSyncStart + mode->vsync_len;
	vTotal = vSyncEnd + mode->upper_margin;
	pixClock = mode->pixclock;
	sync = mode->sync;
	h_sync_pol = sync & FB_SYNC_HOR_HIGH_ACT ? 0 : 1;
	v_sync_pol = sync & FB_SYNC_VERT_HIGH_ACT ? 0 : 1;
	if(primary_mon == MT_DFP || primary_mon == MT_LCD)
	{
		if(rinfo->panel_info.xres < mode->xres)
			mode->xres = rinfo->panel_info.xres;
		if(rinfo->panel_info.yres < mode->yres)
			mode->yres = rinfo->panel_info.yres;
		hTotal = mode->xres + rinfo->panel_info.hblank;
		hSyncStart = mode->xres + rinfo->panel_info.hOver_plus;
		hSyncEnd = hSyncStart + rinfo->panel_info.hSync_width;
		vTotal = mode->yres + rinfo->panel_info.vblank;
		vSyncStart = mode->yres + rinfo->panel_info.vOver_plus;
		vSyncEnd = vSyncStart + rinfo->panel_info.vSync_width;
		h_sync_pol = !rinfo->panel_info.hAct_high;
		v_sync_pol = !rinfo->panel_info.vAct_high;
		pixClock = 100000000 / rinfo->panel_info.clock;
		if(rinfo->panel_info.use_bios_dividers)
		{
			nopllcalc = 1;
			newmode->ppll_div_3 = rinfo->panel_info.fbk_divider
			 | (rinfo->panel_info.post_divider << 16);
			newmode->ppll_ref_div = rinfo->panel_info.ref_divider;
		}
	}
	dotClock = 1000000000 / pixClock;
	freq = dotClock / 10; /* x100 */
	hsync_wid = (hSyncEnd - hSyncStart) / 8;
	if(hsync_wid == 0)
		hsync_wid = 1;
	else if(hsync_wid > 0x3f)	/* max */
		hsync_wid = 0x3f;
	if(mode->vmode & FB_VMODE_DOUBLE)
	{
		vSyncStart <<= 1;
		vSyncEnd <<= 1;
		vTotal <<= 1;
	}
	vsync_wid = vSyncEnd - vSyncStart;
	if(vsync_wid == 0)
		vsync_wid = 1;
	else if(vsync_wid > 0x1f)	/* max */
		vsync_wid = 0x1f;
	hSyncPol = mode->sync & FB_SYNC_HOR_HIGH_ACT ? 0 : 1;
	vSyncPol = mode->sync & FB_SYNC_VERT_HIGH_ACT ? 0 : 1;
	cSync = mode->sync & FB_SYNC_COMP_HIGH_ACT ? (1 << 4) : 0;
	format = radeon_get_dstbpp(depth);
	bytpp = mode->bits_per_pixel >> 3;
	if((primary_mon == MT_DFP) || (primary_mon == MT_LCD))
		hsync_fudge = hsync_fudge_fp[format-1];
	else
		hsync_fudge = hsync_adj_tab[format-1];
	if(mode->vmode & FB_VMODE_DOUBLE)
		hsync_fudge = 0; /* todo: need adjust */		
	hsync_start = hSyncStart - 8 + hsync_fudge;
	newmode->crtc_gen_cntl = CRTC_EXT_DISP_EN | CRTC_EN | (format << 8);
	if(mode->vmode & FB_VMODE_DOUBLE)
		newmode->crtc_gen_cntl |= CRTC_DBL_SCAN_EN;
	if(mode->vmode & FB_VMODE_INTERLACED)
		newmode->crtc_gen_cntl |= CRTC_INTERLACE_EN;
	/* Clear auto-center etc... */
	newmode->crtc_more_cntl = rinfo->init_state.crtc_more_cntl;
	newmode->crtc_more_cntl &= 0xfffffff0;
	if((primary_mon == MT_DFP) || (primary_mon == MT_LCD))
	{
		newmode->crtc_ext_cntl = VGA_ATI_LINEAR | XCRT_CNT_EN;
		if(mirror)
			newmode->crtc_ext_cntl |= CRTC_CRT_ON;
		newmode->crtc_gen_cntl &= ~(CRTC_DBL_SCAN_EN | CRTC_INTERLACE_EN);
	}
	else
		newmode->crtc_ext_cntl = VGA_ATI_LINEAR | XCRT_CNT_EN | CRTC_CRT_ON;
	newmode->dac_cntl = /* INREG(DAC_CNTL) | */ DAC_MASK_ALL | DAC_VGA_ADR_EN | DAC_8BIT_EN;
	newmode->crtc_h_total_disp = ((((hTotal / 8) - 1) & 0x3ff) | (((mode->xres / 8) - 1) << 16));
	newmode->crtc_h_sync_strt_wid = ((hsync_start & 0x1fff) | (hsync_wid << 16) | (h_sync_pol << 23));
	if(mode->vmode & FB_VMODE_DOUBLE)
		newmode->crtc_v_total_disp = ((vTotal - 1) & 0xffff) | (((mode->yres << 1) - 1) << 16);
	else
		newmode->crtc_v_total_disp = ((vTotal - 1) & 0xffff) | ((mode->yres - 1) << 16);
	newmode->crtc_v_sync_strt_wid = (((vSyncStart - 1) & 0xfff) | (vsync_wid << 16) | (v_sync_pol << 23));
	/* We first calculate the engine pitch */
	rinfo->pitch = ((mode->xres_virtual * ((mode->bits_per_pixel + 1) / 8) + 0x3f) & ~(0x3f)) >> 6;
	/* Then, re-multiply it to get the CRTC pitch */
	newmode->crtc_pitch = (rinfo->pitch << 3) / ((mode->bits_per_pixel + 1) / 8);
	newmode->crtc_pitch |= (newmode->crtc_pitch << 16);
	/*
	 * It looks like recent chips have a problem with SURFACE_CNTL,
	 * setting SURF_TRANSLATION_DIS completely disables the
	 * swapper as well, so we leave it unset now.
	 */
	newmode->surface_cntl = 0;
	if(rinfo->big_endian)
	{
		/* Setup swapping on both apertures, though we currently
		 * only use aperture 0, enabling swapper on aperture 1
		 * won't harm
		 */
		switch(mode->bits_per_pixel)
		{
			case 16:
				newmode->surface_cntl |= NONSURF_AP0_SWP_16BPP;
				newmode->surface_cntl |= NONSURF_AP1_SWP_16BPP;
				break;
			case 24:	
			case 32:
				newmode->surface_cntl |= NONSURF_AP0_SWP_32BPP;
				newmode->surface_cntl |= NONSURF_AP1_SWP_32BPP;
				break;
		}
	}
	/* Clear surface registers */
	for(i=0; i<8; i++)
	{
		newmode->surf_lower_bound[i] = 0;
		newmode->surf_upper_bound[i] = 0x1f;
		newmode->surf_info[i] = 0;
	}
	rinfo->bpp = mode->bits_per_pixel;
	rinfo->depth = depth;
	/* We use PPLL_DIV_3 */
	newmode->clk_cntl_index = 0x300;
	/* Calculate PPLL value if necessary */
	if(!nopllcalc)
		radeon_calc_pll_regs(rinfo, newmode, freq);
	newmode->vclk_ecp_cntl = rinfo->init_state.vclk_ecp_cntl;
	if((primary_mon == MT_DFP) || (primary_mon == MT_LCD))
	{
		unsigned int hRatio, vRatio;
		if(mode->xres > rinfo->panel_info.xres)
			mode->xres = rinfo->panel_info.xres;
		if(mode->yres > rinfo->panel_info.yres)
			mode->yres = rinfo->panel_info.yres;
		newmode->fp_horz_stretch = (((rinfo->panel_info.xres / 8) - 1) << HORZ_PANEL_SHIFT);
		newmode->fp_vert_stretch = ((rinfo->panel_info.yres - 1) << VERT_PANEL_SHIFT);
		if(mode->xres != rinfo->panel_info.xres)
		{
			hRatio = round_div(mode->xres * HORZ_STRETCH_RATIO_MAX, rinfo->panel_info.xres);
			newmode->fp_horz_stretch = (((((unsigned long)hRatio) & HORZ_STRETCH_RATIO_MASK))
			 | (newmode->fp_horz_stretch & (HORZ_PANEL_SIZE | HORZ_FP_LOOP_STRETCH | HORZ_AUTO_RATIO_INC)));
			newmode->fp_horz_stretch |= (HORZ_STRETCH_BLEND | HORZ_STRETCH_ENABLE);
			use_rmx = 1;
		}
		newmode->fp_horz_stretch &= ~HORZ_AUTO_RATIO;
		if(mode->yres != rinfo->panel_info.yres)
		{
			vRatio = round_div(mode->yres * VERT_STRETCH_RATIO_MAX, rinfo->panel_info.yres);
			newmode->fp_vert_stretch = (((((unsigned long)vRatio) & VERT_STRETCH_RATIO_MASK))
			 | (newmode->fp_vert_stretch & (VERT_PANEL_SIZE | VERT_STRETCH_RESERVED)));
			newmode->fp_vert_stretch |= (VERT_STRETCH_BLEND | VERT_STRETCH_ENABLE);
			use_rmx = 1;
		}
		newmode->fp_vert_stretch &= ~VERT_AUTO_RATIO_EN;
		newmode->fp_gen_cntl = (rinfo->init_state.fp_gen_cntl
		 & (unsigned long) ~(FP_SEL_CRTC2 | FP_RMX_HVSYNC_CONTROL_EN | FP_DFP_SYNC_SEL | FP_CRT_SYNC_SEL
		  | FP_CRTC_LOCK_8DOT | FP_USE_SHADOW_EN | FP_CRTC_USE_SHADOW_VEND | FP_CRT_SYNC_ALT));
		newmode->fp_gen_cntl |= (FP_CRTC_DONT_SHADOW_VPAR | FP_CRTC_DONT_SHADOW_HEND | FP_PANEL_FORMAT);
		if(IS_R300_VARIANT(rinfo) || (rinfo->family == CHIP_FAMILY_R200))
		{
			newmode->fp_gen_cntl &= ~R200_FP_SOURCE_SEL_MASK;
			if(use_rmx)
				newmode->fp_gen_cntl |= R200_FP_SOURCE_SEL_RMX;
			else
				newmode->fp_gen_cntl |= R200_FP_SOURCE_SEL_CRTC1;
		}
		else
			newmode->fp_gen_cntl |= FP_SEL_CRTC1;
		newmode->lvds_gen_cntl = rinfo->init_state.lvds_gen_cntl;
		newmode->lvds_pll_cntl = rinfo->init_state.lvds_pll_cntl;
		newmode->tmds_crc = rinfo->init_state.tmds_crc;
		newmode->tmds_transmitter_cntl = rinfo->init_state.tmds_transmitter_cntl;
		if(primary_mon == MT_LCD)
		{
			newmode->lvds_gen_cntl |= (LVDS_ON | LVDS_BLON);
			newmode->fp_gen_cntl &= ~(FP_FPON | FP_TMDS_EN);
		}
		else
		{
			/* DFP */
			newmode->fp_gen_cntl |= (FP_FPON | FP_TMDS_EN);
			newmode->tmds_transmitter_cntl &= ~(TMDS_PLLRST);
			/* TMDS_PLL_EN bit is reversed on RV (and mobility) chips */
			if(IS_R300_VARIANT(rinfo) || (rinfo->family == CHIP_FAMILY_R200) || !rinfo->has_CRTC2)
				newmode->tmds_transmitter_cntl &= ~TMDS_PLL_EN;
			else
				newmode->tmds_transmitter_cntl |= TMDS_PLL_EN;
			newmode->crtc_ext_cntl &= ~CRTC_CRT_ON;
		}
		newmode->fp_crtc_h_total_disp = (((rinfo->panel_info.hblank / 8) & 0x3ff) | (((mode->xres / 8) - 1) << 16));
		newmode->fp_crtc_v_total_disp = (rinfo->panel_info.vblank & 0xffff) | ((mode->yres - 1) << 16);
		newmode->fp_h_sync_strt_wid = ((rinfo->panel_info.hOver_plus & 0x1fff) | (hsync_wid << 16) | (h_sync_pol << 23));
		newmode->fp_v_sync_strt_wid = ((rinfo->panel_info.vOver_plus & 0xfff) | (vsync_wid << 16) | (v_sync_pol  << 23));
	}
	/* do it! */
	if(!rinfo->asleep)
	{
#if 0
		if(debug)
		{
			DPRINT("Press a key for write the video mode...\r\n");
			Bconin(2);
		}
#endif
		memcpy(&rinfo->state, newmode, sizeof(*newmode));
#ifdef RADEON_TILING
		rinfo->tilingEnabled = (mode->vmode & (FB_VMODE_DOUBLE | FB_VMODE_INTERLACED)) ? FALSE : TRUE;
#endif
		radeon_write_mode(rinfo, newmode, 0);
		/* (re)initialize the engine */
		radeonfb_engine_init(rinfo);
	}
	/* Update fix */
	info->fix.line_length = rinfo->pitch*64;
	info->fix.visual = rinfo->depth == 8 ? FB_VISUAL_PSEUDOCOLOR : FB_VISUAL_DIRECTCOLOR;
	Funcs_free(newmode);
	return 0;
}

static void radeonfb_check_modes(struct fb_info *info, struct mode_option *resolution)
{
	struct radeonfb_info *rinfo = info->par;
	radeon_check_modes(rinfo, resolution);
}

static struct fb_ops radeonfb_ops =
{
	.fb_check_var = radeonfb_check_var,
	.fb_setcolreg = radeonfb_setcolreg,
	.fb_set_par = radeonfb_set_par,
	.fb_pan_display = radeonfb_pan_display,
	.fb_blank = radeonfb_blank,
	.fb_sync = radeonfb_sync,
	.fb_ioctl = radeonfb_ioctl,
	.fb_check_modes = radeonfb_check_modes,
	.SetupForSolidFill = RADEONSetupForSolidFillMMIO,
	.SubsequentSolidFillRect = RADEONSubsequentSolidFillRectMMIO,
	.SetupForSolidLine = RADEONSetupForSolidLineMMIO,
	.SubsequentSolidHorVertLine = RADEONSubsequentSolidHorVertLineMMIO,
	.SubsequentSolidTwoPointLine = RADEONSubsequentSolidTwoPointLineMMIO,
	.SetupForDashedLine = RADEONSetupForDashedLineMMIO,
	.SubsequentDashedTwoPointLine = RADEONSubsequentDashedTwoPointLineMMIO,
	.SetupForScreenToScreenCopy = RADEONSetupForScreenToScreenCopyMMIO,
	.SubsequentScreenToScreenCopy = RADEONSubsequentScreenToScreenCopyMMIO,
	.ScreenToScreenCopy = RADEONScreenToScreenCopyMMIO,
	.SetupForMono8x8PatternFill = RADEONSetupForMono8x8PatternFillMMIO,
	.SubsequentMono8x8PatternFillRect = RADEONSubsequentMono8x8PatternFillRectMMIO,
	.SetupForScanlineCPUToScreenColorExpandFill = RADEONSetupForScanlineCPUToScreenColorExpandFillMMIO,
	.SubsequentScanlineCPUToScreenColorExpandFill = RADEONSubsequentScanlineCPUToScreenColorExpandFillMMIO,
	.SubsequentScanline = RADEONSubsequentScanlineMMIO,	
	.SetupForScanlineImageWrite = RADEONSetupForScanlineImageWriteMMIO,
	.SubsequentScanlineImageWriteRect = RADEONSubsequentScanlineImageWriteRectMMIO,
	.SetClippingRectangle = RADEONSetClippingRectangleMMIO,
	.DisableClipping = RADEONDisableClippingMMIO,
#ifdef RADEON_RENDER
	.SetupForCPUToScreenAlphaTexture = RADEONSetupForCPUToScreenAlphaTextureMMIO,
	.SetupForCPUToScreenTexture = RADEONSetupForCPUToScreenTextureMMIO,
	.SubsequentCPUToScreenTexture = RADEONSubsequentCPUToScreenTextureMMIO,
#else
	.SetupForCPUToScreenAlphaTexture = NULL,
	.SetupForCPUToScreenTexture = NULL,
	.SubsequentCPUToScreenTexture = NULL,
#endif /* RADEON_RENDER */
	.SetCursorColors = RADEONSetCursorColors,
	.SetCursorPosition = RADEONSetCursorPosition,
	.LoadCursorImage = RADEONLoadCursorImage,
	.HideCursor = RADEONHideCursor,
	.ShowCursor = RADEONShowCursor,
	.CursorInit = RADEONCursorInit,
	.WaitVbl = radeon_wait_vbl,
};

static int radeon_set_fbinfo(struct radeonfb_info *rinfo)
{
	struct fb_info *info = rinfo->info;
	info->par = rinfo;
	info->fbops = &radeonfb_ops;
	info->ram_base = info->screen_base = rinfo->fb_base;
	info->screen_size = rinfo->mapped_vram;
	info->ram_size = rinfo->mapped_vram;
	if(info->screen_size > MAX_MAPPED_VRAM)
		info->screen_size = MAX_MAPPED_VRAM;
	else if(info->screen_size > MIN_MAPPED_VRAM)
		info->screen_size = MIN_MAPPED_VRAM;
	DPRINTVALHEX("radeonfb: radeon_set_fbinfo: screen_size ",info->screen_size);
	DPRINT("\r\n");
	/* Fill fix common fields */
	memcpy(info->fix.id, rinfo->name, sizeof(info->fix.id));
	info->fix.smem_start = rinfo->fb_base_phys;
	info->fix.smem_len = rinfo->video_ram;
	info->fix.type = FB_TYPE_PACKED_PIXELS;
	info->fix.visual = FB_VISUAL_PSEUDOCOLOR;
	info->fix.xpanstep = 8;
	info->fix.ypanstep = 1;
	info->fix.ywrapstep = 0;
	info->fix.type_aux = 0;
	info->fix.mmio_start = rinfo->mmio_base_phys;
	info->fix.mmio_len = RADEON_REGSIZE;
	info->fix.accel = FB_ACCEL_ATI_RADEON;
	return 0;
}

static void radeon_identify_vram(struct radeonfb_info *rinfo)
{
	unsigned long tmp;
	/* framebuffer size */
	if((rinfo->family == CHIP_FAMILY_RS100)
	 || (rinfo->family == CHIP_FAMILY_RS200)
	 || (rinfo->family == CHIP_FAMILY_RS300))
	{
		unsigned long tom = INREG(NB_TOM);
		tmp = ((((tom >> 16) - (tom & 0xffff) + 1) << 6) * 1024);
		radeon_fifo_wait(6);
		OUTREG(MC_FB_LOCATION, tom);
		OUTREG(DISPLAY_BASE_ADDR, (tom & 0xffff) << 16);
		OUTREG(CRTC2_DISPLAY_BASE_ADDR, (tom & 0xffff) << 16);
		OUTREG(OV0_BASE_ADDR, (tom & 0xffff) << 16);
		/* This is supposed to fix the crtc2 noise problem. */
		OUTREG(GRPH2_BUFFER_CNTL, INREG(GRPH2_BUFFER_CNTL) & ~0x7f0000);
		if((rinfo->family == CHIP_FAMILY_RS100) || (rinfo->family == CHIP_FAMILY_RS200))
		{
			/* This is to workaround the asic bug for RMX, some versions
			    of BIOS dosen't have this register initialized correctly. */
			OUTREGP(CRTC_MORE_CNTL, CRTC_H_CUTOFF_ACTIVE_EN, ~CRTC_H_CUTOFF_ACTIVE_EN);
		}
	}
	else
		tmp = INREG(CONFIG_MEMSIZE);
	/* mem size is bits [28:0], mask off the rest */
	rinfo->video_ram = tmp & CONFIG_MEMSIZE_MASK;
	/*
	 * Hack to get around some busted production M6's
	 * reporting no ram
	 */
	if(rinfo->video_ram == 0)
	{
		switch(rinfo->chipset)
		{
		  case PCI_CHIP_RADEON_LY:
			case PCI_CHIP_RADEON_LZ: rinfo->video_ram = 8192 * 1024; break;
			default: break;
		}
	}
	/*
	 * Now try to identify VRAM type
	 */
	if(rinfo->is_IGP || (rinfo->family >= CHIP_FAMILY_R300)
	 || (INREG(MEM_SDRAM_MODE_REG) & (1<<30)))
		rinfo->vram_ddr = 1;
	else
		rinfo->vram_ddr = 0;
	tmp = INREG(MEM_CNTL);
	if(IS_R300_VARIANT(rinfo))
	{
		tmp &=  R300_MEM_NUM_CHANNELS_MASK;
		switch(tmp)
		{
			case 0:  rinfo->vram_width = 64; break;
			case 1:  rinfo->vram_width = 128; break;
			case 2:  rinfo->vram_width = 256; break;
			default: rinfo->vram_width = 128; break;
		}
	}
	else if((rinfo->family == CHIP_FAMILY_RV100)
	 || (rinfo->family == CHIP_FAMILY_RS100)
	 || (rinfo->family == CHIP_FAMILY_RS200))
	{
		if(tmp & RV100_MEM_HALF_MODE)
			rinfo->vram_width = 32;
		else
			rinfo->vram_width = 64;
	}
	else
	{
		if(tmp & MEM_NUM_CHANNELS_MASK)
			rinfo->vram_width = 128;
		else
			rinfo->vram_width = 64;
	}
	/* This may not be correct, as some cards can have half of channel disabled
	 * ToDo: identify these cases
	 */
	DPRINT("radeonfb: ");
	switch(rinfo->family)
	{
		case CHIP_FAMILY_LEGACY: DPRINT("LEGACY"); break;	
		case CHIP_FAMILY_RADEON: DPRINT("RADEON"); break;	
		case CHIP_FAMILY_RV100: DPRINT("RV100"); break;	
		case CHIP_FAMILY_RS100: DPRINT("RS100"); break;	
		case CHIP_FAMILY_RV200: DPRINT("RV200"); break;	
		case CHIP_FAMILY_RS200: DPRINT("RS200"); break;	
		case CHIP_FAMILY_R200: DPRINT("R200"); break;	
		case CHIP_FAMILY_RV250: DPRINT("RV250"); break;	
		case CHIP_FAMILY_RS300: DPRINT("RS300"); break;	
		case CHIP_FAMILY_RV280: DPRINT("RV280"); break;	
		case CHIP_FAMILY_R300: DPRINT("R300"); break;	
		case CHIP_FAMILY_R350: DPRINT("R350"); break;	
		case CHIP_FAMILY_RV350: DPRINT("RV350"); break;	
		case CHIP_FAMILY_RV380: DPRINT("RV380"); break;	
		case CHIP_FAMILY_R420: DPRINT("R420"); break;	
		default: DPRINT("UNKNOW"); break;
	}	
	DPRINTVAL(" found ",rinfo->video_ram / 1024);
	DPRINT("KB of ");
	DPRINTVAL(rinfo->vram_ddr ? "DDR " : "SDRAM ",rinfo->vram_width);
	DPRINT(" bits wide videoram\r\n");
}

int radeonfb_pci_register(long handle, const struct pci_device_id *ent)
{
	struct fb_info *info;
	struct radeonfb_info *rinfo;
	PCI_RSC_DESC *pci_rsc_desc;
#ifndef PCI_XBIOS
  PCI_COOKIE *bios_cookie;
#endif
	info_fvdi = info = framebuffer_alloc(sizeof(struct radeonfb_info));
	if(!info)
		return(-ENOMEM);
	rinfo = info->par;
	rinfo->info = info;
	rinfo->handle = handle;
	Funcs_copy("ATI Radeon XX ", rinfo->name);
	rinfo->name[11] = (char)(ent->device >> 8);
	rinfo->name[12] = (char)ent->device;
	rinfo->family = ent->driver_data & CHIP_FAMILY_MASK;
	rinfo->chipset = ent->device;
	rinfo->has_CRTC2 = (ent->driver_data & CHIP_HAS_CRTC2) != 0;
	rinfo->is_mobility = (ent->driver_data & CHIP_IS_MOBILITY) != 0;
	rinfo->is_IGP = (ent->driver_data & CHIP_IS_IGP) != 0;
	/* Set base addrs */
	DPRINT("radeonfb: radeonfb_pci_register: Set base addrs\r\n");
	rinfo->fb_base_phys = rinfo->mmio_base_phys = rinfo->io_base_phys = 0xFFFFFFFF;
	rinfo->mapped_vram = 0;
	rinfo->mmio_base = rinfo->io_base = NULL;
	rinfo->bios_seg = NULL;
#ifdef PCI_XBIOS
	pci_rsc_desc = (PCI_RSC_DESC *)get_resource(handle);
#else
	bios_cookie = (PCI_COOKIE *)Funcs_get_cookie((void *)"_PCI",Super(1));
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
			DPRINTVALHEX("radeonfb: flags ", pci_rsc_desc->flags);
			DPRINTVALHEX(" start ", pci_rsc_desc->start);
			DPRINTVALHEX(" offset ", pci_rsc_desc->offset);
			DPRINTVALHEX(" length ", pci_rsc_desc->length);
			DPRINT("\r\n");
			if(!(pci_rsc_desc->flags & FLG_IO))
			{
				if((rinfo->fb_base_phys == 0xFFFFFFFF) && (pci_rsc_desc->length >= 0x100000))
				{
					rinfo->fb_base = (void *)(pci_rsc_desc->offset + pci_rsc_desc->start);
					rinfo->fb_base_phys = pci_rsc_desc->start;
					rinfo->mapped_vram = pci_rsc_desc->length;
//					rinfo->dma_offset = pci_rsc_desc->dmaoffset;
					if((pci_rsc_desc->flags & FLG_ENDMASK) == ORD_MOTOROLA)
					{
						rinfo->big_endian = 0; /* host bridge make swapping intel -> motorola */
						DPRINT("radeonfb: host bridge is big endian\r\n");
					}
					else
					{
						rinfo->big_endian = 1; /* radeon make swapping intel -> motorola */
						DPRINT("radeonfb: host bridge is little endian\r\n");
					}
				}
				else if((pci_rsc_desc->length >= RADEON_REGSIZE)
				 && (pci_rsc_desc->length < 0x100000))
				{
					if(rinfo->bios_seg == NULL)
					{
						rinfo->bios_seg_phys = pci_rsc_desc->start;
						if(BIOS_IN16(0) == 0xaa55)
							rinfo->bios_seg = (void *)(pci_rsc_desc->offset + pci_rsc_desc->start);
						else
							rinfo->bios_seg_phys = 0;
					}
					if(rinfo->mmio_base_phys == 0xFFFFFFFF)
					{		
						rinfo->mmio_base = (void *)(pci_rsc_desc->offset + pci_rsc_desc->start);
						rinfo->mmio_base_phys = pci_rsc_desc->start;
					}
				}
			}
			else
			{
				if(rinfo->io_base_phys == 0xFFFFFFFF)
				{		
					rinfo->io_base = (void *)(pci_rsc_desc->offset + pci_rsc_desc->start);
					rinfo->io_base_phys = pci_rsc_desc->start;
				}
			}
			flags = pci_rsc_desc->flags;
			pci_rsc_desc = (PCI_RSC_DESC *)((unsigned long)pci_rsc_desc->next + (unsigned long)pci_rsc_desc);
		}
		while(!(flags & FLG_LAST));
	}
	else
		DPRINT("radeonfb: radeonfb_pci_register: get_resource error\r\n");

	/* map the regions */
	DPRINT("radeonfb: radeonfb_pci_register: map the regions\r\n");
	if(rinfo->mmio_base == NULL)
	{
		DPRINT("radeonfb: cannot map MMIO\r\n");
		framebuffer_release(info);
		return(-EIO);	
	}
	DPRINTVALHEX("radeonfb: radeonfb_pci_register: mmio_base_phys ", rinfo->mmio_base_phys);
	DPRINTVALHEX(" mmio_base ", (unsigned long)rinfo->mmio_base);
	DPRINT("\r\n");
	DPRINTVALHEX("radeonfb: radeonfb_pci_register: io_base_phys ", rinfo->io_base_phys);
	DPRINTVALHEX(" io_base ", (unsigned long)rinfo->io_base);
	DPRINT("\r\n");
	DPRINTVALHEX("radeonfb: radeonfb_pci_register: fb_base_phys ", rinfo->fb_base_phys);
	DPRINTVALHEX(" fb_base ", (unsigned long)rinfo->fb_base);
	DPRINT("\r\n");

	/*
	 * Check for errata
	 */
	DPRINT("radeonfb: radeonfb_pci_register: check for errata\r\n");
	rinfo->errata = 0;
	if(rinfo->family == CHIP_FAMILY_R300
	 && (INREG(CONFIG_CNTL) & CFG_ATI_REV_ID_MASK) == CFG_ATI_REV_A11)
		rinfo->errata |= CHIP_ERRATA_R300_CG;
	if(rinfo->family == CHIP_FAMILY_RV200 || rinfo->family == CHIP_FAMILY_RS200)
		rinfo->errata |= CHIP_ERRATA_PLL_DUMMYREADS;
	if(rinfo->family == CHIP_FAMILY_RV100
	 || rinfo->family == CHIP_FAMILY_RS100
	 || rinfo->family == CHIP_FAMILY_RS200)
		rinfo->errata |= CHIP_ERRATA_PLL_DELAY;

	/*
	 * Map the BIOS ROM if any and retreive PLL parameters from
	 * the BIOS.
	 */
	DPRINTVALHEX("radeonfb: radeonfb_pci_register: bios_seg_phys ", rinfo->bios_seg_phys);
	DPRINTVALHEX(" bios_seg ", (unsigned long)rinfo->bios_seg);
	DPRINT("\r\n");
	DPRINT("radeonfb: radeonfb_pci_register: Map the BIOS ROM\r\n");
	radeon_map_ROM(rinfo);

#ifdef DRIVER_IN_ROM
	/* Run VGA BIOS */
	if(rinfo->bios_seg != NULL)
	{
		Cconws("Run VGA BIOS, please wait...\r\n");
		DPRINT("radeonfb: radeonfb_pci_register: run VGA BIOS\r\n");
		run_bios(rinfo);
	}
#endif

#if 1
	DPRINT("radeonfb: radeonfb_pci_register: fixup display base address\r\n");
	OUTREG(MC_FB_LOCATION, 0x7fff0000);
	rinfo->fb_local_base = 0;
	/* Fixup the display base addresses & engine offsets while we
	 * are at it as well
	 */
	OUTREG(DISPLAY_BASE_ADDR, 0);
	if(rinfo->has_CRTC2)
		OUTREG(CRTC2_DISPLAY_BASE_ADDR, 0);
	OUTREG(OV0_BASE_ADDR, 0);
#else
	rinfo->fb_local_base = INREG(MC_FB_LOCATION) << 16;
#endif

	/* Get VRAM size and type */
	DPRINT("radeonfb: radeonfb_pci_register: get VRAM size\r\n");
	radeon_identify_vram(rinfo);

	if((rinfo->fb_base == NULL)
	 || ((rinfo->video_ram > rinfo->mapped_vram) && (rinfo->mapped_vram < MIN_MAPPED_VRAM*2)))
	{
		DPRINTVAL("radeonfb: cannot map FB, video ram: ",rinfo->mapped_vram / 1024);
		DPRINT("KB\r\n");
		framebuffer_release(info);
		return(-EIO);
	}

	/* Get informations about the board's PLL */
	DPRINT("radeonfb: radeonfb_pci_register: get informations about the board's PLL\r\n");
	radeon_get_pllinfo(rinfo);

#ifdef CONFIG_FB_RADEON_I2C
	/* Register I2C bus */
	DPRINT("radeonfb: radeonfb_pci_register: register I2C bus\r\n");
	radeon_create_i2c_busses(rinfo);
#endif /* CONFIG_FB_RADEON_I2C */

	/* set all the vital stuff */
	DPRINT("radeonfb: radeonfb_pci_register: set all the vital stuff\r\n");
	radeon_set_fbinfo(rinfo);

	/* set offscreen memory descriptor */
	DPRINT("radeonfb: radeonfb_pci_register: set offscreen memory descriptor\r\n");
	offscreen_init(info);
	
	/* Probe screen types */
	DPRINT("radeonfb: radeonfb_pci_register: probe screen types, monitor_layout: ");
	DPRINT(monitor_layout);
	DPRINT("\r\n");
	radeon_probe_screens(rinfo, monitor_layout, (int)ignore_edid);

	/* Build mode list, check out panel native model */
	DPRINT("radeonfb: radeonfb_pci_register: build mode list\r\n");
	radeon_check_modes(rinfo, &resolution);

	/* save current mode regs before we switch into the new one
	 * so we can restore this upon exit
	 */
	DPRINT("radeonfb: radeonfb_pci_register: save current mode\r\n");
	radeon_save_state(rinfo, &rinfo->init_state);
	memcpy(&rinfo->state, &rinfo->init_state, sizeof(struct radeon_regs));

	/* Setup Power Management capabilities */
//	DPRINT("radeonfb: radeonfb_pci_register: setup power management\r\n");
//	radeonfb_pm_init(rinfo, (int)default_dynclk);

	DPRINT("radeonfb: radeonfb_pci_register: install VBL timer\r\n");
	rinfo->lvds_timer = 0;
#ifndef DRIVER_IN_ROM
	install_vbl_timer(radeon_timer_func, 1); /* remove old vector */ 
#else
	install_vbl_timer(radeon_timer_func, 0);
#endif
	rinfo->RageTheatreCrystal = rinfo->RageTheatreTunerPort=rinfo->RageTheatreCompositePort = rinfo->RageTheatreSVideoPort = -1;
	rinfo->tunerType = -1;
	return(0);
}

#if 0

void radeonfb_pci_unregister(void)
{
	struct fb_info *info = info_fvdi;
	struct radeonfb_info *rinfo = info->par;
//	radeonfb_pm_exit(rinfo);
	uninstall_vbl_timer(radeon_timer_func);
	if(rinfo->mon1_EDID!=NULL)
		Funcs_free(rinfo->mon1_EDID);
	if(rinfo->mon2_EDID!=NULL)
		Funcs_free(rinfo->mon2_EDID);
	if(rinfo->mon1_modedb)
		fb_destroy_modedb(rinfo->mon1_modedb);
#ifdef CONFIG_FB_RADEON_I2C
	radeon_delete_i2c_busses(rinfo);
#endif        
	framebuffer_release(info);
}

#endif


