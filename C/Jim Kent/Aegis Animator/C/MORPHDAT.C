
overlay "menu"

#include "..\\include\\lists.h"
#include "..\\include\\io.h"
#include "..\\include\\control.h"
#include "..\\include\\addr.h"
#include "..\\include\\format.h"
#include "..\\include\\cursor.h"
#include "..\\include\\menu.h"
#include "..\\include\\color.h"  /*for color_bar dimensions*/

#define MM_SX	17
#define MM_SY	20
#define MM_CENX 4
#define M_MWIDTH (11*MM_SX + MM_CENX)
#define M_MHEIGHT (4*MM_SY)

extern struct cursor bop_cursor, z_cursor, spiral_cursor;
extern struct cursor story_cursor, undo_cursor, persp_cursor;
extern struct cursor question_cursor, tilde_cursor, time_cursor, palette_cursor;
extern struct cursor exit_cursor;

extern change_s_mode();

extern int status_line();
extern int snap_shot(), breplay(), lreplay();
extern int local_dump(), hide_menu();
extern int change_color(), exit_anim();
extern int point_mode(), segment_mode(), poly_mode(), frame_mode();
extern int load_sequence(), save_sequence();
extern int switch_node(), swap_undo();
extern int vtype();
extern int move_menu();
extern int toggle_node();
/*routines called from menu*/


extern new_v_mode();
extern new_s_mode();

extern int goto_anim_menu();
extern int anim_menu(),morph_menu();
/*co-menus */

extern int edit_color(), color_menu(), storage_menu();
extern int  meta_spike();
extern int time_menu();
extern int meta_replay();
extern int meta_rotate(), meta_z();
extern int s_points(), s_polys(), s_segment(), frame_mode();
extern int double_switch_node();
/*some double_functions*/

extern int crude_help();
/*help functions*/
extern int cin_color(), cin_ccolor(), cursor_in_a_box();
extern int icon_in_color();
extern int color_bars(), double_cursor();
extern int see_gauge();
extern int solid_block();
/*some display_functions*/

extern struct selection morph_table[];


#ifdef DEBUG
struct one_of debug_node =
	{
	&debug,
	1,
	(char *)&strip_cursor,
	};
#endif DEBUG

struct one_of spoint_node =
	{
	&s_mode,
	S_POINT,
	(char *) &point_cursor,
	};

struct one_of spoints_node =
	{
	&s_mode,
	S_POINTS,
	(char *) &point_cursor,
	};

struct one_of ssegment_node =
	{
	&s_mode,
	S_SEGMENT,
	(char *) &segment_cursor,
	};

struct one_of spoly_node =
	{
	&s_mode,
	S_POLY,
	(char *) &poly_cursor,
	};

struct one_of spolys_node =
	{
	&s_mode,
	S_POLYS,
	(char *) &poly_cursor,
	};

struct one_of sframe_node =
	{
	&s_mode,
	S_FRAME,
	(char *) &frame_cursor,
	};


extern WORD v_mode;

struct one_of vspike_node =
	{
	&v_mode,
	0,
	(char *)&spike_cursor,
	};

struct one_of vloop_node =
	{
	&v_mode,
	1,
	(char *)&loop_cursor,
	};

struct one_of vhook_node =
	{
	&v_mode,
	2,
	(char *)&hook_cursor,
	};

struct one_of vmove_node =
	{
	&v_mode,
	3,
	(char *)&grab_cursor,
	};

struct one_of vrotate_node =
	{
	&v_mode,
	4,
	(char *)&rotate_cursor,
	};

struct one_of vsize_node =
	{
	&v_mode,
	5,
	(char *)&size_cursor,
	};

struct one_of vclone_node =
	{
	&v_mode,
	6,
	(char *)&clone_cursor,
	};

struct one_of vkill_node =
	{
	&v_mode,
	7,
	(char *)&kill_cursor,
	};

struct one_of vcolor_node =
	{
	&v_mode,
	8,
	(char *)&color_cursor,
	};

#ifdef NEVER
struct one_of vbop_node =
	{
	&v_mode,
	9,
	(char *)&bop_cursor,
	};
#endif NEVER

extern struct cursor out_cursor;
struct one_of vz_node =
	{
	&v_mode,
	10,
	(char *)&out_cursor,
	};

extern struct cursor sample_cursor;
struct one_of vsample_node =
	{
	&v_mode,
	11,
	(char *)&sample_cursor,
	};

extern struct slider gauge_sl;

