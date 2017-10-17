/* TOS 4.04 Xbios calls for the CT60/CTPCI & Coldfire boards
 * Coldfire Xbios AC97 Sound 
 * Didier Mequignon 2005-2011, e-mail: aniplay@wanadoo.fr
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
 * along with program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include "config.h" 
#include <mint/mintbind.h>
#include <mint/falcon.h>
#include <mint/sysvars.h>
#include <string.h>
#include "fb.h"
#include "radeon/radeonfb.h"
#include "lynx/smi.h"
#include "ct60.h"
#ifdef NETWORK
#ifdef COLDFIRE
#ifndef MCF5445X
#include "ac97/mcf548x_ac97.h"
#endif
#endif
#endif

extern void init_var_linea(long video_found);
extern long call_enumfunc(long (*enumfunc)(SCREENINFO *inf, long flag), SCREENINFO *inf, long flag);
#ifdef COLDFIRE
extern long init_videl(long width, long height, long bpp, long freq, long extended);
extern void setrgb_videl(long index, long rgb, long type);
#endif
#if defined(COLDFIRE) && defined(NETWORK) && defined(LWIP)
extern void board_printf(const char *fmt, ...);
#else
#define board_printf kprint
extern void kprint(const char *fmt, ...);
#endif

unsigned long physbase(void);
long vgetsize(long modecode);
long validmode(long modecode);

extern void ltoa(char *buf, long n, unsigned long base);                                    
extern void cursor_home(void);
#ifdef COLDFIRE
extern void videl_blank(long blank);
#endif
   
#define XBIOS_SCREEN_VERSION 0x0101

#define Modecode (*((short*)0x184C))

typedef struct
{
	long ident;
	union
	{
		long l;
		short i[2];
		char c[4];
	} v;
} COOKIE;

extern COOKIE *get_cookie(long id);
extern int add_cookie(COOKIE *cook);

/* global */
extern struct fb_info *info_fvdi;
extern struct mode_option resolution;
extern const struct fb_videomode modedb[];
extern const struct fb_videomode vesa_modes[];
extern long total_modedb;
extern short video_found, video_log, os_magic, memory_ok, drive_ok;
long fix_modecode, second_screen, second_screen_aligned, log_addr;

static short modecode_magic;
static long bios_colors[256]; 

/* some XBIOS functions for the video driver */

#ifdef RADEON_RENDER
int display_composite_texture(long op, char *src_tex, long src_x, long src_y, long w_tex, long h_tex, long dst_x, long dst_y, long width, long height)
{
	struct fb_info *info = info_fvdi;
	unsigned long dstFormat;
	if(info->screen_mono != NULL)
		return(0);
	switch(info->var.bits_per_pixel)
	{
		case 16: dstFormat = PICT_r5g6b5; break;
		case 32: dstFormat = PICT_x8r8g8b8; break;
		default: return(0);	
	}
	if(info->fbops->SetupForCPUToScreenTexture(info, (int)op, PICT_a8r8g8b8, dstFormat, src_tex, (int)w_tex << 2 , (int)w_tex, (int)h_tex, 0))
	{
		long x, y, x0 = dst_x;
		for(y = 0; y < height; y += h_tex)
		{
			int h = height - y;
			if(h >= h_tex)
				h = h_tex;
			dst_x = x0;
			for(x = 0; x < width; x += w_tex)
			{
				int w = width - x;
				if(w >= w_tex)
					w = w_tex;
				info->fbops->SubsequentCPUToScreenTexture(info, (int)dst_x, (int)dst_y, (int)src_x, (int)src_y, (int)w, (int)h);
				dst_x += w_tex;		
			}
			dst_y += h_tex;
		}
	}
	return(1);
}
#endif /* RADEON_RENDER */

void display_mono_block(char *src_buf, long dst_x, long dst_y, long w, long h, long foreground, long background, long src_wrap)
{
	int skipleft;
	if(info_fvdi->screen_mono != NULL)
		return;
	info_fvdi->fbops->SetClippingRectangle(info_fvdi, (int)dst_x, (int)dst_y, (int)w - 1, (int)h -1);
	skipleft = ((int)src_buf & 3) << 3;
	src_buf = (char *)((int)src_buf & ~3);
	dst_x -= skipleft;
	w += skipleft;
	info_fvdi->fbops->SetupForScanlineCPUToScreenColorExpandFill(info_fvdi, (int)foreground, (int)background, 3, 0xffffffff);
	info_fvdi->fbops->SubsequentScanlineCPUToScreenColorExpandFill(info_fvdi, (int)dst_x, (int)dst_y, (int)w, (int)h, (int)skipleft);
	while(--h >= 0)
	{
		info_fvdi->fbops->SubsequentScanline(info_fvdi, (unsigned long*)src_buf);
		src_buf += src_wrap;
	}
	info_fvdi->fbops->DisableClipping(info_fvdi);
	info_fvdi->fbops->fb_sync(info_fvdi);	
}

long clear_screen(long bg_color, long x, long y, long w, long h)
{
	struct fb_info *info = info_fvdi;
	if(info->screen_mono != NULL)
		return(0);
	if(bg_color == -1)
	{
		x = y = 0;
		w = info->var.xres_virtual;
		h = info->var.yres_virtual;
		if(info->var.bits_per_pixel >= 16)
			info->fbops->SetupForSolidFill(info, 0, 15, 0xffffffff);  /* set */
		else
			info->fbops->SetupForSolidFill(info, 0, 0, 0xffffffff);   /* clr */
	}
	else if(bg_color == -2)
	{
		switch(info->var.bits_per_pixel)
		{
			case 8: bg_color = 0xff; break;
			case 16: bg_color = 0xffff; break;
			default: bg_color = 0xffffff; break;
		}
		info->fbops->SetupForSolidFill(info, (int)bg_color, 6, 0xffffffff);  /* xor */
	}
	else
		info->fbops->SetupForSolidFill(info, (int)bg_color, 3, 0xffffffff);  /* copy */
	info->fbops->SubsequentSolidFillRect(info, (int)x, (int)y, (int)w, (int)h);
	info->fbops->fb_sync(info);
	return(1);
}

long fill_screen(long op, long bg_color, long x, long y, long w, long h)
{
	struct fb_info *info = info_fvdi;
	if(info->screen_mono != NULL)
		return(0);
	info->fbops->SetupForSolidFill(info, (int)bg_color, (int)op, 0xffffffff);
	info->fbops->SubsequentSolidFillRect(info, (int)x, (int)y, (int)w, (int)h);
	info->fbops->fb_sync(info);
	return(1);
}

long line_screen(long op, long fg_color, long bg_color, long x1, long y1, long x2, long y2, long pattern)
{
	struct fb_info *info = info_fvdi;
	if(info->screen_mono != NULL)
		return(0);
	if(pattern == -1) /* solid line */
	{
		info->fbops->SetupForSolidLine(info, (int)fg_color, (int)op, 0xffffff);
		if(info->fbops->SubsequentSolidTwoPointLine == NULL)
			return(0);
		info->fbops->SubsequentSolidTwoPointLine(info, (int)x1, (int)y1, (int)x2, (int)y2, OMIT_LAST);	
	}
	else
	{
		if(info->fbops->SetupForDashedLine == NULL)
			return(0);
		info->fbops->SetupForDashedLine(info, (int)fg_color, (int)bg_color, (int)op, 0xffffffff, 32, (unsigned char *)&pattern);
		info->fbops->SubsequentDashedTwoPointLine(info, (int)x1, (int)y1, (int)x2, (int)y2, OMIT_LAST,0);
	}
	return(1);
}							

long move_screen(long src_x, long src_y, long dst_x, long dst_y, long w, long h)
{
	int xdir = (int)(src_x - dst_x);
	int ydir = (int)(src_y - dst_y);
	if(info_fvdi->screen_mono != NULL)
		return(0);
	info_fvdi->fbops->SetupForScreenToScreenCopy(info_fvdi, xdir, ydir, 3, 0xffffffff, -1);
	info_fvdi->fbops->SubsequentScreenToScreenCopy(info_fvdi, (int)src_x, (int)src_y, (int)dst_x, (int)dst_y, (int)w, (int)h);
	info_fvdi->fbops->fb_sync(info_fvdi);
	return(1);
}

long copy_screen(long op, long src_x, long src_y, long dst_x, long dst_y, long w, long h)
{
	int xdir = (int)(src_x - dst_x);
	int ydir = (int)(src_y - dst_y);
	if(info_fvdi->screen_mono != NULL)
		return(0);
	info_fvdi->fbops->SetupForScreenToScreenCopy(info_fvdi, xdir, ydir, op, 0xffffffff, -1);
	info_fvdi->fbops->SubsequentScreenToScreenCopy(info_fvdi, (int)src_x, (int)src_y, (int)dst_x, (int)dst_y, (int)w, (int)h);
	info_fvdi->fbops->fb_sync(info_fvdi);
	return(1);
}

long clip_screen(long clip_on, long dst_x, long dst_y, long w, long h)
{
	struct fb_info *info = info_fvdi;
	if(info->screen_mono != NULL)
		return(0);
	if(clip_on)
		info->fbops->SetClippingRectangle(info, (int)dst_x, (int)dst_y, (int)(dst_x + w - 1), (int)(dst_y + h - 1));
	else
		info->fbops->DisableClipping(info);
	return(1);
}

long print_screen(char *character_source, long x, long y, long w, long h, long cell_wrap, long fg_color, long bg_color)
{
	static char buffer[256*16]; /* maximum width 2048 pixels, 256 characters, height 16 */
	static long pos_x, pos_y, length, height, foreground, background, old_timer;
	char *ptr;
	if(info_fvdi->screen_mono != NULL)
		return(0);
	if(character_source == (char *)-1) /* init */
	{
		pos_x = -1;
		old_timer = *_hz_200;
	}
	else if(character_source != NULL)
	{
		if((pos_x >= 0) && ((pos_y != y) /* if line is different  => flush buffer */
		 || (*_hz_200 != old_timer)))
		{
			ptr = &buffer[pos_x];
			pos_x <<= 3;
			pos_y *= height;
			length <<= 3;
			display_mono_block(ptr, pos_x, pos_y, length, height, foreground, background, 256);
			pos_x = -1;
		}
		w >>= 3;
		if(pos_x < 0)
		{
			pos_x = x;        /* save starting pos */
			pos_y = y;
			length = 0;
			height = h;
			foreground = fg_color;
			background = bg_color;
		}
		if((x < 256) && (h <= 16))
		{
			ptr = &buffer[x]; /* store character inside a line buffer */
			switch(w)
			{
				case 0:
				case 1:
					while(--h >= 0)
					{
						*ptr = *character_source;
						character_source += cell_wrap;
						ptr += 256;
					}
					length++;
					break;
				default:
					while(--h >= 0)
					{
						*(short *)ptr = *(short *)character_source;
						character_source += cell_wrap;
						ptr += 256;
					}
					length += w;
					break;
			}
		}
	}
	else if(pos_x >= 0)   /* flush buffer */
	{
		ptr = &buffer[pos_x];
		pos_x <<= 3;
		pos_y *= height;
		length <<= 3;
		display_mono_block(ptr, pos_x, pos_y, length, height, foreground, background, 256);
		pos_x = -1;
	}
	old_timer = *_hz_200;
	return(1);
}

static unsigned long mul32(unsigned long a, unsigned long b) // GCC Colfire bug ???
{
	return(a * b);
}

