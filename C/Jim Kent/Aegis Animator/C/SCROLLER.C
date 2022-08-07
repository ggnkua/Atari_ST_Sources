
overlay "menu"

#include "..\\include\\lists.h"
#include "..\\include\\menu.h"
#include "..\\include\\io.h"
#include "..\\include\\cursor.h"
#include "..\\include\\color.h"
#include "..\\include\\format.h"

scroll_height(s)
register struct selection *s;
{
return(sel_height(s) - 2*CHAR_HEIGHT - 4);
}

find_swp_height(sel, sc)
struct selection *sel;
struct select_column *sc;
{
WORD sc_height;

sc_height = scroll_height(sel);
if (sc->names_visible > sc->name_count)
	return(sc_height);
else
	return(sc_height * sc->names_visible / sc->name_count);
}

find_swp_top(sel, sc)
struct selection *sel;
struct select_column *sc;
{
return(CHAR_HEIGHT + 2 + sc->top_name * scroll_height(sel)/ sc->name_count);
}

show_scroll_window_pos(m, sel, sc, color)
struct menu *m;
struct selection *sel;
struct select_column *sc;
WORD color;
{

colrop(color,
	m_sel_xoff(m, sel) + 2,
	m_sel_yoff(m, sel) + find_swp_top(sel, sc),
	6,
	find_swp_height(sel, sc) );
}

do_scroller(m,sel,vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
register struct select_column *sc = (struct select_column *)sel->display_data;
WORD curx, cury;
WORD dy;
WORD init_top;
WORD swp_top;

if (sc->name_count <= 0)
	return;

curx = sel_x_off(m, sel, vis);
cury = sel_y_off(m, sel, vis);

if (curx >= 12 ) /*in name list*/
	{
	sc->selected = (cury)/CHAR_HEIGHT + 
	sc->top_name;
	if (sc->selected >= sc->name_count)
	sc->selected = sc->name_count - 1;
	}
else  /*in scroll bars*/
	{
	if (sc->name_count > sc->names_visible)
		{
		if (cury <= CHAR_HEIGHT) /*top arrow*/
			sc->top_name -= 1;
		else if   /*bottom arrow*/
				(cury >=  (sel_height(sel) -  CHAR_HEIGHT) )
			sc->top_name += 1;
		else if (cury >= (swp_top = find_swp_top(sel, sc) ) )
			{
			if (cury <= find_swp_height(sel, sc) + swp_top) /*move window*/
			{
			init_top = sc->top_name;
			while (vis->result & JUST_DN)
				{
				show_scroll_window_pos(m, sel, sc, fore_color);
				vis = await_input(USE_CURSOR);
				show_scroll_window_pos(m, sel, sc, back_color);
				dy = sel_y_off(m, sel, vis) - cury;
				sc->top_name = 
					init_top + sc->name_count * dy / scroll_height(sel);
				WORD_clip(0, &sc->top_name,
					sc->name_count - sc->names_visible + 1);
				}
			}
			else	/* page down */
			{
			sc->top_name += sc->names_visible;
			}
			}
		else		/*page up */
			{
			sc->top_name -= sc->names_visible;
			}
		clip_scroll(sc);
		}
	}
}

clip_scroll(sc)
register struct select_column *sc;
{
WORD_clip(0, &sc->top_name, sc->name_count - sc->names_visible + 1);
}

see_scroller(m,s,color)
register struct menu *m;
register struct selection *s;
int color;
{
register struct select_column *sc = (struct select_column *)s->display_data;
register struct name_list *nl = sc->name_list;
extern struct cursor up_arrow_cursor, dwn_arrow_cursor;
WORD xoff, yoff,xend, yend;
WORD x,y;
WORD startx;
WORD i,j;
WORD count = sc->top_name;
WORD max_chars, actual_chars;
char *string_pt;
extern char *title;

sc->names_visible = sel_height(s)/CHAR_HEIGHT;

xoff = m_sel_xoff(m, s);
yoff = m_sel_yoff(m, s);
xend = m->xoff + s->x_max_pos;
yend = m->yoff + s->y_max_pos;

hline(yoff,
	xoff,
	xoff+10,fore_color);
hline(yoff + CHAR_HEIGHT,
	xoff,
	xoff+10,fore_color);
hline(yend-CHAR_HEIGHT,
	xoff,
	xoff+10,fore_color);
hline(yend,
	xoff,
	xoff+10,fore_color);
vline( xoff,
	yoff,
	yend, fore_color);
vline( xoff+10,
	yoff,
	yend, fore_color);
show_cursor( &up_arrow_cursor,
	xoff + 6,
	yoff + CHAR_HEIGHT/2 + 1,
	fore_color);
show_cursor( &dwn_arrow_cursor,
	xoff + 6,
	yend - CHAR_HEIGHT/2 + 1,
	fore_color);
if (sc->name_count > 0)
	{
	show_scroll_window_pos(m, s, sc, fore_color);
	startx = x = xoff+ 12;
	max_chars = (xend - startx)/CHAR_WIDTH;
	y = yoff;

	for (i=0; i<sc->top_name; i++)
		{
		if (!nl)
			break;
		nl = nl->next;
		}
	for ( ; i<sc->name_count && i<sc->top_name + sc->names_visible; i++)
		{
		if (!nl)
			break;
		if (jstrcmp( nl->name, title) == 0)
			color = hi_color;
		else
			color = fore_color;
			
		clip_text(nl->name, x, xend, y, color);
		y += CHAR_HEIGHT;
		x = startx;
		nl = nl->next;
		}
	}
}


