/* **[Fonction Coeur]********* */
/* *                         * */
/* * 09/01/2013 # 11/01/2015 * */
/* *************************** */


/* Prototype */
void Fcm_set_config_generale( void );


/* Fonction */
void Fcm_set_config_generale( void )
{
	OBJECT	*adr_formulaire;
	OBJECT	*adr_menu;



	#ifdef LOG_FILE
	sprintf( buf_log, CRLF""TAB8"* Fcm_set_config_generale()"CRLF );
	log_print( FALSE );
	#endif




	/* Adresse du dialogue pr‚f‚rence */
	rsrc_gaddr( R_TREE, DL_OPT_PREF, &adr_formulaire );

	/* on cherche l'adresse du MENU */
	rsrc_gaddr( R_TREE, BARRE_MENU, &adr_menu);



	/* ---------------------------- */
	/* Sauvegarde Auto de la config */
	/* ---------------------------- */
	{
		if( Fcm_save_option_auto==TRUE )
		{
			/* Sauvegarde auto */
			menu_icheck( adr_menu, MN_SAUVER_CONFIG, OS_CHECKED );
			SET_BIT_W( (adr_formulaire+PREF_SAVE_AUTO)->ob_state, OS_SELECTED, 1);

		}
		else
		{
			/* Pas de sauvegarde */
			menu_icheck( adr_menu, MN_SAUVER_CONFIG, 0 );
			SET_BIT_W( (adr_formulaire+PREF_SAVE_AUTO)->ob_state, OS_SELECTED, 0);

		}


		/* On d‚sactive le bouton de sauvergarde des options */
		SET_BIT_W( (adr_formulaire+PREF_SAVE_CONFIG)->ob_state, OS_DISABLED, 1);

	}


	return;


}

