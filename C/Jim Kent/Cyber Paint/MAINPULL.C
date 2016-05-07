
#include "flicker.h"

#define COLWIDTH 24
#define COLHEIGHT 20
#define BRWIDTH	22
#define BRHEIGHT 20

			Pull cefx_pull =
				{
				NONEXT,
				1+0*COLWIDTH, 1+4*COLHEIGHT+2*CH_HEIGHT,
				4*COLWIDTH, CH_HEIGHT,
				NOCHILD,
				" Color f/x %",
				pull_text,
				};
			Pull palette_pull =
				{
				&cefx_pull,
				1+0*COLWIDTH, 1+4*COLHEIGHT+CH_HEIGHT,
				4*COLWIDTH, CH_HEIGHT,
				NOCHILD,
				" Palette   @",
				pull_text,
				};
			Pull cycle_pull =
				{
				&palette_pull,
				1+0*COLWIDTH, 1+4*COLHEIGHT,
				4*COLWIDTH, CH_HEIGHT,
				NOCHILD,
				" Cycle     !",
				pull_text,
				};
			Pull col15_pull =
				{
				&cycle_pull,
				1+3*COLWIDTH, 1+3*COLHEIGHT,
				COLWIDTH, COLHEIGHT,
				NOCHILD,
				(char *)15,
				pull_color,
				};
			Pull col14_pull =
				{
				&col15_pull,
				1+2*COLWIDTH, 1+3*COLHEIGHT,
				COLWIDTH, COLHEIGHT,
				NOCHILD,
				(char *)14,
				pull_color,
				};
			Pull col13_pull =
				{
				&col14_pull,
				1+1*COLWIDTH, 1+3*COLHEIGHT,
				COLWIDTH, COLHEIGHT,
				NOCHILD,
				(char *)13,
				pull_color,
				};
			Pull col12_pull =
				{
				&col13_pull,
				1+0*COLWIDTH, 1+3*COLHEIGHT,
				COLWIDTH, COLHEIGHT,
				NOCHILD,
				(char *)12,
				pull_color,
				};
			Pull col11_pull =
				{
				&col12_pull,
				1+3*COLWIDTH, 1+2*COLHEIGHT,
				COLWIDTH, COLHEIGHT,
				NOCHILD,
				(char *)11,
				pull_color,
				};
			Pull col10_pull =
				{
				&col11_pull,
				1+2*COLWIDTH, 1+2*COLHEIGHT,
				COLWIDTH, COLHEIGHT,
				NOCHILD,
				(char *)10,
				pull_color,
				};
			Pull col9_pull =
				{
				&col10_pull,
				1+1*COLWIDTH, 1+2*COLHEIGHT,
				COLWIDTH, COLHEIGHT,
				NOCHILD,
				(char *)9,
				pull_color,
				};
			Pull col8_pull =
				{
				&col9_pull,
				1+0*COLWIDTH, 1+2*COLHEIGHT,
				COLWIDTH, COLHEIGHT,
				NOCHILD,
				(char *)8,
				pull_color,
				};
			Pull col7_pull =
				{
				&col8_pull,
				1+3*COLWIDTH, 1+1*COLHEIGHT,
				COLWIDTH, COLHEIGHT,
				NOCHILD,
				(char *)7,
				pull_color,
				};
			Pull col6_pull =
				{
				&col7_pull,
				1+2*COLWIDTH, 1+1*COLHEIGHT,
				COLWIDTH, COLHEIGHT,
				NOCHILD,
				(char *)6,
				pull_color,
				};
			Pull col5_pull =
				{
				&col6_pull,
				1+1*COLWIDTH, 1+1*COLHEIGHT,
				COLWIDTH, COLHEIGHT,
				NOCHILD,
				(char *)5,
				pull_color,
				};
			Pull col4_pull =
				{
				&col5_pull,
				1+0*COLWIDTH, 1+1*COLHEIGHT,
				COLWIDTH, COLHEIGHT,
				NOCHILD,
				(char *)4,
				pull_color,
				};
			Pull col3_pull =
				{
				&col4_pull,
				1+3*COLWIDTH, 1+0*COLHEIGHT,
				COLWIDTH, COLHEIGHT,
				NOCHILD,
				(char *)3,
				pull_color,
				};
			Pull col2_pull =
				{
				&col3_pull,
				1+2*COLWIDTH, 1+0*COLHEIGHT,
				COLWIDTH, COLHEIGHT,
				NOCHILD,
				(char *)2,
				pull_color,
				};
			Pull col1_pull =
				{
				&col2_pull,
				1+1*COLWIDTH, 1+0*COLHEIGHT,
				COLWIDTH, COLHEIGHT,
				NOCHILD,
				(char *)1,
				pull_color,
				};
			Pull col0_pull =
				{
				&col1_pull,
				1+0*COLWIDTH, 1+0*COLHEIGHT,
				COLWIDTH, COLHEIGHT,
				NOCHILD,
				(char *)0,
				pull_color,
				};
		Pull rcolor_pull =
			{
			NONEXT,
			-2-2*COLWIDTH, CH_HEIGHT,
			2+4*COLWIDTH, 2+4*COLHEIGHT+3*CH_HEIGHT,
			&col0_pull,
			NODATA,
			pull_oblock,
			};
	Pull color_pull =
		{
		NONEXT,
		34*CH_WIDTH, 0,
		6*CH_WIDTH, CH_HEIGHT,
		&rcolor_pull,
		"Color",
		spull_text,
		};
			Pull clip_brush_pull =
				{
				NONEXT,
				1+0*BRWIDTH, 3+4*BRHEIGHT+CH_HEIGHT,
				4*BRWIDTH+2, CH_HEIGHT,
				NOCHILD,
				" Use Clip U",
				pull_text,
				};
			Pull get_brush_pull =
				{
				&clip_brush_pull,
				1+0*BRWIDTH, 3+4*BRHEIGHT,
				4*BRWIDTH+2, CH_HEIGHT,
				NOCHILD,
				"Get Brush G",
				pull_text,
				};
			Pull brf_pull =
				{
				&get_brush_pull,
				2+3*BRWIDTH, 2+3*BRHEIGHT,
				BRWIDTH, BRHEIGHT,
				NOCHILD,
				(char *)15,
				pull_brush,
				};
			Pull bre_pull =
				{
				&brf_pull,
				2+2*BRWIDTH, 2+3*BRHEIGHT,
				BRWIDTH, BRHEIGHT,
				NOCHILD,
				(char *)14,
				pull_brush,
				};
			Pull brd_pull =
				{
				&bre_pull,
				2+1*BRWIDTH, 2+3*BRHEIGHT,
				BRWIDTH, BRHEIGHT,
				NOCHILD,
				(char *)13,
				pull_brush,
				};
			Pull brc_pull =
				{
				&brd_pull,
				2+0*BRWIDTH, 2+3*BRHEIGHT,
				BRWIDTH, BRHEIGHT,
				NOCHILD,
				(char *)12,
				pull_brush,
				};
			Pull brb_pull =
				{
				&brc_pull,
				2+3*BRWIDTH, 2+2*BRHEIGHT,
				BRWIDTH, BRHEIGHT,
				NOCHILD,
				(char *)11,
				pull_brush,
				};
			Pull bra_pull =
				{
				&brb_pull,
				2+2*BRWIDTH, 2+2*BRHEIGHT,
				BRWIDTH, BRHEIGHT,
				NOCHILD,
				(char *)10,
				pull_brush,
				};
			Pull br9_pull =
				{
				&bra_pull,
				2+1*BRWIDTH, 2+2*BRHEIGHT,
				BRWIDTH, BRHEIGHT,
				NOCHILD,
				(char *)9,
				pull_brush,
				};
			Pull br8_pull =
				{
				&br9_pull,
				2+0*BRWIDTH, 2+2*BRHEIGHT,
				BRWIDTH, BRHEIGHT,
				NOCHILD,
				(char *)8,
				pull_brush,
				};
			Pull br7_pull =
				{
				&br8_pull,
				2+3*BRWIDTH, 2+1*BRHEIGHT,
				BRWIDTH, BRHEIGHT,
				NOCHILD,
				(char *)7,
				pull_brush,
				};
			Pull br6_pull =
				{
				&br7_pull,
				2+2*BRWIDTH, 2+1*BRHEIGHT,
				BRWIDTH, BRHEIGHT,
				NOCHILD,
				(char *)6,
				pull_brush,
				};
			Pull br5_pull =
				{
				&br6_pull,
				2+1*BRWIDTH, 2+1*BRHEIGHT,
				BRWIDTH, BRHEIGHT,
				NOCHILD,
				(char *)5,
				pull_brush,
				};
			Pull br4_pull =
				{
				&br5_pull,
				2+0*BRWIDTH, 2+1*BRHEIGHT,
				BRWIDTH, BRHEIGHT,
				NOCHILD,
				(char *)4,
				pull_brush,
				};
			Pull br3_pull =
				{
				&br4_pull,
				2+3*BRWIDTH, 2+0*BRHEIGHT,
				BRWIDTH, BRHEIGHT,
				NOCHILD,
				(char *)3,
				pull_brush,
				};
			Pull br2_pull =
				{
				&br3_pull,
				2+2*BRWIDTH, 2+0*BRHEIGHT,
				BRWIDTH, BRHEIGHT,
				NOCHILD,
				(char *)2,
				pull_brush,
				};
			Pull br1_pull =
				{
				&br2_pull,
				2+1*BRWIDTH, 2+0*BRHEIGHT,
				BRWIDTH, BRHEIGHT,
				NOCHILD,
				(char *)1,
				pull_brush,
				};
			Pull br0_pull =
				{
				&br1_pull,
				2+0*BRWIDTH, 2+0*BRHEIGHT,
				BRWIDTH, BRHEIGHT,
				NOCHILD,
				(char *)0,
				pull_brush,
				};
		Pull rbrush_pull =
			{
			NONEXT,
			-1, CH_HEIGHT,
			4+4*BRWIDTH, 4+4*BRHEIGHT+2*CH_HEIGHT,
			&br0_pull,
			NODATA,
			pull_oblock,
			};
	Pull brush_pull =
		{
		&color_pull,
		28*CH_WIDTH, 0,
		6*CH_WIDTH, CH_HEIGHT,
		&rbrush_pull,
		"Brush",
		spull_text,
		};
			Pull scratch_pull =
				{
				NONEXT,
				1, 1+11*CH_HEIGHT,
				15*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Scratch       \\",
				pull_text,
				};
			Pull delete_pull =
				{
				&scratch_pull,
				1, 1+10*CH_HEIGHT,
				15*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Delete    [Del]",
				pull_text,
				};
			Pull clpic_pull =
				{
				&delete_pull,
				1, 1+9*CH_HEIGHT,
				15*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Clear Pic [Clr]",
				pull_text,
				};
			Pull next_changes_pull =
				{
				&clpic_pull,
				1, 1+8*CH_HEIGHT,
				15*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Next Changes  +",
				pull_text,
				};
			Pull get_changes_pull =
				{
				&next_changes_pull,
				1, 1+7*CH_HEIGHT,
				15*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Get Changes   *",
				pull_text,
				};
			Pull advance_blue_pull =
				{
				&get_changes_pull,
				1, 1+6*CH_HEIGHT,
				15*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Next Blue     /",
				pull_text,
				};
			Pull unblue_pull =
				{
				&advance_blue_pull,
				1, 1+5*CH_HEIGHT,
				15*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Unblue Pic    )",
				pull_text,
				};
			Pull blue_pull =
				{
				&unblue_pull,
				1, 1+4*CH_HEIGHT,
				15*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Blue Pic      (",
				pull_text,
				};
			Pull separate_many_pull =
				{
				&blue_pull,
				1, 1+3*CH_HEIGHT,
				15*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Separate Many _",
				pull_text,
				};
			Pull separate_pull =
				{
				&separate_many_pull,
				1, 1+2*CH_HEIGHT,
				15*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Separate      -",
				pull_text,
				};
			Pull restore_pull =
				{
				&separate_pull,
				1, 1+1*CH_HEIGHT,
				15*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Restore  [Back]",
				pull_text,
				};
			Pull undo_pull =
				{
				&restore_pull,
				1, 1+0*CH_HEIGHT,
				15*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Undo     [Undo]",
				pull_text,
				};
		Pull rtime_pull =
			{
			NONEXT,
			-1, CH_HEIGHT,
			2+15*CH_WIDTH, 2+12*CH_HEIGHT,
			&undo_pull,
			NODATA,
			pull_oblock,
			};
	Pull time_pull =
		{
		&brush_pull,
		22*CH_WIDTH, 0,
		7*CH_WIDTH, CH_HEIGHT,
		&rtime_pull,
		"Frame",
		spull_text,
		};
			Pull concentric_pull =
				{
				NONEXT,
				1, 1+7*CH_HEIGHT,
				12*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				" Concentric",
				pull_text,
				};
			Pull connected_pull =
				{
				&concentric_pull,
				1, 1+6*CH_HEIGHT,
				12*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				" Connected",
				pull_text,
				};
			Pull distinct_pull =
				{
				&connected_pull,
				1, 1+5*CH_HEIGHT,
				12*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				" Distinct",
				pull_text,
				};
			Pull dottya_pull =
				{
				&distinct_pull,
				1, 1+4*CH_HEIGHT,
				12*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"------------",
				pull_text,
				};
			Pull filled_pull =
				{
				&dottya_pull,
				1, 1+3*CH_HEIGHT,
				12*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				" Filled    F",
				pull_text,
				};
			Pull nozero_pull =
				{
				&filled_pull,
				1, 1+2*CH_HEIGHT,
				12*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				" Xray Copy X",
				pull_text,
				};
			Pull pingpong_pull =
				{
				&nozero_pull,
				1, 1+1*CH_HEIGHT,
				12*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				" Ping Pong W",
				pull_text,
				};
			Pull zoom_pull =
				{
				&pingpong_pull,
				1, 1+0*CH_HEIGHT,
				12*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				" Zoom      Z",
				pull_text,
				};
		Pull rmisc_pull =
			{
			NONEXT,
			-1, CH_HEIGHT,
			2+12*CH_WIDTH, 2+8*CH_HEIGHT,
			&zoom_pull,
			NODATA,
			pull_oblock,
			};
	Pull misc_pull =
		{
		&time_pull,
		16*CH_WIDTH, 0,
		6*CH_WIDTH, CH_HEIGHT,
		&rmisc_pull,
		"Modes",
		spull_text,
		};
			Pull pentext_pull =
				{
				NONEXT,
				1, 1+9*CH_HEIGHT,
				11*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				" Text     0",
				pull_text,
				};
			Pull box_pull =
				{
				&pentext_pull,
				1, 1+8*CH_HEIGHT,
				11*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				" Box      9",
				pull_text,
				};
			Pull circle_pull =
				{
				&box_pull,
				1, 1+7*CH_HEIGHT,
				11*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				" Circle   8",
				pull_text,
				};
			Pull polygon_pull =
				{
				&circle_pull,
				1, 1+6*CH_HEIGHT,
				11*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				" Polygon  7",
				pull_text,
				};
			Pull line_pull =
				{
				&polygon_pull,
				1, 1+5*CH_HEIGHT,
				11*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				" Line     6",
				pull_text,
				};
			Pull flood_pull =
				{
				&line_pull,
				1, 1+4*CH_HEIGHT,
				11*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				" Fill     5",
				pull_text,
				};
			Pull dspray_pull =
				{
				&flood_pull,
				1, 1+3*CH_HEIGHT,
				11*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				" Airbrush 4",
				pull_text,
				};
			Pull drizzle_pull =
				{
				&dspray_pull,
				1, 1+2*CH_HEIGHT,
				11*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				" Stipple  3",
				pull_text,
				};
			Pull scribble_pull =
				{
				&drizzle_pull,
				1, 1+1*CH_HEIGHT,
				11*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				" Streak   2",
				pull_text,
				};
			Pull vdraw_pull =
				{
				&scribble_pull,
				1, 1+0*CH_HEIGHT,
				11*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				" Draw     1",
				pull_text,
				};
		Pull rdraw_pull =
			{
			NONEXT,
			-1, CH_HEIGHT,
			2+11*CH_WIDTH, 2+10*CH_HEIGHT,
			&vdraw_pull,
			NODATA,
			pull_oblock,
			};
	Pull drawing_pull =
		{
		&misc_pull,
		11*CH_WIDTH, 0,
		5*CH_WIDTH, CH_HEIGHT,
		&rdraw_pull,
		"Draw",
		spull_text,
		};
			Pull mask_pull =
				{
				NONEXT,
				1, 1+9*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Mask        V",
				pull_text,
				};
			Pull fixcolors_pull =
				{
				&mask_pull,
				1, 1+8*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Fit Colors  N",
				pull_text,
				};
			Pull flip_pull	=
				{
				&fixcolors_pull,
				1, 1+7*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Invert      I",
				pull_text,
				};
			Pull stretch_pull =
				{
				&flip_pull,
				1, 1+6*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Stretch     S",
				pull_text,
				};
			Pull rotate_pull =
				{
				&stretch_pull,
				1, 1+5*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Rotate      R",
				pull_text,
				};
			Pull clip_pull =
				{
				&rotate_pull,
				1, 1+4*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Clip    [Tab]",
				pull_text,
				};
			Pull move_pull =
				{
				&clip_pull,
				1, 1+3*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Move        M",
				pull_text,
				};
			Pull paste_under_pull =
				{
				&move_pull,
				1, 1+2*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Paste Below B",
				pull_text,
				};
			Pull paste_pull =
				{
				&paste_under_pull,
				1, 1+1*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Paste       P",
				pull_text,
				};
			Pull cut_pull =
				{
				&paste_pull,
				1, 1+0*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Cut     [Esc]",
				pull_text,
				};
		Pull redit_pull =
			{
			NONEXT,
			-1, CH_HEIGHT,
			2+13*CH_WIDTH, 3+10*CH_HEIGHT,
			&cut_pull,
			NODATA,
			pull_oblock,
			};
	Pull edit_pull =
		{
		&drawing_pull,
		6*CH_WIDTH, 0,
		5*CH_WIDTH, CH_HEIGHT,
		&redit_pull,
		"Clip",
		spull_text,
		};
			Pull exit_pull =
				{
				NONEXT,
				1, 1+11*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Quit        Q",
				pull_text,
				};
			Pull clseq_pull =
				{
				&exit_pull,
				1, 1+10*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Kill Seq    K",
				pull_text,
				};
			Pull supermove_pull =
				{
				&clseq_pull,
				1, 1+9*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"ADO f/x     A",
				pull_text,
				};
			Pull pixelfx_pull =
				{
				&supermove_pull,
				1, 1+8*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Pixel f/x   ~",
				pull_text,
				};
			Pull status_pull =
				{
				&pixelfx_pull,
				1, 1+7*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Status      ?",
				pull_text,
				};
			Pull airspeed_pull =
				{
				&status_pull,
				1, 1+6*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Air Speed   #",
				pull_text,
				};
			Pull text_pull =
				{
				&airspeed_pull,
				1, 1+5*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Set Font    =",
				pull_text,
				};
			Pull matte_pull =
				{
				&text_pull,
				1, 1+4*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Matte       $",
				pull_text,
				};
			Pull loadsave_pull =
				{
				&matte_pull,
				1, 1+3*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Load/Save   L",
				pull_text,
				};
			Pull timemenu_pull =
				{
				&loadsave_pull,
				1, 1+2*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Time        T",
				pull_text,
				};
			Pull dots3a_pull =
				{
				&timemenu_pull,
				1, 1+1*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"-------------",
				pull_text,
				};
			Pull aboutf_pull =
				{
				&dots3a_pull,
				1, 1+0*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"About CyPaint",
				pull_text,
				};
		Pull rmenu_pull =
			{
			NONEXT,
			-1, CH_HEIGHT,
			2+13*CH_WIDTH, 2+12*CH_HEIGHT,
			&aboutf_pull,
			NODATA,
			pull_oblock,
			};
	Pull menu_pull =
		{
		&edit_pull,
		1*CH_WIDTH, 0,
		5*CH_WIDTH, CH_HEIGHT,
		&rmenu_pull,
		"Menu",
		spull_text,
		};
Pull root_pull =
	{
	NONEXT,
	0, 0, 320, 10,
	&menu_pull,
	NODATA,
	pull_block,
	};

