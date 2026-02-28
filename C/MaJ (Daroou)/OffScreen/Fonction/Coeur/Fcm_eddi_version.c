/* *************************** */
/* * 09/06/2014  09/06/2014  * */
/* *************************** */


#include "Fcm_cookie_definition.h"
#include "Fcm_cookies_exist.c"
#include "Fcm_get_cookies.c"

#include "Fcm_get_eddi_version.h"



/* Prototype */
int16  Fcm_eddi_version( void );



/* Fonction */
int16  Fcm_eddi_version( void )
{
	uint32 val_cookie;


	if( Fcm_cookies_exist( COOKIE_EdDI ) )
	{

		val_cookie = Fcm_get_cookies( COOKIE_EdDI );

		if( val_cookie > 0 )
		{
			/* Routine Assembleur de Patrice Mandin */
			/* voir get_eddi.S                      */
			return get_eddi_version( val_cookie );
		}
	}

	return 0;


}
