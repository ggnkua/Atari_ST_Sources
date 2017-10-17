/* 
 * 16 bit palette handling routines, by Johan Klockars.
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

#include "config.h"
#include "fvdi.h"
#include "relocate.h"

#define red_bits   5	/* 5 for all normal 16 bit hardware */
#define green_bits 6	/* 6 for Falcon TC and NOVA 16 bit, 5 for NOVA 15 bit */
			/* (I think 15 bit Falcon TC disregards the green LSB) */
#define blue_bits  5	/* 5 for all normal 16 bit hardware */

void CDECL c_get_colours_16(Virtual *vwk, long colour, long *foreground, long *background)
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
	
#if 0 // #ifdef DEBUG
	display_string("c_get_colours_16: local_palette ");
	hex_long(local_palette);
	display_string(" global_palette ");
	hex_long(global_palette);
	display_string(" fore_pal ");
	hex_long(fore_pal);
	display_string(" back_pal ");
	hex_long(back_pal);
	display_string("\r\n");
#endif

	*foreground = (unsigned long)(*(unsigned short *)&fore_pal[(short)colour].real);
	*background = (unsigned long)(*(unsigned short *)&back_pal[colour >> 16].real);
}

long CDECL c_get_colour_16(Virtual *vwk, long colour)
{
	long foreground, background;
	c_get_colours_16(vwk, colour, &foreground, &background);
	return(background << 16) | foreground;	
}

void CDECL c_set_colours_16(Virtual *vwk, long start, long entries, unsigned short *requested, Colour palette[])
{
	unsigned short colour;
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
			palette[start + i].hw.red = component;	/* Not at all correct */
			colour = component >> (16 - red_bits);	/* (component + (1 << (14 - red_bits))) */
			tc_word = colour << green_bits;
			component = *requested++ >> 8;
			palette[start + i].vdi.green = (component * 1000L) / 255;
			palette[start + i].hw.green = component;	/* Not at all correct */
			colour = component >> (16 - green_bits);	/* (component + (1 << (14 - green_bits))) */
			tc_word |= colour;
			tc_word <<= blue_bits;
			component = *requested++ >> 8;
			palette[start + i].vdi.blue = (component * 1000L) / 255;
			palette[start + i].hw.blue = component;	/* Not at all correct */
			colour = component >> (16 - blue_bits);		/* (component + (1 << (14 - blue_bits))) */
			tc_word |= colour;
			*(unsigned short *)&palette[start + i].real = (unsigned short)tc_word;
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
			component = *requested++;
			palette[start + i].vdi.green = component;
			palette[start + i].hw.green = component;	/* Not at all correct */
			colour = (component * ((1L << green_bits) - 1) + 500L) / 1000;
			tc_word |= colour;			/* Was (colour + colour) */
			tc_word <<= blue_bits;
			component = *requested++;
			palette[start + i].vdi.blue = component;
			palette[start + i].hw.blue = component;	/* Not at all correct */
			colour = (component * ((1L << blue_bits) - 1) + 500L) / 1000;
			tc_word |= colour;
			*(unsigned short *)&palette[start + i].real = (unsigned short)tc_word;
		}
	}
}

