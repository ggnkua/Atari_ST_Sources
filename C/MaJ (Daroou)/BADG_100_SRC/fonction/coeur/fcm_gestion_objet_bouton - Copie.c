/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 17/04/2002 MaJ 06/03/2024 * */
/* ***************************** */



#ifndef __FCM_GESTION_OBJET_BOUTON_C__
#define __FCM_GESTION_OBJET_BOUTON_C__


int16 Fcm_gestion_objet_bouton( OBJECT *adr_formulaire, const int16 handle, const int16 objet_bouton )
{
	uint16	etat;
	int16	bouton;
	int16	objet;

	/*
	 * Permet de controler le clic sur un bouton du dialogue.
	 *
	 * Tant que le bouton de la souris est appuy‚, on peut encore
	 * ‚vit‚ l'envoie de l'action du bouton en sortant la souris
	 * de la zone graphique du bouton.
	 *
	 * Au relachement du bouton de la souris, la fonction renvoie
	 * l'objet point‚ avec la souris.
	 *
	 */

	FCM_LOG_PRINT3("* Fcm_gestion_objet_bouton(%8p,%d,%d)", adr_formulaire, handle, objet_bouton );
	FCM_CONSOLE_DEBUG3("Fcm_gestion_objet_bouton(%8p,%d,%d)", adr_formulaire, handle, objet_bouton );

	/* On active le bouton et on le redessine */
	etat = OS_SELECTED;

	Fcm_objet_change( adr_formulaire,  handle, objet_bouton, etat );


	do
	{
		int16	dummy;



		graf_mkstate( &souris.g_x, &souris.g_y, &bouton, &dummy);

		objet = objc_find( adr_formulaire, objet_bouton, 1, souris.g_x, souris.g_y );

		/* Si on est sur le bouton et qu'il n'est pas selectionn‚... */
		if( objet == objet_bouton && etat == 0 )
		{
			/* On le s‚lectionne et on le redessine */
			etat = OS_SELECTED;

			Fcm_objet_change( adr_formulaire, handle, objet_bouton, etat );
		}

		/* Si on est en dehors du bouton et qu'il est s‚lectionn‚... */
		if( objet != objet_bouton  &&  etat == OS_SELECTED )
		{
			/* On le d‚s‚lectionne et on le redessine */
			etat = 0;

			Fcm_objet_change( adr_formulaire, handle, objet_bouton, etat );
		}

		/* Tant que le bouton de la souris est enfonc‚ */
	} while( bouton != 0 );


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
	/* Si le bouton est toujours point‚, l'action associ‚ sera ex‚cut‚ */
	return( objet );


}


#endif   /*   __FCM_GESTION_OBJET_BOUTON_C__   */

