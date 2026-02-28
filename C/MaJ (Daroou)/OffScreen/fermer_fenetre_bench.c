/* **[Offscreen]**************** */
/* *                           * */
/* * 31/12/2015 MaJ 31/12/2015 * */
/* ***************************** */




/* Prototype */
void fermer_fenetre_bench( void );



/* Fonction */
void fermer_fenetre_bench( void )
{

	#ifdef LOG_FILE
	sprintf( buf_log, "# fermer_fenetre_bench"CRLF );
	log_print(FALSE);
	#endif


	{
		wind_close ( h_win[W_BENCH] );	/* on ferme la fenetre */
		wind_delete( h_win[W_BENCH] );	/* et on l'efface      */

		h_win[W_BENCH]=FCM_NO_OPEN_WINDOW;	/* on m‚morise sa fermeture */

		#ifdef LOG_FILE
		sprintf( buf_log, " ~ fenˆtre W_BENCH ferm‚"CRLF );
		log_print(FALSE);
		#endif

	}


	return;


}

