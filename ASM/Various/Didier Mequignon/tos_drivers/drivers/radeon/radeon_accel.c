/*
 * Copyright 2000 ATI Technologies Inc., Markham, Ontario, and
 *                VA Linux Systems Inc., Fremont, California.
 *
 * All Rights Reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation on the rights to use, copy, modify, merge,
 * publish, distribute, sublicense, and/or sell copies of the Software,
 * and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice (including the
 * next paragraph) shall be included in all copies or substantial
 * portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NON-INFRINGEMENT.  IN NO EVENT SHALL ATI, VA LINUX SYSTEMS AND/OR
 * THEIR SUPPLIERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

/*
 * Authors:
 *   Kevin E. Martin <martin@xfree86.org>
 *   Rickard E. Faith <faith@valinux.com>
 *   Alan Hourihane <alanh@fairlite.demon.co.uk>
 *
 * Credits:
 *
 *   Thanks to Ani Joshi <ajoshi@shell.unixbox.com> for providing source
 *   code to his Radeon driver.  Portions of this file are based on the
 *   initialization code for that driver.
 *
 * References:
 *
 * !!!! FIXME !!!!
 *   RAGE 128 VR/ RAGE 128 GL Register Reference Manual (Technical
 *   Reference Manual P/N RRG-G04100-C Rev. 0.04), ATI Technologies: April
 *   1999.
 *
 *   RAGE 128 Software Development Manual (Technical Reference Manual P/N
 *   SDK-G04000 Rev. 0.01), ATI Technologies: June 1999.
 *
 * Notes on unimplemented XAA optimizations:
 *
 *   SetClipping:   This has been removed as XAA expects 16bit registers
 *                  for full clipping.
 *   TwoPointLine:  The Radeon supports this. Not Bresenham.
 *   DashedLine with non-power-of-two pattern length: Apparently, there is
 *                  no way to set the length of the pattern -- it is always
 *                  assumed to be 8 or 32 (or 1024?).
 *   ScreenToScreenColorExpandFill: See p. 4-17 of the Technical Reference
 *                  Manual where it states that monochrome expansion of frame
 *                  buffer data is not supported.
 *   Color8x8PatternFill: Apparently, an 8x8 color brush cannot take an 8x8
 *                  pattern from frame buffer memory.
 *
 */

#include "fb.h"
#include "radeonfb.h"

static struct {
    int rop;
    int pattern;
} RADEON_ROP[] = {
    { ROP3_ZERO, ROP3_ZERO }, /* GXclear        */
    { ROP3_DSa,  ROP3_DPa  }, /* Gxand          */
    { ROP3_SDna, ROP3_PDna }, /* GXandReverse   */
    { ROP3_S,    ROP3_P    }, /* GXcopy         */
    { ROP3_DSna, ROP3_DPna }, /* GXandInverted  */
    { ROP3_D,    ROP3_D    }, /* GXnoop         */
    { ROP3_DSx,  ROP3_DPx  }, /* GXxor          */
    { ROP3_DSo,  ROP3_DPo  }, /* GXor           */
    { ROP3_DSon, ROP3_DPon }, /* GXnor          */
    { ROP3_DSxn, ROP3_PDxn }, /* GXequiv        */
    { ROP3_Dn,   ROP3_Dn   }, /* GXinvert       */
    { ROP3_SDno, ROP3_PDno }, /* GXorReverse    */
    { ROP3_Sn,   ROP3_Pn   }, /* GXcopyInverted */
    { ROP3_DSno, ROP3_DPno }, /* GXorInverted   */
    { ROP3_DSan, ROP3_DPan }, /* GXnand         */
    { ROP3_ONE,  ROP3_ONE  }  /* GXset          */
};

#define ACCEL_MMIO
#define ACCEL_PREAMBLE()       
#define BEGIN_ACCEL(n)          RADEONWaitForFifo(rinfo, (n))
#define OUT_ACCEL_REG(reg, val) OUTREG(reg, val)
#define FINISH_ACCEL()

/* MMIO:
 *
 * Wait for the graphics engine to be completely idle: the FIFO has
 * drained, the Pixel Cache is flushed, and the engine is idle.  This is
 * a standard "sync" function that will make the hardware "quiescent".
 */
void RADEONWaitForIdleMMIO(struct radeonfb_info *rinfo)
{
	int i = 0;
	/* Wait for the engine to go idle */
	RADEONWaitForFifoFunction(rinfo, 64);
	while(1)
	{
		for(i = 0; i < RADEON_TIMEOUT; i++)
		{
			if(!(INREG(RBBM_STATUS) & RBBM_ACTIVE))
			{
				RADEONEngineFlush(rinfo);
				return;
			}
		}
		RADEONEngineReset(rinfo);
		RADEONEngineRestore(rinfo);
	}
}

#if 0

/* This callback is required for multiheader cards using XAA */
void RADEONRestoreAccelStateMMIO(struct fb_info *info)
{
	struct radeonfb_info *rinfo = info->par;
//	unsigned long pitch64 = ((info->var.xres * (rinfo->bpp / 8) + 0x3f)) >> 6;
	OUTREG(DEFAULT_OFFSET, (((INREG(DISPLAY_BASE_ADDR) + rinfo->fb_local_base) >> 10) | (rinfo->pitch << 22)));
	/* FIXME: May need to restore other things, like BKGD_CLK FG_CLK... */
	RADEONWaitForIdleMMIO(rinfo);
}

#endif

/* Setup for XAA SolidFill */
void RADEONSetupForSolidFillMMIO(struct fb_info *info,
     int color, int rop, unsigned int planemask)
{
	struct radeonfb_info *rinfo = info->par;
	ACCEL_PREAMBLE();
	/* Save for later clipping */
	rinfo->dp_gui_master_cntl_clip = (rinfo->dp_gui_master_cntl
	 | GMC_BRUSH_SOLID_COLOR | GMC_SRC_DATATYPE_COLOR | RADEON_ROP[rop].pattern);
	BEGIN_ACCEL(4);
	OUT_ACCEL_REG(DP_GUI_MASTER_CNTL, rinfo->dp_gui_master_cntl_clip);
	OUT_ACCEL_REG(DP_BRUSH_FRGD_CLR, color);
	OUT_ACCEL_REG(DP_WRITE_MSK, planemask);
	OUT_ACCEL_REG(DP_CNTL, (DST_X_LEFT_TO_RIGHT | DST_Y_TOP_TO_BOTTOM));
	FINISH_ACCEL();
}

