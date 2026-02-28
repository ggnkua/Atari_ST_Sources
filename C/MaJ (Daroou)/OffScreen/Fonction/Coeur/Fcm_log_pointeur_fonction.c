/* **[Fonction commune]***** */
/* *                       * */
/* * 20/01/2013 07/01/2015 * */
/* ************************* */


/* Prototype */
void Fcm_log_pointeur_fonction( void );


/* Fonction */
void Fcm_log_pointeur_fonction( void )
{


	sprintf( buf_log, "  ## Fcm_log_pointeur_fonction()"CRLF );
	log_print( FALSE );


	sprintf( buf_log, "  - Main() => $%p"CRLF, main );
	log_print( FALSE );


/*
	sprintf( buf_log, "close_LDG_TGA() => $%p"CRLF, close_LDG_TGA );
	log_print( FALSE );

	sprintf( buf_log, "ldg_close() => $%p"CRLF, ldg_close );
	log_print( FALSE );
*/

	sprintf( buf_log, "  - end -"CRLF""CRLF );
	log_print( FALSE );


	return;


}

