#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<TOS.H>
#include	<VDICOL.H>
#include	<MT_AES.H>
#include	<STDDEF.H>
#include	<STDLIB.H>
#include	<STRING.H>
#include	<STDIO.H>

#include	<atarierr.h>
#ifdef	DRACONIS
#include	<stsocket.h>
#endif
#ifdef	ICONNECT
#include	<iconnect\inet.h>
#include	<iconnect\sockinit.h>
#endif

#include	"DD.h"
#include	"main.h"
#include	RSCHEADER
#include	"Irc.h"
#include	"Help.h"
#include	"IConnect.h"
#include	"Menu.h"
#include	"Rsc.h"
#include	"TCP.h"
#include	"WDialog.h"
#include	"Window.h"
#include	"WIrc\Func.h"
#include	"WIrc\IrcFunc.h"
#include	"WIrc\WDccChat.h"
#include	"WIrc\WChat.h"
#include	"ExtObj\TextObj.h"

#include	"Keytab.h"
#include	"MapKey.h"

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern WORD	Global[15], VdiHandle;
extern OBJECT	**TreeAddr;
extern WORD	SessionCounter, PingFlag;
extern KEYT	*Keytab;
extern WORD	KeytabAnsiExport, KeytabAnsiImport;
extern WORD	IrcFlags;

typedef	struct
{
	BYTE			*Nickname;

	CHAT_WINDOW	*ChatWindow;

	UWORD	Port;
	ULONG	IP;

	WORD	TcpAppId;
	void	*TcpMsgPuf;
	BYTE	*Msg;
	LONG	MsgLen;

	MOD_WIN	*ModWin;

	IRC	*Irc;
	IRC_SESSION	*IrcSession;
}	DCC_CHAT;

typedef	struct
{
	WORD			WinId;
	GRECT			NextFuller;
	BYTE			*Title;
	BYTE			*Info;
	XEDITINFO	*XEdit;
	DIALOG_DATA	*DialogData;
	DCC_CHAT		*DccChat;

	BYTE	*Msg;
	LONG	MsgLen;
	void	*TcpMsgPuf;
}	DCC_CHAT_WINDOW;

#define	MODWIN_ASKDCCCHAT				0x0001
#define	MODWIN_CONNECTION_CLOSED	0x0002

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
static WORD			OpenWindow( DCC_CHAT *DccChat, WORD Global[15] );
static WORD			Start( DCC_CHAT *DccChat, WORD Global[15] );
static DCC_CHAT	*MakeDccChat( BYTE *Nickname, IRC_SESSION *IrcSession, IRC *Irc, UWORD Port, ULONG IP );
static void			FreeDccChat( DCC_CHAT *DccChat );
static void			OpenAlert( DCC_CHAT *DccChat, WORD WinId, WORD Type );
static void 		CloseAlert( void *UD, WORD Button, WORD WinId, WORD Global[15] );

static WORD	cdecl SendWindow( BYTE *Puf, void *UserData, WORD Global[15] );
static void	SetButtonWindow( void *UserData, WORD Global[15] );
static WORD	cdecl ButtonWindow( WORD Obj, void *UserData, WORD Global[15] );
static WORD	cdecl MessageWindow( EVNT *Events, void *UserData, WORD Global[15] );
static WORD	CheckWindow( EVNT *Events, void *UserData, WORD Global[15] );
static WORD	ClosedWindow( void *UserData, WORD Global[15] );

static void ParseInput( DCC_CHAT *DccChat, WORD Global[15] );
static void	ParseMessage( DCC_CHAT *DccChat, char *Msg, WORD Global[15] );

static WORD cdecl	HandleInfoDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData );
static WORD HndlClsInfoDialog( void *DialogData, WORD Global[15] );