/* Subsequent XAA SolidFillRect */
void RADEONSubsequentSolidFillRectMMIO(struct fb_info *info,
     int x, int y, int w, int h)
{
	struct radeonfb_info *rinfo = info->par;
	ACCEL_PREAMBLE();
#ifdef RADEON_TILING
	BEGIN_ACCEL(3);
	OUT_ACCEL_REG(DST_PITCH_OFFSET, rinfo->dst_pitch_offset
	 | ((rinfo->tilingEnabled && (y <= info->var.yres_virtual)) ? DST_TILE_MACRO : 0));
#else
	BEGIN_ACCEL(2);
#endif
	OUT_ACCEL_REG(DST_Y_X, (y << 16) | x);
	OUT_ACCEL_REG(DST_WIDTH_HEIGHT, (w << 16) | h);
	FINISH_ACCEL();
}

/* Setup for XAA solid lines */
void RADEONSetupForSolidLineMMIO(struct fb_info *info,
     int color, int rop, unsigned int planemask)
{
	struct radeonfb_info *rinfo = info->par;
	ACCEL_PREAMBLE();
	/* Save for later clipping */
	rinfo->dp_gui_master_cntl_clip = (rinfo->dp_gui_master_cntl
	 | GMC_BRUSH_SOLID_COLOR | GMC_SRC_DATATYPE_COLOR | RADEON_ROP[rop].pattern);
	if (rinfo->family >= CHIP_FAMILY_RV200)
	{
		BEGIN_ACCEL(1);
		OUT_ACCEL_REG(DST_LINE_PATCOUNT, 0x55 << BRES_CNTL_SHIFT);
	}
	BEGIN_ACCEL(3);
	OUT_ACCEL_REG(DP_GUI_MASTER_CNTL, rinfo->dp_gui_master_cntl_clip);
	OUT_ACCEL_REG(DP_BRUSH_FRGD_CLR, color);
	OUT_ACCEL_REG(DP_WRITE_MSK, planemask);
	FINISH_ACCEL();
}

/* Subsequent XAA solid horizontal and vertical lines */
void RADEONSubsequentSolidHorVertLineMMIO(struct fb_info *info,
     int x, int y, int len, int dir)
{
	struct radeonfb_info *rinfo = info->par;
	int w = 1;
	int h = 1;
	ACCEL_PREAMBLE();
	if(dir == DEGREES_0)
		w = len;
	else
		h = len;
#ifdef RADEON_TILING
	BEGIN_ACCEL(4);
	OUT_ACCEL_REG(DP_CNTL, (DST_X_LEFT_TO_RIGHT | DST_Y_TOP_TO_BOTTOM));
	OUT_ACCEL_REG(DST_PITCH_OFFSET, rinfo->dst_pitch_offset
	 | ((rinfo->tilingEnabled && (y <= info->var.xres_virtual)) ? DST_TILE_MACRO : 0));
#else
	BEGIN_ACCEL(3);
	OUT_ACCEL_REG(DP_CNTL, (DST_X_LEFT_TO_RIGHT | DST_Y_TOP_TO_BOTTOM));
#endif
	OUT_ACCEL_REG(DST_Y_X, (y << 16) | x);
	OUT_ACCEL_REG(DST_WIDTH_HEIGHT, (w << 16) | h);
	FINISH_ACCEL();
}

/* Subsequent XAA solid TwoPointLine line */
void RADEONSubsequentSolidTwoPointLineMMIO(struct fb_info *info,
     int xa, int ya, int xb, int yb, int flags)
{
	struct radeonfb_info *rinfo = info->par;
	ACCEL_PREAMBLE();
	/* TODO: Check bounds -- RADEON only has 14 bits */
	if(!(flags & OMIT_LAST))
		RADEONSubsequentSolidHorVertLineMMIO(info, xb, yb, 1, DEGREES_0);
#ifdef RADEON_TILING
	BEGIN_ACCEL(3);
	OUT_ACCEL_REG(DST_PITCH_OFFSET, rinfo->dst_pitch_offset
	 | ((rinfo->tilingEnabled && (ya <= info->var.yres_virtual)) ? DST_TILE_MACRO : 0));
#else
	BEGIN_ACCEL(2);
#endif
	OUT_ACCEL_REG(DST_LINE_START, (ya << 16) | xa);
	OUT_ACCEL_REG(DST_LINE_END, (yb << 16) | xb);
	FINISH_ACCEL();
}

/* Setup for XAA dashed lines
 * NOTE: Since we can only accelerate lines with power-of-2 patterns of * length <= 32
 */
void RADEONSetupForDashedLineMMIO(struct fb_info *info,
     int fg, int bg, int rop, unsigned int planemask, int length, unsigned char *pattern)
{
	struct radeonfb_info *rinfo = info->par;
	unsigned long pat = *(unsigned long *)(pointer)pattern;
	ACCEL_PREAMBLE();
	/* Save for determining whether or not to draw last pixel */
	rinfo->dashLen = length;
	rinfo->dashPattern = pat;
	if(rinfo->big_endian)
	{
		switch (length)
		{
			case  2: pat |= (pat >> 2);  /* fall through */
			case  4: pat |= (pat >> 4);  /* fall through */
			case  8: pat |= (pat >> 8);  /* fall through */
			case 16: pat |= (pat >> 16);
		}
	}
	else
	{
		switch (length)
		{
			case  2: pat |= (pat << 2);  /* fall through */
			case  4: pat |= (pat << 4);  /* fall through */
			case  8: pat |= (pat << 8);  /* fall through */
			case 16: pat |= (pat << 16);
		}
	}	
	/* Save for later clipping */
	rinfo->dp_gui_master_cntl_clip = (rinfo->dp_gui_master_cntl
	 | (bg == -1 ? GMC_BRUSH_32X1_MONO_FG_LA : GMC_BRUSH_32X1_MONO_FG_BG)
	 | RADEON_ROP[rop].pattern | GMC_BYTE_LSB_TO_MSB);
	rinfo->dash_fg = fg;
	rinfo->dash_bg = bg;
	BEGIN_ACCEL((bg == -1) ? 4 : 5);
	OUT_ACCEL_REG(DP_GUI_MASTER_CNTL, rinfo->dp_gui_master_cntl_clip);
	OUT_ACCEL_REG(DP_WRITE_MSK, planemask);
	OUT_ACCEL_REG(DP_BRUSH_FRGD_CLR, fg);
	if(bg != -1)
		OUT_ACCEL_REG(DP_BRUSH_BKGD_CLR, bg);
	OUT_ACCEL_REG(BRUSH_DATA0, pat);
	FINISH_ACCEL();
}

