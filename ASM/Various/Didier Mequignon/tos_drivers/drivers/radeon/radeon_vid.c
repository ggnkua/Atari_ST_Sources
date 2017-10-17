/*
   radeon_vid - VIDIX based video driver for Radeon chips
   Copyrights 2002 Nick Kurshev. This file is based on sources from
   GATOS (gatos.sf.net) and X11 (www.xfree86.org)
   Licence: GPL

   31.12.2002 added support for fglrx drivers by Marcel Naziri (zwobbl@zwobbl.de)
   6.04.2004 fixes to allow compiling vidix without X11 (broken in original patch)
   PPC support by Alex Beregszaszi
*/

#define __KERNEL__ // for negative errors
#include <errno.h>
#include "fb.h"
#include "radeonfb.h"
#include "ati_ids.h"
#include "vidix.h"
#include "fourcc.h"

#undef radeon_engine_flush

extern long Isin(long x);
extern long Icos(long x);
extern long c_get_width(void);
extern long c_get_height(void);
extern long c_get_width_virtual(void);
extern long c_get_height_virtual(void);
extern long c_get_bpp(void);
extern unsigned long swap_long(unsigned long val);
extern struct fb_info *info_fvdi;

#define radeon_vid_get_dbpp c_get_bpp
#define radeon_get_xres c_get_width
#define radeon_get_yres c_get_height

#define X_ADJUST (besr.is_shift_required ? 8 : 0)

extern void blit_copy(unsigned char *src_addr, int src_line_add, unsigned char *dst_addr, int dst_line_add, int w, int h, int bpp);
extern int blit_copy_ok(void);

typedef struct
{
	unsigned long framebuf_offset;
	unsigned long sys_addr;
	unsigned long command;
	unsigned long reserved;
} bm_list_descriptor;

typedef struct bes_registers_s
{
	/* base address of yuv framebuffer */
	unsigned long yuv_base;
	unsigned long fourcc;
	unsigned long surf_id;
  int load_prg_start;
  int horz_pick_nearest;
  int vert_pick_nearest;
  int swap_uv; /* for direct support of bgr fourccs */
	unsigned long dest_bpp;
	/* YUV BES registers */
	unsigned long reg_load_cntl;
	unsigned long h_inc;
	unsigned long step_by;
	unsigned long y_x_start;
	unsigned long y_x_end;
	unsigned long v_inc;
	unsigned long p1_blank_lines_at_top;
	unsigned long p23_blank_lines_at_top;
	unsigned long vid_buf_pitch0_value;
	unsigned long vid_buf_pitch1_value;
	unsigned long p1_x_start_end;
	unsigned long p2_x_start_end;
	unsigned long p3_x_start_end;
	unsigned long base_addr;
	unsigned long vid_buf_base_adrs_y[VID_PLAY_MAXFRAMES];
	unsigned long vid_buf_base_adrs_u[VID_PLAY_MAXFRAMES];
	unsigned long vid_buf_base_adrs_v[VID_PLAY_MAXFRAMES];
	unsigned long vid_nbufs;
	unsigned long p1_v_accum_init;
	unsigned long p1_h_accum_init;
	unsigned long p23_v_accum_init;
	unsigned long p23_h_accum_init;
	unsigned long scale_cntl;
	unsigned long exclusive_horz;
	unsigned long auto_flip_cntl;
	unsigned long filter_cntl;
  unsigned long four_tap_coeff[5];
	unsigned long key_cntl;
	unsigned long test;
	/* Configurable stuff */
	int double_buff;
	int brightness;
	int saturation;
	int ckey_on;
	unsigned long graphics_key_clr;
	unsigned long graphics_key_msk;
	unsigned long ckey_cntl;
  unsigned long merge_cntl;
	int deinterlace_on;
	unsigned long deinterlace_pattern;
  unsigned family;
  unsigned mobility;
	int is_shift_required;
	int big_endian;
} bes_registers_t;

static bes_registers_t besr;
static unsigned short vendor_id;
static unsigned short device_id;
static void *radeon_mmio_base;
static void *radeon_mem_base;
static unsigned long radeon_mem_base_phys;
static unsigned long radeon_overlay_off;
static unsigned long radeon_ram_size;
#ifdef VIDIX_ENABLE_BM
static void *radeon_dma_desc_base[VID_PLAY_MAXFRAMES];
static unsigned long *dma_phys_addrs;
static unsigned long host_mem_base_phys;
#endif
/* Restore on exit */
static unsigned long SAVED_OV0_GRAPHICS_KEY_CLR;
static unsigned long SAVED_OV0_GRAPHICS_KEY_MSK;
static unsigned long SAVED_OV0_VID_KEY_CLR;
static unsigned long SAVED_OV0_VID_KEY_MSK;
static unsigned long SAVED_OV0_KEY_CNTL;
static unsigned long SAVED_DISP_MERGE_CNTL;
static unsigned long SAVED_CONFIG_CNTL;

static unsigned long inreg(unsigned long addr)
{
	struct radeonfb_info *rinfo = info_fvdi->par;
	return(INREG(addr));
}

static void outreg(unsigned long addr, unsigned long val)
{
	struct radeonfb_info *rinfo = info_fvdi->par;
	OUTREG(addr,val);
}

#undef INREG
#define INREG inreg
#undef OUTREG
#define OUTREG outreg

static const float cste_ceil_floor = 0.99999999999999999999;

static float ceil(float val)
{
	long temp = (long)val;
	if(temp >= 0)
		temp = (long)(val + cste_ceil_floor);
	return((float)temp);
}

static float floor(float val)
{
	long temp = (long)val;
	if(temp <= 0)
		temp = (long)(val - cste_ceil_floor);
	return((float)temp);
}

#if 0

static inline unsigned long INPLL(unsigned long addr)
{
	struct radeonfb_info *rinfo = info_fvdi->par;
	OUTREG8(CLOCK_CNTL_INDEX, addr & 0x0000001f);
	return(INREG(CLOCK_CNTL_DATA));
}

#define OUTPLL(addr,val) OUTREG8(CLOCK_CNTL_INDEX, (addr & 0x0000001f) | 0x00000080); \
				OUTREG(CLOCK_CNTL_DATA, val)
#define OUTPLLP(addr,val,mask)  					\
	do {								\
		unsigned int _tmp = INPLL(addr);			\
		_tmp &= (mask);						\
		_tmp |= (val);						\
		OUTPLL(addr, _tmp);					\
	} while(0)

static unsigned long radeon_vid_get_dbpp(void)
{
	struct radeonfb_info *rinfo = info_fvdi->par;
	unsigned long dbpp,retval;
	dbpp = (INREG(CRTC_GEN_CNTL) >> 8) & 0xF;
	switch(dbpp)
	{
		case DST_8BPP: retval = 8; break;
		case DST_15BPP: retval = 15; break;
		case DST_16BPP: retval = 16; break;
		case DST_24BPP: retval = 24; break;
		default: retval=32; break;
	}
	return(retval);
}

static unsigned long radeon_get_xres(void)
{
	/* FIXME: currently we extract that from CRTC!!!*/
	struct radeonfb_info *rinfo = info_fvdi->par;
	unsigned long xres, h_total;
	h_total = INREG(CRTC_H_TOTAL_DISP);
	xres = (h_total >> 16) & 0xffff;
	return((xres + 1) * 8);
}

static unsigned long radeon_get_yres(void)
{
	/* FIXME: currently we extract that from CRTC!!!*/
	struct radeonfb_info *rinfo = info_fvdi->par;
	unsigned long yres, v_total;
	v_total = INREG(CRTC_V_TOTAL_DISP);
	yres = (v_total >> 16) & 0xffff;
	return(yres + 1);
}
#endif

static int radeon_is_dbl_scan(void)
{
  return((INREG(CRTC_GEN_CNTL)) & CRTC_DBL_SCAN_EN);
}

static int radeon_is_interlace(void)
{
	return((INREG(CRTC_GEN_CNTL)) & CRTC_INTERLACE_EN);
}

static void radeon_wait_vsync(void)
{
	int i;
	OUTREG(GEN_INT_STATUS, VSYNC_INT_AK);
	for(i = 0; i < 2000000; i++) 
	{
		if(INREG(GEN_INT_STATUS) & VSYNC_INT)
			break;
	}
}

static inline void radeon_engine_flush(void)
{
	struct radeonfb_info *rinfo = info_fvdi->par;
	int i;
	/* initiate flush */
	OUTREGP(RB2D_DSTCACHE_CTLSTAT, RB2D_DC_FLUSH_ALL, ~RB2D_DC_FLUSH_ALL);
	for(i=0; i < 2000000; i++)
	{
		if(!(INREG(RB2D_DSTCACHE_CTLSTAT) & RB2D_DC_BUSY))
			break;
	}
}

static void _radeon_engine_idle(void);
static void _radeon_fifo_wait(unsigned);
#undef radeon_engine_idle
#undef radeon_fifo_wait
#define radeon_engine_idle()		_radeon_engine_idle()
#define radeon_fifo_wait(entries)	_radeon_fifo_wait(entries)

static void radeon_engine_reset(void)
{
	struct radeonfb_info *rinfo = info_fvdi->par;
	unsigned long clock_cntl_index, mclk_cntl, rbbm_soft_reset;
	radeon_engine_flush();
	clock_cntl_index = INREG(CLOCK_CNTL_INDEX);
	mclk_cntl = INPLL(MCLK_CNTL);
	OUTPLL(MCLK_CNTL, (mclk_cntl | FORCEON_MCLKA | FORCEON_MCLKB | FORCEON_YCLKA | FORCEON_YCLKB | FORCEON_MC | FORCEON_AIC));
	rbbm_soft_reset = INREG(RBBM_SOFT_RESET);
	OUTREG(RBBM_SOFT_RESET, rbbm_soft_reset | SOFT_RESET_CP | SOFT_RESET_HI |	SOFT_RESET_SE | SOFT_RESET_RE | SOFT_RESET_PP | SOFT_RESET_E2 | SOFT_RESET_RB | SOFT_RESET_HDP);
	INREG(RBBM_SOFT_RESET);
	OUTREG(RBBM_SOFT_RESET, rbbm_soft_reset & (unsigned long)
	 ~(SOFT_RESET_CP | SOFT_RESET_HI | SOFT_RESET_SE | SOFT_RESET_RE | SOFT_RESET_PP | SOFT_RESET_E2 | SOFT_RESET_RB | SOFT_RESET_HDP));
	INREG(RBBM_SOFT_RESET);
	OUTPLL(MCLK_CNTL, mclk_cntl);
	OUTREG(CLOCK_CNTL_INDEX, clock_cntl_index);
	OUTREG(RBBM_SOFT_RESET, rbbm_soft_reset);
}

static void radeon_engine_restore(void)
{
	struct radeonfb_info *rinfo = info_fvdi->par;
	int pitch64;
	unsigned long xres,yres,bpp;
	radeon_fifo_wait(1);
	xres = radeon_get_xres();
	yres = radeon_get_yres();
	bpp = radeon_vid_get_dbpp();
	/* turn of all automatic flushing - we'll do it all */
	OUTREG(RB2D_DSTCACHE_MODE, 0);
	pitch64 = ((xres * (bpp / 8) + 0x3f)) >> 6;
	radeon_fifo_wait(1);
	OUTREG(DEFAULT_OFFSET, (INREG(DEFAULT_OFFSET) & 0xC0000000) | (pitch64 << 22));
	radeon_fifo_wait(1);
	if(besr.big_endian)
    OUTREGP(DP_DATATYPE, HOST_BIG_ENDIAN_EN, ~HOST_BIG_ENDIAN_EN);
	else
    OUTREGP(DP_DATATYPE, 0, ~HOST_BIG_ENDIAN_EN);
	radeon_fifo_wait(1);
	OUTREG(DEFAULT_SC_BOTTOM_RIGHT, (DEFAULT_SC_RIGHT_MAX | DEFAULT_SC_BOTTOM_MAX));
	radeon_fifo_wait(1);
	OUTREG(DP_GUI_MASTER_CNTL, (INREG(DP_GUI_MASTER_CNTL) | GMC_BRUSH_SOLID_COLOR | GMC_SRC_DATATYPE_COLOR));
	radeon_fifo_wait(7);
	OUTREG(DST_LINE_START, 0);
	OUTREG(DST_LINE_END, 0);
	OUTREG(DP_BRUSH_FRGD_CLR, 0xffffffff);
	OUTREG(DP_BRUSH_BKGD_CLR, 0x00000000);
	OUTREG(DP_SRC_FRGD_CLR, 0xffffffff);
	OUTREG(DP_SRC_BKGD_CLR, 0x00000000);
	OUTREG(DP_WRITE_MASK, 0xffffffff);
	radeon_engine_idle();
}

static void _radeon_fifo_wait(unsigned entries)
{
	unsigned i;
	while(1)
	{
		for(i=0; i<2000000; i++)
		if((INREG(RBBM_STATUS) & RBBM_FIFOCNT_MASK) >= entries)
			return;
		radeon_engine_reset();
		radeon_engine_restore();
	}
}

static void _radeon_engine_idle(void)
{
	int i;
	/* ensure FIFO is empty before waiting for idle */
	radeon_fifo_wait(64);
	while(1)
	{
		for(i=0; i<2000000; i++)
		{
			if(((INREG(RBBM_STATUS) & RBBM_ACTIVE)) == 0)
			{
				radeon_engine_flush();
				return;
			}
		}
		radeon_engine_reset();
		radeon_engine_restore();
	}
}

/* Reference color space transform data */
typedef struct tagREF_TRANSFORM
{
	float RefLuma;
	float RefRCb;
	float RefRCr;
	float RefGCb;
	float RefGCr;
	float RefBCb;
	float RefBCr;
} REF_TRANSFORM;

/* Parameters for ITU-R BT.601 and ITU-R BT.709 colour spaces */
REF_TRANSFORM trans[2] =
{
	{1.1678, 0.0, 1.6007, -0.3929, -0.8154, 2.0232, 0.0}, /* BT.601 */
	{1.1678, 0.0, 1.7980, -0.2139, -0.5345, 2.1186, 0.0}  /* BT.709 */
};

/****************************************************************************
 * SetTransform                                                             *
 *  Function: Calculates and sets color space transform from supplied       *
 *            reference transform, gamma, brightness, contrast, hue and     *
 *            saturation.                                                   *
 *    Inputs: bright - brightness                                           *
 *            cont - contrast                                               *
 *            sat - saturation                                              *
 *            hue - hue                                                     *
 *            red_intensity - intense of red component                      *
 *            green_intensity - intense of green component                  *
 *            blue_intensity - intense of blue component                    *
 *            ref - index to the table of refernce transforms               *
 *   Outputs: NONE                                                          *
 ****************************************************************************/
static void radeon_set_transform(float bright, float cont, float sat, float hue,
 float red_intensity, float green_intensity,float blue_intensity, unsigned ref)
{
	float OvHueSin, OvHueCos;
	float CAdjLuma,CAdjOff;
	float RedAdj,GreenAdj,BlueAdj;
	float CAdjRCb, CAdjRCr;
	float CAdjGCb, CAdjGCr;
	float CAdjBCb, CAdjBCr;
	float OvLuma, OvROff, OvGOff, OvBOff;
	float OvRCb, OvRCr;
	float OvGCb, OvGCr;
	float OvBCb, OvBCr;
	float Loff = 64.0;
	float Coff = 512.0f;
	long angle;
	unsigned long dwOvLuma, dwOvROff, dwOvGOff, dwOvBOff;
	unsigned long dwOvRCb, dwOvRCr;
	unsigned long dwOvGCb, dwOvGCr;
	unsigned long dwOvBCb, dwOvBCr;
	if(ref >= 2)
		return;
	angle = (long)((hue / 3.14159265358979323846) * 1800.0);
	if(angle < 0)
		angle += 1800;
	OvHueSin = (float)Isin(angle) / 32767.0;
	OvHueCos = (float)Icos(angle) / 32767.0;
	CAdjLuma = cont * trans[ref].RefLuma;
	CAdjOff = cont * trans[ref].RefLuma * bright * 1023.0;
	RedAdj = cont * trans[ref].RefLuma * red_intensity * 1023.0;
	GreenAdj = cont * trans[ref].RefLuma * green_intensity * 1023.0;
	BlueAdj = cont * trans[ref].RefLuma * blue_intensity * 1023.0;
	CAdjRCb = sat * -OvHueSin * trans[ref].RefRCr;
	CAdjRCr = sat * OvHueCos * trans[ref].RefRCr;
	CAdjGCb = sat * (OvHueCos * trans[ref].RefGCb - OvHueSin * trans[ref].RefGCr);
	CAdjGCr = sat * (OvHueSin * trans[ref].RefGCb + OvHueCos * trans[ref].RefGCr);
	CAdjBCb = sat * OvHueCos * trans[ref].RefBCb;
	CAdjBCr = sat * OvHueSin * trans[ref].RefBCb;
#if 0 /* default constants */
	CAdjLuma = 1.16455078125;
	CAdjRCb = 0.0;
	CAdjRCr = 1.59619140625;
	CAdjGCb = -0.39111328125;
	CAdjGCr = -0.8125;
	CAdjBCb = 2.01708984375;
	CAdjBCr = 0;
#endif
	OvLuma = CAdjLuma;
	OvRCb = CAdjRCb;
	OvRCr = CAdjRCr;
	OvGCb = CAdjGCb;
	OvGCr = CAdjGCr;
	OvBCb = CAdjBCb;
	OvBCr = CAdjBCr;
	OvROff = RedAdj + CAdjOff - OvLuma * Loff - (OvRCb + OvRCr) * Coff;
	OvGOff = GreenAdj + CAdjOff - OvLuma * Loff - (OvGCb + OvGCr) * Coff;
	OvBOff = BlueAdj + CAdjOff - OvLuma * Loff - (OvBCb + OvBCr) * Coff;
#if 0 /* default constants */
	OvROff = -888.5;
	OvGOff = 545;
	OvBOff = -1104;
#endif 
	dwOvROff = ((int)(OvROff * 2.0)) & 0x1fff;
	dwOvGOff = (int)(OvGOff * 2.0) & 0x1fff;
	dwOvBOff = (int)(OvBOff * 2.0) & 0x1fff;
	/* Whatever docs say about R200 having 3.8 format instead of 3.11 as in Radeon is a lie */
#if 0
	if(!IsR200)
	{
#endif
		dwOvLuma =(((int)(OvLuma * 2048.0))&0x7fff)<<17;
		dwOvRCb = (((int)(OvRCb * 2048.0))&0x7fff)<<1;
		dwOvRCr = (((int)(OvRCr * 2048.0))&0x7fff)<<17;
		dwOvGCb = (((int)(OvGCb * 2048.0))&0x7fff)<<1;
		dwOvGCr = (((int)(OvGCr * 2048.0))&0x7fff)<<17;
		dwOvBCb = (((int)(OvBCb * 2048.0))&0x7fff)<<1;
		dwOvBCr = (((int)(OvBCr * 2048.0))&0x7fff)<<17;
#if 0
	}
	else
	{
		dwOvLuma = (((int)(OvLuma * 256.0))&0x7ff)<<20;
		dwOvRCb = (((int)(OvRCb * 256.0))&0x7ff)<<4;
		dwOvRCr = (((int)(OvRCr * 256.0))&0x7ff)<<20;
		dwOvGCb = (((int)(OvGCb * 256.0))&0x7ff)<<4;
		dwOvGCr = (((int)(OvGCr * 256.0))&0x7ff)<<20;
		dwOvBCb = (((int)(OvBCb * 256.0))&0x7ff)<<4;
		dwOvBCr = (((int)(OvBCr * 256.0))&0x7ff)<<20;
	}
#endif
	OUTREG(OV0_LIN_TRANS_A, dwOvRCb | dwOvLuma);
	OUTREG(OV0_LIN_TRANS_B, dwOvROff | dwOvRCr);
	OUTREG(OV0_LIN_TRANS_C, dwOvGCb | dwOvLuma);
	OUTREG(OV0_LIN_TRANS_D, dwOvGOff | dwOvGCr);
	OUTREG(OV0_LIN_TRANS_E, dwOvBCb | dwOvLuma);
	OUTREG(OV0_LIN_TRANS_F, dwOvBOff | dwOvBCr);
}

