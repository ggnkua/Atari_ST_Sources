/* **[Pupul]******************** */
/* *                           * */
/* * 09/05/2024 MaJ 09/05/2024 * */
/* ***************************** */


void set_sound( void );


#include "set_mod_config.c"
#include "set_mod_play.c"



/* Fonction */
void set_sound( void )
{

	if( global_mute_sound == TRUE )
	{
		/* on coupe le son */
		mod_stop();
	}
	else
	{
		if( global_animation_pause==FALSE)
		{
			/* on joue la musique */
			set_mod_play();
		}
	}


	return;

}

