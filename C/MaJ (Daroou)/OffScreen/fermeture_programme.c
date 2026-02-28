/* **[Offscreen]**************** */
/* *                           * */
/* * 10/12/2015 MaJ 17/12/2015 * */
/* ***************************** */



#include "fonction/Coeur/Fcm_Libere_Ram.c"



/* Fonction */
void fermeture_programme( void )
{

	#ifdef LOG_FILE
	sprintf( buf_log, "# fermeture_programme()"CRLF);
	log_print( FALSE );
	#endif



	if(ARGV_adr_buffer) Fcm_libere_ram( ARGV_adr_buffer );



	return;


}

