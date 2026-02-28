/* **[Fonction Commune]************ */
/* *                              * */
/* * libŠre AES et VDI            * */
/* * 16/08/2003 :: 06/04/2013     * */
/* ******************************** */


/* Prototype */
VOID Fcm_libere_aes_vdi( VOID );


/* Fonction */
VOID Fcm_libere_aes_vdi( VOID )
{
/*
 * extern	WORD	vdihandle;
 *
 */


	#ifdef LOG_FILE
	sprintf( buf_log, "#Fcm_libere_aes_vdi()"CRLF );
	log_print( FALSE );
	#endif


	/* fermeture de la station graphique VDI */
	v_clsvwk(vdihandle);
	vdihandle=0;


	/* On indique … l'AES que l'on a plus besoin de lui */
	#ifdef __WINDOM__

		#ifdef LOG_FILE
		sprintf( buf_log, " - Windom appl_exit"CRLF );
		log_print( FALSE );
		#endif

		ApplExit();		/* Windom ApplExit() */

	#else

		#ifdef LOG_FILE
		sprintf( buf_log, " - AES appl_exit"CRLF );
		log_print( FALSE );
		#endif

		appl_exit();	/* Appel Standard AES */

	#endif



	#ifdef LOG_FILE
	{
		UWORD dummy;

		strcpy ( buf_log, CRLF"Fermeture session de "PRG_NOM);
		log_print( FALSE );
		dummy=Tgettime();
		sprintf( buf_log, " … %02d:%02d:%02d"CRLF""CRLF,((dummy>>11) & 31), ((dummy>>5) & 63), ((dummy & 31)<<1) );
		log_print( FALSE );
	}
	#endif


	return;


}

