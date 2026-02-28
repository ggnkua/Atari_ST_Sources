/* **[Focntion commune]***** */
/* *                       * */
/* * 20/01/2013 10/01/2015 * */
/* ************************* */


/* Prototype */
void Fcm_init_prog( void );


/* Fonction */
void Fcm_init_prog( void )
{
	#ifdef ___FENETRE_LAUNCH___
	#error "___FENETRE_LAUNCH___ non defini"
	#endif

	/* ---------------------------------------- */
	/* Initialisation communes aux applications */
	/* ---------------------------------------- */

	#ifdef LOG_FILE
	sprintf( buf_log, "  ## Fcm_init_prog() (coeur)"CRLF);
	log_print( FALSE );
	#endif


	#ifdef LOG_FILE
	sprintf( buf_log, "  - Affectation Dialogue aux fenˆtres"CRLF);
	log_print(FALSE);
	#endif


	/* Numero des dialogue ou FCM_NO_WIN_RSC s'il y en a pas */
	win_rsc[ W_INFO_PRG          ] = DL_INFO_PRG;
	win_rsc[ W_OPTION_PREFERENCE ] = DL_OPT_PREF;


	/* Numero des dialogues pour le mode iconifi‚ ou FCM_NO_WIN_RSC s'il y en a pas */
	win_rsc_iconify[W_INFO_PRG         ] = DL_ICON_INFO;
	win_rsc_iconify[W_OPTION_PREFERENCE] = DL_ICON_PREF;



	#ifdef LOG_FILE
	sprintf( buf_log, "  - Affectation Flag Mouse Through aux fenˆtres"CRLF);
	log_print(FALSE);
	#endif

	/* Flag pour savoir si on doit acheminer l'event MOUSE bouton */
	/* A la fonction de gestion de la fenetre                     */
	/* FCM_MOUSE_THROUGH ou FCM_NO_MOUSE_THROUGH                  */
	win_mouse_through[ W_INFO_PRG          ] =FCM_NO_MOUSE_THROUGH;
	win_mouse_through[ W_OPTION_PREFERENCE ] =FCM_NO_MOUSE_THROUGH;




	#ifdef LOG_FILE
	sprintf( buf_log, "  - Affectation fonction ouverture aux fenˆtres"CRLF);
	log_print(FALSE);
	#endif
	/* Fonctions communes aux application */
	table_ft_ouvre_fenetre[ W_INFO_PRG          ] = Fcm_ouvre_fenetre_info;
	table_ft_ouvre_fenetre[ W_OPTION_PREFERENCE ] = Fcm_ouvre_fenetre_preference;



	#ifdef LOG_FILE
	sprintf( buf_log, "  - Affectation fonction de fermeture aux fenˆtres"CRLF);
	log_print(FALSE);
	#endif
	/* Fonctions communes aux application */
	table_ft_ferme_fenetre[ W_INFO_PRG          ] =FCM_FONCTION_NON_DEFINI;
	table_ft_ferme_fenetre[ W_OPTION_PREFERENCE ] =FCM_FONCTION_NON_DEFINI;




	#ifdef LOG_FILE
	sprintf( buf_log, "  - Affectation fonction redraw aux fenˆtres"CRLF);
	log_print(FALSE);
	#endif
	/* Fonctions communes aux application */
	table_ft_redraw_win[ W_INFO_PRG          ] = Fcm_redraw_fenetre_info;
	table_ft_redraw_win[ W_OPTION_PREFERENCE ] = Fcm_redraw_fenetre_preference;



	#ifdef LOG_FILE
	sprintf( buf_log, "  - Affectation fonction refresh aux fenˆtres"CRLF);
	log_print(FALSE);
	#endif
	/* Fonctions communes aux application */
	table_ft_refresh_win[ W_INFO_PRG          ] =FCM_FONCTION_NON_DEFINI;
	table_ft_refresh_win[ W_OPTION_PREFERENCE ] =FCM_FONCTION_NON_DEFINI;



	#ifdef LOG_FILE
	sprintf( buf_log, "  - Affectation fonction de gestion aux fenˆtres"CRLF""CRLF);
	log_print(FALSE);
	#endif

	/* Fonctions communes aux application */
	table_ft_gestion_win[ W_INFO_PRG          ] =FCM_FONCTION_NON_DEFINI;
	table_ft_gestion_win[ W_OPTION_PREFERENCE ] =Fcm_gestion_fenetre_preference;





	/* ------------------------------------- */
	/* Initialisation locale … l'application */
	/* ------------------------------------- */
	#ifdef LOG_FILE
	sprintf( buf_log, "  - init_prog() (local aplication)"CRLF""CRLF);
	log_print(FALSE);
	#endif

	init_prog();




	return;


}

