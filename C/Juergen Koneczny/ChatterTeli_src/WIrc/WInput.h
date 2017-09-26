WORD	NiuDialog( IRC_SESSION *IrcSession, BYTE *Nickname, WORD Global[15] );
WORD	NnDialog( IRC_SESSION *IrcSession, WORD Global[15] );

#define	OPDIALOG_OP				0x0000
#define	OPDIALOG_DEOP			0x0001
#define	OPDIALOG_VOICE			0x0002
#define	OPDIALOG_DEVOICE		0x0003
WORD	OpDialog( IRC_CHANNEL *IrcChannel, WORD Flag, WORD Global[15] );

#define	KICKDIALOG_KICK		0x0000
#define	KICKDIALOG_BAN			0x0001
#define	KICKDIALOG_DEBAN		0x0002
#define	KICKDIALOG_BANKICK	0x0003
WORD	KickDialog( IRC_CHANNEL *IrcChannel, WORD Flag, BYTE *Nickname, WORD Global[15] );

WORD	TopicDialog( IRC_CHANNEL *IrcChannel, WORD Global[15] );
WORD	InviteDialog( IRC_CHANNEL *IrcChannel, BYTE *Nick, WORD Global[15] );

WORD	CModeDialog( IRC_CHANNEL *IrcChannel, WORD Global[15] );

WORD	UModeDialog( IRC_SESSION *IrcSession, WORD Global[15] );
WORD	AwayDialog( IRC_SESSION *IrcSession, WORD Global[15] );

WORD	InivtedDialog( IRC_SESSION *IrcSession, BYTE *Nick, BYTE *Channel, WORD Global[15] );

#define	MSGDIALOG_CHAT		0x0000
#define	MSGDIALOG_DCCCHAT	0x0001
WORD	MsgDialog( IRC_CHANNEL *IrcChannel, WORD Flag, WORD Global[15] );

WORD	InfoDialog( CHAT_WINDOW *ChatWindow, WORD Global[15] );

WORD	CtcpDialog( IRC_CHANNEL *IrcChannel, BYTE *Nickname, WORD Global[15] );


WORD	HndlCheckDialogWIrc( void *DialogData, EVNT *Events, WORD Global[15] );
WORD	OpenAlertDialog( IRC_SESSION *IrcSession, WORD Global[15] );
