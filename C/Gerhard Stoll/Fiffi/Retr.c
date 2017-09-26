#include	<mt_mem.h>
#include	<PORTAB.H>
#include <STDDEF.H>
#include <STDLIB.H>
#include <STDIO.H>
#include	<STRING.H>
#include	<MT_AES.H>

#include <atarierr.h>
#include <sockerr.h>

#include "main.h"
#include	"Retr.h"
#include	"Ftp.h"

extern volatile ULONG	BufLen;

/*----------------------------------------------------------------------------------------*/ 
/* WorkRFile                                                                              */
/*----------------------------------------------------------------------------------------*/ 
int	WorkRFile( FILE *MsgHandle, FILE **Handle, BYTE **DataPuf, LONG *DataPufLen, LONG *DataPufOffset, BYTE **Filename, WORD GemFtpAppId, WORD Flag, WORD Global[15] )
{
	WORD	Msg[8];
	if( *DataPuf )
	{
		if( *DataPufLen == 0 )
		{
			free( *DataPuf );
			fclose( *Handle );
		}
		else
		{
			fwrite( *DataPuf, sizeof( BYTE ), *DataPufLen, *Handle );
			Msg[0] = Retr_Update;
			Msg[1] = Global[2];
			Msg[2] = 0;
			Msg[4] = (WORD) *DataPufLen;
			while( MT_appl_write( GemFtpAppId, 16, Msg, Global ) != 1 );
/*			if( MT_appl_read( -1, 16, Msg, Global ) && 
			    Msg[0] == Abor_Cmd && Msg[1] == GemFtpAppId )
			{
				fclose( *Handle );
				return( ABORT );
			}	*/
		}
		*DataPufLen = BufLen;
		*DataPufOffset = 0;
		return( E_OK );
	}
	else
	{
#ifdef	RESUME
		*Handle = fopen( *Filename, "ab" );
#else
		*Handle = fopen( *Filename, "wb" );
#endif
		if( !*Handle )
			return( EFILNF );
		*DataPuf = malloc( BufLen + 1 );
		if( !( *DataPuf ))
			return( ENSMEM );
		*DataPufLen = BufLen;
		*DataPufOffset = 0;
		return( E_OK );
	}
}