/* Helper function to draw last point for dashed lines */
static void RADEONDashedLastPelMMIO(struct fb_info *info,
       int x, int y, int fg)
{
	struct radeonfb_info *rinfo = info->par;
	unsigned long dp_gui_master_cntl = rinfo->dp_gui_master_cntl_clip;
	ACCEL_PREAMBLE();
	dp_gui_master_cntl &= ~GMC_BRUSH_DATATYPE_MASK;
	dp_gui_master_cntl |=  GMC_BRUSH_SOLID_COLOR;
	dp_gui_master_cntl &= ~GMC_SRC_DATATYPE_MASK;
	dp_gui_master_cntl |=  GMC_SRC_DATATYPE_COLOR;
#ifdef RADEON_TILING
	BEGIN_ACCEL(8);
	OUT_ACCEL_REG(DP_GUI_MASTER_CNTL, dp_gui_master_cntl);
	OUT_ACCEL_REG(DP_CNTL, (DST_X_LEFT_TO_RIGHT | DST_Y_TOP_TO_BOTTOM));
	OUT_ACCEL_REG(DST_PITCH_OFFSET, rinfo->dst_pitch_offset
	 | ((rinfo->tilingEnabled && (y <= info->var.yres_virtual)) ? DST_TILE_MACRO : 0));
#else
	BEGIN_ACCEL(7);
	OUT_ACCEL_REG(DP_GUI_MASTER_CNTL, dp_gui_master_cntl);
	OUT_ACCEL_REG(DP_CNTL, (DST_X_LEFT_TO_RIGHT | DST_Y_TOP_TO_BOTTOM));
#endif
	OUT_ACCEL_REG(DP_BRUSH_FRGD_CLR, fg);
	OUT_ACCEL_REG(DST_Y_X, (y << 16) | x);
	OUT_ACCEL_REG(DST_WIDTH_HEIGHT, (1 << 16) | 1);
	/* Restore old values */
	OUT_ACCEL_REG(DP_GUI_MASTER_CNTL, rinfo->dp_gui_master_cntl_clip);
	OUT_ACCEL_REG(DP_BRUSH_FRGD_CLR, rinfo->dash_fg);
	FINISH_ACCEL();
}

/* Subsequent XAA dashed line */
void RADEONSubsequentDashedTwoPointLineMMIO(struct fb_info *info,
     int xa, int ya, int xb, int yb, int flags, int phase)
{
	struct radeonfb_info *rinfo = info->par;
	ACCEL_PREAMBLE();
	/* TODO: Check bounds -- RADEON only has 14 bits */
	if(!(flags & OMIT_LAST))
	{
		int deltax = xa - xb;
		int deltay = ya - yb;
		int shift;
		if(deltax < 0)
			deltax = -deltax;
		if(deltay < 0)
			deltay = -deltay;
		if(deltax > deltay)
			shift = deltax;
		else
			shift = deltay;
		shift += phase;
		shift %= rinfo->dashLen;
		if((rinfo->dashPattern >> shift) & 1)
			RADEONDashedLastPelMMIO(info, xb, yb, rinfo->dash_fg);
		else if(rinfo->dash_bg != -1)
			RADEONDashedLastPelMMIO(info, xb, yb, rinfo->dash_bg);
	}
#ifdef RADEON_TILING
	BEGIN_ACCEL(4);
	OUT_ACCEL_REG(DST_PITCH_OFFSET, rinfo->dst_pitch_offset
	 | ((rinfo->tilingEnabled && (ya <= info->var.yres_virtual)) ? DST_TILE_MACRO : 0));
#else
	BEGIN_ACCEL(3);
#endif
	OUT_ACCEL_REG(DST_LINE_START, (ya << 16) | xa);
	OUT_ACCEL_REG(DST_LINE_PATCOUNT, phase);
	OUT_ACCEL_REG(DST_LINE_END, (yb << 16) | xb);
	FINISH_ACCEL();
}

/* Set up for transparency
 *
 * Mmmm, Seems as though the transparency compare is opposite to r128.
 * It should only draw when source != trans_color, this is the opposite
 * of that.
 */
static void RADEONSetTransparencyMMIO(struct radeonfb_info *rinfo, int trans_color)
{
	if(trans_color != -1)
	{
		ACCEL_PREAMBLE();
		BEGIN_ACCEL(3);
		OUT_ACCEL_REG(CLR_CMP_CLR_SRC, trans_color);
		OUT_ACCEL_REG(CLR_CMP_MSK, 0xffffffff);
		OUT_ACCEL_REG(CLR_CMP_CNTL, (SRC_CMP_EQ_COLOR | CLR_CMP_SRC_SOURCE));
		FINISH_ACCEL();
	}
}

/* Setup for XAA screen-to-screen copy */
void RADEONSetupForScreenToScreenCopyMMIO(struct fb_info *info,
     int xdir, int ydir, int rop, unsigned int planemask, int trans_color)
{
	struct radeonfb_info *rinfo = info->par;
	ACCEL_PREAMBLE();
	rinfo->xdir = xdir;
	rinfo->ydir = ydir;
	/* Save for later clipping */
#ifdef RADEON_TILING
	rinfo->dp_gui_master_cntl_clip = (rinfo->dp_gui_master_cntl
	 | GMC_BRUSH_NONE | GMC_SRC_DATATYPE_COLOR | RADEON_ROP[rop].rop
	 | DP_SRC_SOURCE_MEMORY | GMC_SRC_PITCH_OFFSET_CNTL);
#else
	rinfo->dp_gui_master_cntl_clip = (rinfo->dp_gui_master_cntl
	 | GMC_BRUSH_NONE | GMC_SRC_DATATYPE_COLOR | RADEON_ROP[rop].rop | DP_SRC_SOURCE_MEMORY);
#endif
	BEGIN_ACCEL(3);
	OUT_ACCEL_REG(DP_GUI_MASTER_CNTL, rinfo->dp_gui_master_cntl_clip);
	OUT_ACCEL_REG(DP_WRITE_MSK, planemask);
	OUT_ACCEL_REG(DP_CNTL, ((xdir >= 0 ? DST_X_LEFT_TO_RIGHT : 0) | (ydir >= 0 ? DST_Y_TOP_TO_BOTTOM : 0)));
	FINISH_ACCEL();
	rinfo->trans_color = trans_color;
	if(trans_color != -1)
		RADEONSetTransparencyMMIO(rinfo, trans_color);
}