/*-----------------------------------------------------------------------------*/
/* AskDccChatSession                                                           */
/*-----------------------------------------------------------------------------*/
WORD	AskDccChatSession( IRC *Irc, BYTE *Nickname, UWORD Port, ULONG IP, WORD Global[15] )
{
	DCC_CHAT	*DccChat = MakeDccChat( Nickname, NULL, Irc, Port, IP );
	if( !DccChat )
		return( ENSMEM );

#ifdef	DRACONIS
	{
		struct in_addr	x;
		x.s_addr = IP;
		OpenAlert( DccChat, AlertDialogX( 1, TreeAddr[ALERTS][ALERT_ASK_DCCCHAT].ob_spec.free_string, DccChat->Nickname, CloseAlert, DccChat, Global, 2, Nickname, inet_ntoa( x )), MODWIN_ASKDCCCHAT );
	}
#endif
#ifdef	ICONNECT
	OpenAlert( DccChat, AlertDialogX( 1, TreeAddr[ALERTS][ALERT_ASK_DCCCHAT].ob_spec.free_string, DccChat->Nickname, CloseAlert, DccChat, Global, 2, Nickname, inet_ntoa( IP )), MODWIN_ASKDCCCHAT );
#endif
	return( E_OK );
}

/*-----------------------------------------------------------------------------*/
/* OpenDccChatSession                                                          */
/*-----------------------------------------------------------------------------*/
WORD	OpenDccChatSession( IRC_SESSION *IrcSession, BYTE *Nickname, WORD Global[15] )
{
	DCC_CHAT	*DccChat = MakeDccChat( Nickname, IrcSession, IrcSession->Irc, 0, 0 );
	if( !DccChat )
		return( ENSMEM );
	if( OpenWindow( DccChat, Global ) != E_OK )
	{
		FreeDccChat( DccChat );
		return( ERROR );
	}
	if( Start( DccChat, Global ) != E_OK )
	{
/* ChatWindow schliežen */
		return( ERROR );
	}
	return( E_OK );
}

/*-----------------------------------------------------------------------------*/
/* OpenWindow                                                                  */
/*-----------------------------------------------------------------------------*/
static WORD	OpenWindow( DCC_CHAT *DccChat, WORD Global[15] )
{
	BYTE	Title[128];
	if(( DccChat->ChatWindow = malloc( sizeof( CHAT_WINDOW ))) == NULL )
		return( ENSMEM );
	DccChat->ChatWindow->UserData = DccChat;
	DccChat->ChatWindow->SendChatWindow = SendWindow;
	DccChat->ChatWindow->SetButtonChatWindow = SetButtonWindow;
	DccChat->ChatWindow->DoubleClickChatWindow = NULL;
	DccChat->ChatWindow->ButtonChatWindow = ButtonWindow;
	DccChat->ChatWindow->MessageChatWindow = MessageWindow;
	DccChat->ChatWindow->TimerChatWindow = NULL;
	DccChat->ChatWindow->CheckChatWindow = CheckWindow;
	DccChat->ChatWindow->ClosedChatWindow = ClosedWindow;

	sprintf( Title, "%s %s", TreeAddr[TITLES][TITLE_WINDOW].ob_spec.free_string, DccChat->Nickname );
	DccChat->ChatWindow->Title = strdup( Title );
	DccChat->ChatWindow->Info = NULL;

	return( OpenChatWindow( "DccChat", DccChat->Nickname, WIN_CHAT_DCC, DccChat->Irc->nLines, DccChat->Irc->OutputFontId, DccChat->Irc->OutputFontHt, DccChat->Irc->InputFontId, DccChat->Irc->InputFontHt, DccChat->Irc->ColourTable, ( IrcFlags & WINDOW_OVERWRITE ), DccChat->Irc->LogFlag, DccChat->ChatWindow, Global ));
}

static WORD	Start( DCC_CHAT *DccChat, WORD Global[15] )
{
	if(( DccChat->TcpAppId = Tcp( Global )) <= 0 )
		return( ERROR );
	else
	{
		WORD	Msg[8];
		Msg[0] = TCP_CMD;
		Msg[1] = Global[2];
		Msg[2] = 0;
		Msg[3] = DccChat->ChatWindow->WinId;
		Msg[4] = TCP_init;
		while( MT_appl_write( DccChat->TcpAppId, 16, Msg, Global ) != 1 );
		SessionCounter++;
	}
	return( E_OK );
}