void display_atari_logo(void)
{
#define WIDTH_LOGO 96
#define HEIGHT_LOGO 86
#ifndef TOS_ATARI_LOGO
	static unsigned short logo[] = 
	{
		0x0000,0x0000,0x79FF,0x3C00,0x0000,0x0000,
		0x0000,0x0000,0x79FF,0x3C00,0x0000,0x0000,
		0x0000,0x0000,0x79FF,0x3C00,0x0000,0x0000,
		0x0000,0x0000,0x79FF,0x3C00,0x0000,0x0000,
		0x0000,0x0000,0x79FF,0x3C00,0x0000,0x0000,
		0x0000,0x0000,0x79FF,0x3C00,0x0000,0x0000,
		0x0000,0x0000,0x79FF,0x3C00,0x0000,0x0000,
		0x0000,0x0000,0x79FF,0x3C00,0x0000,0x0000,
		0x0000,0x0000,0x79FF,0x3C00,0x0000,0x0000,
		0x0000,0x0000,0x79FF,0x3C00,0x0000,0x0000,
		0x0000,0x0000,0x79FF,0x3C00,0x0000,0x0000,
		0x0000,0x0000,0x79FF,0x3C00,0x0000,0x0000,
		0x0000,0x0000,0x79FF,0x3C00,0x0000,0x0000,
		0x0000,0x0000,0x79FF,0x3C00,0x0000,0x0000,
		0x0000,0x0000,0x79FF,0x3C00,0x0000,0x0000,
		0x0000,0x0000,0x79FF,0x3C00,0x0000,0x0000,
		0x0000,0x0000,0xF9FF,0x3E00,0x0000,0x0000,
		0x0000,0x0000,0xF9FF,0x3E00,0x0000,0x0000,
		0x0000,0x0000,0xF9FF,0x3E00,0x0000,0x0000,
		0x0000,0x0000,0xF9FF,0x3E00,0x0000,0x0000,
		0x0000,0x0000,0xF9FF,0x3E00,0x0000,0x0000,
		0x0000,0x0000,0xF9FF,0x3E00,0x0000,0x0000,
		0x0000,0x0001,0xF9FF,0x3F00,0x0000,0x0000,
		0x0000,0x0001,0xF9FF,0x3F00,0x0000,0x0000,
		0x0000,0x0001,0xF9FF,0x3F00,0x0000,0x0000,
		0x0000,0x0001,0xF9FF,0x3F00,0x0000,0x0000,
		0x0000,0x0003,0xF9FF,0x3F80,0x0000,0x0000,
		0x0000,0x0003,0xF9FF,0x3F80,0x0000,0x0000,
		0x0000,0x0003,0xF9FF,0x3F80,0x0000,0x0000,
		0x0000,0x0007,0xF1FF,0x1FC0,0x0000,0x0000,
		0x0000,0x0007,0xF1FF,0x1FC0,0x0000,0x0000,
		0x0000,0x000F,0xF1FF,0x1FE0,0x0000,0x0000,
		0x0000,0x000F,0xF1FF,0x1FE0,0x0000,0x0000,
		0x0000,0x001F,0xE1FF,0x0FF0,0x0000,0x0000,
		0x0000,0x003F,0xE1FF,0x0FF8,0x0000,0x0000,
		0x0000,0x003F,0xE1FF,0x0FF8,0x0000,0x0000,
		0x0000,0x007F,0xC1FF,0x07FC,0x0000,0x0000,
		0x0000,0x00FF,0xC1FF,0x07FE,0x0000,0x0000,
		0x0000,0x01FF,0x81FF,0x03FF,0x0000,0x0000,
		0x0000,0x03FF,0x81FF,0x03FF,0x8000,0x0000,
		0x0000,0x07FF,0x01FF,0x01FF,0xC000,0x0000,
		0x0000,0x0FFE,0x01FF,0x00FF,0xE000,0x0000,
		0x0000,0x1FFE,0x01FF,0x00FF,0xF000,0x0000,
		0x0000,0x7FFC,0x01FF,0x007F,0xFC00,0x0000,
		0x0000,0xFFF8,0x01FF,0x003F,0xFE00,0x0000,
		0x0003,0xFFF0,0x01FF,0x001F,0xFF80,0x0000,
		0x001F,0xFFE0,0x01FF,0x000F,0xFFF0,0x0000,
		0x00FF,0xFFC0,0x01FF,0x0007,0xFFFE,0x0000,
		0x00FF,0xFF80,0x01FF,0x0003,0xFFFE,0x0000,
		0x00FF,0xFF00,0x01FF,0x0001,0xFFFE,0x0000,
		0x00FF,0xFC00,0x01FF,0x0000,0x7FFE,0x0000,
		0x00FF,0xF800,0x01FF,0x0000,0x3FFE,0x0000,
		0x00FF,0xE000,0x01FF,0x0000,0x0FFE,0x0000,
		0x00FF,0x8000,0x01FF,0x0000,0x03FE,0x0000,
		0x00FC,0x0000,0x01FF,0x0000,0x007E,0x0000,
		0x00E0,0x0000,0x01FF,0x0000,0x000E,0x0000,
		0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
		0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
		0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
		0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
		0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
		0x0000,0xC07F,0xFE03,0x0007,0xC01E,0x0700,
		0x0001,0xE07F,0xFE07,0x801F,0xF81E,0x18C0,
		0x0003,0xE07F,0xFE0F,0x803F,0xFC1E,0x1740,
		0x0003,0xF07F,0xFE0F,0xC03F,0xFE1E,0x2520,
		0x0003,0xF07F,0xFE0F,0xC03F,0xFE1E,0x2620,
		0x0007,0xF803,0xC01F,0xE03C,0x1F1E,0x2520,
		0x0007,0xF803,0xC01F,0xE03C,0x0F1E,0x1540,
		0x0007,0xF803,0xC01F,0xE03C,0x0F1E,0x18C0,
		0x000F,0x7C03,0xC03D,0xF03C,0x0F1E,0x0700,
		0x000F,0x3C03,0xC03C,0xF03C,0x0F1E,0x0000,
		0x000F,0x3C03,0xC03C,0xF03C,0x1E1E,0x0000,
		0x001E,0x3E03,0xC078,0xF83C,0x7E1E,0x0000,
		0x001E,0x1E03,0xC078,0x783D,0xFC1E,0x0000,
		0x001E,0x1E03,0xC078,0x783D,0xF81E,0x0000,
		0x003E,0x1F03,0xC0F8,0x7C3D,0xE01E,0x0000,
		0x003F,0xFF03,0xC0FF,0xFC3D,0xE01E,0x0000,
		0x003F,0xFF03,0xC0FF,0xFC3D,0xE01E,0x0000,
		0x007F,0xFF83,0xC1FF,0xFE3C,0xF01E,0x0000,
		0x007F,0xFF83,0xC1FF,0xFE3C,0xF81E,0x0000,
		0x0078,0x0783,0xC1E0,0x1E3C,0x781E,0x0000,
		0x00F8,0x07C3,0xC3E0,0x1F3C,0x3C1E,0x0000,
		0x00F0,0x07C3,0xC3C0,0x1F3C,0x3E1E,0x0000,
		0x00F0,0x03C3,0xC3C0,0x0F3C,0x1E1E,0x0000,
		0x01F0,0x03E3,0xC7C0,0x0FBC,0x1F1E,0x0000,
		0x01E0,0x01E3,0xC780,0x07B8,0x0F1E,0x0000
};
#endif /* TOS_ATARI_LOGO */
	unsigned long base_addr = (unsigned long)physbase();
	struct fb_info *info = info_fvdi;
	unsigned char *buf_tex = NULL;
	unsigned long *ptr32 = NULL;
	unsigned short *ptr16 = NULL;
	unsigned char *ptr8 = NULL;
	int i, j, k, cnt = 1;
	int bpp = info->var.bits_per_pixel;
	unsigned short val, color = 0;
	unsigned long color2 = 0, r, g, b;
	unsigned long incr = mul32(info->var.xres_virtual, bpp >> 3); // line above not works on CF ?!?!
//	unsigned long incr = (unsigned long)(info->var.xres_virtual * (bpp >> 3));
	if(info->screen_mono != NULL) /* VBL monochrome emulation */
	{
		bpp = 1;
		incr = (unsigned long)(info->var.xres_virtual >> 3);
	}
#ifdef RADEON_RENDER
	if(video_found && (info->screen_mono == NULL) && (bpp >= 16) && (info->fbops->SetupForCPUToScreenTexture != NULL))
	{
		buf_tex = (char *)Malloc(HEIGHT_LOGO * WIDTH_LOGO * 4);
		if(buf_tex != NULL)
		{
			incr = WIDTH_LOGO * 4;
			bpp = 32;
			cnt = 2;
		}
	}
	else
#endif
		base_addr += (incr * 4); // line 4
	while(--cnt >= 0)
	{
#ifdef TOS_ATARI_LOGO
		unsigned short *logo_atari = (unsigned short *)0xE49434; /* logo ATARI monochrome inside TOS 4.04 */
#else
		unsigned short *logo_atari = logo;
#endif
#ifdef RADEON_RENDER
		if(buf_tex != NULL)
			base_addr = (unsigned long)buf_tex;
#endif
		g = 3;
		for(i = 0; i < 86; i++) // lines
		{
			switch(bpp)
			{
				case 1:
					ptr16 = (unsigned short *)base_addr;
					break;
				case 16:
					if(i < 56)
					{
						r = (unsigned long)((63 - i) >> 1) & 0x1F;
						if(i < 28)
							g++;
						else
							g--;
						b = (unsigned long)((i + 8) >> 1) & 0x1F;
						color = (unsigned short)((r << 11) + (g << 6) + b);
					}
					else
						color = 0;
					ptr16 = (unsigned short *)base_addr;
					break;
				case 32:
					if(i < 56)
					{
						r = (unsigned long)(63 - i) & 0x3F;
						if(i < 28)
							g++;
						else
							g--;
						b = (unsigned long)(i + 8) & 0x3F;
						if((buf_tex != NULL) && cnt)
						{
							color2 = ((r << 15) & 0xFF0000) + (g << 8) + ((b >> 1) & 0xFF);
							color2 |= 0xE0E0E0;
						}
						else
							color2 = (r << 18) + (g << 11) + (b << 2);
					}
					else
					{
						if((buf_tex != NULL) && cnt)
							color2 = 0xE0E0E0;
						else
							color2 = 0;
					}
					if(buf_tex != NULL)
						color2 |= 0xFF000000; /* alpha */
					ptr32 = (unsigned long *)base_addr;
					break;
				default:
					ptr8 = (unsigned char *)base_addr;
					break;
			}
			for(j = 0; j < 6; j++)
			{
				switch(bpp)
				{
					case 1:
						*ptr16++ = *logo_atari++;
						break;
					case 8:
						val = *logo_atari++;
						for(k = 0x8000; k; k >>= 1)
						{
							if(val & k)
								*ptr8++ = 0xFF;
							else
								*ptr8++ = 0; 
						}		
						break; 
					case 16:
						val = *logo_atari++;
						for(k = 0x8000; k ; k >>= 1)
						{
							if(val & k)
								*ptr16++ = color;
							else
								*ptr16++ = 0xFFFF;
						}					
						break;
					case 32:
						val = *logo_atari++;
						for(k = 0x8000; k; k >>= 1)
						{
							if(val & k)
								*ptr32++ = color2;
							else
								*ptr32++ = 0xFFFFFF;
						}					
						break;
			  }
			}
			base_addr += incr;
		}
#ifdef RADEON_RENDER
		if(buf_tex != NULL)
		{
			if(cnt)
				display_composite_texture(3, buf_tex, 0, 0, WIDTH_LOGO, HEIGHT_LOGO, 0, 0, info->var.xres_virtual, info->var.yres_virtual);
			else
				display_composite_texture(1, buf_tex, 0, 0, WIDTH_LOGO, HEIGHT_LOGO, 0, 0, WIDTH_LOGO, HEIGHT_LOGO);
		}
#endif
	}
	if(info->screen_mono != NULL) /* VBL monochrome emulation */
		info->update_mono = 1;
#ifdef RADEON_RENDER
	if(buf_tex != NULL)
		Mfree(buf_tex);
#endif
}

void display_ati_logo(void)
{
#ifdef ATI_LOGO
#define WIDTH_ATI_LOGO 96
#define HEIGHT_ATI_LOGO 62
	static unsigned short logo[] =
	{
		0x01FF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,
		0x01FF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF, 
		0x01FF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,
		0x01FF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,
		0x01FF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,
		0x01FF,0xFFFF,0xFFFF,0x8000,0x0000,0x007F,
		0x01FF,0xFFFF,0xFFFE,0x0000,0x0000,0x003F,
		0x01FF,0xFFFF,0xFFFC,0x0000,0x0000,0x1F1F,
		0x01FF,0xFFFF,0xFFF0,0x0000,0x0000,0x3F8F,
		0x01FF,0xFFFF,0xFFF0,0x0000,0x0000,0x7FC7,
		0x01FF,0xFFFF,0xFFC0,0x0000,0x0000,0x7FE7,
		0x01FF,0xFFFF,0xFF80,0x0000,0x0000,0xFFE7,
		0x01FF,0xFFFF,0xFF00,0x0000,0x0000,0xFFE7,
		0x01FF,0xFFFF,0xFE00,0x0000,0x0000,0xFFE7,
		0x01FF,0xFFFF,0xFC00,0x0000,0x0000,0x7FC7,
		0x01FF,0xFFFF,0xF800,0x0000,0x0000,0x7FC7,
		0x01FF,0xFFFF,0xF000,0x0000,0x0000,0x3F8F,
		0x01FF,0xFFFF,0xE000,0x0000,0x0000,0x0E1F,
		0x01FF,0xFFFF,0xC000,0x0000,0x0000,0x003F,
		0x01FF,0xFFFF,0x8000,0x0000,0x0000,0x00FF,
		0x01FF,0xFFFF,0x0000,0x0700,0x00FF,0xFFFF,
		0x01FF,0xFFFE,0x0000,0x0F00,0x01FF,0xFFFF,
		0x01FF,0xFFFC,0x0000,0x1F00,0x01FF,0xC07F,
		0x01FF,0xFFF8,0x0000,0x3F80,0x01FF,0x003F,
		0x01FF,0xFFF0,0x0000,0x7F80,0x01FF,0x001F,
		0x01FF,0xFFE0,0x0000,0xFF80,0x01FE,0x000F,
		0x01FF,0xFFC0,0x0001,0xFF80,0x01FE,0x000F,
		0x01FF,0xFF80,0x0003,0xFF80,0x01FC,0x000F,
		0x01FF,0xFF00,0x0007,0xFF80,0x01FC,0x000F,
		0x01FF,0xFE00,0x000F,0xFF80,0x01FC,0x000F,
		0x01FF,0xFC00,0x001C,0x3F80,0x01FC,0x000F,
		0x01FF,0xF800,0x0030,0x0F80,0x01FC,0x000F,
		0x01FF,0xF000,0x0070,0x0780,0x01FC,0x000F,
		0x01FF,0xE000,0x00E0,0x0380,0x01FC,0x000F,
		0x01FF,0xC000,0x01E0,0x0380,0x01FC,0x000F,
		0x01FF,0x8000,0x03E0,0x0380,0x01FC,0x000F,
		0x01FF,0x0000,0x07E0,0x0380,0x01FC,0x000F,
		0x01FE,0x0000,0x0FE0,0x0380,0x01FC,0x000F,
		0x01FC,0x0000,0x1FE0,0x0380,0x01FC,0x000F,
		0x01F8,0x0000,0x3FE0,0x0780,0x01FC,0x000F,
		0x01F8,0x0000,0x7FF0,0x0780,0x01FC,0x000F,
		0x01F0,0x0000,0xFFFC,0x1F80,0x01FC,0x000F,
		0x01F0,0x0001,0xFFFF,0xFF80,0x01FC,0x000F,
		0x01F0,0x0003,0xFFFF,0xFF80,0x01FC,0x000F,
		0x01E0,0x0007,0xFFFF,0xFF80,0x01FC,0x000F,
		0x01E0,0x000F,0xFFFF,0xFF80,0x01FC,0x000F,
		0x01F0,0x001F,0xFFFF,0xFF80,0x01FE,0x000F,
		0x01F0,0x003F,0xFFFF,0xFF80,0x03FE,0x000F,
		0x01F8,0x007F,0xFFFF,0xFFC0,0x03FE,0x000F,
		0x01F8,0x00FF,0xFFFF,0xFFC0,0x07FF,0x001F, 
		0x01FC,0x01FF,0xFFFF,0xFFE0,0x0FFF,0x803F,
		0x01FF,0x03FF,0xFFFF,0xFFF8,0x3FFF,0xE0FF,
		0x01FF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,
		0x01FF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,
		0x01FF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,
		0x01FF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,
		0x01FF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,
		0x01FF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,
		0x01FF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,
		0x01FF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF, 
		0x01FF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,
		0x01FF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF };
	long dst_y = 0, w = WIDTH_ATI_LOGO - 8, h = HEIGHT_ATI_LOGO, src_wrap = WIDTH_ATI_LOGO / 8;
	struct fb_info *info = info_fvdi;
	long foreground, background;
	long dst_x = (long)info->var.xres - w;
	if(info->screen_mono != NULL)
		return;
	switch(info->var.bits_per_pixel)
	{
		case 8: foreground = 1; background = 7; break; /* red & grey */
		case 16: foreground = 0xF800; background = 0xB596; break;
		default: foreground = 0xFF0000; background = 0xB0B0B0; break;
	}
	display_mono_block(((char *)logo)+1, dst_x, dst_y, w, h, foreground, background, src_wrap);
#endif
}

const struct fb_videomode *get_db_from_modecode(long modecode)
{
	const struct fb_videomode *db;
	long devID = GET_DEVID(modecode);
	if(devID < VESA_MODEDB_SIZE)
		db = &vesa_modes[devID];		
	else
	{
		devID -= VESA_MODEDB_SIZE;
		if(devID < total_modedb)
			db = &modedb[devID];
#if defined(COLDFIRE) && defined(MCF547X) /* FIREBEE */
		else if(!video_found) /* Videl */
		{
			extern struct fb_videomode *videl_modedb;
			extern unsigned long videl_modedb_len;
			devID -= total_modedb;
			if(devID < videl_modedb_len)
				db = &videl_modedb[devID];
			else
				return(NULL);
		}
#endif /* defined(COLDFIRE) && defined(MCF547X) */
		else if(video_found == 1) /* Radeon */
		{
			struct radeonfb_info *rinfo = info_fvdi->par;
			devID -= total_modedb;
			if(devID < rinfo->mon1_dbsize)
				db = &rinfo->mon1_modedb[devID];
			else
				return(NULL);
		}
		else if(video_found == 2) /* Lynx */
		{
			struct radeonfb_info *smiinfo = info_fvdi->par;
			devID -= total_modedb;
			if(devID < smiinfo->mon1_dbsize)
				db = &smiinfo->mon1_modedb[devID];
			else
				return(NULL);
		}	
		else
			return(NULL);
	}
	return(db);
}