/* Gamma curve definition */
typedef struct 
{
	unsigned int gammaReg;
	unsigned int gammaSlope;
	unsigned int gammaOffset;
} GAMMA_SETTINGS;

/* Recommended gamma curve parameters */
GAMMA_SETTINGS r200_def_gamma[18] = 
{
	{OV0_GAMMA_0_F, 0x100, 0x0000},
	{OV0_GAMMA_10_1F, 0x100, 0x0020},
	{OV0_GAMMA_20_3F, 0x100, 0x0040},
	{OV0_GAMMA_40_7F, 0x100, 0x0080},
	{OV0_GAMMA_80_BF, 0x100, 0x0100},
	{OV0_GAMMA_C0_FF, 0x100, 0x0100},
	{OV0_GAMMA_100_13F, 0x100, 0x0200},
	{OV0_GAMMA_140_17F, 0x100, 0x0200},
	{OV0_GAMMA_180_1BF, 0x100, 0x0300},
	{OV0_GAMMA_1C0_1FF, 0x100, 0x0300},
	{OV0_GAMMA_200_23F, 0x100, 0x0400},
	{OV0_GAMMA_240_27F, 0x100, 0x0400},
	{OV0_GAMMA_280_2BF, 0x100, 0x0500},
	{OV0_GAMMA_2C0_2FF, 0x100, 0x0500},
	{OV0_GAMMA_300_33F, 0x100, 0x0600},
	{OV0_GAMMA_340_37F, 0x100, 0x0600},
	{OV0_GAMMA_380_3BF, 0x100, 0x0700},
	{OV0_GAMMA_3C0_3FF, 0x100, 0x0700}
};

GAMMA_SETTINGS r100_def_gamma[6] = 
{
	{OV0_GAMMA_0_F, 0x100, 0x0000},
	{OV0_GAMMA_10_1F, 0x100, 0x0020},
	{OV0_GAMMA_20_3F, 0x100, 0x0040},
	{OV0_GAMMA_40_7F, 0x100, 0x0080},
	{OV0_GAMMA_380_3BF, 0x100, 0x0100},
	{OV0_GAMMA_3C0_3FF, 0x100, 0x0100}
};

void make_default_gamma_correction(void)
{
	unsigned long i;
	if((besr.family == CHIP_FAMILY_RADEON) || (besr.family == CHIP_FAMILY_RV100) || (besr.family == CHIP_FAMILY_RV200))
	{
		OUTREG(OV0_LIN_TRANS_A, 0x12A00000);
		OUTREG(OV0_LIN_TRANS_B, 0x199018FE);
		OUTREG(OV0_LIN_TRANS_C, 0x12A0F9B0);
		OUTREG(OV0_LIN_TRANS_D, 0xF2F0043B);
		OUTREG(OV0_LIN_TRANS_E, 0x12A02050);
		OUTREG(OV0_LIN_TRANS_F, 0x0000174E);
		for(i=0; i<6; i++)
			OUTREG(r100_def_gamma[i].gammaReg, (r100_def_gamma[i].gammaSlope<<16) | r100_def_gamma[i].gammaOffset);
	}
	else
	{
		OUTREG(OV0_LIN_TRANS_A, 0x12a00000);
		OUTREG(OV0_LIN_TRANS_B, 0x1990190e);
		OUTREG(OV0_LIN_TRANS_C, 0x12a0f9c0);
		OUTREG(OV0_LIN_TRANS_D, 0xf3000442);
		OUTREG(OV0_LIN_TRANS_E, 0x12a02040);
		OUTREG(OV0_LIN_TRANS_F, 0x175f);
		/*
		Default Gamma,
	  Of 18 segments for gamma cure, all segments in R200 are programmable,
		while only lower 4 and upper 2 segments are programmable in Radeon
		*/
		for(i=0; i<18; i++)
			OUTREG(r200_def_gamma[i].gammaReg, (r200_def_gamma[i].gammaSlope<<16) | r200_def_gamma[i].gammaOffset);
	}
}
	
static void radeon_vid_make_default(void)
{
	make_default_gamma_correction();
	besr.deinterlace_pattern = 0x900AAAAA;
	OUTREG(OV0_DEINTERLACE_PATTERN,besr.deinterlace_pattern);
	besr.deinterlace_on=1;
	besr.double_buff=1;
	besr.ckey_on=0;
	besr.graphics_key_msk=0;
	besr.graphics_key_clr=0;
	besr.ckey_cntl = VIDEO_KEY_FN_TRUE|GRAPHIC_KEY_FN_TRUE|CMP_MIX_AND;
}

unsigned vixGetVersion(void)
{
//	DPRINT("VIDIX: vixGetVersion\r\n");
	return(VIDIX_VERSION);
}

vidix_capability_t def_cap = 
{
	"BES driver for Radeon cards",
	"Nick Kurshev",
	TYPE_OUTPUT | TYPE_FX,
	{ 0, 0, 0, 0 },
	2048,
	2048,
	4,
	4,
	-1,
	FLAG_UPSCALER | FLAG_DOWNSCALER | FLAG_EQUALIZER,
	PCI_VENDOR_ID_ATI,
	0,
	{ 0, 0, 0, 0}
};

int vixProbe(int verbose,int force)
{
	struct radeonfb_info *rinfo = info_fvdi->par;
#ifdef VIDIX_ENABLE_BM
	PCI_RSC_DESC *pci_rsc_desc;
	unsigned long temp;
	short index;
	long handle;
#endif
//	DPRINT("VIDIX: vixProbe\r\n");
	if(verbose);
	if(force);
	radeon_mmio_base = rinfo->mmio_base;
  radeon_ram_size = rinfo->video_ram;
	radeon_mem_base = rinfo->fb_base;
	radeon_mem_base_phys = rinfo->fb_base_phys;
#ifdef VIDIX_ENABLE_BM
	host_mem_base_phys=0;
	if(read_config_longword(rinfo->handle,PCIIDR,&temp) >= 0)
	{
		vendor_id = (unsigned short)temp;
		device_id = (unsigned short)(temp>>16);
	}
	index=0; /* search host bridge */
	do
	{
		handle = find_pci_device(0x0000FFFFL,index++);
		if(handle >= 0)
		{
			if((read_config_longword(handle,PCIREV,&temp) >= 0)
			 && ((temp>>16) == PCI_CLASS_BRIDGE_OTHER))
			{
				pci_rsc_desc = (PCI_RSC_DESC *)get_resource(handle);
				if(pci_rsc_desc>=0)
				{
					unsigned short flags;
					do
					{
						if(!(pci_rsc_desc->flags & FLG_IO))
							host_mem_base_phys = pci_rsc_desc->start;
						flags = pci_rsc_desc->flags;
			 			(unsigned long)pci_rsc_desc += (unsigned long)pci_rsc_desc->next;
					}
					while(!(flags & FLG_LAST));
					return(0);
				}
			}
		}    
	}
	while(handle>=0);
	return(ENXIO);
#else
	return(0);
#endif
}

int vixInit(void)
{
#ifdef VIDIX_ENABLE_BM
	int i;
	unsigned long offset;
#endif
	struct radeonfb_info *rinfo = info_fvdi->par;
//	DPRINT("VIDIX: vixInit\r\n");
	radeon_mmio_base = rinfo->mmio_base;
  radeon_ram_size = rinfo->video_ram;
	radeon_mem_base = rinfo->fb_base;
	radeon_mem_base_phys = rinfo->fb_base_phys;
	radeon_overlay_off = 0;
	memset(&besr,0,sizeof(bes_registers_t));
	besr.family = (unsigned)rinfo->family;
	besr.mobility = (unsigned )rinfo->is_mobility;
	besr.big_endian = (int)rinfo->big_endian;
	radeon_vid_make_default();
#ifdef VIDIX_ENABLE_BM
//	dma_phys_addrs = (unsigned long *)Mxalloc((4096*VID_PLAY_MAXFRAMES)+4095,3);
  dma_phys_addrs = (unsigned long *)((unsigned long)radeon_mem_base + radeon_ram_size - (radeon_ram_size * sizeof(bm_list_descriptor) / 4096));
	offset = (unsigned long)dma_phys_addrs;
//	offset += 4095;
//	offset &= ~4095; /* alignment */
	for(i=0;i<VID_PLAY_MAXFRAMES;i++)
	{
		radeon_dma_desc_base[i] = (void *)offset;
		offset += sizeof(bm_list_descriptor); // 4096;
  }

#if 0
	/* allocate temporary buffer for DMA */
	dma_phys_addrs = (unsigned long *)Mxalloc(radeon_ram_size*sizeof(unsigned long)/4096,3);

	/*
	WARNING: We MUST have continigous descriptors!!!
  But: (720*720*2(YUV422)*16(sizeof(bm_descriptor)))/4096=4050
	Thus one 4K page is far enough to describe max movie size
	*/
	for(i=0;i<VID_PLAY_MAXFRAMES;i++)
	{
//		if((radeon_dma_desc_base[i] = memalign(4096,radeon_ram_size*sizeof(bm_list_descriptor)/4096)) == 0)
//			goto out_mem;
  }
#endif
#endif
	/* save registers */
	radeon_fifo_wait(besr.big_endian ? 7 : 6);
	SAVED_OV0_GRAPHICS_KEY_CLR = INREG(OV0_GRAPHICS_KEY_CLR);
	SAVED_OV0_GRAPHICS_KEY_MSK = INREG(OV0_GRAPHICS_KEY_MSK);
	SAVED_OV0_VID_KEY_CLR = INREG(OV0_VID_KEY_CLR);
	SAVED_OV0_VID_KEY_MSK = INREG(OV0_VID_KEY_MSK);
	SAVED_OV0_KEY_CNTL = INREG(OV0_KEY_CNTL);
  SAVED_DISP_MERGE_CNTL	= INREG(DISP_MERGE_CNTL);
	if((besr.family == CHIP_FAMILY_R200) || (besr.family == CHIP_FAMILY_R300))
		besr.is_shift_required=0;
	else
		besr.is_shift_required=1;
	if(besr.big_endian)
		SAVED_CONFIG_CNTL = INREG(SURFACE_CNTL);
	return(0);  
}

void vixDestroy(void)
{
//	int i;
//	DPRINT("VIDIX: vixDestroy\r\n");
	radeon_fifo_wait(besr.big_endian ? 7 : 6);
	OUTREG(OV0_GRAPHICS_KEY_CLR, SAVED_OV0_GRAPHICS_KEY_CLR);
	OUTREG(OV0_GRAPHICS_KEY_MSK, SAVED_OV0_GRAPHICS_KEY_MSK);
	OUTREG(OV0_VID_KEY_CLR, SAVED_OV0_VID_KEY_CLR);
	OUTREG(OV0_VID_KEY_MSK, SAVED_OV0_VID_KEY_MSK);
	OUTREG(OV0_KEY_CNTL, SAVED_OV0_KEY_CNTL);
  OUTREG(DISP_MERGE_CNTL, SAVED_DISP_MERGE_CNTL);
	if(besr.big_endian)
    OUTREG(SURFACE_CNTL, SAVED_CONFIG_CNTL);
#ifdef VIDIX_ENABLE_BM
//	Mfree(dma_phys_addrs);
//	dma_phys_addrs = NULL;
#if 0
	for(i=0;i<VID_PLAY_MAXFRAMES;i++) 
	{
		if(radeon_dma_desc_base[i])
			Mfree(radeon_dma_desc_base[i]);
	}
#endif
#endif
}

int vixGetCapability(vidix_capability_t *to)
{
//	DPRINT("VIDIX: vixGetCapability\r\n");
	memcpy(to,&def_cap,sizeof(vidix_capability_t));
	to->vendor_id = vendor_id;
	to->device_id = device_id;
#ifdef VIDIX_ENABLE_BM
	if(dma_phys_addrs != NULL)
		to->flags |= (FLAG_DMA | FLAG_EQ_DMA);
#endif
	return(0); 
}

/*
  Full list of fourcc which are supported by Win2K redeon driver:
  YUY2, UYVY, DDES, OGLT, OGL2, OGLS, OGLB, OGNT, OGNZ, OGNS,
  IF09, YVU9, IMC4, M2IA, IYUV, VBID, DXT1, DXT2, DXT3, DXT4, DXT5
*/
typedef struct fourcc_desc_s
{
	unsigned long fourcc;
	unsigned max_srcw;
} fourcc_desc_t;

fourcc_desc_t supported_fourcc[] = 
{
	{ IMGFMT_Y800, 1567 },
	{ IMGFMT_YVU9, 1567 },
	{ IMGFMT_IF09, 1567 },
	{ IMGFMT_YV12, 1567 },
	{ IMGFMT_I420, 1567 },
	{ IMGFMT_IYUV, 1567 }, 
	{ IMGFMT_UYVY, 1551 },
	{ IMGFMT_YUY2, 1551 },
	{ IMGFMT_YVYU, 1551 },
	{ IMGFMT_RGB15, 1551 },
	{ IMGFMT_BGR15, 1551 },
	{ IMGFMT_RGB16, 1551 },
	{ IMGFMT_BGR16, 1551 },
	{ IMGFMT_RGB32, 775 },
	{ IMGFMT_BGR32, 775 }
};

static inline int is_supported_fourcc(unsigned long fourcc, unsigned srcw)
{
	unsigned i;
	for(i=0;i<sizeof(supported_fourcc)/sizeof(fourcc_desc_t);i++)
	{
		if((fourcc == supported_fourcc[i].fourcc) && (srcw <= supported_fourcc[i].max_srcw))
			return(1);
	}
	return(0);
}

int vixQueryFourcc(vidix_fourcc_t *to)
{
//	DPRINT("VIDIX: vixQueryFourcc\r\n");
	if(is_supported_fourcc(to->fourcc,to->srcw))
	{
		to->depth = VID_DEPTH_1BPP | VID_DEPTH_2BPP | VID_DEPTH_4BPP | VID_DEPTH_8BPP
		 | VID_DEPTH_12BPP | VID_DEPTH_15BPP | VID_DEPTH_16BPP | VID_DEPTH_24BPP | VID_DEPTH_32BPP;
		to->flags = VID_CAP_EXPAND | VID_CAP_SHRINK | VID_CAP_COLORKEY | VID_CAP_BLEND;
		return(0);
	}
	to->depth = to->flags = 0;
	return(ENOSYS);
}

static void radeon_vid_stop_video(void)
{
	radeon_engine_idle();
	OUTREG(OV0_SCALE_CNTL, SCALER_SOFT_RESET);
	OUTREG(OV0_EXCLUSIVE_HORZ, 0);
	OUTREG(OV0_AUTO_FLIP_CNTL, 0);   /* maybe */
	OUTREG(OV0_FILTER_CNTL, FILTER_HARDCODED_COEF);
	OUTREG(OV0_KEY_CNTL, GRAPHIC_KEY_FN_EQ);
	OUTREG(OV0_TEST, 0);
	if(besr.big_endian)
    OUTREG(SURFACE_CNTL, SAVED_CONFIG_CNTL);
}

static void radeon_vid_display_video(void)
{
	int bes_flags=0;
	if(besr.big_endian && !(besr.surf_id == 3 || besr.surf_id == 4 || besr.surf_id == 6))
		bes_flags=1;
	radeon_fifo_wait(bes_flags ? 2 : 1);
	if(bes_flags)
		OUTREG(SURFACE_CNTL, SAVED_CONFIG_CNTL & ~(NONSURF_AP0_SWP_32BPP | NONSURF_AP0_SWP_16BPP));
	OUTREG(OV0_REG_LOAD_CNTL, REG_LD_CTL_LOCK);
	radeon_engine_idle();
	while(!(INREG(OV0_REG_LOAD_CNTL) & REG_LD_CTL_LOCK_READBACK));
	radeon_fifo_wait(besr.deinterlace_on ? 6 : 5);
  /* Shutdown capturing */
	OUTREG(FCP_CNTL, FCP0_SRC_GND);
	OUTREG(CAP0_TRIG_CNTL, 0);
	OUTREG(VID_BUFFER_CONTROL, (1<<16) | 0x01);
	OUTREG(DISP_TEST_DEBUG_CNTL, 0);
	OUTREG(OV0_AUTO_FLIP_CNTL,OV0_AUTO_FLIP_CNTL_SOFT_BUF_ODD);
	if(besr.deinterlace_on)
		OUTREG(OV0_DEINTERLACE_PATTERN,besr.deinterlace_pattern);
	radeon_fifo_wait(19);
	OUTREG(OV0_GRAPHICS_KEY_MSK, besr.graphics_key_msk);
	OUTREG(OV0_GRAPHICS_KEY_CLR, besr.graphics_key_clr);
	OUTREG(OV0_KEY_CNTL,besr.ckey_cntl);
	OUTREG(OV0_H_INC, besr.h_inc);
	OUTREG(OV0_STEP_BY, besr.step_by);
	OUTREG(OV0_Y_X_START, besr.y_x_start);
	OUTREG(OV0_Y_X_END, besr.y_x_end);
	OUTREG(OV0_V_INC, besr.v_inc);
	OUTREG(OV0_P1_BLANK_LINES_AT_TOP,	besr.p1_blank_lines_at_top);
	OUTREG(OV0_P23_BLANK_LINES_AT_TOP,	besr.p23_blank_lines_at_top);
	OUTREG(OV0_VID_BUF_PITCH0_VALUE,	besr.vid_buf_pitch0_value);
	OUTREG(OV0_VID_BUF_PITCH1_VALUE,	besr.vid_buf_pitch1_value);
	OUTREG(OV0_P1_X_START_END, besr.p1_x_start_end);
	OUTREG(OV0_P2_X_START_END, besr.p2_x_start_end);
	OUTREG(OV0_P3_X_START_END, besr.p3_x_start_end);
	OUTREG(OV0_BASE_ADDR, besr.base_addr);
	OUTREG(OV0_VID_BUF0_BASE_ADRS, besr.vid_buf_base_adrs_y[0]);
	OUTREG(OV0_VID_BUF1_BASE_ADRS, besr.vid_buf_base_adrs_v[0]);
	OUTREG(OV0_VID_BUF2_BASE_ADRS, besr.vid_buf_base_adrs_u[0]);
	radeon_fifo_wait(9);
	OUTREG(OV0_VID_BUF3_BASE_ADRS, besr.vid_buf_base_adrs_y[0]);
	OUTREG(OV0_VID_BUF4_BASE_ADRS, besr.vid_buf_base_adrs_v[0]);
	OUTREG(OV0_VID_BUF5_BASE_ADRS, besr.vid_buf_base_adrs_u[0]);
	OUTREG(OV0_P1_V_ACCUM_INIT, besr.p1_v_accum_init);
	OUTREG(OV0_P1_H_ACCUM_INIT, besr.p1_h_accum_init);
	OUTREG(OV0_P23_H_ACCUM_INIT, besr.p23_h_accum_init);
	OUTREG(OV0_P23_V_ACCUM_INIT, besr.p23_v_accum_init);
	bes_flags = SCALER_ENABLE | SCALER_SMART_SWITCH | SCALER_Y2R_TEMP | SCALER_PIX_EXPAND;
	if(besr.double_buff)
		bes_flags |= SCALER_DOUBLE_BUFFER;
	if(besr.deinterlace_on)
		bes_flags |= SCALER_ADAPTIVE_DEINT;
	if(besr.horz_pick_nearest)
		bes_flags |= SCALER_HORZ_PICK_NEAREST;
	if(besr.vert_pick_nearest)
		bes_flags |= SCALER_VERT_PICK_NEAREST;
	bes_flags |= (besr.surf_id << 8) & SCALER_SURFAC_FORMAT;
	if(besr.load_prg_start)
		bes_flags |= SCALER_PRG_LOAD_START;
	OUTREG(OV0_SCALE_CNTL, bes_flags);
	OUTREG(OV0_REG_LOAD_CNTL, 0);
	radeon_fifo_wait(besr.swap_uv ? 8 : 7);
	OUTREG(OV0_FILTER_CNTL,besr.filter_cntl);
	OUTREG(OV0_FOUR_TAP_COEF_0,besr.four_tap_coeff[0]);
	OUTREG(OV0_FOUR_TAP_COEF_1,besr.four_tap_coeff[1]);
	OUTREG(OV0_FOUR_TAP_COEF_2,besr.four_tap_coeff[2]);
	OUTREG(OV0_FOUR_TAP_COEF_3,besr.four_tap_coeff[3]);
	OUTREG(OV0_FOUR_TAP_COEF_4,besr.four_tap_coeff[4]);
	if(besr.swap_uv)
		OUTREG(OV0_TEST,INREG(OV0_TEST) | OV0_SWAP_UV);
	OUTREG(OV0_REG_LOAD_CNTL,	0);
}

