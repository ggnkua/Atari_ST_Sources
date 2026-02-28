/* ****************************** */
/* * Lecture d'un cookie        * */ 
/* * 31/12/2002 MaJ 20/05/2015  * */
/* ****************************** */


#ifndef __Fcm_get_cookies__
#define __Fcm_get_cookies__

#include	"Fcm_get_cookies_table.c"


/* Prototype */
int32 Fcm_get_cookies( const uint32 id_cookie );



/* Fonction */
int32 Fcm_get_cookies( const uint32 id_cookie )
{



	/* ------------------------------------------------- */
	/* recherche cookie, appel fonction MiNT si pr‚sente */
	/* ------------------------------------------------- */

#ifdef Ssystem

	#ifndef S_GETCOOKIE
	#define S_GETCOOKIE (8)
	#endif

	{
		int32 reponse;

		reponse = Ssystem( S_GETCOOKIE, id_cookie, 0 );
		/* retourne -32 si la fonction n'exite pas */
		/* retourne  -1 si cookie non trouv‚       */
		/* sinon retourne valeur du coookie        */

		if( reponse == -1 )
		{
			return(0);
		}


		if( reponse != -32 )
		{
/*			*valeur_cookie = reponse;*/
			return(reponse/*1*/);
		}

	}

#endif





	/* ------------------------------------------ */
	/* ancienne m‚thode de recherche cookie 0x5A0 */
	/* ------------------------------------------ */

	{
		uint32	*pt_table_cookie;


		/* On recupere l'adresse de la table des cookies */
		pt_table_cookie = Fcm_get_cookies_table();


		/* Pas de table Cookie ? */
		if( pt_table_cookie == (void *)0 )
		{
			return(0);
		}


		while( *pt_table_cookie )
		{
			if( *pt_table_cookie == id_cookie )
			{
				/* *valeur_cookie = *(pt_table_cookie+1);*/
				return( *(pt_table_cookie+1)/*1*/);
			}
			pt_table_cookie += 2;
		}

	}




	/* Le cookie n'a pas ‚t‚ trouv‚... */
	return(0);


}


#endif

