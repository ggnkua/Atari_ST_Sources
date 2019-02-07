/* Audio-Video Sequencer           */
/* Copyright 1988 Antic Publishing */
/* by Jim Kent                     */


#include "flicker.h"
#include "flicmenu.h"
#include <ctype.h>

WORD processed_key;


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


extern see_number_slider();


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

static Flicmenu *asl;

inc_sl()
{
struct slidepot *sl;

sl = (struct slidepot *)asl->text;
if (sl->value < sl->max)
	{
	sl->value++;
	draw_sel(asl);
	}
}

long
get60hz()
{
return(time_peek()*60/200);
}

pdn_timeout(timeout)
WORD timeout;
{
long time1;

time1 = get60hz() + timeout;
for (;;)
	{
	check_input();
	if (!PDN)
		return(0);
	if (get60hz() >= time1)
		return(1);
	}
}


repeat_on_pdn(v)
Vector v;
{
WORD i;

(*v)();
if (!pdn_timeout(30))
	return;
i = 0;
for (;;)
	{
	(*v)();
	if (!pdn_timeout( i<10 ? 8 : 4) )
		return;
	i++;
	}
}

inc_slider(m)
Flicmenu *m;
{
hide_mouse();
hilight(m);
asl = (Flicmenu *)m->text;
repeat_on_pdn(inc_sl);
draw_sel(m);
show_mouse();
}

dec_sl()
{
struct slidepot *sl;

sl = (struct slidepot *)asl->text;
if (sl->value > sl->min)
	{
	--sl->value;
	draw_sel(asl);
	}
}


dec_slider(m)
Flicmenu *m;
{
hide_mouse();
hilight(m);
asl = (Flicmenu *)m->text;
repeat_on_pdn(dec_sl);
draw_sel(m);
show_mouse();
}



char break_menu;
char believe_menu;

do_menu(m)
struct flicmenu *m;
{
Pull *ocpull;
Flicmenu *ocmenu;
unsigned char c;

break_menu = 0;
believe_menu = 0;
ocmenu = cur_menu;

cur_menu = m;
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
	}
cur_menu = ocmenu;
break_menu = 0;
}

return_yes()
{
believe_menu = 1;
break_menu = 1;
}

return_no()
{
break_menu = 1;
}


rksel( m)
register struct flicmenu *m;
{
if (m == NULL)
	return(0);
if ( rksel( m->next) )
	return(1);
if (rksel( m->children) )
	return(1);
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
if (m == NULL)
	return(0);
if ( rsel( m->next) )
	return(1);
if (rsel( m->children) )
	return(1);
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

