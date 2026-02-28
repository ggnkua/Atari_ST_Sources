/* **[Fonction Commune]*************** */
/* * Gestion d'un bouton en fenetre  * */
/* * 17/04/2002  =  06/04/2013       * */
/* *********************************** */




#ifndef __Fcm_gestion_objet_bouton__
#define __Fcm_gestion_objet_bouton__




/*#include "Fcm_task_timer.c"*/



/* Prototypes */
WORD Fcm_gestion_objet_bouton( OBJECT *adr_formulaire, const WORD handle, const WORD objet_bouton );


/* Fonction */
WORD Fcm_gestion_objet_bouton( OBJECT *adr_formulaire, const WORD handle, const WORD objet_bouton )
{
/*
 * extern	GRECT	souris;
 *
 */

	WORD	etat;
	WORD	bouton;
	WORD	objet;


	/* Permet de controler l'appuie du bouton                     */
	/* Tant que le bouton de la souris est appuy‚, on peut encore */
	/* ‚vit‚ l'envoie de l'action du bouton en sortant la souris  */
	/* de la zone graphique du bouton.                            */
	/* Au relachement du bouton de la souris, la fonction renvoie */
	/* l'objet point‚ avec la souris.                             */
	/* Si la souris n'est plus sur le bouton, on n'execute pas    */
	/* l'action associ‚ au bouton.                                */



	#ifdef LOG_FILE
	sprintf( buf_log, "#Fcm_gestion_objet_bouton(%8p,%d,%d)"CRLF,adr_formulaire, handle, objet_bouton );
	log_print( FALSE );
	#endif


	/* On active le bouton et on le redessine */
	etat=OS_SELECTED;
	Fcm_objet_change( adr_formulaire,  handle, objet_bouton, etat );


	do
	{
		WORD	dummy;



		graf_mkstate( &souris.g_x, &souris.g_y, &bouton, &dummy);
		objet=objc_find( adr_formulaire, objet_bouton, 1, souris.g_x, souris.g_y );

		/* Si on est sur le bouton et qu'il n'est pas selectionn‚... */
		if( objet==objet_bouton && etat==0 )
		{
			/* On le s‚lectionne et on le redessine */
			etat=OS_SELECTED;
			Fcm_objet_change( adr_formulaire, handle, objet_bouton, etat );
		}

		/* Si on est en dehors du bouton et qu'il est s‚lectionn‚... */
		if( objet != objet_bouton && etat==OS_SELECTED )
		{
			/* On le d‚s‚lectionne et on le redessine */
			etat=0;
			Fcm_objet_change( adr_formulaire, handle, objet_bouton, etat );
		}


		/* appel de la fonction Task TIMER pour ne     */
		/* pas bloquer les taches de fond du programme */
		{
/*			Fcm_task_timer();*/

		}


		/* Tant que le bouton de la souris est enfonc‚ */
	} while( bouton != 0 );


	/* Une petite pause pour voir le bouton enfonc‚ un     */
	/* court moment si l'utilisateur a fait un simple clic */
	evnt_timer( FCM_BT_PAUSE_DOWN );


	/* Le bouton a ‚t‚ relach‚, si le bouton est s‚lectionn‚,  */
	/* on le d‚s‚lectionne et on le red‚sine                   */
	if( etat==OS_SELECTED )
	{
		Fcm_objet_change( adr_formulaire, handle, objet_bouton, 0 );
	}


	/* on retourne l'objet point‚ par la souris */
	/* Si le bouton est toujours point‚, l'action associ‚ sera ex‚cut‚ */
	return( objet/*objc_find(adr_formulaire,objet_bouton,1,souris.g_x,souris.g_y)*/ );

}


#endif