/*-----------------------------------------------------------------------------*/
/* MakeChatSession                                                             */
/*-----------------------------------------------------------------------------*/
static DCC_CHAT	*MakeDccChat( BYTE *Nickname, IRC_SESSION *IrcSession, IRC *Irc, UWORD Port, ULONG IP )
{
	DCC_CHAT	*DccChat = malloc( sizeof( DCC_CHAT ));
	if( !DccChat )
		return( NULL );

	if(( DccChat->Nickname = strdup( Nickname )) == NULL )
	{
		free( DccChat );
		return( NULL );
	}
	if(( DccChat->Irc = CopyIrc( Irc )) == NULL )
	{
		free( DccChat->Nickname );
		free( DccChat );
		return( NULL );
	}
	DccChat->ChatWindow = NULL;
	DccChat->Port = Port;
	DccChat->IP = IP;
	DccChat->TcpMsgPuf = NULL;
	DccChat->Msg = NULL;
	DccChat->MsgLen = 0;
	DccChat->ModWin = NULL;
	DccChat->IrcSession = IrcSession;
	return( DccChat );
}

/*-----------------------------------------------------------------------------*/
/* FreeChatSession                                                             */
/*-----------------------------------------------------------------------------*/
static void	FreeDccChat( DCC_CHAT *DccChat )
{
	if( DccChat->Nickname )
		free( DccChat->Nickname );
	FreeIrc( DccChat->Irc );
	if( DccChat->Msg )
		free( DccChat->Msg );
	free( DccChat );
}

/*-----------------------------------------------------------------------------*/
/* OpenAlert                                                                   */
/*-----------------------------------------------------------------------------*/
static void	OpenAlert( DCC_CHAT *DccChat, WORD WinId, WORD Type )
{
	if( Type == MODWIN_ASKDCCCHAT )
		return;
	else	if( WinId > 0 )
	{
		MOD_WIN	**ModWin, *New, *Last = NULL;
		ModWin = &( DccChat->ModWin );
		if(( New = malloc( sizeof( MOD_WIN ))) == NULL )
			return;
		New->WinId = WinId;
		New->Type = Type;
		New->next = NULL;
		if( *ModWin )
		{
			Last = *ModWin;
			while( Last->next )
				Last = Last->next;
			Last->next = New;
		}
		else
			*ModWin = New;
		New->prev = Last;
	}
}

/*-----------------------------------------------------------------------------*/
/* CloseAlert                                                                   */
/*-----------------------------------------------------------------------------*/
static void CloseAlert( void *UD, WORD Button, WORD WinId, WORD Global[15] )
{
	DCC_CHAT	*DccChat = ( DCC_CHAT * ) UD;
	if( !DccChat->ChatWindow )
	{
		if( Button == 1 )
		{
			if( OpenWindow( DccChat, Global ) != E_OK )
			{
				MT_form_alert( 1, TreeAddr[ALERTS][MEMORY].ob_spec.free_string, Global );
				FreeDccChat( DccChat );
			}
			else
			{
				if( Start( DccChat, Global ) != E_OK )
				{
					MT_form_alert( 1, TreeAddr[ALERTS][MEMORY].ob_spec.free_string, Global );
/* ChatWindow schliežen */
				}
			}
		}
		else
			FreeDccChat( DccChat );
	}
	else
	{
		MOD_WIN	**ModWin = &( DccChat->ModWin );
		MOD_WIN	*Del = *ModWin;
		WORD	Type;
		while( Del )
		{
			if( Del->WinId == WinId )
				break;
			Del = Del->next;
		}
		if( !Del )
			return;

		if( Del->next )
			( Del->next )->prev = Del->prev;
		if( Del->prev )
			( Del->prev )->next = Del->next;
		else
			*ModWin = Del->next;
		Type = Del->Type;
		switch( Type )
		{
			case	MODWIN_CONNECTION_CLOSED:
				if( DccChat->ChatWindow )
				{
					WORD	Msg[8];
					Msg[0] = TCP_CMD;
					Msg[1] = Global[2];
					Msg[2] = 0;
					Msg[3] = DccChat->ChatWindow->WinId;
					Msg[4] = TCP_close;
					TcpMessage( Msg, &( DccChat->TcpMsgPuf ), DccChat->TcpAppId, Global );
#ifdef	DRACONIS
					{
						EVNT	Evnt;
						MT_shel_write( 72, 0, DccChat->TcpAppId, NULL, NULL, Global );
						Evnt.mwhich = MU_MESAG;
						Evnt.msg[0] = TCP_ACK;
						Evnt.msg[1] = DccChat->TcpAppId;
						Evnt.msg[2] = 0;
						Evnt.msg[3] = DccChat->ChatWindow->WinId;
						Evnt.msg[4] = TCP_close;
						HandleWindow( &Evnt, Global );
					}
#endif					
				}
				break;
		}
	}
}


