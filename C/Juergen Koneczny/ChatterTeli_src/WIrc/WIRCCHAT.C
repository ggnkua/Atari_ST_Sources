#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<TOS.H>
#include	<VDICOL.H>
#include	<MT_AES.H>
#include	<STDDEF.H>
#include	<STDLIB.H>
#include	<STRING.H>
#include	<STDIO.H>
#include	<TIME.H>

#include	<atarierr.h>
#include	<iconnect\sockinit.h>

#include	"DD.h"
#include	"main.h"
#include	RSCHEADER
#include	"Irc.h"
#include	"Help.h"
#include	"IConnect.h"
#include	"Menu.h"
#include	"Popup.h"
#include	"Rsc.h"
#include	"ExtObj\TextObj.h"
#include	"TCP.h"
#include	"WDialog.h"
#include	"Window.h"
#include	"WIrc\Func.h"
#include	"WIrc\IrcFunc.h"
#include	"WIrc\WChat.h"
#include	"WIrc\WDccChat.h"
#include	"WIrc\WInput.h"
#include	"WIrc\WIrcChat.h"
#include	"WIrc\WPut.h"

#include	"Keytab.h"
#include	"MapKey.h"

#define	IRC_WINDOW_KINDS	NAME + FULLER + MOVER + CLOSER + ICONIFIER + VSLIDE + UPARROW + DNARROW + SIZER + INFO
#define	EDITPUF		512

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern WORD	Global[15], VdiHandle;
extern OBJECT	**TreeAddr;
extern GRECT	ScreenRect;
extern WORD	PingFlag;
extern WORD	SessionCounter;
extern KEYT	*Keytab;
extern WORD	KeytabAnsiExport, KeytabAnsiImport;
extern WORD	ColourTableObj[], ColourTableRef[];
extern WORD IrcFlags;
extern BYTE	*CtcpCmd[];
/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
static WORD	cdecl SendWindow( BYTE *Puf, void *UserData, WORD Global[15] );
static void	SetButtonWindow( void *UserData, WORD Global[15] );
static void	DoubleClickWindow( BYTE *Line, EVNT *Events, void *UserData, WORD Global[15] );
static WORD	cdecl ButtonWindow( WORD Obj, void *UserData, WORD Global[15] );
static WORD	cdecl MessageWindow( EVNT *Events, void *UserData, WORD Global[15] );
static WORD	TimerWindow( void *UserData, WORD Global[15] );
static WORD	CheckWindow( EVNT *Events, void *UserData, WORD Global[15] );
static WORD	ClosedWindow( void *UserData, WORD Global[15] );

/*-----------------------------------------------------------------------------*/
/* OpenIrcChatWindow                                                           */
/*-----------------------------------------------------------------------------*/
WORD	OpenIrcChatWindow( IRC_CHANNEL *IrcChannel, WORD Global[15] )
{
	IRC_SESSION	*IrcSession = ( IRC_SESSION * ) IrcChannel->IrcSession;
	IRC	*Irc = IrcSession->Irc;
	CHAT_WINDOW	*ChatWindow;
	BYTE	*Dirname, *Filename;
	WORD	Type;
	
	if(( ChatWindow = malloc( sizeof( CHAT_WINDOW ))) == NULL )
		return( ENSMEM );

	IrcChannel->ChatWindow = ChatWindow;

	ChatWindow->UserData = IrcChannel;

	ChatWindow->SendChatWindow = SendWindow;
	ChatWindow->SetButtonChatWindow = SetButtonWindow;
	ChatWindow->DoubleClickChatWindow = DoubleClickWindow;
	ChatWindow->ButtonChatWindow = ButtonWindow;
	ChatWindow->MessageChatWindow = MessageWindow;
	ChatWindow->TimerChatWindow = TimerWindow;
	ChatWindow->CheckChatWindow = CheckWindow;
	ChatWindow->ClosedChatWindow = ClosedWindow;

	ChatWindow->Title = malloc( strlen( TreeAddr[TITLES][TITLE_WINDOW].ob_spec.free_string ) + 1 + strlen( IrcSession->Irc->Host ) + ( IrcChannel->Name ? 1 + strlen( IrcChannel->Name ) : 0 ) + 1 );
	if( !ChatWindow->Title )
	{
		free( ChatWindow );
		IrcChannel->ChatWindow = NULL;
		return( ENSMEM );
	}
	ChatWindow->Info = NULL;

	if( IrcChannel->Name )
	{
		sprintf( ChatWindow->Title, "%s %s %s", TreeAddr[TITLES][TITLE_WINDOW].ob_spec.free_string, IrcSession->Irc->Host, IrcChannel->Name );
		if( IrcChannel->Name[0] == '#' || IrcChannel->Name[0] == '&' )
			Type = WIN_CHAT_IRC_CHANNEL;
		else
			Type = WIN_CHAT_IRC_USER;
		Dirname = "Channel";
		Filename = IrcChannel->Name;
	}
	else
	{
		sprintf( ChatWindow->Title, "%s %s", TreeAddr[TITLES][TITLE_WINDOW].ob_spec.free_string, IrcSession->Irc->Host );
		Type = WIN_CHAT_IRC_CONSOLE;
		Dirname = Irc->Host;
		Filename = "Console";
	}
	return( OpenChatWindow( Dirname, Filename, Type, Irc->nLines, Irc->OutputFontId, Irc->OutputFontHt, Irc->InputFontId, Irc->InputFontHt, Irc->ColourTable, ( IrcFlags & WINDOW_OVERWRITE ), Irc->LogFlag, ChatWindow, Global ));
}

