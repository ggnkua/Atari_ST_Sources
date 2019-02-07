/* Audio-Video Sequencer           */
/* Copyright 1988 Antic Publishing */
/* by Jim Kent                     */



#include "flicker.h"
#include "flicmenu.h"

struct track *xtrack;
struct track otrack;
struct tlib *xlib;
WORD xduration;

extern int mmsee_slider(), mmfeel_slider(),
	see_number_slider(), tfeel_number_slider(),
	left_arrow(), right_arrow(), tinc_slider(), tdec_slider(),
	return_yes(), return_no(), see_frame_text(), fat_frame_text(),
	ex_duration(), examine_rest(), ex_play(),
	black_block(), inverse_cursor(), wbtext(), wbnumber(), white_slice();

extern struct cursor cdown, cleft, cright, csleft,
	cinsert, cappend, cright2, cleft2, csright, cup;

extern char believe_menu;

extern examine_title();

struct flicmenu tcancel_sel =
	{
	NONEXT,
	NOCHILD,
	470+10*CH_WIDTH, 180,	8*CH_WIDTH, 14,
	"Cancel",
	see_frame_text,
	return_no,
	NOGROUP, 0,
	NOKEY,
	};
struct flicmenu tok_sel =
	{
	&tcancel_sel,
	NOCHILD,
	470+2*CH_WIDTH, 180,	6*CH_WIDTH, 14,
	"OK",
	fat_frame_text,
	return_yes,
	NOGROUP, 0,
	'\r',
	};
struct flicmenu tblackr_sel =
	{
	NONEXT,
	&tok_sel,
	463, 174,	640-463-2, 2*13-2,
	NOTEXT,
	black_block,
	NOFEEL,
	NOGROUP, 0,
	NOKEY,
	};
struct slidepot loops_sl =
	{
	0,
	99,
	0,
	};
extern struct flicmenu loops_sel;
struct flicmenu loops_1f4 = 
	{
	&tblackr_sel,
	NOCHILD,
	437, 187,	24, 11,
	(char *)&loops_sel,
	right_arrow,
	tinc_slider,
	NOGROUP, 0,
	NOKEY,
	};
struct flicmenu loops_sel = 
	{
	&loops_1f4,
	NOCHILD,
	109, 187,	326, 11,
	(char *)&loops_sl,
	see_number_slider,
	tfeel_number_slider,
	NOGROUP, 0,
	};
struct flicmenu loops_1f2 = 
	{
	&loops_sel,
	NOCHILD,
	83, 187,	24, 11,
	(char *)&loops_sel,
	left_arrow,
	tdec_slider,
	NOGROUP, 0,
	NOKEY,
	};

struct flicmenu loopstag_sel = 
	{
	&loops_1f2,
	NOCHILD,
	1, 187,	80, 11,
	"Loops",
	wbtext,
	NOFEEL,
	NOGROUP, 0,
	};


struct slidepot tspeed_sl =
	{
	-1,
	59,
	-1,
	};
extern struct flicmenu tspeed_sel;
struct flicmenu tspeed_1f4 = 
	{
	&loopstag_sel,
	NOCHILD,
	437, 174,	24, 11,
	(char *)&tspeed_sel,
	right_arrow,
	tinc_slider,
	NOGROUP, 0,
	NOKEY,
	};
struct flicmenu tspeed_sel = 
	{
	&tspeed_1f4,
	NOCHILD,
	109, 174,	326, 11,
	(char *)&tspeed_sl,
	see_number_slider,
	tfeel_number_slider,
	NOGROUP, 0,
	};
struct flicmenu tspeed_1f2 = 
	{
	&tspeed_sel,
	NOCHILD,
	83, 174,	24, 11,
	(char *)&tspeed_sel,
	left_arrow,
	tdec_slider,
	NOGROUP, 0,
	NOKEY,
	};

struct flicmenu tspeedtag_sel = 
	{
	&tspeed_1f2,
	NOCHILD,
	1, 174,	80, 11,
	"Speed",
	wbtext,
	NOFEEL,
	NOGROUP, 0,
	};

Flicmenu trest_sel =
	{
	&tspeedtag_sel,
	NOCHILD,
	36*CH_WIDTH+3, 161,	44*CH_WIDTH-7, 11,
	NOTEXT,
	examine_rest,
	ex_play,
	NOGROUP, 0,
	};
Flicmenu ttick_sel =
	{
	&trest_sel,
	NOCHILD,
	30*CH_WIDTH+2, 161,	CH_WIDTH*6, 11,
	NOTEXT,
	ex_duration,
	ex_play,
	NOGROUP, 0,
	};
char tnbuf[31];
Flicmenu tname_sel =
	{
	&ttick_sel,
	NOCHILD,
	1, 161,	30*CH_WIDTH, 11,
	tnbuf,
	wbtext,
	ex_play,
	NOGROUP, 0,
	};
Flicmenu examine_menu =
	{
	NONEXT,
	&tname_sel,
	0, 160,	XMAX-1, 3*13,
	NOTEXT,
	white_slice,
	NOFEEL,
	NOGROUP, 0,
	};

ex_play(m)
Flicmenu *m;
{
play_track(xtrack);
if (xtrack->type == TR_SEQ)
	{
	clear_screen();
	draw_a_menu(&examine_menu);
	}
show_mouse();
}

tinc_slider(m)
Flicmenu *m;
{
inc_slider(m);
update_ttick_sel();
}

tdec_slider(m)
Flicmenu *m;
{
dec_slider(m);
update_ttick_sel();
}

tfeel_number_slider(m)
Flicmenu *m;
{
feel_number_slider(m);
update_ttick_sel();
}

update_ttick_sel()
{
xtrack->loops = loops_sl.value+1;
xtrack->speed = tspeed_sl.value+1;
set_duration(xtrack);
draw_sel(&ttick_sel);
}

ex_duration(m)
Flicmenu *m;
{
char buf[16];

sprintf(buf, "%5ld", xtrack->duration);
m->text = buf;
wbtext(m);
}

examine_rest(m)
Flicmenu *m;
{
char buf[80];

if (xtrack->type == TR_SEQ)
	sprintf(buf, " ticks %6ld frames  %6ld bytes %2d links",
		xtrack->samples, xlib->bytes, xlib->links);
else
	sprintf(buf, " ticks %6ld samples %6ld bytes %2d links",
		xtrack->samples, xlib->bytes, xlib->links);
m->text = buf;
wbtext(m);
}

exam()
{
xtrack = tracks[track_ix];
if ((xlib = xtrack->lib) == NULL)
	return;
switch (xtrack->type)
	{
	case TR_SEQ:
		tspeed_sl.max = 59;
		break;
	case TR_SPL:
		tspeed_sl.max = 4;
		break;
	default:
		return;
	}
strncpy(tnbuf, xlib->name, sizeof(tnbuf)-1);
copy_structure(xtrack, &otrack, sizeof(otrack));
hide_mouse();
clear_screen();
loops_sl.value = xtrack->loops-1;
tspeed_sl.value = xtrack->speed-1;
draw_a_menu(&examine_menu);
do_menu(&examine_menu);
if (!believe_menu)
	copy_structure(&otrack, xtrack, sizeof(otrack));
}

qexamine()
{
top_message("Select track to examine...");
if (sel_track())
	{
	exam();
	}
hide_mouse();
redraw_frame();
show_mouse();
}
