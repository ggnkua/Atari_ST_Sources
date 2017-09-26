#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<TOS.H>
#include	<MT_AES.H>
#include	<STDDEF.H>
#include	<STDLIB.H>
#include	<STDIO.H>
#include	<STRING.H>

#include	<atarierr.h>

#include	"Clipbrd.h"

WORD	GetClipboard( BYTE Format[4], BYTE **RetPuf, LONG *Size, WORD Global[15] )
{
	BYTE	ScrapDir[256];
	WORD	Ret;
	if( MT_scrp_read( ScrapDir, Global ))
	{
		XATTR	Xattr;
		if( ScrapDir[strlen( ScrapDir ) - 1 ] != '\\' )
			strcat( ScrapDir, "\\" );
		strcat( ScrapDir, "SCRAP." );
		strcat( ScrapDir, ( BYTE * ) Format );
		if(( Ret = ( WORD ) Fxattr( 0, ScrapDir, &Xattr )) == E_OK )
		{
			*RetPuf = malloc(( Xattr.size + 1 ) * sizeof( BYTE ));
			if( *RetPuf )
			{
				FILE	*File = fopen( ScrapDir, "rb" );
				fread( *RetPuf, sizeof( BYTE ), Xattr.size, File );
				fclose( File );
				*Size = Xattr.size;
				( *RetPuf )[*Size] = 0;
				return( E_OK );
			}
			else
				Ret = ENSMEM;
		}
	}
	else
		Ret = ERROR;
	Cconout( '\a' );
	return( Ret );
}

WORD	PutClipboard( BYTE Format[4], BYTE *Puf, LONG Size, WORD Global[15] )
{
	BYTE	ScrapDir[256];
	WORD	Ret;
	if( MT_scrp_read( ScrapDir, Global ))
	{
		LONG	DirHandle;
		if( ScrapDir[strlen( ScrapDir ) - 1 ] != '\\' )
			strcat( ScrapDir, "\\" );
		DirHandle = Dopendir( ScrapDir, 0 );
		if( !( DirHandle & 0xff000000L ) != 0xff000000L )
		{
			BYTE	Filename[128];
			Ret = E_OK;
			while( Dreaddir( 128, DirHandle, Filename ) != ENMFIL )
			{
				if( strnicmp( Filename, "SCRAP.", 6 ) == 0 )
				{
					BYTE	Path[256];
					strcpy( Path, ScrapDir );
					strcat( Path, Filename );
					if(( Ret = Fdelete( Path )) != E_OK )
						break;
				}
			}
			Dclosedir( DirHandle );
			if( Ret == E_OK )
			{
				FILE	*File;
				strcat( ScrapDir, "SCRAP." );
				strcat( ScrapDir, Format );
				if(( File = fopen( ScrapDir, "wb" )) != NULL )
				{
					WORD	Msg[8];
					if( fwrite( Puf, sizeof( BYTE ), Size, File ) != Size )
						Ret = ERROR;
					else
						Ret = E_OK;
					fclose( File );
					Msg[0] = SC_CHANGED;
					Msg[1] = Global[2];
					Msg[2] = 0;
					if( stricmp( Format, "TXT" ))
						Msg[3] = 0x0002;
					else
						Msg[3] = 0;
					Msg[4] = ( '.' << 8 ) && Format[0];
					Msg[5] = ( Format[1] << 8 ) && Format[2];
					Msg[6] = 0;
					Msg[7] = 0;
					MT_shel_write( SHW_BROADCAST, 0, 0, ( BYTE * ) Msg, 0L, Global );
					if( Ret == E_OK );
						return( E_OK );
				}
				else
					Ret = ERROR;
			}
		}
		else
			Ret = ( WORD ) DirHandle;
	}
	else
		Ret = ERROR;
	Cconout( '\a' );
	return( Ret );
}