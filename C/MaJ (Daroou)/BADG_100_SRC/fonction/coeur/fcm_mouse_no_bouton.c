/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 02/01/2013 MaJ 26/08/2025 * */
/* ***************************** */



#ifndef __FCM_MOUSE_NO_BOUTON_C__
#define __FCM_MOUSE_NO_BOUTON_C__


void Fcm_mouse_no_bouton( void )
{
	int16	event;
	int16	dummy;
//	int16   delai = 1;


FCM_LOG_PRINT("# Fcm_mouse_no_bouton()");
//FCM_CONSOLE_ADD("Fcm_mouse_no_bouton()", G_GREEN);


	wind_update(BEG_MCTRL);

	do
	{
		event = evnt_multi( MU_BUTTON|MU_MESAG|MU_TIMER,
						FCM_EVENT_MBCLICKS, FCM_EVENT_MBMASK, FCM_EVENT_MBSTATE,
 						0,0,0,0,0,
						0,0,0,0,0,
						buffer_aes,20,
						&dummy,&dummy,&dummy,&dummy,
						&dummy,&dummy);


FCM_LOG_PRINT6("event=%d : [0]=%d(0x%x) [1]=%d [2]=%d [3]=%d", event, buffer_aes[0], buffer_aes[0],buffer_aes[1],buffer_aes[2],buffer_aes[3]);
FCM_LOG_PRINT4("[4]=%d [5]=%d [6]=%d [7]=%d ", buffer_aes[4],buffer_aes[5],buffer_aes[6],buffer_aes[7]);


		if( event & MU_MESAG )
		{
			/* On bloque certains types de message qui ne doivent */
			/* pas etre utilisé                                   */
			switch( buffer_aes[0] )
			{
				case WM_TOPPED:
					/* On bloque ce message car si l'action du clic a ouvert */
					/* une fenetre, ne pas bloquer ce message ferait revenir */
					/* la fenetre d'origine du clic au premier plan. Ce qui  */
					/* n'est pas souhaité, si c'est un PopUp en fenêtre qui  */
					/* vient de s'ouvrir par exemple.                        */
					break;
				default:
					/* Les autres messages peuvent être gérer par le Coeur */
					Fcm_gestion_message();
					break;
			}
		}


		/* purge du bouton tout en ne bloquant pas l'AES */
//		if( (event & MU_BUTTON) == 0 )  delai--;
		if( (event & MU_BUTTON) == 0 )  break;

//FCM_CONSOLE_ADD2("Fcm_mouse_no_bouton() : delai=%d", delai, G_GREEN);
//FCM_CONSOLE_ADD2("Fcm_mouse_no_bouton() %ld", Fcm_get_timer(), G_GREEN);

//	} while( delai );
	} while( 1 );

	wind_update(END_MCTRL);


	return;


}


#endif   /*   __FCM_MOUSE_NO_BOUTON_C__   */

