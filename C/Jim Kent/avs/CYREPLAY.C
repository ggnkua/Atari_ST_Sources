/* Audio-Video Sequencer           */
/* Copyright 1988 Antic Publishing */
/* by Jim Kent                     */

#include "flicker.h"
#include "flicmenu.h"
#include <ctype.h>

extern Pull root_pull;
extern struct tlib * get_tlib();

Pull *cur_pull;
Flicmenu *cur_menu;


char keep_path = 1;


main()
{
int temp;

if (!init_sys())
	{
	uninit_sys();
	exit(0);
	}
cur_pull = &root_pull;
clear_tracks();
hide_mouse();
redraw_frame();
show_mouse();
for (;;)
	{
	check_input();
	if (key_hit)
		{
		main_key();
		}
	else if (in_pblock(0, 0, cur_pull) )
		{
		reuse_input();
		pull();
		if (pull_hit)
			{
			sel_main_pull();
			}
		}
	else if (PJSTDN || RJSTDN)
		{
		track_ix = which_track();
		if (track_ix >= 0)
			{
			if (mouse_x < NAME_END)
				{
				if (PJSTDN)
					load_seq();
				else
					load_spl();
				}
			else if (mouse_x < START_END)
				{
				if (PJSTDN)
					temp = tracks[track_ix]->start-1;
				else
					temp = tracks[track_ix]->start-10;
				if (temp < 0)
					temp = 0;
				tracks[track_ix]->start = temp;
				hide_mouse();
				redraw_track(track_ix);
				show_mouse();
				}
			else if (mouse_x < STOP_END)
				{
				if (PJSTDN)
					temp = tracks[track_ix]->start+1;
				else
					temp = tracks[track_ix]->start+10;
				if (temp >= time_ticks)
					temp = time_ticks-1;
				tracks[track_ix]->start = temp;
				hide_mouse();
				redraw_track(track_ix);
				show_mouse();
				}
			else
				{
				if (PJSTDN)
					move_track();
				else
					{
					exam();
					hide_mouse();
					redraw_frame();
					show_mouse();
					}
				}
			}
		}
	}
uninit_sys();
}

quit()
{
uninit_sys();
exit(0);
}

top_message(message)
char *message;
{
hide_mouse();
color_hslice(0, 9, black);
gtext(message, 0, 0, white);
show_mouse();
}



clear_under_menu()
{
color_hslice(10, YMAX-10, black);
}

refresh_pull()
{
paint_pull(0, 0, cur_pull);
}

redraw_frame()
{
char buf[16];

refresh_pull();
color_hslice(10, 21, black);
gtext("NAME", 2*CH_WIDTH, 20, white);
gtext("START",14*CH_WIDTH, 20, white);
gtext("STOP", 22*CH_WIDTH, 20, white);
gtext("TIME POSITION", 40*CH_WIDTH, 20, white);
sprintf(buf, "%5d TICKS", time_ticks);
gtext(buf, 69*CH_WIDTH, 20, white);
color_hslice(31, 1, white);
redraw_tracks();
}

move_track()
{
int x, y;
struct track *t;
int color;
char buf[8];

if (time_ticks <= 0)
	return;
t = tracks[track_ix];
switch (t->type)
	{
	case TR_SEQ:
		color = green;
		break;
	case TR_SPL:
		color = red;
		break;
	default:
		return;
	}
for (;;)
	{
	if (mouse_moved)
		{
		x = tik_pos(mouse_x);
		if (x + t->duration >= time_ticks)
			x = time_ticks - t->duration - 1;
		if (x < 0)
			x = 0;
		if (t->start != x)
			{
			y = track_yoff(track_ix);
			hide_mouse();
			print_track_slider(y, t, black);	/* erase old slider position */
			t->start = x;
			print_track_start(y, t, color);
			print_track_end(y, t, color);
			print_track_slider(y, t, color);	/* erase old slider position */
			show_mouse();
			}
		}
	check_input();
	if (!PDN)
		break;
	}
}


