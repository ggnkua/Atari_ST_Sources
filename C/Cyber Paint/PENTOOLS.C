
#include "flicker.h"
#include "flicmenu.h"

extern WORD clip_brush;
extern struct slidepot spray_sl, spread_sl;

WORD firstx, firsty;
WORD cenx, ceny;
WORD x_0, y_0, x_1, y_1;
char bap_line_buf[320];	/* byte-a-pixel line buffer */

draw()
{
save_undo();
mouse_on = 0;	/* take over cursor handling ourselves, not in check input */
				/* it's a mess of global variables, but should let us */
				/* scribble faster! */
lastx = mouse_x;
lasty = mouse_y;
set_solid_line();
for (;;)
	{
	if (mouse_moved)
		{
		if (cycle_draw)
			{
			cycle_ccolor();
			set_acolor(ccolor);
			}
		wait_out_beam();	/* reduce mouse cursor flicker */
		restore_m();
		line(lastx, lasty, mouse_x, mouse_y);
		save_m();
		draw_m();
		update_zoom();
		}
	check_input();
	if (!PDN)
		break;
	}
mouse_on = 1;
}


scribble()
{
register WORD delay;
int j, k;

delay = 99 - spray_sl.value;
save_undo();
mouse_on = 0;	/* take over cursor handling ourselves, not in check input */
				/* it's a mess of global variables, but should let us */
				/* scribble faster! */
for (;;)
	{
	if (mouse_moved)
		{
		if (cycle_draw)
			cycle_ccolor();
		wait_out_beam();	/* reduce mouse cursor flicker */
		restore_m();
		plot(mouse_x, mouse_y, ccolor);
		save_m();
		draw_m();
		update_zoom();
		}
	check_input();
	if (!PDN)
		break;
	if (j = delay)
		{
		while (--j >= 0)
			{
			k = 200;
			while (--k >= 0)
				;
			}
		}

	}
mouse_on = 1;
}

drizzle()
{
register int i;
int xybuf[2];
register int wait;

/* make time delay twice as long for brushes as points */
if (brush_ix == 0 && clip_brush == 0)
	wait = 1;
else
	wait = 2;
save_undo();
mouse_on = 0;
while (PDN)
	{
	cycle_ccolor();
	polar(FastRand() + i, FastRand()&0x7, xybuf);
	wait_out_beam();	/* reduce mouse cursor flicker */
	restore_m();
	plot(xybuf[0] + mouse_x, xybuf[1] + mouse_y, ccolor);
	save_m();
	draw_m();
	if (zoom_flag)	/* zoom_buf_to_screen takes about 2/60th of a second */
		zbuf_to_screen();
	else
		wait_a_jiffy(wait);
	i++;
	check_input();
	}
mouse_on = 1;
}

spray()
{
register int i;
register WORD radius, delay;
int j, k;
int xybuf[2];

save_undo();
if (delay)
	mouse_on = 0;
else
	hide_mouse();
radius = spread_sl.value+1;
delay = 99 - spray_sl.value;
while (PDN)
	{
	if (cycle_draw)
		cycle_ccolor();
	polar(FastRand() + i, FastRand()%radius, xybuf);
	check_input();
	if (delay)
		{
		wait_out_beam();	/* reduce mouse cursor flicker */
		restore_m();
		plot(xybuf[0] + mouse_x, xybuf[1] + mouse_y, ccolor);
		save_m();
		draw_m();
		}
	else
		plot(xybuf[0] + mouse_x, xybuf[1] + mouse_y, ccolor);
	if (zoom_flag)
		zbuf_to_screen();
	i++;
	if (j = delay)
		{
		while (--j >= 0)
			{
			k = 200;
			while (--k >= 0)
				;
			}
		}

	}
if (delay)
	mouse_on = 1;
else
	show_mouse();
maybe_zoom();
}

flood()
{
cycle_ccolor();
save_undo();
hide_mouse();
floodfill(mouse_x, mouse_y, ccolor);
show_mouse();
update_zoom();
wait_penup();
}


