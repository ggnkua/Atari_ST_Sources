
overlay "vtools"

#include "..\\include\\lists.h"
#include "..\\include\\color.h"
#include "..\\include\\script.h"
#include "..\\include\\poly.h"
#include "..\\include\\acts.h"
#include "..\\include\\addr.h"
#include "..\\include\\control.h"
#include "..\\include\\io.h"
#include "..\\include\\cursor.h"
#include "..\\include\\animath.h"

extern WORD **expand_act_list();
extern struct point *which_point();
extern struct poly *which_poly();
extern WORD s_mode;


vkill(control)
struct control *control;
{
struct menu *m = control->m;
struct selection *sel = control->sel;
struct virtual_input *vis = control->vis;
extern struct cursor kill_cursor;

if (no_polys_check() )
	return;

new_cursor(&kill_cursor);
vkill_poly(m,sel,vis);
#ifdef AMIGA
maybe_disable_move();
#endif AMIGA
}

vkill_poly(m,sel,vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
struct tween *cur_tween = *(cur_sequence->next_tween);
struct poly *poly;
WORD poly_ix;
WORD **acts, *act;
int i;

#ifdef DEBUG
lprintf("vkill_poly()\n");
#endif DEBUG

show_help("remove object's present and future");
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
if (s_mode != S_FRAME)
	{
	poly = which_poly(vis, cur_sequence, &poly_ix);
	if (poly)
	{
	undraw_poly(poly, cur_sequence);
	draw_pledge(poly, cycle_color, cur_sequence);
	show_help("left button to kill, right to live");
	for(;;)
		{
		vis = await_input(USE_CURSOR);
		if (vis->result & CANCEL)
		{
		draw_cur_frame(m);
		return;
		}
		if (vis->result & MENUPICKED)
		{
		draw_cur_frame(m);
		reuse_input();
		return;
		}
		if (pjstdn(vis))
		break;
		}
	save_undo();
	undraw_poly(poly, cur_sequence);
	acts = expand_act_list(cur_tween);
	*acts = act = (WORD *) alloc(3 * sizeof(WORD));
	*act = 3;
	*(act+1) = KILL_POLY;
	*(act+2) = poly_ix;
	aki_poly((cur_sequence->next_poly_list), act, SCALE_ONE);
	kpl_in_s_sequence(cur_sequence, poly_ix);
	retween_poly_list(cur_sequence);
	draw_cur_frame(m);
	}
	}
else
	{
	if (confirm(m ,sel, vis,"kill all objects?") )
	{
	save_undo();
	i = cur_sequence->next_poly_list->count;
	while (--i >= 0)
		{
		acts = expand_act_list(cur_tween);
		*acts = act = (WORD *) alloc(3 * sizeof(WORD));
		*act = 3;
		*(act+1) = KILL_POLY;
		*(act+2) = i;
		aki_poly((cur_sequence->next_poly_list), act, SCALE_ONE);
		kpl_in_s_sequence(cur_sequence, i);
		}
	}
	retween_poly_list(cur_sequence);
	draw_cur_frame(m);
	}
}

