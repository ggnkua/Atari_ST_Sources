
#include "flicker.h"
#include "flicmenu.h"

extern int mmsee_slider(), mmfeel_slider(),
	see_number_slider(), feel_number_slider(),
	left_arrow(), right_arrow(), inc_slider(), dec_slider(),
	inverse_cursor(), wbtext(), wbnumber(), white_slice();

extern struct cursor cdown, cleft, cright, csleft,
	cinsert, cappend, cright2, cleft2, csright, cup;

struct slidepot spread_sl =
	{
	0,
	99,
	31,
	};
extern struct flicmenu spread_sel;
struct flicmenu spread_1f4 = 
	{
	NONEXT,
	NOCHILD,
	306, 187,	12, 11,
	(char *)&spread_sel,
	right_arrow,
	inc_slider,
	NOGROUP, 0,
	NOKEY,
	};
struct flicmenu spread_sel = 
	{
	&spread_1f4,
	NOCHILD,
	97, 187,	207, 11,
	(char *)&spread_sl,
	see_number_slider,
	feel_number_slider,
	NOGROUP, 0,
	};
struct flicmenu spread_1f2 = 
	{
	&spread_sel,
	NOCHILD,
	83, 187,	12, 11,
	(char *)&spread_sel,
	left_arrow,
	dec_slider,
	NOGROUP, 0,
	NOKEY,
	};

struct flicmenu spreadtag_sel = 
	{
	&spread_1f2,
	NOCHILD,
	1, 187,	80, 11,
	"Spread",
	wbtext,
	NOFEEL,
	NOGROUP, 0,
	};

struct slidepot spray_sl =
	{
	0,
	99,
	98,
	};
extern struct flicmenu spray_sel;
struct flicmenu spray_1f4 = 
	{
	&spreadtag_sel,
	NOCHILD,
	306, 174,	12, 11,
	(char *)&spray_sel,
	right_arrow,
	inc_slider,
	NOGROUP, 0,
	NOKEY,
	};
struct flicmenu spray_sel = 
	{
	&spray_1f4,
	NOCHILD,
	97, 174,	207, 11,
	(char *)&spray_sl,
	see_number_slider,
	feel_number_slider,
	NOGROUP, 0,
	};
struct flicmenu spray_1f2 = 
	{
	&spray_sel,
	NOCHILD,
	83, 174,	12, 11,
	(char *)&spray_sel,
	left_arrow,
	dec_slider,
	NOGROUP, 0,
	NOKEY,
	};

struct flicmenu spraytag_sel = 
	{
	&spray_1f2,
	NOCHILD,
	1, 174,	80, 11,
	"Speed",
	wbtext,
	NOFEEL,
	NOGROUP, 0,
	};

struct flicmenu air_menu = 
	{
	NONEXT,
	&spraytag_sel,
	0, 173,	319, 2*11+4,
	NOTEXT,
	white_slice,
	NOFEEL,
	NOGROUP, 0,
	};

go_air()
{
hide_mouse();
draw_a_menu(&air_menu);
do_menu(&air_menu);
}

mair()
{
go_air();
erase_top_menu(&air_menu);
draw_a_menu(cur_menu);
}


