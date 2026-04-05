/* **[Badgers]****************** */
/* *                           * */
/* * 24/10/2015 MaJ 19/12/2015 * */
/* ***************************** */

#include "../fonction/coeur/fcm_libere_ram.c"





void fermeture_programme( void )
{

#ifdef LOG_FILE
sprintf( buf_log, "# fermeture_programme()"CRLF);
log_print( FALSE );
#endif



	if(ARGV_adr_buffer) Fcm_libere_ram( ARGV_adr_buffer );


	return;


}

