/*
 *      8 bit colour index handling
 */

#include "config.h"
#include "fvdi.h"
#include "relocate.h"

#define red_bits   8	/* 5 for all normal 16 bit hardware */
#define green_bits 8	/* 6 for Falcon TC and NOVA 16 bit, 5 for NOVA 15 bit */
			/* (I think 15 bit Falcon TC disregards the green LSB) */
#define blue_bits  8	/* 5 for all normal 16 bit hardware */

void CDECL c_set_colour(Virtual *vwk, long paletteIndex, long red, long green, long blue);

static unsigned char tos_colours[] = {0, 255, 1, 2, 4, 6, 3, 5, 7, 8, 9, 10, 12, 14, 11, 13};

long CDECL c_get_colour_8(Virtual *vwk, long colour)
{
	short foreground, background;

	if ((colour & 0xff) < 16)
		foreground = tos_colours[colour & 0x0f];
	else if ((colour & 0xff) == 255)
		foreground = 15;
	else
		foreground = colour & 0xff;

	colour >>= 16;
	if ((colour & 0xff) < 16)
		background = tos_colours[colour & 0x0f];
	else if ((colour & 0xff) == 255)
		background = 15;
	else
		background = colour & 0xff;

	return ((long)background << 16) | (long)foreground;
}

void CDECL c_get_colours_8(Virtual *vwk, long colour, long *foreground, long *background)
{
	long colours = c_get_colour_8(vwk, colour);
	*foreground = colours & 0xffffL;
	*background = (colours >> 16) & 0xffffL;
}

void CDECL c_set_colours_8(Virtual *vwk, long start, long entries, unsigned short *requested, Colour palette[])
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
			component = *requested++;
			palette[start + i].vdi.red = component;
			palette[start + i].hw.red = component;	/* Not at all correct */
			colour = component >> (16 - red_bits);	/* (component + (1 << (14 - red_bits))) */
			tc_word = colour << green_bits;
			component = *requested++;
			palette[start + i].vdi.green = component;
			palette[start + i].hw.green = component;	/* Not at all correct */
			colour = component >> (16 - green_bits);	/* (component + (1 << (14 - green_bits))) */
			tc_word |= colour;
			tc_word <<= blue_bits;
			component = *requested++;
			palette[start + i].vdi.blue = component;
			palette[start + i].hw.blue = component;	/* Not at all correct */
			colour = component >> (16 - blue_bits);		/* (component + (1 << (14 - blue_bits))) */
			tc_word |= colour;
			c_set_colour(	vwk, start + i, palette[start + i].vdi.red, palette[start + i].vdi.green, palette[start + i].vdi.blue);
			*(unsigned char *)&palette[start + i].real = (unsigned char)tc_word;
		}
	}
	else
	{
		for(i = 0; i < entries; i++)
		{
			component = *requested++;
			palette[start + i].vdi.red = component;
#if 0
			palette[start + i].hw.red = component;	/* Not at all correct */
#endif
			colour = (component * ((1L << red_bits) - 1) + 500L) / 1000;
			palette[start + i].hw.red = (colour * 1000 + (1L << (red_bits - 1))) / ((1L << red_bits) - 1);
			tc_word = colour << green_bits;
			component = *requested++;
			palette[start + i].vdi.green = component;
#if 0
			palette[start + i].hw.green = component;	/* Not at all correct */
#endif
			colour = (component * ((1L << green_bits) - 1) + 500L) / 1000;
			palette[start + i].hw.green = (colour * 1000 + (1L << (green_bits - 1))) / ((1L << green_bits) - 1);
			tc_word |= colour;			/* Was (colour + colour) */
			tc_word <<= blue_bits;
			component = *requested++;
			palette[start + i].vdi.blue = component;
#if 0
			palette[start + i].hw.blue = component;	/* Not at all correct */
#endif
			colour = (component * ((1L << blue_bits) - 1) + 500L) / 1000;
			palette[start + i].hw.blue = (colour * 1000 + (1L << (blue_bits - 1))) / ((1L << blue_bits) - 1);
			tc_word |= colour;
			c_set_colour(	vwk, start + i,	palette[start + i].vdi.red,	palette[start + i].vdi.green, palette[start + i].vdi.blue);
			*(unsigned char *)&palette[start + i].real = (unsigned char)tc_word;
		}
	}
}

