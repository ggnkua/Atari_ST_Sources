	
overlay "timer"
#include "..\\include\\lists.h"
#include "..\\include\\script.h"
#include "..\\include\\control.h"
#include "..\\include\\io.h"
#include "..\\include\\cursor.h"
#include "..\\include\\menu.h"  /* for slider */
#include "..\\include\\story.h"
#include "..\\include\\replay.h"
#include "..\\include\\clip.h"
#include <neo.h>
#include <osbind.h>
#include "..\\include\\splat.h"
#include "..\\include\\poly.h"
#include "..\\include\\color.h"

extern long real_time();
extern char *bbm_name;
extern WORD update_cm;

#ifdef EDITOR
WORD see_title_bar = 1;

status_line()
{
extern char *title;
extern long mem_free;
extern WORD in_story_mode;

if (in_story_mode)
	ldprintf("%ld bytes free", mem_free);
else
	ldprintf("%ld bytes free   tween %d of %d", mem_free,
		cur_sequence->next_tween - cur_sequence->tween_list + 1,
		cur_sequence->tween_count);
wait(1500);
}
#endif EDITOR

#ifdef EDITOR
extern struct n_slider tween_sl, clock_sl;
extern WORD s_mode;
#endif EDITOR

extern WORD see_beginning;
extern WORD ghost_mode;



#ifdef EDITOR
lreplay(m, sel, vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
WORD osb;

osb = see_beginning;
see_beginning = 1;
adjust_pos_in_tween(cur_sequence);
see_beginning = osb;
grc_replay(m, sel, vis, REPLAY_TWEEN, 0);
}

breplay(m, sel, vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
WORD osb;

osb = see_beginning;
see_beginning = 1;
adjust_pos_in_tween(cur_sequence);
see_beginning = osb;
grc_replay(m, sel, vis, REPLAY_LOOP, 0);
}
#endif EDITOR

replay_start_end(m, sel, vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
loop_around_script(cur_sequence);
grc_replay(m, sel, vis, REPLAY_START_END, 0);
}

grc_replay(m, sel, vis, stop_when, backwards)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
WORD stop_when;
WORD backwards;
{
register struct s_sequence *s = cur_sequence;
struct tween  *tween, **first_tween;
long last_time;
long this_time;
long toff;
struct cursor *cursor;
WORD stop;
WORD i;

#ifdef DEBUG
lprintf("grc_replay()\n");
#endif DEBUG


if (s && s->tween_count > 0 )
	{
#ifdef ATARI
	hide_mbar();
#endif ATARI
	first_tween = s->next_tween;
#ifdef EDITOR
	if (see_title_bar)
		{
#ifdef AMIGA
		extern long Iscreen;  /*please no massive amiga .h files ... */
		ShowTitle(Iscreen, (long)0);
#endif AMIGA
		switch(stop_when)
			{
			case REPLAY_TWEEN:
				cursor = &lreplay_cursor;
				break;
			case REPLAY_LOOP:
				cursor = NULL;
				break;
			case REPLAY_START_END:
				cursor = &breplay_cursor;
				break;
			}
		}
	else
		cursor = NULL;
	new_cursor(cursor);
#endif EDITOR
	tween = *first_tween;
	last_time = this_time = real_time();
	for(;;)
		{
		toff = (this_time - last_time);
		if (backwards)
			toff = -toff;

		if (s->tween_count)
			{
			stop = advance_timer(s,(toff*s->speed)>>5, stop_when);
			m_frame(s);
#ifdef ATARI
			wait_beam();
#endif ATARI
			see_seq(s);
			if (update_cm)
				{
				copy_structure(s->next_poly_list->cmap, usr_cmap,
				MAXCOL * sizeof(struct color_def) );
				put_cmap(usr_cmap, 0, MAXCOL);
				update_cm = 0;
				}
			}

		sync();

		last_time = this_time;
		this_time = real_time();
#ifdef ATARI
		if ( stop || sample_cancel())
			break;
#endif ATARI
#ifdef AMIGA
		if ( (vis->result  & CANCEL) || stop)
			break;
		if (vis->result & MENUPICKED)
			{
			reuse_input();
			break;
			}
#endif AMIGA
		}
#ifdef EDITOR
	desync();
	adjust_pos_in_tween(s);
	make_cur_frame(m);
#ifdef AMIGA
		{
		extern long Iscreen;  /*please no massive amiga .h files ... */
		if (see_title_bar)
			ShowTitle(Iscreen, (long)1);
		maybe_disable_move();
		}
#endif AMIGA
#endif EDITOR
	}
}


#ifdef EDITOR
snap_shot(m, sel, vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
struct tween *tween, *last_tween;

#ifdef DEBUG
lprintf("snap_shot()\n");
#endif DEBUG

if (cur_sequence->next_tween + 1 >= cur_sequence->tween_list
	+ cur_sequence->tween_count)
	{
	cur_sequence->tween_count++;
	cken_tweens(cur_sequence);
	tween = *(cur_sequence->next_tween+1);
	last_tween = *(cur_sequence->next_tween);
	tween->start_time = cur_sequence->local_time;
	tween->tweening = tween_sl.value;
	cur_sequence->duration = tween->stop_time = 
	tween->start_time + tween->tweening;
	copy_poly_list( last_tween->poly_list, tween->poly_list );
	end_frame( tween->poly_list, last_tween, cur_sequence);
	initimes(cur_sequence);
	}
skip_a_tween(cur_sequence);
make_cur_frame(m);
#ifdef AMIGA
maybe_disable_move();
#endif AMIGA
}

