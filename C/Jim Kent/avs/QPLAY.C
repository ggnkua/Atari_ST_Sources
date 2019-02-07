/* Audio-Video Sequencer           */
/* Copyright 1988 Antic Publishing */
/* by Jim Kent                     */



#include <osbind.h>
#include "flicker.h"

extern just_sound(), aniwait();

play_seq_track(t)
struct track *t;
{
struct tlib *tl;
int i, j;
long time, t2;
WORD *d;
struct seq_lib *s;

if ((tl = t->lib) == NULL)
	return;
if ((s = tl->image) == NULL)
	return;
Setscreen(-1L, -1L, 0);	/* change to lo res */
copy_screen(s->first_frame, pscreen);
time = get60hz() + t->speed;
for (i=0; i<s->frames_read; i++)
	{
	check_input();
	if (key_hit)
		break;
	if (d = s->deltas[i])
		{
		Setpallete(d);
		do_deltas(d, pscreen);
		}
	for (;;)
		{
		t2 = get60hz();
		if (t2 >= time)
			{
			time = t2+t->speed;
			break;
			}
		Vsync();
		}
	}
Setscreen(-1L, -1L, 1);	/* change to medium res */
Setpallete(sys_cmap);
}

qplay_track()
{
struct track *t;

top_message("Select track to play...");
if (sel_track())
	{
	t = tracks[track_ix];
	play_track(t);
	if (t->type == TR_SEQ)
		redraw_frame();
	else
		refresh_pull();
	}
else
	{
	hide_mouse();
	refresh_pull();
	}
show_mouse();
}

qplay_imm()
{
struct track *t;

track_ix = which_track();
if (track_ix >= 0)
	{
	t = tracks[track_ix];
	play_track(t);
	if (t->type == TR_SEQ)
		redraw_frame();
	show_mouse();
	}
}


play_track(t)
struct track *t;
{
hide_mouse();
switch (t->type)
	{
	case TR_SEQ:
		play_seq_track(t);
		break;
	case TR_SPL:
		play_spl_track(t);
		break;
	}
}

struct vparams
	{
	long start_time;
	WORD **deltas;
	long dcount;
	int	speed;
	int	loops;
	WORD *frame1;
	};

struct vparams vlist[TRACKS+1];

struct sparams
	{
	long start_time;
	char *samples;
	long scount;
	int speed;
	int loops;
	};

struct sparams slist[TRACKS+2];

play_spl_track(t)
struct track *t;
{
struct tlib *tl;
struct sparams *s;
struct vparams *v;

if ((tl = t->lib) == NULL)
	return;
listen(0, just_sound, tl->image, tl->samples, (long)t->speed);
}

play(loops)
int loops;
{
struct track *t, *strack;
struct tlib	*slib, *vlib;
struct seq_lib *sq;
int i;
struct vparams *v;
struct sparams *s;
int vi, si;
struct track *lt[TRACKS];
static char zero_buf[256];

copy_structure(tracks, lt, sizeof(lt) );
sort_word(lt, TRACKS, 1);
s = slist;	/*start off with a zero sample... this is a horrible
		kludge, but gets the keyboard to not fuck up if no sound
		at first */
s->start_time = 0;
s->samples = zero_buf;
s->scount = sizeof(zero_buf);
s->speed = 0;
s->loops = BIG_SHORT;
si = 1;
for (i=0; i<TRACKS; i++)
	{
	t = lt[i];
	if (t->type == TR_SPL)
		{
		slib = t->lib;
		s = slist+si;
		si++;
		s->start_time = t->start;
		s->samples = slib->image;
		s->scount = slib->samples;
		s->speed = t->speed;
		s->loops = t->loops;
		}
	}
s = slist+si;
s->start_time = time_ticks;
s->samples = NULL;
vi = 0;
for (i=0; i<TRACKS; i++)
	{
	t = lt[i];
	if (t->type == TR_SEQ)
		{
		vlib = t->lib;
		sq = vlib->image;
		v = vlist+vi;
		vi++;
		v->start_time = t->start;
		v->deltas = sq->deltas;
		v->dcount = sq->frames_read;
		v->speed = t->speed;
		v->loops = t->loops;
		v->frame1 = sq->first_frame;
		}
	}
v = vlist+vi;
v->start_time = time_ticks;
v->deltas = NULL;
hide_mouse();
Setscreen(-1L, -1L, 0);	/* change to lo res */
for (;;)
	{
	listen(1, aniwait, slist, vlist, pscreen);
	if (!loops)
		break;
	for (;;)	/* suck up keyboard input, break on escape */
		{
		wait_a_jiffy(2);	/* give keyboard interrupts chance to happen */
		check_input();
		if (key_hit)
			{
			if ((key_in&0xff) == 0x1b)	/* escape */
				goto OUT;
			}
		else
			break;
		}
	}
OUT:
Setscreen(-1L, -1L, 1);	/* change to medium res */
Setpallete(sys_cmap);
redraw_frame();
show_mouse();
}

qplay()
{
play(0);
}

qplay_loop()
{
play(1);
}