/*-----------------------------------------------------------------------------*/
/* ButtonWindow                                                                */
/*-----------------------------------------------------------------------------*/
static WORD	cdecl ButtonWindow( WORD Obj, void *UserData, WORD Global[15] )
{
	return( E_OK );
}

/*-----------------------------------------------------------------------------*/
/* SendWindow                                                                  */
/*-----------------------------------------------------------------------------*/
static WORD	cdecl SendWindow( BYTE *Puf, void *UserData, WORD Global[15] )
{
	DCC_CHAT *DccChat = ( DCC_CHAT * ) UserData;
	CHAT_WINDOW	*ChatWindow = DccChat->ChatWindow;
	if( Puf )
	{
		WORD	Msg[8];
		LONG	Len = strlen( Puf ) + 1;
		BYTE	*Tmp = malloc( Len + 1);
		Msg[0] = TCP_CMD;
		Msg[1] = Global[2];
		Msg[2] = 0;
		Msg[3] = ChatWindow->WinId;
		Msg[4] = TCP_out;
		strcpy( Tmp, Puf );
		strcat( Tmp, "\n" );
		Keytab->ExportString( KeytabAnsiExport, Len, Tmp );
		*( BYTE ** )&( Msg[5] ) = Tmp;
		Msg[7] = ( WORD ) Len;
		TcpMessage( Msg, &( DccChat->TcpMsgPuf ), DccChat->TcpAppId, Global );

		if(( Tmp = strdup( Puf )) != NULL )
		{
			ParseMessage( DccChat, Tmp, Global );
			free( Tmp );
			RedrawChatWindow( DccChat->ChatWindow, Global );
		}
	}
	return( E_OK );
}

/*-----------------------------------------------------------------------------*/
/* SetButtonWindow                                                             */
/*-----------------------------------------------------------------------------*/
static void	SetButtonWindow( void *UserData, WORD Global[15] )
{
}

