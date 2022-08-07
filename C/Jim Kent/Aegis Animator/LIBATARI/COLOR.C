
overlay "player"

/*
**	File:	color.c
**
**   general color routines.  Includes some hardware dependent functions
**
**	(C) Copyright 1984 - The Island Graphics Corporation
*/

#include <osbind.h>
#include "..\\include\\lists.h"
#include "..\\include\\machine.h"
#include "..\\include\\color.h"
#include "..\\include\\poly.h"

WORD ccolor = 7;
struct color_def init_cmap[] = {
	{0,0,0}, {224,0,0}, {224,160,0}, {192,224,0}, 
	{0,224,0}, {0,160,192}, {128,96,224}, {192,0,224}, 
	{160,96,0}, {128,96,96}, {32,128,32}, {192,160,64}, 
	{96,96,128}, {128,128,160}, {160,160,192}, {224,224,224}, 
};
struct color_def *usr_cmap = init_cmap;

atari_to_ani_cmap(neo, ani, count)
register WORD *neo;
register struct color_def *ani;
register int count;
{
register int n;
while (--count >= 0)
	{
	n = *neo++;
	ani->red = (n&0x700)>>3;
	ani->green = (n&0x070)<<1;
	ani->blue = (n&0x007)<<5;
	ani++;
	}
}

ani_to_atari_cmap( cmap,c_pt,  count)
register struct color_def *cmap;
register unsigned WORD *c_pt;
register int count;
{
while (--count >= 0)
	{
	*c_pt++ = ((cmap->red & 0xe0)<<3)
	+ ((cmap->green & 0xe0)>>1)
	+ ((cmap->blue & 0xe0)>>5);
	cmap++;
	}

}

/************************************************************************
*
*				put_cmap(cmap)
*
*
* put_cmap takes a color map array and makes
* it active hardware color map 
*************************************************************************/

put_cmap(cmap, start, count)
register struct color_def *cmap;  /*pointer to an colormap array of color_defs*/
WORD start, count;
{
static unsigned WORD c_arr[MAXCOL];

ani_to_atari_cmap(cmap, c_arr, MAXCOL);
Setpallete(c_arr);
}



#ifdef SLUFFED
init_color()
{
put_cmap(usr_cmap, 0, MAXCOL);
/*install system color map into hardware */
#ifdef EDITOR
find_colors();
#endif EDITOR
}
#endif SLUFFED

put_color(color_ix, r, g, b)
WORD color_ix, r, g, b;
{
unsigned WORD colval;

colval =
	(((r) & 0xe0)<<3)
	+ (((g) & 0xe0)>>1)
	+ (((b) & 0xe0)>>5);
Setcolor( color_ix, colval);
}

color_cycle(color)
int color;
{
static unsigned char cycler = 0;
unsigned char r, g, b;
static WORD cycle_dir = 1;

if (cycler > 240)
	cycle_dir = -1;
else if (cycler < 30) 
	cycle_dir = 1;
	

cycler+= cycle_dir;
r = b = cycler;
g = 255 - cycler;
put_color(color, r, g, b);
}

