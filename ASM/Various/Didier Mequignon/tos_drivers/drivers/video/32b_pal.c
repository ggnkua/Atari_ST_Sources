/* 
 * 32 bit palette handling routines, by Johan Klockars.
 *
 * $Id: 16b_pal.c,v 1.4 2005/08/04 10:17:10 johan Exp $
 *
 * This file is an example of how to write an
 * fVDI device driver routine in C.
 *
 * You are encouraged to use this file as a starting point
 * for other accelerated features, or even for supporting
 * other graphics modes. This file is therefore put in the
 * public domain. It's not copyrighted or under any sort
 * of license.
 */

#define red_bits   8	/* 5 for all normal 16 bit hardware */
#define green_bits 8	/* 6 for Falcon TC and NOVA 16 bit, 5 for NOVA 15 bit */
			/* (I think 15 bit Falcon TC disregards the green LSB) */
#define blue_bits  8	/* 5 for all normal 16 bit hardware */

#include "config.h"
#include "fvdi.h"
#include "relocate.h"

long _background;

void CDECL c_get_colours_32(Virtual *vwk, long colour, long *foreground, long *background)
{
	Colour *local_palette, *global_palette;
	Colour *fore_pal, *back_pal;

	local_palette = vwk->palette;
	if(local_palette && !((long)local_palette & 1))	/* Complete local palette? */
		fore_pal = back_pal = local_palette;
	else
	{						/* Global or only negative local */
		local_palette = (Colour *)((long)local_palette & 0xfffffffeL);
		global_palette = vwk->real_address->screen.palette.colours;
		if(local_palette && ((short)colour < 0))
			fore_pal = local_palette;
		else
			fore_pal = global_palette;
		if(local_palette && ((colour >> 16) < 0))
			back_pal = local_palette;
		else
			back_pal = global_palette;
	}

	*foreground = *(unsigned long *)&fore_pal[(short)colour].real;
	*background = *(unsigned long *)&back_pal[colour >> 16].real;
}

long CDECL c_get_colour_32(Virtual *vwk, long colour)
{
	long foreground;
	c_get_colours_32(vwk, colour, &foreground, &_background);
	return foreground;
}

void CDECL c_set_colours_32(Virtual *vwk, long start, long entries, unsigned short *requested, Colour palette[])
{
	unsigned long colour;
	unsigned short component;
	unsigned long tc_word;
	int i;
	
	if((long)requested & 1)
	{			/* New entries? */
		requested = (unsigned short *)((long)requested & 0xfffffffeL);
		for(i = 0; i < entries; i++)
		{
			requested++;				/* First word is reserved */
			component = *requested++ >> 8;
			palette[start + i].vdi.red = (component * 1000L) / 255;
			palette[start + i].hw.red = component;
			tc_word = (unsigned long)component << green_bits;
			component = *requested++ >> 8;
			palette[start + i].vdi.green = (component * 1000L) / 255;
			palette[start + i].hw.green = component;
			tc_word |= (unsigned long)component << red_bits;
			component = *requested++ >> 8;
			palette[start + i].vdi.blue = (component * 1000L) / 255;
			palette[start + i].hw.blue = component;
			tc_word |= (unsigned long)component;
			/* Would likely be better to have a different mode for this */
			*(unsigned long *)&palette[start + i].real = (unsigned long)tc_word;
		}
	}
	else
	{
		for(i = 0; i < entries; i++)
		{
			component = *requested++;
			palette[start + i].vdi.red = component;
			palette[start + i].hw.red = component;	/* Not at all correct */
			colour = (component * ((1L << red_bits) - 1) + 500L) / 1000;
			tc_word = colour << green_bits;
			palette[start + i].hw.red = (colour * 1000 + (1L << (red_bits - 1))) / ((1L << red_bits) - 1);
			component = *requested++;
			palette[start + i].vdi.green = component;
			palette[start + i].hw.green = component;	/* Not at all correct */
			colour = (component * ((1L << green_bits) - 1) + 500L) / 1000;
			tc_word |= colour;
			tc_word <<= blue_bits;
			palette[start + i].hw.green = (colour * 1000 + (1L << (green_bits - 1))) / ((1L << green_bits) - 1);
			component = *requested++;
			palette[start + i].vdi.blue = component;
			palette[start + i].hw.blue = component;	/* Not at all correct */
			colour = (component * ((1L << blue_bits) - 1) + 500L) / 1000;
			palette[start + i].hw.blue = (colour * 1000 + (1L << (blue_bits - 1))) / ((1L << blue_bits) - 1);
			tc_word |= colour;
			*(unsigned long *)&palette[start + i].real = (unsigned long)tc_word;
		}
	}
}