init_some_tools()
{
save_undo();
undo_to_buf();
cenx = firstx = mouse_x;
ceny = firsty = mouse_y;
set_solid_line();
hide_mouse();
draw_on_buffer();
show_mouse();
update_screen();
}

uninit_some_tools()
{
if (!zoom_flag)
	{
	hide_mouse();
	buf_to_screen();
	draw_on_screen();
	show_mouse();
	}
}

static
first_mouse()
{
line(firstx, firsty, mouse_x, mouse_y);
}

#ifdef SLUFFED
static
first_last()
{
line(firstx, firsty, lastx, lasty);
}
#endif SLUFFED

draw_line()
{
switch (connect_mode)
	{
	case DISTINCT:
		draw_a_line();
		break;
	case CONNECTED:
		draw_lines();
		break;
	case CONCENTRIC:
		rays();
		break;
	}
}


draw_a_line()
{
cycle_ccolor();
init_some_tools();
plot_nobrush(mouse_x, mouse_y, ccolor);
for (;;)
	{
	check_input();
	if (!PDN)
		break;
	if (mouse_moved)
		{
		hide_mouse();
		unundo();
		first_mouse();
		show_mouse();
		update_screen();
		}
	}
uninit_some_tools();
}

draw_lines()
{
cycle_ccolor();
d_poly(0, 0);
}

draw_polygon()
{
cycle_ccolor();
d_poly(1, filled_flag);
}

#define MAXPTS 64

d_poly(connected, filled)
WORD connected, filled;
{
WORD points[MAXPTS*2+2];
register WORD count;

init_some_tools();
points[2] = points[0] = mouse_x;
points[3] = points[1] = mouse_y;
count = 2;
wait_penup();
for (;;)
	{
	for (;;)
		{
		check_input();
		if (RDN || count >= MAXPTS)
			{
			hide_mouse();
			unundo();
			some_poly(points, count-1, connected, filled);
			show_mouse();
			update_screen();
			uninit_some_tools();
			wait_rup();
			return;
			}
		if (PJSTDN)
			{
			points[2*count-2] = points[2*count] = mouse_x;
			points[2*count-1] = points[2*count+1] = mouse_y;
			count++;
			}
		if (mouse_moved)
			{
			points[2*count-2] = mouse_x;
			points[2*count-1] = mouse_y;
			hide_mouse();
			unundo();
			some_poly(points, count, connected, filled);
			show_mouse();
			update_screen();
			}
		}
	}
}

some_poly(points, count, connected, filled)
register WORD *points;
register WORD count, connected, filled;
{
if (filled)
	polyfill( points, count, ccolor);
else
	{
	if (connected)
		{
		points[2*count] = points[0];
		points[2*count+1] = points[1];
		polyline( points, count+1, ccolor);
		}
	else
		polyline( points, count, ccolor);
	}
}

rays()
{
init_some_tools();
plot_nobrush(mouse_x, mouse_y, ccolor);
for (;;)
	{
	while (PDN)
		{
		if (mouse_moved)
			{
			cycle_ccolor();
			set_solid_line();
			hide_mouse();
			line(firstx, firsty, mouse_x, mouse_y);
			first_mouse();
			show_mouse();
			update_screen();
			}
		check_input();
		}
	hide_mouse();			
	set_xor_line();	 /* and leave up xor line and cursor */
	thin_line(firstx, firsty, mouse_x, mouse_y);
	show_mouse();
	update_screen();
	for (;;)
		{
		check_input();
		if (EDN)	/* if button pushed either out of rays, or back to
						the pendown state */
			{
			hide_mouse();
			set_xor_line();	/* erase last xor */
			thin_line(firstx, firsty, lastx, lasty);
			show_mouse();
			update_screen();
			if (PDN)
				{
				break;
				}
			else
				{
				uninit_some_tools();
				wait_rup();
				return;
				}
			}
		if (mouse_moved)	/* if moved erase last xor line and put up new one*/
			{
			hide_mouse();	
			set_xor_line();			/* go into xor mode */
			thin_line(firstx, firsty, lastx, lasty);
			thin_line(firstx, firsty, mouse_x, mouse_y);
			show_mouse();
			update_screen();
			}
		}
	}
}

