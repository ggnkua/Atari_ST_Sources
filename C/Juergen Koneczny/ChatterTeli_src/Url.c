#include	<mt_mem.h>
#include	<PORTAB.H>
#include <STDDEF.H>
#include	<STDLIB.H>
#include	<STRING.H>

#include	"Url.h"

BYTE	*MakeTelnetUrl( BYTE *Host, UWORD Port )
{
}

BYTE	*GetTelnetUrl( BYTE *Url )
{
	if( strncmp( Url, "telnet://", strlen( "telnet://" )) == 0 )
		return( strdup( &( Url[strlen( "telnet://" )] )));
	return(( BYTE * ) NULL );
}