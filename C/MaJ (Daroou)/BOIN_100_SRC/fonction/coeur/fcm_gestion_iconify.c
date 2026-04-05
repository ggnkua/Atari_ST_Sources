/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 05/12/2003 MaJ 27/02/2024 * */
/* ***************************** */



#ifndef ___FCM_GESTION_ICONIFY_C___
#define ___FCM_GESTION_ICONIFY_C___



void Fcm_gestion_iconify( void )
{
	int16 win_index;


	FCM_LOG_PRINT1("#Fcm_gestion_iconify( MSG=%d (34 iconify, 36 all iconify) )", buffer_aes[0]);

	/* Gestion des iconifications des fenetres */
	/* En cas d'iconification globale (Control+smaller), c'est la fenetre */
	/* cliqu‚ qui sera iconifi‚ et donnera son 'motif' pour le contenu    */

	win_index = Fcm_get_indexwindow( buffer_aes[3] );


	if( win_index != FCM_NO_MY_WINDOW )
	{
		if( buffer_aes[0] == WM_ICONIFY )
		{
			wind_set( buffer_aes[3], WF_ICONIFY, buffer_aes[4], buffer_aes[5], buffer_aes[6], buffer_aes[7] );
			win_iconified[win_index]=TRUE;

			return;
		}


		if( buffer_aes[0] == WM_ALLICONIFY )
		{
			int16 myindex;

			for( myindex=0; myindex < NB_FENETRE; myindex++)
			{
				if( h_win[myindex] > 0   &&   myindex != win_index )
				{
					win_iconified[myindex] = TRUE;
					Fcm_fermer_fenetre(myindex);
					Fcm_purge_aes_message();
				}
			}

			wind_set( h_win[win_index], WF_ICONIFY, buffer_aes[4], buffer_aes[5], buffer_aes[6], buffer_aes[7] );
			win_iconified[win_index] = TRUE;
			win_all_iconified_flag = TRUE;

			return;
		}
	}


	return;

}


#endif  /* ___FCM_GESTION_ICONIFY_C___ */


