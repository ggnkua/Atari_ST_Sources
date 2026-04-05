/* **[Badgers]****************** */
/* *                           * */
/* * 04/01/2024 MaJ 04/01/2024 * */
/* ***************************** */

void check_sequence_animation( void );





void check_sequence_animation( void )
{
	static int16  old_index_sequence_animation=0;


/*{
	char mytexte[80];

	snprintf( mytexte, 80, " index_sequence_animation=%d    ", index_sequence_animation );
	Fcm_console_add(mytexte, G_GREEN);
}*/



	if( index_sequence_animation != old_index_sequence_animation )
	{
		old_index_sequence_animation = index_sequence_animation;

		build_screen_restart = TRUE;

		switch( index_sequence_animation )
		{
			case 0:
			case 3:
			case 6:
			case 9:
				pf_build_screen = build_screen_badgers;
				break;

			case 1:
			case 2:
			case 4:
			case 5:
			case 7:
			case 8:
				pf_build_screen = build_screen_mushroom;
				break;

			case 10:
				pf_build_screen = build_screen_argh;
				break;

			default:
				pf_build_screen = build_screen_badgers;
				break;
		}
	}


	return;


}

