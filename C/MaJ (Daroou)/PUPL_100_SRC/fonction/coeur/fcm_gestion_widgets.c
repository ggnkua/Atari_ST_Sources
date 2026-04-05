/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 28/12/2018 MaJ 06/03/2024 * */
/* ***************************** */



/*
 * fonction premiere version, en test...
 *
 */


void Fcm_gestion_widgets( void )
{
	int16 index_win;


	FCM_LOG_PRINT(CRLF"* Fcm_gestion_widgets");
	FCM_LOG_PRINT1("#Message(%d) (24: WM_ARROWED  25:WM_HSLID  26:WM_VSLID)", buffer_aes[0] );
	FCM_LOG_PRINT1(" buffer_aes[3]=%d (handle win)", buffer_aes[3] );
	FCM_LOG_PRINT4("buffer_aes[4]=%d buffer_aes[5]=%d buffer_aes[6]=%d buffer_aes[7]=%d : "CRLF, buffer_aes[4], buffer_aes[5], buffer_aes[6], buffer_aes[7] );

//FCM_CONSOLE_DEBUG1("---- #Message(%d) (24: WM_ARROWED  25:WM_HSLID  26:WM_VSLID)", buffer_aes[0] );
//FCM_CONSOLE_DEBUG1("buffer_aes[3]=%d (handle win)", buffer_aes[3] );
//FCM_CONSOLE_DEBUG4("buffer_aes[4]=%d buffer_aes[5]=%d buffer_aes[6]=%d buffer_aes[7]=%d : "CRLF, buffer_aes[4], buffer_aes[5], buffer_aes[6], buffer_aes[7] );


	/* buffer_aes[3] est l'handle AES de la fenetre    */
	/* on cherche son index dans notre liste (tableau) */
	index_win = Fcm_get_indexwindow( buffer_aes[3] );

//FCM_CONSOLE_ADD2("index_win=%d", index_win, G_GREEN );

	/* on verifie si c'est une de nos fenetres par s‚curit‚ */
	if( index_win != FCM_NO_MY_WINDOW )
	{
		FCM_LOG_PRINT("# Appel fonction dynamique gestion sliders - Fcm_gestion_widgets() ");
		FCM_LOG_PRINT2("  -> index_win=%d, adresse fonction=%p", index_win, table_ft_gestion_widgets[index_win] );


		if( table_ft_gestion_widgets[index_win] != FCM_FONCTION_NON_DEFINI )
		{
			table_ft_gestion_widgets[index_win]();
		}
		else
		{
			FCM_LOG_PRINT("# ERREUR !!! pas de fonction defini");
			FCM_CONSOLE_DEBUG("Fcm_gestion_widgets() : pas de fonction defini");
		}
	}
	else
	{
		FCM_LOG_PRINT(" ERREUR !!! index win");
		FCM_CONSOLE_DEBUG("Fcm_gestion_widgets() : erreur index win");
	}


	return;


}

