/* VDI driver for the CT60/CTPCI & Coldfire boards
 * Didier Mequignon 2005-2010, e-mail: aniplay@wanadoo.fr
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
 * along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */
 
#include "config.h"
#include <mint/mintbind.h>
#include <mint/falcon.h>
#include <mint/sysvars.h>
#include <string.h>
#include "fb.h"
#include "ct60.h"

#undef Vsetscreen // return a long, trick for get info_fvdi structure with 'VN', CMD_ENUMMODES
#define Vsetscreen(lscrn,pscrn,rez,mode) (long)trap_14_wllww((short)5,(long)(lscrn),(long)(pscrn),(short)(rez),(short)(mode))

#ifdef COLDFIRE
extern short SMUL_DIV(short x, short y, short z);
#else
#define SMUL_DIV(x,y,z)	((short)(((short)(x)*(long)((short)(y)))/(short)(z)))
#endif

#ifdef DRIVER_IN_ROM
#include "../dma_utils/dma_utils.h"
#endif /* DRIVER_IN_ROM */

#undef USE_OFFSCREEN

#define CLIP_LEFT_EDGE   0x1
#define CLIP_RIGHT_EDGE  0x2
#define CLIP_BOTTOM_EDGE 0x4
#define CLIP_TOP_EDGE    0x8
#define CLIP_INSIDE(a)   (!a)
#define CLIP_REJECT(a,b) (a&b)
#define CLIP_ACCEPT(a,b) (!(a|b))

static const unsigned char vdi_colours[] = { 0,2,3,6,4,7,5,8,9,10,11,14,12,15,13,255 };
static const unsigned char tos_colours[] = { 0,255,1,2,4,6,3,5,7,8,9,10,12,14,11,13 };
#define toTosColors( color ) \
    ( (color)<(sizeof(tos_colours)/sizeof(*tos_colours)) ? tos_colours[color] : ((color) == 255 ? 15 : (color)) )
#define toVdiColors( color ) \
    ( (color)<(sizeof(vdi_colours)/sizeof(*vdi_colours)) ? vdi_colours[color] : color)

/* from common.c */
extern Driver *me;

/* from spec.c */
extern long buf_cursor;
extern short virtual;
extern short zoom_mouse;
#ifndef DRIVER_IN_ROM
extern short use_setscreen;
extern short init_screen;
#endif
extern void CDECL (*get_colours_r)(Virtual *vwk, long colour, long *foreground, long *background);

extern struct fb_info *info_fvdi;

/* from colours.c */

extern short colours[];

/* from access.S */
extern char *Funcs_allocate_block(long size);
extern void Funcs_free_block(void *addr);

#ifdef COLDFIRE
extern long init_videl(long width, long height, long bpp, long freq);
#if defined(DRIVER_IN_ROM) && defined(MCF547X)
extern void blitter_copy(unsigned char *src_addr, int src_line_add, unsigned char *dst_addr, int dst_line_add, int w, int h, int bpp, int op, int backward);
#undef USE_BLITTER
#endif /* defined(DRIVER_IN_ROM) && defined(MCF547X) */
#endif /* COLDFIRE */

static inline int clip_encode(long x, long y, long left, long top, long right, long bottom)
{
	int code = 0;
	if(x < left)
		code |= CLIP_LEFT_EDGE;
	else if (x > right)
		code |= CLIP_RIGHT_EDGE;
	if(y < top)
		code |= CLIP_TOP_EDGE;
	else if (y > bottom)
		code |= CLIP_BOTTOM_EDGE;
	return code;
}

int clip_line(Virtual *vwk, long *x_1, long *y_1, long *x_2, long *y_2)
{
	long left, top, right, bottom;
	long x1, y1, x2, y2, m1, m2, dx, dy;
	struct fb_info *info = info_fvdi;
	int draw = 0;
	x1 = *x_1;
	y1 = *y_1;
	x2 = *x_2;
	y2 = *y_2;
	m1 = m2 = 65536;
	if(!vwk->clip.on)
	{
		left   = 0;
		top    = 0;
		right  = (long)info->var.xres_virtual-1;
		bottom = (long)info->var.yres_virtual-1;
	}
	else
	{
		left   = (long)vwk->clip.rectangle.x1;
		top    = (long)vwk->clip.rectangle.y1;
		right  = (long)vwk->clip.rectangle.x2;
		bottom = (long)vwk->clip.rectangle.y2;
	}
	while(1)
	{
		int code1 = clip_encode(x1, y1, left, top, right, bottom);
		int code2 = clip_encode(x2, y2, left, top, right, bottom);
		if(CLIP_ACCEPT(code1, code2))
		{
			draw = 1;
			break;
		}
		else if(CLIP_REJECT(code1, code2))
			break;
		else
		{
			if(CLIP_INSIDE(code1))
			{
				long swaptmp = x2; x2 = x1; x1 = swaptmp;
				swaptmp = y2; y2 = y1; y1 = swaptmp;
				swaptmp = code2; code2 = code1; code1 = swaptmp;
			}
			if(x2 != x1)
			{
				dx = x2 - x1;
				if(dx)
					m1 = ((y2 - y1) << 16) / dx;
				else
					m1 = 0;
				dy = y2 - y1;
				if(dy)
					m2 = ((x2 - x1) << 16) / dy;
				else
					m2 = 0;
			}
			if(code1 & CLIP_LEFT_EDGE)
			{
				y1 += (((left - x1) * m1) >> 16);
				x1 = left;
			}
			else if(code1 & CLIP_RIGHT_EDGE)
			{
				y1 += (((right - x1) * m1) >> 16);
				x1 = right;
			}
			else if(code1 & CLIP_BOTTOM_EDGE)
			{
				if (x2 != x1)
					x1 += (((bottom - y1) * m2) >> 16);
				y1 = bottom;
			}
			else if(code1 & CLIP_TOP_EDGE)
			{
				if (x2 != x1)
					x1 += (((top - y1) * m2) >> 16);
				y1 = top;
			}
		}
	}
	*x_1 = x1;
	*y_1 = y1;
	*x_2 = x2;
	*y_2 = y2;
	return draw;
}

static int check_table(short *table, int length)
{
  while(length > 0)
  {
  	if((table[0] != table[2]) && (table[1] != table[3]))
			return(0);
		table += 2;
		length--;
  }
  return(1);
}

#ifdef DRIVER_IN_ROM
#ifdef COLDFIRE
#ifndef NETWORK

inline int dma_transfer(char *src, char *dest, int size, int width, int src_incr, int dest_incr, int step)
{
	if(src && dest && size && width && src_incr && dest_incr && step);
	return(-1);
}
inline int dma_status(void) { return(-1); }
inline void wait_dma(void) { }

#endif /* NETWORK */
#endif /* COLDFIRE */
#endif /* DRIVER_IN_ROM */

#ifndef COLDFIRE
static void blit_copy_1(unsigned short *src_addr, int src_line_add, unsigned short *dst_addr, int dst_line_add, int src_x, int dst_x, int w, int h)
{
	int i, j;
	unsigned short src_word, dst_word, src_mask, dst_mask;
	src_x = 1 << (15 - (src_x & 15));
	dst_x = 1 << (15 - (dst_x & 15));
	for(i = h - 1; i >= 0; i--)
	{
		src_word = *src_addr++;
		dst_word = *dst_addr;
		src_mask = src_x;
		dst_mask = dst_x;
		for(j = w - 1; j >= 0; j--)
		{
			if(src_word & src_mask)
				dst_word |= dst_mask;
			else
				dst_word &= ~dst_mask;			
			if(!(src_mask >>= 1))
			{
				src_mask = 0x8000;
				src_word = *src_addr++;
			}
			if(!(dst_mask >>= 1))
			{
				dst_mask = 0x8000;
				*dst_addr++ = dst_word;
				dst_word = *dst_addr;
			}
		}
		if(dst_mask != 0x8000)
			*dst_addr++ = dst_word;
		else
			dst_addr++;
		src_addr += src_line_add;
		dst_addr += dst_line_add;
	}
}
#endif

static void blit_copy_8(unsigned char *src_addr, int src_line_add, unsigned char *dst_addr, int dst_line_add, int w, int h)
{
	if(!src_line_add && !dst_line_add)
	{
#ifdef DRIVER_IN_ROM
		if((w >= 128) && (h >= 8)
		 && !dma_transfer((char *)src_addr, (char *)dst_addr, w * h, 0, 0, 0, 1));
		else
#endif
			memcpy(dst_addr, src_addr, w * h);
	}
	else
	{
#ifdef DRIVER_IN_ROM
		if((w >= 128)
		 && !dma_transfer((char *)src_addr, (char *)dst_addr, w * h, w, src_line_add + w, dst_line_add + w, 1));
		else
#endif
		{
			int i;
			for(i = h - 1; i >= 0; i--)
			{
				memcpy(dst_addr, src_addr, w);
				src_addr += (src_line_add + w);
				dst_addr += (dst_line_add + w);
			}
		}
	}
}

static void blit_copy_16(unsigned short *src_addr, int src_line_add, unsigned short *dst_addr, int dst_line_add, int w, int h)
{
	if(!src_line_add && !dst_line_add)
	{
#ifdef DRIVER_IN_ROM
		if((((long)src_addr & 0x1L) == 0) && (((long)dst_addr & 0x1L) == 0)
		 && (w >= 64) && (h >= 8)
		 &&	!dma_transfer((char *)src_addr, (char *)dst_addr, (w * h) << 1, 0, 0, 0, 2));
		else
#endif
			memcpy(dst_addr, src_addr, (w << 1) * h);
	}
	else
	{
#ifdef DRIVER_IN_ROM
		if((w >= 64) && (((long)src_addr & 0x1L) == 0) && (((long)dst_addr & 0x1L) == 0)
		 &&	!dma_transfer((char *)src_addr, (char *)dst_addr, (w * h) << 1, w << 1, (src_line_add + w) << 1, (dst_line_add + w) << 1, 2));
		else
#endif
		{
			int i;
			for(i = h - 1; i >= 0; i--)
			{
				memcpy(dst_addr, src_addr, w << 1);
				src_addr += (src_line_add + w);
				dst_addr += (dst_line_add + w);
			}
		}
	}
}

static void blit_copy_32(unsigned long *src_addr, int src_line_add, unsigned long *dst_addr, int dst_line_add, int w, int h)
{
	if(!src_line_add && !dst_line_add)
	{
#ifdef DRIVER_IN_ROM
		if((((long)src_addr & 0x3L) == 0) && (((long)dst_addr & 0x3L) == 0)
		 && (w >= 32) && (h >= 8)
		 && !dma_transfer((char *)src_addr, (char *)dst_addr, (w * h) << 2, 0, 0, 0, 4));
		else
#endif
			memcpy(dst_addr, src_addr, (w << 2) * h);
	}
	else
	{
#ifdef DRIVER_IN_ROM
		if((w >= 32) && (((long)src_addr & 0x3L) == 0) && (((long)dst_addr & 0x3L) == 0)
		 && !dma_transfer((char *)src_addr, (char *)dst_addr, (w * h) << 2, w << 2, (src_line_add + w) << 2, (dst_line_add + w) << 2, 4));
		else
#endif
		{
			int i;
			for(i = h - 1; i >= 0; i--)
			{
				memcpy(dst_addr, src_addr, w << 2);
				src_addr += (src_line_add + w);
				dst_addr += (dst_line_add + w);
			}
		}
	}
}

void blit_copy(unsigned char *src_addr, int src_line_add, unsigned char *dst_addr, int dst_line_add, int w, int h, int bpp)
{
	switch(bpp)
	{
		case 16:
			blit_copy_16((void *)src_addr,src_line_add,(void *)dst_addr,dst_line_add,w,h);
			break;
		case 32:
			blit_copy_32((void *)src_addr,src_line_add,(void *)dst_addr,dst_line_add,w,h);
			break;
		default:
			blit_copy_8(src_addr,src_line_add,dst_addr,dst_line_add,w,h);
			break;
	}
}

int blit_copy_ok()
{
#ifdef DRIVER_IN_ROM
	return(dma_status());
#else
	return(-1);
#endif
}

#ifndef COLDFIRE
static void blit_or_1(unsigned short *src_addr, int src_line_add, unsigned short *dst_addr, int dst_line_add, int src_x, int dst_x, int w, int h)
{
	int i, j;
	unsigned short src_word, dst_word, src_mask, dst_mask;
	src_x = 1 << (15 - (src_x & 15));
	dst_x = 1 << (15 - (dst_x & 15));
	for(i = h - 1; i >= 0; i--)
	{
		src_word = *src_addr++;
		dst_word = *dst_addr;
		src_mask = src_x;
		dst_mask = dst_x;
		for(j = w - 1; j >= 0; j--)
		{
			if(src_word & src_mask)
				dst_word |= dst_mask;
			if(!(src_mask >>= 1))
			{
				src_mask = 0x8000;
				src_word = *src_addr++;
			}
			if(!(dst_mask >>= 1))
			{
				dst_mask = 0x8000;
				*dst_addr++ = dst_word;
				dst_word = *dst_addr;
			}
		}
		if(dst_mask != 0x8000)
			*dst_addr++ = dst_word;
		else
			dst_addr++;
		src_addr += src_line_add;
		dst_addr += dst_line_add;
	}
}
#endif

static void blit_or_8(unsigned char *src_addr, int src_line_add, unsigned char *dst_addr, int dst_line_add, int w, int h)
{
	int i, j;
	for(i = h - 1; i >= 0; i--)
	{
		for(j = w - 1; j >= 0; j--)
			*dst_addr++ |= *src_addr++;
		src_addr += src_line_add;
		dst_addr += dst_line_add;
	}
}

static void blit_or_16(unsigned short *src_addr, int src_line_add, unsigned short *dst_addr, int dst_line_add, int w, int h)
{
	int i, j;
	for(i = h - 1; i >= 0; i--)
	{
		for(j = w - 1; j >= 0; j--)
			*dst_addr++ |= *src_addr++;
		src_addr += src_line_add;
		dst_addr += dst_line_add;
	}
}

static void blit_or_32(unsigned long *src_addr, int src_line_add, unsigned long *dst_addr, int dst_line_add, int w, int h)
{
	int i, j;
	for(i = h - 1; i >= 0; i--)
	{
		for(j = w - 1; j >= 0; j--)
			*dst_addr++ |= *src_addr++;
		src_addr += src_line_add;
		dst_addr += dst_line_add;
	}
}

#ifndef COLDFIRE
static void blit_1(unsigned short *src_addr, int src_line_add, unsigned short *dst_addr, int dst_line_add, int src_x, int dst_x, int w, int h, int operation)
{
	int i, j;
	unsigned short src_word, dst_word, src_mask, dst_mask;
	src_x = 1 << (15 - (src_x & 15));
	dst_x = 1 << (15 - (dst_x & 15));
	for(i = h - 1; i >= 0; i--)
	{
		src_word = *src_addr++;
		dst_word = *dst_addr;
		src_mask = src_x;
		dst_mask = dst_x;
		for(j = w - 1; j >= 0; j--)
		{
			switch(operation)
			{
				case 0: dst_word &= ~dst_mask; break;
				case 1: 
					if(!(src_word & src_mask))
						dst_word &= ~dst_mask;
					break;
				case 2:
					if((src_word & src_mask) && !(dst_word & dst_mask))
						dst_word |= dst_mask;
					else
						dst_word &= ~dst_mask;			
					break;
				case 3:
					if(src_word & src_mask)
						dst_word |= dst_mask;
					else
						dst_word &= ~dst_mask;			
					break;		
				case 4:
					if(src_word & src_mask)
						dst_word &= ~dst_mask;
					break;
				case 5: break;
				case 6:
					if(src_word & src_mask)
						dst_word ^= dst_mask;
					break;
				case 7:
					if(src_word & src_mask)
						dst_word |= dst_mask;
					break;
				case 8:
					if(!((src_word & src_mask) || (dst_word & dst_mask)))
						dst_word |= dst_mask;
					else
						dst_word &= ~dst_mask;	
					break;
				case 9:
					if(!((!(src_word & src_mask) && (dst_word & dst_mask)) || ((src_word & src_mask) && !(dst_word & dst_mask))))
						dst_word |= dst_mask;
					else
						dst_word &= ~dst_mask;	
					break;
				case 10:
					if(!(dst_word & src_mask))
						dst_word |= dst_mask;
					else
						dst_word &= ~dst_mask;			
					break;
				case 11: 
					if((src_word & src_mask) || !(dst_word & dst_mask))
						dst_word |= dst_mask;
					else
						dst_word &= ~dst_mask;			
					break;				
				case 12:
					if(!(src_word & src_mask))
						dst_word |= dst_mask;
					else
						dst_word &= ~dst_mask;			
					break;		
				case 13:
					if(!(src_word & src_mask) || (dst_word & dst_mask))
						dst_word |= dst_mask;
					else
						dst_word &= ~dst_mask;	
					break;
				case 14:
					if(!((src_word & src_mask) && (dst_word & dst_mask)))
						dst_word |= dst_mask;
					else
						dst_word &= ~dst_mask;	
					break;
				case 15: dst_word |= dst_mask; break;
			}
			if(!(src_mask >>= 1))
			{
				src_mask = 0x8000;
				src_word = *src_addr++;
			}
			if(!(dst_mask >>= 1))
			{
				dst_mask = 0x8000;
				*dst_addr++ = dst_word;
				dst_word = *dst_addr;
			}
		}
		if(dst_mask != 0x8000)
			*dst_addr++ = dst_word;
		else
			dst_addr++;
		src_addr += src_line_add;
		dst_addr += dst_line_add;
	}
}
#endif

