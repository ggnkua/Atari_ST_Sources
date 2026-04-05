/* **[Fonction commune]******* */
/* * Fermeture d'une ou de   * */
/* * toutes les fenetres     * */
/* * 02/01/2013 = 06/04/2013 * */
/* *************************** */



#ifndef __Fcm_fermer_fenetre__
#define __Fcm_fermer_fenetre__



/* Prototype */
VOID Fcm_fermer_fenetre( WORD win_index );


/* Fonction */
VOID Fcm_fermer_fenetre( WORD win_index )
{
/*
 * extern	WORD	h_win[NB_FENETRE];
 *
 */



	#ifdef LOG_FILE
	sprintf( buf_log, "# Fcm_fermer_fenetre(%d)"CRLF, win_index );
	log_print(FALSE);
	#endif


	/* Doit-on fermer une fenetre ou toutes ? */
	if( win_index != FCM_CLOSE_ALL_WIN )
	{
		/* une seule */
		wind_close ( h_win[win_index] );	/* on ferme la fenetre */
		wind_delete( h_win[win_index] );	/* et on l'efface      */

		h_win[win_index]=FCM_NO_OPEN_WINDOW;	/* on m‚morise sa fermeture */

		#ifdef LOG_FILE
		sprintf( buf_log, " ~ Fermeture fenˆtre: h_win(%d)"CRLF, win_index );
		log_print(FALSE);
		#endif

		return;
	}


	#ifdef LOG_FILE
	strcpy ( buf_log, " ~ Fermeture de toutes les fenˆtres: "CRLF);
	log_print(FALSE);
	#endif


	for(win_index=0; win_index<NB_FENETRE; win_index++)
	{
		if(h_win[win_index] != FCM_NO_OPEN_WINDOW)
		{
			wind_close ( h_win[win_index] );	/* on ferme la fenetre */
			wind_delete( h_win[win_index] );	/* et on l'efface      */

			h_win[win_index]=FCM_NO_OPEN_WINDOW;	/* on m‚morise sa fermeture */

			#ifdef LOG_FILE
			sprintf( buf_log, "   Fermeture fenˆtre: h_win(%d)"CRLF, win_index );
			log_print(FALSE);
			#endif
		}
	}

	return;


}


#endif


