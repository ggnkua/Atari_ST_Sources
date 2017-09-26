#ifndef	__WIN_ITEM__
#define	__WIN_ITEM__

/*-----------------------------------------------------------------------------*/
/* Strukturdefinitionen                                                        */
/*-----------------------------------------------------------------------------*/
typedef	struct	__win_item__
{
	struct __win_item__	*next;
	struct __win_item__	*prev;
	HNDL_WINDOW		HandleWindow;
	MENU_WINDOW		MenuWindow;
	void				*WindowData;
	WORD				WinId;
	WORD				Type;
	WORD				Status;
	GRECT				CurrRect;
} WIN_ITEM;


WIN_ITEM		*GetWindow( WORD WinId );
WIN_ITEM		*GetLastWindow( void );

void	CloseWindow( WORD WinId );
void	OpenWindow( WORD WinId );
void	ShadedWindow( WORD WinId );
WORD	isShadedWindow( WORD WinId );
void	UnShadedWindow( WORD WinId );
#endif