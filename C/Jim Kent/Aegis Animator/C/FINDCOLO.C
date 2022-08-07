overlay "find"

#include "..\\include\\lists.h"
#include "..\\include\\color.h"
#include "..\\include\\poly.h" 
#include "..\\include\\animath.h"

extern WORD glow_on;

#ifdef NEVER
build_translation_map(native,foreign,translator)
struct color_def *native;
register struct color_def *foreign;
unsigned char *translator;
{
register struct color_def *col;
register WORD r,g,b;
WORD i,j;
register unsigned char closest;
register WORD best_diff;
register WORD current_diff;

*(translator++) = 0;  /* zero is transparent */
foreign++;
for (i=1; i<MAXCOL; i++)
	{
	r = foreign->red;
	g = foreign->green;
	b = foreign->blue;
	closest = 1;
	best_diff = MAXCOL<<2;
	col = native+1;
	for (j=1; j<MAXCOL; j++) /*don't want colors to map to 0 which will be
				transparent*/
	{
	current_diff = abs(col->red - r);
	current_diff += abs(col->green - g);
	current_diff += abs(col->blue - b);
	if (current_diff < best_diff)
		{
		best_diff = current_diff;
		closest = j;
		}
	col++;
	}
	*(translator++) = closest;
	foreign++;
	}
}
#endif NEVER

color_diff(c1, c2)
register struct color_def *c1, *c2;
{
return( abs(c1->red - c2->red)  +
	abs(c1->green - c2->green) +
	abs(c1->blue - c2->blue) ); 
}


closest_color(cmap, ccount, match, except)
register struct color_def cmap[], *match;
int ccount;
int except;
{
int closest_diff = BIG_INT;
int closest_ix = 0;
int cur_diff, i;

for ( i=0; i<ccount; i++)
	if (i != except)
		if ( (cur_diff = color_diff(cmap++, match) ) < closest_diff )
			{
			closest_ix = i;
			closest_diff = cur_diff;
			}
return(closest_ix);
}

int back_color, fore_color, hi_color, grey_color;
/*find color with greatest difference between red and green components*/
find_colors()
{
static struct color_def menu_back =  { 12*16, 12*16, 12*16 };
static struct color_def menu_fore =  {  0*16,  0*16,  0*16 };
static struct color_def menu_hi =  {  15*16,  0*16,  0*16 };
static struct color_def menu_grey =  {  8*16,  8*16,  8*16 };
int except;

if (glow_on)
	except = cycle_color;
else
	except = -1;
back_color = closest_color(usr_cmap, MAXCOL,&menu_back, except);
fore_color = closest_color(usr_cmap,MAXCOL,  &menu_fore, except);
hi_color = closest_color(usr_cmap, MAXCOL, &menu_hi, -1);
grey_color = closest_color(usr_cmap, MAXCOL, &menu_grey, except);
if ( color_diff(usr_cmap+fore_color, usr_cmap+back_color) < 32)
	{
	back_color = 0;
	fore_color = cycle_color;   /* just to keep things visible */
	glow_on = 1;
	}
}

