/* Audio-Video Sequencer           */
/* Copyright 1988 Antic Publishing */
/* by Jim Kent                     */


#include "flicker.h"

int time_ticks;
int video_ticks;
int sound_ticks;

struct track track_buf[TRACKS];
struct track *tracks[TRACKS];
int track_ix;
int track_offset;

free_track(t)
struct track *t;
{
unlink_track(t );
t->type = TR_NONE;
t->start = BIG_SHORT;
}

clear_tracks()
{
int temp;

for (temp=0; temp<TRACKS; temp++)
	unlink_track(tracks[temp] );
for (temp=0; temp<TRACKS; temp++)
	{
	tracks[temp] = track_buf+temp;
	track_buf[temp].type = TR_NONE;
	track_buf[temp].start = BIG_SHORT;
	}
track_offset = 0;
}

which_t(y)
int y;
{
return( (y - TRACK_YOFF)/TRACK_HEIGHT + track_offset);
}

which_track()
{
return(which_t(mouse_y) );
}

sel_track()
{
wait_click();
if (PJSTDN)
	{
	track_ix = which_track();
	if (track_ix >= 0)
		return(1);
	}
return(0);
}

print_track_start(y, t, color)
int y;
register struct track *t;
int color;
{
char buf[8];

sprintf(buf, "%5d", t->start);
gtext(buf, NAME_END+CH_WIDTH, y+1, color);
}

print_track_end(y, t, color)
int y;
register struct track *t;
int color;
{
char buf[8];

sprintf(buf, "%5ld", t->start+t->duration);
gtext(buf, START_END+CH_WIDTH, y+1, color);
}

print_track_slider(y, t, color)
int y;
register struct track *t;
int color;
{
if (time_ticks > 0 && t->type != TR_NONE)
	{
	colblock(color, 
		TBAR_START+uscale_by(t->start, TBAR_WIDTH, time_ticks),
		y+2,
		TBAR_START+uscale_by(t->start+(int)t->duration, 
			TBAR_WIDTH, time_ticks)-1,
		y+8);
	}
}

dtrack(y, t)
int y;
register struct track *t;
{
int color;

switch (t->type)
	{
	case TR_SEQ:
		color = green;
		break;
	case TR_SPL:
		color = red;
		break;
	default:
		color = black;
		break;
	}
gtext(t->name, 1*CH_WIDTH, y+1, color);
print_track_start(y, t, color);
print_track_end(y, t, color);
print_track_slider(y, t, color);
}

tvlines(y, height)
int y, height;
{
height += y;

colblock(white, 0, y, 0, height);
colblock(white, NAME_END, y, NAME_END, height);
colblock(white, START_END, y, START_END, height);
colblock(white, STOP_END, y, STOP_END, height);
colblock(white, XMAX-1, y, XMAX-1, height);
}

track_yoff(ix)
int ix;
{
return(TRACK_YOFF+TRACK_HEIGHT*(ix-track_offset));
}

onscreen_track(ix)
int ix;
{
ix -= track_offset;
if (ix < 0 || ix >= TRACKS_SEEN)	/* don't draw it unless on screen */
	return(0);
return(1);
}

redraw_track(ix)
int ix;
{
register int y;

if (!onscreen_track(ix))
	return;
y = track_yoff(ix);
color_hslice(y, 11, black);
dtrack(y, tracks[ix]);
color_hslice(y+11, 1, white);
tvlines(y, TRACK_HEIGHT);
}

redraw_tracks()
{
int y;
int i;

y = TRACK_YOFF;
for (i=0; i<TRACKS_SEEN; i++)
	{
	color_hslice(y, 11, black);
	dtrack(y, tracks[i+track_offset]);
	color_hslice(y+11, 1, white);
	y += TRACK_HEIGHT;
	}
tvlines(TRACK_YOFF, TRACK_HEIGHT*TRACKS);
}

tik_pos()
{
int x;

x = sscale_by(mouse_x-TBAR_START, time_ticks, TBAR_WIDTH);
return(x);
}

