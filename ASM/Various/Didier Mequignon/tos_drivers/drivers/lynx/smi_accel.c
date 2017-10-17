/*
Copyright (C) 1994-1999 The XFree86 Project, Inc.  All Rights Reserved.
Copyright (C) 2000 Silicon Motion, Inc.  All Rights Reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FIT-
NESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
XFREE86 PROJECT BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Except as contained in this notice, the names of the XFree86 Project and
Silicon Motion shall not be used in advertising or otherwise to promote the
sale, use or other dealings in this Software without prior written
authorization from the XFree86 Project and silicon Motion.
*/

#include "config.h"
#include "fb.h"
#include "smi.h"

#ifdef CONFIG_VIDEO_SMI_LYNXEM

#define ENTER()
#define LEAVE()

#define ROP3_ZERO             0x00
#define ROP3_DSa              0x88
#define ROP3_SDna             0x44
#define ROP3_S                0xcc
#define ROP3_SRCCOPY          0xcc
#define ROP3_DSna             0x22
#define ROP3_D                0xaa
#define ROP3_DSx              0x66
#define ROP3_DSo              0xee
#define ROP3_DSon             0x11
#define ROP3_DSxn             0x99
#define ROP3_Dn               0x55
#define ROP3_SDno             0xdd
#define ROP3_Sn               0x33
#define ROP3_DSno             0xbb
#define ROP3_DSan             0x77
#define ROP3_ONE              0xff
#define ROP3_DPa              0xa0
#define ROP3_PDna             0x50
#define ROP3_P                0xf0
#define ROP3_PATCOPY          0xf0
#define ROP3_DPna             0x0a
#define ROP3_D                0xaa
#define ROP3_DPx              0x5a
#define ROP3_DPo              0xfa
#define ROP3_DPon             0x05
#define ROP3_PDxn             0xa5
#define ROP3_PDno             0xf5
#define ROP3_Pn               0x0f
#define ROP3_DPno             0xaf
#define ROP3_DPan             0x5f

static struct {
    int rop;
    int pattern;
} SMI_ROP[] = {
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

extern int swap_long(int val);

/* timeout value for engine waits */
#define MAXLOOP			0x100000

/* Wait until 2d engine queue is empty */
static void SMI_WaitQueue(struct smifb_info *smiinfo)
{
	int	loop = MAXLOOP;
	while(loop-- && !(VGAIN8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x16) & 0x10));
	if(loop <= 0)
		SMI_GEReset(smiinfo->info, 1);
}

/* Wait until GP is idle */
void SMI_WaitIdle(struct smifb_info *smiinfo)
{
	int	status, loop = MAXLOOP;
	for(status = VGAIN8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x16);
		loop && (status & 0x18) != 0x10;
	status = VGAIN8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x16), loop--);				       			\
	if(loop <= 0)
		SMI_GEReset(smiinfo->info, 1);
}

void SMI_SetupForScreenToScreenCopy(struct fb_info *info, int xdir, int ydir, int rop, unsigned int planemask, int trans)
{
	struct smifb_info *smiinfo = info->par;
	ENTER();
	if(smiinfo->big_endian)
	{
		if(smiinfo->depth >= 24)
			trans = swap_long(trans);
	}
	smiinfo->AccelCmd = SMI_ROP[rop].rop | SMI_BITBLT | SMI_START_ENGINE;
	if((xdir == -1) || (ydir == -1))
		smiinfo->AccelCmd |= SMI_RIGHT_TO_LEFT;
	if(trans != -1)
	{
		smiinfo->AccelCmd |= SMI_TRANSPARENT_SRC | SMI_TRANSPARENT_PXL;
		SMI_WaitQueue(smiinfo);
		WRITE_DPR(smiinfo, 0x20, trans);
	}
	if(smiinfo->ClipTurnedOn)
	{
		SMI_WaitQueue(smiinfo);
		WRITE_DPR(smiinfo, 0x2C, smiinfo->ScissorsLeft);
		smiinfo->ClipTurnedOn = FALSE;
	}
	LEAVE();
}

