#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<TOS.H>
#include	<VDICOL.H>
#include	<MT_AES.H>
#include	<STDDEF.H>
#include	<STDARG.H>
#include	<STDLIB.H>
#include	<STRING.H>
#include	<STDIO.h>
#include	<MATH.H>
#include	<TIME.H>

#include	<atarierr.h>

#include	"main.h"
#include	RSCHEADER
#include	"IConnect.h"
#include	"Irc.h"
#include	"TCP.h"
#include	"WDialog.h"
#include	"WIrc\Func.h"
#include	"WIrc\IrcFunc.h"
#include	"WIrc\WChannel.h"
#include	"WIrc\WDccChat.h"
#include	"WIrc\WDccData.h"
#include	"WIrc\WInput.h"
#include	"WIrc\WIrcChat.h"
#include	"WIrc\WNames.h"
#include	"WIrc\WPut.h"

#include	"Keytab.h"

#define	RPL_LUSERCLIENT		251
#define	RPL_LUSEROP				252
#define	RPL_LUSERUNKNOWN		253
#define	RPL_LUSERCHANNELS		254
#define	RPL_LUSERME				255

#define	RPL_AWAY					301
#define	RPL_UNAWAY				305
#define	RPL_NOWAWAY				306
#define	RPL_WHOISUSER			311
#define	RPL_WHOISSERVER		312
#define	RPL_WHOISOPERATOR		313
#define	RPL_WHOISIDLE			317
#define	RPL_ENDOFWHOIS			318
#define	RPL_WHOISCHANNELS		319

#define	RPL_LISTSTART			321
#define	RPL_LIST					322
#define	RPL_LISTEND				323
#define	RPL_CHANNELMODEIS		324
#define	RPL_TOPIC				332
#define	RPL_INVITING			341
#define	RPL_NAMREPLY			353
#define	RPL_ENDOFNAMES			366
#define	RPL_MOTD					372
#define	RPL_MOTDSTART			375
#define	RPL_ENDOFMOTD			376

#define	ERR_NOSUCHNICK			401
#define	ERR_NOSUCHCHANNEL		403
#define	ERR_CANNOTSENDTOCHAN	404
#define	ERR_TOOMANYCHANNELS	405
#define	ERR_NICKNAMEINUSE		433
#define	ERR_NICKCOLLISION		436
#define	ERR_USERNOTINCHANNEL	441
#define	ERR_NOTONCHANNEL		442
#define	ERR_USERONCHANNEL		443
#define	ERR_INVITEONLYCHAN	473

#define	ERR_CHANNELISFULL		471
#define	ERR_UNKNOWNMODE		472
#define	ERR_BANNEDFROMCHAN	474
#define	ERR_CHANOPRIVSNEEDED	482
#define 	ERR_UMODEUNKOWNFLAG	501

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern char	Hostname[256];
extern WORD	SessionCounter;
extern KEYT	*Keytab;
extern WORD	KeytabAnsiExport, KeytabAnsiImport;
extern OBJECT	**TreeAddr;
extern WORD	IrcFlags;

IRC_CHANNEL	*GetIrcChannel( IRC_SESSION *IrcSession, BYTE *Name );
static void RedrawIrcSession( IRC_SESSION *IrcSession, WORD Global[15] );
static BYTE	*NextDD( BYTE *Puf );
static void	ParseMessage( IRC_SESSION *IrcSession, BYTE *Msg, WORD Global[15] );
static void	OutputMessage( IRC_SESSION *IrcSession, char *Name, char *Msg, int Colour, WORD Global[15] );
static void	OutputNames( IRC_SESSION *IrcSession, int Flag, char *Name, char *Nickname, int Colour, WORD Global[15] );
static void OutputInfoNames( IRC_SESSION *IrcSession, char *Name, char *Username, char *Realname, char *Channels, char *Server, char *Host, char *Idle, WORD Global[15] );
static void	DeleteNames( IRC_SESSION *IrcSession, char *Name, char *Nickname, WORD Global[15] );
static WORD	Cmp( BYTE *S1, BYTE *S2 );
static WORD CloseAlert( MOD_WIN **ModWin, WORD WinId );

/*-----------------------------------------------------------------------------*/
/* OpenIrcSession                                                              */
/*-----------------------------------------------------------------------------*/
WORD OpenIrcSession( IRC *Irc, WORD Global[15] )
{
	IRC_SESSION *IrcSession = malloc( sizeof( IRC_SESSION ));
	WORD	Ret, Msg[8];

	if( !IrcSession )
		return( ENSMEM );

	IrcSession->Irc = Irc;
	IrcSession->IrcChannel = NULL;
	IrcSession->Msg = NULL;
	IrcSession->MsgLen = 0;
	IrcSession->TcpMsgPuf = NULL;

	IrcSession->ModWin = NULL;
	IrcSession->TmpFile = NULL;
	IrcSession->Counter = 0;

	IrcSession->Away = NULL;
	IrcSession->SessionFlag = 0;
	
	IrcSession->Time = ( LONG ) time( NULL );

	if(( Ret = OpenIrcChannel( IrcSession, NULL, Global )) != E_OK )
	{
		free( IrcSession );
		return( Ret );
	}

	if(( IrcSession->TcpAppId = Tcp( Global )) <= 0 )
	{
/* Channel schliežen */
		free( IrcSession );
		return( ERROR );
	}

	Msg[0] = TCP_CMD;
	Msg[1] = Global[2];
	Msg[2] = 0;
	Msg[3] = IrcSession->IrcChannel->ChatWindow->WinId;
	Msg[4] = TCP_init;
	while( MT_appl_write( IrcSession->TcpAppId, 16, Msg, Global )  != 1 );
	SessionCounter++;

/*	OpenDccChatSession( CopyIrc( Irc ), -1, -1, Global );	*/

/*	OpenIrcChannel( IrcSession, "#atari.de", Global );	*/

	return( E_OK );
}

/*-----------------------------------------------------------------------------*/
/* OpenIrcChannel                                                              */
/*-----------------------------------------------------------------------------*/
WORD OpenIrcChannel( IRC_SESSION *IrcSession, BYTE *Name, WORD Global[15] )
{
	IRC_CHANNEL	*IrcChannel, *TmpChannel = IrcSession->IrcChannel;
	WORD	Ret;

	while( TmpChannel )
	{
		if( TmpChannel->Name && !stricmp( TmpChannel->Name, Name ))
			return( E_OK );
		if( !TmpChannel->next )
			break;
		TmpChannel = TmpChannel->next;
	}

	if( ( IrcChannel = malloc( sizeof( IRC_CHANNEL ))) == NULL )
		return( ENSMEM );
	IrcChannel->Name = Name ? strdup( Name ) : NULL;
	IrcChannel->next = NULL;
	IrcChannel->IrcSession = IrcSession;

	if( TmpChannel )
	{
		TmpChannel->next = IrcChannel;
		IrcChannel->prev = TmpChannel;
	}
	else
	{
		IrcSession->IrcChannel = IrcChannel;
		IrcChannel->prev = NULL;
	}

	IrcChannel->next = NULL;
	IrcChannel->ChatWindow = NULL;
	IrcChannel->ListWindow = NULL;
	IrcChannel->ModWin = NULL;
	IrcChannel->ChannelFlag = MODE_NONE;

	if(( Ret = OpenIrcChatWindow( IrcChannel, Global )) != E_OK )
	{
/* Aus Liste wieder rausnehmen */
		if( IrcChannel->Name )
			free( IrcChannel );
		free( IrcChannel );
		return( Ret );
	}

	if( Name )
	{
		if(( Name[0] == '#' || Name[0] == '&' ) && ( IrcFlags & AUTO_NAMES ))
			OpenNamesWindow( IrcChannel, Global );
	}

	return( E_OK );
}
void	CloseIrcChannel( IRC_CHANNEL *IrcChannel )
{
	IRC_SESSION	*IrcSession = IrcChannel->IrcSession;
	if( IrcChannel->ListWindow == NULL && IrcChannel->ChatWindow == NULL )
	{
		if( IrcChannel->prev )
			( IrcChannel->prev )->next = IrcChannel->next;
		else
			IrcSession->IrcChannel = IrcChannel->next;
		if( IrcChannel->next )
			( IrcChannel->next )->prev = IrcChannel->prev;

		if( IrcChannel->Name )
			free( IrcChannel->Name );
		free( IrcChannel );

		CloseIrcSession( IrcSession );
	}
}

void	CloseIrcSession( IRC_SESSION *IrcSession )
{
	if( !IrcSession->IrcChannel )
	{
		IrcSession->TcpMsgPuf = NULL;
		if( IrcSession->Away )
			free( IrcSession->Away );
		FreeIrc( IrcSession->Irc );
		free( IrcSession );
	}
}

static void	CloseIrcChannelWindow( IRC_CHANNEL *IrcChannel, WORD Global[15] )
{
	if( IrcChannel )
	{
		EVNT	lEvents;
		while( IrcChannel->ModWin )
		{
			lEvents.mwhich = MU_MESAG;
			lEvents.msg[0] = WM_CLOSED;
			lEvents.msg[1] = Global[2];
			lEvents.msg[2] = 0;
			lEvents.msg[3] = IrcChannel->ModWin->WinId;
			lEvents.msg[4] = WIN_CLOSE_WITHOUT_DEMAND;
			HandleWindow( &lEvents, Global );
		}
		if( IrcChannel->ListWindow )
		{
			lEvents.mwhich = MU_MESAG;
			lEvents.msg[0] = WM_CLOSED;
			lEvents.msg[1] = Global[2];
			lEvents.msg[2] = 0;
			lEvents.msg[3] = (( NAMES_WINDOW * )( IrcChannel->ListWindow ))->WinId;
			lEvents.msg[4] = WIN_CLOSE_WITHOUT_DEMAND;
			HandleWindow( &lEvents, Global );
		}
		lEvents.mwhich = MU_MESAG;
		lEvents.msg[0] = WM_CLOSED;
		lEvents.msg[1] = Global[2];
		lEvents.msg[2] = 0;
		lEvents.msg[3] = IrcChannel->ChatWindow->WinId;
		lEvents.msg[4] = WIN_CLOSE_WITHOUT_DEMAND;
		HandleWindow( &lEvents, Global );
	}	
}