static void blit_8(unsigned char *src_addr, int src_line_add, unsigned char *dst_addr, int dst_line_add, int w, int h, int operation)
{
	int i, j;
	unsigned char vs, vd;
	for(i = h - 1; i >= 0; i--)
	{
		for(j = w - 1; j >= 0; j--)
		{
			vs = *src_addr++;
			vd = *dst_addr;
			switch(operation)
			{
				case 0: *dst_addr++ = 0; break;
				case 1: *dst_addr++ = vs & vd; break;
				case 2:	*dst_addr++ = vs & ~vd; break;
				case 3:	*dst_addr++ = vs; break;
				case 4: *dst_addr++ = ~vs & vd; break;
				case 5: *dst_addr++ = vd; break;
				case 6: *dst_addr++ = vs ^ vd; break;
				case 7: *dst_addr++ = vs | vd; break;
				case 8: *dst_addr++ = ~(vs | vd); break;
				case 9: *dst_addr++ = ~(vs ^ vd); break;
				case 10: *dst_addr++ = ~vd; break;
				case 11: *dst_addr++ = vs | ~vd; break;
				case 12: *dst_addr++ = ~vs; break;
				case 13: *dst_addr++ = ~vs | vd; break;
				case 14: *dst_addr++ = ~(vs & vd); break;
				case 15: *dst_addr++ = 0xff; break;
			}
		}
		src_addr += src_line_add;
		dst_addr += dst_line_add;
	}
}

static void blit_16(unsigned short *src_addr, int src_line_add, unsigned short *dst_addr, int dst_line_add, int w, int h, int operation)
{
	int i, j;
	unsigned short vs, vd;
	for(i = h - 1; i >= 0; i--)
	{
		for(j = w - 1; j >= 0; j--)
		{
			vs = *src_addr++;
			vd = *dst_addr;
			switch(operation)
			{
				case 0: *dst_addr++ = 0; break;
				case 1: *dst_addr++ = vs & vd; break;
				case 2:	*dst_addr++ = vs & ~vd; break;
				case 3:	*dst_addr++ = vs; break;
				case 4: *dst_addr++ = ~vs & vd; break;
				case 5: *dst_addr++ = vd; break;
				case 6: *dst_addr++ = vs ^ vd; break;
				case 7: *dst_addr++ = vs | vd; break;
				case 8: *dst_addr++ = ~(vs | vd); break;
				case 9: *dst_addr++ = ~(vs ^ vd); break;
				case 10: *dst_addr++ = ~vd; break;
				case 11: *dst_addr++ = vs | ~vd; break;
				case 12: *dst_addr++ = ~vs; break;
				case 13: *dst_addr++ = ~vs | vd; break;
				case 14: *dst_addr++ = ~(vs & vd); break;
				case 15: *dst_addr++ = 0xffff; break;
			}
		}
		src_addr += src_line_add;
		dst_addr += dst_line_add;
	}
}

static void blit_32(unsigned long *src_addr, int src_line_add, unsigned long *dst_addr, int dst_line_add, int w, int h, int operation)
{
	int i, j;
	unsigned long vs, vd;
	for(i = h - 1; i >= 0; i--)
	{
		for(j = w - 1; j >= 0; j--)
		{
			vs = *src_addr++;
			vd = *dst_addr;
			switch(operation)
			{
				case 0: *dst_addr++ = 0; break;
				case 1: *dst_addr++ = vs & vd; break;
				case 2:	*dst_addr++ = vs & ~vd; break;
				case 3:	*dst_addr++ = vs; break;
				case 4: *dst_addr++ = ~vs & vd; break;
				case 5: *dst_addr++ = vd; break;
				case 6: *dst_addr++ = vs ^ vd; break;
				case 7: *dst_addr++ = vs | vd; break;
				case 8: *dst_addr++ = ~(vs | vd); break;
				case 9: *dst_addr++ = ~(vs ^ vd); break;
				case 10: *dst_addr++ = ~vd; break;
				case 11: *dst_addr++ = vs | ~vd; break;
				case 12: *dst_addr++ = ~vs; break;
				case 13: *dst_addr++ = ~vs | vd; break;
				case 14: *dst_addr++ = ~(vs & vd); break;
				case 15: *dst_addr++ = 0xffffff; break;
			}
		}
		src_addr += src_line_add;
		dst_addr += dst_line_add;
	}
}

#ifndef COLDFIRE
static void pan_backwards_copy_1(unsigned short *src_addr, int src_line_add, unsigned short *dst_addr, int dst_line_add, int src_x, int dst_x, int w, int h)
{
	int i, j;
	unsigned short src_word, dst_word, src_mask, dst_mask;
	src_x = 1 << (15 - ((src_x + w) & 15));
	dst_x = 1 << (15 - ((dst_x + w) & 15));
	for(i = h - 1; i >= 0; i--)
	{
		src_word = *--src_addr;
		dst_word = *--dst_addr;
		src_mask = src_x;
		dst_mask = dst_x;
		for(j = w - 1; j >= 0; j--)
		{
			if(!(src_mask <<= 1))
			{
				src_mask = 0x0001;
				src_word = *--src_addr;
			}
			if(!(dst_mask <<= 1))
			{
				dst_mask = 0x0001;
				*dst_addr = dst_word;
				dst_word = *--dst_addr;
			}
			if(src_word & src_mask)
				dst_word |= dst_mask;
			else
				dst_word &= ~dst_mask;			
		}
		if(dst_mask != 0x0001)
			*dst_addr = dst_word;
		src_addr += src_line_add;
		dst_addr += dst_line_add;
  }
}
#endif

static void pan_backwards_copy_8(unsigned char *src_addr, int src_line_add, unsigned char *dst_addr, int dst_line_add, int w, int h)
{
	int i, j;
	for(i = h - 1; i >= 0; i--)
	{
		for(j = w - 1; j >= 0; j--)
			*--dst_addr = *--src_addr;
		src_addr += src_line_add;
		dst_addr += dst_line_add;
  }
}

static void pan_backwards_copy_16(unsigned short *src_addr, int src_line_add, unsigned short *dst_addr, int dst_line_add, int w, int h)
{
	int i, j;
	for(i = h - 1; i >= 0; i--)
	{
		for(j = w - 1; j >= 0; j--)
			*--dst_addr = *--src_addr;
		src_addr += src_line_add;
		dst_addr += dst_line_add;
  }
}

static void pan_backwards_copy_32(unsigned long *src_addr, int src_line_add, unsigned long *dst_addr, int dst_line_add, int w, int h)
{
	int i, j;
	for(i = h - 1; i >= 0; i--)
	{
		for(j = w - 1; j >= 0; j--)
			*--dst_addr = *--src_addr;
		src_addr += src_line_add;
		dst_addr += dst_line_add;
  }
}

#ifndef COLDFIRE
static void pan_backwards_or_1(unsigned short *src_addr, int src_line_add, unsigned short *dst_addr, int dst_line_add, int src_x, int dst_x, int w, int h)
{
	int i, j;
	unsigned short src_word, dst_word, src_mask, dst_mask;
	src_x = 1 << (15 - ((src_x + w) & 15));
	dst_x = 1 << (15 - ((dst_x + w) & 15));
	for(i = h - 1; i >= 0; i--)
	{
		src_word = *--src_addr;
		dst_word = *--dst_addr;
		src_mask = src_x;
		dst_mask = dst_x;
		for(j = w - 1; j >= 0; j--)
		{
			if(!(src_mask <<= 1))
			{
				src_mask = 0x0001;
				src_word = *--src_addr;
			}
			if(!(dst_mask <<= 1))
			{
				dst_mask = 0x0001;
				*dst_addr = dst_word;
				dst_word = *--dst_addr;
			}
			if(src_word & src_mask)
				dst_word |= dst_mask;
		}
		if(dst_mask != 0x0001)
			*dst_addr = dst_word;
		src_addr += src_line_add;
		dst_addr += dst_line_add;
	}
}
#endif

static void pan_backwards_or_8(unsigned char *src_addr, int src_line_add, unsigned char *dst_addr, int dst_line_add, int w, int h)
{
	int i, j;
	for(i = h - 1; i >= 0; i--)
	{
		for(j = w - 1; j >= 0; j--)
			*--dst_addr |= *--src_addr;
		src_addr += src_line_add;
		dst_addr += dst_line_add;
	}
}

static void pan_backwards_or_16(unsigned short *src_addr, int src_line_add, unsigned short *dst_addr, int dst_line_add, int w, int h)
{
	int i, j;
	for(i = h - 1; i >= 0; i--)
	{
		for(j = w - 1; j >= 0; j--)
			*--dst_addr |= *--src_addr;
		src_addr += src_line_add;
		dst_addr += dst_line_add;
	}
}

static void pan_backwards_or_32(unsigned long *src_addr, int src_line_add, unsigned long *dst_addr, int dst_line_add, int w, int h)
{
	int i, j;
	for(i = h - 1; i >= 0; i--)
	{
		for(j = w - 1; j >= 0; j--)
			*--dst_addr |= *--src_addr;
		src_addr += src_line_add;
		dst_addr += dst_line_add;
	}
}

#ifndef COLDFIRE
static void pan_backwards_1(unsigned short *src_addr, int src_line_add, unsigned short *dst_addr, int dst_line_add, int src_x, int dst_x, int w, int h, int operation)
{
	int i, j;
	unsigned short src_word, dst_word, src_mask, dst_mask;
	src_x = 1 << (15 - ((src_x + w) & 15));
	dst_x = 1 << (15 - ((dst_x + w) & 15));
	for(i = h - 1; i >= 0; i--)
	{
		src_word = *--src_addr;
		dst_word = *--dst_addr;
		src_mask = src_x;
		dst_mask = dst_x;
		for(j = w - 1; j >= 0; j--)
		{
			if(!(src_mask <<= 1))
			{
				src_mask = 0x0001;
				src_word = *--src_addr;
			}
			if(!(dst_mask <<= 1))
			{
				dst_mask = 0x0001;
				*dst_addr = dst_word;
				dst_word = *--dst_addr;
			}
			switch(operation)
			{
				case 0: dst_word &= ~dst_mask; break;
				case 1: 
					if(!(src_word & src_mask))
						dst_word &= ~dst_mask;
					break;
				case 2:
					if((src_word & src_mask) && !(dst_word & dst_mask))
						dst_word |= dst_mask;
					else
						dst_word &= ~dst_mask;			
					break;
				case 3:
					if(src_word & src_mask)
						dst_word |= dst_mask;
					else
						dst_word &= ~dst_mask;			
					break;		
				case 4:
					if(src_word & src_mask)
						dst_word &= ~dst_mask;
					break;
				case 5: break;
				case 6:
					if(src_word & src_mask)
						dst_word ^= dst_mask;
					break;
				case 7:
					if(src_word & src_mask)
						dst_word |= dst_mask;
					break;
				case 8:
					if(!((src_word & src_mask) || (dst_word & dst_mask)))
						dst_word |= dst_mask;
					else
						dst_word &= ~dst_mask;	
					break;
				case 9:
					if(!((!(src_word & src_mask) && (dst_word & dst_mask)) || ((src_word & src_mask) && !(dst_word & dst_mask))))
						dst_word |= dst_mask;
					else
						dst_word &= ~dst_mask;	
					break;
				case 10:
					if(!(dst_word & src_mask))
						dst_word |= dst_mask;
					else
						dst_word &= ~dst_mask;			
					break;
				case 11: 
					if((src_word & src_mask) || !(dst_word & dst_mask))
						dst_word |= dst_mask;
					else
						dst_word &= ~dst_mask;			
					break;				
				case 12:
					if(!(src_word & src_mask))
						dst_word |= dst_mask;
					else
						dst_word &= ~dst_mask;			
					break;		
				case 13:
					if(!(src_word & src_mask) || (dst_word & dst_mask))
						dst_word |= dst_mask;
					else
						dst_word &= ~dst_mask;	
					break;
				case 14:
					if(!((src_word & src_mask) && (dst_word & dst_mask)))
						dst_word |= dst_mask;
					else
						dst_word &= ~dst_mask;	
					break;
				case 15: dst_word |= dst_mask; break;
			}
		}
		if(dst_mask != 0x0001)
			*dst_addr = dst_word;
		src_addr += src_line_add;
		dst_addr += dst_line_add;
	}
}
#endif

static void pan_backwards_8(unsigned char *src_addr, int src_line_add, unsigned char *dst_addr, int dst_line_add, int w, int h, int operation)
{
	int i, j;
	unsigned char vs, vd;
	for(i = h - 1; i >= 0; i--)
	{
		for(j = w - 1; j >= 0; j--)
		{
			vs = *--src_addr;
			vd = *--dst_addr;
			switch(operation)
			{
				case 0: *dst_addr = 0; break;
				case 1:	*dst_addr = vs & vd; break;
				case 2:	*dst_addr = vs & ~vd;	break;
				case 3:	*dst_addr = vs;	break;
				case 4:	*dst_addr = ~vs & vd;	break;
				case 5:	*dst_addr = vd;	break;
				case 6:	*dst_addr = vs ^ vd; break;
				case 7:	*dst_addr = vs | vd; break;
				case 8:	*dst_addr = ~(vs | vd);	break;
				case 9:	*dst_addr = ~(vs ^ vd);	break;
				case 10: *dst_addr = ~vd; break;
				case 11: *dst_addr = vs | ~vd; break;
				case 12: *dst_addr = ~vs; break;
				case 13: *dst_addr = ~vs | vd; break;
				case 14: *dst_addr = ~(vs & vd); break;
				case 15: *dst_addr = 0xff; break;
			}
		}
		src_addr += src_line_add;
		dst_addr += dst_line_add;
	}
}

static void pan_backwards_16(unsigned short *src_addr, int src_line_add, unsigned short *dst_addr, int dst_line_add, int w, int h, int operation)
{
	int i, j;
	unsigned short vs, vd;
	for(i = h - 1; i >= 0; i--)
	{
		for(j = w - 1; j >= 0; j--)
		{
			vs = *--src_addr;
			vd = *--dst_addr;
			switch(operation)
			{
				case 0: *dst_addr = 0; break;
				case 1:	*dst_addr = vs & vd; break;
				case 2:	*dst_addr = vs & ~vd;	break;
				case 3:	*dst_addr = vs;	break;
				case 4:	*dst_addr = ~vs & vd;	break;
				case 5:	*dst_addr = vd;	break;
				case 6:	*dst_addr = vs ^ vd; break;
				case 7:	*dst_addr = vs | vd; break;
				case 8:	*dst_addr = ~(vs | vd);	break;
				case 9:	*dst_addr = ~(vs ^ vd);	break;
				case 10: *dst_addr = ~vd; break;
				case 11: *dst_addr = vs | ~vd; break;
				case 12: *dst_addr = ~vs; break;
				case 13: *dst_addr = ~vs | vd; break;
				case 14: *dst_addr = ~(vs & vd); break;
				case 15: *dst_addr = 0xffff; break;
			}
		}
		src_addr += src_line_add;
		dst_addr += dst_line_add;
	}
}

static void pan_backwards_32(unsigned long *src_addr, int src_line_add, unsigned long *dst_addr, int dst_line_add, int w, int h, int operation)
{
	int i, j;
	unsigned long vs, vd;
	for(i = h - 1; i >= 0; i--)
	{
		for(j = w - 1; j >= 0; j--)
		{
			vs = *--src_addr;
			vd = *--dst_addr;
			switch(operation)
			{
				case 0: *dst_addr = 0; break;
				case 1:	*dst_addr = vs & vd; break;
				case 2:	*dst_addr = vs & ~vd;	break;
				case 3:	*dst_addr = vs;	break;
				case 4:	*dst_addr = ~vs & vd;	break;
				case 5:	*dst_addr = vd;	break;
				case 6:	*dst_addr = vs ^ vd; break;
				case 7:	*dst_addr = vs | vd; break;
				case 8:	*dst_addr = ~(vs | vd);	break;
				case 9:	*dst_addr = ~(vs ^ vd);	break;
				case 10: *dst_addr = ~vd; break;
				case 11: *dst_addr = vs | ~vd; break;
				case 12: *dst_addr = ~vs; break;
				case 13: *dst_addr = ~vs | vd; break;
				case 14: *dst_addr = ~(vs & vd); break;
				case 15: *dst_addr = 0xffffff; break;
			}
		}
		src_addr += src_line_add;
		dst_addr += dst_line_add;
	}
}

#ifndef COLDFIRE
static void replace_1(unsigned short *src_addr, int src_line_add, unsigned short *dst_addr, int dst_line_add, int src_x, int dst_x, int w, int h, unsigned char foreground, unsigned char background)
{
	int i, j;
	unsigned short expand_word, dst_word, src_mask, dst_mask;
	src_x = 1 << (15 - (src_x & 15));
	dst_x = 1 << (15 - (dst_x & 15));
	for(i = h - 1; i >= 0; i--)
	{
		expand_word = *src_addr++;
		dst_word = *dst_addr;
		src_mask = src_x;
		dst_mask = dst_x;
		for(j = w - 1; j >= 0; j--)
		{
			if(expand_word & src_mask)
			{
				if(foreground)
					dst_word |= dst_mask;
				else
					dst_word &= ~dst_mask;
			}
			else
			{
				if(background)
					dst_word |= dst_mask;
				else
					dst_word &= ~dst_mask;			
			}
			if(!(src_mask >>= 1))
			{
				src_mask = 0x8000;
				expand_word = *src_addr++;
			}
			if(!(dst_mask >>= 1))
			{
				dst_mask = 0x8000;
				*dst_addr++ = dst_word;
				dst_word = *dst_addr;
			}
		}
		if(dst_mask != 0x8000)
			*dst_addr++ = dst_word;
		else
			dst_addr++;
		src_addr += src_line_add;
		dst_addr += dst_line_add;
	}
}
#endif

static void replace_8(unsigned short *src_addr, int src_line_add, unsigned char *dst_addr, int dst_line_add, int x, int w, int h, unsigned char foreground, unsigned char background)
{
	int i, j;
	unsigned short expand_word, mask;
	x = 1 << (15 - (x & 15));
	for(i = h - 1; i >= 0; i--)
	{
		expand_word = *src_addr++;
		mask = x;
		for(j = w - 1; j >= 0; j--)
		{
			if(expand_word & mask)
				*dst_addr++ = foreground;
			else
				*dst_addr++ = background;
			if(!(mask >>= 1))
			{
				mask = 0x8000;
				expand_word = *src_addr++;
			}
		}
		src_addr += src_line_add;
		dst_addr += dst_line_add;
	}
}