/*-----------------------------------------------------------------------------*/
/* MesageWindow                                                                */
/*-----------------------------------------------------------------------------*/
static WORD	cdecl MessageWindow( EVNT *Events, void *UserData, WORD Global[15] )
{
	DCC_CHAT *DccChat = ( DCC_CHAT * ) UserData;
	CHAT_WINDOW	*ChatWindow = DccChat->ChatWindow;
	WORD	Msg[8];

	TcpMessage( NULL, &( DccChat->TcpMsgPuf ), -1, Global );

	switch( Events->msg[0] )
	{
		case	WM_CLOSED:
		{
			WORD	Msg[8];
			Msg[0] = TCP_CMD;
			Msg[1] = Global[2];
			Msg[2] = 0;
			Msg[3] = DccChat->ChatWindow->WinId;
			Msg[4] = TCP_close;
			TcpMessage( Msg, &( DccChat->TcpMsgPuf ), DccChat->TcpAppId, Global );
#ifdef	DRACONIS
			{
				EVNT	Evnt;
				MT_shel_write( 22, 0, DccChat->TcpAppId, NULL, NULL, Global );
				Evnt.mwhich = MU_MESAG;
				Evnt.msg[0] = TCP_ACK;
				Evnt.msg[1] = DccChat->TcpAppId;
				Evnt.msg[2] = 0;
				Evnt.msg[3] = DccChat->ChatWindow->WinId;
				Evnt.msg[4] = TCP_close;
				HandleWindow( &Evnt, Global );
			}
#endif					
			break;
		}
		case	TCP_CMD:
		{
			switch( Events->msg[4] )
			{
				case	TCP_closed:
					OpenAlert( DccChat, AlertDialog( 1, TreeAddr[ALERTS][CONNECTION_CLOSED].ob_spec.free_string, ChatWindow->Title, CloseAlert, DccChat, Global ), MODWIN_CONNECTION_CLOSED );
					break;
				case	TCP_in:
				{
					char	*Puf;
					Keytab->ImportString( KeytabAnsiImport, ( long ) Events->msg[7], *( BYTE ** )&( Events->msg[5] ));
					if( DccChat->Msg )
					{
						Puf = malloc( DccChat->MsgLen + ( long ) Events->msg[7] );
						memcpy( Puf, DccChat->Msg, DccChat->MsgLen );
						free( DccChat->Msg );
						DccChat->Msg = Puf;
						Puf += DccChat->MsgLen;
						DccChat->MsgLen += ( long ) Events->msg[7];
					}
					else
					{
						Puf = malloc(( long ) Events->msg[7] );
						DccChat->Msg = Puf;
						DccChat->MsgLen = ( long ) Events->msg[7];
					}
					memcpy( Puf, *( BYTE ** )&( Events->msg[5] ), ( long ) Events->msg[7] );
					Msg[0] = TCP_ACK;
					Msg[1] = Global[2];
					Msg[2] = 0;
					Msg[3] = ChatWindow->WinId;
					Msg[4] = TCP_in;
					*( long * )&( Msg[5] ) = *( long * )&( Events->msg[5] );
					TcpMessage( Msg, &( DccChat->TcpMsgPuf ), DccChat->TcpAppId, Global );
					ParseInput( DccChat, Global );
					break;
				}
				
			}
			break;
		}
		case	TCP_ACK:
		{
			switch( Events->msg[4] )
			{
				case	TCP_init:
					if( DccChat->IP )
						SetInfoChatWindow( TreeAddr[INFOS][TCP_CONNECT].ob_spec.free_string, ChatWindow, Global );
					else
						SetInfoChatWindow( TreeAddr[INFOS][TCP_WAITFORACK].ob_spec.free_string, ChatWindow, Global );
					Msg[0] = TCP_CMD;
					Msg[1] = Global[2];
					Msg[2] = 0;
					Msg[3] = ChatWindow->WinId;
					Msg[4] = TCP_socket;
					TcpMessage( Msg, &( DccChat->TcpMsgPuf ), DccChat->TcpAppId, Global );
					break;
				case	TCP_socket:
					if( Events->msg[4] < 0 )
					{
						OpenAlert( DccChat, AlertDialog( 1, TreeAddr[ALERTS][SOCKET_FAILED].ob_spec.free_string, ChatWindow->Title, CloseAlert, DccChat, Global ), MODWIN_CONNECTION_CLOSED );
						break;
					}
					else
					{
						if( DccChat->IP )
						{
							Msg[0] = TCP_CMD;
							Msg[1] = Global[2];
							Msg[2] = 0;
							Msg[3] = ChatWindow->WinId;
							Msg[4] = TCP_connect;
							*( long * )&( Msg[5] ) = DccChat->IP;
							Msg[7] = DccChat->Port;
							TcpMessage( Msg, &( DccChat->TcpMsgPuf ), DccChat->TcpAppId, Global );
						}
						else
						{
							Msg[0] = TCP_CMD;
							Msg[1] = Global[2];
							Msg[2] = 0;
							Msg[3] = ChatWindow->WinId;
							Msg[4] = TCP_bind;
							TcpMessage( Msg, &( DccChat->TcpMsgPuf ), DccChat->TcpAppId, Global );
						}
					}
					break;
				case	TCP_connect:
				{
					if( Events->msg[7] == E_OK )
					{
						OBJECT		*DialogTree;
						GRECT			Rect;
						MT_wdlg_get_tree( DccChat->ChatWindow->DialogData->Dialog, &DialogTree, &Rect, Global );
						
						SetInfoChatWindow( "", DccChat->ChatWindow, Global );
						if( PingFlag )
							Cconout( '\a' );

						mt_edit_cursor( ChatWindow->DialogData->Tree, WCHAT_INPUT, ChatWindow->WinId , 1, Global );
						break;
					}
					OpenAlert( DccChat, AlertDialog( 1, TreeAddr[ALERTS][CONNECT_FAILED].ob_spec.free_string, ChatWindow->Title, CloseAlert, DccChat, Global ), MODWIN_CONNECTION_CLOSED );
					break;
				}
				case	TCP_close:
				{
					EVNT	lEvents;
					SessionCounter--;
					lEvents.mwhich = MU_MESAG;
					lEvents.msg[0] = ICONNECT_ACK;
					lEvents.msg[1] = Global[2];
					lEvents.msg[2] = 0;
					lEvents.msg[3] = ChatWindow->WinId;
					HandleIConnect( &lEvents, Global );
					return( 1 );
				}
				case	TCP_out:
				{
					free( *( BYTE ** )&( Events->msg[5] ));
					break;
				}
				case	TCP_bind:
				{
					if( Events->msg[7] > 0 )
					{
						BYTE	Puf[512];
						DccChat->IP = *( long * )&( Events->msg[5] );
						DccChat->Port = Events->msg[7];
						Msg[0] = TCP_CMD;
						Msg[1] = Global[2];
						Msg[2] = 0;
						Msg[3] = ChatWindow->WinId;
						Msg[4] = TCP_accept;
						TcpMessage( Msg, &( DccChat->TcpMsgPuf ), DccChat->TcpAppId, Global );
						sprintf( Puf, "\001DCC CHAT chat %lu %u\001", DccChat->IP, DccChat->Port );
						SendMessage( DccChat->IrcSession, GenerateMessage( Puf, DccChat->Nickname, DccChat->IrcSession, Global ), Global );
					}
					else
						OpenAlert( DccChat, AlertDialog( 1, TreeAddr[ALERTS][CONNECT_FAILED].ob_spec.free_string, ChatWindow->Title, CloseAlert, DccChat, Global ), MODWIN_CONNECTION_CLOSED );
					break;
				}
				case	TCP_accept:
				{
					OBJECT		*DialogTree;
					GRECT			Rect;
					MT_wdlg_get_tree( DccChat->ChatWindow->DialogData->Dialog, &DialogTree, &Rect, Global );
						
					SetInfoChatWindow( "", DccChat->ChatWindow, Global );
					if( PingFlag )
						Cconout( '\a' );

					mt_edit_cursor( ChatWindow->DialogData->Tree, WCHAT_INPUT, ChatWindow->WinId , 1, Global );
					break;
				}
			}
			break;
		}
	}
	return( E_OK );
}

