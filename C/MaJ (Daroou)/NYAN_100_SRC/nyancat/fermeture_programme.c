/* **[NyanCat]****************** */
/* *                           * */
/* * 04/10/2014 MaJ 24/05/2018 * */
/* ***************************** */



#include "../fonction/Coeur/Fcm_Libere_Ram.c"



/* Fonction */
void fermeture_programme( void )
{

	#ifdef LOG_FILE
	sprintf( buf_log, "# fermeture_programme()"CRLF);
	log_print( FALSE );
	#endif

/*	if(ARGV_adr_buffer) Fcm_libere_ram( ARGV_adr_buffer );*/


	return;


}

