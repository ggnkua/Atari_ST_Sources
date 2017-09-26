/*
	RGB test library for video info programs

	Copyright (C) 2002	Patrice Mandin

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#include <stdlib.h>

#include "rgb.h"

/*--- Functions prototypes ---*/

static void RGB_Plot2(unsigned short *buffer, int x, int color);
static void RGB_Plot4(unsigned short *buffer, int x, int color);
static void RGB_Plot8(unsigned short *buffer, int x, int color);

/*--- Functions ---*/

/* Init a framebuffer structure */

void RGB_InitFramebuffer(framebuffer_t *framebuffer, unsigned short width, unsigned short height, unsigned short bpp)
{
	framebuffer->width = width;
	framebuffer->height = height;
	framebuffer->bpp = bpp;

	framebuffer->buffer = NULL;
	framebuffer->pitch = (framebuffer->width * framebuffer->bpp)>>3;
	framebuffer->format = FBFORMAT_PACKED;
	FBMASK(0, 0, 0, 0);
	FBLOSS(8, 8, 8, 8);
	FBSHIFT(0, 0, 0, 0);

	switch(framebuffer->bpp) {
		case 8:
			framebuffer->pixsize = 1;
			framebuffer->format = FBFORMAT_BITPLANES;
			break;
		case 15:
			framebuffer->pixsize = 2;
			framebuffer->pitch = (framebuffer->width * (framebuffer->bpp+1))>>3;
			FBMASK(1<<15, 31<<10, 31<<5, 31);
			FBLOSS(7, 3, 3, 3);
			FBSHIFT(15, 10, 5, 0);
			break;
		case 16:
			framebuffer->pixsize = 2;
			FBMASK(0, 31<<11, 63<<5, 31);
			FBLOSS(8, 3, 2, 3);
			FBSHIFT(0, 11, 5, 0);
			break;
		case 24:
			framebuffer->pixsize = 3;
			FBMASK(0, 255<<16, 255<<8, 255);
			FBLOSS(8, 0, 0, 0);
			FBSHIFT(0, 16, 8, 0);
			break;
		case 32:
			framebuffer->pixsize = 4;
			FBMASK(255<<24, 255<<16, 255<<8, 255);
			FBLOSS(0, 0, 0, 0);
			FBSHIFT(24, 16, 8, 0);
			break;
		default:
			framebuffer->pixsize = 0;
			framebuffer->format = FBFORMAT_BITPLANES;
			break;
	}
}

/* Clear all the framebuffer */

void RGB_ClearScreen(framebuffer_t *framebuffer)
{
	unsigned char *screen;
	unsigned long line_length;
	int y;

	screen = (unsigned char *) (framebuffer->buffer);
	if (framebuffer->bpp >= 8) {
		line_length = framebuffer->width * framebuffer->pixsize;
	} else {
		line_length = (framebuffer->width * framebuffer->bpp)>>3;
	}
	for (y=0; y<framebuffer->height; y++) {
		memset(screen, 0, line_length);
		screen += framebuffer->pitch;
	}
}

/* Clear a rectangle in the framebuffer */

void RGB_ClearRect(framebuffer_t *framebuffer, fbrect_t *rect)
{
	unsigned char *screen;
	unsigned long line_length;
	int y;

	screen = (unsigned char *) (framebuffer->buffer);
	screen += rect->y * framebuffer->pitch;
	if (framebuffer->bpp >= 8) {
		line_length = rect->w * framebuffer->pixsize;
		screen += rect->x * framebuffer->pixsize;
	} else {
		/* bitplanes, we align on a 16-pixel boundary */
		line_length = ((rect->w & 0xfffffff0UL) * framebuffer->bpp)>>3;
		screen += ((rect->x & 0xfffffff0UL) * framebuffer->bpp)>>3;
	}
	for (y=0; y<rect->h; y++) {
		memset(screen, 0, line_length);
		screen += framebuffer->pitch;
	}
}

/* Draw a shaded 1-component rectangle in the framebuffer */