sel_main_pull()
{
switch (menu_ix)
	{
	case 0:	/* CyReplay */
		switch (sel_ix)
			{
			case 0: /* about */
				qabout();
				break;
			case 2: /* load */
				qload();
				break;
			case 3: /* play */
				qplay();
				break;
			case 4:	/* play loop */
				qplay_loop();
				break;
			case 5: /* save */
				qsave();
				break;
			case 6: /* memory */
				qmemory();
				break;
			case 7:	/* clear all */
				qclear();
				break;
			case 8:	/* quit */
				qquit();
				break;
			}
		break;
	case 1:	/* Track */
		switch (sel_ix)
			{
			case 0:	/* play track */
				qplay_track();
				break;
			case 1:	/* load cyber */
				qload_video();
				break;
			case 2: /* load replay */
				qload_sound();
				break;
			case 3:	/* examine */
				qexamine();
				break;
			case 4: /* kill */
				qkill();
				break;
			}
		break;
	case 2:	/* block */
		switch (sel_ix)
			{
			case 0:	/* Capture */
				qcapture_block();
				break;
			case 1:	/* Cut	*/
				qcut_block();
				break;
			case 2:	/* Paste */
				qpaste_block();
				break;
			case 3:	/* Insert */
				qinsert_block();
				break;
			case 4: /* Delete */
				qdelete_block();
				break;
			case 5:	/* Free Block */
				qfree_block();
				break;
			case 6: /* Load Block */
				qload_block();
				break;
			}
		break;
	case 3:	/* time */
		switch (sel_ix)
			{
			case 0:	/* Duration */
				qduration();
				break;
			case 1:	/* Pack Video */
				qpack_video();
				break;
			case 2:	/* Pack Sound */
				qpack_sound();
				break;
			case 3: /* Pack Both */
				qpack_both();
				break;
			case 4:	/* Sort Tracks */
				qsort_tracks();
				break;
			case 5:	/* Separate */
				qseparate();
				break;
			}
		break;
	case 4:	/* window */
		switch (sel_ix)
			{
			case 0:	/* down line */
				qinc_win();
				break;
			case 1: /* up line */
				qdec_win();
				break;
			case 2:	/* down page */
				qpageinc();
				break;
			case 3:	/* up page */
				qpagedec();
				break;
			}
		break;
	}
}

arrow_keys()
{
unsigned char c;

c = key_in;
if (isupper(c))
	c = _tolower(c);
if (c == 0)
	{
	c = key_in>>8;
	switch (c)
		{
		case 0x48:	/* up arrow */
			qdec_win();
			break;
		case 0x50: /* down arrow */
			qinc_win();
			break;
		case 0x4b:	/* left arrow */
			qpagedec();
			break;
		case 0x4d:	/* right arrow */
			qpageinc();
			break;
		}
	}
}

main_key()
{
unsigned char c;

arrow_keys();
c = key_in;
if (isupper(c))
	c = _tolower(c);
if (c == 0)
	{
	c = key_in>>8;
	switch (c)
		{
		case 0x47: /* clr/home */
			qclear();
			break;
		}
	}
else
	{
	switch (c)
		{
		case 'l':
			qload();
			break;
		case 's':
			qsave();
			break;
		case 'm':
			qmemory();
			break;
		case 'q':
			qquit();
			break;
		case 'k':
			qkill();
			break;
		case '<':
			qseparate();
			break;
		case '>':
			qsort_tracks();
			break;
		case 'r':
			qload_sound();
			break;
		case 'c':
			qload_video();
			break;
		case 'd':
			qduration();
			break;
		case 'x':
			qexamine();
			break;
		case '?':
			qplay_track();
			break;
		case 'p':
			qplay();
			break;
		case '\r':
			qplay_loop();
			break;
		case ' ':
			qplay_imm();
			break;
		case '*':	/* Capture */
			qcapture_block();
			break;
		case '-':	/* Cut	*/
			qcut_block();
			break;
		case '+':	/* Paste */
			qpaste_block();
			break;
		case 0x7f:	/* delete */
			qdelete_block();
			break;
		case 0x52: /* insert */
			qinsert_block();
			break;
		case 'b':
			qload_block();
			break;
		}
	}
}

