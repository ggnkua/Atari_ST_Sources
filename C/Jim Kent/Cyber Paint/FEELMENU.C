
#include "flicker.h"
#include "flicmenu.h"
#include <ctype.h>

find_grid(m)
register struct flicmenu *m;
{
register struct grid *g;
WORD x, y;
WORD width, height;

g = (struct grid *)m->text;
x = mouse_x - m->x - 1;
y = mouse_y - m->y - 1;
width = m->width-1;
height = m->height-1;
if (x < 0 || x >= width || y < 0 || y >= height )
	return(-1);

return(uscale_by(y, g->divy, height)*g->divx + uscale_by(x, g->divx, width) );
}

#ifdef SLUFFED
in_lr_half(m)
Flicmenu *m;
{
WORD xcenter;

xcenter = m->x + m->width/2;
if (mouse_x <= xcenter)
	return(-1);
else
	return(1);
}
#endif SLUFFED

clip_slider(s)
struct slidepot *s;
{
if (s->value < s->min)
	s->value = s->min;
if (s->value > s->max)
	s->value = s->max;
}

slide_where(m)
struct flicmenu *m;
{
struct slidepot *s;
WORD width;
WORD x;

s = (struct slidepot *)m->text;
x = mouse_x - m->x - 1;
width = m->width-2;
if (x < 0)
	return(s->min);
if (x >= width)
	return(s->max);
return(uscale_by(x, s->max - s->min + 1, width) + s->min);
}

#ifdef SLUFFED
upd_slidepot(m, erase, draw)
Flicmenu *m;
WORD erase, draw;
{
WORD new;
struct slidepot *s;

s = (struct slidepot *)m->text;
new = slide_where(m);
if (new != s->value)
	{
	hide_mouse();
	see_1slide(m, s->value, erase);
	see_1slide(m, new, draw);
	show_mouse();
	s->value = new;
	}
}
#endif SLUFFED

#ifdef SLUFFED
update_slidepot(m)
struct flicmenu *m;
{
upd_slidepot(m, sblack, swhite);
}
#endif SLUFFED

update_number_slider(m)
Flicmenu *m;
{
WORD new;
struct slidepot *s;

s = (struct slidepot *)m->text;
new = slide_where(m);
if (new != s->value)
	{
	hide_mouse();
	s->value = new;
	(*m->seeme)(m);
	show_mouse();
	}
}


move_range(m)
struct flicmenu *m;
{
mv_range(m, NULL, NULL);
}

mv_range(m, v1func, v2func)
struct flicmenu *m;
Vector v1func, v2func;
{
struct range *rg;
WORD *which;
WORD where;
Vector func;

rg = (struct range *)m->text;
where = slide_where(m);
if (absval(where - rg->v1) < absval(where-rg->v2) )
	{
	which = &rg->v1;
	func = v1func;
	}
else
	{
	which = &rg->v2;
	func = v2func;
	}
for (;;)
	{
	if (mouse_moved)
		{
		where = slide_where(m);
		if (where != *which)
			{
			hide_mouse();
			s_range(m, sblack);
			*which = where;
			s_range(m, swhite);
			if (func != NULL)
				(*func)();
			show_mouse();
			}
		}
	check_input();
	if (!PDN)
		break;
	}
}

extern see_number_slider();

#ifdef SLUFFED
feel_slidepot(m)
struct flicmenu *m;
{
feelslide(m, update_slidepot);
}
#endif SLUFFED

feel_number_slider(m)
Flicmenu *m;
{
feelslide(m, update_number_slider);
}

feelslide(m, update)
struct flicmenu *m;
Vector update;
{
(*update)(m);
for (;;)
	{
	check_input();
	if (!PDN)
		break;
	if (mouse_moved)
		(*update)(m);
	}
}


WORD processed_key;

char break_menu;

do_menu(m)
struct flicmenu *m;
{
Pull *ocpull;
Flicmenu *ocmenu;
unsigned char c;

break_menu = 0;
whipe_pull(0, 0, cur_pull);
ocpull = cur_pull;
ocmenu = cur_menu;

cur_pull = NULL;
cur_menu = m;
set_top_lines();
while (!break_menu)
	{
	check_input();
	if (key_hit)
		{
		c = key_in;
		if (c == ' ')
			break;
		if (isalpha(c))
			c = _tolower(c);
		if (c == 0)
			processed_key = key_in;
		else
			processed_key = c;
		rksel(m);
		}
	else if (PJSTDN)
		{
		rsel(m);
		}
	else if (RJSTDN)
		{
		wait_rup();
		break;
		}
	}
cur_menu = ocmenu;
cur_pull = ocpull;
see_pull(0, 0, cur_pull);
set_top_lines();
break_menu = 0;
}

char dummied_cefx;

return_dummy_key(m, key)
Flicmenu *m;
WORD key;
{
hide_mouse();
hilight(m);
wait_penup();
break_menu = 1;
key_hit = 1;
key_in = key;
dummied_cefx = 1;
reuse_input();
show_mouse();
}


rksel( m)
register struct flicmenu *m;
{
if (m->next)
	{
	if ( rksel( m->next) )
		return(1);
	}
if (m->children)
	{
	if (rksel( m->children) )
		return(1);
	}
if (processed_key == m->key_equiv)
	{
	if (m->feelme)
		{
		(*m->feelme)( m);
		}
	return(1);
	}
return(0);
}

rsel( m)
register struct flicmenu *m;
{
if (m->next)
	{
	if ( rsel( m->next) )
		return(1);
	}
if (m->children)
	{
	if (rsel( m->children) )
		return(1);
	}
if ( mouse_x >= m->x && mouse_x <= m->x + m->width &&
	mouse_y >= m->y && mouse_y <= m->y + m->height)
	{
	if (m->feelme)
		{
		(*m->feelme)( m);
		}
	return(1);
	}
return(0);
}

toggle_group(m)
struct flicmenu *m;
{
*m->group = !*m->group;
hide_mouse();
(*m->seeme)(m);
show_mouse();
}

change_mode(m)
Flicmenu *m;
{
unhi_group(cur_menu, m->group);
*(m->group) = m->identity;
hi_group(cur_menu, m->group);
}

