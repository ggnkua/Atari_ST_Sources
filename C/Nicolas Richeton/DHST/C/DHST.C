#include	<mgx_dos.h>
#include	<string.h>
#include	<mt_aes.h>
#include <cookies.h>
#include	<portab.h>

#ifndef NULL
#define NULL        ((void *)0L)
#endif

#ifndef	DHST_ADD
#define	DHST_ADD			0xdadd
#endif

#if !defined (DHST_ACK)
#define	DHST_ACK			0xdade
#endif

#ifndef	DHSTINFO
typedef struct
{
	char		*appname,
				*apppath,
				*docname,
				*docpath;
} DHSTINFO;
#endif

/* Definitions */

ULONG DHST_ServerId( VOID );

 
ULONG	DHST_write( ULONG ap_id, ULONG count, UBYTE *appname, UBYTE *apppath,
                                            UBYTE *docname, UBYTE *docpath);

ULONG	DHST_init( ULONG ap_id );
 
ULONG DHST_exit( ULONG ap_id, ULONG count );

ULONG DHST_evnt_ack( ULONG ap_id, ULONG count, ULONG msg0, ULONG msg3, ULONG msg4 );



ULONG DHST_ServerId( VOID )
{
	ULONG cookievalue;
	ULONG noerror;
	
	noerror = Cookie_GetCookie( 'DHST', &cookievalue );
	
	if( noerror )
		return( cookievalue );
	else 
		return( 0L );
}

ULONG	DHST_write( ULONG ap_id, ULONG count, UBYTE *appname, UBYTE *apppath,
                                            UBYTE *docname, UBYTE *docpath)
{
	UWORD	msg[8];
	UWORD	server;
	DHSTINFO	*datablock;
	
	if( server = (UWORD)DHST_ServerId() )
	{	
		datablock = Mxalloc( sizeof( DHSTINFO ), 3 + 0x20 ); 
		datablock->appname = Mxalloc( sizeof( UBYTE ) * ( strlen( appname ) + 1 ), 3 + 0x20 );
		datablock->apppath = Mxalloc( sizeof( UBYTE ) * ( strlen( apppath ) + 1 ), 3 + 0x20 );
		datablock->docname = Mxalloc( sizeof( UBYTE ) * ( strlen( docname ) + 1 ), 3 + 0x20 );
		datablock->docpath = Mxalloc( sizeof( UBYTE ) * ( strlen( docpath ) + 1 ), 3 + 0x20 );

		strcpy( datablock->appname, appname );
		strcpy( datablock->apppath, apppath );
		strcpy( datablock->docname, docname );
		strcpy( datablock->docpath, docpath );

		msg[0] = DHST_ADD;
		msg[1] = (UWORD)ap_id;
		msg[2] = 0;
		msg[3] = (UWORD)( ( (ULONG)datablock >> 16 ) & 0x0000ffffL );
		msg[4] = (UWORD)( (ULONG)datablock & 0x0000ffffL );
		msg[5] = 0;
		msg[6] = 0;
		msg[7] = 0;
		appl_write( server, 16, msg );  /* Envoi du message */
		count++;
	}
	
	return( count );
}


ULONG	DHST_init( ULONG ap_id )
{
	
	if( DHST_ServerId() )
		return( 0 );
	else
		return( 1 );
}

ULONG DHST_exit( ULONG ap_id, ULONG count )
{
	UWORD	msg[8];
	
	if( DHST_ServerId() )
	{
		while( count != 0 )
		{
			evnt_mesag( (WORD *)msg );
			count = DHST_evnt_ack( ap_id, count, msg[0], msg[3], msg[4] );
		}
	}
	return( 0 );
}

ULONG DHST_evnt_ack( ULONG ap_id, ULONG count, ULONG msg0, ULONG msg3, ULONG msg4 )
{
	DHSTINFO	*datablock;

	if( ( msg0 == DHST_ACK ) )
	{
			datablock = (DHSTINFO *)( ( ( msg3 & 0xffffL ) << 16 ) + ( msg4 & 0xffffL ) );
			Mfree( datablock->appname );
			Mfree( datablock->apppath );
			Mfree( datablock->docname );
			Mfree( datablock->docpath );
			Mfree( datablock );	
			count--;		
	}
	return( count );
}