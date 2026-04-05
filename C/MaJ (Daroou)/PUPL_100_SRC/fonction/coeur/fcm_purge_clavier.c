/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 30/10/2003 MaJ 02/03/2024 * */
/* ***************************** */



void Fcm_purge_clavier( void )
{
	int16	delai = 1;
	int16	dummy;
	int16	event;

	do
	{
		event = evnt_multi(MU_KEYBD|MU_TIMER,0,0,0,
 						0,0,0,0,0,
						0,0,0,0,0,
						buffer_aes,20,
						NULL/*&souris.g_x*/,NULL/*&souris.g_y*/,NULL/*&bouton*/,&dummy,
						&dummy,NULL/*&nb_click*/ );


		/* une touche ? */
		if( event & MU_KEYBD )  delai = 1;


		/* Uniquement MU_TIMER */
		if( event == MU_TIMER )  delai--;


//FCM_CONSOLE_ADD2("Fcm_purge_clavier() : delai=%d", delai, G_GREEN);

	} while( delai );


}