static unsigned radeon_query_pitch(unsigned fourcc,const vidix_yuv_t *spitch)
{
  unsigned pitch,spy,spv,spu;
  spy = spv = spu = 0;
  switch(spitch->y)
  {
    case 16:
    case 32:
    case 64:
    case 128:
    case 256: spy = spitch->y; break;
    default: break;
  }
  switch(spitch->u)
  {
    case 16:
    case 32:
    case 64:
    case 128:
    case 256: spu = spitch->u; break;
    default: break;
  }
  switch(spitch->v)
  {
    case 16:
    case 32:
    case 64:
    case 128:
    case 256: spv = spitch->v; break;
    default: break;
  }
  switch(fourcc)
  {
	/* 4:2:0 */
	case IMGFMT_IYUV:
	case IMGFMT_YV12:
	case IMGFMT_I420:
		if(spy > 16 && spu == spy/2 && spv == spy/2)
			pitch = spy;
		else
			pitch = 32;
		break;
	/* 4:1:0 */
	case IMGFMT_IF09:
	case IMGFMT_YVU9:
		if(spy > 32 && spu == spy/4 && spv == spy/4)
			pitch = spy;
		else
			pitch = 64;
		break;
	default:
		if(spy >= 16)
			pitch = spy;
		else
			pitch = 16;
		break;
  }
  return(pitch);
}

