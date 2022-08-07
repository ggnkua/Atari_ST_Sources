
overlay "menu"

#include "..\\include\\lists.h"
#include "..\\include\\cursor.h"
#include "..\\include\\script.h"
#include "..\\include\\menu.h"
#include "..\\include\\control.h"
#include "..\\include\\format.h"
#include "..\\include\\io.h"
#include "..\\include\\animath.h"
#include "..\\include\\digitgau.h"
#include "..\\include\\replay.h"

extern struct cursor question_cursor;
extern int do_slider(), see_slider();
extern int see_nslider(), text_in_box(), just_text();
extern int just_int();
extern int new_mode();
extern snap_shot();
extern int split_tween();
extern struct cursor box_cursor;
extern struct cursor larrow_cursor, l2arrow_cursor, l3arrow_cursor;
extern struct cursor rarrow_cursor, r2arrow_cursor, r3arrow_cursor;
extern crude_help(), cin_color(), solid_block(), inverse_text();
extern hide_menu(), move_menu();
extern snap_back(), back_replay(), forwards_replay();

struct digit_gauge tween_gauge =
	{
	4,   /*digits*/
	1,   /*min */
	1,   /*value */
	1,   /*max */
	};

struct digit_gauge twtime_gauge =
	{
	4,
	1,
	200*6/20,
	1000*6/20,
	};

struct digit_gauge scspeed_gauge =
	{
	4,
	1,
	32,
	160,
	};

WORD see_beginning = 0;

struct slider click_sl =
	{
	"which tween", 30, 100,
	};

struct n_slider tween_sl = 
	{
	"tween time",999,199,199,
	};

struct n_slider clock_sl = 
	{
	"global speed",32*5,32,32,
	};

tm_snap_shot(m, sel, vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
skip_a_tween(cur_sequence);
init_times();
make_cur_frame(m);
}

tm_snap_back(m, sel, vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
snap_back(NULL, sel, vis);
init_times();
maybe_draw_menu(m);
}

back_replay(m, sel, vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
WORD osb;

osb = see_beginning;
see_beginning = 0;
adjust_pos_in_tween(cur_sequence);
see_beginning = osb;
grc_replay(NULL, sel, vis, REPLAY_START_END, 1);
init_times();
draw_menu(m);
}

forwards_replay(m, sel, vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
WORD osb;

osb = see_beginning;
see_beginning = 1;
adjust_pos_in_tween(cur_sequence);
see_beginning = osb;
grc_replay(NULL, sel, vis, REPLAY_START_END, 0);
init_times();
draw_menu(m);
}

init_times()
{
register Script *cs = cur_sequence;
register Tween *ct;

ct = *(cs->next_tween);
tween_sl.value = ct->tweening -  1;
twtime_gauge.value = (ct->tweening * 60L + 100)/200;
clock_sl.value = scspeed_gauge.value = cs->speed;
clock_sl.value -= 1;
click_sl.value = tween_gauge.value = cs->next_tween - cs->tween_list;
tween_gauge.value++;
click_sl.scale = tween_gauge.max =  cs->tween_count;
}


show_time(m, sel, vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
long time;
WORD minutes, seconds, clicks;
char *tstring;
extern char *lsprintf();

time = (cur_sequence->local_time<<5)/cur_sequence->speed;
minutes = time/(200*60);
time %= (200*60);
seconds = time/200;
time %= 200;
clicks = time*60/200;
tstring = lsprintf("%2d:%2d:%2d", minutes, seconds, clicks);
tr_string(tstring, ' ', '0');
strcpy(sel->display_data, tstring);
inverse_text(m, sel, vis);
}

static
xframe(next_frame, m)
WORD next_frame;
struct menu *m;
{
register Script *cs = cur_sequence;
WORD this_frame, i;

this_frame = cs->next_tween - cs->tween_list;
if (next_frame >= cs->tween_count)
	next_frame = cs->tween_count-1;
if (next_frame != this_frame)
	{
	if (next_frame < this_frame)
	{
	startup_sequence(cs);
	this_frame = 0;
	}
	for ( i=this_frame; i<next_frame; i++)
	{
	skip_a_tween(cs);
	}
	init_times();
	make_cur_frame(m);
	}
}

change_this_frame(m,sel,vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
do_digit_gauge(m,sel,vis);
xframe(tween_gauge.value-1, m);
}

slide_this_frame(m,sel,vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
do_slider(m,sel,vis);
xframe((WORD)click_sl.value, m);
}

redo_see_beginning(m, sel, vis,begin)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
WORD begin;
{
see_beginning = begin;
adjust_pos_in_tween(cur_sequence, begin);
make_cur_frame(m);
}

static
xcur_tween_time(time, m)
long time;
struct menu *m;
{
struct tween *tween;
long toff;

tween = *(cur_sequence->next_tween);
toff = time - tween->tweening;
tween->tweening = time;
fix_tween_times(cur_sequence);
initimes(cur_sequence);
if (see_beginning)
	{
	cur_sequence->to_next_tween = time;
	}
else
	{
	toff += cur_sequence->local_time;
	loop_around_script(cur_sequence);
	advance_timer(cur_sequence, toff, REPLAY_LOOP);
	}
init_times();
make_cur_frame(m);
}

redo_tween_time(m,sel,vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
do_slider(m,sel,vis);
xcur_tween_time(tween_sl.value+1, m);
}

dredo_tween_time(m, sel, vis)	/*digitally adjust tween time */
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
long time;

do_digit_gauge(m,sel,vis);
time = twtime_gauge.value;
time *= 200;
time += 30;
time /= 60;
xcur_tween_time( time, m);
}

redo_script_speed(m, sel, vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
do_slider(m,sel,vis);
cur_sequence->speed = clock_sl.value+1;
init_times();
draw_menu(m);
}

dredo_script_speed(m, sel, vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{

do_digit_gauge(m,sel,vis);
cur_sequence->speed = scspeed_gauge.value;
init_times();
draw_menu(m);
}


goto_end_script(m, sel, vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
WORD i;
register struct tween *tween, **end_tween;

end_tween = cur_sequence->tween_list + cur_sequence->tween_count - 1;

while ( cur_sequence->next_tween < end_tween)
	{
	skip_a_tween(cur_sequence);
	}
init_times();
make_cur_frame(m);
}

goto_begin_script(m, sel, vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
struct tween *tween;

startup_sequence(cur_sequence);
init_times();
make_cur_frame(m);
}

#include "timedata.c"


/*this is called as a SUB_MENU */
time_menu(menu,sel,vis)
struct menu *menu;
struct selection *sel;
VIRTUAL_INPUT *vis;
{
struct control local_control;

#ifdef DEBUG
lprintf("meta_camera()\n");
#endif DEBUG

show_help("time menu");
init_times();

local_control.m = &time_m;
local_control.sel = NULL;
local_control.vis = vis;

#ifdef SUN
#endif SUN
copy_menu_offsets(menu, &time_m);

time_m.visible = 1;
draw_menu(&time_m);
main_menu_driver(&local_control, NOSWAP_CONT);
clear_menu(&time_m);
copy_menu_offsets(&time_m, menu);

#ifdef AMIGA
maybe_disable_move();
#endif AMIGA
}


