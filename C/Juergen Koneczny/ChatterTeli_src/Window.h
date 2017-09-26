#ifndef	__WIN__
#define	__WIN__

#define	WIN_WDIALOG				0x0000
#define	WIN_ALERT_WINDOW		0x0001
#define	WIN_WDIALOG_OPTIONS	0x0002
#define	WIN_TEXT_WINDOW		0x0003

#define	WIN_CHAT_IRC_CONSOLE	0x0004
#define	WIN_CHAT_IRC_CHANNEL	0x0005
#define	WIN_CHAT_IRC_USER		0x0006
#define	WIN_CHAT_DCC			0x0007
#define	WIN_CHANNEL_IRC		0x0008
#define	WIN_NAMES_IRC			0x0009
#define	WIN_DATA_DCC			0x000a
#define	WIN_UPDATE  			0x000b

#define	WIN_MAX_TYPES		0x000c

#define	WIN_INIT			0x0000
#define	WIN_CLOSE		0x0001
#define	WIN_DEL			0x0002
#define	WIN_KEY			0x0003
#define	WIN_DRAGDROP	0x0004
#define	WIN_FONT			0x0005
#define	WIN_COPY			0x0006
#define	WIN_CUT			0x0007
#define	WIN_PASTE		0x0008
#define	WIN_MARK_ALL	0x0009
#define	WIN_HELP			0x000a
#define	WIN_KONTEXT_1	0x000b
#define	WIN_KONTEXT_2	0x000c

#define	WIN_USER_LOW	0x0bcd
#define	WIN_USER_HIGH	0x0bff
#define	WIN_USER			WIN_USER_LOW

#define	WIN_CMD			( WIN_USER )
#define	WIN_ACK			( WIN_USER + 1 )
#define	ICONNECT_CMD	( WIN_USER + 2 )
#define	ICONNECT_ACK	( WIN_USER + 3 )
#define	TCP_CMD			( WIN_USER + 4 )
#define	TCP_ACK    		( WIN_USER + 5 )
#ifdef	TELNET_CLIENT
#define	WTEXT_CMD		( WIN_USER + 6 )
#define	RX					( WIN_USER + 7 )
#define	TX					( WIN_USER + 8 )
#endif

#define	WIN_CLOSE_WITHOUT_DEMAND	1

/*#define	TELNET_OPT		( WIN_USER + 6 )*/



typedef	struct
{
	ULONG	format;
	WORD	mx;
	WORD	my;
	WORD	kstate;
	void	*puf;
	LONG	size;
}	DD_INFO;

typedef	WORD	( *HNDL_WINDOW )( WORD WinId, EVNT *Events, void *UserData, WORD Global[15] );
typedef	void	( *DRAW_WINDOW )( WORD WinId, GRECT *DrawRect, GRECT *WorkRect );
typedef	ULONG	( *MENU_WINDOW )( WORD WinId, WORD Global[15] );


WORD	HandleWindow( EVNT *Events, WORD Global[15] );

ULONG	GetKontextWindow( WORD WinId, WORD Global[15] );
HNDL_WINDOW GetHandleWindow( WORD WinId );
MENU_WINDOW GetMenuWindow( WORD WinId );

WORD	RcInterSect( GRECT *p1, GRECT *p2 );
WORD	DrawIconifiedWindow( WORD WinId, GRECT *RedrawRect, GRECT *WorkRect, OBJECT *Tree, WORD Global[15] );
void	ScrollWindow( WORD WinId, WORD VdiHandle, WORD Dx, WORD Dy, GRECT *Work, DRAW_WINDOW DrawWindow, WORD Global[15] );

WORD	NewWindow( WORD WinId, WORD Type, HNDL_WINDOW HndlWindow, MENU_WINDOW MenuWindow, void *WindowData );
void	DelWindow( WORD WinId );
WORD	GetFirstWindow( void );
WORD	GetNextWindow( WORD WinId );
void 	*GetWindowData( WORD WinId );
WORD	GetTypeWindow( WORD WinId );

void	IconifyWindow( WORD WinId );
void	AllIconifyWindow( WORD WinId, GRECT *CurrRect );
void	UnIconifyWindow( WORD WinId );
void	UnAllIconifyWindow( WORD WinId, GRECT *CurrRect );

WORD	isWindow( WORD WinId );
WORD	isOpenWindow( WORD WinId );
WORD	isIconifiedWindow( WORD WinId );
WORD	isAllIconifiedWindow( WORD WinId );

void	SetPosWindow( WORD WinId, GRECT *Pos );
void	SetPosWindowFirst( WORD WinId, GRECT *Pos );
void	GetPosWindow( WORD WinId, GRECT *Pos );
void	GetPosWindowByType( WORD Type, GRECT *Pos );

WORD	GetInitPosWindow( WORD Type, WORD n, GRECT *Pos );
void	SetInitPosWindow( WORD Type, GRECT *Pos );

#define	FONT_CHANGED	0x7a18
#define	COLOR_ID			0xC010

#endif