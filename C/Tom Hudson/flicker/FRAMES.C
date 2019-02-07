
#include "flicker.h"

extern long time_peek();

WORD screen_ix = 0;
WORD screen_ct = 1;
WORD *screens[MAX_SCREENS];

last_frame()
{
if (screen_ix > 0)
	{
	save_undo();
	--screen_ix;
	see_screen_ix();
	}
}

next_frame()
{
if (screen_ix < screen_ct - 1)
	{
	save_undo();
	screen_ix++;
	see_screen_ix();
	}
}

start_frame()
{
save_undo();
screen_ix = 0;
see_screen_ix();
}

end_frame()
{
save_undo();
screen_ix = screen_ct - 1;
see_screen_ix();
}

too_many_frames()
{
top_line("Too Many Frames");
}

outta_memory()
{
top_line("Out of Memory");
}


mnext_frame()
{
register WORD **myframe;
register WORD *frame;

if (screen_ct >= MAX_SCREENS)
	{
	too_many_frames();
	return;
	}
if (mem_free < 32000 + 8000)
	{
	outta_memory();
	return;
	}
if ((frame = alloc(32000)) == NULL)
	{
	outta_memory();
	return;
	}
save_undo();
myframe = screens+screen_ix+1;
copy_pointers(myframe, myframe+1, screen_ct - screen_ix - 1);
*myframe = frame;
copy_screen(cscreen, frame);
screen_ix++;
screen_ct++;
show_status();
}

mlast_frame()
{
register WORD **myframe;
register WORD *frame;

if (screen_ct >= MAX_SCREENS)
	{
	too_many_frames();
	return;
	}
if (mem_free < 32000 + 8000)
	{
	outta_memory();
	return;
	}
if ((frame = alloc(32000)) == NULL)
	{
	outta_memory();
	return;
	}
save_undo();
myframe = screens+screen_ix;
copy_pointers(myframe, myframe+1, screen_ct - screen_ix);
*myframe = frame;
copy_screen(cscreen, frame);
screen_ct++;
show_status();
}

delete_frame()
{
register WORD **myframe;

if (screen_ct == 1)
	{
	clear_pic();
	}
else
	{
	myframe = screens+screen_ix;
	mfree(*myframe, 32000);
	--screen_ct;
	copy_pointers(myframe+1, myframe, screen_ct - screen_ix);
	screens[screen_ct] = NULL;
	if (screen_ix == screen_ct)
		--screen_ix;
	see_screen_ix();
	}
}

play_slowly()	/* 2 frames/sec */
{
playit(30, 1);
}

play_forwards()	/* 6 frames/sec */
{
playit(10, 1);
}

play_backwards() /* -6 frames/sec */
{
playit(10, -1);
}

play_fast()		/* 15 frames/sec */
{
playit(4, 1);
}

playit(ticks, dir)
WORD ticks;
WORD dir;
{
register long desttime;

save_undo();
hide_mouse();
desttime = get60hz() + ticks;
for (;;)
	{
	screen_ix+=dir;
	if (screen_ix >= screen_ct)
		screen_ix = 0;
	if (screen_ix < 0)
		screen_ix = screen_ct-1;
	if (zoom_flag)
		{
		zoom(screens[screen_ix], pscreen, zoomx, zoomy);
		}
	else
		{
		skip_beam();
		copy_screen( screens[screen_ix], cscreen);
		}
	for (;;)
		{
		check_input();
		if (EDN || key_hit)
			goto nomore_play;
		if (get60hz() >= desttime)
			break;
		}
	desttime += ticks;
	}
nomore_play:
show_mouse();
see_screen_ix();
}

wait_a_jiffy(jiff)
WORD jiff;
{
register long desttime;

desttime = get60hz() + jiff;
while ( get60hz() < desttime)
	;
}


long
get60hz()
{
return( time_peek()*60/200);
}

