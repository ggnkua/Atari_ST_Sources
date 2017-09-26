#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<MT_AES.H>
#include <STDDEF.H>
#include <STDLIB.H>
#include <STDIO.H>
#include	<STRING.H>
#include	<EXT.H>

#include	"main.h"
#include	"Register.h"

void	DecodeName( BYTE *DestSer, BYTE *DestName, BYTE *DestFirma )
{
	BYTE	Ver[] = FiffiVersion;

	strcpy( DestSer, "0000000000" );
	strcpy( DestFirma, "" );

	if( Ver[4] == 'b' )
	{
		strcpy( DestName, "Beta-Version" );
	}
	else
	{
		strcpy( DestName, "Final-Version" );
	}
#ifdef	DEBUG
	strcpy( DestFirma, "Debug-Version" );
#endif
}