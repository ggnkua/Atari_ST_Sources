
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

WORD bitmasks[16] = {
	0x8000, 0x4000, 0x2000, 0x1000,
	0x800, 0x400, 0x200, 0x100,
	0x80, 0x40, 0x20, 0x10,
	0x8, 0x4, 0x2, 0x1,
	};

wait_a_jiffy(jiff)
WORD jiff;
{
while (--jiff >= 0)
	Vsync();
}


long
get60hz()
{
return(vbcount);
}



get_cmap(cmap)
register WORD *cmap;
{
register int i;

for (i=0; i<16; i++)
	*cmap++ = Setcolor(i, -1);
}

brush_draw_frame(x0, y0, x1, y1)
register int x0, y0, x1, y1;
{
brush_hline(y0, x0, x1);
brush_hline(y1, x0, x1);
brush_vline(x0, y0, y1);
brush_vline(x1, y0, y1);
}

draw_frame(color, x0, y0, x1, y1)
register int color, x0, y0, x1, y1;
{
hline(y0, x0, x1, color);
hline(y1, x0, x1, color);
vline(x0, y0, y1, color);
vline(x1, y0, y1, color);
}


#ifdef SLUFFED
WORD solid[] = {0xffff, 0xffff, 0xffff, 0xffff,
		 0xffff, 0xffff, 0xffff, 0xffff};
#endif SLUFFED

set_acolor(color)
register WORD color;
{
register struct aline *a = aline;

if (color & (1<<3) )
	a->colbit3 = 1;
else
	a->colbit3 = 0;
if (color & (1<<2) )
	a->colbit2 = 1;
else
	a->colbit2 = 0;
if (color & (1<<1) )
	a->colbit1 = 1;
else
	a->colbit1 = 0;
if (color & 1)
	a->colbit0 = 1;
else
	a->colbit0 = 0;
}

#ifdef C_CODE
getdot(x, y)
int x, y;
{
aline->ptsin = &x;	/*hope x and y on stack in correct order... */
return(aget());
}
#endif C_CODE

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

set_solid_line()
{
register struct aline *a = aline;

set_acolor(ccolor);
a->lnmask = 0xffff;
a->wmode = REPLACE;  
}

set_xor_line()
{
register struct aline *a = aline;

set_acolor(oppositec[0]);
a->lnmask = 0xffff;
a->wmode = XOR;  /*xor*/
}

#ifdef SLUFFED
set_white_line()
{
register struct aline *a = aline;

set_acolor(white);
a->lnmask = 0xffff;
a->wmode = REPLACE;  
}
#endif SLUFFED

thin_line(x1, y1, x2, y2)
WORD x1, y1, x2, y2;
{
register struct aline *a = aline;

a->x1 = x1;
a->y1 = y1;
a->x2 = x2;
a->y2 = y2;
aaline();
}

line(x1, y1, x2, y2)
WORD x1, y1, x2, y2;
{
register struct aline *a = aline;

if (brush_ix == 0)
	{
	a->x1 = x1;
	a->y1 = y1;
	a->x2 = x2;
	a->y2 = y2;
	aaline();
	}
else
	brush_line(x1, y1, x2, y2);
}

extern WORD screen_bounds[];

floodfill(x, y, color)
int x, y, color;
{
if (getdot(x, y) == color)	/* avoid taking a long time to do nothing */
	return;	
vsf_color(handle, gemctable[color]);
vsf_interior(handle, 1 /* solid */ );
vs_clip(handle, 1, screen_bounds);
v_contourfill(handle, x, y, -1);
}

polyfill( points, count, color)
WORD *points;
WORD count, color;
{
vsf_color(handle, gemctable[color]);
vsf_interior(handle, 1 /* solid */ );
v_fillarea(handle, count, points);
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

/* set up things so draw on buffer (invisible) screen */
draw_on_buffer()
{
Setscreen(cscreen = bscreen, -1L, -1);
}

/* set up things so draw on visible screen */
draw_on_screen()
{
Setscreen(cscreen = pscreen, -1L, -1);
}

/* just copy buffer to screen */
buf_to_screen()
{
copy_screen(bscreen, pscreen);
}

undo_to_buf()
{
copy_screen(uscreen, bscreen);
}

/* expand part of buffer to visible screen ... zoom x 4 */
zbuf_to_screen()
{
zoom(bscreen, pscreen, zoomx, zoomy);
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



gtext(s, x, y, color)
char *s;
WORD x, y;
WORD color;
{
vst_color(handle, gemctable[color]);
vswr_mode(handle, 2);
v_gtext(handle, x, y+7, s);
}

#ifdef SLUFFED
sample_text()
{
int i, j;
char *sample = "Samp";

save_undo();
check_input();
hide_mouse();
for (i=0; i<16; i++)
	for (j=0; j<8; j++)
		{
		vst_effects(handle, i*8+j);
		v_gtext(handle, j*40, i*10+10, sample);
		}
show_mouse();
wait_click();
unundo();
vst_effects(handle, 0);
}
#endif SLUFFED
