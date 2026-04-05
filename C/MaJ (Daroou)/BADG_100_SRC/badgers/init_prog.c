/* **[Badgers]****************** */
/* *                           * */
/* * 24/10/2015 MaJ 12/11/2023 * */
/* ***************************** */

#include "reinit_rsc.c"





void init_prog( void )
{


#ifdef LOG_FILE
sprintf( buf_log, "# init_prog()  (local application)"CRLF);
log_print( FALSE );
#endif



	/* titre de chaque fenetre */
	win_titre[W_BADGERS] = TITRE_BADGERS;
	win_titre[W_OPTIONS] = TITRE_OPTIONS;

	/* attribut pour chaque fenetre */
	win_widgets[W_BADGERS] = NAME|INFO|CLOSER|MOVER|BACKDROP|SMALLER;
	win_widgets[W_OPTIONS] = NAME|CLOSER|MOVER|BACKDROP|SMALLER;






	#ifdef LOG_FILE
	sprintf( buf_log, " - Affectation Dialogue aux fenˆtres"CRLF);
	log_print(FALSE);
	#endif

	/* Numero des dialogues ou FCM_NO_RSC_DEFINED s'il y en a pas */
	win_rsc[ W_BADGERS ] = FCM_NO_RSC_DEFINED;
	win_rsc[ W_OPTIONS ] = DL_OPTIONS;


	/* Numero des dialogues pour le mode iconifi‚ ou FCM_NO_RSC_DEFINED s'il y en a pas */
	win_rsc_iconify[ W_BADGERS ] = FCM_NO_RSC_DEFINED;
	win_rsc_iconify[ W_OPTIONS ] = DL_ICON_OPTIONS;



	#ifdef LOG_FILE
	sprintf( buf_log, " - Affectation Flag Mouse Through aux fenˆtres"CRLF);
	log_print(FALSE);
	#endif

	/* Flag pour savoir si on doit acheminer l'event MOUSE bouton */
	/* A la fonction de gestion de la fenetre                     */
	/* FCM_MOUSE_THROUGH ou FCM_NO_MOUSE_THROUGH                  */

	win_mouse_through[ W_BADGERS ] = FCM_MOUSE_THROUGH;
	win_mouse_through[ W_OPTIONS ] = FCM_NO_MOUSE_THROUGH;



	#ifdef LOG_FILE
	sprintf( buf_log, " - Affectation fonction ouverture aux fenˆtres"CRLF);
	log_print(FALSE);
	#endif

	/* Fonctions sp‚cifiques … l'application */
	table_ft_ouvre_fenetre[ W_BADGERS ] = ouvre_fenetre_badgers;
	table_ft_ouvre_fenetre[ W_OPTIONS ] = FCM_FONCTION_NON_DEFINI; /* c'est le coeur qui s'en charge */





	#ifdef LOG_FILE
	sprintf( buf_log, " - Affectation fonction redraw aux fenˆtres"CRLF);
	log_print(FALSE);
	#endif

	/* Fonctions sp‚cifiques … l'application */
	table_ft_redraw_win[ W_BADGERS ] = redraw_fenetre_badgers;
	table_ft_redraw_win[ W_OPTIONS ] = FCM_FONCTION_NON_DEFINI; /* c'est le coeur qui s'en charge */




	#ifdef LOG_FILE
	sprintf( buf_log, " - Affectation fonction refresh aux fenˆtres"CRLF);
	log_print(FALSE);
	#endif

	/* Fonctions sp‚cifiques … l'application */
/*	table_ft_refresh_win[ W_BADGERS ] = refresh_fenetre_badgers;*/






	#ifdef LOG_FILE
	sprintf( buf_log, " - Affectation fonction de gestion aux fenˆtres"CRLF""CRLF);
	log_print(FALSE);
	#endif

	/* Fonctions sp‚cifiques … l'application */
	table_ft_gestion_win[ W_BADGERS ] = gestion_fenetre_badgers;
	table_ft_gestion_win[ W_OPTIONS ] = gestion_fenetre_options;



	#ifdef LOG_FILE
	sprintf( buf_log, " - Affectation fonction fermeture aux fenˆtres"CRLF);
	log_print(FALSE);
	#endif

	/* Fonctions sp‚cifiques … l'application */
	table_ft_ferme_fenetre[ W_BADGERS ] = fermer_fenetre_badgers;
	table_ft_ferme_fenetre[ W_OPTIONS ] = FCM_FONCTION_NON_DEFINI; /* c'est le coeur qui s'en charge */



	/* fonction appeler lors d'un changement de langue */
	/* pour ré-initialiser des objets / etc...         */
	Fcm_ft_rsc_init = reinit_rsc;



	return;


}

