/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 11/08/2003 MaJ 06/03/2024 * */
/* ***************************** */



/*
 * La fonction intercepte les raccourcis
 * standard du GEM (CTRL-W/CTRL-U/etc...
 *
 * Vieille fonction... la langue du clavier n'est pas géré
 * un jour peut-être...
 *
 */


int16 Fcm_analyse_raccourci_GEM( const int16 touche )
{
	int16  reponse = FALSE; /* TRUE si un raccourci a été géré */


	/* on vide le buffer AES */
	memset( buffer_aes, 0, sizeof( buffer_aes ) );

	buffer_aes[1] = ap_id;


	switch(touche & 0xff)
	{

		case 17: /* - Raccourci CTRL-Q - */
			{
				buffer_aes[0] = AP_TERM;
				appl_write( ap_id, 16, &buffer_aes );
			}
			reponse = TRUE;
			break;



		case 21: /* - Raccourci CTRL-U - */
			{
				int16 index_win;


				index_win = Fcm_is_my_win_ontop();

				if( index_win != FCM_NO_MY_WINDOW )
				{
					buffer_aes[0] = WM_CLOSED;
					buffer_aes[3] = h_win[index_win];
					appl_write( ap_id, 16, &buffer_aes );
				}
			}
			reponse = TRUE;
			break;



		case 23: /* - Raccourci CTRL-W - */
			{
				int16 index_win_old, index_win;


				index_win = Fcm_is_my_win_ontop();

				if( index_win != FCM_NO_MY_WINDOW )
				{
					index_win_old = index_win;

					do
					{
						index_win++;

						if( index_win == FCM_NO_MY_WINDOW )  index_win = 0;

						/* on sort de la boucle dŠs que l'on trouve une fenetre ouverte */
					} while( h_win[index_win] <= 0 );

					/* Est-ce la meme fenetre ? */
					/* S'il y a qu'une fenetre ouverte, c'est le cas */
					if( index_win != index_win_old )
					{
						/* c'est une autre fenetre... */
						/* on fait passer la nouvelle fenˆtre au premier plan en envoyant */
						/* un message … l'AES */
						buffer_aes[0] = WM_TOPPED;
						buffer_aes[3] = h_win[index_win];
						appl_write( ap_id, 16, &buffer_aes );
					}
				}
			}
			reponse = TRUE;
			break;
		}


	/* Si Raccourci inconnu, au retour, ce sera redirig‚ */
	/* vers la fonction de gestion de cette fenetre      */
	return( reponse ); 


}

