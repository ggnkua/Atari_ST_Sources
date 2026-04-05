/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 31/12/2002 MaJ 05/03/2024 * */
/* ***************************** */



#ifndef __FCM_COOKIES_EXIST_C__
#define __FCM_COOKIES_EXIST_C__


/* ------------------------------------ */
/* retourn  1 si le cookie a été trouvé */
/* retourn  0 si le cookie n'existe pas */
/* ------------------------------------ */

int16 Fcm_cookies_exist( const uint32 id_cookie )
{
	uint32 dummy;

	if( Fcm_get_cookies( id_cookie, &dummy ) == 0 )
	{
		return 1;
	}
	
	return 0;

}


#endif  /*   __FCM_COOKIES_EXIST_C__   */