static void replace_16(unsigned short *src_addr, int src_line_add, unsigned short *dst_addr, int dst_line_add, int x, int w, int h, unsigned short foreground, unsigned short background)
{
	int i, j;
	unsigned short expand_word, mask;
	x = 1 << (15 - (x & 15));
	for(i = h - 1; i >= 0; i--)
	{
		expand_word = *src_addr++;
		mask = x;
		for(j = w - 1; j >= 0; j--)
		{
			if(expand_word & mask)
				*dst_addr++ = foreground;
			else
				*dst_addr++ = background;
			if(!(mask >>= 1))
			{
				mask = 0x8000;
				expand_word = *src_addr++;
			}
		}
		src_addr += src_line_add;
		dst_addr += dst_line_add;
	}
}

static void replace_32(unsigned short *src_addr, int src_line_add, unsigned long *dst_addr, int dst_line_add, int x, int w, int h, unsigned long foreground, unsigned long background)
{
	int i, j;
	unsigned short expand_word, mask;
	x = 1 << (15 - (x & 15));
	for(i = h - 1; i >= 0; i--)
	{
		expand_word = *src_addr++;
		mask = x;
		for(j = w - 1; j >= 0; j--)
		{
			if(expand_word & mask)
				*dst_addr++ = foreground;
			else
				*dst_addr++ = background;
			if(!(mask >>= 1))
			{
				mask = 0x8000;
				expand_word = *src_addr++;
			}
		}
		src_addr += src_line_add;
		dst_addr += dst_line_add;
	}
}

#ifndef COLDFIRE
static void transparent_1(unsigned short *src_addr, int src_line_add, unsigned short *dst_addr, int dst_line_add, int src_x, int dst_x, int w, int h, unsigned char foreground, unsigned char background)
{
	int i, j;
	unsigned short expand_word, dst_word, src_mask, dst_mask;
	src_x = 1 << (15 - (src_x & 15));
	dst_x = 1 << (15 - (dst_x & 15));
	for(i = h - 1; i >= 0; i--)
	{
		expand_word = *src_addr++;
		dst_word = *dst_addr;
		src_mask = src_x;
		dst_mask = dst_x;
		for(j = w - 1; j >= 0; j--)
		{
			if(expand_word & src_mask)
			{
				if(foreground)
					dst_word |= dst_mask;
				else
					dst_word &= ~dst_mask;
			}
			if(!(src_mask >>= 1))
			{
				src_mask = 0x8000;
				expand_word = *src_addr++;
			}
			if(!(dst_mask >>= 1))
			{
				dst_mask = 0x8000;
				*dst_addr++ = dst_word;
				dst_word = *dst_addr;
			}
		}
		if(dst_mask != 0x8000)
			*dst_addr++ = dst_word;
		else
			dst_addr++;
		src_addr += src_line_add;
		dst_addr += dst_line_add;
	}
}
#endif

static void transparent_8(unsigned short *src_addr, int src_line_add, unsigned char *dst_addr, int dst_line_add, int x, int w, int h, unsigned char foreground, unsigned char background)
{
	int i, j;
	unsigned short expand_word, mask;
	x = 1 << (15 - (x & 15));
	for(i = h - 1; i >= 0; i--)
	{
		expand_word = *src_addr++;
		mask = x;
		for(j = w - 1; j >= 0; j--)
		{
			if(expand_word & mask)
				*dst_addr++ = foreground;
			else
				dst_addr++;
			if(!(mask >>= 1))
			{
				mask = 0x8000;
				expand_word = *src_addr++;
			}
		}
		src_addr += src_line_add;
		dst_addr += dst_line_add;
	}
}

static void transparent_16(unsigned short *src_addr, int src_line_add, unsigned short *dst_addr, int dst_line_add, int x, int w, int h, unsigned short foreground, unsigned short background)
{
	int i, j;
	unsigned short expand_word, mask;
	x = 1 << (15 - (x & 15));
	for(i = h - 1; i >= 0; i--)
	{
		expand_word = *src_addr++;
		mask = x;
		for(j = w - 1; j >= 0; j--)
		{
			if(expand_word & mask)
				*dst_addr++ = foreground;
			else
				dst_addr++;
			if(!(mask >>= 1))
			{
				mask = 0x8000;
				expand_word = *src_addr++;
			}
		}
		src_addr += src_line_add;
		dst_addr += dst_line_add;
	}
}

static void transparent_32(unsigned short *src_addr, int src_line_add, unsigned long *dst_addr, int dst_line_add, int x, int w, int h, unsigned long foreground, unsigned long background)
{
	int i, j;
	unsigned short expand_word, mask;
	x = 1 << (15 - (x & 15));
	for(i = h - 1; i >= 0; i--)
	{
		expand_word = *src_addr++;
		mask = x;
		for(j = w - 1; j >= 0; j--)
		{
			if(expand_word & mask)
				*dst_addr++ = foreground;
			else
				dst_addr++;
			if(!(mask >>= 1))
			{
				mask = 0x8000;
				expand_word = *src_addr++;
			}
		}
		src_addr += src_line_add;
		dst_addr += dst_line_add;
	}
}

#ifndef COLDFIRE
static void xor_1(unsigned short *src_addr, int src_line_add, unsigned short *dst_addr, int dst_line_add, int src_x, int dst_x, int w, int h, unsigned char foreground, unsigned char background)
{
	int i, j;
	unsigned short expand_word, dst_word, src_mask, dst_mask;
	src_x = 1 << (15 - (src_x & 15));
	dst_x = 1 << (15 - (dst_x & 15));
	for(i = h - 1; i >= 0; i--)
	{
		expand_word = *src_addr++;
		dst_word = *dst_addr;
		src_mask = src_x;
		dst_mask = dst_x;
		for(j = w - 1; j >= 0; j--)
		{
			if(expand_word & src_mask)
				dst_word ^= dst_mask;
			if(!(src_mask >>= 1))
			{
				src_mask = 0x8000;
				expand_word = *src_addr++;
			}
			if(!(dst_mask >>= 1))
			{
				dst_mask = 0x8000;
				*dst_addr++ = dst_word;
				dst_word = *dst_addr;
			}
		}
		if(dst_mask != 0x8000)
			*dst_addr++ = dst_word;
		else
			dst_addr++;
		src_addr += src_line_add;
		dst_addr += dst_line_add;
	}
}
#endif

static void xor_8(unsigned short *src_addr, int src_line_add, unsigned char *dst_addr, int dst_line_add, int x, int w, int h, unsigned char foreground, unsigned char background)
{
	int i, j, v;
	unsigned short expand_word, mask;
	x = 1 << (15 - (x & 15));
	for(i = h - 1; i >= 0; i--)
	{
		expand_word = *src_addr++;
		mask = x;
		for(j = w - 1; j >= 0; j--)
		{
			if(expand_word & mask)
			{
				v = ~*dst_addr;
				*dst_addr++ = v;
			}
			else
				dst_addr++;
			if(!(mask >>= 1))
			{
				mask = 0x8000;
				expand_word = *src_addr++;
			}
		}
		src_addr += src_line_add;
		dst_addr += dst_line_add;
	}
}

static void xor_16(unsigned short *src_addr, int src_line_add, unsigned short *dst_addr, int dst_line_add, int x, int w, int h, unsigned short foreground, unsigned short background)
{
	int i, j, v;
	unsigned short expand_word, mask;
	x = 1 << (15 - (x & 15));
	for(i = h - 1; i >= 0; i--)
	{
		expand_word = *src_addr++;
		mask = x;
		for(j = w - 1; j >= 0; j--)
		{
			if(expand_word & mask)
			{
				v = ~*dst_addr;
				*dst_addr++ = v;
			}
			else
				dst_addr++;
			if(!(mask >>= 1))
			{
				mask = 0x8000;
				expand_word = *src_addr++;
			}
		}
		src_addr += src_line_add;
		dst_addr += dst_line_add;
	}
}

static void xor_32(unsigned short *src_addr, int src_line_add, unsigned long *dst_addr, int dst_line_add, int x, int w, int h, unsigned long foreground, unsigned long background)
{
	int i, j, v;
	unsigned short expand_word, mask;
	x = 1 << (15 - (x & 15));
	for(i = h - 1; i >= 0; i--)
	{
		expand_word = *src_addr++;
		mask = x;
		for(j = w - 1; j >= 0; j--)
		{
			if(expand_word & mask)
			{
				v = ~*dst_addr;
				*dst_addr++ = v;
			}
			else
				dst_addr++;
			if(!(mask >>= 1))
			{
				mask = 0x8000;
				expand_word = *src_addr++;
			}
		}
		src_addr += src_line_add;
		dst_addr += dst_line_add;
	}
}

#ifndef COLDFIRE
static void revtransp_1(unsigned short *src_addr, int src_line_add, unsigned short *dst_addr, int dst_line_add, int src_x, int dst_x, int w, int h, unsigned char foreground, unsigned char background)
{
	int i, j;
	unsigned short expand_word, dst_word, src_mask, dst_mask;
	src_x = 1 << (15 - (src_x & 15));
	dst_x = 1 << (15 - (dst_x & 15));
	for(i = h - 1; i >= 0; i--)
	{
		expand_word = *src_addr++;
		dst_word = *dst_addr;
		src_mask = src_x;
		dst_mask = dst_x;
		for(j = w - 1; j >= 0; j--)
		{
			if(!(expand_word & src_mask))
			{
				if(foreground)
					dst_word |= dst_mask;
				else
					dst_word &= ~dst_mask;
			}
			if(!(src_mask >>= 1))
			{
				src_mask = 0x8000;
				expand_word = *src_addr++;
			}
			if(!(dst_mask >>= 1))
			{
				dst_mask = 0x8000;
				*dst_addr++ = dst_word;
				dst_word = *dst_addr;
			}
		}
		if(dst_mask != 0x8000)
			*dst_addr++ = dst_word;
		else
			dst_addr++;
		src_addr += src_line_add;
		dst_addr += dst_line_add;
	}
}
#endif

static void revtransp_8(unsigned short *src_addr, int src_line_add, unsigned char *dst_addr, int dst_line_add, int x, int w, int h, unsigned char foreground, unsigned char background)
{
	int i, j;
	unsigned short expand_word, mask;
	x = 1 << (15 - (x & 15));
	for(i = h - 1; i >= 0; i--)
	{
		expand_word = *src_addr++;
		mask = x;
		for(j = w - 1; j >= 0; j--)
		{
			if(!(expand_word & mask))
				*dst_addr++ = foreground;
			else
				dst_addr++;
			if(!(mask >>= 1))
			{
				mask = 0x8000;
				expand_word = *src_addr++;
			}
		}
		src_addr += src_line_add;
		dst_addr += dst_line_add;
	}
}

static void revtransp_16(unsigned short *src_addr, int src_line_add, unsigned short *dst_addr, int dst_line_add, int x, int w, int h, unsigned short foreground, unsigned short background)
{
	int i, j;
	unsigned short expand_word, mask;
	x = 1 << (15 - (x & 15));
	for(i = h - 1; i >= 0; i--)
	{
		expand_word = *src_addr++;
		mask = x;
		for(j = w - 1; j >= 0; j--)
		{
			if(!(expand_word & mask))
				*dst_addr++ = foreground;
			else
				dst_addr++;
			if(!(mask >>= 1))
			{
				mask = 0x8000;
				expand_word = *src_addr++;
			}
		}
		src_addr += src_line_add;
		dst_addr += dst_line_add;
	}
}

static void revtransp_32(unsigned short *src_addr, int src_line_add, unsigned long *dst_addr, int dst_line_add, int x, int w, int h, unsigned long foreground, unsigned long background)
{
	int i, j;
	unsigned short expand_word, mask;
	x = 1 << (15 - (x & 15));
	for(i = h - 1; i >= 0; i--)
	{
		expand_word = *src_addr++;
		mask = x;
		for(j = w - 1; j >= 0; j--)
		{
			if(!(expand_word & mask))
				*dst_addr++ = foreground;
			else
				dst_addr++;
			if(!(mask >>= 1))
			{
				mask = 0x8000;
				expand_word = *src_addr++;
			}
		}
		src_addr += src_line_add;
		dst_addr += dst_line_add;
	}
}

void update_mono(void)
{
	info_fvdi->update_mono = 1;  /* VBL drawing flag */
}

#ifndef COLDFIRE
long CDECL c_read_pixel_1(Virtual *vwk, MFDB *src, long x, long y)
{
	Workstation *wk;
	long offset, offset_x = (x >> 4) << 1;
	unsigned long color;
	wk = vwk->real_address;
	if(!src || !src->address || (src->address == wk->screen.mfdb.address))
	{
		offset = ((long)wk->screen.wrap * y) + offset_x;
		color = (unsigned long)*(unsigned char *)((unsigned long)wk->screen.mfdb.address + (unsigned long)offset);
	}
	else
	{
		offset = ((src->wdwidth * 2 * src->bitplanes) * y) + offset_x;
		color = (unsigned long)*(unsigned short *)((unsigned long)src->address + (unsigned long)offset);
	}
	return((long)(color >> (15 - (x & 15))) & 1);
}

long CDECL c_write_pixel_1(Virtual *vwk, MFDB *dst, long x, long y, long color)
{
	Workstation *wk;
	long offset, mask;
	short *p;
	if((long)vwk & 1)
		return 0;
	wk = vwk->real_address;
	mask = 1 << (15 - (x & 15));
	x = (x >> 4) << 1;
	if(!dst || !dst->address || (dst->address == wk->screen.mfdb.address))
	{
		offset = ((long)wk->screen.wrap * y) + x;
		p = (unsigned short *)((unsigned long)wk->screen.mfdb.address + (unsigned long)offset);
		if(color)
			*p |= mask;
		else
			*p &= ~mask;
	}
	else
	{
		offset = ((dst->wdwidth * 2 * dst->bitplanes) * y) + x;
		p = (unsigned short *)((unsigned long)dst->address + (unsigned long)offset);
		if(color)
			*p |= mask;
		else
			*p &= ~mask;		
	}
	info_fvdi->update_mono = 1;
	return(1);
}
#endif

long CDECL c_read_pixel_8(Virtual *vwk, MFDB *src, long x, long y)
{
	Workstation *wk;
	long offset;
	unsigned long color;
	wk = vwk->real_address;
	if(!src || !src->address || (src->address == wk->screen.mfdb.address))
	{
		if(info_fvdi->par != NULL) /* Videl driver */
		{
#ifdef DRIVER_IN_ROM
			wait_dma();
#endif
			info_fvdi->fbops->fb_sync(info_fvdi);
		}
		offset = (long)wk->screen.wrap * y + x;
		color = (unsigned long)*(unsigned char *)((unsigned long)wk->screen.mfdb.address + (unsigned long)offset);
	}
	else
	{
		offset = (src->wdwidth * 2 * src->bitplanes) * y + x;
		color = (unsigned long)*(unsigned char *)((unsigned long)src->address + (unsigned long)offset);
	}
	return((long)color);
}

long CDECL c_write_pixel_8(Virtual *vwk, MFDB *dst, long x, long y, long color)
{
	Workstation *wk;
	long offset;
	if((long)vwk & 1)
		return 0;
	wk = vwk->real_address;
	if(!dst || !dst->address || (dst->address == wk->screen.mfdb.address))
	{
		if(info_fvdi->par == NULL) /* Videl driver */
		{
			offset = (long)wk->screen.wrap * y + x;
			*(unsigned char *)((unsigned long)wk->screen.mfdb.address + (unsigned long)offset) = (unsigned char)color;
			return(1);
		}
#ifdef DRIVER_IN_ROM
		wait_dma();
#endif
		info_fvdi->fbops->SetupForSolidFill(info_fvdi,(int)color,3,0xffffffff);
		info_fvdi->fbops->SubsequentSolidHorVertLine(info_fvdi,(int)x,(int)y,1,DEGREES_0);
		return(1);
	}
	else
	{
		offset = (dst->wdwidth * 2 * dst->bitplanes) * y + x;
		*(unsigned char *)((unsigned long)dst->address + (unsigned long)offset) = (unsigned char)color;
	}
	return(1);
}

long CDECL c_read_pixel_16(Virtual *vwk, MFDB *src, long x, long y)
{
	Workstation *wk;
	long offset;
	unsigned long color;
	wk = vwk->real_address;
	if(!src || !src->address || (src->address == wk->screen.mfdb.address))
	{
		if(info_fvdi->par != NULL) /* Videl driver */
		{
#ifdef DRIVER_IN_ROM
			wait_dma();
#endif
			info_fvdi->fbops->fb_sync(info_fvdi);
		}
		offset = (long)wk->screen.wrap * y + x * sizeof(short);
		color = (unsigned long)*(unsigned short *)((unsigned long)wk->screen.mfdb.address + (unsigned long)offset);
	}
	else
	{
		offset = (src->wdwidth * 2 * src->bitplanes) * y + x * sizeof(short);
		color = (unsigned long)*(unsigned short *)((unsigned long)src->address + (unsigned long)offset);
	}
	return((long)color);
}

long CDECL c_write_pixel_16(Virtual *vwk, MFDB *dst, long x, long y, long color)
{
	Workstation *wk;
	long offset;
	if((long)vwk & 1)
		return 0;
	wk = vwk->real_address;
	if(!dst || !dst->address || (dst->address == wk->screen.mfdb.address))
	{
		if(info_fvdi->par == NULL) /* Videl driver */
		{
			offset = (long)wk->screen.wrap * y + x * sizeof(short);
			*(unsigned short *)((unsigned long)wk->screen.mfdb.address + (unsigned long)offset) = (unsigned short)color;
			return(1);
		}
#ifdef DRIVER_IN_ROM
		wait_dma();
#endif
		info_fvdi->fbops->SetupForSolidFill(info_fvdi,(int)color,3,0xffffffff);
		info_fvdi->fbops->SubsequentSolidHorVertLine(info_fvdi,(int)x,(int)y,1,DEGREES_0);
		return(1);
	}
	else
	{
		offset = (dst->wdwidth * 2 * dst->bitplanes) * y + x * sizeof(short);
		*(unsigned short *)((unsigned long)dst->address + (unsigned long)offset) = (unsigned short)color;
	}
	return(1);
}

