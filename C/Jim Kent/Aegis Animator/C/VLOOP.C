

overlay "vtools"

#include "..\\include\\lists.h"
#include "..\\include\\script.h"
#include "..\\include\\poly.h"
#include "..\\include\\acts.h"
#include "..\\include\\addr.h"
#include "..\\include\\control.h"
#include "..\\include\\io.h"
#include "..\\include\\cursor.h"
#include "..\\include\\color.h"
#include "..\\include\\animath.h"
#include "..\\include\\format.h"


extern struct poly *which_poly();
extern WORD **one_address(), function_length[];
extern struct poly_list *clone_plist();
extern WORD *make_opcode();

vloop(control)
struct control *control;
{
struct menu *m = control->m;
struct selection *sel = control->sel;
struct virtual_input *vis = control->vis;

struct poly_list *poly_list, *local_poly_list;
WORD *function;
WORD address_count, **address_list, **addrs;
WORD op_count, **ops, **op_list, *op;
WORD firstx, firsty, lastx, lasty;
struct tween *cur_tween;
struct poly *poly;
WORD poly_ix;
WORD i;
WORD **acts;
extern WORD move_mode;

#ifdef DEBUG
lprintf("vloop()\n");
#endif DEBUG

if ( no_polys_check() )
	return;
new_cursor(&loop_cursor);
show_help("loop - move points in poly");

function = (WORD *) clone_zero(function_length[MOVE_OP] * sizeof(WORD) );
if (!function)
	{
	c_dest = m_dest;
	return;
	}
*function = function_length[MOVE_OP];
*(function+1) = MOVE_OP;
move_mode = 'x';

for(;;)
	{
	for(;;)
	{
	vis = await_input(USE_CURSOR);
	if (in_menu(m,vis) )
		{
		free_tube(function);
		reuse_input();
		return;
		}
#ifdef NEVER
	if (vis->result & CANCEL)
		toggle_menu(m,vis);
#endif NEVER
	if (pjstdn(vis))
		{
		break;
		}
	}

	maybe_clear_menu(m);
	poly_list = (cur_sequence->next_poly_list);
	poly = which_poly(vis, cur_sequence, &poly_ix);
	if ( poly && !(poly->type & IS_RASTER) )
	{
	save_undo();

	undraw_poly(poly, cur_sequence);
	plop_front_to_back();
	rub_poly_pts(poly, cur_sequence);

#ifdef ATARI
	hide_mbar();
#endif ATARI
	for(;;)
		{
		address_list = one_address( m, sel, vis, cur_sequence, 
			POINTS, poly_list,
			poly_ix, &address_count, 0);

		if (!address_list)
		{
		break;
		}

		local_poly_list = clone_plist(poly_list);
		poly = *(local_poly_list->list + poly_ix);
		i = op_count = address_count;
		ops = op_list = (WORD **) alloc( address_count * sizeof(WORD *) );
		addrs = address_list;
		while (--i >= 0)
		{
		op = make_opcode( *(addrs++), function );
		*(ops++) = op;
		}

		firstx = lastx = vis->curx*VRES;
		firsty = lasty = vis->cury*VRES;
		while (vis->result & JUST_DN)
		{
		vis = await_input(USE_CURSOR);
		unrub_ppoints(poly, cur_sequence);
		last_coors( op_list, op_count, firstx, firsty, lastx, lasty,
			vis->curx*VRES, vis->cury*VRES);
		lastx = vis->curx*VRES;
		lasty = vis->cury*VRES;
		copy_poly_list( poly_list, local_poly_list);
		act_on_poly_list(op_list, op_count, local_poly_list, 
			SCALE_ONE, cur_sequence);
		rub_poly_pts(poly, cur_sequence);
		}

		cur_tween = *(cur_sequence->next_tween);
		i = op_count;
		ops = op_list;
		while (--i >= 0)
		{
		opto_add_act(cur_tween, *ops++);
		}

		do_upstream( op_list, op_count, cur_sequence);
		mfree( op_list, op_count * sizeof(WORD *) );
		free_tube_list(address_list, address_count);
		copy_poly_list( local_poly_list, poly_list);
		free_poly_list(local_poly_list);
		}
	}
	retween_poly_list(cur_sequence);
	make_cur_frame(m);
	}
}

