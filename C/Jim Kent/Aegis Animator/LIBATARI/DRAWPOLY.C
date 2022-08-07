
overlay "player"

#include "..\\include\\lists.h"
#include "..\\include\\poly.h"
#include "..\\include\\color.h"
#include "..\\include\\cursor.h"

extern struct cursor pt_cursor;
extern struct poly *cube_clip();

#ifdef C_CODE
outline_poly(poly)
register struct poly *poly;
{
register struct llpoint *pts1, *pts2;
register WORD i;
register int color;

if ( (i = poly->pt_count ) > 0)
	{
	pts1 = poly->clipped_list;
	color = poly->color;
	if (poly->type == JUST_LINE)
	--i;
	while (--i >= 0)
	{
	pts2 = pts1->next;
	if (pts1->level)
		line(color, pts1->x, pts1->y, pts2->x, pts2->y);
	pts1 = pts2;
	}
	}
}
#endif C_CODE

hilite_poly(poly, with_points)
register struct poly *poly;
WORD with_points;
{
register struct llpoint *pts1;
register WORD i;

if (poly->type & IS_RASTER)
	return;
if ((poly = cube_clip(poly)) == NULL)
	return;
poly->color = cycle_color;
outline_poly(poly);
if (with_points)
	{
	pts1 = poly->clipped_list;
	i = poly->pt_count;
	while (--i >= 0)
	{
	show_cursor(&pt_cursor, pts1->x, pts1->y, cycle_color);
	pts1 = pts1->next;
	}
	}
}

