/* ****************************** */
/* * 09/06/2014  MaJ 01/01/2017 * */
/* ****************************** */

/* --------------------------------------------------------- */
/* retourne la version de EdDI ou -1 si le cookie est absent */
/* --------------------------------------------------------- */


#include "Fcm_cookie_definition.h"
#include "Fcm_get_cookies.c"
#include "Fcm_get_eddi_version.h"



/* Prototype */
/*int16  Fcm_eddi_version( void );*/



/* Fonction */
int16  Fcm_eddi_version( void )
{
	uint32 val_cookie;
	int32 reponse;

	#ifdef LOG_FILE
	sprintf( buf_log, "  -> Fcm_eddi_version()"CRLF );
	log_print(FALSE);
	#endif

	reponse = Fcm_get_cookies( COOKIE_EdDI, &val_cookie );

	if( reponse==0 )
	{
		/* Routine Assembleur de Patrice Mandin */
		/* voir get_eddi.S                      */
		return (int16)get_eddi_version( val_cookie );
	}

	return -1;

}

