#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<VDICOL.H>
#include	<MT_AES.H>
#include	<VDI.H>
#include	<STDDEF.H>

#include	<atarierr.h>

#include	"W_Text.h"
#include	"W_Text\Cursor.h"
#include	"Window.h"

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
static WORD	DrawCursorTextWindow( WORD WinId, TEXT_WINDOW *TextWindow, WORD Global[15] );

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern GRECT	ScreenRect;

WORD	HandleMuTimerTextWindow( WORD WinId, TEXT_WINDOW *TextWindow, WORD Global[15] )
{
	if( isIconifiedWindow( WinId ) || !( TextWindow->CursorFlag & C_ON ))
		return( E_OK );	
	if( TextWindow->CursorFlag & C_ON_SCREEN )
		CursorOffTextWindow( WinId, TextWindow, Global );
	else
		CursorOnTextWindow( WinId, TextWindow, Global );
	return( E_OK );
}

void	CursorOffTextWindow( WORD WinId, TEXT_WINDOW *TextWindow, WORD Global[15] )
{
	if(( TextWindow->CursorFlag & C_ON_SCREEN ) && ( TextWindow->CursorFlag & C_ON ))
	{
		DrawCursorTextWindow( WinId, TextWindow, Global );
			TextWindow->CursorFlag &= ~C_ON_SCREEN;
	}
}
void	CursorOnTextWindow( WORD WinId, TEXT_WINDOW *TextWindow, WORD Global[15] )
{
	if( isIconifiedWindow( WinId ))
		return;
	if( !( TextWindow->CursorFlag & C_ON_SCREEN ) && ( TextWindow->CursorFlag & C_ON ))
	{
		if( DrawCursorTextWindow( WinId, TextWindow, Global ))
			TextWindow->CursorFlag |= C_ON_SCREEN;
	}
}


static WORD	DrawCursorTextWindow( WORD WinId, TEXT_WINDOW *TextWindow, WORD Global[15] )
{
	GRECT	BoxRect, CursorRect, FullRect;
	WORD	Pxy[4], Cxy[4], Ret = 0;
	CursorRect.g_x = ( WORD )( TextWindow->WorkRect.g_x + ( TextWindow->Cursor.x - TextWindow->Pos.x ) * TextWindow->CellWidth );
	CursorRect.g_y = ( WORD )( TextWindow->WorkRect.g_y + ( TextWindow->Cursor.y - TextWindow->Pos.y + 1 ) * TextWindow->CellHeight ) - 2;
	CursorRect.g_w = TextWindow->CellWidth;
	CursorRect.g_h = 2;
	Pxy[0] = CursorRect.g_x;	Pxy[1] = CursorRect.g_y;
	Pxy[2] = Pxy[0] + CursorRect.g_w - 1;	Pxy[3] = Pxy[1] + CursorRect.g_h - 1;

	MT_wind_update( BEG_UPDATE, Global );
	MT_graf_mouse( M_OFF, NULL, Global );

	vsf_interior( TextWindow->VdiHandle, 1 );
	vsf_perimeter( TextWindow->VdiHandle, 0 );
	vsf_color( TextWindow->VdiHandle, TextWindow->FontColor );
	vswr_mode( TextWindow->VdiHandle, MD_XOR );

	MT_wind_get_grect( WinId, WF_FIRSTXYWH, &BoxRect, Global );
	while( BoxRect.g_w && BoxRect.g_h )
	{
		if( RcInterSect( &ScreenRect, &BoxRect ))
			if( RcInterSect( &( TextWindow->WorkRect ), &BoxRect ))
			{
				if( RcInterSect( &CursorRect, &BoxRect ))
				{
					Cxy[0] = BoxRect.g_x;Cxy[1] = BoxRect.g_y;
					Cxy[2] = Cxy[0] + BoxRect.g_w - 1;	Cxy[3] = Cxy[1] + BoxRect.g_h - 1;
					vs_clip( TextWindow->VdiHandle, 1, Cxy );	

					v_bar( TextWindow->VdiHandle, Pxy );
					Ret = 1;

					vs_clip( TextWindow->VdiHandle, 0, Cxy );
				}
			}
		MT_wind_get_grect( WinId, WF_NEXTXYWH, &BoxRect, Global );
	}

	MT_graf_mouse( M_ON, NULL, Global );
	MT_wind_update( END_UPDATE, Global );
	return( Ret );
}