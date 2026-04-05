/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 30/12/2012 MaJ 14/02/2024 * */
/* ***************************** */




/* Fonction recherchant tous les TAG de configuration du coeur. */
/* Commun a toutes les applis GEM qui utilisent le Coeur        */


/*
 * 14/02/2024:  amelioration et nettoyage de l'usine a gaz que j'avais comis :p
 *   Merci a Pierre Tonthat pour l'inspiration donnée par ses sources encore une fois :)
 *   Au lieu d'une fonction qui lit tous les type de TAG, plusieurs fonctions optimisées
 *   pour lire un seul type de donnée.
 *   Plus d'alerte en cas d'erreur ou absence, juste un message en console si pas désactivé.
 *
 */



void Fcm_get_tag_config_generale( const char *pt_fichier_config )
{


	FCM_LOG_PRINT1( CRLF"* Fcm_get_tag_config_generale(%p)", pt_fichier_config );


	/* Sauvegarde Auto de la config */
	Fcm_save_option_auto = Fcm_get_tag_booleen( "SAUVEGARDE_AUTO=", pt_fichier_config, TRUE );
	FCM_LOG_PRINT1( "  Fcm_save_option_auto=%d", Fcm_save_option_auto );

	/* Sauvegarde position des fenetres */
	Fcm_save_winpos = Fcm_get_tag_booleen( "SAUVEGARDE_WINPOS=", pt_fichier_config, TRUE );
	FCM_LOG_PRINT1( "  Fcm_save_winpos=%d", Fcm_save_winpos );

	/* Quitter sur fermeture fenetre principale */
	Fcm_quit_closewin = Fcm_get_tag_booleen( "QUITTER_CLOSEWIN=", pt_fichier_config, TRUE );
	FCM_LOG_PRINT1( "  Fcm_quit_closewin=%d", Fcm_quit_closewin );

	Fcm_rsc_langage_code = Fcm_get_tag_int32( "RSC_LANGAGE=", pt_fichier_config );
	if( Fcm_rsc_langage_code < PLANG_ANGLAIS   ||   Fcm_rsc_langage_code > PLANG_RUSSE )
	{
		Fcm_rsc_langage_code = PLANG_FRANCAIS;  /* PLANG_xxxxx -> RSC definition dans POPUP_PREF_LANG */
	}
	FCM_LOG_PRINT1( "  Fcm_rsc_langage_code=%d", Fcm_rsc_langage_code );



	/* *********************** */
	/* ParamŠtres des fenetres */
	/* *********************** */
	if( Fcm_save_winpos == TRUE )
	{
		/* on charge les positions seulement si la sauvegarde est active */
		Fcm_get_win_parametre( pt_fichier_config );
	}


	return;


}

