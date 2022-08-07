

overlay "menu"

#include "..\\include\\lists.h"
#include "..\\include\\acts.h"
#include "..\\include\\color.h"
#include "..\\include\\menu.h"
#include "..\\include\\poly.h"
#include "..\\include\\control.h"
#include "..\\include\\format.h"
#include "..\\include\\io.h"
#include "..\\include\\cursor.h"
#include "..\\include\\clip.h"

extern struct cursor grab_cursor, select_cursor, tilde_cursor, question_cursor;
extern struct menu morph_m;
extern struct menu anim_m;
extern struct menu confirm_m;

#ifdef ATARI
extern struct menu *dissa_menu;	/*points to menu to redraw after been desked*/
#endif ATARI

main_menu_driver(control,nested)
struct control *control;
register WORD nested;
{
register struct menu *m = control->m;
register struct selection *sel = control->sel;
struct virtual_input *vis = control->vis;
register int i;

#ifdef DEBUG
ldprintf("\nmain_menu_driver(control%lx) control->(%lx %lx %lx)",control, m, sel, vis);
#endif DEBUG


for(;;)
	{
	vis = quick_input(USE_CURSOR);  /*so if out of menu, passes through 
					without waiting... */
	for (;;)
		{
		if (m->meta)
			new_cursor(&tilde_cursor);
		else if (m->help)
			new_cursor(&question_cursor);
		else
			new_cursor(&select_cursor);
		if ((vis->result & KEYPRESS) && m != &anim_m && m != &confirm_m)
			{
#ifdef ATARI
			switch (vis->data)
				{
				case 0x6200:	/* help */
					m->help = !m->help;
					break;
				case 0x6100:	/* undo */
					swap_undo(m, NULL, vis);
					make_cur_frame(m);
					break;
				case 0x4800:	/* up_arrow */
					goto_begin_script(m, NULL, vis);
					break;
				case 0x5000:	/* down arrow */
					goto_end_script(m ,NULL, vis);
					break;
				case 0x4b00:	/* left arrow */
					tm_snap_back(m, NULL, vis);
					break;
				case 0x4d00:	/* right arrow */
					tm_snap_shot(m, NULL, vis);
					break;
				case 0x5200:	/* insert */
					lreplay(m, NULL, vis);
					break;
				case 0x4700:	/* clr/home */
					breplay(m, NULL, vis);
					break;
				case 0x3920:	/* space bar */
					if (m == &morph_m)	/* special case highest level menu */
						{
						toggle_menu(m);
						return;
						}
					break;
				}
	#endif ATARI
			}
		else if (vis->result & MENUPICKED)
			{
			if ( !(nested & NOSWAP_CONT) )
				{
#ifdef ATARI
				gem_event(m, sel, vis);
#endif ATARI
#ifdef AMIGA
				intuition_event(m, sel, vis);
#endif AMIGA
				return;
				}
			else
				{
				reuse_input();
				return(0);
				}
			}
		else if (vis->result & CANCEL)
			{
			return(0); /*to return NO to confirm etc */
			}
		else if ( !in_menu(m,vis) && !(nested & NOSWAP_CONT) )
			return;
		else if (pjstdn(vis) )
			break;
		if (m->with_input)
			vis = (*m->with_input)(m, vis);
		else
			vis = await_input();
		}
	sel = m->sel_list;
	for (i=0; i<m->sel_count; i++)
		{
		if (in_selection(m,sel,vis) )
			{
			if (m->help)
				{
				if (sel->help_function)
					{
					(*sel->help_function)(m, sel,vis);
					}
				m->help = 0;
				}
			else if ( m->meta)
				{
				clear_menu(m);
				if (sel->double_function)
					{
					(*sel->double_function)(m, sel,vis);
					}
				m->meta = 0;
				draw_menu(m);
				}
			else if (sel->display_mode != DISABLED)
				{
				switch (sel->function_case)
					{
					case DISPLAY_ONLY:
						break;
					case NO_HI_GOSUB:
						if (sel->function)
							(*sel->function)(m, sel,vis);
						break;
					case GO_SUBBER:
						draw_sel(m,sel,hi_color);
						if (sel->function)
							(*sel->function)(m, sel,vis);
						draw_sel(m,sel,fore_color);
						break;
					case GO_SUB_REMENU:
						draw_sel(m,sel,hi_color);
						if (sel->function)
							(*sel->function)(m, sel,vis);
#ifdef ATARI
						wind_update(1);
#endif ATARI
						draw_menu(m);
#ifdef ATARI
						wind_update(0);
#endif ATARI
						break;
					case GO_SUB_REDRAW:
						draw_sel(m,sel,hi_color);
						if (sel->function)
							(*sel->function)(m, sel,vis);
						draw_cur_frame(m);
						break;
					case DISAPPEAR_MENU:
						clear_menu(m);
						if (sel->function)
							(*sel->function)(m, sel,vis);
#ifdef ATARI
						wind_update(1);
#endif ATARI
						draw_menu(m);
#ifdef ATARI
						wind_update(0);
#endif ATARI
						break;
					case HELP:
						m->help = !m->help;
						break;
					case DOUBLE:
						m->meta = !m->meta;
						if (m->meta)
							{
							draw_sel(m,sel,hi_color);
							}
						else
							{
							draw_sel(m,sel,fore_color);
							}
						break;
					case COMENU:
						if (sel->function)
							(*sel->function)(m, sel,vis);
						return;
					case RETURN_SOMETHING:
						draw_sel(m,sel,hi_color);
						if (sel->function)
							return(*sel->function)(m,sel,vis);
						else
							return(0);
#ifdef PARANOID
					default:
						ldprintf("unknown case %d in main_menu_driver()\n",
							sel->function_case);
						break;
#endif PARANOID
					}
				}
#ifdef AMIGA
			morph_hilights();
#endif AMIGA
#ifdef ATARI
			mmenu_hilights();
#endif ATARI
			break;  /*for(i=0; i<m->sel_count; i++) */
			}
		sel++;
		}
	}
}