static WORD	cdecl SendWindow( BYTE *Puf, void *UserData, WORD Global[15] )
{
	IRC_CHANNEL	*IrcChannel = ( IRC_CHANNEL * ) UserData;
	IRC_SESSION *IrcSession = ( IRC_SESSION * ) IrcChannel->IrcSession;
	SendMessage( IrcSession, GenerateMessage( Puf, IrcChannel->Name, IrcSession, Global ), Global );
	IrcSession->Time = ( LONG ) time( NULL );
	return( E_OK );
}

static void	SetButtonWindow( void *UserData, WORD Global[15] )
{
	IRC_CHANNEL	*IrcChannel = ( IRC_CHANNEL * ) UserData;
	IRC_SESSION *IrcSession = ( IRC_SESSION * ) IrcChannel->IrcSession;
	CHAT_WINDOW	*ChatWindow = IrcChannel->ChatWindow;
	DIALOG_DATA	*DialogData = ChatWindow->DialogData;

	OBJECT			*DialogTree;
	GRECT				Rect;
	if( DialogData->Dialog )
		MT_wdlg_get_tree( DialogData->Dialog, &DialogTree, &Rect, Global );

	if(( IrcChannel->ChannelFlag & MODE_OP ))
	{
		if(( DialogData->Tree[WCHAT_TOPIC].ob_state & DISABLED ))
		{
			DialogData->Tree[WCHAT_TOPIC].ob_state &= ~DISABLED;
			DialogData->Tree[WCHAT_TOPIC].ob_flags |= SELECTABLE;
			if( DialogData->Dialog )
				DoRedraw( DialogData->Dialog, &Rect, WCHAT_TOPIC, Global );
		}
		if(( DialogData->Tree[WCHAT_CHANNELMODE].ob_state & DISABLED ))
		{
			DialogData->Tree[WCHAT_CHANNELMODE].ob_state &= ~DISABLED;
			DialogData->Tree[WCHAT_CHANNELMODE].ob_flags |= SELECTABLE;
			if( DialogData->Dialog )
				DoRedraw( DialogData->Dialog, &Rect, WCHAT_CHANNELMODE, Global );
		}
	}
	if( !( IrcChannel->ChannelFlag & MODE_OP ))
	{
		if( !( DialogData->Tree[WCHAT_CHANNELMODE].ob_state & DISABLED ))
		{
			DialogData->Tree[WCHAT_CHANNELMODE].ob_state |= DISABLED;
			DialogData->Tree[WCHAT_CHANNELMODE].ob_flags &= ~SELECTABLE;
			if( DialogData->Dialog )
				DoRedraw( DialogData->Dialog, &Rect, WCHAT_CHANNELMODE, Global );
		}
	}
	if( !( IrcChannel->ChannelFlag & MODE_OP ) && !( IrcChannel->ChannelFlag & MODE_TOPIC ))
	{
		if( ( DialogData->Tree[WCHAT_TOPIC].ob_state & DISABLED ))
		{
			DialogData->Tree[WCHAT_TOPIC].ob_state &= ~DISABLED;
			DialogData->Tree[WCHAT_TOPIC].ob_flags |= SELECTABLE;
			if( DialogData->Dialog )
				DoRedraw( DialogData->Dialog, &Rect, WCHAT_TOPIC, Global );
		}
	}
	if( !( IrcChannel->ChannelFlag & MODE_OP ) && ( IrcChannel->ChannelFlag & MODE_TOPIC ))
	{
		if( !( DialogData->Tree[WCHAT_TOPIC].ob_state & DISABLED ))
		{
			DialogData->Tree[WCHAT_TOPIC].ob_state |= DISABLED;
			DialogData->Tree[WCHAT_TOPIC].ob_flags &= ~SELECTABLE;
			if( DialogData->Dialog )
				DoRedraw( DialogData->Dialog, &Rect, WCHAT_TOPIC, Global );
		}
	}
		
}

