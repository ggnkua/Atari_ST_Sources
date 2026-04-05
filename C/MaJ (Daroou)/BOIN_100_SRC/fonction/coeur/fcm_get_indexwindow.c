/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 28/12/2012 MaJ 28/02/2024 * */
/* ***************************** */


/*
 * Recherche un handle de fenetre dans le tableau
 * d'handle des fenêtres de l'application.
 * Si l'handle est trouvé, renvoie son index de tableau.
 * Sinon renvoie NB_FENETRE (taille du tableau)
 */



#ifndef __FCM_GET_INDEXWINDOW_C__
#define __FCM_GET_INDEXWINDOW_C__



int16 Fcm_get_indexwindow( const int16 handle_win )
{
	int16 index_win;


	/* On cherche la presence de l'handle dans notre liste */
	for( index_win=0; index_win < NB_FENETRE; index_win++ )
	{
//FCM_LOG_PRINT3("h_win[%d]=%d   ==   handle_win=%d", index_win, h_win[index_win], handle_win);

		/* Si ‡a correspond avec une de nos fenetres, on sort */
		if( h_win[index_win] == handle_win ) break;
	}

	/*
	   Si aucun handle n'est trouv‚, … la fin de la boucle
	   index_win sera ‚gale … NB_FENETRE.
	   Sinon, index_win correspondra … l'index de notre fenetre
	   dans le tableau h_win[]
	*/

	return( index_win );

}


#endif   /*   __FCM_GET_INDEXWINDOW_C__   */

