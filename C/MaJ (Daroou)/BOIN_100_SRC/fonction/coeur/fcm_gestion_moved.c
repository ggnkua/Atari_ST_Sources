/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 10/12/2001 MaJ 29/02/2024 * */
/* ***************************** */



#ifndef ___FCM_GESTION_MOVED_C___
#define ___FCM_GESTION_MOVED_C___



void Fcm_gestion_moved( void )
{
	int16 index_win;


	/*	Lors d'un message WM_MOVED, nous devons modifier la position */
	/*	de la fenetre, ainsi que la position des objets present dans */
	/*	cette fenetre. Ensuite, si n‚cessaire, l'AES va nous envoyer */
	/*	un message WM_REDRAW pour redessiner la totalit‚ (sous TOS)  */
	/*	ou une partie de la fenetre (les AES modernes d‚placent      */
	/*	automatiquement le contenu de la fenetre visible, il demande */
	/*	juste a redessinner les parties absentes.                    */

/*
	FCM_LOG_PRINT4(CRLF"Fcm_gestion_moved buffer_aes[4]=%d b[5]=%d b[6]=%d b[7]=%d", buffer_aes[4], buffer_aes[5], buffer_aes[6], buffer_aes[7] );
*/


	/* buffer_aes[3] est l'handle AES de la fenetre    */
	/* on cherche son index dans notre liste (tableau) */
	index_win = Fcm_get_indexwindow( buffer_aes[3] );


	/* on verifie si c'est une de nos fenetres par s‚curit‚ */
	if( index_win != FCM_NO_MY_WINDOW )
	{

		if( win_moved_scalex[index_win] != 0 )
		{
			/* x doit-il être corrigé ? */
			wind_calc( WC_WORK, win_widgets[index_win], buffer_aes[4], buffer_aes[5], buffer_aes[6], buffer_aes[7], &buffer_aes[4], &buffer_aes[5], &buffer_aes[6], &buffer_aes[7] );
			buffer_aes[4] = ( buffer_aes[4] / win_moved_scalex[index_win] ) * win_moved_scalex[index_win];
			wind_calc( WC_BORDER, win_widgets[index_win], buffer_aes[4], buffer_aes[5], buffer_aes[6], buffer_aes[7], &buffer_aes[4], &buffer_aes[5], &buffer_aes[6], &buffer_aes[7] );
		}

		/* on place cette fenetre sur sa nouvelle position */
		wind_set(buffer_aes[3],WF_CURRXYWH,buffer_aes[4],buffer_aes[5],buffer_aes[6],buffer_aes[7]);


		/* Si la fenetre n'est pas iconifi‚, on m‚morise   */
		/* la position. Cela permet de replacer la fenetre */
		/* au bon endroit aprŠs une d‚siconification       */
		if( win_iconified[index_win] == FALSE )
		{
			win_posxywh[index_win][0] = buffer_aes[4];
			win_posxywh[index_win][1] = buffer_aes[5];
			win_posxywh[index_win][2] = buffer_aes[6];
			win_posxywh[index_win][3] = buffer_aes[7];
		}

		/* on repositionne notre formulaire de fenetre si présent */
		if( win_rsc[index_win] != FCM_NO_RSC_DEFINED )
		{
			/* On r‚cupŠre l'espace de travail de la fenetre */
			wind_get(buffer_aes[3],WF_WORKXYWH,&buffer_aes[4],&buffer_aes[5],&buffer_aes[6],&buffer_aes[7]);

/*
			FCM_LOG_PRINT4("WF_WORKXYWH buffer_aes[4]=%d b[5]=%d b[6]=%d b[7]=%d", buffer_aes[4], buffer_aes[5], buffer_aes[6], buffer_aes[7] );
*/

			/* on modifie la position du formulaire */
			{
/*				OBJECT	*adr_formulaire;*/
/*				adr_formulaire = Fcm_adr_RTREE[ win_rsc[index_win] ];
				adr_formulaire->ob_x = buffer_aes[4];
				adr_formulaire->ob_y = buffer_aes[5];
*/
				Fcm_adr_RTREE[ win_rsc[index_win] ]->ob_x = buffer_aes[4];
				Fcm_adr_RTREE[ win_rsc[index_win] ]->ob_y = buffer_aes[5];
			}
		}
	}
	else
	{
		FCM_CONSOLE_DEBUG("Fcm_gestion_moved() : fenetre inconnu");
	}


	return;

}


#endif  /* ___FCM_GESTION_MOVED_C___ */

