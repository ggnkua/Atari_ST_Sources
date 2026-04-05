/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 27/11/2003 MaJ 03/03/2024 * */
/* ***************************** */



#ifndef ___FCM_OUVRE_FENETRE_START_C___
#define ___FCM_OUVRE_FENETRE_START_C___


void Fcm_ouvre_fenetre_start( void )
{
	uint16	win_index;


	FCM_LOG_PRINT(CRLF"# Fcm_ouvre_fenetre_start()");

	/*
	 * les fenetres du programme commence à l'index FCM_W_INDEX_APP_START
	 * index 0 : multi usage ponctuel pour le coeur ( fcm_select_pixel_format() )
	 * index 1 : fenetre launch
	 * index 2 : fenetre info
	 * index 3 : fenetre preference
	 * index 4 : fenetre console
	 * index 5 : fenetre PopUP
	 * index 6 : fenetre Win_Form_Alert
	 * voir coeur_define.h pour la config exact en cas de changement 
	 * tous les index < FCM_W_INDEX_APP_START sont gérés par le Coeur
	 *
	 */
	for( win_index=1; win_index < NB_FENETRE; win_index++ )
	{
		/*
		 * La console peut etre ouverte a tout moment (avec un
		 * message debug par ex), et peut donc deja contenir un
		 * handle valide et être ouverte.
		 *
		 * Les index 4 à W_COEUR_END ne doivent être ouvert...
		 *
		 */
		if( win_index < W_CONSOLE  ||  win_index > W_COEUR_END )
		{
			FCM_LOG_PRINT2(" - h_win[%d]=%d", win_index, h_win[win_index] );

			/* le status open est sauvé dans le fichier de config */
			/* voir fcm_get_win_parametre.c et fcm_save_config_generale.c */
			if( h_win[win_index] == FCM_GO_OPEN_WINDOW )
			{
				/* On aiguille vers la fonction d'ouverture concern‚e */
				/* si la fonction est d‚fini dans notre tableau de pointeur de fonction */
				if( table_ft_ouvre_fenetre[win_index] == FCM_FONCTION_NON_DEFINI )
				{
					/* on utilise la fonction standard du coeur */
					Fcm_ouvre_fenetre(win_index, NULL);
				}
				else
				{
					/* on appel la fonction defini */
					table_ft_ouvre_fenetre[win_index]();
				}

				/* pour éviter un plantage de l'AES, d'après ST mag No 96 p45,      */
				/* si plus de 8 fenetres sont ouvertes en rafale, cela provoque un  */
				/* buffer AES overflow (accumulation de message dans le buffer AES) */
				Fcm_purge_aes_message();
			}
			else
			{
				FCM_LOG_PRINT("   -> fenetre ferm‚.");
			}
		}
	}


	return;


}


#endif   /* ___FCM_OUVRE_FENETRE_START_C___ */

