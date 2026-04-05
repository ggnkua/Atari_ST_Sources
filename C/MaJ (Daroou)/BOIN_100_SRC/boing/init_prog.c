/* **[Boing]******************** */
/* *                           * */
/* * 20/09/2015 MaJ 09/05/2024 * */
/* ***************************** */


#include "reinit_rsc.c"



/* Fonction */
void init_prog( void )
{

	#ifdef LOG_FILE
	sprintf( buf_log, "# init_prog()  (local application)"CRLF);
	log_print( FALSE );
	#endif


	win_titre             [W_BOING] = TITRE_BOING;
	win_widgets           [W_BOING] = NAME|INFO|CLOSER|MOVER|BACKDROP|SMALLER;
	win_rsc               [W_BOING] = FCM_NO_RSC_DEFINED;
	win_rsc_iconify       [W_BOING] = FCM_NO_RSC_DEFINED;
	win_mouse_through     [W_BOING] = FCM_MOUSE_THROUGH;
	table_ft_ouvre_fenetre[W_BOING] = ouvre_fenetre_boing;
	table_ft_redraw_win   [W_BOING] = redraw_fenetre_boing;
	table_ft_gestion_win  [W_BOING] = gestion_fenetre_boing;
	table_ft_ferme_fenetre[W_BOING] = fermer_fenetre_boing;


	win_titre             [W_OPTIONS] = TITRE_OPTIONS;
	win_widgets           [W_OPTIONS] = NAME|CLOSER|MOVER|BACKDROP|SMALLER;
	win_rsc               [W_OPTIONS] = DL_OPTIONS;
	win_rsc_iconify       [W_OPTIONS] = DL_ICON_OPTIONS;
	win_mouse_through     [W_OPTIONS] = FCM_NO_MOUSE_THROUGH;
	table_ft_ouvre_fenetre[W_OPTIONS] = FCM_FONCTION_NON_DEFINI;
	table_ft_redraw_win   [W_OPTIONS] = FCM_FONCTION_NON_DEFINI;
	table_ft_gestion_win  [W_OPTIONS] = gestion_fenetre_options;
	table_ft_ferme_fenetre[W_OPTIONS] = FCM_FONCTION_NON_DEFINI;


	win_titre             [W_RAM] = TITRE_RAM;
	win_widgets           [W_RAM] = NAME|CLOSER|MOVER|BACKDROP|SMALLER;
	win_rsc               [W_RAM] = DL_RAM;
	win_rsc_iconify       [W_RAM] = DL_ICON_RAM;
	win_mouse_through     [W_RAM] = FCM_NO_MOUSE_THROUGH;
	table_ft_ouvre_fenetre[W_RAM] = FCM_FONCTION_NON_DEFINI;
	table_ft_redraw_win   [W_RAM] = FCM_FONCTION_NON_DEFINI;
	table_ft_gestion_win  [W_RAM] = gestion_fenetre_ram;
	table_ft_ferme_fenetre[W_RAM] = FCM_FONCTION_NON_DEFINI;


	/* fonction appeler lors d'un changement de langue */
	/* pour ré-initialiser des objets / etc...         */
	Fcm_ft_rsc_init = reinit_rsc;


	return;


}

