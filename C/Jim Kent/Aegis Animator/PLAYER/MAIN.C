#include <osbind.h>
#include <gemdefs.h>
#include "lists.h"
#include "pull.h"
#include "format.h"

WORD ccolor;

#define COLWIDTH 16
#define COLHEIGHT 16

			Pull col15_pull =
				{
				NONEXT,
				1+COLWIDTH, 1+7*COLHEIGHT,
				COLWIDTH, COLHEIGHT,
				NOCHILD,
				(char *)15,
				pull_color,
				};
			Pull col14_pull =
				{
				&col15_pull,
				1+COLWIDTH, 1+6*COLHEIGHT,
				COLWIDTH, COLHEIGHT,
				NOCHILD,
				(char *)14,
				pull_color,
				};
			Pull col13_pull =
				{
				&col14_pull,
				1+COLWIDTH, 1+5*COLHEIGHT,
				COLWIDTH, COLHEIGHT,
				NOCHILD,
				(char *)13,
				pull_color,
				};
			Pull col12_pull =
				{
				&col13_pull,
				1+COLWIDTH, 1+4*COLHEIGHT,
				COLWIDTH, COLHEIGHT,
				NOCHILD,
				(char *)12,
				pull_color,
				};
			Pull col11_pull =
				{
				&col12_pull,
				1+COLWIDTH, 1+3*COLHEIGHT,
				COLWIDTH, COLHEIGHT,
				NOCHILD,
				(char *)11,
				pull_color,
				};
			Pull col10_pull =
				{
				&col11_pull,
				1+COLWIDTH, 1+2*COLHEIGHT,
				COLWIDTH, COLHEIGHT,
				NOCHILD,
				(char *)10,
				pull_color,
				};
			Pull col9_pull =
				{
				&col10_pull,
				1+COLWIDTH, 1+1*COLHEIGHT,
				COLWIDTH, COLHEIGHT,
				NOCHILD,
				(char *)9,
				pull_color,
				};
			Pull col8_pull =
				{
				&col9_pull,
				1+COLWIDTH, 1+0*COLHEIGHT,
				COLWIDTH, COLHEIGHT,
				NOCHILD,
				(char *)8,
				pull_color,
				};
			Pull col7_pull =
				{
				&col8_pull,
				1, 1+7*COLHEIGHT,
				COLWIDTH, COLHEIGHT,
				NOCHILD,
				(char *)7,
				pull_color,
				};
			Pull col6_pull =
				{
				&col7_pull,
				1, 1+6*COLHEIGHT,
				COLWIDTH, COLHEIGHT,
				NOCHILD,
				(char *)6,
				pull_color,
				};
			Pull col5_pull =
				{
				&col6_pull,
				1, 1+5*COLHEIGHT,
				COLWIDTH, COLHEIGHT,
				NOCHILD,
				(char *)5,
				pull_color,
				};
			Pull col4_pull =
				{
				&col5_pull,
				1, 1+4*COLHEIGHT,
				COLWIDTH, COLHEIGHT,
				NOCHILD,
				(char *)4,
				pull_color,
				};
			Pull col3_pull =
				{
				&col4_pull,
				1, 1+3*COLHEIGHT,
				COLWIDTH, COLHEIGHT,
				NOCHILD,
				(char *)3,
				pull_color,
				};
			Pull col2_pull =
				{
				&col3_pull,
				1, 1+2*COLHEIGHT,
				COLWIDTH, COLHEIGHT,
				NOCHILD,
				(char *)2,
				pull_color,
				};
			Pull col1_pull =
				{
				&col2_pull,
				1, 1+1*COLHEIGHT,
				COLWIDTH, COLHEIGHT,
				NOCHILD,
				(char *)1,
				pull_color,
				};
			Pull col0_pull =
				{
				&col1_pull,
				1, 1+0*COLHEIGHT,
				COLWIDTH, COLHEIGHT,
				NOCHILD,
				(char *)0,
				pull_color,
				};
		Pull rcolor_pull =
			{
			NONEXT,
			-1, CHAR_HEIGHT,
			2+2*COLWIDTH, 2+8*COLHEIGHT,
			&col0_pull,
			NODATA,
			pull_oblock,
			};
	Pull color_pull =
		{
		NONEXT,
		31*CHAR_WIDTH, 0,
		6*CHAR_WIDTH, CHAR_HEIGHT,
		&rcolor_pull,
		"Color",
		pull_text,
		};
			Pull atstart_pull =
				{
				NONEXT,
				1, 1+7*CHAR_HEIGHT,
				12*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  At Start",
				pull_text,
				};
			Pull atend_pull =
				{
				&atstart_pull,
				1, 1+6*CHAR_HEIGHT,
				12*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  At End",
				pull_text,
				};
			Pull ghost_pull =
				{
				&atend_pull,
				1, 1+5*CHAR_HEIGHT,
				12*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  Ghost Mode",
				pull_text,
				};
			Pull dots3_pull =
				{
				&ghost_pull,
				1, 1+4*CHAR_HEIGHT,
				12*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"------------",
				pull_text,
				};
			Pull playloop_pull =
				{
				&dots3_pull,
				1, 1+3*CHAR_HEIGHT,
				12*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  Play Loop",
				pull_text,
				};
			Pull playall_pull =
				{
				&playloop_pull,
				1, 1+2*CHAR_HEIGHT,
				12*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  Play All",
				pull_text,
				};
			Pull playtween_pull =
				{
				&playall_pull,
				1, 1+1*CHAR_HEIGHT,
				12*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  Play Tween",
				pull_text,
				};
			Pull nexttween_pull =
				{
				&playtween_pull,
				1, 1+0*CHAR_HEIGHT,
				12*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  Next Tween",
				pull_text,
				};
		Pull rtime_pull =
			{
			NONEXT,
			-1, CHAR_HEIGHT,
			2+12*CHAR_WIDTH, 2+8*CHAR_HEIGHT,
			&nexttween_pull,
			NODATA,
			pull_oblock,
			};
	Pull time_pull =
		{
		&color_pull,
		25*CHAR_WIDTH, 0,
		6*CHAR_WIDTH, CHAR_HEIGHT,
		&rtime_pull,
		"Time",
		pull_text,
		};
			Pull pall_pull =
				{
				NONEXT,
				1, 1+5*CHAR_HEIGHT,
				10*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  All",
				pull_text,
				};
			Pull ppolygons_pull =
				{
				&pall_pull,
				1, 1+4*CHAR_HEIGHT,
				10*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  Polygons",
				pull_text,
				};
			Pull ppolygon_pull =
				{
				&ppolygons_pull,
				1, 1+3*CHAR_HEIGHT,
				10*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"x Polygon",
				pull_text,
				};
			Pull psegment_pull =
				{
				&ppolygon_pull,
				1, 1+2*CHAR_HEIGHT,
				10*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  Segment",
				pull_text,
				};
			Pull ppoints_pull =
				{
				&psegment_pull,
				1, 1+1*CHAR_HEIGHT,
				10*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  Points",
				pull_text,
				};
			Pull ppoint_pull =
				{
				&ppoints_pull,
				1, 1+0*CHAR_HEIGHT,
				10*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  Point",
				pull_text,
				};
		Pull rpick_pull =
			{
			NONEXT,
			-1, CHAR_HEIGHT,
			2+10*CHAR_WIDTH, 2+6*CHAR_HEIGHT,
			&ppoint_pull,
			NODATA,
			pull_oblock,
			};
	Pull pick_pull =
		{
		&time_pull,
		19*CHAR_WIDTH, 0,
		6*CHAR_WIDTH, CHAR_HEIGHT,
		&rpick_pull,
		"Pick",
		pull_text,
		};
			Pull hook_pull =
				{
				NONEXT,
				1, 1+13*CHAR_HEIGHT,
				15*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  Hook",
				pull_text,
				};
			Pull loop_pull =
				{
				&hook_pull,
				1, 1+12*CHAR_HEIGHT,
				15*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  Loop",
				pull_text,
				};
			Pull makeline_pull =
				{
				&loop_pull,
				1, 1+11*CHAR_HEIGHT,
				15*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  Make Line",
				pull_text,
				};
			Pull makeoutline_pull =
				{
				&makeline_pull,
				1, 1+10*CHAR_HEIGHT,
				15*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  Make Outline",
				pull_text,
				};
			Pull makefilled_pull =
				{
				&makeoutline_pull,
				1, 1+9*CHAR_HEIGHT,
				15*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  Make Filled",
				pull_text,
				};
			Pull changecolor_pull =
				{
				&makefilled_pull,
				1, 1+8*CHAR_HEIGHT,
				15*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  Change Color",
				pull_text,
				};
			Pull alongpath_pull =
				{
				&changecolor_pull,
				1, 1+7*CHAR_HEIGHT,
				15*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  Along Path",
				pull_text,
				};
			Pull bigsmall_pull =
				{
				&alongpath_pull,
				1, 1+6*CHAR_HEIGHT,
				15*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  Big/Small",
				pull_text,
				};
			Pull yrotate_pull =
				{
				&bigsmall_pull,
				1, 1+5*CHAR_HEIGHT,
				15*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  Yrotate",
				pull_text,
				};
			Pull xrotate_pull =
				{
				&yrotate_pull,
				1, 1+4*CHAR_HEIGHT,
				15*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  Xrotate",
				pull_text,
				};
			Pull rotate_pull =
				{
				&xrotate_pull,
				1, 1+3*CHAR_HEIGHT,
				15*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  Rotate",
				pull_text,
				};
			Pull outofscreen_pull =
				{
				&rotate_pull,
				1, 1+2*CHAR_HEIGHT,
				15*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  Out of Screen",
				pull_text,
				};
			Pull intoscreen_pull =
				{
				&outofscreen_pull,
				1, 1+1*CHAR_HEIGHT,
				15*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  Into Screen",
				pull_text,
				};
			Pull sideways_pull =
				{
				&intoscreen_pull,
				1, 1+0*CHAR_HEIGHT,
				15*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  Sideways",
				pull_text,
				};
		Pull rmove_pull =
			{
			NONEXT,
			-1, CHAR_HEIGHT,
			2+15*CHAR_WIDTH, 2+14*CHAR_HEIGHT,
			&sideways_pull,
			NODATA,
			pull_oblock,
			};
	Pull move_pull =
		{
		&pick_pull,
		13*CHAR_WIDTH, 0,
		6*CHAR_WIDTH, CHAR_HEIGHT,
		&rmove_pull,
		"Move",
		pull_text,
		};
			Pull destroy_pull =
				{
				NONEXT,
				1, 1+10*CHAR_HEIGHT,
				9*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  Destroy",
				pull_text,
				};
			Pull clone_pull =
				{
				&destroy_pull,
				1, 1+9*CHAR_HEIGHT,
				9*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  Clone",
				pull_text,
				};
			Pull dots1_pull =
				{
				&clone_pull,
				1, 1+8*CHAR_HEIGHT,
				9*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"---------",
				pull_text,
				};
			Pull line_pull =
				{
				&dots1_pull,
				1, 1+7*CHAR_HEIGHT,
				9*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  Line",
				pull_text,
				};
			Pull outline_pull =
				{
				&line_pull,
				1, 1+6*CHAR_HEIGHT,
				9*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  Outline",
				pull_text,
				};
			Pull filled_pull =
				{
				&outline_pull,
				1, 1+5*CHAR_HEIGHT,
				9*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"x Filled",
				pull_text,
				};
			Pull dots2_pull =
				{
				&filled_pull,
				1, 1+4*CHAR_HEIGHT,
				9*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"---------",
				pull_text,
				};
			Pull block_pull =
				{
				&dots2_pull,
				1, 1+3*CHAR_HEIGHT,
				9*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  Block",
				pull_text,
				};
			Pull star_pull =
				{
				&block_pull,
				1, 1+2*CHAR_HEIGHT,
				9*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  Star",
				pull_text,
				};
			Pull circle_pull =
				{
				&star_pull,
				1, 1+1*CHAR_HEIGHT,
				9*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  Circle",
				pull_text,
				};
			Pull polygon_pull =
				{
				&circle_pull,
				1, 1+0*CHAR_HEIGHT,
				9*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"x Polygon",
				pull_text,
				};
		Pull rmake_pull =
			{
			NONEXT,
			-1, CHAR_HEIGHT,
			2+9*CHAR_WIDTH, 3+11*CHAR_HEIGHT,
			&polygon_pull,
			NODATA,
			pull_oblock,
			};
	Pull make_pull =
		{
		&move_pull,
		7*CHAR_WIDTH, 0,
		6*CHAR_WIDTH, CHAR_HEIGHT,
		&rmake_pull,
		"Make",
		pull_text,
		};
			Pull exit_pull =
				{
				NONEXT,
				1, 1+10*CHAR_HEIGHT,
				12*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  Exit",
				pull_text,
				};
			Pull status_pull =
				{
				&exit_pull,
				1, 1+9*CHAR_HEIGHT,
				12*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  Status",
				pull_text,
				};
			Pull newscript_pull =
				{
				&status_pull,
				1, 1+8*CHAR_HEIGHT,
				12*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  New Script",
				pull_text,
				};
			Pull timemenu_pull =
				{
				&newscript_pull,
				1, 1+7*CHAR_HEIGHT,
				12*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  Time",
				pull_text,
				};
			Pull colormenu_pull =
				{
				&timemenu_pull,
				1, 1+6*CHAR_HEIGHT,
				12*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  Color",
				pull_text,
				};
			Pull storyboard_pull =
				{
				&colormenu_pull,
				1, 1+5*CHAR_HEIGHT,
				12*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  Storyboard",
				pull_text,
				};
			Pull storage_pull =
				{
				&storyboard_pull,
				1, 1+4*CHAR_HEIGHT,
				12*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  Storage",
				pull_text,
				};
			Pull fastmenu_pull =
				{
				&storage_pull,
				1, 1+3*CHAR_HEIGHT,
				12*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"x Fast Menu",
				pull_text,
				};
			Pull helpbar_pull =
				{
				&fastmenu_pull,
				1, 1+2*CHAR_HEIGHT,
				12*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"x Help Bar",
				pull_text,
				};
			Pull undo_pull =
				{
				&helpbar_pull,
				1, 1+1*CHAR_HEIGHT,
				12*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  Undo",
				pull_text,
				};
			Pull aboutani1_pull =
				{
				&undo_pull,
				1, 1+0*CHAR_HEIGHT,
				12*CHAR_WIDTH, CHAR_HEIGHT,
				NOCHILD,
				"  About Ani",
				pull_text,
				};
		Pull rmenu_pull =
			{
			NONEXT,
			-1, CHAR_HEIGHT,
			2+12*CHAR_WIDTH, 2+11*CHAR_HEIGHT,
			&aboutani1_pull,
			NODATA,
			pull_oblock,
			};
	Pull menu_pull =
		{
		&make_pull,
		1*CHAR_WIDTH, 0,
		6*CHAR_WIDTH, CHAR_HEIGHT,
		&rmenu_pull,
		"Menu",
		pull_text,
		};
