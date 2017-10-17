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
authorization from the XFree86 Project and Silicon Motion.
*/

#include "config.h"
#include "smi.h"

#ifdef CONFIG_VIDEO_SMI_LYNXEM

#define MAX_CURSOR	32

void SMI_LoadCursorImage(struct fb_info *info, unsigned short *mask, unsigned short *data, int zoom)
{
	struct smifb_info *smiinfo = info->par;
	static unsigned long buffer[256];
	char *src = (unsigned char *)buffer;
	unsigned short chunk, mchunk;
	char tmp;
	int i = 0, j;
	if(zoom);
	/* Copy cursor image */
	for(j = 0; j < MAX_CURSOR; j++)
	{
		if(j < 16)
		{
			mchunk = *mask++;
			chunk = *data++;
		}
		else
			mchunk = chunk = 0;
		src[i++] = ~((unsigned char)(mchunk >> 8));
		src[i++] = (unsigned char)(chunk >> 8);
		src[i++] = ~((unsigned char)(mchunk & 0xFF));
		src[i++] = (unsigned char)(chunk & 0xFF);
		i += 4;
		src[i++] = 0xFF;
		src[i++] = 0x00;
		src[i++] = 0xFF;
		src[i++] = 0x00;
		i += 4;
	}
	/* Load storage location. */
	VGAOUT8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x80, smiinfo->cursor_start / 2048);
	tmp = VGAIN8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x81) & 0x80;
	VGAOUT8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x81, tmp | ((smiinfo->cursor_start / 2048) >> 8));
	/* Copy cursor image to framebuffer storage */
	memcpy(smiinfo->fb_base + smiinfo->cursor_start, src, 1024);
}

void SMI_ShowCursor(struct fb_info *info)
{
	struct smifb_info *smiinfo = info->par;
	char tmp;
	/* Show cursor */
	tmp = VGAIN8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x81);
	VGAOUT8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x81, tmp | 0x80);
}

void SMI_HideCursor(struct fb_info *info)
{
	struct smifb_info *smiinfo = info->par;
	char tmp;
	/* Hide cursor */
	tmp = VGAIN8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x81);
	VGAOUT8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x81, tmp & ~0x80);
}

void SMI_SetCursorPosition(struct fb_info *info, int xoff, int yoff)
{
	struct smifb_info *smiinfo = info->par;
	/* Program coordinates */
	if(xoff >= 0)
	{
		VGAOUT8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x88, xoff & 0xFF);
		VGAOUT8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x89, (xoff >> 8) & 0x07);
	}
	else
	{
		VGAOUT8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x88, (-xoff) & (MAX_CURSOR - 1));
		VGAOUT8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x89, 0x08);
	}
	if(yoff >= 0)
	{
		VGAOUT8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x8A, yoff & 0xFF);
		VGAOUT8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x8B, (yoff >> 8) & 0x07);
	}
	else
	{
		VGAOUT8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x8A, (-yoff) & (MAX_CURSOR - 1));
		VGAOUT8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x8B, 0x08);
	}
}

void SMI_SetCursorColors(struct fb_info *info, int bg, int fg)
{
	struct smifb_info *smiinfo = info->par;
	unsigned char packedFG, packedBG;
	/* Pack the true color into 8 bit */
	packedFG = (fg & 0xE00000) >> 16 | (fg & 0x00E000) >> 11 | (fg & 0x0000C0) >> 6;
	packedBG = (bg & 0xE00000) >> 16 | (bg & 0x00E000) >> 11 | (bg & 0x0000C0) >> 6;
	/* Program the colors */
	VGAOUT8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x8C, packedFG);
	VGAOUT8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, 0x8D, packedBG);
}

long SMI_CursorInit(struct fb_info *info)
{
	struct smifb_info *smiinfo = info->par;
	int size_bytes = MAX_CURSOR * MAX_CURSOR;
	unsigned long fbarea = offscreen_alloc(smiinfo->info, size_bytes + 2048);
	DPRINTVALHEX("lynxfb: SMI_CursorInit: fbarea ", fbarea);
	if(!fbarea)
		smiinfo->cursor_start = 0;
	else
	{
		smiinfo->cursor_start = SMI_ALIGN(fbarea - (unsigned long)smiinfo->fb_base, 2048);
		smiinfo->cursor_end = smiinfo->cursor_start + size_bytes;
	}
	DPRINTVALHEX(" cursor_start ", smiinfo->cursor_start);
	DPRINT("\r\n");
	return(smiinfo->cursor_start ? fbarea : 0);
}

#endif /* CONFIG_VIDEO_SMI_LYNXEM */
