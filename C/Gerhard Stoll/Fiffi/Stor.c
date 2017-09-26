#include	<mt_mem.h>
#include	<PORTAB.H>
#include <STDDEF.H>
#include <STDLIB.H>
#include <STDIO.H>
#include	<STRING.H>
#include	<MT_AES.H>

#include <atarierr.h>

#include "main.h"
#include	"Stor.h"
#include	"Ftp.h"

extern volatile ULONG	BufLen;

/*----------------------------------------------------------------------------------------*/ 
/* WorkTFile                                                                              */
/*----------------------------------------------------------------------------------------*/ 
int	WorkTFile( FILE **Handle, BYTE **DataPuf, LONG *DataPufLen, LONG *PufOffset, BYTE **Dirname, WORD GemFtpAppId, WORD Global[15] )
{
	WORD	Msg[8];
	LONG	Ret;
	if( *DataPuf )
	{
		Msg[0] = Stor_Update;
		Msg[1] = Global[2];
		Msg[2] = 0;
		Msg[4] = ( WORD ) *DataPufLen;
		while( MT_appl_write( GemFtpAppId, 16, Msg, Global ) != 1 );
		if( MT_appl_read( -1, 16, Msg, Global ) && 
		    Msg[0] == Abor_Cmd && Msg[1] == GemFtpAppId )
		{
			return( ABORT );
		}
/*		fseek( *Handle, *PufOffset, SEEK_SET );	*/
		if(( Ret = fread( *DataPuf, sizeof( BYTE ), *DataPufLen, *Handle )) == 0 )
		{
			Ret = EOF;
			free( *DataPuf );
			fclose( *Handle );
		}
		else
		{
			*DataPufLen = ( LONG ) Ret;
			Ret = E_OK;
		}
		return(( WORD ) Ret );
	}
	else
	{
		*DataPuf = malloc( BufLen + 1 );
		if( !( *DataPuf ))
			return( ENSMEM );
		*DataPufLen = BufLen;
		*PufOffset = 0;
		*Handle = fopen( *Dirname, "rb" );
		if( !*Handle )
			return( EFILNF );
		Ret = fread( *DataPuf, sizeof( BYTE ), *DataPufLen, *Handle );
		*DataPufLen = ( LONG ) Ret;
		return( E_OK );
	}
}