
overlay "vtools"

#include "..\\include\\lists.h"
#include "..\\include\\acts.h"
#include "..\\include\\script.h"
#include "..\\include\\poly.h"
#include "..\\include\\control.h"
#include "..\\include\\addr.h"
#include "..\\include\\io.h"
#include "..\\include\\color.h"
#include "..\\include\\cursor.h"
#include "..\\include\\animath.h"
#include "..\\include\\format.h"




vhook(control)
struct control *control;
{
struct menu *m = control->m;
struct selection *sel = control->sel;
struct virtual_input *vis = control->vis;
struct tween *cur_tween = *(cur_sequence->next_tween);
extern struct poly *which_poly();
struct poly *this_poly;
WORD poly_ix;

#ifdef DEBUG
lprintf("vhook()\n");
#endif DEBUG

if ( !any_polys(cur_sequence->next_poly_list))
	{
	c_dest = m_dest;
	return;
	}

new_cursor(&hook_cursor);
show_help("hook - move/insert/delete points");

for(;;)
	{
	vis = await_input(USE_CURSOR);
	if (in_menu(m,vis) )
	{
	reuse_input();
	return;
	}
#ifdef NEVER
	if (vis->result & CANCEL)
	toggle_menu(m,vis);
#endif NEVER
	if (pjstdn(vis))
	break;
	}
maybe_clear_menu(m);
this_poly = which_poly(vis, cur_sequence, &poly_ix);
if (this_poly && !(this_poly->type & IS_RASTER) )
	{
	save_undo();
	undraw_poly(this_poly, cur_sequence);
	plop_front_to_back();
#ifdef ATARI
	hide_mbar();
#endif ATARI
	work_poly(m, sel, vis, this_poly,poly_ix);
	}
retween_poly_list(cur_sequence);
make_cur_frame(m);
return;
}

a_way_more_b( a, b)
WORD a, b;
{
#ifdef DEBUG
lprintf("a_way_more_b(%d %d)\n", a, b);
#endif DEBUG
if ((long)a > (long)b * b)
	{
	return(1);
	}
else
	{
	return(0);
	}
}