long get_modecode_from_screeninfo(struct fb_var_screeninfo *var)
{
	const struct fb_videomode *db = NULL;
	long modecode, i, nb = 0;
#ifndef COLDFIRE
	if(info_fvdi->screen_mono)
		modecode = BPS1; /* VBL mono emulation */
	else
#endif
	{
		switch(var->bits_per_pixel)
		{
			case 16: modecode = BPS16; break;
			case 32: modecode = BPS32; break;
			default: modecode = BPS8; break;
		}
	}
#if defined(COLDFIRE) && defined(MCF547X) /* FIREBEE */
	if(!video_found) /* Videl */
	{
		extern struct fb_videomode *videl_modedb;
		extern unsigned long videl_modedb_len;
		if((nb = videl_modedb_len) != 0)
			db = videl_modedb;
	}
	else
#endif /* defined(COLDFIRE) && defined(MCF547X) */
	if(video_found == 1) /* Radeon */
	{
		struct radeonfb_info *rinfo = info_fvdi->par;
		if((nb = rinfo->mon1_dbsize) != 0)
			db = rinfo->mon1_modedb;
	}
	else if(video_found == 2) /* Lynx */
	{
		struct radeonfb_info *smiinfo = info_fvdi->par;
		if((nb = smiinfo->mon1_dbsize) != 0)
			db = smiinfo->mon1_modedb;
	}
	if(db != NULL)
	{
		for(i = 0; i < nb; i++)
		{
			if(((unsigned long)db->xres == var->xres) && ((unsigned long)db->yres == var->yres) && ((unsigned long)db->refresh == var->refresh))
				return(SET_DEVID(i + VESA_MODEDB_SIZE + total_modedb) + modecode);
			db++;
		}
	}
	db = modedb;
	for(i = 0; i < total_modedb; i++)
	{
		if(((unsigned long)db->xres == var->xres) && ((unsigned long)db->yres == var->yres) && ((unsigned long)db->refresh == var->refresh))
			return(SET_DEVID(i + VESA_MODEDB_SIZE) + modecode);
		db++;
	}
	db = vesa_modes;
	for(i = 0; i < VESA_MODEDB_SIZE; i++)
	{
		if(((unsigned long)db->xres == var->xres) && ((unsigned long)db->yres == var->yres) && ((unsigned long)db->refresh == var->refresh))
			return(SET_DEVID(i) + modecode);
		db++;
	}
	return(-1);
}

void init_screen_info(SCREENINFO *si, long modecode)
{
	char buf[16];
	long flags = 0;
	struct fb_info *info = info_fvdi;
	switch(modecode & NUMCOLS)
	{
#ifndef COLDFIRE
		case BPS1: /* VBL mono emulation */
			si->scrPlanes = 1;
			si->scrColors = 2;
			si->redBits = si->greenBits = si->blueBits = 255;
			si->unusedBits = 0;
			break;
#endif
		case BPS8:
			si->scrPlanes = 8;
			si->scrColors = 256;
			si->redBits = si->greenBits = si->blueBits = 255;
			si->unusedBits = 0;
			break;
		case BPS16:
			si->scrPlanes = 16;
			si->scrColors = 65536;
			si->redBits = 0xF800;                    /* mask of red bits */
			si->greenBits = 0x3E0;                   /* mask of green bits */
			si->blueBits = 0x1F;                     /* mask of blue bits */
			si->unusedBits = 0;                      /* mask of unused bits */
			break;
		case BPS32:
			si->scrPlanes = 32;
			si->scrColors = 16777216;
			si->redBits = 0xFF0000;                 /* mask of red bits */
			si->greenBits = 0xFF00;                 /* mask of green bits */
			si->blueBits = 0xFF;                    /* mask of blue bits */
			si->unusedBits = 0xFF000000;            /* mask of unused bits */
			break;
		default:
			si->scrFlags = 0;
			return;
	}
	si->alphaBits = si->genlockBits = 0;
	if(!(modecode & DEVID)) /* modecode normal */
	{
		switch(modecode & (VERTFLAG2|VESA_768|VESA_600|HORFLAG2|HORFLAG|VERTFLAG|STMODES|VGA|COL80))
		{
			case (VERTFLAG+VGA):                      /* 320 * 240 */
			case 0:
#if defined(COLDFIRE) && defined(MCF547X) /* FIREBEE */
				if(!video_found)
					break;
#endif 
				si->scrWidth = 320;
				si->scrHeight = 240;
				break;
			case (VGA+COL80):                         /* 640 * 480 */
			case (VERTFLAG+COL80):
				si->scrWidth = 640;
				si->scrHeight = 480;
				break;
			case (VESA_600+HORFLAG2+VGA+COL80):       /* 800 * 600 */
				si->scrWidth = 800;
				si->scrHeight = 600;
				break;
			case (VESA_768+HORFLAG2+VGA+COL80):       /* 1024 * 768 */
				si->scrWidth = 1024;
				si->scrHeight = 768;
				break;
			case (VERTFLAG2+HORFLAG+VGA+COL80):       /* 1280 * 960 */
				si->scrWidth = 1280;
				si->scrHeight = 960;
				break;
			case (VERTFLAG2+VESA_600+HORFLAG2+HORFLAG+VGA+COL80): /* 1600 * 1200 */
				si->scrWidth = 1600;
				si->scrHeight = 1200;
				break;
			default:
				si->scrFlags = 0;
				return;
		}
		if(modecode & OVERSCAN)
		{
			if(modecode & PAL)
				si->refresh=85;
			else
				si->refresh=70;
		}
		else
		{
			if(modecode & PAL)
				si->refresh = 60;
			else
				si->refresh = 56;
		}
		si->pixclock = 0;
	}
	else /* bits 11-3 used for devID */
	{
		const struct fb_videomode *db = get_db_from_modecode(modecode);
		if(db == NULL)
		{
			si->scrFlags = 0;
			return;
		}
#if defined(COLDFIRE) && defined(MCF547X) /* FIREBEE */
		if(!video_found && (db->vmode & (FB_VMODE_DOUBLE | FB_VMODE_INTERLACED)))
		{
			si->scrFlags = 0;
			return;
		}
#endif
		si->scrWidth = (long)db->xres;
		si->scrHeight = (long)db->yres;
		si->refresh = (long)db->refresh;
		si->pixclock = (long)db->pixclock;
		flags = (long)db->flag;
	}
	if((si->scrPlanes == 1)
	 && ((os_magic == 1) || (si->scrWidth > MAX_WIDTH_EMU_MONO) || (si->scrHeight > MAX_HEIGHT_EMU_MONO)
	  || (modecode & VIRTUAL_SCREEN))) /* limit size for the VBL mono emulation */
	{
		si->scrFlags = 0;
		return;
	}
	if(modecode & VIRTUAL_SCREEN)
	{
		si->virtWidth = si->scrWidth*2;
		if(si->virtWidth > 2048)
			si->virtWidth = 2048;
		si->virtHeight = si->scrHeight*2;
		if(si->virtHeight > 2048)
			si->virtHeight = 2048;
	}
	else
	{
		si->virtWidth = si->scrWidth;
		si->virtHeight = si->scrHeight;
	}
	ltoa(buf, si->scrWidth, 10); 
	strcpy(si->name, buf);
	strcat(si->name, "x");
	ltoa(buf, si->scrHeight, 10); 
	strcat(si->name, buf);
	strcat(si->name, "-");
	ltoa(buf, si->scrPlanes, 10); 
	strcat(si->name, buf);
	strcat(si->name, "@");
	ltoa(buf, si->refresh, 10); 
	strcat(si->name, buf);
	strcat(si->name, "Hz");
	if(modecode & VIRTUAL_SCREEN)
		strcat(si->name, " x4");
	else
		strcat(si->name, "   ");
	buf[0] = ' ';
	buf[1] = buf[2] ='\0';
	if(flags & FB_MODE_IS_VESA)
		buf[1] = 'V';
	if(flags & FB_MODE_IS_CALCULATED)
		buf[1] = 'C';
	if(flags & FB_MODE_IS_STANDARD)
		buf[1] = 'S';
	if(flags & FB_MODE_IS_DETAILED)
		buf[1] = 'D';
	if(flags & FB_MODE_IS_FIRST)
		buf[1] = '*';
	if(buf[1])
		strcat(si->name, buf);
	si->frameadr = (long)physbase();
	si->lineWrap = si->virtWidth * (si->scrPlanes / 8);
	si->planeWarp = 0;
	si->scrFormat = PACKEDPIX_PLANES;
	if(si->scrPlanes <= 8)
		si->scrClut = HARD_CLUT;
	else
		si->scrClut = SOFT_CLUT;
	si->bitFlags = STANDARD_BITS;					
	si->max_x = si->virtWidth;
	si->max_y = 8192; /* max. possible heigth/width ??? */
	si->maxmem = si->max_x * si->max_y * (si->scrPlanes / 8);
	si->pagemem = vgetsize(modecode);
	if(!si->devID)
	{
		if(info->var.refresh)
			si->refresh = info->var.refresh;
		if(info->var.pixclock)
			si->pixclock = info->var.pixclock;
		si->devID = modecode;
	}
	si->scrFlags = SCRINFO_OK;
}

static long update_modecode(long modecode)
{
	if(os_magic == 1)
		modecode_magic = (short)modecode;
	else
		Modecode = (short)modecode;
	return(modecode);
}

void init_screen(void)
{
	Bconout(2,27);
	Bconout(2,'b');
	Bconout(2,0x3F); /* black characters */
	Bconout(2,27);
	Bconout(2,'c');
	Bconout(2,0x30); /* white background */
	Bconout(2,27);
	Bconout(2,'E');  /* clear screen */
	Bconout(2,27);
	Bconout(2,'f');  /* no cursor */
}

void init_resolution(long modecode)
{
	long Mode;
	if(os_magic == 1)
		Mode = (long)modecode_magic & 0xFFFF;
	else
		Mode = (long)Modecode & 0xFFFF;
//	board_printf("init_resolution modecode %04X (%04X)\r\n", modecode, Mode);
	switch(modecode & NUMCOLS)
	{
		case BPS1: 
			if(os_magic == 1)
				break;
			resolution.flags = MODE_EMUL_MONO_FLAG; resolution.bpp = 1; break;
		case BPS16: resolution.flags = 0; resolution.bpp = 16; break;
		case BPS32: resolution.flags = 0; resolution.bpp = 32; break;
		default: resolution.flags = 0; resolution.bpp = 8; break;
	}
	if(!(modecode & DEVID)) /* modecode normal */
	{
		if(modecode & OVERSCAN)
		{
			if(modecode & PAL)
				resolution.freq = 85;
			else
				resolution.freq = 70;
		}
		else
		{
			if(modecode & PAL)
				resolution.freq = 60;
			else
				resolution.freq = 56;
		}
		switch(modecode & (VERTFLAG2|VESA_768|VESA_600|HORFLAG2|HORFLAG|VERTFLAG|STMODES|VGA|COL80))
		{
			case (VERTFLAG+VGA):                      /* 320 * 240 */
			case 0:
				resolution.width = 320;
				resolution.height = 240;
				break;
			case (VGA+COL80):                         /* 640 * 480 */
			case (VERTFLAG+COL80):
				resolution.width = 640;
				resolution.height = 480;
				break;
			case (VESA_600+HORFLAG2+VGA+COL80):       /* 800 * 600 */
				resolution.width = 800;
				resolution.height = 600;
				break;
			case (VESA_768+HORFLAG2+VGA+COL80):       /* 1024 * 768 */
				resolution.width = 1024;
				resolution.height = 768;
				break;
			case (VERTFLAG2+HORFLAG+VGA+COL80):       /* 1280 * 960 */
				resolution.width = 1280;
				resolution.height = 960;
				resolution.flags |= MODE_VESA_FLAG;
				break;
			case (VERTFLAG2+VESA_600+HORFLAG2+HORFLAG+VGA+COL80): /* 1600 * 1200 */
				resolution.width = 1600;
				resolution.height = 1200;
				break;
			default:
				init_resolution(validmode(Mode));
			 	break;
		}
	}
	else /* bits 11-3 used for devID */
	{
		const struct fb_videomode *db;
		long devID = GET_DEVID(modecode);
		if(devID < VESA_MODEDB_SIZE)
		{
			db = &vesa_modes[devID];
			resolution.flags |= MODE_VESA_FLAG;
		}
		else
		{
			devID -= VESA_MODEDB_SIZE;
			if(devID < total_modedb)
				db = &modedb[devID];
#if defined(COLDFIRE) && defined(MCF547X) /* FIREBEE */
			else if(!video_found) /* Videl */
			{
				extern struct fb_videomode *videl_modedb;
				extern unsigned long videl_modedb_len;
				devID -= total_modedb;
				if(devID < videl_modedb_len)
					db = &videl_modedb[devID];
				else
				{
					init_resolution(Mode);
					return;
				}
			}
#endif /* defined(COLDFIRE) && defined(MCF547X) */
			else if(video_found == 1) /* Radeon */
			{
				struct radeonfb_info *rinfo = info_fvdi->par;
				devID -= total_modedb;
				if(devID < rinfo->mon1_dbsize)
					db = &rinfo->mon1_modedb[devID];
				else
				{
					init_resolution(Mode);
					return;
				}
			}
			else if(video_found == 2) /* Lynx */
			{
				struct smifb_info *smiinfo = info_fvdi->par;
				devID -= total_modedb;
				if(devID < smiinfo->mon1_dbsize)
					db = &smiinfo->mon1_modedb[devID];
				else
				{
					init_resolution(Mode);
					return;
				}
			}
			else
			{
				init_resolution(Mode);
				return;
			}
		}
		resolution.width = (short)db->xres;
		resolution.height = (short)db->yres;
		resolution.freq = (short)db->refresh;
	}
}

void vsetrgb(long index, long count, long *array)
{
	static int init_ok;
	unsigned red,green,blue;
	struct fb_info *info = info_fvdi;
	int i;
	for(i = index; i < (count + index); i++, array++)
	{
		if(video_found && (info->var.bits_per_pixel <= 8))
		{
			if(init_ok && (bios_colors[i] == *array))
				continue;
			bios_colors[i] = *array;
			red = (*array>>16) & 0xFF;
			green = (*array>>8) & 0xFF;
			blue = *array & 0xFF;
			info->fbops->fb_setcolreg((unsigned)i, red << 8, green << 8, blue << 8, 0, info);
		}
#ifdef COLDFIRE
		else if(!video_found)
		{
			long type = 1; /* FALCON */
			bios_colors[i] = *array;
			if((Modecode & STMODES) && (((Modecode & NUMCOLS) == BPS2) || ((Modecode & NUMCOLS) == BPS4)))
				type = 0; /* ST */
			else if((unsigned long)info->screen_base >= 0x1000000)
				type = 2; /* FIREBEE */
			if((Modecode & NUMCOLS) <= BPS8)
				setrgb_videl(i, *array, type);
		}
#endif
		else
			bios_colors[i] = *array;
	}
	if(!index && (count == 256) && video_found && (info->var.bits_per_pixel <= 8))
		init_ok = 1;
}

