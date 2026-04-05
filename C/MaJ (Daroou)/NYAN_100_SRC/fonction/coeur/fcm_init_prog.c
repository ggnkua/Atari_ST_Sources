/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 20/01/2013 MaJ 03/03/2024 * */
/* ***************************** */



void Fcm_init_prog( void )
{

	/* ---------------------------------------- */
	/* Initialisation communes aux applications */
	/* ---------------------------------------- */

	FCM_LOG_PRINT("# Fcm_init_prog() (Coeur)");

	/* titre de chaque fenetre */
	win_titre[W_INFO_PRG          ] = TITRE_INFO;
	win_titre[W_OPTION_PREFERENCE ] = TITRE_PREFERENCE;


	/* attribut pour chaque fenetre */
	win_widgets[W_INFO_PRG          ] = NAME|CLOSER|MOVER|BACKDROP|SMALLER;
	win_widgets[W_OPTION_PREFERENCE ] = NAME|CLOSER|MOVER|BACKDROP|SMALLER;


	/* Numero des dialogue ou FCM_NO_RSC_DEFINED s'il y en a pas */
	win_rsc[ W_INFO_PRG          ] = DL_INFO_PRG;
	win_rsc[ W_OPTION_PREFERENCE ] = DL_OPT_PREF;


	/* Numero des dialogues pour le mode iconifi‚ ou FCM_NO_RSC_DEFINED s'il y en a pas */
	win_rsc_iconify[W_INFO_PRG         ] = DL_ICON_INFO;
	win_rsc_iconify[W_OPTION_PREFERENCE] = DL_ICON_PREF;


	/* Flag pour savoir si on doit acheminer l'event MOUSE bouton */
	/* a la fonction de gestion de la fenetre                     */
	/* FCM_MOUSE_THROUGH ou FCM_NO_MOUSE_THROUGH                  */
	win_mouse_through[ W_INFO_PRG          ] = FCM_NO_MOUSE_THROUGH;
	win_mouse_through[ W_OPTION_PREFERENCE ] = FCM_NO_MOUSE_THROUGH;


	/* Tableau pointeur de Fonction */
	/* si FCM_FONCTION_NON_DEFINI, c'est le Coeur qui s'en occupe */
	table_ft_ouvre_fenetre[ W_INFO_PRG          ] = FCM_FONCTION_NON_DEFINI;
	table_ft_ouvre_fenetre[ W_OPTION_PREFERENCE ] = FCM_FONCTION_NON_DEFINI;

	table_ft_ferme_fenetre[ W_INFO_PRG          ] = FCM_FONCTION_NON_DEFINI;
	table_ft_ferme_fenetre[ W_OPTION_PREFERENCE ] = FCM_FONCTION_NON_DEFINI;

	table_ft_redraw_win[ W_INFO_PRG          ]  = FCM_FONCTION_NON_DEFINI;
	table_ft_redraw_win[ W_OPTION_PREFERENCE ]  = FCM_FONCTION_NON_DEFINI;

	table_ft_refresh_win[ W_INFO_PRG          ] = FCM_FONCTION_NON_DEFINI;
	table_ft_refresh_win[ W_OPTION_PREFERENCE ] = FCM_FONCTION_NON_DEFINI;

	table_ft_gestion_win[ W_INFO_PRG          ] = Fcm_gestion_fenetre_info;
	table_ft_gestion_win[ W_OPTION_PREFERENCE ] = Fcm_gestion_fenetre_preference;


	/* ------------------------------------- */
	/* Initialisation locale … l'application */
	/* ------------------------------------- */

	FCM_LOG_PRINT(" -> start init_prog()");

	init_prog();

	FCM_LOG_PRINT(" FIN Fcm_init_prog()"CRLF);


	return;


}

