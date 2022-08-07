

struct selection m3_table[] =
	{
		{
		1, 1,	9,9,
		FALSE,
		(char *) &box_cursor,FIRST_TIME,
		cin_color,
		NULL, RETURN_SOMETHING,
		hide_menu,
		NO_DOUBLE, NO_DOUBLE,
		"close time menu", crude_help,
		},

		{
		1, 69,	14,79,
		FALSE,
		(char *)&l3arrow_cursor, FIRST_TIME,
		cin_color,
		NULL,GO_SUBBER,
		goto_begin_script,
		NO_DOUBLE,NO_DOUBLE,
		"jump to beginning of script", crude_help,
		},

		{
		16, 69,	28,79,
		FALSE,
		(char *)&l2arrow_cursor, FIRST_TIME,
		cin_color,
		NO_SDATA, GO_SUBBER,
		back_replay,
		NO_DOUBLE, NO_DOUBLE,
		"play script backwards", crude_help,
		},

		{
		30-1, 69,	41-2,79,
		FALSE,
		(char *)&larrow_cursor, FIRST_TIME,
		cin_color,
		NO_SDATA, GO_SUBBER,
		tm_snap_back,
		NO_DOUBLE, NO_DOUBLE,
		"go to last tween", crude_help,
		},

		{
		43-2, 69,	101-2,79,
		FALSE,
		(char *)"00:00:00", FIRST_TIME,
		show_time,
		NO_SDATA, GO_SUBBER,
		NO_SFUNCTION,
		NO_DOUBLE, NO_DOUBLE,
		"time position in script - minutes:seconds:60ths", crude_help,
		},

		{
		103-3, 69,	114-4,79,
		FALSE,
		(char *)&rarrow_cursor, FIRST_TIME,
		cin_color,
		NO_SDATA, GO_SUBBER,
		tm_snap_shot,
		NO_DOUBLE, NO_DOUBLE,
		"go to next tween", crude_help,
		},

		{
		116-4, 69,	128-4,79,
		FALSE,
		(char *)&r2arrow_cursor, FIRST_TIME,
		cin_color,
		NO_SDATA, GO_SUBBER,
		forwards_replay,
		NO_DOUBLE, NO_DOUBLE,
		"play script forward", crude_help,
		},

		{
		130-4, 69,	143-4,79,
		FALSE,
		(char *)&r3arrow_cursor, FIRST_TIME,
		cin_color,
		NULL,GO_SUBBER,
		goto_end_script,
		NO_DOUBLE,NO_DOUBLE,
		"jump to end of script", crude_help,
		},

		{
		143-2, 69,	150,79,
		FALSE,
		(char *)&question_cursor, FIRST_TIME,
		cin_color,
		NO_SDATA, HELP,
		NO_SFUNCTION,
		NO_DOUBLE, NO_DOUBLE,
		"explain icon", crude_help,
		},

		{
		150+1, 16-1,	190+1,26+2+3+2+1,
		FALSE,
		(char *) &tween_gauge, FIRST_TIME,
		see_digit_gauge,

			(char *) &tween_gauge, NO_HI_GOSUB,
		change_this_frame,

		NULL, NO_DOUBLE,
		"jump to tween", crude_help,
		},

		{
		150+1, 29+2+2+3+2-1,	190+1,39+2+2+2+6+4+1,
		FALSE,
		(char *)&twtime_gauge, FIRST_TIME,
		see_digit_gauge,
		(char *)&twtime_gauge, NO_HI_GOSUB,
		dredo_tween_time,
		NO_DOUBLE, NO_DOUBLE,
		"time between key frames", crude_help,
		},

		{
		150+1, 42+4+4+6+4-1,	190+1,52+2+4+4+9+6+1,
		FALSE,
		(char *)&scspeed_gauge, FIRST_TIME,
		see_digit_gauge,
		(char *)&scspeed_gauge, NO_HI_GOSUB,
		dredo_script_speed,
		NO_DOUBLE, NO_DOUBLE,
		"speed of whole script", crude_help,
		},

		{
		3, 16,	129+8+6+2,26+2+2,
		FALSE,
		(char *)&click_sl, FIRST_TIME,
		see_slider,
		(char *)&click_sl, GO_SUBBER,
		slide_this_frame,
		NO_DOUBLE, NO_DOUBLE,
		"place in script", crude_help,
		},

		{
		3, 29+2+2,	129+8+6+2,39+2+2+2+2,
		FALSE,
		(char *) &tween_sl,FIRST_TIME,
		see_nslider,
		(char *)&tween_sl,GO_SUBBER,
		redo_tween_time,
		NO_DOUBLE,NO_DOUBLE,
		"time between key frames", crude_help,
		},

		{
		3, 42+4+4,	129+8+6+2,52+2+4+4+2,
		FALSE,
		(char *) &clock_sl,FIRST_TIME,
		see_nslider,
		(char *)&clock_sl,GO_SUBBER,
		redo_script_speed,
		NO_DOUBLE,NO_DOUBLE,
		"speed of whole script", crude_help,
		},

		{
		11, 1,	190,10,
		FALSE,
		(char *) 0,FIRST_TIME,
		solid_block,
		NULL, GO_SUB_REMENU,
		move_menu,
		NO_DOUBLE, NO_DOUBLE,
		"move time menu", crude_help,
		},

	};

struct menu time_m =
	{
	FALSE,
	TRUE,
	10, 20,
	191, 80,
	sizeof(m3_table)/sizeof(struct selection),
	sizeof(m3_table)/sizeof(struct selection),
	m3_table,
	await_input,
	FALSE, FALSE,
	};
