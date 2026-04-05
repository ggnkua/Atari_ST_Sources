/* *************************** */
/* * Lecture d'un cookie     * */ 
/* * 31/12/2002  08/01/2015  * */
/* *************************** */


#ifndef __Fcm_get_cookies__
#define __Fcm_get_cookies__




/* Prototype */
int32 Fcm_get_cookies( const uint32 val_cookie );



/* Fonction */
int32 Fcm_get_cookies( const uint32 val_cookie )
{
	uint32	*pt_table_cookie;



	/* On recupere l'adresse de la table des cookies */
	pt_table_cookie = Fcm_get_cookies_table();


	/* Pas de Cookie ? */
	if( !pt_table_cookie )  return(FALSE);



	while( *pt_table_cookie )
	{
		if( *pt_table_cookie == val_cookie )
		{
			return( *(pt_table_cookie+1) );
		}
		pt_table_cookie += 2;
	}


	return(FALSE);


}


#endif

