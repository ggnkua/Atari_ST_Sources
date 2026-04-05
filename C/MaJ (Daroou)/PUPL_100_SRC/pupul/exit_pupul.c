/* **[Pupul]******************** */
/* *                           * */
/* * 16/08/2014 MaJ 08/11/2023 * */
/* ***************************** */



/*#include "ferme_offscreen_ecran.c"*/
#include "libere_surface.c"
//#include "exit_sound.c"



/* prototype */
void exit_pupul( void );




/* Fonction */
void exit_pupul( void )
{

	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# exit_pupul()"CRLF);
	log_print(FALSE);
	#endif



	if( global_mute_sound==FALSE)
	{
		mod_stop();
	}
	ldg_close( ldg_MOD, ldg_global );
	Fcm_libere_ram(adr_buffer_MOD);



	libere_surface();
	//exit_sound();

	/*ferme_offscreen_ecran();*/


	/* pour le mode 4 bits 16 couleurs */
	if( Fcm_screen.nb_plan==4 && global_palette_save==TRUE )
	{
		set_palette( PALETTE_RESTORE );
	}




	return;


}

