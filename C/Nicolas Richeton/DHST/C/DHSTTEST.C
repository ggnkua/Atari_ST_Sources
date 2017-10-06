/* Filename					: Dhsttest.c - Example for use of dhst.c
 * Number of functions	: 1.1
 * Version					: ?
 * Author					: Nicolas Richeton - trashman@netcourrier.com
 * Last update				: 16/02/2000
 * Statut					: Freeware
 * Downloaded from		: http://www.geocities.com/SiliconValley/Hills/2239/apc
 * Comments					: Add a document "Test " to document history
 * History					: 16/02/2000 - First version
 */

#include	<mgx_dos.h>
#include <mt_aes.h>
#include <portab.h>
#include	<stdio.h>
#include <string.h>
#include "dhst.h"
#include	<stdlib.h>

#ifndef NULL
#define NULL        ((void *)0L)
#endif
char	*File_GetFullName( char *dest, char *src );


VOID main (WORD argc, const UBYTE *argv[])
{
	WORD ap_id;
	UWORD	msg[8];
	ULONG	count = 0;
	UBYTE	buf[1024];
	UBYTE	path[1024];
	
	ap_id = appl_init();
	path[0] = 'A' + Dgetdrv();
	path[1] = 0;
	Dgetpath( buf, 0 );
	strcat( path, buf );
	strcpy( buf, getenv( "_PNAM" ) );
	strcat( path, "\\" );
	strcat( path, buf );
	printf( "\n%s", path );
	if( ( ( count = DHST_init( ap_id ) ) == 0) && ( argc > 1 ) )
	{
		printf( "\nAdding %s", argv[1] );
		count = DHST_write( ap_id, count, "DHSTTest", path, File_GetFullName( buf, argv[1] ), argv[1] );
		while( count != 0 )
		{
			evnt_mesag( (WORD *)msg );
			count = DHST_evnt_ack( ap_id, count, msg[0], msg[3], msg[4] );	
		} 
		DHST_exit( ap_id, count );
	}
	appl_exit();
}

char	*File_GetFullName( char *dest, char *src )
{
	long j = 0; 
	long i = strlen( src ) - 1;
	
	strcpy( dest, "" );
	while( (i >= 0) && (src[i] != '\\') )
		i--;

	j = i;
	for( i++; i < strlen( src ); i++ )
	{
		dest[i-j-1] = src[i];
	}
	dest[i-j-1] = 0;

	return( dest );	
}
