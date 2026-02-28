/* **[Fonction Commune]************** */
/* * Init Parametres des fenˆtres   * */
/* *                                * */
/* * 19/09/2002 = 09/01/2015        * */
/* ********************************** */



/* Prototype */
void Fcm_init_win_parametre( void );



/* Fonction */
void Fcm_init_win_parametre( void )
{

	int16	win_index, xywh;



	#ifdef LOG_FILE
	sprintf( buf_log, "  ## Fcm_init_win_parametre()"CRLF"  - init ParamŠtres Fenˆtre par d‚faut (%d fenetres)"CRLF, NB_FENETRE );
	log_print(FALSE);
	sprintf( buf_log, "  - init pointeur de fonction des fenetres"CRLF""CRLF );
	log_print(FALSE);
	#endif


	/* ----------------------------------------------- */
	/* * On Remplie notre tableu d'‚tat des fenˆtres * */
	/* ----------------------------------------------- */
	for( win_index=0; win_index<NB_FENETRE; win_index++ )
	{

		h_win            [win_index] = FCM_NO_OPEN_WINDOW;
		win_shaded       [win_index] = FALSE;
		win_rsc          [win_index] = FCM_NO_RSC_DEFINED;
		win_mouse_through[win_index] = FCM_NO_MOUSE_THROUGH;
		win_iconified    [win_index] = FALSE;

		table_ft_redraw_win   [win_index] = FCM_FONCTION_NON_DEFINI;
		table_ft_refresh_win  [win_index] = FCM_FONCTION_NON_DEFINI;
		table_ft_gestion_win  [win_index] = FCM_FONCTION_NON_DEFINI;
		table_ft_ouvre_fenetre[win_index] = FCM_FONCTION_NON_DEFINI;
		table_ft_ferme_fenetre[win_index] = FCM_FONCTION_NON_DEFINI;

		for( xywh=0; xywh<4; xywh++)
		{
			win_posxywh[win_index][xywh] = FCM_NO_WINPOS;
		}


	}





	return;


}