void vgetrgb(long index, long count, long *array)
{
	short i;
	for(i = index; i < (count + index); i++)
		*array++ = bios_colors[i];
}

unsigned long physbase(void)
{
	struct fb_info *info = info_fvdi;
	long physaddr;
	if(video_found == 1) /* Radeon */
	{
		struct radeonfb_info *rinfo = info->par;
		if(info->screen_mono != NULL)
			physaddr = (unsigned long)info->screen_mono;
		else
			physaddr = (unsigned long)info->screen_base + rinfo->fb_offset;
	}
	else if(video_found == 2) /* Lynx */
	{
		struct smifb_info *smiinfo = info->par;
		if(info->screen_mono != NULL)
			physaddr = (unsigned long)info->screen_mono;
		else
			physaddr = (unsigned long)info->screen_base + smiinfo->fb_offset;
	}
#if defined(COLDFIRE) && defined(MCF547X)
	else if(!video_found && ((unsigned long)info->screen_base < 0x1000000)) /* Videl */
	{
		physaddr = (unsigned long)(*(unsigned char *)0xFFFF8201); /* video screen memory position, high byte */
		physaddr <<= 8;
		physaddr |= (unsigned long)(*(unsigned char *)0xFFFF8203); /* mid byte */
		physaddr <<= 8;
		physaddr |= (unsigned long)(*(unsigned char *)0xFFFF820D); /* low byte */
	}
#endif
	else
		physaddr = (unsigned long)info->screen_base;
//	board_printf("physbase => %08X\r\n", physaddr);
	return(physaddr);
}

unsigned long logbase(void)
{
	struct fb_info *info = info_fvdi;
	if(video_found && (info->screen_mono == NULL))
		return(log_addr);
	return((long)*((char **)_v_bas_ad));
}

long getrez(void)
{

	long Mode;
	if(os_magic == 1)
		Mode = (long)modecode_magic & 0xFFFF;
	else
		Mode = (long)Modecode & 0xFFFF;
	if(!(Mode & DEVID)) /* modecode normal */
	{
		switch(Mode & (VERTFLAG2|VESA_768|VESA_600|HORFLAG2|HORFLAG|VERTFLAG|VGA|COL80))
		{
			case (VERTFLAG+VGA):                      /* 320 * 240 */
			case 0:
				return(0);
			case (VGA+COL80):                         /* 640 * 480 */
			case (VERTFLAG+COL80):
				return(4);
			default:
				return(6);
		}
	}
	else /* bits 11-3 used for devID */
	{
		const struct fb_videomode *db = get_db_from_modecode(Mode);
		if(db == NULL)
			return(0);
		if((db->xres <= 320) && (db->yres <= 240))
			return(0);
		if((db->xres <= 640) && (db->yres <= 480))
			return(4);
		return(6);
	}
}