Pull root_pull =
	{
	NONEXT,
	0, 0, 320, 10,
	&menu_pull,
	NODATA,
	pull_block,
	};

main(argc, argv)
int argc;
char *argv;
{
int i;

if (!init_sys())
	{
	uninit_sys();
	exit(0);
	}
load_pic("reef1.neo");
show_mouse();
for (;;)
	{
	check_input();
	if (key_hit)
		do_key();
	else if (EDN)
		{
		if (PDN)
			draw_in_ccolor();
		else if (RDN)
			{
			i = pull(&root_pull);
			if (i >= 0)
				{
				switch (i>>8)
					{
					case 0:
						switch (i&0xff)
							{
							case 10:
								go_byebye();
							}
						break;
					case 5:
						ccolor = i&0xff;
						break;
					default:
						printf("%x\n", i);
						break;
					}
				}
			}
		}
	}
}

draw_in_ccolor()
{
hide_mouse();
for (;;)
	{
	putdot(mouse_x, mouse_y, ccolor);
	check_input();
	if (!PDN)
		break;
	}
show_mouse();
}

do_key()
{
switch((short)key_in)
	{
	case 'c':
		ccolor = getdot(mouse_x, mouse_y);
		break;
	case 'q':
		go_byebye();
	default:
		printf("%c %lx\n", (char)key_in, key_in);
		break;
	}
}

go_byebye()
{
hide_mouse();
uninit_sys();
exit(0);
}