void SMI_SubsequentScreenToScreenCopy(struct fb_info *info, int x1, int y1, int x2, int y2, int w, int h)
{
	struct smifb_info *smiinfo = info->par;
	ENTER();
	if(smiinfo->AccelCmd & SMI_RIGHT_TO_LEFT)
	{
		x1 += w - 1;
		y1 += h - 1;
		x2 += w - 1;
		y2 += h - 1;
	}
	if(smiinfo->bpp == 24)
	{
		x1 *= 3;
		x2 *= 3;
		w  *= 3;
		if(smiinfo->chipset == SMI_LYNX)
		{
			y1 *= 3;
			y2 *= 3;
		}
		if(smiinfo->AccelCmd & SMI_RIGHT_TO_LEFT)
		{
			x1 += 2;
			x2 += 2;
		}
	}
	SMI_WaitIdle(smiinfo);
	WRITE_DPR(smiinfo, 0x00, (x1 << 16) + (y1 & 0xFFFF));
	WRITE_DPR(smiinfo, 0x04, (x2 << 16) + (y2 & 0xFFFF));
	WRITE_DPR(smiinfo, 0x08, (w  << 16) + (h  & 0xFFFF));
	WRITE_DPR(smiinfo, 0x0C, smiinfo->AccelCmd);
	LEAVE();
}

void SMI_ScreenToScreenCopy(struct fb_info *info, int x1, int y1, int x2, int y2, int w, int h, int rop)
{
	struct smifb_info *smiinfo = info->par;
	int xdir = x1 - x2;
	int ydir = y1 - y2;
	ENTER();
	smiinfo->AccelCmd = SMI_ROP[rop].rop | SMI_BITBLT | SMI_START_ENGINE;
	if((xdir == -1) || (ydir == -1))
		smiinfo->AccelCmd |= SMI_RIGHT_TO_LEFT;
	if(smiinfo->ClipTurnedOn)
	{
		SMI_WaitQueue(smiinfo);
		WRITE_DPR(smiinfo, 0x2C, smiinfo->ScissorsLeft);
		smiinfo->ClipTurnedOn = FALSE;
	}
	if(smiinfo->AccelCmd & SMI_RIGHT_TO_LEFT)
	{
		x1 += w - 1;
		y1 += h - 1;
		x2 += w - 1;
		y2 += h - 1;
	}
	if(smiinfo->bpp == 24)
	{
		x1 *= 3;
		x2 *= 3;
		w  *= 3;
		if(smiinfo->chipset == SMI_LYNX)
		{
			y1 *= 3;
			y2 *= 3;
		}
		if(smiinfo->AccelCmd & SMI_RIGHT_TO_LEFT)
		{
			x1 += 2;
			x2 += 2;
		}
	}
	SMI_WaitIdle(smiinfo);
	WRITE_DPR(smiinfo, 0x00, (x1 << 16) + (y1 & 0xFFFF));
	WRITE_DPR(smiinfo, 0x04, (x2 << 16) + (y2 & 0xFFFF));
	WRITE_DPR(smiinfo, 0x08, (w  << 16) + (h  & 0xFFFF));
	WRITE_DPR(smiinfo, 0x0C, smiinfo->AccelCmd);
	LEAVE();
}

void SMI_SetupForSolidFill(struct fb_info *info, int color, int rop, unsigned int planemask)
{
	struct smifb_info *smiinfo = info->par;
	ENTER();
	smiinfo->AccelCmd = SMI_ROP[rop].pattern | SMI_BITBLT | SMI_START_ENGINE;
	if(smiinfo->big_endian)
	{
		if(smiinfo->depth >= 24)
		{
			/* because of the BGR values are in the MSB bytes,
			 * 'white' is not possible and -1 has a different meaning.
			 * As a work around (assuming white is more used as
			 * light yellow (#FFFF7F), we handle this as beining white.
			 * Thanks to the SM501 not being able to work in MSB on PCI on the PowerPC */
			if(color == 0x7FFFFFFF)
				color = -1;
			color = swap_long(color);
		}
	}
	if(smiinfo->ClipTurnedOn)
	{
		SMI_WaitQueue(smiinfo);
		WRITE_DPR(smiinfo, 0x2C, smiinfo->ScissorsLeft);
		smiinfo->ClipTurnedOn = FALSE;
	}
	else
		SMI_WaitQueue(smiinfo);
	WRITE_DPR(smiinfo, 0x14, color);
	WRITE_DPR(smiinfo, 0x34, 0xFFFFFFFF);
	WRITE_DPR(smiinfo, 0x38, 0xFFFFFFFF);
	LEAVE();
}

