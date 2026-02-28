/* ***************************** */
/* *                           * */
/* * 01/09/2002 = 08/04/2013   * */
/* ***************************** */



#ifndef __Fcm_purge_redraw__
#define __Fcm_purge_redraw__



#include "Fcm_gestion_redraw_fenetre.c"



/* Prototype */
VOID Fcm_purge_redraw(VOID);


/* Fonction */
VOID Fcm_purge_redraw(VOID)
{
/*
 * extern	UWORD	buffer_aes[16];
 * extern	GRECT	souris;
 *
 */

	WORD	event,bouton,controlkey,touche,nb_click;
	WORD	delai=2;


	do
	{
		event=evnt_multi(MU_MESAG|MU_TIMER,EVENT_BCLICK,3,0,
 						0,0,0,0,0,
						0,0,0,0,0,
						buffer_aes,20,
						&souris.g_x,&souris.g_y,&bouton,&controlkey,
						&touche,&nb_click);


		/* Gestion des Çvänement TIMER ici ... */
		if( event == MU_TIMER )
		{
			delai--;
		}

		/* Gestion des messages... */
		if( event & MU_MESAG )
		{
			/* Que nous demande l'AES ? */
			switch( buffer_aes[0] )
			{
				case WM_REDRAW:
					/* Il faut redessiner le contenu de la fentre */	
					Fcm_gestion_redraw_fenetre();
					delai=2;
					break;
			}
		}


	} while( delai );


	return;


}


#endif

