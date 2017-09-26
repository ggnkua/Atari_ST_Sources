#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<MT_AES.H>
#include <STDDEF.H>
#include	<STDLIB.H>

#include	<atarierr.h>

#include	"Window.h"
#include	"Window\Pos.h"

typedef	struct	_pos_window_
{
	struct _pos_window_	*next;
	struct _pos_window_	*last;
	WORD	WinId;
	GRECT	Pos;
}	POS_WINDOW;

/*-----------------------------------------------------------------------------*/
/* Lokale Variablen                                                            */
/*-----------------------------------------------------------------------------*/
static POS_WINDOW	*pPosWin[WIN_MAX_TYPES];

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
static POS_WINDOW	*GetPosWin( WORD WinId, WORD Type );
static POS_WINDOW	*NewPosWin( WORD WinId, WORD Type, GRECT *Pos );

void	SetPosWindow( WORD WinId, GRECT *Pos )
{
	WORD	Type = GetTypeWindow( WinId );
	POS_WINDOW	*PosWin = GetPosWin( WinId, Type );
	if( !PosWin )
		PosWin = NewPosWin( WinId, Type, Pos );
	else
	{
		PosWin->Pos.g_x = Pos->g_x;
		PosWin->Pos.g_y = Pos->g_y;
		PosWin->Pos.g_w = Pos->g_w;
		PosWin->Pos.g_h = Pos->g_h;
	}
}
void	SetPosWindowFirst( WORD WinId, GRECT *Pos )
{
	WORD	Type = GetTypeWindow( WinId );
	POS_WINDOW	*PosWin = GetPosWin( -1, Type );
	if( PosWin )
	{
		PosWin->Pos.g_x = Pos->g_x;
		PosWin->Pos.g_y = Pos->g_y;
		PosWin->Pos.g_w = Pos->g_w;
		PosWin->Pos.g_h = Pos->g_h;
		PosWin->WinId = WinId;
	}
	else
		NewPosWin( WinId, Type, Pos );
}

void	UnSetPosWindow( WORD WinId )
{
	POS_WINDOW	*PosWin = GetPosWin( WinId, GetTypeWindow( WinId ));
	if( PosWin )
		PosWin->WinId = -1;
}

void	GetPosWindow( WORD WinId, GRECT *Pos )
{
	POS_WINDOW	*PosWin = GetPosWin( WinId, GetTypeWindow( WinId ));
	if( !PosWin )
		PosWin = GetPosWin( -1, GetTypeWindow( WinId ));
	if( PosWin )
	{
		Pos->g_x = PosWin->Pos.g_x;
		Pos->g_y = PosWin->Pos.g_y;
		Pos->g_w = PosWin->Pos.g_w;
		Pos->g_h = PosWin->Pos.g_h;
		PosWin->WinId = WinId;
	}
	else
	{
		Pos->g_x = -1;
		Pos->g_y = -1;
		Pos->g_w = -1;
		Pos->g_h = -1;
	}
}

void	GetPosWindowByType( WORD Type, GRECT *Pos )
{
	POS_WINDOW	*PosWin = GetPosWin( -1, Type );
	if( PosWin )
	{
		Pos->g_x = PosWin->Pos.g_x;
		Pos->g_y = PosWin->Pos.g_y;
		Pos->g_w = PosWin->Pos.g_w;
		Pos->g_h = PosWin->Pos.g_h;
	}
	else
	{
		Pos->g_x = -1;
		Pos->g_y = -1;
		Pos->g_w = -1;
		Pos->g_h = -1;
	}
}

WORD	GetInitPosWindow( WORD Type, WORD n, GRECT *Pos )
{
	if( Type >= 0 )
	{
		POS_WINDOW	*PosWin = pPosWin[Type];
		WORD	i = 0;
		while( PosWin )
		{
			if( i == n )
			{
				Pos->g_x = PosWin->Pos.g_x;
				Pos->g_y = PosWin->Pos.g_y;
				Pos->g_w = PosWin->Pos.g_w;
				Pos->g_h = PosWin->Pos.g_h;
				return( E_OK );
			}
			i++;
			PosWin = PosWin->next;
		}
	}
	return( ERROR );
}

void	SetInitPosWindow( WORD Type, GRECT *Pos )
{
	if( Type >= 0 )
		NewPosWin( -1, Type, Pos );
}

static POS_WINDOW	*GetPosWin( WORD WinId, WORD Type )
{
	if( Type >= 0 )
	{
		POS_WINDOW	*PosWin = pPosWin[Type];
		while( PosWin )
		{
			if( PosWin->WinId == WinId )
				return( PosWin );
			PosWin = PosWin->next;
		}
	}
	return( NULL );
}

static POS_WINDOW	*NewPosWin( WORD WinId, WORD Type, GRECT *Pos )
{
	POS_WINDOW	*PosWin = pPosWin[Type];
	if( !PosWin )
	{
		PosWin = malloc( sizeof( POS_WINDOW ));
		if( !PosWin )
			return( NULL );
		pPosWin[Type] = PosWin;
		PosWin->last = NULL;
	}
	else
	{
		POS_WINDOW	*NewPosWin = malloc( sizeof( POS_WINDOW ));
		if( !NewPosWin )
			return( NULL );
		while( PosWin->next )
			PosWin = PosWin->next;
		PosWin->next = NewPosWin;
		NewPosWin->last = PosWin;
		PosWin = NewPosWin;
	}
	PosWin->next = NULL;
	PosWin->WinId = WinId;
	PosWin->Pos.g_x = Pos->g_x;
	PosWin->Pos.g_y = Pos->g_y;
	PosWin->Pos.g_w = Pos->g_w;
	PosWin->Pos.g_h = Pos->g_h;
	return( PosWin );
}