
#include "flicker.h"
#include "flicmenu.h"

extern long calc_dlt_size();
extern WORD *make_deltas();
extern WORD *make_literal_xor();
extern WORD *insert_to_ram_dlt();
extern WORD *expand2();

extern struct slidepot speed_sl;
extern struct range trange;

WORD ping_pong;
WORD start_frame, stop_frame, range_frames;
WORD screen_ix = 0;
WORD screen_ct = 1;
WORD *ram_screens[MAX_SCREENS+2];
WORD *ram_dlt;
WORD *ram_dlt_start;
long rd_alloc;
long rd_count;

clip_trange()
{
trange.max = screen_ct;
if (trange.v1 > screen_ct)
	trange.v1 = 1;
if (trange.v2 > screen_ct)
	trange.v2 = screen_ct;
}

all_start_stop()
{
start_frame = 0;
stop_frame = screen_ct-1;
range_frames = screen_ct;
}

frame_start_stop()
{
start_frame = stop_frame = screen_ix;
range_frames = 1;
}

range_start_stop()
{
clip_trange();
if (trange.v1 <= trange.v2)
	{
	start_frame = trange.v1;
	stop_frame = trange.v2;
	}
else
	{
	start_frame = trange.v2;
	stop_frame = trange.v1;
	}
start_frame-=1;
stop_frame-=1;
range_frames = stop_frame - start_frame + 1;
}

multi_start_stop()
{
if (select_mode == 1) /* range mode */
	range_start_stop();
else
	all_start_stop();
}

Vector fss_tab[] = { frame_start_stop, range_start_stop, all_start_stop };

find_start_stop()
{
(*fss_tab[select_mode])();
}

long
pt_to_long(pt)
long pt;
{
return(pt);
}

#ifdef SLUFFED
list_dlts()
{
int i;

for (i=0; i<= screen_ct; i++)
	{
	printf("%lx, ", ram_screens[i]);
	if ( (i&3) == 3)
		puts("");
	}
puts("");
}
#endif SLUFFED

zero_screens()
{
zero_screen(uscreen);
zero_screen(start_screen);
zero_screen(end_screen);
zero_screen(prev_screen);
zero_screen(next_screen);
}

make_end_screen()
{
register WORD **rscr;
WORD i;

copy_screen(start_screen, end_screen);
rscr = ram_screens;
i = screen_ct;
while (--i >= 0)
	do_deltas(*rscr++, end_screen);
}

last_frame()
{
if (screen_ix > 0)
	{
	hide_mouse();
	clean_ram_deltas(cscreen);
	screen_ix-=1;
	retreat_next_prev(cscreen);
	see_frame(cscreen, -1);
	save_undo();
	show_mouse();
	if (zoom_flag)
		zbuf_to_screen();
	}
}

next_frame()
{
if (screen_ix < screen_ct - 1)
	{
	hide_mouse();
	clean_ram_deltas(cscreen);
	screen_ix++;
	advance_next_prev(cscreen);
	see_frame(cscreen, 1);
	save_undo();
	show_mouse();
	if (zoom_flag)
		zbuf_to_screen();
	}
}

end_frame()
{
inc_frame(screen_ct-1);
}

jump_start_frame()
{
inc_frame(0);
}

inc_frame(frame)
WORD frame;
{
hide_mouse();
clean_ram_deltas(cscreen);
screen_ix = frame;
see_frame(cscreen, 1);
update_next_prev(cscreen);
save_undo();
show_mouse();
if (zoom_flag)
	zbuf_to_screen();
}

too_many_frames()
{
continu_line("Too Many Frames");
}

outta_memory()
{
continu_line("Out of Memory");
}


mnext_frame()
{
hide_mouse();
do_append();
show_mouse();
}

mlast_frame()
{
hide_mouse();
do_insert();
show_mouse();
}

tseek(new, screen)
WORD new;
WORD *screen;
{
if (new == 0 || new == screen_ct - 1)
	{
	screen_ix = new;
	see_frame(screen, 1);
	}
else
	{
	while (new > screen_ix)
		{
		screen_ix++;
		see_frame(screen, 1);
		}
	while (new < screen_ix)
		{
		--screen_ix;
		see_frame(screen, -1);
		}
	}
update_next_prev(screen);
}