outta_memory()
{
continu_line("Out of Memory!");
}


qquit()
{
if (yes_no_line("Quit Audio-Video Sequencer?"))
	quit();
}

char *
qfile(hail, suffix)
char *hail, *suffix;
{
char *title;

set_for_gem();
hide_mouse();
clear_screen();
gtext(hail, 0, 0, white);
show_mouse();
title = get_fname(suffix);
set_for_jim();
return(title);
}

qload_sound()
{
top_message("Select track to load with STReplay Sample");
wait_click();
if (PJSTDN)
	{
	track_ix = which_track();
	if (track_ix >= 0)
		load_spl();
	}
hide_mouse();
refresh_pull();
show_mouse();
}

qload_video()
{
top_message("Select track to load with Cyber Sequence");
wait_click();
if (PJSTDN)
	{
	track_ix = which_track();
	if (track_ix >= 0)
		load_seq();
	}
hide_mouse();
refresh_pull();
show_mouse();
}


qkill()
{
struct track *t;

top_message("Select track to delete...");
if (sel_track())
	{
	t = tracks[track_ix];
	free_track(t);
	hide_mouse();
	redraw_track(track_ix);
	}
hide_mouse();
refresh_pull();
show_mouse();
}

load_seq()
{
char *title;
struct track *t;
struct tlib *tl;

if (title = qfile("Load Cyber Sequence", "SEQ"))
	{
	t = tracks[track_ix];
	free_track(t);
	if (tl = get_tlib(title, TR_SEQ) )
		{
		attatch_tlib(t, tl, tbuf);
		cat_video_t(t);
		}
	}
hide_mouse();
redraw_frame();
show_mouse();
}

load_spl()
{
char *title;
struct track *t;
struct tlib *tl;

if (title = qfile("Load STReplay Sample", "SPL"))
	{
	t = tracks[track_ix];
	free_track(t);
	if (tl = get_tlib(title, TR_SPL) )
		{
		attatch_tlib(t, tl, tbuf);
		cat_sound_t(t);
		}
	}
hide_mouse();
redraw_frame();
show_mouse();
}

clear_ticks()
{
sound_ticks = video_ticks = time_ticks = 0;
}

qclear()
{
if (yes_no_line("Clear all video and sound tracks from memory?"))
	{
	clear_tracks();
	clear_ticks();
	hide_mouse();
	redraw_frame();
	show_mouse();
	}
}

qinc_win()
{
char *c;

if (track_offset + TRACKS_SEEN < TRACKS)
	{
	track_offset++;
	hide_mouse();
	c = (char *)cscreen;
	c += (TRACK_YOFF+1)*Raster_line(XMAX);
	copy_lots(c+TRACK_HEIGHT*Raster_line(XMAX), c, 
		((long)(TRACKS_SEEN-1)*TRACK_HEIGHT-2)*Raster_line(XMAX) );
	redraw_track(track_offset+TRACKS_SEEN-1);
	show_mouse();
	}
}

qpageinc()
{
if (track_offset + TRACKS_SEEN < TRACKS)
	{
	track_offset += TRACKS_SEEN;
	if (track_offset + TRACKS_SEEN > TRACKS)
		track_offset = TRACKS-TRACKS_SEEN;
	hide_mouse();
	redraw_frame();
	show_mouse();
	}
}

qpagedec()
{
if (track_offset > 0)
	{
	track_offset -= TRACKS_SEEN;
	if (track_offset < 0)
		track_offset = 0;
	hide_mouse();
	redraw_frame();
	show_mouse();
	}
}

qdec_win()
{
char *c;

if (track_offset > 0)
	{
	--track_offset;
	hide_mouse();
	c = (char *)cscreen;
	c += (TRACK_YOFF+1)*Raster_line(XMAX);
	copy_lots(c, c+TRACK_HEIGHT*Raster_line(XMAX), 
		((long)(TRACKS_SEEN-1)*TRACK_HEIGHT-2)*Raster_line(XMAX) );
	redraw_track(track_offset);
	show_mouse();
	}
}

