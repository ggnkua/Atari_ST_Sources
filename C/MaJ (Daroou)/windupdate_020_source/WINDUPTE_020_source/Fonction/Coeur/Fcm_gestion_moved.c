/* **[Fonction Commune]*********** */
/* * Gestion Moved               * */
/* * 10/12/2001 06/04/2013       * */
/* ******************************* */


#include "Fcm_gestion_redraw_fenetre.c"



/* Prototypes */
VOID Fcm_gestion_moved(VOID);


/* Fonction */
VOID Fcm_gestion_moved(VOID)
{
/*
 * extern	WORD	h_win[NB_FENETRE];
 * extern	WORD	win_rsc[NB_FENETRE];
 * extern	UWORD	buffer_aes[16];
 *
 */

	/*	Lors d'un message WM_MOVED, nous devons modifier la position */
	/*	de la fenetre, ainsi que la position des objets present dans */
	/*	cette fenetre. Ensuite, si n‚cessaire, l'AES va nous envoyer */
	/*	un message WM_REDRAW pour redessiner la totalit‚ (sous TOS)  */
	/*	ou une partie de la fenetre (les AES modernes d‚placent      */
	/*	automatiquement le contenu de la fenetre visible, il demande */
	/*	juste a redessinner les parties absentes.                    */


	WORD	event;


/*sprintf( texte, "*** GESTION MOVED: %ld ***", Fcm_get_timer() );
v_gtext(vdihandle,4*8,1*16,texte);*/



	/* 	On se positionne sur MU_MESAG, on a recu un WM_MOVED
		avant d'arriver sur cette fonction */
	event=MU_MESAG;
	do
	{
		WORD	index_win;
		WORD	dummy;


		if(event & MU_MESAG) /* Si c'est un message AES */
		{

			switch(buffer_aes[0]) /* Que nous demande l'AES ? */
			{

				case WM_REDRAW:
	 				/* Il faut redessiner le contenu de la fenetre */

					/* Le contenu des fenetres est multiple et vari‚,  */
					/* c'est donc une fonction … part qui gere tout ‡… */
					Fcm_gestion_redraw_fenetre();
					break;



				case WM_MOVED:
					/* tremblement de terre, la fenetre a boug‚     */
					/* on place la fenetre sur sa nouvelle position */
					wind_set(buffer_aes[3],WF_CURRXYWH,buffer_aes[4],
							 buffer_aes[5],buffer_aes[6],buffer_aes[7]);


					/* buffer_aes[3] est l'handle AES de la fenetre    */
					/* on cherche son index dans notre liste (tableau) */
					index_win = Fcm_get_indexwindow( buffer_aes[3] );


					/* on verifie si c'est une de nos fenetre par s‚curit‚ */
					if( index_win != FCM_NO_MY_WINDOW )
					{

						/* Si la fenetre n'est pas iconifi‚, on m‚morise   */
						/* la position. Cela permet de replacer la fenetre */
						/* au bon endroit aprŠs une d‚siconification       */
						if( win_iconified[index_win]==FALSE )
						{
							win_posxywh[index_win][0]=buffer_aes[4];
							win_posxywh[index_win][1]=buffer_aes[5];
						}

						/* on repositionne notre formulaire de fenetre */
						/* s'il y en a de pr‚sent                      */
						if( win_rsc[index_win] != FCM_NO_RSC_DEFINED )
						{
							OBJECT	*adr_formulaire;


							/* On r‚cupŠre l'espace de travail de la fenetre */
							wind_get(buffer_aes[3],WF_WORKXYWH,&buffer_aes[4],&buffer_aes[5],&buffer_aes[6],&buffer_aes[7]);


							if(  win_rsc[index_win] == FCM_NO_DIALOGUE )
							{
								/* je me rappel plus de cette condition ??? */
								/* alors on affiche un texte barbare au cas */
								/* ou une appli l'utiliserai                */
/*sprintf( texte, "*** GESTION MOVED: Regarde par ici ! ***");
v_gtext(vdihandle,4*8,1*16,texte);*/
							}

							/* on modifie la position du formulaire */
							rsrc_gaddr(R_TREE, win_rsc[index_win], &adr_formulaire);
							adr_formulaire->ob_x=buffer_aes[4];
							adr_formulaire->ob_y=buffer_aes[5];
						}
					}
					break;

				default:
/*sprintf( texte, "*** GESTION MOVED: message suppl‚mentaire !!! *** (%ld)", get_timer() );
v_gtext(vdihandle,4*8,2*16,texte);*/

					#ifdef LOG_FILE
					sprintf( buf_log, "*** ERREUR - GESTION MOVED: message suppl‚mentaire !!! *** (msg=%d)"CRLF, buffer_aes[0] );
					log_print(FALSE);
					#endif

					break;

			}	/* End Switch */


		}	/* End IF(event) */



		/* appel de la fonction Task TIMER pour ne
		   pas bloquer les taches de fond du programme */
/*		Fcm_task_timer();*/


		/* L'AES du TOS d‚place un fantome de notre fenetre, par contre,    */ 
		/* sous AES modernes le d‚placement peut etre en temps r‚el, on     */
		/* doit donc continuer … regarder si l'AES nous envoie des MU_MESAG */
		/* Pour ne pas rester bloqu‚ dans la fonction, on place un MU_TIMER */
		/* pour sortir s'il n'y a plus de MU_MESAG (WM_MOVED) qui arrive    */
		event=evnt_multi(MU_MESAG|MU_TIMER,
						EVENT_BCLICK,3,0,
 						0,0,0,0,0,
	   					0,0,0,0,0,
						buffer_aes,
						100, /* (Task timer de 100) */
	   					&dummy,&dummy,&dummy,&dummy,&dummy,&dummy);


	} while( event==MU_MESAG );	/* tant que l'on recoit des messages */



	/* une fenetre a boug‚, on active le bouton pour */
	/* pouvoir sauver la config dans les pref‚rences */
	Fcm_active_sauve_config();



}