long vsetscreen(long logaddr, long physaddr, long rez, long modecode, long init_vdi)
{
	static unsigned short tab_16_col_ntc[16] = {
		0xFFDF,0xF800,0x07C0,0xFFC0,0x001F,0xF81F,0x07DF,0xB596,
		0x8410,0xA000,0x0500,0xA500,0x0014,0xA014,0x0514,0x0000 };
	static unsigned long tab_16_col_tc[16] = {
		0xFFFFFF,0xFF0000,0x00FF00,0xFFFF00,0x0000FF,0xFF00FF,0x00FFFF,0xB0B0B0,
		0x808080,0x8F0000,0x008F00,0x8F8F00,0x00008F,0x8F008F,0x008F8F,0x000000 };
	long y, color = 0, test = 0;
	struct fb_info *info = info_fvdi;
	struct fb_var_screeninfo var;
	int milan_mode = 0;
	short dup_handle = -1, log_handle = -1, save_debug = debug;
	long Mode;
	if(os_magic == 1)
		Mode = (long)modecode_magic & 0xFFFF;
	else
		Mode = (long)Modecode & 0xFFFF;
//	board_printf("vsetscreen logaddr %08X phyaddr %08X rez %04X modecode %04X (%04X)\r\n", logaddr, physaddr, rez, modecode, Mode);
	switch((short)rez)
	{
		case 0x4D49: /* 'MI' (Milan Vsetscreen) */
			milan_mode = 1;
		case 0x564E: /* 'VN' (Vsetscreen New) */
			switch((short)modecode)
			{
				case CMD_GETMODE:
					*((long *)physaddr) = Mode;
					return(0);
				case CMD_SETMODE:
					modecode = physaddr;
					rez = 3;
					logaddr = physaddr = 0;
					switch(modecode & NUMCOLS)
					{
#ifndef COLDFIRE
						case BPS1:
							if(os_magic == 1)
								return(0);
							init_resolution(modecode);
							if((resolution.width > MAX_WIDTH_EMU_MONO) || (resolution.height > MAX_HEIGHT_EMU_MONO))
								return(0);
							break;
#endif
						case BPS8:
						case BPS16:
						case BPS32:
							init_resolution(modecode);
							break;
						default:
							return(0);
					}
					Mode = update_modecode(modecode);
					break;
				case CMD_GETINFO:
					{
						SCREENINFO *si = (SCREENINFO *)physaddr;
						if(si->devID)
							modecode = si->devID;
						else
							modecode = Mode;
						init_screen_info(si, modecode);
					}
					return(0);
				case CMD_ALLOCPAGE:
					if(video_found && (info->screen_mono == NULL))
					{
						long addr, addr_aligned, size;
						long wrap = info->var.xres_virtual * (info->var.bits_per_pixel >> 3);
						modecode = physaddr;
						if(second_screen)
						{
							if(logaddr != -1)
								*((long *)logaddr) = second_screen_aligned;
							return(0);
						}
						if(modecode == -1)
							size = info->var.yres_virtual * wrap;
						else
						{
							size = vgetsize(modecode & 0xFFFF);
							if(size <  (info->var.yres_virtual * wrap))
								size = info->var.yres_virtual * wrap;
						}
						addr_aligned = addr = offscreen_alloc(info, size + wrap);
						if(addr)
						{
							addr_aligned = addr - (long)info->screen_base;
							addr_aligned += (wrap-1);
							addr_aligned /= wrap;
							addr_aligned *= wrap;
							addr_aligned += (long)info->screen_base;
							if(logaddr != -1)
								*((long *)logaddr) = addr_aligned;
							if(!second_screen)
							{
								second_screen = addr;
								second_screen_aligned = addr_aligned;
							}
						}
						else
						{
							if(logaddr != -1)
								*((long *)logaddr) = 0;
						}
					}
					return(0);
				case CMD_FREEPAGE:
					if(video_found && (info->screen_mono == NULL))
					{
						if((logaddr == -1) || (logaddr == second_screen_aligned))
							logaddr = second_screen;
						else
							logaddr = 0;
						if(logaddr)
						{
							offscreen_free(info, logaddr);
							if(logaddr == second_screen)
							{
								if(second_screen_aligned == (long)physbase())
								{
									log_addr = logaddr = physaddr = (long)info->screen_base;
									rez = -1; /* switch back to the first if second page active */
									init_vdi = 0;
									second_screen = second_screen_aligned = 0;
									break;
								}								
								else				
									second_screen = second_screen_aligned = 0;							
							}
						}
					}
					return(0);
				case CMD_FLIPPAGE:
					if(!video_found || !second_screen || (info->screen_mono != NULL))
						return(0);
					if(second_screen_aligned == (long)physbase())
						physaddr = (long)info->screen_base;
					else
						physaddr = second_screen_aligned;
					if(second_screen_aligned == log_addr)
						log_addr = logaddr = (long)info->screen_base;
					else
						log_addr = logaddr = second_screen_aligned;
					rez = -1;
					break;
				case CMD_ALLOCMEM:
					if(video_found && (info->screen_mono == NULL))
					{
						SCRMEMBLK *blk = (SCRMEMBLK *)physaddr;
						if(blk->blk_y)
							blk->blk_h=blk->blk_y;
						if(blk->blk_h)
						{	
							int bpp = info->var.bits_per_pixel >> 3;
							blk->blk_len = (long)(info->var.xres_virtual * bpp) * blk->blk_h;
							blk->blk_start = offscreen_alloc(info, blk->blk_len);
							if(blk->blk_start)
								blk->blk_status = BLK_OK;
							else
								blk->blk_status = BLK_ERR;
							blk->blk_w = (long)info->var.xres_virtual;
							blk->blk_wrap = blk->blk_w * (long)bpp;
							blk->blk_x = ((blk->blk_start - (long)info->screen_base) % (info->var.xres_virtual * bpp)) / bpp;
							blk->blk_y = (blk->blk_start - (long)info->screen_base) / (info->var.xres_virtual * bpp);
						}
					}
					else
					{
						SCRMEMBLK *blk = (SCRMEMBLK *)physaddr;
						blk->blk_status = BLK_ERR;
					}
					return(0);
				case CMD_FREEMEM:
					if(video_found && (info->screen_mono == NULL))
					{
						SCRMEMBLK *blk	= (SCRMEMBLK *)physaddr;
						offscreen_free(info, blk->blk_start);
						blk->blk_status = BLK_CLEARED;
					}
					return(0);
				case CMD_SETADR:
					if(video_found && (info->screen_mono == NULL))
					{
						if((logaddr >= (long)info->screen_base)
						 || ((logaddr - (long)info->screen_base) >= (info->var.xres_virtual * 8192 * (info->var.bits_per_pixel >> 3))))
							log_addr = logaddr;
						rez = -1;
						break;
					}
					return(0);
				case CMD_ENUMMODES:
					{
						long (*enumfunc)(SCREENINFO *inf, long flag) = (void *)physaddr;
						SCREENINFO si;
						long index, mode;
						si.size = sizeof(SCREENINFO);
						for(index = 0; index < 65536; index++)
						{
							mode = index;
							if(!video_found && (mode & VIRTUAL_SCREEN))
								continue;
							if(!(mode & DEVID)) /* modecode normal */
							{
								if(mode & STMODES)
									continue;
								if(!(mode & VGA))
									continue;
								mode &= (VIRTUAL_SCREEN|VERTFLAG2|VESA_768|VESA_600|HORFLAG2|HORFLAG|VERTFLAG|OVERSCAN|PAL|VGA|COL80|NUMCOLS);
								if(mode == (Mode & (VIRTUAL_SCREEN|VERTFLAG2|VESA_768|VESA_600|HORFLAG2|HORFLAG|VERTFLAG|OVERSCAN|PAL|VGA|COL80|NUMCOLS)))
									si.devID = 0;
								else
									si.devID = mode;
							}
							else /* bits 11-3 used for devID */
							{
								if(mode == Mode)
									si.devID = 0;
								else
									si.devID = mode;
							}							
						  init_screen_info(&si, mode);
						  si.devID = mode;
						  if(si.scrFlags == SCRINFO_OK)
						  {
								if(!call_enumfunc(enumfunc, &si, 1 /* ??? */)) /* for Pure C user */
									break;
							}
						}
					}
					if(milan_mode)
						return(0);
					return((long)info); /* trick for get sructure */
				case CMD_TESTMODE:
					if(milan_mode)
						return(0);
					modecode = physaddr;
					logaddr = physaddr = 0;
					rez = 3;
					init_vdi = 0;
					test = 1;
					switch(modecode & NUMCOLS)
					{
#ifndef COLDFIRE
						case BPS1:
							if(os_magic == 1)
								return(0);
							init_resolution(modecode);
							if((resolution.width > MAX_WIDTH_EMU_MONO) || (resolution.height > MAX_HEIGHT_EMU_MONO))
								return(0);
							break;
#endif
						case BPS8:
						case BPS16:
						case BPS32:
							init_resolution(modecode);
							break;
						default:
							return(0);
					}
					Mode = update_modecode(modecode);
					break;
				case CMD_COPYPAGE:
					if(milan_mode)
						return(0);					
					if(video_found && second_screen	&& (info->screen_mono == NULL))
					{
						long src_x, src_y, dst_x, dst_y;
						int bpp = info->var.bits_per_pixel >> 3;
						long offset = (long)second_screen_aligned - (long)info->screen_base;
						if(physaddr & 1)
						{
					    src_x = (offset % (info->var.xres_virtual * bpp)) / bpp;
							src_y = offset / (info->var.xres_virtual * bpp);
							dst_x = dst_y = 0;
						}
						else
						{
							src_x = src_y = 0;
					    dst_x = (offset % (info->var.xres_virtual * bpp)) / bpp;
							dst_y = offset / (info->var.xres_virtual * bpp);
						}
						move_screen(src_x, src_y, dst_x, dst_y, info->var.xres_virtual, info->var.yres_virtual);
					}
					return(0);
				case CMD_FILLMEM:
					if(milan_mode)
						return(0);
					if(video_found)
					{
						SCRFILLMEMBLK *blk = (SCRFILLMEMBLK *)physaddr;
						if(fill_screen(blk->blk_op, blk->blk_color, blk->blk_x, blk->blk_y, blk->blk_w, blk->blk_h))
							blk->blk_status = BLK_OK;
						else
							blk->blk_status = BLK_ERR;			
					}
					else
					{
						SCRFILLMEMBLK *blk = (SCRFILLMEMBLK *)physaddr;
						blk->blk_status = BLK_ERR;			
					}
					return(0);
				case CMD_COPYMEM:
					if(milan_mode)
						return(0);
					if(video_found)
					{
						SCRCOPYMEMBLK *blk = (SCRCOPYMEMBLK *)physaddr;
						if(copy_screen(blk->blk_op, blk->blk_src_x, blk->blk_src_y, blk->blk_dst_x, blk->blk_dst_y, blk->blk_w, blk->blk_h))
							blk->blk_status = BLK_OK;
						else
							blk->blk_status = BLK_ERR;				
					}
					else
					{
						SCRCOPYMEMBLK *blk = (SCRCOPYMEMBLK *)physaddr;
						blk->blk_status = BLK_ERR;			
					}
					return(0);
				case CMD_TEXTUREMEM:
					if(milan_mode)
						return(0);
					if(video_found && (info->screen_mono == NULL))
					{
						SCRTEXTUREMEMBLK *blk = (SCRTEXTUREMEMBLK *)physaddr;
#ifdef RADEON_RENDER
						if(display_composite_texture(blk->blk_op, (char *)blk->blk_src_tex, blk->blk_src_x, blk->blk_src_y, blk->blk_w_tex, blk->blk_h_tex, blk->blk_dst_x, blk->blk_dst_y, blk->blk_w, blk->blk_h))
							blk->blk_status = BLK_OK;
						else
#endif
							blk->blk_status = BLK_ERR;				
					}
					else
					{
						SCRTEXTUREMEMBLK *blk = (SCRTEXTUREMEMBLK *)physaddr;
						blk->blk_status = BLK_ERR;			
					}
					return(0);
				case CMD_GETVERSION:
					if(milan_mode)
						return(0);
					if(physaddr != -1)
						*((long *)physaddr) = XBIOS_SCREEN_VERSION;
					return(0);			
				case CMD_LINEMEM:
					if(milan_mode)
						return(0);
					if(video_found && (info->screen_mono == NULL))
					{
						SCRLINEMEMBLK *blk = (SCRLINEMEMBLK *)physaddr;
						if(line_screen(blk->blk_op, blk->blk_fgcolor, blk->blk_bgcolor, blk->blk_x1, blk->blk_y1, blk->blk_x2, blk->blk_y2, blk->blk_pattern))
							blk->blk_status = BLK_OK;
						else
							blk->blk_status = BLK_ERR;			
					}
					else
					{
						SCRLINEMEMBLK *blk = (SCRLINEMEMBLK *)physaddr;
						blk->blk_status = BLK_ERR;			
					}
					return(0);
				case CMD_CLIPMEM:
					if(milan_mode)
						return(0);
					if(video_found)
					{
						SCRCLIPMEMBLK *blk = (SCRCLIPMEMBLK *)physaddr;
						if(clip_screen(blk->blk_clip_on, blk->blk_x, blk->blk_y, blk->blk_w, blk->blk_h))
							blk->blk_status = BLK_OK;
						else
							blk->blk_status = BLK_ERR;			
					}
					else
					{
						SCRCLIPMEMBLK *blk = (SCRCLIPMEMBLK *)physaddr;
						blk->blk_status = BLK_ERR;			
					}
					return(0);
				case CMD_SYNCMEM:
					if(!milan_mode && video_found)
						info_fvdi->fbops->fb_sync(info_fvdi);
					return(0);
				case CMD_BLANK:
					if(!milan_mode)
					{
						if(video_found)
							info_fvdi->fbops->fb_blank(physaddr, info_fvdi);
#ifdef COLDFIRE
						else
							videl_blank(physaddr);
#endif
					}
					return(0);
				case -1:
				default:
					return(0);
			}
			break;
#if 0 // actually the fVDI driver works only with packed pixels in 256 / 65K / 16M colors and VBL mono emulation
		case 0:	/* ST-LOW */
			if(!video_found)
			{
				resolution.width = 320;
				resolution.height = 200;
				resolution.bpp = 4;
				resolution.freq = 60;
				resolution.flags = 0;
				modecode = VERTFLAG|STMODES|PAL|VGA|BPS4;
				Mode = update_modecode(modecode);
				break;
			}
			return(Mode);
		case 1: /* ST-MED */
			if(!video_found)
			{
				resolution.width = 640;
				resolution.height = 200;
				resolution.bpp = 2;
				resolution.freq = 60;
				resolution.flags = 0;
				modecode = VERTFLAG|STMODES|PAL|VGA|COL80|BPS2;
				Mode = update_modecode(modecode);
				break;
			}
			return(Mode);
#endif
#ifndef COLDFIRE
		case 2: /* ST-HIG */
			if(os_magic == 1)
				return(Mode);
			resolution.width = 640;
			resolution.height = 400;
			resolution.bpp = 1;
			resolution.freq = 60;
			resolution.flags = MODE_EMUL_MONO_FLAG;
			modecode = STMODES|PAL|VGA|COL80|BPS1;
			Mode = update_modecode(modecode);
			break;
#endif
		case 3:
			switch(modecode & NUMCOLS)
			{
#ifndef COLDFIRE
				case BPS1:
					init_resolution(modecode);
					if((resolution.width > MAX_WIDTH_EMU_MONO) || (resolution.height > MAX_HEIGHT_EMU_MONO))
						return(Mode);
					break;
#endif
				case BPS8:
				case BPS16:
				case BPS32:
					init_resolution(modecode);
					break;
				default:
#if 0
					modecode = Mode;  /* previous modecode */
					init_resolution(modecode);
					break;
#else
					return(Mode);
#endif
			}
			Mode = update_modecode(modecode);
			break;
		default:
#if 0
			modecode = Mode; /* previous modecode */
			init_resolution(modecode);
			break;
#else
			return(Mode);
#endif
	}
	if(modecode & VIRTUAL_SCREEN)
		virtual=1;
	else
		virtual=0;
	if(((!logaddr && !physaddr) || ((logaddr == -1) && (physaddr == -1))) && (rez >= 0))
	{
		resolution.used = 1;
#if defined(DEBUG) && defined(COLDFIRE) && defined(NETWORK) && defined(LWIP)
		if(init_vdi)
			board_printf("Setscreen mode 0x%04X %dx%d-%d@%d\r\n", Mode, resolution.width, resolution.height, resolution.bpp, resolution.freq);
#endif
#ifdef COLDFIRE
		if(!video_found)
		{
			long addr = init_videl((long)resolution.width, (long)resolution.height, (long)resolution.bpp, (long)resolution.freq, 1);
     	if(addr)
     	{
				*((char **)_v_bas_ad) = info->screen_base = (char *)addr;
				info->var.xres = info->var.xres_virtual = (int)resolution.width;
				info->var.yres = info->var.yres_virtual = (int)resolution.height;
				info->var.bits_per_pixel = (int)resolution.bpp;
				if(info->var.bits_per_pixel == 8)
					vsetrgb(0, 256, (long *)0xE1106A); /* default TOS 4.04 palette */
				if(init_vdi)
				{
					init_var_linea((long)video_found);
					init_screen();
				}
				else if(test)
				{
					int color = 0;
					for(y = 0; y < info->var.yres_virtual; y += 16)
					{
						long size = ((info->var.bits_per_pixel * info->var.xres_virtual) >> 3) << 4;
						memset((void *)addr, color, size); 
						addr += size;
						switch(info->var.bits_per_pixel)
						{
							case 16: 
							case 32: color += 0x11; break;
							default: color = (y >> 4) & 15; break;
						}
					}
				}
			}
			else if(!test) /* error */
			{
				long addr;
#if defined(DEBUG) && defined(COLDFIRE) && defined(NETWORK) && defined(LWIP)
				board_printf("Setscreen init_videl error mode 0x%04X %dx%d-%d@%d, try to use default 640x480\r\n", Mode, resolution.width, resolution.height, resolution.bpp, resolution.freq);
#endif
				resolution.width = 640;
				resolution.height = 480;
				resolution.bpp = 16;
				resolution.freq = 60;
				Mode = PAL | VGA | COL80 | BPS16;
				addr = init_videl((long)resolution.width, (long)resolution.height, (long)resolution.bpp, (long)resolution.freq, 0);
	     	if(addr)
	     	{
					*((char **)_v_bas_ad) = info->screen_base = (char *)addr;
					info->var.xres = info->var.xres_virtual = (int)resolution.width;
					info->var.yres = info->var.yres_virtual = (int)resolution.height;
					info->var.bits_per_pixel = (int)resolution.bpp;
					if(info->var.bits_per_pixel == 8)
						vsetrgb(0, 256, (long *)0xE1106A); /* default TOS 4.04 palette */
					if(init_vdi)
					{
						init_var_linea((long)video_found);
						init_screen();
					}
				}
			}
			return(Mode);
		}
#endif /* COLDFIRE */
		if(test)
			debug = 0;
		if(!test && drive_ok && video_log)
		{
			dup_handle = Fdup(1); /* stdout */
			if(dup_handle >= 0)
			{
				log_handle = Fcreate("C:\\screen.log", 0);
				if(log_handle >= 0)
				{
					Fforce(1, log_handle); /* stdout */
					debug = 1;  /* force debug to file */
				}
			}
		}
		info->update_mono = 0; /* stop VBL redraw if monochrome emulation */
		info->fbops->fb_check_modes(info, &resolution);
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
//		rinfo->asleep = 0;
		print_screen(NULL, 0, 0, 0, 0, 0, 0, 0); /* flush characters */
    if(!fb_set_var(info, &var))
		{
			int i, red = 0, green = 0, blue = 0;
			switch(info->var.bits_per_pixel)
			{
				case 16:
					for(i = 0; i < 64; i++)
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
				case 32:
					for(i = 0; i < 256; i++)
					{
						if(red > 65535)
							red = 65535;
						if(green > 65535)
							green = 65535;
						if(blue > 65535)
							blue = 65535;
						info->fbops->fb_setcolreg((unsigned)i,red,green,blue,0,info);
						green += 256;   /* 8 bits */
						red += 256;     /* 8 bits */
						blue += 256;    /* 8 bits */
					}
					break;
				default:
					vsetrgb(0, 256, (long *)0xE1106A); /* default TOS 4.04 palette */
					break;
			}
			if((info->var.xres != (unsigned long)resolution.width) || (info->var.yres != (unsigned long)resolution.height))
			{ /* fix modecode if the driver choice another screen */
				modecode = get_modecode_from_screeninfo(&info->var);
				init_resolution(modecode);
				Mode = update_modecode(modecode);
			}
			if(resolution.flags & MODE_EMUL_MONO_FLAG)
			{
#ifndef COLDFIRE /* normal to VBL nono emulation => update fVDI accel functions */
				extern Driver *me;
				extern void *default_text;
//				extern void *default_line, *default_fill;
				extern void *line, *fill;
				Virtual *vwk = me->default_vwk;
				Workstation *wk = vwk->real_address;
//				wk->r.line = &default_line;
//				wk->r.fill = &default_fill;
				wk->r.line = &line;
				wk->r.fill = &fill;
				wk->r.fillpoly = NULL; 
				wk->r.text = &default_text;				
#endif
				info->screen_mono = (char *)Srealloc((info->var.xres_virtual * info->var.yres_virtual) >> 3);
				if(info->screen_mono != NULL)
					memset(info->screen_mono, 0, (info->var.xres_virtual * info->var.yres_virtual) >> 3);
			}
			else if(info->screen_mono != NULL)  /* VBL nono emulation to normal => update fVDI accel functions */
			{
					extern Driver *me;
					extern void *c_line, *c_text, *c_fill, *c_fillpoly;
					Virtual *vwk = me->default_vwk;
					Workstation *wk = vwk->real_address;
					info->update_mono = 0; /* stop VBL redraw */
					info->screen_mono = NULL;
					wk->r.line = &c_line;
					wk->r.fill = &c_fill;
					wk->r.fillpoly = &c_fillpoly; 
					wk->r.text = &c_text;
			}
			if(info->screen_mono != NULL)
				*((char **)_v_bas_ad) = info->screen_mono;
			else
			{
				*((char **)_v_bas_ad) = info->screen_base;
				log_addr = (long)info->screen_base;
			}
			if(init_vdi) /* Vsetscreen, Vsetmode not change linea variables */
			{
				offscreen_init(info);
				second_screen = second_screen_aligned = 0;
				init_var_linea((long)video_found);
				switch(info->var.bits_per_pixel)
				{
					case 16: color = (unsigned long)tab_16_col_ntc[15]; break;
					case 32: color = tab_16_col_tc[15]; break;
					default: color = 15; break;
				}
				clear_screen(color, 0, 0, info->var.xres_virtual, info->var.yres_virtual); /* black screen */
				init_screen(); /* it's possible than fVDI not clear latest lines (modulo 16) */				
			}
			else if(test)
			{
				if(info->screen_mono == NULL)
				{
					for(y = 0; y < info->var.yres_virtual; y += 16)
					{
						switch(info->var.bits_per_pixel)
						{
							case 16: color = (unsigned long)tab_16_col_ntc[(y >> 4) & 15]; break;
							case 32: color = tab_16_col_tc[(y >> 4) & 15]; break;
							default: color = (unsigned long)((y >> 4) & 15); break;
						}
						clear_screen(color, 0, y, info->var.xres_virtual, info->var.yres_virtual-y >= 16 ? 16 : info->var.yres_virtual - y);
					}
				}
				else /* VBL mono emulation */
				{
					unsigned char *buffer = (unsigned char *)info->screen_mono;
					int size  = (info->var.xres_virtual >> 3) << 4;
					for(y = 0; y < info->var.yres_virtual; y += 16)
					{
						memset(buffer, (y >> 4) & 1 ? -1 : 0, size);
						buffer += size;
					}
					info->update_mono = 1;
				}
			}
			Mode = update_modecode(modecode);		
		}
		if(log_handle >= 0)
			Fclose(log_handle);
		if(dup_handle >= 0)
			Fforce(1, dup_handle); /* stdout */
		debug = save_debug;
	}
	else
	{
		if(logaddr && (logaddr != -1) && (info->screen_mono != NULL))
			*((char **)_v_bas_ad) = (char *)logaddr;
		if(physaddr && (physaddr != -1))
		{
			if((video_found) && (info->screen_mono == NULL))
			{
				int bpp = info->var.bits_per_pixel >> 3;
				physaddr -= (long)info->screen_base;
				if((physaddr < 0)
				 || (physaddr >= (info->var.xres_virtual * 8192 * bpp)))
					return(Mode);
				memcpy(&var, &info->var, sizeof(struct fb_var_screeninfo));			
				var.xoffset = (physaddr % (info->var.xres_virtual * bpp)) / bpp;
				var.yoffset = physaddr / (info->var.xres_virtual * bpp);
				if(var.yoffset < 8192)
					fb_pan_display(info, &var);
			}
			else if((info->screen_mono != NULL) && (physaddr < *phystop)) /* VBL mono emulation */
				info->screen_mono = (char *)physaddr;
		}
	}
	return(Mode);
}

long vsetmode(long modecode)
{
	long Mode;
	if(os_magic == 1)
		Mode = (long)modecode_magic & 0xFFFF;
	else
		Mode = (long)Modecode & 0xFFFF;
//	board_printf("vsetmode modecode %04X (%04X)\r\n", modecode, Mode);
	if(modecode == -1)
		return(Mode);
	vsetscreen(0, 0 , 3, modecode & 0xFFFF, 0);
	return(Mode);
}

long montype(void)
{
	if(video_found == 1) /* Radeon */
	{
		struct radeonfb_info *rinfo = info_fvdi->par;
		switch(rinfo->mon1_type)
		{
			case MT_STV: return(1); /* S-Video out */
			case MT_CRT: return(2); /* VGA */
			case MT_CTV: return(3); /* TV / composite */
//			case MT_LCD: return(4);	/* LCD */
//			case MT_DFP: return(5); /* DVI */
			default: return(2);     /* VGA */
		}
	}
	else if(video_found == 2) /* Lynx */
	{
		struct smifb_info *smiinfo = info_fvdi->par;
		/* 0:none 1:LCD 2:CRT 3:CRT/LCD 4:TV 5:TV/LCD */
		switch(smiinfo->videoout)
		{
			case 2: return(2); /* VGA */
			case 4: return(3); /* TV / composite */
			case 1:
			case 3:
			case 5:
				return(4);	/* LCD */
			default: return(2);     /* VGA */
		}	
	}
	return(2);
}

