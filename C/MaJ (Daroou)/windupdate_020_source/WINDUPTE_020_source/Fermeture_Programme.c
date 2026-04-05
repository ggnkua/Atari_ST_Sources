/* **[WindUpdate]**************** */
/* *                            * */
/* * 20/12/2012 MaJ 29/01/2015  * */
/* ****************************** */



void fermeture_programme( void )
{

	#ifdef LOG_FILE
	sprintf( buf_log, "# Fermeture programme"CRLF);
	log_print( FALSE );
	#endif


	if( ARGV_adr_buffer ) Fcm_libere_ram( ARGV_adr_buffer );


}

