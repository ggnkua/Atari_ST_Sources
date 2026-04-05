/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 27/11/2003 MaJ 01/03/2024 * */
/* ***************************** */



void Fcm_gestion_aes(void)
{
	/* L'initialisation de l'appli est terminée, certaines fonctions  */
	/* ont besoin de le savoir comme Fcm_win_formalert(), pour ne pas */
	/* appeler la fonction gestion_timer si l'init n'est pas achevée  */
	Fcm_init_appli_terminer = TRUE;
	Fcm_quitter_application = FALSE;

	FCM_LOG_PRINT(CRLF"#########################################");
	FCM_LOG_PRINT(    "# Fcm_gestion_aes() - Boucle principale #");
	FCM_LOG_PRINT(    "#########################################"CRLF);

    /* La boucle principale du coeur, on en sort que pour quitter l'application */
	do
	{
		int16  event, bouton, controlkey, touche, nb_click;

	
		/* TASK_TIMER est defini par l'application */
		event = evnt_multi(MU_KEYBD|MU_BUTTON|MU_MESAG|MU_TIMER,
						FCM_EVENT_MBCLICKS, FCM_EVENT_MBMASK, FCM_EVENT_MBSTATE,
 						0,0,0,0,0,
						0,0,0,0,0,
						buffer_aes,TASK_TIMER,
						&souris.g_x,&souris.g_y,&bouton,&controlkey,
						&touche,&nb_click);


		/* ------------------------------------------------- */
		/*                      MU_MESAG                     */
		/* ================================================= */
		if( event & MU_MESAG )
		{
			/* Si AP_TERM , Fcm_quitter_application passe a TRUE */
			Fcm_gestion_message();
		}


		/* ------------------------------------------------- */
		/*                      MU_BUTTON                    */
		/* ================================================= */
		if( event & MU_BUTTON )
		{
			Fcm_gestion_souris( controlkey, bouton );
		}


		/* ------------------------------------------------- */
		/*                      MU_KEYBD                     */
		/* ================================================= */
		if( event & MU_KEYBD)
		{
			Fcm_gestion_clavier( controlkey, touche );
		}


		/* ------------------------------------------------- */
		/*                      MU_TIMER                     */
		/* ================================================= */
		if( event & MU_TIMER )
		{
			gestion_timer();
		}


	} while( Fcm_quitter_application == FALSE );
	/* On sort de la boucle uniquement par AP_TERM ou par crash ;) */


	return;

}