struct selection morph_table[] =
{
	{
	MARGIN, MARGIN,
	MARGIN + CHAR_HEIGHT, CHAR_HEIGHT,

	0,

	(char *) &box_cursor,FIRST_TIME,
	cin_color,

	NULL, RETURN_SOMETHING,	/*RETURN_SOMETHING*/
	hide_menu,

	NULL,NO_DOUBLE,

	NULL, NO_HELP,
	},

	{
	MARGIN + CHAR_HEIGHT + 1, MARGIN,
	M_MWIDTH - MARGIN, CHAR_HEIGHT,

	0,

	(char *) 0,FIRST_TIME,
	solid_block,

	NULL, GO_SUB_REMENU,
	move_menu,

	NULL,NO_DOUBLE,

	"move menu", crude_help,
	},

	{
	0, 		MM_SY/2,
	MM_SX,	3*MM_SY/2,

	0,

	(char *) &spoint_node, ONE_OF,
	cin_color,

	(char *)NULL,GO_SUB_REMENU,
	new_s_mode,

	(char *)NULL, NO_DOUBLE,

	"select point", crude_help,
	},
	
	{
	MM_SX,	MM_SY/2,
	2*MM_SX,	3*MM_SY/2,

	0,

	(char *) &spoints_node, ONE_OF,
	double_cursor,

	(char *)NULL,GO_SUB_REMENU,
	new_s_mode,

	(char *)NULL, NO_DOUBLE,

	"select points", crude_help,
	},
	
	{
	2*MM_SX,	MM_SY/2,
	3*MM_SX,	3*MM_SY/2,

	0,

	(char *) &ssegment_node,ONE_OF,
	cin_color,

	(char *)NULL,GO_SUB_REMENU,
	new_s_mode,

	(char *)NULL, NO_DOUBLE,

	"select polygon segment", crude_help,
	},

	{
	3*MM_SX,	MM_SY/2,
	4*MM_SX,	3*MM_SY/2,

	1,

	(char *) &spoly_node,ONE_OF,
	cin_color,

	(char *)NULL, GO_SUB_REMENU,
	new_s_mode,

	(char *)NULL, NO_DOUBLE,

	"select polygon", crude_help,
	},

	{
	4*MM_SX,	MM_SY/2,
	5*MM_SX,	3*MM_SY/2,

	1,

	(char *) &spolys_node,ONE_OF,
	double_cursor,

	(char *)NULL, GO_SUB_REMENU,
	new_s_mode,

	(char *)NULL, NO_DOUBLE,

	"select polygons", crude_help,
	},


	{
	5*MM_SX,	MM_SY/2,
	6*MM_SX,	3*MM_SY/2,

	0,

	(char *) &sframe_node,ONE_OF,
	cin_color,

	(char *)NULL,GO_SUB_REMENU,
	new_s_mode,

	(char *)NULL, NO_DOUBLE,

	"select entire frame", crude_help,
	},

	{
	6*MM_SX+MM_CENX/2 + 4,	MM_SY/2 + 2,
	8*MM_SX+MM_CENX/2 - 4,	3*MM_SY/2 - 2,


	0,

	(char *) &gauge_sl, FIRST_TIME,
	see_gauge,

	NO_DATA,GO_SUBBER,
	status_line,

	NULL,NULL,

	"memory usage", crude_help,
	},

	{
	8*MM_SX+MM_CENX,	MM_SY/2,
	9*MM_SX+MM_CENX,	3*MM_SY/2,

	0,

	(char *) &question_cursor, FIRST_TIME,
	cin_color,

	NO_DATA,HELP,
	NULL,

	NO_DOUBLE,NO_DOUBLE,

	"explain icon", crude_help,
	},


	{
	9*MM_SX+MM_CENX,	MM_SY/2,
	10*MM_SX+MM_CENX,	3*MM_SY/2,

	0,

	(char *) &tilde_cursor, FIRST_TIME,
	cin_color,

	NO_DATA,DOUBLE,
	NULL,

	NO_DOUBLE,NO_DOUBLE,

	"function key", crude_help,
	},
	
	{
	10*MM_SX+MM_CENX,	MM_SY/2,
	11*MM_SX+MM_CENX,	3*MM_SY/2,

	0,

	(char *) &undo_cursor, FIRST_TIME,
	cin_color,

	NO_DATA,GO_SUB_REDRAW,
	swap_undo,

	NO_DOUBLE,NO_DOUBLE,

	"forget last action", crude_help,
	},
	