long CDECL c_read_pixel_32(Virtual *vwk, MFDB *src, long x, long y)
{
	Workstation *wk;
	long offset;
	unsigned long color;
	wk = vwk->real_address;
	if(!src || !src->address || (src->address == wk->screen.mfdb.address))
	{
		if(info_fvdi->par != NULL) /* Videl driver */
		{
#ifdef DRIVER_IN_ROM
			wait_dma();
#endif
			info_fvdi->fbops->fb_sync(info_fvdi);
		}
		offset = (long)wk->screen.wrap * y + x * sizeof(long);
		color = (unsigned long)*(unsigned long *)((unsigned long)wk->screen.mfdb.address + (unsigned long)offset);
	}
	else
	{
		offset = (src->wdwidth * 2 * src->bitplanes) * y + x * sizeof(long);
		color = (unsigned long)*(unsigned long *)((unsigned long)src->address + (unsigned long)offset);
	}
	return((long)color);
}

long CDECL c_write_pixel_32(Virtual *vwk, MFDB *dst, long x, long y, long color)
{
	Workstation *wk;
	long offset;
	if((long)vwk & 1)
		return 0;
	wk = vwk->real_address;
	if(!dst || !dst->address || (dst->address == wk->screen.mfdb.address))
	{
		if(info_fvdi->par == NULL) /* Videl driver */
		{
			offset = (long)wk->screen.wrap * y + x * sizeof(long);
			*(unsigned long *)((unsigned long)wk->screen.mfdb.address + (unsigned long)offset) = (unsigned long)color;
			return(1);
		}
#ifdef DRIVER_IN_ROM
		wait_dma();
#endif
		info_fvdi->fbops->SetupForSolidFill(info_fvdi,(int)color,3,0xffffffff);
		info_fvdi->fbops->SubsequentSolidHorVertLine(info_fvdi,(int)x,(int)y,1,DEGREES_0);
		return(1);
	}
	else
	{
		offset = (dst->wdwidth * 2 * dst->bitplanes) * y + x * sizeof(long);
		*(unsigned long *)((unsigned long)dst->address + (unsigned long)offset) = (unsigned long)color;
	}
	return(1);
}

long CDECL c_mouse_draw(Workstation *wk, long x, long y, Mouse *mouse)
{
	static long hotspot_x,hotspot_y;
	unsigned long foreground,background,colour;
	long xoffset, yoffset;
	struct fb_info *info= info_fvdi;
	if(info->par == NULL) /* Videl driver */
		return(1);
	xoffset = (long)info->var.xoffset; /* virtual screen */
	yoffset = (long)info->var.yoffset;
	/* Need to mask x since it contains old operation in high bits */
	x &= 0xffff;
	x -= hotspot_x;
	if(x < xoffset)
		x = xoffset;
	else if(x > (info->var.xres + xoffset))
		x = info->var.xres + xoffset;
	y -= hotspot_y;
	if(y < yoffset)
		y = yoffset;
	else if(y > (info->var.yres + yoffset))
		y = info->var.yres + yoffset;
	switch((long)mouse)
	{
		case 0: /* move shown */
		case 4: /* move shown */
		case 3: /* show */
			info->fbops->SetCursorPosition(info,(int)(x-xoffset),(int)(y-yoffset));
			info->fbops->ShowCursor(info);
			break;
		case 1: /* move hidden */
		case 5: /* move hidden */
			info->fbops->SetCursorPosition(info,(int)(x-xoffset),(int)(y-yoffset));
		case 2: /* hide */
			info->fbops->HideCursor(info);
			break;
		case 6:
		case 7:
			info->fbops->SetCursorPosition(info,(int)(x-xoffset),(int)(y-yoffset));
			break;
		default:
			colour = *(unsigned long *)&mouse->colour;
			/* mouse is always in 16M colours on Radeon so use default palette */
			foreground = ((((unsigned long)colours[((short)colour)*3])*255/1000)<<16)
			           + ((((unsigned long)colours[((short)colour)*3+1])*255/1000)<<8)
			           + (((unsigned long)colours[((short)colour)*3+2])*255/1000);
			background = ((((unsigned long)colours[(colour>>16)*3])*255/1000)<<16)
			           + ((((unsigned long)colours[(colour>>16)*3+1])*255/1000)<<8)
			           + (((unsigned long)colours[(colour>>16)*3+2])*255/1000);
			info->fbops->LoadCursorImage(info,(unsigned short *)&mouse->mask,(unsigned short *)&mouse->data, (int)zoom_mouse);
			info->fbops->SetCursorPosition(info,(int)(x-xoffset),(int)(y-yoffset));
			info->fbops->SetCursorColors(info,(int)background,(int)foreground);
			hotspot_x = (long)mouse->hotspot.x * (long)zoom_mouse;
			hotspot_y = (long)mouse->hotspot.y * (long)zoom_mouse;
			break;
	}
	return(1);
}

long CDECL c_expand_area(Virtual *vwk, MFDB *src, long src_x, long src_y, MFDB *dst, long dst_x, long dst_y, long w, long h, long operation, long colour)
{
	Workstation *wk;
	short *src_addr;
	void *dst_addr;
	long foreground, background;
	int src_wrap, dst_wrap;
	int src_line_add, dst_line_add;
	unsigned long src_pos, dst_pos;
	int to_screen, bpp;
	struct fb_info *info = info_fvdi;
	wk = vwk->real_address;
	get_colours_r(vwk, colour, &foreground, &background);
	src_wrap = (int)src->wdwidth * 2;		/* Always monochrome */
	src_addr = src->address;
	src_pos = (src_y * (long)src_wrap) + ((src_x >> 4) * 2);
	src_line_add = src_wrap - (((src_x + w) >> 4) - (src_x >> 4) + 1) * 2;
	if(!dst || !dst->address || (dst->address == wk->screen.mfdb.address))
	{		/* To screen? */
		dst_wrap = (int)wk->screen.wrap;
		dst_addr = wk->screen.mfdb.address;
		bpp = (int)info->var.bits_per_pixel;
		if(info->screen_mono != NULL) /* VBL mono emulation */
			bpp = 1;
		to_screen = 1;
	}
	else
	{
		dst_wrap = (long)dst->wdwidth * 2 * dst->bitplanes;
		dst_addr = dst->address;
		bpp = (int)dst->bitplanes;
		to_screen = 0;
	}
	if((info->par != NULL) && (info->screen_mono == NULL)) /* <> Videl driver */
	{
#ifdef DRIVER_IN_ROM
		wait_dma();
#endif
		if(to_screen)
		{
			int skipleft, rop;
			unsigned char *src_buf = (unsigned char *)src_addr;
			src_buf += src_pos;
			switch(operation)
			{
				case 1:  /* AND replace (col AND obj) */
					rop = 3;
					break;
				case 2:  /* transparent (col AND obj) OR (old AND NOT obj) */
#ifndef DRIVER_IN_ROM
					if(!init_screen)
						return(0); /* not works, if fVDI started from desktop */
#endif
					rop = 3;
					background = -1;
					break;
				case 3:  /* XOR         (obj XOR old)  */
					rop = 6;
					switch(info->var.bits_per_pixel)
					{
						case 8: foreground = 0xff; break;
						case 16: foreground = 0xffff; break;
						default: foreground = 0xffffff; break;
					}
					background = -1;
					break;
				case 4:  /* reverse transparent (old AND obj) OR (col AND not obj) */
					rop = 12;
					background = -1;
					break;
				default:
					return(1);
			}
			info->fbops->SetClippingRectangle(info,(int)dst_x,(int)dst_y,(int)(dst_x+w-1),(int)(dst_y+h-1));
			skipleft = ((int)src_buf & 3) << 3;
			src_buf = (unsigned char*)((long)src_buf & ~3);
			skipleft += (int)(src_x & 15);
			dst_x -= (long)skipleft;
			w += (long)skipleft;
			info->fbops->SetupForScanlineCPUToScreenColorExpandFill(info,(int)foreground,(int)background,rop,0xffffffff);
			info->fbops->SubsequentScanlineCPUToScreenColorExpandFill(info,(int)dst_x,(int)dst_y,(int)w,(int)h,skipleft);
			while(--h >= 0)
			{
				info->fbops->SubsequentScanline(info, (unsigned long *)src_buf);
				src_buf += src_wrap;
			}
			info->fbops->DisableClipping(info);
			return(1);
		}
		info->fbops->fb_sync(info);
	}
	src_addr += (src_pos / 2);
	src_line_add /= 2;
	if(bpp >= 8)
	{
		int Bpp = bpp / 8;
		dst_pos = (dst_y * (long)dst_wrap) + (dst_x * Bpp);
		dst_line_add = dst_wrap - (w * Bpp);
		dst_line_add /= Bpp;			/* Change into pixel count */
	}
	else /* planes */
	{
		dst_pos = (dst_y * (long)dst_wrap) + ((dst_x >> 4) * 2 * bpp);
		dst_line_add = dst_wrap - (((dst_x + w) >> 4) - (dst_x >> 4) + 1) * 2 * bpp;
		dst_line_add /= 2;
	}
	dst_addr += dst_pos;
	switch(operation)
	{
		case 1:				/* Replace */
			switch(bpp)
			{
#ifndef COLDFIRE
				case 1:
					replace_1(src_addr,src_line_add,dst_addr,dst_line_add,src_x,dst_x,w,h,(unsigned char)foreground,(unsigned char)background);
					break;
#endif
				case 16:
					replace_16((void *)src_addr,src_line_add,(void *)dst_addr,dst_line_add,src_x,w,h,(unsigned short)foreground,(unsigned short)background);
					break;
				case 32:
					replace_32((void *)src_addr,src_line_add,(void *)dst_addr,dst_line_add,src_x,w,h,foreground,background);
					break;				
				default:
					replace_8((void *)src_addr,src_line_add,(void *)dst_addr,dst_line_add,src_x,w,h,(unsigned char)foreground,(unsigned char)background);
					break;
			}				
			break;
		case 2:				/* Transparent */
			switch(bpp)
			{
#ifndef COLDFIRE
				case 1:
					transparent_1(src_addr,src_line_add,dst_addr,dst_line_add,src_x,dst_x,w,h,(unsigned char)foreground,(unsigned char)background);
					break;
#endif
				case 16:
					transparent_16((void *)src_addr,src_line_add,(void *)dst_addr,dst_line_add,src_x,w,h,(unsigned short)foreground,(unsigned short)background);
					break;
				case 32:
					transparent_32((void *)src_addr,src_line_add,(void *)dst_addr,dst_line_add,src_x,w,h,foreground,background);
					break;
				default:
					transparent_8((void *)src_addr,src_line_add,(void *)dst_addr,dst_line_add,src_x,w,h,(unsigned char)foreground,(unsigned char)background);
					break;
			}
			break;
		case 3:				/* XOR */
			switch(bpp)
			{
#ifndef COLDFIRE
				case 1:
					xor_1(src_addr,src_line_add,dst_addr,dst_line_add,src_x,dst_x,w,h,(unsigned char)foreground,(unsigned char)background);
					break;
#endif
				case 16:
					xor_16((void *)src_addr,src_line_add,(void *)dst_addr,dst_line_add,src_x,w,h,(unsigned short)foreground,(unsigned short)background);
					break;
				case 32:
					xor_32((void *)src_addr,src_line_add,(void *)dst_addr,dst_line_add,src_x,w,h,foreground,background);
					break;
				default:
					xor_8((void *)src_addr,src_line_add,(void *)dst_addr,dst_line_add,src_x,w,h,(unsigned char)foreground,(unsigned char)background);
					break;
			}				
			break;
		case 4:				/* Reverse transparent */
			switch(bpp)
			{
#ifndef COLDFIRE
				case 1:			
					revtransp_1(src_addr,src_line_add,dst_addr,dst_line_add,src_x,dst_x,w,h,(unsigned char)foreground,(unsigned char)background);
					break;
#endif
				case 16:			
					revtransp_16((void *)src_addr,src_line_add,(void *)dst_addr,dst_line_add,src_x,w,h,(unsigned short)foreground,(unsigned short)background);
					break;
				case 32:
					revtransp_32((void *)src_addr,src_line_add,(void *)dst_addr,dst_line_add,src_x,w,h,foreground,background);
					break;
				default:
					revtransp_8((void *)src_addr,src_line_add,(void *)dst_addr,dst_line_add,src_x,w,h,(unsigned char)foreground,(unsigned char)background);
					break;
			}
			break;
	}
	info->update_mono = 1;
	return(1);
}

long CDECL c_fill_area(Virtual *vwk, long x, long y, long w, long h, short *pattern, long colour, long mode, long interior_style)
{
	int rop, interior, multiplane;
  long foreground, background, height;
	unsigned long patternx = 0, patterny = 0;
	struct fb_info *info = info_fvdi;
	short *table;
	if((info->par == NULL) || (info->screen_mono != NULL)) /* Videl driver */
		return(0);
	table = NULL;
	if((long)vwk & 1)
	{
		if((y & 0xffff) != 0)
			return(-1);		/* Don't know about this kind of table operation */
		table = (short *)x;
		height = (y >> 16) & 0xffff;
		vwk = (Virtual *)((long)vwk - 1);
		if(!height)
			return(1);
		height--;
	}
	else
		height = -1;
	get_colours_r(vwk, colour, &foreground, &background);
	interior = (int)(interior_style>>16);
	multiplane = (int)vwk->fill.user.multiplane;
	switch(mode)
	{
		case 1:  /* AND replace (col AND obj) */
			rop = 3;
			break;
		case 2:  /* transparent (col AND obj) OR (old AND NOT obj) */
#if 1
			rop = 3;
			background = -1;
#else
			if(interior < 2) /* fill color */
				rop = 3;
			else
			{
				rop = 7;
				background = -1;				
			}
#endif
			break;
		case 3:  /* XOR         (obj XOR old)  */
			rop = 6;  
			switch(info->var.bits_per_pixel)
			{
				case 8: foreground = 0xff; break;
				case 16: foreground = 0xffff; break;
				default: foreground = 0xffffff; break;
			}
			background = -1;
			break;
		case 4:  /* reverse transparent (old AND obj) OR (col AND not obj) */
#if 1
			rop = 12;
			background = -1;
#else
			rop = 13;
#endif
			if(interior < 2)
				return(1);
			break;
		default:
			return(1);
	}
#ifdef DRIVER_IN_ROM
	wait_dma();
#endif
	switch(interior)
	{
		case 0:  /* empty fill */
		case 1:  /* color fill */
			info->fbops->SetupForSolidFill(info,(int)foreground,rop,0xffffffff);
			break;
		case 2:  /* pattern fill */
		case 3:  /* pattern fill */
			if(((interior==2) && ((short)interior_style!=13))
			 || ((interior==3) && ((short)interior_style<=5 || (short)interior_style==11)))
			{
				patternx = (((unsigned long)pattern[0] & 0xff) << 24)
				         + (((unsigned long)pattern[1] & 0xff) << 16)
				         + (((unsigned long)pattern[2] & 0xff) << 8)
				         + ((unsigned long)pattern[3] & 0xff);
				patterny = (((unsigned long)pattern[4] & 0xff) << 24)
				         + (((unsigned long)pattern[5] & 0xff) << 16)
				         + (((unsigned long)pattern[6] & 0xff) << 8)
				         + ((unsigned long)pattern[7] & 0xff);
				info->fbops->SetupForMono8x8PatternFill(info,(int)patternx,(int)patterny,(int)foreground,(int)background,rop,0xffffffff);
				break;
			}
			multiplane = 0;
			interior = 4;
		case 4:  /* user pattern */
			if(!table)
			{
				Workstation *wk = vwk->real_address;	
				static unsigned long pattern32[256*4];
				unsigned short *pattern16;
				unsigned char *src_buf;
				int src_x, src_y, xdir, ydir, skipleft, ws, hs, i, j;
				int bpp = info->var.bits_per_pixel/8;
				long off_buf = offscreen_alloc(info, (long)wk->screen.wrap*16);
				if(off_buf)
				{
					unsigned long src = (unsigned long)off_buf - (unsigned long)info->screen_base;
					src_x = (int)(src % (long)wk->screen.wrap) / bpp;
					src_y = (int)(src / (long)wk->screen.wrap);
					ws = hs = 16;	
					if(w < 16)
						ws = (int)w;
					if(h < 16)
						hs = (int)h;
					if(interior && multiplane)
					{
						/* color pattern */
						unsigned long dst_pos, temp, *ptr, *ptr1, *ptr2, *ptr3, *ptr4;
						void *src_addr, *dst_addr;
						int dst_wrap, src_line_add, dst_line_add;
						switch(info->var.bits_per_pixel)
						{
							case 8:
								/* not implemented */
								info->fbops->fb_sync(info);
								return(0);						
								break;
							case 16:
								ptr = (unsigned long *)pattern; /* 65K colors 16x16 */
								ptr1 = &pattern32[0];
								ptr2 = &pattern32[8];
								ptr3 = &pattern32[256];
								ptr4 = &pattern32[256+8];
								for(i = 16; i > 0; i--)         /* to 32x32 */
								{
									for(j = 8; j > 0; j--)
									{
										temp = *ptr++;
										*ptr1++ = *ptr2++ = *ptr3++ = *ptr4++ = temp;
									}
									ptr1 += 8;
									ptr2 += 8;
									ptr3 += 8;
									ptr4 += 8;							
								}
								pattern16 = (unsigned short *)pattern32;
								src_addr = (void *)&pattern16[((src_y & 15) << 5) + (src_x & 15)];
								dst_wrap = (int)wk->screen.wrap;
								dst_addr = wk->screen.mfdb.address;
								src_line_add = (32 - ws) * bpp;
								dst_pos = (long)(src_y * dst_wrap) + (long)(src_x * bpp);
								dst_line_add = dst_wrap - ws * bpp;
								dst_addr += dst_pos;
								src_line_add /= bpp;		/* Change into pixel count */
								dst_line_add /= bpp;
								blit_copy_16(src_addr,src_line_add,dst_addr,dst_line_add,ws,hs);
								break;
							default:
								ptr = (unsigned long *)pattern; /* 16M colors 16x16 */
								ptr1 = &pattern32[0];
								ptr2 = &pattern32[16];
								ptr3 = &pattern32[512];
								ptr4 = &pattern32[512+16];
								for(i = 16; i > 0; i--)         /* to 32x32 */
								{
									for(j = 16; j > 0; j--)
									{
										temp = *ptr++;
										*ptr1++ = *ptr2++ = *ptr3++ = *ptr4++ = temp;
									}
									ptr1 += 16;
									ptr2 += 16;
									ptr3 += 16;
									ptr4 += 16;							
								}
								src_addr = (void *)&pattern32[((src_y & 15) << 5) + (src_x & 15)];
								dst_wrap = (int)wk->screen.wrap;
								dst_addr = wk->screen.mfdb.address;
								src_line_add = (32 - ws) * bpp;
								dst_pos = (long)(src_y * dst_wrap) + (long)(src_x * bpp);
								dst_line_add = dst_wrap - ws * bpp;
								dst_addr += dst_pos;
								src_line_add /= bpp;		/* Change into pixel count */
								dst_line_add /= bpp;
								blit_copy_32(src_addr,src_line_add,dst_addr,dst_line_add,ws,hs);
								break;
						}
					}
					else
					{
						/* transform monochrome pattern 16x16 to color pattern */
						unsigned long temp;
						unsigned long *ptr1 = &pattern32[0];
						unsigned long *ptr2 = &pattern32[16];
						j = (x & 15);
						for(i = 16; i > 0; i--)             /* to 32x32 */
						{
							temp = (unsigned long)*pattern++;
							temp |= (temp << 16);
							temp <<= j;
							*ptr1++ = *ptr2++ = temp;
						}
						src_buf = (unsigned char *)&pattern32[y & 15];
						info->fbops->SetClippingRectangle(info,src_x,src_y,src_x+ws-1,src_y+hs-1);
						skipleft = ((int)src_buf & 3) << 3;
						src_buf = (unsigned char*)((long)src_buf & ~3);
						src_x -= skipleft;
						ws += skipleft;
						info->fbops->SetupForScanlineCPUToScreenColorExpandFill(info,(int)foreground,(int)background,3,0xffffffff);
						info->fbops->SubsequentScanlineCPUToScreenColorExpandFill(info,src_x,src_y,ws,hs,skipleft);
						while(hs--)
						{
							info->fbops->SubsequentScanline(info, (unsigned long *)src_buf);
							src_buf += 4;
						}
						info->fbops->DisableClipping(info);
					}
					/* copy color pattern */
					src_x = (int)(src % (long)wk->screen.wrap) / bpp;
					xdir = src_x - (int)x;
					ydir = src_y - (int)y;
					info->fbops->SetupForScreenToScreenCopy(info,xdir,ydir,(int)rop,0xffffffff,-1);
					for(i = 0; i < h; i += 16, y += 16)
					{
						for(j = 0; j < w; j +=16, x += 16)
							info->fbops->SubsequentScreenToScreenCopy(info,src_x,src_y,(int)x,(int)y,
							 (w-j > 16) ? 16 : (w-j), (h-i > 16) ? 16 : (h-i));
						x -= j;
					}
					offscreen_free(info, off_buf);
					return(1);
				}
			}
			info->fbops->fb_sync(info);
			return(0);
		default:
			return(1);
	}
	do
	{
		if(table)
		{
			height--;
			y = (long)*table++;
			x = (long)*table++;
			w = (long)*table++ - x + 1;
			h = 1;
		}
		switch(interior)
		{
			case 0:
			case 1:
				info->fbops->SubsequentSolidFillRect(info,(int)x,(int)y,(int)w,(int)h);
				break;
			case 2:
			case 3:
			case 4:
				info->fbops->SubsequentMono8x8PatternFillRect(info,0,0,(int)x,(int)y,(int)w,(int)h);
				break;
		}
	}
	while(height >= 0);
	return(1);
}