/* Subsequent XAA screen-to-screen copy */
void RADEONSubsequentScreenToScreenCopyMMIO(struct fb_info *info,
     int xa, int ya, int xb, int yb, int w, int h)
{
	struct radeonfb_info *rinfo = info->par;
	ACCEL_PREAMBLE();
	if(rinfo->xdir < 0)
		xa += w - 1, xb += w - 1;
	if(rinfo->ydir < 0)
		ya += h - 1, yb += h - 1;
#ifdef RADEON_TILING
	BEGIN_ACCEL(5);
	OUT_ACCEL_REG(SRC_PITCH_OFFSET, rinfo->dst_pitch_offset
	 | ((rinfo->tilingEnabled && (ya <= info->var.yres_virtual)) ? DST_TILE_MACRO : 0));
	OUT_ACCEL_REG(DST_PITCH_OFFSET, rinfo->dst_pitch_offset
	 | ((rinfo->tilingEnabled && (yb <= info->var.yres_virtual)) ? DST_TILE_MACRO : 0));
#else
	BEGIN_ACCEL(3);
#endif
	OUT_ACCEL_REG(SRC_Y_X, (ya << 16) | xa);
	OUT_ACCEL_REG(DST_Y_X, (yb << 16) | xb);
	OUT_ACCEL_REG(DST_HEIGHT_WIDTH, (h  << 16) | w);
	FINISH_ACCEL();
}

/* XAA screen-to-screen copy */
void RADEONScreenToScreenCopyMMIO(struct fb_info *info,
     int xa, int ya, int xb, int yb, int w, int h, int rop)
{
	struct radeonfb_info *rinfo = info->par;
	int xdir = xa - xb;
	int ydir = ya - yb;
	ACCEL_PREAMBLE();
	if(xdir < 0)
		xa += w - 1, xb += w - 1;
	if(ydir < 0)
		ya += h - 1, yb += h - 1;
#ifdef RADEON_TILING
	/* Save for later clipping */
	rinfo->dp_gui_master_cntl_clip = (rinfo->dp_gui_master_cntl
	 | GMC_BRUSH_NONE | GMC_SRC_DATATYPE_COLOR | RADEON_ROP[rop].rop
	 | DP_SRC_SOURCE_MEMORY | GMC_SRC_PITCH_OFFSET_CNTL);
	BEGIN_ACCEL(8);
	OUT_ACCEL_REG(SRC_PITCH_OFFSET, rinfo->dst_pitch_offset
	 | ((rinfo->tilingEnabled && (ya <= info->var.yres_virtual)) ? DST_TILE_MACRO : 0));
	OUT_ACCEL_REG(DST_PITCH_OFFSET, rinfo->dst_pitch_offset
	 | ((rinfo->tilingEnabled && (yb <= info->var.yres_virtual)) ? DST_TILE_MACRO : 0));
#else
	/* Save for later clipping */
	rinfo->dp_gui_master_cntl_clip = (rinfo->dp_gui_master_cntl
	 | GMC_BRUSH_NONE | GMC_SRC_DATATYPE_COLOR | RADEON_ROP[rop].rop | DP_SRC_SOURCE_MEMORY);
	BEGIN_ACCEL(6);
#endif
	OUT_ACCEL_REG(DP_GUI_MASTER_CNTL, rinfo->dp_gui_master_cntl_clip);
	OUT_ACCEL_REG(DP_WRITE_MSK, -1);
	OUT_ACCEL_REG(DP_CNTL, ((xdir >= 0 ? DST_X_LEFT_TO_RIGHT : 0) | (ydir >= 0 ? DST_Y_TOP_TO_BOTTOM : 0)));
	OUT_ACCEL_REG(SRC_Y_X, (ya << 16) | xa);
	OUT_ACCEL_REG(DST_Y_X, (yb << 16) | xb);
	OUT_ACCEL_REG(DST_HEIGHT_WIDTH, (h  << 16) | w);
	FINISH_ACCEL();
}

/* Setup for XAA mono 8x8 pattern color expansion.  Patterns with
 * transparency use `bg == -1'.  This routine is only used if the XAA
 * pixmap cache is turned on.
 */
