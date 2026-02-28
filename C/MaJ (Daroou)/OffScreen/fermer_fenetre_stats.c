/* **[Offscreen]**************** */
/* *                           * */
/* * 13/12/2015 MaJ 13/12/2015 * */
/* ***************************** */




/* Prototype */
void fermer_fenetre_stats( void );



/* Fonction */
void fermer_fenetre_stats( void )
{

	#ifdef LOG_FILE
	sprintf( buf_log, "# fermer_fenetre_stats"CRLF );
	log_print(FALSE);
	#endif


	{
		wind_close ( h_win[W_STATS] );	/* on ferme la fenetre */
		wind_delete( h_win[W_STATS] );	/* et on l'efface      */

		h_win[W_STATS]=FCM_NO_OPEN_WINDOW;	/* on m‚morise sa fermeture */

		#ifdef LOG_FILE
		sprintf( buf_log, " ~ fenˆtre W_STATS ferm‚"CRLF );
		log_print(FALSE);
		#endif

	}


	return;


}

