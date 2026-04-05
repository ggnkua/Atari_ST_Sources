/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 01/09/2002 MaJ 04/03/2024 * */
/* ***************************** */



#ifndef __FCM_PURGE_AES_MESSAGE_C__
#define __FCM_PURGE_AES_MESSAGE_C__



void Fcm_purge_aes_message( void )
{
//	static int16 Fcm_purge_aes_message_compteur = 0; /* controle ré-entrance */
	int16 event;
//	int16 bouton, nb_click;
//	int16 controlkey, touche;
//	int16 boucle = 16; /* 16 au hasard */
	int16 boucle = 2;




	/*
	 * Le but de cette fonction est de vider la liste des messages en attente que
	 * l'AES a construit pour notre appli.
	 *
	 * Cette fonction est appelé car on est sortit de la boucle de gestion AES
	 * pour executer une fonction qui effectue un certain nombre d'action avant
	 * de retourner dans la boucle de gestion AES. Or ces actions peuvent occasioner
	 * des messages de REDRAW par exemple. Si trop de message s'accumulent, certains
	 * peuvent être perdu ou ignoré par l'AES, qui provoqueront des altérations sur
	 * le bureau...
	 *
	 * On fait donc un certain nombre de boucle pour appeler la fonction de gestion de
	 * message, puis on quitte. On ne peut pas tester la fin de réception de message, car si
	 * l'appli est une animation par exemple, des appels auto-appl_write() sont générés en
	 * continue et on resterait bloqué dans cette fonction...
	 * Par contre, si aucun MU_MESAG, on quitte de suite.
	 *
	 * La fonction / fenêtre Launch utilise cette fonction pendant l'init, ce qui permet de
	 * la déplacer par exemple.
	 *
	 */

//	Fcm_purge_aes_message_compteur++;
//FCM_LOG_PRINT1("* [%d] Fcm_purge_aes_message", Fcm_purge_aes_message_compteur);


	do
	{
		event = evnt_multi( MU_MESAG|MU_TIMER,
						0/*FCM_EVENT_MBCLICKS*/,0/*FCM_EVENT_MBMASK*/,0/*FCM_EVENT_MBSTATE*/,
 						0,0,0,0,0,
						0,0,0,0,0,
						buffer_aes,20,
						NULL/*&souris.g_x*/,NULL/*&souris.g_y*/,NULL/*&bouton*/,NULL/*&controlkey*/,
						NULL/*&touche*/,NULL/*&nb_click*/ );


		if( event & MU_MESAG )
		{
			Fcm_gestion_message();
			/* si ce n'est pas un message auto-appl_write, on re-boucle */
			if( buffer_aes[0] != 0x3039 )
			{
				boucle = 2;
			}
		}
		else
		{
			/* Si plus de MU_MESAG on quitte de suite */
			boucle = 1;
		}

		boucle--;

	} while( boucle );


//	Fcm_purge_aes_message_compteur--;


	return;


}


#endif   /*   __FCM_PURGE_AES_MESSAGE_C__   */

