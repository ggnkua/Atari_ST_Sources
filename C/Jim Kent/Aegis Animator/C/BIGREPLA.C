
overlay "menu"

#include "..\\include\\lists.h"
#include "..\\include\\cursor.h"
#include "..\\include\\menu.h"
#include "..\\include\\control.h"
#include "..\\include\\format.h"
#include "..\\include\\io.h"

extern int see_nslider(), do_slider(), text_in_box(), just_text();
extern int new_mode();

extern struct selection meta_re_table[];

extern WORD ghost_mode;
extern struct cursor box_cursor;
extern crude_help(), cin_color(), solid_block();
extern hide_menu(), move_menu();
extern struct slider clock_sl;


struct one_of do_fills_node =
	{
	&ghost_mode,
	0,
	"do fills",
	};

struct one_of gh_mode_node =
	{
	&ghost_mode,
	1,
	"ghost mode",
	};

new_ghost_mode(m, sel, vis)
register struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
new_mode(m, sel, vis);
draw_cur_frame(m);
}

struct selection meta_re_table[] = 
	{
		{
		MARGIN, MARGIN,
		MARGIN + CHAR_HEIGHT, CHAR_HEIGHT,

		0,

		(char *) &box_cursor,FIRST_TIME,
		cin_color,

		NULL, RETURN_SOMETHING,
		hide_menu,

		NULL,NO_DOUBLE,

		NULL, NO_HELP,
		},

		{
		MARGIN + CHAR_HEIGHT + 1, MARGIN,
		M_WIDTH - MARGIN, CHAR_HEIGHT,

		0,

		(char *) 0,FIRST_TIME,
		solid_block,

		NULL, GO_SUB_REMENU,
		move_menu,

		NULL,NO_DOUBLE,

		NULL, NO_HELP,
		},

		{
		2*MARGIN,		 1*S_HEIGHT/2 + CHAR_HEIGHT,
		M_WIDTH-2*MARGIN, 2*S_HEIGHT/2 + CHAR_HEIGHT,

		1,

		(char *)&do_fills_node, ONE_OF,
		just_text,

		(char *)NULL, GO_SUB_REMENU,
		new_ghost_mode,

		NO_DOUBLE,NO_DOUBLE,

		NULL, NO_HELP,
		},

		{
		2*MARGIN,		 2*S_HEIGHT/2 + CHAR_HEIGHT,
		M_WIDTH-2*MARGIN, 3*S_HEIGHT/2 + CHAR_HEIGHT,

		0,

		(char *)&gh_mode_node, ONE_OF,
		just_text,

		(char *)NULL,GO_SUB_REMENU,
		new_ghost_mode,

		NO_DOUBLE,NO_DOUBLE,

		NULL, NO_HELP,
		},

		{
		8,		3*S_HEIGHT + CHAR_HEIGHT,
		M_WIDTH-8, 4*S_HEIGHT + CHAR_HEIGHT,

		0,

		(char *) &clock_sl,FIRST_TIME,
		see_nslider,

		(char *)&clock_sl,GO_SUBBER,
		do_slider,

		NO_DOUBLE,NO_DOUBLE,

		NULL, NO_HELP,
		},
	};
	
#define BIG_REPLAY_HEIGHT (9*S_HEIGHT/2 + CHAR_HEIGHT)
struct menu meta_re_m =
	{
	1,
	1,
	XMAX - M_WIDTH - 1, YMAX - BIG_REPLAY_HEIGHT - 1,
	M_WIDTH, BIG_REPLAY_HEIGHT,
	sizeof(meta_re_table) / sizeof(struct selection),
	sizeof(meta_re_table) / sizeof(struct selection),
	meta_re_table,
	await_input,
	0,
	0,
	};


/*this is called as a SUB_MENU */
meta_replay(menu,sel,vis)
register struct menu *menu;
struct selection *sel;
VIRTUAL_INPUT *vis;
{
struct control local_control;
register struct menu *mrmenu = &meta_re_m;

local_control.m = mrmenu;
local_control.sel = sel;
local_control.vis = vis;

copy_menu_offsets(menu, mrmenu);

meta_re_m.visible = 1;
draw_menu(mrmenu);
main_menu_driver(&local_control, NOSWAP_CONT);
clear_menu(mrmenu);

copy_menu_offsets(mrmenu, menu);
}