	{
	0*MM_SX, 	3*MM_SY/2,
	1*MM_SX, 	5*MM_SY/2,

	0,

	(char *) &vmove_node,ONE_OF,
	cin_color,

	(char *)NULL, GO_SUB_REMENU,
	new_v_mode,

	NO_DOUBLE,NO_DOUBLE,

	"move object", crude_help,
	},

	{
	1*MM_SX, 	3*MM_SY/2,
	2*MM_SX, 	5*MM_SY/2,

	0,

	(char *) &vz_node,ONE_OF,
	cin_color,

	(char *)NULL, GO_SUB_REMENU,
	new_v_mode,

	NULL,meta_z,

	"change what's in front", crude_help,
	},

	{
	2*MM_SX, 	3*MM_SY/2,
	3*MM_SX, 	5*MM_SY/2,

	0,

	(char *) &vsample_node,ONE_OF,
	cin_color,

	(char *)NULL, GO_SUB_REMENU,
	new_v_mode,

	NULL,NULL,

	"make path for object", crude_help,
	},

	{
	3*MM_SX, 	3*MM_SY/2,
	4*MM_SX, 	5*MM_SY/2,

	0,

	(char *) &vsize_node, ONE_OF,
	cin_color,

	(char *)NULL, GO_SUB_REMENU,
	new_v_mode,

	NO_DOUBLE,NO_DOUBLE,

	"shrink/expand object", crude_help,
	},

	{
	4*MM_SX, 	3*MM_SY/2,
	5*MM_SX, 	5*MM_SY/2,

	0,

	(char *) &vrotate_node,ONE_OF,
	cin_color,

	(char *)NULL, GO_SUB_REMENU,
	new_v_mode,

	NULL,meta_rotate,

	"rotate object", crude_help,
	},

	{
	5*MM_SX, 	3*MM_SY/2,
	6*MM_SX, 	5*MM_SY/2,

	0,

	(char *) &vloop_node,ONE_OF,
	cin_color,

	(char *)NULL,GO_SUB_REMENU,
	new_v_mode,

	NO_DOUBLE,NO_DOUBLE,

	"move points in a polygon", crude_help,
	},

	{
	7*MM_SX + MM_CENX, 	3*MM_SY/2,
	8*MM_SX + MM_CENX, 	5*MM_SY/2,

	0,

	(char *) &disk_cursor,FIRST_TIME,
	cin_color,

	NULL,GO_SUB_REMENU,
	storage_menu,

	NULL,NO_DOUBLE,

	"filing menu", crude_help,
	},

	{
	8*MM_SX + MM_CENX, 	3*MM_SY/2,
	9*MM_SX + MM_CENX, 	5*MM_SY/2,

	0,

	(char *)&story_cursor, FIRST_TIME,
	cin_color,

	NO_DATA,COMENU,
	goto_anim_menu,

	NULL,NO_DOUBLE,

	"go to storyboard menu", crude_help,
	},

	{
	9*MM_SX + MM_CENX, 	3*MM_SY/2,
	10*MM_SX + MM_CENX, 5*MM_SY/2,

	0,

	(char *) &palette_cursor,FIRST_TIME,
	cin_ccolor,

	NULL,GO_SUB_REMENU,
	color_menu,

	NULL,NO_DOUBLE,

	"color menu", crude_help,
	},

	{
	10*MM_SX + MM_CENX, 	3*MM_SY/2,
	11*MM_SX + MM_CENX,		5*MM_SY/2,

	0,

	(char *) &time_cursor,FIRST_TIME,
	cin_color,

	NULL,GO_SUB_REMENU,
	time_menu,

	NULL,NO_DOUBLE,

	"time menu", crude_help,
	},

	{
	0*MM_SX, 		5*MM_SY/2,
	1*MM_SX,		7*MM_SY/2,

	1,

	(char *) &vspike_node,ONE_OF,
	cin_color,

	(char *)NULL,GO_SUB_REMENU,
	new_v_mode,

	NULL,meta_spike,

	"create polygon", crude_help,
	},

#ifdef NEVER
	{
	1*MM_SX, 		5*MM_SY/2,
	2*MM_SX,		7*MM_SY/2,

	0,

	(char *) &vbop_node,ONE_OF,
	cin_color,

	(char *)NULL, GO_SUB_REMENU,
	new_v_mode,

	NULL,meta_spike,

	"convert types", crude_help,
	},
#endif NEVER

