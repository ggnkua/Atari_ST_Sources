
overlay "vtools"

#include "..\\include\\lists.h"
#include "..\\include\\cursor.h"
#include "..\\include\\color.h"
#include "..\\include\\script.h"
#include "..\\include\\poly.h"
#include "..\\include\\io.h"
#include "..\\include\\acts.h"
#include "..\\include\\addr.h"
#include "..\\include\\control.h"
#include "..\\include\\menu.h"
#include "..\\include\\format.h"

extern WORD **expand_act_list();
extern WORD **get_address_list();
extern WORD *make_opcode();
extern struct cursor sample_cursor;

extern WORD ground_z;

vsample(control)
struct control *control;
{
struct menu *m = control->m;
struct selection *sel = control->sel;
struct virtual_input *vis = control->vis;
struct poly *sample_poly;
Point *pt;
WORD i;
WORD samples;
WORD *function;
WORD **addrs;
WORD **address_list;
WORD address_count;
WORD *op, **ops;
WORD **op_list;
struct tween *cur_tween;
WORD **acts;


#ifdef DEBUG
ldprintf("vsample()\n");
#endif DEBUG

if (no_polys_check() )
	return;

new_cursor(&sample_cursor);

show_help("freehand path");
address_list = get_address_list( m, sel, vis, cur_sequence, 
	s_mode, cur_sequence->next_poly_list, &address_count);
if (!address_list)
	{
	c_dest = m_dest;
	return;
	}
/*find objects which we want to put a path on, return if none*/

new_cursor(&sample_cursor);
show_help("make path a dot at a time");

save_undo();
maybe_clear_menu(m);

display_active();

for (;;)
	{
	vis = quick_input(USE_CURSOR);
	if (((vis->result & 0x3) == JUST_UP) || (vis->result & JUST_DN) )
	{
	break;
	}
	if (vis->result & CANCEL) 
	{
	undisplay_active();
	return;
	}
	if (in_menu(m, vis) )
	{
	undisplay_active();
	reuse_input();
	return;   /*c_dest = m_dest in in_menu() */
	}
	}

sample_poly = (Poly *)clone_structure(&grc_poly, sizeof(Poly) );
sample_poly->type = JUST_LINE; 
sample_poly->pt_count = 2;
cken_points(sample_poly);
/*make up a dummy polygon to hold the path*/

pt = sample_poly->pt_list;
pt->x = vis->curx*VRES;
pt->y = vis->cury*VRES;
pt->z = ground_z;
pt->level = 0;
pt++;
pt->x = vis->curx*VRES;
pt->y = vis->cury*VRES;
pt->z = ground_z;
pt->level = 0;
for(;;)
	{
	rub_poly_pts(sample_poly, cur_sequence);
	vis = await_input(USE_CURSOR);
	unrub_ppoints(sample_poly, cur_sequence);
	if (vis->result & (CANCEL|MENUPICKED) )
	{
	--sample_poly->pt_count;
	break;
	}
	if (pjstdn(vis) )
	{
	sample_poly->pt_count++;
	cken_points(sample_poly);
	pt = (sample_poly->pt_list + sample_poly->pt_count - 1);
	}
	pt->x = vis->curx*VRES;
	pt->y = vis->cury*VRES;
	pt->z = ground_z;
	pt->level = 0;
	}
/*now have collected a polygon that has the path for it's point list*/

samples = sample_poly->pt_count;
if (samples > 1)
	{
	if (samples > 2)
	{
	function = (WORD *)alloc( (3*samples + 3) * sizeof(WORD) );
	function[0] = 3*samples + 3;
	function[1] = SAMPLE_OP;
	function[2] = samples;
	path_from_poly(function+3, sample_poly);
	}
	else
	{
	function = (WORD *)alloc(function_length[MOVE_OP] * sizeof(WORD) );
	function[0] = function_length[MOVE_OP];
	function[1] = MOVE_OP;
	pt = sample_poly->pt_list;
	function[2] = (pt+1)->x - pt->x;
	function[3] = (pt+1)->y - pt->y;
	function[4] = (pt+1)->z - pt->z;
	}
	i = address_count;
	ops = op_list = (WORD **) alloc( address_count * sizeof(WORD *) );
	addrs = address_list;
	while (--i >= 0)
	{
	op = make_opcode( *(addrs++), function );
	*(ops++) = op;
	}
	cur_tween = *(cur_sequence->next_tween);
	i = address_count;
	ops = op_list;
	while (--i >= 0)
	{
	acts = expand_act_list(cur_tween);
	if (acts)
		*(acts) = *(ops++);
	}
	do_upstream( op_list, address_count, cur_sequence);
	mfree( op_list, address_count * sizeof(WORD *) );
	free_tube(function);
	}
if (vis->result & MENUPICKED)
	reuse_input();
free_poly(sample_poly);
retween_poly_list(cur_sequence);
make_cur_frame(m);
}

path_from_poly(path, poly)
WORD *path;
Poly *poly;
{
register WORD count = poly->pt_count;
register Point *pts = poly->pt_list;
register WORD firstx, firsty, firstz;

firstx = pts->x;
firsty = pts->y;
firstz = pts->z;
while (--count >= 0)
	{
	*(path++) = pts->x - firstx;
	*(path++) = pts->y - firsty;
	*(path++) = pts->z - firstz;
	pts++;
	}
}

