/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 09/01/2013 MaJ 23/02/2024 * */
/* ***************************** */


#ifndef ___FCM_SET_CONFIG_GENERALE_C___
#define ___FCM_SET_CONFIG_GENERALE_C___



void Fcm_set_config_generale( void )
{
	OBJECT	*adr_formulaire;
	OBJECT	*adr_menu;

UNUSED(adr_menu);

	FCM_LOG_PRINT("* Fcm_set_config_generale()");


	/* Adresse du dialogue pr‚f‚rence */
	adr_formulaire = Fcm_adr_RTREE[DL_OPT_PREF];

	/* Adresse du MENU */
	adr_menu = Fcm_adr_RTREE[BARRE_MENU];


	if( TRUE != 1   ||   FALSE != 0 )
	{
		FCM_CONSOLE_DEBUG2("TRUE(1) ou/et FALSE(0) sont incorrect TRUE=%d FALSE=%d", TRUE, FALSE );
		FCM_CONSOLE_DEBUG("Fcm_set_config_generale() code configuration n'est plus correct" );
	}


	/* ---------------------------- */
	/* Sauvegarde Auto de la config */
	/* ---------------------------- */
	SET_BIT_W( adr_formulaire[CHK_SAVE_AUTO].ob_state, OS_SELECTED, Fcm_save_option_auto);

//	menu_icheck( adr_menu, MN_SAUVER_CONFIG, 0 );
//	if( Fcm_save_option_auto==TRUE ) menu_icheck( adr_menu, MN_SAUVER_CONFIG, OS_CHECKED );

	/* ---------------------------- */
	/* Sauvegarde position fenetre  */
	/* ---------------------------- */
	SET_BIT_W( adr_formulaire[CHK_SAVE_WINPOS].ob_state, OS_SELECTED, Fcm_save_winpos );

	/* ---------------------------------------- */
	/* Quitter sur fermeture fenetre principale */
	/* ---------------------------------------- */
	SET_BIT_W( adr_formulaire[CHK_CLOSE_QUIT].ob_state, OS_SELECTED, Fcm_quit_closewin );

	/* ---------------------------------------- */
	/* Langue du RSC                            */
	/* ---------------------------------------- */
	FCM_LOG_PRINT1(" Fcm_rsc_langage_code=%d", Fcm_rsc_langage_code);
	FCM_LOG_PRINT1(" Texte={%s}", Fcm_adr_RTREE[POPUP_PREF_LANG][Fcm_rsc_langage_code].ob_spec.free_string);
//FCM_CONSOLE_DEBUG1(" Fcm_rsc_langage_code=%d", Fcm_rsc_langage_code);
//FCM_CONSOLE_DEBUG1(" Texte={%s}", Fcm_adr_RTREE[POPUP_PREF_LANG][Fcm_rsc_langage_code].ob_spec.free_string);

	if( Fcm_adr_RTREE[POPUP_PREF_LANG][Fcm_rsc_langage_code].ob_type != G_STRING )
	{
		FCM_CONSOLE_DEBUG("PopUP Langue: mettre les champs en G_STRING");
	}

	Fcm_set_rsc_string( DL_OPT_PREF, PREF_POPUP_LANG, Fcm_adr_RTREE[POPUP_PREF_LANG][Fcm_rsc_langage_code].ob_spec.free_string );


	/* ---------------------------------------- */
	/* Titre des fenêtres                       */
	/* ---------------------------------------- */
	snprintf( fcm_win_titre_texte[W_INFO_PRG], FCM_WIN_TITRE_MAXSIZE, "%s", Fcm_adr_RTREE[DL_TITRE_W_COEUR][ win_titre[W_INFO_PRG] ].ob_spec.free_string);
	snprintf( fcm_win_titre_texte[W_OPTION_PREFERENCE], FCM_WIN_TITRE_MAXSIZE, APP_WIN_PREFIX_TITRE" %s", Fcm_adr_RTREE[DL_TITRE_W_COEUR][ win_titre[W_OPTION_PREFERENCE] ].ob_spec.free_string);
	snprintf( fcm_win_titre_texte[W_CONSOLE], FCM_WIN_TITRE_MAXSIZE, APP_WIN_PREFIX_TITRE" Console");

	return;


}


#endif  /* ___FCM_SET_CONFIG_GENERALE_C___ */

