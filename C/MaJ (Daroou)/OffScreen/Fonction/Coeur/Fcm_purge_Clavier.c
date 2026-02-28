/* **[Fonction commune]******* */
/* *                         * */
/* * 30/10/2003 = 08/04/2013 * */
/* *************************** */


/* Prototypes */
VOID Fcm_purge_clavier(VOID);


/* Fonction */
VOID Fcm_purge_clavier(VOID)
{
/*
 * extern	UWORD	buffer_aes[16];
 *
 */

	WORD	delai=3;
	WORD	dummy;
	WORD	event;

	do
	{
		event=evnt_multi(MU_KEYBD|MU_TIMER,0,0,0,
 						0,0,0,0,0,
						0,0,0,0,0,
						buffer_aes,20,
						&dummy,&dummy,&dummy,&dummy,
						&dummy,&dummy);


		/* Gestion des Çvänement TIMER ici ... */
		if( event == MU_TIMER )
		{
			delai--;
		}

		/* Gestion des messages... */
		if( event & MU_KEYBD )
		{
			delai=3;
		}


		/* appel de la fonction Task TIMER pour ne     */
		/* pas bloquer les taches de fond du programme */
/*		Fcm_task_timer();*/



	} while( delai );


}

