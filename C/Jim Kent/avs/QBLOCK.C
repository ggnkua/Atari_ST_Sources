/* Audio-Video Sequencer           */
/* Copyright 1988 Antic Publishing */
/* by Jim Kent                     */


#include "flicker.h"

extern char *qfile();

struct track *block_buf;
int block_count;

int lowest_b()
{
struct track *t;
int i, lo;


if ((t = block_buf) == NULL)
	return(0);
i = block_count;
lo = t->start;
t++;
while (--i > 0)
	{
	if (t->start < lo)
		lo = t->start;
	}
return(lo);
}

free_block()
{
int i;
struct track *t;

if ((t = block_buf) != NULL)
	{
	i = block_count;
	while (--block_count >= 0)
		{
		unlink_track(t++);
		}
	freemem(block_buf);
	block_buf = NULL;
	block_count = 0;
	}
}

qfree_block()
{
if (yes_no_line("Free Block Memory?") )
	free_block();
}

qload_block()
{
int i;
struct track **btracks;

if (cyr_name("Load .AVS file into block"))
	{
	free_block();
	if ((btracks = begmem(TRACKS*sizeof(*btracks) )) == NULL)
		goto OUT;
	if ((block_buf = begzeros(TRACKS*sizeof(*block_buf))) == NULL)
		{
		freemem(btracks);
		goto OUT;
		}
	for (i=0; i<TRACKS; i++)
		{
		btracks[i] = block_buf+i;
		block_buf[i].type = TR_NONE;
		block_buf[i].start = BIG_SHORT;
		}
	block_count = qld(btracks);
	freemem(btracks);
	}
OUT:
hide_mouse();
redraw_frame();
show_mouse();
}

snip_block(start, count)
int start, count;
{
struct track **s;
register struct track *d;
struct tlib *tl;

free_block();
if ((d = begmem(count*sizeof(*d))) == NULL)
	return(0);
block_buf = d;
block_count = count;
s = tracks + start;
while (--count >= 0)
	{
	copy_structure(*s++, d, sizeof(*d) );
	if ((tl = d->lib) != NULL)
		tl->links++;
	d++;
	}
return(1);
}

int x1, y1, x2, y2, x0, y0, dx, dy;
int tr1, tr2, tr0, dtr;
int tik1, tik2, tik0, dtik;

arrow_wait()
{
for (;;)
	{
	check_input();
	if (key_hit)
		arrow_keys();
	if (RJSTDN)
		return(0);
	if (PJSTDN)
		return(1);
	}
}

define_block()
{
top_message("Select start of block...");
if (!arrow_wait())
	return(0);
x1 = mouse_x;
y1 = mouse_y;
tr1 = which_t(mouse_y);
if (tr1 < 0)
	return(0);
tik1 = tik_pos(mouse_x);

top_message("Select end of block...");
if (!arrow_wait())
	return(0);
x2 = mouse_x;
y2 = mouse_y;
tr2 = which_t(mouse_y);
if (tr2 < 0)
	return(0);
tik2 = tik_pos(mouse_x);

tik0 = tik1;
if (x1 < x2)
	{
	x0 = x1;
	dx = x2 - x1;
	dtik = tik2 - tik1;
	}
else
	{
	x0 = x2;
	dx = x1 - x2;
	tik0 = tik2;
	dtik = 0;
	}
if (y1 < y2)
	{
	y0 = y1;
	dy = y2 - y1;
	tr0 = tr1;
	dtr = tr2 - tr1;
	}
else
	{
	y0 = y2;
	dy = y1 - y2;
	tr0 = tr2;
	dtr = tr1 - tr2;
	}
return(1);
}

qcapture_block()
{
capture_block();
hide_mouse();
refresh_pull();
show_mouse();
}

capture_block()
{
int t1, t2, swap;

if (define_block())
	{
	if (snip_block( tr0, dtr+1))
		return(1);
	}
return(0);
}

