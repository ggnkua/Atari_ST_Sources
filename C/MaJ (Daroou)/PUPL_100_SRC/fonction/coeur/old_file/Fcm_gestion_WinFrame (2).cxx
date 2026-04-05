/* ****************************** */
/* * Gestion ‚tat winframe      * */
/* * 27/02/2004  =  06/04/2013  * */
/* ****************************** */


/* Prototype */
void Fcm_gestion_winframe( const uint32 flag );


/* Fonction */
void Fcm_gestion_winframe( const uint32 flag )
{
/*
 * extern int16  h_win[NB_FENETRE];
 * extern int16  buffer_aes[16];
 * extern uint32 winframe_flag;
 */

	#ifdef LOG_FILE
	sprintf( buf_log, "#Gestion WinFrame(%ld)"CRLF, flag );
	log_print(FALSE);
	#endif




	/* On demande de retirer le winframe */
	if( flag==FALSE )
	{
		/* on d‚sactive le winframe */
		if(Fcm_adr_buf_windframe)
		{
			Fcm_libere_ram(Fcm_adr_buf_windframe);
			Fcm_adr_buf_windframe=NULL;			/* Buffer Malloc()         */
			Fcm_adr_win_frame=NULL;				/* adresse d‚part winframe */
		}
		Fcm_winframe_flag=FALSE;

		#ifdef LOG_FILE
		sprintf( buf_log, "# WinFrame retir‚"CRLF );
		log_print(FALSE);
		#endif

		return;
	}




	/* On demande de mettre en place le windframe */
	if( flag==TRUE && Fcm_adr_buf_windframe==NULL )
	{
		/* on (r‚)active le winframe */
		Fcm_init_win_frame();

		/* si l'init_win_frame a ‚chou‚ winframe_flag est mis … FALSE */
		if( Fcm_winframe_flag==FALSE )
		{
			/* ‚chec de l'activation du winframe */
			Fcm_form_alerte( 0, ALT_WINFRAME_ERR );
		}
		else
		{
			#ifdef LOG_FILE
			sprintf( buf_log, "# WinFrame activ‚"CRLF );
			log_print(FALSE);
			#endif
		}
	}


	return;


}


