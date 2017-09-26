#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<TOS.H>
#include	<VDICOL.H>
#include	<MT_AES.H>
#include	<VDI.H>
#include	<STDLIB.H>
#include <STDDEF.H>
#include	<STDIO.H>
#include	<STRING.H>

#include	<atarierr.h>

#include	"main.h"
#include	"Window.h"
#include	"Window\Item.h"
#include	"Window\Pos.h"

#define	min( a, b )	( a < b ) ? a : b;
#define	max( a, b )	( a > b ) ? a : b;

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern OBJECT	**TreeAddr;
extern GRECT	ScreenRect;

HNDL_WINDOW GetHandleWindow( WORD WinId )
{
	if( GetWindow( WinId ))
		return( GetWindow( WinId )->HandleWindow );
	else
		return( NULL );
}

ULONG	GetKontextWindow( WORD WinId, WORD Global[15] )
{
	MENU_WINDOW	MenuWindow = GetMenuWindow( WinId );
	if( MenuWindow )
		return( MenuWindow( WinId, Global ));
	else
		return( 0 );
}

MENU_WINDOW GetMenuWindow( WORD WinId )
{
	if( GetWindow( WinId ))
		return( GetWindow( WinId )->MenuWindow );
	else
		return( NULL );
}

WORD	RcInterSect( GRECT *p1, GRECT *p2 )
{
	WORD	tx, ty, tw, th;
	tw = min( p2->g_x + p2->g_w, p1->g_x + p1->g_w );
	th = min( p2->g_y + p2->g_h, p1->g_y + p1->g_h );
	tx = max( p2->g_x, p1->g_x );
	ty = max( p2->g_y, p1->g_y );
	p2->g_x = tx;
	p2->g_y = ty;
	p2->g_w = tw - tx;
	p2->g_h = th -ty;
	return(( tw > tx ) && ( th > ty ));
}

WORD	DrawIconifiedWindow( WORD WinId, GRECT *RedrawRect, GRECT *WorkRect, OBJECT *Tree, WORD Global[15] )
{
	GRECT	Box;
	MT_graf_mouse( M_OFF, NULL, Global );
	MT_wind_update( BEG_UPDATE, Global );
	MT_wind_get_grect( WinId, WF_FIRSTXYWH, &Box, Global );
	while( Box.g_w && Box.g_h )
	{
		if( RcInterSect( &ScreenRect, &Box ))
			if( RcInterSect( RedrawRect, &Box ))
			{
				Tree[0].ob_x = WorkRect->g_x;
				Tree[0].ob_y = WorkRect->g_y;
				Tree[0].ob_width = WorkRect->g_w;
				Tree[0].ob_height = WorkRect->g_h;
				Tree[1].ob_x = ( WorkRect->g_w - Tree[1].ob_width ) / 2;
				Tree[1].ob_y = ( WorkRect->g_h - Tree[1].ob_height ) / 2;
				MT_objc_draw( Tree, ROOT, MAX_DEPTH, &Box, Global );
			}
		MT_wind_get_grect( WinId, WF_NEXTXYWH, &Box, Global );
	}
	MT_wind_update( END_UPDATE, Global );
	MT_graf_mouse( M_ON, NULL, Global );
	return( E_OK );
}

void	ScrollWindow( WORD WinId, WORD VdiHandle, WORD Dx, WORD Dy, GRECT *Work, DRAW_WINDOW DrawWindow, WORD Global[15] )
{
	GRECT	Box, New;
	MFDB	Src, Dst;
	WORD	Pxy[8];

	MT_graf_mouse( M_OFF, NULL, Global );
	MT_wind_update( BEG_UPDATE, Global );

	Src.fd_addr = NULL;
	Dst.fd_addr = NULL;

	MT_wind_get_grect( WinId, WF_FIRSTXYWH, &Box, Global );
	while( Box.g_w && Box.g_h )
	{
		if( RcInterSect( &ScreenRect, &Box ))
		{
			if( abs( Dx ) >= Box.g_w || abs( Dy ) >= Box.g_h )
				DrawWindow( WinId, &Box, Work );
			else
			{
				Pxy[0] = Box.g_x; Pxy[1] = Box.g_y;
				Pxy[2] = Pxy[0] + Box.g_w - 1; Pxy[3] = Pxy[1] + Box.g_h - 1;
				Pxy[4] = Pxy[0] + Dx;	Pxy[5] = Pxy[1] + Dy;
				Pxy[6] = Pxy[2] + Dx;	Pxy[7] = Pxy[3] + Dy;
				vs_clip( VdiHandle, 1, Pxy );
				vro_cpyfm( VdiHandle, S_ONLY, Pxy, &Src, &Dst );
				vs_clip( VdiHandle, 0, Pxy );

				if( Dx )
				{
					New.g_x = ( Dx > 0 ) ? Box.g_x : Box.g_x + Box.g_w + Dx;
					New.g_y = Box.g_y;
					New.g_w = abs( Dx );
					New.g_h = Box.g_h;
					DrawWindow( WinId, &New, Work );
				}
				if( Dy )
				{
					New.g_x = Box.g_x;
					New.g_y = ( Dy > 0 ) ? Box.g_y : Box.g_y + Box.g_h + Dy;
					New.g_w = Box.g_w;
					New.g_h = abs( Dy );
					DrawWindow( WinId, &New, Work );
				}
			}
		}
		MT_wind_get_grect( WinId, WF_NEXTXYWH, &Box, Global );
	}

	MT_wind_update( END_UPDATE, Global );
	MT_graf_mouse( M_ON, NULL, Global );
}


