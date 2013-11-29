
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

reuse_input()
{
reuse = 1;
}

check_zoom()
{
unsigned WORD w;

/* numeric keypad 1-9 moves about zoom */
if (key_hit && (key_in&0xf000)==0x6000)
	{
	w = (key_in & 0xff) - '1';
	if (w >= 0 && w <= 8)
		{
		switch (w%3)
			{
			case 0:
				zoomx -= 16;
				break;
			case 2:
				zoomx += 16;
				break;
			}
		switch (w/3)
			{
			case 0:
				zoomy += 16;
				break;
			case 2:
				zoomy -= 16;
				break;
			}
		clip_zoom();
		key_hit = 0;	/* don't pass key through, eat it */
		return(1);
		}
	}
return(0);
}

check_input()
{
unsigned WORD w;
register WORD *a;
unsigned long l;
WORD mouse_color;

if (reuse)
	{
	reuse = 0;
	return;
	}
lastx = mouse_x;
lasty = mouse_y;
a = aline;
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
	check_zoom();
	mouse_x >>= 2;
	mouse_x += zoomx;
	mouse_y >>= 2;
	mouse_y += zoomy;
	}
if (mouse_x == lastx && mouse_y == lasty && mouse_button == omouse_button)
	mouse_moved = 0;
else
	{
	mouse_moved = 1;
	}
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

#ifdef SLUFFED
hello_gem()
{
unsigned WORD mousex, mousey, button, keyboard, bclicks, ev_which;
unsigned long kreturn;
char message_buf[16];

ev_which =
evnt_multi( MU_KEYBD | MU_TIMER | MU_MESAG,
	0, 1, 1,
	0,
	0, 0, XMAX, YMAX,
	0, 0, 0, 0, 0,
	message_buf,
	50, 0,
	&mousex, &mousey,
	&button, &keyboard,
	&kreturn, &bclicks);
if (ev_which & MU_MESAG)
	flash_bg(0x700);
}
#endif SLUFFED

init_input()
{
ghide_mouse();
set_brush(0);
return(1);
}

wait_penup()
{
if (!PDN)
	return;
for (;;)
	{
	check_input();
	if (mouse_moved)
		maybe_see_buffer();
	if (!PDN)
		break;
	}
}

wait_click()
{
for (;;)
	{
	check_input();
	if (key_hit || PJSTDN || RJSTDN)
		break;
	}
}

wait_rkey()
{
for (;;)
	{
	check_input();
	if (key_hit || RJSTDN)
		break;
	}
}

wait_ednkey()
{
for (;;)
	{
	check_input();
	if (mouse_moved)
		maybe_see_buffer();
	if (EDN || key_hit)
		break;
	}
}

wait_rup()
{
if (!RDN)
	return;
for (;;)
	{
	check_input();
	if (mouse_moved)
		maybe_see_buffer();
	if (!RDN)
		break;
	}
}

