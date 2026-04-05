/* **[Badgers]****************** */
/* *                           * */
/* * 16/08/2014 MaJ 04/01/2024 * */
/* ***************************** */



/*#include "ferme_offscreen_ecran.c"*/

#include "libere_surface.c"
#include "exit_sound.c"
#include "set_palette.c"

void exit_badgers( void );





void exit_badgers( void )
{

#ifdef LOG_FILE
sprintf( buf_log, CRLF"# exit_badgers()"CRLF);
log_print(FALSE);
#endif


	exit_sound();
	libere_surface();

	//ferme_offscreen_ecran();


	/* pour le mode 4 bits 16 couleurs */
	if( Fcm_screen.nb_plan==4 && global_palette_save==TRUE )
	{
		set_palette( PALETTE_RESTORE );
	}


	return;


}

