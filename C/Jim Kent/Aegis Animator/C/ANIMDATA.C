overlay "menu"

#include "..\\include\\lists.h"
#include "..\\include\\io.h"
#include "..\\include\\format.h"
#include "..\\include\\cursor.h"
#include "..\\include\\menu.h"


#ifdef SUN
extern int snap_shot(),  big_replay(), little_replay();
extern int change_color(), exit_anim();
extern int point_mode(), poly_mode(), frame_mode();
/*routines called from menu*/

extern int new_w_mode();
extern int edit_color();
extern int meta_replay();

extern int anim_menu(),morph_menu();
/*co-menus */

extern int cin_color(), cin_ccolor(), cursor_in_a_box();
extern int icon_in_color();
extern int color_bars();
extern int see_gauge();
/*some display_functions*/

extern int crude_help();

extern struct cursor question_cursor;
#define AN_YOFF 0

extern struct slider gauge_sl;

extern short w_mode;

struct one_of wactivate_node =
	{
	&w_mode,
	0,
	(char *)&breplay_cursor,
	};

extern struct cursor edit_cursor;
struct one_of wedit_node =
	{
	&w_mode,
	1,
	(char *)&edit_cursor,
	};

#ifdef NEVER
extern struct cursor overlay_cursor;
struct one_of wclone_node =
	{
	&w_mode,
	2,
	(char *)&overlay_cursor,
	};
#endif NEVER

extern struct cursor splice_cursor;
struct one_of wsplice_node =
	{
	&w_mode,
	3,
	(char *)&splice_cursor,
	};

struct one_of wkill_node =
	{
	&w_mode,
	4,
	(char *)&kill_cursor,
	};

extern struct cursor scissors_cursor;
struct one_of wscissors_node =
	{
	&w_mode,
	5,
	(char *)&scissors_cursor,
	};

struct selection anim_menu_table[] =
{
	{
	0*S_WIDTH+S_WIDTH/2,S_HEIGHT/2 + AN_YOFF,
	1*S_WIDTH+S_WIDTH/2,S_HEIGHT + S_HEIGHT/2 + AN_YOFF,

	0,

	(char *) &wactivate_node,ONE_OF,
	cin_color,

	NO_DATA,GO_SUB_REMENU,
	new_w_mode,

	NULL,meta_replay,

	"activate strip", crude_help,
	},

#ifdef NEVER
	{
	6*S_WIDTH+S_WIDTH/2,S_HEIGHT/2 + AN_YOFF,
	7*S_WIDTH+S_WIDTH/2,S_HEIGHT + S_HEIGHT/2 + AN_YOFF,

	0,

	(char *) &disk_cursor,FIRST_TIME,
	cin_color,

	NULL,GO_SUB_REMENU,
	sstorage_menu,

	NULL,NO_DOUBLE,

	"file menu", crude_help,
	},
#endif NEVER

	{
	S_WIDTH,S_HEIGHT/2+S_HEIGHT + AN_YOFF,
	2*S_WIDTH,2*S_HEIGHT + S_HEIGHT/2 + AN_YOFF,

	0,

	(char *) &wsplice_node,ONE_OF,
	cin_color,

	NO_DATA,GO_SUB_REMENU,
	new_w_mode,

	NO_DOUBLE,NO_DOUBLE,

	"splice strips", crude_help,
	},

#ifdef NEVER
	{
	2*S_WIDTH,S_HEIGHT/2+S_HEIGHT + AN_YOFF,
	3*S_WIDTH,2*S_HEIGHT + S_HEIGHT/2 + AN_YOFF,

	0,

	(char *) &wclone_node,ONE_OF,
	cin_color,

	NO_DATA,GO_SUB_REMENU,
	new_w_mode,

	NO_DOUBLE,NO_DOUBLE,

	"overlay_strips", crude_help,
	},
#endif NEVER