snap_back(m, sel, vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
struct tween *t;

if (cur_sequence->next_tween > cur_sequence->tween_list)
	{
	if (see_beginning)
	{
	t = *(cur_sequence->next_tween-1);
	}
	else
	{
	t = *(cur_sequence->next_tween);
	}
	advance_timer(cur_sequence, -(long)t->tweening, REPLAY_LOOP);
	make_cur_frame(m);
	}
}


skip_a_tween(s)
Script *s;
{
Tween *t;

if (cur_sequence->next_tween + 1 < cur_sequence->tween_list
	+ cur_sequence->tween_count)
	{
	if (see_beginning)
		{
		t = *(s->next_tween);
		}
	else
		{
		t = *(s->next_tween+1);
		}
	advance_timer(s, (long)t->tweening, REPLAY_LOOP);
	}
}

#ifdef SLUFFED
display_new_frame(m)
struct menu *m;
{
adjust_pos_in_tween(cur_sequence);
make_cur_frame(m);
}
#endif SLUFFED
#endif EDITOR

#ifdef LATER
wopen(name)
char *name;
{
int f;

if ((f = Fopen(name, 1)) < 0)
	f = Fcreate(name, 0);
return(f);
}

extern WORD *cscreen;

long
write_screen_box(f, sq)
int f;
Square *sq;
{
long length;
register long width;
register char *screen;
register WORD i;

screen = (char *)cscreen;
screen += sq->y*160 + (sq->x/16)*8;
i = sq->Y - sq->y;
width = sq->X - sq->x;
width /= 16;
width *= 8;
length = width * i;
while (--i >= 0)
	{
	if (Fwrite(f, width, screen) != width)
		return(-1);
	screen += 160;
	}
return(length);
}

save_seq(ss, trez, name)
Script *ss;
int trez;	/* 60ths between frames */
char *name;
{
struct neo_head nh;
struct seq_head sh;
struct seq_tab *tabs;
int tab_len;
char buf[80];
int i;
int fd;
int frames;
int len;
long time;
Square sq, lastsq;
long offset, length;
Tween *tween;

frames = script_duration(ss)/trez + 1;
tab_len = frames * sizeof(struct seq_tab);
tabs = (struct seq_tab *)alloc(tab_len);
if ((fd = wopen(name) ) < 0 )
	{
	couldnt_open(name);
	return(0);
	}
sh.type = SEQ_TYPE;
sh.length = 0;
sh.count = frames;
if ( Fwrite(fd, (long)sizeof(sh), &sh) != sizeof(sh) )
	{
	file_truncated(name);
	Fclose(fd);
	mfree(tabs, tab_len);
	return(0);
	}
for (i=0; i<frames; i++)
	{
	block_stuff(tabs[i].name, 0, sizeof( tabs[i].name) );
	strcpy(tabs[i].name, name);
	len = strlen(name);
	digits3(tabs[i].name + len - 3, i);
	tabs[i].length = 0;
	tabs[i].offset = 0;
	if (Fwrite(fd, (long)sizeof(struct seq_tab), &tabs[i]) != 
		sizeof(struct seq_tab) )
		{
		file_truncated(name);
		Fclose(fd);
		mfree(tabs, tab_len);
		return(0);
		} 
	}
startup_sequence(cur_sequence);
tween = *(cur_sequence->next_tween);
cur_sequence->since_last_tween = 0;
cur_sequence->to_next_tween = tween->tweening;
offset = sizeof(struct seq_head) + tab_len;
lastsq.x = lastsq.y = 0;
lastsq.X = 320;
lastsq.Y = 200;
if (bbm_name == NULL)
	{
	make_frame(cur_sequence);
	bbox_script(cur_sequence,&lastsq);
	}
for (i=0; i<frames; i++)
	{
	make_frame(cur_sequence);
	bbox_script(cur_sequence,&sq);
	box_union(&sq, &lastsq);
	allign_box(&lastsq);
	block_stuff(&nh, 0, sizeof(nh) );
	ani_to_atari_cmap( usr_cmap, nh.colormap,  MAXCOL);
	nh.type = -1;
	nh.xoff = lastsq.x;
	nh.yoff = lastsq.y;
	nh.width = lastsq.X - lastsq.x;
	nh.height = lastsq.Y - lastsq.y;
	nh.slide_time = trez * 60/200;	
	if (Fwrite(fd, (long)sizeof(nh), &nh) != sizeof(nh) )
		{
		file_truncated(name);
		Fclose(fd);
		mfree(tabs, tab_len);
		return(0);
		} 
	length = write_screen_box(fd, &lastsq);
	if (length < 0)
		{
		file_truncated(name);
		Fclose(fd);
		mfree(tabs, tab_len);
		return(0);
		} 
	length += 128;	/*neo header size */
	tabs[i].length = length;
	tabs[i].offset = offset;
	offset += length;
	copy_structure(&sq, &lastsq, sizeof(sq) );
	advance_timer(cur_sequence, (long)trez, REPLAY_START_END);
	}
Fseek((long)0, fd, 0);
sh.length = offset;
Fwrite( fd, (long)sizeof(sh), &sh);
Fwrite( fd, (long)tab_len, tabs);
Fclose(fd);
mfree(tabs, tab_len);
return(1);
}

allign_box(sq)
Square *sq;
{
sq->x = sq->x & 0xfff0;
sq->X = (sq->X+15)&0xfff0;
}

digits3(s, val)
char *s;
int val;
{
int x;

x = val/100;
val = val%100;
s[0] = x + '0';
x = val/10;
val = val%10;
s[1] = x + '0';
s[2] = val + '0';
}
#endif LATER
