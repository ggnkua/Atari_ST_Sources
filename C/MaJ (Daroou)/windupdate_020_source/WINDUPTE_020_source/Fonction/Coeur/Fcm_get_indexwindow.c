/*====================================*/
/* Recherche l'handle de la fenetre   */
/* dans la liste de nos fenetres et   */
/* donne son index en r‚ponse         */
/* 28/12/2012 # 06/04/2013            */
/*____________________________________*/


#ifndef __Fcm_get_indexwindow__
#define __Fcm_get_indexwindow__




/* prototype */
WORD Fcm_get_indexwindow( const WORD handle_win );


/* Fonction */
WORD Fcm_get_indexwindow( const WORD handle_win )
{
	WORD index_win;


	/* On cherche la presence de l'handle dans notre liste */
	for( index_win=0; index_win<NB_FENETRE; index_win++)
	{
		/* Si ‡a correspond avec une de nos fenetres on sort */
		if( h_win[index_win]==handle_win)	break;
	}

	/*
	   Si aucun handle n'est trouv‚, … la fin de la boucle
	   index_win sera ‚gale … NB_FENETRE.
	   Sinon, index_win correspondra … l'index de notre fenetre
	   dans le tableau h_win[]
	*/


	return(index_win);


}


#endif

