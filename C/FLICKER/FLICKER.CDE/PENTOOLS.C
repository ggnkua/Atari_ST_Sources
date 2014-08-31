
#include "flicker.h"

WORD firstx, firsty;
WORD x_0, y_0, x_1, y_1;


draw()
{
save_undo();
mouse_on = 0;	/* take over cursor handling ourselves, not in check input */
				/* it's a mess of global variables, but should let us */
				/* scribble faster! */
for (;;)
	{
	if (mouse_moved)
		{
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
	}
mouse_on = 1;
}

drizzle()
{
register int i;
int xybuf[2];
register int wait;

/* make time delay twice as long for brushes as points */
if (brush_ix == 0)
	wait = 1;
else
	wait = 2;
save_undo();
mouse_on = 0;
while (PDN)
	{
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
int xybuf[2];

save_undo();
hide_mouse();
while (PDN)
	{
	polar(FastRand() + i, FastRand()&0x1f, xybuf);
	plot(xybuf[0] + mouse_x, xybuf[1] + mouse_y, ccolor);
	if (zoom_flag)
		zbuf_to_screen();
	i++;
	check_input();
	}
show_mouse();
maybe_zoom();
}

flood()
{
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
firstx = mouse_x;
firsty = mouse_y;
set_solid_line();
hide_mouse();
draw_on_buffer();
putdot(mouse_x, mouse_y, ccolor);
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

static
first_last()
{
line(firstx, firsty, lastx, lasty);
}

draw_line()
{
init_some_tools();
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
d_poly(0, 0);
}

draw_polygon()
{
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

draw_circle()
{
register int radius;

init_some_tools();
for (;;)
	{
	check_input();
	if (!PDN)
		break;
	if (mouse_moved)
		{
		radius = calc_distance(mouse_x, mouse_y, firstx, firsty);
		hide_mouse();
		unundo();
		if (filled_flag)
			disk(firstx, firsty, radius, ccolor);
		else
			circle(firstx, firsty, radius, ccolor);
		show_mouse();
		update_screen();
		}
	}
uninit_some_tools();
}

rays()
{
init_some_tools();
for (;;)
	{
	set_solid_line();
	while (PDN)
		{
		if (mouse_moved)
			{
			hide_mouse();
			first_mouse();
			show_mouse();
			update_screen();
			}
		check_input();
		}
	hide_mouse();			
	set_xor_line();			/* go into xor mode */
	first_mouse();			/* and leave up xor line and cursor */
	show_mouse();
	update_screen();
	for (;;)
		{
		check_input();
		if (EDN)	/* if button pushed either out of rays, or back to
						the pendown state */
			{
			hide_mouse();
			set_xor_line();			/* go into xor mode */
			first_last();
			show_mouse();
			update_screen();
			if (PDN)
				{
				break;
				}
			else
				{
				uninit_some_tools();
				return;
				}
			}
		if (mouse_moved)	/* if moved erase last xor line and put up new one*/
			{
			hide_mouse();	
			set_xor_line();			/* go into xor mode */
			first_last();
			first_mouse();
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
hline(mouse_y, 0, XMAX, white);
vline(mouse_x, 0, YMAX, white);
}

d_frame()
{
draw_frame(ccolor, x_0, y_0, x_1, y_1);
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

draw_box()
{
init_some_tools();
for (;;)
	{
	check_input();
	if (!PDN)
		break;
	if (mouse_moved)
		{
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

update_zoom()
{
if (zoom_flag && mouse_moved)
	{
	zbuf_to_screen();
	}
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

