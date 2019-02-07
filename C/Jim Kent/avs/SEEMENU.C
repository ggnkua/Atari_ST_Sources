/* Audio-Video Sequencer           */
/* Copyright 1988 Antic Publishing */
/* by Jim Kent                     */


#include "flicker.h"
#include "flicmenu.h"


draw_a_menu(m)
struct flicmenu *m;
{
if (m != NULL)
	{
	hide_mouse();
	draw_menus(m);
	show_mouse();
	}
}

hilit(m)
struct flicmenu *m;
{
if (m->group)
	if (*m->group == m->identity)
		return(red);
return(black);
}

a_block(color, m)
WORD color;
struct flicmenu *m;
{
colrop(color, m->x, m->y, m->width, m->height);
}

a_fframe(color, m)
WORD color;
struct flicmenu *m;
{
colrop(color, m->x-1, m->y+1, 2, m->height-2);
colrop(color, m->x+m->width-1, m->y+1, 2, m->height-2);
colrop(color, m->x-1, m->y-1, m->width+2, 2);
colrop(color, m->x-1, m->y+m->height-1, m->width+2, 2);
}

a_frame(color, m)
WORD color;
struct flicmenu *m;
{
draw_frame(color,  m->x,  m->y,  m->x + m->width, m->y + m->height);
}


black_block(m)
struct flicmenu *m;
{
a_block(black, m);
}


wbtext(m)
struct flicmenu *m;
{
wbtext_offset(m, 0, 0);
}



wbtext_offset(m, dx, dy)
struct flicmenu *m;
WORD dx, dy;
{
char *string = m->text;

a_block(hilit(m), m);
gtext( string, 
	dx + m->x + (1+m->width)/2 - string_width(string)/2, 
	dy + m->y + (1+m->height)/2 - CH_HEIGHT/2 - 1, 
	white);
}

wbnumber(m)
Flicmenu *m;
{
wbnum(m, 0);
}


wbnum(m, yoff)
register struct flicmenu *m;
WORD yoff;
{
char buf[10];
char *savetext;

sprintf(buf, "%d", *((WORD *)m->text));
savetext = m->text;
m->text = buf;
wbtext_offset(m, 0, yoff);
m->text = savetext;
}


inverse_c(m, c)
struct flicmenu *m;
struct cursor *c;
{
a_block(hilit(m), m);
show_cursor(c,
	m->x + (1+m->width)/2, 
	m->y + (1+m->height)/2, 
	white);
}


extern struct cursor cleft, cright;


left_arrow(m)
struct flicmenu *m;
{
inverse_c(m, &cleft);
}

right_arrow(m)
struct flicmenu *m;
{
inverse_c(m, &cright);
}

hilight(m)
struct flicmenu *m;
{
WORD *save_group;

if (m->seeme != NULL)
	{
	save_group = m->group;
	m->group = &m->identity;
	(*m->seeme)(m);
	m->group = save_group;
	}
}

draw_sel(m)
struct flicmenu *m;
{
if (m != NULL && m->seeme != NULL)
	{
	(m->seeme)(m);
	}
}



fat_frame_text(m)
struct flicmenu *m;
{
char *string = m->text;

a_fframe(white, m);
gtext( string, 
	m->x + (1+m->width)/2 - string_width(string)/2, 
	m->y + (1+m->height)/2 - CH_HEIGHT/2 - 1, 
	white);
}

see_frame_text(m)
struct flicmenu *m;
{
char *string = m->text;

a_frame(white, m);
gtext( string, 
	m->x + (1+m->width)/2 - string_width(string)/2, 
	m->y + (1+m->height)/2 - CH_HEIGHT/2 - 1, 
	white);
}

see_number_slider(m)
register Flicmenu *m;
{
register struct slidepot *slp;
WORD width;
WORD swidth;
WORD nwidth;	/* width of number */
WORD nval;
WORD nmax;
WORD xstart;
char nbuf[10];	/* buffer for number */

slp = (struct slidepot *)m->text;
a_block(black, m);
swidth = m->width - 2;
nval = slp->value - slp->min;
nmax = slp->max - slp->min + 1;
width = uscale_by(swidth, nval+1, nmax) - uscale_by(swidth, nval, nmax);
sprintf(nbuf, "%d", slp->value+1);
nwidth = strlen(nbuf)*CH_WIDTH+1;
if (width < nwidth)
	width = nwidth;
swidth -= width;
xstart = 1+m->x + uscale_by(swidth, nval, nmax-1);
colrop(white, xstart, m->y + 1, width, m->height-2);
ctext( nbuf, xstart + 1 + (width - nwidth)/2,
	m->y + ((m->height-CH_HEIGHT)>>1)+1, black);
}


draw_menus(m)
register struct flicmenu *m;
{
if (m->seeme)
	(*m->seeme)(m);
if (m->children)
	draw_menus(m->children);
if (m->next)
	draw_menus(m->next);
}


white_slice(m)
Flicmenu *m;
{
color_hslice(m->y, m->height+1, white);
}