void	CloseIrcSessionWindow( IRC_SESSION *IrcSession, WORD Global[15] )
{
	EVNT			lEvents;
	WORD			Msg[8];
	IRC_CHANNEL	*Tmp1 = IrcSession->IrcChannel->next, *Tmp2;

	IrcSession->SessionFlag |= MODE_CLOSE;
	SetInfoChatWindow( TreeAddr[INFOS][CLOSE_IRC].ob_spec.free_string, IrcSession->IrcChannel->ChatWindow, Global );

	while( Tmp1 )
	{
		Tmp2 = Tmp1->next;
		CloseIrcChannelWindow( Tmp1, Global );
		Tmp1 = Tmp2;
	}
	
	while( IrcSession->ModWin )
	{
		lEvents.mwhich = MU_MESAG;
		lEvents.msg[0] = WM_CLOSED;
		lEvents.msg[1] = Global[2];
		lEvents.msg[2] = 0;
		lEvents.msg[3] = IrcSession->ModWin->WinId;
		lEvents.msg[4] = WIN_CLOSE_WITHOUT_DEMAND;
		HandleWindow( &lEvents, Global );
	}

	if( IrcSession->IrcChannel->ListWindow )
	{
		lEvents.mwhich = MU_MESAG;
		lEvents.msg[0] = WM_CLOSED;
		lEvents.msg[1] = Global[2];
		lEvents.msg[2] = 0;
		lEvents.msg[3] = (( CHANNEL_WINDOW * )( IrcSession->IrcChannel->ListWindow ))->WinId;
		lEvents.msg[4] = WIN_CLOSE_WITHOUT_DEMAND;
		HandleWindow( &lEvents, Global );
	}

	Msg[0] = TCP_CMD;
	Msg[1] = Global[2];
	Msg[2] = 0;
	Msg[3] = IrcSession->IrcChannel->ChatWindow->WinId;
	Msg[4] = TCP_close;
	TcpMessageTime( Msg, &( IrcSession->TcpMsgPuf ), IrcSession->TcpAppId, Global );
	while( TcpMessageTime( NULL, &( IrcSession->TcpMsgPuf ), -1, Global ) != 0 )
		MT_appl_yield( Global );
}

char	*ConnectionRegistration( IRC *Irc )
{
	BYTE	Puf[1024];
	strcpy( Puf, "PASS " );
	strcat( Puf, Irc->Password ? Irc->Password : "Chatter" );
	strcat( Puf, "\r\n" );
	strcat( Puf, "NICK " );
	strcat( Puf, Irc->Nickname );
	strcat( Puf, "\r\n" );
	strcat( Puf, "USER ");
	strcat( Puf, Irc->Username );
	strcat( Puf, " " );
	strcat( Puf, Hostname );
	strcat( Puf, " " );
	strcat( Puf, Irc->Host );
	strcat( Puf, " :" );
	strcat( Puf, Irc->Realname );
	strcat( Puf, "\r\n" );
	return( strdup( Puf ));
}

char *GenerateMessage( char *Message, char *Channel, IRC_SESSION *IrcSession, WORD Global[15] )
{
	IRC	*Irc = IrcSession->Irc;
	char	Prefix[256], Ret[512];
	int	Pos;

/*	sprintf( Prefix, ":%s!%s@%s ", Irc->Nickname, Irc->Username, Hostname );	*/

	sprintf( Prefix, ":%s ", Irc->Nickname );

	if( Message[0] == '/' )
	{
		char	Command[128];
		sscanf( Message, "/%s%n", Command, &Pos );
		if( stricmp( Command, "AWAY" ) == 0 )
		{
			sprintf( Ret, "%sAWAY :%s\r\n", Prefix, &Message[Pos] + 1 );
			if( IrcSession->Away )
				free( IrcSession->Away );
			if( strlen( &Message[Pos] + 1 ))
				IrcSession->Away = strdup( &Message[Pos] + 1 );
			return( strdup( Ret ));
		}
		else	if( stricmp( Command, "CHAT" ) == 0 )
		{
			char	Nickname[128];
			Nickname[0] = 0;
			sscanf( &Message[Pos], " %s", Nickname );
			if( strlen( Nickname ))
			{
				if( OpenDccChatSession( IrcSession, Nickname, Global ) != E_OK )
					MT_form_alert( 1, TreeAddr[ALERTS][MEMORY].ob_spec.free_string, Global );
			}
			else
			{
				IRC_CHANNEL *IrcChannel = GetIrcChannel( IrcSession, Channel );
				OpenAlertIrc( IrcSession, IrcChannel, MsgDialog( IrcChannel, MSGDIALOG_DCCCHAT, Global ), MODWIN_NORMAL );
			}
			return( NULL );
		}
		else	if( stricmp( Command, "CTCP" ) == 0 )
		{
			char	Nickname[128], Msg[512];
			sscanf( &Message[Pos], " %s", Nickname );
			strcpy( Msg, &Message[Pos + strlen( Nickname ) + 2]);
			if( NextDD( Msg ) != Msg )
			{
				BYTE	K[128];
				sscanf( Msg, "%s", K );
				sprintf( Ret, "%sNOTICE %s :\001%s %s\001\r\n", Prefix, Nickname, K, NextDD( Msg ) + 1 );
			}
			else
			{
				BYTE	K[128];
				sscanf( Msg, "%s", K );
				if( strcmp( K, "PING" ) == 0 )
					sprintf( Ret, "%sPRIVMSG %s :\001%s %li\001\r\n", Prefix, Nickname, Msg, time( NULL ));
				else
					sprintf( Ret, "%sPRIVMSG %s :\001%s\001\r\n", Prefix, Nickname, Msg );
			}
			return( strdup( Ret ));
		}
		else	if( stricmp( Command, "INVITE" ) == 0 )
		{
			char	Nickname[128], Name[128];
			Nickname[0] = 0;
			Name[0] = 0;
			sscanf( &Message[Pos], " %s%s", Nickname, Name );

			if( strlen( Nickname) && Channel )
			{
				if( strlen( Name ))
					sprintf( Ret, "%sINVITE %s %s\r\n", Prefix, Nickname, Name );
				else
					sprintf( Ret, "%sINVITE %s %s\r\n", Prefix, Nickname, Channel );
				return( strdup( Ret ));
			}
			else
			{
				IRC_CHANNEL *IrcChannel = GetIrcChannel( IrcSession, Channel );
				OpenAlertIrc( IrcSession, IrcChannel, InviteDialog( IrcChannel, strlen( Nickname ) ? Nickname : NULL, Global ), MODWIN_NORMAL );
				return( NULL );
			}
		}
		else	if( stricmp( Command, "JOIN" ) == 0 )
		{
			sprintf( Ret, "%sJOIN %s\r\n", Prefix, &Message[Pos] + 1 );
			return( strdup( Ret ));
		}
		else	if( stricmp( Command, "LEAVE" ) == 0 )
		{
			char	Name[128];
			Name[0] = 0;
			sscanf( &Message[Pos], "%s", Name );
			if( strlen( Name ))
				sprintf( Ret, "%sPART %s\r\n", Prefix, Name );
			else	if( Channel )
				sprintf( Ret, "%sPART %s\r\n", Prefix, Channel );
			else
				return( NULL );
			return( strdup( Ret ));
		}
		else	if( stricmp( Command, "KICK" ) == 0 )
		{
			sprintf( Ret, "%sKICK %s\r\n", Prefix, &Message[Pos] + 1 );
			return( strdup( Ret ));
		}
		else	if( stricmp( Command, "LIST" ) == 0 )
		{
			if( !strcmp( &Message[Pos] + 1, "-n" ))
			{
				if( OpenChannelWindow( IrcSession->IrcChannel, 1, Global ) != E_OK )
					MT_form_alert( 1, TreeAddr[ALERTS][MEMORY].ob_spec.free_string, Global );
				if( ChannelWindowCheckDisable( IrcSession->IrcChannel, Global ) == E_OK )
				{
					if( !IrcSession->TmpFile )
					{
						BYTE	*Path, *HomePath, *DefaultPath;
						GetFilename( IrcSession->Irc->Host, "Tmp", &Path, &HomePath, &DefaultPath );
						if( DefaultPath )
							IrcSession->TmpFile = fopen( DefaultPath, "w" );
						else	if( HomePath )
							IrcSession->TmpFile = fopen( HomePath, "w" );
						else
							IrcSession->TmpFile = fopen( Path, "w" );
						if( Path )
							free( Path );
						if( HomePath )
							free( HomePath );
						if( DefaultPath )
							free( DefaultPath );
					}
					sprintf( Ret, "%sLIST\r\n", Prefix );
					return( strdup( Ret ));
				}
			}
			else
				if( OpenChannelWindow( IrcSession->IrcChannel, 1, Global ) != E_OK )
					MT_form_alert( 1, TreeAddr[ALERTS][MEMORY].ob_spec.free_string, Global );
			return( NULL );
		}
		else	if( stricmp( Command, "NAMES" ) == 0 )
		{
			IRC_CHANNEL	*IrcChannel;
			BYTE	Name[128];
			if( strlen( &Message[Pos] + 1 ))
			{
				sprintf( Ret, "%sNAMES %s\r\n", Prefix, &Message[Pos] + 1 );
				sprintf( Name, "%s", &Message[Pos] + 1 );
			}
			else	if( Channel )
			{
				sprintf( Ret, "%sNAMES %s\r\n", Prefix, Channel );
				sprintf( Name, "%s", Channel );
			}
			else
				return ( NULL );

			if(( IrcChannel = GetIrcChannel( IrcSession, Name )) != NULL )
			{
				OpenNamesWindow( IrcChannel, Global );
				NamesWindowReset( IrcChannel, Global );
			}
			return( strdup( Ret ));
		}
		else	if( stricmp( Command, "NICK" ) == 0 )
		{
			if( strlen( &Message[Pos] + 1 ))
			{
				sprintf( Ret, "%sNICK %s\r\n", Prefix, &Message[Pos] + 1 );
				return( strdup( Ret ));
			}
			else
			{
				OpenAlertIrc( IrcSession, NULL, NnDialog( IrcSession, Global ), MODWIN_NORMAL );
				return( NULL );
			}
		}
		else	if( stricmp( Command, "ME" ) == 0 )
		{
			if( !Channel || ( Channel[0] != '#' && Channel[0] != '&' ))
				return( NULL );
			sprintf( Ret, "%sPRIVMSG %s :\001ACTION %s\001\r\n", Prefix, Channel, &Message[Pos] + 1 );
			return( strdup( Ret ));
		}
		else	if( stricmp( Command, "MODE" ) == 0 )
		{
			sprintf( Ret, "%sMODE %s\r\n", Prefix, &Message[Pos] + 1 );
			return( strdup( Ret ));
		}
		else	if( stricmp( Command, "MSG" ) == 0 )
		{
			char	Nickname[128];
			Nickname[0] = 0;
			sscanf( &Message[Pos], " %s", Nickname );
			if( strlen( Nickname ))
			{
				if( OpenIrcChannel( IrcSession, Nickname, Global ) != E_OK )
					MT_form_alert( 1, TreeAddr[ALERTS][MEMORY].ob_spec.free_string, Global );
			}
			else
			{
				IRC_CHANNEL *IrcChannel = GetIrcChannel( IrcSession, Channel );
				OpenAlertIrc( IrcSession, IrcChannel, MsgDialog( IrcChannel, MSGDIALOG_CHAT, Global ), MODWIN_NORMAL );
			}
			return( NULL );
		}
		else	if( stricmp( Command, "PING" ) == 0 )
		{
			sprintf( Ret, "PING %s\r\n", Irc->Host );
			return( strdup( Ret ));
		}
		else	if( stricmp( Command, "QUIT" ) == 0 )
		{
			if( strlen( &Message[Pos] - 1 ))
				sprintf( Ret, "%sQUIT :%s\r\n", Prefix, &Message[Pos] + 1 );
			else
				sprintf( Ret, "%sQUIT\r\n", Prefix );
			return( strdup( Ret ));
		}
		else	if( stricmp( Command, "SEND" ) == 0 )
		{
			IRC_CHANNEL *IrcChannel = GetIrcChannel( IrcSession, Channel );
			char	Nickname[128];
			Nickname[0] = 0;
			sscanf( &Message[Pos], " %s", Nickname );
			OpenAlertIrc( IrcSession, IrcChannel, OpenPutWindow( IrcChannel, strlen( Nickname ) ? Nickname : NULL, Global ), MODWIN_NORMAL );
			return( NULL );
		}
		else	if( stricmp( Command, "TOPIC" ) == 0 )
		{
			if( Channel )
			{
				sprintf( Ret, "%sTOPIC %s :", Prefix, Channel );
				sprintf( Ret, "%sTOPIC %s :", Prefix, Channel );
				strcat( Ret, &Message[Pos] + 1 );
			}
			else
			{
				sprintf( Ret, "%sTOPIC ", Prefix );
				strcat( Ret, &Message[Pos] + 1 );
			}
			strcat( Ret, "\r\n" );
			return( strdup( Ret ));
		}
		else	if( stricmp( Command, "WHO" ) == 0 )
		{
			if( strlen( &Message[Pos] + 1 ))
				sprintf( Ret, "%sWHO %s\r\n", Prefix, &Message[Pos] + 1 );
			else
				sprintf( Ret, "%sWHO\r\n", Prefix );
			return( strdup( Ret ));
		}
		else	if( stricmp( Command, "WHOIS" ) == 0 )
		{
			if( strlen( &Message[Pos] + 1 ))
				sprintf( Ret, "%sWHOIS %s\r\n", Prefix, &Message[Pos] + 1 );
			else
				sprintf( Ret, "%sWHOIS\r\n", Prefix );
			return( strdup( Ret ));
		}
		else
		{
			sprintf( Ret, "%s%s\r\n", Prefix, &Message[1] );
			return( strdup( Ret ));
		}
	}
	else
	{
		if( Channel )
		{
			sprintf( Ret, "%sPRIVMSG %s :%s\r\n", Prefix, Channel, Message );
			return( strdup( Ret ));
		}
		else
		{
			return( NULL );
		}
	}
}


