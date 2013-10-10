
#include <osbind.h>
#include "flicker.h"
#include "flicmenu.h"

extern Flicmenu mframe_sel, frames_sel;
extern Flicmenu color_menu, cefx_menu;
extern Flicmenu main_menu, menutime, rcolor_menu, 
	rcefx_menu, menu_save, text_menu;
extern Flicmenu supermove_menu;
extern WORD ccolor, pen_tool_group;
extern struct slidepot frame_sl;
extern struct slidepot speed_sl;
extern Pull *cur_pull;
extern Flicmenu *cur_menu;
extern WORD live_top, live_lines;
extern WORD ping_pong;
extern timebon(), timeboff();

show_sel_mode(m)
register Flicmenu *m;
{
register char *t;

switch (select_mode)
	{
	case 0:
		t = "f";
		break;
	case 1:
		t = "s";
		m->identity = 1;
		break;
	case 2:
		t = "a";
		m->identity = 2;
		break;
	}
m->text = t;
wbtext(m);
}

tog_sel_mode()
{
select_mode++;
if (select_mode > 2)
	select_mode = 0;
}

toggle_sel_mode(m)
Flicmenu *m;
{
tog_sel_mode();
hide_mouse();
draw_sel(m);
show_mouse();
}

mmsee_slider(m)
Flicmenu *m;
{
frame_sl.max = screen_ct-1;
frame_sl.value = screen_ix;
see_number_slider(m);
}

#ifdef SLUFFED
mmfeel_update(m)
Flicmenu *m;
{
amfeel_update(m);
}
#endif SLUFFED

seek_new(screen, new)
register WORD *screen;
register WORD new;
{
while (new >= screen_ct)
	new -= screen_ct;
while (new < 0)
	new += screen_ct;
while (new > screen_ix)
	{
	screen_ix++;
	ncsee_frame(screen, 1);
	}
while (new < screen_ix)
	{
	--screen_ix;
	ncsee_frame(screen, -1);
	}
put_cmap(ram_screens[screen_ix]);
}

amfeel_update(m)
Flicmenu *m;
{
WORD new;
struct slidepot *s;

s = (struct slidepot *)m->text;
new = slide_where(m);
if (new != s->value)
	{
	hide_mouse();
	seek_new(bscreen, new);
	s->value = new;
	if (!zoom_flag)
		mskip_beam();
	see_top_lines();
	see_number_slider(m);
	show_mouse();
	}
}

mmfeel_slider(m)
Flicmenu *m;
{
clean_ram_deltas(bscreen);
feelslide(m, amfeel_update);
update_next_prev(bscreen);
copy_screen(bscreen, uscreen);
sput_cmap();
}


erase_seg(ystart, lines)
WORD ystart, lines;
{
/* these 2 for line of background color had to put in for horizontal interrupt */
if (lines <= 0)
	return;
if (zoom_flag)
	{
	zoom_seg(ystart, lines);
	}
else
	copy_lines( bscreen+80*ystart, pscreen+80*ystart, 
		lines);
}

zoom_seg(ystart, lines)
WORD ystart, lines;
{
WORD mod, lstart;
WORD lzoomx;
WORD *saddr;
WORD *daddr;

saddr = bscreen+80*(ystart>>2);
daddr = pscreen+80*ystart;
mod = (ystart&3);
if (mod != 0)
	{
	lines -= mod;
	zoom_line(saddr, daddr, zoomx, zoomy);
	daddr += 80;
	while (--mod > 0)	/* loop mod-1 times */
		{
		copy_line(daddr-80, daddr);
		daddr += 80;
		}
	saddr += 80;
	}
zoom_lines(saddr, daddr, zoomx, zoomy, lines>>2);
saddr += (lines>>2)*80;
daddr += (lines&0xfffc)*80;
mod = (lines&3);
if (mod != 0)
	{
	zoom_line(saddr, daddr, zoomx, zoomy);
	while (--mod > 0)	/* loop mod-1 times */
		{
		daddr += 80;
		copy_line(daddr-80, daddr);
		}
	}
}

redraw_menu_frame()
{
set_top_lines();
see_pull(0, 0, cur_pull);
see_top_lines();
draw_a_menu(cur_menu);
}

see_top_lines()
{
erase_seg(live_top, live_lines);
}

clear_top_lines()
{
live_top = 0;
stripe2.height = live_lines = 200;
startclist = &stripe2;
nohblanks();
}

