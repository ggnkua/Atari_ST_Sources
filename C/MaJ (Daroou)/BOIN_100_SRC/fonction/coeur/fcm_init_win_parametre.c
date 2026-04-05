/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 19/09/2002 MaJ 03/03/2024 * */
/* ***************************** */



void Fcm_init_win_parametre( void )
{
	int16  win_index;
	int16  xywh;


	FCM_LOG_PRINT1("# Fcm_init_win_parametre()"CRLF"  NB_FENETRE=%d", NB_FENETRE);

	/* -------------------------------------------- */
	/* * On init les tableaux d'‚tat des fenˆtres * */
	/* -------------------------------------------- */
	for( win_index=0; win_index < NB_FENETRE; win_index++ )
	{
		h_win              [win_index]    = FCM_NO_OPEN_WINDOW;
		win_rsc            [win_index]    = FCM_NO_RSC_DEFINED;
		win_rsc_iconify    [win_index]    = FCM_NO_RSC_DEFINED;
		win_iconified      [win_index]    = FALSE;
		win_shaded         [win_index]    = FALSE;
		win_mouse_through  [win_index]    = FCM_NO_MOUSE_THROUGH;
		win_titre          [win_index]    = FCM_NO_WIN_TITRE;
		win_moved_scalex   [win_index]    = 0;

		strcpy( fcm_win_titre_texte[win_index], "Renaissance" );
		fcm_win_info_texte [win_index]    = NULL;

		table_ft_redraw_win   [win_index] = FCM_FONCTION_NON_DEFINI;
		table_ft_refresh_win  [win_index] = FCM_FONCTION_NON_DEFINI;
		table_ft_gestion_win  [win_index] = FCM_FONCTION_NON_DEFINI;
		table_ft_ouvre_fenetre[win_index] = FCM_FONCTION_NON_DEFINI;
		table_ft_ferme_fenetre[win_index] = FCM_FONCTION_NON_DEFINI;

		table_ft_gestion_widgets[win_index] = FCM_FONCTION_NON_DEFINI;
		table_ft_gestion_sized  [win_index] = FCM_FONCTION_NON_DEFINI;

		for( xywh=0; xywh < 4; xywh++)
		{
			win_posxywh[win_index][xywh]  = FCM_NO_WINPOS;
		}
	}


	return;


}

