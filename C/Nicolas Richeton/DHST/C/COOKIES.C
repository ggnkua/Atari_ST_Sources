/* Filename					: Cookies.c - Cookies functions
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

/* Includes */
#include <mgx_dos.h>
#include	<portab.h>

/* Functions definitions */

COOKIE *Cookie_GetCookieJar( VOID );
/* Name				: Get Cookie Jar - Get the 1st cookie of the cookie jar
 * Definition		: COOKIE *Cookie_GetCookieJar( VOID );
 * Prototype in	: cookies.h
 * Parameters		: None
 * Answer			: Pointer on a COOKIE struct
 * Author			: Nicolas Richeton ( nicolas.richeton@free.fr )
 * Version			: 1.00
 * Last update		: 20/04/2000
 * Comments			: Based on the work of Thomas Much
 * History			: 20/04/2000 - Converted to LDG
 *                  16/02/2000 - First version
 */

ULONG	Cookie_GetCookie( ULONG id, ULONG *value );
/* Name				: Get Cookie - Get the value of a cookie
 * Definition		: ULONG	Cookie_GetCookie( ULONG id, ULONG *value );
 * Prototype in	: cookies.h
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

ULONG  Cookie_NewCookie( ULONG id, ULONG value );
/* Name				: New Cookie - Create a new cookie 
 * Definition		: ULONG  Cookie_NewCookie( ULONG id, ULONG value );
 * Prototype in	: cookies.h
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

ULONG  Cookie_RemoveCookie( ULONG id );
/* Name				: Remove Cookie - Remove a cookie from the cookie jar
 * Definition		: ULONG  Cookie_RemoveCookie( ULONG id );
 * Prototype in	: cookies.h
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

COOKIE*	Cookie_GetCookieJar( VOID )
{
	return( (COOKIE *)Setexc( 360, (VOID (*)())-1L ) );
}


ULONG	Cookie_GetCookie( ULONG id, ULONG *value )
{
	COOKIE *cookiejar = Cookie_GetCookieJar();

	if( cookiejar )
	{
		while( cookiejar->key )
		{
			if( cookiejar->key == id )
			{
				if( value ) *value = cookiejar->value;
				return( 1 );
			}

			cookiejar++;
		}
	}

	return( 0 );
}


ULONG	Cookie_NewCookie( ULONG id, ULONG value )
{
	COOKIE *cookiejar = Cookie_GetCookieJar();

	if( cookiejar )
	{
		long maxc, anz = 1;

		while( cookiejar->key )
		{
			anz++;
			cookiejar++;
		}

		maxc = cookiejar->value;

		if( anz < maxc )
		{
			cookiejar->key    = id;
			cookiejar->value = value;

			cookiejar++;

			cookiejar->key    = 0L;
			cookiejar->value = maxc;

			return( 1 );
		}
	}

	return( 0 );
}


ULONG	Cookie_RemoveCookie( ULONG id )
{
	COOKIE *cookiejar = Cookie_GetCookieJar();

	if( cookiejar )
	{
		while( ( cookiejar->key ) && ( cookiejar->key != id ) ) cookiejar++;

		if( cookiejar->key )
		{
			COOKIE *cjo;

			do
			{
				cjo = cookiejar++;

				cjo->key    = cookiejar->key;
				cjo->value = cookiejar->value;

			} while( cookiejar->key );

			return( 1 );
		}
	}

	return( 0 );

}