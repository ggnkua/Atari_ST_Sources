
#include "flicker.h"
#include "flicmenu.h"

extern WORD startr_cursor[], endr_cursor[];
extern Flicmenu color_menu, cefx_menu;

save_menu()
{
set_top_lines();
if (zoom_flag)	/* do some re-arranging so menu's in our screen */
	{
	zbuf_to_screen();
	draw_on_screen();
	zscale_cursor = 0;
	}
else
	{
	copy_screen(pscreen, bscreen);
	}
}

restore_menu()
{
Pull *opull;
Flicmenu *omenu;

opull = cur_pull;
omenu = cur_menu;
cur_pull = NULL;
cur_menu = NULL;
set_top_lines();
cur_pull = opull;
cur_menu = omenu;
hide_mouse();
if (zoom_flag)
	{
	zscale_cursor = 1;
	draw_on_buffer();
	show_mouse();
	zbuf_to_screen();
	}
else
	{
	copy_screen(bscreen, pscreen);
	show_mouse();
	}
}

draw_a_menu(m)
struct flicmenu *m;
{
if (m != NULL)
	{
	hide_mouse();
	if (m == &color_menu || m == &cefx_menu)
		m = m->children;
	color_hslice(m->y-1, 1, 0); /* color 0 line to avoid interrupt
								flicker */
	draw_menus(m);
	show_mouse();
	}
}

draw_sub_menu(m)
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
		return(sred);
return(sblack);
}

a_block(color, m)
WORD color;
struct flicmenu *m;
{
colrop(color, m->x, m->y, m->width, m->height);
}

a_frame(color, m)
WORD color;
struct flicmenu *m;
{
draw_frame(color,  m->x,  m->y,  m->x + m->width, m->y + m->height);
}

see_menu_back( m)
struct flicmenu *m;
{
a_block(hilit(m), m);
a_frame(swhite, m);
}

white_block(m)
struct flicmenu *m;
{
a_block(swhite, m);
}

#ifdef SLUFFED
black_block(m)
struct flicmenu *m;
{
a_block(sblack, m);
}

yellow_block(m)
struct flicmenu *m;
{
a_block(4, m);
}
#endif SLUFFED

#ifdef SLUFFED
lines_h(l)
char **l;
{
char *s;
WORD h = 0;

while ((s = *l++) != NULL)
	h+=CH_HEIGHT;
return(h);
}
#endif SLUFFED

#ifdef SLUFFED
lines_w(l)
char **l;
{
char *s;
WORD w = 0;
WORD a;

while ((s = *l++) != NULL)
	{
	a = strlen(s);
	if (a > w)
		w = a;
	}
return(w*CH_WIDTH);
}
#endif SLUFFED

#ifdef SLUFFED
print_lines(lines, xoff, yoff, color)
char *lines[];
WORD xoff, yoff, color;
{
char *line;

while ((line = *lines++) != NULL) 
	{
	gtext(line, xoff, yoff, color);
	yoff += CH_HEIGHT;
	}
}
#endif SLUFFED

#ifdef SLUFFED
wb_text_box(m)
struct flicmenu *m;
{
WORD dx, dy;
WORD width, height;

see_menu_back( m);
width = lines_w(m->text);
height = lines_h(m->text);
dx = m->x + ((m->width-width)>>1);
dx += 4;
dx &= 0xfff8;
dy = m->y + ((m->height-height)>>1);
print_lines(m->text, dx, dy, swhite);
}
#endif SLUFFED

text_attr_box(m)
Flicmenu *m;
{
struct text_attr *ta;

ta = (struct text_attr *)m->text;
a_block(hilit(m), m);
a_frame(swhite, m);
vst_effects(handle, ta->attr);
gtext( ta->text, 
	m->x + (1+m->width)/2 - string_width(ta->text)/2, 
	m->y + (1+m->height)/2 - CH_HEIGHT/2 - 1, 
	swhite);
vst_effects(handle, 0);
}

wbtext(m)
struct flicmenu *m;
{
wbtext_offset(m, 0, 0);
}

wbtextx2(m)
struct flicmenu *m;
{
wbtext_offset(m, 2, 0);
}

wbtexty1(m)
Flicmenu *m;
{
wbtext_offset(m, 0, 1);
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
	swhite);
}

wbnumber(m)
Flicmenu *m;
{
wbnum(m, 0);
}

wbnumber1(m)
Flicmenu *m;
{
wbnum(m, 1);
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
	swhite);
}

inverse_cursor(m)
struct flicmenu *m;
{
inverse_c(m, m->text);
}


extern struct cursor cleft, cright, cup, cdown, cin, cout;

in_arrow(m)
Flicmenu *m;
{
inverse_c(m, &cin);
}

out_arrow(m)
Flicmenu *m;
{
inverse_c(m, &cout);
}

down_arrow(m)
Flicmenu *m;
{
inverse_c(m, &cdown);
}

up_arrow(m)
Flicmenu *m;
{
inverse_c(m, &cup);
}


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


#ifdef SLUFFED
see_itext(m)
struct flicmenu *m;
{
char *string = m->text;

a_block(swhite, m);
gtext( string, 
	m->x + (1+m->width)/2 - string_width(string)/2, 
	m->y + (1+m->height)/2 - CH_HEIGHT/2 - 1, 
	hilit(m));
}
#endif SLUFFED

#ifdef SLUFFED
see_frame_text(m)
struct flicmenu *m;
{
char *string = m->text;

a_block(hilit(m), m);
a_frame(swhite, m);
gtext( string, 
	m->x + (1+m->width)/2 - string_width(string)/2, 
	m->y + (1+m->height)/2 - CH_HEIGHT/2 - 1, 
	swhite);
}
#endif SLUFFED