swap_d_box()
{
if (firstx > mouse_x)
	{
	x_0 = mouse_x;
	x_1 = firstx;
	}
else
	{
	x_0 = firstx;
	x_1 = mouse_x;
	}
if (firsty > mouse_y)
	{
	y_0 = mouse_y;
	y_1 = firsty;
	}
else
	{
	y_0 = firsty;
	y_1 = mouse_y;
	}
}

lines_cursor()
{
register WORD color;

color = oppositec[getdot(mouse_x, mouse_y)];
hline(mouse_y, 0, XMAX, color);
vline(mouse_x, 0, YMAX, color);
}

d_frame()
{
if (brush_ix == 0)
	draw_frame(ccolor, x_0, y_0, x_1, y_1);
else
	brush_draw_frame(x_0, y_0, x_1, y_1);
}

d_block()
{
colblock(ccolor, x_0, y_0, x_1, y_1);
}

draw_d_box()
{
if (filled_flag)
	d_block();
else
	d_frame();
}

draw_circle()
{
WORD radius;

cycle_ccolor();
init_some_tools();
for (;;)
	{
	check_input();
	if (RDN)
		{
		wait_rup();
		break;
		}
	if (!PDN)
		{
		if (connect_mode == DISTINCT)
			break;
		else 
			{
			if (connect_mode == CONNECTED)
				{
				firstx = lastx;
				firsty = lasty;
				}
			cycle_ccolor();
			set_acolor(ccolor);
			wait_ednkey();
			if (key_hit)
				{
				reuse_input();
				break;
				}
			if (RDN)
				{
				wait_rup();
				break;
				}
			save_undo();
			}
		}
	if (mouse_moved)
		{
		if (connect_mode == CONNECTED)
			{
			cenx = (mouse_x + firstx)>>1;
			ceny = (mouse_y + firsty)>>1;
			}
		radius = calc_distance(mouse_x, mouse_y, cenx, ceny);
		hide_mouse();
		unundo();
		if (filled_flag)
			disk(cenx, ceny, radius, ccolor);
		else
			circle(cenx, ceny, radius, ccolor);
		show_mouse();
		update_screen();
		}
	}
uninit_some_tools();
}


draw_box()
{
cycle_ccolor();
init_some_tools();
for (;;)
	{
	check_input();
	if (RDN)
		{
		wait_rup();
		break;
		}
	if (!PDN)
		{
		if (connect_mode == DISTINCT)
			break;
		else 
			{
			if (connect_mode == CONNECTED)
				{
				firstx = lastx;
				firsty = lasty;
				}
			cycle_ccolor();
			wait_ednkey();
			if (key_hit)
				{
				reuse_input();
				break;
				}
			if (RDN)
				{
				wait_rup();
				break;
				}
			save_undo();
			}
		}
	if (mouse_moved)
		{
		if (connect_mode == CONCENTRIC)
			{
			firstx = mouse_x + 2*(cenx - mouse_x);
			firsty = mouse_y + 2*(ceny - mouse_y);
			}
		hide_mouse();
		unundo();
		swap_d_box();
		draw_d_box();
		show_mouse();
		update_screen();
		}
	}
uninit_some_tools();
}


refresh_zoom()
{
if (zoom_flag)
	zbuf_to_screen();
}

update_zoom()
{
if (mouse_moved)
	{
	refresh_zoom();
	}
}

maybe_see_buffer()
{
if (pscreen != cscreen)
	see_buffer();
}

see_buffer()
{
if (zoom_flag)
	zbuf_to_screen();
else
	{
	skip_beam();
	buf_to_screen();
	}
}

update_screen()
{
if (mouse_moved)
	see_buffer();
}

maybe_zoom()
{
if (zoom_flag)
	zbuf_to_screen();
}

