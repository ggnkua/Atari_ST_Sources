/* Filename					: Cooktest.c - Example for use of cookie shared library (LDG)
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
#include	<ldg.h>
#include "../cook_ldg.h"

EXTERN AESPB ldg_aespb;

ULONG main( VOID )
{	
	ULONG	dummy;
	WORD	app_id;
	
	app_id = appl_init();
	printf( "\nTest for Dynamic lib 'cookies.ldg'\nBy Nicolas Richeton\n" );
	
	Cookie_lib  = ldg_exec( app_id, "cookies.ldg" );	/* Load lib */
	
	if( Cookie_lib )
	{
		printf( "\ncookies.ldg successfully loaded" );
		Cookie_Init();												/* Init Lib */
		printf( "\nInit OK" );
		
		if( ( *Cookie_NewCookie )( 'CLDG', 0x10 ) )		/* Install Cookie */
			printf( "\nTest cookie 'CLDG' installed" );
			
		if( ( *Cookie_GetCookie )( 'CLDG', &dummy) )		/* Read Cookie */
			printf( "\nTest cookie 'CLDG' found" );
			
		if( ( *Cookie_RemoveCookie )( 'CLDG' ) )			/* Remove Cookie */
			printf( "\nTest cookie 'CLDG' removed" );
		
		ldg_term( app_id,  Cookie_lib );						/* Close lib */
	}
	else
		printf( "\nError while loading 'cookie.ldg'" );

	appl_exit();
	
	return( 0 );
}