/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 17/11/2003 MaJ 02/03/2024 * */
/* ***************************** */



void Fcm_gestion_fenetre_preference( const int16 controlkey, const int16 touche, const int16 bouton )
{
	OBJECT	*adr_formulaire_preference;
	int16	objet;
	int16	clavier = FALSE;
	int16	commande = 0;


	FCM_LOG_PRINT3("#Fcm_gestion_fenetre_preference(%d,%d,%d)", controlkey,touche,bouton );


	adr_formulaire_preference = Fcm_adr_RTREE[DL_OPT_PREF];


	objet = objc_find( adr_formulaire_preference, 0, 4, souris.g_x, souris.g_y );


	if( touche )
	{
		switch( touche & 0xff)
		{
			case 0x0d:	/* Return */
				commande = 4;
				clavier = TRUE;
				break;
		}

		switch( touche & 0xff00)
		{
			case 0x0100:	/* ESCape */
				commande = 6;
				break;
		}

		if( controlkey==K_ALT )
		{
			switch( touche )
			{
				case 0x1000:	/* Alt-a */
					commande = 1;
					break;
				case 0x1400:	/* Alt-t */
					commande = 2;
					break;
				case 0x1F00:	/* Alt-s */
					commande = 4;
					clavier = TRUE;
					break;
			}

		}
	}



	if( bouton )
	{
		switch( objet )
		{
			case PREF_SAVE_AUTO:
			case CHK_SAVE_AUTO:
				commande = 1;
				break;

			case PREF_SAVE_WINPOS:
			case CHK_SAVE_WINPOS:
				commande = 2;
				break;

			case PREF_CLOSE_QUIT:
			case CHK_CLOSE_QUIT:
				commande = 3;
				break;

			case PREF_SAVE_CONFIG:
				commande = 4;
				break;

			case PREF_POPUP_LANG:
				commande = 5;
				break;
		}
	}



	/* ------------------------------------ */
	/* CheckBox : Sauver option en quittant */
	/* ------------------------------------ */
	if( commande == 1 )
	{
		/* On change l'‚tat de notre checkbox... */
		Fcm_gestion_bit_objet( adr_formulaire_preference,  h_win[W_OPTION_PREFERENCE], CHK_SAVE_AUTO, OS_SELECTED);

		Fcm_save_option_auto = FALSE;
		if( adr_formulaire_preference[CHK_SAVE_AUTO].ob_state & OS_SELECTED )
		{
//			menu_icheck( Fcm_adr_RTREE[BARRE_MENU], MN_SAUVER_CONFIG, OS_CHECKED );
			Fcm_save_option_auto = TRUE;
		}
		else
		{
//			menu_icheck( Fcm_adr_RTREE[BARRE_MENU], MN_SAUVER_CONFIG, 0 );
		}
	}



	/* ------------------------------------ */
	/* CheckBox : Sauver position fenetre   */
	/* ------------------------------------ */
	if( commande == 2 )
	{
		/* On change l'‚tat de notre checkbox... */
		Fcm_gestion_bit_objet( adr_formulaire_preference,  h_win[W_OPTION_PREFERENCE], CHK_SAVE_WINPOS, OS_SELECTED);

		Fcm_save_winpos = FALSE;
		if( adr_formulaire_preference[CHK_SAVE_WINPOS].ob_state & OS_SELECTED )
		{
			Fcm_save_winpos = TRUE;
		}
	}



	/* --------------------------------------------------- */
	/* CheckBox : quitter sur fermeture fenetre principale */
	/* --------------------------------------------------- */
	if( commande == 3 )
	{
		/* On change l'‚tat de notre checkbox... */
		Fcm_gestion_bit_objet( adr_formulaire_preference,  h_win[W_OPTION_PREFERENCE], CHK_CLOSE_QUIT, OS_SELECTED);

		Fcm_quit_closewin = FALSE;
		if( adr_formulaire_preference[CHK_CLOSE_QUIT].ob_state & OS_SELECTED )
		{
			Fcm_quit_closewin = TRUE;
		}
	}



	/* ------------------------- */
	/* Bouton Sauver les options */
	/* ------------------------- */
	if( commande == 4 )
	{
		/* Si le bouton a ‚t‚ activ‚ au clavier */
		if( clavier )
		{
			Fcm_objet_change( adr_formulaire_preference, h_win[W_OPTION_PREFERENCE], PREF_SAVE_CONFIG, OS_SELECTED );
			evnt_timer(FCM_BT_PAUSE_DOWN);
			Fcm_objet_change( adr_formulaire_preference, h_win[W_OPTION_PREFERENCE], PREF_SAVE_CONFIG, 0 );
			evnt_timer(FCM_BT_PAUSE_UP);
		}
		else
		{
			/* Activ‚ avec la souris */
			if( Fcm_gestion_objet_bouton( adr_formulaire_preference, h_win[W_OPTION_PREFERENCE], PREF_SAVE_CONFIG ) != PREF_SAVE_CONFIG )
			{
				/* Bouton non valid‚, on quitte */
				return;
			}
		}

		Fcm_sauver_config( TRUE );

		/* on garde la fenetre ouverte seulement si le bouton save */
		/* a été cliqué avec le bouton droit */
		if( bouton != 2 )
		{
			Fcm_fermer_fenetre( W_OPTION_PREFERENCE );
		}
	}



	/* ------------------------- */
	/* Pop Up langue             */
	/* ------------------------- */
	if( commande == 5 )
	{
		Fcm_gestion_preference_langue();
	}



	/* ------------------------- */
	/* Touche ESCape             */
	/* ------------------------- */
	if( commande == 6 )
	{
		Fcm_fermer_fenetre( W_OPTION_PREFERENCE );
	}


	return;


}

