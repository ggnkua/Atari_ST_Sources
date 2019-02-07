/* Audio-Video Sequencer           */
/* Copyright 1988 Antic Publishing */
/* by Jim Kent                     */



#include "flicker.h"
#include "flicmenu.h"

sort_word(array, count, offset)
WORD **array;
WORD count;
register WORD offset;
{
register WORD **pt1, **pt2;
register WORD *swap;
register WORD swaps;
register WORD ct;

bee_cursor();
--count; /* since look at two elements at once...*/
swaps = 1;
while (swaps)
	{
	pt1 = array;
	pt2 = array + 1;
	ct = count;
	swaps = 0;
	while (--ct >= 0)
		{
		if ((*pt1)[offset] > (*pt2)[offset])
			{
			swaps = 1;
			swap = *pt1;
			*pt1 = *pt2;
			*pt2 = swap;
			}
		pt1++;
		pt2++;
		}
	}
cross_cursor();
}

qsort_tracks()
{
sort_word(tracks, TRACKS, 1);
hide_mouse();
redraw_frame();
show_mouse();
}

qseparate()
{
sort_word(tracks, TRACKS, 0);
hide_mouse();
redraw_frame();
show_mouse();
}

cat_sound_t(t)
struct track *t;
{
t->start = sound_ticks;
sound_ticks += t->duration;
if (sound_ticks > MAX_TICKS)
	sound_ticks = MAX_TICKS;
if (sound_ticks > time_ticks)
	time_ticks = sound_ticks;
}

cat_video_t(t)
struct track *t;
{
t->start = video_ticks;
video_ticks += t->duration;
if (video_ticks > MAX_TICKS)
	video_ticks = MAX_TICKS;
if (video_ticks > time_ticks)
	time_ticks = video_ticks;
}


qpackem(seq, sou)
WORD seq, sou;	/* whether to include seq track and sound track */
{
struct track *lt[TRACKS];
struct track *t;
int i;

copy_structure(tracks, lt, sizeof(lt) );
sort_word(lt, TRACKS, 1);
if (seq)
	video_ticks = 0;
if (sou)
	sound_ticks = 0;
time_ticks = 0;
for (i=0; i<TRACKS; i++)
	{
	t = lt[i];
	switch (t->type)
		{
		case TR_SEQ:
			if (seq)
				cat_video_t(t);
			break;
		case TR_SPL:
			if (sou)
				cat_sound_t(t);
			break;
		}
	}
hide_mouse();
redraw_frame();
show_mouse();
}

qpack_both()
{
qpackem(1, 1);
}

qpack_sound()
{
qpackem(0, 1);
}

qpack_video()
{
qpackem(1, 0);
}