static void Calc_H_INC_STEP_BY(int fieldvalue_OV0_SURFACE_FORMAT, float H_scale_ratio, int DisallowFourTapVertFiltering, int DisallowFourTapUVVertFiltering,
 unsigned long *val_OV0_P1_H_INC, unsigned long *val_OV0_P1_H_STEP_BY, unsigned long *val_OV0_P23_H_INC, unsigned long *val_OV0_P23_H_STEP_BY, int *P1GroupSize, int *P1StepSize, int *P23StepSize)
{
	float ClocksNeededFor16Pixels;
	switch(fieldvalue_OV0_SURFACE_FORMAT)
	{
		case 3:
		case 4: /*16BPP (ARGB1555 and RGB565) */
			/* All colour components are fetched in pairs */
			*P1GroupSize = 2;
			/* We don't support four tap in this mode because G's are split between two bytes. In theory we could support it if */
			/* we saved part of the G when fetching the R, and then filter the G, followed by the B in the following cycles. */
			if(H_scale_ratio>=.5)
			{
				/* We are actually generating two pixels (but 3 colour components) per tick. Thus we don't have to skip */
				/* until we reach .5. P1 and P23 are the same. */
				*val_OV0_P1_H_INC = (unsigned short)((long)((1/(H_scale_ratio)) * (1<<0xc) + 0.5));
				*val_OV0_P1_H_STEP_BY = 1;
				*val_OV0_P23_H_INC = (unsigned short)((long)((1/(H_scale_ratio)) * (1<<0xc) + 0.5));
				*val_OV0_P23_H_STEP_BY = 1;
				*P1StepSize = 1;
				*P23StepSize = 1;
			}
			else if(H_scale_ratio>=.25)
			{
				/* Step by two */
				*val_OV0_P1_H_INC = (unsigned short)((long)((1/(H_scale_ratio*2)) * (1<<0xc) + 0.5));
				*val_OV0_P1_H_STEP_BY = 2;
				*val_OV0_P23_H_INC = (unsigned short)((long)((1/(H_scale_ratio*2)) * (1<<0xc) + 0.5));
				*val_OV0_P23_H_STEP_BY = 2;
				*P1StepSize = 2;
				*P23StepSize = 2;
			}
			else if(H_scale_ratio>=.125)
			{
				/* Step by four */
				*val_OV0_P1_H_INC = (unsigned short)((long)((1/(H_scale_ratio*4)) * (1<<0xc) + 0.5));
				*val_OV0_P1_H_STEP_BY = 3;
				*val_OV0_P23_H_INC = (unsigned short)((long)((1/(H_scale_ratio*4)) * (1<<0xc) + 0.5));
				*val_OV0_P23_H_STEP_BY = 3;
				*P1StepSize = 4;
				*P23StepSize = 4;
			}
			else if(H_scale_ratio>=.0625)
			{
				/* Step by eight */
				*val_OV0_P1_H_INC = (unsigned short)((long)((1/(H_scale_ratio*8)) * (1<<0xc) + 0.5));
				*val_OV0_P1_H_STEP_BY = 4;
				*val_OV0_P23_H_INC = (unsigned short)((long)((1/(H_scale_ratio*8)) * (1<<0xc) + 0.5));
				*val_OV0_P23_H_STEP_BY = 4;
				*P1StepSize = 8;
				*P23StepSize = 8;
			}
			else if(H_scale_ratio>=0.03125)
			{
				/* Step by sixteen */
				*val_OV0_P1_H_INC = (unsigned short)((long)((1/(H_scale_ratio*16)) * (1<<0xc) + 0.5));
				*val_OV0_P1_H_STEP_BY = 5;
				*val_OV0_P23_H_INC = (unsigned short)((long)((1/(H_scale_ratio*16)) * (1<<0xc) + 0.5));
				*val_OV0_P23_H_STEP_BY = 5;
				*P1StepSize = 16;
				*P23StepSize = 16;
			}
			else
			{
				H_scale_ratio=0.03125;
				*val_OV0_P1_H_INC = (unsigned short)((long)((1/(H_scale_ratio*16)) * (1<<0xc) + 0.5));
				*val_OV0_P1_H_STEP_BY = 5;
				*val_OV0_P23_H_INC = (unsigned short)((long)((1/(H_scale_ratio*16)) * (1<<0xc) + 0.5));
				*val_OV0_P23_H_STEP_BY = 5;
				*P1StepSize = 16;
				*P23StepSize = 16;
			}
			break;
		case 6: /* 32BPP RGB */
			if(H_scale_ratio>=1.5 && !DisallowFourTapVertFiltering)
			{
				/* All colour components are fetched in pairs */
				*P1GroupSize = 2;
				/* With four tap filtering, we can generate two colour components every clock, or two pixels every three */
				/* clocks. This means that we will have four tap filtering when scaling 1.5 or more. */
				*val_OV0_P1_H_INC = (unsigned short)((long)((1/(H_scale_ratio)) * (1<<0xc) + 0.5));
				*val_OV0_P1_H_STEP_BY = 0;
				*val_OV0_P23_H_INC = (unsigned short)((long)((1/(H_scale_ratio)) * (1<<0xc) + 0.5));
				*val_OV0_P23_H_STEP_BY = 0;
				*P1StepSize = 1;
				*P23StepSize = 1;
			}
			else if(H_scale_ratio>=0.75)
			{
				/* Four G colour components are fetched at once */
				*P1GroupSize = 4;
				/* R and B colour components are fetched in pairs */
				/* With two tap filtering, we can generate four colour components every clock. */
				/* This means that we will have two tap filtering when scaling 1.0 or more. */
				*val_OV0_P1_H_INC = (unsigned short)((long)((1/(H_scale_ratio)) * (1<<0xc) + 0.5));
				*val_OV0_P1_H_STEP_BY = 1;
				*val_OV0_P23_H_INC = (unsigned short)((long)((1/(H_scale_ratio)) * (1<<0xc) + 0.5));
				*val_OV0_P23_H_STEP_BY = 1;
				*P1StepSize = 1;
				*P23StepSize = 1;
			}
			else if(H_scale_ratio>=0.375)
			{
				/* Step by two. */
				/* Four G colour components are fetched at once */
				*P1GroupSize = 4;
				/* R and B colour components are fetched in pairs */
				*val_OV0_P1_H_INC = (unsigned short)((long)((1/(H_scale_ratio*2)) * (1<<0xc) + 0.5));
				*val_OV0_P1_H_STEP_BY = 2;
				*val_OV0_P23_H_INC = (unsigned short)((long)((1/(H_scale_ratio*2)) * (1<<0xc) + 0.5));
				*val_OV0_P23_H_STEP_BY = 2;
				*P1StepSize = 2;
				*P23StepSize = 2;
			}
			else if(H_scale_ratio>=0.25)
			{
				/* Step by two. */
				/* Four G colour components are fetched at once */
				*P1GroupSize = 4;
				/* R and B colour components are fetched in pairs */
				*val_OV0_P1_H_INC = (unsigned short)((long)((1/(H_scale_ratio*2)) * (1<<0xc) + 0.5));
				*val_OV0_P1_H_STEP_BY = 2;
				*val_OV0_P23_H_INC = (unsigned short)((long)((1/(H_scale_ratio*4)) * (1<<0xc) + 0.5));
				*val_OV0_P23_H_STEP_BY = 3;
				*P1StepSize = 2;
				*P23StepSize = 4;
			}
			else if(H_scale_ratio>=0.1875)
			{
				/* Step by four */
				/* Four G colour components are fetched at once */
				*P1GroupSize = 4;
				/* R and B colour components are fetched in pairs */
				*val_OV0_P1_H_INC = (unsigned short)((long)((1/(H_scale_ratio*4)) * (1<<0xc) + 0.5));
				*val_OV0_P1_H_STEP_BY = 3;
				*val_OV0_P23_H_INC = (unsigned short)((long)((1/(H_scale_ratio*4)) * (1<<0xc) + 0.5));
				*val_OV0_P23_H_STEP_BY = 3;
				*P1StepSize = 4;
				*P23StepSize = 4;
			}
			else if(H_scale_ratio>=0.125)
			{
				/* Step by four */
				/* Four G colour components are fetched at once */
				*P1GroupSize = 4;
				/* R and B colour components are fetched in pairs */
				*val_OV0_P1_H_INC = (unsigned short)((long)((1/(H_scale_ratio*4)) * (1<<0xc) + 0.5));
				*val_OV0_P1_H_STEP_BY = 3;
				*val_OV0_P23_H_INC = (unsigned short)((long)((1/(H_scale_ratio*8)) * (1<<0xc) + 0.5));
				*val_OV0_P23_H_STEP_BY = 4;
				*P1StepSize = 4;
				*P23StepSize = 8;
			}
			else if(H_scale_ratio>=0.09375)
			{
				/* Step by eight */
				/* Four G colour components are fetched at once */
				*P1GroupSize = 4;
				/* R and B colour components are fetched in pairs */
				*val_OV0_P1_H_INC = (unsigned short)((long)((1/(H_scale_ratio*8)) * (1<<0xc) + 0.5));
				*val_OV0_P1_H_STEP_BY = 4;
				*val_OV0_P23_H_INC = (unsigned short)((long)((1/(H_scale_ratio*8)) * (1<<0xc) + 0.5));
				*val_OV0_P23_H_STEP_BY = 4;
				*P1StepSize = 8;
				*P23StepSize = 8;
			}
			else if(H_scale_ratio>=0.0625)
			{
				/* Step by eight */
				/* Four G colour components are fetched at once */
				*P1GroupSize = 4;
				/* R and B colour components are fetched in pairs */
				*val_OV0_P1_H_INC = (unsigned short)((long)((1/(H_scale_ratio*16)) * (1<<0xc) + 0.5));
				*val_OV0_P1_H_STEP_BY = 5;
				*val_OV0_P23_H_INC = (unsigned short)((long)((1/(H_scale_ratio*16)) * (1<<0xc) + 0.5));
				*val_OV0_P23_H_STEP_BY = 5;
				*P1StepSize = 16;
				*P23StepSize = 16;
			}
	    else
	    {
				H_scale_ratio=0.0625;
				*P1GroupSize = 4;
				*val_OV0_P1_H_INC = (unsigned short)((long)((1/(H_scale_ratio*16)) * (1<<0xc) + 0.5));
				*val_OV0_P1_H_STEP_BY = 5;
				*val_OV0_P23_H_INC = (unsigned short)((long)((1/(H_scale_ratio*16)) * (1<<0xc) + 0.5));
				*val_OV0_P23_H_STEP_BY = 5;
				*P1StepSize = 16;
				*P23StepSize = 16;
			}
			break;
		case 9:
			/* ToDo_Active: In mode 9 there is a possibility that HScale ratio may be set to an illegal value, so we have extra conditions in the if statement. For consistancy, these conditions be added to the other modes as well. */
			/* four tap on both (unless Y is too wide) */
			if((H_scale_ratio>=(ClocksNeededFor16Pixels=8.0f+2.0f+2.0f) / 16.0f)
			 && ((unsigned short)((1/(H_scale_ratio)) * (1<<0xc) + 0.5)<=0x3000)
			 && ((unsigned short)((1/(H_scale_ratio*4)) * (1<<0xc) + 0.5)<=0x2000)
			 && !DisallowFourTapVertFiltering && !DisallowFourTapUVVertFiltering)
			{ /* *0.75 */
				/* Colour components are fetched in pairs */
				*P1GroupSize = 2;
				*val_OV0_P1_H_INC = (unsigned short)((1/(H_scale_ratio)) * (1<<0xc) + 0.5);
				*val_OV0_P1_H_STEP_BY = 0;
				*val_OV0_P23_H_INC = (unsigned short)((1/(H_scale_ratio*4)) * (1<<0xc) + 0.5);
				*val_OV0_P23_H_STEP_BY = 0;
				*P1StepSize = 1;
				*P23StepSize = 1;
			}
	    /* two tap on Y (because it is too big for four tap), four tap on UV */
	    else if((H_scale_ratio>=(ClocksNeededFor16Pixels=4.0f+2.0f+2.0f) / 16.0f)
	     && ((unsigned short)((1/(H_scale_ratio)) * (1<<0xc) + 0.5)<=0x3000)
	     && ((unsigned short)((1/(H_scale_ratio*4)) * (1<<0xc) + 0.5)<=0x2000)
	     && DisallowFourTapVertFiltering && !DisallowFourTapUVVertFiltering)
			{ /* 0.75 */
				*P1GroupSize = 4;
				*val_OV0_P1_H_INC = (unsigned short)((1/(H_scale_ratio)) * (1<<0xc) + 0.5);
				*val_OV0_P1_H_STEP_BY = 1;
				*val_OV0_P23_H_INC = (unsigned short)((1/(H_scale_ratio*4)) * (1<<0xc) + 0.5);
				*val_OV0_P23_H_STEP_BY = 0;
				*P1StepSize = 1;
				*P23StepSize = 1;
			}
			/* We scale the Y with the four tap filters, but UV's are generated
			   with dual two tap configuration */
			else if((H_scale_ratio>=(ClocksNeededFor16Pixels=8.0f+1.0f+1.0f) / 16.0f)
			 && ((unsigned short)((1/(H_scale_ratio)) * (1<<0xc) + 0.5)<=0x3000)
			 && ((unsigned short)((1/(H_scale_ratio*4)) * (1<<0xc) + 0.5)<=0x2000)
			 && !DisallowFourTapVertFiltering)
			{	/* 0.625 */
				*P1GroupSize = 2;
				*val_OV0_P1_H_INC = (unsigned short)((1/(H_scale_ratio)) * (1<<0xc) + 0.5);
				*val_OV0_P1_H_STEP_BY = 0;
				*val_OV0_P23_H_INC = (unsigned short)((1/(H_scale_ratio*4)) * (1<<0xc) + 0.5);
				*val_OV0_P23_H_STEP_BY = 1;
				*P1StepSize = 1;
				*P23StepSize = 1;
			}
			/* We scale the Y, U, and V with the two tap filters */
			else if((H_scale_ratio>=(ClocksNeededFor16Pixels=4.0f+1.0f+1.0f) / 16.0f)
			 && ((unsigned short)((1/(H_scale_ratio)) * (1<<0xc) + 0.5)<=0x3000)
			 && ((unsigned short)((1/(H_scale_ratio*4)) * (1<<0xc) + 0.5)<=0x2000))
			{ /* 0.375 */
				*P1GroupSize = 4;
				*val_OV0_P1_H_INC = (unsigned short)((1/(H_scale_ratio)) * (1<<0xc) + 0.5);
				*val_OV0_P1_H_STEP_BY = 1;
				*val_OV0_P23_H_INC = (unsigned short)((1/(H_scale_ratio*4)) * (1<<0xc) + 0.5);
				*val_OV0_P23_H_STEP_BY = 1;
				*P1StepSize = 1;
				*P23StepSize = 1;
			}
			/* We scale step the U and V by two to allow more bandwidth for fetching Y's,
			   thus we won't drop Y's yet */
			else if((H_scale_ratio>=(ClocksNeededFor16Pixels=4.0f+.5f+.5f) / 16.0f)
			 && ((unsigned short)((1/(H_scale_ratio)) * (1<<0xc) + 0.5)<=0x3000)
			 && ((unsigned short)((1/(H_scale_ratio*4*2)) * (1<<0xc) + 0.5)<=0x2000))
			{ /* >=0.3125 and >.333333~ */
				*P1GroupSize = 4;
				*val_OV0_P1_H_INC = (unsigned short)((1/(H_scale_ratio)) * (1<<0xc) + 0.5);
				*val_OV0_P1_H_STEP_BY = 1;
				*val_OV0_P23_H_INC = (unsigned short)((1/(H_scale_ratio*4*2)) * (1<<0xc) + 0.5);
				*val_OV0_P23_H_STEP_BY = 2;
				*P1StepSize = 1;
				*P23StepSize = 2;
			}
			/* We step the Y, U, and V by two */
	    else if ((H_scale_ratio>=(ClocksNeededFor16Pixels=2.0f+.5f+.5f) / 16.0f)
			 && ((unsigned short)((1/(H_scale_ratio*2)) * (1<<0xc) + 0.5)<=0x3000)
			 && ((unsigned short)((1/(H_scale_ratio*4*2)) * (1<<0xc) + 0.5)<=0x2000))
			{
				*P1GroupSize = 4;
				*val_OV0_P1_H_INC = (unsigned short)((1/(H_scale_ratio*2)) * (1<<0xc) + 0.5);
				*val_OV0_P1_H_STEP_BY = 2;
				*val_OV0_P23_H_INC = (unsigned short)((1/(H_scale_ratio*4*2)) * (1<<0xc) + 0.5);
				*val_OV0_P23_H_STEP_BY = 2;
				*P1StepSize = 2;
				*P23StepSize = 2;
			}
			/* We step the Y by two and the U and V by four */
			else if((H_scale_ratio>=(ClocksNeededFor16Pixels=2.0f+.25f+.25f) / 16.0f)
			 && ((unsigned short)((1/(H_scale_ratio)) * (1<<0xc) + 0.5)<=0x3000)
			 && ((unsigned short)((1/(H_scale_ratio*4*4)) * (1<<0xc) + 0.5)<=0x2000))
	    {
				*P1GroupSize = 4;
				*val_OV0_P1_H_INC = (unsigned short)((1/(H_scale_ratio*2)) * (1<<0xc) + 0.5);
				*val_OV0_P1_H_STEP_BY = 2;
				*val_OV0_P23_H_INC = (unsigned short)((1/(H_scale_ratio*4*4)) * (1<<0xc) + 0.5);
				*val_OV0_P23_H_STEP_BY = 3;
				*P1StepSize = 2;
				*P23StepSize = 4;
			}
	    /* We step the Y, U, and V by four */
			else if((H_scale_ratio>=(ClocksNeededFor16Pixels=1.0f+.25f+.25f) / 16.0f)
			 && ((unsigned short)((1/(H_scale_ratio*4)) * (1<<0xc) + 0.5)<=0x3000)
			 && ((unsigned short)((1/(H_scale_ratio*4*4)) * (1<<0xc) + 0.5)<=0x2000))
			{
				*P1GroupSize = 4;
				*val_OV0_P1_H_INC = (unsigned short)((1/(H_scale_ratio*4)) * (1<<0xc) + 0.5);
				*val_OV0_P1_H_STEP_BY = 3;
				*val_OV0_P23_H_INC = (unsigned short)((1/(H_scale_ratio*4*4)) * (1<<0xc) + 0.5);
				*val_OV0_P23_H_STEP_BY = 3;
				*P1StepSize = 4;
				*P23StepSize = 4;
			}
			/* We would like to step the Y by four and the U and V by eight, but we can't mix step by 3 and step by 4 for packed modes */
			/* We step the Y, U, and V by eight */
	    else if((H_scale_ratio>=(ClocksNeededFor16Pixels=.5f+.125f+.125f) / 16.0f)
	     && ((unsigned short)((1/(H_scale_ratio*8)) * (1<<0xc) + 0.5)<=0x3000)
	     && ((unsigned short)((1/(H_scale_ratio*4*8)) * (1<<0xc) + 0.5)<=0x2000))
			{
				*P1GroupSize = 4;
				*val_OV0_P1_H_INC = (unsigned short)((long)((1/(H_scale_ratio*8)) * (1<<0xc) + 0.5));
				*val_OV0_P1_H_STEP_BY = 4;
				*val_OV0_P23_H_INC = (unsigned short)((long)((1/(H_scale_ratio*4*8)) * (1<<0xc) + 0.5));
				*val_OV0_P23_H_STEP_BY = 4;
				*P1StepSize = 8;
				*P23StepSize = 8;
			}
			/* We step the Y by eight and the U and V by sixteen */
			else if((H_scale_ratio>=(ClocksNeededFor16Pixels=.5f+.0625f+.0625f) / 16.0f)
			 && ((unsigned short)((1/(H_scale_ratio*8)) * (1<<0xc) + 0.5)<=0x3000)
			 && ((unsigned short)((1/(H_scale_ratio*4*16)) * (1<<0xc) + 0.5)<=0x2000))
			{
				*P1GroupSize = 4;
				*val_OV0_P1_H_INC = (unsigned short)((long)((1/(H_scale_ratio*8)) * (1<<0xc) + 0.5));
				*val_OV0_P1_H_STEP_BY = 4;
				*val_OV0_P23_H_INC = (unsigned short)((long)((1/(H_scale_ratio*4*16)) * (1<<0xc) + 0.5));
				*val_OV0_P23_H_STEP_BY = 5;
				*P1StepSize = 8;
				*P23StepSize = 16;
			}
			/* We step the Y, U, and V by sixteen */
			else if((H_scale_ratio>=(ClocksNeededFor16Pixels=.25f+.0625f+.0625f) / 16.0f)
			 && ((unsigned short)((1/(H_scale_ratio*16)) * (1<<0xc) + 0.5)<=0x3000)
			 && ((unsigned short)((1/(H_scale_ratio*4*16)) * (1<<0xc) + 0.5)<=0x2000))
	    {
				*P1GroupSize = 4;
				*val_OV0_P1_H_INC = (unsigned short)((long)((1/(H_scale_ratio*16)) * (1<<0xc) + 0.5));
				*val_OV0_P1_H_STEP_BY = 5;
				*val_OV0_P23_H_INC = (unsigned short)((long)((1/(H_scale_ratio*4*16)) * (1<<0xc) + 0.5));
				*val_OV0_P23_H_STEP_BY = 5;
				*P1StepSize = 16;
				*P23StepSize = 16;
			}
			else
			{
				H_scale_ratio=(ClocksNeededFor16Pixels=.25f+.0625f+.0625f) / 16.0f;
				*P1GroupSize = 4;
				*val_OV0_P1_H_INC = (unsigned short)((long)((1/(H_scale_ratio*16)) * (1<<0xc) + 0.5));
				*val_OV0_P1_H_STEP_BY = 5;
				*val_OV0_P23_H_INC = (unsigned short)((long)((1/(H_scale_ratio*4*16)) * (1<<0xc) + 0.5));
				*val_OV0_P23_H_STEP_BY = 5;
				*P1StepSize = 16;
				*P23StepSize = 16;
			}
			break;
		case 10:
		case 11:
		case 12:
		case 13:
		case 14:    /* YUV12, VYUY422, YUYV422, YOverPkCRCB12, YWovenWithPkCRCB12 */
			/* We scale the Y, U, and V with the four tap filters */
			/* four tap on both (unless Y is too wide) */
			if((H_scale_ratio>=(ClocksNeededFor16Pixels=8.0f+4.0f+4.0f) / 16.0f) && !DisallowFourTapVertFiltering && !DisallowFourTapUVVertFiltering)
			{
				/* 0.75 */
				*P1GroupSize = 2;
				*val_OV0_P1_H_INC = (unsigned short)((long)((1/(H_scale_ratio)) * (1<<0xc) + 0.5));
				*val_OV0_P1_H_STEP_BY = 0;
				*val_OV0_P23_H_INC = (unsigned short)((long)((1/(H_scale_ratio*2)) * (1<<0xc) + 0.5));
				*val_OV0_P23_H_STEP_BY = 0;
				*P1StepSize = 1;
				*P23StepSize = 1;
			}
			/* two tap on Y (because it is too big for four tap), four tap on UV */
			else if((H_scale_ratio>=(ClocksNeededFor16Pixels=4.0f+4.0f+4.0f) / 16.0f) && DisallowFourTapVertFiltering && !DisallowFourTapUVVertFiltering)
			{
				/* 0.75 */
				*P1GroupSize = 4;
				*val_OV0_P1_H_INC = (unsigned short)((long)((1/(H_scale_ratio)) * (1<<0xc) + 0.5));
				*val_OV0_P1_H_STEP_BY = 1;
				*val_OV0_P23_H_INC = (unsigned short)((long)((1/(H_scale_ratio*2)) * (1<<0xc) + 0.5));
				*val_OV0_P23_H_STEP_BY = 0;
				*P1StepSize = 1;
				*P23StepSize = 1;
			}
			/* We scale the Y with the four tap filters, but UV's are generated with dual two tap configuration */
			else if((H_scale_ratio>=(ClocksNeededFor16Pixels=8.0f+2.0f+2.0f) / 16.0f) && !DisallowFourTapVertFiltering)
			{
				/* 0.625 */
				*P1GroupSize = 2;
				*val_OV0_P1_H_INC = (unsigned short)((long)((1/(H_scale_ratio)) * (1<<0xc) + 0.5));
				*val_OV0_P1_H_STEP_BY = 0;
				*val_OV0_P23_H_INC = (unsigned short)((long)((1/(H_scale_ratio*2)) * (1<<0xc) + 0.5));
				*val_OV0_P23_H_STEP_BY = 1;
				*P1StepSize = 1;
				*P23StepSize = 1;
			}
			/* We scale the Y, U, and V with the two tap filters */
			else if (H_scale_ratio>=(ClocksNeededFor16Pixels=4.0f+2.0f+2.0f) / 16.0f)
			{
				/* 0.375 */
		    *P1GroupSize = 4;
		    *val_OV0_P1_H_INC = (unsigned short)((long)((1/(H_scale_ratio)) * (1<<0xc) + 0.5));
		    *val_OV0_P1_H_STEP_BY = 1;
		    *val_OV0_P23_H_INC = (unsigned short)((long)((1/(H_scale_ratio*2)) * (1<<0xc) + 0.5));
		    *val_OV0_P23_H_STEP_BY = 1;
		    *P1StepSize = 1;
		    *P23StepSize = 1;
			}
			/* We scale step the U and V by two to allow more bandwidth for
			   fetching Y's, thus we won't drop Y's yet */
			else if(H_scale_ratio>=(ClocksNeededFor16Pixels=4.0f+1.0f+1.0f) / 16.0f)
			{
				/*0.312 */
				*P1GroupSize = 4;
				*val_OV0_P1_H_INC = (unsigned short)((1/(H_scale_ratio)) * (1<<0xc) + 0.5);
				*val_OV0_P1_H_STEP_BY = 1;
				*val_OV0_P23_H_INC = (unsigned short)((1/(H_scale_ratio*2*2)) * (1<<0xc) + 0.5);
				*val_OV0_P23_H_STEP_BY = 2;
				*P1StepSize = 1;
				*P23StepSize = 2;
			}
			/* We step the Y, U, and V by two */
			else if(H_scale_ratio>=(ClocksNeededFor16Pixels=2.0f+1.0f+1.0f) / 16.0f)
			{
				*P1GroupSize = 4;
				*val_OV0_P1_H_INC = (unsigned short)((1/(H_scale_ratio*2)) * (1<<0xc) + 0.5);
				*val_OV0_P1_H_STEP_BY = 2;
				*val_OV0_P23_H_INC = (unsigned short)((1/(H_scale_ratio*2*2)) * (1<<0xc) + 0.5);
				*val_OV0_P23_H_STEP_BY = 2;
				*P1StepSize = 2;
				*P23StepSize = 2;
			}
			/* We step the Y by two and the U and V by four */
			else if(H_scale_ratio>=(ClocksNeededFor16Pixels=2.0f+.5f+.5f) / 16.0f)
			{
				*P1GroupSize = 4;
				*val_OV0_P1_H_INC = (unsigned short)((1/(H_scale_ratio*2)) * (1<<0xc) + 0.5);
				*val_OV0_P1_H_STEP_BY = 2;
				*val_OV0_P23_H_INC = (unsigned short)((1/(H_scale_ratio*2*4)) * (1<<0xc) + 0.5);
				*val_OV0_P23_H_STEP_BY = 3;
				*P1StepSize = 2;
				*P23StepSize = 4;
			}
			/* We step the Y, U, and V by four */
			else if(H_scale_ratio>=(ClocksNeededFor16Pixels=1.0f+.5f+.5f) / 16.0f)
			{
				*P1GroupSize = 4;
				*val_OV0_P1_H_INC = (unsigned short)((1/(H_scale_ratio*4)) * (1<<0xc) + 0.5);
				*val_OV0_P1_H_STEP_BY = 3;
				*val_OV0_P23_H_INC = (unsigned short)((1/(H_scale_ratio*2*4)) * (1<<0xc) + 0.5);
				*val_OV0_P23_H_STEP_BY = 3;
				*P1StepSize = 4;
				*P23StepSize = 4;
			}
			/* We step the Y by four and the U and V by eight */
			else if((H_scale_ratio>=(ClocksNeededFor16Pixels=1.0f+.25f+.25f) / 16.0f) && (fieldvalue_OV0_SURFACE_FORMAT==10))
			{
				*P1GroupSize = 4;
				/* Can't mix step by 3 and step by 4 for packed modes */
				*val_OV0_P1_H_INC = (unsigned short)((1/(H_scale_ratio*4)) * (1<<0xc) + 0.5);
				*val_OV0_P1_H_STEP_BY = 3;
				*val_OV0_P23_H_INC = (unsigned short)((1/(H_scale_ratio*2*8)) * (1<<0xc) + 0.5);
				*val_OV0_P23_H_STEP_BY = 4;
				*P1StepSize = 4;
				*P23StepSize = 8;
			}
			/* We step the Y, U, and V by eight */
			else if(H_scale_ratio>=(ClocksNeededFor16Pixels=.5f+.25f+.25f) / 16.0f)
			{
				*P1GroupSize = 4;
				*val_OV0_P1_H_INC = (unsigned short)((1/(H_scale_ratio*8)) * (1<<0xc) + 0.5);
				*val_OV0_P1_H_STEP_BY = 4;
				*val_OV0_P23_H_INC = (unsigned short)((1/(H_scale_ratio*2*8)) * (1<<0xc) + 0.5);
				*val_OV0_P23_H_STEP_BY = 4;
				*P1StepSize = 8;
				*P23StepSize = 8;
			}
			/* We step the Y by eight and the U and V by sixteen */
			else if((H_scale_ratio>=(ClocksNeededFor16Pixels=.5f+.125f+.125f) / 16.0f) && (fieldvalue_OV0_SURFACE_FORMAT==10))
			{
				*P1GroupSize = 4;
				/* Step by 5 not supported for packed modes */
				*val_OV0_P1_H_INC = (unsigned short)((1/(H_scale_ratio*8)) * (1<<0xc) + 0.5);
				*val_OV0_P1_H_STEP_BY = 4;
				*val_OV0_P23_H_INC = (unsigned short)((1/(H_scale_ratio*2*16)) * (1<<0xc) + 0.5);
				*val_OV0_P23_H_STEP_BY = 5;
				*P1StepSize = 8;
				*P23StepSize = 16;
			}
			/* We step the Y, U, and V by sixteen */
			else if((H_scale_ratio>=(ClocksNeededFor16Pixels=.25f+.125f+.125f) / 16.0f) && (fieldvalue_OV0_SURFACE_FORMAT==10))
			{
				*P1GroupSize = 4;
				/* Step by 5 not supported for packed modes */
				*val_OV0_P1_H_INC = (unsigned short)((1/(H_scale_ratio*16)) * (1<<0xc) + 0.5);
				*val_OV0_P1_H_STEP_BY = 5;
				*val_OV0_P23_H_INC = (unsigned short)((1/(H_scale_ratio*2*16)) * (1<<0xc) + 0.5);
				*val_OV0_P23_H_STEP_BY = 5;
				*P1StepSize = 16;
				*P23StepSize = 16;
			}
			else
			{
		    if(fieldvalue_OV0_SURFACE_FORMAT==10)
		    {
					H_scale_ratio=(ClocksNeededFor16Pixels=.25f+.125f+.125f) / 16.0f;
					*P1GroupSize = 4;
					*val_OV0_P1_H_INC = (unsigned short)((1/(H_scale_ratio*16)) * (1<<0xc) + 0.5);
					*val_OV0_P1_H_STEP_BY = 5;
					*val_OV0_P23_H_INC = (unsigned short)((1/(H_scale_ratio*2*16)) * (1<<0xc) + 0.5);
					*val_OV0_P23_H_STEP_BY = 5;
					*P1StepSize = 16;
					*P23StepSize = 16;
				}
				else
				{
					H_scale_ratio=(ClocksNeededFor16Pixels=.5f+.25f+.25f) / 16.0f;
					*P1GroupSize = 4;
					*val_OV0_P1_H_INC = (unsigned short)((1/(H_scale_ratio*8)) * (1<<0xc) + 0.5);
					*val_OV0_P1_H_STEP_BY = 4;
					*val_OV0_P23_H_INC = (unsigned short)((1/(H_scale_ratio*2*8)) * (1<<0xc) + 0.5);
					*val_OV0_P23_H_STEP_BY = 4;
					*P1StepSize = 8;
					*P23StepSize = 8;
				}
			}
			break;
		default:
			break;
	}
	besr.h_inc = (*(val_OV0_P1_H_INC)&0x3fff) | ((*(val_OV0_P23_H_INC)&0x3fff)<<16);
	besr.step_by = (*(val_OV0_P1_H_STEP_BY)&0x7) | ((*(val_OV0_P23_H_STEP_BY)&0x7)<<8);
}

/* Setup Black Bordering */

