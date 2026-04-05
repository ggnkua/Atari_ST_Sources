/* **[Boing]******************** */
/* *                           * */
/* * 20/09/2015 MaJ 27/05/2018 * */
/* ***************************** */



/* Prototype */
void fermer_fenetre_boing( void );



/* Fonction */
void fermer_fenetre_boing( void )
{


	#ifdef LOG_FILE
	sprintf( buf_log, "# fermer_fenetre_boing"CRLF );
	log_print(FALSE);
	#endif

	#ifdef LOG_FILE
	sprintf( buf_log, " Fcm_quit_closewin = %d"CRLF, Fcm_quit_closewin );
	log_print(FALSE);
	#endif
		
	Fcm_fermer_fenetre(W_BOING);


	/* Doit-on fermer une fenetre ou quitter ? */
	if( Fcm_quit_closewin == TRUE )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, " Fcm_quit_closewin == TRUE, On doit quitter le programme => APP_TERM "CRLF );
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

