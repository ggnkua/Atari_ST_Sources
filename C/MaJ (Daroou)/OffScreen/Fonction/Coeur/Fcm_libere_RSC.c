/* **[Fonction Commune]************ */
/* * LibŠration d'un ressource    * */
/* * 09/08/2003 :: 06/04/2013     * */
/* ******************************** */



#ifndef ___Fcm_libere_RSC___
#define ___Fcm_libere_RSC___



/* Prototype */
VOID Fcm_libere_RSC( VOID );


/* Fonction */
VOID Fcm_libere_RSC( VOID )
{


	#ifdef LOG_FILE
	sprintf( buf_log, "# Fcm_libere_RSC()"CRLF );
	log_print( FALSE );
	#endif


	rsrc_free();		/* Standard AES fonction */


	#ifdef LOG_FILE
	sprintf( buf_log, "  - Lib‚ration Ressource termin‚"CRLF );
	log_print( FALSE );
	#endif


	return;


}


#endif  /* ___Fcm_libere_RSC___ */


