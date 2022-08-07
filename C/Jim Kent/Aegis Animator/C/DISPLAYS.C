
overlay "menu"

#include "..\\include\\lists.h"
#include "..\\include\\cursor.h"
#include "..\\include\\poly.h"
#include "..\\include\\color.h"
#include "..\\include\\format.h"
#include "..\\include\\menu.h"

text_in_box(m, s, color)
register struct menu *m;
register struct selection *s;
int color;
{
	just_text(m, s,color);
	frame(m, s, color, 1);
}

just_text(m, s,color)
register struct menu *m;
register struct selection *s;
int color;
{
	char *title;
	WORD xoffset, yoffset;

	title = s->display_data;

	xoffset = center_text(s->x_min_pos, s->x_max_pos, title) + 1;
	yoffset = sel_mid_y(s) - CHAR_HEIGHT/2 + 1;


	gtext(s->display_data,
		m->xoff +  xoffset,  yoffset + m->yoff,
	color);
}

inverse_text(m, s, color)
register struct menu *m;
register struct selection *s;
int color;
{
register WORD xoff, yoff;

xoff =  m->xoff;
yoff =  m->yoff;
colblock(color, xoff + s->x_min_pos, yoff + s->y_min_pos,
	xoff + s->x_max_pos, yoff + s->y_max_pos);
just_text(m, s, back_color);
}

cursor_and_text(m, s,color)
register struct menu *m;
register struct selection *s;
int color;
{
struct cursor_text *ct;
register  WORD xoffset, yoffset;

	ct = (struct cursor_text *) s->display_data;

	xoffset = m_sel_xoff(m, s);
	yoffset =  sel_mid_y(s) - CHAR_HEIGHT/2 + m->yoff;

	show_cursor( ct->cursor, xoffset + 4,
	sel_mid_y(s) + m->yoff, color);

	gtext(ct->text,
	xoffset +  16,
	yoffset,
	color);
}



center_text(min, max, string)
WORD min, max;
char *string;
{

	return(((max - min)>>1) - ( string_width(string) >> 1) + min);
}

cin_color(m, s,color)
struct menu *m;
struct selection *s;
int color;
{
register struct cursor *cursor = (struct cursor *)s->display_data;

show_c_nohot( cursor,
			sel_mid_x(s) + m->xoff - cursor->width/2,
			sel_mid_y(s) + m->yoff - cursor->height/2,
		color);
}

double_cursor(m, s, color)
register struct menu *m;
struct selection *s;
register int color;
{
WORD xoff, yoff;
register struct cursor *cursor = (struct cursor *)s->display_data;

xoff = sel_mid_x(s) + m->xoff - cursor->width/2;
yoff = sel_mid_y(s) + m->yoff - cursor->height/2;

show_c_nohot(cursor, xoff-2, yoff-1, color);
show_c_nohot(cursor, xoff+2, yoff+1, color);
}


cin_ccolor(m, s,color)
struct menu *m;
struct selection *s;
int color;
{
	cin_color(m,s,ccolor);
}

#ifdef SUN
cursor_in_a_box(m, s,color)
struct menu *m;
register struct selection *s;
int color;
{
register struct cursor *cursor;

cursor = (struct cursor *)s->display_data;
show_c_nohot(cursor,
			sel_mid_x(s) + m->xoff - cursor->width/2,
			sel_mid_y(s) + m->yoff - cursor->height/2,
			color);
	frame(m, s, color, 1);
}
#endif SUN



frame(m, s,color,strip)
struct menu *m;
register struct selection *s;
int color;
WORD strip;
{
	WORD xwidth, ywidth;
	WORD xoff, yoff;

	xwidth = sel_width(s);
	ywidth = sel_height(s);
	xoff = m_sel_xoff(m,s);
	yoff = m_sel_yoff(m,s);
	colrop(color, xoff, yoff,
	   	   strip, ywidth);
	colrop(color, xoff, yoff,
	xwidth, strip);
/*top and left*/

	colrop(color, xoff + xwidth - strip, yoff,
	strip, ywidth);	/*right*/

	colrop(color, xoff, yoff + ywidth - strip,
	   xwidth, strip);   /*bottom */
}

solid_block(m, s, color)
struct menu *m;
struct selection *s;
int color;
{
WORD xoff, yoff;

xoff =  m->xoff;
yoff =  m->yoff;
color = fore_color;
colblock(color, xoff + s->x_min_pos, yoff + s->y_min_pos,
	xoff + s->x_max_pos, yoff + s->y_max_pos);
}

color_bars(m, s, color)
struct menu *m;
struct selection *s;
int color;
{
extern struct cursor tick_cursor;

	int dx, dy;
	int xoff, yoff;
	WORD i,j;
	WORD cxoff, cyoff;

	xoff = m_sel_xoff(m, s);
	yoff = m_sel_yoff(m, s);

	dx = sel_width(s);
	dy = sel_height(s);

	color = 0;
	for (i=0; i<COL_YDIV; i++)
	for (j=0; j<COL_XDIV; j++)
	{
	cxoff = (j*dx + COL_XDIV/2)/COL_XDIV;
	cyoff = (i*dy + COL_YDIV/2)/COL_YDIV;
	colrop(color,
		xoff + cxoff, yoff + cyoff,
		( (j+1)*dx + COL_XDIV/2)/COL_XDIV - cxoff,
		( (i+1)*dy + COL_YDIV/2)/COL_YDIV - cyoff);
	if (color == ccolor)
		{
		struct color_def cd;
		WORD com_color;

		copy_structure( usr_cmap+ccolor, &cd, sizeof(struct color_def) );
		cd.red ^= 0x80;
		cd.green ^= 0x80;
		cd.blue ^= 0x80;
		show_cursor( &tick_cursor,
		xoff + cxoff + dx/(COL_XDIV*2),
		yoff + cyoff + dy/(COL_YDIV*2),
		closest_color(usr_cmap, MAXCOL, &cd));
		}
	color++;
	}
}