void RADEONSetupForMono8x8PatternFillMMIO(struct fb_info *info,
     int patternx, int patterny, int fg, int bg, int rop, unsigned int planemask)
{
	struct radeonfb_info *rinfo = info->par;
	unsigned char pattern[8];
	ACCEL_PREAMBLE();
	if(rinfo->big_endian)
	{
		/* Take care of endianness */
		pattern[0] = (patternx & 0x000000ff);
		pattern[1] = (patternx & 0x0000ff00) >> 8;
		pattern[2] = (patternx & 0x00ff0000) >> 16;
		pattern[3] = (patternx & 0xff000000) >> 24;
		pattern[4] = (patterny & 0x000000ff);
		pattern[5] = (patterny & 0x0000ff00) >> 8;
		pattern[6] = (patterny & 0x00ff0000) >> 16;
		pattern[7] = (patterny & 0xff000000) >> 24;
		/* Save for later clipping */
		rinfo->dp_gui_master_cntl_clip = (rinfo->dp_gui_master_cntl
		 | (bg == -1 ? GMC_BRUSH_8X8_MONO_FG_LA : GMC_BRUSH_8X8_MONO_FG_BG)
		 | RADEON_ROP[rop].pattern | GMC_BYTE_MSB_TO_LSB);
	}
	else
		/* Save for later clipping */
		rinfo->dp_gui_master_cntl_clip = (rinfo->dp_gui_master_cntl
		 | (bg == -1 ? GMC_BRUSH_8X8_MONO_FG_LA : GMC_BRUSH_8X8_MONO_FG_BG)
		 | RADEON_ROP[rop].pattern);
	BEGIN_ACCEL((bg == -1) ? 5 : 6);
	OUT_ACCEL_REG(DP_GUI_MASTER_CNTL, rinfo->dp_gui_master_cntl_clip);
	OUT_ACCEL_REG(DP_WRITE_MSK, planemask);
	OUT_ACCEL_REG(DP_BRUSH_FRGD_CLR, fg);
	if(bg != -1)
		OUT_ACCEL_REG(DP_BRUSH_BKGD_CLR, bg);
	if(rinfo->big_endian)
	{
		OUT_ACCEL_REG(BRUSH_DATA0, *(unsigned long *)(pointer)&pattern[0]);
		OUT_ACCEL_REG(BRUSH_DATA1, *(unsigned long *)(pointer)&pattern[4]);
	}
	else
	{
    OUT_ACCEL_REG(BRUSH_DATA0, patternx);
    OUT_ACCEL_REG(BRUSH_DATA1, patterny);
	}
	FINISH_ACCEL();
}

/* Subsequent XAA 8x8 pattern color expansion.  Because they are used in
 * the setup function, `patternx' and `patterny' are not used here.
 */
void RADEONSubsequentMono8x8PatternFillRectMMIO(struct fb_info *info,
     int patternx, int patterny, int x, int y, int w, int h)
{
	struct radeonfb_info *rinfo = info->par;
	ACCEL_PREAMBLE();
#ifdef RADEON_TILING
	BEGIN_ACCEL(4);
	OUT_ACCEL_REG(DST_PITCH_OFFSET, rinfo->dst_pitch_offset
	 | ((rinfo->tilingEnabled && (y <= info->var.yres_virtual)) ? DST_TILE_MACRO : 0));
#else
	BEGIN_ACCEL(3);
#endif
	OUT_ACCEL_REG(BRUSH_Y_X, (patterny << 8) | patternx);
	OUT_ACCEL_REG(DST_Y_X, (y << 16) | x);
	OUT_ACCEL_REG(DST_HEIGHT_WIDTH, (h << 16) | w);
	FINISH_ACCEL();
}

/* Setup for XAA indirect CPU-to-screen color expansion (indirect).
 * Because of how the scratch buffer is initialized, this is really a
 * mainstore-to-screen color expansion.  Transparency is supported when
 * `bg == -1'.
 */
void RADEONSetupForScanlineCPUToScreenColorExpandFillMMIO(struct fb_info *info, 
     int fg, int bg, int rop, unsigned int planemask)
{
	struct radeonfb_info *rinfo = info->par;
	ACCEL_PREAMBLE();
	/* Save for later clipping */
	if(rinfo->big_endian)
		rinfo->dp_gui_master_cntl_clip = (rinfo->dp_gui_master_cntl
		 | GMC_DST_CLIPPING | GMC_BRUSH_NONE
		 | (bg == -1 ? GMC_SRC_DATATYPE_MONO_FG_LA : GMC_SRC_DATATYPE_MONO_FG_BG)
		 | RADEON_ROP[rop].rop | GMC_BYTE_MSB_TO_LSB | DP_SRC_SOURCE_HOST_DATA);
	else
		rinfo->dp_gui_master_cntl_clip = (rinfo->dp_gui_master_cntl
		 | GMC_DST_CLIPPING | GMC_BRUSH_NONE
		 | (bg == -1 ? GMC_SRC_DATATYPE_MONO_FG_LA : GMC_SRC_DATATYPE_MONO_FG_BG)
		 | RADEON_ROP[rop].rop | GMC_BYTE_LSB_TO_MSB | DP_SRC_SOURCE_HOST_DATA);
	if(rinfo->big_endian)
	{
    BEGIN_ACCEL(5);
		OUT_ACCEL_REG(RBBM_GUICNTL, HOST_DATA_SWAP_NONE);
  }
	else	
		BEGIN_ACCEL(4);
	OUT_ACCEL_REG(DP_GUI_MASTER_CNTL, rinfo->dp_gui_master_cntl_clip);
	OUT_ACCEL_REG(DP_WRITE_MSK, planemask);
	OUT_ACCEL_REG(DP_SRC_FRGD_CLR, fg);
	OUT_ACCEL_REG(DP_SRC_BKGD_CLR, bg);
	FINISH_ACCEL();
}

/* Subsequent XAA indirect CPU-to-screen color expansion. This is only
 * called once for each rectangle.
 */
void RADEONSubsequentScanlineCPUToScreenColorExpandFillMMIO(struct fb_info *info,
     int x, int y, int w, int h, int skipleft)
{
	struct radeonfb_info *rinfo = info->par;
	ACCEL_PREAMBLE();
	rinfo->scanline_h  = h;
	rinfo->scanline_words = (w + 31) >> 5;
#ifdef RADEON_TILING
	BEGIN_ACCEL(5);
	OUT_ACCEL_REG(DST_PITCH_OFFSET, rinfo->dst_pitch_offset
	 | ((rinfo->tilingEnabled && (y <= info->var.yres_virtual)) ? DST_TILE_MACRO : 0));
#else
	BEGIN_ACCEL(4);
#endif
	OUT_ACCEL_REG(SC_TOP_LEFT, (y << 16) | ((x+skipleft) & 0xffff));
	OUT_ACCEL_REG(SC_BOTTOM_RIGHT, ((y+h) << 16) | ((x+w) & 0xffff));
	OUT_ACCEL_REG(DST_Y_X, (y << 16) | (x & 0xffff));
	/* Have to pad the width here and use clipping engine */
	OUT_ACCEL_REG(DST_HEIGHT_WIDTH, (h << 16) | ((w + 31) & ~31));
	FINISH_ACCEL();
}

/* Subsequent XAA indirect CPU-to-screen color expansion and indirect
 * image write.  This is called once for each scanline.
 */