IRC_CHANNEL	*GetIrcChannel( IRC_SESSION *IrcSession, BYTE *Name )
{
	IRC_CHANNEL	*IrcChannel = IrcSession->IrcChannel->next;
	if( !Name )
		return( IrcSession->IrcChannel );
	while( IrcChannel )
	{
		if( stricmp( IrcChannel->Name, Name ) == 0 )
			return( IrcChannel );
		IrcChannel = IrcChannel->next;
	}
	return( NULL );
}

static void RedrawIrcSession( IRC_SESSION *IrcSession, WORD Global[15] )
{
	IRC_CHANNEL	*IrcChannel = IrcSession->IrcChannel;
	while( IrcChannel )
	{
		RedrawChatWindow( IrcChannel->ChatWindow, Global );
		if( IrcChannel->Name )
			NamesWindowRedraw( IrcChannel, Global );
		else
			ChannelWindowRedraw( IrcChannel, Global );
		IrcChannel = IrcChannel->next;
	}	
}

static BYTE	*NextDD( BYTE *Puf )
{
	BYTE	*Tmp = Puf;
	while( *Tmp )
		if( *Tmp == ':' )
			return( Tmp );
		else
			Tmp++;
	return( Puf );
}

/*-----------------------------------------------------------------------------*/
/* ParseMessage                                                                */
/*-----------------------------------------------------------------------------*/
void ParseInputIrcChat( IRC_SESSION *IrcSession, WORD Global[15] )
{
	long	Pos = 0, StartPos = 0;
	char	Msg[512];
	while( Pos + 1 < IrcSession->MsgLen )
	{
		if( IrcSession->Msg[Pos] == '\r' && IrcSession->Msg[Pos+1] == '\n' )
		{
			memcpy( Msg, &( IrcSession->Msg[StartPos] ), Pos + 2 - StartPos );
			Msg[Pos-StartPos] = '\0';

			ParseMessage( IrcSession, Msg, Global );

			Pos += 2;
			StartPos = Pos;
		}
		else
			Pos++;
	}
	if( StartPos )
	{
		if( IrcSession->MsgLen - StartPos > 0 )
		{
			memmove( IrcSession->Msg, &( IrcSession->Msg[StartPos] ), IrcSession->MsgLen - StartPos );
			IrcSession->MsgLen -= StartPos;
		}
		else
		{
			free( IrcSession->Msg );
			IrcSession->Msg = NULL;
			IrcSession->MsgLen = 0;
		}
	}
	RedrawIrcSession( IrcSession, Global );
}