static void	DoubleClickWindow( BYTE *Line, EVNT *Events, void *UserData, WORD Global[15] )
{
	IRC_CHANNEL	*IrcChannel = ( IRC_CHANNEL * ) UserData;
	IRC_SESSION *IrcSession = ( IRC_SESSION * ) IrcChannel->IrcSession;

	if( !strncmp( Line, "*** ", 4 ))
	{
		BYTE	*Pos;
		if(( Pos = strstr( Line, " invites you to channel " )) != NULL )
		{
			BYTE	Puf[512];
			sprintf( Puf, "/JOIN %s", Pos + strlen(" invites you to channel "));
			strcat( Puf, "" );
			SendMessage( IrcSession, GenerateMessage( Puf, NULL, IrcSession, Global ), Global );
		}
	}
	else	if( Line[0] == '<' )
	{
		WORD	Ret, i = 0;
		BYTE	Nickname[128];
		while( Line[i+1] != '>' )
		{
			Nickname[i] = Line[i+1];
			i++;
		}
		Nickname[i] = 0;
		TreeAddr[POPUP_IRC][IRC_OP].ob_state |= DISABLED;
		TreeAddr[POPUP_IRC][IRC_DEOP].ob_state |= DISABLED;
		TreeAddr[POPUP_IRC][IRC_KICK].ob_state |= DISABLED;
		TreeAddr[POPUP_IRC][IRC_BAN].ob_state |= DISABLED;
		TreeAddr[POPUP_IRC][IRC_DEBAN].ob_state |= DISABLED;
		TreeAddr[POPUP_IRC][IRC_KICKBAN].ob_state |= DISABLED;
		TreeAddr[POPUP_IRC][IRC_VOICE].ob_state |= DISABLED;
		TreeAddr[POPUP_IRC][IRC_DEVOICE].ob_state |= DISABLED;
		if( IrcChannel->ChannelFlag & MODE_OP )
		{
			TreeAddr[POPUP_IRC][IRC_OP].ob_state &= ~DISABLED;
			TreeAddr[POPUP_IRC][IRC_DEOP].ob_state &= ~DISABLED;
			TreeAddr[POPUP_IRC][IRC_KICK].ob_state &= ~DISABLED;
			TreeAddr[POPUP_IRC][IRC_BAN].ob_state &= ~DISABLED;
			TreeAddr[POPUP_IRC][IRC_DEBAN].ob_state &= ~DISABLED;
			TreeAddr[POPUP_IRC][IRC_KICKBAN].ob_state &= ~DISABLED;
			if( IrcChannel->ChannelFlag & MODE_MODERATED )
			{
				TreeAddr[POPUP_IRC][IRC_VOICE].ob_state &= ~DISABLED;
				TreeAddr[POPUP_IRC][IRC_DEVOICE].ob_state &= ~DISABLED;
			}
		}
		if(( Ret = Popup( TreeAddr[POPUP_IRC], 0, Events->mx, Events->my, Global )) != -1 )
		{
			BYTE	Puf[512];
			switch( Ret )
			{
				case	IRC_MSG:
					if( OpenIrcChannel( IrcSession, Nickname, Global ) != E_OK )
						MT_form_alert( 1, TreeAddr[ALERTS][MEMORY].ob_spec.free_string, Global );
					break;
				case	IRC_INVITE:
					OpenAlertIrc( IrcSession, IrcChannel, InviteDialog( IrcChannel, Nickname, Global ), MODWIN_NORMAL );
					break;
				case	IRC_DCCTX:
					OpenAlertIrc( IrcSession, IrcChannel, OpenPutWindow( IrcChannel, Nickname, Global ), MODWIN_NORMAL );
					break;			
				case	IRC_DCCCHAT:
					if( OpenDccChatSession( IrcSession, Nickname, Global ) != E_OK )
						MT_form_alert( 1, TreeAddr[ALERTS][MEMORY].ob_spec.free_string, Global );
					break;
				case	IRC_OP:
					sprintf( Puf, "/MODE %s +o %s", IrcChannel->Name, Nickname );
					strcat( Puf, "" );
					SendMessage( IrcSession, GenerateMessage( Puf, IrcChannel->Name, IrcSession, Global ), Global );
					break;
				case	IRC_DEOP:
					sprintf( Puf, "/MODE %s -o %s", IrcChannel->Name, Nickname );
					strcat( Puf, "" );
					SendMessage( IrcSession, GenerateMessage( Puf, IrcChannel->Name, IrcSession, Global ), Global );
					break;
				case	IRC_KICK:
				{
					EVNTDATA	Ev;
					MT_graf_mkstate( &Ev, Global );
					if( Ev.kstate )
						OpenAlertIrc( IrcSession, IrcChannel, KickDialog( IrcChannel, KICKDIALOG_KICK, Nickname, Global ), MODWIN_NORMAL );
					else
					{
						sprintf( Puf, "/KICK %s %s", IrcChannel->Name, Nickname );
						strcat( Puf, "" );
						SendMessage( IrcSession, GenerateMessage( Puf, IrcChannel->Name, IrcSession, Global ), Global );
					}
					break;
				}
				case	IRC_BAN:
					sprintf( Puf, "/MODE %s +b %s", IrcChannel->Name, Nickname );
					strcat( Puf, "" );
					SendMessage( IrcSession, GenerateMessage( Puf, IrcChannel->Name, IrcSession, Global ), Global );
					break;
				case	IRC_DEBAN:
					sprintf( Puf, "/MODE %s -b %s", IrcChannel->Name, Nickname );
					strcat( Puf, "" );
					SendMessage( IrcSession, GenerateMessage( Puf, IrcChannel->Name, IrcSession, Global ), Global );
					break;
				case	IRC_KICKBAN:
				{
					EVNTDATA	Ev;
					MT_graf_mkstate( &Ev, Global );
					if( Ev.kstate )
						OpenAlertIrc( IrcSession, IrcChannel, KickDialog( IrcChannel, KICKDIALOG_BANKICK, Nickname, Global ), MODWIN_NORMAL );
					else
					{
						sprintf( Puf, "/KICK %s %s", IrcChannel->Name, Nickname );
						strcat( Puf, "" );
						SendMessage( IrcSession, GenerateMessage( Puf, IrcChannel->Name, IrcSession, Global ), Global );
						sprintf( Puf, "/MODE %s +b %s", IrcChannel->Name, Nickname );
						strcat( Puf, "" );
						SendMessage( IrcSession, GenerateMessage( Puf, IrcChannel->Name, IrcSession, Global ), Global );
					}
					break;
				}
				case	IRC_VOICE:
					sprintf( Puf, "/MODE %s +v %s", IrcChannel->Name, Nickname );
					strcat( Puf, "" );
					SendMessage( IrcSession, GenerateMessage( Puf, IrcChannel->Name, IrcSession, Global ), Global );
					break;
				case	IRC_DEVOICE:
					sprintf( Puf, "/MODE %s -v %s", IrcChannel->Name, Nickname );
					strcat( Puf, "" );
					SendMessage( IrcSession, GenerateMessage( Puf, IrcChannel->Name, IrcSession, Global ), Global );
					break;
				case	IRC_CTCP:
				{
					EVNTDATA	Ev;
					MT_graf_mkstate( &Ev, Global );
					if( Ev.kstate )
						OpenAlertIrc( IrcSession, IrcChannel, CtcpDialog( IrcChannel, Nickname, Global ), MODWIN_NORMAL );
					else
					{
						WORD	Ret, x, y;
						if(( Ret = Popup( TreeAddr[POPUP_CTCP], 0, Ev.x, Ev.y, Global )) > 0 )
						{
							BYTE	Puf[512],	**Item;
							WORD	Colour;
							sprintf( Puf, "/CTCP %s %s", Nickname, CtcpCmd[Ret-1] );
							SendMessage( IrcSession, GenerateMessage( Puf, IrcChannel->Name, IrcSession, Global ), Global );
						}
					}
					break;
				}
			}
		}
	}
}
static WORD	cdecl ButtonWindow( WORD Obj, void *UserData, WORD Global[15] )
{
	IRC_CHANNEL	*IrcChannel = ( IRC_CHANNEL * ) UserData;
	IRC_SESSION *IrcSession = ( IRC_SESSION * ) IrcChannel->IrcSession;
	DIALOG_DATA	*DialogData = IrcChannel->ChatWindow->DialogData;
	OBJECT		*DialogTree;
	GRECT	Rect;
	MT_wdlg_get_tree( DialogData->Dialog, &DialogTree, &Rect, Global );
	
	switch( Obj )
	{
		case	WCHAT_LIST:
		{
			BYTE	Puf[128];
			sprintf( Puf, "/LIST\0\0" );
			SendMessage( IrcSession, GenerateMessage( Puf, IrcChannel->Name, IrcSession, Global ), Global );
			DialogTree[Obj].ob_state &= ~SELECTED;
			DoRedraw( DialogData->Dialog, &Rect, Obj, Global );
			break;
		}
		case	WCHAT_WHO:
		{
			BYTE	Puf[128];
			sprintf( Puf, "/NAMES %s\0\0", IrcChannel->Name );
			SendMessage( IrcSession, GenerateMessage( Puf, IrcChannel->Name, IrcSession, Global ), Global );
			DialogTree[WCHAT_WHO].ob_state &= ~SELECTED;
			DoRedraw( DialogData->Dialog, &Rect, WCHAT_WHO, Global );
			break;
		}
		case	WCHAT_USERMODE:
		case	WCHAT_CHANNELMODE:
		case	WCHAT_TOPIC:
		case	WCHAT_INVITE:
		case	WCHAT_AWAY:
		case	WCHAT_NICK:
		{
			if( Obj == WCHAT_USERMODE )
				OpenAlertIrc( IrcSession, NULL, UModeDialog( IrcSession, Global ), MODWIN_NORMAL );
			else	if( Obj == WCHAT_CHANNELMODE )
				OpenAlertIrc( IrcSession, IrcChannel, CModeDialog( IrcChannel, Global ), MODWIN_NORMAL );
			else	if( Obj == WCHAT_TOPIC )
				OpenAlertIrc( IrcSession, IrcChannel, TopicDialog( IrcChannel, Global ), MODWIN_NORMAL );
			else	if( Obj == WCHAT_INVITE )
				OpenAlertIrc( IrcSession, IrcChannel, InviteDialog( IrcChannel, NULL, Global ), MODWIN_NORMAL );
			else	if( Obj == WCHAT_AWAY )
				OpenAlertIrc( IrcSession, NULL, AwayDialog( IrcSession, Global ), MODWIN_NORMAL );
			else	if( Obj == WCHAT_NICK )
				OpenAlertIrc( IrcSession, NULL, NnDialog( IrcSession, Global ), MODWIN_NORMAL );
			DialogTree[Obj].ob_state &= ~SELECTED;
			DoRedraw( DialogData->Dialog, &Rect, Obj, Global );
			break;
		}
	}
	return( 1 );
}

