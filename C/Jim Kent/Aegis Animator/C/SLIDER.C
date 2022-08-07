
overlay "menu"

#include "..\\include\\lists.h"
#include "..\\include\\poly.h"
#include "..\\include\\color.h"
#include "..\\include\\io.h"
#include "..\\include\\cursor.h"
#include "..\\include\\menu.h"
#include "..\\include\\format.h"
#include "..\\include\\animath.h"
#include "..\\include\\perspect.h"
#include "..\\include\\script.h"

extern int  draw_pl_with();
extern struct cursor diamond_cursor, cross_cursor;


extern struct slider gauge_sl;
struct point gauge_points[] =
	{
	25 * VRES,	0 * VRES,	NEW_GROUND_Z, 0,
	75 * VRES,	0 * VRES,	NEW_GROUND_Z,0,
	100 * VRES,	25 * VRES,	NEW_GROUND_Z,0,
	75 * VRES,	75 * VRES,	NEW_GROUND_Z,0,
	60 * VRES,	60 * VRES,	NEW_GROUND_Z,0,
	40 * VRES,	60 * VRES,	NEW_GROUND_Z,0,
	25 * VRES,	75 * VRES,	NEW_GROUND_Z,0,
	0 * VRES,	25 * VRES,	NEW_GROUND_Z,0,
	};

struct poly gauge_poly =
	{
	OUT_LINE,1,1,
	{0,0,0,0},
	8,8,
	gauge_points,
	NULL,
	};

struct point needle_points[] =
	{
	50 * VRES,	10 * VRES,	NEW_GROUND_Z,0,
	55 * VRES,	19 * VRES,	NEW_GROUND_Z,0,
	50 * VRES,	75 * VRES,	NEW_GROUND_Z,0,
	45 * VRES,	19 * VRES,	NEW_GROUND_Z,0,
	};

struct poly needle_poly =
	{
	FILLED,1,1,
	{0,0,0,0},
	4,4,
	needle_points,
	NULL,
	};


see_gauge(m,s,color)
struct menu *m;
struct selection *s;
int color;
{
register struct slider *sl = (struct slider *)s->display_data;
WORD op, oq;
WORD theta;
WORD osys_scale;
register struct poly *poly;
WORD scale;
extern long mem_free;
extern WORD sys_scale;
extern Poly *clone_poly();

osys_scale = sys_scale;
sys_scale = 0;

theta = (mem_free) * 217 / sl->scale;
theta -= 100;
theta = -theta;

scale = uscale_by(SCALE_ONE, sel_width(s), 100);

poly = clone_poly(&needle_poly);
rotate_poly(poly, poly, 50, 75, theta);

scale_point_list(poly->pt_list, poly->pt_count,
	scale,
	(s->x_min_pos + m->xoff), (s->y_min_pos + m->yoff));
poly->fill_color = poly->color = hi_color;
draw_pl_with(poly, cur_sequence);
free_poly(poly);

poly = clone_poly(&gauge_poly);
scale_point_list(poly->pt_list, poly->pt_count,
	scale, (s->x_min_pos + m->xoff), (s->y_min_pos + m->yoff));
poly->color = fore_color;
draw_pl_with(poly, cur_sequence);
free_poly(poly);
sys_scale = osys_scale;
}


see_sld(m, s,color, show_tick)
struct menu *m;
struct selection *s;
int color;
WORD show_tick;
{
register struct n_slider *sl = (struct n_slider *)s->display_data;
char *title;
WORD length;
WORD slider_width;
WORD offset;
WORD ystart;
WORD now_where;



slider_width = sel_width(s);

title = sl->string;

offset = center_text(s->x_min_pos, s->x_max_pos, title);

ystart = s->y_min_pos + m->yoff + CHAR_HEIGHT + 1;

colblock( back_color,
	m->xoff + s->x_min_pos, m->yoff + s->y_min_pos,
	m->xoff + s->x_max_pos, m->yoff + s->y_max_pos
	);

gtext(sl->string,
	m->xoff + offset, m->yoff +  s->y_min_pos,
	color);

hline(ystart, s->x_min_pos + m->xoff, s->x_max_pos + m->xoff, fore_color);

now_where = uscale_by(slider_width, (int)sl->value, (int)sl->scale);

xor_cursor(&diamond_cursor,
	m->xoff + s->x_min_pos + now_where,
	ystart,
	cycle_color);
if (show_tick)
	{
	now_where = uscale_by(slider_width, (int)sl->usual, (int)sl->scale);
	vline( m->xoff + s->x_min_pos + now_where,
		ystart - 2, ystart + 2, hi_color);
	}
}

see_nslider(m, s, color)
struct menu *m;
struct selection *s;
int color;
{
see_sld(m, s, color, 1);
}

see_slider(m, s, color)
struct menu *m;
struct selection *s;
int color;
{
see_sld(m, s, color, 0);
}

show_sl_loc(m, sel, sl)
struct menu *m;
struct selection *sel;
struct slider *sl;
{
WORD now_where;

now_where = uscale_by(sel_width(sel), (int)sl->value, (int)sl->scale);

xor_cursor(&diamond_cursor,
	m->xoff + sel->x_min_pos + now_where,
	sel->y_min_pos + m->yoff + CHAR_HEIGHT + 2,
	cycle_color);
}

do_slider(m, sel, vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
d_slider(m, sel, vis, NULL);
}


d_slider(m, sel, vis, funct)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
int (*funct)();
{
register struct slider *scale = (struct slider *)sel->function_data;
WORD x;
WORD slider_width;
long new_value;

show_sl_loc(m, sel, scale);
while (vis->result & JUST_DN)
	{
	show_sl_loc(m, sel, scale);
	vis = await_input(USE_CURSOR);
	show_sl_loc(m, sel, scale);
	x = sel_x_off(m, sel, vis);
	new_value = uscale_by( (int)scale->scale, x, sel_width(sel) );
	long_clip( (long)0, &new_value, scale->scale);
	scale->value = new_value;
	if (funct)
	(*funct)(scale);
	}
show_sl_loc(m, sel, scale);
/*xor in the new position*/
}


