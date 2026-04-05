/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 17/04/2002 MaJ 29/11/2025 * */
/* ***************************** */



/*
 * Permet de controler le clic sur un bouton (G_BUTTON) du dialogue.
 *
 * Tant que le bouton de la souris est appuy‚, on peut encore
 * ‚vit‚ l'envoie de l'action du bouton en sortant la souris
 * de la zone graphique du bouton.
 *
 * Au relachement du bouton de la souris, la fonction renvoie
 * l'objet point‚ avec la souris.
 *
 *
 * wind_update(BEG_MCTRL). Sous XaAES, ça bloque l'affichage
 * des autres applis comme si c'était un BEG_UPDATE...
 *
 *
 */


#ifndef __FCM_GESTION_OBJET_BOUTON_C__
#define __FCM_GESTION_OBJET_BOUTON_C__


int16 Fcm_gestion_objet_bouton( OBJECT *adr_formulaire, const int16 handle, const uint16 objet_bouton )
{
	uint16 etat;
	int16  objet = (int16)objet_bouton;

	/* si simple clic, aucun MU_BUTTON n'arrivera, on renvoie le bouton cliqué 'objet_bouton' */


	FCM_LOG_PRINT3("* Fcm_gestion_objet_bouton(%8p,%d,%d)", adr_formulaire, handle, objet_bouton );
//FCM_CONSOLE_DEBUG3("Fcm_gestion_objet_bouton(%8p,%d,%d)", adr_formulaire, handle, objet_bouton );

	/* On active le bouton et on le redessine */
	etat = OS_SELECTED;
	Fcm_objet_change( adr_formulaire,  handle, objet_bouton, etat );


	/* Gestion des ‚vŠnements et du dialogue */
	{
		int16  event, bouton, nb_click;
		/*int16  controlkey, touche;*/

		wind_update(BEG_MCTRL);
		do
		{
			event = evnt_multi( MU_MESAG|MU_TIMER|MU_BUTTON,
							FCM_EVENT_MBCLICKS, FCM_EVENT_MBMASK, FCM_EVENT_MBSTATE,
 							0,0,0,0,0,
							0,0,0,0,0,
							buffer_aes,20,
							&souris.g_x,&souris.g_y,&bouton,NULL/*&controlkey*/,
							NULL/*&touche*/,&nb_click);


			/* ------------------------------------------------- */
			/*                      MU_MESAG                     */
			/* ================================================= */
			if( event & MU_MESAG )
			{
				/*
				 * y a t-il des MU_MESAG a bloquer ?
				 * normalement non, si on arrive ici, c'est que l'utilisateur
				 * a le bouton de la souris enfoncée... donc spam de MU_BUTTON
				 */
				Fcm_gestion_message();
			}


			/* ------------------------------------------------- */
			/*                      MU_BUTTON                    */
			/* ================================================= */
			if( event & MU_BUTTON )
			{
				objet = objc_find( adr_formulaire, (int16)objet_bouton, 1, souris.g_x, souris.g_y );

				/* Si on est sur le bouton et qu'il n'est pas selectionn‚... */
				if( objet == (int16)objet_bouton   &&   etat == 0 )
				{
					/* On le s‚lectionne et on le redessine */
					etat = OS_SELECTED;
					Fcm_objet_change( adr_formulaire, handle, objet_bouton, etat );
				}

				/* Si on est en dehors du bouton et qu'il est s‚lectionn‚... */
				if( objet != (int16)objet_bouton  &&  etat == OS_SELECTED )
				{
					/* On le d‚s‚lectionne et on le redessine */
					etat = 0;
					Fcm_objet_change( adr_formulaire, handle, objet_bouton, etat );
				}
			}

		}  while( event & MU_BUTTON );

		wind_update(END_MCTRL);
	}

//FCM_CONSOLE_DEBUG1("objet %d", objet );

	/* Une petite pause pour voir le bouton enfonc‚ un     */
	/* court moment si l'utilisateur a fait un simple clic */
	evnt_timer( FCM_BT_PAUSE_DOWN );


	/* Le bouton a ‚t‚ relach‚, si le bouton est s‚lectionn‚,  */
	/* on le d‚s‚lectionne et on le red‚sine                   */
	if( etat == OS_SELECTED )
	{
		Fcm_objet_change( adr_formulaire, handle, objet_bouton, 0 );
	}


	/* on retourne l'objet point‚ par la souris */
	return( objet );


}


#endif   /*   __FCM_GESTION_OBJET_BOUTON_C__   */

