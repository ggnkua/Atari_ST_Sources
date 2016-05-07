
#include "flicker.h"
#include "flicmenu.h"

extern int see_menu_back(), text_toggle_group(), text_attr_box(),
	group_size_text(), get_cfont(), right_arrow(), left_arrow(),
	inc_points(), dec_points(), see_number_slider(), feel_number_slider(),
	white_block(), 
	change_point_size(), see_frame_text(), see_sample_text();

extern WORD got_cf;
WORD bold_mode;
struct text_attr bold_atr =
	{
	"Bold",
	1,
	};
WORD light_mode;
struct text_attr light_atr =
	{
	"Light",
	2,
	};
WORD italic_mode;
struct text_attr italic_atr =
	{
	"Italic",
	4,
	};
WORD underline_mode;
struct text_attr underline_atr =
	{
	"Underline",
	8,
	};
WORD outline_mode;
struct text_attr outline_atr =
	{
	"Outline",
	16,
	};
#ifdef SLUFFED
WORD shadow_mode;
struct text_attr shadow_atr =
	{
	"Shadow",
	32,
	};
#endif SLUFFED

struct text_attr load_atr =
	{
	"Custom",
	0,
	};

struct flicmenu sample_sel =
	{
	NONEXT,
	NOCHILD,
	8+12*8+14*8-4+22, 140+4, 12*8+4-22, 50,
	NOTEXT,
	see_sample_text,
	NOFEEL,
	NOGROUP, 1,
	};
struct flicmenu loadf_sel =
	{
	&sample_sel,
	NOCHILD,
	157, 181, 8*8+5, 14,
	(char *)&load_atr,
	text_attr_box,
	get_cfont,
	&got_cf, 1,
	};
struct slidepot points_sl =
	{
	3,
	99,
	5,
	};
extern struct flicmenu points_sel;
struct flicmenu points_1f4 = 
	{
	NONEXT,
	NOCHILD,
	136, 182,	12, 12,
	(char *)&points_sel,
	right_arrow,
	inc_points,
	NOGROUP, 0,
	NOKEY,
	};
struct flicmenu points_sel = 
	{
	&points_1f4,
	NOCHILD,
	22, 182,	112, 12,
	(char *)&points_sl,
	see_number_slider,
	change_point_size,
	NOGROUP, 0,
	};
struct flicmenu points_1f2 = 
	{
	&points_sel,
	NOCHILD,
	8, 182,	12, 12,
	(char *)&points_sel,
	left_arrow,
	dec_points,
	NOGROUP, 0,
	NOKEY,
	};
struct flicmenu points_mother =
	{
	&loadf_sel,
	&points_1f2,
	7,181, 142, 14,
	NULL,
	white_block,
	NOFEEL,
	NOGROUP, 0,
	NOKEY,
	};
struct flicmenu italic_sel =
	{
	&points_mother,
	NOCHILD,
	8+19*8-3, 140+3+20, 9*8-3, 13,
	(char *)&italic_atr,
	text_attr_box,
	text_toggle_group,
	&italic_mode,
	1,
	};
struct flicmenu light_sel =
	{
	&italic_sel,
	NOCHILD,
	8+9*8-2, 140+3+20, 9*8, 13,
	(char *)&light_atr,
	text_attr_box,
	text_toggle_group,
	&light_mode,
	1,
	};
struct flicmenu bold_sel =
	{
	&light_sel,
	NOCHILD,
	8-1, 140+3+20, 8*8, 13,
	(char *)&bold_atr,
	text_attr_box,
	text_toggle_group,
	&bold_mode,
	1,
	};
struct flicmenu underline_sel =
	{
	&bold_sel,
	NOCHILD,
	8+14*8-2, 140+3+1, 14*8-3, 13,
	(char *)&underline_atr,
	text_attr_box,
	text_toggle_group,
	&underline_mode,
	1,
	};
struct flicmenu outline_sel =
	{
	&underline_sel,
	NOCHILD,
	8-1, 140+3+1, 13*8, 13,
	(char *)&outline_atr,
	text_attr_box,
	text_toggle_group,
	&outline_mode,
	1,
	};
struct flicmenu text_menu = 
	{
	NONEXT,
	&outline_sel,
	0, 139,	319, 60,
	NOTEXT,
	see_menu_back,
	NOFEEL,
	NOGROUP, 0,
	};