set_top_lines()
{
Pull *p;
Flicmenu *m;

if ((m = cur_menu) != NULL)
	{
	if (m == &color_menu)
		{
		m = m->children;
		stripe3.height = 15;
		}
	else if (m == &cefx_menu)
		{
		m = m->children;
		stripe3.height = 27;
		}
	else
		{
		stripe3.height = 255;
		}
	if ((p = cur_pull) != NULL)
		{
		stripe1.height = live_top = p->height;
		startclist = &stripe1;
		}
	else
		{
		live_top = 0;
		startclist = &stripe2;
		}
	live_lines = 198 - live_top - m->height;
	stripe2.height = live_lines;
	yeshblanks();
	}
else
	{
	clear_top_lines();
	}
}

mmsave_undo(m)
struct Flicmenu *m;
{
hide_mouse();
if (m != NULL)
	hilight(m);
clean_ram_deltas(bscreen);
hide_mouse();
}

mmsee_times(m)
struct Flicmenu *m;
{
if (m != NULL)
	draw_sel(m);
mmsee_slider(&mframe_sel);
draw_sel(&frames_sel);
show_mouse();
}

static Flicmenu *avs;

remain_adv_frame()
{
if (!zoom_flag)
	mskip_beam();
see_top_lines();
if (avs != NULL)
	draw_sel(avs);
}

adv_frame()
{
if (screen_ix < screen_ct - 1)
	{
	screen_ix++;
	advance_next_prev(bscreen);
	see_frame(bscreen, 1);
	remain_adv_frame();
	}
}

dec_frame()
{
if (screen_ix > 0)
	{
	--screen_ix;
	retreat_next_prev(bscreen);
	see_frame(bscreen, -1);
	remain_adv_frame();
	}
}

pdn_timeout(timeout)
WORD timeout;
{
long time1;

time1 = get60hz() + timeout;
for (;;)
	{
	check_input();
	if (!PDN)
		return(0);
	if (get60hz() >= time1)
		return(1);
	}
}


repeat_on_pdn(v)
Vector v;
{
WORD i;

(*v)();
if (!pdn_timeout(30))
	return;
i = 0;
for (;;)
	{
	(*v)();
	if (!pdn_timeout( i<10 ? 8 : 4) )
		return;
	i++;
	}
}

avd_frame(m, s, v)
Flicmenu *m;
Flicmenu *s;
Vector v;
{
mmsave_undo(m);
avs = s;
repeat_on_pdn(v);
if (m != NULL)
	draw_sel(m);
show_mouse();
}

amnext_frame(m, s)
Flicmenu *m;
Flicmenu *s;
{
avd_frame(m, s, adv_frame);
}

mmnext_frame(m)
Flicmenu *m;
{
amnext_frame(m, &mframe_sel);
}

amlast_frame(m, s)
Flicmenu *m;
Flicmenu *s;
{
avd_frame(m, s, dec_frame);
}

mmlast_frame(m)
Flicmenu *m;
{
amlast_frame(m, &mframe_sel);
}

mswap_undo()
{
hide_mouse();
exchange_screen(bscreen, uscreen);
see_top_lines();
show_mouse();
}


minsert(m)
Flicmenu *m;
{
ainsert(m);
mmsee_times(m);
}

ainsert(m)
Flicmenu *m;
{
mmsave_undo(m);
draw_on_buffer();
do_insert();
draw_on_screen();
}

add_ten()
{
hide_mouse();
clean_ram_deltas(cscreen);
add_empties_at_end(10);
update_next_prev(cscreen);
show_mouse();
}

aadd_ten(m, frames, frame)
Flicmenu *m;
Flicmenu *frames, *frame;
{
hide_mouse();
clean_ram_deltas(bscreen);
add_empties_at_end(10);
update_next_prev(bscreen);
draw_sel(m);
draw_sel(frames);
draw_sel(frame);
show_mouse();
}

madd_ten(m)
Flicmenu *m;
{
aadd_ten(m, &frames_sel, &mframe_sel);
}

mappend(m)
Flicmenu *m;
{
aappend(m);
mmsee_times(m);
}

aappend(m)
struct Flicmenu *m;
{
mmsave_undo(m);
draw_on_buffer();
do_append();
draw_on_screen();
}

mkill(m)
struct Flicmenu *m;
{
if (m != NULL)
	hilight(m);
querilous_delete(bscreen);
hide_mouse();
see_top_lines();
draw_sel(&frames_sel);
mmsee_times(m);
}



extern WORD pen_tool_group;

