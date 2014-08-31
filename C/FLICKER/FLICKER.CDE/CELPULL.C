
#include "flicker.h"

#define COLWIDTH 16
#define COLHEIGHT 16
#define BRWIDTH	18
#define BRHEIGHT 18
#define CH_WIDTH 8
#define CH_HEIGHT 9

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
			-1, CH_HEIGHT,
			2+2*COLWIDTH, 2+8*COLHEIGHT,
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
		pull_text,
		};
			Pull brf_pull =
				{
				NONEXT,
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
			4+4*BRWIDTH, 4+4*BRHEIGHT,
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
		pull_text,
		};
			Pull pfast_pull =
				{
				NONEXT,
				1, 1+11*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Play Fast",
				pull_text,
				};
			Pull pslow_pull =
				{
				&pfast_pull,
				1, 1+10*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Play Slowly",
				pull_text,
				};
			Pull pback_pull =
				{
				&pslow_pull,
				1, 1+9*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Play Backward",
				pull_text,
				};
			Pull pforward_pull =
				{
				&pback_pull,
				1, 1+8*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Play Forward",
				pull_text,
				};
			Pull dots3_pull =
				{
				&pforward_pull,
				1, 1+7*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"-------------",
				pull_text,
				};
			Pull delete_pull =
				{
				&dots3_pull,
				1, 1+6*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Delete",
				pull_text,
				};
			Pull playloop_pull =
				{
				&delete_pull,
				1, 1+5*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Insert",
				pull_text,
				};
			Pull playall_pull =
				{
				&playloop_pull,
				1, 1+4*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Append",
				pull_text,
				};
			Pull last_pull =
				{
				&playall_pull,
				1, 1+3*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Go To Last",
				pull_text,
				};
			Pull first_pull =
				{
				&last_pull,
				1, 1+2*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Go To First",
				pull_text,
				};
			Pull goback_pull =
				{
				&first_pull,
				1, 1+1*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Go Backward",
				pull_text,
				};
			Pull gofor_pull =
				{
				&goback_pull,
				1, 1+0*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Go Forward",
				pull_text,
				};
		Pull rtime_pull =
			{
			NONEXT,
			-1, CH_HEIGHT,
			2+13*CH_WIDTH, 2+12*CH_HEIGHT,
			&gofor_pull,
			NODATA,
			pull_oblock,
			};
	Pull time_pull =
		{
		&brush_pull,
		21*CH_WIDTH, 0,
		7*CH_WIDTH, CH_HEIGHT,
		&rtime_pull,
		"Frames",
		pull_text,
		};
			Pull zoom_pull =
				{
				NONEXT,
				1, 1+4*CH_HEIGHT,
				12*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Zoom",
				pull_text,
				};
			Pull degas_pull =
				{
				&zoom_pull,
				1, 1+3*CH_HEIGHT,
				12*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Neochrome",
				pull_text,
				};
			Pull filled_pull =
				{
				&degas_pull,
				1, 1+2*CH_HEIGHT,
				12*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"x Filled",
				pull_text,
				};
			Pull nozero_pull =
				{
				&filled_pull,
				1, 1+1*CH_HEIGHT,
				12*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"x Zero Clear",
				pull_text,
				};
			Pull status_pull =
				{
				&nozero_pull,
				1, 1+0*CH_HEIGHT,
				12*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Status",
				pull_text,
				};
		Pull rmisc_pull =
			{
			NONEXT,
			-1, CH_HEIGHT,
			2+12*CH_WIDTH, 2+5*CH_HEIGHT,
			&status_pull,
			NODATA,
			pull_oblock,
			};
	Pull misc_pull =
		{
		&time_pull,
		16*CH_WIDTH, 0,
		5*CH_WIDTH, CH_HEIGHT,
		&rmisc_pull,
		"Misc",
		pull_text,
		};
			Pull box_pull =
				{
				NONEXT,
				1, 1+9*CH_HEIGHT,
				10*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Box",
				pull_text,
				};
			Pull circle_pull =
				{
				&box_pull,
				1, 1+8*CH_HEIGHT,
				10*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Circle",
				pull_text,
				};
			Pull rays_pull =
				{
				&circle_pull,
				1, 1+7*CH_HEIGHT,
				10*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Rays",
				pull_text,
				};
			Pull polygon_pull =
				{
				&rays_pull,
				1, 1+6*CH_HEIGHT,
				10*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Polygon",
				pull_text,
				};
			Pull lines_pull =
				{
				&polygon_pull,
				1, 1+5*CH_HEIGHT,
				10*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Lines",
				pull_text,
				};
			Pull line_pull =
				{
				&lines_pull,
				1, 1+4*CH_HEIGHT,
				10*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Line",
				pull_text,
				};
			Pull flood_pull =
				{
				&line_pull,
				1, 1+3*CH_HEIGHT,
				10*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Flood",
				pull_text,
				};
			Pull dspray_pull =
				{
				&flood_pull,
				1, 1+2*CH_HEIGHT,
				10*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Spray",
				pull_text,
				};
			Pull drizzle_pull =
				{
				&dspray_pull,
				1, 1+1*CH_HEIGHT,
				10*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Drizzle",
				pull_text,
				};
			Pull vdraw_pull =
				{
				&drizzle_pull,
				1, 1+0*CH_HEIGHT,
				10*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"x Draw",
				pull_text,
				};
		Pull rdraw_pull =
			{
			NONEXT,
			-1, CH_HEIGHT,
			2+10*CH_WIDTH, 2+10*CH_HEIGHT,
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
		pull_text,
		};
			Pull fixcolors_pull =
				{
				NOCHILD,
				1, 1+9*CH_HEIGHT,
				11*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Fit Colors",
				pull_text,
				};
			Pull paste_pull =
				{
				&fixcolors_pull,
				1, 1+8*CH_HEIGHT,
				11*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Paste",
				pull_text,
				};
			Pull clip_pull =
				{
				&paste_pull,
				1, 1+7*CH_HEIGHT,
				11*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Clip",
				pull_text,
				};
			Pull cut_pull =
				{
				&clip_pull,
				1, 1+6*CH_HEIGHT,
				11*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Cut",
				pull_text,
				};
			Pull dots12_pull =
				{
				&cut_pull,
				1, 1+5*CH_HEIGHT,
				11*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"-----------",
				pull_text,
				};
			Pull clseq_pull =
				{
				&dots12_pull,
				1, 1+4*CH_HEIGHT,
				11*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Clear Seq",
				pull_text,
				};
			Pull clpic_pull =
				{
				&clseq_pull,
				1, 1+3*CH_HEIGHT,
				11*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Clear Pic",
				pull_text,
				};
			Pull unblue_pull =
				{
				&clpic_pull,
				1, 1+2*CH_HEIGHT,
				11*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Unblue Pic",
				pull_text,
				};
			Pull blue_pull =
				{
				&unblue_pull,
				1, 1+1*CH_HEIGHT,
				11*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Blue Pic",
				pull_text,
				};
			Pull undo_pull =
				{
				&blue_pull,
				1, 1+0*CH_HEIGHT,
				11*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Undo",
				pull_text,
				};
		Pull redit_pull =
			{
			NONEXT,
			-1, CH_HEIGHT,
			2+11*CH_WIDTH, 3+10*CH_HEIGHT,
			&undo_pull,
			NODATA,
			pull_oblock,
			};
	Pull edit_pull =
		{
		&drawing_pull,
		6*CH_WIDTH, 0,
		5*CH_WIDTH, CH_HEIGHT,
		&redit_pull,
		"Edit",
		pull_text,
		};
			Pull exit_pull =
				{
				NONEXT,
				1, 1+10*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Exit",
				pull_text,
				};
			Pull savecol_pull =
				{
				&exit_pull,
				1, 1+9*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Save Col",
				pull_text,
				};
			Pull lcol_pull =
				{
				&savecol_pull,
				1, 1+8*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Load Col",
				pull_text,
				};
			Pull sseq_pull =
				{
				&lcol_pull,
				1, 1+7*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Save Seq",
				pull_text,
				};
			Pull lseq_pull =
				{
				&sseq_pull,
				1, 1+6*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Load Seq",
				pull_text,
				};
			Pull scel_pull =
				{
				&lseq_pull,
				1, 1+5*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Save Cel",
				pull_text,
				};
			Pull lcel_pull =
				{
				&scel_pull,
				1, 1+4*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Load Cel",
				pull_text,
				};
			Pull spic_pull =
				{
				&lcel_pull,
				1, 1+3*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Save Pic",
				pull_text,
				};
			Pull lpic_pull =
				{
				&spic_pull,
				1, 1+2*CH_HEIGHT,
				13*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Load Pic",
				pull_text,
				};
			Pull dots3a_pull =
				{
				&lpic_pull,
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
				"About Flicker",
				pull_text,
				};
		Pull rfile_pull =
			{
			NONEXT,
			-1, CH_HEIGHT,
			2+13*CH_WIDTH, 2+11*CH_HEIGHT,
			&aboutf_pull,
			NODATA,
			pull_oblock,
			};
	Pull file_pull =
		{
		&edit_pull,
		1*CH_WIDTH, 0,
		5*CH_WIDTH, CH_HEIGHT,
		&rfile_pull,
		"File",
		pull_text,
		};
Pull root_pull =
	{
	NONEXT,
	0, 0, 320, 10,
	&file_pull,
	NODATA,
	pull_block,
	};