long vgetsize(long modecode)
{
	long size = 0, Mode;
	struct fb_info *info = info_fvdi;
	if(os_magic == 1)
		Mode = (long)modecode_magic & 0xFFFF;
	else
		Mode = (long)Modecode & 0xFFFF;
	if((short)modecode == Mode)
	{
		if(info->screen_mono != NULL)
			return((info->var.xres_virtual * info->var.yres_virtual) >> 3);
		return(info->var.xres_virtual * info->var.yres_virtual * (info->var.bits_per_pixel >> 3));
	}
	if(!(modecode & DEVID)) /* modecode normal */
	{
		if(modecode & STMODES)
			return(32000);
		switch(modecode & (VESA_768|VESA_600|HORFLAG2|HORFLAG|VERTFLAG|OVERSCAN|VGA|COL80))
		{		
			case (VERTFLAG|VGA):                      /* 320 * 240 */
			case 0:
				size = 320 * 240;
				break;
			case (VGA+COL80):                         /* 640 * 480 */
			case (VERTFLAG|COL80):
				size = 640 * 480;
				break;
			case (VESA_600+HORFLAG2+VGA+COL80):       /* 800 * 600 */
				size = 800 * 600;
				break;
			case (VESA_768+HORFLAG2+VGA+COL80):       /* 1024 * 768 */
				size=1024 * 768;
				break;
			case (VERTFLAG2+HORFLAG+VGA+COL80):       /* 1280 x 960 */
				size = 1280 * 960;
				break;
			case (VERTFLAG2+VESA_600+HORFLAG2+HORFLAG+VGA+COL80): /* 1600 * 1200 */
			default:
				size = 1600 * 1200;
				break;
		}
	}
	else /* bits 11-3 used for devID */
	{
		const struct fb_videomode *db = get_db_from_modecode(modecode);
		if(db == NULL)
			return(0);
		size = db->xres * db->yres;
	}
	switch(modecode & NUMCOLS)
	{
		case BPS1: size >>= 3; break;
		case BPS8: break;
		case BPS16: size <<= 1; break;
		case BPS32: size <<= 2; break;
		default: break;
	}
	if(modecode & VIRTUAL_SCREEN)
		size <<= 2;
	return(size);
}

long find_best_mode(long modecode)
{
	long i = 0, index = -1;
	switch(video_found)
	{
#if defined(COLDFIRE) && defined(MCF547X) /* FIREBEE */
		case 0: /* Videl */
			{
				extern struct fb_videomode *videl_modedb;
				extern unsigned long videl_modedb_len;
				const struct fb_videomode *db;
				while(i < videl_modedb_len)
				{
					db = &videl_modedb[i];
					if(db->flag & FB_MODE_IS_FIRST)
					{
						modecode = SET_DEVID(i + VESA_MODEDB_SIZE + total_modedb);
						return(modecode);
					}
					i++;
				}
				i = 0;
				while(i < videl_modedb_len)
				{
					db = &videl_modedb[i];
					if(db->flag & FB_MODE_IS_STANDARD)
						index = i;
					i++;
				}
			}
			break;
#endif /* defined(COLDFIRE) && defined(MCF547X) */
		case 1: /* Radeon */
			{
				struct radeonfb_info *rinfo = info_fvdi->par;
				const struct fb_videomode *db;
				while(i < rinfo->mon1_dbsize)
				{
					db = &rinfo->mon1_modedb[i];
					if(db->flag & FB_MODE_IS_FIRST)
					{
						modecode = SET_DEVID(i + VESA_MODEDB_SIZE + total_modedb);
						return(modecode);
					}
					i++;
				}
				i = 0;
				while(i < rinfo->mon1_dbsize)
				{
					db = &rinfo->mon1_modedb[i];
					if(db->flag & FB_MODE_IS_STANDARD)
						index = i;
					i++;
				}
			}
			break;
		case 2: /* Lynx */
			{
				struct radeonfb_info *smiinfo = info_fvdi->par;
				const struct fb_videomode *db;
				while(i < smiinfo->mon1_dbsize)
				{
					db = &smiinfo->mon1_modedb[i];
					if(db->flag & FB_MODE_IS_FIRST)
					{
						modecode = SET_DEVID(i + VESA_MODEDB_SIZE + total_modedb);
						return(modecode);
					}
					i++;
				}
				i = 0;
				while(i < smiinfo->mon1_dbsize)
				{
					db = &smiinfo->mon1_modedb[i];
					if(db->flag & FB_MODE_IS_STANDARD)
						index = i;
					i++;
				}
			}
			break;
	}
	if(index >= 0)
		modecode = SET_DEVID(index + VESA_MODEDB_SIZE + total_modedb); /* last standard mode */
	return(modecode);
}

long validmode(long modecode)
{
	long Mode;
	if(os_magic == 1)
		Mode = (long)modecode_magic & 0xFFFF;
	else
		Mode = (long)Modecode & 0xFFFF;
//	board_printf("validmode modecode %04X fix %d\r\n", modecode, fix_modecode);
	if((unsigned short)modecode != 0xFFFF)
	{
#ifndef COLDFIRE
		if((os_magic != 1) && ((modecode & NUMCOLS) == BPS1)) /* VBL mono emulation */
			modecode &= ~VIRTUAL_SCREEN; /* limit size */
		else
#endif
		if(((modecode & NUMCOLS) < BPS8) || ((modecode & NUMCOLS) > BPS32))
		{
			modecode &= ~NUMCOLS;
			modecode = find_best_mode(modecode) | BPS16;
		}
		if(!(modecode & DEVID)) /* modecode normal */
		{
			modecode |= (PAL|VGA);
			if(modecode & STMODES)
			{
				modecode &= (VERTFLAG|STMODES|OVERSCAN|COL80);
				modecode |= BPS16;
			}
			else if(fix_modecode < 0)
			{
				modecode &= (VERTFLAG|PAL|VGA|COL80|NUMCOLS);
				modecode |= (Mode & (VIRTUAL_SCREEN|VERTFLAG2|VESA_768|VESA_600|HORFLAG2|HORFLAG));
			}
			if((modecode & VGA) && !(modecode & COL80))
				modecode |= VERTFLAG;
		}
		else /* bits 11-3 used for devID */
		{
			if(fix_modecode < 0)
			{
			 	modecode &= NUMCOLS;
			 	modecode |= (Mode & ~NUMCOLS);
			}
#if defined(COLDFIRE) && defined(MCF547X) /* FIREBEE */
			if(!video_found) /* Videl */
			{
				extern unsigned long videl_modedb_len;
				if(GET_DEVID(modecode) >= (VESA_MODEDB_SIZE + total_modedb + videl_modedb_len))
				{
					modecode &= NUMCOLS;
					modecode |= (PAL|VGA|COL80);
				}
			}
			else
#endif /* defined(COLDFIRE) && defined(MCF547X) */
			if(video_found == 1) /* Radeon */
			{
				struct radeonfb_info *rinfo = info_fvdi->par;
				if(GET_DEVID(modecode) >= (VESA_MODEDB_SIZE + total_modedb + rinfo->mon1_dbsize))
				{
					modecode &= NUMCOLS;
					modecode |= (PAL|VGA|COL80);
				}
			}
			else if(video_found == 2) /* Lynx */
			{
				struct smifb_info *smiinfo = info_fvdi->par;
				if(GET_DEVID(modecode) >= (VESA_MODEDB_SIZE + total_modedb + smiinfo->mon1_dbsize))
				{
					modecode &= NUMCOLS;
					modecode |= (PAL|VGA|COL80);
				}
			}
			else
			{
				if(GET_DEVID(modecode) >= (VESA_MODEDB_SIZE + total_modedb))
				{
					modecode &= NUMCOLS;
					modecode |= (PAL|VGA|COL80);
				}		
			}
		}
	}
	if(fix_modecode != 1)
		fix_modecode = -1;
//	board_printf(" => modecode %04X\r\n", modecode);
	return(modecode);
}

long wait_vbl(void)
{
	if(video_found && (info_fvdi->fbops->WaitVbl != NULL))
	{
		info_fvdi->fbops->WaitVbl(info_fvdi);
		return(1);
	}
	return(0);
}

long vmalloc(long mode, long value)
{
	if(video_found)
	{
		switch(mode)
		{
			case 0:
				if(value)
					return(offscreen_alloc(info_fvdi, value));
				break;
			case 1:
				return(offscreen_free(info_fvdi, value));
			case 2:
				if(value > 0)
					info_fvdi = (struct fb_info *)value;
				offscreen_init(info_fvdi);
				return(0);
				break;
		}
	}
	return(-1);
}

long InitVideo(void) /* test for Video input */
{
#if 0 /* todo */
	if(video_found == 1) /* Radeon */
	{
		struct radeonfb_info *rinfo = info_vdi->par;
		RADEONInitVideo(rinfo);
		Cconin();	
		RADEONPutVideo(rinfo, 0, 0, 720, 576, 0, 0, 640, 512);
		Cconin();
		RADEONStopVideo(rinfo, 1);	
		Cconin();
		RADEONShutdownVideo(rinfo);
		Cconin();	
	}
#endif
	return(0);
}

#ifdef NETWORK
#ifdef COLDFIRE
#ifndef MCF5445X

#ifdef SOUND_AC97

#undef DEBUG

#ifdef MCF547X
#define AC97_DEVICE 2 /* FIREBEE */
#else /* MCF548X */
#define AC97_DEVICE 3 /* M5484LITE */
#endif /* MCF547X */
#define SETSMPFREQ 7
#define SETFMT8BITS 8
#define SETFMT16BITS 9
#define SETFMT24BITS 10
#define SETFMT32BITS 11
#define LTGAINMASTER 12
#define RTGAINMASTER 13
#define LTGAINMIC 14
#define RTGAINMIC 15
#define LTGAINFM 16
#define RTGAINFM 17
#define LTGAINLINE 18
#define RTGAINLINE 19
#define LTGAINCD 20
#define RTGAINCD 21
#define LTGAINVIDEO 22
#define RTGAINVIDEO 23
#define LTGAINAUX 24
#define RTGAINAUX 25

#define SI_CALLBACK 2

struct McSnCookie
{
	short vers; // version in BCD
	short size; // size the structure
	short play;
	short record;
	short dsp;  // Is the DSP there?
	short pint; // Playing: Interrupt possible with frame-end?
 	short rint; // Recording: Interrupt possible with frame-end?
	long res1;
	long res2;
	long res3;
	long res4;
};

long flag_snd_init, flag_gsxb, count_timer_a, preload_timer_a, timer_a_enabled, io7_enabled; 
static long flag_snd_lock, status_dma, mode_res;
static long volume_play, volume_record, volume_master, volume_mic, volume_fm, volume_line, volume_cd, volume_video, volume_aux;
static long adder_inputs, record_source;
static long nb_tracks_play, nb_tracks_record, mon_track;
static long flag_clock_44_48, prescale_ste, frequency, cause_inter;
static long play_addr, record_addr, end_play_addr, end_record_addr;
static void (*callback_play)(), (*callback_record)();
extern void display_string(char *string);
extern void ltoa(char *buf, long n, unsigned long base);

static unsigned short tab_freq_falcon[] = {
	// internal
	49170, 33800, 24585, 20770, 16940, 16940, 12292, 12292, 9834, 9834, 8195, // 25.175 MHz
	// external
	44100, 29400, 22050, 17640, 14700, 14700, 11025, 11025, 8820, 8820, 7350, // 22.5792 MHz
	48000, 32000, 24000, 19200, 16000, 16000, 12000, 12000, 9600, 9600, 8000 }; // 24.576 MHz
// static unsigned short tab_freq_ste[] = { 6258, 12517, 25033, 50066 };
static unsigned short tab_freq_ste[] = { 6146, 12292, 24585, 49170 };
struct McSnCookie cookie_mac_sound = { 0x0100, 30, 2, 2, 0, 1, 1, 0, 0, 0, 0 }; 

void call_timer_a(void)
{
	void *vect_timer_a = *(void **)0x134;
	if((vect_timer_a == NULL) || (!timer_a_enabled))
		return;
	count_timer_a--;
	if(count_timer_a > 0)
		return;
	count_timer_a = preload_timer_a;
	asm volatile (
		" clr.w -(SP)\n\t"         /* 68K format */
		" pea.l .next_timer_a(PC)\n\t" /* return address */
		" clr.w -(SP)\n\t"         /* space for SR */
		" move.l D0,-(SP)\n\t"
		" move.w SR,D0\n\t"
		" move.w D0,4(SP)\n\t"
		" move.l (SP)+,D0\n\t"
		" move.l 0x134,-(SP)\n\t"  /* timer A vector */
		"	rts\n\t"
		".next_timer_a:" );
}

void call_io7_mfp(void)
{
	void *vect_io7 = *(void **)0x13C;
	if((vect_io7 == NULL) || (!io7_enabled))
		return;
	asm volatile (
		" clr.w -(SP)\n\t"         /* 68K format */
		"	pea.l .next_io7(PC)\n\t" /* return address */
		" clr.w -(SP)\n\t"		     /* space for SR */
		" move.l D0,-(SP)\n\t"
		" move.w SR,D0\n\t"
		" move.w D0,4(SP)\n\t"
		" move.l (SP)+,D0\n\t"
		" move.l 0x13C,-(SP)\n\t"
		"	rts\n\t"
		".next_io7:" );            /* IO7 MFP vector */
}

void stop_dma_play(void)
{
	if(status_dma & SB_PLA_ENA)
	{
		mcf548x_ac97_playback_trigger(AC97_DEVICE, 0);
		mcf548x_ac97_playback_close(AC97_DEVICE);
		status_dma &= ~SB_PLA_ENA;
	}
}

void stop_dma_record(void)
{
	if(status_dma & SB_REC_ENA)
	{
		mcf548x_ac97_capture_trigger(AC97_DEVICE, 0);
		mcf548x_ac97_capture_close(AC97_DEVICE);
		status_dma &= ~SB_REC_ENA;
	}
}

long locksnd(void)
{
#ifdef DEBUG
	display_string("locksnd\r\n");
#endif
	if(flag_snd_lock)
		return(-128);
	flag_snd_lock = 1;
	flag_clock_44_48 = 0; /* seems better for SDL who use devconnect(DMAPLAY,DAC,CLKEXT,prediv,1) */
#ifdef DEBUG
	display_string("locksnd ok\r\n");
#endif
	return(1);
}

long unlocksnd(void)
{
#ifdef DEBUG
	display_string("unlocksnd\r\n");
#endif
	if(!flag_snd_lock)
		return(-127);
	flag_snd_lock = 0;
#ifdef DEBUG
	display_string("unlocksnd ok\r\n");
#endif
	return(0);
}

static long get_left_volume(long volume)
{
	if(flag_gsxb)
		return(255 - (volume & 0xff));
	else			
		return(volume & 0xff);
}

static void set_left_volume(unsigned long data, long *volume)
{
	*volume &= 0xff00;
	if(flag_gsxb)
		*volume |= ((255 - data) & 0xff);
	else
		*volume |= (data & 0xff);
}

