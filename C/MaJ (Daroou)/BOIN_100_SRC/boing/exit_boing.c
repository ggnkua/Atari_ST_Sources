/* **[Boing]******************** */
/* *                           * */
/* * 22/07/2017 MaJ 27/05/2018 * */
/* ***************************** */



/*#include "ferme_offscreen_ecran.c"*/
#include "libere_surface.c"



/* prototype */
void exit_boing( void );




/* Fonction */
void exit_boing( void )
{

	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# exit_boing()"CRLF);
	log_print(FALSE);
	#endif


	libere_surface();


	if( global_flag_audio_ok==TRUE)
	{
/*		Fcm_sound_exit();*/
		unload_sound();
	}


	/*ferme_offscreen_ecran();*/



	/* pour le mode 4 bits 16 couleurs */
	if( Fcm_screen.nb_plan==4 && global_palette_save==TRUE )
	{
		set_palette( PALETTE_RESTORE );
	}


	return;


}

