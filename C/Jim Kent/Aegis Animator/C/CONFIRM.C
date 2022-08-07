
overlay "menu"

#include "..\\include\\lists.h"
#include "..\\include\\io.h"
#include "..\\include\\menu.h"
#include "..\\include\\format.h"
#include "..\\include\\control.h"

extern int see_nslider(), text_in_box(), just_text();

return0()
{
return(0);
}

return1()
{
return(1);
}

#define CONFIRM_WIDTH ( 36 * CHAR_WIDTH)
#define CONFIRM_HEIGHT (4 * S_HEIGHT)

struct selection confirm_table[] =
{
	{
	MARGIN,		 1*S_HEIGHT/2,
	CONFIRM_WIDTH-2*MARGIN, 2*S_HEIGHT/2,

	1,

	NULL, FIRST_TIME,  /*this null is stuffed by confirm function*/
	just_text,

	(char *)NULL, GO_SUBBER,
	NULL,

	NO_DOUBLE,NO_DOUBLE,

	NULL, NO_HELP,
	},

	{
	MARGIN,		 5*S_HEIGHT/2,
	(CONFIRM_WIDTH-2*MARGIN)/ 2, 7*S_HEIGHT/2,

	0,

	"yes", FIRST_TIME,
	just_text,

	(char *)NULL,RETURN_SOMETHING,
	return1,

	NO_DOUBLE,NO_DOUBLE,

	NULL, NO_HELP,
	},

	{
	(CONFIRM_WIDTH - 2*MARGIN)/2,		 5*S_HEIGHT/2,
	CONFIRM_WIDTH-2*MARGIN, 7*S_HEIGHT/2,

	0,

	"no", FIRST_TIME,
	just_text,

	(char *)NULL,RETURN_SOMETHING,
	return0,

	NO_DOUBLE,NO_DOUBLE,

	NULL, NO_HELP,
	},

};



struct menu confirm_m =
	{
	0,
	1,
	XMAX - CONFIRM_WIDTH, YMAX - CONFIRM_HEIGHT,
	CONFIRM_WIDTH, CONFIRM_HEIGHT,
	sizeof(confirm_table) / sizeof(struct selection),
	sizeof(confirm_table) / sizeof(struct selection),
	confirm_table,
	await_input,
	0,
	};


confirm(m,sel, vis, what)
register struct menu *m;
struct selection *sel;
struct virtual_input *vis;
char *what;
{
struct control local_control;
int confirmed;
register struct menu *cm = &confirm_m;

copy_menu_offsets(m, cm);
confirm_m.redraw_flag = 0;

confirm_table[0].display_data = what;

local_control.m = cm;
local_control.sel = sel;
local_control.vis = vis;

maybe_clear_menu(m);
draw_menu(cm);
confirmed = main_menu_driver(&local_control, NOSWAP_CONT);
clear_menu(cm);
return(confirmed);
}

no_msv_confirm(what)
char *what;
{
struct control local_control;
int confirmed;
register struct menu *cm = &confirm_m;

confirm_table[0].display_data = what;

center_menu(cm);
local_control.m = cm;
draw_menu(cm);
confirmed = main_menu_driver(&local_control, NOSWAP_CONT);
clear_menu(cm);
return(confirmed);
}

static struct selection ok_boss_table[] =
{
	{
	MARGIN,		 1*S_HEIGHT/2,
	CONFIRM_WIDTH-2*MARGIN, 2*S_HEIGHT/2,

	1,

	NULL, FIRST_TIME,  /*this null is stuffed by ok boss function*/
	just_text,

	(char *)NULL, GO_SUBBER,
	NULL,

	NO_DOUBLE,NO_DOUBLE,

	NULL, NO_HELP,
	},

	{
	9*S_WIDTH/2,		 	5*S_HEIGHT/2,
	11*S_WIDTH/2, 		7*S_HEIGHT/2,

	0,

	"ok", FIRST_TIME,
	text_in_box,

	(char *)NULL,RETURN_SOMETHING,
	return0,

	NO_DOUBLE,NO_DOUBLE,

	NULL, NO_HELP,
	},

};



static struct menu ok_boss_m =
	{
	0,
	1,
	XMAX - CONFIRM_WIDTH, YMAX - CONFIRM_HEIGHT,
	CONFIRM_WIDTH, CONFIRM_HEIGHT,
	sizeof(ok_boss_table) / sizeof(struct selection),
	sizeof(ok_boss_table) / sizeof(struct selection),
	ok_boss_table,
	await_input,
	0,
	};


ok_boss(what)
char *what;
{
struct control local_control;
int confirmed;
register struct menu *cm = &ok_boss_m;

ok_boss_table[0].display_data = what;

center_menu(cm);
local_control.m = cm;
draw_menu(cm);
confirmed = main_menu_driver(&local_control, NOSWAP_CONT);
clear_menu(cm);
return(confirmed);
}

exit_anim(m,sel,vis)
register struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
extern char x_animation;
#ifdef DEBUG
lprintf("exit_anim()\n");
#endif DEBUG

if (confirm(m,sel,vis,"exit animator?") )
	x_animation = 0;
maybe_draw_menu(m);
}


struct selection request_table[] =
{
	{
	MARGIN,		 1*S_HEIGHT/2,
	CONFIRM_WIDTH-2*MARGIN, 2*S_HEIGHT/2,

	1,

	NULL, FIRST_TIME,  /*this null is stuffed by confirm function*/
	just_text,

	(char *)NULL, GO_SUBBER,
	NULL,

	NO_DOUBLE,NO_DOUBLE,

	NULL, NO_HELP,
	},

	{
	MARGIN,		 5*S_HEIGHT/2,
	(CONFIRM_WIDTH-2*MARGIN)/ 2, 7*S_HEIGHT/2,

	0,

	NULL, FIRST_TIME,
	NULL,

	(char *)NULL,GO_SUBBER,
	NULL,

	NO_DOUBLE,NO_DOUBLE,

	NULL, NO_HELP,
	},

};



struct menu request_m =
	{
	0,
	1,
	XMAX - CONFIRM_WIDTH, YMAX - CONFIRM_HEIGHT,
	CONFIRM_WIDTH, CONFIRM_HEIGHT,
	sizeof(request_table) / sizeof(struct selection),
	sizeof(request_table) / sizeof(struct selection),
	request_table,
	await_input,
	0,
	};



char *
request_line(m, sel, vis, request)
register struct menu *m;
struct selection *sel;
struct virtual_input *vis;
char *request;
{
register struct menu *rm = &request_m;
static char *req_string = NULL;
extern char *getline();

request_table[0].display_data = request;
copy_menu_offsets(m, rm);
request_m.redraw_flag = 0;

maybe_clear_menu(m);
draw_menu(rm);

if (req_string)
	free_string(req_string);
req_string  = clone_string( getline(rm, request_table+1, vis) );

clear_menu(rm);
return(req_string);
}

