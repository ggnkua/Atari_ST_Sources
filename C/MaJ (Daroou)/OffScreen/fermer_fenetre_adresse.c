/* **[Offscreen]**************** */
/* *                           * */
/* * 30/12/2015 MaJ 30/12/2015 * */
/* ***************************** */




/* Prototype */
void fermer_fenetre_adresse( void );



/* Fonction */
void fermer_fenetre_adresse( void )
{

	#ifdef LOG_FILE
	sprintf( buf_log, "# fermer_fenetre_adresse"CRLF );
	log_print(FALSE);
	#endif


	{
		wind_close ( h_win[W_ADRESSE] );	/* on ferme la fenetre */
		wind_delete( h_win[W_ADRESSE] );	/* et on l'efface      */

		h_win[W_ADRESSE]=FCM_NO_OPEN_WINDOW;	/* on m‚morise sa fermeture */

		#ifdef LOG_FILE
		sprintf( buf_log, " ~ fenˆtre W_ADRESSE ferm‚"CRLF );
		log_print(FALSE);
		#endif

	}


	return;


}

