/* Audio-Video Sequencer           */
/* Copyright 1988 Antic Publishing */
/* by Jim Kent                     */


#define EDITOR

#include <aline.h>
#include <osbind.h>
#include "flicker.h"

#define REPLACE 1
#define XOR	2


extern struct aline *aline;
extern WORD handle;

char gemctable[16] = 
	{
	0, 2, 3, 6, 4, 7, 5, 8, 9, 0xa, 0xb, 0xe, 0xc, 0xf, 0xd, 1,
	};

wait_a_jiffy(jiff)
WORD jiff;
{
while (--jiff >= 0)
	Vsync();
}


get_cmap(cmap)
register WORD *cmap;
{
register int i;

for (i=0; i<16; i++)
	*cmap++ = Setcolor(i, -1);
}

draw_frame(color, x0, y0, x1, y1)
register int color, x0, y0, x1, y1;
{
hline(y0, x0, x1, color);
hline(y1, x0, x1, color);
vline(x0, y0, y1, color);
vline(x1, y0, y1, color);
}



hline(y, x1, x2, color)
WORD color, y, x1, x2;
{
colblock(color, x1, y, x2, y);
}

vline(x, y1, y2, color)
int color, x, y1, y2;
{
colblock(color, x, y1, x, y2);
}

colblock(color, x1, y1, x2, y2)
WORD color;
register WORD x1, y1, x2, y2;
{
register struct aline *a = aline;
WORD swap;

if (x1 > x2)
	{
	swap = x2;
	x2 = x1;
	x1 = swap;
	}
if (y1 > y2)
	{
	swap = y2;
	y2 = y1;
	y1 = swap;
	}
if (y2 < 0 || y1 >= YMAX)
	return;
if (x2 < 0 || x1 >= XMAX)
	return;
if (y1 < 0)
	y1 = 0;
if (x1 < 0)
	x1 = 0;
if (x2 >= XMAX)
	x2 = XMAX-1;
if (y2 >= YMAX)
	y2 = YMAX-1;
blast_block(x1,y1,x2,y2,color);
}


colrop(color, x, y, width, height)
int color, x, y, width, height;
{
register struct aline *a = aline;

colblock(color, x, y, x+width, y+height);
}

clear_screen()
{
zero_screen(cscreen);
}

color_hslice(ystart, height, color)
WORD ystart, height, color;
{
color_lines(cscreen+80*ystart, height, color);
}


ctext(s, x, y, color)
char *s;
WORD x, y;
WORD color;
{
vst_color(handle, gemctable[color]);
vswr_mode(handle, 2);
v_gtext(handle, x, y+7, s);
}


gtext(s, x, y, color)
char *s;
WORD x, y;
WORD color;
{
vst_color(handle, gemctable[color]);
vswr_mode(handle, 0);
v_gtext(handle, x, y+7, s);
}

#ifdef SLUFFED
new_cursor(c, color)
register struct cursor *c;
WORD color;
{
register WORD *data;

data = *( (WORD **)(((char *)aline)+8) );
data[4] = data[2] = gemctable[color];
data[0] = c->xhot;
data[1] = c->yhot;
zero_structure(data+5, 16*sizeof(WORD) );
copy_structure(c->image, data+21, 16*sizeof(WORD) );
atmouse();
}
#endif SLUFFED

