/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 05/12/2003 MaJ 06/03/2024 * */
/* ***************************** */



#ifndef  ___FCM_GESTION_UNICONIFY_C___
#define  ___FCM_GESTION_UNICONIFY_C___


void Fcm_gestion_uniconify(void)
{
	int16 win_index;


	FCM_LOG_PRINT(CRLF"* Fcm_gestion_uniconify()");

	/* On cherche l'index de la fenetre */
	win_index = Fcm_get_indexwindow( buffer_aes[3] );

	/* S'il s'agit d'une fenetre qui nous appartient */
	if( win_index != FCM_NO_MY_WINDOW )
	{
		/* On d‚s-iconify et m‚morise son ‚tat */
		wind_set( buffer_aes[3], WF_UNICONIFY,  buffer_aes[4], buffer_aes[5], buffer_aes[6], buffer_aes[7] );

		win_iconified[win_index] = FALSE;

		/* L'AES redimensionne et place la fenetre dans son etat normal */
		/* et nous envoie un message de redraw sur cette fenetre        */
		Fcm_purge_aes_message();


		/* All uniconify ? */
		if( win_all_iconified_flag == FALSE )
		{
			/* Non, on peut quitter */
			return;
		}


		/* All uniconify */
		{
			uint16 dummy;

			/* On memorise l'etat */
			win_all_iconified_flag = FALSE;

			/* On cherche toutes les fenetres iconifi‚es et on les rouvre */
			for( dummy=0; dummy < NB_FENETRE; dummy++ )
			{
				if( win_iconified[dummy] == TRUE )
				{
					win_iconified[dummy] = FALSE;

					if( table_ft_ouvre_fenetre[dummy] != FCM_FONCTION_NON_DEFINI )
					{
						table_ft_ouvre_fenetre[dummy]();
					}
					else
					{
						Fcm_ouvre_fenetre(dummy, NULL);
					}

					Fcm_purge_aes_message();
				}
			}
		}
	}


	return;

}


#endif  /* ___FCM_GESTION_UNICONIFY_C___ */