static long get_right_volume(long volume)
{
	if(flag_gsxb)
		return(255 - ((volume >> 8) & 0xff));				
	else
		return((volume >> 8) & 0xff);
}

static void set_right_volume(unsigned long data, long *volume)
{                
	*volume &= 0xff;
	data &= 0xff;
	if(flag_gsxb)
		*volume |= ((255 - data) << 8);
	else
		*volume |= (data << 8);
}

long soundcmd(long mode, unsigned long data)
{
	int val1, val2;
	long temp;
#ifdef DEBUG
	if(data < 0x8000)
	{
		char buf[10];
		display_string("soundcmd, mode: ");
		ltoa(buf, mode, 10);
		display_string(buf);
		display_string(", data: ");
		ltoa(buf, data, 10);
		display_string(buf);
		display_string("\r\n");
	}
#endif
	switch(mode)
	{
		case LTATTEN:
		case RTATTEN:
			if(mode == LTATTEN)
			{
				if(data >= 0x8000)
					return(255 - (volume_play & 0xff));
				volume_play &= 0xff00;
				volume_play |= ((255 - data) & 0xff);
			}
			else /* RTATTEN */
			{
				if(data >= 0x8000)
					return(255 - ((volume_play >> 8) & 0xff));
				volume_play &= 0xff;
				data &= 0xff;
				volume_play |= ((255 - data) << 8);			
			}			
			mcf548x_ac97_ioctl(AC97_DEVICE, SOUND_MIXER_WRITE_PCM, (void *)&volume_play);
			return(data);
		case LTGAIN:
		case RTGAIN:
			if(mode == LTGAIN)
			{
				if(data >= 0x8000)
					return(volume_record & 0xff);
				volume_record &= 0xff00;
				volume_record |= (data & 0xff);
			}
			else /* RTGAIN */
			{
				if(data >= 0x8000)
					return((volume_record >> 8) & 0xff);
				volume_record &= 0xff;
				volume_record |= ((data & 0xff) << 8);			
			}
			mcf548x_ac97_ioctl(AC97_DEVICE, SOUND_MIXER_WRITE_RECLEV, (void *)&volume_record);
			return(data);
		case ADDERIN: /* Select inputs to adder 0=off, 1=on */
			if(data >= 0x8000)
				return(adder_inputs);
			if(data & ADCIN) /* Input from ADC */
				val1 = 0x1ff0000;
			else
				val1 = 0x1000000;
			mcf548x_ac97_ioctl(AC97_DEVICE, SOUND_MIXER_WRITE_MIC, (void *)&val1);
			if(data & MATIN) /* Input from connection matrix */
				val1 = 0x1ff0000;
			else
				val1 = 0x1000000;
			mcf548x_ac97_ioctl(AC97_DEVICE, SOUND_MIXER_WRITE_VOLUME, (void *)&val1); // Master
			if(data & 0x4000) /* Bit 14 */
			{
				/* extended values valid by bit 5 of cookie '_SND'
				   Bit 2: Mic
				   Bit 3: FM-Generator, PC Beep on AC97
				   Bit 4: Line
				   Bit 5: CD
					 Bit 6: Video
				   Bit 7: Aux1
				   bit 8: PCM
				*/
				adder_inputs = data & 0x1ff;
				if(data & 4) /* Mic */
					val1 = 0x1ff0000;
				else
					val1 = 0x1000000;
				mcf548x_ac97_ioctl(AC97_DEVICE, SOUND_MIXER_WRITE_MIC, (void *)&val1); // Mic
				if(data & 8) /* FM-Generator, PC Beep on AC97 */
					val1 = 0x1ff0000;
				else
					val1 = 0x1000000;
				mcf548x_ac97_ioctl(AC97_DEVICE, SOUND_MIXER_WRITE_SYNTH, (void *)&val1);  // FM enable
				mcf548x_ac97_ioctl(AC97_DEVICE, SOUND_MIXER_WRITE_ENHANCE, (void *)&val1); // 3D enable
				if(data & 0x10) /* Line */
					val1 = 0x1ff0000;
				else
					val1 = 0x1000000;
				mcf548x_ac97_ioctl(AC97_DEVICE, SOUND_MIXER_WRITE_LINE, (void *)&val1);
				if(data & 0x20) /* CD */
					val1 = 0x1ff0000;
				else
					val1 = 0x1000000;
				mcf548x_ac97_ioctl(AC97_DEVICE, SOUND_MIXER_WRITE_CD, (void *)&val1);
				if(data & 0x40) /* Video */
					val1 = 0x1ff0000;
				else
					val1 = 0x1000000;
				mcf548x_ac97_ioctl(AC97_DEVICE, SOUND_MIXER_WRITE_LINE2, (void *)&val1); // Video
				if(data & 0x80) /* Aux */
					val1 = 0x1ff0000;
				else
					val1 = 0x1000000;
				mcf548x_ac97_ioctl(AC97_DEVICE, SOUND_MIXER_WRITE_LINE1, (void *)&val1); // Aux1
				if(data & 0x100) /* PCM */
					val1 = 0x1ff0000;
				else
					val1 = 0x1000000;
				mcf548x_ac97_ioctl(AC97_DEVICE, SOUND_MIXER_WRITE_PCM, (void *)&val1);
			}
			else
				adder_inputs = (data & 3) + (adder_inputs & ~3);
			return(adder_inputs);
			break;
		case ADCINPUT: /* Select input to ADC, 0=mic, 1=PSG */
			if(data >= 0x8000)
				return(record_source);			
			record_source = data & (ADCRT | ADCLT | 0x3ffc);
			if(!(data & 0x4000))
			{
				if(data & ADCRT) /* Right channel input */
					val2 = RECORD_SOURCE_AUX; /* (Firebee PSG) */
				else
					val2 = RECORD_SOURCE_LINE;
				if(data & ADCLT) /* Left channel input */
					val1 = RECORD_SOURCE_AUX; /* (Firebee PSG) */
				else
					val1 = RECORD_SOURCE_LINE;			
			}
			else  /* Bit 14 */
			{
				/* extended values valid by bit 5 of cookie '_SND'
					 Bit 0: right microphone
					 Bit 1: left microphone 
				   Bit 2: right FM-Generator, not used on AC97
				   Bit 3: left FM-Generator, not used on AC97
				   Bit 4: right Line input
				   Bit 5: left Line input
				   Bit 6: right CD
				   Bit 7: left CD                   
				   Bit 8: right Video
				   Bit 9: left Video
				   Bit 10: right Aux
				   Bit 11: left Aux
				   Bit 12: right Mix out
				   Bit 13: left Mix out
				*/
				if(!(data & 1)) /* Microphone right input */
					val2 = RECORD_SOURCE_MIC; 
				if(!(data & 2)) /* Microphone left input */
					val1 = RECORD_SOURCE_MIC; 
				if(!(data & 0x10)) /* Line right input */
					val2 = RECORD_SOURCE_LINE; 
				if(!(data & 0x20)) /* Line left input */
					val1 = RECORD_SOURCE_LINE; 
				if(!(data & 0x40)) /* CD right input */
					val2 = RECORD_SOURCE_CD;
				if(!(data & 0x80)) /* CD left input*/
					val1 = RECORD_SOURCE_CD;
				if(!(data & 0x100)) /* Video right */
					val2 = RECORD_SOURCE_VIDEO;
				if(!(data & 0x200)) /* Video left */
					val1 = RECORD_SOURCE_VIDEO;
				if(!(data & 0x400)) /* Aux right (Firebee PSG)  */
					val2 = RECORD_SOURCE_AUX;
				if(!(data & 0x800)) /* Aux left (Firebee PSG) */
					val1 = RECORD_SOURCE_AUX;
				if(!(data & 0x1000)) /* Mix right out */
					val2 = RECORD_SOURCE_STEREO_MIX;
				if(!(data & 0x2000)) /* Mix left out */
					val1 = RECORD_SOURCE_STEREO_MIX;
			}
			switch(val1) // left
			{
				case RECORD_SOURCE_MIC: record_source &= ~ADCLT; break;
				case RECORD_SOURCE_CD: record_source &= ~0x80; break;
				case RECORD_SOURCE_VIDEO: record_source &= ~0x200; break;
				case RECORD_SOURCE_AUX: record_source &= ~0x800; break;
				case RECORD_SOURCE_LINE: record_source &= ~0x20; break;
				case RECORD_SOURCE_STEREO_MIX: record_source &= ~0x2000; break;
			}
			switch(val2) // right
			{
				case RECORD_SOURCE_MIC: record_source &= ~ADCRT; break;
				case RECORD_SOURCE_CD: record_source &= ~0x40; break;
				case RECORD_SOURCE_VIDEO: record_source &= ~0x100; break;
				case RECORD_SOURCE_AUX: record_source &= ~0x400; break;
				case RECORD_SOURCE_LINE: record_source &= ~0x10; break;
				case RECORD_SOURCE_STEREO_MIX: record_source &= ~0x1000; break;
			}
			val2 <<= 8;
			val2 |= val1;
			mcf548x_ac97_ioctl(AC97_DEVICE, SOUND_MIXER_WRITE_RECSRC, (void *)&val2);
			return(record_source);
		case SETPRESCALE:
			if(data >= 0x8000)
				return prescale_ste;
			switch(data)
			{
				case PREMUTE:
				case PRE640:
				case PRE320:
				case PRE160:
					prescale_ste = data;
					break;
			}
			return(prescale_ste);
		case SETSMPFREQ: /* valid by bit 5 of cookie '_SND' */
			if(data != 0xFFFF)
			{
				int i = 0, index = 0;
				long d, mini = 999999;
				data &= 0xffff;
				while(i < sizeof(tab_freq_falcon)/sizeof(tab_freq_falcon[0]))
				{
					d = tab_freq_falcon[i++] - data;
					if(d < 0)
						d = -d;
					if(d < mini)
					{
						mini = d;
						index = i - 1;
					}
				}
				frequency = tab_freq_falcon[index];
			}
			return(frequency);
		case SETFMT8BITS: /* valid by bit 5 of cookie '_SND' */
			return(1); /* signed */
		case SETFMT16BITS: /* valid by bit 5 of cookie '_SND' */
			return(5); /* signed motorola big endian */
		/* WARNING: GSXB use attenuations and MilanBlaster gains ! */
		case LTGAINMASTER: /* valid by bit 5 of cookie '_SND' */
			if(data >= 0x8000)
				return(get_left_volume(volume_master));
			set_left_volume(data, &volume_master);
			mcf548x_ac97_ioctl(AC97_DEVICE, SOUND_MIXER_WRITE_VOLUME, (void *)&volume_master);
			return(data);
		case RTGAINMASTER: /* valid by bit 5 of cookie '_SND' */
			if(data >= 0x8000)
				return(get_right_volume(volume_master));
			set_right_volume(data, &volume_master);
			mcf548x_ac97_ioctl(AC97_DEVICE, SOUND_MIXER_WRITE_VOLUME, (void *)&volume_master);
			return(data);
		case LTGAINMIC: /* valid by bit 5 of cookie '_SND' */
			if(data >= 0x8000)
				return(get_left_volume(volume_mic));
			set_left_volume(data, &volume_mic);
			mcf548x_ac97_ioctl(AC97_DEVICE, SOUND_MIXER_WRITE_MIC, (void *)&volume_mic);
			return(data);
		case RTGAINMIC: /* valid by bit 5 of cookie '_SND' */
			if(data >= 0x8000)
				return(get_right_volume(volume_mic));
			set_right_volume(data, &volume_mic);
			mcf548x_ac97_ioctl(AC97_DEVICE, SOUND_MIXER_WRITE_MIC, (void *)&volume_mic);
			return(data);
		case LTGAINFM: /* valid by bit 5 of cookie '_SND' */
			if(data >= 0x8000)
				return(get_left_volume(volume_fm));
			set_left_volume(data, &volume_fm);
			temp = volume_fm & 0xff;
			mcf548x_ac97_ioctl(AC97_DEVICE, SOUND_MIXER_WRITE_SYNTH, (void *)&temp); // PC Beep
			return(data);
		case RTGAINFM: /* valid by bit 5 of cookie '_SND' */
			if(data >= 0x8000)
				return(get_right_volume(volume_fm));
			set_right_volume(data, &volume_fm);
			temp = volume_fm >> 8;
			mcf548x_ac97_ioctl(AC97_DEVICE, SOUND_MIXER_WRITE_ENHANCE, (void *)&temp); // 3D Control
			return(data);
		case LTGAINLINE: /* valid by bit 5 of cookie '_SND' */
			if(data >= 0x8000)
				return(get_left_volume(volume_line));
			set_left_volume(data, &volume_line);
			mcf548x_ac97_ioctl(AC97_DEVICE, SOUND_MIXER_WRITE_LINE, (void *)&volume_line);
			return(data);
		case RTGAINLINE: /* valid by bit 5 of cookie '_SND' */
			if(data >= 0x8000)
				return(get_right_volume(volume_line));
			set_right_volume(data, &volume_line);
			mcf548x_ac97_ioctl(AC97_DEVICE, SOUND_MIXER_WRITE_LINE, (void *)&volume_line);
			return(data);
		case LTGAINCD: /* valid by bit 5 of cookie '_SND' */
			if(data >= 0x8000)
				return(get_left_volume(volume_cd));
			set_left_volume(data, &volume_cd);
			mcf548x_ac97_ioctl(AC97_DEVICE, SOUND_MIXER_WRITE_CD, (void *)&volume_cd);
			return(data);
		case RTGAINCD: /* valid by bit 5 of cookie '_SND' */
			if(data >= 0x8000)
				return(get_right_volume(volume_cd));
			set_right_volume(data, &volume_cd);
			mcf548x_ac97_ioctl(AC97_DEVICE, SOUND_MIXER_WRITE_CD, (void *)&volume_cd);
			return(data);
		case LTGAINVIDEO: /* valid by bit 5 of cookie '_SND' */
			if(data >= 0x8000)
				return(get_left_volume(volume_video));
			set_left_volume(data, &volume_video);
			mcf548x_ac97_ioctl(AC97_DEVICE, SOUND_MIXER_WRITE_LINE2, (void *)&volume_video);
			return(data);
		case RTGAINVIDEO: /* valid by bit 5 of cookie '_SND' */
			if(data >= 0x8000)
				return(get_right_volume(volume_video));
			set_right_volume(data, &volume_video);
			mcf548x_ac97_ioctl(AC97_DEVICE, SOUND_MIXER_WRITE_LINE2, (void *)&volume_video);
			return(data);
		case LTGAINAUX: /* valid by bit 5 of cookie '_SND' */
			if(data >= 0x8000)
				return(get_left_volume(volume_aux));
			set_left_volume(data, &volume_aux);
			mcf548x_ac97_ioctl(AC97_DEVICE, SOUND_MIXER_WRITE_LINE1, (void *)&volume_aux);
			return(data);
		case RTGAINAUX: /* valid by bit 5 of cookie '_SND' */
			if(data >= 0x8000)
				return(get_right_volume(volume_aux));
			set_right_volume(data, &volume_aux);
			mcf548x_ac97_ioctl(AC97_DEVICE, SOUND_MIXER_WRITE_LINE1, (void *)&volume_aux);
			return(data);
	}
	return(-15); /* ENODEV */
}