void SMI_SubsequentSolidFillRect(struct fb_info *info, int x, int y, int w, int h)
{
	struct smifb_info *smiinfo = info->par;
	ENTER();
	if(smiinfo->bpp == 24)
		x *= 3;
	w *= 3;
	if(smiinfo->chipset == SMI_LYNX)
		y *= 3;
	SMI_WaitQueue(smiinfo);
	WRITE_DPR(smiinfo, 0x04, (x << 16) | (y & 0xFFFF));
	WRITE_DPR(smiinfo, 0x08, (w << 16) | (h & 0xFFFF));
	WRITE_DPR(smiinfo, 0x0C, smiinfo->AccelCmd);
	LEAVE();
}

void SMI_SubsequentSolidHorVertLine(struct fb_info *info, int x, int y, int len, int dir)
{
	struct smifb_info *smiinfo = info->par;
	int w, h;
	ENTER();
	if(dir == DEGREES_0)
	{
		w = len;
		h = 1;
	}
	else
	{
		w = 1;
		h = len;
	}
	if(smiinfo->bpp == 24)
	{
		x *= 3;
		w *= 3;
		if(smiinfo->chipset == SMI_LYNX)
			y *= 3;
	}
	SMI_WaitQueue(smiinfo);
	WRITE_DPR(smiinfo, 0x04, (x << 16) | (y & 0xFFFF));
	WRITE_DPR(smiinfo, 0x08, (w << 16) | (h & 0xFFFF));
	WRITE_DPR(smiinfo, 0x0C, smiinfo->AccelCmd);
	LEAVE();
}

void SMI_SetupForCPUToScreenColorExpandFill(struct fb_info *info, int fg, int bg, int rop, unsigned int planemask)
{
	struct smifb_info *smiinfo = info->par;
	ENTER();
	if(smiinfo->big_endian)
	{
		if(smiinfo->depth >= 24)
		{
			/* see remark elswere */
			if(fg == 0x7FFFFFFF)
				fg = -1;
			fg = swap_long(fg);
			bg = swap_long(bg);
		}
	}
	smiinfo->AccelCmd = SMI_ROP[rop].rop | SMI_HOSTBLT_WRITE | SMI_SRC_MONOCHROME | SMI_START_ENGINE;
	if(bg == -1)
	{
		smiinfo->AccelCmd |= SMI_TRANSPARENT_SRC;
		SMI_WaitQueue(smiinfo);
		WRITE_DPR(smiinfo, 0x14, fg);
		WRITE_DPR(smiinfo, 0x18, ~fg);
		WRITE_DPR(smiinfo, 0x20, fg);
	}
	else
	{
		if(smiinfo->big_endian)
		{
			if(bg == 0xFFFFFF7F)
		    bg = -1;
		}
		SMI_WaitQueue(smiinfo);
		WRITE_DPR(smiinfo, 0x14, fg);
		WRITE_DPR(smiinfo, 0x18, bg);
	}
	LEAVE();
}

void SMI_SubsequentCPUToScreenColorExpandFill(struct fb_info *info, int x, int y, int w, int h, int skipleft)
{
	struct smifb_info *smiinfo = info->par;
	ENTER();
	smiinfo->scanline_words = (w + 31) >> 5;
	smiinfo->scanline_ptr = (unsigned long *)smiinfo->DataPortBase;
	if(smiinfo->bpp == 24)
	{
		x *= 3;
		w *= 3;
		skipleft *= 3;
		if(smiinfo->chipset == SMI_LYNX)
			y *= 3;
	}
	if(skipleft)
	{
		SMI_WaitQueue(smiinfo);
		WRITE_DPR(smiinfo, 0x2C, (smiinfo->ScissorsLeft & 0xFFFF0000) | (x + skipleft) | 0x2000);
		smiinfo->ClipTurnedOn = TRUE;
	}
	else
	{
		SMI_WaitQueue(smiinfo);
		if(smiinfo->ClipTurnedOn)
		{
			WRITE_DPR(smiinfo, 0x2C, smiinfo->ScissorsLeft);
			smiinfo->ClipTurnedOn = FALSE;
		}
	}
	WRITE_DPR(smiinfo, 0x00, 0);
	WRITE_DPR(smiinfo, 0x04, (x << 16) | (y & 0xFFFF));
	WRITE_DPR(smiinfo, 0x08, (w << 16) | (h & 0xFFFF));
	WRITE_DPR(smiinfo, 0x0C, smiinfo->AccelCmd);
	LEAVE();
}