in_selection(m,sel,vis)
struct menu *m;
register struct selection *sel;
register VIRTUAL_INPUT *vis;
{
register WORD x,y;

#ifdef DEBUG2
lprintf("in_selection(%lx %lx %lx) vis->(%d %d)\n",m, sel,vis);
#endif DEBUG2
x = vis->curx - m->xoff;
y = vis->cury - m->yoff;

return( x>sel->x_min_pos && x<sel->x_max_pos &&
	 y>sel->y_min_pos && y<sel->y_max_pos );
}


maybe_draw_menu(m)
register struct menu *m;
{
if (m->visible)
	draw_menu(m);
#ifdef ATARI
else
	dissa_menu = NULL;
#endif ATARI
}

draw_menu(m)
register struct menu *m;
{
register WORD i;
register struct selection *s;
struct one_of *one_of;
register WORD color;


#ifdef DEBUG
printf("draw_menu(%lx)\n",m);
lsleep(1);
#endif DEBUG

#ifdef ATARI
dissa_menu = m;
#endif ATARI

find_colors();
whipe_menu(m);

s = m->sel_list;

for (i=0; i<m->sel_count; i++)
	{
	switch (s->display_mode)
		{
		case DISABLED:
			color = grey_color;
			draw_sel(m, s, color);
			break;
		case ONE_OF:
			one_of = (struct one_of *)s->display_data;
			if ( *(one_of->which_one) == one_of->i_am)
				color = hi_color;
			else
				color = fore_color;
			draw_sel(m, s, color);
			break;
		default:
			if (s->is_selected)
				color = hi_color;
			else
				color = fore_color;
			draw_sel(m, s, color);
			break;
		}
	s++;
	}
}

draw_sel(m,s,color)
struct menu *m;
register struct selection *s;
register WORD color;
{
register struct one_of *one_of;

#ifdef DEBUG
printf("draw_sel(%lx %lx %d)\n", m, s, color);
lsleep(1);
#endif DEBUG

if (debug)
	frame(m, s, color, 1);
else
	{
	switch( s->display_mode)
	{
	case ONE_OF:
		one_of = (struct one_of *)s->display_data;
		s->display_data = one_of->display_data;
		if (s->display_function)
			(*s->display_function)(m, s,color);
		s->display_data = (char *)one_of;
		break;
	default:
		if (s->display_function)
			(*s->display_function)(m, s,color);
		break;
	}
	}
}


whipe_sel(m,sel)
register struct menu *m;
register struct selection *sel;
{
colblock(back_color, 
	m->xoff+sel->x_min_pos, m->yoff+sel->y_min_pos,
	m->xoff+sel->x_max_pos-1, m->yoff+sel->y_max_pos-1);
}

whipe_menu(m)
register struct menu *m;
{
colrop(back_color,m->xoff, m->yoff, m->width, m->height);
}

clear_menu(m)
register struct menu *m;
{
Cube c;

#ifdef ATARI
dissa_menu = NULL;
#endif ATARI

c.X = c.x = m->xoff;
c.Y = c.y = m->yoff;
c.X += m->width+1;
c.Y += m->height+1;
redraw_through_box(&c);
}

