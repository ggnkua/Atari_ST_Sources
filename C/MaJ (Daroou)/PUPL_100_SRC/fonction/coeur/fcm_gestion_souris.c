/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 21/01/2002 MaJ 26/08/2025 * */
/* ***************************** */



void Fcm_gestion_souris( const int16 controlkey, int16 bouton )
{
	int16 win_handle;
	int16 win_index;


	FCM_LOG_PRINT2("# Fcm_gestion_souris(%d,%d)", controlkey, bouton );

//FCM_CONSOLE_ADD3("# Fcm_gestion_souris(%d,%d)", controlkey, bouton, G_GREEN );



	{
		int16 dummy, handle_win;

		/* On demande l'handle de la fenetre au premier plan */
		wind_get(0, WF_TOP, &handle_win, &dummy, &dummy, &dummy);
//FCM_CONSOLE_ADD3("WF_TOP handle_win=%d index=%d", handle_win, Fcm_get_indexwindow(handle_win), G_GREEN );
	}



	/* hack pour utilisation sous TOS lorsque des appl_write sont utilis‚s */
	/* dans ce cas evnt_multi ne renvoi plus la valeur du bouton appuy‚    */
	/* cela ce produit sous TOS Milan, TOS TT, TOS Falcon                  */
	/* c'est soit une limitation de ces TOS soit un bug de mon code        */
	/* ceci est un patch provisoire                                        */
	if( bouton==0 )
	{
		//int16 dummy;
		FCM_CONSOLE_DEBUG("MU_BUTTON avec bouton=0");
		bouton=1;  /* valeur par defaut */

		//graf_mkstate( &dummy, &dummy, &bouton, &dummy);

		/*if( bouton==0 )
		{
			bouton=1;
		}*/
	}

	FCM_LOG_PRINT2("# Fcm_gestion_souris(%d,%d) (apres patch)", controlkey, bouton );

	/* Avant d'aiguiller l'‚vŠnement souris sur la fenetre concern‚  */
	/* On fait quelque controle pour ‚viter d'y aller pour rien      */
	/* ------------------------------------------------------------- */
	/* win_mouse_through[]: indique si l'event souris doit etre      */
	/*                      passer imp‚rativement … la fenetre       */
	/*                      Ex: fenetre de dessin, jeu, etc...       */
	/* ------------------------------------------------------------- */
	/* Si la fenetre est un dialogue ou en partie, alors seulement   */
	/* si l'objet point‚ a un ob_flag de mis, on passe a sa fonction */
	/* de Gestion et … condition que celui-ci ne soit pas d‚j…       */
	/* s‚lectionn‚ (si selectable) ou disabled                       */
	/* ------------------------------------------------------------- */
	/* ------------------------------------------------------------- */

	/* On cherche l' Handle de la fenetre concern‚ */
	win_handle = wind_find( souris.g_x, souris.g_y );
	/* on recherche l'index correspondant */
	win_index = Fcm_get_indexwindow(win_handle);

	FCM_LOG_PRINT2(" -> win_handle=%d  win_index=%d", win_handle, win_index );
//FCM_CONSOLE_ADD3(" -> win_handle=%d  win_index=%d", win_handle, win_index, G_WHITE );

	/* La souris peut bouger bouton enfonc‚, on v‚rifie */
	/* si la fenetre sous la souris nous appartient...  */
	/* ATTENTION: sous TOS ou EmuTOS, le bureau nous appartient est a l'handle 0 */
	/* Pour le moment aucune applis n'installe de bureau, donc on ignore le message */
	if( win_index == FCM_NO_MY_WINDOW )
	{
		/* win_handle==0 pour le bureau sous TOS ou EmuTOS */
		if( win_handle != 0 )
		{
			/* Ce n'est pas une de nos fenetres ! */
			/* on ne fait rien, on retourne dans la boucle gestion AES */
FCM_CONSOLE_DEBUG1("Fcm_gestion_souris() : index => FCM_NO_MY_WINDOW handle=%d", win_handle);
		}
		return;
	}


	FCM_LOG_PRINT1(" -> win_mouse_through[win_index]=%d", win_mouse_through[win_index] );

	/* On regarde et teste l'etat du bouton seulement si on ne doit pas */
	/* forcer l'appel a la fonction de gestion de souris                */
	if( win_mouse_through[win_index] == FCM_NO_MOUSE_THROUGH )
	{
		FCM_LOG_PRINT(" -> recherche objet et s'il est cliquable");

		/* S'il y a des objets ressources dans la fenetre, */
		/* on regarde si un objet a ‚t‚ cliqu‚             */
		if( win_rsc[win_index] == FCM_NO_RSC_DEFINED )
		{
			/* Pas de Dialogue, pas de bouton ... */

			FCM_LOG_PRINT(" -> pas de dialogue defini");

			return;
		}
		else
		{
			OBJECT	*adr_formulaire;
			int16	objet;

			adr_formulaire = Fcm_adr_RTREE[ win_rsc[win_index] ];

			objet = objc_find(adr_formulaire,0,7,souris.g_x,souris.g_y);
			/* si objet == -1 , la souris n'est plus sur le daialogue au moment du test */

			FCM_LOG_PRINT1(" -> objet=%d", objet);

			if( objet == FCM_NO_OBJET_FOUND ) /* -1 */
			{
				/* Pas d'objet, on s'en va */
				return;
			}
			else
			{
				/* Un objet a ‚t‚ trouv‚ … cette position  */
				/* On regarde la situation de son OB_FLAG. */
				/* Si aucun flag n'est position‚, c'est un */
				/* objet d‚coratif, pas besoin de d‚ranger */
				/* la fonction de gestion de cette fenetre */
				/* ob_flags==32 -> dernier objet           */

				FCM_LOG_PRINT1(" -> adr_formulaire[objet].ob_flags & 0xff=%d "CRLF, adr_formulaire[objet].ob_flags & 0xff );

				//FCM_CONSOLE_DEBUG1("Fcm_gestion_souris() : objet=%d", objet);
				//FCM_CONSOLE_DEBUG1("Fcm_gestion_souris() : adr_formulaire[objet].ob_flags & OF_SELECTABLE=%d", adr_formulaire[objet].ob_flags & OF_SELECTABLE);
				//FCM_CONSOLE_DEBUG1("Fcm_gestion_souris() : adr_formulaire[objet].ob_state & OS_DISABLED=%d", adr_formulaire[objet].ob_state & OS_DISABLED);
				//FCM_CONSOLE_DEBUG1("Fcm_gestion_souris() : win_mouse_through[win_index]=%d", win_mouse_through[win_index]);

				if(  (adr_formulaire[objet].ob_flags & OF_SELECTABLE) == 0   ||   (adr_formulaire[objet].ob_state & OS_DISABLED) )
				{
					/* Si l'objet n'est pas SELECTABLE ou est DISABLED, on s'en va */
					/*Fcm_mouse_no_bouton();*/

					FCM_LOG_PRINT(" -> l'objet est pas SELECTABLE ou il est DISABLED");

					return;
				}
			}
		}
	}
	else
	{
		FCM_LOG_PRINT(" -> win_mouse_through[] == FCM_MOUSE_THROUGH");
	}


	/* On arrive ici si win_mouse_through[win_index] == FCM_MOUSE_THROUGH ou */
	/* si l'objet est SELECTABLE et non DISABLED  */
	FCM_LOG_PRINT( "# Appel fonction dynamique gestion souris");
	FCM_LOG_PRINT2("  -> win_index=%d, adresse fonction=%p", win_index, table_ft_gestion_win[win_index] );
	FCM_LOG_PRINT2("  -> controlkey=%d, bouton=%d"CRLF, controlkey, bouton );

	//FCM_CONSOLE_DEBUG("Fcm_gestion_souris() : appel fonction dynamique gestion souris");

	if( table_ft_gestion_win[win_index] != FCM_FONCTION_NON_DEFINI )
	{
		table_ft_gestion_win[win_index](controlkey, 0, bouton);
		return;
	}
	else
	{
		FCM_LOG_PRINT("# ERREUR => FCM_FONCTION_NON_DEFINI");
		FCM_CONSOLE_DEBUG("Fcm_gestion_souris() : Fonction de gestion non defini");
	}


	/* Si l'utilisateur a le doigt lourd... */
/*	Fcm_mouse_no_bouton();*/


	return;


}