static void	ParseMessage( IRC_SESSION *IrcSession, char *Msg, WORD Global[15] )
{
	BYTE	Prefix[128], Command[128], Params[128], Puf[512];
	int	Pos, Numeric;

	if( !strnicmp( Msg, "PING", 4 ))
	{
		if(  Msg[strlen( Msg ) - 2] != '\r' )
		{
			if( IrcSession->Irc->PingPong )
			{
				BYTE	*Cmd = malloc( 512 );
				if( Cmd )
				{
					sprintf( Cmd, "PONG%s\r\n", Msg + 4 );
					SendMessage( IrcSession, Cmd, Global );
				}
				return;
				OutputMessage( IrcSession, NULL, "PING? PONG!", COLOUR_MSG_SERVER, Global );
			}
			else
				OutputMessage( IrcSession, NULL, "PING?", COLOUR_MSG, Global );
		}
		else
		{
			OutputMessage( IrcSession, NULL, "PING?", COLOUR_MSG_SERVER, Global );
		}
		return;
	}
	else	if( !strnicmp( Msg, "PONG", 4 ))
		return;
	else	if( !strnicmp( Msg, "NICK", 4 ))
		return;
	else	if( !strnicmp( Msg, "ERROR", 5 ))
	{
		OutputMessage( IrcSession, NULL, Msg, COLOUR_MSG_SERVER, Global );
		return;
	}

	sscanf( Msg, ":%s%s%n", Prefix, Command, &Pos );

	if(( Numeric = atoi( Command )) != 0 )
	{
		switch( Numeric )
		{
			case	1:
			{
				SetInfoChatWindow( "", IrcSession->IrcChannel->ChatWindow, Global );
				if( IrcFlags & AUTO_CHANNEL )
				{
					if( OpenChannelWindow( IrcSession->IrcChannel, 1, Global ) != E_OK )
						MT_form_alert( 1, TreeAddr[ALERTS][MEMORY].ob_spec.free_string, Global );
				}
				if( IrcSession->Irc->Autojoin )
				{
					BYTE	Puf[1024];
					sprintf( Puf, "/JOIN %s", IrcSession->Irc->Autojoin );
					strcat( Puf, "" );
					SendMessage( IrcSession, GenerateMessage( Puf, NULL, IrcSession, Global ), Global );
				}
			}	
			case	2:
				OutputMessage( IrcSession, NULL, NextDD( &Msg[Pos] ) + 1, COLOUR_MSG_SERVER, Global );
			case	3:
				break;
			case	4:
				OutputMessage( IrcSession, NULL, NextDD( &Msg[Pos] ) + 1, COLOUR_MSG_SERVER, Global );
				break;
			case	RPL_LUSERCLIENT:
				OutputMessage( IrcSession, NULL, NextDD( &Msg[Pos] ) + 1, COLOUR_MSG_SERVER, Global );
				break;
			case	RPL_LUSEROP:
			case	RPL_LUSERUNKNOWN:
			case	RPL_LUSERCHANNELS:
				sscanf( &Msg[Pos], "%*s%s", Params );
				sprintf( Puf, "%s %s", Params, NextDD( &Msg[Pos] ) + 1 );
				OutputMessage( IrcSession, NULL, Puf, COLOUR_MSG_SERVER, Global );
				break;
			case	RPL_LUSERME:
				OutputMessage( IrcSession, NULL, NextDD( &Msg[Pos] ) + 1, COLOUR_MSG_SERVER, Global );
				break;

			case	RPL_AWAY:
			{
				BYTE	Nick[128], Output[512];
				sscanf( &Msg[Pos], "%*s%s", Nick );
				sprintf( Output, "*** %s is away: %s", Nick, NextDD( &Msg[Pos] ) + 1 );
				OutputMessage( IrcSession, Nick, Output, COLOUR_MSG_AWAY, Global );
				break;
			}
			case	RPL_UNAWAY:
				OutputMessage( IrcSession, NULL, NextDD( &Msg[Pos] ) + 1, COLOUR_MSG_SERVER, Global );
				break;
			case	RPL_NOWAWAY:
				OutputMessage( IrcSession, NULL, NextDD( &Msg[Pos] ) + 1, COLOUR_MSG_SERVER, Global );
				break;
			case	RPL_WHOISUSER:
			{
				BYTE	Name[128], Username[128], Host[512], Realname[512], Dummy[128];
				sscanf( &Msg[Pos], "%s%s%s%s", Dummy, Name, Username, Host );
				strcpy( Realname, NextDD( &Msg[Pos] ) + 1 );
				OutputInfoNames( IrcSession, Name, Username, Realname, NULL, NULL, Host, NULL, Global );
				break;
			}
			case	RPL_WHOISSERVER:
			{
				BYTE	Name[128], Server[128], Dummy[128];
				sscanf( &Msg[Pos], "%s%s%s", Dummy, Name, Server );
				OutputInfoNames( IrcSession, Name, NULL, NULL, NULL, Server, NULL, NULL, Global );
				break;
			}
			case	RPL_WHOISIDLE:
			{
				BYTE	Name[128], Idle[20], Dummy[128];
				sscanf( &Msg[Pos], "%s%s%s", Dummy, Name, Idle );
				OutputInfoNames( IrcSession, Name, NULL, NULL, NULL, NULL, NULL, Idle, Global );
				break;
			}
			case	RPL_ENDOFWHOIS:
				break;
			case	RPL_WHOISCHANNELS:
			{
			 	BYTE	Name[128], Channels[128], Dummy[128];
			 	sscanf( &Msg[Pos], "%s%s", Dummy, Name );
				strcpy( Channels, NextDD( &Msg[Pos] ) + 1 );
				OutputInfoNames( IrcSession, Name, NULL, NULL, Channels, NULL, NULL, NULL, Global );
				break;
			}
			case	RPL_LISTSTART:
			{
				break;
			}
			case	RPL_LIST:
			{
				BYTE	Name[128], User[10], Topic[512];
				sscanf( &Msg[Pos], "%*s%s%s", Name, User );
				strcpy( Topic, NextDD( &Msg[Pos] ) + 1 );
				if( IrcSession->TmpFile )
				{
					fprintf( IrcSession->TmpFile, "%s\n%s\n%s\n", Name, User, Topic );
					if( IrcSession->Counter++ == 1024 )
					{
						IrcSession->Counter = 0;
						SendMessage( IrcSession, GenerateMessage( "/PING", NULL, IrcSession, Global ), Global );
					}
				}
				break;
			}
			case	RPL_LISTEND:
			{
				fclose( IrcSession->TmpFile );
				IrcSession->TmpFile = NULL;
				IrcSession->Counter = 0;
				ChannelWindowUpdate( IrcSession->IrcChannel, Global );
				break;
			}
			case	RPL_CHANNELMODEIS:
			{
				BYTE	Name[128], Mode[128];
				IRC_CHANNEL	*IrcChannel;
				sscanf( &Msg[Pos], "%*s%s%s", Name, Mode );
				if(( IrcChannel = GetIrcChannel( IrcSession, Name )) != NULL )
				{
					WORD	i = 0;
					while( Mode[i] )
					{
						switch( Mode[i++] )
						{
							case	'i':
								if( IrcChannel )
									IrcChannel->ChannelFlag |= MODE_INVITE;
/* else Usermode */
								break;
							case	'l':
							{
								sscanf( &Msg[Pos], "%*s%*s%*s%li", &( IrcChannel->ChannelLimit ));
								IrcChannel->ChannelFlag |= MODE_LIMIT;
								break;
							}
							case	'm':
								IrcChannel->ChannelFlag |= MODE_MODERATED;
								break;
							case	's':
								IrcChannel->ChannelFlag |= MODE_SECRET;
								break;
							case	't':
								IrcChannel->ChannelFlag |= MODE_TOPIC;
								break;
						}
					}
				}
				break;
			}
			case	RPL_TOPIC:
			{
				BYTE	Name[128], Topic[512];
				IRC_CHANNEL	*IrcChannel = IrcSession->IrcChannel->next;
				sscanf( &Msg[Pos], "%*s%s", Name );
				strcpy( Topic, NextDD( &Msg[Pos] ) + 1 );
				if(( IrcChannel = GetIrcChannel( IrcSession, Name )) != NULL )
					SetInfoChatWindow( Topic, IrcChannel->ChatWindow, Global );
				break;
			}
			case	RPL_INVITING:
			{
				BYTE	Nickname[128], Name[128], Output[512];
				sscanf( &Msg[Pos], "%*s%s%s", Nickname, Name );
				sprintf( Output, "*** %s inviting to channel %s", Nickname, Name );
				OutputMessage( IrcSession, NULL, Output, COLOUR_MSG_SERVER, Global );
				break;
			}
			case	RPL_NAMREPLY:
			{
				BYTE	Nickname[128], Name[128], *Start;
				int	Read, Flag = 0;
				Name[0] = 0;
				sscanf( &Msg[Pos], "%*s = %s", Name );
				if( strlen( Name ) == 0 )
					sscanf( &Msg[Pos], "%*s @ %s", Name );
				Start = NextDD( &Msg[Pos] ) + 1;
				while( *Start != 0 )
				{
					Read = 0;
					Flag = 0;
					if( *Start == '@' )
						Flag = 1;
					else	if( *Start == '*' )
						Flag = 2;
					else	if( *Start == '+' )
						Flag = 3;
					while( *Start != ' ' && *Start != 0 )
					{
						if( Read || *Start != '@' && *Start != '*' && *Start != '+' )
							Nickname[Read++] = *Start;
						Start++;
					}
					if( *Start != 0 )
						Start++;
					Nickname[Read] = 0;
					if( Flag == 0 )
						OutputNames( IrcSession, 0, Name, Nickname, COLOUR_USER, Global );
					else	if( Flag == 1 )
						OutputNames( IrcSession, 0, Name, Nickname, COLOUR_USER_OP, Global );
					else	if( Flag == 2 )
						OutputNames( IrcSession, 0, Name, Nickname, COLOUR_USER_IRCOP, Global );
					else	if( Flag == 3 )
						OutputNames( IrcSession, 0, Name, Nickname, COLOUR_USER_VOICE, Global );
				}
				break;
			}
			case	RPL_ENDOFNAMES:
			{
				IRC_CHANNEL	*Channel;
				BYTE	Name[128];
				sscanf( &Msg[Pos], "%*s %s", Name );
				Channel = GetIrcChannel( IrcSession, Name );
				if( Channel )
					NamesWindowWhois( Channel, Global );
				break;
			}
			case	RPL_MOTD:
			case	RPL_MOTDSTART:
			case	RPL_ENDOFMOTD:
				OutputMessage( IrcSession, NULL, NextDD( &Msg[Pos] ) + 1, COLOUR_MSG_SERVER, Global );
				break;
			case	ERR_NOSUCHNICK:
			{
				BYTE	Output[512], Nickname[128];
				sscanf( &Msg[Pos], "%*s%s", Nickname );
				sprintf( Output, "*** %s %s", Nickname, NextDD( &Msg[Pos] ) + 1 );
				OutputMessage( IrcSession, NULL, Output, COLOUR_MSG_SERVER, Global );
				OpenAlertIrc( IrcSession, NULL, AlertDialogX( 1, TreeAddr[ALERTS][ALERT_NOSUCHNICK].ob_spec.free_string, IrcSession->IrcChannel->ChatWindow->Title, CloseSessionAlertIrc, IrcSession, Global, 1, Nickname ), MODWIN_NORMAL );
				break;
			}
			case	ERR_NOSUCHCHANNEL:
			{
				BYTE	Output[512], Name[128];
				sscanf( &Msg[Pos], "%*s%s", Name );
				sprintf( Output, "*** %s %s", Name, NextDD( &Msg[Pos] ) + 1 );
				OutputMessage( IrcSession, NULL, Output, COLOUR_MSG_SERVER, Global );
				OpenAlertIrc( IrcSession, NULL, AlertDialogX( 1, TreeAddr[ALERTS][ALERT_NOSUCHCHANNEL].ob_spec.free_string, IrcSession->IrcChannel->ChatWindow->Title, CloseSessionAlertIrc, IrcSession, Global, 1, Name ), MODWIN_NORMAL );
				break;
			}
			case	ERR_CANNOTSENDTOCHAN:
			{
				BYTE	Output[512], Name[128];
				IRC_CHANNEL	*IrcChannel;
				sscanf( &Msg[Pos], "%*s%s", Name );
				sprintf( Output, "*** %s %s", Name, NextDD( &Msg[Pos] ) + 1 );
				OutputMessage( IrcSession, NULL, Output, COLOUR_MSG_SERVER, Global );
				IrcChannel = GetIrcChannel( IrcSession, Name );
				OpenAlertIrc( IrcSession, IrcChannel, AlertDialogX( 1, TreeAddr[ALERTS][ALERT_CANNOTSENDTOCHAN].ob_spec.free_string, IrcSession->IrcChannel->ChatWindow->Title, ( IrcChannel ? CloseChannelAlertIrc : CloseSessionAlertIrc ), ( IrcChannel ? IrcChannel : IrcSession ), Global, 1, Name ), MODWIN_NORMAL );
				break;
			}
			case	ERR_TOOMANYCHANNELS:
			{
				BYTE	Output[512], Name[128];
				sscanf( &Msg[Pos], "%*s%s", Name );
				sprintf( Output, "*** %s %s", Name, NextDD( &Msg[Pos] ) + 1 );
				OutputMessage( IrcSession, NULL, Output, COLOUR_MSG_SERVER, Global );
				OpenAlertIrc( IrcSession, NULL, AlertDialog( 1, TreeAddr[ALERTS][ALERT_TOOMANYCHANNELS].ob_spec.free_string, IrcSession->IrcChannel->ChatWindow->Title, CloseSessionAlertIrc, IrcSession, Global ), MODWIN_NORMAL );
				break;
			}
			case	ERR_NICKNAMEINUSE:
			{
				BYTE	Output[512], Nickname[128];
				sscanf( &Msg[Pos], "%*s%s", Nickname );
				sprintf( Output, "*** %s %s", Nickname, NextDD( &Msg[Pos] ) + 1 );
				OutputMessage( IrcSession, NULL, Output, COLOUR_MSG_SERVER, Global );
				if( !IrcSession->ModWin )
					OpenAlertIrc( IrcSession, NULL, NiuDialog( IrcSession, Nickname, Global ), MODWIN_NORMAL );
				break;
			}
			case	ERR_USERNOTINCHANNEL:
			{
				BYTE	Output[512], Nickname[128], Name[128];
				IRC_CHANNEL	*IrcChannel;

				sscanf( &Msg[Pos], "%*s%s%s", Nickname, Name );
				sprintf( Output, "*** %s %s %s", Nickname, Name, NextDD( &Msg[Pos] ) + 1 );
				OutputMessage( IrcSession, NULL, Output, COLOUR_MSG_SERVER, Global );
				IrcChannel = GetIrcChannel( IrcSession, Name );
				OpenAlertIrc( IrcSession, IrcChannel, AlertDialogX( 1, TreeAddr[ALERTS][ALERT_USERNOTINCHANNEL].ob_spec.free_string, IrcSession->IrcChannel->ChatWindow->Title, ( IrcChannel ? CloseChannelAlertIrc : CloseSessionAlertIrc ), ( IrcChannel ? IrcChannel : IrcSession ), Global, 2, Nickname, Name ), MODWIN_NORMAL );
				break;
			}
			case	ERR_NOTONCHANNEL:
			{
				BYTE	Output[512], Name[128];
				IRC_CHANNEL	*IrcChannel;
				sscanf( &Msg[Pos], "%*s%s", Name );
				sprintf( Output, "*** %s %s", Name, NextDD( &Msg[Pos] ) + 1 );
				OutputMessage( IrcSession, NULL, Output, COLOUR_MSG_SERVER, Global );
				IrcChannel = GetIrcChannel( IrcSession, Name );
				OpenAlertIrc( IrcSession, IrcChannel, AlertDialogX( 1, TreeAddr[ALERTS][ALERT_NOTONCHANNEL].ob_spec.free_string, IrcSession->IrcChannel->ChatWindow->Title, ( IrcChannel ? CloseChannelAlertIrc : CloseSessionAlertIrc ), ( IrcChannel ? IrcChannel : IrcSession ), Global, 1, Name ), MODWIN_NORMAL );
				break;
			}
			case	ERR_USERONCHANNEL:
			{
				BYTE	Output[512], Nickname[128], Name[128];
				IRC_CHANNEL	*IrcChannel;
				sscanf( &Msg[Pos], "%*s%s%s", Nickname, Name );
				sprintf( Output, "*** %s %s %s", Nickname, Name, NextDD( &Msg[Pos] ) + 1 );
				OutputMessage( IrcSession, NULL, Output, COLOUR_MSG_SERVER, Global );
				IrcChannel = GetIrcChannel( IrcSession, Name );
				OpenAlertIrc( IrcSession, IrcChannel, AlertDialogX( 1, TreeAddr[ALERTS][ALERT_USERONCHANNEL].ob_spec.free_string, IrcSession->IrcChannel->ChatWindow->Title, ( IrcChannel ? CloseChannelAlertIrc : CloseSessionAlertIrc ), ( IrcChannel ? IrcChannel : IrcSession ), Global, 2, Nickname, Name ), MODWIN_NORMAL );
				break;
			}			
			case	ERR_INVITEONLYCHAN:
			{
				BYTE	Output[512], Name[128];
				sscanf( &Msg[Pos], "%*s%s", Name );
				sprintf( Output, "*** %s %s", Name, NextDD( &Msg[Pos] ) + 1 );
				OutputMessage( IrcSession, NULL, Output, COLOUR_MSG_SERVER, Global );
				OpenAlertIrc( IrcSession, NULL, AlertDialogX( 1, TreeAddr[ALERTS][ALERT_INVITEONLYCHAN].ob_spec.free_string, IrcSession->IrcChannel->ChatWindow->Title, CloseSessionAlertIrc, IrcSession, Global, 1, Name ), MODWIN_NORMAL );
				break;
			}
			case	ERR_CHANNELISFULL:
			{
				BYTE	Output[512], Name[128];
				sscanf( &Msg[Pos], "%*s%s", Name );
				sprintf( Output, "*** %s %s", Name, NextDD( &Msg[Pos] ) + 1 );
				OutputMessage( IrcSession, NULL, Output, COLOUR_MSG_SERVER, Global );
				OpenAlertIrc( IrcSession, NULL, AlertDialogX( 1, TreeAddr[ALERTS][ALERT_CHANNELISFULL].ob_spec.free_string, IrcSession->IrcChannel->ChatWindow->Title, CloseSessionAlertIrc, IrcSession, Global, 1, Name ), MODWIN_NORMAL );
				break;
			}
			case	ERR_UNKNOWNMODE:
			{
				BYTE	Output[512], Mode[128];
				sscanf( &Msg[Pos], "%*s%s", Mode );
				sprintf( Output, "*** %s %s", Mode, NextDD( &Msg[Pos] ) + 1 );
				OutputMessage( IrcSession, NULL, Output, COLOUR_MSG_SERVER, Global );
				OpenAlertIrc( IrcSession, NULL, AlertDialogX( 1, TreeAddr[ALERTS][ALERT_UNKNOWNMODE].ob_spec.free_string, IrcSession->IrcChannel->ChatWindow->Title, CloseSessionAlertIrc, IrcSession, Global, 1, Mode ), MODWIN_NORMAL );
				break;
			}
			case	ERR_BANNEDFROMCHAN:
			{
				BYTE	Output[512], Name[128];
				sscanf( &Msg[Pos], "%*s%s", Name );
				sprintf( Output, "*** %s %s", Name, NextDD( &Msg[Pos] ) + 1 );
				OutputMessage( IrcSession, NULL, Output, COLOUR_MSG_SERVER, Global );
				OpenAlertIrc( IrcSession, NULL, AlertDialogX( 1, TreeAddr[ALERTS][ALERT_BANNEDFROMCHAN].ob_spec.free_string, IrcSession->IrcChannel->ChatWindow->Title, CloseSessionAlertIrc, IrcSession, Global, 1, Name ), MODWIN_NORMAL );
				break;
			}
			case	ERR_CHANOPRIVSNEEDED:
			{
				BYTE	Output[512], Name[128];
				IRC_CHANNEL	*IrcChannel;
				sscanf( &Msg[Pos], "%*s%s", Name );
				sprintf( Output, "*** %s %s", Name, NextDD( &Msg[Pos] ) + 1 );
				OutputMessage( IrcSession, NULL, Output, COLOUR_MSG_SERVER, Global );
				IrcChannel = GetIrcChannel( IrcSession, Name );
				OpenAlertIrc( IrcSession, IrcChannel, AlertDialogX( 1, TreeAddr[ALERTS][ALERT_CHANOPRIVSNEEDED].ob_spec.free_string, IrcSession->IrcChannel->ChatWindow->Title, ( IrcChannel ? CloseChannelAlertIrc : CloseSessionAlertIrc ), ( IrcChannel ? IrcChannel : IrcSession ), Global, 1, Name ), MODWIN_NORMAL );
				break;
			}
			case	ERR_UMODEUNKOWNFLAG:
			{
				BYTE	Output[512];
				sprintf( Output, "*** %s", NextDD( &Msg[Pos] ) + 1 );
				OutputMessage( IrcSession, NULL, Output, COLOUR_MSG_SERVER, Global );
				OpenAlertIrc( IrcSession, NULL, AlertDialog( 1, TreeAddr[ALERTS][ALERT_UMODEUNKOWNFLAG].ob_spec.free_string, IrcSession->IrcChannel->ChatWindow->Title, CloseSessionAlertIrc, IrcSession, Global ), MODWIN_NORMAL );
				break;
			}
			default:
				OutputMessage( IrcSession, NULL, Msg, -1, Global );
		}
	}
	else	if( !stricmp( Command, "AWAY" ))
	{
	}
	else	if( !stricmp( Command, "INVITE" ))
	{
		BYTE	Name[128], Nickname[128], Output[512];
		sscanf( Msg, ":%[^! ]", Nickname );
		sscanf( &Msg[Pos], "%s", Name );
		if( stricmp( IrcSession->Irc->Nickname, Nickname ) != 0 )
		{
			sprintf( Output, "*** %s invites you to channel %s", Nickname, NextDD( &Msg[Pos] ) + 1 );
			OutputMessage( IrcSession, NULL, Output, -1, Global );
			OpenAlertIrc( IrcSession, NULL, InivtedDialog( IrcSession, Nickname, NextDD( &Msg[Pos] ) + 1, Global ), MODWIN_NORMAL );
		}
	}
	else	if( !stricmp( Command, "JOIN" ))
	{
		BYTE	Name[128], Nickname[128], Fullname[128], Output[512];;
		sscanf( Msg, ":%s", Fullname );
		sscanf( Msg, ":%[^! ]", Nickname );
		sscanf( NextDD( &Msg[Pos] ) + 1, "%s", Name );
		sprintf( Output, "*** %s (%s) has joined channel %s", Nickname, Fullname, Name );
		if( stricmp( Nickname, IrcSession->Irc->Nickname ) != 0 )
		{
			OutputNames( IrcSession, 1, Name, Nickname, COLOUR_USER, Global );
			OutputMessage( IrcSession, Name, Output, COLOUR_MSG_SERVER, Global );
		}
		else	if( Msg[strlen( Msg ) - 2] != '\r' )
		{
			if( OpenIrcChannel( IrcSession, Name, Global ) != E_OK )
				MT_form_alert( 1, TreeAddr[ALERTS][MEMORY].ob_spec.free_string, Global );
			else
			{
				BYTE	Puf[128];
				sprintf( Puf, "/MODE %s", Name );
				strcat( Puf, "" );
				SendMessage( IrcSession, GenerateMessage( Puf, Name, IrcSession, Global ), Global );
			}
		}
	}
	else	if( !stricmp( Command, "KICK" ))
	{
		if( Msg[strlen( Msg ) - 2] != '\r' )
		{
			BYTE	Orig[128], Opfer[128], Name[128], Output[512];
			sscanf( Msg, ":%[^! ]", Orig );
			sscanf( &Msg[Pos], "%s%s", Name, Opfer );

			if( stricmp( Opfer, IrcSession->Irc->Nickname ))
			{
				DeleteNames( IrcSession, Name, Opfer, Global );
				sprintf( Output, "*** %s has been kicked off channel %s by %s (%s)", Opfer, Name, Orig, NextDD( &Msg[Pos] ) + 1 );
				OutputMessage( IrcSession, Name, Output, COLOUR_MSG_OP, Global );
			}
			else
			{
				IRC_CHANNEL	*IrcChannel;
				CloseIrcChannelWindow( GetIrcChannel( IrcSession, Name ), Global );
				sprintf( Output, "*** You have been kicked off channel %s by %s (%s)", Name, Orig, NextDD( &Msg[Pos] ) + 1 );
				OutputMessage( IrcSession, NULL, Output, COLOUR_MSG_OP, Global );
				IrcChannel = GetIrcChannel( IrcSession, Name );
				OpenAlertIrc( IrcSession, IrcChannel, AlertDialogX( 1, TreeAddr[ALERTS][ALERT_KICK].ob_spec.free_string, IrcSession->IrcChannel->ChatWindow->Title, ( IrcChannel ? CloseChannelAlertIrc : CloseSessionAlertIrc ), ( IrcChannel ? IrcChannel : IrcSession ), Global, 2, Orig, Name ), MODWIN_NORMAL );
			}
		}
	}
	else	if( !stricmp( Command, "LIST" ))
	{
/*		if( !IrcSession->TmpFile )
		{
			BYTE	*Path, *HomePath, *DefaultPath;
			GetFilename( IrcSession->Irc->Host, "Tmp", &Path, &HomePath, &DefaultPath );
			if( DefaultPath )
				IrcSession->TmpFile = fopen( DefaultPath, "w" );
			else	if( HomePath )
				IrcSession->TmpFile = fopen( HomePath, "w" );
			else
				IrcSession->TmpFile = fopen( Path, "w" );
			if( Path )
				free( Path );
			if( HomePath )
				free( HomePath );
			if( DefaultPath )
				free( DefaultPath );
		}
*/	}
	else	if( !stricmp( Command, "MODE" ))
	{
		if( Msg[strlen( Msg ) - 2] != '\r' )
		{
			WORD	Colour = COLOUR_MSG_SERVER, i = 0, Flag;
			BYTE	Nickname[128], Name[128], Mode[10], Op[128], Output[512];
			IRC_CHANNEL	*IrcChannel;
			Nickname[0] = 0;
			sscanf( Msg, ":%[^!@ ]", Op );
			sscanf( &Msg[Pos], "%s%s%s", Name, Mode, Nickname );
			IrcChannel = GetIrcChannel( IrcSession, Name );
			while( Mode[i] )
			{
				switch( Mode[i++] )
				{
					case	'+':
						Flag = 1;
						break;
					case	'-':
						Flag = 0;
						break;
					case	'i':
						if( IrcChannel )
							Flag ? ( IrcChannel->ChannelFlag |= MODE_INVITE ) : ( IrcChannel->ChannelFlag &= ~MODE_INVITE );
						else
							Flag ? ( IrcSession->SessionFlag |= MODE_INVISIBLE ) : ( IrcSession->SessionFlag &= ~MODE_INVISIBLE );
						break;
					case	'l':
						if( IrcChannel )
						{
							if( Flag )
							{
								IrcChannel->ChannelFlag |= MODE_LIMIT;
								sscanf( &Msg[Pos], "%*s%*s%li", &( IrcChannel->ChannelLimit ));
							}
							else
								IrcChannel->ChannelFlag &= ~MODE_LIMIT;
						}
						break;
					case	'm':
						Flag ? ( IrcChannel->ChannelFlag |= MODE_MODERATED ) : ( IrcChannel->ChannelFlag &= ~MODE_MODERATED );
						break;
					case	'n':
						Flag ? ( IrcChannel->ChannelFlag |= MODE_MESSAGE ) : ( IrcChannel->ChannelFlag &= ~MODE_MESSAGE );
						break;
					case	'o':
						if( Flag )
							OutputNames( IrcSession, 1, Name, Nickname, COLOUR_USER_OP, Global );
						else
							OutputNames( IrcSession, 1, Name, Nickname, COLOUR_USER, Global );
						Colour = COLOUR_MSG_OP;
						break;
					case	'p':
						Flag ? ( IrcChannel->ChannelFlag |= MODE_PRIVATE ) : ( IrcChannel->ChannelFlag &= ~MODE_PRIVATE );
						break;
					case	's':
						if( IrcChannel )
							Flag ? ( IrcChannel->ChannelFlag |= MODE_SECRET ) : ( IrcChannel->ChannelFlag &= ~MODE_SECRET );
						else
							Flag ? ( IrcSession->SessionFlag |= MODE_NOTICE ) : ( IrcSession->SessionFlag &= ~MODE_NOTICE );
						break;
					case	't':
						Flag ? ( IrcChannel->ChannelFlag |= MODE_TOPIC ) : ( IrcChannel->ChannelFlag &= ~MODE_TOPIC );
						break;
					case	'v':
					{
						WORD	C;
						if( IsInNamesWindow( IrcChannel, Nickname, &C, Global ))
						{
							if( C != COLOUR_USER_OP )
							{
								if( Flag )
									OutputNames( IrcSession, 1, Name, Nickname, COLOUR_USER_VOICE, Global );
								else
									OutputNames( IrcSession, 1, Name, Nickname, COLOUR_USER, Global );
							}
						}
						Colour = COLOUR_MSG_OP;
						break;
					}
					case	'w':
						Flag ? ( IrcSession->SessionFlag |= MODE_NOTICE ) : ( IrcSession->SessionFlag &= ~MODE_NOTICE );
						break;
				}
			}
			sprintf( Output, "*** %s sets mode: %s %s", Op, Mode, Nickname );
			OutputMessage( IrcSession, Name, Output, Colour, Global );
		}
	}
	else	if( !stricmp( Command, "NAMES" ))
	{
/*		BYTE	Name[128];
		IRC_CHANNEL	*IrcChannel;
		sscanf( &Msg[Pos], "%s", Name );
		
		if(( IrcChannel = GetIrcChannel( IrcSession, Name )) != NULL )
		{
			OpenNamesWindow( IrcChannel, Global );
			NamesWindowReset( IrcChannel, Global );
		}
*/	}
	else	if( !stricmp( Command, "NICK" ))
	{
		if( Msg[strlen( Msg ) - 2] != '\r' )
		{
			BYTE	Nickname[128];
			BYTE	Output[512];
			IRC_CHANNEL	*Tmp = IrcSession->IrcChannel->next;
			WORD	Colour;
			sscanf( Msg, ":%[^! ]", Nickname );

			if( !stricmp( Nickname, IrcSession->Irc->Nickname ))
			{
				free( IrcSession->Irc->Nickname );
				IrcSession->Irc->Nickname = strdup( NextDD( &Msg[Pos] ) + 1 );
				sprintf( Output, "*** %s is now known as %s", Nickname, NextDD( &Msg[Pos] ) + 1 );
				OutputMessage( IrcSession, NULL, Output, COLOUR_MSG_SERVER, Global );
			}
			while( Tmp )
			{
				if( Tmp->Name[0] != '#' && Tmp->Name[0] != '&' && !stricmp( Tmp->Name, Nickname ))
				{
					BYTE	Puf[128];
					sprintf( Puf, "%s %s %s", TreeAddr[TITLES][TITLE_WINDOW].ob_spec.free_string, IrcSession->Irc->Host, NextDD( &Msg[Pos] ) + 1 );
					SetTitleChatWindow( Puf, Tmp->ChatWindow, Global );
					sprintf( Output, "*** %s is now known as %s", Nickname, NextDD( &Msg[Pos] ) + 1 );
					OutputMessage( IrcSession, Tmp->Name, Output, COLOUR_MSG_SERVER, Global );
					free( Tmp->Name );
					Tmp->Name = strdup( NextDD( &Msg[Pos] ) + 1 );
				}
				else	if( IsInNamesWindow( Tmp, Nickname, &Colour, Global ))
				{
					DeleteNames( IrcSession, Tmp->Name, Nickname, Global );
					OutputNames( IrcSession, 1, Tmp->Name, NextDD( &Msg[Pos] ) + 1, Colour, Global );
					sprintf( Output, "*** %s is now known as %s", Nickname, NextDD( &Msg[Pos] ) + 1 );
					if( stricmp( Nickname, IrcSession->Irc->Nickname ))
						OutputMessage( IrcSession, Tmp->Name, Output, COLOUR_MSG_SERVER, Global );
				}
				Tmp = Tmp->next;
			}
		}
	}
	else	if( !stricmp( Command, "NOTICE" ))
	{
		BYTE	Name[128], Nickname[128], Output[512];
		sscanf( Msg, ":%[^! ]", Nickname );
		sscanf( &Msg[Pos], "%s", Name );

		if( *( NextDD( &Msg[Pos] ) + 1 ) == 1 )
		{
			if( Msg[strlen( Msg ) - 2] != '\r' )
			{
				BYTE	P1[128], P2[1024];
				sscanf( NextDD( &Msg[Pos] ) + 2, "%s %[^\n]", P1, P2 );
				if( strrchr( P2, 1 ))
					*strrchr( P2, 1 ) = 0;
				if( strcmp( P1, "PING" ) == 0 )
				{
					LONG	i = ( LONG ) time( NULL ) - atol( P2 );
					if( i <= 1 )
						sprintf( Output, "*** CTCP PING reply from %s: %li second", Nickname, i );
					else
						sprintf( Output, "*** CTCP PING reply from %s: %li seconds", Nickname, i );
				}
				else
					sprintf( Output, "*** CTCP %s reply from %s: %s", P1, Nickname, P2 );
				OutputMessage( IrcSession, NULL, Output, COLOUR_MSG, Global );
			}
		}
		else
		{
			sprintf( Output, "<%s> %s", Nickname, NextDD( &Msg[Pos] ) + 1 );
			OutputMessage( IrcSession, NULL, Output, COLOUR_MSG, Global );
		}
	}
	else	if( !stricmp( Command, "PART" ))
	{
		BYTE	Name[128], Nickname[128], Fullname[128], Output[512];;
		sscanf( Msg, ":%s", Fullname );
		sscanf( Msg, ":%[^! ]", Nickname );
		sscanf( &Msg[Pos], "%s", Name );
		sprintf( Output, "*** %s has left channel %s", Nickname, Name );
		if( stricmp( Nickname, IrcSession->Irc->Nickname ) != 0 )
		{
			DeleteNames( IrcSession, Name, Nickname, Global );
			OutputMessage( IrcSession, Name, Output, COLOUR_MSG_SERVER, Global );
		}
		else
		{
			if( Msg[strlen( Msg ) - 2] == '\r' )
				CloseIrcChannelWindow( GetIrcChannel( IrcSession, Name ), Global );
		}
	}
	else	if( !stricmp( Command, "PONG" ))
	{
		OutputMessage( IrcSession, NULL, "PONG!", COLOUR_MSG_SERVER, Global );
	}
	else	if( !stricmp( Command, "QUIT" ))
	{
		BYTE	Nickname[128];
		sscanf( Msg, ":%[^! ]", Nickname );
		if( !stricmp( Nickname, IrcSession->Irc->Nickname ))
		{
			if( Msg[strlen( Msg ) - 2] == '\r' )
				CloseIrcSessionWindow( IrcSession, Global );
		}
		else
		{
			BYTE	Output[512];
			IRC_CHANNEL	*Tmp = IrcSession->IrcChannel->next;
			WORD	Colour;
			while( Tmp )
			{
				if( Tmp->Name[0] != '#' && Tmp->Name[0] != '&' && !stricmp( Tmp->Name, Nickname ))
					OpenAlertIrc( IrcSession, Tmp, AlertDialogX( 1, TreeAddr[ALERTS][ALERT_CLOSE_USER].ob_spec.free_string, Tmp->ChatWindow->Title, CloseChannelAlertIrc, Tmp, Global, 1, Nickname ), MODWIN_CLOSE_USER );
				else	if( IsInNamesWindow( Tmp, Nickname, &Colour, Global ))
				{
					DeleteNames( IrcSession, Tmp->Name, Nickname, Global );
					sprintf( Output, "*** %s has left irc (%s)", Nickname, NextDD( &Msg[Pos] ) + 1 );
					OutputMessage( IrcSession, Tmp->Name, Output, COLOUR_MSG_SERVER, Global );
				}
				Tmp = Tmp->next;
			}
		}
	}
	else	if( !stricmp( Command, "PRIVMSG" ))
	{
		BYTE	Name[128], Nickname[128], Output[512];
		sscanf( Msg, ":%[^! ]", Nickname );
		sscanf( &Msg[Pos], "%s", Name );
		if( stricmp( IrcSession->Irc->Nickname, Nickname ) == 0 )
		{
			if( *( NextDD( &Msg[Pos] ) + 1 ) == 1 )
			{
				BYTE	P1[128];
				BYTE	Output[1024];
				sscanf( NextDD( &Msg[Pos] ) + 2, "%s", P1 );
				if( !stricmp( P1, "ACTION" ))
				{
					sprintf( Output, "* %s %s", Nickname, NextDD( &Msg[Pos] ) + 2 + strlen( "ACTION" ) + 1 );
					if( Output[strlen( Output ) - 2] == '\r' )
						Output[strlen( Output ) - 2] = '\0';
					if( Output[strlen( Output )-1] == 1 )
						Output[strlen( Output )-1] = 0 ;
					OutputMessage( IrcSession, Name, Output, COLOUR_ACTION, Global );
				}
				else
				{
					OutputMessage( IrcSession, Name, Output, COLOUR_MSG, Global );
				}
			}
			else
			{
				if( IrcFlags & APPEND_OWNNICK )
					sprintf( Output, "<%s> %s", Nickname, NextDD( &Msg[Pos] ) + 1 );
				else
					sprintf( Output, "> %s", NextDD( &Msg[Pos] ) + 1 );
				if( Output[strlen( Output ) - 2] == '\r' )
					Output[strlen( Output ) - 2] = '\0';
				OutputMessage( IrcSession, Name, Output, COLOUR_MSG_MYSELF, Global );
			}
		}
		else
		{
			if( stricmp( IrcSession->Irc->Nickname, Name ) == 0 )
			{
				if( *( NextDD( &Msg[Pos] ) + 1 ) == 1 )
				{
					BYTE	P1[128], P2[128], P3[128], P4[128], P5[128], P6[128];
					BYTE	Output[512], Puf[512];
					sscanf( NextDD( &Msg[Pos] ) + 2, "%s", P1 );
					if( strrchr( P1, 1 ))
						*strrchr( P1, 1 ) = 0;
					if( !stricmp( P1, "CLIENTINFO" ))
					{
						sprintf( Output, "*** CTCP CLIENTINFO %s", Nickname );
						OutputMessage( IrcSession, NULL, Output, COLOUR_MSG, Global );
						sprintf( Puf, "/CTCP %s CLIENTINFO :ACTION CLIENTINFO DCC ECHO FINGER PING TIME VERSION", Nickname );
						if( IrcSession->Irc->CtcpReply )
							SendMessage( IrcSession, GenerateMessage( Puf, NULL, IrcSession, Global ), Global );
					}
					else	if( !stricmp( P1, "ECHO" ))
					{
						BYTE	P0[1024];
						strcpy( P0, NextDD( &Msg[Pos] ) + strlen( P1 ) + 3 );
						if( strrchr( P0, 1 ))
							*strrchr( P0, 1 ) = 0;
						sprintf( Output, "*** CTCP ECHO %s: %s", Nickname, P0 );
						OutputMessage( IrcSession, NULL, Output, COLOUR_MSG, Global );
						sprintf( Puf, "/CTCP %s ECHO :%s", Nickname, P0 );
						if( IrcSession->Irc->CtcpReply )
							SendMessage( IrcSession, GenerateMessage( Puf, NULL, IrcSession, Global ), Global );
					}
					else	if( !stricmp( P1, "FINGER" ))
					{
						sprintf( Output, "*** CTCP FINGER %s", Nickname );
						OutputMessage( IrcSession, NULL, Output, COLOUR_MSG, Global );
						sprintf( Puf, "/CTCP %s FINGER : (%s@%s) Idle %li seconds", Nickname, IrcSession->Irc->Username, Hostname, (( LONG ) time( NULL )) - IrcSession->Time );
						if( IrcSession->Irc->CtcpReply )
							SendMessage( IrcSession, GenerateMessage( Puf, NULL, IrcSession, Global ), Global );
					}
					else	if( !stricmp( P1, "PING" ))
					{
						BYTE	P0[1024];
						strcpy( P0, NextDD( &Msg[Pos] ) + strlen( P1 ) + 3 );
						if( strrchr( P0, 1 ))
							*strrchr( P0, 1 ) = 0;
						sprintf( Output, "*** CTCP PING %s: %s", Nickname, P0 );
						OutputMessage( IrcSession, NULL, Output, COLOUR_MSG, Global );
						sprintf( Puf, "/CTCP %s PING :%s", Nickname, P0 );
						if( IrcSession->Irc->CtcpReply )
							SendMessage( IrcSession, GenerateMessage( Puf, NULL, IrcSession, Global ), Global );
					}
					else	if( !stricmp( P1, "TIME" ))
					{
						BYTE	Time[512];
						struct tm	*Tm;
						time_t	T;
						sprintf( Output, "*** CTCP TIME %s", Nickname );
						OutputMessage( IrcSession, NULL, Output, COLOUR_MSG, Global );
						time( &T );
						Tm = localtime( &T );
						strftime( Time, 512, "%a %b %d %H:%M:%S %Y", Tm );
						sprintf( Puf, "/CTCP %s TIME :%s", Nickname, Time );
						if( IrcSession->Irc->CtcpReply )
							SendMessage( IrcSession, GenerateMessage( Puf, NULL, IrcSession, Global ), Global );
					}
					else	if( !stricmp( P1, "VERSION" ))
					{
						sprintf( Output, "*** CTCP VERSION %s", Nickname );
						OutputMessage( IrcSession, NULL, Output, COLOUR_MSG, Global );
#ifdef	DRACONIS
						sprintf( Puf, "/CTCP %s VERSION :Chatter V%s (Draconis)", Nickname, VERSION );
#endif
#ifdef	ICONNECT
						sprintf( Puf, "/CTCP %s VERSION :Chatter V%s (IConnect)", Nickname, VERSION );
#endif
						if( IrcSession->Irc->CtcpReply )
							SendMessage( IrcSession, GenerateMessage( Puf, NULL, IrcSession, Global ), Global );
					}
					else	if( !stricmp( P1, "DCC" ))
					{
						*strchr( NextDD( &Msg[Pos] ) + 2, 1 ) = 0;
						sscanf( NextDD( &Msg[Pos] ) + 2, "%s %s %s %s %s %s", P1, P2, P3, P4, P5, P6 );
						if( !strcmp( P2, "CHAT" ))
						{
							sprintf( Output, "*** CTCP DCC CHAT %s", Name );
							OutputMessage( IrcSession, NULL, Output, COLOUR_MSG, Global );
							if( AskDccChatSession( IrcSession->Irc, Nickname, atoi( P5 ), atol( P4 ), Global ) != E_OK )
								MT_form_alert( 1, TreeAddr[ALERTS][MEMORY].ob_spec.free_string, Global );
						}
						if( !stricmp( P2, "SEND" ))
						{
							ULONG	l = 0;
							sprintf( Output, "*** CTCP DCC SEND %s", Name );
							OutputMessage( IrcSession, NULL, Output, COLOUR_MSG, Global );
							if( strlen( P6 ))
								l = ( ULONG ) atol( P6 );
							if( AskDccRx( IrcSession->Irc, Nickname, P3, ( UWORD ) atoi( P5 ), ( ULONG ) atol( P4 ), l, Global ) != E_OK )
								MT_form_alert( 1, TreeAddr[ALERTS][MEMORY].ob_spec.free_string, Global );
						}
					}
				}
				else
				{
					if( OpenIrcChannel( IrcSession, Nickname, Global ) != E_OK )
						MT_form_alert( 1, TreeAddr[ALERTS][MEMORY].ob_spec.free_string, Global );

					sprintf( Output, "<%s> %s", Nickname, NextDD( &Msg[Pos] ) + 1 );
					if( Cmp( IrcSession->Irc->Nickname, NextDD( &Msg[Pos] ) + 1 ))
					{
						OutputMessage( IrcSession, Nickname, Output, COLOUR_MSGWITHNICK, Global );
						if( IrcFlags & WINDOW_TOPWITHNICK )
						{
							IRC_CHANNEL	*IrcChannel = GetIrcChannel( IrcSession, Nickname );
							if( IrcChannel )
							{
								EVNT	lEvents;
								lEvents.mwhich = MU_MESAG;
								lEvents.msg[0] = WM_TOPPED;
								lEvents.msg[1] = Global[2];
								lEvents.msg[2] = 0;
								lEvents.msg[3] = IrcChannel->ChatWindow->WinId;
								HandleWindow( &lEvents, Global );
							}
						}
					}
					else
					{
						OutputMessage( IrcSession, Nickname, Output, COLOUR_MSG, Global );
						if( IrcFlags & WINDOW_TOPWITHNICK )
							if( Name[0] != '#' && Name[0] != '&' )
							{
								IRC_CHANNEL	*IrcChannel = GetIrcChannel( IrcSession, Nickname );
								if( IrcChannel )
								{
									EVNT	lEvents;
									lEvents.mwhich = MU_MESAG;
									lEvents.msg[0] = WM_TOPPED;
									lEvents.msg[1] = Global[2];
									lEvents.msg[2] = 0;
									lEvents.msg[3] = IrcChannel->ChatWindow->WinId;
									HandleWindow( &lEvents, Global );
								}
							}
					}
				}
/*				OutputMessage( IrcSession, NULL, Msg, -1, Global );	*/
			}
			else
			{
				sprintf( Output, "<%s> %s", Nickname, NextDD( &Msg[Pos] ) + 1 );
				if( Cmp( IrcSession->Irc->Nickname, NextDD( &Msg[Pos] ) + 1 ))
				{
					OutputMessage( IrcSession, Name, Output, COLOUR_MSGWITHNICK, Global );
					if( IrcFlags & WINDOW_TOPWITHNICK )
					{
						IRC_CHANNEL	*IrcChannel = GetIrcChannel( IrcSession, Name );
						if( IrcChannel )
						{
							EVNT	lEvents;
							lEvents.mwhich = MU_MESAG;
							lEvents.msg[0] = WM_TOPPED;
							lEvents.msg[1] = Global[2];
							lEvents.msg[2] = 0;
							lEvents.msg[3] = IrcChannel->ChatWindow->WinId;
							HandleWindow( &lEvents, Global );
						}
					}
				}
				else
				{
					if( *( NextDD( &Msg[Pos] ) + 1 ) == 1 )
					{
						BYTE	P1[128];
						sscanf( NextDD( &Msg[Pos] ) + 2, "%s", P1 );
						if( !stricmp( P1, "ACTION" ))
						{
							BYTE	Output[1024];
							sprintf( Output, "* %s %s", Nickname, NextDD( &Msg[Pos] ) + 2 + strlen( "ACTION" ) + 1 );
							if( Output[strlen( Output )-1] == 1 )
								Output[strlen( Output )-1] = 0 ;
							OutputMessage( IrcSession, Name, Output, COLOUR_ACTION, Global );
						}
						else
							OutputMessage( IrcSession, Name, Output, COLOUR_MSG, Global );

						if( IrcFlags & WINDOW_TOPWITHNICK )
							if( Name[0] != '#' && Name[0] != '&' )
							{
								IRC_CHANNEL	*IrcChannel = GetIrcChannel( IrcSession, Name );
								if( IrcChannel )
								{
									EVNT	lEvents;
									lEvents.mwhich = MU_MESAG;
									lEvents.msg[0] = WM_TOPPED;
									lEvents.msg[1] = Global[2];
									lEvents.msg[2] = 0;
									lEvents.msg[3] = IrcChannel->ChatWindow->WinId;
									HandleWindow( &lEvents, Global );
								}
							}
					}
					else
						OutputMessage( IrcSession, Name, Output, COLOUR_MSG, Global );
				}
			}
		}
	}
	else	if( !stricmp( Command, "TOPIC" ))
	{
		BYTE	Name[128], Nickname[128], Topic[512];
		IRC_CHANNEL	*IrcChannel = IrcSession->IrcChannel->next;
		sscanf( Msg, ":%[^! ]%*s%*s%s", Nickname, Name );
		strcpy( Topic, NextDD( &Msg[Pos] ) + 1 );
		if( Topic[strlen( Topic )-1] != '\n' )
		{
			if( stricmp( IrcSession->Irc->Nickname, Nickname ))
			{
				BYTE	Output[512];
				sprintf( Output, "*** %s has changed the topic on channel %s to ", Nickname, Name );
				strcat( Output, Topic );
				OutputMessage( IrcSession, Name, Output, COLOUR_MSG_SERVER, Global );
			}
			while( IrcChannel )
			{
				if( stricmp( IrcChannel->Name, Name ) == 0 )
				{
					SetInfoChatWindow( Topic, IrcChannel->ChatWindow, Global );
					break;
				}
				IrcChannel = IrcChannel->next;
			}
		}
	}
	else	if( !stricmp( Command, "WHOIS" ))
	{
	}
	else
		OutputMessage( IrcSession, NULL, Msg, -1, Global );
/*	OutputMessage( IrcSession, NULL, Msg, -1, Global );*/
}

