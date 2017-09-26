#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<VDICOL.H>
#include	<MT_AES.H>
#include	<VDI.H>
#include	<STDDEF.H>
#include	<STDARG.H>
#include	<STDLIB.H>
#include	<STRING.H>
#include	<stdio.h>

#include	<atarierr.h>

#include	"..\main.h"
#include	RSCHEADER
#include	"..\DD.h"
#include	"..\Menu.h"
#include	"..\W_Text.h"
#include	"..\Window.h"

#include	"Button.h"
#include	"Cursor.h"
#include	"Mesag.h"

#include	"..\MapKey.h"
/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern OBJECT	**TreeAddr;
extern GRECT	ScreenRect;

WORD	HandleMuButtonTextWindow( WORD WinId, EVNT *Events, TEXT_WINDOW *TextWindow, WORD Global[15] )
{
	WORD	w1, w2, w3, w4;
	EVNTDATA	Ev;
	EVNT		Event;
	MT_wind_get( 0, WF_TOP, &w1, &w2, &w3, &w4, Global );
	MT_graf_mkstate( &Ev, Global );
	if( w1 == WinId && Events->mbutton == 1 )
	{
		XY	A, B;
		if( Ev.bstate == 0 )
		{
			A.x = -1; A.y = -1; B.x = -1; B.y = -1;
			BlockTextWindow( WinId, &A, &B, TextWindow );
		}
		else
		{
			MOBLK	M1;
			WORD	dHpos = 0, dVpos = 0;
			A.x = (( Events->mx - TextWindow->WorkRect.g_x ) / TextWindow->CellWidth ) + TextWindow->Pos.x;
			A.y = (( Events->my - TextWindow->WorkRect.g_y ) / TextWindow->CellHeight ) + TextWindow->Pos.y;
			if( TextWindow->BlockStart.x != -1 && TextWindow->BlockStart.y != -1 && TextWindow->BlockEnd.x != -1 && TextWindow->BlockEnd.y != -1 )
			{
				if(( A.y > TextWindow->BlockStart.y && A.y < TextWindow->BlockEnd.y ) ||
				   ( A.y == TextWindow->BlockStart.y && A.y != TextWindow->BlockEnd.y && A.x >= TextWindow->BlockStart.x ) ||
				   ( A.y == TextWindow->BlockEnd.y && A.y != TextWindow->BlockStart.y && A.x <= TextWindow->BlockEnd.x ) ||
				   ( A.y == TextWindow->BlockStart.y && TextWindow->BlockStart.y == TextWindow->BlockEnd.y && A.x >= TextWindow->BlockStart.x && A.x <= TextWindow->BlockEnd.x ))
				{
					if(( Events->kstate << 8 ) & KbSHIFT )
					{
						B.x = TextWindow->BlockStart.x;
						B.y = TextWindow->BlockStart.y;
						A.x--;
						BlockTextWindow( WinId, &B, &A, TextWindow );
					}
					else
					{
						WORD	Cxy[4], Pxy[10], x = Events->mx, y = Events->my, Dx, Dy;
						MOBLK	M1;
						M1.m_out = 1;
						M1.m_x = 0;
						M1.m_y = 0;
						M1.m_w = 0;
						M1.m_h = 0;
						MT_wind_update( BEG_UPDATE, Global );
						MT_wind_update( BEG_MCTRL, Global );
						MT_graf_mouse( 258, NULL, Global );
						MT_graf_mouse( FLAT_HAND, NULL, Global );
						MT_graf_mouse( M_OFF, NULL, Global );
						Cxy[0] = ScreenRect.g_x; Cxy[1] = ScreenRect.g_y;
						Cxy[2] = Cxy[0] + ScreenRect.g_w; Cxy[3] = Cxy[2] + ScreenRect.g_h;
						vs_clip( TextWindow->VdiHandle, 1, Cxy );
						vsl_udsty( TextWindow->VdiHandle, 0xaaaa );
						vsl_type( TextWindow->VdiHandle, 7 );
						vswr_mode( TextWindow->VdiHandle, MD_XOR );
						Pxy[0] = TextWindow->WorkRect.g_x + (( WORD )( TextWindow->Pos.x )) * TextWindow->CellWidth;
						Pxy[1] = TextWindow->WorkRect.g_y + (( WORD )( TextWindow->BlockStart.y - TextWindow->Pos.y )) * TextWindow->CellHeight;
						Pxy[2] = TextWindow->WorkRect.g_x + (( WORD )( TextWindow->nCharMax )) * TextWindow->CellWidth;
						Pxy[3] = Pxy[1];
						Pxy[4] = Pxy[2];
						Pxy[5] = TextWindow->WorkRect.g_y + (( WORD )( TextWindow->BlockEnd.y - TextWindow->Pos.y + 1 )) * TextWindow->CellHeight;
						if( TextWindow->BlockEnd.x == 0 )
							Pxy[5] -= TextWindow->CellHeight;
						Pxy[6] = Pxy[0];
						Pxy[7] = Pxy[5];
						Pxy[8] = Pxy[0];
						Pxy[9] = Pxy[1];
						v_pline( TextWindow->VdiHandle, 5, Pxy );
						MT_graf_mouse( M_ON, NULL, Global );
						do
						{
							MT_EVNT_multi( MU_BUTTON + MU_M1, 1, 1, 0, &M1, NULL, 0, &Event, Global );
							M1.m_x = Event.mx;
							M1.m_y = Event.my;
							Dx = Event.mx - x; Dy = Event.my - y;
							if( Dx || Dy )
							{
								MT_graf_mouse( M_OFF, NULL, Global );
								v_pline( TextWindow->VdiHandle, 5, Pxy );
								Pxy[0] += Dx;	Pxy[1] += Dy;
								Pxy[2] += Dx;	Pxy[3] += Dy;
								Pxy[4] += Dx;	Pxy[5] += Dy;
								Pxy[6] += Dx;	Pxy[7] += Dy;
								Pxy[8] += Dx;	Pxy[9] += Dy;
								v_pline( TextWindow->VdiHandle, 5, Pxy );
								x = Event.mx; y = Event.my;
								MT_graf_mouse( M_ON, NULL, Global );
							}
						}
						while( !( Event.mwhich & MU_BUTTON ));
						MT_graf_mouse( M_OFF, NULL, Global );
						v_pline( TextWindow->VdiHandle, 5, Pxy );
						vs_clip( TextWindow->VdiHandle, 0, Cxy );
						MT_graf_mouse( M_ON, NULL, Global );
						MT_graf_mouse( 259, NULL, Global );
						MT_wind_update( END_MCTRL, Global );
						MT_wind_update( END_UPDATE, Global );
						{
							WORD	DestWinId = MT_wind_find( Event.mx, Event.my, Global );
							WORD	AppId, w2, w3, w4;
							BYTE	*Puf = GetBlockTextWindow( TextWindow );
							if( !Puf )
								return( ENSMEM );
							if( DestWinId != -1 && DestWinId != WinId )
							{
								MT_wind_get( DestWinId, WF_OWNER, &AppId, &w2, &w3, &w4, Global );
								if( AppId != Global[2] )
									PutDragDrop( DestWinId, Event.mx, Event.my, Ev.kstate, AppId, '.TXT', Puf, strlen( Puf ), Global );
								else
								{
									EVNT	lEvent;
									DD_INFO	DdInfo;
									DdInfo.format = '.TXT';
									DdInfo.mx = Event.mx;
									DdInfo.my = Event.my;
									DdInfo.kstate = Ev.kstate;
									DdInfo.size = strlen( Puf );
									DdInfo.puf = Puf;
									lEvent.mwhich = MU_MESAG;
									lEvent.msg[0] = WIN_CMD;
									lEvent.msg[1] = Global[2];
									lEvent.msg[2] = 0;
									lEvent.msg[3] = DestWinId;
									lEvent.msg[4] = WIN_DRAGDROP;
									*( DD_INFO ** )&( lEvent.msg[5] ) = &DdInfo;
									HandleWindow( &lEvent, Global );
								}
							}
							free( Puf );
						}
						return( E_OK );
					}
				}
				else
				{
					if(( Events->kstate << 8 ) & KbSHIFT )
					{
						if( A.y > TextWindow->BlockEnd.y || ( A.y == TextWindow->BlockEnd.y && A.x > TextWindow->BlockEnd.x ))
						{
							B.x = TextWindow->BlockStart.x;
							B.y = TextWindow->BlockStart.y;
							SortXy( &A, &B );
						}
						else	if( A.y < TextWindow->BlockStart.y || ( A.y == TextWindow->BlockStart.y && A.x < TextWindow->BlockEnd.x ))
						{
							B.x = TextWindow->BlockEnd.x;
							B.y = TextWindow->BlockEnd.y;
							SortXy( &B, &A );
						}
						BlockTextWindow( WinId, &A, &B, TextWindow );
					}
					else
					{
						B.x = A.x;
						B.y = A.y;
						BlockTextWindow( WinId, &A, &B, TextWindow );
					}
				}  
			}
			else
			{
			}
			M1.m_out = 1;
			M1.m_x = 0;
			M1.m_y = 0;
			M1.m_w = 0;
			M1.m_h = 0;

			MT_wind_update( BEG_UPDATE, Global );
			MT_wind_update( BEG_MCTRL, Global );
			MT_graf_mouse( 258, NULL, Global );
			MT_graf_mouse( POINT_HAND, NULL, Global );
			do
			{
				MT_EVNT_multi( MU_BUTTON + MU_M1, 1, 1, 0, &M1, NULL, 0, &Event, Global );
				M1.m_x = Event.mx;
				M1.m_y = Event.my;
				dHpos = 0;
				dVpos = 0;

				if( Event.mx < TextWindow->WorkRect.g_x )
					dHpos = -1;
				if( Event.mx > TextWindow->WorkRect.g_x + TextWindow->WorkRect.g_w )
					dHpos = +1;
				if( Event.my < TextWindow->WorkRect.g_y )
					dVpos = -1;
				if( Event.my > TextWindow->WorkRect.g_y + TextWindow->WorkRect.g_h )
					dVpos = +1;
				if( dHpos || dVpos )
				{
					if( TextWindow->Pos.x + dHpos < 0 )
						dHpos = 0;
					if( TextWindow->Pos.x + TextWindow->WorkRect.g_w / TextWindow->CellWidth + dHpos > TextWindow->Terminal.x )
						dHpos = 0;
					if( TextWindow->Pos.y + dVpos < 0 )
						dVpos = 0;
					if( TextWindow->Pos.y + TextWindow->WorkRect.g_h / TextWindow->CellHeight + dVpos > TextWindow->nLine )
						dVpos = 0;
					if( dHpos || dVpos )
					{
						TextWindow->Pos.x += dHpos;
						TextWindow->Pos.y += dVpos;
						ScrollWindow( WinId, TextWindow->VdiHandle, -dHpos * TextWindow->CellWidth, -dVpos * TextWindow->CellHeight, &( TextWindow->WorkRect ), DrawTextWindow, Global );
						SetHSliderTextWindow( WinId, TextWindow, Global );
						SetVSliderTextWindow( WinId, TextWindow, Global );
					}
				}

				B.x = (( Event.mx - TextWindow->WorkRect.g_x ) / TextWindow->CellWidth ) + TextWindow->Pos.x;
				B.y = (( Event.my - TextWindow->WorkRect.g_y ) / TextWindow->CellHeight ) + TextWindow->Pos.y;
				if( B.x < 0 )
				{
					B.x = TextWindow->Terminal.x;
					B.y--;
				}
				{
					XY	a, b;
					if( A.x == -1 && A.y == -1 )
					{
						A.x = B.x;
						A.y = B.y;
					}
					a.x = A.x;	a.y = A.y;
					b.x = B.x;	b.y = B.y;
					if( B.y < A.y || ( B.y == A.y && B.x <= A.x ))
						SortXy( &a, &b );
					if( a.x != TextWindow->BlockStart.x || a.y != TextWindow->BlockStart.y || b.x != TextWindow->BlockEnd.x || b.y != TextWindow->BlockEnd.y )
						BlockTextWindow( WinId, &a, &b, TextWindow );
				}
			}
			while( !( Event.mwhich & MU_BUTTON ));
			MT_graf_mouse( 259, NULL, Global );
			MT_wind_update( END_MCTRL, Global );
			MT_wind_update( END_UPDATE, Global );
/* Klick innerhalb eines Blockes (mit Shift) -> Blockende an diesem Klick */
/* Klick ausserhalb des Blockes (ohne Shift) -> Neuer Blockanfang */
/* Klick ausserhalb des Blockes (mit Shift) -> Block auf diese Stelle erweitern */
		}
		return( E_OK );
	}
	else	if( Events->mbutton == 2 )
	{
		if( TextWindow->ModWin )
			return( E_OK );
		if( Ev.bstate != 2 )
			return( KontextTextWindow( WinId, TextWindow, Global ));
		else
		{
			MOBLK	M1;
			WORD	Dx = 0, Dy = 0;
			WORD	x = Events->mx, y = Events->my;
			M1.m_out = 1;
			M1.m_x = 0;
			M1.m_y = 0;
			M1.m_w = 0;
			M1.m_h = 0;
			MT_wind_update( BEG_UPDATE, Global );
			MT_wind_update( BEG_MCTRL, Global );
			MT_graf_mouse( 258, NULL, Global );
			MT_graf_mouse( FLAT_HAND, NULL, Global );
			do
			{
				MT_EVNT_multi( MU_BUTTON + MU_M1, 1, 2, 0, &M1, NULL, 0, &Event, Global );
				M1.m_x = Event.mx;
				M1.m_y = Event.my;
				Dx += ( x - Event.mx );	Dy += ( y - Event.my );
				x = Event.mx;	y = Event.my;
				if( Dx || Dy )
				{
					LONG	HPos = TextWindow->Pos.x, VPos = TextWindow->Pos.y;
					WORD	dHPos, dVPos;
					TextWindow->Pos.x += Dx / TextWindow->CellWidth;
					if( TextWindow->Pos.x > TextWindow->nCharMax - TextWindow->WorkRect.g_w / TextWindow->CellWidth )
						TextWindow->Pos.x = TextWindow->nCharMax - TextWindow->WorkRect.g_w / TextWindow->CellWidth;
					if( TextWindow->Pos.x < 0 )
						TextWindow->Pos.x = 0;
					dHPos = ( WORD )( HPos - TextWindow->Pos.x );
					TextWindow->Pos.y += Dy / TextWindow->CellHeight;
					if( TextWindow->Pos.y > TextWindow->nLine - TextWindow->WorkRect.g_h / TextWindow->CellHeight )
						TextWindow->Pos.y = TextWindow->nLine - TextWindow->WorkRect.g_h / TextWindow->CellHeight;
					if( TextWindow->Pos.y < 0 )
						TextWindow->Pos.y = 0;
					dVPos = ( WORD )( VPos - TextWindow->Pos.y );
					if( dHPos || dVPos )
					{
						ScrollWindow( WinId, TextWindow->VdiHandle, dHPos * TextWindow->CellWidth, dVPos * TextWindow->CellHeight, &( TextWindow->WorkRect ), DrawTextWindow, Global );
						SetHSliderTextWindow( WinId, TextWindow, Global );
						SetVSliderTextWindow( WinId, TextWindow, Global );
						if( dHPos )
							Dx = 0;
						if( dVPos )
							Dy = 0;
					}
				}
			}
			while( !( Event.mwhich & MU_BUTTON ));
			MT_graf_mouse( 259, NULL, Global );
			MT_wind_update( END_MCTRL, Global );
			MT_wind_update( END_UPDATE, Global );
		}
	}
	else	if( Events->mbutton == 1 )
	{
		if( TextWindow->ModWin )
			MT_wind_set( TextWindow->ModWin->WinId, WF_TOP, 0, 0, 0, 0, Global );
		else
		{
			MT_wind_update( BEG_UPDATE, Global );
			MT_wind_set( WinId, WF_TOP, 0, 0, 0, 0, Global );
			while( MT_graf_mkstate( &Ev, Global ) && Ev.bstate );
			MT_wind_update( END_UPDATE, Global );
			return( E_OK );
		}
	}
	return( ERROR );
}