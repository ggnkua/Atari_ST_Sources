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

#ifndef _RGB_H
#define _RGB_H

/*--- Defines ---*/

typedef enum {
	COMPONENT_RED,
	COMPONENT_GREEN,
	COMPONENT_BLUE
} fbcomponent_t ;

typedef enum {
	FBFORMAT_BITPLANES,
	FBFORMAT_VDI,
	FBFORMAT_PACKED
} fbformat_t ;

#define FBMASK(amask_value, rmask_value, gmask_value, bmask_value) \
	framebuffer->amask = amask_value; \
	framebuffer->rmask = rmask_value; \
	framebuffer->gmask = gmask_value; \
	framebuffer->bmask = bmask_value;

#define FBLOSS(aloss_value, rloss_value, gloss_value, bloss_value) \
	framebuffer->aloss = aloss_value; \
	framebuffer->rloss = rloss_value; \
	framebuffer->gloss = gloss_value; \
	framebuffer->bloss = bloss_value;

#define FBSHIFT(ashift_value, rshift_value, gshift_value, bshift_value) \
	framebuffer->ashift = ashift_value; \
	framebuffer->rshift = rshift_value; \
	framebuffer->gshift = gshift_value; \
	framebuffer->bshift = bshift_value;

/*--- Types ---*/

typedef struct {
	unsigned short width;	/* Width in pixels */
	unsigned short height;	/* Height in pixels */
	unsigned short bpp;		/* Bits per pixel */
	unsigned short pixsize;	/* Bytes per pixel (only if bpp>=8, else 0) */
	void *buffer;			/* Address of video RAM */
	unsigned long pitch;	/* Length of a screen line, in bytes */
	fbformat_t format;		/* Screen structure for pixels */

	/* Info needed to write in a TrueColour buffer */
	unsigned long amask, rmask, gmask, bmask;		/* Bits used for a component */
	unsigned short aloss, rloss, gloss, bloss;		/* 8-bits to n-bits component */
	unsigned short ashift, rshift, gshift, bshift;	/* component to final pixel */
} framebuffer_t;

typedef struct {
	short x;
	short y;
	short w;
	short h;
} fbrect_t;

/*--- Functions ---*/

void RGB_InitFramebuffer(framebuffer_t *framebuffer, unsigned short width, unsigned short height, unsigned short bpp);
void RGB_ClearScreen(framebuffer_t *framebuffer);
void RGB_ClearRect(framebuffer_t *framebuffer, fbrect_t *rect);
void RGB_DrawBar(framebuffer_t *framebuffer, fbrect_t *rect, fbcomponent_t component);

#endif /* _RGB_H */
