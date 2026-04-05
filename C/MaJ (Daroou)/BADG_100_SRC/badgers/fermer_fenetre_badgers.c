/* **[Badgers]****************** */
/* *                           * */
/* * 24/10/2015 MaJ 19/12/2015 * */
/* ***************************** */

void fermer_fenetre_badgers( void );






void fermer_fenetre_badgers( void )
{

#ifdef LOG_FILE
sprintf( buf_log, "# fermer_fenetre_badgers"CRLF );
log_print(FALSE);
#endif



	/* Doit-on fermer une fenetre ou toutes ? */
	if( Fcm_quit_closewin == TRUE )
	{
#ifdef LOG_FILE
sprintf( buf_log, " ~ APP_TERM "CRLF );
log_print(FALSE);
#endif

		buffer_aes[0]=AP_TERM;
		buffer_aes[1]=ap_id;
		buffer_aes[2]=0;
		buffer_aes[3]=0;
		appl_write( ap_id, 16, &buffer_aes );

	}
	else
	{
		wind_close ( h_win[W_BADGERS] );	/* on ferme la fenetre */
		wind_delete( h_win[W_BADGERS] );	/* et on l'efface      */

		h_win[W_BADGERS]=FCM_NO_OPEN_WINDOW;	/* on m‚morise sa fermeture */

#ifdef LOG_FILE
sprintf( buf_log, " ~ fenˆtre badgers ferm‚"CRLF );
log_print(FALSE);
#endif

	}


	return;


}

