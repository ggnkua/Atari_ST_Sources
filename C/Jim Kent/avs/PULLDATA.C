/* Audio-Video Sequencer           */
/* Copyright 1988 Antic Publishing */
/* by Jim Kent                     */


#include "flicker.h"
#include "flicmenu.h"

			Pull pageup_pull =
				{
				NONEXT,
				1, 1+3*CH_HEIGHT,
				14*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Page Up     <-",
				pull_text,
				};
			Pull pagedown_pull =
				{
				&pageup_pull,
				1, 1+2*CH_HEIGHT,
				14*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Page Down   ->",
				pull_text,
				};
			Pull lineup_pull =
				{
				&pagedown_pull,
				1, 1+1*CH_HEIGHT,
				14*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Line Up      ",
				pull_text,
				};
			Pull linedown_pull =
				{
				&lineup_pull,
				1, 1+0*CH_HEIGHT,
				14*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Line Down     ",
				pull_text,
				};
		Pull rwindow_pull =
			{
			NONEXT,
			-1, CH_HEIGHT,
			2+14*CH_WIDTH, 2+4*CH_HEIGHT,
			&linedown_pull,
			NODATA,
			pull_oblock,
			};
	Pull window_pull =
		{
		NONEXT,
		57*CH_WIDTH, 0,
		12*CH_WIDTH, CH_HEIGHT,
		&rwindow_pull,
		"Window",
		spull_text,
		};
			Pull separate_pull =
				{
				NONEXT,
				1, 1+5*CH_HEIGHT,
				14*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Separate     <",
				pull_text,
				};
			Pull sort_pull =
				{
				&separate_pull,
				1, 1+4*CH_HEIGHT,
				14*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Sort Tracks  >",
				pull_text,
				};
			Pull packb_pull =
				{
				&sort_pull,
				1, 1+3*CH_HEIGHT,
				14*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Pack Both     ",
				pull_text,
				};
			Pull pack_s_pull =
				{
				&packb_pull,
				1, 1+2*CH_HEIGHT,
				14*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Pack Sound    ",
				pull_text,
				};
			Pull pack_v_pull =
				{
				&pack_s_pull,
				1, 1+1*CH_HEIGHT,
				14*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Pack Video    ",
				pull_text,
				};
			Pull duration_pull =
				{
				&pack_v_pull,
				1, 1+0*CH_HEIGHT,
				14*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Duration     D",
				pull_text,
				};
		Pull rtime_pull =
			{
			NONEXT,
			-1, CH_HEIGHT,
			2+14*CH_WIDTH, 2+6*CH_HEIGHT,
			&duration_pull,
			NODATA,
			pull_oblock,
			};
	Pull time_pull =
		{
		&window_pull,
		45*CH_WIDTH, 0,
		12*CH_WIDTH, CH_HEIGHT,
		&rtime_pull,
		"Time",
		spull_text,
		};
			Pull loadb_pull =
				{
				NONEXT,
				1, 1+6*CH_HEIGHT,
				14*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Load Block   B",
				pull_text,
				};
			Pull free_pull =
				{
				&loadb_pull,
				1, 1+5*CH_HEIGHT,
				14*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Free Block   F",
				pull_text,
				};
			Pull delete_pull =
				{
				&free_pull,
				1, 1+4*CH_HEIGHT,
				14*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Delete   [Del]",
				pull_text,
				};
			Pull insert_pull =
				{
				&delete_pull,
				1, 1+3*CH_HEIGHT,
				14*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Insert   [Ins]",
				pull_text,
				};
			Pull paste_pull =
				{
				&insert_pull,
				1, 1+2*CH_HEIGHT,
				14*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Paste        +",
				pull_text,
				};
			Pull cut_pull =
				{
				&paste_pull,
				1, 1+1*CH_HEIGHT,
				14*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Cut          -",
				pull_text,
				};
			Pull capture_pull =
				{
				&cut_pull,
				1, 1+0*CH_HEIGHT,
				14*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Capture      *",
				pull_text,
				};
		Pull rblock_pull =
			{
			NONEXT,
			-1, CH_HEIGHT,
			2+14*CH_WIDTH, 2+7*CH_HEIGHT,
			&capture_pull,
			NODATA,
			pull_oblock,
			};
	Pull block_pull =
		{
		&time_pull,
		30*CH_WIDTH, 0,
		12*CH_WIDTH, CH_HEIGHT,
		&rblock_pull,
		"Block",
		spull_text,
		};
			Pull kill_pull =
				{
				NONEXT,
				1, 1+4*CH_HEIGHT,
				14*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Kill Track   K",
				pull_text,
				};
			Pull examine_pull =
				{
				&kill_pull,
				1, 1+3*CH_HEIGHT,
				14*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Examine      X",
				pull_text,
				};
			Pull loadr_pull =
				{
				&examine_pull,
				1, 1+2*CH_HEIGHT,
				14*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Load Replay  R",
				pull_text,
				};
			Pull loadc_pull =
				{
				&loadr_pull,
				1, 1+1*CH_HEIGHT,
				14*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Load Cyber   C",
				pull_text,
				};
			Pull playt_pull =
				{
				&loadc_pull,
				1, 1+0*CH_HEIGHT,
				14*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Play Track   ?",
				pull_text,
				};
		Pull rtracks_pull =
			{
			NONEXT,
			-1, CH_HEIGHT,
			2+14*CH_WIDTH, 2+5*CH_HEIGHT,
			&playt_pull,
			NODATA,
			pull_oblock,
			};
	Pull tracks_pull =
		{
		&block_pull,
		15*CH_WIDTH, 0,
		12*CH_WIDTH, CH_HEIGHT,
		&rtracks_pull,
		"Tracks",
		spull_text,
		};
			Pull quit_pull =
				{
				NONEXT,
				1, 1+8*CH_HEIGHT,
				15*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Quit          Q",
				pull_text,
				};
			Pull new_pull =
				{
				&quit_pull,
				1, 1+7*CH_HEIGHT,
				15*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Clear All [Clr]",
				pull_text,
				};
			Pull memory_pull =
				{
				&new_pull,
				1, 1+6*CH_HEIGHT,
				15*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Memory        M",
				pull_text,
				};
			Pull save_pull =
				{
				&memory_pull,
				1, 1+5*CH_HEIGHT,
				15*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Save          S",
				pull_text,
				};
			Pull playl_pull =
				{
				&save_pull,
				1, 1+4*CH_HEIGHT,
				15*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Play Loop [Ret]",
				pull_text,
				};
			Pull play_pull =
				{
				&playl_pull,
				1, 1+3*CH_HEIGHT,
				15*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Play Once     P",
				pull_text,
				};
			Pull load_pull =
				{
				&play_pull,
				1, 1+2*CH_HEIGHT,
				15*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"Load          L",
				pull_text,
				};
			Pull dots3a_pull =
				{
				&load_pull,
				1, 1+1*CH_HEIGHT,
				15*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"---------------",
				pull_text,
				};
			Pull aboutf_pull =
				{
				&dots3a_pull,
				1, 1+0*CH_HEIGHT,
				15*CH_WIDTH, CH_HEIGHT,
				NOCHILD,
				"About AVS",
				pull_text,
				};
		Pull rcyreplay_pull =
			{
			NONEXT,
			-1, CH_HEIGHT,
			2+15*CH_WIDTH, 2+9*CH_HEIGHT,
			&aboutf_pull,
			NODATA,
			pull_oblock,
			};
	Pull cyreplay_pull =
		{
		&tracks_pull,
		1*CH_WIDTH, 0,
		12*CH_WIDTH, CH_HEIGHT,
		&rcyreplay_pull,
		"AVS",
		spull_text,
		};
Pull root_pull =
	{
	NONEXT,
	0, 0, 640, 10,
	&cyreplay_pull,
	NODATA,
	pull_block,
	};

