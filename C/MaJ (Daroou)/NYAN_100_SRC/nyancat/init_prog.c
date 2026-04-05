/* **[NyanCat]****************** */
/* *                           * */
/* * 04/10/2014 MaJ 24/05/2018 * */
/* ***************************** */


#include "reinit_rsc.c"



/* Fonction */
void init_prog( void )
{

	#ifdef LOG_FILE
	sprintf( buf_log, "# init_prog()  (local application)"CRLF);
	log_print( FALSE );
	#endif


	/* titre de chaque fenetre */
	win_titre[W_NYANCAT] = TITRE_NYANCAT;
	win_titre[W_OPTIONS] = TITRE_OPTIONS;

	/* attribut pour chaque fenetre */
	win_widgets[W_NYANCAT] = NAME|INFO|CLOSER|MOVER|BACKDROP|SMALLER;
	win_widgets[W_OPTIONS] = NAME|CLOSER|MOVER|BACKDROP|SMALLER;


	
	#ifdef LOG_FILE
	sprintf( buf_log, " - Affectation Dialogue aux fenˆtres"CRLF);
	log_print(FALSE);
	#endif

	/* Numero des dialogue ou FCM_NO_RSC_DEFINED s'il y en a pas */
	win_rsc[ W_NYANCAT ] = FCM_NO_RSC_DEFINED;
	win_rsc[ W_OPTIONS ] = DL_OPTIONS;



	/* Numero des dialogues pour le mode iconifi‚ ou FCM_NO_RSC_DEFINED s'il y en a pas */
	win_rsc_iconify[W_NYANCAT] = DL_ICON_NYANCAT;
	win_rsc_iconify[W_OPTIONS] = DL_ICON_OPTIONS;



	#ifdef LOG_FILE
	sprintf( buf_log, " - Affectation Flag Mouse Through aux fenˆtres"CRLF);
	log_print(FALSE);
	#endif

	/* Flag pour savoir si on doit acheminer l'event MOUSE bouton */
	/* A la fonction de gestion de la fenetre                     */
	/* FCM_MOUSE_THROUGH ou FCM_NO_MOUSE_THROUGH                  */

	win_mouse_through[ W_NYANCAT ] = FCM_MOUSE_THROUGH;
	win_mouse_through[ W_OPTIONS ] = FCM_NO_MOUSE_THROUGH;




	#ifdef LOG_FILE
	sprintf( buf_log, " - Affectation fonction ouverture aux fenˆtres"CRLF);
	log_print(FALSE);
	#endif

	/* Fonctions sp‚cifiques … l'application */
	table_ft_ouvre_fenetre[ W_NYANCAT ] = ouvre_fenetre_nyancat;
	table_ft_ouvre_fenetre[ W_OPTIONS ] = FCM_FONCTION_NON_DEFINI; /* c'est le coeur qui s'en charge */








	#ifdef LOG_FILE
	sprintf( buf_log, " - Affectation fonction redraw aux fenˆtres"CRLF);
	log_print(FALSE);
	#endif

	/* Fonctions sp‚cifiques … l'application */
	table_ft_redraw_win[ W_NYANCAT ] = redraw_fenetre_nyancat;
	table_ft_redraw_win[ W_OPTIONS ] = FCM_FONCTION_NON_DEFINI; /* c'est le coeur qui s'en charge */




	#ifdef LOG_FILE
	sprintf( buf_log, " - Affectation fonction refresh aux fenˆtres"CRLF);
	log_print(FALSE);
	#endif

	/* Fonctions sp‚cifiques … l'application */
/*	table_ft_refresh_win[ W_NYANCAT ] = refresh_fenetre_xxxxxx;*/



	#ifdef LOG_FILE
	sprintf( buf_log, " - Affectation fonction de gestion aux fenˆtres"CRLF""CRLF);
	log_print(FALSE);
	#endif

	/* Fonctions sp‚cifiques … l'application */
	table_ft_gestion_win[ W_NYANCAT ] = gestion_fenetre_nyancat;
	table_ft_gestion_win[ W_OPTIONS ] = gestion_fenetre_options;



	#ifdef LOG_FILE
	sprintf( buf_log, " - Affectation fonction fermeture aux fenˆtres"CRLF);
	log_print(FALSE);
	#endif

	/* Fonctions sp‚cifiques … l'application */
	table_ft_ferme_fenetre[ W_NYANCAT ] = fermer_fenetre_nyancat;
	table_ft_ferme_fenetre[ W_OPTIONS ] = FCM_FONCTION_NON_DEFINI; /* c'est le coeur qui s'en charge */




	/* fonction appeler lors d'un changement de langue */
	/* pour ré-initialiser des objets / etc...         */
	Fcm_ft_rsc_init = reinit_rsc;


	return;


}

