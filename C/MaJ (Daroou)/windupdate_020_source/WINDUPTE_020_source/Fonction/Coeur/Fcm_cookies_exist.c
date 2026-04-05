/* *************************** */
/* * Le cookie Existe ?      * */ 
/* * 31/12/2002  08/01/2015  * */
/* *************************** */

#ifndef __Fcm_cookies_exist__
#define __Fcm_cookies_exist__




#include "Fcm_get_cookies_table.c"


/* Prototype */
int16 Fcm_cookies_exist( const uint32 val_cookie );


/* Fonction */
int16 Fcm_cookies_exist( const uint32 val_cookie )
{
	uint32	*pt_table_cookie;


	/* On recupere l'adresse de la table des cookies */
	pt_table_cookie = Fcm_get_cookies_table();



	if( !pt_table_cookie )  return(FALSE);



	while(*pt_table_cookie)
	{
		if	(*pt_table_cookie == val_cookie)
		{
			return(TRUE);
		}
		pt_table_cookie += 2;
	}

	return(FALSE);


}


#endif

