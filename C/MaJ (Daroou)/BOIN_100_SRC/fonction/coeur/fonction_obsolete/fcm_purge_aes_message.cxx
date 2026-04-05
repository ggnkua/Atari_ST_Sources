/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 11/04/2015 MaJ 27/02/2024 * */
/* ***************************** */



#ifndef ___FCM_PURGE_AES_MESSAGE_C___
#define ___FCM_PURGE_AES_MESSAGE_C___


/*
 * Permet de vidanger les messages AES avant d'entrée dans la
 * boucle principale du Coeur. Utilisez par les fonctions durant
 * l'init de l'appli (fenetre launch par exemple)
 *
 */


void Fcm_purge_aes_message(void)
{
	int16	event;
	/*,bouton,controlkey,touche,nb_click;*/
	int16   delai = 1;


	FCM_LOG_PRINT("* Fcm_purge_aes_message()");

	do
	{
		event = evnt_multi( MU_MESAG|MU_TIMER,
						0/*FCM_EVENT_MBCLICKS*/, 0/*FCM_EVENT_MBMASK*/, 0/*FCM_EVENT_MBSTATE*/,
 						0,0,0,0,0,
						0,0,0,0,0,
						buffer_aes,20,
						NULL/*&souris.g_x*/,NULL/*&souris.g_y*/,NULL/*&bouton*/,NULL/*&controlkey*/,
						NULL/*&touche*/,NULL/*&nb_click*/);


//FCM_LOG_PRINT6("event=%d : [0]=%d(0x%x) [1]=%d [2]=%d [3]=%d", event, buffer_aes[0], buffer_aes[0],buffer_aes[1],buffer_aes[2],buffer_aes[3]);
//FCM_LOG_PRINT4("[4]=%d [5]=%d [6]=%d [7]=%d ", buffer_aes[4],buffer_aes[5],buffer_aes[6],buffer_aes[7]);

		/* ------------------------------------------------- */
		/*                      MU_MESAG                     */
		/* ================================================= */
		if( event & MU_MESAG )
		{
//FCM_CONSOLE_ADD2("Fcm_purge_aes_message() : buffer_aes[0]=%d", buffer_aes[0], G_WHITE);

			if( buffer_aes[0] != 0x3039 )
			{
				/*
				 * 0x3039 (12345) Message interne appl_write()
				 * on ne peut pas executer cette commande ici, sinon on
				 * reste bloqué dans la boucle.
				 * Normalement, ce message n'est pas envoyé ici car
				 * Fcm_purge_aes_message() ne sert que pendant l'init de
				 * l'appli, donc la partie Animation, si présente, n'est
				 * pas encore active.
				 */
				Fcm_gestion_message();
			}
		}


		/* Uniquement MU_TIMER, si combiné avec MU_MESAG, on reboucle... */
		if( event == MU_TIMER )  delai--;


//FCM_CONSOLE_ADD2("Fcm_purge_aes_message() : delai=%d", delai, G_GREEN);

	} while( delai );


	return;


}


#endif /* ___FCM_PURGE_AES_MESSAGE_C___ */

