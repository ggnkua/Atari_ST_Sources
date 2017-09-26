#ifndef	_IRC_FUNC_
#define	_IRC_FUNC_

#include	"Irc.h"
#include	"WDialog.h"
#include	"WIrc\Func.h"
#include	"WIrc\WChat.h"

#define	MODWIN_NORMAL					0x0000
#define	MODWIN_CLOSE_SESSION			0x0001
#define	MODWIN_CONNECTION_CLOSED	0x0002
#define	MODWIN_CHANNEL					0x0003
#define	MODWIN_CLOSE_USER				0x0004

/*-----------------------------------------------------------------------------*/
/* Strukturen                                                                  */
/*-----------------------------------------------------------------------------*/
typedef	struct	__irc_channel__
{
	BYTE			*Name;
	CHAT_WINDOW	*ChatWindow;
	void			*ListWindow;
	void			*IrcSession;
	struct __irc_channel__	*next;
	struct __irc_channel__	*prev;
	MOD_WIN		*ModWin;
	WORD			ChannelFlag;
	LONG			ChannelLimit;
}	IRC_CHANNEL;

#define	MODE_NONE		0x0000
#define	MODE_OP			0x0001

#define	MODE_PRIVATE	0x0100
#define	MODE_SECRET		0x0100
#define	MODE_INVITE		0x0200
#define	MODE_TOPIC		0x0400
#define	MODE_MESSAGE	0x0800
#define	MODE_MODERATED	0x1000
#define	MODE_LIMIT		0x2000

typedef	struct
{
	WORD			WinId;
	WORD			AppId;
	WORD			ThreadFlag;
	WORD			UpdateFlag;
	GRECT			NextFuller;
	BYTE			*Title;
	BYTE			*Info;
	IRC_CHANNEL	*IrcChannel;
	DIALOG_DATA	*DialogData;
	WORD			ModWinId;
}	CHANNEL_WINDOW;

typedef	struct
{
	WORD			WinId;
	GRECT			NextFuller;
	BYTE			*Title;
	BYTE			Info[80];
	IRC_CHANNEL	*IrcChannel;
	DIALOG_DATA	*DialogData;
}	NAMES_WINDOW;

typedef struct
{
	IRC_CHANNEL	*IrcChannel;
	
	IRC			*Irc;
	WORD			TcpAppId;

	MOD_WIN		*ModWin;
	
	BYTE	*Msg;
	LONG	MsgLen;
	FILE	*TmpFile;
	LONG	Counter;
	void	*TcpMsgPuf;
	
	WORD	SessionFlag;
	BYTE	*Away;
	
	LONG	Time;

}	IRC_SESSION;

#define	MODE_INVISIBLE	0x0100
#define	MODE_NOTICE		0x0200
#define	MODE_WALLOPS	0x0400
#define	MODE_CLOSE		0x8000

WORD OpenIrcSession( IRC *Irc, WORD Global[15] );
WORD OpenIrcChannel( IRC_SESSION *IrcSession, BYTE *Name, WORD Global[15] );

void CloseIrcChannel( IRC_CHANNEL *IrcChannel );
void CloseIrcSession( IRC_SESSION *IrcSession );
void CloseIrcChannelWindow( IRC_CHANNEL *IrcChannel, WORD Global[15] );
void CloseIrcSessionWindow( IRC_SESSION *IrcSession, WORD Global[15] );

void SendMessage( IRC_SESSION *IrcSession, BYTE *Msg, WORD Global[15] );
char * GenerateMessage( char *Message, char *Channel, IRC_SESSION *IrcSession, WORD Global[15] );
void ParseInputIrcChat( IRC_SESSION *IrcSession, WORD Global[15] );

char * ConnectionRegistration( IRC *Irc );

void OpenAlertIrc( IRC_SESSION *IrcSession, IRC_CHANNEL *IrcChannel, WORD WinId, WORD Type );
void CloseSessionAlertIrc( void *IrcSession, WORD Button, WORD WinId, WORD Global[15] );	
void CloseChannelAlertIrc( void *IrcChannel, WORD Button, WORD WinId, WORD Global[15] );

#endif