long setbuffer(long reg, long begaddr, long endaddr)
{
	void *ptr[2];
	if(endaddr <= begaddr)
		return(1); // error
#ifdef DEBUG
	{
		char buf[10];
		display_string("setbuffer, reg: ");
		ltoa(buf, reg, 10);
		display_string(buf);
		display_string(", begaddr: 0x");
		ltoa(buf, (long)begaddr, 16);
		display_string(buf);
		display_string(", endaddr: 0x");
		ltoa(buf, (long)endaddr, 16);
		display_string(buf);
		display_string("\r\n");
	}
#endif
	switch(reg)
	{
		case SR_PLAY:
			play_addr = begaddr;
			end_play_addr = endaddr;
			if(status_dma & SB_PLA_ENA)
			{
				ptr[0] = (void *)play_addr;
				ptr[1] = (void *)end_play_addr;
				mcf548x_ac97_playback_pointer(AC97_DEVICE, (void **)&ptr, 1);
			}
			return(0); // OK
		case SR_RECORD:
			record_addr = begaddr;
			end_record_addr = endaddr;
			if(status_dma & SB_REC_ENA)
			{
				ptr[0] = (void *)record_addr;
				ptr[1] = (void *)end_record_addr;
				mcf548x_ac97_capture_pointer(AC97_DEVICE, (void **)&ptr, 1);
			}
			return(0); // OK
	}
	return(1); // error
}

long setmode(long mode)
{
	switch(mode & 0xff)
	{
		case STEREO8:
		case STEREO16:
		case MONO8:
		/* valid by bit 5 of cookie '_SND' */
		case MONO16:
			break;
		return(1); // error
	}
	switch(mode & 0xff00)
	{
		case RECORD_STEREO16:
		/* valid by bit 5 of cookie '_SND' */
		case RECORD_STEREO8:
		case RECORD_MONO8:
		case RECORD_MONO16:
    	break;
 		default:
 			return(1); // error
 	}
	mode_res = mode;
	return(0); // OK
}

long settracks(long playtracks, long rectracks)
{
	nb_tracks_play = playtracks & 3;
	nb_tracks_record = rectracks & 3; // not used actually
	return(0); // OK
}

long setmontracks(long track)
{
	mon_track = track & 3; // not used actually
	return(0); // OK
}

long setinterrupt(long src, long cause, void (*callback)())
{
#ifdef DEBUG
	{
		char buf[10];
		display_string("setinterrupt, src: ");
		ltoa(buf, src, 10);
		display_string(buf);
		display_string(", cause: ");
		ltoa(buf, cause, 10);
		display_string(buf);
		if(src == SI_CALLBACK)
		{
			display_string(", callback: 0x");
			ltoa(buf, (long)callback, 16);
			display_string(buf);
		}
		display_string("\r\n");
	}
#endif
	switch(src)
	{
		case SI_TIMERA:
			switch(cause)
			{
				case SI_NONE:
				case SI_PLAY:
				case SI_RECORD:
				case SI_BOTH:
					cause_inter = cause;
					return(0); // OK
			}
			break;
		case SI_MFPI7:
			switch(cause)
			{
				case SI_NONE:
				case SI_PLAY:
				case SI_RECORD:
				case SI_BOTH:
					cause_inter = cause | 0x100;
					return(0); // OK
			}
			break;
		case SI_CALLBACK: // valid by bit 5 of cookie '_SND'
			switch(cause)
			{
				case SI_NONE: callback_play = callback_record = NULL; break; // disable interrupt
				case SI_PLAY: callback_play = callback; break;	// int_addr called on eof DAC interrupts
				case SI_RECORD: callback_record = callback;	break; // int_addr called on eof ADC interrupts
				case SI_BOTH: callback_play = callback_record = callback; break; // int_addr called on eof DAC/ADC interrupts
			}
			mcf548x_ac97_playback_callback(AC97_DEVICE, callback_play);
			mcf548x_ac97_capture_callback(AC97_DEVICE, callback_record);
			cause_inter = 0;
			return(0); // OK
			break;
	}
	return(1); // error
}

long buffoper(long mode)
{
	void *ptr[2];
	void *ptr_play, *ptr_record;
#ifdef DEBUG
	if(mode >= 0)
	{
		char buf[10];
		display_string("buffoper, mode: ");
		ltoa(buf, mode, 10);
		display_string(buf);
		display_string(", status_dma: ");
		ltoa(buf, status_dma, 10);
		display_string(buf);
		display_string("\r\n");
	}
#endif
	mcf548x_ac97_playback_pointer(AC97_DEVICE, &ptr_play, 0);
	mcf548x_ac97_capture_pointer(AC97_DEVICE, &ptr_record, 0);
	if(ptr_play == NULL)
		stop_dma_play(); /* => status_dma update */
	if(ptr_record == NULL)
		stop_dma_record(); /* => status_dma update */
	if(mode < 0)
	  return(status_dma);
	if((mode & SB_PLA_ENA) /* Play enable */
	 && !(status_dma & SB_PLA_ENA))
	{
		if(!mcf548x_ac97_playback_open(AC97_DEVICE))
		{
			if(!mcf548x_ac97_playback_prepare(AC97_DEVICE, frequency, mode_res, mode))
			{
				ptr[0] = (void *)play_addr;
				ptr[1] = (void *)end_play_addr;
				if(!mcf548x_ac97_playback_pointer(AC97_DEVICE, (void **)&ptr, 1)
				 && !mcf548x_ac97_playback_trigger(AC97_DEVICE, 1))
			 		status_dma |= SB_PLA_ENA;
		 	}
		 	else
				mcf548x_ac97_playback_close(AC97_DEVICE);
		}
	}
	if(!(mode & SB_PLA_ENA) && (status_dma & SB_PLA_ENA))
	{
		stop_dma_play();
		return(0);	
	}
	if((mode & SB_REC_ENA) /* Record enable */
	 && !(status_dma & SB_REC_ENA))
	{
		if(!mcf548x_ac97_capture_open(AC97_DEVICE))
		{
			if(!mcf548x_ac97_capture_prepare(AC97_DEVICE, frequency, mode_res, mode))
			{
				ptr[0] = (void *)record_addr;
				ptr[1] = (void *)end_record_addr;
				if(!mcf548x_ac97_capture_pointer(AC97_DEVICE, (void **)&ptr, 1)
				 && !mcf548x_ac97_capture_trigger(AC97_DEVICE, 1))
					status_dma |= SB_REC_ENA;
			}
			else
				mcf548x_ac97_capture_close(AC97_DEVICE);
		}
	}
	if(!(mode & SB_REC_ENA) && (status_dma & SB_REC_ENA))
	{
		stop_dma_record();
		return(0);	
	}
	return(0); // OK
}

long gpio(long mode, long data)
{
// bit0: 0: external clock 22.5792 Mhz for 44.1KHz, 1: clock 24.576 MHz for 48KHZ
// bit1: 1 for quartz
#ifdef DEBUG
	char buf[10];
	display_string("gpio, mode: ");
	ltoa(buf, mode, 10);
	display_string(buf);
	display_string(", data: ");
	ltoa(buf, data, 10);
	display_string(buf);
	display_string("\r\n");
#endif
	switch(mode)
	{
		case GPIO_READ:
			return(flag_clock_44_48 ? 3 : 2);
		case GPIO_WRITE:
			flag_clock_44_48 = data & 1;
   		break;
	}
	return(0); // OK
}

long devconnect(long src, long dest, long srcclk, long prescale, long protocol)
{
#ifdef DEBUG
	char buf[10];
	display_string("devconnect, src: ");
	ltoa(buf, src, 10);
	display_string(buf);
	display_string(", dest: ");
	ltoa(buf, dest, 10);
	display_string(buf);
	display_string(", srcclk: ");
	ltoa(buf, srcclk, 10);
	display_string(buf);
	display_string(", prescale: ");
	ltoa(buf, prescale, 10);
	display_string(buf);
	display_string("\r\n");
#endif
	switch(prescale)
	{
		case CLKOLD:
		case CLK50K:
		case CLK33K:
		case CLK25K:
		case CLK20K:
		case CLK16K:
		case CLK12K:
		case CLK10K:
		case CLK8K:
			break;
    default:
    	return(1); // error
	}
	switch(srcclk)
	{
		case CLK25M:
		  if(prescale == CLKOLD)
		  	frequency = tab_freq_ste[prescale_ste & 3];
		  else
		  	frequency = tab_freq_falcon[prescale - 1];
			break;		
		case CLKEXT:
		  if(prescale == CLKOLD)
		  	frequency = (long)tab_freq_ste[prescale_ste & 3] & 0xFFFF;
		  else
		  {
		  	if(!flag_clock_44_48)
		  		frequency = (long)tab_freq_falcon[prescale + 11 - 1] & 0xFFFF;
				else
		  		frequency = (long)tab_freq_falcon[prescale + (11*2) - 1] & 0xFFFF;
		 	}
			break;
		default:
			return(1); // error
	}
	switch(src)
	{
		case DMAPLAY:
		case ADC:
			return(0); // OK
		case DSPXMIT:
		case EXTINP:
		default:
			return(1); // error
	}
/* dest: DMAREC 1, DSPRECV 2, EXTOUT 4, DAC 8 */
}

long sndstatus(long reset)
{
	long max = 189;
	long min = 66;
	switch(reset)
	{
		case SND_CHECK:
			return(SS_OK);
		case SND_RESET:
			stop_dma_play();
			stop_dma_record();
			soundcmd(LTATTEN, 66);
			soundcmd(RTATTEN, 66);
			soundcmd(LTGAIN, 0);
			soundcmd(RTGAIN, 0); 
			/* WARNING: GSXB use attenuations and MilanBlaster gains ! */
			if(flag_gsxb)
			{
				long temp = max;
				max = min;
				min = temp;
			}
			/* new calls */
			soundcmd(LTGAINMASTER, max);
			soundcmd(RTGAINMASTER, max); 
			soundcmd(LTGAINMIC, min);
			soundcmd(RTGAINMIC, min);
			soundcmd(LTGAINLINE, flag_gsxb ? 0 : 255);
			soundcmd(RTGAINLINE, flag_gsxb ? 0 : 255);
			soundcmd(LTGAINCD, min);
			soundcmd(RTGAINCD, min);
			soundcmd(LTGAINVIDEO, min);
			soundcmd(RTGAINVIDEO, min);
			soundcmd(LTGAINAUX, min); // (Firebee PSG)
			soundcmd(RTGAINAUX, min); // (Firebee PSG)
			soundcmd(LTGAINFM, min); // PC Beep
			soundcmd(RTGAINFM, min); // 3D Control
			soundcmd(ADDERIN, ADCIN + MATIN + 0x41B4); /* + PCM / Aux / CD / Mic */
			soundcmd(ADCINPUT, 0);
			status_dma = 0;
			nb_tracks_play = nb_tracks_record = mon_track = 0;
			flag_clock_44_48 = prescale_ste = 0;
			play_addr = record_addr = 0;
			cause_inter = 0;
			callback_play = callback_record = NULL;
			mcf548x_ac97_ioctl(AC97_DEVICE, SOUND_MIXER_WRITE_POWERDOWN, NULL);
			return(SS_OK);
		/* extended values valid by bit 5 of cookie '_SND' */
		case 2: // resolutions
			return(3); // 8 & 16 bits
		case 3: // MasterMix
		  /* Bit 0: A/D (ADC-InMix bypass)   X
		     Bit 1: D/A (DAC/Multiplexer)    X
		     Bit 2: Mic                      X
		     Bit 3: FM-Generator             X (PC Beep / 3D Control)
		     Bit 4: Line                     X
		     Bit 5: CD                       X
		     Bit 6: Video                    X
		     Bit 7: Aux1                     X
		   */
			return(0xff);
		case 4: // record sources
			/* Bit 0: Mic right                X
			   Bit 1: Mic left                 X
			   Bit 2: FM-Generator right
			   Bit 3: FM-Generator left
			   Bit 4: Line right               X
			   Bit 5: Line left                X
			   Bit 6: CD right                 X
			   Bit 7: CD left                  X
			   Bit 8: Video right              X
			   Bit 9: Video left               X
			   Bit 10: Aux1 right              X
			   Bit 11: Aux1 left               X
			   Bit 12: Mixer right (MasterMix) X
			   Bit 13: Mixer left (MasterMix)  X
			*/
			return(0x3ff3);
		case 5: // duplex
			return(0);
		case 8: // format8bits
			return(1); // signed
		case 9: // format16bits
			return(5); // signed motorola big endian
		default:
			return(-15); /* ENODEV */
	}
}

long buffptr(SndBufPtr *ptr)
{
	mcf548x_ac97_playback_pointer(AC97_DEVICE, (void **)&ptr->play, 0);
	mcf548x_ac97_capture_pointer(AC97_DEVICE, (void **)&ptr->record, 0);
#ifdef DEBUG
	{
		char buf[10];
		display_string("buffptr, play: 0x");
		ltoa(buf, (long)ptr->play, 16);
		display_string(buf);
		display_string(", record: 0x");
		ltoa(buf, (long)ptr->record, 16);
		display_string(buf);
		display_string("\r\n");
	}
#endif
	if(ptr->play == NULL)
	{
		ptr->play = (char *)play_addr;
		stop_dma_play();
	}
	if(ptr->record == NULL)
	{
		ptr->record = (char *)record_addr;
		stop_dma_record();
	}
	ptr->reserve1 = ptr->reserve2 = 0;
	return(0); // OK
}

long InitSound(long type_gsxb)
{
	if(!mcf548x_ac97_install(AC97_DEVICE))
	{
		COOKIE mcsn;
		COOKIE gsxb;
		COOKIE *p = get_cookie('_SND');
		if(p != 0)
		{
			p->v.l &= 0x9;  /* preserve PSG & DSP bits */
#ifdef MCF547X
			p->v.l |= 0x27; /* bit 5: extended mode, bit 2: 16 bits DMA, bit 1: 8 bits DMA, bit 0: YM2149 */
#else
			p->v.l |= 0x26; /* bit 5: extended mode, bit 2: 16 bits DMA, bit 1: 8 bits DMA */
#endif
		}
		mcsn.ident = 'McSn';
		mcsn.v.l = (long)&cookie_mac_sound;
		add_cookie(&mcsn);
		if(type_gsxb)
		{
			gsxb.ident = 'GSXB';
			gsxb.v.l = 0;
			add_cookie(&gsxb);
		}
		flag_snd_init = 1;
		flag_gsxb = type_gsxb;
		sndstatus(SND_RESET);
		return(0); // OK
	}
	flag_snd_init = 0;
	return(-1); // error
}

#else

long InitSound(long gsxb)
{
	return(-1); // error
}

#endif /* SOUND_AC97 */

#endif /* MCF5445X */
#endif /* COLDFIRE */
#endif /* NETWORK */