void RADEONSubsequentScanlineMMIO(struct fb_info *info, unsigned long *src)
{
	struct radeonfb_info *rinfo = info->par;
	int left = rinfo->scanline_words;
	volatile unsigned long *d;
	ACCEL_PREAMBLE();
	--rinfo->scanline_h;
	while(left)
	{
		if(left <= 8)
		{
	  	/* Last scanline - finish write to DATA_LAST */
			if(rinfo->scanline_h == 0)
			{
				BEGIN_ACCEL(left);
				/* Unrolling doesn't improve performance */
				for(d = ADDRREG(HOST_DATA_LAST) - (left - 1); left; --left)
					*d++ = *src++;
				return;
			}
			else
			{
	    	BEGIN_ACCEL(left);
				/* Unrolling doesn't improve performance */
				for(d = ADDRREG(HOST_DATA7) - (left - 1); left; --left)
					*d++ = *src++;
			}
		}
		else
		{
			BEGIN_ACCEL(8);
			/* Unrolling doesn't improve performance */
			d = ADDRREG(HOST_DATA0);
			*d++ = *src++;
			*d++ = *src++;
			*d++ = *src++;
			*d++ = *src++;
			*d++ = *src++;
			*d++ = *src++;
			*d++ = *src++;
			*d++ = *src++;
			left -= 8;
		}
	}
	FINISH_ACCEL();
}

/* Setup for XAA indirect image write */
void RADEONSetupForScanlineImageWriteMMIO(struct fb_info *info,
     int rop, unsigned int planemask, int trans_color, int bpp)
{
	struct radeonfb_info *rinfo = info->par;
	ACCEL_PREAMBLE();
	rinfo->scanline_bpp = bpp;
	/* Save for later clipping */
	rinfo->dp_gui_master_cntl_clip = (rinfo->dp_gui_master_cntl
	 | GMC_DST_CLIPPING | GMC_BRUSH_NONE | GMC_SRC_DATATYPE_COLOR | RADEON_ROP[rop].rop
	 | GMC_BYTE_MSB_TO_LSB | DP_SRC_SOURCE_HOST_DATA);
	if(rinfo->big_endian)
	{
		BEGIN_ACCEL(3);
		if(bpp == 16)
			OUT_ACCEL_REG(RBBM_GUICNTL, HOST_DATA_SWAP_16BIT);
		else if(bpp == 32)
			OUT_ACCEL_REG(RBBM_GUICNTL, HOST_DATA_SWAP_32BIT);
		else
			OUT_ACCEL_REG(RBBM_GUICNTL, HOST_DATA_SWAP_NONE);
	}
	else
		BEGIN_ACCEL(2);
	OUT_ACCEL_REG(DP_GUI_MASTER_CNTL, rinfo->dp_gui_master_cntl_clip);
	OUT_ACCEL_REG(DP_WRITE_MSK, planemask);
	FINISH_ACCEL();
	rinfo->trans_color = trans_color;
	if(trans_color != -1)
		RADEONSetTransparencyMMIO(rinfo, trans_color);
}

/* Subsequent XAA indirect image write. This is only called once for each rectangle. */
void RADEONSubsequentScanlineImageWriteRectMMIO(struct fb_info *info,
     int x, int y, int w, int h, int skipleft)
{
	struct radeonfb_info *rinfo = info->par;
	int shift = 0; /* 32bpp */
	ACCEL_PREAMBLE();
	if(rinfo->bpp == 8)
		shift = 3;
	else if(rinfo->bpp == 16)
		shift = 1;
	rinfo->scanline_h = h;
	rinfo->scanline_words = (w * rinfo->scanline_bpp + 31) >> 5;
#ifdef RADEON_TILING
	BEGIN_ACCEL(5);
	OUT_ACCEL_REG(DST_PITCH_OFFSET, rinfo->dst_pitch_offset
	 | ((rinfo->tilingEnabled && (y <= info->var.yres_virtual)) ? DST_TILE_MACRO : 0));
#else
	BEGIN_ACCEL(4);
#endif
	OUT_ACCEL_REG(SC_TOP_LEFT, (y << 16) | ((x+skipleft) & 0xffff));
	OUT_ACCEL_REG(SC_BOTTOM_RIGHT, ((y+h) << 16) | ((x+w) & 0xffff));
	OUT_ACCEL_REG(DST_Y_X, (y << 16) | (x & 0xffff));
	/* Have to pad the width here and use clipping engine */
	OUT_ACCEL_REG(DST_HEIGHT_WIDTH, (h << 16) | ((w + shift) & ~shift));
	FINISH_ACCEL();
}

/* Set up the clipping rectangle */
void RADEONSetClippingRectangleMMIO(struct fb_info *info,
     int xa, int ya, int xb, int yb)
{
	struct radeonfb_info *rinfo = info->par;
	unsigned long  tmp1 = 0;
	unsigned long  tmp2 = 0;
	ACCEL_PREAMBLE();
	if(xa < 0)
	{
		tmp1 = (-xa) & 0x3fff;
		tmp1 |= SC_SIGN_MASK_LO;
	}
	else
		tmp1 = xa;
	if(ya < 0)
	{
		tmp1 |= (((-ya) & 0x3fff) << 16);
		tmp1 |= SC_SIGN_MASK_HI;
	}
	else
		tmp1 |= (ya << 16);
	xb++; yb++;
	if(xb < 0)
	{
		tmp2 = (-xb) & 0x3fff;
		tmp2 |= SC_SIGN_MASK_LO;
	}
	else
		tmp2 = xb;
	if(yb < 0)
	{
		tmp2 |= (((-yb) & 0x3fff) << 16);
		tmp2 |= SC_SIGN_MASK_HI;
	}
	else
		tmp2 |= (yb << 16);
	BEGIN_ACCEL(3);
	OUT_ACCEL_REG(DP_GUI_MASTER_CNTL, (rinfo->dp_gui_master_cntl_clip | GMC_DST_CLIPPING));
	OUT_ACCEL_REG(SC_TOP_LEFT, tmp1);
	OUT_ACCEL_REG(SC_BOTTOM_RIGHT, tmp2);
	FINISH_ACCEL();
	if(rinfo->trans_color != -1)
		RADEONSetTransparencyMMIO(rinfo, rinfo->trans_color);
}

