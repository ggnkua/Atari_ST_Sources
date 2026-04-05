/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 28/12/2012 MaJ 03/03/2024 * */
/* ***************************** */



/*
 * Determine si la fenetre au premier
 * plan nous appartient.
 *
 */


int16 Fcm_is_my_win_ontop( void )
{
	int16 dummy, handle_win, index_win;


	/* On demande l'handle de la fenetre au premier plan */
	wind_get(0, WF_TOP, &handle_win, &dummy, &dummy, &dummy);

	/* On verifie qu'il s'agit bien  d'une de nos fenetres */
	for( index_win=0; index_win < NB_FENETRE; index_win++)
	{
		/* Si ‡a correspond avec une de nos fenetres on sort */
		if( h_win[index_win] == handle_win )  break;
	}

	/*
	   Si aucun handle n'est trouv‚, … la fin de la boucle
	   index_win sera ‚gale … NB_FENETRE.
	   Sinon, index_win correspondra … l'index de notre fenetre
	   dans le tableau h_win[]
	*/


	return(index_win);


}