static void ComputeBorders(vidix_playback_t *config, int VertUVSubSample)
{
	float tempBLANK_LINES_AT_TOP;
	unsigned TopLine, BottomLine, SourceLinesUsed, TopUVLine, BottomUVLine, SourceUVLinesUsed;
	unsigned long val_OV0_P1_ACTIVE_LINES_M1, val_OV0_P1_BLNK_LN_AT_TOP_M1;
	unsigned long val_OV0_P23_ACTIVE_LINES_M1, val_OV0_P23_BLNK_LN_AT_TOP_M1;
	if(floor((float)config->src.y) < 0.0)
	{
		tempBLANK_LINES_AT_TOP = -floor((float)config->src.y);
		TopLine = 0;
	}
	else
	{
		tempBLANK_LINES_AT_TOP = 0.0;
		TopLine = (unsigned)((long)floor((float)config->src.y));
	}
	/* Round rSrcBottom up and subtract one */
	if(ceil((float)(config->src.y+config->src.h)) > (float)config->src.h)
		BottomLine = config->src.h - 1;
	else
		BottomLine = config->src.y + config->src.h - 1;
	if(BottomLine >= TopLine)
		SourceLinesUsed = BottomLine - TopLine + 1;
	else
		SourceLinesUsed = 1;
	val_OV0_P1_ACTIVE_LINES_M1 = (unsigned long)(SourceLinesUsed - 1);
	val_OV0_P1_BLNK_LN_AT_TOP_M1 = (unsigned long)(((long)tempBLANK_LINES_AT_TOP)-1) & 0xfff;
	if((config->src.y/VertUVSubSample) < 0)
		TopUVLine = 0;
	else
		TopUVLine = config->src.y/VertUVSubSample;   /* Round rSrcTop down */
	if((long)ceil((config->src.y+config->src.h)/VertUVSubSample) > (config->src.h/VertUVSubSample))
		BottomUVLine = (unsigned)(config->src.h/VertUVSubSample)-1;
	else
		BottomUVLine = (unsigned)((long)ceil(((config->src.y+config->src.h)/VertUVSubSample))-1);
	if(BottomUVLine >= TopUVLine)
		SourceUVLinesUsed = BottomUVLine - TopUVLine + 1;
	else
		SourceUVLinesUsed = 1;
	val_OV0_P23_ACTIVE_LINES_M1 = (unsigned long)(SourceUVLinesUsed - 1);
	val_OV0_P23_BLNK_LN_AT_TOP_M1 = (unsigned long)((long)(tempBLANK_LINES_AT_TOP/(float)VertUVSubSample)-1) & 0x7ff;
	besr.p1_blank_lines_at_top = (val_OV0_P1_BLNK_LN_AT_TOP_M1  & 0xfff) | ((val_OV0_P1_ACTIVE_LINES_M1 & 0xfff) << 16);
	besr.p23_blank_lines_at_top = (val_OV0_P23_BLNK_LN_AT_TOP_M1 & 0x7ff) | ((val_OV0_P23_ACTIVE_LINES_M1 & 0x7ff) << 16);
}

static void ComputeXStartEnd(int is_400, unsigned long LeftPixel, unsigned long LeftUVPixel, unsigned long MemWordsInBytes, unsigned long BytesPerPixel, unsigned long SourceWidthInPixels,
 unsigned long P1StepSize, unsigned long BytesPerUVPixel, unsigned long SourceUVWidthInPixels, unsigned long P23StepSize, unsigned long *p1_x_start, unsigned long *p2_x_start)
{
	unsigned long val_OV0_P1_X_START, val_OV0_P2_X_START, val_OV0_P3_X_START;
	unsigned long val_OV0_P1_X_END, val_OV0_P2_X_END, val_OV0_P3_X_END;
	/* ToDo_Active: At the moment we are not using iOV0_VID_BUF?_START_PIX, but instead		// are using iOV0_P?_X_START and iOV0_P?_X_END. We should use "start pix" and	    // "width" to derive the start and end. */
	val_OV0_P1_X_START = (int)LeftPixel % (MemWordsInBytes/BytesPerPixel);
	val_OV0_P1_X_END = (int)((val_OV0_P1_X_START + SourceWidthInPixels - 1) / P1StepSize) * P1StepSize;
	val_OV0_P2_X_START = val_OV0_P2_X_END = 0;
	switch(besr.surf_id)
	{
		case 9:
		case 10:
		case 13:
		case 14:
			/* ToDo_Active: The driver must insure that the initial value is */
			/* a multiple of a power of two when decimating */
			val_OV0_P2_X_START = (int)LeftUVPixel % (MemWordsInBytes/BytesPerUVPixel);
			val_OV0_P2_X_END = (int)((val_OV0_P2_X_START + SourceUVWidthInPixels - 1) / P23StepSize) * P23StepSize;
			break;
		case 11:
		case 12:
			val_OV0_P2_X_START = (int)LeftUVPixel % (MemWordsInBytes/(BytesPerPixel*2));
			val_OV0_P2_X_END = (int)((val_OV0_P2_X_START + SourceUVWidthInPixels - 1) / P23StepSize) * P23StepSize;
			break;
		case 3:
		case 4:
			val_OV0_P2_X_START = val_OV0_P1_X_START;
			/* This value is needed only to allow proper setting of */
			/* val_OV0_PRESHIFT_P23_TO */
			/* val_OV0_P2_X_END = 0; */
			break;
		case 6:
			val_OV0_P2_X_START = (int)LeftPixel % (MemWordsInBytes/BytesPerPixel);
			val_OV0_P2_X_END = (int)((val_OV0_P1_X_START + SourceWidthInPixels - 1) / P23StepSize) * P23StepSize;
			break;
		default:
//			DPRINT("VIDIX: unknown fourcc\r\n");
	    break;
	}
	val_OV0_P3_X_START = val_OV0_P2_X_START;
	val_OV0_P3_X_END = val_OV0_P2_X_END;
	besr.p1_x_start_end = (val_OV0_P1_X_END&0x7ff) | ((val_OV0_P1_X_START&0x7ff)<<16);
	besr.p2_x_start_end = (val_OV0_P2_X_END&0x7ff) | ((val_OV0_P2_X_START&0x7ff)<<16);
	besr.p3_x_start_end = (val_OV0_P3_X_END&0x7ff) | ((val_OV0_P3_X_START&0x7ff)<<16);
	if(is_400)
	{
		besr.p2_x_start_end = 0;
		besr.p3_x_start_end = 0;
	}
	*p1_x_start = val_OV0_P1_X_START;
	*p2_x_start = val_OV0_P2_X_START;
}

#ifdef VIDIX_FILTER

static void ComputeAccumInit(unsigned long val_OV0_P1_X_START, unsigned long val_OV0_P2_X_START, unsigned long val_OV0_P1_H_INC, unsigned long val_OV0_P23_H_INC, unsigned long val_OV0_P1_H_STEP_BY,
 unsigned long val_OV0_P23_H_STEP_BY, unsigned long CRT_V_INC, unsigned long P1GroupSize, unsigned long P23GroupSize, unsigned long val_OV0_P1_MAX_LN_IN_PER_LN_OUT, unsigned long val_OV0_P23_MAX_LN_IN_PER_LN_OUT)
{
	unsigned long val_OV0_P1_H_ACCUM_INIT, val_OV0_PRESHIFT_P1_TO;
	unsigned long val_OV0_P23_H_ACCUM_INIT, val_OV0_PRESHIFT_P23_TO;
	unsigned long val_OV0_P1_V_ACCUM_INIT, val_OV0_P23_V_ACCUM_INIT;
	/* 2.5 puts the kernal 50% of the way between the source pixel that is off screen */
	/* and the first on-screen source pixel. "(float)valOV0_P?_H_INC / (1<<0xc)" is */
	/* the distance (in source pixel coordinates) to the center of the first */
	/* destination pixel. Need to add additional pixels depending on how many pixels */
	/* are fetched at a time and how many pixels in a set are masked. */
	/* P23 values are always fetched in groups of two or four. If the start */
	/* pixel does not fall on the boundary, then we need to shift preshift for */
	/* some additional pixels */
	{
		float ExtraHalfPixel, tempAdditionalShift, tempP1HStartPoint, tempP23HStartPoint, tempP1Init, tempP23Init;
		if(besr.horz_pick_nearest)
			ExtraHalfPixel = 0.5;
		else
			ExtraHalfPixel = 0.0;
		tempAdditionalShift = val_OV0_P1_X_START % P1GroupSize + ExtraHalfPixel;
		tempP1HStartPoint = tempAdditionalShift + 2.5 + ((float)val_OV0_P1_H_INC / (1<<0xd));
		tempP1Init = (float)((int)(tempP1HStartPoint * (1<<0x5) + 0.5)) / (1<<0x5);
		/* P23 values are always fetched in pairs. If the start pixel is odd, then we */
		/* need to shift an additional pixel */
		/* Note that if the pitch is a multiple of two, and if we store fields using */
		/* the traditional planer format where the V plane and the U plane share the */
		/* same pitch, then OverlayRegFields->val_OV0_P2_X_START % P23Group */
		/* OverlayRegFields->val_OV0_P3_X_START % P23GroupSize. Either way */
		/* it is a requirement that the U and V start on the same polarity byte */
		/* (even or odd). */
		tempAdditionalShift = val_OV0_P2_X_START % P23GroupSize + ExtraHalfPixel;
		tempP23HStartPoint = tempAdditionalShift + 2.5 + ((float)val_OV0_P23_H_INC / (1<<0xd));
		tempP23Init = (float)((int)(tempP23HStartPoint * (1<<0x5) + 0.5)) / (1 << 0x5);
		val_OV0_P1_H_ACCUM_INIT = (unsigned long)((long)((tempP1Init - floor(tempP1Init)) * (float)(1<<0x5)));
		val_OV0_PRESHIFT_P1_TO = (unsigned long)((long)tempP1Init);
		val_OV0_P23_H_ACCUM_INIT = (unsigned long)((long)((tempP23Init - floor(tempP23Init)) * (float)(1<<0x5)));
		val_OV0_PRESHIFT_P23_TO = (unsigned long)((long)tempP23Init);
	}
	/* Calculate values for initializing the vertical accumulators */
	{
		float ExtraHalfLine, ExtraFullLine, tempP1VStartPoint, tempP23VStartPoint;
		if(besr.vert_pick_nearest)
			ExtraHalfLine = 0.5;
		else
			ExtraHalfLine = 0.0;
		if(val_OV0_P1_H_STEP_BY==0)
			ExtraFullLine = 1.0;
		else
			ExtraFullLine = 0.0;
		tempP1VStartPoint = 1.5 + ExtraFullLine + ExtraHalfLine + ((float)CRT_V_INC / (1<<0xd));
		if(tempP1VStartPoint>2.5 + 2*ExtraFullLine)
			tempP1VStartPoint = 2.5 + 2*ExtraFullLine;
		val_OV0_P1_V_ACCUM_INIT = (int)(tempP1VStartPoint * (1<<0x5) + 0.5);
		if(val_OV0_P23_H_STEP_BY==0)
			ExtraFullLine = 1.0;
	  else
		  ExtraFullLine = 0.0;
		switch(besr.surf_id)
		{
			case 10:
			case 13:
			case 14:
				tempP23VStartPoint = 1.5 + ExtraFullLine + ExtraHalfLine + ((float)CRT_V_INC / (1<<0xe));
				break;
			case 9:
				tempP23VStartPoint = 1.5 + ExtraFullLine + ExtraHalfLine + ((float)CRT_V_INC / (1<<0xf));
				break;
			case 3:
			case 4:
			case 6:
			case 11:
			case 12:
				tempP23VStartPoint = 0;
				break;
			default:
				tempP23VStartPoint = 0xFFFF; /* insert debug statement here */
				break;
		}
		if(tempP23VStartPoint>2.5 + 2*ExtraFullLine)
			tempP23VStartPoint = 2.5 + 2*ExtraFullLine;
		val_OV0_P23_V_ACCUM_INIT = (int)(tempP23VStartPoint * (1<<0x5) + 0.5);
	}
	besr.p1_h_accum_init = ((val_OV0_P1_H_ACCUM_INIT&0x1f)<<15)  |((val_OV0_PRESHIFT_P1_TO&0xf)<<28);
	besr.p1_v_accum_init = (val_OV0_P1_MAX_LN_IN_PER_LN_OUT&0x3) |((val_OV0_P1_V_ACCUM_INIT&0x7ff)<<15);
	besr.p23_h_accum_init= ((val_OV0_P23_H_ACCUM_INIT&0x1f)<<15) |((val_OV0_PRESHIFT_P23_TO&0xf)<<28);
	besr.p23_v_accum_init= (val_OV0_P23_MAX_LN_IN_PER_LN_OUT&0x3)|((val_OV0_P23_V_ACCUM_INIT&0x3ff)<<15);
}

typedef struct RangeAndCoefSet
{
	float Range;
	signed char CoefSet[5][4];
} RANGEANDCOEFSET;