/*-----------------------------------------------------------------------------*/
/* CheckWindow                                                                 */
/*-----------------------------------------------------------------------------*/
static WORD	CheckWindow( EVNT *Events, void *UserData, WORD Global[15] )
{
	DCC_CHAT *DccChat = ( DCC_CHAT * ) UserData;
	CHAT_WINDOW	*ChatWindow = DccChat->ChatWindow;
	if( DccChat->ModWin )
	{
		WORD	WinId = DccChat->ModWin->WinId, Ret;
		WORD	TopWinId, TopAppId, Dummy;
		MT_wind_get( 0, WF_TOP, &TopWinId, &TopAppId, &Dummy, &Dummy, Global );
		if( TopWinId == ChatWindow->WinId )
			MT_wind_set_int( WinId, WF_TOP, 0, Global );
		if( Events->mwhich & MU_MESAG )
		{
			switch( Events->msg[0] )
			{
				case	WM_CLOSED:
					if( Events->msg[3] != WinId && Events->msg[4] != WIN_CLOSE_WITHOUT_DEMAND )
					{
						Events->mwhich &= ~MU_MESAG;
						Ret = ERROR;
					}
					break;
				case	WM_ONTOP:
				case	WM_TOPPED:
					if( Events->msg[3] != WinId && Events->msg[4] != WIN_CLOSE_WITHOUT_DEMAND )
					{
						MT_wind_set_int( WinId, WF_TOP, 0, Global );
						Events->mwhich &= ~MU_MESAG;
					}
					break;
			}
		}
		if( Events->mwhich & MU_BUTTON )
		{
			WORD	Id = MT_wind_find( Events->mx, Events->my, Global );
			if( WinId != Id )
			{
				Events->mwhich &= ~MU_BUTTON;
				MT_wind_set_int( WinId, WF_TOP, 0, Global );
			}
		}
	}
	return( E_OK );
}

