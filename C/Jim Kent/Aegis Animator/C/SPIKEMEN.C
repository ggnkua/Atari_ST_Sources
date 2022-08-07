
overlay "menu"

#include "..\\include\\lists.h"
#include "..\\include\\menu.h"
#include "..\\include\\control.h"
#include "..\\include\\format.h"
#include "..\\include\\cursor.h"
#include "..\\include\\poly.h"
#include "..\\include\\io.h"
#include "..\\include\\drawmode.h"

WORD draw_mode = FREE_HAND;


WORD bop_mode = FILLED;


extern struct cursor question_cursor;

extern int crude_help();
extern int cin_color();
extern int see_slider(), do_slider(), text_in_box(), just_text();
extern int new_mode();


struct one_of free_hand_node =
	{
	&draw_mode,
	FREE_HAND,
	"free hand",
	};

struct one_of reg_poly_node =
	{
	&draw_mode,
	REG_POLY,
	"reg poly",
	};

struct one_of circle_node =
	{
	&draw_mode,
	CIRCLE,
	"circle",
	};


struct one_of filled_node =
	{
	&bop_mode,
	FILLED,
	"filled"
	};

struct one_of out_line_node =
	{
	&bop_mode,
	OUT_LINE,
	"out line",
	};

struct one_of just_line_node =
	{
	&bop_mode,
	JUST_LINE,
	"just line",
	};

struct one_of color_rect_node =
	{
	&draw_mode,
	BLOCK,
	"block",
	};

struct selection meta_sp_table[] = 
	{
	{
	3*S_WIDTH/2,2*S_HEIGHT/2 - S_HEIGHT/4,
	7*S_WIDTH/2, 4*S_HEIGHT/2 - S_HEIGHT/4,

	0,

	(char *)&filled_node, ONE_OF,
	just_text,

	(char *)NULL, GO_SUB_REMENU,
	new_mode,

	NO_DOUBLE,NO_DOUBLE,

	NULL, NO_HELP,
	},

	{
	3*S_WIDTH/2,4*S_HEIGHT/2 - S_HEIGHT/4,
	7*S_WIDTH/2, 6*S_HEIGHT/2 - S_HEIGHT/4,

	1,

	(char *)&out_line_node,ONE_OF,
	just_text,

	(char *)NULL, GO_SUB_REMENU,
	new_mode,

	NO_DOUBLE,NO_DOUBLE,

	NULL, NO_HELP,
	},

	{
	3*S_WIDTH/2,6*S_HEIGHT/2 - S_HEIGHT/4,
	7*S_WIDTH/2, 8*S_HEIGHT/2 - S_HEIGHT/4,

	0,

	(char *)&just_line_node,ONE_OF,
	just_text,

	NULL, GO_SUB_REMENU,
	new_mode,

	NO_DOUBLE,NO_DOUBLE,

	NULL, NO_HELP,
	},

	{
	3*S_WIDTH/2,8*S_HEIGHT/2 - S_HEIGHT/4,
	7*S_WIDTH/2, 10*S_HEIGHT/2 - S_HEIGHT/4,

	0,

	(char *)&color_rect_node,ONE_OF,
	just_text,

	NULL, GO_SUB_REMENU,
	new_mode,

	NO_DOUBLE,NO_DOUBLE,

	NULL, NO_HELP,
	},

	{
	10*S_WIDTH/2,1*S_HEIGHT - S_HEIGHT/4,
	14*S_WIDTH/2, 2*S_HEIGHT - S_HEIGHT/4,

	1,

	(char *)&free_hand_node,ONE_OF,
	just_text,

	NULL, GO_SUB_REMENU,
	new_mode,

	NO_DOUBLE,NO_DOUBLE,

	NULL, NO_HELP,
	},

	{
	10*S_WIDTH/2,2*S_HEIGHT - S_HEIGHT/4,
	14*S_WIDTH/2, 3*S_HEIGHT - S_HEIGHT/4,

	0,

	(char *)&reg_poly_node,ONE_OF,
	just_text,

	NULL, GO_SUB_REMENU,
	new_mode,

	NO_DOUBLE,NO_DOUBLE,

	NULL, NO_HELP,
	},

	{
	10*S_WIDTH/2,3*S_HEIGHT - S_HEIGHT/4,
	14*S_WIDTH/2, 4*S_HEIGHT - S_HEIGHT/4,

	0,

	(char *)&circle_node,ONE_OF,
	just_text,

	NULL, GO_SUB_REMENU,
	new_mode,

	NO_DOUBLE,NO_DOUBLE,

	NULL, NO_HELP,
	},

	};
	
struct menu meta_sp_m =
	{
	1,
	1,
	0, 0,
	M_WIDTH, M_HEIGHT,
	sizeof(meta_sp_table) / sizeof(struct selection),
	sizeof(meta_sp_table) / sizeof(struct selection),
	meta_sp_table,
	await_input,
	0,
	0,
	};


/*this is called as a SUB_MENU */
meta_spike(menu,sel,vis)
struct menu *menu;
struct selection *sel;
struct virtual_input *vis;
{
struct control local_control;

local_control.m = &meta_sp_m;
local_control.sel = NULL;
local_control.vis = vis;

#ifdef SUN
#endif SUN
copy_menu_offsets(menu, &meta_sp_m);


draw_menu(&meta_sp_m);
main_menu_driver(&local_control, NOSWAP_CONT);
clear_menu(&meta_sp_m);
}


