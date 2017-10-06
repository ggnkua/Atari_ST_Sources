/* Filename					: Cooktest.c - Example for use of cookie static library (C)
 * Number of functions	: 1
 * Version					: 1.01
 * Author					: Nicolas Richeton ( nicolas.richeton@free.fr )
 * Last update				: 20/04/2000
 * Statut					: Freeware
 * Downloaded from		: http://nicosoft.free.atari.fr
 * Comments					: Based on the work of Thomas Much
 * History					: 20/04/2000 - Added LDG version
 *                        16/02/2000 - First version
 */
 
#include	<stdio.h>
#include	<portab.h>
#include	<mgx_dos.h>
#include	<mt_aes.h>
#include "cookies.h"

ULONG main( VOID )
{	
	ULONG	dummy;
	
	appl_init();
	printf( "\nTest for static lib 'cookies.c'\nBy Nicolas Richeton\n" );
			
	if( Cookie_NewCookie( 'CLDG', 0x10 ) )		/* Install Cookie */
		printf( "\nTest cookie 'CLDG' installed" );
			
	if( Cookie_GetCookie( 'CLDG', &dummy ) )		/* Read Cookie */
		printf( "\nTest cookie 'CLDG' found" );
			
	if( Cookie_RemoveCookie( 'CLDG' ) )			/* Remove Cookie */
		printf( "\nTest cookie 'CLDG' removed" );
		

	appl_exit();
	
	return( 0 );
}