ago_first(m, slider)
Flicmenu *m;
Flicmenu *slider;
{
clean_ram_deltas(bscreen);
hide_mouse();
if (m != NULL)
	hilight(m);
copy_screen(start_screen, uscreen);
copy_screen(start_screen, bscreen);
screen_ix = 0;
put_cmap(ram_screens[screen_ix]);
see_top_lines();
if (m != NULL)
	draw_sel(m);
if (slider && slider->seeme)
	(*slider->seeme)(slider);
show_mouse();
update_next_prev(bscreen);
}

mgo_first(m)
struct Flicmenu *m;
{
ago_first(m, &mframe_sel);
}

ago_last(m, slider)
Flicmenu *m;
Flicmenu *slider;
{
clean_ram_deltas(bscreen);
hide_mouse();
if (m != NULL)
	hilight(m);
copy_screen(end_screen, uscreen);
copy_screen(end_screen, bscreen);
screen_ix = screen_ct-1;
put_cmap(ram_screens[screen_ix]);
see_top_lines();
if (m != NULL)
	draw_sel(m);
if (slider && slider->seeme)
	(*slider->seeme)(slider);
show_mouse();
update_next_prev(bscreen);
}

mgo_last(m)
Flicmenu *m;
{
ago_last(m, &mframe_sel);
}

aplay_az(m, slider, dir)
Flicmenu *m;
Flicmenu *slider;
WORD dir;
{
hide_mouse();
if (m != NULL)
	hilight(m);
mplayit(speed_sl.value+1, dir, slider);
if (m != NULL)
	draw_sel(m);
show_mouse();
}

aplay_forwards(m, slider)
Flicmenu *m;
Flicmenu *slider;
{
aplay_az(m, slider, 1);
}

mrewind(m)
Flicmenu *m;
{
arewind(m, &mframe_sel);
}

mfast_forward(m)
Flicmenu *m;
{
afast_forward(m, &mframe_sel);
}

mscratch()
{
msetup();
scratch();
mrecover();
}

mplay_forwards()
{
msetup();
play_forwards();
mrecover();
}

aplay_backwards(m, slider)
Flicmenu *m;
Flicmenu *slider;
{
aplay_az(m, slider, -1);
}

mplay_backwards()
{
msetup();
play_backwards();
mrecover();
}

#ifdef SLUFFED
mplay_slowly()
{
msetup();
play_slowly();
mrecover();
}

mplay_fast()
{
msetup();
play_fast();
mrecover();
}
#endif SLUFFED

see_frame(screen, dir)
WORD *screen;
WORD dir;
{
qsee_frame(screen, dir);
sput_cmap();
}

qsee_frame(screen, dir)
WORD *screen;
WORD dir;
{
ncsee_frame(screen, dir);
qput_cmap(ram_screens[screen_ix]);
}

ncsee_frame(screen, dir)
WORD *screen;
WORD dir;
{
if (screen_ix == 0)
	{
	copy_screen(start_screen, screen);
	do_deltas(ram_screens[0], screen);
	}
else if (screen_ix == screen_ct-1)
	{
	copy_screen(end_screen, screen);
	do_deltas(ram_screens[screen_ct], screen);
	}
else
	{
	if (dir > 0)
		do_deltas(ram_screens[screen_ix], screen);
	else
		do_deltas(ram_screens[screen_ix+1], screen);
	}
}



advance_next_prev(screen)
WORD *screen;
{
copy_screen(screen, prev_screen);
do_deltas(ram_screens[screen_ix+1], next_screen);
}

retreat_next_prev(screen)
WORD *screen;
{
copy_screen(screen, next_screen);
do_deltas(ram_screens[screen_ix], prev_screen);
}

