/* **[Fonction Commune]*************** */
/* * Attente fin clic bouton souris  * */
/* *                                 * */
/* * 02/01/2013  =  06/04/2013       * */
/* *********************************** */



#ifndef __Fcm_mouse_no_bouton__
#define __Fcm_mouse_no_bouton__




#include "Fcm_task_timer.c"




/* Prototype */
VOID Fcm_mouse_no_bouton( VOID );


/* Fonction */
VOID Fcm_mouse_no_bouton( VOID )
{
/*
 *
 * extern UWORD buffer_aes[16];
 *
 */

	WORD	dummy;
	WORD	bouton;


	#ifdef LOG_FILE
	sprintf( buf_log, "#Fcm_mouse_no_bouton()"CRLF );
	log_print(FALSE);
	#endif



	/* 02/01/2013: r‚‚criture de la fonction, je me demande pourquoi */
	/* j'avais fait si compliqu‚...                                  */
	/* je laisse l'ancien code en commentaire au cas ou quelque      */
	/* chose m'aurait ‚chapp‚                                        */


	do
	{
		graf_mkstate(&dummy,&dummy,&bouton,&dummy);


/*		event=evnt_multi(MU_BUTTON|MU_TIMER,EVENT_BCLICK,3,0,
 						0,0,0,0,0,
						0,0,0,0,0,
						buffer_aes,20,
						&dummy,&dummy,&bouton,&dummy,
						&dummy,&dummy);*/

		/* Gestion de la Souris... */
/*		if( event & MU_BUTTON )
		{
			compteur=0;
		}
		else
		{
			compteur++;
		}*/

/*sprintf(texte,"**** mouse_no_bouton ***** event=%04d (%ld) ", event, get_timer() );
v_gtext(vdihandle,20*8,2*16,texte);*/






		/* Si l'utilisateur est un peu joueur et qu'il laisse le bouton   */
		/* de la souris ind‚finiment appuy‚, ‡… va boucler ici et bloquer */
		/* tous les autres ‚vŠnements, dont le TIMER, ce qui peut nuire   */
		/* au programme si des taches ont besoin de s'executer assez      */
		/* r‚gulierement, donc on lance ici une fonction qui continu a    */
		/* executer une fonction d‚fini dans le meme lapse de temps que   */
		/* l'event TIMER                                                  */
		Fcm_task_timer();


	} while( bouton /*compteur != 2*/);



	return;


}


#endif

