/* **[Badgers]****************** */
/* *                           * */
/* * 09/05/2024 MaJ 09/05/2024 * */
/* ***************************** */


void set_sound( void );



/* Fonction */
void set_sound( void )
{

	if( global_mute_sound == TRUE )
	{
		sound_stop();
	}
	else
	{
		if( global_animation_pause==FALSE)
		{
			/* on joue la musique */
			sound_start();

			/* on redemarre l'animation */
			index_sequence_animation = 0;
			build_screen_restart = TRUE;
		}
	}


	return;

}

