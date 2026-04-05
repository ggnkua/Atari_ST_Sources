/* **[Pupul]******************** */
/* *                           * */
/* * 16/08/2014 MaJ 23/02/2015 * */
/* ***************************** */

void gestion_va_start( void )
{


	#ifdef LOG_FILE
	sprintf( buf_log, "# gestion_va_start(), Gestion des messages VA_START:"CRLF);
	log_print( FALSE );
	#endif


	#ifdef LOG_FILE
	sprintf( buf_log, " -> Les messages VA_START ou APP_ARGV sont inutiles pour cette application"CRLF);
	log_print( FALSE );
	sprintf( buf_log, "    Les messages sont ignor‚s"CRLF);
	log_print( FALSE );
	#endif


	return;

}