mplayit(ticks, dir, slider)
WORD ticks;
WORD dir;
Flicmenu *slider;
{
register long desttime;
WORD startix, stopix;
WORD oscreenix;
WORD *first_screen;
WORD ozscale;

ozscale = zscale_cursor;
zscale_cursor = 1;
clean_ram_deltas(bscreen);	/* write back changes to this frame */
if (select_mode == 1)	/* to segment */
	{
	oscreenix = screen_ix;
	copy_screen(bscreen, prev_screen);
	clip_trange();
	if (trange.v1 > trange.v2)
		{
		startix = trange.v2-1;
		stopix = trange.v1-1;
		}
	else
		{
		startix = trange.v1-1;
		stopix = trange.v2-1;
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
	copy_screen(bscreen, uscreen);
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
	screen_ix+=dir;
	if (screen_ix > stopix)
		{
		if (ping_pong)
			{
			dir = -dir;
			screen_ix += dir;
			screen_ix += dir;
			ncsee_frame(bscreen, dir);
			}
		else
			{
			copy_screen(first_screen, bscreen);
			screen_ix = startix;
			}
		}
	else if (screen_ix < startix)
		{
		if (ping_pong)
			{
			dir = -dir;
			screen_ix += dir;
			screen_ix += dir;
			ncsee_frame(bscreen, dir);
			}
		else
			{
			copy_screen(first_screen, bscreen);
			screen_ix = stopix;
			}
		}
	else
		{
		ncsee_frame(bscreen, dir);
		}
	if (PDN)
		desttime += (ticks>>1);
	else
		desttime += ticks;
	/* display the buffer screen */
	if (!zoom_flag)
		{
		if (live_top)
			mskip_beam();
		else
			skip_beam();
		}
	qput_cmap(ram_screens[screen_ix]);
	see_top_lines();
	if (slider && slider->seeme)
		(*slider->seeme)(slider);

	}
nomore_play:
zscale_cursor = ozscale;
if (select_mode == 1)	/* to segment */
	{
	copy_screen(prev_screen, bscreen);
	screen_ix = oscreenix;
	qput_cmap(ram_screens[screen_ix]);
	see_top_lines();
	if (slider && slider->seeme)
		(*slider->seeme)(slider);
	}
copy_screen(bscreen, uscreen);
update_next_prev(bscreen);
sput_cmap();
}



#ifdef SLUFFED
mplayit(ticks, dir, slider)
WORD ticks;
WORD dir;
Flicmenu *slider;
{
register long desttime;

if (select_mode == 1)	/* to segment */
	{
	mplayseg(ticks, dir, slider);
	return;
	}
clean_ram_deltas(bscreen);
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
	qsee_frame(bscreen, dir);
	if (!zoom_flag)
		mskip_beam();
	see_top_lines();
	if (slider && slider->seeme)
		(*slider->seeme)(slider);
	for (;;)
		{
		check_input();
		if (RJSTDN || key_hit)
			goto nomore_play;
		if (get60hz() >= desttime)
			break;
		}
	if (PDN)
		desttime += (ticks>>1);
	else
		desttime += ticks;
	}
nomore_play:
copy_screen(bscreen, uscreen);
update_next_prev(bscreen);
sput_cmap();
}
#endif SLUFFED

msetup()
{
hide_mouse();
restore_menu();
wait_penup();
}

mrecover()
{
hide_mouse();
save_menu();
draw_a_menu(cur_menu);
see_pull(0, 0, cur_pull);
}

mcut()
{
msetup();
cut_clip();
mrecover();
}

mpaste()
{
msetup();
paste_clip();
mrecover();
}

mpaste_under()
{
msetup();
paste_under();
mrecover();
}

mmove()
{
msetup();
position_clip();
mrecover();
}


mclip()
{
msetup();
clip_clip();
mrecover();
}

mstretch()
{
msetup();
stretch_clip();
mrecover();
}

mrotate()
{
msetup();
rotate_clip();
mrecover();
}

mflip()
{
msetup();
flip_clip();
mrecover();
}

#ifdef SLUFFED
mblur()
{
msetup();
blur_clip();
mrecover();
}
#endif SLUFFED

mcfit()
{
msetup();
cfit_clip();
mrecover();
}

mmask_clip()
{
msetup();
mask_clip();
mrecover();
}


#ifdef SLUFFED
mmtime()
{
mtime();
hide_mouse();
erase_seg(menutime.y, main_menu.y - menutime.y);
show_mouse();
}
#endif SLUFFED

mtime()
{
go_time();
erase_top_menu(&menutime);
draw_a_menu(cur_menu);
}

mtext()
{
go_text();
erase_top_menu(&text_menu);
draw_a_menu(cur_menu);
}

msupermove()
{
supermove();
erase_top_menu(&supermove_menu);
draw_a_menu(cur_menu);
}

msave()
{
go_save();
erase_top_menu(&menu_save);
draw_a_menu(cur_menu);
}

mpalette()
{
go_colors();
erase_top_menu(&rcolor_menu);
draw_a_menu(cur_menu);
}

mcefx()
{
go_cefx();
erase_top_menu(&rcefx_menu);
draw_a_menu(cur_menu);
}

mpixelfx()
{
extern Flicmenu px_menu;

go_px();
erase_top_menu(&px_menu);
draw_a_menu(cur_menu);
}

