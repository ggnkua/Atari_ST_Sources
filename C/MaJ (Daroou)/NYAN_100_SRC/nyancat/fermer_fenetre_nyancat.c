/* **[NyanCat]****************** */
/* *                           * */
/* * 04/10/2014 MaJ 24/05/2018 * */
/* ***************************** */




/* Prototype */
void fermer_fenetre_nyancat( void );



/* Fonction */
void fermer_fenetre_nyancat( void )
{


	#ifdef LOG_FILE
	sprintf( buf_log, "# fermer_fenetre_nyancat"CRLF );
	log_print(FALSE);
	#endif

	Fcm_fermer_fenetre(W_NYANCAT);


	/* Doit-on quitter ? */
	if( Fcm_quit_closewin == TRUE )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, " Quitter sur fermeture fenetre main => APP_TERM "CRLF );
		log_print(FALSE);
		#endif

		buffer_aes[0]=AP_TERM;
		buffer_aes[1]=ap_id;
		buffer_aes[2]=0;
		buffer_aes[3]=0;
		appl_write( ap_id, 16, &buffer_aes );
	}


	return;


}

