#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<MT_AES.H>
#include <STDDEF.H>
#include	<STDLIB.H>

#include	<atarierr.h>

#include	"Window.h"
#include	"Window\Item.h"
#include	"Window\Pos.h"

#define	WIN_OPEN     		0x01
#define	WIN_ICONIFIED		0x02
#define	WIN_ALLICONIFIED	0x04
#define	WIN_SHADED			0x08

/*-----------------------------------------------------------------------------*/
/* Lokale Variablen                                                            */
/*-----------------------------------------------------------------------------*/
static WIN_ITEM	*WindowList = NULL;

WORD	NewWindow( WORD WinId, WORD Type, HNDL_WINDOW HndlWindow, MENU_WINDOW MenuWindow, void *WindowData )
{
	WORD	Ret;
	{
		WIN_ITEM	*Tmp = malloc( sizeof( WIN_ITEM ));
		if( Tmp )
		{
			Tmp->HandleWindow = HndlWindow;
			Tmp->MenuWindow = MenuWindow;
			Tmp->WindowData = WindowData;
			Tmp->WinId = WinId;
			Tmp->Type = Type;
			Tmp->Status = WIN_OPEN;
			if( GetLastWindow() )
			{
				Tmp->prev = GetLastWindow();
				GetLastWindow()->next = Tmp;
			}
			else
			{
				Tmp->prev = NULL;
				WindowList = Tmp;
			}
			Tmp->next = NULL;
			Ret = E_OK;
		}
		else
			Ret = ENSMEM;
	}
	return( Ret );
}

void	DelWindow( WORD WinId )
{
	{
		WIN_ITEM	*Del = GetWindow( WinId );
		UnSetPosWindow( WinId );
		if( Del )
		{
			if( Del == WindowList )
			{
				WindowList = Del->next;
				if( WindowList )
					WindowList->prev = NULL;
			}
			else
			{
				( Del->prev )->next = Del->next;
				if( Del->next )
					( Del->next )->prev = Del->prev;
			}
			free( Del );
		}
	}
}

WORD	GetFirstWindow()
{
	WORD	Ret;
	if( WindowList )
		Ret = WindowList->WinId;
	else
		Ret = -1;
	return( Ret );
}

WORD	GetNextWindow( WORD WinId )
{
	WORD	Ret;
	{
		WIN_ITEM	*Tmp = GetWindow( WinId );
		if( Tmp )
		{
			if( Tmp->next )
				Ret = ( Tmp->next )->WinId;
			else
				Ret = -1;
		}
		else
			Ret = -1;
	}
	return( Ret );
}

WORD	GetTypeWindow( WORD WinId )
{
	WIN_ITEM	*WinItem = GetWindow( WinId );
	if( WinItem )
		return( WinItem->Type);
	else
		return( -1 );
}

void	*GetWindowData( WORD WinId )
{
	if( GetWindow( WinId ))
		return( GetWindow( WinId )->WindowData );
	else
		return( NULL );
}

void	CloseWindow( WORD WinId )
{
	if( GetWindow( WinId ))
		GetWindow( WinId )->Status &= ~WIN_OPEN;
}
void	OpenWindow( WORD WinId )
{
	if( GetWindow( WinId ))
		GetWindow( WinId )->Status |= WIN_OPEN;
}

void	IconifyWindow( WORD WinId )
{
	if( GetWindow( WinId ))
	{
		WIN_ITEM	*WinItem = GetWindow( WinId );
		WinItem->Status |= WIN_ICONIFIED;
	}
}
void	UnIconifyWindow( WORD WinId )
{
	if( GetWindow( WinId ))
	{
		WIN_ITEM	*WinItem = GetWindow( WinId );
		WinItem->Status &= ~WIN_ICONIFIED;
	}
}
void	AllIconifyWindow( WORD WinId, GRECT *CurrRect )
{
	if( GetWindow( WinId ))
	{
		WIN_ITEM	*WinItem = GetWindow( WinId );
		WinItem->Status |= WIN_ALLICONIFIED;
		WinItem->CurrRect.g_x = CurrRect->g_x;
		WinItem->CurrRect.g_y = CurrRect->g_y;
		WinItem->CurrRect.g_w = CurrRect->g_w;
		WinItem->CurrRect.g_h = CurrRect->g_h;
	}
}
void	UnAllIconifyWindow( WORD WinId, GRECT *CurrRect )
{
	if( GetWindow( WinId ))
	{
		WIN_ITEM	*WinItem = GetWindow( WinId );
		WinItem->Status &= ~WIN_ALLICONIFIED;
		CurrRect->g_x = WinItem->CurrRect.g_x;
		CurrRect->g_y = WinItem->CurrRect.g_y;
		CurrRect->g_w = WinItem->CurrRect.g_w;
		CurrRect->g_h = WinItem->CurrRect.g_h;
	}
}
void	ShadedWindow( WORD WinId )
{
	if( GetWindow( WinId ))
		GetWindow( WinId )->Status |= WIN_SHADED;
}
void	UnShadedWindow( WORD WinId )
{
	if( GetWindow( WinId ))
		GetWindow( WinId )->Status &= ~WIN_SHADED;
}

WORD	isWindow( WORD WinId )
{
	if( GetWindow( WinId ))
		return( 1 );
	else
		return( 0 );
}
WORD	isOpenWindow( WORD WinId )
{
	if( GetWindow( WinId ))
		if( GetWindow( WinId )->Status & WIN_OPEN )
			return( 1 );
	return( 0 );
}
WORD	isIconifiedWindow( WORD WinId )
{
	if( GetWindow( WinId ))
		if( GetWindow( WinId )->Status & WIN_ICONIFIED )
			return( 1 );
	return( 0 );
}
WORD	isAllIconifiedWindow( WORD WinId )
{
	if( GetWindow( WinId ))
		if( GetWindow( WinId )->Status & WIN_ALLICONIFIED )
			return( 1 );
	return( 0 );
}
WORD	isShadedWindow( WORD WinId )
{
	if( GetWindow( WinId ))
		if( GetWindow( WinId )->Status & WIN_SHADED )
			return( 1 );
	return( 0 );
}

WIN_ITEM	*GetWindow( WORD WinId )
{
	WIN_ITEM	*Tmp = WindowList;
	while( Tmp )
		if( Tmp->WinId == WinId )
			break;
		else
			Tmp = Tmp->next;
	return( Tmp );
}

WIN_ITEM	*GetLastWindow( void )
{
	WIN_ITEM	*Tmp = WindowList;
	if( Tmp )
	{
		while( Tmp->next )
			Tmp = Tmp->next;
		return( Tmp );
	}
	else
		return( NULL );
}
