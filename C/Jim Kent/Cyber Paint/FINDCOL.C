
#include <osbind.h>
#include "flicker.h"

extern WORD *vbcmap;

WORD init_cmap[16] = { 
	0x000,	0x004,	0x007,	0x141,
	0x433,	0x530,	0x653,	0x754,
	0x700,	0x750,	0x670,	0x070,
	0x056,	0x137,	0x607,	0x777,
	};
WORD sys_cmap[16];
char oppositec[COLORS];		/* worst fit lookup - for visible cursor */
char clookup[512];
Unp_color unp_colors[COLORS];


qput_cmap(cmap)
register WORD *cmap;
{
extern char jimint_status;

copy_words(cmap, sys_cmap, COLORS);
copy_words(cmap+1, stripe2.colors, 3);
copy_words(cmap+1, stripe4.colors, 3);
vbcmap = sys_cmap;
if (!jimint_status)
	Setpallete(sys_cmap);
}

sput_cmap()
{
find_colors();
make_oppositec();
}

put_cmap(cmap)
WORD *cmap;
{
qput_cmap(cmap);
sput_cmap();
}

WORD white, black, red;
WORD swhite = 1, sblack = 2, sred = 3;

color_dif(c1, c2)
register WORD c1, c2;
{
register WORD temp, acc;

temp = (c1&7) - (c2&7);
acc = temp*temp;
temp = ((c1>>4)&7) - ((c2>>4)&7);
acc += temp*temp;
temp = (c1>>8) - (c2>>8);
acc += temp*temp;
return(acc);
}

closest_col(abs, start_ix)
WORD abs;	/* absolute color */
WORD start_ix;
{
register WORD min_dif;
register WORD temp;
WORD i;
register WORD *pt;
WORD closest;

pt = sys_cmap + start_ix;
min_dif = color_dif(abs, *pt++);
closest = start_ix;
for (i=start_ix+1; i<16; i++)
	{
	temp = color_dif(abs, *pt++);
	if (temp < min_dif)
		{
		closest = i;
		min_dif = temp;
		}
	}
return(closest);
}

opposite_color(col)
WORD col;
{
register WORD abs;
register WORD max_dif;	
register WORD temp;
WORD i;
register WORD *pt;
WORD farthest;

pt = sys_cmap;
abs = pt[col];
max_dif = color_dif(abs, *pt++);
farthest = 0;
for (i=1; i<16; i++)
	{
	temp = color_dif(abs, *pt++);
	if (temp > max_dif)
		{
		farthest = i;
		max_dif = temp;
		}
	}
return(farthest);
}


find_colors()
{
white = closest_col(0x777, 0);
black = closest_col(0x000, 0);
red = closest_col(0x702, 0);
#ifdef LATER
if (black == white)
	{
	sys_cmap[0] = 0;
	sys_cmap[1] = 0x700;
	sys_cmap[14] = 0x007;
	sys_cmap[15] = 0x777;
	put_cmap(sys_cmap);
	}
#endif LATER
}

make_oppositec()
{
register char *cc;
register WORD i;

cc = oppositec;
for (i=0; i<COLORS; i++)
	*cc++ = opposite_color(i);
}

unpack_colors()
{
register Unp_color *unp;
register WORD *packed;
register WORD i;
register WORD color;

unp = unp_colors;
packed = sys_cmap;
i = COLORS;
while (--i >= 0)
	{
	color = *packed++;
	unp->r = color>>8;
	unp->g = (color&0x0f0)>>4;
	unp->b = color&0x00f;
	unp++;
	}
}

make_clookup()
{
register WORD r, g, b;
register char *clk;
register WORD acc;
static WORD same_cmap[16];

if (!words_same(sys_cmap, same_cmap, COLORS) )	/* if same already relax */
	{
	unpack_colors();
	clk = clookup;
	for (r=0; r<8; r++)
		for (g=0; g<8; g++)
			for (b=0; b<8; b++)
				{
				*clk++ = closest_col( rgb_to_abs(r, g, b), 0);
				}
	copy_words(sys_cmap, same_cmap, COLORS);
	}
}

