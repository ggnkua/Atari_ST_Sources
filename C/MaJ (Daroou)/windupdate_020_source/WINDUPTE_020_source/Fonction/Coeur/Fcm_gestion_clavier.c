/* **[Fonction commune]******** */
/* * 27/11/2003 = 06/04/2013  * */
/* **************************** */



#include "Fcm_Analyse_Raccourci_GEM.c"
#include "Fcm_Purge_Clavier.c"



/* Prototypes */
VOID Fcm_gestion_clavier( const WORD controlkey, const WORD touche);


/* Fonction */
VOID Fcm_gestion_clavier( const WORD controlkey, const WORD touche)
{
/*
 * extern	WORD	h_win[NB_FENETRE];
 *
 */


	#ifdef LOG_FILE
	sprintf( buf_log, "#Fcm_gestion_clavier(controlkey=$%x, touche=$%x)"CRLF, controlkey, touche);
	log_print( FALSE );
	#endif



	/* ---------------------------------------------------------- */
	/* On regarde s'il s'agit d'un raccourci clavier standard GEM */
	/* ---------------------------------------------------------- */
	if( controlkey==K_CTRL )
	{
		if( Fcm_analyse_raccourci_GEM(touche) )
		{
			/* renvoie TRUE si le raccourci a ‚t‚ g‚r‚ */
			return;
		}
	}



	/* ------------------------------------------------------------------------ */
	/* On regarde s'il s'agit d'un raccourci clavier commum … toutes les applis */
	/* ------------------------------------------------------------------------ */

	/* Avec la touche CONTROL */
	if( controlkey==K_CTRL )
	{

		switch(touche & 0xff)
		{
			case	9:	/* CTRL-I */
				Fcm_ouvre_fenetre_info();
				return;
				break;

		}
	}


	/* Avec la touche ALT */
	if( controlkey==K_ALT )
	{
		/* rien pour le moment */
	}



	/* Ca doit etre un raccourci propre … l'application */
	/* On execute sa gestion des raccourcis claviers    */

	gestion_clavier( controlkey, touche );


	Fcm_purge_clavier();

	return;


}

