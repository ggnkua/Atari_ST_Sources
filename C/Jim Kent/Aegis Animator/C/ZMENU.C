
overlay "menu"

#include "..\\include\\lists.h"
#include "..\\include\\cursor.h"
#include "..\\include\\io.h"
#include "..\\include\\menu.h"
#include "..\\include\\control.h"
#include "..\\include\\format.h"

WORD perspective = 1;
WORD z_direction = 'u';

extern int see_slider(), do_slider(), text_in_box(), just_text();
extern int new_mode();


#ifdef SUN
#endif SUN



struct one_of persp_off =
	{
	&perspective,
	0,
	"off",
	};

struct one_of persp_on =
	{
	&perspective,
	1,
	"on",
	};

persp_on_off(m, sel, vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
new_mode(m, sel, vis);
draw_cur_frame(m);
}

struct one_of z_out =
	{
	&z_direction,
	'u',
	"out"
	};

struct one_of z_in =
	{
	&z_direction,
	'd',
	"in",
	};

struct selection meta_z_table[] = 
	{
	{
	3*S_WIDTH/2,1*S_HEIGHT,
	7*S_WIDTH/2, 2*S_HEIGHT,

	0,

	"perspective", FIRST_TIME,
	just_text,

	(char *)NULL, GO_SUB_REMENU,
	NULL,

	NO_DOUBLE,NO_DOUBLE,

	NULL, NO_HELP,
	},

	{
	3*S_WIDTH/2,2*S_HEIGHT,
	7*S_WIDTH/2, 3*S_HEIGHT,

	1,

	(char *)&persp_on,ONE_OF,
	just_text,

	(char *)NULL, GO_SUB_REMENU,
	persp_on_off,

	NO_DOUBLE,NO_DOUBLE,

	NULL, NO_HELP,
	},

	{
	3*S_WIDTH/2,3*S_HEIGHT,
	7*S_WIDTH/2, 4*S_HEIGHT,

	0,

	(char *)&persp_off,ONE_OF,
	just_text,

	NULL, GO_SUB_REMENU,
	persp_on_off,

	NO_DOUBLE,NO_DOUBLE,

	NULL, NO_HELP,
	},

	{
	10*S_WIDTH/2,1*S_HEIGHT,
	14*S_WIDTH/2, 2*S_HEIGHT,

	0,

	"direction", FIRST_TIME,
	just_text,

	NULL, GO_SUB_REMENU,
	NULL,

	NO_DOUBLE,NO_DOUBLE,

	NULL, NO_HELP,
	},

	{
	10*S_WIDTH/2,2*S_HEIGHT,
	14*S_WIDTH/2, 3*S_HEIGHT,

	0,

	(char *)&z_out,ONE_OF,
	just_text,

	NULL, GO_SUB_REMENU,
	new_mode,

	NO_DOUBLE,NO_DOUBLE,

	NULL, NO_HELP,
	},

	{
	10*S_WIDTH/2,3*S_HEIGHT,
	14*S_WIDTH/2, 4*S_HEIGHT,

	0,

	(char *)&z_in,ONE_OF,
	just_text,

	NULL, GO_SUB_REMENU,
	new_mode,

	NO_DOUBLE,NO_DOUBLE,

	NULL, NO_HELP,
	},
	};
	
struct menu meta_z_m =
	{
	1,
	1,
	0, 0,
	M_WIDTH, M_HEIGHT,
	sizeof(meta_z_table) / sizeof(struct selection),
	sizeof(meta_z_table) / sizeof(struct selection),
	meta_z_table,
	await_input,
	0,
	0,
	};

set_z_curs(sel)
struct selection *sel;
{
struct cursor *c;
if (z_direction == 'u')
	c = &out_cursor;
else
	c = &in_cursor;
((struct one_of *)(sel->display_data))->display_data =
	(char *)c;
}

/*this is called as a SUB_MENU */
meta_z(menu,sel,vis)
struct menu *menu;
struct selection *sel;
VIRTUAL_INPUT *vis;
{
struct control local_control;
extern struct cursor out_cursor, in_cursor;

local_control.m = &meta_z_m;
local_control.sel = NULL;
local_control.vis = vis;

#ifdef SUN
#endif SUN
copy_menu_offsets( menu, &meta_z_m);

draw_menu(&meta_z_m);
main_menu_driver(&local_control, NOSWAP_CONT);
clear_menu(&meta_z_m);

set_z_curs(sel);
}


