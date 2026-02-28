/* **[Fonction Commune]*********************** */
/* * Analyse raccourci clavier               * */
/* * 11/08/2003 :: 04/03/2013                * */
/* *-----------------------------------------* */
/* * La fonction intercepte les raccourcis   * */
/* * standard du GEM (CTRL-W/CTRL-U/etc...   * */
/* ******************************************* */


#include "Fcm_is_my_win_ontop.c"




/* prototype */
WORD Fcm_analyse_raccourci_GEM( const WORD touche );


/* Fonction */
WORD Fcm_analyse_raccourci_GEM( const WORD touche )
{
/*
 *	variables globales:
 *  WORD h_win[NB_FENETRE];
 *
 */

	switch(touche & 0xff)
	{


		case 17: /* ---- Raccourci CTRL-Q ------------------------------------------ */
			{

/*				sprintf(texte," Gestion CTRL-Q (%ld) ", get_timer() );
				v_gtext(vdihandle,40*8,1*16,texte);*/

				/* On demande … l'AES de nous envoyer un message
				   de fin de programme */
				buffer_aes[0]=AP_TERM;
				buffer_aes[1]=ap_id;
				buffer_aes[2]=0;
				buffer_aes[3]=0;
				appl_write( ap_id, 16, &buffer_aes );
			}
			return(TRUE); /* le raccourci a ‚t‚ g‚r‚ */
			break;





		case 21: /* ---- Raccourci CTRL-U ------------------------------------------ */
			{
				WORD index_win;


/*				sprintf(texte," Gestion CTRL-U (%ld) ", get_timer() );
				v_gtext(vdihandle,40*8,1*16,texte);*/

				/* On regarde si notre fenetre est au premier plan */
				index_win = Fcm_is_my_win_ontop();

				/* Si c'est une fenetre … nous... */
				if( index_win != FCM_NO_MY_WINDOW )
				{
/*					sprintf(texte," Fermeture fenetre %d (%ld) ", index_win, get_timer() );
					v_gtext(vdihandle,40*8,1*16,texte);*/

					/* On demande … l'AES de nous envoyer un message
					   de fermeture de fenetre */
					buffer_aes[0]=WM_CLOSED;
					buffer_aes[1]=ap_id;
					buffer_aes[2]=0;
					buffer_aes[3]=h_win[index_win];
					appl_write( ap_id, 16, &buffer_aes );
				}
			}
			return(TRUE); /* le raccourci a ‚t‚ g‚r‚ */
			break;





		case 23: /* ---- Raccourci CTRL-W ------------------------------------------- */
			{
				WORD index_win_old, index_win;


/*				sprintf(texte," Gestion CTRL-W (%ld) ", get_timer() );
				v_gtext(vdihandle,40*8,1*16,texte);*/

				/* On regarde si notre fenetre est au premier plan */
				index_win = Fcm_is_my_win_ontop();

				/* Si c'est une fenetre … nous... */
				if( index_win != FCM_NO_MY_WINDOW )
				{
					/* on memorise la fenetre en cours... */
					index_win_old=index_win;
					do
					{
						/* et on cherche la fenetre suivante dans notre liste de fenetre */
						index_win++;
						if(index_win==NB_FENETRE) index_win=0;

/*						sprintf(texte," handle=%d, H_win[%d]=%d, %ld  ", handle_win, index_win, h_win[index_win], get_timer() );
						v_gtext(vdihandle,40*8,(6+index_win)*16,texte);*/

						/* on sort de la boucle dŠs que l'on trouve une fenetre ouverte */
					} while( h_win[index_win]==FCM_NO_OPEN_WINDOW );

					/* Est-ce la meme fenetre ? */
					/* S'il y a qu'une fenetre ouverte, c'est le cas */
					if( index_win != index_win_old )
					{
						/* c'est une autre fenetre... */
						/* on fait passer la nouvelle fenˆtre au premier plan en envoyant */
						/* un message … l'AES */
						buffer_aes[0]=WM_TOPPED;
						buffer_aes[1]=ap_id;
						buffer_aes[2]=0;
						buffer_aes[3]=h_win[index_win];
						appl_write( ap_id, 16, &buffer_aes );
					}
				}
			}
			return(TRUE);	/* le raccourci a ‚t‚ g‚r‚ */
			break;

		}


	/* Raccourci inconnu, au retour, ce sera redirig‚ vers la fonction
	   de gestion de cette fenetre */
	return( FALSE ); 

}