void SMI_SubsequentScanline(struct fb_info *info, unsigned long *src)
{
	struct smifb_info *smiinfo = info->par;
	ENTER();
	memcpy(smiinfo->scanline_ptr, src, smiinfo->scanline_words << 2);
	smiinfo->scanline_ptr += smiinfo->scanline_words;
	LEAVE();
}

void SMI_SetupForMono8x8PatternFill(struct fb_info *info, int patx, int paty, int fg, int bg, int rop, unsigned int planemask)
{
	struct smifb_info *smiinfo = info->par;
	ENTER();
	if(smiinfo->big_endian)
	{
		if(smiinfo->depth >= 24)
		{
			if(fg == 0x7FFFFFFF)
				fg = -1;
			fg = swap_long(fg);
			bg = swap_long(bg);
		}
	}
	smiinfo->AccelCmd = SMI_ROP[rop].pattern | SMI_BITBLT | SMI_START_ENGINE;
	if(smiinfo->ClipTurnedOn)
	{
		SMI_WaitQueue(smiinfo);
		WRITE_DPR(smiinfo, 0x2C, smiinfo->ScissorsLeft);
		smiinfo->ClipTurnedOn = FALSE;
	}
	if(bg == -1)
	{
		SMI_WaitQueue(smiinfo);
		WRITE_DPR(smiinfo, 0x14, fg);
		WRITE_DPR(smiinfo, 0x18, ~fg);
		WRITE_DPR(smiinfo, 0x20, fg);
		WRITE_DPR(smiinfo, 0x34, patx);
		WRITE_DPR(smiinfo, 0x38, paty);
	}
	else
	{
		if(smiinfo->big_endian)
		{
			if(bg == 0xFFFFFF7F)
			bg = -1;
		}
		SMI_WaitQueue(smiinfo);
		WRITE_DPR(smiinfo, 0x14, fg);
		WRITE_DPR(smiinfo, 0x18, bg);
		WRITE_DPR(smiinfo, 0x34, patx);
		WRITE_DPR(smiinfo, 0x38, paty);
	}
	LEAVE();
}

void SMI_SubsequentMono8x8PatternFillRect(struct fb_info *info, int patx, int paty, int x, int y, int w, int h)
{
	struct smifb_info *smiinfo = info->par;
	ENTER();
	if(smiinfo->bpp == 24)
	{
		x *= 3;
		w *= 3;
		if(smiinfo->chipset == SMI_LYNX)
			y *= 3;
	}
	SMI_WaitQueue(smiinfo);
	WRITE_DPR(smiinfo, 0x04, (x << 16) | (y & 0xFFFF));
	WRITE_DPR(smiinfo, 0x08, (w << 16) | (h & 0xFFFF));
	WRITE_DPR(smiinfo, 0x0C, smiinfo->AccelCmd);
	LEAVE();
}

#if 0

void SMI_SetupForColor8x8PatternFill(struct fb_info *info, int patx, int paty, int rop, unsigned int planemask, int trans_color)
{
	struct smifb_info *smiinfo = info->par;
	ENTER();
	smiinfo->AccelCmd = SMI_ROP[rop].pattern | SMI_BITBLT | SMI_COLOR_PATTERN | SMI_START_ENGINE;
	if(smiinfo->big_endian)
	{
		if(smiinfo->depth >= 24)
			trans_color = swap_long(trans_color);
	}
	if(smiinfo->bpp <= 16)
	{
		/* PDR#950 */
 		int Bpp = smiinfo->bpp >> 3;
		char *pattern = smiinfo->fb_base + (patx + paty * (((info->var.xres_virtual * Bpp + 15) & ~15) / Bpp)) * Bpp;
		SMI_WaitIdle(smiinfo);
		WRITE_DPR(smiinfo, 0x0C, SMI_BITBLT | SMI_COLOR_PATTERN);
		memcpy(smiinfo->DataPortBase, pattern, 8 * Bpp * 8);
	}
	else
	{
		if(smiinfo->bpp == 24)
		{
			patx *= 3;
			if(smiinfo->chipset == SMI_LYNX)
				paty *= 3;
		}
		SMI_WaitQueue(smiinfo);
		WRITE_DPR(smiinfo, 0x00, (patx << 16) | (paty & 0xFFFF));
	}
	SMI_WaitQueue(smiinfo);
	if(trans_color == -1)
	{
		smiinfo->AccelCmd |= SMI_TRANSPARENT_SRC | SMI_TRANSPARENT_PXL;
		SMI_WaitQueue(smiinfo);
		WRITE_DPR(smiinfo, 0x20, trans_color);
	}
	if(smiinfo->ClipTurnedOn)
	{
		SMI_WaitQueue(smiinfo);
		WRITE_DPR(smiinfo, 0x2C, smiinfo->ScissorsLeft);
		smiinfo->ClipTurnedOn = FALSE;
	}
	LEAVE();
}

