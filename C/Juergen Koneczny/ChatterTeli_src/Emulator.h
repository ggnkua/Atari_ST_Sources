#ifndef	__EMULATOR__
#define	__EMULATOR__

#define	EMU_NUL	0
#define	EMU_BELL	'\a'
#define	EMU_BS	'\b'
#define	EMU_HT	'\t'
#define	EMU_LF	'\n'
#define	EMU_CR	'\r'
#define	EMU_VT	'\v'
#define	EMU_FF	'\f'

#define	KEYPAD_APPLICATION	0x0001
#define	CURSOR_APPLICATION	0x0002

#define	EMUFLAG_NON		0x00000000L
#define	EMUFLAG_WRAP	0x00000001L
#define	EMUFLAG_C_ON	0x00000002L

#define	EMU_BOLD					0x0001
#define	EMU_LIGHT				0x0002
#define	EMU_ITALIC				0x0003
#define	EMU_LINE					0x0004

#define	EMU_DARK					0x0007
#define	EMU_FLASH				0x0008
#define	EMU_FLASHFLASH			0x0009

#define	EMU_REVERSE				0x0010
#define	EMU_FOREGROUND_COLOR	0x0011
#define	EMU_BACKGROUND_COLOR	0x0012


/*-----------------------------------------------------------------------------*/
/* Strukturdefinitionen                                                        */
/*-----------------------------------------------------------------------------*/
typedef	enum { NVT, VT52, VT100, VT102, DUMP, }	EMU_TYPE;

typedef struct
{
	long	Len;
	char	*Seq;
} CTRL_SEQ;

typedef struct
{
	int	A;
	int	P;
}	ATTR;

typedef struct _attritem_
{
	struct _attritem_	*next;
	struct _attritem_	*prev;
	ATTR	Attr;
} ATTR_ITEM;

typedef struct _char_
{
	struct _char_	*next;
	struct _char_	*prev;
	ATTR_ITEM	*Attribut;
	char	C[2];
}	CHAR;

typedef struct	_line_
{
	struct _line_	*next;
	struct _line_	*prev;
	long		Len;
	CHAR	*Char;
}	TEXTLINE;

#ifndef	_XY_
	#define	_XY_
	typedef	struct
	{
		long	x;
		long	y;
	}	XY;
#endif

typedef struct	_xy_item_
{
	struct _xy_item_	*next;
	struct _xy_item_	*prev;
	XY	Start;
	XY	End;
}	XY_ITEM;

typedef	struct
{
	TEXTLINE	*Line;
	int		KeyImport;
	int		Key;
	long		PufLines;
	long		nLine;
	XY			Cursor;
	XY			MCursor;
	ATTR_ITEM	*MAttribut;
	int		ScrollFlag;
	XY			Scroll;	/* Zeile x bis Zeile y */
	int		CursorFlag;
	int		Invers;
	XY			Terminal;
	XY			Tab;
	XY_ITEM	*RedrawXy;
	ATTR_ITEM	*Attribut;
	CTRL_SEQ		*CtrlSeq;
	long		EmuFlag;
	void		*EmuFunc;
}	EMU_DATA;


/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
EMU_DATA	*EMU_InitData( EMU_TYPE EmuType, int KeyImport, int Key, XY *Terminal, XY *Tab, long PufLines );
void		EMU_Del( EMU_DATA *EmuData );
CHAR		*EMU_GetChar( long x, long y, EMU_DATA *EmuData );
int		EMU_GetCursor( XY *Cursor, EMU_DATA *EmuData );
long		EMU_GetNCharMax( EMU_DATA *EmuData );
long		EMU_GetNLine( EMU_DATA *EmuData );
long		EMU_GetNCharLine( long n, EMU_DATA *EmuData );
CTRL_SEQ	*EMU_GetCtrl( int Key, EMU_DATA *EmuData );
long		EMU_AppendText( char *Text, long Len, XY_ITEM **RedrawXy, int *Invers, EMU_DATA *EmuData );

void		EMU_ChangeEmu( EMU_DATA *EmuData, EMU_TYPE EmuType );
void		EMU_ChangeKeyImport( EMU_DATA *EmuData, int KeyImport );
void		EMU_ChangeKey( EMU_DATA *EmuData, int Key );
void		EMU_ChangePufLines( EMU_DATA *EmuData, long PufLines, long *nLine, XY *Cursor );
void		EMU_ChangeTab( EMU_DATA *EmuData, XY *Tab );
void		EMU_ChangeTerminal( EMU_DATA *EmuData, XY *Terminal, long *nLine, XY *Cursor );

#endif