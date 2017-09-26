#include	<mt_mem.h>
#include	<PORTAB.H>
#include <STDDEF.H>
#include	<TOS.H>
#include	<MT_AES.H>
#include <STDLIB.H>
#include	<STDIO.H>
#include	<STRING.H>

#include	<usis.h>
#include <atarierr.h>

#include	"main.h"
#include	"Fiffi.h"
#include	"Url.h"
#include	"Window.h"
#include "mapkey.h"

extern UWORD	ComPort;
#ifdef	V110
extern WORD		Sockets;
#endif

/*-----------------------------------------------------------------------------*/
/* ParseFtpUrl                                                                 */
/* sock_init() muž unbedingt erledig sein!                                     */
/*-----------------------------------------------------------------------------*/
WORD	ParseFtpUrl( BYTE	*Url, SESSION *Session )
{
	BYTE	Puf[512];
	BYTE	Host[128], UserId[128], Pwd[128], Path[256];
	BYTE	TT;
	WORD	Port = 0;
	WORD	n;
	memset( Puf, 0, 512 );
	memset( Host, 0, 128 );
	memset( UserId, 0, 128 );
	memset( Pwd, 0, 128 );
	memset( Path, 0, 256 );

	Session->Host = NULL;
	Session->Uid = NULL;
	Session->Pwd = NULL;
	Session->Dir = NULL;
	Session->Port = 0;
	sscanf( Url, "ftp://%s", Puf );	
	if( strchr( Puf, '@' ))
	{
		sscanf( Puf, "%[^:@]", UserId ); 
		memmove( Puf, Puf + strlen( UserId ), strlen( Puf ) - strlen( UserId ) + 1 );
		Session->Uid = strdup( UserId );
		if( !Session->Uid )
			return( ENSMEM );
		if( *Puf == ':' )
		{
			*strrchr( Puf, '@' ) = 0;
			sscanf( Puf, ":%s", Pwd ); 
			*( Puf + strlen( Pwd ) + 1 ) = '@';
			memmove( Puf, Puf + strlen( Pwd ) + 1, strlen( Puf ) - strlen( Pwd ) + 1 );
			Session->Pwd = strdup( Pwd );
			if( !Session->Pwd )
				return( ENSMEM );
		}
		else
		{
			Session->Pwd = strdup( "" );
			if( !Session->Pwd )
				return( ENSMEM );
		}
		memmove( Puf, Puf + 1, strlen( Puf ));
		
	}
	sscanf( Puf, "%[^:;/]%n", Host, &n );
	memmove( Puf, Puf + n, strlen( Puf + n ) + 1 );
	Session->Host = strdup( Host );
	if( !Session->Host )
		return( ENSMEM );
	if( *Puf == ':' )
	{
		sscanf( Puf, ":%i%n", &Port, &n );
		memmove( Puf, Puf + n, strlen( Puf + n ) + 1 );
		Session->Port = Port;
	}
	if( *Puf == ';' )
	{
		sscanf( Puf, ";type=%c", &TT );
		memmove( Puf, Puf + 7, strlen( Puf + 7 ) + 1 );
	}
	sscanf( Puf, "%s", Path );
	Session->Dir = strdup( Path );
	if( !Session->Dir )
		return( ENSMEM );
	if( Session->Port == 0 )
		Session->Port = ComPort;
	if( !Session->Uid )
	{
		Session->Uid = strdup( "anonymous" );
		if( !Session->Uid )
			return( ENSMEM );
	}
	if( Sockets && ( strcmp( Session->Uid, "anonymous" ) == 0 || strcmp( Session->Uid, "ftp" ) == 0 ))
	{
		USIS_REQUEST	Usis;
		Usis.result = malloc( 256 * sizeof( BYTE ));
		if( !Usis.result )
			return( ENSMEM );
		Usis.request = UR_EMAIL_ADDR;
		if( usis_query( &Usis ) == UA_FOUND )
			Session->Pwd = strdup( Usis.result );
		else
			Session->Pwd = strdup( "" );
		free( Usis.result );
	}
	if( !Session->Dir )
	{
		Session->Dir = strdup( "" );
		if( !Session->Dir )
			return( ENSMEM );
	}
	Session->Comment = NULL;
	return( E_OK );
}

