
#include <aline.h>
#include <osbind.h>
#include <stdio.h>
#include "pogo.h"
#include "neo.h"


#define XMAX 320
#define YMAX 200
#define REPLACE 1
#define XOR	2

/* handy macro to find out how much memory a raster line takes up */
#define Mask_line(width) ((((width)+15)>>3)&0xfffe)
#define Mask_block(width, height) (Mask_line(width)*(height))
#define Raster_line(width) (((((width)+15)>>3)&0xfffe)<<2)
#define Raster_block(width, height) (Raster_line(width)*(height))

extern struct aline *aline;
extern WORD handle;
extern WORD in_graphics;
extern WORD *cscreen, *physcreen;

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

get_cmap(cmap)
register WORD *cmap;
{
register int i;

for (i=0; i<16; i++)
	*cmap++ = Setcolor(i, -1);
}

#define STCOLOR(r,g,b) (((r & 0xe0)<<3) + ((g & 0xe0)>>1) + ((b & 0xe0)>>5))

WORD screen_cmap[] = 
	{
	STCOLOR(0, 0, 0),
	STCOLOR(128, 0, 1*64),
	STCOLOR(128, 0, 2*64),
	STCOLOR(128, 0, 3*64),
	STCOLOR(128, 0, 4*64-1),
	STCOLOR(128, 1*64, 255),
	STCOLOR(128, 2*64, 255),
	STCOLOR(128, 3*64, 255),
	STCOLOR(128, 4*64-1, 255),
	STCOLOR(0, 128, 1*64),
	STCOLOR(0, 128, 2*64),
	STCOLOR(0, 128, 3*64),
	STCOLOR(0, 128, 4*64-1),
	STCOLOR(128, 128, 1*64),
	STCOLOR(128, 128, 2*64),
	STCOLOR(128, 128, 3*64),
	};
WORD *sys_cmap = screen_cmap;

put_cmap(c)
WORD *c;
{
copy_words(c,sys_cmap, 16);
Setpallete(sys_cmap);	/* restore start-up colors */
}

set_color(color, r, g, b)
int color, r, g, b;
{
int c;

color &= 15;		/* mask to existing color */
c = STCOLOR(r,g,b);
sys_cmap[color] = c;
Setcolor(color, c);
}

flashred()
{
set_color(0,255,0,0);
wait_a_jiffy(10);
set_color(0,0,0,0);
}


#ifdef EISENSTIEN
line(color, x1, y1, x2, y2)
WORD color, x1, y1, x2, y2;
{
register struct aline *a = aline;

set_acolor(color);
a->lnmask = 0xffff;
a->wmode = REPLACE;  
a->x1 = x1;
a->y1 = y1;
a->x2 = x2;
a->y2 = y2;
aaline();
}

pline(p)
register union pt_int *p;
{
register struct aline *a = aline;

if (!in_graphics)
	to_graphics();
set_acolor(p[-5].i);
a->lnmask = 0xffff;
a->wmode = REPLACE;  
a->x1 = p[-4].i;
a->y1 = p[-3].i;
a->x2 = p[-2].i;
a->y2 = p[-1].i;
aaline();
}

pline(p)
register union pt_int *p;
{
if (!in_graphics)
	to_graphics();
line(p[-5].i&15, p[-4].i, p[-3].i, p[-2].i, p[-1].i);
}
#endif EISENSTIEN


/* just to fool compiler into treating a pointer as a long */
long 
pt_to_long(pt)
long pt;
{
return(pt);
}

long
compress_screen(s, d)
register char *s;
char *d;
{
int i, j;
char ravel_buf[Mask_line(XMAX)];
register char *dpt;
extern char *pack();

#define Mask_line(width) ((((width)+15)>>3)&0xfffe)

i = YMAX;
dpt = d;
while (--i >= 0)
	{
	j = 4;
	while (--j >= 0)
		{
		ravel_line(s, ravel_buf, Mask_line(XMAX) );
		dpt = pack(ravel_buf, dpt, Mask_line(XMAX) );
		if (pt_to_long(dpt) - pt_to_long(d) > 32000L)
			return(0);
		s += sizeof(WORD);
		}
	s += Raster_line(XMAX)-4*sizeof(WORD);
	}
return( pt_to_long(dpt) - pt_to_long(d) );
}

clear_screen()
{
zero_screen(cscreen);
}

