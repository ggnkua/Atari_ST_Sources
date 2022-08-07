
overlay "vtools"

#include "..\\include\\lists.h"
#include "..\\include\\script.h"
#include "..\\include\\poly.h"
#include "..\\include\\acts.h"
#include "..\\include\\cursor.h"
#include "..\\include\\io.h"
#include "..\\include\\control.h"
#include "..\\include\\color.h"

extern int draw_pl_with();
extern struct point *which_point();
extern struct poly *which_poly();

extern WORD bop_mode;

vbop(control)
struct control *control;
{
struct menu *m = control->m;
struct selection *sel = control->sel;
struct virtual_input *vis = control->vis;

struct tween *cur_tween = *(cur_sequence->next_tween);
extern struct cursor bop_cursor;
struct poly *this_poly;
WORD poly_ix;
WORD **acts, *act;

#ifdef DEBUG
lprintf("vbop()\n");
#endif DEBUG

if (cur_sequence->next_poly_list->count)
	{
	new_cursor(&bop_cursor);
	show_help("select polygon to change");
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
	save_undo();
	this_poly = which_poly(vis, cur_sequence,&poly_ix);

	undraw_poly(this_poly, cur_sequence);
	this_poly->type = bop_mode;
	draw_pl_with(this_poly, cur_sequence);

	act = (WORD *) alloc( 4 * sizeof(WORD) );
	add_act(cur_tween, act);
	*(act++) = 4;
	*(act++) = CHANGE_TYPE;
	*(act++) = poly_ix;
	*(act++) = bop_mode;

	retween_poly_list(cur_sequence);
	draw_cur_frame(m);
	}
else
	{
	c_dest = m_dest;
	return;
	}
}


vcolor(control)
struct control *control;
{
struct menu *m = control->m;
struct selection *sel = control->sel;
struct virtual_input *vis = control->vis;
struct tween *cur_tween = *(cur_sequence->next_tween);
struct poly *this_poly;
WORD poly_ix;
WORD **acts, *act;

#ifdef DEBUG
lprintf("vcolor()\n");
#endif DEBUG

if (cur_sequence->next_poly_list->count)
	{
	new_cursor(&color_cursor);
	show_help("change polygon to current color");
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
	save_undo();
	this_poly = which_poly(vis, cur_sequence, &poly_ix);
	if (this_poly->type != ANI_STRIP)
	{
	this_poly->color = ccolor;
	if (bop_mode == FILLED)
		this_poly->fill_color = ccolor;
	draw_pl_with(this_poly, cur_sequence);

	act = (WORD *) alloc( 4 * sizeof(WORD) );
	add_act(cur_tween, act);
	*(act++) = 4;
	if (bop_mode == FILLED)
		*(act++) = CHANGE_COLOR;
	else
		*(act++) = CHANGE_OCOLOR;
	*(act++) = poly_ix;
	*(act++) = ccolor;
	retween_poly_list(cur_sequence);
	draw_cur_frame(m);
	}
	}
else
	{
	c_dest = m_dest;
	return;
	}
}

