#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<TOS.H>
#include	<MT_AES.H>
#include	<STDLIB.H>
#include <STDDEF.H>

#include	<atarierr.h>

#include	<Window.h>
#include	<main.h>

#define	WIN_OPEN     		0x01
#define	WIN_ICONIFIED		0x02
#define	WIN_ALLICONIFIED	0x04


/*-----------------------------------------------------------------------------*/
/* Strukturdefinitionen                                                        */
/*-----------------------------------------------------------------------------*/
typedef	struct	_win_item
{
	struct _win_item	*next;
	struct _win_item	*last;
	WORD		WinId;
	WORD		AppId;
	WORD		Status;
} WIN_ITEM;

/*-----------------------------------------------------------------------------*/
/* Globale Variablen                                                           */
/*-----------------------------------------------------------------------------*/
WIN_ITEM	*WindowList = NULL;
volatile WORD WindowListSem = 0;
#ifdef	GEMScript
WORD		TopWindow;
#endif

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern WORD	Global[15];

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
WIN_ITEM	*GetLastWindow( void );
WIN_ITEM	*GetWindow( WORD WinId );

WORD	NewWindow( WORD WinId, WORD AppId, WORD Global[15] )
{
	WORD	Ret;
	while( WindowListSem )
		MT_appl_yield( Global );
	WindowListSem = 1;
	{
		WIN_ITEM	*Tmp = malloc( sizeof( WIN_ITEM ));
		if( Tmp )
		{
			Tmp->WinId = WinId;
			Tmp->AppId = AppId;
			Tmp->Status = WIN_OPEN;
			if( GetLastWindow() )
			{
				Tmp->last = GetLastWindow();
				GetLastWindow()->next = Tmp;
			}
			else
			{
				Tmp->last = NULL;
				WindowList = Tmp;
			}
			Tmp->next = NULL;
#ifdef DEBUG
	DebugMsg( Global, "New Window [AppId = %i, WinId = %i]\n", AppId, WinId );
	DebugMsg( Global, "\t%lx\n", Tmp );
	DebugMsg( Global, "\tnext = %lx\n", Tmp->next );
	DebugMsg( Global, "\tlast = %lx\n", Tmp->last );
#endif
			Ret = E_OK;
		}
		else
			Ret = ENSMEM;
	}
	WindowListSem = 0;
	return( Ret );
}

void	DelWindow( WORD WinId, WORD Global[15] )
{
	while( WindowListSem )
		MT_appl_yield( Global );
	WindowListSem = 1;
	{
		WIN_ITEM	*Del = GetWindow( WinId );
		if( Del )
		{
#ifdef DEBUG
	DebugMsg( Global, "Del Window [AppId = %i, WinId = %i] = %lx\n", Del->AppId, Del->WinId, Del );
#endif
			if( Del == WindowList )
			{
				WindowList = Del->next;
				if( WindowList )
					WindowList->last = NULL;
#ifdef DEBUG
	DebugMsg( Global, "\tfirst Window! WindowList = %lx\n", WindowList );
#endif
			}
			else
			{
#ifdef DEBUG
	DebugMsg( Global, "\tnext = %lx\n", Del->next );
	DebugMsg( Global, "\tlast = %lx\n", Del->last );
#endif
				( Del->last )->next = Del->next;
#ifdef DEBUG
	DebugMsg( Global, "\tlast->next = %lx\n", (Del->last)->next );
#endif
				if( Del->next )
				{
					( Del->next )->last = Del->last;
#ifdef DEBUG
	DebugMsg( Global, "\tnext->last = %lx\n", (Del->next)->last );
#endif
				}
			}
			free( Del );
		}
	}
	WindowListSem = 0;
}

WORD	GetAppIdWindow( WORD WinId )
{
	if( GetWindow( WinId ))
		return( GetWindow( WinId )->AppId );
	else
		return( -1 );
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

void	IconifyWindow( WORD WinId )
{
	if( GetWindow( WinId ))
		GetWindow( WinId )->Status |= WIN_ICONIFIED;
}
void	UnIconifyWindow( WORD WinId )
{
	if( GetWindow( WinId ))
		GetWindow( WinId )->Status &= ~WIN_ICONIFIED;
}
void	AllIconifyWindow( WORD WinId )
{
	if( GetWindow( WinId ))
		GetWindow( WinId )->Status |= WIN_ALLICONIFIED;
}
void	UnAllIconifyWindow( WORD WinId )
{
	if( GetWindow( WinId ))
		GetWindow( WinId )->Status &= ~WIN_ALLICONIFIED;
}

WORD	isWindow( WORD WinId )
{
	if( GetWindow( WinId ))
		return( 1 );
	else
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

#ifdef	GEMScript
void	SetTopWindow( WORD WinId )
{
	TopWindow = WinId;
}
WORD	GetTopWindow( void )
{
	if( GetFirstWindow() != -1 )
		return( TopWindow );
	else
		return( -1 );
}
#endif