/*-----------------------------------------------------------------------------*/
/* ClosedWindow                                                                */
/*-----------------------------------------------------------------------------*/
static WORD	ClosedWindow( void *UserData, WORD Global[15] )
{
	DCC_CHAT *DccChat = ( DCC_CHAT * ) UserData;
	WriteConfigChatWindow( "DccChat", DccChat->Nickname, DccChat->ChatWindow, Global );
	FreeDccChat( DccChat );
	return( E_OK );
}

/*-----------------------------------------------------------------------------*/
/* ParseInput                                                                  */
/*-----------------------------------------------------------------------------*/
static void ParseInput( DCC_CHAT *DccChat, WORD Global[15] )
{
	long	Pos = 0, StartPos = 0;
	char	Msg[512];
	while( Pos < DccChat->MsgLen )
	{
		if( DccChat->Msg[Pos] == '\n' )
		{
			memcpy( Msg, &( DccChat->Msg[StartPos] ), Pos + 1 - StartPos );
			Msg[Pos-StartPos+1] = '\0';

			ParseMessage( DccChat, Msg, Global );

			Pos += 1;
			StartPos = Pos;
		}
		else
			Pos++;
	}
	if( StartPos )
	{
		if( DccChat->MsgLen - StartPos > 0 )
		{
			memmove( DccChat->Msg, &( DccChat->Msg[StartPos] ), DccChat->MsgLen - StartPos );
			DccChat->MsgLen -= StartPos;
			DccChat->Msg = realloc( DccChat->Msg, DccChat->MsgLen );
		}
		else
		{
			free( DccChat->Msg );
			DccChat->Msg = NULL;
			DccChat->MsgLen = 0;
		}
	}
	RedrawChatWindow( DccChat->ChatWindow, Global );
}
/*-----------------------------------------------------------------------------*/
/* ParseMessage                                                                */
/*-----------------------------------------------------------------------------*/
static void	ParseMessage( DCC_CHAT *DccChat, char *Msg, WORD Global[15] )
{
	CHAT_WINDOW	*ChatWindow = DccChat->ChatWindow;
	if( Msg[strlen( Msg ) - 1] == '\n' )
	{
		BYTE	Output[1024];
		Msg[strlen( Msg ) - 1] = 0;
		sprintf( Output, "<%s> %s", DccChat->Nickname, Msg );
		AppendChatWindow( Output, COLOUR_MSG, ChatWindow, Global );

		if( IrcFlags & WINDOW_TOPWITHNICK )
		{
			EVNT	lEvents;
			lEvents.mwhich = MU_MESAG;
			lEvents.msg[0] = WM_TOPPED;
			lEvents.msg[1] = Global[2];
			lEvents.msg[2] = 0;
			lEvents.msg[3] = DccChat->ChatWindow->WinId;
			HandleWindow( &lEvents, Global );
		}
	}
	else
	{
		BYTE	Output[1024];
		sprintf( Output, "> %s", Msg );
		AppendChatWindow( Output, COLOUR_MSG_MYSELF, ChatWindow, Global );
	}
}