WORD *sw_buf;
WORD *swscreens[2];
int swap_ix;
int got_swap;

gtext(s, x, y, color)
char *s;
WORD x, y;
WORD color;
{
vst_color(handle, gemctable[color]);
vswr_mode(handle, 1);
v_gtext(handle, x, y+7, s);
}

pgtext(p)
union pt_int *p;
{
gtext(p[-1].p, p[-3].i, p[-2].i, p[-4].i);
}

pgnumber(p)
union pt_int *p;
{
char buf[36];
static char format[4] = "%xd";

format[1] = p[-2].i + '0';
sprintf(buf, format, p[-1].i);
gtext(buf, p[-4].i, p[-3].i, p[-5].i);
}

#define SMAX 128

/* screen 0 is never used so isn't confused with false return.  Screen 1
   is the physical ST screen */

WORD *screens[SMAX+2];
WORD *cmaps[SMAX+2];
int lscreen = 1;

pscreen()
{
return(1);
}

palloc_screen()
{
WORD *ns, *nc;
int i;

for (i=2; i<SMAX+2; i++)
	{
	if (screens[i] == NULL)
		{
		if ((ns = beg_mem(32000)) == NULL)
			return(0);
		if ((nc = beg_mem(32)) == NULL)
			{
			freemem(ns);
			return(0);
			}
		screens[i] = ns;
		cmaps[i] = nc;
		return(i);
		}
	}
return(0);
}

check_screen(s,who,start)
int s;
char *who;
int start;
{
char buf[60];

if (s >= start  && s < SMAX+2)
	{
	if (screens[s] != NULL)
		{
		return(1);
		}
	}
sprintf(buf, "Screen %d doesn't exist in %s", s, who);
runtime_err(buf);
return(0);
}

pfree_screen(p)
union pt_int *p;
{
int s;

s = p[-1].i;
if (check_screen(s, "FreeScreen",2))
	{
	gentle_free(cmaps[s]);
	gentle_free(screens[s]);
	screens[s] = NULL;
	}
}


puse_screen(p)
union pt_int *p;
{
int s;

s = p[-1].i;
if (check_screen(s, "UseScreen",1))
	{
	lscreen = s;
	cscreen = screens[s];
	sys_cmap = cmaps[s];
	}
}

pcopy_screen(p)
union pt_int *p;
{
int s, d;

if (!in_graphics)
	to_graphics();
s = p[-2].i;
d = p[-1].i;
if (check_screen(s, "CopyScreen",1) && check_screen(d,"CopyScreen",1))
	{
	copy_screen(screens[s], screens[d]);
	copy_words(cmaps[s], cmaps[d], 16);
	if (d == 1)
		Setpallete(cmaps[d]);
	}
}


pblit(p)
union pt_int *p;
{
int s, d;

p -= 8;	/* so can access parameters without thinking backwards */
s = p[2].i;
d = p[5].i;
if (check_screen(s, "Blit", 1) && check_screen(d,"Blit",1))
	{
	copy_blit(p[0].i, p[1].i, p[3].i, p[4].i, screens[s], 160,
		p[6].i, p[7].i, screens[d], 160);
	}
}

ptblit(p)
union pt_int *p;
{
pblit(p);
}

#define ALLIGN	256

pre_swap()
{
to_graphics();
if (!got_swap)
	{
	if ((sw_buf = Malloc(32000L + 256)) == NULL)
		{
		runtime_err("Not enough memory for double-buffering, damn.");
		return(0);
		}
	screens[1] = swscreens[0] = cscreen;
	swscreens[1] = (WORD *)(((long)sw_buf+ALLIGN) & 0xffffff00);
	}
Setscreen(swscreens[1], swscreens[0], -1);
swap_ix = 0;
cscreen = swscreens[1];
got_swap = 1;
return(1);
}

swap()
{
if (!got_swap)
	{
	if (!pre_swap())
		return;
	}
screens[1] = cscreen = swscreens[swap_ix];
swap_ix = 1-swap_ix;
Setscreen(cscreen, swscreens[swap_ix], -1);
Vsync();
}

de_swap()
{
if (got_swap)
	{
	Setscreen(physcreen, physcreen, -1);
	Mfree(sw_buf);
	cscreen = physcreen;
	got_swap = 0;
	}
}

vsync()
{
Vsync();
}