static WORD	cdecl MessageWindow( EVNT *Events, void *UserData, WORD Global[15] )
{
	IRC_CHANNEL	*IrcChannel = ( IRC_CHANNEL * ) UserData;
	IRC_SESSION *IrcSession = ( IRC_SESSION * ) IrcChannel->IrcSession;
	CHAT_WINDOW	*ChatWindow = IrcChannel->ChatWindow;
	DIALOG_DATA	*DialogData = IrcChannel->ChatWindow->DialogData;
	WORD	Msg[8];

	TcpMessageTime( NULL, &( IrcSession->TcpMsgPuf ), -1, Global );

	switch( Events->msg[0] )
	{
		case	WIN_CMD:
		{
			if( Events->msg[4] == WIN_CLOSE )
			{
				BYTE	Puf[512];
				if( IrcChannel->Name )
					sprintf( Puf, "/LEAVE %s", IrcChannel->Name );
				else
					sprintf( Puf, "/QUIT" );
				strcat( Puf, "" );
				SendMessage( IrcSession, GenerateMessage( Puf, IrcChannel->Name, IrcSession, Global ), Global );
			}
			break;
		}
		case	WM_CLOSED:
		{
			if( Events->msg[4] == WIN_CLOSE_WITHOUT_DEMAND )
			{
				if( IrcChannel->Name )
					return( 1 );
				else
				{
					WORD	Msg[8];
					Msg[0] = WIN_CMD;
					Msg[1] = Global[2];
					Msg[2] = 0;
					Msg[3] = Events->msg[3];
					Msg[4] = WIN_CLOSE;
					MT_appl_write( Global[2], 16, &Msg, Global );
				}
			}
			else
			{
				if( IrcChannel->Name )
				{
					if( IrcChannel->Name[0] == '#' || IrcChannel->Name[0] == '&' )
					{
						WORD	Msg[8];
						Msg[0] = WIN_CMD;
						Msg[1] = Global[2];
						Msg[2] = 0;
						Msg[3] = Events->msg[3];
						Msg[4] = WIN_CLOSE;
						MT_appl_write( Global[2], 16, &Msg, Global );
					}
					else
						return( 1 );
				}
				else
					OpenAlertIrc( IrcSession, NULL, AlertDialog( 1, TreeAddr[ALERTS][CLOSE_SESSION].ob_spec.free_string, IrcSession->IrcChannel->ChatWindow->Title, CloseSessionAlertIrc, IrcSession, Global ), MODWIN_CLOSE_SESSION );
			}
/*			if( Events->msg[4] == WIN_CLOSE_WITHOUT_DEMAND )
			{
				if( IrcChannel->Name )
					return( 1 );
				else	if( !( IrcSession->SessionFlag & MODE_CLOSE ))
				{
					BYTE	Puf[512];
					sprintf( Puf, "/QUIT" );
					strcat( Puf, "" );
					SendMessage( IrcSession, GenerateMessage( Puf, IrcChannel->Name, IrcSession, Global ), Global );
				}
			}
			else
			{
				if( IrcChannel->Name )
				{
					if( IrcChannel->Name[0] == '#' || IrcChannel->Name[0] == '&' )
					{
						BYTE	Puf[512];
						sprintf( Puf, "/LEAVE %s", IrcChannel->Name );
						strcat( Puf, "" );
						SendMessage( IrcSession, GenerateMessage( Puf, IrcChannel->Name, IrcSession, Global ), Global );
					}
					else
						return( 1 );
				}
				else	if( !( IrcSession->SessionFlag & MODE_CLOSE ))
					OpenAlertIrc( IrcSession, NULL, AlertDialog( 1, TreeAddr[ALERTS][CLOSE_SESSION].ob_spec.free_string, IrcSession->IrcChannel->ChatWindow->Title, CloseSessionAlertIrc, IrcSession, Global ), MODWIN_CLOSE_SESSION );
			}
*/			break;
		}
		case	ICONNECT_ACK:
		{
			if( Events->msg[4] != E_OK )
			{
				Msg[0] = TCP_CMD;
				Msg[1] = Global[2];
				Msg[2] = 0;
				Msg[3] = IrcSession->IrcChannel->ChatWindow->WinId;
				Msg[4] = TCP_close;
				TcpMessageTime( Msg, &( IrcSession->TcpMsgPuf ), IrcSession->TcpAppId, Global );
			}
			else
			{
				Msg[0] = TCP_CMD;
				Msg[1] = Global[2];
				Msg[2] = 0;
				Msg[3] = IrcSession->IrcChannel->ChatWindow->WinId;
				Msg[4] = TCP_socket;
				TcpMessageTime( Msg, &( IrcSession->TcpMsgPuf ), IrcSession->TcpAppId, Global );
			}
			break;
		}
		case	TCP_CMD:
		{
			switch( Events->msg[4] )
			{
				case	TCP_closed:
				{
					if( PingFlag )
						Cconout( '\a' );
					if( !( IrcSession->SessionFlag & MODE_CLOSE ))
						OpenAlertIrc( IrcSession, NULL, AlertDialog( 1, TreeAddr[ALERTS][CONNECTION_CLOSED].ob_spec.free_string, IrcSession->IrcChannel->ChatWindow->Title, CloseSessionAlertIrc, IrcSession, Global ), MODWIN_CONNECTION_CLOSED );
					else
					{
						Msg[0] = TCP_CMD;
						Msg[1] = Global[2];
						Msg[2] = 0;
						Msg[3] = IrcSession->IrcChannel->ChatWindow->WinId;
						Msg[4] = TCP_close;
						TcpMessageTime( Msg, &( IrcSession->TcpMsgPuf ), IrcSession->TcpAppId, Global );
					}
 					break;
				}
				case	TCP_in:
				{
					char	*Puf;
					Keytab->ImportString( KeytabAnsiImport, ( long ) Events->msg[7], *( BYTE ** )&( Events->msg[5] ));
					if( IrcSession->Msg )
					{
						Puf = malloc( IrcSession->MsgLen + ( long ) Events->msg[7] );
						memcpy( Puf, IrcSession->Msg, IrcSession->MsgLen );
						free( IrcSession->Msg );
						IrcSession->Msg = Puf;
						Puf += IrcSession->MsgLen;
						IrcSession->MsgLen += ( long ) Events->msg[7];
					}
					else
					{
						Puf = malloc(( long ) Events->msg[7] );
						IrcSession->Msg = Puf;
						IrcSession->MsgLen = ( long ) Events->msg[7];
					}
					memcpy( Puf, *( BYTE ** )&( Events->msg[5] ), ( long ) Events->msg[7] );
					Msg[0] = TCP_ACK;
					Msg[1] = Global[2];
					Msg[2] = 0;
					Msg[3] = IrcSession->IrcChannel->ChatWindow->WinId;
					Msg[4] = TCP_in;
					*( long * )&( Msg[5] ) = *( long * )&( Events->msg[5] );
					TcpMessageTime( Msg, &( IrcSession->TcpMsgPuf ), IrcSession->TcpAppId, Global );
					ParseInputIrcChat( IrcSession, Global );
					break;
				}
			}
			return( E_OK );
		}
		case	TCP_ACK:
		{
			switch( Events->msg[4] )
			{
				case	TCP_init:
				{
					if( Events->msg[7] == E_OK )
					{
						EVNT Evnt;
						SetInfoChatWindow( TreeAddr[INFOS][TCP_INTERNET].ob_spec.free_string, IrcSession->IrcChannel->ChatWindow, Global );
						Evnt.mwhich = MU_MESAG;
						Evnt.msg[0] = ICONNECT_CMD;
						Evnt.msg[1] = Global[2];
						Evnt.msg[2] = 0;
						Evnt.msg[3] = IrcSession->IrcChannel->ChatWindow->WinId;
						HandleIConnect( &Evnt, Global );
						break;
					}
					if( Events->msg[7] == SE_NINSTALL )
						OpenAlertIrc( IrcSession, NULL, AlertDialog( 1, TreeAddr[ALERTS][SOCKETS_NOT_INST].ob_spec.free_string, IrcSession->IrcChannel->ChatWindow->Title, CloseSessionAlertIrc, IrcSession, Global ), MODWIN_CONNECTION_CLOSED );
					else	if( Events->msg[7] == SE_NSUPP )
						OpenAlertIrc( IrcSession, NULL, AlertDialog( 1, TreeAddr[ALERTS][SOCKETS_TOO_OLD].ob_spec.free_string, IrcSession->IrcChannel->ChatWindow->Title, CloseSessionAlertIrc, IrcSession, Global ), MODWIN_CONNECTION_CLOSED );
					break;
				}
				case	TCP_socket:
				{
					if( Events->msg[4] < 0 )
					{
						OpenAlertIrc( IrcSession, NULL, AlertDialog( 1, TreeAddr[ALERTS][SOCKET_FAILED].ob_spec.free_string, IrcSession->IrcChannel->ChatWindow->Title, CloseSessionAlertIrc, IrcSession, Global ), MODWIN_CONNECTION_CLOSED );
						break;
					}
					SetInfoChatWindow( TreeAddr[INFOS][TCP_GETHOSTBYNAME].ob_spec.free_string, IrcSession->IrcChannel->ChatWindow, Global );
					Msg[0] = TCP_CMD;
					Msg[1] = Global[2];
					Msg[2] = 0;
					Msg[3] = IrcSession->IrcChannel->ChatWindow->WinId;
					Msg[4] = TCP_gethostbyname;
					*( BYTE ** )&( Msg[5] ) = IrcSession->Irc->Host;
					TcpMessageTime( Msg, &( IrcSession->TcpMsgPuf ), IrcSession->TcpAppId, Global );
					break;
				}
				case	TCP_gethostbyname:
				{
					if( Events->msg[7] == E_OK )
					{
						SetInfoChatWindow( TreeAddr[INFOS][TCP_CONNECT].ob_spec.free_string, IrcSession->IrcChannel->ChatWindow, Global );
						Msg[0] = TCP_CMD;
						Msg[1] = Global[2];
						Msg[2] = 0;
						Msg[3] = IrcSession->IrcChannel->ChatWindow->WinId;
						Msg[4] = TCP_connect;
						*( long * )&( Msg[5] ) = *( long * )&( Events->msg[5] );
						Msg[7] = IrcSession->Irc->Port;
						TcpMessageTime( Msg, &( IrcSession->TcpMsgPuf ), IrcSession->TcpAppId, Global );
						break;
					}
					OpenAlertIrc( IrcSession, NULL, AlertDialog( 1, TreeAddr[ALERTS][DNS_FAILED].ob_spec.free_string, IrcSession->IrcChannel->ChatWindow->Title, CloseSessionAlertIrc, IrcSession, Global ), MODWIN_CONNECTION_CLOSED );
					break;
				}
				case	TCP_connect:
				{
					if( Events->msg[7] == E_OK )
					{
						BYTE	*Puf;
						LONG	Len;
						OBJECT		*DialogTree;
						GRECT			Rect;
						MT_wdlg_get_tree((( DIALOG_DATA * ) DialogData)->Dialog, &DialogTree, &Rect, Global );
						
						SetInfoChatWindow( TreeAddr[INFOS][TCP_ETABLISHED].ob_spec.free_string, IrcSession->IrcChannel->ChatWindow, Global );
						if( PingFlag )
							Cconout( '\a' );

						Msg[0] = TCP_CMD;
						Msg[1] = Global[2];
						Msg[2] = 0;
						Msg[3] = IrcSession->IrcChannel->ChatWindow->WinId;
						Msg[4] = TCP_out;
						Puf = ConnectionRegistration( IrcSession->Irc );
						Len = strlen( Puf );
						Keytab->ExportString( KeytabAnsiExport, Len, Puf );
						*( BYTE ** )&( Msg[5] ) = Puf;
						Msg[7] = ( WORD ) Len;
						TcpMessageTime( Msg, &( IrcSession->TcpMsgPuf ), IrcSession->TcpAppId, Global );
						(( DIALOG_DATA * ) DialogData )->Tree[WCHAT_AWAY].ob_state &= ~DISABLED;
						(( DIALOG_DATA * ) DialogData )->Tree[WCHAT_AWAY].ob_flags |= SELECTABLE;
						(( DIALOG_DATA * ) DialogData )->Tree[WCHAT_LIST].ob_state &= ~DISABLED;
						(( DIALOG_DATA * ) DialogData )->Tree[WCHAT_LIST].ob_flags |= SELECTABLE;
						(( DIALOG_DATA * ) DialogData )->Tree[WCHAT_USERMODE].ob_state &= ~DISABLED;
						(( DIALOG_DATA * ) DialogData )->Tree[WCHAT_USERMODE].ob_flags |= SELECTABLE;
						(( DIALOG_DATA * ) DialogData )->Tree[WCHAT_NICK].ob_state &= ~DISABLED;
						(( DIALOG_DATA * ) DialogData )->Tree[WCHAT_NICK].ob_flags |= SELECTABLE;
						DoRedrawX((( DIALOG_DATA * ) DialogData)->Dialog, &Rect, Global, WCHAT_AWAY, WCHAT_LIST, WCHAT_USERMODE, WCHAT_NICK, EDRX );
						mt_edit_cursor((( DIALOG_DATA * ) DialogData )->Tree, WCHAT_INPUT, MT_wdlg_get_handle((( DIALOG_DATA * ) DialogData)->Dialog, Global) , 1, Global );
						break;
					}
					OpenAlertIrc( IrcSession, NULL, AlertDialog( 1, TreeAddr[ALERTS][CONNECT_FAILED].ob_spec.free_string, IrcSession->IrcChannel->ChatWindow->Title, CloseSessionAlertIrc, IrcSession, Global ), MODWIN_CONNECTION_CLOSED );
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
					lEvents.msg[3] = IrcSession->IrcChannel->ChatWindow->WinId;
					HandleIConnect( &lEvents, Global );
					SetInfoChatWindow( TreeAddr[INFOS][CLOSE_IRC].ob_spec.free_string, IrcSession->IrcChannel->ChatWindow, Global );
					return( 1 );
				}
				case	TCP_out:
				{
					free( *( BYTE ** )&( Events->msg[5] ));
					break;
				}
			}
		}
	}
	return( E_OK );
}