BYTE	*MakeFtpUrl( BYTE *Host, WORD Port, BYTE *Uid, BYTE *Pwd, BYTE *Dir )
{
	BYTE	P[10];
	BYTE	*Url = malloc( 1024 );
	if( !Url )
		return( 0 );
	strcpy( Url, "ftp://" );
	if( Uid && strlen( Uid ))
	{
		strcat( Url, Uid );
		if( Pwd && strlen( Pwd ))
		{
			strcat( Url, ":" );
			strcat( Url, Pwd );
		}
		strcat( Url, "@" );
	}
	strcat( Url, Host );
	strcat( Url, ":" );
	strcat( Url, itoa( Port, P, 10 ));
	if( Dir )
	{
/*		if( *Dir != '/' )
			strcat( Url, "/" );	*/
		strcat( Url, Dir );
	}
/*	else
		strcat( Url, "/" );	*/
	return( Url );
}

WORD cdecl	HandleNoFtpUrlDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD )
{
	OBJECT	*DialogTree;
	GRECT		Rect;

	WORD 		*Global;
	Global = (WORD *) UD;

	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );

	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_INIT:
			{
				DialogTree[NFU_CANCEL].ob_state &= ~SELECTED;
				break;
			}
			case	HNDL_MESG:
			{
				if( Events->msg[0] == WM_ICONIFY )
				{
					RSHDR 	*Rsh;
					OBJECT	**TreeAddr;
					Rsh = *((RSHDR **)( &(Global[7] )));	
					TreeAddr = (OBJECT **)(((UBYTE *)Rsh) + Rsh->rsh_trindex);
					if( !isIconifiedWindow( MT_wdlg_get_handle( Dialog, Global )))
					{
						DialogTree = malloc( 2 * sizeof( OBJECT ));
						if( !DialogTree )
						{
							MemErr( "NoFtpUrl" );
							return( 0 );
						}
						memcpy( DialogTree, TreeAddr[ICONIFY], 2 * sizeof( OBJECT ));
						MT_wdlg_set_iconify( Dialog, ( GRECT *) &( Events->msg[4] ), NULL, DialogTree, ICONIFY_ICON, Global );
						IconifyWindow( MT_wdlg_get_handle( Dialog, Global ));
					}
					else
						MT_wind_set_grect( MT_wdlg_get_handle( Dialog, Global ), WF_CURRXYWH, ( GRECT *) &( Events->msg[4] ), Global );
				}
				if( Events->msg[0] == WM_UNICONIFY )
				{
					RSHDR 	*Rsh;
					OBJECT	**TreeAddr;
					Rsh = *((RSHDR **)( &(Global[7] )));
					TreeAddr = (OBJECT **)(((UBYTE *)Rsh) + Rsh->rsh_trindex);
					MT_wdlg_set_uniconify( Dialog, ( GRECT *) &( Events->msg[4] ), NULL, TreeAddr[NFU], Global );
					UnIconifyWindow( MT_wdlg_get_handle( Dialog, Global ));
					free( DialogTree );
				}
				if( Events->msg[0] == WM_ALLICONIFY )
				{
					WORD	Msg[8];
					Msg[0] = WM_ALLICONIFY;
					Msg[1] = Global[2];
					Msg[2] = 0;
					Msg[3] = 0;
					Msg[4] = Events->msg[4]; Msg[5] = Events->msg[5]; Msg[6] = Events->msg[6];	Msg[7] = Events->msg[7];
					MT_appl_write( Global[2], 16, Msg, Global );
				}
				break;
			}
			case	HNDL_CLSD:
				return( 0 );
		}
	}
	else
	{
		Obj &= 0x7fff;
		if( Obj == NFU_CANCEL )
			return( 0 );
	}
	return( 1 );
}
