
overlay "vtools"

#include "..\\include\\lists.h"
#include "..\\include\\cursor.h"
#include "..\\include\\color.h"
#include "..\\include\\script.h"
#include "..\\include\\poly.h"
#include "..\\include\\acts.h"
#include "..\\include\\io.h"
#include "..\\include\\control.h"
#include "..\\include\\animath.h"
#include "..\\include\\drawmode.h"
#include "..\\include\\format.h"

extern WORD **expand_act_list();

extern WORD bop_mode;
extern WORD draw_mode;
extern WORD ground_z;

extern struct cursor spike_cursor;

vspike(control)
struct control *control;
{
struct menu *m = control->m;
struct selection *sel = control->sel;
struct virtual_input *vis = control->vis;

#ifdef DEBUG
printf("vspike(%lx)\n",control);
#endif DEBUG

switch (draw_mode)
	{
	case FREE_HAND:
	vfree_hand_spike(m,  sel, vis);
	break;
	case CIRCLE:
	vstar(m, sel, vis, 16, 0, "circle");
	break;
	case STAR:
	vstar(m, sel, vis, 5, 1, "star");
	break;
	case REG_POLY:
	vstar(m, sel, vis, 6, 0, "hexagon");
	break;
	case BLOCK:
	vrect(m, sel, vis);
		break;
	}
#ifdef AMIGA
maybe_disable_move();
#endif AMIGA
}

vrect(m, sel, vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
extern struct cursor cross_cursor;
WORD **act_list;
struct tween *cur_tween = *(cur_sequence->next_tween);
struct poly *cur_poly;
struct point *pt_list;
register struct point *pt, **pts;
WORD *sh_pt;
WORD i;
WORD x0, y0, x1, y1, swapper;

#ifdef DEBUG
printf("vrect()\n");
#endif DEBUG
show_help("drag out a box");
new_cursor(&cross_cursor);
if (get_pd_off_menu(m))
	{
	maybe_clear_menu(m);
	vis = getcurvis();
	x0 = vis->curx;
	y0 = vis->cury;
	while (vis->result & JUST_DN)
		{
		x1 = vis->curx;
		y1 = vis->cury;
		rub_frame(x0, y0, x1, y1);
		vis = await_input(USE_CURSOR);
		rub_frame(x0, y0, x1, y1);
		}
	if (x0 > x1)
		{
		swapper = x0;
		x0 = x1;
		x1 = swapper;
		}
	if (y0 > y1)
		{
		swapper = y0;
		y0 = y1;
		y1 = swapper;
		}
	save_undo();

	act_list = expand_act_list(cur_tween);
	*act_list = sh_pt = (WORD *)
		alloc( (lof_type(INSERT_CBLOCK))*sizeof(WORD) );
	sh_pt[0] = lof_type(INSERT_CBLOCK);
	sh_pt[1] = INSERT_CBLOCK;
	sh_pt[2] = cur_sequence->next_poly_list->count;
	sh_pt[3] = COLOR_BLOCK;
	sh_pt[4] = ccolor;
	sh_pt[5] = (x0 + x1)>>1;
	sh_pt[6] = (y0 + y1)>>1;
	sh_pt[7] = ground_z;
	sh_pt[8] = x1 - x0;
	sh_pt[9] = y1 - y0;
	insert_poly_in_s_sequence(cur_sequence, sh_pt[2]);
	ain_cblock( cur_sequence->next_poly_list, sh_pt);
	retween_poly_list(cur_sequence);
	draw_cur_frame(m);
	}
else
	{
	c_dest = m_dest;
	return;
	}

}


vfree_hand_spike(m,sel,vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
WORD **act_list;
struct tween *cur_tween = *(cur_sequence->next_tween);
struct poly *cur_poly;
struct point *pt_list;
register struct point *pt, **pts;
WORD *sh_pt;
WORD i;

#ifdef DEBUG
printf("vfree_hand_spike()\n");
lsleep(1);
#endif DEBUG

new_cursor(&spike_cursor);

show_help("make polygon - dot at a time");
for (;;)
	{
	vis = await_input(USE_CURSOR);
	if (in_menu(m,vis) || (keypress(vis) && vis->data == ' '))
		{
		reuse_input();
		return;
		}
	if (pjstdn(vis))
		{
		break;
		}
	}

#ifdef ATARI
hide_mbar();
#endif ATARI

save_undo();

maybe_clear_menu(m);
cur_sequence->next_poly_list->count++;
cken_polys(cur_sequence);

cur_poly = *(cur_sequence->next_poly_list->list + cur_sequence->next_poly_list->count - 1);
cur_poly->type = bop_mode; 
cur_poly->color = ccolor;
cur_poly->fill_color = ccolor;
cur_poly->pt_count = 2;
cken_points(cur_poly);

pt = cur_poly->pt_list;
pt->x = vis->curx;
pt->y = vis->cury;
pt->z = ground_z;
pt->level = 0;
pt++;
pt->x = vis->curx;
pt->y = vis->cury;
pt->z = ground_z;
pt->level = 0;

for(;;)
	{
	rub_poly(cur_poly, cur_sequence);
	vis = await_input(USE_CURSOR);
	unrub_poly(cur_poly, cur_sequence);
	if ((vis->result & CANCEL) || (vis->result & MENUPICKED) )
		{
		--cur_poly->pt_count;
		act_list = expand_act_list(cur_tween);
		*act_list = sh_pt = (WORD *)
			alloc( (4*cur_poly->pt_count + 
				lof_type(INSERT_POLY))*sizeof(WORD) );
		sh_pt[0] = 4*cur_poly->pt_count + lof_type(INSERT_POLY);
		sh_pt[1] = INSERT_POLY;
		sh_pt[2] = cur_sequence->next_poly_list->count - 1;
		sh_pt[3] = bop_mode;
		sh_pt[4] = ccolor;
		sh_pt[5] = cur_poly->pt_count;
		sh_pt[6] = ccolor;
		sh_pt[7] = 0;
		sh_pt[8] = 0;
		copy_structure( cur_poly->pt_list, sh_pt + 9, cur_poly->pt_count *
			sizeof(struct point) );
		insert_poly_in_s_sequence(cur_sequence, sh_pt[2]);
		break;
		}
	if (pjstdn(vis) )
		{
		cur_poly->pt_count++;
		cken_points(cur_poly);
		pt = (cur_poly->pt_list + cur_poly->pt_count - 1);
		if (cur_poly->pt_count == 4)
			show_help("right button after last point");
		}
	pt->x = vis->curx;
	pt->y = vis->cury;
	pt->z = ground_z;
	pt->level = 0;
	}
#ifdef AMIGA
if (vis->result & MENUPICKED)
	reuse_input();
#endif AMIGA
retween_poly_list(cur_sequence);
draw_cur_frame(m);
}


