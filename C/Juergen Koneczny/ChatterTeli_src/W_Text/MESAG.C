#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<VDICOL.H>
#include	<MT_AES.H>
#include	<VDICOL.H>
#include	<STDDEF.H>
#include	<STDLIB.H>
#include	<STRING.H>

#include	<atarierr.h>

#include	"..\main.h"
#include	RSCHEADER
#include	"..\Clipbrd.h"
#include	"..\DD.h"
#include	"..\Help.h"
#include	"WDialog\CView.h"
#include	"W_Text.h"
#include	"W_Text\Cursor.h"
#include	"W_Text\Mesag.h"
#include	"..\Window.h"

#include	"..\KEYTAB.h"

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern OBJECT	**TreeAddr;
extern GRECT	ScreenRect;
extern WORD	FontId, FontColor, FontEffects;
extern LONG	FontPt;

extern KEYT	*Keytab;
/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/

WORD	HandleMuMesagTextWindow( WORD WinId, EVNT *Events, TEXT_WINDOW *TextWindow, WORD Global[15] )
{
	if( Events->msg[0] == WIN_CMD )
	{
		if( Events->msg[4] == WIN_DRAGDROP )
			return( TextWindow->HandleUserTextWindow( WinId, Events, TextWindow->UserData, Global ));

		if( Events->msg[4] == WIN_COPY )
		{
			BYTE	*Puf = GetBlockTextWindow( TextWindow );
			if( !Puf )
				return( ENSMEM );
			PutClipboard( "TXT", Puf, strlen( Puf ), Global );
			free( Puf );
			return( E_OK );
		}
		if( Events->msg[4] == WIN_PASTE )
		{
			BYTE	*Ret;
			LONG	Size;
			if( GetClipboard( "TXT", &Ret, &Size, Global ) == E_OK )
			{
				EVNT	Evnt;
				DD_INFO	DdInfo;
				DdInfo.format = '.TXT';
				DdInfo.mx = -1;
				DdInfo.my = -1;
				DdInfo.kstate = -1;
				DdInfo.size = Size;
				DdInfo.puf = Ret;
				Keytab->ExportString( TextWindow->KeyExport, Size, Ret );
				Evnt.mwhich = MU_MESAG;
				Evnt.msg[0] = WIN_CMD;
				Evnt.msg[1] = Global[2];
				Evnt.msg[2] = 0;
				Evnt.msg[3] = WinId;
				Evnt.msg[4] = WIN_DRAGDROP;
				*( DD_INFO ** )&( Evnt.msg[5] ) = &DdInfo;
				TextWindow->HandleUserTextWindow( WinId, &Evnt, TextWindow->UserData, Global );
				free( Ret );
			}
			return( E_OK );
		}
		if( Events->msg[4] == WIN_MARK_ALL )
		{
			XY	Start, End;
			Start.x = 0;
			Start.y = 0;
			End.x = TextWindow->Terminal.x - 1;
			End.y = TextWindow->nLine - 1;
			BlockTextWindow( WinId, &Start, &End, TextWindow );
			return( E_OK );
		}
		
		if( Events->msg[4] == WIN_FONT )
		{
			WORD	D;
			EVNT	Evnt;
			GRECT	Rect;

			vst_font( TextWindow->VdiHandle, TextWindow->FontId );
			vst_arbpt32( TextWindow->VdiHandle, TextWindow->FontPt, &D, &D, &D, &D );
			vst_color( TextWindow->VdiHandle, TextWindow->FontColor );
			vst_effects( TextWindow->VdiHandle, TextWindow->FontEffects );
			GetFontInfo( TextWindow->VdiHandle, &( TextWindow->CellHeight ), &( TextWindow->dBasicLine ), &( TextWindow->CellWidth ));
			vst_font( TextWindow->BmHandle, TextWindow->FontId );
			vst_arbpt32( TextWindow->BmHandle, TextWindow->FontPt, &D, &D, &D, &D );
			vst_color( TextWindow->BmHandle, TextWindow->FontColor );
			vst_effects( TextWindow->BmHandle, TextWindow->FontEffects );

			v_clsbm( TextWindow->BmHandle );
			TextWindow->BmHandle = NewBitmapTextWindow( WinId, TextWindow );

			GetMaxTextWindow( WinId, TextWindow, &( TextWindow->FullRect ), Global );
			GetMaxTextWindow( WinId, TextWindow, &( TextWindow->NextFuller ), Global );
			MT_wind_get_grect( WinId, WF_CURRXYWH, &Rect, Global );
			if( Rect.g_w > TextWindow->FullRect.g_w || Rect.g_h > TextWindow->FullRect.g_h )
			{
				Rect.g_w = TextWindow->FullRect.g_w;
				Rect.g_h = TextWindow->FullRect.g_h;
				MT_wind_set_grect( WinId, WF_CURRXYWH, &Rect, Global );
				MT_wind_get_grect( WinId, WF_WORKXYWH, &( TextWindow->WorkRect ), Global );
			}

			AdjustTextWindow( WinId, TextWindow, Global );
			SetHSliderTextWindow( WinId, TextWindow, Global );
			SetVSliderTextWindow( WinId, TextWindow, Global );

			Evnt.mwhich = MU_MESAG;
			Evnt.msg[0] = WM_REDRAW;
			Evnt.msg[1] = Global[2];
			Evnt.msg[2] = 0;
			Evnt.msg[3] = WinId;
			Evnt.msg[4] = TextWindow->WorkRect.g_x;
			Evnt.msg[5] = TextWindow->WorkRect.g_y;
			Evnt.msg[6] = TextWindow->WorkRect.g_w;
			Evnt.msg[7] = TextWindow->WorkRect.g_h;
			return( HandleMuMesagTextWindow( WinId, &Evnt, TextWindow, Global ));
		}

		if( Events->msg[4] == WIN_HELP )
			return( StGuide_Action( TreeAddr[POPUP_TEXT], POPUP_TEXT, Global ));

		if( Events->msg[4] == WIN_KONTEXT_1 )
			return( KontextTextWindow( WinId, TextWindow, Global ));
		if( Events->msg[4] == WIN_KONTEXT_2 )
			return( TextWindow->HandleUserTextWindow( WinId, Events, TextWindow->UserData, Global ));
	}
	
	if( Events->msg[0] == WIN_ACK )
	{
		if( Events->msg[4] == WIN_CLOSE )
		{
			EVNT	Evnt;
#ifdef	DEBUG
	DebugMsg( Global, "HandleMuMesagTextWindow (WIN_ACK, WIN_CLOSE)\n" );
#endif
			Evnt.mwhich = MU_MESAG;
			Evnt.msg[0] = WIN_CMD;
			Evnt.msg[1] = Global[2];
			Evnt.msg[2] = 0;
			Evnt.msg[3] = WinId;
			Evnt.msg[4] = WIN_DEL;
			TextWindow->HandleUserTextWindow( WinId, &Evnt, TextWindow->UserData, Global );
			CloseTextWindow( WinId, Global );
			return( E_OK );
		}
	}

	if( ( Events->msg[0] >= WIN_USER_LOW && Events->msg[0] <= WIN_USER_HIGH ))
		return( TextWindow->HandleUserTextWindow( WinId, Events, TextWindow->UserData, Global ));

/*--- WM_ARROWED ------------------------------------------------------------*/
	if( Events->msg[0] == WM_ARROWED )
	{
		if( Events->msg[4] == WA_UPPAGE || Events->msg[4] == WA_DNPAGE ||
		    Events->msg[4] == WA_UPLINE || Events->msg[4] == WA_DNLINE )
		{
			LONG	Pos = TextWindow->Pos.y;
			switch( Events->msg[4] )
			{
				case	WA_DNPAGE:	Pos += TextWindow->WorkRect.g_h / TextWindow->CellHeight; break;
				case	WA_UPPAGE:	Pos -= TextWindow->WorkRect.g_h / TextWindow->CellHeight; break;
				case	WA_DNLINE:	Pos++; break;
				case	WA_UPLINE:	Pos--; break;
			}
			if( Pos > TextWindow->nLine - TextWindow->WorkRect.g_h / TextWindow->CellHeight )
				Pos = TextWindow->nLine - TextWindow->WorkRect.g_h / TextWindow->CellHeight;
			if( Pos < 0 )
				Pos = 0;
			if( Pos != TextWindow->Pos.y )
			{
				WORD	Dy = ( WORD )( TextWindow->Pos.y - Pos );
				TextWindow->Pos.y = Pos;
				ScrollWindow( WinId, TextWindow->VdiHandle, 0, Dy * TextWindow->CellHeight, &( TextWindow->WorkRect ), DrawTextWindow, Global );
				SetVSliderTextWindow( WinId, TextWindow, Global );
			}
		}
		if( Events->msg[4] == WA_LFPAGE || Events->msg[4] == WA_RTPAGE ||
		    Events->msg[4] == WA_LFLINE || Events->msg[4] == WA_RTLINE )
		{
			LONG	Pos = TextWindow->Pos.x;
			switch( Events->msg[4] )
			{
				case	WA_RTPAGE:	Pos += TextWindow->WorkRect.g_w / TextWindow->CellWidth; break;
				case	WA_LFPAGE:	Pos -= TextWindow->WorkRect.g_w / TextWindow->CellWidth; break;
				case	WA_RTLINE:	Pos++; break;
				case	WA_LFLINE:	Pos--; break;
			}
			if( Pos > TextWindow->nCharMax - TextWindow->WorkRect.g_w / TextWindow->CellWidth )
				Pos = TextWindow->nCharMax - TextWindow->WorkRect.g_w / TextWindow->CellWidth;
			if( Pos < 0 )
				Pos = 0;
			if( Pos != TextWindow->Pos.x )
			{
				WORD	Dx = ( WORD )( TextWindow->Pos.x - Pos );
				TextWindow->Pos.x = Pos;
				SetHSliderTextWindow( WinId, TextWindow, Global );
				ScrollWindow( WinId, TextWindow->VdiHandle, Dx * TextWindow->CellWidth, 0, &( TextWindow->WorkRect ), DrawTextWindow, Global );
			}
		}
		return( E_OK );
	}
/*--- WM_CLOSED -------------------------------------------------------------*/
	if( Events->msg[0] == WM_CLOSED )
	{
		EVNT	Evnt;
		Evnt.mwhich = MU_MESAG;
		Evnt.msg[0] = WIN_CMD;
		Evnt.msg[1] = Global[2];
		Evnt.msg[2] = 0;
		Evnt.msg[3] = WinId;
		Evnt.msg[4] = WIN_CLOSE;
		Evnt.msg[5] = Events->msg[4];
		return( TextWindow->HandleUserTextWindow( WinId, &Evnt, TextWindow->UserData, Global ));
	}
/*--- WM_FULLED -------------------------------------------------------------*/
	if( Events->msg[0] == WM_FULLED )
	{
		EVNT	Evnt;
		GRECT	CurrRect;
		Evnt.mwhich = MU_MESAG;
		Evnt.msg[0] = WM_SIZED;
		Evnt.msg[1] = Global[2];
		Evnt.msg[2] = 0;
		Evnt.msg[3] = WinId;
		MT_wind_get_grect( WinId, WF_CURRXYWH, &CurrRect, Global );

		if( CurrRect.g_x != TextWindow->FullRect.g_x || CurrRect.g_y != TextWindow->FullRect.g_y )
		{
			Evnt.msg[4] = TextWindow->FullRect.g_x;
			Evnt.msg[5] = TextWindow->FullRect.g_y;
			Evnt.msg[6] = TextWindow->FullRect.g_w;
			Evnt.msg[7] = TextWindow->FullRect.g_h;
		}
		else
		{
			Evnt.msg[4] = TextWindow->NextFuller.g_x;
			Evnt.msg[5] = TextWindow->NextFuller.g_y;
			Evnt.msg[6] = TextWindow->NextFuller.g_w;
			Evnt.msg[7] = TextWindow->NextFuller.g_h;
		}
		TextWindow->NextFuller.g_x = CurrRect.g_x;
		TextWindow->NextFuller.g_y = CurrRect.g_y;
		TextWindow->NextFuller.g_w = CurrRect.g_w;
		TextWindow->NextFuller.g_h = CurrRect.g_h;
		HandleMuMesagTextWindow( WinId, &Evnt, TextWindow, Global );
		return( E_OK );
	}
/*--- WM_HSLID --------------------------------------------------------------*/
	if( Events->msg[0] == WM_HSLID )
	{
		LONG	Pos = TextWindow->Pos.x;
		TextWindow->Pos.x = (( LONG ) Events->msg[4] ) * ( TextWindow->nCharMax - (( LONG ) TextWindow->WorkRect.g_w / TextWindow->CellWidth )) / 1000L;
		if( Pos != TextWindow->Pos.x )
		{
			WORD	Dx = ( WORD )( Pos - TextWindow->Pos.x );
			SetHSliderTextWindow( WinId, TextWindow, Global );
			ScrollWindow( WinId, TextWindow->VdiHandle, Dx * TextWindow->CellWidth, 0, &( TextWindow->WorkRect ), DrawTextWindow, Global );
		}
		return( E_OK );
	}
/*--- WM_ICONIFY ------------------------------------------------------------*/
	if( Events->msg[0] == WM_ICONIFY )
	{
		MT_wind_set_grect( Events->msg[3], WF_ICONIFY, ( GRECT * ) &Events->msg[4], Global );
		MT_wind_get_grect( Events->msg[3], WF_WORKXYWH, &( TextWindow->WorkRect ), Global );
		IconifyWindow( Events->msg[3] );
		return( E_OK );
	}
/*--- WM_MOVED --------------------------------------------------------------*/
	if( Events->msg[0] == WM_MOVED )
	{
		MT_wind_set_grect( Events->msg[3], WF_CURRXYWH, ( GRECT * ) &Events->msg[4], Global );
		MT_wind_get_grect( Events->msg[3], WF_WORKXYWH, &( TextWindow->WorkRect ), Global );
		SetPosWindow( WinId, ( GRECT * ) &Events->msg[4] );
		return( E_OK );
	}
/*--- WM_REDRAW -------------------------------------------------------------*/
	if( Events->msg[0] == WM_REDRAW )
	{
		if( isIconifiedWindow( Events->msg[3] ))
			return( DrawIconifiedWindow( Events->msg[3], ( GRECT * ) &Events->msg[4], &( TextWindow->WorkRect ), TreeAddr[ICONIFY], Global ));
		else
		{
			GRECT	Box;
			MT_wind_update( BEG_UPDATE, Global );
			MT_graf_mouse( M_OFF, NULL, Global );
			MT_wind_get_grect( Events->msg[3], WF_FIRSTXYWH, &Box, Global );
			while( Box.g_w && Box.g_h )
			{
				if( RcInterSect( &ScreenRect, &Box ))
					if( RcInterSect(( GRECT * ) &Events->msg[4], &Box ))
						DrawTextWindow( Events->msg[3], &Box, &( TextWindow->WorkRect ));
				MT_wind_get_grect( Events->msg[3], WF_NEXTXYWH, &Box, Global );
			}
			MT_graf_mouse( M_ON, NULL, Global );
			MT_wind_update( END_UPDATE, Global );
			return( E_OK );
		}
	}
/*--- WM_SIZED --------------------------------------------------------------*/
	if( Events->msg[0] == WM_SIZED )
	{
		WORD	Kind, w2, w3, w4, Dx = 0, Dy = 0;
		if( Events->msg[6] > TextWindow->FullRect.g_w )
			Events->msg[6] = TextWindow->FullRect.g_w;
		if( Events->msg[7] > TextWindow->FullRect.g_h )
			Events->msg[7] = TextWindow->FullRect.g_h;
		
		MT_wind_get( WinId, WF_KIND, &Kind, &w2, &w3, &w4, Global );
		MT_wind_calc( WC_WORK, Kind, ( GRECT * ) &Events->msg[4], &( TextWindow->WorkRect ), Global );
		if(( TextWindow->WorkRect.g_w / TextWindow->CellWidth ) * TextWindow->CellWidth != TextWindow->WorkRect.g_w ||
		   ( TextWindow->WorkRect.g_h / TextWindow->CellHeight ) * TextWindow->CellHeight != TextWindow->WorkRect.g_h )
		{
			TextWindow->WorkRect.g_w = ( TextWindow->WorkRect.g_w / TextWindow->CellWidth ) * TextWindow->CellWidth;
			TextWindow->WorkRect.g_h = ( TextWindow->WorkRect.g_h / TextWindow->CellHeight ) * TextWindow->CellHeight;
			MT_wind_calc( WC_BORDER, Kind, &( TextWindow->WorkRect ), ( GRECT * ) &Events->msg[4], Global );
		}
		if( TextWindow->nCharMax - TextWindow->Pos.x < TextWindow->WorkRect.g_w / TextWindow->CellWidth && TextWindow->Pos.x > 0 )
		{
			LONG	HPos = TextWindow->Pos.x;
			TextWindow->Pos.x = TextWindow->nCharMax - TextWindow->WorkRect.g_w / TextWindow->CellWidth;
			Dx = ( WORD )(  HPos - TextWindow->Pos.x );
		}
		if( TextWindow->nLine - TextWindow->Pos.y < TextWindow->WorkRect.g_h / TextWindow->CellHeight && TextWindow->Pos.y > 0 )
		{
			LONG VPos = TextWindow->Pos.y;
			TextWindow->Pos.y = TextWindow->nLine - TextWindow->WorkRect.g_h / TextWindow->CellHeight;
			Dy = ( WORD )( VPos - TextWindow->Pos.y );
		}
		if( Dx || Dy )
			ScrollWindow( WinId, TextWindow->VdiHandle, Dx * TextWindow->CellWidth, Dy * TextWindow->CellHeight, &( TextWindow->WorkRect ), DrawTextWindow, Global );
		MT_wind_set_grect( Events->msg[3], WF_CURRXYWH, ( GRECT * ) &Events->msg[4], Global );
		AdjustTextWindow( WinId, TextWindow, Global );
		SetHSliderTextWindow( WinId, TextWindow, Global );
		SetVSliderTextWindow( WinId, TextWindow, Global );
		return( E_OK );
	}
/*--- WM_TOPPED -------------------------------------------------------------*/
	if( Events->msg[0] == WM_TOPPED )
	{
		if( !TextWindow->ModWin )
			MT_wind_set( Events->msg[3], WF_TOP, 0, 0, 0, 0, Global );
		else
			MT_wind_set( TextWindow->ModWin->WinId, WF_TOP, 0, 0, 0, 0, Global );
		return( E_OK );
	}
/*--- WM_UNICONIFY ----------------------------------------------------------*/
	if( Events->msg[0] == WM_UNICONIFY )
	{
		MT_wind_set_grect( Events->msg[3], WF_UNICONIFY, ( GRECT * ) &Events->msg[4], Global );
		MT_wind_get_grect( Events->msg[3], WF_WORKXYWH, &( TextWindow->WorkRect ), Global );
		UnIconifyWindow( Events->msg[3] );
		return( E_OK );
	}
/*--- WM_UNTOPPED -----------------------------------------------------------*/
	if( Events->msg[0] == WM_UNTOPPED )
	{
		return( E_OK );
	}
/*--- WM_VSLID --------------------------------------------------------------*/
	if( Events->msg[0] == WM_VSLID )
	{
		LONG	Pos = TextWindow->Pos.y;
		TextWindow->Pos.y = (( LONG ) Events->msg[4] ) * ( TextWindow->nLine - (( LONG ) TextWindow->WorkRect.g_h / TextWindow->CellHeight )) / 1000L;
		if( Pos != TextWindow->Pos.y )
		{
			WORD	Dy = ( WORD )( Pos - TextWindow->Pos.y );
			ScrollWindow( WinId, TextWindow->VdiHandle, 0, Dy * TextWindow->CellHeight, &( TextWindow->WorkRect ), DrawTextWindow, Global );
			SetVSliderTextWindow( WinId, TextWindow, Global );
		}
		return( E_OK );
	}
/*--- FONT_CHANGED ----------------------------------------------------------*/
	if( Events->msg[0] == FONT_CHANGED )
		return( TextWindow->HandleUserTextWindow( WinId, Events, TextWindow->UserData, Global ));
/*--- FONT_CHANGED ----------------------------------------------------------*/
	if( Events->msg[0] == COLOR_ID )
		return( TextWindow->HandleUserTextWindow( WinId, Events, TextWindow->UserData, Global ));
/*--- AP_DRAGDROP -----------------------------------------------------------*/
	if( Events->msg[0] == AP_DRAGDROP )
	{
		BYTE	*Ret;
		LONG	Size;
		ULONG	FormatRcvr[8], Format;
		FormatRcvr[0] = '.TXT';	FormatRcvr[1] = 'ARGS';	FormatRcvr[2] = 0;	FormatRcvr[3] = 0;
		FormatRcvr[4] = 0;	FormatRcvr[5] = 0;	FormatRcvr[6] = 0;	FormatRcvr[7] = 0;
		if( GetDragDrop( Events, FormatRcvr, &Format, &Ret, &Size ) == E_OK )
		{
			EVNT	Evnt;
			DD_INFO	DdInfo;
			DdInfo.format = '.TXT';
			DdInfo.mx = Events->msg[4];
			DdInfo.my = Events->msg[5];
			DdInfo.kstate = Events->msg[6];
			DdInfo.size = Size;
			DdInfo.puf = Ret;
			Keytab->ExportString( TextWindow->KeyExport, Size, Ret );
			Evnt.mwhich = MU_MESAG;
			Evnt.msg[0] = WIN_CMD;
			Evnt.msg[1] = Global[2];
			Evnt.msg[2] = 0;
			Evnt.msg[3] = WinId;
			Evnt.msg[4] = WIN_DRAGDROP;
			*( DD_INFO ** )&( Evnt.msg[5] ) = &DdInfo;
			TextWindow->HandleUserTextWindow( WinId, &Evnt, TextWindow->UserData, Global );
			free( Ret );
		}
		return( E_OK );
	}
	return( ERROR );
}
