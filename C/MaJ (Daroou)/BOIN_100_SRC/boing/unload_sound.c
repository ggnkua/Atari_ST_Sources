/* **[Boing]******************** */
/* *                           * */
/* * 20/09/2015 MaJ 27/05/2020 * */
/* ***************************** */


#ifndef ___unload_sound___
#define ___unload_sound___



/* prototype */
void unload_sound( void );



/* Fonction */
void unload_sound( void )
{

	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# unload_sound()"CRLF);
	log_print(FALSE);
	#endif


	Fcm_libere_ram( global_adr_buffer_boing_gauche );
	Fcm_libere_ram( global_adr_buffer_boing_droite );
	Fcm_libere_ram( global_adr_buffer_boing_sol );


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"---------------- End unload_sound()"CRLF);
	log_print(FALSE);
	#endif

	return;


}


#endif     /* ___unload_sound___ */

