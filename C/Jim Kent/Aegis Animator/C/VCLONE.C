
overlay "vtools"

#include <stdio.h>
#include "..\\include\\lists.h"
#include "..\\include\\acts.h"
#include "..\\include\\script.h"
#include "..\\include\\poly.h"
#include "..\\include\\control.h"
#include "..\\include\\io.h"
#include "..\\include\\cursor.h"
#include "..\\include\\addr.h"
#include "..\\include\\format.h"

extern WORD **expand_act_list();
extern struct point *which_point();
extern WORD s_mode;
extern WORD  **get_polys_only();
extern WORD *act_from_poly();
extern WORD see_beginning;

WORD exchange_mode = 0;	/*global flag to replace closest object with new, 
								or just insert new*/
cope_exchange()
{
if (exchange_mode)
	{
	WORD poly_ix;
	WORD *act;
	struct virtual_input *vis;

	extern struct poly *which_poly();

	vis = getcurvis();
	if (which_poly(vis, cur_sequence, &poly_ix) != NULL)
		{
		act = (WORD *) alloc(3 * sizeof(WORD));
		*act = 3;
		*(act+1) = KILL_POLY;
		*(act+2) = poly_ix;
		add_act( *(cur_sequence->next_tween), act);
		aki_poly((cur_sequence->next_poly_list), act, 0);
		kpl_in_s_sequence(cur_sequence, poly_ix);
		return(1);
		}
	}
return(0);
}


vclone(control)
struct control *control;
{
static WORD last_all = 0;
struct menu *m = control->m;
struct selection *sel = control->sel;
struct virtual_input *vis = control->vis;
WORD lastx, lasty;
char *vclone_prompt = "clone - make a copy of object";

register Poly_list *poly_list = cur_sequence->next_poly_list;
register struct tween *cur_tween = *(cur_sequence->next_tween);

WORD o_a_count, o_poly_count;
WORD i;
struct poly *p, **pp, *sp, *dp;
WORD **act_list, *act;
WORD **ap_list, *ap;

WORD **la_polys;
WORD la_poly_count;

#ifdef DEBUG
ldprintf("vclone()\n");
#endif DEBUG

if (no_polys_check() )
	return;

new_cursor(&clone_cursor);
show_help(vclone_prompt);
if (poly_list->count <= 0)
	{
	c_dest = m_dest;
	return;
	}


la_polys = get_polys_only(m, sel, vis, cur_sequence, 
	s_mode, poly_list, &la_poly_count);
if (!la_polys)
	{
	c_dest = m_dest;
	return;
	}

new_cursor(&clone_cursor);
if (s_mode == S_POLYS )
	{
	show_help(vclone_prompt);
	vis = await_anydn(USE_CURSOR);
	if ( !pjstdn(vis) )
		{
		undisplay_active();
		maybe_draw_menu(m);
		if ( !(vis->result & CANCEL) )
			{
			reuse_input();
			}
		return_to_menu;
		}
	}
else
	vis = quick_input(USE_CURSOR);


/*little confirmation cause it's a hassle when inadvertantly clone all*/
if (s_mode == S_FRAME && !last_all)
	{
	if (!confirm(m ,sel, vis,"clone all objects?") )
		{
		c_dest = m_dest;
		maybe_draw_menu(m);
		return;
		}

	new_cursor(&clone_cursor);
	if (!get_pd_no_menu() )
		{
		c_dest = m_dest;
		maybe_draw_menu(m);
		return;
		}
	}

if (s_mode == S_FRAME)
	last_all = 1;
else
	last_all = 0;

show_help("release clone at place of birth");
save_undo();

o_poly_count = poly_list->count;
poly_list->count += la_poly_count;
cken_polys(cur_sequence);

i = la_poly_count;
pp = poly_list->list + o_poly_count;
ap_list = la_polys;
while (--i >= 0)
	{
	ap = *(ap_list++);
	sp = *(poly_list->list + ap[2]);
	dp = *(pp++);
	copy_poly(sp, dp);
	if (dp->type == ANI_STRIP)
		{
		struct ani_strip *strip;
		
		strip = (struct ani_strip *)dp;
		strip->script_ix = add_a_strip(
			cur_sequence->child_scripts[strip->script_ix], cur_sequence);
		}
	}

lastx = vis->curx*VRES;
lasty = vis->cury*VRES;

while (vis->result & JUST_DN)
	{
	i = la_poly_count;
	pp = poly_list->list + o_poly_count;
	while (i--)
		{
		p = *(pp++);
		rub_poly(p, cur_sequence);
		}
	vis = await_input(USE_CURSOR);
	i = la_poly_count;
	pp = poly_list->list + o_poly_count;
	while (i--)
	{
	p = *(pp++);
	unrub_poly(p, cur_sequence);
	move_poly(p, p, vis->curx*VRES - lastx, vis->cury*VRES - lasty);
	}

	lastx = vis->curx*VRES;
	lasty = vis->cury*VRES;
	}

if (la_poly_count == 1 && exchange_mode)
	{
	WORD poly_ix;
	WORD *act;

	extern struct poly *which_poly();
	poly_list->count -= 1;
	if (which_poly(vis, cur_sequence, &poly_ix) != NULL)
		{
		act = (WORD *) alloc(3 * sizeof(WORD));
		*act = 3;
		*(act+1) = KILL_POLY;
		*(act+2) = poly_ix;
		add_act( *(cur_sequence->next_tween), act);
		poly_list->count += 1;
		aki_poly(poly_list, act, 0);
		kpl_in_s_sequence(cur_sequence, poly_ix);
		(la_polys[0])[2] -= 1;
		}
	else
		{
		poly_list->count += 1;
		}
	p = poly_list->list[ poly_list->count - 1];
	act = act_from_poly(p, poly_list->count - 1, cur_sequence);
	add_act( *(cur_sequence->next_tween), act);
	insert_poly_in_s_sequence(cur_sequence, poly_list->count-1);
	}
else
	{
	i = cur_tween->act_count;
	act_list = (WORD **) alloc( (i+la_poly_count) * sizeof(WORD *) );
	copy_structure( cur_tween->act_list, 
		act_list, i * sizeof(WORD *) );
	mfree( cur_tween->act_list, i * sizeof(WORD *) );
	cur_tween->act_count+= la_poly_count;
	cur_tween->act_list = act_list;
	/*expand act list*/

	act_list += i;  /*point act_list to first open slot*/
	i = la_poly_count;
	pp = poly_list->list + o_poly_count;
	while (--i >= 0)
		{
		p = *(pp++);
		*act_list++ = act_from_poly(p, o_poly_count, cur_sequence);
		insert_poly_in_s_sequence(cur_sequence, o_poly_count);
		o_poly_count++;
		}
	}
retween_poly_list(cur_sequence);
draw_cur_frame(m);
}


