/* **[Pupul]******************** */
/* *                           * */
/* * 16/08/2014 MaJ 24/02/2015 * */
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
	win_titre[W_PUPUL]   = TITRE_PUPUL;
	win_titre[W_OPTIONS] = TITRE_OPTIONS;
	win_titre[W_MODLDG ] = TITRE_MODLDG;

	/* attribut pour chaque fenetre */
	win_widgets[W_PUPUL]   = NAME|INFO|CLOSER|MOVER|BACKDROP|SMALLER;
	win_widgets[W_OPTIONS] = NAME|CLOSER|MOVER|BACKDROP|SMALLER;
	win_widgets[W_MODLDG ] = NAME|CLOSER|MOVER|BACKDROP|SMALLER;




	#ifdef LOG_FILE
	sprintf( buf_log, " - Affectation Dialogue aux fenˆtres"CRLF);
	log_print(FALSE);
	#endif

	/* Numero des dialogues ou FCM_NO_RSC_DEFINED s'il y en a pas */
	win_rsc[ W_PUPUL   ] = FCM_NO_RSC_DEFINED;
	win_rsc[ W_OPTIONS ] = DL_OPTIONS;
	win_rsc[ W_MODLDG  ] = DL_MODLDG;

	/* Numero des dialogues pour le mode iconifi‚ ou FCM_NO_RSC_DEFINED s'il y en a pas */
	win_rsc_iconify[W_PUPUL  ] = FCM_NO_RSC_DEFINED;
	win_rsc_iconify[W_OPTIONS] = DL_ICON_OPTIONS;
	win_rsc_iconify[W_MODLDG ] = DL_ICON_MODLDG;


	#ifdef LOG_FILE
	sprintf( buf_log, " - Affectation Flag Mouse Through aux fenˆtres"CRLF);
	log_print(FALSE);
	#endif

	/* Flag pour savoir si on doit acheminer l'event MOUSE bouton */
	/* A la fonction de gestion de la fenetre                     */
	/* FCM_MOUSE_THROUGH ou FCM_NO_MOUSE_THROUGH                  */

	win_mouse_through[ W_PUPUL   ] = FCM_MOUSE_THROUGH;
	win_mouse_through[ W_OPTIONS ] = FCM_NO_MOUSE_THROUGH;
	win_mouse_through[ W_MODLDG  ] = FCM_NO_MOUSE_THROUGH;



	#ifdef LOG_FILE
	sprintf( buf_log, " - Affectation fonction ouverture aux fenˆtres"CRLF);
	log_print(FALSE);
	#endif

	/* Fonctions sp‚cifiques … l'application */
	table_ft_ouvre_fenetre[ W_PUPUL   ] = ouvre_fenetre_pupul;
	table_ft_ouvre_fenetre[ W_OPTIONS ] = FCM_FONCTION_NON_DEFINI; /* c'est le coeur qui s'en charge */
	table_ft_ouvre_fenetre[ W_MODLDG  ] = FCM_FONCTION_NON_DEFINI; /* c'est le coeur qui s'en charge */







	#ifdef LOG_FILE
	sprintf( buf_log, " - Affectation fonction redraw aux fenˆtres"CRLF);
	log_print(FALSE);
	#endif

	/* Fonctions sp‚cifiques … l'application */
	table_ft_redraw_win[ W_PUPUL   ] = redraw_fenetre_pupul;
	table_ft_redraw_win[ W_OPTIONS ] = FCM_FONCTION_NON_DEFINI; /* c'est le coeur qui s'en charge */
	table_ft_redraw_win[ W_MODLDG  ] = FCM_FONCTION_NON_DEFINI; /* c'est le coeur qui s'en charge */



	#ifdef LOG_FILE
	sprintf( buf_log, " - Affectation fonction refresh aux fenˆtres"CRLF);
	log_print(FALSE);
	#endif

	/* Fonctions sp‚cifiques … l'application */
/*	table_ft_refresh_win[ W_PUPUL ] =refresh_fenetre_pupul;*/






	#ifdef LOG_FILE
	sprintf( buf_log, " - Affectation fonction de gestion aux fenˆtres"CRLF""CRLF);
	log_print(FALSE);
	#endif

	/* Fonctions sp‚cifiques … l'application */
	table_ft_gestion_win[ W_PUPUL   ] = gestion_fenetre_pupul;
	table_ft_gestion_win[ W_OPTIONS ] = gestion_fenetre_options;
	table_ft_gestion_win[ W_MODLDG  ] = gestion_fenetre_mod;


	#ifdef LOG_FILE
	sprintf( buf_log, " - Affectation fonction fermeture aux fenˆtres"CRLF);
	log_print(FALSE);
	#endif

	/* Fonctions sp‚cifiques … l'application */
	table_ft_ferme_fenetre[ W_PUPUL   ] = fermer_fenetre_pupul;
	table_ft_ferme_fenetre[ W_OPTIONS ] = FCM_FONCTION_NON_DEFINI; /* c'est le coeur qui s'en charge */
	table_ft_ferme_fenetre[ W_MODLDG  ] = FCM_FONCTION_NON_DEFINI; /* c'est le coeur qui s'en charge */


	/* fonction appeler lors d'un changement de langue */
	/* pour ré-initialiser des objets / etc...         */
	Fcm_ft_rsc_init = reinit_rsc;




	return;


}

