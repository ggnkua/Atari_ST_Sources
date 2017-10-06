/* Filename					: Cookies.h - Definitions for cookies.C
 * Number of functions	: 4
 * Version					: 1.01
 * Author					: Nicolas Richeton ( nicolas.richeton@free.fr )
 * Last update				: 20/04/2000
 * Statut					: Freeware
 * Downloaded from		: http://nicosoft.free.atari.fr
 * Comments					: Based on the work of Thomas Much
 * History					: 20/04/2000 - Added LDG version
 *                        16/02/2000 - First version
 */


/* Definition */
EXTERN	COOKIE	*Cookie_GetCookieJar( VOID );
EXTERN	ULONG	Cookie_GetCookie( ULONG id, ULONG *value);
EXTERN	ULONG	Cookie_NewCookie( ULONG id, ULONG value);
EXTERN	ULONG	Cookie_RemoveCookie( ULONG id);