maybe_clear_menu(m)
register struct menu *m;
{

if (m->visible)
	{
	clear_menu(m);
	plop_front_to_back();
	}
}

in_menu(m,vis)
register struct menu *m;
register struct virtual_input *vis;
{
register WORD x,y;

#ifdef DEBUG
lprintf("in_menu(%lx %lx)\n",m,vis);
#endif DEBUG

if ((vis->result & MENUPICKED ) || (vis->result & KEYPRESS))
	{
	c_dest = m_dest;
	return(1);
	}
if (!m->visible)
	{
	c_dest = v_dest;
	return(0);
	}

x = vis->curx;
y = vis->cury;

if (x> m->xoff && y > m->yoff && x < m->xoff+m->width && y < m->yoff+m->height)
	{
	c_dest = m_dest;
	return(1);
	}
else
	{
	c_dest = v_dest;
	return(0);
	}
}

#ifdef SLUFFED
toggle_node(m, sel, vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
register struct one_of *one_of;

one_of = (struct one_of *)sel->display_data;
*(one_of->which_one) = !*(one_of->which_one);
}
#endif SLUFFED

new_mode(m, sel, vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
register struct one_of *one_of;

one_of = (struct one_of *)sel->display_data;
*(one_of->which_one) = one_of->i_am;
}

toggle_menu(m)
register struct menu *m;
{
extern char *title;

if (m->visible)
	{
	m->visible = 0;
	clear_menu(m);
	plop_front_to_back();
	}
else
	{
	m->visible = 1;
	draw_menu(m);
	}
#ifdef ATARI
mmenu_hilights();
#endif ATARI
}

hide_menu(m, sel, vis)
register struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
if (m->visible)
	{
	m->visible = 0;
	clear_menu(m);
	plop_front_to_back();
	}
return(0);
}

move_menu(m, sel, vis)
register struct menu *m;
struct selection *sel;
register struct virtual_input *vis;
{
register WORD initx, inity;
register WORD initxoff, inityoff;

initx = vis->curx;
inity = vis->cury;
initxoff = m->xoff;
inityoff = m->yoff;

clear_menu(m);
while (vis->result & JUST_DN)
	{
	m->xoff = initxoff +( vis->curx - initx);
	m->yoff = inityoff +( vis->cury - inity);
	if (m->yoff < 10)
	m->yoff = 10;
	rub_frame( m->xoff, m->yoff, m->xoff + m->width, m->yoff + m->height);
	vis = await_input(USE_CURSOR);
	rub_frame( m->xoff, m->yoff, m->xoff + m->width, m->yoff + m->height);
	}
}


crude_help(m, sel, vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
bottom_line( sel->help_data );
}



sel_x_off(m, sel, vis)
register struct menu *m;
register struct selection *sel;
register struct virtual_input *vis;
{
return(vis->curx - m->xoff - sel->x_min_pos);
}

sel_y_off(m, sel, vis)
register struct menu *m;
register struct selection *sel;
register struct virtual_input *vis;
{
return(vis->cury - m->yoff - sel->y_min_pos);
}

sel_height(sel)
register struct selection *sel;
{
return(sel->y_max_pos - sel->y_min_pos);
}

sel_width(sel)
register struct selection *sel;
{
return(sel->x_max_pos - sel->x_min_pos);
}

sel_mid_y(sel)
register struct selection *sel;
{
return( (sel->y_max_pos + sel->y_min_pos)/2);
}

sel_mid_x(sel)
register struct selection *sel;
{
return( (sel->x_max_pos + sel->x_min_pos)/2);
}

m_sel_xoff(m, sel)
struct menu *m;
struct selection *sel;
{
return(m->xoff + sel->x_min_pos);
}

m_sel_yoff(m, sel)
struct menu *m;
struct selection *sel;
{
return(m->yoff + sel->y_min_pos);
}

m_sel_cenx(m, sel)
struct menu *m;
struct selection *sel;
{
return(m->xoff + sel_mid_x(sel));
}

m_sel_ceny(m, sel)
struct menu *m;
struct selection *sel;
{
return(m->yoff + sel_mid_y(sel));
}

copy_menu_offsets(s, d)
register struct menu *s, *d;
{
d->xoff = s->xoff;
d->yoff = s->yoff;
}

center_menu(m)
register struct menu *m;
{
m->xoff = (XMAX - m->width)/2;
m->yoff = (YMAX - m->height)/2;
}

