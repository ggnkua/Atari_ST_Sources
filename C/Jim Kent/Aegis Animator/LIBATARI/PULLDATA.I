

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
		31*CH_WIDTH, 0,
		6*CH_WIDTH, CH_HEIGHT,
		&rcolor_pull,
		"Color",
		pull_text,
		};
			Pull atstart_pull =
				{
				NONEXT,
				1, 1+7*CH_HEIGHT,
				12*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  At Start",
				pull_text,
				};
			Pull atend_pull =
				{
				&atstart_pull,
				1, 1+6*CH_HEIGHT,
				12*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  At End",
				pull_text,
				};
			Pull ghost_pull =
				{
				&atend_pull,
				1, 1+5*CH_HEIGHT,
				12*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Ghost Mode",
				pull_text,
				};
			Pull dots3_pull =
				{
				&ghost_pull,
				1, 1+4*CH_HEIGHT,
				12*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"------------",
				pull_text,
				};
			Pull playloop_pull =
				{
				&dots3_pull,
				1, 1+3*CH_HEIGHT,
				12*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Play Loop",
				pull_text,
				};
			Pull playall_pull =
				{
				&playloop_pull,
				1, 1+2*CH_HEIGHT,
				12*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Play All",
				pull_text,
				};
			Pull playtween_pull =
				{
				&playall_pull,
				1, 1+1*CH_HEIGHT,
				12*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Play Tween",
				pull_text,
				};
			Pull nexttween_pull =
				{
				&playtween_pull,
				1, 1+0*CH_HEIGHT,
				12*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Next Tween",
				pull_text,
				};
		Pull rtime_pull =
			{
			NONEXT,
			-1, CH_HEIGHT,
			2+12*CH_WIDTH, 2+8*CH_HEIGHT,
			&nexttween_pull,
			NODATA,
			pull_oblock,
			};
	Pull time_pull =
		{
		&color_pull,
		25*CH_WIDTH, 0,
		6*CH_WIDTH, CH_HEIGHT,
		&rtime_pull,
		"Time",
		pull_text,
		};
			Pull pall_pull =
				{
				NONEXT,
				1, 1+5*CH_HEIGHT,
				10*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  All",
				pull_text,
				};
			Pull ppolygons_pull =
				{
				&pall_pull,
				1, 1+4*CH_HEIGHT,
				10*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Polygons",
				pull_text,
				};
			Pull ppolygon_pull =
				{
				&ppolygons_pull,
				1, 1+3*CH_HEIGHT,
				10*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"x Polygon",
				pull_text,
				};
			Pull psegment_pull =
				{
				&ppolygon_pull,
				1, 1+2*CH_HEIGHT,
				10*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Segment",
				pull_text,
				};
			Pull ppoints_pull =
				{
				&psegment_pull,
				1, 1+1*CH_HEIGHT,
				10*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Points",
				pull_text,
				};
			Pull ppoint_pull =
				{
				&ppoints_pull,
				1, 1+0*CH_HEIGHT,
				10*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Point",
				pull_text,
				};
		Pull rpick_pull =
			{
			NONEXT,
			-1, CH_HEIGHT,
			2+10*CH_WIDTH, 2+6*CH_HEIGHT,
			&ppoint_pull,
			NODATA,
			pull_oblock,
			};
	Pull pick_pull =
		{
		&time_pull,
		19*CH_WIDTH, 0,
		6*CH_WIDTH, CH_HEIGHT,
		&rpick_pull,
		"Pick",
		pull_text,
		};
			Pull hook_pull =
				{
				NONEXT,
				1, 1+13*CH_HEIGHT,
				15*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Hook",
				pull_text,
				};
			Pull loop_pull =
				{
				&hook_pull,
				1, 1+12*CH_HEIGHT,
				15*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Loop",
				pull_text,
				};
			Pull makeline_pull =
				{
				&loop_pull,
				1, 1+11*CH_HEIGHT,
				15*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Make Line",
				pull_text,
				};
			Pull makeoutline_pull =
				{
				&makeline_pull,
				1, 1+10*CH_HEIGHT,
				15*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Make Outline",
				pull_text,
				};
			Pull makefilled_pull =
				{
				&makeoutline_pull,
				1, 1+9*CH_HEIGHT,
				15*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Make Filled",
				pull_text,
				};
			Pull changecolor_pull =
				{
				&makefilled_pull,
				1, 1+8*CH_HEIGHT,
				15*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Change Color",
				pull_text,
				};
			Pull alongpath_pull =
				{
				&changecolor_pull,
				1, 1+7*CH_HEIGHT,
				15*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Along Path",
				pull_text,
				};
			Pull bigsmall_pull =
				{
				&alongpath_pull,
				1, 1+6*CH_HEIGHT,
				15*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Big/Small",
				pull_text,
				};
			Pull yrotate_pull =
				{
				&bigsmall_pull,
				1, 1+5*CH_HEIGHT,
				15*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Yrotate",
				pull_text,
				};
			Pull xrotate_pull =
				{
				&yrotate_pull,
				1, 1+4*CH_HEIGHT,
				15*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Xrotate",
				pull_text,
				};
			Pull rotate_pull =
				{
				&xrotate_pull,
				1, 1+3*CH_HEIGHT,
				15*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Rotate",
				pull_text,
				};
			Pull outofscreen_pull =
				{
				&rotate_pull,
				1, 1+2*CH_HEIGHT,
				15*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Out of Screen",
				pull_text,
				};
			Pull intoscreen_pull =
				{
				&outofscreen_pull,
				1, 1+1*CH_HEIGHT,
				15*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Into Screen",
				pull_text,
				};
			Pull sideways_pull =
				{
				&intoscreen_pull,
				1, 1+0*CH_HEIGHT,
				15*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Sideways",
				pull_text,
				};
		Pull rmove_pull =
			{
			NONEXT,
			-1, CH_HEIGHT,
			2+15*CH_WIDTH, 2+14*CH_HEIGHT,
			&sideways_pull,
			NODATA,
			pull_oblock,
			};
	Pull move_pull =
		{
		&pick_pull,
		13*CH_WIDTH, 0,
		6*CH_WIDTH, CH_HEIGHT,
		&rmove_pull,
		"Move",
		pull_text,
		};
			Pull exchange_pull =
				{
				NONEXT,
				1, 1+13*CH_HEIGHT,
				10*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Exchange",
				pull_text,
				};
			Pull insert_pull =
				{
				&exchange_pull,
				1, 1+12*CH_HEIGHT,
				10*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Insert",
				pull_text,
				};
			Pull dotss_pull =
				{
				&insert_pull,
				1, 1+11*CH_HEIGHT,
				10*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"----------",
				pull_text,
				};
			Pull destroy_pull =
				{
				&dotss_pull,
				1, 1+10*CH_HEIGHT,
				10*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Destroy",
				pull_text,
				};
			Pull clone_pull =
				{
				&destroy_pull,
				1, 1+9*CH_HEIGHT,
				10*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Clone",
				pull_text,
				};
			Pull dots1_pull =
				{
				&clone_pull,
				1, 1+8*CH_HEIGHT,
				10*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"----------",
				pull_text,
				};
			Pull line_pull =
				{
				&dots1_pull,
				1, 1+7*CH_HEIGHT,
				10*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Line",
				pull_text,
				};
			Pull outline_pull =
				{
				&line_pull,
				1, 1+6*CH_HEIGHT,
				10*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Outline",
				pull_text,
				};
			Pull filled_pull =
				{
				&outline_pull,
				1, 1+5*CH_HEIGHT,
				10*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"x Filled",
				pull_text,
				};
			Pull dots2_pull =
				{
				&filled_pull,
				1, 1+4*CH_HEIGHT,
				10*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"----------",
				pull_text,
				};
			Pull block_pull =
				{
				&dots2_pull,
				1, 1+3*CH_HEIGHT,
				10*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Block",
				pull_text,
				};
			Pull star_pull =
				{
				&block_pull,
				1, 1+2*CH_HEIGHT,
				10*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Star",
				pull_text,
				};
			Pull circle_pull =
				{
				&star_pull,
				1, 1+1*CH_HEIGHT,
				10*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Circle",
				pull_text,
				};
			Pull polygon_pull =
				{
				&circle_pull,
				1, 1+0*CH_HEIGHT,
				10*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"x Polygon",
				pull_text,
				};
		Pull rmake_pull =
			{
			NONEXT,
			-1, CH_HEIGHT,
			2+10*CH_WIDTH, 3+14*CH_HEIGHT,
			&polygon_pull,
			NODATA,
			pull_oblock,
			};
	Pull make_pull =
		{
		&move_pull,
		7*CH_WIDTH, 0,
		6*CH_WIDTH, CH_HEIGHT,
		&rmake_pull,
		"Make",
		pull_text,
		};
			Pull exit_pull =
				{
				NONEXT,
				1, 1+10*CH_HEIGHT,
				12*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Exit",
				pull_text,
				};
			Pull status_pull =
				{
				&exit_pull,
				1, 1+9*CH_HEIGHT,
				12*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Status",
				pull_text,
				};
			Pull newscript_pull =
				{
				&status_pull,
				1, 1+8*CH_HEIGHT,
				12*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  New Script",
				pull_text,
				};
			Pull timemenu_pull =
				{
				&newscript_pull,
				1, 1+7*CH_HEIGHT,
				12*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Time",
				pull_text,
				};
			Pull colormenu_pull =
				{
				&timemenu_pull,
				1, 1+6*CH_HEIGHT,
				12*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Color",
				pull_text,
				};
			Pull storyboard_pull =
				{
				&colormenu_pull,
				1, 1+5*CH_HEIGHT,
				12*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Storyboard",
				pull_text,
				};
			Pull storage_pull =
				{
				&storyboard_pull,
				1, 1+4*CH_HEIGHT,
				12*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Storage",
				pull_text,
				};
			Pull fastmenu_pull =
				{
				&storage_pull,
				1, 1+3*CH_HEIGHT,
				12*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"x Fast Menu",
				pull_text,
				};
			Pull helpbar_pull =
				{
				&fastmenu_pull,
				1, 1+2*CH_HEIGHT,
				12*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"x Help Bar",
				pull_text,
				};
			Pull undo_pull =
				{
				&helpbar_pull,
				1, 1+1*CH_HEIGHT,
				12*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Undo",
				pull_text,
				};
			Pull aboutani1_pull =
				{
				&undo_pull,
				1, 1+0*CH_HEIGHT,
				12*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  About Ani",
				pull_text,
				};
		Pull rmenu_pull =
			{
			NONEXT,
			-1, CH_HEIGHT,
			2+12*CH_WIDTH, 2+11*CH_HEIGHT,
			&aboutani1_pull,
			NODATA,
			pull_oblock,
			};
	Pull menu_pull =
		{
		&make_pull,
		1*CH_WIDTH, 0,
		6*CH_WIDTH, CH_HEIGHT,
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
			Pull activate_pull =
				{
				NONEXT,
				1, 1+4*CH_HEIGHT,
				10*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Activate",
				pull_text,
				};
			Pull delete2_pull =
				{
				&activate_pull,
				1, 1+3*CH_HEIGHT,
				10*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Delete",
				pull_text,
				};
			Pull cut_pull =
				{
				&delete2_pull,
				1, 1+2*CH_HEIGHT,
				10*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Cut",
				pull_text,
				};
			Pull splice_pull =
				{
				&cut_pull,
				1, 1+1*CH_HEIGHT,
				10*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Splice",
				pull_text,
				};
			Pull gointo_pull =
				{
				&splice_pull,
				1, 1+0*CH_HEIGHT,
				10*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Go Into",
				pull_text,
				};
		Pull redit_pull =
			{
			NONEXT,
			-1, CH_HEIGHT,
			2+10*CH_WIDTH, 2+5*CH_HEIGHT,
			&gointo_pull,
			NODATA,
			pull_oblock,
			};
	Pull edit_pull =
		{
		NONEXT,
		7*CH_WIDTH, 0,
		6*CH_WIDTH, CH_HEIGHT,
		&redit_pull,
		"Edit",
		pull_text,
		};
			Pull exit2_pull =
				{
				NONEXT,
				1, 1+2*CH_HEIGHT,
				11*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Exit",
				pull_text,
				};
			Pull status2_pull =
				{
				&exit2_pull,
				1, 1+1*CH_HEIGHT,
				11*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  Status",
				pull_text,
				};
			Pull aboutani2_pull =
				{
				&status2_pull,
				1, 1+0*CH_HEIGHT,
				11*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"  About Ani",
				pull_text,
				};
		Pull rmenu2_pull =
			{
			NONEXT,
			-1, CH_HEIGHT,
			2+11*CH_WIDTH, 2+3*CH_HEIGHT,
			&aboutani2_pull,
			NODATA,
			pull_oblock,
			};
	Pull menu2_pull =
		{
		&edit_pull,
		1*CH_WIDTH, 0,
		6*CH_WIDTH, CH_HEIGHT,
		&rmenu2_pull,
		"Menu",
		pull_text,
		};
Pull aroot_pull =
	{
	NONEXT,
	0, 0, 320, 10,
	&menu2_pull,
	NODATA,
	pull_block,
	};

