/* **[Fonction Commune]************ */
/* * LibŠration d'un ressource    * */
/* * 09/08/2003 :: 06/04/2013     * */
/* ******************************** */


/* Prototype */
VOID Fcm_libere_RSC( VOID );


/* Fonction */
VOID Fcm_libere_RSC( VOID )
{


	#ifdef LOG_FILE
	sprintf( buf_log, "# Fcm_libere_RSC()"CRLF );
	log_print( FALSE );
	#endif


	#ifdef __WINDOM__

		#ifdef LOG_FILE
		sprintf( buf_log, " - Lib‚ration Ressource (Windom)"CRLF );
		log_print( FALSE );
		#endif

		#ifdef LOG_FILE
		sprintf( buf_log, "  - Lib‚ration objet ‚tendu"CRLF );
		log_print( FALSE );
		#endif

		RsrcXtype( 0, NULL, 0);		/* Uninstall the extended objects */

		#ifdef LOG_FILE
		sprintf( buf_log, "  - Lib‚ration ressource"CRLF );
		log_print( FALSE );
		#endif

		RsrcFree();				/* Windom Free Fonction */



	#else

		#ifdef LOG_FILE
		sprintf( buf_log, " - Lib‚ration Ressource (AES)"CRLF );
		log_print( FALSE );
		#endif

		rsrc_free();		/* Standard AES fonction */

	#endif


	#ifdef LOG_FILE
	sprintf( buf_log, "  - Lib‚ration Ressource termin‚"CRLF );
	log_print( FALSE );
	#endif


	return;


}