erase_block_pos()
{
int i;

for (i=tr0; i<=tr0+dtr; i++)
	{
	free_track(tracks[i]);
	hide_mouse();
	redraw_track(i);
	}
}

qcut_block()
{
if (capture_block())
	{
	erase_block_pos();
	}
hide_mouse();
refresh_pull();
show_mouse();
}


add_toff_t(t, off)
struct track *t;
int off;
{
t->start += off;
if (t->start < 0)
	t->start = 0;
}

qpb()
{
int i, dtr, tik, toff;
struct track *t;

top_message("Click on start of where to paste block...");
wait_click();
if (!PJSTDN)
	{
	return;
	}
dtr = which_t(mouse_y);
if (dtr < 0)
	{
	return(0);
	}
tik = tik_pos(mouse_x);
if (tik < 0)
	tik = 0;
toff = tik - lowest_b();
t = block_buf;
hide_mouse();
for (i=dtr; i<block_count+dtr && i < TRACKS; i++)
	{
	free_track(tracks[i]);
	copy_structure(t, tracks[i], sizeof(*t) );
	if (t->lib != NULL)
		{
		t->lib->links++;
		add_toff_t(tracks[i], toff);
		}
	redraw_track(i);
	t++;
	}
}

qpaste_block()
{
qpb();
hide_mouse();
refresh_pull();
show_mouse();
}

qdelete_block()
{
int i;
struct track *t;
struct track **tbuf, **tt;

if (define_block())
	{
	if ((tbuf = begmem((dtr+1)*sizeof(*tbuf))) != NULL)
		{
		for (i=tr0; i<=tr0+dtr; i++)	/* mark tracks as free and save them */
			{
			t = tracks[i];
			free_track(t);
			tbuf[i-tr0] = t;
			}
		for (i=tr0; i<TRACKS - dtr - 1; i++)	/* move tracks after block up */
			{
			tracks[i] = tracks[i+dtr+1];
			}
		tt = tbuf;
		for (i=TRACKS-dtr-1; i<TRACKS; i++)	/* put deleted tracks at end */
			{
			tracks[i] = *tt++;
			}
		for (i=0; i<TRACKS; i++)	/* add time offset of deleted block to
									later blocks */
			{
			t = tracks[i];
			if (t->start >= tik0)
				add_toff_t(t, -dtik);
			}
		freemem(tbuf);
		time_ticks -= dtik;
		sound_ticks -= dtik;
		video_ticks -= dtik;
		}
	}
hide_mouse();
redraw_frame();
show_mouse();
}


qinsert_block()
{
int i;
struct track *t;
struct track **tbuf, **tt;

if (define_block())
	{
	for (i=TRACKS-dtr-1; i<TRACKS; i++)	/* see if would kill tracks at end*/
		{
		t = tracks[i];
		if (t->type != TR_NONE)	/* if any let user say NO! */
			{
			if (!yes_no_line("Delete tracks at end?") )
				goto OUT;
			}
		}
	if ((tbuf = begmem((dtr+1)*sizeof(*tbuf))) != NULL)
		{
		tt = tbuf;
						/* mark end tracks as free and save em*/
		for (i=TRACKS-dtr-1; i<TRACKS; i++)	
			{
			t = tracks[i];
			free_track(t);
			*tt++ = t;
			}
						/* move tracks */
		copy_pointers(tracks+tr0, tracks+tr0+dtr+1, TRACKS-tr0-dtr-1);
		tt = tbuf;
		for (i=tr0; i<=tr0+dtr; i++)	/* put free tracks in middle */
			{
			tracks[i] = *tt++;
			}
		for (i=0; i<TRACKS; i++)	/* add time offset of inserted block to
									later blocks */
			{
			t = tracks[i];
			if (t->start >= tik0)
				add_toff_t(t, dtik);
			}
		freemem(tbuf);
		time_ticks += dtik;
		sound_ticks = tik0;
		video_ticks = tik0;
		}
	}
OUT:
hide_mouse();
redraw_frame();
show_mouse();
}