void RGB_DrawBar(framebuffer_t *framebuffer, fbrect_t *rect, fbcomponent_t component)
{
	unsigned char *screen, *screen_line;
	unsigned long r,g,b,color, shade;
	int x,y, xx1, xx2;
	unsigned long line_length;
	int x1,x2,y1,y2;
	int numshades;

	if ((framebuffer->bpp>1) && (framebuffer->bpp<=8)) {
		numshades = ((1<<framebuffer->bpp)-1)/3;
	} else {
		numshades = 1;
	}

	/* Direct rendering, we must do clipping */
	x1 = rect->x;
	if (x1<0) x1=0;
	if (x1>=framebuffer->width) x1=framebuffer->width-1;

	y1 = rect->y;
	if (y1<0) y1=0;
	if (y1>=framebuffer->height) y1=framebuffer->height-1;

	x2 = rect->x + rect->w - 1;
	if (x2<0) x2=0;
	if (x2>=framebuffer->width) x2=framebuffer->width-1;

	y2 = rect->y + rect->h - 1;
	if (y2<0) y2=0;
	if (y2>=framebuffer->height) y2=framebuffer->height-1;

	if ((x1==x2) || (y1==y2))
		return;

	/* Now, where to draw ? */
	screen = (unsigned char *) (framebuffer->buffer);
	screen += y1 * framebuffer->pitch;
	screen_line = screen;
	if (framebuffer->bpp >= 8) {
		screen += x1 * framebuffer->pixsize;
		line_length = (x2-x1) * framebuffer->pixsize;
	} else {
		/* bitplanes, we align on a 16-pixel boundary */
		xx1 = x1 & 0xfffffff0UL;
		xx2 = x2 & 0xfffffff0UL;
		if (x2 & 15) { xx2 += 16; }
		screen += (xx1 * framebuffer->bpp)>>3;
		line_length = ((xx2-xx1) * framebuffer->bpp)>>3;
	}

	/* Create a line */
	r = g = b = color = 0;
	switch(framebuffer->bpp) {
		case 1:
			{
				/* Monochrome, create a black line */
				memset(screen, 0xff, line_length);
			}
			break;		
		case 2:
			{
				/* 4 colours=black + 1 shade/component */
				for (x=x1; x<=x2; x++) {
					RGB_Plot2((unsigned short *)screen_line, x, component+1);
				}
			}
			break;		
		case 4:
			{
				/* 16 colours=black + 5 shades/component */
				for (x=x1; x<=x2; x++) {
					color = 1+ (((x-x1)*numshades)/(x2-x1));
					switch(component) {
						case COMPONENT_RED:		/* 1 to 5 */
							break;
						case COMPONENT_GREEN:	/* 6 to 10 */
							color += numshades;
							break;
						case COMPONENT_BLUE:	/* 11 to 15 */
							color += numshades<<1;
							break;
					}
					RGB_Plot4((unsigned short *)screen_line, x, color);
				}
			}
			break;		
		case 8:
			{
				/* 256 colours=black + 85 shades/component */
				if (framebuffer->format == FBFORMAT_PACKED) {
					unsigned char *dst_column;

					dst_column = screen;
					for (x=x1; x<=x2; x++) {
						color = 1+ (((x-x1)*numshades)/(x2-x1));
						switch(component) {
							case COMPONENT_RED:		/* 1 to 85 */
								break;
							case COMPONENT_GREEN:	/* 86 to 170 */
								color += numshades;
								break;
							case COMPONENT_BLUE:	/* 171 to 255 */
								color += numshades<<1;
								break;
						}
						*dst_column++ = color;
					}
				} else {
					for (x=x1; x<=x2; x++) {
						color = 1+ (((x-x1)*numshades)/(x2-x1));
						switch(component) {
							case COMPONENT_RED:		/* 1 to 85 */
								break;
							case COMPONENT_GREEN:	/* 86 to 170 */
								color += numshades;
								break;
							case COMPONENT_BLUE:	/* 171 to 255 */
								color += numshades<<1;
								break;
						}
						RGB_Plot8((unsigned short *)screen_line, x, color);
					}
				}
			}
			break;		
		case 15:
		case 16:
			{
				unsigned short *dst_column;

				dst_column = (unsigned short *)screen;
				for(x=x1;x<=x2;x++) {
					shade = ((x-x1)*256)/(x2-x1);
					switch(component) {
						case COMPONENT_RED: r = shade; break;
						case COMPONENT_GREEN: g = shade; break;
						case COMPONENT_BLUE: b = shade; break;
					}
					color = (r>>framebuffer->rloss)<<framebuffer->rshift;
					color |= (g>>framebuffer->gloss)<<framebuffer->gshift;
					color |= (b>>framebuffer->bloss)<<framebuffer->bshift;
					*dst_column++ = color;
				}
			}
			break;
		case 24:
			{
				unsigned char *dst_column;

				dst_column = screen;
				for(x=x1; x<=x2; x++) {
					shade = ((x-x1)*256)/(x2-x1);
					switch(component) {
						case COMPONENT_RED: r = shade; break;
						case COMPONENT_GREEN: g = shade; break;
						case COMPONENT_BLUE: b = shade; break;
					}
					color = (r>>framebuffer->rloss)<<framebuffer->rshift;
					color |= (g>>framebuffer->gloss)<<framebuffer->gshift;
					color |= (b>>framebuffer->bloss)<<framebuffer->bshift;
					*dst_column++ = color>>16;
					*dst_column++ = color>>8;
					*dst_column++ = color;
				}
			}
			break;
		case 32:
			{
				unsigned long *dst_column;

				dst_column = (unsigned long *)screen;
				for(x=x1; x<=x2; x++) {
					shade = ((x-x1)*256)/(x2-x1);
					switch(component) {
						case COMPONENT_RED: r = shade; break;
						case COMPONENT_GREEN: g = shade; break;
						case COMPONENT_BLUE: b = shade; break;
					}
					color = (r>>framebuffer->rloss)<<framebuffer->rshift;
					color |= (g>>framebuffer->gloss)<<framebuffer->gshift;
					color |= (b>>framebuffer->bloss)<<framebuffer->bshift;
					*dst_column++ = color;
				}
			}
			break;
	}

	/* Then recopy it, on the rest of the rectangle */
	{
		unsigned char *src_line, *dst_line;

		src_line = screen;
		dst_line = screen + framebuffer->pitch;

		for(y=y1+1; y<=y2; y++) {
			memcpy(dst_line, src_line, line_length);
			dst_line += framebuffer->pitch;
		}
	}
}

