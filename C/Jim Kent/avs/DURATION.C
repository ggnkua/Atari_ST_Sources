/* Audio-Video Sequencer           */
/* Copyright 1988 Antic Publishing */
/* by Jim Kent                     */



#include "flicker.h"
#include "flicmenu.h"

extern int mmsee_slider(), mmfeel_slider(),
	see_number_slider(), dfeel_number_slider(),
	left_arrow(), right_arrow(), dinc_slider(), ddec_slider(),
	return_yes(), return_no(), see_frame_text(), fat_frame_text(),
	black_block(), inverse_cursor(), wbtext(), wbnumber(), white_slice();

extern struct cursor cdown, cleft, cright, csleft,
	cinsert, cappend, cright2, cleft2, csright, cup;

extern char believe_menu;

struct flicmenu dcancel_sel =
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
struct flicmenu dok_sel =
	{
	&dcancel_sel,
	NOCHILD,
	470+2*CH_WIDTH, 180,	6*CH_WIDTH, 14,
	"OK",
	fat_frame_text,
	return_yes,
	NOGROUP, 0,
	'\r',
	};
struct flicmenu tick_sel =
	{
	&dok_sel,
	NOCHILD,
	480+10*CH_WIDTH, 165,	5*CH_WIDTH, CH_HEIGHT,
	(char *)&time_ticks,
	wbnumber,
	NOFEEL,
	NOGROUP, 0,
	NOKEY,
	};
struct flicmenu ticktag_sel =
	{
	&tick_sel,
	NOCHILD,
	480+2*CH_WIDTH, 165,	7*CH_WIDTH, CH_HEIGHT,
	"ticks:",
	wbtext,
	NOFEEL,
	NOGROUP, 0,
	NOKEY,
	};
struct flicmenu dblackr_sel =
	{
	NONEXT,
	&ticktag_sel,
	463, 161,	640-463-2, 3*13-2,
	NOTEXT,
	black_block,
	NOFEEL,
	NOGROUP, 0,
	NOKEY,
	};
struct slidepot jiffies_sl =
	{
	-1,
	58,
	-1,
	};
extern struct flicmenu jiffies_sel;
struct flicmenu jiffies_1f4 = 
	{
	&dblackr_sel,
	NOCHILD,
	437, 187,	24, 11,
	(char *)&jiffies_sel,
	right_arrow,
	dinc_slider,
	NOGROUP, 0,
	NOKEY,
	};
struct flicmenu jiffies_sel = 
	{
	&jiffies_1f4,
	NOCHILD,
	109, 187,	326, 11,
	(char *)&jiffies_sl,
	see_number_slider,
	dfeel_number_slider,
	NOGROUP, 0,
	};
struct flicmenu jiffies_1f2 = 
	{
	&jiffies_sel,
	NOCHILD,
	83, 187,	24, 11,
	(char *)&jiffies_sel,
	left_arrow,
	ddec_slider,
	NOGROUP, 0,
	NOKEY,
	};

struct flicmenu jiffiestag_sel = 
	{
	&jiffies_1f2,
	NOCHILD,
	1, 187,	80, 11,
	"Jiffies",
	wbtext,
	NOFEEL,
	NOGROUP, 0,
	};


struct slidepot seconds_sl =
	{
	-1,
	58,
	-1,
	};
extern struct flicmenu seconds_sel;
struct flicmenu seconds_1f4 = 
	{
	&jiffiestag_sel,
	NOCHILD,
	437, 174,	24, 11,
	(char *)&seconds_sel,
	right_arrow,
	dinc_slider,
	NOGROUP, 0,
	NOKEY,
	};
struct flicmenu seconds_sel = 
	{
	&seconds_1f4,
	NOCHILD,
	109, 174,	326, 11,
	(char *)&seconds_sl,
	see_number_slider,
	dfeel_number_slider,
	NOGROUP, 0,
	};
struct flicmenu seconds_1f2 = 
	{
	&seconds_sel,
	NOCHILD,
	83, 174,	24, 11,
	(char *)&seconds_sel,
	left_arrow,
	ddec_slider,
	NOGROUP, 0,
	NOKEY,
	};

struct flicmenu secondstag_sel = 
	{
	&seconds_1f2,
	NOCHILD,
	1, 174,	80, 11,
	"Seconds",
	wbtext,
	NOFEEL,
	NOGROUP, 0,
	};

struct slidepot minutes_sl =
	{
	-1,
	4,
	-1,
	};
extern struct flicmenu minutes_sel;
struct flicmenu minutes_1f4 = 
	{
	&secondstag_sel,
	NOCHILD,
	437, 161,	24, 11,
	(char *)&minutes_sel,
	right_arrow,
	dinc_slider,
	NOGROUP, 0,
	NOKEY,
	};
struct flicmenu minutes_sel = 
	{
	&minutes_1f4,
	NOCHILD,
	109, 161,	326, 11,
	(char *)&minutes_sl,
	see_number_slider,
	dfeel_number_slider,
	NOGROUP, 0,
	};
struct flicmenu minutes_1f2 = 
	{
	&minutes_sel,
	NOCHILD,
	83, 161,	24, 11,
	(char *)&minutes_sel,
	left_arrow,
	ddec_slider,
	NOGROUP, 0,
	NOKEY,
	};

struct flicmenu minutestag_sel = 
	{
	&minutes_1f2,
	NOCHILD,
	1, 161,	80, 11,
	"Minutes",
	wbtext,
	NOFEEL,
	NOGROUP, 0,
	};

struct flicmenu duration_menu = 
	{
	NONEXT,
	&minutestag_sel,
	0, 160,	XMAX-1, 3*13,
	NOTEXT,
	white_slice,
	NOFEEL,
	NOGROUP, 0,
	};

dinc_slider(m)
Flicmenu *m;
{
inc_slider(m);
update_tick_sel();
}

ddec_slider(m)
Flicmenu *m;
{
dec_slider(m);
update_tick_sel();
}

dfeel_number_slider(m)
Flicmenu *m;
{
feel_number_slider(m);
update_tick_sel();
}

update_tick_sel()
{
calc_time_ticks();
draw_sel(&tick_sel);
}

calc_time_ticks()
{
int m, s, j;

time_ticks = (minutes_sl.value+1)*3600 + (seconds_sl.value+1)*60 + 
	jiffies_sl.value+1;
}

qduration()
{
int oticks, t, m, s, j;

oticks = time_ticks;

/* set up time sliders from time_ticks */
t = time_ticks;
m = t/3600;
t -= m*3600;
s = t/60;
t -= s*60;
j = t;
minutes_sl.value = m-1;
seconds_sl.value = s-1;
jiffies_sl.value = j-1;

hide_mouse();
clear_under_menu();
top_message("Set how long it will take to play through once:");
draw_a_menu(&duration_menu);
do_menu(&duration_menu);
if (!believe_menu)
	time_ticks = oticks;
hide_mouse();
redraw_frame();
show_mouse();
}