abs_tseek(ix, screen)
WORD ix;
WORD *screen;
{
_abs_tseek(ix, screen);
screen_ix = ix;
update_next_prev(screen);
}

_abs_tseek(ix, screen)
WORD ix;
WORD *screen;
{
WORD i;

copy_screen(start_screen, screen);
for (i=0; i<= ix; i++)
	do_deltas(ram_screens[i], screen);
put_cmap(ram_screens[ix]);
}

really_delete_segment()
{
return(really_segment("Delete segment?", "  (no undo)"));
}

really_segment(what, line2)
char *what;
char *line2;
{
char *bufs[4];
char fbuf[40];

bufs[0] = what;
clip_trange();
sprintf(fbuf, "frames %d to %d", trange.v1, trange.v2);
bufs[1] = fbuf;
bufs[2] = line2;
bufs[3] = NULL;
return(yes_no_from(bufs) );
}

yes_no_2lines(line, line2)
char *line;
char *line2;
{
char *buf[3];

buf[0] = line;
buf[1] = line2;
buf[2] = NULL;
return(yes_no_from(buf));
}


querilous_delete(screen)
WORD *screen;
{
if (select_mode == 1)	/* over segment */
	{
	if (!really_delete_segment())
		return;
	delete_ram_range(screen);
	}
else
	{
	if (!yes_no_2lines("Delete this frame?", "    (no undo)"))
		return;
	delete_ram_frame(screen);
	}
copy_screen(screen, uscreen);
}

delete_frame()
{
hide_mouse();
querilous_delete(cscreen);
show_mouse();
}

play_forwards()	/* 6 frames/sec */
{
playit(speed_sl.value+1, 1);
}

play_backwards() /* -6 frames/sec */
{
playit(speed_sl.value+1, -1);
}

play_fast()		/* 60/2 = 30 frames/sec */
{
playit(0, 1);
}

play_fast_backwards()
{
playit(0, -1);
}


playit(ticks, dir)
WORD ticks;
WORD dir;
{
unzoom();
hide_mouse();
mplayit(ticks, dir, NULL);
show_mouse();
rezoom();
}

#ifdef SLUFFED
playit(ticks, dir, slider)
WORD ticks;
WORD dir;
Flicmenu *slider;
{
register long desttime;
WORD startix, stopix;
WORD oscreenix;
WORD *first_screen;

clean_ram_deltas(bscreen);	/* write back changes to this frame */
if (select_mode == 1)	/* to segment */
	{
	oscreenix = screen_ix;
	copy_screen(bscreen, prev_screen);
	clip_trange();
	if (trange.v1 > trange.v2)
		{
		startix = trange.v2+1;
		stopix = trange.v1+1;
		}
	else
		{
		startix = trange.v1+1;
		stopix = trange.v2+1;
		}
	if (dir > 0)
		{
		_abs_tseek(startix, bscreen);
		screen_ix = startix;
		}
	else
		{
		_abs_tseek(stopix, bscreen);
		screen_ix = stopix;
		}
	oscreenix = screen_ix;
	copy_screen(bscreen, uscreen);
	copy_screen(bscreen, prev_screen);
	first_screen = uscreen;
	}
else
	{
	if (dir > 0)
		{
		first_screen = start_screen;
		}
	else
		{
		first_screen = end_screen;
		}
	startix = 0;
	stopix = screen_ct-1;
	}

if (stopix - startix == 0)
	{
	see_top_lines();
	if (slider && slider->seeme)
		(*slider->seeme)(slider);
	wait_rkey();
	goto nomore_play;
	}
desttime = get60hz() + ticks;
for (;;)
	{
	/* wait until it's time for the next frame */
	for (;;)
		{
		check_input();
		if (RJSTDN || key_hit)
			goto nomore_play;
		if (get60hz() >= desttime)
			break;
		}
	/* display the buffer screen */
	if (!zoom_flag)
		mskip_beam();
	see_top_lines();
	if (slider && slider->seeme)
		(*slider->seeme)(slider);

	screen_ix+=dir;
	if (screen_ix > stopix)
		{
		if (ping_pong)
			{
			dir = -dir;
			screen_ix += dir;
			screen_ix += dir;
			qsee_frame(bscreen, dir);
			}
		else
			{
			copy_screen(uscreen, bscreen);
			screen_ix = startix;
			qput_cmap(ram_screens[screen_ix]);
			}
		}
	else if (screen_ix < startix)
		{
		if (ping_pong)
			{
			dir = -dir;
			screen_ix += dir;
			screen_ix += dir;
			qsee_frame(bscreen, dir);
			}
		else
			{
			copy_screen(uscreen, bscreen);
			screen_ix = stopix;
			qput_cmap(ram_screens[screen_ix]);
			}
		}
	else
		{
		qsee_frame(bscreen, dir);
		}
	if (PDN)
		desttime += (ticks>>1);
	else
		desttime += ticks;
	}
nomore_play:
if (select_mode == 1)	/* to segment */
	{
	copy_screen(prev_screen, bscreen);
	screen_ix = oscreenix;
	qput_cmap(ram_screens[screen_ix]);
	see_top_lines();
	copy_screen(bscreen, uscreen);
	if (slider && slider->seeme)
		(*slider->seeme)(slider);
	}
update_next_prev(bscreen);
copy_screen(bscreen, cscreen);
sput_cmap();
}

