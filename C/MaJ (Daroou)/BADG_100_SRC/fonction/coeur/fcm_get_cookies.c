/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 31/12/2002 MaJ 06/03/2024 * */
/* ***************************** */



/* ------------------------------------ */
/* retourn  0 si le cookie a été trouvé */
/* retourn -1 si le cookie n'existe pas */
/* ------------------------------------ */


#ifndef __FCM_GET_COOKIES_C__
#define __FCM_GET_COOKIES_C__


/* Prototype fonction incluse dans ce fichier */
uint32 *Fcm_get_cookies_table( void );
uint32  get_adresse_table_cookie( void );





int32 Fcm_get_cookies( const uint32 id_cookie, uint32 *valeur_cookie )
{

	/* valeur par defaut */
	*valeur_cookie = 0;


	/* ------------------------------------------------- */
	/* recherche cookie, appel fonction MiNT si pr‚sente */
	/* ------------------------------------------------- */
	
#ifdef Ssystem

	#ifndef S_GETCOOKIE
	#define S_GETCOOKIE (8)
	#endif

	#warning "Ssystem() disponible !"
	{
		int32 reponse;

		reponse = Ssystem( S_GETCOOKIE, id_cookie, 0 );
		/* retourne -32 si la fonction n'exite pas */
		/* retourne  -1 si cookie non trouv‚       */
		/* sinon retourne valeur du coookie        */

		FCM_LOG_PRINT1(" reponse Ssystem() = %ld", reponse );

		if( reponse == -1 )
		{
			return(-1);
		}


		if( reponse != -32 )
		{
			*valeur_cookie = (uint32)reponse;
			return(0);
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
			return(-1);
		}

		while( *pt_table_cookie )
		{
			if( *pt_table_cookie == id_cookie )
			{
				*valeur_cookie = *(pt_table_cookie + 1);
				return(0);
			}
			pt_table_cookie += 2;
		}
	}


	/* Le cookie n'a pas ‚t‚ trouv‚... */
	return(-1);


}



uint32 *Fcm_get_cookies_table( void )
{
	/* On recupere l'adresse de la table des cookies */
	return( (uint32 *)Supexec(get_adresse_table_cookie) );
}



uint32 get_adresse_table_cookie( void )
{
	return(  *( (uint32 *)0x5A0L )  );
}



#endif   /*   __FCM_GET_COOKIES_C__   */

