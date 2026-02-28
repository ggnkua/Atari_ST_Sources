/* **[Fonction Coeur]********* */
/* *                         * */
/* * 09/01/2013 # 11/01/2015 * */
/* *************************** */


#ifndef ___Fcm_set_config_generale___
#define ___Fcm_set_config_generale___



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
	}


	/* ---------------------------- */
	/* Sauvegarde position fenetre  */
	/* ---------------------------- */
	{
		if( Fcm_save_winpos==TRUE )
		{
			/* Sauvegarde position */
			SET_BIT_W( adr_formulaire[PREF_SAVE_WINPOS].ob_state, OS_SELECTED, 1);
		}
		else
		{
			/* Pas de sauvegarde */
			SET_BIT_W( adr_formulaire[PREF_SAVE_WINPOS].ob_state, OS_SELECTED, 0);
		}
	}



	/* ---------------------------------------- */
	/* Quitter sur fermeture fenetre principale */
	/* ---------------------------------------- */
	{
		if( Fcm_quit_closewin==TRUE )
		{
			/* Quitter */
			SET_BIT_W( adr_formulaire[PREF_CLOSE_QUIT].ob_state, OS_SELECTED, 1);
		}
		else
		{
			/* fermer fenetre */
			SET_BIT_W( adr_formulaire[PREF_CLOSE_QUIT].ob_state, OS_SELECTED, 0);
		}
	}




	/* ---------------------------------------- */
	/* Langue du RSC                            */
	/* ---------------------------------------- */
	{
		OBJECT	*adr_popup;

		/* Adresse du pop up langue */
		rsrc_gaddr( R_TREE, POPUP_PREF_LANG, &adr_popup );

		Fcm_set_rsc_string( DL_OPT_PREF, PREF_POPUP_LANG, adr_popup[Fcm_rsc_langage_code].ob_spec.tedinfo->te_ptext );
	}






	{
		/* On d‚sactive le bouton de sauvergarde des options */
/*		SET_BIT_W( (adr_formulaire+PREF_SAVE_CONFIG)->ob_state, OS_DISABLED, 1);*/
	}


	return;


}



#endif  /* ___Fcm_set_config_generale___ */