long CDECL c_blit_area(Virtual *vwk, MFDB *src, long src_x, long src_y, MFDB *dst, long dst_x, long dst_y, long w, long h, long operation)
{
	Workstation *wk;
	void *src_addr, *dst_addr;
	long new_src, new_dst;
	int src_wrap, dst_wrap;
	int src_line_add, dst_line_add;
	unsigned long src_pos, dst_pos;
	int bpp, from_screen, to_screen;
	struct fb_info *info = info_fvdi;
	if((info->par != NULL) && (info->screen_mono == NULL)) /* <> Videl driver */
	{
#ifdef DRIVER_IN_ROM
		wait_dma();
#endif /* DRIVER_IN_ROM */

#if 0
		{
 		wk = vwk->real_address;
		if((src_x + w > (wk->screen.wrap / (info->var.bits_per_pixel/8)))
		 || (dst_x + w > (wk->screen.wrap / (info->var.bits_per_pixel/8))))
		{
			char buf[10];
			Funcs_ltoa(buf, src_x, 10);
			Funcs_puts(buf);
			Funcs_puts(" ");
			Funcs_ltoa(buf, src_y, 10);
			Funcs_puts(buf);
			Funcs_puts(" ");
			Funcs_ltoa(buf, src_x + w - 1, 10);
			Funcs_puts(buf);
			Funcs_puts(" ");
			Funcs_ltoa(buf, src_y + h - 1, 10);
			Funcs_puts(buf);
			Funcs_puts(" ");
			Funcs_ltoa(buf, dst_x, 10);
			Funcs_puts(buf);
			Funcs_puts(" ");
			Funcs_ltoa(buf, dst_y, 10);
			Funcs_puts(buf);
			Funcs_puts(" ");
			Funcs_ltoa(buf, dst_x + w - 1, 10);
			Funcs_puts(buf);
			Funcs_puts(" ");
			Funcs_ltoa(buf, dst_y + h - 1, 10);
			Funcs_puts(buf);
			Funcs_puts(" ");
			Funcs_ltoa(buf, ((!src || !src->address) && (!dst || !dst->address)) ? 1 : 0, 10);
			Funcs_puts(buf);
			Funcs_puts(" 0x");
			Funcs_ltoa(buf, (long)wk->screen.mfdb.address, 16);
			Funcs_puts(buf);
			Funcs_puts(" ");			
			Funcs_ltoa(buf, wk->screen.wrap, 10);
			Funcs_puts(buf);
			Funcs_puts("      ");
			Funcs_puts("\r");
		}
		}
#endif
			
		if((!src || !src->address) && (!dst || !dst->address))
		{
			info->fbops->ScreenToScreenCopy(info,(int)src_x,(int)src_y,(int)dst_x,(int)dst_y,(int)w,(int)h,(int)operation);
			return(1);
		}
	}
	new_src = new_dst = 0;
	wk = vwk->real_address;	
	if(!src || !src->address || (src->address == wk->screen.mfdb.address))
	{		/* From screen? */
		src_wrap = (int)wk->screen.wrap;
		src_addr = wk->screen.mfdb.address;
		from_screen = 1;
	}
	else
	{
		src_wrap = (long)src->wdwidth * 2 * src->bitplanes;
		src_addr = src->address;
		if(((unsigned long)src_addr >= (unsigned long)info->ram_base)
		 && ((unsigned long)src_addr < ((unsigned long)info->ram_base + (unsigned long)info->ram_size)))
			from_screen = 2;
		else
		{
			from_screen = 0;
#ifdef USE_OFFSCREEN
			if((info->par != NULL) && (info->screen_mono == NULL)) /* <> Videl driver */
			{
				if((operation != 3) /* and target is screen */
				 && (!dst || !dst->address || (dst->address == wk->screen.mfdb.address)))
				{
					new_src = offscreen_alloc(info, ((long)src->height * src_wrap) + 32);
					if(new_src)
					{
#ifdef DRIVER_IN_ROM
						int bpp = (int)info->var.bits_per_pixel/8;
						if((((unsigned long)src->address & (bpp-1)) == 0)
						 && (src_wrap >= 32) && (src->height >= 8))
						{
							char *psrc = (char *)src->address;
							char *pdst = (char *)((new_src + 15) & ~15);
							if(!dma_transfer(psrc, pdst, (int)src->height * src_wrap, 0, 0, 0, bpp))
								wait_dma();
							else
								memcpy((void *)((new_src + 15) & ~15), (void *)src->address, (long)src->height * (long)src_wrap);
						}
						else
#endif
						memcpy((void *)((new_src + 15) & ~15), (void *)src->address, (long)src->height * (long)src_wrap);
						from_screen = 3;
					}
				}
			}
#endif /* USE_OFFSCREEN */
		}
	}
	if(!dst || !dst->address || (dst->address == wk->screen.mfdb.address))
	{		/* To screen? */
		dst_wrap = (int)wk->screen.wrap;
		dst_addr = wk->screen.mfdb.address;
		bpp = (int)info->var.bits_per_pixel;
		if(info->screen_mono != NULL) /* VBL mono emulation */
			bpp = 1;
		to_screen = 1;
	}
	else
	{
		dst_wrap = (long)dst->wdwidth * 2 * dst->bitplanes;
		dst_addr = dst->address;
		bpp = (int)dst->bitplanes;
		if(((unsigned long)dst_addr >= (unsigned long)info->ram_base)
		 && ((unsigned long)dst_addr < ((unsigned long)info->ram_base + (unsigned long)info->ram_size)))
			to_screen = 2;
		else
		{
			to_screen = 0;
#ifdef USE_OFFSCREEN
			if((info->par != NULL) && (operation != 3) && from_screen)
			{
				new_dst = offscreen_alloc(info, ((long)dst->height * dst_wrap) + 32);
				if(new_dst)
					to_screen = 3;
			}
#endif /* USE_OFFSCREEN */
		}
	}
	if((info->par != NULL) && (info->screen_mono == NULL)) /* <> Videl driver */
	{
		if(from_screen && to_screen)
		{
			bpp /= 8;
			if((from_screen == 1) && (to_screen == 1))
				info->fbops->ScreenToScreenCopy(info,(int)src_x,(int)src_y,(int)dst_x,(int)dst_y,(int)w,(int)h,(int)operation);
			else
			{
				unsigned long src=0, dst=0;
				int xdir, ydir, i;
				int screen_wrap = info->var.xres_virtual * bpp;
				if(from_screen != 1)
				{
					if(from_screen == 3)
						src = (unsigned long)((new_src + 15) & ~15) - (unsigned long)info->screen_base;
					else
						src = (unsigned long)src_addr - (unsigned long)info->screen_base;
					src += (unsigned long)((src_y * (long)src_wrap) + (src_x * (long)bpp));
					src_x = (int)(src % (long)screen_wrap) / bpp;
					src_y = (int)(src / (long)screen_wrap);
				}
				if(to_screen != 1)
				{
					if(to_screen == 3)
						dst = (unsigned long)((new_dst + 15) & ~15) - (unsigned long)info->screen_base;
					else
						dst = (unsigned long)dst_addr - (unsigned long)info->screen_base;
					dst += (unsigned long)((dst_y * (long)dst_wrap) + (dst_x * (long)bpp));	
					dst_x = (int)(dst % (long)screen_wrap) / bpp;
					dst_y = (int)(dst / (long)screen_wrap);
				}
				xdir = (int)(src_x - dst_x);
				ydir = (int)(src_y - dst_y);
				info->fbops->SetupForScreenToScreenCopy(info,xdir,ydir,(int)operation,0xffffffff,-1);
				for(i = h - 1; i >= 0; i--) /* line by line because src or dst havn't the screen width */
				{
					info->fbops->SubsequentScreenToScreenCopy(info,(int)src_x,(int)src_y,(int)dst_x,(int)dst_y,(int)w,1);
					if(from_screen != 1)
					{
						src += (unsigned long)src_wrap;
						src_x = (int)(src % (long)screen_wrap) / bpp;
						src_y = (int)(src / (long)screen_wrap);
					}
					else
						src_y++;
					if(to_screen != 1)
					{
						dst += (unsigned long)dst_wrap;
						dst_x = (int)(dst % (long)screen_wrap) / bpp;
						dst_y = (int)(dst / (long)screen_wrap);
					}
					else
						dst_y++;
				}
			}
#ifdef USE_OFFSCREEN
			if(from_screen == 3)
				offscreen_free(info, new_src);
			if(to_screen == 3)
			{
#ifdef DRIVER_IN_ROM
				int bpp = (int)info->var.bits_per_pixel/8;
				if((((long)dst->address & (bpp-1)) == 0)
				 && (dst_wrap >= 32) && (dst->height >= 8))
				{
					char *psrc = (char *)((new_dst + 15) & ~15);
					char *pdst = (char *)dst->address;
					if(dma_transfer(psrc, pdst, (int)dst->height * dst_wrap, 0, 0, 0, bpp))
						memcpy((void *)dst->address, (void *)((new_dst + 15) & ~15), (long)dst->height * (long)dst_wrap);
				}
				else
#endif
				memcpy((void *)dst->address, (void *)((new_dst + 15) & ~15),
				 (long)dst->height * (long)dst_wrap);
				offscreen_free(info, new_dst);			
			}
#endif /* USE_OFFSCREEN */
			return(1);
		}
#if 0
		// slower than the CPU or DMA in 16M colors where src must be aligned to 32 bits
		else if((info->fbops->SetupForScanlineImageWrite != NULL)
		 && !from_screen && to_screen
		 && (bpp < 3*8 || (bpp > 3*8 && (((long)src_addr & 0x3L) == 0))))
		{
			int skipleft; 
			unsigned char *src_buf = (unsigned char *)src_addr;
			src_pos = src_y * (long)src_wrap + src_x * (bpp/8);
			src_buf += src_pos;
			info->fbops->SetClippingRectangle(info,(int)dst_x,(int)dst_y,(int)(dst_x+w-1),(int)(dst_y+h-1));
			skipleft = ((int)src_buf & 3) << 3;
			src_buf = (unsigned char*)((long)src_buf & ~3);
			dst_x -= (long)skipleft;
			w += (long)skipleft;
			info->fbops->SetupForScanlineImageWrite(info,(int)operation,0xffffffff,-1,(int)src->bitplanes);
			info->fbops->SubsequentScanlineImageWriteRect(info,(int)dst_x,(int)dst_y,(int)w,(int)h,skipleft);
			while(--h >= 0)
			{
				info->fbops->SubsequentScanline(info, (unsigned long *)src_buf);
				src_buf += src_wrap;
			}
			info->fbops->DisableClipping(info);
			return(1);
		}
#endif
		info->fbops->fb_sync(info);
	}
	if(bpp >= 8)
	{
		int Bpp = bpp/8;
		src_pos = (src_y * (long)src_wrap) + (src_x * (long)Bpp);
		src_line_add = src_wrap - w * Bpp;
		dst_pos = (dst_y * (long)dst_wrap) + (dst_x * (long)Bpp);
		dst_line_add = dst_wrap - w * Bpp;
		if(src_y < dst_y)
		{
			src_pos += (h - 1) * (long)src_wrap;
			src_line_add -= (src_wrap * 2);
			dst_pos += (h - 1) * (long)dst_wrap;
			dst_line_add -= (dst_wrap * 2);
		}
		src_line_add /= Bpp;		/* Change into pixel count */
		dst_line_add /= Bpp;
 	}
 	else /* planes */
 	{
		src_pos = (src_y * (long)src_wrap) + ((src_x >> 4) * 2 * bpp);
		src_line_add = src_wrap - (((src_x + w) >> 4) - (src_x >> 4) + 1) * 2 * bpp;
		dst_pos = (dst_y * (long)dst_wrap) + ((dst_x >> 4) * 2 * bpp);
		dst_line_add = dst_wrap - (((dst_x + w) >> 4) - (dst_x >> 4) + 1) * 2 * bpp;
		if(src_y < dst_y)
		{
			src_pos += (h - 1) * (long)src_wrap;
			src_line_add -= (src_wrap * 2);
			dst_pos += (h - 1) * (long)dst_wrap;
			dst_line_add -= (dst_wrap * 2);
		}
		src_line_add /= 2;      /* Word */
		dst_line_add /= 2;
	}
	src_addr += src_pos;
	dst_addr += dst_pos;
	if((src_y == dst_y) && (src_x < dst_x))
	{
		if(bpp >= 8)
		{
			int Bpp = bpp/8;
			src_addr += (w * Bpp); /* To take backward copy into account */
			dst_addr += (w * Bpp);
			src_line_add += (2 * w);
			dst_line_add += (2 * w);
		}
		else /* planes */
		{
			int src_width = (((src_x + w) >> 4) - (src_x >> 4) + 1) * 2 * bpp;
			int dst_width = (((dst_x + w) >> 4) - (dst_x >> 4) + 1) * 2 * bpp;
			src_addr += src_width;
			dst_addr += dst_width;
			src_line_add += src_width;
			dst_line_add += dst_width;
		}
#ifdef USE_BLITTER
		if(info->par == NULL) /* Videl driver */
		{
			blitter_copy(src_addr,src_line_add,dst_addr,dst_line_add,w,h,bpp,operation,1);
      return(1);
		}
#endif /* defined(COLDFIRE) && defined(MCF547X) */
		switch(operation)
		{
			case 3:
				switch(bpp)
				{
#ifndef COLDFIRE
					case 1:
						pan_backwards_copy_1(src_addr,src_line_add,dst_addr,dst_line_add,src_x,dst_x,w,h);
						break;
#endif
					case 16:
						pan_backwards_copy_16(src_addr,src_line_add,dst_addr,dst_line_add,w,h);
						break;
					case 32:
						pan_backwards_copy_32(src_addr,src_line_add,dst_addr,dst_line_add,w,h);
						break;
					default:
						pan_backwards_copy_8(src_addr,src_line_add,dst_addr,dst_line_add,w,h);
						break;
				}
				break;
			case 7:
				switch(bpp)
				{
#ifndef COLDFIRE
					case 1:
						pan_backwards_or_1(src_addr,src_line_add,dst_addr,dst_line_add,src_x,dst_x,w,h);
						break;
#endif
					case 16:
						pan_backwards_or_16(src_addr,src_line_add,dst_addr,dst_line_add,w,h);
						break;
					case 32:
						pan_backwards_or_32(src_addr,src_line_add,dst_addr,dst_line_add,w,h);
						break;
					default:
						pan_backwards_or_8(src_addr,src_line_add,dst_addr,dst_line_add,w,h);
						break;			
				}
				break;
			default:
				switch(bpp)
				{
#ifndef COLDFIRE
					case 1:
						pan_backwards_1(src_addr,src_line_add,dst_addr,dst_line_add,src_x,dst_x,w,h,operation);
						break;
#endif
					case 16:
						pan_backwards_16(src_addr,src_line_add,dst_addr,dst_line_add,w,h,operation);
						break;
					case 32:
						pan_backwards_32(src_addr,src_line_add,dst_addr,dst_line_add,w,h,operation);
						break;
					default:
						pan_backwards_8(src_addr,src_line_add,dst_addr,dst_line_add,w,h,operation);
						break;
				}
				break;
		}
	}
	else
	{
#ifdef USE_BLITTER
		if(info->par == NULL) /* Videl driver */
		{
			blitter_copy(src_addr,src_line_add,dst_addr,dst_line_add,w,h,bpp,operation,0);
      return(1);
		}
#endif /* defined(COLDFIRE) && defined(MCF547X) */
		switch(operation)
		{
			case 3:
				switch(bpp)
				{
#ifndef COLDFIRE
					case 1:
						blit_copy_1(src_addr,src_line_add,dst_addr,dst_line_add,src_x,dst_x,w,h);
						break;
#endif
					case 16:
						blit_copy_16(src_addr,src_line_add,dst_addr,dst_line_add,w,h);
						break;
					case 32:
						blit_copy_32(src_addr,src_line_add,dst_addr,dst_line_add,w,h);
						break;
					default:
						blit_copy_8(src_addr,src_line_add,dst_addr,dst_line_add,w,h);
						break;
				}
				break;
			case 7:
				switch(bpp)
				{
#ifndef COLDFIRE
					case 1:
						blit_or_1(src_addr,src_line_add,dst_addr,dst_line_add,src_x,dst_x,w,h);
						break;
#endif
					case 16:
						blit_or_16(src_addr,src_line_add,dst_addr,dst_line_add,w,h);
						break;
					case 32:
						blit_or_32(src_addr,src_line_add,dst_addr,dst_line_add,w,h);
						break;
					default:
						blit_or_8(src_addr,src_line_add,dst_addr,dst_line_add,w,h);
						break;
				}
				break;
			default:
				switch(bpp)
				{
#ifndef COLDFIRE
					case 1:
						blit_1(src_addr,src_line_add,dst_addr,dst_line_add,w,h,src_x,dst_x,operation);
						break;
#endif
					case 16:
						blit_16(src_addr,src_line_add,dst_addr,dst_line_add,w,h,operation);
						break;
					case 32:
						blit_32(src_addr,src_line_add,dst_addr,dst_line_add,w,h,operation);
						break;
 					default:
						blit_8(src_addr,src_line_add,dst_addr,dst_line_add,w,h,operation);
						break;
				}
				break;
		}
	}
#ifdef DRIVER_IN_ROM
	if((info->par != NULL) && (info->screen_mono == NULL) && from_screen && !to_screen)
		wait_dma();
#endif /* DRIVER_IN_ROM */
	info->update_mono = 1;
	return(1);
}