	{
	3*S_WIDTH,S_HEIGHT/2+S_HEIGHT + AN_YOFF,
	4*S_WIDTH,2*S_HEIGHT + S_HEIGHT/2 + AN_YOFF,

	0,

	(char *) &wscissors_node,ONE_OF,
	cin_color,

	NO_DATA,GO_SUB_REMENU,
	new_w_mode,

	NO_DOUBLE,NO_DOUBLE,

	"cut strip", crude_help,
	},

	
	{
	5*S_WIDTH, S_HEIGHT/2+S_HEIGHT + AN_YOFF,
	6*S_WIDTH, 2*S_HEIGHT + S_HEIGHT/2 + AN_YOFF,

	0,

	(char *) &wkill_node,ONE_OF,
	cin_color,

	NO_DATA,GO_SUB_REMENU,
	new_w_mode,

	NO_DOUBLE,NO_DOUBLE,

	"remove strip", crude_help,
	},


	{
	7*S_WIDTH, S_HEIGHT/2+S_HEIGHT + AN_YOFF,
	8*S_WIDTH, 2*S_HEIGHT + S_HEIGHT/2 + AN_YOFF,

	0,

	(char *) &bye_cursor, FIRST_TIME,
	cin_color,

	NO_DATA,COMENU,
	exit_anim,

	NO_DOUBLE,NO_DOUBLE,

	"exit animator", crude_help,
	},

	
	{
	4*S_WIDTH + S_WIDTH/2,S_HEIGHT/2+2*S_HEIGHT + AN_YOFF,
	6*S_WIDTH + S_WIDTH/2 - 3,3*S_HEIGHT + S_HEIGHT/2 + AN_YOFF,

	0,

	(char *)&wedit_node, ONE_OF,
	cin_a_box,

	NO_DATA,GO_SUB_REMENU,
	new_w_mode,

	NULL,NO_DOUBLE,

	"enter strip", crude_help,
	},


	{
	7*S_WIDTH,2*S_HEIGHT + S_HEIGHT/2 + AN_YOFF,
	8*S_WIDTH + S_WIDTH/2,4*S_HEIGHT + AN_YOFF,

	0,

	(char *) &gauge_sl, FIRST_TIME,
	see_gauge,

	NO_DATA,GO_SUB_REMENU,
	NULL,

	NULL,NULL,

	"memory use", crude_help,
	},

	{
	8*S_WIDTH + S_WIDTH/2,3*S_HEIGHT + AN_YOFF,
	9*S_WIDTH,4*S_HEIGHT + AN_YOFF,

	0,

	(char *) &box_cursor, FIRST_TIME,
	cin_color,

	NO_DATA,DOUBLE,
	NULL,

	NO_DOUBLE,NO_DOUBLE,

	"function key", crude_help,
	},

	{
	9*S_WIDTH + S_WIDTH/2,3*S_HEIGHT + AN_YOFF,
	10*S_WIDTH,4*S_HEIGHT + AN_YOFF,

	0,

	(char *) &question_cursor, FIRST_TIME,
	cin_color,

	NO_DATA,HELP,
	NULL,

	NO_DOUBLE,NO_DOUBLE,

	"define selection", crude_help,
	},
	
};

short anim_menu_size =  (sizeof(anim_menu_table) / sizeof(struct selection));


extern struct virtual_input *advance_story_board();

struct menu anim_m =
	{
	1,
	1,
	10, YMAX - M_HEIGHT,
	AM_WIDTH, AM_HEIGHT,
	sizeof(anim_menu_table) / sizeof(struct selection),
	sizeof(anim_menu_table) / sizeof(struct selection),
	anim_menu_table,
	advance_story_board,
	0,
	0,
	};

#endif SUN

#ifdef ATARI
extern struct virtual_input *advance_story_board();
struct menu anim_m =
	{
	0,
	1,
	10, 20,
	M_WIDTH, M_HEIGHT,
	0,
	0,
	NULL,
	advance_story_board,
	0,
	0,
	};
#endif ATARI