void SMI_SubsequentColor8x8PatternFillRect(struct fb_info *info, int patx, int paty, int x, int y, int w, int h)
{
	struct smifb_info *smiinfo = info->par;
	ENTER();
	if(smiinfo->bpp == 24)
	{
		x *= 3;
		w *= 3;
		if(smiinfo->chipset == SMI_LYNX)
		  y *= 3;
	}
	SMI_WaitQueue(smiinfo);
	WRITE_DPR(smiinfo, 0x04, (x << 16) | (y & 0xFFFF));
	WRITE_DPR(smiinfo, 0x08, (w << 16) | (h & 0xFFFF));	/* PDR#950 */
	WRITE_DPR(smiinfo, 0x0C, smiinfo->AccelCmd);
	LEAVE();
}

void SMI_SetupForImageWrite(struct fb_info *info, int rop, unsigned int planemask, int trans_color, int bpp, int depth)
{
	struct smifb_info *smiinfo = info->par;
	ENTER();
	if(smiinfo->big_endian)
	{
		if(smiinfo->depth >= 24)
			trans_color = swap_long(trans_color);
	}
	smiinfo->AccelCmd = SMI_ROP[rop].rop | SMI_HOSTBLT_WRITE | SMI_START_ENGINE;
	if(trans_color != -1)
	{
		if(smiinfo->big_endian)
		{
			if(trans_color == 0xFFFFFF7F)
		    trans_color = -1;
		}
		smiinfo->AccelCmd |= SMI_TRANSPARENT_SRC | SMI_TRANSPARENT_PXL;
		SMI_WaitQueue(smiinfo);
		WRITE_DPR(smiinfo, 0x20, trans_color);
	}
	LEAVE();
}

void SMI_SubsequentImageWriteRect(struct fb_info *info, int x, int y, int w, int h, int skipleft)
{
	struct smifb_info *smiinfo = info->par;
	ENTER();
	if(smiinfo->bpp == 24)
	{
		x *= 3;
		w *= 3;
		skipleft *= 3;
		if(smiinfo->chipset == SMI_LYNX)
	    y *= 3;
	}
	if(skipleft)
	{
		SMI_WaitQueue(smiinfo);
		WRITE_DPR(smiinfo, 0x2C, (smiinfo->ScissorsLeft & 0xFFFF0000) | (x + skipleft) | 0x2000);
		smiinfo->ClipTurnedOn = TRUE;
	}
	else
	{
		if(smiinfo->ClipTurnedOn)
		{
	    SMI_WaitQueue(smiinfo);
	    WRITE_DPR(smiinfo, 0x2C, smiinfo->ScissorsLeft);
	    smiinfo->ClipTurnedOn = FALSE;
		}
		else
			SMI_WaitQueue(smiinfo);
	}
	WRITE_DPR(smiinfo, 0x00, 0);
	WRITE_DPR(smiinfo, 0x04, (x << 16) | (y * 0xFFFF));
	WRITE_DPR(smiinfo, 0x08, (w << 16) | (h & 0xFFFF));
	WRITE_DPR(smiinfo, 0x0C, smiinfo->AccelCmd);
	LEAVE();
}

#endif

