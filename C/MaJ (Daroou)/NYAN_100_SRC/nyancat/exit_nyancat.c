/* **[Nyancat]****************** */
/* *                           * */
/* * 22/07/2017 MaJ 24/05/2018 * */
/* ***************************** */



/*#include "ferme_offscreen_ecran.c"*/
#include "libere_surface.c"
#include "exit_sound.c"



/* prototype */
void exit_nyancat( void );




/* Fonction */
void exit_nyancat( void )
{

	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# exit_nyancat()"CRLF);
	log_print(FALSE);
	#endif


	libere_surface();
	exit_sound();

	/*ferme_offscreen_ecran();*/


	/* pour le mode 4 bits 16 couleurs */
	if( Fcm_screen.nb_plan==4 && global_palette_save==TRUE )
	{
		set_palette( PALETTE_RESTORE );
	}

	return;


}