extern struct point center_point;






vstar(m,sel,vis,vertices, is_star, prompt)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
WORD vertices;
WORD is_star;
char *prompt;
{
WORD **act_list;
struct tween *cur_tween = *(cur_sequence->next_tween);
struct poly *cur_poly;
struct point *pt_list;
register struct point *pt, **pts;
WORD *sh_pt;
WORD distance;
WORD start_theta;
WORD i;
extern WORD rot_mode;
WORD inc_pt;

#ifdef DEBUG
printf("vstar(%d)\n",vertices);
#endif DEBUG

rot_mode = 'z';
if ( !move_center_point(m, sel, vis, prompt))
	{
	c_dest = m_dest;
	return;
	}

save_undo();
maybe_clear_menu(m);
new_cursor(&spike_cursor);
show_help("draw out to desired radius");

cur_sequence->next_poly_list->count++;
cken_polys(cur_sequence);

cur_poly = *(cur_sequence->next_poly_list->list + cur_sequence->next_poly_list->count - 1);
cur_poly->type = bop_mode; 
cur_poly->fill_color = cur_poly->color = ccolor;

if (is_star)
	{
	cur_poly->pt_count = 2*vertices;
	inc_pt = 2;
	}
else
	{
	cur_poly->pt_count = vertices;
	inc_pt = 1;
	}

cken_points(cur_poly);

i = cur_poly->pt_count;
pt = cur_poly->pt_list;
while ( --i >= 0)
	{
	pt->x = center_point.x;
	pt->y = center_point.y;
	pt->z = ground_z;
	pt->level = 0;
	pt++;
	}

vis = getcurvis();
while(vis->result & JUST_DN)
	{
	rub_poly(cur_poly, cur_sequence);
	vis = await_input(USE_CURSOR);
	unrub_poly(cur_poly, cur_sequence);

	distance = calc_distance(center_point.x, center_point.y,
		vis->curx, vis->cury);
	start_theta = arctan( vis->curx - center_point.x,
		vis->cury - center_point.y);

	pt = cur_poly->pt_list;
	for ( i = 0; i<vertices; i++)
		{
		pt->x = center_point.x + 
			itmult( distance, isin( start_theta + i*TWO_PI/vertices) ) +
			itmult( distance, icos( start_theta + i*TWO_PI/vertices) );
		pt->y = center_point.y + 
			itmult( distance, -isin( start_theta + i*TWO_PI/vertices) ) +
			itmult( distance, icos( start_theta + i*TWO_PI/vertices) );
		pt+=inc_pt;
		}
	if (is_star)
		{
		pt = cur_poly->pt_list + 1;
		distance /= 2;
		start_theta += TWO_PI/(vertices*2);
		for ( i = 0; i<vertices; i++)
			{
			pt->x = center_point.x + 
				itmult(distance, isin( start_theta + i*TWO_PI/vertices) ) +
				itmult(distance, icos( start_theta + i*TWO_PI/vertices) );
			pt->y = center_point.y + 
				itmult(distance, -isin( start_theta + i*TWO_PI/vertices) ) +
				itmult(distance, icos( start_theta + i*TWO_PI/vertices) );
			pt+=2;
			}
		}
	}

act_list = expand_act_list(cur_tween);
*act_list = sh_pt = (WORD *)
	alloc( (4*cur_poly->pt_count + 
		lof_type(INSERT_POLY))*sizeof(WORD) );
sh_pt[0] = 4*cur_poly->pt_count + lof_type(INSERT_POLY);
sh_pt[1] = INSERT_POLY;
sh_pt[2] = cur_sequence->next_poly_list->count - 1;
sh_pt[3] = bop_mode;
sh_pt[4] = ccolor;
sh_pt[5] = cur_poly->pt_count;
sh_pt[6] = ccolor;
sh_pt[7] = 0;
sh_pt[8] = 0;
copy_structure( cur_poly->pt_list, sh_pt + 9, cur_poly->pt_count *
	sizeof(struct point) );
insert_poly_in_s_sequence(cur_sequence, sh_pt[2]);
retween_poly_list(cur_sequence);
draw_cur_frame(m);
}