static WORD	TimerWindow( void *UserData, WORD Global[15] )
{
	IRC_CHANNEL	*IrcChannel = ( IRC_CHANNEL * ) UserData;
	IRC_SESSION *IrcSession = ( IRC_SESSION * ) IrcChannel->IrcSession;
	TcpMessageTime( NULL, &( IrcSession->TcpMsgPuf ), -1, Global );
	return( E_OK );
}
static WORD	CheckWindow( EVNT *Events, void *UserData, WORD Global[15] )
{
	IRC_CHANNEL	*IrcChannel = ( IRC_CHANNEL * ) UserData;
	DIALOG_DATA	*DialogData = IrcChannel->ChatWindow->DialogData;
	return( HndlCheckDialogWIrc( DialogData, Events, Global ));
}

static WORD	ClosedWindow( void *UserData, WORD Global[15] )
{
	IRC_CHANNEL	*IrcChannel = ( IRC_CHANNEL * ) UserData;
	IRC_SESSION *IrcSession = ( IRC_SESSION * ) IrcChannel->IrcSession;
	IRC	*Irc = IrcSession->Irc;
	CHAT_WINDOW	*ChatWindow = IrcChannel->ChatWindow;

	WriteConfigChatWindow( IrcChannel->Name ? "Channel" : Irc->Host, IrcChannel->Name ? IrcChannel->Name : "Console", ChatWindow, Global );

	IrcChannel->ChatWindow = NULL;
	CloseIrcChannel( IrcChannel );
	return( E_OK );
}
