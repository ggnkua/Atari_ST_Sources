#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<TOS.H>
#include	<MT_AES.H>
#include <STDDEF.H>
#include <STDLIB.H>
#include <STDIO.H>
#include	<STRING.H>

#include	<atarierr.h>

#include	"main.h"
#include	"Window.h"
#include "dragdrop.h"
#include	"DD.h"

extern WORD	AppId;

WORD	DDUrl( WORD X, WORD Y, WORD Key, BYTE *Url, WORD Global[15] )
{
	WORD	WinHandle;
	if(( WinHandle = MT_wind_find( X, Y, Global )) != -1 )
	{
		WORD	w1, w2, w3, w4;
		MT_wind_get( WinHandle, WF_OWNER, &w1, &w2, &w3, &w4, Global );
		if( !isWindow( WinHandle ))
		{
			ULONG	FormatRcvr[8];
			void	*OldSig;
			WORD	Fd;
			if(( Fd = ddcreate( Global[2], w1, WinHandle, X, Y, Key, FormatRcvr, &OldSig, Global )) >= 0 )
			{
				if( ddstry( Fd, 'URLS', "", strlen( Url ) + 1 + strlen( Url + strlen( Url ) + 1 ) + 1 ) == DD_OK )
				{
					if( Fwrite( Fd, strlen( Url ) + 1 + strlen( Url + strlen( Url ) + 1 ) + 1, Url ) > 0 )
					{
						ddclose( Fd, OldSig );
						return( E_OK );
					}
				}
				else if( ddstry( Fd, '.TXT', "", strlen( Url ) + 1 ) == DD_OK || 
				    ddstry( Fd, '.ASC', "", strlen( Url ) + 1 ) == DD_OK )
				{
					if( Fwrite( Fd, strlen( Url ) + 1, Url ) > 0 )
					{
						ddclose( Fd, OldSig );
						return( E_OK );
					}
				}
				ddclose( Fd, OldSig );
			}
			return( ERROR );
		}
		else
		{
			WORD	Msg[8];
			Msg[0] = DRAGDROP;
			Msg[1] = Global[2];
			Msg[2] = 0;
			Msg[3] = WinHandle;
			*( BYTE **) &Msg[4] = strdup( Url );
			MT_appl_write( AppId, 16, Msg, Global );
		}
	}

	return( E_OK );
}

