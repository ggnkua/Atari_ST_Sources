/* Filename					: Cook_ldg.h - Definition for the cookie shared library (LDG)
 * Number of functions	: 5
 * Version					: 1.01
 * Author					: Nicolas Richeton ( nicolas.richeton@free.fr )
 * Last update				: 20/04/2000
 * Statut					: Freeware
 * Downloaded from		: http://nicosoft.free.atari.fr
 * Comments					: Based on the work of Thomas Much
 * History					: 20/04/2000 - Added LDG version
 *                        16/02/2000 - First version
 */

#include <ldg.h>
#include <mgx_dos.h>
#include	<portab.h>

LDG *Cookie_lib;

/* Functions */

COOKIE*	cdecl	( *Cookie_GetCookieJar )( VOID );
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
 
ULONG	cdecl	( *Cookie_GetCookie )( ULONG id, ULONG *value );
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
 
ULONG	cdecl	( *Cookie_NewCookie )( ULONG id, ULONG value );
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

ULONG	cdecl	( *Cookie_RemoveCookie )( ULONG id );
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

VOID Cookie_Init( VOID	);

VOID Cookie_Init( VOID	)  /* Init library. Use it only after a successfull ldg_exec */
{
	Cookie_GetCookieJar	= ldg_find( "Cookie_GetCookieJar", Cookie_lib );
	Cookie_GetCookie		= ldg_find( "Cookie_GetCookie", Cookie_lib );
	Cookie_NewCookie		= ldg_find( "Cookie_NewCookie", Cookie_lib );         
	Cookie_RemoveCookie	= ldg_find( "Cookie_RemoveCookie", Cookie_lib );         
}

