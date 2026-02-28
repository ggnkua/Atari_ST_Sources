/*====================================*/
/* Recherche l'objet parent           */
/* 29/12/2012 # 06/04/2013            */
/*____________________________________*/


#ifndef __Fcm_get_objet_parent__
#define __Fcm_get_objet_parent__



/* prototype */
WORD  Fcm_get_objet_parent( OBJECT *adr_formulaire, WORD objet );


/* Fonction */
WORD Fcm_get_objet_parent( OBJECT *adr_formulaire, WORD objet )
{

	WORD objet_next, objet_tail, objet_precedent;



	#ifdef LOG_FILE
	sprintf( buf_log, "#Fcm_get_objet_parent(%8p,%d) "CRLF, adr_formulaire, objet );
	log_print(FALSE);
	#endif


	objet_precedent=objet;

	do
	{

		objet_next=(adr_formulaire+objet)->ob_next;
		objet_tail=(adr_formulaire+objet)->ob_tail;

/*		#ifdef LOG_FILE
		sprintf( buf_log, " Objet=%02d - objet_precedent=%02d - objet_next=%02d - objet_tail=%02d "CRLF, objet, objet_precedent, objet_next, objet_tail );
		log_print(FALSE);
		#endif*/



		/* ob_tail designe le num‚ro d'objet du dernier enfant ou -1 s'il en a pas   */

		/* ob_next pointe sur le prochain objet frŠre, lorsqu'il n'y a plus de       */
		/* frere, il pointe sur l'objet pere                                         */

		/* Donc, aprŠs le dernier enfant, ob_next va pointer sur l'objet pŠre.       */
		/* A ce moment, ob_tail pointe sur le dernier enfant, soit l'objet pr‚cŠdent */
		/* on est donc sur le pere quant ob_tail est ‚gale … l'objet pr‚c‚dent :p    */
		if( objet_tail==objet_precedent )
		{
			return( objet );
		}

		/* On m‚morise l'objet et on passe au suivant */
		objet_precedent=objet;
		objet=objet_next;

	/* Si par malheur on ne trouve pas l'objet pere, on quitte    */
	/* la boucle dŠs que l'on est sur l'objet racine (ob_next=-1) */
	} while( objet_next >= 0 );


	/* On retourne l'objet racine, au moins ‡… ne plantera pas le programme */
	/* Ca alourdira uniquement le redraw (re-dessin de tous les objets      */
	return(0);


}


#endif