long CDECL c_line_draw(Virtual *vwk, long x1, long y1, long x2, long y2, long pattern, long colour, long mode)
{
	int rop, w, h;
	unsigned long patternx, patterny;
	long foreground, background;
	struct fb_info *info = info_fvdi;
	short *table, *index;
	int length = 0, moves = 0, n = 1;
	int movepnt = -1;
	if((info->par == NULL) || (info->screen_mono != NULL)) /* Videl driver or monochrome emulation */
		return(0);
	table = index = 0;
	if((long)vwk & 1)
	{
		if((y1 & 0xffff) > 1)
			return(-1);		/* Don't know about this kind of table operation */
		table = (short *)x1;
		length = (y1 >> 16) & 0xffff;
		if(length < 2)
			return(1);
		if((y1 & 0xffff) == 1)
		{
			index = (short *)y2;
			moves = (int)(x2 & 0xffff);
			if(!moves)
				index = 0;
			else
			{
				moves >>= 1;
				if(index[--moves] == -4)
					moves--;
				if(index[moves] == -2)
					moves--;
				if(moves >= 0)
					movepnt = ((int)index[moves>>1] + 4) / 2;
			}
		}
		length--;
		vwk = (Virtual *)((long)vwk - 1);
		x1 = (long)table[0];
		y1 = (long)table[1];
		x2 = (long)table[2];
		y2 = (long)table[3];
		table += 2;
		if(!index && (length == 1))
			table = 0;
	}
	else
		length = 1;
	if(!table && !clip_line(vwk, &x1, &y1, &x2, &y2))
		return(1);
	get_colours_r(vwk, colour, &foreground, &background);
	switch(mode)
	{
		case 1:  /* AND replace (col AND obj) */
			rop = 3;
			break;
		case 2:  /* transparent (col AND obj) OR (old AND NOT obj) */
#if 1
			rop = 3;
			background = -1;			
#else
			if((pattern & 0xffff) == 0xffff) /* solid line */
				rop = 3;
			else
			{
				rop = 7;
				background = -1;				
			}
#endif
			break;
		case 3:  /* XOR         (obj XOR old)  */
			rop = 6;
			switch(info->var.bits_per_pixel)
			{
				case 8: foreground = 0xff; break;
				case 16: foreground = 0xffff; break;
				default: foreground = 0xffffff; break;
			}
			background = -1;
			break;
		case 4:  /* reverse transparent (old AND obj) OR (col AND not obj) */
#if 1
			rop = 12;
			background = -1;
#else
			rop = 13;
#endif
			if((pattern & 0xffff) == 0xffff) /* solid line */
				return(1);
			break;
		default:
			return(1);
#if 0
//fb=	00  01  10  11
//	0x0,0x0,0x3,0x3		replace mode
//	0x4,0x4,0x7,0x7		transparent mode
//	0x6,0x6,0x6,0x6		XOR mode
//	0x1,0x1,0xD,0xD		inverse transparent mode
//	0x0,0xF,0x0,0xF		mode 0  D = 0
//	0x0,0xE,0x1,0xF		mode 1  D = S and D
//	0x0,0xD,0x2,0xF		mode 2  D = S and [not D]
//	0x0,0xC,0x3,0xF		mode 3  D = S	(replace)
//	0x0,0xB,0x4,0xF		mode 4  D = [not S] and D
//	0x0,0xA,0x5,0xF		mode 5  D = D
//	0x0,0x9,0x6,0xF		mode 6  D = S xor D (XOR mode)
//	0x0,0x8,0x7,0xF		mode 7  D = S or D  (OR mode)
//	0x0,0x7,0x8,0xF		mode 8  D = not [S or D]
//	0x0,0x6,0x9,0xF		mode 9  D = not [S xor D]
//	0x0,0x5,0xA,0xF		mode A  D = not D
//	0x0,0x4,0xB,0xF		mode B  D = S or [not D]
//	0x0,0x3,0xC,0xF		mode C  D = not S
//	0x0,0x2,0xD,0xF		mode D  D = [not s] or D
//	0x0,0x1,0xE,0xF		mode E  D = not [S and D]
//	0x0,0x0,0xF,0xF		mode F  D = 1
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
#endif		
	}
#ifdef DRIVER_IN_ROM
	wait_dma();
#endif
	if((pattern & 0xffff) == 0xffff) /* solid line */
	{
		info->fbops->SetupForSolidLine(info,(int)foreground,rop,0xffffff);
		do
		{
			if(index)
			{
				if(n == movepnt)
				{
					if(--moves >= 0)
						movepnt = ((int)index[moves] + 4) / 2;
					else
						movepnt = -1;		/* never again equal to n */
					n++;
					x1 = (long)table[0];
					y1 = (long)table[1];
					x2 = (long)table[2];
					y2 = (long)table[3];
					table += 2;
					continue;
				}
				n++;
			}
			if(!table || (table && clip_line(vwk, &x1, &y1, &x2, &y2)))
			{
				if(y1 == y2)
				{
					if(x2 > x1)
						w = x2 - x1 + 1;
					else
					{
						w = x1 - x2 + 1;
						x1 = x2;	
					}
					info->fbops->SubsequentSolidHorVertLine(info,(int)x1,(int)y1,w,DEGREES_0);
				}
				else if(x1 == x2)
				{
					if(y2 > y1)
						h = y2 - y1 + 1;
					else
					{
						h = y1 - y2 + 1;
						y1 = y2;	
					}
					info->fbops->SubsequentSolidHorVertLine(info,(int)x1,(int)y1,h,DEGREES_90);
				}
				else
				{
					if(info->fbops->SubsequentSolidTwoPointLine != NULL)
						info->fbops->SubsequentSolidTwoPointLine(info,(int)x1,(int)y1,(int)x2,(int)y2,OMIT_LAST);
					else /* function not exists for example with the Lynx */
					{
						int d, incrE, incrNE, dx, dy, xx, yy;
						int x_step = 1, y_step = 1;
						dx = (int)(x2 - x1);
						if(dx < 0)
						{
							dx = -dx;
							x_step = -x_step;
						}
						dy = (int)(y2 - y1);
						if(dy < 0)
						{
							dy = -dy;
							y_step = -y_step;
						}
						if(dx > dy)
						{
							incrE = 2 * dy;
							incrNE = -2 * dx;
							d = -dx;
							xx = (int)x1;
							for(; dx >= 0; dx--)
							{
								d += incrE;
								if(d >= 0)
								{
									int len = xx - (int)x1;
									if(len >= 0)
										info->fbops->SubsequentSolidHorVertLine(info,(int)x1,(int)y1,len,DEGREES_0);
									else
										info->fbops->SubsequentSolidHorVertLine(info,(int)xx,(int)y1,-len,DEGREES_0);
									d += incrNE;
									y1 += (long)y_step;
									x1 = (long)xx;
								}
								xx += x_step;
							}
						}
						else
						{
							incrE = 2 * dx;
							incrNE = -2 * dy;
							d = -dy;
							yy = (int)y1;
							for(; dy >= 0; dy--)
							{
								d += incrE;
								if(d >= 0)
								{
									int len = yy + (int)y1;
									if(len >= 0)
										info->fbops->SubsequentSolidHorVertLine(info,(int)x1,(int)y1,len,DEGREES_90);
									else
										info->fbops->SubsequentSolidHorVertLine(info,(int)x1,(int)yy,-len,DEGREES_90);
									d += incrNE;
									x1 += (long)x_step;
									y1 = (long)yy;
								}
								yy += y_step;
							}
						}
					}
				}
			}
			if(table)
			{
				x1 = (long)table[0];
				y1 = (long)table[1];
				x2 = (long)table[2];
				y2 = (long)table[3];
				table += 2;
			}
		}
		while(--length > 0);
	}
	else                             /* dashed line */
	{
		pattern = (pattern << 16) | (pattern & 0xffff);
		if(mode == 3)                  /* XOR not works ??? */
		{
			if(((pattern & 0xff) == ((pattern >> 8) & 0xff))
			 && ((!table && ((x1 == x2) || (y1 == y2)))
			  || (!index && table && check_table(&table[-2], length))))
			{
				do
				{
					if(index)
					{
						if(n == movepnt)
						{
							if(--moves >= 0)
								movepnt = ((int)index[moves] + 4) / 2;
							else
								movepnt = -1;		/* never again equal to n */
							n++;
							x1 = (long)table[0];
							y1 = (long)table[1];
							x2 = (long)table[2];
							y2 = (long)table[3];
							table += 2;
							continue;
						}
						n++;
					}
 					if(!table || (table && clip_line(vwk, &x1, &y1, &x2, &y2)))
					{
						if(y1 == y2)           /* horizontal line */
						{
							h = 1;
							if(x2 > x1)
								w = x2 - x1 + 1;
							else
							{
								w = x1 - x2 + 1;
								x1 = x2;	
							}
							patterny = ((pattern >> 8) & 0x00ff00ff) | (pattern & 0xff00ff00);
							info->fbops->SetupForMono8x8PatternFill(info,(int)patterny,(int)patterny,(int)foreground,(int)background,rop,0xffffffff);
							info->fbops->SubsequentMono8x8PatternFillRect(info,0,0,(int)x1,(int)y1,(int)w,(int)h);
						}
						else if(x1 == x2)      /* vertical line */
						{
							w = 1;
							if(y2 > y1)
								h = y2 - y1 + 1;
							else
							{
								h = y1 - y2 + 1;
								y1 = y2;	
							}
							patternx = patterny = 0;
							if(pattern & 1)
								patternx |= 0xff000000;
							if(pattern & 2)
								patternx |= 0x00ff0000;
							if(pattern & 4)
								patternx |= 0x0000ff00;
							if(pattern & 8)
								patternx |= 0x000000ff;
							if(pattern & 0x10)
								patterny |= 0xff000000;
							if(pattern & 0x20)
								patterny |= 0x00ff0000;
							if(pattern & 0x40)
								patterny |= 0x0000ff00;
							if(pattern & 0x80)
								patterny |= 0x000000ff;
							info->fbops->SetupForMono8x8PatternFill(info,(int)patternx,(int)patterny,(int)foreground,(int)background,rop,0xffffffff);
							info->fbops->SubsequentMono8x8PatternFillRect(info,0,0,(int)x1,(int)y1,(int)w,(int)h);
						}
					}
					if(table)
					{
						x1 = (long)table[0];
						y1 = (long)table[1];
						x2 = (long)table[2];
						y2 = (long)table[3];
						table += 2;
					}
				}
				while(--length > 0);
			}
			else                         /* use default line */
			{
				info->fbops->fb_sync(info);
				return(0);
			}
		}
		else
		{
			if(info->fbops->SetupForDashedLine == NULL)
			{                            /* for example with Lynx, use default line */
				info->fbops->fb_sync(info);
				return(0);
			}
			info->fbops->SetupForDashedLine(info,(int)foreground,(int)background,rop,0xffffffff,32,(unsigned char *)&pattern);
			do
			{
				if(index)
				{
					if(n == movepnt)
					{
						if(--moves >= 0)
							movepnt = ((int)index[moves] + 4) / 2;
						else
							movepnt = -1;		/* never again equal to n */
						n++;
						x1 = (long)table[0];
						y1 = (long)table[1];
						x2 = (long)table[2];
						y2 = (long)table[3];
						table += 2;
						continue;
					}
					n++;
				}
				if(!table || (table && clip_line(vwk, &x1, &y1, &x2, &y2)))
					info->fbops->SubsequentDashedTwoPointLine(info,(int)x1,(int)y1,(int)x2,(int)y2,OMIT_LAST,0);
				if(table)
				{
					x1 = (long)table[0];
					y1 = (long)table[1];
					x2 = (long)table[2];
					y2 = (long)table[3];
					table += 2;
				}
			}
			while(--length > 0);
		}
	}
	return(1);
}

