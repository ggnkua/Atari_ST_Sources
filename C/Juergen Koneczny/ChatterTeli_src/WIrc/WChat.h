#ifndef	_CHAT_WINDOW_
#define	_CHAT_WINDOW_

#include	"WDialog.h"

typedef	WORD	cdecl ( *SEND_CHAT_WINDOW )( BYTE *Puf, void *UserData, WORD Global[15] );
typedef	void	( *SETBUTTON_CHAT_WINDOW )( void *UserData, WORD Global[15] );
typedef	void	( *DOUBLECLICK_CHAT_WINDOW )( BYTE *Puf, EVNT *Events, void *UserData, WORD Global[15] );
typedef	WORD	cdecl ( *BUTTON_CHAT_WINDOW )( WORD Obj, void *UserData, WORD Global[15] );
typedef	WORD	cdecl ( *MESSAGE_CHAT_WINDOW )( EVNT *Events, void *UserData, WORD Global[15] );
typedef	WORD	( *TIMER_CHAT_WINDOW )( void *UserData, WORD Global[15] );
typedef	WORD	( *CHECK_CHAT_WINDOW )( EVNT *Events, void *UserData, WORD Global[15] );
typedef	WORD	( *CLOSED_CHAT_WINDOW )( void *UserData, WORD Global[15] );

typedef	struct
{
	WORD			WinId;
	GRECT			NextFuller;
	BYTE			*Title;
	BYTE			*Info;
	XEDITINFO	*XEdit;
	DIALOG_DATA	*DialogData;
	void			*UserData;
	FILE			*LogFile;

	SEND_CHAT_WINDOW			SendChatWindow;
	SETBUTTON_CHAT_WINDOW	SetButtonChatWindow;
	DOUBLECLICK_CHAT_WINDOW	DoubleClickChatWindow;
	BUTTON_CHAT_WINDOW		ButtonChatWindow;
	MESSAGE_CHAT_WINDOW		MessageChatWindow;
	TIMER_CHAT_WINDOW			TimerChatWindow;
	CHECK_CHAT_WINDOW			CheckChatWindow;
	CLOSED_CHAT_WINDOW		ClosedChatWindow;
}	CHAT_WINDOW;

WORD	OpenChatWindow( BYTE *Dirname, BYTE *Filename, WORD Type, LONG nLines, WORD OutputFontId, WORD OutputFontHt, WORD InputFontId, WORD InputFontHt, WORD ColourTable[], WORD OverWrite, WORD LogFlag, CHAT_WINDOW *ChatWindow, WORD Global[15] );
FILE *OpenLog( BYTE *Dirname, BYTE *Filename );
void	CloseLog( FILE *Handle );

void	SetInfoChatWindow( BYTE *Str, CHAT_WINDOW *ChatWindow, WORD Global[15] );
void	SetTitleChatWindow( BYTE *Str, CHAT_WINDOW *ChatWindow, WORD Global[15] );
WORD	AppendChatWindow( BYTE *Msg, WORD Colour, CHAT_WINDOW *ChatWindow, WORD Global[15] );
void	RedrawChatWindow( CHAT_WINDOW *ChatWindow, WORD Global[15] );

WORD	WriteConfigChatWindow( BYTE *Dirname, BYTE *Filename, CHAT_WINDOW *ChatWindow, WORD Global[15] );

#endif