/* Disable the clipping rectangle */
void RADEONDisableClippingMMIO(struct fb_info *info)
{
	struct radeonfb_info *rinfo = info->par;
	ACCEL_PREAMBLE();
	BEGIN_ACCEL(3);
	OUT_ACCEL_REG(DP_GUI_MASTER_CNTL, rinfo->dp_gui_master_cntl_clip);
	OUT_ACCEL_REG(SC_TOP_LEFT, 0);
	OUT_ACCEL_REG(SC_BOTTOM_RIGHT, (DEFAULT_SC_RIGHT_MAX | DEFAULT_SC_BOTTOM_MAX));
	FINISH_ACCEL();
	if(rinfo->trans_color != -1)
		RADEONSetTransparencyMMIO(rinfo, rinfo->trans_color);
}

#if 0

/* Change surfaces
   The idea here is to only set up front buffer as tiled, and back/depth buffer when needed.
   Everything else is left as untiled. This means we need to use eplicit src/dst pitch control
   when blitting, based on the src/target address, and can no longer use a default offset.
   But OTOH we don't need to dynamically change surfaces (for xv for instance), and some
   ugly offset / fb reservation (cursor) is gone. And as a bonus, everything actually works...
   All surface addresses are relative to MC_FB_LOCATION
 */
void RADEONChangeSurfaces(struct fb_info *info)
{
	struct radeonfb_info *rinfo = info->par;
	int cpp = rinfo->bpp >> 3;
	/* depth/front/back pitch must be identical (and the same as displayWidth) */
	int width_bytes = info->var.xres_virtual * cpp;
	int bufferSize = (((((info->var.yres_virtual + 15) & ~15) * width_bytes) + RADEON_BUFFER_ALIGN) & ~RADEON_BUFFER_ALIGN);
	unsigned int depth_pattern, color_pattern, swap_pattern, surf_info;
	if(rinfo->big_endian)
	{
		switch(rinfo->bpp)
		{
			case 16:
				swap_pattern = SURF_AP0_SWP_16BPP | SURF_AP1_SWP_16BPP;
				break;
	    case 32:
				swap_pattern = SURF_AP0_SWP_32BPP | SURF_AP1_SWP_32BPP;
				break;
			default:
				swap_pattern = 0;
		}
	}
	else
		swap_pattern = 0;
	if(rinfo->family < CHIP_FAMILY_R200)
	{
		color_pattern = SURF_TILE_COLOR_MACRO;
		if(cpp == 2)
			depth_pattern = SURF_TILE_DEPTH_16BPP;
		else
			depth_pattern = SURF_TILE_DEPTH_32BPP;
	}
	else if(rinfo->family >= CHIP_FAMILY_R300)
	{
		color_pattern = R300_SURF_TILE_COLOR_MACRO;
		if(cpp == 2)
			depth_pattern = R300_SURF_TILE_COLOR_MACRO;
		else
			depth_pattern = R300_SURF_TILE_COLOR_MACRO | R300_SURF_TILE_DEPTH_32BPP;
	}
	else
	{
		color_pattern = R200_SURF_TILE_COLOR_MACRO;
		if(cpp == 2)
			depth_pattern = R200_SURF_TILE_DEPTH_16BPP;
		else
			depth_pattern = R200_SURF_TILE_DEPTH_32BPP;
	}   
	/* we don't need anything like WaitForFifo, no? */
#ifdef RADEON_TILING
	if(rinfo->tilingEnabled)
	{
		if(rinfo->family >= CHIP_FAMILY_R300)
			surf_info = swap_pattern | (width_bytes / 8) | color_pattern;
		else
			surf_info = swap_pattern | (width_bytes / 16) | color_pattern;
	}
	else
#endif
		surf_info = 0;
	OUTREG(SURFACE0_INFO, surf_info);
	OUTREG(SURFACE0_LOWER_BOUND, 0);
	OUTREG(SURFACE0_UPPER_BOUND, bufferSize - 1);
}

#endif

/* The FIFO has 64 slots.  This routines waits until at least `entries'
 * of these slots are empty.
 */
void RADEONWaitForFifoFunction(struct radeonfb_info *rinfo, int entries)
{
	int i;
	while(1)
	{
		for(i = 0; i < RADEON_TIMEOUT; i++)
		{
			rinfo->fifo_slots = INREG(RBBM_STATUS) & RBBM_FIFOCNT_MASK;
			if(rinfo->fifo_slots >= entries)
				return;
		}
		RADEONEngineReset(rinfo);
		RADEONEngineRestore(rinfo);
	}
}

/* Flush all dirty data in the Pixel Cache to memory */
void RADEONEngineFlush(struct radeonfb_info *rinfo)
{
	int i;
	OUTREGP(RB2D_DSTCACHE_CTLSTAT, RB2D_DC_FLUSH_ALL, ~RB2D_DC_FLUSH_ALL);
	for(i = 0; i < RADEON_TIMEOUT; i++)
	{
		if(!(INREG(RB2D_DSTCACHE_CTLSTAT) & RB2D_DC_BUSY))
			break;
	}
}