long CDECL c_fill_polygon(Virtual *vwk, short points[][2], long n, short index[], long moves, short *pattern, long colour, long mode, long interior_style)
{
	struct fb_info *info = info_fvdi;
	long foreground, background;
	unsigned long patternx = 0, patterny = 0;
	static unsigned long pattern32[16];
	static short crossing[2048];
	short *coords;
	short miny, maxy, y, x1 = 0, x2 = 0, y1 = 0, y2 = 0;
	int i, j, ints, move_n = 0, movepnt = 0, rop, interior, multiplane;
	if((info->par == NULL) || (info->screen_mono != NULL)) /* Videl driver */
		return(0);
	if((long)vwk & 1)
		return(-1);		/* Don't know about this kind of table operation */
	if(!n)
		return(1);
	get_colours_r(vwk, colour, &foreground, &background);
	interior = (int)(interior_style >> 16);
	multiplane = (int)vwk->fill.user.multiplane;
	switch(mode)
	{
		case 1:  /* AND replace (col AND obj) */
			rop = 3;
			break;
		case 2:  /* transparent (col AND obj) OR (old AND NOT obj) */
#if 1
			rop = 3;
			background = -1;
#else
			if(interior < 2) /* fill color */
				rop = 3;
			else
			{
				rop = 7;
				background = -1;				
			}
#endif
			break;
		case 3:  /* XOR         (obj XOR old)  */
			rop = 6;  
			switch(info->var.bits_per_pixel)
			{
				case 8: foreground = 0xff; break;
				case 16: foreground = 0xffff; break;
				default: foreground = 0xffffff; break;
			}
			background = -1;
			break;
		case 4:  /* reverse transparent (old AND obj) OR (col AND not obj) */			
#if 1
			rop = 12;
			background = -1;
#else
			rop = 13;
#endif
			if(interior < 2)
				return(1);
			break;
		default:
			return(1);
	}
#ifdef DRIVER_IN_ROM
	wait_dma();
#endif
	switch(interior)
	{
		case 0:  /* empty fill */
		case 1:  /* color fill */
			info->fbops->SetupForSolidFill(info,(int)foreground,rop,0xffffffff);
			break;
		case 2:  /* pattern fill */
		case 3:  /* pattern fill */
			if(((interior==2) && ((short)interior_style!=13))
			 || ((interior==3) && ((short)interior_style<=5 || (short)interior_style==11)))
			{
				patternx = (((unsigned long)pattern[0] & 0xff) << 24)
				         + (((unsigned long)pattern[1] & 0xff) << 16)
				         + (((unsigned long)pattern[2] & 0xff) << 8)
				         + ((unsigned long)pattern[3] & 0xff);
				patterny = (((unsigned long)pattern[4] & 0xff) << 24)
				         + (((unsigned long)pattern[5] & 0xff) << 16)
				         + (((unsigned long)pattern[6] & 0xff) << 8)
				         + ((unsigned long)pattern[7] & 0xff);
				info->fbops->SetupForMono8x8PatternFill(info,(int)patternx,(int)patterny,(int)foreground,(int)background,rop,0xffffffff);
				break;
			}
			multiplane = 0;
			interior = 4;
		case 4:  /* user pattern */
			if(multiplane)
				return(1);                           /* to do */		
			else 
			{
				unsigned long temp;
				unsigned long *ptr = pattern32;
				for(i = 16; i > 0; i--)              /* to 32x16 */
				{
					temp = (unsigned long)*pattern++;
					temp |= (temp << 16);
					*ptr++ = temp;
				}
			}
			break;
		default:
			return(1);
	}
	if(!moves)
	{
		index = 0;
		if((points[0][0] == points[n-1][0]) && (points[0][1] == points[n-1][1]))
			n--;
	}
	else
	{
		if(index[--moves] == -4)
			moves--;
		if(index[moves] == -2)
			moves--;
	}
	miny = maxy = points[0][1];
	coords = &points[1][1];
	for(i = 1; i < n; i++)
	{
		y = *coords;
		coords += 2;		/* Skip to next y */
		if(y < miny)
			miny = y;
		if(y > maxy)
			maxy = y;
	}
	if(vwk->clip.on)
	{
		if(miny < vwk->clip.rectangle.y1)
			miny = vwk->clip.rectangle.y1;
		if(maxy > vwk->clip.rectangle.y2)
			maxy = vwk->clip.rectangle.y2;
	}
	for(y = miny; y <= maxy; y++)
	{
		ints = 0;
		if(index)
		{
			move_n = moves;
			movepnt = (index[move_n] + 4) / 2;
			x1 = points[0][0];
			y1 = points[0][1];
			for(i = 1; i < n; i++)
			{
				x2 = points[i][0];
				y2 = points[i][1];
				if(i == movepnt)
				{
					if(--move_n >= 0)
						movepnt = (index[move_n] + 4) / 2;
					else
						movepnt = -1;		/* Never again equal to n */
					continue;
				}
				if(y1 < y2)
				{
					if((y >= y1) && (y < y2))
						crossing[ints++] = SMUL_DIV((y - y1), (x2 - x1), (y2 - y1)) + x1;
				}
				else if (y1 > y2)
				{
					if((y >= y2) && (y < y1))
						crossing[ints++] = SMUL_DIV((y - y2), (x1 - x2), (y1 - y2)) + x2;
				}
				x1 = x2;
				y1 = y2;
				if(ints >= 2048)
					return(1);
			}
		}
		else /* !index */
		{
			x1 = points[n-1][0];
			y1 = points[n-1][1];
			for(i = 0; i < n; i++)
			{
				x2 = points[i][0];
				y2 = points[i][1];
				if(y1 < y2)
				{
					if((y >= y1) && (y < y2))
						crossing[ints++] = SMUL_DIV((y - y1), (x2 - x1), (y2 - y1)) + x1;
				}
				else if (y1 > y2)
				{
					if((y >= y2) && (y < y1))
						crossing[ints++] = SMUL_DIV((y - y2), (x1 - x2), (y1 - y2)) + x2;
				}
				x1 = x2;
				y1 = y2;
				if(ints >= 2048)
					return(1);
			}
		}
		for(i = 0; i < ints - 1; i++)
		{
			for(j = i + 1; j < ints; j++)
			{
				if(crossing[i] > crossing[j])
				{
					short tmp = crossing[i];
					crossing[i] = crossing[j];
					crossing[j] = tmp;
				}
			}
		}
		x1 = vwk->clip.rectangle.x1;
		x2 = vwk->clip.rectangle.x2;
		for(i = 0; i < ints - 1; i += 2)
		{
			y1 = crossing[i];		/* Really x-values, but... */
			y2 = crossing[i+1];
			if(y1 < x1)
				y1 = x1;
			if(y2 > x2)
				y2 = x2;
			if(y1 <= y2)
			{
				switch(interior)
				{
					case 0:  /* empty fill */
					case 1:  /* color fill */
						info->fbops->SubsequentSolidFillRect(info,(int)y1,(int)y,(int)(y2-y1+1),1);
						break;
					case 2:  /* pattern fill */
					case 3:  /* pattern fill */
						info->fbops->SubsequentMono8x8PatternFillRect(info,0,0,(int)y1,(int)y,(int)(y2-y1+1),1);
						break;
					case 4:  /* user pattern */
						patterny = pattern32[y & 15];
						patterny = (patterny << (y1 & 15)) | (patterny >> (32 - (y1 & 15)));
						if(mode == 3) /* XOR not works with lines ? */
						{
							patterny = ((patterny >> 8) & 0x00ff00ff) | (patterny & 0xff00ff00);
							info->fbops->SetupForMono8x8PatternFill(info,(int)patterny,(int)patterny,(int)foreground,(int)background,rop,0xffffffff);
							info->fbops->SubsequentMono8x8PatternFillRect(info,0,0,(int)y1,(int)y,(int)(y2-y1+1),1);
						}
						else
						{
							info->fbops->SetupForDashedLine(info,(int)foreground,(int)background,rop,0xffffffff,32,(unsigned char *)&patterny);
							info->fbops->SubsequentDashedTwoPointLine(info,(int)y1,(int)y,(int)y2,(int)y,OMIT_LAST,0);
						}
						break;
				}
			}
		}
	}
	return(1);
}

long CDECL c_text_area(Virtual *vwk, short *text, long length, long dst_x, long dst_y, short *offsets)
{
	int rop, skipleft, effects, rotation;
	long foreground, background, w, h, i, j, k, width, height, shift;
	long src_x, src_y, src_wrap, src_wrap2, x, y, x1, x2, y1, y2, left, top, right, bottom;
	unsigned long data, mask;
	unsigned long *lptr, *lptr2;
	unsigned short *sptr;
	short *offset;
	unsigned char *font, *chardata, *bitmap, *bitmap2, *ptr, *ptr2, *src_buf;
	struct fb_info *info = info_fvdi;
	if((info->par == NULL) || (info->screen_mono != NULL)) /* Videl driver */
		return(0);
	font = (unsigned char *)vwk->text.current_font->extra.unpacked.data;
	if(!font)			  /* Must have unpacked data */
		return(0);
	if(!(vwk->text.current_font->flags & 8)) /* proportionnal font */
		return(0);
	w = vwk->text.current_font->widest.cell; /* Used to be character, which was wrong */
	if(w > 8)
		return(0);
	h = vwk->text.current_font->height;
	if(!vwk->clip.on)
	{
		left   = 0;
		top    = 0;
		right  = (long)info->var.xres_virtual-1;
		bottom = (long)info->var.yres_virtual-1;
	}
	else
	{
		left   = (long)vwk->clip.rectangle.x1;
		top    = (long)vwk->clip.rectangle.y1;
		right  = (long)vwk->clip.rectangle.x2;
		bottom = (long)vwk->clip.rectangle.y2;
	}
	get_colours_r(vwk, *(long *)&vwk->text.colour, &foreground, &background);
 	switch(vwk->mode)
	{
		case 1:  /* AND replace (col AND obj) */
			rop = 3;
			break;
		case 2:  /* transparent (col AND obj) OR (old AND NOT obj) */
#ifndef DRIVER_IN_ROM
			if(!init_screen)
				return(0); /* not works, if fVDI started from desktop */
#endif
			rop = 3;
			background = -1;
			break;
		case 3:  /* XOR         (obj XOR old)  */
			rop = 6;
			switch(info->var.bits_per_pixel)
			{
				case 8: foreground = 0xff; break;
				case 16: foreground = 0xffff; break;
				default: foreground = 0xffffff; break;
			}
			background = -1;
			break;
		case 4:  /* reverse transparent (old AND obj) OR (col AND not obj) */
			rop = 12;
			background = -1;
			break;
		default:
			return(1);
 	}
	effects = (int)vwk->text.effects;
	rotation = (int)vwk->text.rotation;
 	if(w != 8 || effects || rotation)
 	{
 		if(offsets)
 		{
			offset = offsets;
			width = w;
			height = h;
			i = length;
			while(--i >= 0)
			{
				width += (long)*offset++;
				height += (long)*offset++;
			} 		
 		}
 		else
 		{
			width = w * length;
			if(effects & 4) /* italic */
				width +=	((long)vwk->text.current_font->offset.left + (long)vwk->text.current_font->offset.right);
			height = h;		
		}
		switch(rotation)
		{
			case 900:
				dst_x += (&vwk->text.current_font->extra.distance.base)[vwk->text.alignment.vertical];
				dst_y -= (width -1);
				x1 = dst_x;
				y1 = dst_y;
				x2 = dst_x + height - 1;
				y2 = dst_y + width - 1;
				break;
			case 1800:
				dst_y -= (&vwk->text.current_font->extra.distance.base)[vwk->text.alignment.vertical];
				dst_x -= (width -1);
				dst_y -= (height -1);
				x1 = dst_x;
				y1 = dst_y;
				x2 = dst_x + width - 1;
				y2 = dst_y + height - 1;
				break;
			case 2700:
				dst_x -= (&vwk->text.current_font->extra.distance.base)[vwk->text.alignment.vertical];
				dst_x -= (height -1);
				x1 = dst_x;
				y1 = dst_y;
				x2 = dst_x + height - 1;
				y2 = dst_y + width - 1;
				break;
			default:
				dst_y += (&vwk->text.current_font->extra.distance.base)[vwk->text.alignment.vertical];
				x1 = dst_x;
				y1 = dst_y;
				x2 = dst_x + width - 1;
				y2 = dst_y + height - 1;
				break;
		}
		if(x1 < left)
		{
			if(x2 < left)
				return(1);
			x1 = left;
		}
		if(y1 < top)
		{
			if(y2 < top)
				return(1);
			y1 = top;
		}
		if(x2 > right)
		{
			if(x1 > right)
				return(1);
			x2 = right;
		}
		if(y2 > bottom)
		{
			if(y1 > bottom)
				return(1);
			y2 = bottom;
		}
		src_x = x1 - dst_x;
		src_y = y1 - dst_y;
		src_wrap2 = src_wrap = ((width + 31) & ~31) >> 3;
		j = ((src_wrap * height) + 31) & ~31;
		bitmap = (unsigned char *)Funcs_allocate_block(j * 2); /* x 2  for outline */
		if(!bitmap)
			return(0);
		bitmap2 = bitmap + j;
		memset(bitmap, 0, j);
		x = y = 0;
		while(--length >= 0)
		{
			chardata = &font[*text++ * 16];
			if(offsets)
			{
				x += (long)*offsets++;
				y += (long)*offsets++;
			}
			ptr = &bitmap[(y * src_wrap) + ((x >> 4) * 2)];
			shift = 24 - (x & 15);
			for(j = height - 1; j >= 0; j--)
			{
				*(unsigned long *)ptr |= (((unsigned long)*chardata++) << shift);
				ptr += src_wrap;
			}
			if(!offsets)
				x += w; 
		}
		if(effects & 1) /* bold */
		{
			shift = (long)vwk->text.current_font->thickening;
			lptr = (unsigned long *)bitmap;
			for(i = height - 1; i >= 0; i--)
			{
        for(j = (src_wrap >> 2) - 1; j >= 0; j--)
        {
					data = *lptr;
					k = shift;
					while(--k >= 0)
						data |= (data >> 1);
					*lptr++ = data;
				}
			}
		}
		if(effects & 8) /* underline */
		{
			i = src_wrap * ((long)vwk->text.current_font->distance.top + 1);
			lptr = (unsigned long *)(bitmap + i);
			i = vwk->text.current_font->underline;
			while(--i >= 0)
			{
        for(j = (src_wrap >> 2) - 1; j >= 0; j--)
					*lptr++ = 0xffffffff;
			}
		}
		if(effects & 4) /* italic */
		{
			i = (long)vwk->text.current_font->distance.bottom + (long)vwk->text.current_font->distance.top + 1;
			ptr = bitmap + (src_wrap * i);
			k = (long)vwk->text.current_font->skewing;
			shift = 0;
			for(i = i - 1; i >= 0; i--)
			{
				sptr = (unsigned short *)ptr;
        for(j = (src_wrap >> 1) - 2; j >= 0; j--)
        {
					data = *((unsigned long *)&sptr[-2]) >> shift;
					*--sptr = (unsigned short)data;
				}
				data = (unsigned long)*--sptr >> shift;
				*sptr = (unsigned short)data;
				ptr -= src_wrap;
				if(k & 0x8000)
					shift++;
				k <<= 1;
			}
    }
		if(effects & 16) /* outline */
		{
			unsigned long data1, data2;
			unsigned short *sptr2 = (unsigned short *)bitmap2;
			sptr = (unsigned short *)bitmap;
			for(i = height - 1; i >= 0; i--)
			{
				data2 = data1 = (unsigned long)*sptr++;
				for(j = (src_wrap >> 1) - 1; j >= 0; j--)
        {
        	data = data1;
					data2 <<= 16;
					data2 |= (unsigned long)*sptr++;
					data1 >>= 1;
					data |= data1;
					data1 = data2 << 1;
					data1 >>= 16;
					data |= data1;
					data1 = data2;
					*sptr2++ = (unsigned short)data; /* <-> bold */
				}
				sptr--;
			}
			lptr = (unsigned long *)bitmap;
			lptr2= (unsigned long *)bitmap2;
			for(j = (src_wrap >> 2) - 1; j >= 0; j--)
			{
				ptr = (unsigned char *)lptr;       /* original source */
				ptr2 = (unsigned char *)lptr2;     /* source bold */
				data = 0;
				data1 = *(unsigned long *)ptr2;
				ptr2 += src_wrap;
				for(i = height - 1; i >= 0; i--)
				{
					data2 = *(unsigned long *)ptr2;  /* bold ^ */
					data |= data1;                   /*      v */
					data |= data2;
					data ^= *(unsigned long *)ptr;   /* EOR    */
					*(unsigned long *)ptr2 = data;
					data = data1;
					data1 = data2;
					ptr += src_wrap;
					ptr2 += src_wrap;
				}
				data |= data1;
				*(unsigned long *)ptr2 = data;
				lptr++;
				lptr2++;
			}
			memcpy(bitmap, bitmap2, (long)(bitmap2 - bitmap));
		}
		if(effects & 2) /* light */
		{
			data = (unsigned long)vwk->text.current_font->lightening;
			data |= (data << 16);
			lptr = (unsigned long *)bitmap;
			for(i = height - 1; i >= 0; i--)
			{
        for(j = (src_wrap >> 2) - 1; j >= 0; j--)
					 *lptr++ &= data;
				data = (data << 1) | (data >> 31);
			}
		}
		switch(rotation)
		{
			case 900:
				src_wrap2 = ((height + 31) & ~31) >> 3;
				j = ((src_wrap2 * width) + 31) & ~31;
				bitmap2 = (unsigned char *)Funcs_allocate_block(j);
				if(!bitmap2)
				{
					Funcs_free_block(bitmap);
					return(0);
				}
				memset(bitmap2, 0, j);
				ptr = bitmap;
				lptr2 = (unsigned long *)(bitmap2 + (src_wrap2 * (width - 1)));
				data = 0x80000000;
				for(i = height - 1; i >= 0; i--)
				{
					lptr = (unsigned long *)ptr;
					ptr2 = (unsigned char *)lptr2;
					mask = 0x80000000; 
					for(j = width - 1; j >=0; j--)
					{
						if(*lptr & mask)
            	*(unsigned long *)ptr2 |= data;
						mask >>= 1;
						if(!mask)
						{
							mask = 0x80000000;
							lptr ++;
						}
						ptr2 -= src_wrap2;						
					}
					data >>= 1;
					ptr += src_wrap;
				}
				Funcs_free_block(bitmap);
				bitmap = bitmap2;
				src_wrap = src_wrap2;
				break;
			case 1800:
				bitmap2 = (unsigned char *)Funcs_allocate_block(src_wrap * height);
				if(!bitmap2)
				{
					Funcs_free_block(bitmap);
					return(0);
				}
				lptr = (unsigned long *)bitmap;
				lptr2 = (unsigned long *)(bitmap2 + (src_wrap * height));
				for(i = ((src_wrap >> 2) * height) -1; i >= 0; i--)
				{
					data = 0;
					mask = *lptr++;
					if(mask & 0x80000000)
						data |= 0x00000001;
					if(mask & 0x40000000)
						data |= 0x00000002;
					if(mask & 0x20000000)
						data |= 0x00000004;
					if(mask & 0x10000000)
						data |= 0x00000008;
					if(mask & 0x08000000)
						data |= 0x00000010;
					if(mask & 0x04000000)
						data |= 0x00000020;
					if(mask & 0x02000000)
						data |= 0x00000040;
					if(mask & 0x01000000)
						data |= 0x00000080;
					if(mask & 0x00800000)
						data |= 0x00000100;
					if(mask & 0x00400000)
						data |= 0x00000200;
					if(mask & 0x00200000)
						data |= 0x00000400;
					if(mask & 0x00100000)
						data |= 0x00000800;
					if(mask & 0x00080000)
						data |= 0x00001000;
					if(mask & 0x00040000)
						data |= 0x00002000;
					if(mask & 0x00020000)
						data |= 0x00004000;
					if(mask & 0x00010000)
						data |= 0x00008000;
					if(mask & 0x00008000)
						data |= 0x00010000;
					if(mask & 0x00004000)
						data |= 0x00020000;
					if(mask & 0x00002000)
						data |= 0x00040000;
					if(mask & 0x00001000)
						data |= 0x00080000;
					if(mask & 0x00000800)
						data |= 0x00100000;
					if(mask & 0x00000400)
						data |= 0x00200000;
					if(mask & 0x00000200)
						data |= 0x00400000;
					if(mask & 0x00000100)
						data |= 0x00800000;
					if(mask & 0x00000080)
						data |= 0x01000000;
					if(mask & 0x00000040)
						data |= 0x02000000;
					if(mask & 0x00000020)
						data |= 0x04000000;
					if(mask & 0x00000010)
						data |= 0x08000000;
					if(mask & 0x00000008)
						data |= 0x10000000;
					if(mask & 0x00000004)
						data |= 0x20000000;
					if(mask & 0x00000002)
						data |= 0x40000000;
					if(mask & 0x00000001)
						data |= 0x80000000;
					*--lptr2 = data;
				}
				src_x += ((src_wrap << 3) - width);
				Funcs_free_block(bitmap);
				bitmap = bitmap2;			
				src_wrap = src_wrap2;
				break;
			case 2700:
				src_wrap2 = ((height + 31) & ~31) >> 3;
				j = ((src_wrap2 * width) + 31) & ~31;
				bitmap2 = (unsigned char *)Funcs_allocate_block(j);
				if(!bitmap2)
				{
					Funcs_free_block(bitmap);
					return(0);
				}
				memset(bitmap2, 0, j);
				ptr = bitmap;
				lptr2 = (unsigned long *)bitmap2;
				data = 0x00000001;
				for(i = height - 1; i >= 0; i--)
				{
					lptr = (unsigned long *)ptr;
					ptr2 = (unsigned char *)lptr2;
					mask = 0x80000000; 
					for(j = width - 1; j >=0; j--)
					{
						if(*lptr & mask)
            	*(unsigned long *)ptr2 |= data;
						mask >>= 1;
						if(!mask)
						{
							mask = 0x80000000;
							lptr ++;
						}
						ptr2 += src_wrap2;						
					}
					data <<= 1;
					ptr += src_wrap;
				}			
				src_x += ((src_wrap2 << 3) - height);
				Funcs_free_block(bitmap);
				bitmap = bitmap2;
				src_wrap = src_wrap2;
				break;
		}
 	}
	else if(offsets) /* normal justified text => faster */
	{
		dst_y += (&vwk->text.current_font->extra.distance.base)[vwk->text.alignment.vertical];
		offset = offsets;
		width = w;
		height = h;
		i = length;
		while(--i >= 0)
		{
			width += (long)*offset++;
			height += (long)*offset++;
		}
		x1 = dst_x;
		y1 = dst_y;
		x2 = dst_x + width - 1;
		y2 = dst_y + height - 1;
		if(x1 < left)
		{
			if(x2 < left)
				return(1);
			x1 = left;
		}
		if(y1 < top)
		{
			if(y2 < top)
				return(1);
			y1 = top;
		}
		if(x2 > right)
		{
			if(x1 > right)
				return(1);
			x2 = right;
		}
		if(y2 > bottom)
		{
			if(y1 > bottom)
				return(1);
			y2 = bottom;
		}
		src_x = x1 - dst_x;
		src_y = y1 - dst_y;
		src_wrap = ((width + 31) & ~31) >> 3;
		j = ((src_wrap * height) + 31) & ~31;
		bitmap = (unsigned char *)Funcs_allocate_block(j);
		if(!bitmap)
			return(0);
		memset(bitmap, 0, j);
		x = y = 0;
		if(h == 16)
		{
			while(--length >= 0)
			{
				chardata = &font[*text++ * 16];
				x += (long)*offsets++;
				y += (long)*offsets++;
				ptr = &bitmap[(y * src_wrap) + ((x >> 4) * 2)];
				shift = 24 - (x & 15);
				*(unsigned long *)ptr |= (((unsigned long)*chardata++) << shift);
				ptr += src_wrap;
				*(unsigned long *)ptr |= (((unsigned long)*chardata++) << shift);
				ptr += src_wrap;
				*(unsigned long *)ptr |= (((unsigned long)*chardata++) << shift);
				ptr += src_wrap;
				*(unsigned long *)ptr |= (((unsigned long)*chardata++) << shift);
				ptr += src_wrap;
				*(unsigned long *)ptr |= (((unsigned long)*chardata++) << shift);
				ptr += src_wrap;
				*(unsigned long *)ptr |= (((unsigned long)*chardata++) << shift);
				ptr += src_wrap;
				*(unsigned long *)ptr |= (((unsigned long)*chardata++) << shift);
				ptr += src_wrap;
				*(unsigned long *)ptr |= (((unsigned long)*chardata++) << shift);
				ptr += src_wrap;
				*(unsigned long *)ptr |= (((unsigned long)*chardata++) << shift);
				ptr += src_wrap;
				*(unsigned long *)ptr |= (((unsigned long)*chardata++) << shift);
				ptr += src_wrap;
				*(unsigned long *)ptr |= (((unsigned long)*chardata++) << shift);
				ptr += src_wrap;
				*(unsigned long *)ptr |= (((unsigned long)*chardata++) << shift);
				ptr += src_wrap;
				*(unsigned long *)ptr |= (((unsigned long)*chardata++) << shift);
				ptr += src_wrap;
				*(unsigned long *)ptr |= (((unsigned long)*chardata++) << shift);
				ptr += src_wrap;
				*(unsigned long *)ptr |= (((unsigned long)*chardata++) << shift);
				ptr += src_wrap;
				*(unsigned long *)ptr |= (((unsigned long)*chardata++) << shift);
			}
		}
		else
		{
			while(--length >= 0)
			{
				chardata = &font[*text++ * 16];
				x += (long)*offsets++;
				y += (long)*offsets++;
				ptr = &bitmap[(y * src_wrap) + ((x >> 4) * 2)];
				shift = 24 - (x & 15);
				for(j = h - 1; j >= 0; j--)
				{
					*(unsigned long *)ptr |= (((unsigned long)*chardata++) << shift);
					ptr += src_wrap;
				}
			}
		}			
	}
	else  /* normal text => faster */
	{
		dst_y += (&vwk->text.current_font->extra.distance.base)[vwk->text.alignment.vertical];
		width = (w * length);
		if((dst_y + h <= top) || (dst_y > bottom)
		 || (dst_x + width <= left) || (dst_x >  right))
			return(1);
		if(dst_x + width - w > right)
			length -= ((dst_x + width - right - 1) / w) ;
		if(dst_x + w <= left)
		{
			i = (left - dst_x) / w;
			length -= i;
			dst_x += (w * i);
			text += i;
		}
		if(length <= 0)
			return(1);
		src_wrap = (length + 3) & ~3;
		bitmap = (unsigned char *)Funcs_allocate_block(src_wrap * h);
		if(!bitmap)
			return(0);
		if(h == 16)
		{
			for(i = 0; i < length; i++)
			{
				chardata = &font[*text++ * 16];
				ptr = bitmap + i;
				*ptr = *chardata++;
				ptr += src_wrap;
				*ptr = *chardata++;
				ptr += src_wrap;
				*ptr = *chardata++;
				ptr += src_wrap;
				*ptr = *chardata++;
				ptr += src_wrap;
				*ptr = *chardata++;
				ptr += src_wrap;
				*ptr = *chardata++;
				ptr += src_wrap;
				*ptr = *chardata++;
				ptr += src_wrap;
				*ptr = *chardata++;
				ptr += src_wrap;
				*ptr = *chardata++;
				ptr += src_wrap;
				*ptr = *chardata++;
				ptr += src_wrap;
				*ptr = *chardata++;
				ptr += src_wrap;
				*ptr = *chardata++;
				ptr += src_wrap;
				*ptr = *chardata++;
				ptr += src_wrap;
				*ptr = *chardata++;
				ptr += src_wrap;
				*ptr = *chardata++;
				ptr += src_wrap;
				*ptr = *chardata++;
			}		
		}
		else
		{
			for(i = 0; i < length; i++)
			{
				chardata = &font[*text++ * 16];
				ptr = bitmap + i;
				for(j = h -1; j >= 0; j--)
				{
					*ptr = *chardata++;
					ptr += src_wrap;
				}
			}
		}
		w *= length;
		x1 = dst_x;
		y1 = dst_y;
		x2 = dst_x + w - 1;
		y2 = dst_y + h - 1;
		if(x1 < left)
			x1 = left;
		if(y1 < top)
			y1 = top;
		if(x2 > right)
			x2 = right;
		if(y2 > bottom)
			y2 = bottom;
		src_x = x1 - dst_x;
		src_y = y1 - dst_y;
	}
 	dst_x = x1;
 	dst_y = y1;
 	w = x2 - x1 + 1;
 	h = y2 - y1 + 1;
	if((w > 0) && (h > 0))
	{
#ifdef DRIVER_IN_ROM
		wait_dma();
#endif
		src_buf = bitmap;
		src_buf += (src_y * src_wrap);
		src_buf += ((src_x >> 3) & ~1);
		info->fbops->SetClippingRectangle(info,(int)dst_x,(int)dst_y,(int)x2,(int)y2);
		skipleft = ((int)src_buf & 3) << 3;
		src_buf = (unsigned char*)((long)src_buf & ~3);
		skipleft += (int)(src_x & 15);
		dst_x -= (long)skipleft;
		w += (long)skipleft;
		info->fbops->SetupForScanlineCPUToScreenColorExpandFill(info,(int)foreground,(int)background,rop,0xffffffff);
		info->fbops->SubsequentScanlineCPUToScreenColorExpandFill(info,(int)dst_x,(int)dst_y,(int)w,(int)h,skipleft);
		while(--h >= 0)
		{
			info->fbops->SubsequentScanline(info, (unsigned long *)src_buf);
			src_buf += src_wrap;
		}
		info->fbops->DisableClipping(info);
	}
	Funcs_free_block(bitmap);
	return(1);
}