/*-----------------------------------------------------------------------------*/
/* OutputMessage                                                               */
/*-----------------------------------------------------------------------------*/
static void	OutputMessage( IRC_SESSION *IrcSession, char *Name, char *Msg, int Colour, WORD Global[15] )
{
	IRC_CHANNEL	*Channel = NULL;
	if( Name )
		Channel = GetIrcChannel( IrcSession, Name );
	else
	{
		Channel = IrcSession->IrcChannel;
		if( IrcFlags & WINDOW_TOPWITHNICK )
		{
			EVNT	lEvents;
			lEvents.mwhich = MU_MESAG;
			lEvents.msg[0] = WM_TOPPED;
			lEvents.msg[1] = Global[2];
			lEvents.msg[2] = 0;
			lEvents.msg[3] = Channel->ChatWindow->WinId;
			HandleWindow( &lEvents, Global );
		}
	}
	if( Channel )
		AppendChatWindow( Msg, Colour, Channel->ChatWindow, Global );
}
static void	OutputNames( IRC_SESSION *IrcSession, int Flag, char *Name, char *Nickname, int Colour, WORD Global[15] )
{
	IRC_CHANNEL	*Channel = NULL;

	if( Name )
		Channel = GetIrcChannel( IrcSession, Name );
	if( Channel && Channel->ListWindow )
	{
		if( Flag )
		{
			NAMES_WINDOW *NamesWindow = Channel->ListWindow;
			DIALOG_DATA	*DialogData = NamesWindow->DialogData;
			if( !( DialogData->Tree[WNAMES_SWITCH].ob_state & SELECTED ))
			{
				BYTE	Puf[128];
				OpenNamesWindow( Channel, Global );
				sprintf( Puf, "/WHOIS %s", Nickname );
				strcat( Puf, "" );
				SendMessage( IrcSession, GenerateMessage( Puf, Channel->Name, IrcSession, Global ), Global );
			}
		}
		NamesWindowAppend( Channel, 0, Nickname, NULL, NULL, NULL, NULL, NULL, NULL, Colour, Global );
	}
}
static void OutputInfoNames( IRC_SESSION *IrcSession, char *Name, char *Username, char *Realname, char *Channels, char *Server, char *Host, char *Idle, WORD Global[15] )
{
	IRC_CHANNEL	*Channel = IrcSession->IrcChannel->next;
	while( Channel )
	{
		NamesWindowAppend( Channel, 1, Name, Username, Realname, Channels, Server, Host, Idle, -1, Global );
		Channel = Channel->next;
	}
}
static void	DeleteNames( IRC_SESSION *IrcSession, char *Name, char *Nickname, WORD Global[15] )
{
	IRC_CHANNEL	*IrcChannel;
	
	if(( IrcChannel = GetIrcChannel( IrcSession, Name )) != NULL )
		NamesWindowDelete( IrcChannel, Nickname, Global );
}

