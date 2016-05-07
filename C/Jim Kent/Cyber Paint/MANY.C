
#include "flicker.h"
#include "flicmenu.h"

char *am_lines[3] =
	{
	"Abort multi-frame rendering",
	NULL,
	NULL,
	};

abort_multi(so_far, total)
WORD so_far;
WORD total;
{
WORD ret;
char buf[40];

hide_mouse();
check_input();
if (RJSTDN || key_hit)
	{
	copy_screen(cscreen, uscreen);
	sprintf(buf, "on frame %d of %d?", so_far+1, total);
	am_lines[1] = buf;
	ret = yes_no_from(am_lines);
	hide_mouse();
	copy_screen(uscreen, cscreen);
	return(ret);
	}
return(0);
}

qdo_many(func, shy_of_last)
Vector func;
WORD shy_of_last;
{
WORD ret;
WORD otween;

hide_mouse();
copy_screen(cscreen, uscreen);
otween = tween_mode;
tween_mode = 0;
(*func)(1,1);
tween_mode = otween;
maybe_see_buffer();
show_mouse();
ret = over_many();
hide_mouse();
unundo();
if (!ret)
	{
	show_mouse();
	return(1);
	}
return(do_many_times(func, shy_of_last, 0));
}

doit_many_times(func, shy_of_last)
Vector func;
WORD shy_of_last;
{
if (!over_many())
	return(1);
return(do_many_times(func, shy_of_last, 0));
}


WORD many_direction;

do_many_times(func, shy_of_last, conly)
Vector func;
WORD shy_of_last;
WORD conly;	/* colors only gonna change... */
{
WORD start, end, count;
register WORD ds;
WORD i;
WORD oscreen_ix;
WORD x, y;
char mem = 1;

dirty_file = 1;
hide_mouse();
clean_ram_deltas(cscreen);
if (select_mode == 1)	/* over segment */
	{
	clip_trange();
	start = trange.v1-1;
	end = trange.v2-1;
	many_direction = ( start < end ? 1 : -1 );
	count  = ds = (end - start)*many_direction;
	count += 1;
	}
else
	{
	start = 0;
	count = ds = end = screen_ct;
	end -= 1;
	many_direction = 1;
	if (!shy_of_last)
		ds -= 1;
	}
oscreen_ix = screen_ix;
tseek(start, cscreen);
for (i=0; i<count; i++)
	{
	if (abort_multi(i, count))
		break;
	if (ds == 0)
		mem = (*func)(1, 1);
	else
		mem = (*func)((tween_mode ? i : ds), ds);
	if (!mem)
		break;
	refresh_zoom();
	if (conly)
		{
		copy_words(sys_cmap, ram_screens[screen_ix], COLORS);
		}
	else
		{
		if (!s_ram_deltas(cscreen))
			{
			mem = 0;
			break;
			}
		}
	screen_ix += many_direction;
	if (screen_ix < 0 || screen_ix >= screen_ct)
		{
		screen_ix -= many_direction;
		break;
		}
	if (many_direction > 0)
		advance_next_prev(cscreen);
	else
		retreat_next_prev(cscreen);
	qsee_frame(cscreen, many_direction);
	}
abs_tseek(oscreen_ix, cscreen);
copy_screen(cscreen, uscreen);
copy_screen(cscreen, bscreen);
refresh_zoom();
if (!mem)
	outta_memory();
show_mouse();
return(mem);
}