void SMI_SetClippingRectangle(struct fb_info *info, int left, int top, int right, int bottom)
{
	struct smifb_info *smiinfo = info->par;
	ENTER();
	if(smiinfo->bpp == 24)
	{
		left  *= 3;
		right *= 3;
		if(smiinfo->chipset == SMI_LYNX)
		{
	    top    *= 3;
	    bottom *= 3;
		}
	}
	smiinfo->ScissorsLeft = (top << 16) | (left & 0xFFFF) | 0x2000;
	smiinfo->ScissorsRight = (bottom << 16) | (right & 0xFFFF);
	smiinfo->ClipTurnedOn = FALSE;
	SMI_WaitQueue(smiinfo);
	WRITE_DPR(smiinfo, 0x2C, smiinfo->ScissorsLeft);
	WRITE_DPR(smiinfo, 0x30, smiinfo->ScissorsRight);
	LEAVE();
}

void SMI_DisableClipping(struct fb_info *info)
{
	struct smifb_info *smiinfo = info->par;
	ENTER();
	smiinfo->ScissorsLeft = 0;
	if(smiinfo->bpp == 24)
	{
		if(smiinfo->chipset == SMI_LYNX)
			smiinfo->ScissorsRight = ((info->var.yres_virtual * 3) << 16) | (info->var.xres_virtual * 3);
		else
			smiinfo->ScissorsRight = (info->var.yres_virtual << 16) | (info->var.xres_virtual * 3);
	}
	else
		smiinfo->ScissorsRight = (info->var.yres_virtual << 16) | info->var.xres_virtual;
	smiinfo->ClipTurnedOn = FALSE;
	SMI_WaitQueue(smiinfo);
	WRITE_DPR(smiinfo, 0x2C, smiinfo->ScissorsLeft);
	WRITE_DPR(smiinfo, 0x30, smiinfo->ScissorsRight);
	LEAVE();
}

void SMI_GEReset(struct fb_info *info, int from_timeout)
{
	struct smifb_info *smiinfo = info->par;
	long tmp;
	ENTER();
	SMI_WaitIdle(smiinfo);
	tmp = VGAIN8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x15);
	VGAOUT8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x15, tmp | 0x30);
	VGAOUT8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x15, tmp);
	SMI_EngineReset(info);
	LEAVE();
}

static unsigned long SMI_DEDataFormat(int bpp)
{
	unsigned long DEDataFormat = 0;
	switch(bpp)
	{
    case 8: DEDataFormat = 0x00000000; break;
		case 16: DEDataFormat = 0x00100000; break;
		case 24: DEDataFormat = 0x00300000; break;
		case 32: DEDataFormat = 0x00200000; break;
	}
	return DEDataFormat;
}

void SMI_EngineReset(struct fb_info *info)
{
	struct smifb_info *smiinfo = info->par;
	unsigned long DEDataFormat = 0;
	int i, stride, Bpp = smiinfo->bpp >> 3;
	int xyAddress[] = { 320, 400, 512, 640, 800, 1024, 1280, 1600, 2048 };
	ENTER();
	DEDataFormat = SMI_DEDataFormat(smiinfo->bpp);
	for(i = 0; i < sizeof(xyAddress) / sizeof(xyAddress[0]); i++)
	{
		if(xyAddress[i] == info->var.xres_virtual)
		{
			DEDataFormat |= (i << 16);
			break;
		}
	}
	DEDataFormat |= 0x40000000; /* Force pattern origin coordinates to (0,0) */
	SMI_WaitIdle(smiinfo);
	stride = ((info->var.xres_virtual * Bpp + 15) & ~15) / Bpp;
	if(smiinfo->bpp == 24)
		stride *= 3;
	WRITE_DPR(smiinfo, 0x10, (stride << 16) | stride);
	WRITE_DPR(smiinfo, 0x1C, DEDataFormat);
	WRITE_DPR(smiinfo, 0x24, 0xFFFFFFFF);
	WRITE_DPR(smiinfo, 0x28, 0xFFFFFFFF);
	WRITE_DPR(smiinfo, 0x3C, (stride << 16) | stride);
	WRITE_DPR(smiinfo, 0x40, smiinfo->fb_offset >> 3);
	WRITE_DPR(smiinfo, 0x44, smiinfo->fb_offset >> 3);
	SMI_DisableClipping(info);
	LEAVE();
}

#endif /* CONFIG_VIDEO_SMI_LYNXEM */
