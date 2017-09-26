#define	C_ON	0x0001
#define	C_ON_SCREEN	0x0002

WORD	HandleMuTimerTextWindow( WORD WinId, TEXT_WINDOW *TextWindow, WORD Global[15] );
void	CursorOffTextWindow( WORD WinId, TEXT_WINDOW *TextWindow, WORD Global[15] );
void	CursorOnTextWindow( WORD WinId, TEXT_WINDOW *TextWindow, WORD Global[15] );