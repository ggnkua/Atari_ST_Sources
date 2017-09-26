#ifndef	__IRC__
#define	__IRC__

#define	WINDOW_INTELLIGENT	0x0001
#define	WINDOW_TOPLEFT			0x0002
#define	WINDOW_ONLY				0x0004
#define	WINDOW_TOPWITHNICK	0x0008
#define	WINDOW_OVERWRITE		0x0010
#define	APPEND_OWNNICK			0x0020
#define	AUTO_CHANNEL			0x0040
#define	AUTO_NAMES				0x0080
#define	APPEND_LOG				0x0100
#define	USE_SMICONS				0x0200

#define	COLOUR_MAX				17
#define	COLOUR_INPUT			0
#define	COLOUR_INPUT_BACK		1
#define	COLOUR_MSG				2
#define	COLOUR_MSG_MYSELF		3
#define	COLOUR_MSG_OP			4
#define	COLOUR_MSG_SERVER		5
#define	COLOUR_MSG_BACK		6
#define	COLOUR_USER				7
#define	COLOUR_USER_OP			8
#define	COLOUR_USER_IRCOP		9
#define	COLOUR_USER_BACK		10
#define	COLOUR_CHANNEL			11
#define	COLOUR_CHANNEL_BACK	12
#define	COLOUR_MSG_AWAY		13
#define	COLOUR_USER_VOICE		14
#define	COLOUR_MSGWITHNICK	15
#define	COLOUR_ACTION     	16

typedef	struct
{
	BYTE	*Host;
	UWORD	Port;
	BYTE	*Nickname;
	BYTE	*Username;
	BYTE	*Password;
	BYTE	*Realname;
	BYTE	*Autojoin;

	WORD	InputFontId;
	WORD	InputFontHt;
	WORD	OutputFontId;
	WORD	OutputFontHt;
	WORD	ChannelFontId;
	WORD	ChannelFontHt;
	WORD	UserFontId;
	WORD	UserFontHt;

	LONG	nLines;
	WORD	PingPong;
	WORD	CtcpReply;
	WORD	LogFlag;

	WORD	ColourTable[COLOUR_MAX];
}	IRC;

WORD	OpenIrc( IRC *Irc, WORD Global[15] );
IRC	*CopyIrc( IRC *Irc );
void	FreeIrc( IRC *Irc );
void	FreeContentIrc( IRC *Irc );

void	ReadColourTable( double Version, BYTE *Puf, WORD ColourTable[] );

#endif