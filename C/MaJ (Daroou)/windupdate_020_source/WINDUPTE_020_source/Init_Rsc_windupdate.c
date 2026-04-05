/* **[WindUpdate Test]********** */
/* *                           * */
/* * 20/12/2012 MaJ 29/01/2015 * */
/* ***************************** */



void init_rsc_windupdate( void )
{

	OBJECT	*adr_formulaire;



	#ifdef LOG_FILE
	sprintf( buf_log, "# Init RSC Wind Update"CRLF);
	log_print(FALSE);
	#endif


	/* on cherche l'adresse du formulaire */
	rsrc_gaddr( R_TREE, DL_WINDUPDATE, &adr_formulaire );

	/* Position barre de progression */
	(adr_formulaire+WU_POSITION_BAR)->ob_x     = 1;
	(adr_formulaire+WU_POSITION_BAR)->ob_width = 1;

	/* position cache avant */
	(adr_formulaire+WU_BAR_AVANT)->ob_x     = 0;
	(adr_formulaire+WU_BAR_AVANT)->ob_width = 1;

	/* position cache arriere */
	(adr_formulaire+WU_BAR_ARRIERE)->ob_x     = 2;
	(adr_formulaire+WU_BAR_ARRIERE)->ob_width = 1;



	/* Nombre redraw */
	Fcm_set_rsc_string( DL_WINDUPDATE, WU_REDRAW_START, "0" );

	/* Redraw effectuÇ */
	Fcm_set_rsc_string( DL_WINDUPDATE, WU_REDRAW_FINISH, "0" );
	Fcm_set_rsc_string( DL_WINDUPDATE, WU_CONSEC_FINISH, "0" );
	Fcm_set_rsc_string( DL_WINDUPDATE, WU_RECORD_FINISH, "0" );

	/* Redraw esquivÇ */
	Fcm_set_rsc_string( DL_WINDUPDATE, WU_REDRAW_SKIP, "0" );
	Fcm_set_rsc_string( DL_WINDUPDATE, WU_CONSEC_SKIP, "0" );
	Fcm_set_rsc_string( DL_WINDUPDATE, WU_RECORD_SKIP, "0" );



	{
		char buffer[16];

		sprintf( buffer, "%1x.%2x", systeme.aes_version>>8, systeme.aes_version&0xff );
		Fcm_set_rsc_string( DL_WINDUPDATE, WU_AES_VERSION, buffer );

		sprintf( buffer, "%1d", systeme.noblock );
		Fcm_set_rsc_string( DL_WINDUPDATE, WU_APPL_GETINFO, buffer );

	}



	/* on lance une premiäre fois pour initialiser l'affichage */
	/* correct de la bar defilante (calcul)                    */
	gestion_timer();


	return;


}

