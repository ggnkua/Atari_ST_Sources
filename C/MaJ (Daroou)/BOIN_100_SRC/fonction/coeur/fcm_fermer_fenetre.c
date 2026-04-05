/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 02/01/2013 MaJ 29/02/2024 * */
/* ***************************** */



/*
 * Fermeture d'une ou de toutes les fenetres
 *
 *
 * 31/10/2023: ajout de Fcm_purge_aes_message en cas de fermeture
 *             de toutes les fenetres (Réf: ST MAG 96 page 45)
 *
 *
 *
 *
 * win_index = FCM_CLOSE_ALL_WIN pour fermer toutes les fenetres
 *
 */



#ifndef __FCM_FERMER_FENETRE_C__
#define __FCM_FERMER_FENETRE_C__



void Fcm_fermer_fenetre( int16 win_index )
{

	FCM_LOG_PRINT1("# Fcm_fermer_fenetre(%d)", win_index );
//FCM_CONSOLE_ADD2("# Fcm_fermer_fenetre(%d)", win_index, G_YELLOW );


	/* Doit-on fermer une fenetre ou toutes ? */
	if( win_index != FCM_CLOSE_ALL_WIN )
	{
		if( h_win[win_index] > 0 )
		{

			FCM_LOG_PRINT2("  fermeture idx=%d hdl=%d", win_index, h_win[win_index] );
//FCM_CONSOLE_ADD3("  fermeture idx=%d hdl=%d", win_index, h_win[win_index], G_GREEN );

			/* une seule */
			wind_close ( h_win[win_index] );	/* on ferme la fenetre */
			wind_delete( h_win[win_index] );	/* et on l'efface      */

			h_win[win_index] = FCM_NO_OPEN_WINDOW;	/* on m‚morise sa fermeture */
			Fcm_purge_aes_message();

			return;
		}
		else
		{
			FCM_LOG_PRINT1("fenetre deja ferme ? handle=%d", h_win[win_index]);
			FCM_CONSOLE_DEBUG1("fenetre deja ferme handle=%d", h_win[win_index]);
		}
	}



	FCM_LOG_PRINT(" ~ Fermeture de toutes les fenˆtres:");

	/* si on ferme toutes les fenetres, c'est pour:
	 * - quitter l'appli
	 * - redemarrer l'appli
	 * - changer la langue du RSC
	 * donc, on sauve l'etat des fenetres ouverte pour leur ré-ouverture.
	 */
	for( win_index=0; win_index < NB_FENETRE; win_index++ )
	{
		if( h_win[win_index] > 0 )
		{
			FCM_LOG_PRINT2("  fermeture idx=%d hdl=%d", win_index, h_win[win_index] );
//FCM_CONSOLE_ADD3("  fermeture idx=%d hdl=%d", win_index, h_win[win_index], G_GREEN );

			wind_close ( h_win[win_index] );	 /* on ferme la fenetre */
			wind_delete( h_win[win_index] );	 /* et on l'efface      */

			h_win[win_index] = FCM_GO_OPEN_WINDOW; /* on m‚morise qu'elle etait ouverte */

			/* en attendant de trouver une solution pour r‚ iconifier */
			/* les fenetres, on les r‚-ouvre en normal                */
			win_iconified[win_index] = FALSE;


			/* pour éviter un plantage de l'AES, d'après ST MAG No 96 p45,       */
			/* si plus de 8 fenetres sont fermé en rafale, cela provoque un      */
			/* buffer AES overflow (accumulation de message dans le buffer AES)  */
			/* Problème rencontré dans les préf de langue, voir Remarque_dev.txt */
			Fcm_purge_aes_message();
		}
	}

	return;

}


#endif   /*   __FCM_FERMER_FENETRE_C__   */