/* Filter Setup Routine */
static void FilterSetup(unsigned long val_OV0_P1_H_INC)
{
	static RANGEANDCOEFSET ArrayOfSets[] = {
	{0.25, {{ 7,	16,  9,	 0}, { 7,   16,	 9,  0}, { 5,	15, 11,	 1}, { 4,   15, 12,  1}, { 3,	13,   13,    3}, }},
	{0.26, {{ 7,	16,  9,	 0}, { 7,   16,	 9,  0}, { 5,	15, 11,	 1}, { 4,   15, 12,  1}, { 3,	13, 13,	 3}, }},
	{0.27, {{ 7,	16,  9,	 0}, { 7,   16,	 9,  0}, { 5,	15, 11,	 1}, { 4,   15, 12,  1}, { 3,	13, 13,	 3}, }},
	{0.28, {{ 7,	16,  9,	 0}, { 7,   16,	 9,  0}, { 5,	15, 11,	 1}, { 4,   15, 12,  1}, { 3,	13, 13,	 3}, }},
	{0.29, {{ 7,	16,  9,	 0}, { 7,   16,	 9,  0}, { 5,	15, 11,	 1}, { 4,   15, 12,  1}, { 3,	13, 13,	 3}, }},
	{0.30, {{ 7,	16,  9,	 0}, { 7,   16,	 9,  0}, { 5,	15, 11,	 1}, { 4,   15, 12,  1}, { 3,	13, 13,	 3}, }},
	{0.31, {{ 7,	16,  9,	 0}, { 7,   16,	 9,  0}, { 5,	15, 11,	 1}, { 4,   15, 12,  1}, { 3,	13, 13,	 3}, }},
	{0.32, {{ 7,	16,  9,	 0}, { 7,   16,	 9,  0}, { 5,	15, 11,	 1}, { 4,   15, 12,  1}, { 3,	13, 13,	 3}, }},
	{0.33, {{ 7,	16,  9,	 0}, { 7,   16,	 9,  0}, { 5,	15, 11,	 1}, { 4,   15, 12,  1}, { 3,	13, 13,	 3}, }},
	{0.34, {{ 7,	16,  9,	 0}, { 7,   16,	 9,  0}, { 5,	15, 11,	 1}, { 4,   15, 12,  1}, { 3,	13, 13,	 3}, }},
	{0.35, {{ 7,	16,  9,	 0}, { 7,   16,	 9,  0}, { 5,	15, 11,	 1}, { 4,   15, 12,  1}, { 3,	13, 13,	 3}, }},
	{0.36, {{ 7,	16,  9,	 0}, { 7,   16,	 9,  0}, { 5,	15, 11,	 1}, { 4,   15, 12,  1}, { 3,	13, 13,	 3}, }},
	{0.37, {{ 7,	16,  9,	 0}, { 7,   16,	 9,  0}, { 5,	15, 11,	 1}, { 4,   15, 12,  1}, { 3,	13, 13,	 3}, }},
	{0.38, {{ 7,	16,  9,	 0}, { 7,   16,	 9,  0}, { 5,	15, 11,	 1}, { 4,   15, 12,  1}, { 3,	13, 13,	 3}, }},
	{0.39, {{ 7,	16,  9,	 0}, { 7,   16,	 9,  0}, { 5,	15, 11,	 1}, { 4,   15, 12,  1}, { 3,	13, 13,	 3}, }},
	{0.40, {{ 7,	16,  9,	 0}, { 7,   16,	 9,  0}, { 5,	15, 11,	 1}, { 4,   15, 12,  1}, { 3,	13, 13,	 3}, }},
	{0.41, {{ 7,	16,  9,	 0}, { 7,   16,	 9,  0}, { 5,	15, 11,	 1}, { 4,   15, 12,  1}, { 3,	13, 13,	 3}, }},
	{0.42, {{ 7,	16,  9,	 0}, { 7,   16,	 9,  0}, { 5,	15, 11,	 1}, { 4,   15, 12,  1}, { 3,	13, 13,	 3}, }},
	{0.43, {{ 7,	16,  9,	 0}, { 7,   16,	 9,  0}, { 5,	15, 11,	 1}, { 4,   15, 12,  1}, { 3,	13, 13,	 3}, }},
	{0.44, {{ 7,	16,  9,	 0}, { 7,   16,	 9,  0}, { 5,	15, 11,	 1}, { 4,   15, 12,  1}, { 3,	13, 13,	 3}, }},
	{0.45, {{ 7,	16,  9,	 0}, { 7,   16,	 9,  0}, { 5,	15, 11,	 1}, { 4,   15, 12,  1}, { 3,	13, 13,	 3}, }},
	{0.46, {{ 7,	16,  9,	 0}, { 7,   16,	 9,  0}, { 5,	15, 11,	 1}, { 4,   15, 12,  1}, { 3,	13, 13,	 3}, }},
	{0.47, {{ 7,	16,  9,	 0}, { 7,   16,	 9,  0}, { 5,	15, 11,	 1}, { 4,   15, 12,  1}, { 3,	13, 13,	 3}, }},
	{0.48, {{ 7,	16,  9,	 0}, { 7,   16,	 9,  0}, { 5,	15, 11,	 1}, { 4,   15, 12,  1}, { 3,	13, 13,	 3}, }},
	{0.49, {{ 7,	16,  9,	 0}, { 7,   16,	 9,  0}, { 5,	15, 11,	 1}, { 4,   15, 12,  1}, { 3,	13, 13,	 3}, }},
	{0.50, {{ 7,	16,  9,	 0}, { 7,   16,	 9,  0}, { 5,	15, 11,	 1}, { 4,   15, 12,  1}, { 3,	13, 13,	 3}, }},
	{0.51, {{ 7,	17,  8,	 0}, { 6,   17,	 9,  0}, { 5,	15, 11,	 1}, { 4,   15, 12,  1}, { 2,	14, 14,	 2}, }},
	{0.52, {{ 7,	17,  8,	 0}, { 6,   17,	 9,  0}, { 5,	16, 11,	 0}, { 3,   15, 13,  1}, { 2,	14, 14,	 2}, }},
	{0.53, {{ 7,	17,  8,	 0}, { 6,   17,	 9,  0}, { 5,	16, 11,	 0}, { 3,   15, 13,  1}, { 2,	14, 14,	 2}, }},
	{0.54, {{ 7,	17,  8,	 0}, { 6,   17,	 9,  0}, { 4,	17, 11,	 0}, { 3,   15, 13,  1}, { 2,	14, 14,	 2}, }},
	{0.55, {{ 7,	18,  7,	 0}, { 6,   17,	 9,  0}, { 4,	17, 11,	 0}, { 3,   15, 13,  1}, { 1,	15, 15,	 1}, }},
	{0.56, {{ 7,	18,  7,	 0}, { 5,   18,	 9,  0}, { 4,	17, 11,	 0}, { 2,   17, 13,  0}, { 1,	15, 15,	 1}, }},
	{0.57, {{ 7,	18,  7,	 0}, { 5,   18,	 9,  0}, { 4,	17, 11,	 0}, { 2,   17, 13,  0}, { 1,	15, 15,	 1}, }},
	{0.58, {{ 7,	18,  7,	 0}, { 5,   18,	 9,  0}, { 4,	17, 11,	 0}, { 2,   17, 13,  0}, { 1,	15, 15,	 1}, }},
	{0.59, {{ 7,	18,  7,	 0}, { 5,   18,	 9,  0}, { 4,	17, 11,	 0}, { 2,   17, 13,  0}, { 1,	15, 15,	 1}, }},
	{0.60, {{ 7,	18,  8, -1}, { 6,   17, 10, -1}, { 4,	17, 11,	 0}, { 2,   17, 13,  0}, { 1,	15, 15,	 1}, }},
	{0.61, {{ 7,	18,  8, -1}, { 6,   17, 10, -1}, { 4,	17, 11,	 0}, { 2,   17, 13,  0}, { 1,	15, 15,	 1}, }},
	{0.62, {{ 7,	18,  8, -1}, { 6,   17, 10, -1}, { 4,	17, 11,	 0}, { 2,   17, 13,  0}, { 1,	15, 15,	 1}, }},
	{0.63, {{ 7,	18,  8, -1}, { 6,   17, 10, -1}, { 4,	17, 11,	 0}, { 2,   17, 13,  0}, { 1,	15, 15,	 1}, }},
	{0.64, {{ 7,	18,  8, -1}, { 6,   17, 10, -1}, { 4,	17, 12, -1}, { 2,   17, 13,  0}, { 1,	15, 15,	 1}, }},
	{0.65, {{ 7,	18,  8, -1}, { 6,   17, 10, -1}, { 4,	17, 12, -1}, { 2,   17, 13,  0}, { 0,	16, 16,	 0}, }},
	{0.66, {{ 7,	18,  8, -1}, { 6,   18, 10, -2}, { 4,	17, 12, -1}, { 2,   17, 13,  0}, { 0,	16, 16,	 0}, }},
	{0.67, {{ 7,	20,  7, -2}, { 5,   19, 10, -2}, { 3,	18, 12, -1}, { 2,   17, 13,  0}, { 0,	16, 16,	 0}, }},
	{0.68, {{ 7,	20,  7, -2}, { 5,   19, 10, -2}, { 3,	19, 12, -2}, { 1,   18, 14, -1}, { 0,	16, 16,	 0}, }},
	{0.69, {{ 7,	20,  7, -2}, { 5,   19, 10, -2}, { 3,	19, 12, -2}, { 1,   18, 14, -1}, { 0,	16, 16,	 0}, }},
	{0.70, {{ 7,	20,  7, -2}, { 5,   20,	 9, -2}, { 3,	19, 12, -2}, { 1,   18, 14, -1}, { 0,	16, 16,	 0}, }},
	{0.71, {{ 7,	20,  7, -2}, { 5,   20,	 9, -2}, { 3,	19, 12, -2}, { 1,   18, 14, -1}, { 0,	16, 16,	 0}, }},
	{0.72, {{ 7,	20,  7, -2}, { 5,   20,	 9, -2}, { 2,	20, 12, -2}, { 0,   19, 15, -2}, {-1,	17, 17, -1}, }},
	{0.73, {{ 7,	20,  7, -2}, { 4,   21,	 9, -2}, { 2,	20, 12, -2}, { 0,   19, 15, -2}, {-1,	17, 17, -1}, }},
	{0.74, {{ 6,	22,  6, -2}, { 4,   21,	 9, -2}, { 2,	20, 12, -2}, { 0,   19, 15, -2}, {-1,	17, 17, -1}, }},
	{0.75, {{ 6,	22,  6, -2}, { 4,   21,	 9, -2}, { 1,	21, 12, -2}, { 0,   19, 15, -2}, {-1,	17, 17, -1}, }},
	{0.76, {{ 6,	22,  6, -2}, { 4,   21,	 9, -2}, { 1,	21, 12, -2}, { 0,   19, 15, -2}, {-1,	17, 17, -1}, }},
	{0.77, {{ 6,	22,  6, -2}, { 3,   22,	 9, -2}, { 1,	22, 12, -3}, { 0,   19, 15, -2}, {-2,	18, 18, -2}, }},
	{0.78, {{ 6,	21,  6, -1}, { 3,   22,	 9, -2}, { 1,	22, 12, -3}, { 0,   19, 15, -2}, {-2,	18, 18, -2}, }},
	{0.79, {{ 5,	23,  5, -1}, { 3,   22,	 9, -2}, { 0,	23, 12, -3}, {-1,   21, 15, -3}, {-2,	18, 18, -2}, }},
	{0.80, {{ 5,	23,  5, -1}, { 3,   23,	 8, -2}, { 0,	23, 12, -3}, {-1,   21, 15, -3}, {-2,	18, 18, -2}, }},
	{0.81, {{ 5,	23,  5, -1}, { 2,   24,	 8, -2}, { 0,	23, 12, -3}, {-1,   21, 15, -3}, {-2,	18, 18, -2}, }},
	{0.82, {{ 5,	23,  5, -1}, { 2,   24,	 8, -2}, { 0,	23, 12, -3}, {-1,   21, 15, -3}, {-3,	19, 19, -3}, }},
	{0.83, {{ 5,	23,  5, -1}, { 2,   24,	 8, -2}, { 0,	23, 11, -2}, {-2,   22, 15, -3}, {-3,	19, 19, -3}, }},
	{0.84, {{ 4,	25,  4, -1}, { 1,   25,	 8, -2}, { 0,	23, 11, -2}, {-2,   22, 15, -3}, {-3,	19, 19, -3}, }},
	{0.85, {{ 4,	25,  4, -1}, { 1,   25,	 8, -2}, { 0,	23, 11, -2}, {-2,   22, 15, -3}, {-3,	19, 19, -3}, }},
	{0.86, {{ 4,	24,  4,	 0}, { 1,   25,	 7, -1}, {-1,	24, 11, -2}, {-2,   22, 15, -3}, {-3,	19, 19, -3}, }},
	{0.87, {{ 4,	24,  4,	 0}, { 1,   25,	 7, -1}, {-1,	24, 11, -2}, {-2,   22, 15, -3}, {-3,	19, 19, -3}, }},
	{0.88, {{ 3,	26,  3,	 0}, { 0,   26,	 7, -1}, {-1,	24, 11, -2}, {-3,   23, 15, -3}, {-3,	19, 19, -3}, }},
	{0.89, {{ 3,	26,  3,	 0}, { 0,   26,	 7, -1}, {-1,	24, 11, -2}, {-3,   23, 15, -3}, {-3,	19, 19, -3}, }},
	{0.90, {{ 3,	26,  3,	 0}, { 0,   26,	 7, -1}, {-2,	25, 11, -2}, {-3,   23, 15, -3}, {-3,	19, 19, -3}, }},
	{0.91, {{ 3,	26,  3,	 0}, { 0,   27,	 6, -1}, {-2,	25, 11, -2}, {-3,   23, 15, -3}, {-3,	19, 19, -3}, }},
	{0.92, {{ 2,	28,  2,	 0}, { 0,   27,	 6, -1}, {-2,	25, 11, -2}, {-3,   23, 15, -3}, {-3,	19, 19, -3}, }},
	{0.93, {{ 2,	28,  2,	 0}, { 0,   26,	 6,  0}, {-2,	25, 10, -1}, {-3,   23, 15, -3}, {-3,	19, 19, -3}, }},
	{0.94, {{ 2,	28,  2,	 0}, { 0,   26,	 6,  0}, {-2,	25, 10, -1}, {-3,   23, 15, -3}, {-3,	19, 19, -3}, }},
	{0.95, {{ 1,	30,  1,	 0}, {-1,   28,	 5,  0}, {-3,	26, 10, -1}, {-3,   23, 14, -2}, {-3,	19, 19, -3}, }},
	{0.96, {{ 1,	30,  1,	 0}, {-1,   28,	 5,  0}, {-3,	26, 10, -1}, {-3,   23, 14, -2}, {-3,	19, 19, -3}, }},
	{0.97, {{ 1,	30,  1,	 0}, {-1,   28,	 5,  0}, {-3,	26, 10, -1}, {-3,   23, 14, -2}, {-3,	19, 19, -3}, }},
	{0.98, {{ 1,	30,  1,	 0}, {-2,   29,	 5,  0}, {-3,	27,  9, -1}, {-3,   23, 14, -2}, {-3,	19, 19, -3}, }},
	{0.99, {{ 0,	32,  0,	 0}, {-2,   29,	 5,  0}, {-3,	27,  9, -1}, {-4,   24, 14, -2}, {-3,	19, 19, -3}, }},
	{1.00, {{ 0,	32,  0,	 0}, {-2,   29,	 5,  0}, {-3,	27,  9, -1}, {-4,   24, 14, -2}, {-3,	19, 19, -3}, }}
	};
	float DSR;
	unsigned ArrayElement;
	DSR = (float)(1<<0xc)/val_OV0_P1_H_INC;
	if(DSR<.25)
		DSR=.25;
	if(DSR>1.0)
		DSR=1.0;
	ArrayElement = (int)((DSR-0.25) * 100.0);
	besr.four_tap_coeff[0] = (ArrayOfSets[ArrayElement].CoefSet[0][0] & 0xf) | ((ArrayOfSets[ArrayElement].CoefSet[0][1] & 0x7f)<<8) | ((ArrayOfSets[ArrayElement].CoefSet[0][2] & 0x7f)<<16) | ((ArrayOfSets[ArrayElement].CoefSet[0][3] & 0xf)<<24);
	besr.four_tap_coeff[1] = (ArrayOfSets[ArrayElement].CoefSet[1][0] & 0xf) | ((ArrayOfSets[ArrayElement].CoefSet[1][1] & 0x7f)<<8) | ((ArrayOfSets[ArrayElement].CoefSet[1][2] & 0x7f)<<16) | ((ArrayOfSets[ArrayElement].CoefSet[1][3] & 0xf)<<24);
	besr.four_tap_coeff[2] = (ArrayOfSets[ArrayElement].CoefSet[2][0] & 0xf) | ((ArrayOfSets[ArrayElement].CoefSet[2][1] & 0x7f)<<8) | ((ArrayOfSets[ArrayElement].CoefSet[2][2] & 0x7f)<<16) | ((ArrayOfSets[ArrayElement].CoefSet[2][3] & 0xf)<<24);
	besr.four_tap_coeff[3] = (ArrayOfSets[ArrayElement].CoefSet[3][0] & 0xf) | ((ArrayOfSets[ArrayElement].CoefSet[3][1] & 0x7f)<<8) | ((ArrayOfSets[ArrayElement].CoefSet[3][2] & 0x7f)<<16) | ((ArrayOfSets[ArrayElement].CoefSet[3][3] & 0xf)<<24);
	besr.four_tap_coeff[4] = (ArrayOfSets[ArrayElement].CoefSet[4][0] & 0xf) | ((ArrayOfSets[ArrayElement].CoefSet[4][1] & 0x7f)<<8) | ((ArrayOfSets[ArrayElement].CoefSet[4][2] & 0x7f)<<16) | ((ArrayOfSets[ArrayElement].CoefSet[4][3] & 0xf)<<24);
}

#endif

/* The minimal value of horizontal scale ratio when hard coded coefficients
   are suitable for the best quality. */
const float MinHScaleHard=0.75;