/* Reset graphics card to known state */
void RADEONEngineReset(struct radeonfb_info *rinfo)
{
	unsigned long clock_cntl_index;
	unsigned long mclk_cntl;
	unsigned long rbbm_soft_reset;
	unsigned long host_path_cntl;
	RADEONEngineFlush(rinfo);
	clock_cntl_index = INREG(CLOCK_CNTL_INDEX);
	/* Some ASICs have bugs with dynamic-on feature, which are
	 * ASIC-version dependent, so we force all blocks on for now
	 */
	if(rinfo->has_CRTC2)
	{
		unsigned long tmp;
		tmp = INPLL(SCLK_CNTL);
		OUTPLL(SCLK_CNTL, ((tmp & ~DYN_STOP_LAT_MASK) | CP_MAX_DYN_STOP_LAT | SCLK_FORCEON_MASK));
		if(rinfo->family == CHIP_FAMILY_RV200)
		{
			tmp = INPLL(SCLK_MORE_CNTL);
			OUTPLL(SCLK_MORE_CNTL, tmp | SCLK_MORE_FORCEON);
		}
	}
	mclk_cntl = INPLL(MCLK_CNTL);
	OUTPLL(MCLK_CNTL, (mclk_cntl | FORCEON_MCLKA | FORCEON_MCLKB
	 | FORCEON_YCLKA | FORCEON_YCLKB | FORCEON_MC | FORCEON_AIC));
	/* Soft resetting HDP thru RBBM_SOFT_RESET register can cause some
	 * unexpected behaviour on some machines.  Here we use
	 * HOST_PATH_CNTL to reset it.
	 */
	host_path_cntl = INREG(HOST_PATH_CNTL);
	rbbm_soft_reset = INREG(RBBM_SOFT_RESET);
	if((rinfo->family == CHIP_FAMILY_R300)
	 || (rinfo->family == CHIP_FAMILY_R350)
	 || (rinfo->family == CHIP_FAMILY_RV350))
	{
		unsigned long tmp;
		OUTREG(RBBM_SOFT_RESET, (rbbm_soft_reset
		 | SOFT_RESET_CP | SOFT_RESET_HI | SOFT_RESET_E2));
		INREG(RBBM_SOFT_RESET);
		OUTREG(RBBM_SOFT_RESET, 0);
		tmp = INREG(RB2D_DSTCACHE_MODE);
		OUTREG(RB2D_DSTCACHE_MODE, tmp | (1 << 17)); /* FIXME */
	}
	else
	{
		OUTREG(RBBM_SOFT_RESET, (rbbm_soft_reset | SOFT_RESET_CP
		 | SOFT_RESET_HI | SOFT_RESET_SE | SOFT_RESET_RE
		 | SOFT_RESET_PP | SOFT_RESET_E2 | SOFT_RESET_RB));
		INREG(RBBM_SOFT_RESET);
		OUTREG(RBBM_SOFT_RESET, (rbbm_soft_reset
		 & (unsigned long) ~(SOFT_RESET_CP | SOFT_RESET_HI | SOFT_RESET_SE
		  | SOFT_RESET_RE | SOFT_RESET_PP | SOFT_RESET_E2 | SOFT_RESET_RB)));
		INREG(RBBM_SOFT_RESET);
	}
	OUTREG(HOST_PATH_CNTL, host_path_cntl | HDP_SOFT_RESET);
	INREG(HOST_PATH_CNTL);
	OUTREG(HOST_PATH_CNTL, host_path_cntl);
	if((rinfo->family != CHIP_FAMILY_R300)
	 && (rinfo->family != CHIP_FAMILY_R350)
	 && (rinfo->family != CHIP_FAMILY_RV350))
	OUTREG(RBBM_SOFT_RESET, rbbm_soft_reset);
	OUTREG(CLOCK_CNTL_INDEX, clock_cntl_index);
	OUTPLL(MCLK_CNTL, mclk_cntl);
}

/* Restore the acceleration hardware to its previous state */
void RADEONEngineRestore(struct radeonfb_info *rinfo)
{
	BEGIN_ACCEL(1);
	/* NOTE: The following RB2D_DSTCACHE_MODE setting will cause the
	 * R300 to hang.  ATI does not see a reason to change it from the
	 * default BIOS settings (even on non-R300 cards).  This setting
	 * might be removed in future versions of the Radeon driver.
	 */
	/* Turn of all automatic flushing - we'll do it all */
	if((rinfo->family != CHIP_FAMILY_R300)
	 && (rinfo->family != CHIP_FAMILY_R350)
	 && (rinfo->family != CHIP_FAMILY_RV350))
		OUTREG(RB2D_DSTCACHE_MODE, 0);
	rinfo->fb_local_base = INREG(MC_FB_LOCATION) << 16;
	BEGIN_ACCEL(3);
	OUTREG(DEFAULT_PITCH_OFFSET, rinfo->dst_pitch_offset);
	OUTREG(DST_PITCH_OFFSET, rinfo->dst_pitch_offset);
	OUTREG(SRC_PITCH_OFFSET, rinfo->dst_pitch_offset);
	BEGIN_ACCEL(1);
	if(rinfo->big_endian)
		OUTREGP(DP_DATATYPE, HOST_BIG_ENDIAN_EN, ~HOST_BIG_ENDIAN_EN);
	else
    OUTREGP(DP_DATATYPE, 0, ~HOST_BIG_ENDIAN_EN);
	/* Restore SURFACE_CNTL - only the first head contains valid data */
	OUTREG(SURFACE_CNTL, rinfo->state.surface_cntl);
	BEGIN_ACCEL(2);
	OUTREG(DEFAULT_SC_TOP_LEFT, 0);
	OUTREG(DEFAULT_SC_BOTTOM_RIGHT, (DEFAULT_SC_RIGHT_MAX | DEFAULT_SC_BOTTOM_MAX));
	BEGIN_ACCEL(1);
	OUTREG(DP_GUI_MASTER_CNTL, (rinfo->dp_gui_master_cntl | GMC_BRUSH_SOLID_COLOR | GMC_SRC_DATATYPE_COLOR));
	BEGIN_ACCEL(7);
	OUTREG(DST_LINE_START, 0);
	OUTREG(DST_LINE_END, 0);
	OUTREG(DP_BRUSH_FRGD_CLR, 0xffffffff);
	OUTREG(DP_BRUSH_BKGD_CLR, 0x00000000);
	OUTREG(DP_SRC_FRGD_CLR, 0xffffffff);
	OUTREG(DP_SRC_BKGD_CLR, 0x00000000);
	OUTREG(DP_WRITE_MSK, 0xffffffff);
	RADEONWaitForIdleMMIO(rinfo);
}

/* Initialize the acceleration hardware */
void RADEONEngineInit(struct radeonfb_info *rinfo)
{
	unsigned long temp;
	OUTREG(RB3D_CNTL, 0);
	RADEONEngineReset(rinfo);
	temp = radeon_get_dstbpp(rinfo->depth);
#ifdef RADEON_TILING
	rinfo->dp_gui_master_cntl = ((temp << GMC_DST_DATATYPE_SHIFT) | GMC_CLR_CMP_CNTL_DIS | GMC_DST_PITCH_OFFSET_CNTL);
#else
	rinfo->dp_gui_master_cntl = ((temp << GMC_DST_DATATYPE_SHIFT) | GMC_CLR_CMP_CNTL_DIS);
#endif
	RADEONEngineRestore(rinfo);
}