playit(ticks, dir)
WORD ticks;
WORD dir;
{
WORD d;
register long desttime;

save_undo();
hide_mouse();
clean_ram_deltas(cscreen);
if (!zoom_flag)
	copy_screen(cscreen, bscreen);
desttime = get60hz() + ticks;
for (;;)
	{
	screen_ix+=dir;
	if (screen_ix >= screen_ct)
		{
		if (ping_pong)
			{
			dir = -dir;
			screen_ix += dir;
			screen_ix += dir;
			}
		else
			screen_ix = 0;
		}
	if (screen_ix < 0)
		{
		if (ping_pong)
			{
			dir = -dir;
			screen_ix += dir;
			screen_ix += dir;
			}
		else
			screen_ix = screen_ct-1;
		}
	if (screen_ix == 0)
		{
		copy_screen(start_screen, bscreen);
		}
	else if (screen_ix == screen_ct-1)
		{
		copy_screen(end_screen, bscreen);
		}
	else
		{
		if (dir > 0)
			do_deltas(ram_screens[screen_ix], bscreen);
		else
			do_deltas(ram_screens[screen_ix+1], bscreen);
		}
	qput_cmap(ram_screens[screen_ix]);
	if (zoom_flag)
		{
		zoom(cscreen, pscreen, zoomx, zoomy);
		}
	else
		{
		if (ticks != 0)
			skip_beam();
		copy_screen(bscreen, pscreen);
		}
	for (;;)
		{
		check_input();
		if (RJSTDN || key_hit)
			goto outofit;
		if (get60hz() >= desttime)
			break;
		}
	if (PDN)
		desttime += (ticks>>1);
	else
		desttime += ticks;
	}
outofit:
update_next_prev(cscreen);
sput_cmap();
show_mouse();
}
#endif SLUFFED

scratch()
{
WORD new_screen_ix;

hide_mouse();
clean_ram_deltas(cscreen);
if (!zoom_flag)
	copy_screen(cscreen, bscreen);
mouse_moved = 1;	/* force screen update 1st go through */
for (;;)
	{
	if (RJSTDN)
		break;
	if (mouse_moved)
		{
		new_screen_ix = uscale_by(mouse_x, screen_ct, XMAX);
		if (new_screen_ix >= screen_ct)
			new_screen_ix = screen_ct;
		seek_new(bscreen, new_screen_ix);
		if (zoom_flag)
			{
			zoom(bscreen, pscreen, zoomx, zoomy);
			}
		else
			{
			skip_beam();
			copy_screen(bscreen, pscreen);
			}
		}
	check_input();
	}
copy_screen(bscreen, uscreen);
update_next_prev(cscreen);
}
