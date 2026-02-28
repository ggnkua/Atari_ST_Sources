/* Filename					: Cook_ldg.h - Definition for the cookie shared library (LDG)
 * Number of functions	: 5
 * Version					: 1.01
 * Author					: Nicolas Richeton ( nicolas.richeton@free.fr )
 * Last update				: 20/04/2000
 * Statut					: Freeware
 * Downloaded from		: http://nicosoft.free.atari.fr
 * Comments					: Based on the work of Thomas Much
 * History					: 20/04/2000 - Added LDG version
 *                            16/02/2000 - First version
 *
 */

/*typedef struct
{
	int32 ;
	int32 ;
} COOKIE;*/



#include <ldg.h>
/*#include <mgx_dos.h>*/
/*#include	<portab.h>*/

/*LDG *Cookie_lib;*/
LDG *ldg_COOKIE;

/* Functions */

/*COOKIE*	cdecl	( *Cookie_GetCookieJar )( VOID );*/
/* Name				: Get Cookie Jar - Get the 1st cookie of the cookie jar
 * Definition		: COOKIE*	cdecl	( *Cookie_GetCookieJar )( VOID );
 * Prototype in	: cook_ldg.h
 * Parameters		: None
 * Answer			: Pointer on a COOKIE struct
 * Author			: Nicolas Richeton ( nicolas.richeton@free.fr )
 * Version			: 1.00
 * Last update		: 20/04/2000
 * Comments			: Based on the work of Thomas Much
 * History			: 20/04/2000 - Converted to LDG
 *                  16/02/2000 - First version
 */
 
uint32	CDECL	( *Cookie_GetCookie )( uint32 id, uint32 *value );
/* Name				: Get Cookie - Get the value of a cookie
 * Definition		: ULONG	cdecl	( *Cookie_GetCookie )( ULONG id, ULONG *value );
 * Prototype in	: cook_ldg.h
 * Parameters		: id - Id of the cookie
 *						  *value - pointer on a long where the value will be written
 * Answer			: (ULONG)1 - Ok
 *						: (ULONG)0 - Error (no such cookie or no cookie jar)
 * Author			: Nicolas Richeton ( nicolas.richeton@free.fr )
 * Version			: 1.00
 * Last update		: 20/04/2000
 * Comments			: Based on the work of Thomas Much
 * History			: 20/04/2000 - Converted to LDG
 *                  16/02/2000 - First version
 */
 
uint32	CDECL	( *Cookie_NewCookie )( uint32 id, uint32 value );
/* Name				: New Cookie - Create a new cookie 
 * Definition		: ULONG	cdecl	( *Cookie_NewCookie )( ULONG id, ULONG value );
 * Prototype in	: cook_ldg.h
 * Parameters		: id - Id of the cookie
 *						  value - Value of the cookie
 * Answer			: (ULONG)1 - Ok
 *						: (ULONG)0 - Error (not enough room or no cookie jar)
 * Author			: Nicolas Richeton ( nicolas.richeton@free.fr )
 * Version			: 1.00
 * Last update		: 20/04/2000
 * Comments			: Based on the work of Thomas Much
 * History			: 20/04/2000 - Converted to LDG
 *                  16/02/2000 - First version
 */

uint32	CDECL	( *Cookie_RemoveCookie )( uint32 id );
/* Name				: Remove Cookie - Remove a cookie from the cookie jar
 * Definition		: ULONG	cdecl	( *Cookie_RemoveCookie )( ULONG id );
 * Prototype in	: cook_ldg.h
 * Parameters		: id - Id of the cookie
 * Answer			: (int)1 - Ok
 *						: (int)0 - Error (no such cookie or no cookie jar)
 * Author			: Nicolas Richeton ( nicolas.richeton@free.fr )
 * Version			: 1.00
 * Last update		: 20/04/2000
 * Comments			: Based on the work of Thomas Much
 * History			: 20/04/2000 - Converted to LDG
 *                  16/02/2000 - First version
 */

/*VOID Cookie_Init( VOID	);*/

  /* Init library. Use it only after a successfull ldg_exec */
/*VOID Cookie_Init( VOID	)
{
	Cookie_GetCookieJar	= ldg_find( "Cookie_GetCookieJar", Cookie_lib );
	Cookie_GetCookie		= ldg_find( "Cookie_GetCookie", Cookie_lib );
	Cookie_NewCookie		= ldg_find( "Cookie_NewCookie", Cookie_lib );
	Cookie_RemoveCookie	= ldg_find( "Cookie_RemoveCookie", Cookie_lib );
}*/



/* ---------------------------------------------------------------- */
/* Open / Close COOKIE.LDG fonction ajout‚ par Daroou (Renaissance) */
/* Protocol LDG 2.xx                                                */
/* -- 25/11/2014 -------------------------------------------------- */

int32 open_LDG_COOKIE( VOID )
{
	extern 	LDG    *ldg_COOKIE;
			int32   erreur=FALSE;
/*	CHAR	my_buffer[256];*/


/*	sprintf( my_buffer, "Render ldg_open   " );
	v_gtext( vdihandle, 600, 16, my_buffer);
*/

	ldg_COOKIE=ldg_open( "COOKIES.LDG", ldg_global ); /* ldg_global d‚fini dans LDG.H */



	if( ldg_COOKIE==NULL )
	{
		return( ldg_error() );
	}


/*	sprintf( my_buffer, "1 Render ldg_TGA=%p    ",  ldg_TGA );
	v_gtext( vdihandle, 600, 116, my_buffer);
*/

	/* Recherche des fonctions dans la LDG */

/*	Cookie_GetCookieJar = ldg_find( "Cookie_GetCookieJar", ldg_COOKIE );
	if( !Cookie_GetCookieJar ) erreur=TRUE;*/

	Cookie_GetCookie    = ldg_find( "Cookie_GetCookie",    ldg_COOKIE );
	if( !Cookie_GetCookie )    erreur=TRUE;

	Cookie_NewCookie    = ldg_find( "Cookie_NewCookie",    ldg_COOKIE );
	if( !Cookie_NewCookie )    erreur=TRUE;

	Cookie_RemoveCookie = ldg_find( "Cookie_RemoveCookie", ldg_COOKIE );
	if( !Cookie_RemoveCookie ) erreur=TRUE;



	/* Si une erreur s'est produite ... */
	if( erreur==TRUE )
	{
		ldg_close( ldg_COOKIE, ldg_global);
		return( LDG_NO_FUNC );
	}

	return(TRUE);

}



void close_LDG_COOKIE( void )
{
	extern 	LDG    *ldg_COOKIE;


	/* ldg_global est d‚fini dans LDG.H */
	ldg_close( ldg_COOKIE, ldg_global);


	return;


}