/* Functions to plot a pixel */

static void RGB_Plot2(unsigned short *buffer, int x, int color)
{
	unsigned short tmp;
	int i;

	buffer += (((x & 0xfffffff0UL)<<1)>>3)>>1;
	x = (15-x) & 15;

	for (i=0; i<2; i++) {
		tmp = *buffer;
		if (color & (1<<i)) {
			tmp |= (1<<x);
		} else {
			tmp &= ~(1<<x);
		}
		*buffer++ = tmp;
	}
}

static void RGB_Plot4(unsigned short *buffer, int x, int color)
{
	unsigned short tmp;
	int i;

	buffer += (((x & 0xfffffff0UL)<<2)>>3)>>1;
	x = (15-x) & 15;

	for (i=0; i<4; i++) {
		tmp = *buffer;
		if (color & (1<<i)) {
			tmp |= (1<<x);
		} else {
			tmp &= ~(1<<x);
		}
		*buffer++ = tmp;
	}
}

static void RGB_Plot8(unsigned short *buffer, int x, int color)
{
	unsigned short tmp;
	int i;

	buffer += (((x & 0xfffffff0UL)<<3)>>3)>>1;
	x = (15-x) & 15;

	for (i=0; i<8; i++) {
		tmp = *buffer;
		if (color & (1<<i)) {
			tmp |= (1<<x);
		} else {
			tmp &= ~(1<<x);
		}
		*buffer++ = tmp;
	}
}
