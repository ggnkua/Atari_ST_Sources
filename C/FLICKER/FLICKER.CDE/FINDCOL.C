
#include <osbind.h>
#include "flicker.h"

WORD sys_cmap[16] = { 
	0x000,	0x004,	0x007,	0x407,
	0x707,	0x704,	0x700,	0x740,
	0x770,	0x470,	0x070,	0x074,
	0x077,	0x047,	0x444,	0x777,
	};
char oppositec[16];		/* worst fit lookup - for visible cursor */

put_cmap(cmap)
WORD *cmap;
{
Setpallete(cmap);
copy_words(cmap, sys_cmap, 16);
make_oppositec();
}

WORD white, black, red;

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
red = closest_col(0x700, 0);
}

make_oppositec()
{
register char *cc;
register WORD i;

cc = oppositec;
for (i=0; i<16; i++)
	*cc++ = opposite_color(i);
}