long CDECL c_set_colour(Virtual *vwk, long index, long red, long green, long blue)
{
	int ret;
	struct fb_info *info = info_fvdi;
	if(info->par == NULL) /* Videl driver */
		return(0);
	if(info->var.bits_per_pixel == 8)
	{
		index = toTosColors(index);
		red *= 255;
		green *= 255;
		blue *= 255; 
		red /= 1000;
		green /= 1000;
		blue /= 1000;
		ret = info->fbops->fb_setcolreg((unsigned)index,(unsigned)red<<8,(unsigned)green<<8,(unsigned)blue<<8,0,info);
		return(!ret ? 1 : 0);
	}
	return(0);
}

#ifndef DRIVER_IN_ROM

static struct mode_option s_resolution, g_resolution;
static short current_modecode;
static short exact_modecode;
static short near_modecode;
static short near_col_modecode;

static long g_enumfunc(SCREENINFO *inf, long flag)
{
	if(flag);
	if(current_modecode == (short)inf->devID)
	{
		g_resolution.used = 1;
		g_resolution.width = (short)inf->scrWidth;
		g_resolution.height = (short)inf->scrHeight;
		g_resolution.bpp = (short)(1 << (inf->devID & NUMCOLS));
		g_resolution.freq = (short)inf->refresh;
		return(0);
	}
	return(1);
}

static long s_enumfunc(SCREENINFO *inf, long flag)
{
	if(flag);
	if((s_resolution.width == (short)inf->scrWidth) && (s_resolution.height == (short)inf->scrHeight))
	{
		if(s_resolution.bpp == (short)(1 << (inf->devID & NUMCOLS)))
		{
		 	if(s_resolution.freq == (short)inf->refresh)
		 	{
				exact_modecode = (short)inf->devID;
				return(0);
			}
			else if(inf->refresh == 60)
		  	near_modecode = (short)inf->devID;
		}
		else if((inf->refresh == 60) && ((inf->devID & NUMCOLS) == BPS8))
			near_col_modecode = (short)inf->devID;		
	}
	return(1);
}

long CDECL c_get_resolution(struct mode_option *resolution)
{
	g_resolution.used = 0;
	current_modecode = Vsetmode(-1);
	Vsetscreen(-1, &g_enumfunc, 'VN', CMD_ENUMMODES);
	*resolution = g_resolution;
	return(1);
}

long CDECL c_set_resolution(struct mode_option *resolution)
{
	struct fb_info *info = info_fvdi;
	struct fb_var_screeninfo var;
	s_resolution = *resolution;
	exact_modecode = near_modecode = near_col_modecode = 0;
	if(use_setscreen)
	{
		short modecode = 0;
		long ret = Vsetscreen(-1, &s_enumfunc, 'VN', CMD_ENUMMODES);
		if(exact_modecode)
			modecode = exact_modecode;
		else if(near_modecode)
			modecode = near_modecode;
		else if(near_col_modecode)
			modecode = near_col_modecode;
		if(virtual)
			modecode |= VIRTUAL_SCREEN;
		if(modecode && ret && (ret >> 16) && ((ret >> 16) != -1))
		{
			Vsetscreen(0, 0,	3, modecode);
			info_fvdi = (struct fb_info *)ret; /* use the same structure than TOS ! */
			buf_cursor = 0;
#ifndef DRIVER_IN_ROM
			init_screen = 1;
#endif
			return(1);
		}
	}
	if(info->par == NULL) /* Videl driver */
	{
#ifdef DRIVER_IN_ROM
#ifdef COLDFIRE
		if(resolution->used)
		{
			long addr = init_videl((long)resolution->width, (long)resolution->height, (long)resolution->bpp, (long)resolution->freq);
     	if(addr)
     	{
				info->screen_base = (char *)addr;
				info->var.xres = info->var.xres_virtual = (int)resolution->width;
				info->var.yres = info->var.yres_virtual = (int)resolution->height;
				info->var.bits_per_pixel = (int)resolution->bpp;
				return(1);
			}
			return(0);
		}
#endif /* COLDFIRE */
#endif /* DRIVER_IN_ROM */
		return(0);
	}
	resolution->flags &= ~MODE_EMUL_MONO_FLAG;
	if(resolution->bpp < 8)
	{
		if(resolution->bpp == 1)
			resolution->flags |= MODE_EMUL_MONO_FLAG;
	}
	info->fbops->fb_check_modes(info, resolution);
	memcpy(&var, &info->var, sizeof(struct fb_var_screeninfo));
	if(virtual)
	{
		var.xres_virtual = var.xres * 2;
		var.yres_virtual = var.yres * 2;	
		if(var.xres_virtual > 2048)
			var.xres_virtual = 2048;
		if(var.yres_virtual > 2048)
			var.yres_virtual = 2048;	
	}
	var.activate = (FB_ACTIVATE_FORCE|FB_ACTIVATE_NOW);
	if(fb_set_var(info, &var) == 0)
	{
		int i, red=0, green=0, blue=0;
		switch(info->var.bits_per_pixel)
		{
			case 16:
				for(i=0;i<64;i++)
				{
					if(red > 65535)
						red = 65535;
					if(green > 65535)
						green = 65535;
					if(blue > 65535)
						blue = 65535;
					info->fbops->fb_setcolreg((unsigned)i,red,green,blue,0,info);
					green += 1024;   /* 6 bits */
					red += 2048;     /* 5 bits */
					blue += 2048;    /* 5 bits */
				}
				break;
			case 24:
			case 32:
				for(i=0;i<256;i++)
				{
					if(red > 65535)
						red = 65535;
					if(green > 65535)
						green = 65535;
					if(blue > 65535)
						blue = 65535;
					info->fbops->fb_setcolreg((unsigned)i,red,green,blue,0,info);
					green += 256;    /* 8 bits */
					red += 256;      /* 8 bits */
					blue += 256;     /* 8 bits */
				}
				break;
		}
		if(resolution->flags & MODE_EMUL_MONO_FLAG)
		{
			info->screen_mono = (char *)Srealloc((info->var.xres_virtual * info->var.yres_virtual) >> 3);
			if(info->screen_mono != NULL)
				memset(info->screen_mono, 0, (info->var.xres_virtual * info->var.yres_virtual) >> 3);
		}
		else
			info->screen_mono = NULL;
		if(info->var.bits_per_pixel >= 16)
			info->fbops->SetupForSolidFill(info,0,15,0xffffffff);  /* set */
		else
			info->fbops->SetupForSolidFill(info,0,0,0xffffffff);   /* clr */
		info->fbops->SubsequentSolidFillRect(info,0,0,(int)info->var.xres_virtual,(int)info->var.yres_virtual);
		offscreen_init(info);
		buf_cursor = 0;
#ifndef DRIVER_IN_ROM
		init_screen = 1;
#endif
		return(1);	
	}
	return(0);
}

#endif /* DRIVER_IN_ROM */

long CDECL c_get_videoramaddress()
{
	if(info_fvdi->par == NULL) /* Videl driver */
		return((long)(info_fvdi->screen_base=Physbase()));
	if(info_fvdi->screen_mono != NULL) /* VBL mono emulation */
		return((long)info_fvdi->screen_mono);	
	return((long)info_fvdi->screen_base);
}

long CDECL c_get_width(void)
{
	return((long)info_fvdi->var.xres);
}

long CDECL c_get_height(void)
{
	return((long)info_fvdi->var.yres);
}

long CDECL c_get_width_virtual(void)
{
	return((long)info_fvdi->var.xres_virtual);
}

long CDECL c_get_height_virtual(void)
{
	return((long)info_fvdi->var.yres_virtual);
}

long CDECL c_get_bpp(void)
{
	return((long)info_fvdi->var.bits_per_pixel);
}

long CDECL c_get_bpp_virtual(void)
{
	if(info_fvdi->screen_mono != NULL) /* VBL mono emulation */
		return(1);
	return((long)info_fvdi->var.bits_per_pixel);
}

long CDECL c_init_cursor(void)
{
	if(info_fvdi->par == NULL) /* Videl driver */
		return(0);
	return(info_fvdi->fbops->CursorInit(info_fvdi)); /* buffer */
}

long CDECL c_free_cursor(long buf)
{
	if(info_fvdi->par == NULL) /* Videl driver */
		return(0);
	return(offscreen_free(info_fvdi, buf));
}