WORD	InfoDccDialog( CHAT_WINDOW *ChatWindow, WORD Global[15] )
{
	DIALOG_DATA		*DialogData;
	if(( DialogData = malloc( sizeof( DIALOG_DATA ))) == NULL )
		return( ENSMEM );

	DialogData->Dialog = NULL;
	DialogData->HndlDdDialog = NULL;
	DialogData->HndlClsDialog = HndlClsInfoDialog;
	DialogData->HndlMesagDialog = NULL;
	DialogData->HndlTimerDialog = NULL;
	DialogData->HndlEditDialog = NULL;
	DialogData->HndlHelpDialog = NULL;
	DialogData->HndlCheckDialog = NULL;
	DialogData->UserData = ChatWindow;
	DialogData->TreeIndex = INFOD;

	if(( DialogData->Tree = CopyTree( TreeAddr[INFOD] )) == NULL )
	{
		free( DialogData );
		return( ENSMEM );
	}

	sprintf( DialogData->Tree[INFOD_NLINES].ob_spec.tedinfo->te_ptext, "%li", mt_text_get_pufline( ChatWindow->DialogData->Tree, WCHAT_OUTPUT, Global ));
	if( ChatWindow->LogFile )
		DialogData->Tree[INFOD_LOG].ob_state |= SELECTED;
	DialogData->Tree[INFOD_IRC].ob_flags |= HIDETREE;
	
	if( OpenDialogX( ChatWindow->Title, WIN_ALERT_WINDOW, NAME + MOVER, -1, -1, HandleInfoDialog, DialogData, Global ) != E_OK )
	{
		FreeTree( DialogData->Tree );
		free( DialogData );
		return( ERROR );
	}
	OpenAlert( ChatWindow->UserData, MT_wdlg_get_handle( DialogData->Dialog, Global ), MODWIN_NORMAL );
	return( E_OK );
}
static WORD cdecl	HandleInfoDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData )
{
	OBJECT		*DialogTree;
	GRECT			Rect;
	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );
	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_EDIT:
			{
				WORD	a, b;
				if((( Events->kstate & KsCONTROL ) || ( Events->kstate & KsALT )) && isMenuKey( Events->key, &a, &b ))
					return( 0 );
				break;
			}
			case	HNDL_CLSD:
				if( Events->msg[4] == WIN_CLOSE_WITHOUT_DEMAND )
				{
					CloseAlert((( CHAT_WINDOW * )(( DIALOG_DATA * ) UserData )->UserData )->UserData, 0, MT_wdlg_get_handle( Dialog, Global ), Global );
					return( 0 );
				}
				else
					return( 1 );
		}
	}
	else
	{
		Obj &= 0x7fff;
		if( HandleWDialogIcon( &Obj, Dialog, Global ))
			return( 1 );

		if(( DialogTree[Obj].ob_type & 0x0100 ) == 0x0100 )
		{
			StGuide_Action( DialogTree, INFOD, Global );
			return( 1 );
		}
		if( DialogTree[Obj].ob_state & DISABLED )
		{
			DialogTree[Obj].ob_state &= ~SELECTED;
			return( 1 );
		}
		switch( Obj )
		{
			case	INFOD_OK:
			{
				CHAT_WINDOW	*ChatWindow = ( CHAT_WINDOW * )(( DIALOG_DATA *) UserData)->UserData;
				if(( DialogTree[INFOD_LOG].ob_state & SELECTED ) && !ChatWindow->LogFile )
				{
					DCC_CHAT *DccChat = ( DCC_CHAT * ) ChatWindow->UserData;
					BYTE	*Dirname, *Filename;
					Dirname = "DccChat";
					Filename = DccChat->Nickname;
					if(( ChatWindow->LogFile = OpenLog( Dirname, Filename )) == NULL )
						MT_form_alert( 1, TreeAddr[ALERTS][ALERT_ERROR_LOG].ob_spec.free_string, Global );
				}
				if( !( DialogTree[INFOD_LOG].ob_state & SELECTED ) && ChatWindow->LogFile )
				{
					CloseLog( ChatWindow->LogFile );
					ChatWindow->LogFile = NULL;
				}
				mt_text_set_pufline( ChatWindow->DialogData->Tree, WCHAT_OUTPUT, atol( DialogTree[INFOD_NLINES].ob_spec.tedinfo->te_ptext ), Global );
				break;
			}
			case	INFOD_CANCEL:
				break;
		}

		CloseAlert((( CHAT_WINDOW * )(( DIALOG_DATA * ) UserData )->UserData )->UserData, 0, MT_wdlg_get_handle( Dialog, Global ), Global );
		return( 0 );
	}
	return( 1 );
}
static WORD HndlClsInfoDialog( void *DialogData, WORD Global[15] )
{
	FreeTree((( DIALOG_DATA *) DialogData)->Tree );
	free( DialogData );
	return( E_OK );
}
