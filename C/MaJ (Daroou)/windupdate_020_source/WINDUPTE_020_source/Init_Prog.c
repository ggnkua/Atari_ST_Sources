/* **[WindUpdate]*************** */
/* *                           * */
/* * 20/12/2012 MaJ 29/01/2015 * */
/* ***************************** */



void init_prog( void )
{


	#ifdef LOG_FILE
	sprintf( buf_log, TAB8"# init_prog() (local application)"CRLF);
	log_print( FALSE );
	sprintf( buf_log, TAB8" - Affectation Dialogue aux fenˆtres"CRLF);
	log_print(FALSE);
	#endif


	/* Numero des dialogue ou FCM_NO_WIN_RSC s'il y en a pas */
	win_rsc[ W_WINDUPDATE ] = DL_WINDUPDATE;


	/* Numero des dialogues pour le mode iconifi‚ ou FCM_NO_WIN_RSC s'il y en a pas */
	win_rsc_iconify[ W_WINDUPDATE ] = DL_ICON_WINDUPTE;




	#ifdef LOG_FILE
	sprintf( buf_log, TAB8" - Affectation Flag Mouse Through aux fenˆtres"CRLF);
	log_print(FALSE);
	#endif


	/* Flag pour savoir si on doit acheminer l'event MOUSE bouton */
	/* A la fonction de gestion de la fenetre                     */
	/* FCM_MOUSE_THROUGH ou FCM_NO_MOUSE_THROUGH                  */
	win_mouse_through[ W_WINDUPDATE ] = FCM_NO_MOUSE_THROUGH;





	#ifdef LOG_FILE
	sprintf( buf_log, TAB8" - Affectation fonction ouverture aux fenˆtres"CRLF);
	log_print(FALSE);
	#endif

	/* Pointeur de fonction pour l'ouverure de fenetre */
	table_ft_ouvre_fenetre[ W_WINDUPDATE ] = ouvre_fenetre_windupdate;





	#ifdef LOG_FILE
	sprintf( buf_log, TAB8" - Affectation fonction redraw aux fenˆtres"CRLF);
	log_print(FALSE);
	#endif

	/* Pointeur de fonction pour le redraw de fenetre */
	table_ft_redraw_win[ W_WINDUPDATE ] = redraw_fenetre_windupdate;




	#ifdef LOG_FILE
	sprintf( buf_log, TAB8" - Affectation fonction refresh aux fenˆtres"CRLF);
	log_print(FALSE);
	#endif

	/* Pointeur de fonction pour le refresh de fenetre aprŠs un redraw partiel */
	table_ft_refresh_win[ W_WINDUPDATE ] = refresh_fenetre_windupdate;





	#ifdef LOG_FILE
	sprintf( buf_log, TAB8" - Affectation fonction de gestion aux fenˆtres"CRLF);
	log_print(FALSE);
	#endif

	/* Pointeur de fonction pour la gestion de la fenetre */
	table_ft_gestion_win[ W_WINDUPDATE ] = gestion_fenetre_windupdate;


	return;


}

