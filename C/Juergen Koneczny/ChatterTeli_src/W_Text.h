#ifndef	__W_TEXT__
#define	__W_TEXT__

#include	<VDICOL.H>
#include	"Emulator.h"

#define	MODWIN_NORMAL					0x0000
#define	MODWIN_CLOSE_SESSION			0x0001
#define	MODWIN_CONNECTION_CLOSED	0x0002

typedef	WORD ( *HNDL_USER_TEXT_WINDOW )( WORD WinId, EVNT *Events, void *UserData, WORD Global[15] );

#ifndef	_XY_
#define	_XY_
	typedef	struct
	{
		long	x;
		long	y;
	}	XY;
#endif
typedef	struct	__mod_win__
{
	struct __mod_win__	*next;
	struct __mod_win__	*prev;
	WORD	WinId;
	WORD	Type;
}	MOD_WIN;
/*-----------------------------------------------------------------------------*/
/* Strukturdefinitionen                                                        */
/*-----------------------------------------------------------------------------*/
typedef	struct	__text_window__
{
	WORD	VdiHandle;
	int16	BmHandle;
	MFDB	Bitmap;
	GCBITMAP	GcBitmap;

	WORD	isFirst;

	WORD	KeyExport;
	WORD	KeyImport;
	WORD	KeyFlag;

	XY		Terminal;

	XY		Pos;

	XY		Cursor;
	WORD	CursorFlag;	

	XY		BlockStart;
	XY		BlockEnd;

	BYTE	*Title;
	BYTE	*Info;

	GRECT	WorkRect;
	GRECT	FullRect;
	GRECT	NextFuller;
	WORD	CellWidth;
	WORD	CellHeight;
	WORD	dBasicLine;

	WORD	FontId;
	LONG	FontPt;
	WORD	FontColor;
	WORD	FontEffects;
	WORD	WindowColor;
	WORD	Invers;

	LONG	PufLines;
	LONG	nCharMax;
	LONG	nLine;

	EMU_DATA	*EmuData;
	HNDL_USER_TEXT_WINDOW	HandleUserTextWindow;
	void		*UserData;

	WORD		WinId;
	WORD		CloseId;
	MOD_WIN	*ModWin;
} TEXT_WINDOW;

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/

WORD	OpenTextWindow( EMU_TYPE EmuType, WORD KeyFlag, WORD KeyExport, WORD KeyImport, LONG PufLines, XY *Terminal, XY *Tab, WORD FontId, LONG FontPt, WORD FontColor, WORD FontEffects, WORD WindowColor, HNDL_USER_TEXT_WINDOW HandleUserTextWindow, BYTE *Title, void *UserData, WORD Global[15] );
void	CloseTextWindow( WORD WinId, WORD Global[15] );
void	DrawTextWindow( WORD WinId, GRECT *DrawRect, GRECT *WorkRect );
void	AdjustTextWindow( WORD WinId, TEXT_WINDOW *TextWindow, WORD Global[15] );
void	SetVSliderTextWindow( WORD WinId, TEXT_WINDOW *TextWindow, WORD Global[15] );
void	SetHSliderTextWindow( WORD WinId, TEXT_WINDOW *TextWindow, WORD Global[15] );
void	GetFontInfo( WORD VdiHandle, WORD *CellHeight, WORD *dBasicLine, WORD *CellWidth );
WORD	AppendCharTextWindow( WORD WinId, BYTE Char, WORD Global[15] );
LONG	AppendBlockTextWindow( WORD WinId, BYTE *TextBlock, LONG Len, WORD Global[15] );
ULONG	MenuKontextTextWindow( WORD WinId, WORD Global[15] );
void	BlockTextWindow( WORD WinId, XY *Start, XY *End, TEXT_WINDOW	*TextWindow );
BYTE	*GetBlockTextWindow( TEXT_WINDOW	*TextWindow );
void	SetInfoTextWindow( WORD WinId, BYTE *Info, WORD Global[15] );
void	GetMaxTextWindow( WORD WinId, TEXT_WINDOW *TextWindow, GRECT *Rect, WORD Global[15] );
WORD	NewBitmapTextWindow( WORD WinId, TEXT_WINDOW *TextWindow );
WORD	KontextTextWindow( WORD WinId, TEXT_WINDOW *TextWindow, WORD Global[15] );

void	ChangeColorTextWindow( WORD WinId, WORD FontColor, WORD WindowColor, WORD Global[15] );
void	ChangeFontTextWindow( WORD WinId, WORD FontId, LONG FontPt, WORD FontColor, WORD WindowColor, WORD Global[15] );

void	ChangeEmuTextWindow( WORD WinId, EMU_TYPE EmuType );
void	ChangeKeyExportTextWindow( WORD WinId, WORD KeyExport );
void	ChangeKeyImportTextWindow( WORD WinId, WORD KeyImport );
void	ChangeKeyFlagTextWindow( WORD WinId, WORD KeyFlag );
void	ChangePufLinesTextWindow( WORD WinId, LONG PufLines, WORD Global[15] );
void	ChangeTabTextWindow( WORD WinId, XY *Tab );
void	ChangeTerminalTextWindow( WORD WinId, XY *Terminal, WORD Global[15] );

void	OpenAlertTelnet( TEXT_WINDOW *TextWindow, WORD WinId, WORD Type );
void	CloseAlertTelnet( void *TextWindow, WORD Button, WORD WinId, WORD Global[15] );
#endif