work_poly(m, sel, vis, poly,poly_ix)
struct menu *m;
struct selection *sel;
VIRTUAL_INPUT	*vis;
struct poly *poly;
WORD poly_ix;
{
extern struct poly *clone_poly();
extern WORD **one_address(), function_length[];
extern struct poly_list *clone_plist();
extern WORD *make_opcode(), *build_dead_list();

struct point *edge_list;
struct point *hot_point;
struct point *next_point, *last_point;
WORD next_ix, last_ix;
WORD next_distance, last_distance;
WORD closest_edge, closest_vertex;
long edge_distance, vertex_distance;
struct poly *edge_poly;
WORD do_merge, vertex_to_merge;
struct poly_list *poly_list, *local_poly_list;
WORD *move_func, *insert_op, *kill_op;
WORD address_count, **address_list, **addrs;
WORD op_count, **ops, **op_list, *op;
WORD firstx, firsty, lastx, lasty, thisx, thisy;
struct tween *cur_tween;
WORD i;
WORD **acts;
WORD start_ix, segment_length;
extern WORD move_mode;
/*this function has more variables than just about anything I've seen*/

cur_tween = *(cur_sequence->next_tween);
poly_list = (cur_sequence->next_poly_list);
local_poly_list = clone_plist(poly_list);

move_func = (WORD *) clone_zero(function_length[MOVE_OP] * sizeof(WORD) );
*move_func = function_length[MOVE_OP];
*(move_func+1) = MOVE_OP;
move_mode = 'x';
/*allocate and initialize move op*/

for (;;)
	{
	poly = *(local_poly_list->list + poly_ix);
	rub_poly_pts(poly, cur_sequence);
	for(;;)
	{
	vis = await_input(USE_CURSOR);

	if ( (vis->result & CANCEL) )
		{
		free_poly_list(local_poly_list);
		mfree(move_func, *move_func * sizeof(WORD) );
		return;
		}
	if ( vis->result & MENUPICKED )
		{
		free_poly_list(local_poly_list);
		mfree(move_func, *move_func * sizeof(WORD) );
		reuse_input();
		return;
		}
	if (pjstdn(vis) )
		break;
	}
	unrub_ppoints(poly, cur_sequence);
	find_closest(vis,poly->pt_list,poly->pt_count,
		&closest_vertex,&vertex_distance);

	edge_poly = clone_poly( poly );
	edge_list = edge_poly->pt_list;
	do_edge_list(edge_list,poly->pt_list,edge_poly->pt_count);
	if (edge_poly->type == JUST_LINE)
	{
	find_closest(vis, edge_list+1, edge_poly->pt_count - 1,
		&closest_edge, &edge_distance);
	closest_edge++;
	}
	else
	find_closest(vis,edge_list,
		edge_poly->pt_count,&closest_edge,&edge_distance);
	free_poly(edge_poly);


	if (vertex_distance <= edge_distance)
	/*this is to pick up a vertex*/
	{
	reuse_input();  /*one_address needs the JUST_DN*/
	address_list = one_address( m, sel, vis, cur_sequence, 
		POINTS, local_poly_list,
		poly_ix, &address_count, 0);

	i = op_count = address_count;
	ops = op_list = (WORD **) alloc( address_count * sizeof(WORD *) );
	addrs = address_list;
	while (--i >= 0)
		{
		op = make_opcode( *(addrs++), move_func );
		*(ops++) = op;
		}

	find_dead_segment(cur_tween, poly_ix, poly, closest_vertex,
		&start_ix, &segment_length);

	closest_vertex = start_ix + segment_length - 1;
	poly_wrap(&closest_vertex, poly->pt_count);

	next_ix = closest_vertex + 1;
	poly_wrap(&next_ix, poly->pt_count);
	last_ix = start_ix - 1;
	poly_wrap(&last_ix, poly->pt_count);

	hot_point = poly->pt_list + closest_vertex;
	firstx  = lastx = hot_point->x;
	firsty = lasty = hot_point->y;

	while ( vis->result & JUST_DN)
		{
		rub_poly_pts(poly, cur_sequence);
		vis = await_input(USE_CURSOR);
		/*let user know where he is .. hope all the bullshit below
		  doesnt take so long that it out-times input loop..*/

		unrub_ppoints(poly, cur_sequence);

		next_point = poly->pt_list + next_ix;
		last_point = poly->pt_list + last_ix;

		next_distance = calc_distance(hot_point->x, hot_point->y,
		next_point->x, next_point->y);
		last_distance = calc_distance(hot_point->x, hot_point->y,
		last_point->x, last_point->y);

		/*if one side way bigger than other merge into small side*/
		do_merge = 0;
		thisx = vis->curx *VRES;
		thisy = vis->cury *VRES;
		if (a_way_more_b(next_distance, last_distance) )
		{
		vertex_to_merge = last_ix;
		if (poly->type != JUST_LINE || 
			vertex_to_merge != poly->pt_count - 1)
			{
			thisx = last_point->x;
			thisy = last_point->y;
			do_merge = 1;
			}
		}
		else if (a_way_more_b(last_distance, next_distance) )
		{
		vertex_to_merge = closest_vertex;
		if (poly->type != JUST_LINE || 
			vertex_to_merge != poly->pt_count - 1)
			{
			thisx = next_point->x;
			thisy = next_point->y;
			do_merge = 1;
			}
		}
		last_coors(op_list, op_count, firstx, firsty, lastx, lasty,
			thisx, thisy);
		copy_poly_list(poly_list, local_poly_list);
		act_on_poly_list(op_list, op_count, local_poly_list,
		 SCALE_ONE, cur_sequence);
		 /*move points*/

		if (do_merge)
		break;  /*out of while DN */
		}
	i = op_count;
	ops = op_list;
	while (--i >= 0)
		{
		opto_add_act(cur_tween, *ops++ );
		}
	do_upstream( op_list, op_count, cur_sequence);

	/*first of all move point to be right on top of point
	   its merging with*/

	if (do_merge)
		{
		kill_op = (WORD *) 
			alloc(lof_type(KILL_POINT) * sizeof(WORD));
		*kill_op = lof_type(KILL_POINT);
		*(kill_op+1) = KILL_POINT;
		*(kill_op+2) = poly_ix;
		*(kill_op+3) = vertex_to_merge;
		opto_add_act(cur_tween, kill_op);
		do_upstream(&kill_op, 1, cur_sequence);
		/*and then put the kill point op into the script*/
		}

	mfree(op_list, op_count * sizeof(WORD *) );
	free_tube_list(address_list, address_count);
	copy_poly_list(local_poly_list, poly_list);
	}
	else
	/*this is to add a vertex*/
	{
	insert_op = (WORD *) 
		alloc(lof_type(INSERT_POINT) * sizeof(WORD));
	*insert_op = lof_type(INSERT_POINT);
	*(insert_op+1) = INSERT_POINT;
	*(insert_op+2) = poly_ix;
	*(insert_op+3) = closest_edge;
	opto_add_act(cur_tween, insert_op);
	copy_poly_list(poly_list, local_poly_list);
	act_on_poly_list(&insert_op, 1, local_poly_list, SCALE_ONE,
		cur_sequence);
	copy_poly_list(local_poly_list, poly_list);
	do_upstream(&insert_op, 1, cur_sequence);
	/*and then put the insert point op into the script*/

	reuse_input();  /*one_address needs the JUST_DN*/
	address_list = one_address(m, sel, vis, cur_sequence,
		POINTS, local_poly_list, poly_ix, &address_count, 0);
	i = op_count = address_count;
	ops = op_list = (WORD **)
		alloc(address_count * sizeof(WORD *) );
	addrs = address_list;
	while(--i >= 0)
		{
		op = make_opcode(*(addrs++), move_func);
		*(ops++) = op;
		}
	/*build new address and op structures for moving points*/

	hot_point = poly->pt_list + closest_edge;
	firstx = lastx = hot_point->x;
	firsty = lasty = hot_point->y;
	/*get point's initial position*/

	while (vis->result & JUST_DN)
		{
		rub_poly_pts(poly, cur_sequence);
		vis = await_input(USE_CURSOR);
		unrub_ppoints(poly, cur_sequence);
		copy_poly_list( poly_list, local_poly_list);
		last_coors( op_list, op_count, firstx, firsty, lastx, lasty,
		vis->curx * VRES, vis->cury * VRES);
		lastx = vis->curx * VRES;
		lasty = vis->cury * VRES;
		act_on_poly_list(op_list, op_count, local_poly_list, 
		SCALE_ONE, cur_sequence);
		}
	i = op_count;
	ops = op_list;
	while (--i >= 0)
		{
		opto_add_act( cur_tween, *ops++ );
		}
	do_upstream( op_list, op_count, cur_sequence);
	mfree( op_list, op_count * sizeof(WORD *) );
	free_tube_list(address_list, address_count);
	copy_poly_list( local_poly_list, poly_list);
	}
	}
}