static int radeon_vid_init_video(vidix_playback_t *config)
{
	struct radeonfb_info *rinfo = info_fvdi->par;
	float H_scale_ratio, V_scale_ratio;
	unsigned long i, src_w, src_h,dest_w, dest_h, pitch, left, leftUV, top, h_inc;
	unsigned long val_OV0_P1_H_INC = 0, val_OV0_P1_H_STEP_BY, val_OV0_P23_H_INC = 0, val_OV0_P23_H_STEP_BY;
	unsigned long val_OV0_P1_X_START, val_OV0_P2_X_START;
	unsigned long val_OV0_P1_MAX_LN_IN_PER_LN_OUT, val_OV0_P23_MAX_LN_IN_PER_LN_OUT;
	unsigned long CRT_V_INC;
	unsigned long BytesPerOctWord, LogMemWordsInBytes, MemWordsInBytes, LogTileWidthInMemWords;
	unsigned long TileWidthInMemWords, TileWidthInBytes, LogTileHeight, TileHeight;
	unsigned long PageSizeInBytes, OV0LB_Rows;
	unsigned long SourceWidthInMemWords, SourceUVWidthInMemWords;
	unsigned long SourceWidthInPixels, SourceUVWidthInPixels;
	unsigned long RightPixel,RightUVPixel, LeftPixel, LeftUVPixel;
	int is_400, is_410, is_420, best_pitch,mpitch;
	int horz_repl_factor,interlace_factor;
	int BytesPerPixel, BytesPerUVPixel, HorzUVSubSample, VertUVSubSample;
	int DisallowFourTapVertFiltering, DisallowFourTapUVVertFiltering;
	radeon_vid_stop_video();
	left = config->src.x << 16;
	top =  config->src.y << 16;
	src_h = config->src.h;
	src_w = config->src.w;
	is_400 = is_410 = is_420 = 0;
	if(config->fourcc == IMGFMT_YV12 || config->fourcc == IMGFMT_I420 || config->fourcc == IMGFMT_IYUV)
		is_420 = 1;
	if(config->fourcc == IMGFMT_YVU9 || config->fourcc == IMGFMT_IF09)
		is_410 = 1;
	if(config->fourcc == IMGFMT_Y800)
		is_400 = 1;
	best_pitch = radeon_query_pitch(config->fourcc,&config->src.pitch);
	mpitch = best_pitch-1;
	BytesPerOctWord = 16;
	LogMemWordsInBytes = 4;
	MemWordsInBytes = 1<<LogMemWordsInBytes;
	LogTileWidthInMemWords = 2;
	TileWidthInMemWords = 1<<LogTileWidthInMemWords;
	TileWidthInBytes = 1<<(LogTileWidthInMemWords+LogMemWordsInBytes);
	LogTileHeight = 4;
	TileHeight = 1<<LogTileHeight;
	PageSizeInBytes = 64*MemWordsInBytes;
	OV0LB_Rows = 96;
	h_inc = 1;
	switch(config->fourcc)
	{
		/* 4:0:0*/
		case IMGFMT_Y800:
		/* 4:1:0*/
		case IMGFMT_YVU9:
		case IMGFMT_IF09:
		/* 4:2:0 */
		case IMGFMT_IYUV:
		case IMGFMT_YV12:
		case IMGFMT_I420:
			pitch = (src_w + mpitch) & ~mpitch;
			config->dest.pitch.y = config->dest.pitch.u = config->dest.pitch.v = best_pitch;
			break;
		/* RGB 4:4:4:4 */
		case IMGFMT_RGB32:
		case IMGFMT_BGR32:
			pitch = (src_w*4 + mpitch) & ~mpitch;
			config->dest.pitch.y = config->dest.pitch.u = config->dest.pitch.v = best_pitch;
			break;
		/* 4:2:2 */
		default: /* RGB15, RGB16, YVYU, UYVY, YUY2 */
			pitch = ((src_w*2) + mpitch) & ~mpitch;
			config->dest.pitch.y = config->dest.pitch.u = config->dest.pitch.v = best_pitch;
			break;
	}
	besr.load_prg_start=0;
	besr.swap_uv=0;
	switch(config->fourcc)
	{
		case IMGFMT_RGB15:
			besr.swap_uv=1;
		case IMGFMT_BGR15:
			besr.surf_id = SCALER_SOURCE_15BPP>>8;
			besr.load_prg_start = 1;
			if(besr.big_endian)
				besr.swap_uv ^= 1;
			break;
		case IMGFMT_RGB16:
			besr.swap_uv=1;
		case IMGFMT_BGR16:
			besr.surf_id = SCALER_SOURCE_16BPP>>8;
			besr.load_prg_start = 1;
			if(besr.big_endian)
				besr.swap_uv ^= 1;
			break;
		case IMGFMT_RGB32:
			besr.swap_uv=1;
		case IMGFMT_BGR32:
			besr.surf_id = SCALER_SOURCE_32BPP>>8;
			besr.load_prg_start = 1;
			if(besr.big_endian)
				besr.swap_uv ^= 1;
			break;
			/* 4:1:0*/
		case IMGFMT_IF09:
		case IMGFMT_YVU9:
			besr.surf_id = SCALER_SOURCE_YUV9>>8;
			break;
		/* 4:0:0*/
		case IMGFMT_Y800:
		/* 4:2:0 */
		case IMGFMT_IYUV:
		case IMGFMT_I420:
		case IMGFMT_YV12:
			besr.surf_id = SCALER_SOURCE_YUV12>>8;
			break;
		/* 4:2:2 */
		case IMGFMT_YVYU:
		case IMGFMT_UYVY:
			besr.surf_id = SCALER_SOURCE_YVYU422>>8;
			break;
		case IMGFMT_YUY2:
		default:
			besr.surf_id = SCALER_SOURCE_VYUY422>>8;
			break;
	}
	switch(besr.surf_id)
	{
		case 3:
		case 4:
		case 11:
		case 12: BytesPerPixel = 2; break;
		case 6: BytesPerPixel = 4; break;
		case 9:
		case 10:
		case 13:
		case 14: BytesPerPixel = 1; break;
		default: BytesPerPixel = 0; break;
	}
	switch(besr.surf_id)
	{
		case 3:
		case 4:	BytesPerUVPixel = 0; break;/* In RGB modes, the BytesPerUVPixel is don't care */
		case 11:
		case 12: BytesPerUVPixel = 2; break;
		case 6:	BytesPerUVPixel = 0; break;	/* In RGB modes, the BytesPerUVPixel is don't care */
		case 9:
		case 10: BytesPerUVPixel = 1; break;
		case 13:
		case 14: BytesPerUVPixel = 2; break;
		default: BytesPerUVPixel = 0; break;
	}
	switch(besr.surf_id)
	{
		case 3:
		case 4:
		case 6:	HorzUVSubSample = 1; break;
		case 9:	HorzUVSubSample = 4; break;
		case 10:
		case 11:
		case 12:
		case 13:
		case 14: HorzUVSubSample = 2; break;
		default: HorzUVSubSample = 0; break;
	}
	switch(besr.surf_id)
	{
		case 3:
		case 4:
		case 6:
		case 11:
		case 12: VertUVSubSample = 1; break;
		case 9: VertUVSubSample = 4; break;
		case 10:
		case 13:
		case 14: VertUVSubSample = 2; break;
		default: VertUVSubSample = 0; break;
	}
	DisallowFourTapVertFiltering = 0; /* Allow it by default */
	DisallowFourTapUVVertFiltering = 0;	/* Allow it by default */
	LeftPixel = config->src.x;
	RightPixel = config->src.w-1;
	if(floor((float)config->src.x/(float)HorzUVSubSample) < 0.0)
		LeftUVPixel = 0;
	else
		LeftUVPixel = (unsigned long)((long)(floor((float)config->src.x/(float)HorzUVSubSample)));
	if(ceil((float)(config->src.x+config->src.w)/(float)HorzUVSubSample) > ((float)config->src.w/(float)HorzUVSubSample))
		RightUVPixel = (unsigned long)(config->src.w/HorzUVSubSample - 1);
	else
		RightUVPixel = (unsigned long)((long)ceil((float)(config->src.x+config->src.w)/(float)HorzUVSubSample) - 1);
	/* Top, Bottom and Right Crops can be out of range. The driver will program the hardware
	   to create a black border at the top and bottom. This is useful for DVD letterboxing. */
	SourceWidthInPixels = config->src.w + 1;
	SourceUVWidthInPixels = RightUVPixel - LeftUVPixel + 1;
	SourceWidthInMemWords = (unsigned long)((long)(ceil((float)(RightPixel*BytesPerPixel) / (float)MemWordsInBytes) - floor((float)(LeftPixel*BytesPerPixel) / (float)MemWordsInBytes) + 1));
	/* SourceUVWidthInMemWords means Source_U_or_V_or_UV_WidthInMemWords depending on whether the UV is packed together of not */
	SourceUVWidthInMemWords = (unsigned long)((long)(ceil((float)(RightUVPixel*BytesPerUVPixel) / (float)MemWordsInBytes) - floor((float)(LeftUVPixel*BytesPerUVPixel) / (float)MemWordsInBytes) + 1));
	switch(besr.surf_id)
	{
		case 9:
		case 10:
			if((long)((ceil((float)SourceWidthInMemWords/2.0)-1) * 2) > (long)(OV0LB_Rows-1))
			{
//				DPRINT("VIDIX: ceil(SourceWidthInMemWords/2)-1) * 2 > OV0LB_Rows-1\r\n");
			}
			else if((SourceWidthInMemWords-1) * 2 > OV0LB_Rows-1)
				DisallowFourTapVertFiltering = 1;
			if((long)((ceil(SourceUVWidthInMemWords/2.0)-1) * 4 + 1) > (long)(OV0LB_Rows-1))
			{
//				DPRINT("VIDIX: Image U plane width spans more octwords than supported by hardware\r\n")
			}
			else if((SourceUVWidthInMemWords-1) * 4 + 1 > OV0LB_Rows-1)
				DisallowFourTapUVVertFiltering = 1;
			if((long)((ceil(SourceUVWidthInMemWords/2.0)-1) * 4 + 3) > (long)(OV0LB_Rows-1))
			{
//				DPRINT("VIDIX: Image V plane width spans more octwords than supported by hardware\r\n")
			}
			else if((SourceUVWidthInMemWords-1) * 4 + 3 > OV0LB_Rows-1)
				DisallowFourTapUVVertFiltering = 1;
			break;
		case 13:
		case 14:
			if((long)((ceil(SourceWidthInMemWords/2.0)-1) * 2) > (long)(OV0LB_Rows-1))
			{
//				DPRINT("VIDIX: ceil(SourceWidthInMemWords/2)-1) * 2 > OV0LB_Rows-1\r\n");
			}
			else if((SourceWidthInMemWords-1) * 2 > OV0LB_Rows-1)
				DisallowFourTapVertFiltering = 1;
			if((long)((ceil(SourceUVWidthInMemWords/2.0)-1) * 2) + 1 > (long)(OV0LB_Rows-1))
			{
//				DPRINT("VIDIX: Image UV plane width spans more octwords than supported by hardware.") */
			}
			else if((SourceUVWidthInMemWords-1) * 2 + 1 > OV0LB_Rows-1)
				DisallowFourTapUVVertFiltering = 1;
			break;
		case 3:
		case 4:
		case 6:
		case 11:
		case 12:
			if((ceil(SourceWidthInMemWords/2)-1) > OV0LB_Rows-1)
			{
//				DPRINT("VIDIX: ceil(SourceWidthInMemWords/2)-1) > OV0LB_Rows-1\r\n")
			}
			else if((SourceWidthInMemWords-1) > OV0LB_Rows-1)
				DisallowFourTapVertFiltering = 1;
			break;
		default:    /* insert debug statement here. */
			break;
	}
	dest_w = config->dest.w;
	dest_h = config->dest.h;
	if(radeon_is_dbl_scan())
		dest_h *= 2;
	besr.dest_bpp = radeon_vid_get_dbpp();
	besr.fourcc = config->fourcc;
	if(radeon_is_interlace())
		interlace_factor = 2;
	else
		interlace_factor = 1;
	/* TODO: must be checked in doublescan mode!!! */
	if(besr.mobility)
		/* Force the overlay clock on for integrated chips */
		OUTPLL(VCLK_ECP_CNTL, (INPLL(VCLK_ECP_CNTL) | (1<<18)));
	horz_repl_factor = 1 << (unsigned long)((INPLL(VCLK_ECP_CNTL) & 0x300) >> 8);
	H_scale_ratio = (float)ceil(((float)dest_w+1)/horz_repl_factor)/src_w;
	V_scale_ratio = (float)(dest_h+1)/src_h;
	if(H_scale_ratio < 0.5 && V_scale_ratio < 0.5)
	{
		val_OV0_P1_MAX_LN_IN_PER_LN_OUT = 3;
		val_OV0_P23_MAX_LN_IN_PER_LN_OUT = 2;
	}
	else if(H_scale_ratio < 1 && V_scale_ratio < 1)
	{
		val_OV0_P1_MAX_LN_IN_PER_LN_OUT = 2;
		val_OV0_P23_MAX_LN_IN_PER_LN_OUT = 1;
	}
	else
	{
		val_OV0_P1_MAX_LN_IN_PER_LN_OUT = 1;
		val_OV0_P23_MAX_LN_IN_PER_LN_OUT = 1;
	}
	/* N.B.: Indeed it has 6.12 format but shifted on 8 to the left!!! */
	besr.v_inc = (unsigned short)((long)((1./V_scale_ratio)*(1<<12)*interlace_factor+0.5));
	CRT_V_INC = besr.v_inc/interlace_factor;
	besr.v_inc <<= 8;
	{
		int ThereIsTwoTapVerticalFiltering,DoNotUseMostRecentlyFetchedLine;
		int P1GroupSize, P23GroupSize, P1StepSize = 0, P23StepSize = 0;
		Calc_H_INC_STEP_BY(besr.surf_id,H_scale_ratio,DisallowFourTapVertFiltering,DisallowFourTapUVVertFiltering,
		 &val_OV0_P1_H_INC,&val_OV0_P1_H_STEP_BY,&val_OV0_P23_H_INC,&val_OV0_P23_H_STEP_BY,&P1GroupSize,&P1StepSize,&P23StepSize);
#ifdef VIDIX_FILTER
		if(H_scale_ratio > MinHScaleHard)
#endif
		{
			h_inc = (src_w << 12) / dest_w;
			besr.step_by = 0x0101;
			switch(besr.surf_id)
			{
				case 3:
				case 4:
				case 6:
					besr.h_inc = (h_inc)|(h_inc<<16);
					break;
				case 9:
					besr.h_inc = h_inc | ((h_inc >> 2) << 16);
					break;
				default:
					besr.h_inc = h_inc | ((h_inc >> 1) << 16);
					break;
			}
		}
		P23GroupSize = 2;	/* Current vaue for all modes */
		besr.horz_pick_nearest=0;
		DoNotUseMostRecentlyFetchedLine=0;
		ThereIsTwoTapVerticalFiltering = (val_OV0_P1_H_STEP_BY!=0) || (val_OV0_P23_H_STEP_BY!=0);
		if(ThereIsTwoTapVerticalFiltering && DoNotUseMostRecentlyFetchedLine)
			besr.vert_pick_nearest = 1;
		else
			besr.vert_pick_nearest = 0;
		ComputeXStartEnd(is_400,LeftPixel,LeftUVPixel,MemWordsInBytes,BytesPerPixel,SourceWidthInPixels,P1StepSize,
		 BytesPerUVPixel,SourceUVWidthInPixels,P23StepSize,&val_OV0_P1_X_START,&val_OV0_P2_X_START);
#ifdef VIDIX_FILTER
		if(H_scale_ratio > MinHScaleHard)
#endif
		{
			unsigned tmp;
			tmp = (left & 0x0003ffff) + 0x00028000 + (h_inc << 3);
			besr.p1_h_accum_init = ((tmp <<  4) & 0x000f8000) | ((tmp << 12) & 0xf0000000);
			tmp = (top & 0x0000ffff) + 0x00018000;
			besr.p1_v_accum_init = ((tmp << 4) & OV0_P1_V_ACCUM_INIT_MASK) | (OV0_P1_MAX_LN_IN_PER_LN_OUT & 1);
			tmp = ((left >> 1) & 0x0001ffff) + 0x00028000 + (h_inc << 2);
			besr.p23_h_accum_init = ((tmp << 4) & 0x000f8000) | ((tmp << 12) & 0x70000000);
			tmp = ((top >> 1) & 0x0000ffff) + 0x00018000;
			besr.p23_v_accum_init = (is_420||is_410) ? ((tmp << 4) & OV0_P23_V_ACCUM_INIT_MASK) | (OV0_P23_MAX_LN_IN_PER_LN_OUT & 1) : 0;
		}
#ifdef VIDIX_FILTER
		else
			ComputeAccumInit(val_OV0_P1_X_START,val_OV0_P2_X_START,val_OV0_P1_H_INC,val_OV0_P23_H_INC,val_OV0_P1_H_STEP_BY,val_OV0_P23_H_STEP_BY,
			 CRT_V_INC,P1GroupSize,P23GroupSize,val_OV0_P1_MAX_LN_IN_PER_LN_OUT,val_OV0_P23_MAX_LN_IN_PER_LN_OUT);
#endif
	}
	/* keep everything in 16.16 */
	besr.base_addr = INREG(DISPLAY_BASE_ADDR);
	config->offsets[0] = 0;
	for(i=1;i<besr.vid_nbufs;i++)
		config->offsets[i] = config->offsets[i-1]+config->frame_size;
	if(is_420 || is_410 || is_400)
	{
		unsigned long d1line,d2line,d3line;
		d1line = top*pitch;
		if(is_420)
		{
			d2line = src_h*pitch+(d1line>>2);
			d3line = d2line+((src_h*pitch)>>2);
		}
		else if(is_410)
		{
			d2line = src_h*pitch+(d1line>>4);
			d3line = d2line+((src_h*pitch)>>4);
		}
		else
			d2line = d3line = 0;
		d1line += (left >> 16) & ~15;
		if(is_420)
		{
			d2line += (left >> 17) & ~15;
			d3line += (left >> 17) & ~15;
		}
		else /* is_410 */
		{
			d2line += (left >> 18) & ~15;
			d3line += (left >> 18) & ~15;
		}
		config->offset.y = d1line & VIF_BUF0_BASE_ADRS_MASK;
		if(is_400)
			config->offset.v = config->offset.u = 0;
		else
		{
			config->offset.v = d2line & VIF_BUF1_BASE_ADRS_MASK;
			config->offset.u = d3line & VIF_BUF2_BASE_ADRS_MASK;
		}
		for(i=0;i<besr.vid_nbufs;i++)
		{
			besr.vid_buf_base_adrs_y[i]=((radeon_overlay_off+config->offsets[i]+config->offset.y)&VIF_BUF0_BASE_ADRS_MASK);
			if(is_400)
				besr.vid_buf_base_adrs_v[i] = besr.vid_buf_base_adrs_u[i] = 0;
			else
			{
				besr.vid_buf_base_adrs_v[i]=((radeon_overlay_off+config->offsets[i]+config->offset.v)&VIF_BUF1_BASE_ADRS_MASK)|VIF_BUF1_PITCH_SEL;
				besr.vid_buf_base_adrs_u[i]=((radeon_overlay_off+config->offsets[i]+config->offset.u)&VIF_BUF2_BASE_ADRS_MASK)|VIF_BUF2_PITCH_SEL;
			}
		}
		config->offset.y = ((besr.vid_buf_base_adrs_y[0])&VIF_BUF0_BASE_ADRS_MASK) - radeon_overlay_off;
		if(is_400)
			config->offset.v = config->offset.u = 0;
		else
		{
			config->offset.v = ((besr.vid_buf_base_adrs_v[0])&VIF_BUF1_BASE_ADRS_MASK) - radeon_overlay_off;
			config->offset.u = ((besr.vid_buf_base_adrs_u[0])&VIF_BUF2_BASE_ADRS_MASK) - radeon_overlay_off;
		}
		if(besr.fourcc == IMGFMT_I420 || besr.fourcc == IMGFMT_IYUV)
		{
			unsigned long tmp;
			tmp = config->offset.u;
			config->offset.u = config->offset.v;
			config->offset.v = tmp;
		}
	}
	else
	{
		config->offset.y = config->offset.u = config->offset.v = ((left & ~7) << 1)&VIF_BUF0_BASE_ADRS_MASK;
		for(i=0;i<besr.vid_nbufs;i++)
			besr.vid_buf_base_adrs_y[i] = besr.vid_buf_base_adrs_u[i] = besr.vid_buf_base_adrs_v[i] = radeon_overlay_off + config->offsets[i] + config->offset.y;
	}
	leftUV = (left >> (is_410?18:17)) & 15;
	left = (left >> 16) & 15;
	besr.y_x_start = (config->dest.x+X_ADJUST) | (config->dest.y << 16);
	besr.y_x_end = (config->dest.x + dest_w+X_ADJUST) | ((config->dest.y + dest_h) << 16);
	ComputeBorders(config,VertUVSubSample);
	besr.vid_buf_pitch0_value = pitch;
	besr.vid_buf_pitch1_value = is_410 ? pitch>>2 : is_420 ? pitch>>1 : pitch;
	/* Calculate programmable coefficients as needed */
	/* ToDo_Active: When in pick nearest mode, we need to program the filter tap zero */
	/* coefficients to 0, 32, 0, 0. Or use hard coded coefficients */
#ifdef VIDIX_FILTER
	if(H_scale_ratio > MinHScaleHard)
		besr.filter_cntl |= FILTER_HARDCODED_COEF;
	else
	{
		FilterSetup(val_OV0_P1_H_INC);
		/* ToDo_Active: Must add the smarts into the driver to decide what type of filtering it */
		/* would like to do. For now, we let the test application decide. */
		besr.filter_cntl = FILTER_PROGRAMMABLE_COEF;
		if(DisallowFourTapVertFiltering)
			besr.filter_cntl |= FILTER_HARD_SCALE_VERT_Y;
		if(DisallowFourTapUVVertFiltering)
			besr.filter_cntl |= FILTER_HARD_SCALE_VERT_UV;
	}
#else
	besr.filter_cntl |= FILTER_HARDCODED_COEF;
#endif
	return 0;
}

static void radeon_compute_framesize(vidix_playback_t *info)
{
	unsigned pitch,awidth,dbpp;
	pitch = radeon_query_pitch(info->fourcc,&info->src.pitch);
	dbpp = radeon_vid_get_dbpp();
	switch(info->fourcc)
	{
		case IMGFMT_Y800:
			awidth = (info->src.w + (pitch-1)) & ~(pitch-1);
			info->frame_size = awidth*info->src.h;
			break;
		case IMGFMT_YVU9:
		case IMGFMT_IF09:
			awidth = (info->src.w + (pitch-1)) & ~(pitch-1);
			info->frame_size = awidth*(info->src.h+info->src.h/8);
			break;
		case IMGFMT_I420:
		case IMGFMT_YV12:
		case IMGFMT_IYUV:
			awidth = (info->src.w + (pitch-1)) & ~(pitch-1);
			info->frame_size = awidth*(info->src.h+info->src.h/2);
			break;
		case IMGFMT_RGB32:
		case IMGFMT_BGR32:
			awidth = (info->src.w*4 + (pitch-1)) & ~(pitch-1);
			info->frame_size = awidth*info->src.h;
			break;
		/* YUY2 YVYU, RGB15, RGB16 */
		default:	
			awidth = (info->src.w*2 + (pitch-1)) & ~(pitch-1);
			info->frame_size = awidth*info->src.h;
			break;
	}
	info->frame_size = (info->frame_size+4095) & ~4095;
}

int vixConfigPlayback(vidix_playback_t *info)
{
	unsigned rgb_size, nfr;
	unsigned long radeon_video_size;
//	DPRINT("VIDIX: vixConfigPlayback\r\n");
  if(!is_supported_fourcc(info->fourcc,info->src.w))
  	return ENOSYS;
	if(info->num_frames>VID_PLAY_MAXFRAMES)
		info->num_frames=VID_PLAY_MAXFRAMES;
	if(info->num_frames==1)
		besr.double_buff=0;
	else
		besr.double_buff=1;
	radeon_compute_framesize(info);
	rgb_size = radeon_get_xres()*radeon_get_yres()*((radeon_vid_get_dbpp()+7)/8);
	nfr = info->num_frames;
	radeon_video_size = radeon_ram_size;
#ifdef VIDIX_ENABLE_BM
	if(dma_phys_addrs != NULL)
	{
		/* every descriptor describes one 4K page and takes 16 bytes in memory
		   Note: probably it's not good idea to locate them in video memory
		   but as initial release it's OK */
		radeon_video_size -= radeon_ram_size * sizeof(bm_list_descriptor) / 4096;
//		radeon_dma_desc_base = (void *)(radeon_mem_base_phys + radeon_video_size);
  }
#endif
	for(;nfr>0; nfr--)
	{
		radeon_overlay_off = radeon_ram_size - info->frame_size*nfr;
		radeon_overlay_off &= 0xffff0000;
		if(radeon_overlay_off >= (int)rgb_size)
			break;
  }
	if(nfr <= 3)
	{
		nfr = info->num_frames;
		for(;nfr>0; nfr--)
		{
			radeon_overlay_off = radeon_ram_size - info->frame_size*nfr;
			radeon_overlay_off &= 0xffff0000;
			if(radeon_overlay_off > 0)
				break;
		}
	}
	if(nfr <= 0)
		return(EINVAL);
	info->num_frames = nfr;
	besr.vid_nbufs = info->num_frames;
	info->dga_addr = (char *)radeon_mem_base + radeon_overlay_off;
	radeon_vid_init_video(info);
#if 0
	DPRINTVAL(" src.w: ", info->src.w);	
	DPRINTVAL(" src.h: ", info->src.h);	
	DPRINTVAL(" dest.x: ", info->dest.x);	
	DPRINTVAL(" dest.y: ", info->dest.y);	
	DPRINTVAL(" dest.w: ", info->dest.w);	
	DPRINTVAL(" dest.h: ", info->dest.h);	
	DPRINTVAL(" dest.pitch.y: ", info->dest.pitch.y);
	DPRINT("\r\n");
	DPRINTVAL(" frame_size: ", info->frame_size);	
	DPRINTVAL(" num_frames: ", info->num_frames);	
	DPRINTVALHEX(" dga_addr: ", (long)info->dga_addr);	
	DPRINT("\r\n");
	DPRINTVALHEX(" offset.y: ", info->offset.y);	
	DPRINTVALHEX(" offset.u: ", info->offset.u);	
	DPRINTVALHEX(" offset.v: ", info->offset.v);
	DPRINT("\r\n");
	DPRINTVALHEX(" adrs_y: ", besr.vid_buf_base_adrs_y[0]);
	DPRINTVALHEX(" adrs_u: ", besr.vid_buf_base_adrs_u[0]);
	DPRINTVALHEX(" adrs_v: ", besr.vid_buf_base_adrs_v[0]);
	DPRINT("\r\n");
//	Cconin();
#endif
	return(0);
}

