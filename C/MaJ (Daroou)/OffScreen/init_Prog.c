/* **[Offscreen]**************** */
/* *                           * */
/* * 10/12/2015 MaJ 31/12/2015 * */
/* ***************************** */


#include "init_rsc.c"



/* Fonction */
void init_prog( void )
{


	#ifdef LOG_FILE
	sprintf( buf_log, "# init_prog()  (local application)"CRLF);
	log_print( FALSE );
	#endif


	#ifdef LOG_FILE
	sprintf( buf_log, " - Affectation Dialogue aux fenˆtres"CRLF);
	log_print(FALSE);
	#endif

	/* Numero des dialogues ou FCM_NO_WIN_RSC s'il y en a pas */
	win_rsc[ W_OFFSCREEN        ] = FCM_NO_WIN_RSC;
	win_rsc[ W_SPRITE_OFFSCREEN ] = FCM_NO_WIN_RSC;
	win_rsc[ W_STATS            ] = DL_STATS;
	win_rsc[ W_ADRESSE          ] = DL_ADRESSE;
	win_rsc[ W_BENCH            ] = DL_BENCH;
	win_rsc[ W_INFOSYS          ] = DL_INFO_SYSTEM;


	/* Numero des dialogues pour le mode iconifi‚ ou FCM_NO_WIN_RSC s'il y en a pas */
	win_rsc_iconify[ W_OFFSCREEN        ] = FCM_NO_WIN_RSC;
	win_rsc_iconify[ W_SPRITE_OFFSCREEN ] = FCM_NO_WIN_RSC;
	win_rsc_iconify[ W_STATS            ] = DL_ICN_STATS;
	win_rsc_iconify[ W_ADRESSE          ] = DL_ICN_ADRESSE;
	win_rsc_iconify[ W_BENCH            ] = DL_ICN_BENCH;
	win_rsc_iconify[ W_INFOSYS          ] = DL_ICN_INFO;



	#ifdef LOG_FILE
	sprintf( buf_log, " - Affectation Flag Mouse Through aux fenˆtres"CRLF);
	log_print(FALSE);
	#endif

	/* Flag pour savoir si on doit acheminer l'event MOUSE bouton */
	/* A la fonction de gestion de la fenetre                     */
	/* FCM_MOUSE_THROUGH ou FCM_NO_MOUSE_THROUGH                  */

	win_mouse_through[ W_OFFSCREEN        ] = FCM_MOUSE_THROUGH;
	win_mouse_through[ W_SPRITE_OFFSCREEN ] = FCM_NO_MOUSE_THROUGH;
	win_mouse_through[ W_STATS            ] = FCM_NO_MOUSE_THROUGH;
	win_mouse_through[ W_ADRESSE          ] = FCM_NO_MOUSE_THROUGH;
	win_mouse_through[ W_BENCH            ] = FCM_NO_MOUSE_THROUGH;
	win_mouse_through[ W_INFOSYS          ] = FCM_NO_MOUSE_THROUGH;



	#ifdef LOG_FILE
	sprintf( buf_log, " - Affectation fonction ouverture aux fenˆtres"CRLF);
	log_print(FALSE);
	#endif

	/* Fonctions sp‚cifiques … l'application */
	table_ft_ouvre_fenetre[ W_OFFSCREEN        ] = ouvre_fenetre_offscreen;
	table_ft_ouvre_fenetre[ W_SPRITE_OFFSCREEN ] = ouvre_fenetre_sprite_offscreen;
	table_ft_ouvre_fenetre[ W_STATS            ] = ouvre_fenetre_stats;
	table_ft_ouvre_fenetre[ W_ADRESSE          ] = ouvre_fenetre_adresse;
	table_ft_ouvre_fenetre[ W_BENCH            ] = ouvre_fenetre_bench;
	table_ft_ouvre_fenetre[ W_INFOSYS          ] = ouvre_fenetre_info;






	#ifdef LOG_FILE
	sprintf( buf_log, " - Affectation fonction redraw aux fenˆtres"CRLF);
	log_print(FALSE);
	#endif

	/* Fonctions sp‚cifiques … l'application */
	table_ft_redraw_win[ W_OFFSCREEN        ] = redraw_fenetre_offscreen;
	table_ft_redraw_win[ W_SPRITE_OFFSCREEN ] = redraw_fenetre_sprite_offscreen;
	table_ft_redraw_win[ W_STATS            ] = redraw_fenetre_stats;
	table_ft_redraw_win[ W_ADRESSE          ] = redraw_fenetre_adresse;
	table_ft_redraw_win[ W_BENCH            ] = redraw_fenetre_bench;
	table_ft_redraw_win[ W_INFOSYS          ] = redraw_fenetre_info;




	#ifdef LOG_FILE
	sprintf( buf_log, " - Affectation fonction refresh aux fenˆtres"CRLF);
	log_print(FALSE);
	#endif

	/* Fonctions sp‚cifiques … l'application */
/*	table_ft_refresh_win[ W_BOING ] = refresh_fenetre_boing;*/






	#ifdef LOG_FILE
	sprintf( buf_log, " - Affectation fonction de gestion aux fenˆtres"CRLF""CRLF);
	log_print(FALSE);
	#endif

	/* Fonctions sp‚cifiques … l'application */
	table_ft_gestion_win[ W_OFFSCREEN        ] = gestion_fenetre_offscreen;
	table_ft_gestion_win[ W_SPRITE_OFFSCREEN ] = FCM_FONCTION_NON_DEFINI;
	table_ft_gestion_win[ W_STATS            ] = gestion_fenetre_stats;
	table_ft_gestion_win[ W_ADRESSE          ] = gestion_fenetre_adresse;
	table_ft_gestion_win[ W_BENCH            ] = gestion_fenetre_bench;
	table_ft_gestion_win[ W_INFOSYS          ] = FCM_FONCTION_NON_DEFINI;




	#ifdef LOG_FILE
	sprintf( buf_log, " - Affectation fonction fermeture aux fenˆtres"CRLF);
	log_print(FALSE);
	#endif

	/* Fonctions sp‚cifiques … l'application */
	table_ft_ferme_fenetre[ W_OFFSCREEN        ] = fermer_fenetre_offscreen;
	table_ft_ferme_fenetre[ W_SPRITE_OFFSCREEN ] = fermer_fenetre_sprite_offscreen;
	table_ft_ferme_fenetre[ W_STATS            ] = fermer_fenetre_stats;
	table_ft_ferme_fenetre[ W_ADRESSE          ] = fermer_fenetre_adresse;
	table_ft_ferme_fenetre[ W_BENCH            ] = fermer_fenetre_bench;
	table_ft_ferme_fenetre[ W_INFOSYS          ] = fermer_fenetre_info;





/*	#ifdef LOG_FILE
	sprintf( buf_log, " - Affectation de la fonction Task TIMER"CRLF);
	log_print(FALSE);
	#endif

	fcm_ft_task_timer = gestion_timer;*/



	#ifdef LOG_FILE
	sprintf( buf_log, " - Affectation de la fonction rsc init"CRLF);
	log_print(FALSE);
	#endif

	Fcm_ft_rsc_init = init_rsc;

	return;


}

