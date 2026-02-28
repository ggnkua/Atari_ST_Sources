/* **[Offscreen]**************** */
/* *                           * */
/* * 01/02/2016 MaJ 07/02/2016 * */
/* ***************************** */




/* Prototype */
void fermer_fenetre_info( void );



/* Fonction */
void fermer_fenetre_info( void )
{

	#ifdef LOG_FILE
	sprintf( buf_log, "# fermer_fenetre_info"CRLF );
	log_print(FALSE);
	#endif


	{
		wind_close ( h_win[W_INFOSYS] );	/* on ferme la fenetre */
		wind_delete( h_win[W_INFOSYS] );	/* et on l'efface      */

		h_win[W_INFOSYS]=FCM_NO_OPEN_WINDOW;	/* on m‚morise sa fermeture */

		#ifdef LOG_FILE
		sprintf( buf_log, " ~ fenˆtre W_INFOSYS ferm‚"CRLF );
		log_print(FALSE);
		#endif

	}


	return;


}