	{
	1*MM_SX, 		5*MM_SY/2,
	2*MM_SX,		7*MM_SY/2,

	0,

	(char *) &vcolor_node, ONE_OF,
	cin_color,

	(char *)NULL, GO_SUB_REMENU,
	new_v_mode,

	NULL,NO_DOUBLE,

	"change color", crude_help,
	},
	/*aka brush*/
	
	{
	2*MM_SX, 		5*MM_SY/2,
	3*MM_SX,		7*MM_SY/2,

	0,

	(char *) &vclone_node, ONE_OF,
	cin_color,

	(char *)NULL, GO_SUB_REMENU,
	new_v_mode,

	NO_DOUBLE,NO_DOUBLE,

	"duplicate object", crude_help,
	},

	{
	3*MM_SX, 		5*MM_SY/2,
	4*MM_SX,		7*MM_SY/2,

	0,

	(char *) &vkill_node, ONE_OF,
	cin_color,

	(char *)NULL,GO_SUB_REMENU,
	new_v_mode,

	NO_DOUBLE,NO_DOUBLE,

	"remove object", crude_help,
	},

	
	{
	4*MM_SX, 		5*MM_SY/2,
	5*MM_SX,		7*MM_SY/2,

	0,

	(char *) &vhook_node,ONE_OF,
	cin_color,

	(char *)NULL, GO_SUB_REMENU,
	new_v_mode,

	NULL,NO_DOUBLE,

	"insert/delete/move points in polygon", crude_help,
	},

#ifdef DEBUG
	{
	6*MM_SX, 		5*MM_SY/2,
	7*MM_SX,		7*MM_SY/2,

	0,

	(char *)&debug_node, ONE_OF,
	cin_color,

	NO_DATA,GO_SUB_REMENU,
	toggle_node,

	NULL,NO_DOUBLE,

	"debugging info", crude_help,
	},
#endif DEBUG

	{
	7*MM_SX + MM_CENX, 		5*MM_SY/2,
	8*MM_SX + MM_CENX,		7*MM_SY/2,

	0,

	(char *) &exit_cursor, FIRST_TIME,
	cin_color,

	NO_DATA, COMENU,
	exit_anim,

	NO_DOUBLE,NO_DOUBLE,

	"exit animation program", crude_help,
	},

	{
	8*MM_SX + MM_CENX, 		5*MM_SY/2,
	9*MM_SX + MM_CENX,		7*MM_SY/2,

	0,

	(char *) &breplay_cursor,FIRST_TIME,
	cin_color,

	NO_DATA,GO_SUBBER,
	breplay,

	NULL,meta_replay,

	"replay whole strip", crude_help,
	},

	{
	9*MM_SX + MM_CENX, 		5*MM_SY/2,
	10*MM_SX + MM_CENX,		7*MM_SY/2,

	0,  

	(char *) &lreplay_cursor,FIRST_TIME,
	cin_color,

	NO_DATA,GO_SUBBER,
	lreplay,

	NULL,NULL,

	"replay this tween", crude_help,
	},

	{
	10*MM_SX + MM_CENX, 	5*MM_SY/2,
	11*MM_SX + MM_CENX,		7*MM_SY/2,

	0,

	(char *) &camera_cursor,FIRST_TIME,
	cin_color,

	NULL, GO_SUBBER,
	snap_shot,

	NULL, NO_DOUBLE,

	"advance to next tween", crude_help,
	},

	
	{
	MARGIN,
	M_MHEIGHT - (M_MWIDTH-2*MARGIN)*COL_YDIV/COL_XDIV  - MARGIN,
	/*this rather horrific expression makes the individual color swatches
	  square and right on the bottom of the menu -jk*/
	M_MWIDTH-MARGIN, M_MHEIGHT-MARGIN,

	0,

	NULL, FIRST_TIME,
	color_bars,

	NO_DATA, GO_SUB_REMENU,
	change_color,

	NULL,edit_color,

	"select color", crude_help,
	},

};

#ifdef SLUFFED
rearrange_morph_menu()
{
set_rot_curs(morph_table + 16);
set_z_curs(morph_table + 13);
}
#endif SLUFFED

extern int waits();

#ifdef SLUFFED
WORD mm_initx = XMAX - M_MWIDTH -1;
WORD mm_inity = YMAX - M_MHEIGHT - 1;
#endif SLUFFED
struct menu morph_m =
	{
	1,
	1,
	10,2*CHAR_HEIGHT,
	M_MWIDTH, M_MHEIGHT,
	sizeof(morph_table) / sizeof(struct selection),
	sizeof(morph_table) / sizeof(struct selection),
	morph_table,
	await_input,
	0,
	0,
	};