int vixPlaybackOn(void)
{
//	DPRINT("VIDIX: vixPlaybackOn\r\n");
	radeon_vid_display_video();
	return(0);
}

int vixPlaybackOff(void)
{
//	DPRINT("VIDIX: vixPlaybackOff\r\n");
	radeon_vid_stop_video();
	return(0);
}

int vixPlaybackFrameSelect(unsigned frame)
{
	unsigned long off[6];
	int prev_frame= (frame-1+besr.vid_nbufs) % besr.vid_nbufs;
	/* buf3-5 always should point onto second buffer for better deinterlacing and TV-in */
//	DPRINT("VIDIX: vixPlaybackFrameSelect\r\n");
	if(!besr.double_buff)
		return(0);
	if(frame > besr.vid_nbufs)
		frame = besr.vid_nbufs-1;
	if(prev_frame > (int)besr.vid_nbufs)
		prev_frame = besr.vid_nbufs-1;
	off[0] = besr.vid_buf_base_adrs_y[frame];
	off[1] = besr.vid_buf_base_adrs_v[frame];
	off[2] = besr.vid_buf_base_adrs_u[frame];
	off[3] = besr.vid_buf_base_adrs_y[prev_frame];
	off[4] = besr.vid_buf_base_adrs_v[prev_frame];
	off[5] = besr.vid_buf_base_adrs_u[prev_frame];
	radeon_fifo_wait(1);
	OUTREG(OV0_REG_LOAD_CNTL, REG_LD_CTL_LOCK);
	radeon_engine_idle();
	while(!(INREG(OV0_REG_LOAD_CNTL) & REG_LD_CTL_LOCK_READBACK));
	radeon_fifo_wait(7);
	OUTREG(OV0_VID_BUF0_BASE_ADRS, off[0]);
	OUTREG(OV0_VID_BUF1_BASE_ADRS, off[1]);
	OUTREG(OV0_VID_BUF2_BASE_ADRS, off[2]);
	OUTREG(OV0_VID_BUF3_BASE_ADRS, off[3]);
	OUTREG(OV0_VID_BUF4_BASE_ADRS, off[4]);
	OUTREG(OV0_VID_BUF5_BASE_ADRS, off[5]);
	OUTREG(OV0_REG_LOAD_CNTL,	0);
	if(besr.vid_nbufs == 2)
		radeon_wait_vsync();
	return(0);
}

vidix_video_eq_t equal =
{
 VEQ_CAP_BRIGHTNESS | VEQ_CAP_SATURATION
  | VEQ_CAP_CONTRAST | VEQ_CAP_HUE | VEQ_CAP_RGB_INTENSITY,
 0, 0, 0, 0, 0, 0, 0, 0 };

int vixPlaybackGetEq(vidix_video_eq_t * eq)
{
//	DPRINT("VIDIX: vixPlaybackGetEq\r\n");
	memcpy(eq,&equal,sizeof(vidix_video_eq_t));
	return(0);
}

#define RTFSaturation(a)   (1.0 + ((a)*1.0)/1000.0)
#define RTFBrightness(a)   (((a)*1.0)/2000.0)
#define RTFIntensity(a)    (((a)*1.0)/2000.0)
#define RTFContrast(a)   (1.0 + ((a)*1.0)/1000.0)
#define RTFHue(a)   (((a)*3.1416)/1000.0)
#define RTFCheckParam(a) {if((a)<-1000) (a)=-1000; if((a)>1000) (a)=1000;}

int vixPlaybackSetEq(const vidix_video_eq_t * eq)
{
	int itu_space;
//	DPRINT("VIDIX: vixPlaybackSetEq\r\n");
	if(eq->cap & VEQ_CAP_BRIGHTNESS)
		equal.brightness = eq->brightness;
	if(eq->cap & VEQ_CAP_CONTRAST)
		equal.contrast   = eq->contrast;
	if(eq->cap & VEQ_CAP_SATURATION)
		equal.saturation = eq->saturation;
	if(eq->cap & VEQ_CAP_HUE)
		equal.hue        = eq->hue;
	if(eq->cap & VEQ_CAP_RGB_INTENSITY)
	{
		equal.red_intensity   = eq->red_intensity;
		equal.green_intensity = eq->green_intensity;
		equal.blue_intensity  = eq->blue_intensity;
	}
	equal.flags = eq->flags;
	itu_space = equal.flags == VEQ_FLG_ITU_R_BT_709 ? 1 : 0;
	RTFCheckParam(equal.brightness);
	RTFCheckParam(equal.saturation);
	RTFCheckParam(equal.contrast);
	RTFCheckParam(equal.hue);
	RTFCheckParam(equal.red_intensity);
	RTFCheckParam(equal.green_intensity);
	RTFCheckParam(equal.blue_intensity);
	radeon_set_transform(RTFBrightness(equal.brightness), RTFContrast(equal.contrast),
	 RTFSaturation(equal.saturation), RTFHue(equal.hue), RTFIntensity(equal.red_intensity),
	 RTFIntensity(equal.green_intensity), RTFIntensity(equal.blue_intensity), itu_space);
  return(0);
}

int vixPlaybackSetDeint(const vidix_deinterlace_t * info)
{
	unsigned sflg;
//	DPRINT("VIDIX: vixPlaybackSetDeint\r\n");
	switch(info->flags)
	{
		default:
		case CFG_NON_INTERLACED:
			besr.deinterlace_on = 0;
			break;
		case CFG_EVEN_ODD_INTERLACING:
		case CFG_INTERLACED:
			besr.deinterlace_on = 1;
			besr.deinterlace_pattern = 0x900AAAAA;
			break;
		case CFG_ODD_EVEN_INTERLACING:
			besr.deinterlace_on = 1;
			besr.deinterlace_pattern = 0x00055555;
			break;
		case CFG_UNIQUE_INTERLACING:
			besr.deinterlace_on = 1;
			besr.deinterlace_pattern = info->deinterlace_pattern;
			break;
	}
	OUTREG(OV0_REG_LOAD_CNTL, REG_LD_CTL_LOCK);
	radeon_engine_idle();
	while(!(INREG(OV0_REG_LOAD_CNTL) & REG_LD_CTL_LOCK_READBACK));
	radeon_fifo_wait(besr.deinterlace_on ? 3 : 2);
	sflg = INREG(OV0_SCALE_CNTL);
	if(besr.deinterlace_on)
	{
		OUTREG(OV0_SCALE_CNTL,sflg | SCALER_ADAPTIVE_DEINT);
		OUTREG(OV0_DEINTERLACE_PATTERN, besr.deinterlace_pattern);
	}
	else
		OUTREG(OV0_SCALE_CNTL,sflg & (~SCALER_ADAPTIVE_DEINT));
	OUTREG(OV0_REG_LOAD_CNTL,	0);
	return(0);  
}

int vixPlaybackGetDeint(vidix_deinterlace_t * info)
{
//	DPRINT("VIDIX: vixPlaybackGetDeint\r\n");
	if(!besr.deinterlace_on)
		info->flags = CFG_NON_INTERLACED;
	else
	{
		info->flags = CFG_UNIQUE_INTERLACING;
		info->deinterlace_pattern = besr.deinterlace_pattern;
	}
	return(0);
}

/* Graphic keys */
static vidix_grkey_t radeon_grkey;

static int set_gr_key(void)
{
	int result = 0;
	besr.merge_cntl = 0xff000000 | /* overlay alpha */ 0x00ff0000;  /* graphic alpha */
	if(radeon_grkey.ckey.op == CKEY_TRUE)
	{
		int dbpp=radeon_vid_get_dbpp();
		besr.ckey_on=1;
		switch(dbpp)
		{
			case 15:
				if(besr.family != CHIP_FAMILY_RADEON)
					besr.graphics_key_clr = ((radeon_grkey.ckey.blue &0xF8)) | ((radeon_grkey.ckey.green&0xF8)<<8) | ((radeon_grkey.ckey.red  &0xF8)<<16);
				else
					besr.graphics_key_clr = ((radeon_grkey.ckey.blue &0xF8)>>3) | ((radeon_grkey.ckey.green&0xF8)<<2) | ((radeon_grkey.ckey.red  &0xF8)<<7);
				break;
			case 16:
				/* This test may be too general/specific */
				if(besr.family != CHIP_FAMILY_RADEON)
					besr.graphics_key_clr = ((radeon_grkey.ckey.blue &0xF8)) | ((radeon_grkey.ckey.green&0xFC)<<8) | ((radeon_grkey.ckey.red  &0xF8)<<16);
				else
					besr.graphics_key_clr = ((radeon_grkey.ckey.blue &0xF8)>>3) | ((radeon_grkey.ckey.green&0xFC)<<3) | ((radeon_grkey.ckey.red  &0xF8)<<8);
				break;
			case 24:
			case 32:
				besr.graphics_key_clr = ((radeon_grkey.ckey.blue &0xFF)) | ((radeon_grkey.ckey.green&0xFF)<<8) | ((radeon_grkey.ckey.red  &0xFF)<<16);
				break;
			default:
				besr.ckey_on=besr.graphics_key_msk=besr.graphics_key_clr=0;
				break;
		}
		besr.graphics_key_msk=besr.graphics_key_clr;
		besr.ckey_cntl = VIDEO_KEY_FN_TRUE|CMP_MIX_AND|GRAPHIC_KEY_FN_EQ;
	}
	else if(radeon_grkey.ckey.op == CKEY_ALPHA)
	{
		int dbpp=radeon_vid_get_dbpp();
		besr.ckey_on=1;
		switch(dbpp)
		{
			case 32:
				besr.ckey_on=1;
				besr.graphics_key_msk=0;
				besr.graphics_key_clr=0;
				besr.ckey_cntl = VIDEO_KEY_FN_TRUE|GRAPHIC_KEY_FN_TRUE|CMP_MIX_AND;
				besr.merge_cntl = 0xff000000 | /* overlay alpha */ 0x00ff0000 | /* graphic alpha */ 0x00000001; /* DISP_ALPHA_MODE_PER_PIXEL */
				break;
			default:
				besr.ckey_on=besr.graphics_key_msk=besr.graphics_key_clr=0;
				besr.ckey_cntl = VIDEO_KEY_FN_TRUE|GRAPHIC_KEY_FN_TRUE|CMP_MIX_AND;
				result = 1;
				break;
		}
	}
	else
	{
		besr.ckey_on=besr.graphics_key_msk=besr.graphics_key_clr=0;
		besr.ckey_cntl = VIDEO_KEY_FN_TRUE|GRAPHIC_KEY_FN_TRUE|CMP_MIX_AND;
	}
	radeon_fifo_wait(4);
	OUTREG(OV0_GRAPHICS_KEY_MSK, besr.graphics_key_msk);
	OUTREG(OV0_GRAPHICS_KEY_CLR, besr.graphics_key_clr);
	OUTREG(OV0_KEY_CNTL,besr.ckey_cntl);
	OUTREG(DISP_MERGE_CNTL, besr.merge_cntl);
	return(result);
}

int vixGetGrKeys(vidix_grkey_t *grkey)
{
//	DPRINT("VIDIX: vixGetGrKeys\r\n");
	memcpy(grkey, &radeon_grkey, sizeof(vidix_grkey_t));
	return(0);
}

int vixSetGrKeys(const vidix_grkey_t *grkey)
{
//	DPRINT("VIDIX: vixSetGrKeys\r\n");
	memcpy(&radeon_grkey, grkey, sizeof(vidix_grkey_t));
	return(set_gr_key());
}

int vixPlaybackCopyFrame(vidix_dma_t *dmai)
{
#ifndef VIDIX_ENABLE_BM
	char *src, *dest;
//	DPRINT("VIDIX: vixPlaybackCopyFrame\r\n");
	if(dmai->dest_offset + dmai->size > radeon_ram_size)
		return(E2BIG);
	src = (char *)dmai->src;
	dest = (char *)radeon_mem_base + radeon_overlay_off + dmai->dest_offset;	
//	DPRINTVALHEX(" src: ", (long)src);	
//	DPRINTVALHEX(" dest ", (long)dest);
//	DPRINTVAL(" size: ", dmai->size);
//	DPRINT("\r\n");
	if((long)dmai->src & 3)
		return(EINVAL);
	if((dmai->flags & BM_DMA_SYNC) == BM_DMA_SYNC)
		while(blit_copy_ok() > 0);
	if(!dmai->src_incr && !dmai->dest_incr)
	{
		if(!(dmai->size & 3))
			blit_copy((unsigned char *)src, 0, (unsigned char *)dest, 0, (int)dmai->size >> 2, 1, 32);
		else if(!(dmai->size & 1))
			blit_copy((unsigned char *)src, 0, (unsigned char *)dest, 0, (int)dmai->size >> 1, 1, 16);
		else
			blit_copy((unsigned char *)src, 0, (unsigned char *)dest, 0, (int)dmai->size, 1, 8);
	}
	else
	{
		int h = (int)dmai->size / (int)dmai->dest_incr;	
		if(!(dmai->src_incr & 3) && !(dmai->dest_incr & 3))
		{
			int src_line_add = ((int)dmai->src_incr - (int)dmai->dest_incr) >> 2;
			blit_copy((unsigned char *)src, src_line_add, (unsigned char *)dest, 0, (int)dmai->dest_incr >> 2, h, 32);
		}
		else if(!(dmai->src_incr & 1) && !(dmai->dest_incr & 1))
		{
			int src_line_add = ((int)dmai->src_incr - (int)dmai->dest_incr) >> 1;
			blit_copy((unsigned char *)src, src_line_add, (unsigned char *)dest, 0, (int)dmai->dest_incr >> 1, h, 16);
		}
		else
		{
			int src_line_add = (int)dmai->src_incr - (int)dmai->dest_incr;
			blit_copy((unsigned char *)src, src_line_add, (unsigned char *)dest, 0, (int)dmai->dest_incr, h, 8);
		}
	}
	return(0);
#else /* VIDIX_ENABLE_BM */
	bm_list_descriptor * list = (bm_list_descriptor *)radeon_dma_desc_base[dmai->idx];
	unsigned long dest_ptr;
	int i=0;
//	unsigned i, n, count;
//	DPRINT("VIDIX: vixPlaybackCopyFrame\r\n");
	if(dma_phys_addrs == NULL)
		return(ENOMEM);
	if(dmai->src_incr != dmai->dest_incr)
		return(ENOSYS);
	if(dmai->dest_offset + dmai->size > radeon_ram_size)
		return(E2BIG);
	if((dmai->flags & BM_DMA_SYNC) == BM_DMA_SYNC)
		while(vixQueryDMAStatus() != 0);
#ifdef COLDFIRE
#if (__GNUC__ > 3)
		asm volatile (" .chip 68060\n\t cpusha DC\n\t .chip 5485\n\t"); /* from CF68KLIB */
#else
		asm volatile (" .chip 68060\n\t cpusha DC\n\t .chip 5200\n\t"); /* from CF68KLIB */
#endif
#else /* 68060 */
		asm volatile (" cpusha DC\n\t");
#endif /* COLDFIRE */

//	n = dmai->size / 4096;
//	if(dmai->size % 4096)
//		n++;
//	if((retval = bm_virt_to_bus(dmai->src,dmai->size,dma_phys_addrs)) != 0)
//		return retval;

	dmai->internal[dmai->idx] = radeon_dma_desc_base[dmai->idx];
	dest_ptr = dmai->dest_offset;
	if(besr.big_endian)
	{
		list[0].framebuf_offset = swap_long(radeon_overlay_off + dest_ptr);
		list[0].sys_addr = swap_long((unsigned long)dmai->src + host_mem_base_phys);
		list[0].command = swap_long(dmai->size | DMA_GUI_COMMAND__EOL);
		list[0].reserved = 0;
	}
	else
	{
		list[0].framebuf_offset = radeon_overlay_off + dest_ptr;
		list[0].sys_addr = (unsigned long)dmai->src + host_mem_base_phys;
		list[0].command = dmai->size | DMA_GUI_COMMAND__EOL;
		list[0].reserved = 0;
	}
	DPRINTVAL("VIDIX: RADEON_DMA_TABLE[", i);
	DPRINTVALHEXLONG("] ", list[0].framebuf_offset);
	DPRINTVALHEXLONG(" ", list[0].sys_addr);
	DPRINTVALHEXLONG(" ", list[0].command);
	DPRINTVALHEXLONG(" ", list[0].reserved);
	DPRINT("\r\n");
	
#if 0
	count = dmai->size;
	for(i=0;i<n;i++)
	{
		list[i].framebuf_offset = radeon_overlay_off + dest_ptr;
		list[i].sys_addr = dma_phys_addrs[i]; 
		list[i].command = (count > 4096 ? 4096 : count | DMA_GUI_COMMAND__EOL);
		list[i].reserved = 0;
//		DPRINTVAL("VIDIX: RADEON_DMA_TABLE[", i);
//		DPRINTVALHEXLONG("] ", list[i].framebuf_offset);
//		DPRINTVALHEXLONG(" ", list[i].sys_addr);
//		DPRINTVALHEXLONG(" ", list[i].command);
//		DPRINTVALHEXLONG(" ", list[i].reserved);
//		DPRINT("\r\n");
		dest_ptr += 4096;
		count -= 4096;
	}
//	cpu_flush(list,4096);

#endif
	radeon_engine_idle();
	for(i=0;i<1000;i++)
		INREG(BUS_CNTL); /* FlushWriteCombining */
	OUTREG(BUS_CNTL,(INREG(BUS_CNTL) | BUS_STOP_REQ_DIS) & (~BUS_MASTER_DIS));
	OUTREG(MC_FB_LOCATION,((radeon_mem_base_phys>>16) & 0xffff) | ((radeon_mem_base_phys+INREG(CONFIG_APER_SIZE)-1) & 0xffff0000));
//	if((INREG(MC_AGP_LOCATION) & 0xffff) != (((radeon_mem_base_phys+INREG(CONFIG_APER_SIZE))>>16) & 0xffff))
//		return(EINVAL); 	/* Radeon memory controller is misconfigured */
	OUTREG(DMA_VID_ACT_DSCRPTR,(unsigned long)radeon_dma_desc_base[dmai->idx]-(unsigned long)radeon_mem_base+radeon_mem_base_phys); // +host_mem_base_phys);
//	OUTREG(GEN_INT_STATUS,INREG(GEN_INT_STATUS) | (1<<30)); /* start */
	OUTREG(GEN_INT_STATUS,INREG(GEN_INT_STATUS) | 0x00010000); /* start */
	return(0);
#endif /* VIDIX_ENABLE_BM */
}

int vixQueryDMAStatus(void)
{
#ifndef VIDIX_ENABLE_BM
  int status = blit_copy_ok();
//	DPRINT("VIDIX: vixQueryDMAStatus\r\n");
  if(status < 0)
		return(ENOSYS);
	return(status);
#else /* VIDIX_ENABLE_BM */
//	DPRINT("VIDIX: vixQueryDMAStatus\r\n");
	return(0);
//	return(((INREG(GEN_INT_STATUS) & (1<<30)) == 0) ? 1 : 0);
	return(((INREG(GEN_INT_STATUS) & 0x00010000) == 0) ? 1 : 0);
#endif /* VIDIX_ENABLE_BM */
}

