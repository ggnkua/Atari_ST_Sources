
overlay "vsupport"

#include "..\\include\\lists.h"
#include "..\\include\\poly.h"
#include "..\\include\\color.h"
#include "..\\include\\script.h"
#include "..\\include\\io.h"
#include "..\\include\\control.h"
#include "..\\include\\cursor.h"
#include "..\\include\\addr.h"
#include "..\\include\\clip.h"

WORD s_mode = S_POLY;

WORD **a_list;
WORD a_count = 0;

#ifdef NEVER
WORD **a_points;
WORD a_point_count = 0;
WORD **a_segments;
WORD a_segment_count = 0;
WORD **a_polys;
WORD a_poly_count = 0;

free_a_lists()
{
free_tube_list( a_points, a_point_count);
a_point_count = 0;
free_tube_list( a_segments, a_segment_count);
a_segment_count = 0;
free_tube_list( a_polys, a_poly_count);
a_poly_count = 0;
a_count = 0;
}

point_mode()
{
s_mode = S_POINT;
a_count = 0;
}

points_mode()
{
mfree( a_points, a_point_count * sizeof(WORD *) );
a_point_count = 0;
s_mode = S_POINTS;
a_list = a_points;
a_count = a_point_count;
}

segment_mode()
{
s_mode = S_SEGMENT;
a_count = 0;
}

poly_mode()
{
s_mode = S_POLY;
a_count = 0;
}

polys_mode()
{
mfree( a_polys, a_poly_count * sizeof(WORD *) );
a_poly_count = 0;
s_mode = S_POLYS;
a_list = a_polys;
a_count = a_poly_count;
}

frame_mode()
{
s_mode = S_FRAME;
a_count = 0;
}
#endif NEVER


WORD **
sgeneric(m, sel, vis, adr_mode)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
WORD adr_mode;
{
extern struct cursor segment_cursor;
extern WORD **one_address(), **add_to_tube_list();
extern WORD **rm_from_tube_list();
register Poly_list *nplist;
register WORD **new_addresses;
WORD one_ad_count;
register WORD i;
register WORD first_time;

nplist = cur_sequence->next_poly_list;
if (nplist->count <= 0)
	return;

free_tube_list(a_list, a_count);
a_count = 0;
first_time = 1;

for (;;)
	{
	if (first_time)
	new_addresses = 
		one_address(m,sel, vis, cur_sequence,
		adr_mode, nplist,-1 , &one_ad_count,1);
	else
	new_addresses = 
		one_address(m,sel, vis, cur_sequence,
		adr_mode, nplist,-1 , &one_ad_count,0);
	if (new_addresses == NULL)
	{
	vis = quick_input(USE_CURSOR);
	if (!(vis->result & CANCEL))
		{
		reuse_input();
		a_count = 0;
		}
	if (a_count == 0)
		if (first_time)
		return(NULL);
		else
		return((WORD **)-1);
	else
		return(a_list);
	}
	for (i=0; i<one_ad_count; i++)
	{
	if (first_time)
		{
		first_time = 0;
		maybe_clear_menu(m);
		}
	if (in_tube_list(a_list, a_count, new_addresses[i]) )
		{
		a_list = rm_from_tube_list(
			a_list, &a_count, new_addresses[i] );
		d_one_add( new_addresses[i], 0);
		display_active();
		}
	else
		{
		a_list = add_to_tube_list(a_list, &a_count, new_addresses[i] );
		d_one_add( new_addresses[i], cycle_color);
		}
	}
	mfree( new_addresses, one_ad_count * sizeof(WORD *) );
	}
}


WORD **
s_points(m, sel, vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
extern struct cursor point_cursor;

new_cursor(&point_cursor);
show_help("select points");
return(sgeneric(m, sel, vis,  s_mode));
}

WORD **
s_polys(m, sel, vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
extern struct cursor ppoly_cursor;

new_cursor(&ppoly_cursor);
show_help("select polygons");
return(sgeneric(m, sel, vis,  s_mode));
}


display_active()
{
d_active(1);
}

undisplay_active()
{
d_active(0);
}


d_active(color)
int color;
{
register WORD i;
register WORD **adds;

i = a_count;
adds = a_list;
while (--i >= 0)
	d_one_add( *(adds++), color);
}

d_one_add( add, hilight)
register WORD *add;
register WORD hilight;
{
struct point *p, *end_p;
register struct poly *pl;
struct poly **pls;
struct point persp_p;
register int color;
register WORD i;

pls = cur_sequence->next_poly_list->list;

switch ( *(add+1) )
	{
	case POINTS:
	pl = pls[ add[2] ];
	if (hilight)
		color = cycle_color;
	else
		color = 0;
	p = pl->pt_list + add[3];
	zscale_point(p, &persp_p);
	show_cursor(&point_cursor,persp_p.x,persp_p.y,color);
	break;
	case SEGMENT:
	case POLYS:
	pl = pls[ add[2] ];
	if (hilight)
		draw_pledge(pl, cycle_color, cur_sequence);
	else
		{
		Cube c;

		find_bounding_box(pl, &c, cur_sequence);
		redraw_through_box(&c);
		}
	break;
	case FRAME:
	pls += add[2];
	i = add[3];
	while (--i >= 0)
		{
		pl = *pls++;
		if (hilight)
		color = cycle_color;
		else
		color = pl->color;
		draw_pledge(pl,color, cur_sequence);
		}
	break;
	default:
	break;
	}
}