center_grid(m, grid_ix, where, divx, divy)
register struct flicmenu *m;
WORD grid_ix;
register WORD *where;
WORD divx, divy;
{
WORD x, y;
WORD width, height;

x = grid_ix%divx;
y = grid_ix/divx;
width = m->width-2;
height = m->height - 2;
where[0] = ((uscale_by(x+1, width, divx) + uscale_by(x, width, divx))>>1)
	+ m->x + 1;
where[1] = ((uscale_by(y+1, height, divy) + uscale_by(y, height, divy))>>1)
	+ m->y + 1;
}

#ifdef SLUFFED
see_colors(m)
struct flicmenu *m;
{
s_colors(m, swhite);
}
#endif SLUFFED

see_colors2(m)
struct flicmenu *m;
{
s_colors(m, 0);
}

s_colors(m, outcolor)
struct flicmenu *m;
WORD outcolor;
{
struct grid *g;
WORD i, j, count;
WORD lastx, lasty;
WORD nextx, nexty;
WORD x, y;
WORD width, height;


a_frame(outcolor, m);
g = (struct grid *)m->text;
x = m->x+1;
y = m->y+1;
width = m->width-2;
height = m->height-2;
count = 0;
lasty = y;
for (i=0; i<g->divy; )
	{
	nexty = (i+1)*height/g->divy + y;
	lastx = x;
	for (j=0; j<g->divx; )
		{
		nextx = (j+1)*width/g->divx + x;
		colblock(count, lastx, lasty, nextx, nexty);
		if (count == ccolor)
			putdot((lastx+nextx)>>1, (lasty+nexty)>>1, oppositec[count] );
		count++;
		lastx = nextx;
		j++;
		}
	lasty = nexty;
	i++;
	}
}
extern WORD circ2_cursor[];


s_range(m, color)
struct flicmenu *m;
{
struct range *rg;
WORD where[4];
WORD steps;

rg = (struct range *)m->text;
steps = rg->max - rg->min + 1;
m->x += 1;
m->width -= 2;
center_grid(m, rg->v1 - rg->min, where, steps, 1);
center_grid(m, rg->v2 - rg->min, where+2, steps, 1);
m->x -= 1;
m->width += 2;
hline(where[1], where[0]+1, where[2]+1, color);
cdraw_brush(startr_cursor, where[0]+1, where[1], color);
cdraw_brush(endr_cursor, where[2]+1, where[3], color);
}

see_range(m)
struct flicmenu *m;
{
a_block(sblack, m);
s_range(m, swhite);
}


see_1slide(m, one, color)
struct flicmenu *m;
WORD one, color;
{
struct slidepot *s;
WORD nval;
WORD nmax;
WORD width;

s = (struct slidepot *)m->text;
nval = one - s->min;
nmax = s->max - s->min + 1;
width = m->width - 2;

colblock(color, 
	1+m->x + uscale_by(width, nval, nmax),
	m->y+1, 
	1+m->x + uscale_by(width, nval+1, nmax),
	m->y + m->height - 1);
}

see_islidepot(m)
struct flicmenu *m;
{
struct slidepot *s;

s = (struct slidepot *)m->text;
a_block(sblack, m);
see_1slide(m, s->value, swhite);
}

#ifdef SLUFFED
see_slidepot(m)
struct flicmenu *m;
{
struct slidepot *s;

s = (struct slidepot *)m->text;
a_block(swhite, m);
see_1slide(m, s->value, sblack);
}
#endif SLUFFED

see_n1_slider(m)
Flicmenu *m;
{
see_noff_slider(m, 1);
}

see_n160_slider(m)
Flicmenu *m;
{
see_noff_slider(m, -160);
}

see_n100_slider(m)
Flicmenu *m;
{
see_noff_slider(m, -100);
}

/* see a slider with value off by one sort of.... */
see_noff_slider(m, off)
register Flicmenu *m;
WORD off;
{
register struct slidepot *slp;
WORD width;

slp = (struct slidepot *)m->text;
slp->min -= off;
slp->max -= off;
slp->value -= off;
see_number_slider(m);
slp->min += off;
slp->max += off;
slp->value += off;
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
a_block(sblack, m);
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
colrop(swhite, xstart, m->y + 1, width, m->height-2);
#ifdef LATER
gtext( nbuf, xstart + 1 + (width - nwidth)/2, m->y + 2, sblack);
#endif LATER
gtext( nbuf, xstart + 1 + (width - nwidth)/2,
	m->y + ((m->height-CH_HEIGHT)>>1)+1, sblack);
}

#ifdef SLUFFED
WORD see_equivs = 0;
#endif SLUFFED


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

static WORD *group;
static char change;
static WORD saveid;

uh_group(m)
register struct flicmenu *m;
{

if (m->group == group)
	{
	if (*m->group == m->identity)
		{
		saveid = m->identity;
		if (change)
			m->identity = !m->identity;
		if (m->seeme)
			(*m->seeme)(m);
		m->identity = saveid;
		}
	}
if (m->children)
	uh_group(m->children);
if (m->next)
	uh_group(m->next);
}

unhi_group(m, mgroup)
register struct flicmenu *m;
WORD *mgroup;
{
group = mgroup;
change = 1;
hide_mouse();
uh_group(m);
show_mouse();
}

hi_group(m, mgroup)
register struct flicmenu *m;
WORD *mgroup;
{
group = mgroup;
change = 0;
hide_mouse();
uh_group(m);
show_mouse();
}


white_slice(m)
Flicmenu *m;
{
color_hslice(m->y, m->height+1, swhite);
}
