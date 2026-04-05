/* **[NyanCat]****************** */
/* *                           * */
/* * 09/05/2024 MaJ 09/05/2024 * */
/* ***************************** */


void set_sound( void );

#include "play_sound.c"


/* Fonction */
void set_sound( void )
{

	if( global_mute_sound == TRUE )
	{
		/* on coupe le son */
		Fcm_musique_stop( &global_musique );
	}
	else
	{
		play_sound();
	}


	return;


}

