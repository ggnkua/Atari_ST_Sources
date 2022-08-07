
overlay "vtools"

#include "..\\include\\lists.h"
#include "..\\include\\cursor.h"
#include "..\\include\\io.h"
#include "..\\include\\script.h"
#include "..\\include\\poly.h"
#include "..\\include\\acts.h"
#include "..\\include\\addr.h"
#include "..\\include\\control.h"
#include "..\\include\\menu.h"
#include "..\\include\\animath.h"
#include "..\\include\\format.h"

#define return_to_menu {c_dest = m_dest; return;}

extern struct poly_list *clone_plist();
extern WORD *make_opcode();
extern WORD **expand_act_list();
extern WORD **get_address_list();

extern WORD rotate_axis;
extern WORD rot_mode;

no_polys_check()
{

if (cur_sequence->next_poly_list->count > 0)
	return(0);
show_help("no objects to move");
wait(500);
c_dest = m_dest;
return(1);
}
	
vrotate(control)
struct control *control;
{
struct menu *m = control->m;
struct selection *sel = control->sel;
struct virtual_input *vis = control->vis;
extern struct cursor rotate_cursor;

#ifdef DEBUG
lprintf("vrotate( control%lx )\n",control);
#endif DEBUG

if (no_polys_check() )
	return;

rot_mode = rotate_axis;
vgeneric(m, sel, vis, (cur_sequence->next_poly_list), ROT_OP, s_mode,
	&rotate_cursor, "move cursor around center");
}


vsize(control)
struct control *control;
{
struct menu *m = control->m;
struct selection *sel = control->sel;
struct virtual_input *vis = control->vis;
extern struct cursor size_cursor;

#ifdef DEBUG
lprintf("vsize( control%lx )\n",control);
#endif DEBUG

if (no_polys_check() )
	return;
rot_mode = 's';
vgeneric(m, sel, vis, (cur_sequence->next_poly_list), SIZE_OP, s_mode,
	&size_cursor, "move cursor toward & away center");
}

vgeneric(m, sel, vis, poly_list, op_mode, addr_mode, op_cursor,
	after_addr_string)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
struct poly_list *poly_list;
WORD op_mode;
WORD addr_mode;
struct cursor *op_cursor;
char *after_addr_string;
{
WORD *function;
WORD *address;
WORD **addrs;
WORD **address_list;
WORD address_count;
WORD *op, **ops;
WORD **op_list;
WORD op_count;

WORD i;
struct poly_list *local_poly_list;
struct tween *cur_tween;
WORD **acts;

WORD firstx, firsty, firstz;
WORD lastx, lasty, lastz;
WORD curz;

#ifdef DEBUG
lprintf("vgeneric( m%lx sel%lx vis%lx plist%lx %d %d)\n", m, sel, vis,
	poly_list, op_mode, addr_mode);
#endif DEBUG

if ( (poly_list->count <= 0) || 
	((s_mode == S_POINT || s_mode == S_POINTS || s_mode == S_SEGMENT) &&
	!any_polys(poly_list) )  )
	{
	c_dest = m_dest;
	return;
	}

function = (WORD *) alloc(function_length[op_mode] * sizeof(WORD) );
*function = function_length[op_mode];
*(function+1) = op_mode;

if (!initialize_function(m,sel, vis, function) )
	{
	free_tube(function);
	return_to_menu;
	}

new_cursor(op_cursor);

address_list = get_address_list( m, sel, vis, cur_sequence, 
	addr_mode, poly_list, &address_count);
if (address_list == NULL)
	{
	free_tube(function);
	cleanup_after_v(op_mode);
	return_to_menu;
	}
new_cursor(op_cursor);

if (s_mode == S_POINTS || s_mode == S_POLYS )
	{
	vis = await_anydn(USE_CURSOR);
	if ( !pjstdn(vis) )
		{
		free_tube(function);
		undisplay_active();
		cleanup_after_v(op_mode);
		maybe_draw_menu(m);
		if ( !(vis->result & CANCEL) )
			{
			reuse_input();
			}
		return_to_menu;
		}
	}
else
	vis = getcurvis();

show_help(after_addr_string);

local_poly_list = clone_plist(poly_list);
save_undo();
i = op_count = address_count;
ops = op_list = (WORD **) alloc( address_count * sizeof(WORD *) );

addrs = address_list;
while (--i >= 0)
	*(ops++) = make_opcode( *(addrs++), function);

lastx = firstx = vis->curx;
lasty = firsty = vis->cury;


undraw_a_list(address_list, address_count, local_poly_list);
plop_front_to_back();
switch(op_mode)
	{
	case ROT_OP:
	case SIZE_OP:
	show_center_point();
	break;
	}

dshow_cursor(op_cursor, firstx, firsty);

while (vis->result & JUST_DN)
	{
	rub_a_list(address_list, address_count, local_poly_list);
	vis = await_input(USE_CURSOR);
	unrub_a_list(address_list, address_count, local_poly_list);
	copy_poly_list( poly_list, local_poly_list);
	last_coors( op_list, op_count, firstx, firsty, lastx, lasty,
		vis->curx, vis->cury);
	lastx = vis->curx;
	lasty = vis->cury;
	act_on_poly_list(op_list, op_count, local_poly_list, 
	SCALE_ONE, cur_sequence);
	}


cur_tween = *(cur_sequence->next_tween);
i = op_count;
ops = op_list;
while (--i >= 0)
	{
	acts = expand_act_list(cur_tween);
	if (acts)
		{
		*(acts) = *(ops);
		do_one_upstream( *ops++, cur_sequence);
		}
	}

copy_poly_list( local_poly_list, poly_list);
free_poly_list(local_poly_list);
mfree( op_list, op_count * sizeof(WORD *) );
mfree( function, *function * sizeof(WORD) );
retween_poly_list(cur_sequence);
make_cur_frame(m);
}


cleanup_after_v(opmode)
WORD opmode;
{
if (opmode == ROT_OP || opmode == SIZE_OP)
	unshow_center_point();
}

