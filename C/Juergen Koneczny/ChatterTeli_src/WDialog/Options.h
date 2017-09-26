#ifdef	IRC_CLIENT
#define	OPT_COLORS			0x0000
#define	OPT_SESSION			0x0001
#define	OPT_OTHER			0x0002
#define	OPT_FONTS			0x0003
#endif

#ifdef	TELNET_CLIENT
#define	OPT_VIEW			0x0000
#define	OPT_TELNET		0x0001
#define	OPT_TERMINAL	0x0002
#define	OPT_OTHER		0x0003
#endif

#define	OPT_NO_ALL		0x0000
#define	OPT_NO_HOST		0x0001
#define	OPT_NO_PORT		0x0002
#ifdef	IRC_CLIENT
#define	OPT_NO_PASSWORD	0x0008

#define	OPT_NN_NICKNAME	0x0100
#define	OPT_NN_USERNAME	0x0100
#define	OPT_NN_REALNAME	0x0200
#endif

typedef	struct
{
	WORD		Kat;
	WORD		Edit;
	OBJECT	*DialogTree;
	OBJECT	*Tree;
	WORD		TreeIdx;
	WORD		Obj;
	WORD		Button;
	WORD		No;
#ifdef	IRC_CLIENT
	WORD	InputFontId;
	WORD	InputFontHt;
	WORD	OutputFontId;
	WORD	OutputFontHt;
	WORD	ChannelFontId;
	WORD	ChannelFontHt;
	WORD	UserFontId;
	WORD	UserFontHt;
#endif
#ifdef	TELNET_CLIENT
	WORD		FontId;
	WORD		FontEffects;
	LONG		FontPt;
#endif
#ifdef	TELNET_CLIENT
	EMU_TYPE	EmuType;
	WORD		KeyExport;
	WORD		KeyImport;
	WORD		KeyFlag;
#endif
#ifdef	TELNET_CLIENT
	USERBLK	FontColorUserBlk;
	USERBLK	WindowColorUserBlk;	
#endif
}	OPT_DATA;

#ifdef	IRC_CLIENT
OBJECT	*CreateOptions( OPT_DATA *OptData, WORD No, IRC *Irc );
void	GetOptions( OPT_DATA *OptData, IRC *Irc );
void	NewOptions( DIALOG *Dialog, OPT_DATA *OptData, IRC *Irc, WORD Global[15] );
#endif
#ifdef	TELNET_CLIENT
OBJECT	*CreateOptions( OPT_DATA *OptData, WORD No, TELNET *Telnet );
void	GetOptions( OPT_DATA *OptData, TELNET *Telnet );
void	NewOptions( DIALOG *Dialog, OPT_DATA *OptData, TELNET *Telnet, WORD Global[15] );
#endif
void	DelOptions( OPT_DATA *OptData );
WORD	HandleOptions( DIALOG *Dialog, OPT_DATA *OptData, WORD Obj, EVNT *Events, WORD Data, WORD Global[15] );
WORD	HandleDdOptions( DIALOG *Dialog, OPT_DATA *OptData, EVNT *Events, WORD Global[15] );
WORD	HandleMesagOptions( DIALOG *Dialog, OPT_DATA *OptData, EVNT *Events, WORD Global[15] );
WORD	HandleHelpOptions( DIALOG *Dialog, OPT_DATA *OptData, EVNT *Events, WORD Global[15] ); 
void	ChangeFontOptions( DIALOG *Dialog, OPT_DATA *OptData, WORD FontId, LONG FontPt, WORD FontColor, WORD Global[15] );