/*-----------------------------------------------------------------------------*/
/* SendMessage                                                                 */
/*-----------------------------------------------------------------------------*/
void SendMessage( IRC_SESSION *IrcSession, BYTE *Message, WORD Global[15] )
{
	if( Message )
	{
		WORD	Msg[8];
		LONG	Len = strlen( Message );
		BYTE	*Tmp = strdup( Message );
		Msg[0] = TCP_CMD;
		Msg[1] = Global[2];
		Msg[2] = 0;
		Msg[3] = IrcSession->IrcChannel->ChatWindow->WinId;
		Msg[4] = TCP_out;
		Keytab->ExportString( KeytabAnsiExport, Len, Message );
		*( BYTE ** )&( Msg[5] ) = Message;
		Msg[7] = ( WORD ) Len;
		TcpMessageTime( Msg, &( IrcSession->TcpMsgPuf ), IrcSession->TcpAppId, Global );
		if( Tmp )
		{
			ParseMessage( IrcSession, Tmp, Global );
			free( Tmp );
			RedrawIrcSession( IrcSession, Global );
		}
	}
}

void	OpenAlertIrc( IRC_SESSION *IrcSession, IRC_CHANNEL *IrcChannel, WORD WinId, WORD Type )
{
	if( WinId > 0 )
	{
		MOD_WIN	**ModWin, *New, *Last = NULL;
		if( IrcChannel )
			ModWin = &( IrcChannel->ModWin );
		else
			ModWin = &( IrcSession->ModWin );
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
static WORD CloseAlert( MOD_WIN **ModWin, WORD WinId )
{
	MOD_WIN	*Del = *ModWin;
	WORD	Type;
	while( Del )
	{
		if( Del->WinId == WinId )
			break;
		Del = Del->next;
	}
	if( !Del )
		return( ERROR );

	if( Del->next )
		( Del->next )->prev = Del->prev;
	if( Del->prev )
		( Del->prev )->next = Del->next;
	else
		*ModWin = Del->next;
	Type = Del->Type;
	free( Del );
	return( Type );
}
void CloseSessionAlertIrc( void *IrcSession, WORD Button, WORD WinId, WORD Global[15] )
{
	WORD	Type = CloseAlert( &((( IRC_SESSION * ) IrcSession )->ModWin ), WinId );
	switch( Type )
	{
		case	MODWIN_CLOSE_SESSION:
		{
			if( Button == 1 )
			{
/*				EVNT	lEvents;
				lEvents.mwhich = MU_MESAG;
				lEvents.msg[0] = WM_CLOSED;
				lEvents.msg[1] = Global[2];
				lEvents.msg[2] = 0;
				lEvents.msg[3] = (( IRC_SESSION * ) IrcSession )->IrcChannel->ChatWindow->WinId;
				lEvents.msg[4] = WIN_CLOSE_WITHOUT_DEMAND;
				HandleWindow( &lEvents, Global );	*/
				BYTE	Puf[512];
				sprintf( Puf, "/QUIT" );
				strcat( Puf, "" );
				SendMessage( IrcSession, GenerateMessage( Puf, (( IRC_SESSION * ) IrcSession )->IrcChannel->Name, ( IRC_SESSION * ) IrcSession, Global ), Global );
			}
			break;
		}
		case	MODWIN_CONNECTION_CLOSED:
		{
			if(((( IRC_SESSION * ) IrcSession )->IrcChannel ) && ((( IRC_SESSION * ) IrcSession )->IrcChannel->ChatWindow ))
				CloseIrcSessionWindow( IrcSession, Global );
			break;
		}
		case	MODWIN_CHANNEL:
		{
			IRC_CHANNEL	*IrcChannel = (( IRC_SESSION * ) IrcSession )->IrcChannel;
			CHANNEL_WINDOW	*ChannelWindow = ( CHANNEL_WINDOW * ) IrcChannel->ListWindow;
			ChannelWindow->ModWinId = 0;
			break;
		}
	}
}
void CloseChannelAlertIrc( void *IrcChannel, WORD Button, WORD WinId, WORD Global[15] )
{
	WORD	Type = CloseAlert( &((( IRC_CHANNEL * ) IrcChannel )->ModWin ), WinId );
	switch( Type )
	{
		case	MODWIN_CLOSE_USER:
		{
			EVNT	lEvents;
			lEvents.mwhich = MU_MESAG;
			lEvents.msg[0] = WM_CLOSED;
			lEvents.msg[1] = Global[2];
			lEvents.msg[2] = 0;
			lEvents.msg[3] = (( IRC_CHANNEL * ) IrcChannel )->ChatWindow->WinId;
			lEvents.msg[4] = WIN_CLOSE_WITHOUT_DEMAND;
			HandleWindow( &lEvents, Global );
			break;
		}
	}
}

static WORD	Cmp( BYTE *S1, BYTE *S2 )
{
	BYTE	Str[1024], Orig[1024];
	WORD	i, j;
	WORD	Max = 0, t;
	strlwr( strcpy( Str, S1 ));
	strlwr( strcpy( Orig, S2 ));
	for( i = 0; i <= abs( (WORD)(strlen( Orig ) - strlen( Str )) ); i++ )
	{
		t = 0;
		for( j = 0; j < strlen( Str ); j++ )
		{
			if( Str[j] == Orig[i+j] )
				t++;
		}
		if( t > Max )
			Max = t;
		if( Max == strlen( Str ))
			break;
	}
	if( Max > strlen( Str ) * 3 / 4 )
		return( 1 );
	else
		return( 0 );
}
