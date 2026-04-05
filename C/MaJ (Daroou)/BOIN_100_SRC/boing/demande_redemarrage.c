/* **[NyanCat]****************** */
/* *                           * */
/* * 26/05/2018 MaJ 27/05/2018 * */
/* ***************************** */



void demande_redemarrage( void );




void demande_redemarrage( void )
{
	int16 reponse;



	Fcm_affiche_alerte( DATA_MODE_APPLI, ALT_REDEMARRAGE, &reponse );

	#ifdef LOG_FILE
	sprintf( buf_log, "#Fcm_affiche_alerte , reponse=%d)"CRLF, reponse );
	log_print(FALSE);
	#endif

	if( reponse == 2 )
	{
		/* l'utilisateur veut redemarrer de suite */
		global_app_restart = TRUE;
		
		buffer_aes[0] = AP_TERM;
		buffer_aes[1] = ap_id;
		buffer_aes[2] = 0;
		buffer_aes[3] = 0;
		appl_write( ap_id, 16, &buffer_aes );
	}


	return;

}

