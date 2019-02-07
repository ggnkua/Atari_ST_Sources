
#include <gemdefs.h>
#include <osbind.h>
#include "flicker.h"

extern WORD *aline;
extern WORD handle;
extern long beam_peek();

WORD mouse_button, omouse_button;
WORD mouse_x, mouse_y;
WORD lastx, lasty;
WORD mouse_moved;	/* mouse not same as last time - x,y or buttons */
WORD key_hit;
long key_in;
WORD mouse_on = 1;

static WORD reuse;
static WORD lmousex = -1000, lmousey = -1000;  /* initialize offscreen */

reuse_input()
{
reuse = 1;
}

check_input()
{
register WORD *a;
unsigned long l;
unsigned WORD w;
WORD mouse_color;

if (reuse)
	{
	reuse = 0;
	return;
	}
a = aline;
lastx = mouse_x;
lasty = mouse_y;
omouse_button = mouse_button;
mouse_x = *(a-301);
mouse_y = *(a-300);
mouse_button = *(a-174);
if (Cconis())
	{
	key_hit = 1;
	l = Crawcin();
	w = l>>8;
	w += l;
	key_in = w;
	}
else
	key_hit = 0;
if (zscale_cursor)
	{
	mouse_x >>= 2;
	mouse_x += zoomx;
	mouse_y >>= 2;
	mouse_y += zoomy;
	}
if (mouse_x == lastx && mouse_y == lasty && mouse_button == omouse_button)
	mouse_moved = 0;
else
	mouse_moved = 1;
if (mouse_on)
	{
	if (mouse_moved)
		{
		wait_out_beam();
		restore_m();
		save_m();
		draw_m();
		}
	}
}

draw_m()
{
draw_shifted(mouse_x-8, mouse_y-8, oppositec[ getdot(mouse_x, mouse_y) ]);
}


hide_mouse()
{
if (mouse_on)
	{
	restore_m();
	mouse_on = 0;
	}
}

show_mouse()
{
if (!mouse_on)
	{
	save_m();
	draw_m();
	mouse_on = 1;
	}
}

ghide_mouse()
{
v_hide_c(handle, 0);
}

gshow_mouse()
{
v_show_c(handle, 0);
}


init_input()
{
ghide_mouse();
set_brush(0);
return(1);
}

wait_penup()
{
for (;;)
	{
	check_input();
	if (!PDN)
		break;
	}
}

wait_ednkey()
{
for (;;)
	{
	check_input();
	if (EDN || key_hit)
		break;
	}
}

wait_rup()
{
for (;;)
	{
	check_input();
	if (!RDN)
		break;
	}
}

