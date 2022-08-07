overlay "menu"

#include "..\\include\\lists.h"
#include "..\\include\\io.h"
#include "..\\include\\menu.h"
#include "..\\include\\control.h"
#include "..\\include\\format.h"
#include "..\\include\\cursor.h"

WORD rotate_axis = 'z';

#ifdef SUN
#endif SUN

extern int see_slider(), do_slider(), text_in_box(), just_text(), 
	   cursor_and_text();
extern int new_mode();



extern struct cursor rotate_cursor;
extern struct cursor zxrot_cursor;
extern struct cursor zyrot_cursor;

struct cursor_text ct_rip =
{
	&rotate_cursor,
	"in plane"
};

struct cursor_text ct_riy =
{
	&zxrot_cursor,
	"around y"
};

struct cursor_text ct_rix =
{
	&zyrot_cursor,
	"around x"
};

struct one_of rotate_in_plane =
{
	&rotate_axis,
	'z',
	(char *)&ct_rip
};

struct one_of roa_x =
{
	&rotate_axis,
	'x',
	(char *)&ct_rix
};

struct one_of roa_y =
{
	&rotate_axis,
	'y',
	(char *)&ct_riy
};

struct selection meta_ro_table[] = 
{
	{
	0,	1*S_HEIGHT,
	M_WIDTH, 2*S_HEIGHT,

	0,

	"axis", FIRST_TIME,
	just_text,

	(char *)NULL, GO_SUB_REMENU,
	NULL,

	NO_DOUBLE,NO_DOUBLE,

	NULL, NO_HELP,
	},

	{
	50,	6*S_HEIGHT/3,
	M_WIDTH, 8*S_HEIGHT/3,

	1,

	(char *)&rotate_in_plane,ONE_OF,
	cursor_and_text,

	(char *)NULL, GO_SUB_REMENU,
	new_mode,

	NO_DOUBLE,NO_DOUBLE,

	NULL, NO_HELP,
	},

	{
	50,	8*S_HEIGHT/3,
	M_WIDTH, 10*S_HEIGHT/3,

	0,

	(char *)&roa_x,ONE_OF,
	cursor_and_text,

	NULL, GO_SUB_REMENU,
	new_mode,

	NO_DOUBLE,NO_DOUBLE,

	NULL, NO_HELP,
	},

	{
	50,	10*S_HEIGHT/3,
	M_WIDTH, 12*S_HEIGHT/3,

	0,

	(char *)&roa_y,ONE_OF,
	cursor_and_text,

	NULL, GO_SUB_REMENU,
	new_mode,

	NO_DOUBLE,NO_DOUBLE,

	NULL, NO_HELP,
	},

};
	

struct menu meta_ro_m =
{
	1,
	1,
	0, 0,
	M_WIDTH, M_HEIGHT,
	sizeof(meta_ro_table) / sizeof(struct selection),
	sizeof(meta_ro_table) / sizeof(struct selection),
	meta_ro_table,
	await_input,
	0,
	0,
};

set_rot_curs(sel)
struct selection *sel;
{
extern struct cursor rotate_cursor, zyrot_cursor, zxrot_cursor;
struct cursor *c;

switch(rotate_axis)
	{
	case 'x':
		c = &zyrot_cursor;
		break;
	case 'y':
		c = &zxrot_cursor;
		break;
	case 'z':
		c = &rotate_cursor;
		break;
	}
((struct one_of *)(sel->display_data))->display_data =
	(char *)c;
}

/*this is called as a SUB_MENU */
meta_rotate(menu,sel,vis)
struct menu *menu;
struct selection *sel;
VIRTUAL_INPUT *vis;
{
struct control local_control;

local_control.m = &meta_ro_m;
local_control.sel = NULL;
local_control.vis = vis;

copy_menu_offsets(menu, &meta_ro_m);
#ifdef SUN
#endif SUN

draw_menu(&meta_ro_m);
main_menu_driver(&local_control, NOSWAP_CONT);
clear_menu(&meta_ro_m);
set_rot_curs(sel);
}

