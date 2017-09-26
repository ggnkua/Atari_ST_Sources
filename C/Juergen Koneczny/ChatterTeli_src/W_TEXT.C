#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<VDICOL.H>
#include	<MT_AES.H>
#include	<STDDEF.H>
#include	<STDLIB.H>
#include	<STRING.H>
#include	<stdio.h>

#include	<atarierr.h>

#include	"main.h"
#include	RSCHEADER
#include	"Emulator.h"
#include	"Help.h"
#include	"Menu.h"
#include	"Popup.h"
#include	"W_Text.h"
#include	"W_Text\Button.h"
#include	"W_Text\Cursor.h"
#include	"W_Text\Keybd.h"
#include	"W_Text\Mesag.h"
#include	"Window.h"

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern WORD	Global[15], AesHandle, WorkOut[57];
extern ULONG ScreenColors;
extern OBJECT	**TreeAddr;
extern GRECT	ScreenRect;

extern WORD	VqExtnd[48];
extern int	EdDI;

/*-----------------------------------------------------------------------------*/
/* Globale Variablen                                                           */
/*-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
static WORD	HandleTextWindow( WORD WinId, EVNT *Events, void *UserData, WORD Global[15] );
static void	DrawEmulationTextWindow( TEXT_WINDOW *TextWindow, XY *Start, XY *End );
static void	Scroll2PosTextWindow( WORD WinId, XY *Pos, TEXT_WINDOW *TextWindow, WORD Global[15] );
void	DrawBlockTextWindow( WORD WinId, XY *Start, XY *End, WORD Flag, TEXT_WINDOW *TextWindow );
static WORD CloseAlert( MOD_WIN **ModWin, WORD WinId );

WORD	OpenTextWindow( EMU_TYPE EmuType, WORD KeyFlag, WORD KeyExport, WORD KeyImport, LONG PufLines, XY *Terminal, XY *Tab, WORD FontId, LONG FontPt, WORD FontColor, WORD FontEffects, WORD WindowColor, HNDL_USER_TEXT_WINDOW HandleUserTextWindow, BYTE *Title, void *UserData, WORD Global[15] )
{
	TEXT_WINDOW	*New;
	GRECT			Rect, CurrRect;
	WORD			WorkOut[57], D, WinId;
	EVNT			Evnt;

	New = malloc( sizeof( TEXT_WINDOW ));
	if( !New )
		return( ENSMEM );

	New->FontId = FontId;
	New->FontPt = FontPt;
	New->FontColor = FontColor;
	New->FontEffects = FontEffects;
	New->WindowColor = WindowColor;
	New->Invers = 0;
	New->KeyExport = KeyExport;
	New->KeyImport = KeyImport;
	New->KeyFlag = KeyFlag;
	New->isFirst = 1;

	New->Terminal.x = Terminal->x;
	New->Terminal.y = Terminal->y;
	New->HandleUserTextWindow = HandleUserTextWindow;
	New->UserData = UserData;
	New->Pos.x = 0;
	New->Pos.y = 0;
	New->PufLines = PufLines;
	New->BlockStart.x = -1;
	New->BlockStart.y = -1;
	New->BlockEnd.x = -1;
	New->BlockEnd.y = -1;
	New->Cursor.x = 0;
	New->Cursor.y = 0;
	New->CursorFlag = C_ON;

	New->CloseId = 0;
	New->ModWin = NULL;
#ifdef	DEBUG
	DebugMsg( Global, "OpenTextWindow: EMU_InitData()\n" );
#endif
	New->EmuData = EMU_InitData( EmuType, KeyImport, KeyFlag, &( New->Terminal ), Tab, New->PufLines );
	New->nCharMax = EMU_GetNCharMax( New->EmuData );
	New->nLine = EMU_GetNLine( New->EmuData );
#ifdef	DEBUG
	DebugMsg( Global, "OpenTextWindow: OpenScreenWk()\n" );
#endif
	if(( New->VdiHandle = OpenScreenWk( AesHandle, WorkOut )) <= 0 )
	{
		free( New );
		return( ERROR );
	}
#ifdef	DEBUG
	DebugMsg( Global, "                VdiHandle = %i\n", New->VdiHandle );
#endif

	if( vq_gdos())
		vst_load_fonts( New->VdiHandle, 0 );
	vst_font( New->VdiHandle, New->FontId );
	vst_arbpt32( New->VdiHandle, New->FontPt, &D, &D, &D, &D );
	vst_color( New->VdiHandle, New->FontColor );
	vst_effects( New->VdiHandle, New->FontEffects );
	GetFontInfo( New->VdiHandle, &( New->CellHeight ), &( New->dBasicLine ), &( New->CellWidth ));

#ifdef	DEBUG
	DebugMsg( Global, "OpenTextWindow: NewBitmapTextWindow()\n" );
#endif
	New->GcBitmap.ctab = NULL;
	if( NewBitmapTextWindow( 0, New ) <= 0 )
	{
		MT_graf_mouse( M_SAVE, NULL, Global );
		MT_graf_mouse( ARROW, NULL, Global );
		MT_form_alert( 1, TreeAddr[ALERTS][BITMAP_FAILED].ob_spec.free_string, Global );
		MT_graf_mouse( M_RESTORE, NULL, Global );
		free( New );
		return( ERROR );
	}
#ifdef	DEBUG
	DebugMsg( Global, "                BmHandle = %i\n", New->BmHandle );
#endif

#ifdef	DEBUG
	DebugMsg( Global, "OpenTextWindow: wind_create()\n" );
#endif
	if(( WinId = MT_wind_create( NAME + CLOSER + FULLER + MOVER + INFO + SIZER + UPARROW + 
	                                  DNARROW + VSLIDE + LFARROW + RTARROW + HSLIDE + 
	                                  ICONIFIER, &Rect, Global )) < 0 )
	{
		v_clsbm( New->BmHandle );
		if( New->GcBitmap.ctab )
		{
			v_delete_ctab( New->VdiHandle, New->GcBitmap.ctab );
			New->GcBitmap.ctab = NULL;
		}
		v_clsvwk ( New->VdiHandle );
		free( New );
		return( ERROR );
	}
#ifdef	DEBUG
	DebugMsg( Global, "                WinId = %i\n", WinId );
#endif

	if( Title )
		New->Title = malloc( strlen( TreeAddr[TITLES][TITLE_WINDOW].ob_spec.free_string ) +
		                     strlen( Title ) + 2 );
	else
		New->Title = malloc( strlen( TreeAddr[TITLES][TITLE_WINDOW].ob_spec.free_string ) + 1 );
	if( !New->Title )
	{
		free( New );
		return( ENSMEM );
	}
	strcpy( New->Title, TreeAddr[TITLES][TITLE_WINDOW].ob_spec.free_string );

	if( Title )
	{
		strcat( New->Title, " " );
		strcat( New->Title, Title );
	}
	MT_wind_set_string( WinId, WF_NAME, New->Title, Global );
	New->Info = NULL;

	MT_wind_set( WinId, WF_BEVENT, 0x0001, 0, 0, 0, Global );

	NewWindow( WinId, WIN_TEXT_WINDOW, HandleTextWindow, MenuKontextTextWindow, New );

	GetMaxTextWindow( WinId, New, &Rect, Global );

	New->FullRect.g_x = Rect.g_x;
	New->FullRect.g_y = Rect.g_y;
	New->FullRect.g_w = Rect.g_w;
	New->FullRect.g_h = Rect.g_h;

	New->NextFuller.g_x = Rect.g_x;
	New->NextFuller.g_y = Rect.g_y;
	New->NextFuller.g_w = Rect.g_w;
	New->NextFuller.g_h = Rect.g_h;
	
	GetPosWindow( WinId, &CurrRect );
	if( CurrRect.g_x != -1 && CurrRect.g_y != -1 && CurrRect.g_w != -1 && CurrRect.g_h != -1 )
	{
		if( CurrRect.g_w > New->FullRect.g_w )
			CurrRect.g_w = New->FullRect.g_w;
		if( CurrRect.g_h > New->FullRect.g_h )
			CurrRect.g_h = New->FullRect.g_h;
		if( CurrRect.g_x > ScreenRect.g_x + ScreenRect.g_w )
			CurrRect.g_x = ScreenRect.g_x;
		if( CurrRect.g_y > ScreenRect.g_y + ScreenRect.g_h )
			CurrRect.g_y = ScreenRect.g_y;
		MT_wind_open( WinId, &CurrRect, Global );
		SetPosWindow( WinId, &CurrRect );
	}
	else
	{
		SetPosWindow( WinId, &Rect );
		MT_wind_open( WinId, &Rect, Global );
	}
	MT_wind_get_grect( WinId, WF_WORKXYWH, &( New->WorkRect ), Global );

	AdjustTextWindow( WinId, New, Global );
	SetHSliderTextWindow( WinId, New, Global );
	SetVSliderTextWindow( WinId, New, Global );

	Evnt.mwhich = MU_MESAG;
	Evnt.msg[0] = WIN_CMD;
	Evnt.msg[1] = Global[2];
	Evnt.msg[2] = 0;
	Evnt.msg[3] = WinId;
	Evnt.msg[4] = WIN_INIT;
#ifdef	DEBUG
	DebugMsg( Global, "OpenTextWindow: HandleUserTextWindow (WIN_INIT)\n" );
#endif
	New->WinId = WinId;
	HandleUserTextWindow( WinId, &Evnt, UserData, Global );
	return( E_OK );
}

void	CloseTextWindow( WORD WinId, WORD Global[15] )
{
	TEXT_WINDOW	*TextWindow = GetWindowData( WinId );
	EVNT	lEvents;

#ifdef	DEBUG
	DebugMsg( Global, "CloseTextWindow: WinId = %i\n", WinId );
#endif
	MT_wind_close( WinId, Global );
	MT_wind_delete( WinId, Global );

	while( TextWindow->ModWin )
	{
		lEvents.mwhich = MU_MESAG;
		lEvents.msg[0] = WM_CLOSED;
		lEvents.msg[1] = Global[2];
		lEvents.msg[2] = 0;
		lEvents.msg[3] = TextWindow->ModWin->WinId;
		lEvents.msg[4] = WIN_CLOSE_WITHOUT_DEMAND;
		HandleWindow( &lEvents, Global );
	}

	if( TextWindow->Title )
		free( TextWindow->Title );
	if( TextWindow->Info )
		free( TextWindow->Info );

	EMU_Del( TextWindow->EmuData );
	DelWindow( WinId );

	if( vq_gdos())
		vst_unload_fonts( TextWindow->BmHandle, 0 );
	v_clsbm( TextWindow->BmHandle );
	if( TextWindow->GcBitmap.ctab )
	{
		v_delete_ctab( TextWindow->VdiHandle, TextWindow->GcBitmap.ctab );
		TextWindow->GcBitmap.ctab = NULL;
	}

	if( vq_gdos())
		vst_unload_fonts( TextWindow->VdiHandle, 0 );
	v_clsvwk( TextWindow->VdiHandle );
	free( TextWindow );
}

static WORD	HandleTextWindow( WORD WinId, EVNT *Events, void *UserData, WORD Global[15] )
{
	if( Events->mwhich & MU_BUTTON )
		return( HandleMuButtonTextWindow( WinId, Events, ( TEXT_WINDOW * ) UserData, Global ));
	if( Events->mwhich & MU_KEYBD )
		return( HandleMuKeybdTextWindow( WinId, Events, ( TEXT_WINDOW * ) UserData, Global ));
	if( Events->mwhich & MU_MESAG )
		return( HandleMuMesagTextWindow( WinId, Events, ( TEXT_WINDOW * ) UserData, Global ));
	if( Events->mwhich & MU_TIMER )
		return( HandleMuTimerTextWindow( WinId, ( TEXT_WINDOW * ) UserData, Global ));
	return( ERROR );
}

void	DrawTextWindow( WORD WinId, GRECT *DrawRect, GRECT *WorkRect )
{
	TEXT_WINDOW	*TextWindow = GetWindowData( WinId );
#ifdef	DEBUG
	DebugMsg( Global, "DrawTextWindow: WinId = %i\n", WinId );
#endif
	if( EdDI >= 0x0120 && ( VqExtnd[30] & 0x0002 ) && ( ScreenColors == 0 || ScreenColors >= 256 ))
	{
		RECT16	Source, Dest;
#ifdef	DEBUG
	DebugMsg( Global, "DrawTextWindow: vr_transfer_bits()\n" );
#endif
		Source.x1 = DrawRect->g_x - TextWindow->WorkRect.g_x + ( WORD )( TextWindow->Pos.x * TextWindow->CellWidth );
		Source.y1 = DrawRect->g_y - TextWindow->WorkRect.g_y + ( WORD )( TextWindow->Pos.y * TextWindow->CellHeight );
		Source.x2 = Source.x1 + DrawRect->g_w - 1;	
		Source.y2 = Source.y1 + DrawRect->g_h - 1;
		Dest.x1 = DrawRect->g_x;
		Dest.y1 = DrawRect->g_y;
		Dest.x2 = Dest.x1 + DrawRect->g_w - 1;
		Dest.y2 = Dest.y1 + DrawRect->g_h - 1;
		vr_transfer_bits(( int16 ) TextWindow->VdiHandle, &( TextWindow->GcBitmap ), NULL, ( int16 * ) &Source, ( int16 * ) &Dest, T_REPLACE );
	}
	else
	{
		WORD	Pxy[8];
		MFDB	WindowMfdb;
#ifdef	DEBUG
	DebugMsg( Global, "DrawTextWindow: vro_cpyfm()\n" );
#endif
		WindowMfdb.fd_addr = NULL;
		Pxy[0] = DrawRect->g_x - TextWindow->WorkRect.g_x + ( WORD )( TextWindow->Pos.x * TextWindow->CellWidth );
		Pxy[1] = DrawRect->g_y - TextWindow->WorkRect.g_y + ( WORD )( TextWindow->Pos.y * TextWindow->CellHeight );
		Pxy[2] = Pxy[0] + DrawRect->g_w - 1;	
		Pxy[3] = Pxy[1] + DrawRect->g_h - 1;	
		Pxy[4] = DrawRect->g_x;
		Pxy[5] = DrawRect->g_y;
		Pxy[6] = Pxy[4] + DrawRect->g_w - 1;
		Pxy[7] = Pxy[5] + DrawRect->g_h - 1;
		vro_cpyfm( TextWindow->VdiHandle, S_ONLY, Pxy, &( TextWindow->Bitmap ), &WindowMfdb );
	}

#ifdef	DEBUG
	DebugMsg( Global, "DrawTextWindow: return\n" );
#endif
}

static void	DrawEmulationTextWindow( TEXT_WINDOW *TextWindow, XY *Start, XY *End )
{
	WORD	Pxy[4], x, y, Reverse, ForegroundColor, BackgroundColor, Effect;
	LONG	Row = Start->y, Column = Start->x;
	ATTR_ITEM	*AttrItem;
	CHAR			*Char;

#ifdef	DEBUG
	DebugMsg( Global, "DrawEmulationTextWindow: BmHandle = %i\n", TextWindow->BmHandle );
#endif

	if( TextWindow->isFirst )
	{
#ifdef	DEBUG
	DebugMsg( Global, "DrawEmulationTextWindow: isFirst\n" );
#endif
		TextWindow->isFirst = 0;
		return;
	}

	if( TextWindow->Invers )
	{
		Pxy[0] =	0;	Pxy[1] = 0;
		Pxy[2] = TextWindow->CellWidth * ( WORD ) TextWindow->Terminal.x;
		Pxy[3] = TextWindow->CellHeight * ( WORD )( TextWindow->Terminal.y + TextWindow->PufLines );
		vswr_mode( TextWindow->BmHandle, MD_XOR );
		vsf_color( TextWindow->BmHandle, 1 );
		v_bar( TextWindow->BmHandle, Pxy );
	}

	while( Row <= End->y )
	{
		Char = EMU_GetChar( Column, Row, TextWindow->EmuData );
		while( Char )
		{
			if( Start->y == End->y && 	Column > End->x )
				break;
			else	if( Row == End->y && Column > End->x )
				break;
				
			x = ( WORD )( Column * TextWindow->CellWidth );
			y = ( WORD )(( Row + 1 ) * TextWindow->CellHeight  - TextWindow->dBasicLine );

			ForegroundColor = TextWindow->FontColor;
			BackgroundColor = TextWindow->WindowColor;
			Effect = 0;
			Reverse = 0;

			AttrItem = Char->Attribut;
			while( AttrItem )
			{
				switch( AttrItem->Attr.A )
				{
					case	EMU_BOLD:
						Effect |= 0x01;
						break;
					case	EMU_LIGHT:
						Effect |= 0x02;
						break;
					case	EMU_ITALIC:
						Effect |= 0x04;
						break;
					case	EMU_LINE:
						Effect |= 0x08;
						break;
					case	EMU_DARK:
						Effect |= 0x02;
						break;
					case	EMU_FLASH:
						Effect |= 0x10;
						break;
					case	EMU_FLASHFLASH:
						Effect |= 0x20;
						break;
					case	EMU_REVERSE:
						Reverse = 1;
						break;
					case	EMU_FOREGROUND_COLOR:
						ForegroundColor = AttrItem->Attr.P;
						break;
					case	EMU_BACKGROUND_COLOR:
						BackgroundColor = AttrItem->Attr.P;
						break;
				}
				AttrItem = AttrItem->next;
			}

			if( Reverse )
			{
				WORD	C = ForegroundColor;
				ForegroundColor = BackgroundColor;
				BackgroundColor = C;
			}
			Pxy[0] =	x;	Pxy[1] = y + TextWindow->dBasicLine - 1;
			Pxy[2] = Pxy[0] + TextWindow->CellWidth - 1; Pxy[3] = Pxy[1] - TextWindow->CellHeight + 1;
			vswr_mode( TextWindow->BmHandle, MD_REPLACE );
			vsf_color( TextWindow->BmHandle, BackgroundColor );
			vst_effects( TextWindow->BmHandle, Effect );
			v_bar( TextWindow->BmHandle, Pxy );

			if( Char->C[0] )
			{
				vswr_mode( TextWindow->BmHandle, MD_TRANS );
				vst_color( TextWindow->BmHandle, ForegroundColor );
				v_gtext( TextWindow->BmHandle, x, y, Char->C );
			}
			Char = Char->next;

			Column++;
		}
		Column = 0;
		Row++;
	}

	if( TextWindow->Invers )
	{
		Pxy[0] =	0;	Pxy[1] = 0;
		Pxy[2] = TextWindow->CellWidth * ( WORD ) TextWindow->Terminal.x;
		Pxy[3] = TextWindow->CellHeight * ( WORD )( TextWindow->Terminal.y + TextWindow->PufLines );
		vswr_mode( TextWindow->BmHandle, MD_XOR );
		vsf_color( TextWindow->BmHandle, 1 );
		v_bar( TextWindow->BmHandle, Pxy );
	}
}

void	AdjustTextWindow( WORD WinId, TEXT_WINDOW *TextWindow, WORD Global[15] )
{
	GRECT	CurrRect;
	WORD	Kind, w2, w3, w4;
	MT_wind_get( WinId, WF_KIND, &Kind, &w2, &w3, &w4, Global );
	TextWindow->WorkRect.g_w = ( TextWindow->WorkRect.g_w / TextWindow->CellWidth ) * TextWindow->CellWidth;
	TextWindow->WorkRect.g_h = ( TextWindow->WorkRect.g_h / TextWindow->CellHeight ) * TextWindow->CellHeight;
	MT_wind_calc( WC_BORDER, Kind, &( TextWindow->WorkRect ), &CurrRect, Global );

	while( CurrRect.g_w > ScreenRect.g_w || CurrRect.g_w > TextWindow->FullRect.g_w )
	{
		CurrRect.g_w -= TextWindow->CellWidth;
		TextWindow->WorkRect.g_w -= TextWindow->CellWidth;
	}
	while( CurrRect.g_h > ScreenRect.g_h || CurrRect.g_h > TextWindow->FullRect.g_h )
	{
		CurrRect.g_h -= TextWindow->CellHeight;
		TextWindow->WorkRect.g_h -= TextWindow->CellHeight;
	}

	MT_wind_set_grect( WinId, WF_CURRXYWH, &CurrRect, Global );
	SetPosWindow( WinId, &CurrRect );
}

void	SetVSliderTextWindow( WORD WinId, TEXT_WINDOW *TextWindow, WORD Global[15] )
{
	WORD	Pos, Size = 1000;
	WORD	w1, w2, w3, w4;

	if( TextWindow->nLine > TextWindow->WorkRect.g_h / TextWindow->CellHeight )
		Size = ( WORD )( 1000L * (( LONG ) TextWindow->WorkRect.g_h ) / (( LONG ) TextWindow->CellHeight ) / TextWindow->nLine );
	MT_wind_get( WinId, WF_VSLSIZE, &w1, &w2, &w3, &w4, Global );
	if( w1 != Size )
		MT_wind_set( WinId, WF_VSLSIZE, Size, 0, 0, 0, Global );

	if( TextWindow->nLine == TextWindow->WorkRect.g_h / TextWindow->CellHeight )
		Pos = 1;
	else
		Pos = ( WORD )( 1000L * TextWindow->Pos.y / ( TextWindow->nLine - (( LONG ) TextWindow->WorkRect.g_h / TextWindow->CellHeight )));
	MT_wind_get( WinId, WF_VSLIDE, &w1, &w2, &w3, &w4, Global );
	if( w1 != Pos )
		MT_wind_set( WinId, WF_VSLIDE, Pos, 0, 0, 0, Global );
}

void	SetHSliderTextWindow( WORD WinId, TEXT_WINDOW *TextWindow, WORD Global[15] )
{
	WORD	Pos, Size = 1000;
	WORD	w1, w2, w3, w4;

	if( TextWindow->nCharMax > TextWindow->WorkRect.g_w / TextWindow->CellWidth )
		Size = ( WORD )( 1000L * (( LONG ) TextWindow->WorkRect.g_w ) / (( LONG ) TextWindow->CellWidth ) / TextWindow->nCharMax );
	MT_wind_get( WinId, WF_HSLSIZE, &w1, &w2, &w3, &w4, Global );
	if( w1 != Size )
		MT_wind_set( WinId, WF_HSLSIZE, Size, 0, 0, 0, Global );

	if( TextWindow->nCharMax == TextWindow->WorkRect.g_w / TextWindow->CellWidth )
		Pos = 1;
	else
		Pos = ( WORD )( 1000L * TextWindow->Pos.x / ( TextWindow->nCharMax - (( LONG ) TextWindow->WorkRect.g_w / TextWindow->CellWidth )));
	MT_wind_get( WinId, WF_HSLIDE, &w1, &w2, &w3, &w4, Global );
	if( w1 != Pos )
		MT_wind_set( WinId, WF_HSLIDE, Pos, 0, 0, 0, Global );
}

void	GetFontInfo( WORD VdiHandle, WORD *CellHeight, WORD *dBasicLine, WORD *CellWidth )
{
	WORD	D, Distances[5], Effects[3];
	vqt_fontinfo( VdiHandle, &D, &D, Distances, &D, Effects );
	*CellHeight =  Distances[4] + Distances[0] + 1;
	*dBasicLine = Distances[0] + 1;
	vqt_width( VdiHandle, ' ', CellWidth, &D, &D );	
}

LONG	AppendBlockTextWindow( WORD WinId, BYTE *Text, LONG Len, WORD Global[15] )
{
	TEXT_WINDOW	*TextWindow = GetWindowData( WinId );
	EVNT	Events;
	XY_ITEM	*RedrawXy;
	LONG	nCharMax, nLine, WorkedLen;
	WORD	Invers = TextWindow->Invers;

	WorkedLen = EMU_AppendText( Text, Len, &RedrawXy, &( TextWindow->Invers ), TextWindow->EmuData );

	if( Invers != TextWindow->Invers )
	{
		WORD	Pxy[4];
		Pxy[0] =	0;	Pxy[1] = 0;
		Pxy[2] = TextWindow->CellWidth * ( WORD ) TextWindow->Terminal.x;
		Pxy[3] = TextWindow->CellHeight * ( WORD )( TextWindow->Terminal.y + TextWindow->PufLines );
		vswr_mode( TextWindow->BmHandle, MD_XOR );
		vsf_color( TextWindow->BmHandle, 1 );
		v_bar( TextWindow->BmHandle, Pxy );
		Events.mwhich = MU_MESAG;
		Events.msg[0] = WM_REDRAW;
		Events.msg[1] = Global[2];
		Events.msg[2] = 0;
		Events.msg[3] = WinId;
		Events.msg[4] = TextWindow->WorkRect.g_x;
		Events.msg[5] = TextWindow->WorkRect.g_y;
		Events.msg[6] = TextWindow->WorkRect.g_w;
		Events.msg[7] = TextWindow->WorkRect.g_h;
		HandleMuMesagTextWindow( WinId, &Events, TextWindow, Global );
	}
	if( WorkedLen )
	{
/*		FILE	*File	= fopen( "C:\\tmp\\Teli.out", "ab" );
fprintf( File, "---\n");*/
		CursorOffTextWindow( WinId, TextWindow, Global);
		TextWindow->CursorFlag &= ~C_ON;

		while( RedrawXy )
		{
/*			fprintf( File, "%li,%li,%li,%li\n", RedrawXy->Start.x, RedrawXy->Start.y, RedrawXy->End.x, RedrawXy->End.y );*/

			if( TextWindow->BlockStart.x != -1 && TextWindow->BlockStart.y != -1 &&
		    TextWindow->BlockEnd.x != -1 && TextWindow->BlockEnd.y != -1 )
				DrawBlockTextWindow( WinId, &( TextWindow->BlockStart ), &( TextWindow->BlockEnd ), 0, TextWindow );
			DrawEmulationTextWindow( TextWindow, &( RedrawXy->Start ), &( RedrawXy->End ));
				if( TextWindow->BlockStart.x != -1 && TextWindow->BlockStart.y != -1 &&
			    TextWindow->BlockEnd.x != -1 && TextWindow->BlockEnd.y != -1 )
				DrawBlockTextWindow( WinId, &( TextWindow->BlockStart ), &( TextWindow->BlockEnd ), 0, TextWindow );
			if( RedrawXy->Start.y == RedrawXy->End.y )
			{
				Events.msg[4] = TextWindow->WorkRect.g_x + (( WORD )( RedrawXy->Start.x - TextWindow->Pos.x )) * TextWindow->CellWidth;
				Events.msg[6] = (( WORD )( RedrawXy->End.x - RedrawXy->Start.x + 1 )) * TextWindow->CellWidth;
			}
			else
			{
				Events.msg[4] = TextWindow->WorkRect.g_x;
				Events.msg[6] = TextWindow->WorkRect.g_w;
			}
			Events.mwhich = MU_MESAG;
			Events.msg[0] = WM_REDRAW;
			Events.msg[1] = Global[2];
			Events.msg[2] = 0;
			Events.msg[3] = WinId;
			Events.msg[5] = TextWindow->WorkRect.g_y + (( WORD )( RedrawXy->Start.y - TextWindow->Pos.y )) * TextWindow->CellHeight;
			Events.msg[7] = (( WORD )( RedrawXy->End.y - RedrawXy->Start.y + 1 )) * TextWindow->CellHeight;
			if( !isIconifiedWindow( WinId ) && WorkedLen <= 2 )
				HandleMuMesagTextWindow( WinId, &Events, TextWindow, Global );
			RedrawXy = RedrawXy->next;
		}

/*		fclose( File );*/

		if( EMU_GetCursor( &( TextWindow->Cursor ), TextWindow->EmuData ))
			TextWindow->CursorFlag |= C_ON;
		else
			TextWindow->CursorFlag &= ~C_ON;

		if(( nCharMax = EMU_GetNCharMax( TextWindow->EmuData )) > TextWindow->nCharMax )
		{
			TextWindow->nCharMax = nCharMax;
			if( !isIconifiedWindow( WinId ))
				SetHSliderTextWindow( WinId, TextWindow, Global );
		}
		if(( nLine = EMU_GetNLine( TextWindow->EmuData )) > TextWindow->nLine )
		{
			TextWindow->nLine = nLine;
			if( !isIconifiedWindow( WinId ))
				SetVSliderTextWindow( WinId, TextWindow, Global );
		}

		{
			WORD	dHpos = 0, dVpos = 0;
			if( TextWindow->nLine > TextWindow->Pos.y + TextWindow->WorkRect.g_h / TextWindow->CellHeight )
				dVpos = TextWindow->nLine - TextWindow->Pos.y - TextWindow->WorkRect.g_h / TextWindow->CellHeight;
			if( TextWindow->Cursor.x < TextWindow->Pos.x )
				dHpos = TextWindow->Cursor.x - TextWindow->Pos.x;
			if( TextWindow->Cursor.x >= TextWindow->Pos.x + TextWindow->WorkRect.g_w / TextWindow->CellWidth )
			{
				if( TextWindow->Cursor.x < TextWindow->Terminal.x )
					dHpos = TextWindow->Cursor.x - TextWindow->Pos.x - TextWindow->WorkRect.g_w / TextWindow->CellWidth + 1;
				else
					dHpos = TextWindow->Cursor.x - 1 - TextWindow->Pos.x - TextWindow->WorkRect.g_w / TextWindow->CellWidth + 1;
			}
			if( dVpos == 0 )
			{
				if( TextWindow->Cursor.y < TextWindow->Pos.y )
					dVpos = TextWindow->Cursor.y - TextWindow->Pos.y;
				if( TextWindow->Cursor.y >= TextWindow->Pos.y + TextWindow->WorkRect.g_h / TextWindow->CellHeight )
					dVpos = TextWindow->Cursor.y - TextWindow->Pos.y - TextWindow->WorkRect.g_h / TextWindow->CellHeight + 1;
			}

			if( dHpos || dVpos )
			{
				if( !isIconifiedWindow( WinId ))
				{
					TextWindow->Pos.x += dHpos;
					TextWindow->Pos.y += dVpos;
					if( WorkedLen <= 2 )
						ScrollWindow( WinId, TextWindow->VdiHandle, -dHpos * TextWindow->CellWidth, -dVpos * TextWindow->CellHeight, &( TextWindow->WorkRect ), DrawTextWindow, Global );
					SetHSliderTextWindow( WinId, TextWindow, Global );
					SetVSliderTextWindow( WinId, TextWindow, Global );
				}
			}
		}
			Events.mwhich = MU_MESAG;
			Events.msg[0] = WM_REDRAW;
			Events.msg[1] = Global[2];
			Events.msg[2] = 0;
			Events.msg[3] = WinId;
			Events.msg[4] = TextWindow->WorkRect.g_x;
			Events.msg[5] = TextWindow->WorkRect.g_y;
			Events.msg[6] = TextWindow->WorkRect.g_w;
			Events.msg[7] = TextWindow->WorkRect.g_h;
			if( !isIconifiedWindow( WinId ) && WorkedLen > 2 )
				HandleMuMesagTextWindow( WinId, &Events, TextWindow, Global );

		CursorOnTextWindow( WinId, TextWindow, Global);
	}
	return( WorkedLen );
}

static void	Scroll2PosTextWindow( WORD WinId, XY *Pos, TEXT_WINDOW *TextWindow, WORD Global[15] )
{
	WORD	dHPos = 0, dVPos = 0, ScrollFlag = 0;

	if( TextWindow->Pos.y != Pos->y )
	{
		dVPos = ( WORD )( TextWindow->Pos.y - Pos->y );
		TextWindow->Pos.y = Pos->y;
		ScrollFlag = 1;
	}
	if( TextWindow->Pos.x != Pos->x )
	{
		dVPos = ( WORD )( TextWindow->Pos.x - Pos->x );
		TextWindow->Pos.x = Pos->x;
		ScrollFlag = 1;
	}

/*	if( Pos->y >= TextWindow->Pos.y + TextWindow->WorkRect.g_h / TextWindow->CellHeight )
	{
		dVPos = ( WORD )( TextWindow->Pos.y - ( Pos->y - TextWindow->WorkRect.g_h / TextWindow->CellHeight + 1 ));
		TextWindow->Pos.y = Pos->y - TextWindow->WorkRect.g_h / TextWindow->CellHeight + 1;
		ScrollFlag = 1;
	}
	if( Pos->x >= TextWindow->Pos.x + TextWindow->WorkRect.g_w / TextWindow->CellWidth )
	{
		dHPos = ( WORD )( TextWindow->Pos.x - ( Pos->x - TextWindow->WorkRect.g_w / TextWindow->CellWidth + 1 ));
		TextWindow->Pos.x = Pos->x - TextWindow->WorkRect.g_w / TextWindow->CellWidth + 1;
		ScrollFlag = 1;
	}
	if( Pos->x < TextWindow->Pos.x )
	{
		dHPos = ( WORD )( TextWindow->Pos.x - Pos->x );
		TextWindow->Pos.x = ( WORD ) Pos->x;
		ScrollFlag = 1;
	}*/

	if( ScrollFlag )
	{
		ScrollWindow( WinId, TextWindow->VdiHandle, dHPos * TextWindow->CellWidth, dVPos * TextWindow->CellHeight, &( TextWindow->WorkRect ), DrawTextWindow, Global );
		SetHSliderTextWindow( WinId, TextWindow, Global );
		SetVSliderTextWindow( WinId, TextWindow, Global );
	}
}

ULONG	MenuKontextTextWindow( WORD WinId, WORD Global[15] )
{
	TEXT_WINDOW	*TextWindow = GetWindowData( WinId );
	ULONG	Ret = 0;

	if( !( TextWindow->BlockStart.x == -1 && TextWindow->BlockStart.y == -1 &&
	    TextWindow->BlockEnd.x == -1 && TextWindow->BlockEnd.y == -1 ))
		Ret |= MENUE_KONTEXT_COPY;

	Ret |= MENUE_KONTEXT_PASTE;
	if( TextWindow->nCharMax )
		if( !( TextWindow->BlockStart.x == 0 && TextWindow->BlockStart.y == 0 &&
		       TextWindow->BlockEnd.x == EMU_GetNCharLine( TextWindow->nLine - 1, TextWindow->EmuData ) && TextWindow->BlockEnd.y == TextWindow->nLine - 1 ))
		Ret |= MENUE_KONTEXT_MARK_ALL;

	Ret |= MENUE_KONTEXT_KONTEXT;
	Ret |= MENUE_KONTEXT_WINDOW_CYCLE;
	Ret |= MENUE_KONTEXT_WINDOW_CLOSE;
	Ret |= MENUE_KONTEXT_WINDOW_FULL;

	return( Ret );
}

void	BlockTextWindow( WORD WinId, XY *BlockStart, XY *BlockEnd, TEXT_WINDOW *TextWindow )
{
	XY	Start, End;
	CursorOffTextWindow( WinId, TextWindow, Global);
	if( TextWindow->BlockStart.x == -1 && TextWindow->BlockStart.y == -1 &&
	    TextWindow->BlockEnd.x == -1 && TextWindow->BlockEnd.y == -1 )
	{
		DrawBlockTextWindow( WinId, BlockStart, BlockEnd, 1, TextWindow );
	}
	else	if( BlockStart->x == -1 && BlockStart->y == -1 && BlockEnd->x == -1 && BlockEnd->y == -1 )
	{
		DrawBlockTextWindow( WinId, &( TextWindow->BlockStart ), &( TextWindow->BlockEnd ), 1, TextWindow );
	}
	else	if( TextWindow->BlockStart.x == BlockStart->x && TextWindow->BlockStart.y == BlockStart->y )
	{
		if( BlockEnd->y < TextWindow->BlockEnd.y || 
		    ( BlockEnd->y == TextWindow->BlockEnd.y && BlockEnd->x < TextWindow->BlockEnd.x ))
		{
			Start.x = BlockEnd->x + 1;	Start.y = BlockEnd->y;
			End.x = TextWindow->BlockEnd.x;	End.y = TextWindow->BlockEnd.y;
			DrawBlockTextWindow( WinId, &Start, &End, 1, TextWindow );
		}
		else
		{
			Start.x = TextWindow->BlockEnd.x + 1;
			Start.y = TextWindow->BlockEnd.y;
			DrawBlockTextWindow( WinId, &Start, BlockEnd, 1, TextWindow );
		}
	}
	else	if( TextWindow->BlockEnd.x == BlockEnd->x && TextWindow->BlockEnd.y == BlockEnd->y )
	{
		if( BlockStart->y < TextWindow->BlockStart.y || 
		    ( BlockStart->y == TextWindow->BlockStart.y && BlockStart->x < TextWindow->BlockStart.x ))
		{
			Start.x = BlockStart->x;	Start.y = BlockStart->y;
			End.x = TextWindow->BlockStart.x - 1;	End.y = TextWindow->BlockStart.y;
			DrawBlockTextWindow( WinId, &Start, &End, 1, TextWindow );
		}
		else
		{
			End.x = BlockStart->x - 1;
			End.y = BlockStart->y;
			DrawBlockTextWindow( WinId, &( TextWindow->BlockStart ), &End, 1, TextWindow );
		}
	}
	else
	{
		DrawBlockTextWindow( WinId, &( TextWindow->BlockStart ), &( TextWindow->BlockEnd ), 1, TextWindow );
		DrawBlockTextWindow( WinId, BlockStart, BlockEnd, 1, TextWindow );
	}

	TextWindow->BlockStart.x = BlockStart->x;
	TextWindow->BlockStart.y = BlockStart->y;
	TextWindow->BlockEnd.x = BlockEnd->x;
	TextWindow->BlockEnd.y = BlockEnd->y;
	CursorOnTextWindow( WinId, TextWindow, Global);
}

void	DrawBlockTextWindow( WORD WinId, XY *Start, XY *End, WORD Flag, TEXT_WINDOW *TextWindow )
{
	WORD	Pxy[4];
	vswr_mode( TextWindow->BmHandle, MD_XOR );
	vsf_perimeter( TextWindow->BmHandle, 0 );
	vsf_interior( TextWindow->BmHandle, 1 );
	vsf_color( TextWindow->BmHandle, 1 );

	Pxy[0] = ( WORD )( TextWindow->CellWidth * Start->x );
	Pxy[1] = ( WORD )( TextWindow->CellHeight * Start->y );
	Pxy[2] = ( WORD )( TextWindow->CellWidth * ( Start->y == End->y ? End->x + 1 : TextWindow->Terminal.x )) - 1;
	Pxy[3] = Pxy[1] + TextWindow->CellHeight - 1;
	v_bar( TextWindow->BmHandle, Pxy );
	if( Flag )
	{
		EVNT	Events;
		Events.mwhich = MU_MESAG;
		Events.msg[0] = WM_REDRAW;
		Events.msg[1] = Global[2];
		Events.msg[2] = 0;
		Events.msg[3] = WinId;
		Events.msg[4] = TextWindow->WorkRect.g_x + (( WORD )( Start->x - TextWindow->Pos.x )) * TextWindow->CellWidth;
		Events.msg[5] = TextWindow->WorkRect.g_y + (( WORD )( Start->y - TextWindow->Pos.y )) * TextWindow->CellHeight;
		Events.msg[6] = (( WORD )(( Start->y == End->y ? End->x + 1 : TextWindow->Terminal.x ) - Start->x )) * TextWindow->CellWidth;
		Events.msg[7] = TextWindow->CellHeight;
		HandleMuMesagTextWindow( WinId, &Events, TextWindow, Global );
	}

	if( End->y > Start->y + 1 )
	{
		Pxy[0] = 0;
		Pxy[1] = ( WORD )( TextWindow->CellHeight * ( Start->y + 1 ));
		Pxy[2] = ( WORD )( TextWindow->CellWidth * TextWindow->Terminal.x ) - 1;
		Pxy[3] = ( WORD )( TextWindow->CellHeight * End->y ) - 1;
		v_bar( TextWindow->BmHandle, Pxy );
		if( Flag )
		{
			EVNT	Events;
			Events.mwhich = MU_MESAG;
			Events.msg[0] = WM_REDRAW;
			Events.msg[1] = Global[2];
			Events.msg[2] = 0;
			Events.msg[3] = WinId;
			Events.msg[4] = TextWindow->WorkRect.g_x - (( WORD ) TextWindow->Pos.x ) * TextWindow->CellWidth;
			Events.msg[5] = TextWindow->WorkRect.g_y + (( WORD )( Start->y + 1 - TextWindow->Pos.y )) * TextWindow->CellHeight;
			Events.msg[6] = (( WORD )( TextWindow->Terminal.x )) * TextWindow->CellWidth;
			Events.msg[7] = (( WORD )( End->y - Start->y - 1 )) * TextWindow->CellHeight;
			HandleMuMesagTextWindow( WinId, &Events, TextWindow, Global );
		}
	}
	if( End->y > Start->y )
	{
		Pxy[0] = 0;
		Pxy[1] = ( WORD )( TextWindow->CellHeight * End->y );
		Pxy[2] = ( WORD )( TextWindow->CellWidth * ( End->x + 1 )) - 1;
		Pxy[3] = ( WORD )( TextWindow->CellHeight * ( End->y + 1 )) - 1;
		v_bar( TextWindow->BmHandle, Pxy );
		if( Flag )
		{
			EVNT	Events;
			Events.mwhich = MU_MESAG;
			Events.msg[0] = WM_REDRAW;
			Events.msg[1] = Global[2];
			Events.msg[2] = 0;
			Events.msg[3] = WinId;
			Events.msg[4] = TextWindow->WorkRect.g_x - (( WORD ) TextWindow->Pos.x ) * TextWindow->CellWidth;
			Events.msg[5] = TextWindow->WorkRect.g_y + (( WORD )( End->y - TextWindow->Pos.y )) * TextWindow->CellHeight;
			Events.msg[6] = (( WORD )( End->x + 1 )) * TextWindow->CellWidth;
			Events.msg[7] = TextWindow->CellHeight;
			HandleMuMesagTextWindow( WinId, &Events, TextWindow, Global );
		}
	}
}

BYTE	*GetBlockTextWindow( TEXT_WINDOW	*TextWindow )
{
	BYTE	*Puf = malloc( TextWindow->nCharMax * ( TextWindow->BlockEnd.y - TextWindow->BlockStart.y + 2 ) + 3 );
	CHAR	*Char;
	long	i, j = 0;

	if( !Puf )
		return( NULL );

	for( i = TextWindow->BlockStart.y; i <= TextWindow->BlockEnd.y; i++ )
	{
		if( i == TextWindow->BlockStart.y && i != TextWindow->BlockEnd.y )
			Char = EMU_GetChar( TextWindow->BlockStart.x, i, TextWindow->EmuData );
		else	if( i == TextWindow->BlockEnd.y )
		{
			long	k = i == TextWindow->BlockStart.y ? TextWindow->BlockStart.x : 0;
			Char = EMU_GetChar( k, i, TextWindow->EmuData );
			while( Char && k <= TextWindow->BlockEnd.x )
			{
				Puf[j++] = Char->C[0];
				k++;
				Char = Char->next;
			}
			break;
		}
		else
		{
			Char = EMU_GetChar( 0, i, TextWindow->EmuData );
		}
		while( Char )
		{
			Puf[j++] = Char->C[0];
			Char = Char->next;
		}
		Puf[j++] = '\r';
		Puf[j++] = '\n';
	}
	Puf[j] = 0;
	return( Puf );
}

void	SetInfoTextWindow( WORD WinId, BYTE *Info, WORD Global[15] )
{
	TEXT_WINDOW	*TextWindow = GetWindowData( WinId );

	if( TextWindow->Info )
		free( TextWindow->Info );
	TextWindow->Info = malloc( strlen( Info ) + 2 );
	if( TextWindow->Info )
	{
		strcpy( TextWindow->Info, " " );
		strcat( TextWindow->Info, Info );
	}
	MT_wind_set_string( WinId, WF_INFO, TextWindow->Info, Global );
}

void	GetMaxTextWindow( WORD WinId, TEXT_WINDOW *TextWindow, GRECT *Rect, WORD Global[15] )
{
	GRECT	WorkRect, FullRect;
	WORD	Kind, w2, w3, w4;

	MT_wind_get( WinId, WF_KIND, &Kind, &w2, &w3, &w4, Global );

	WorkRect.g_x = 50;
	WorkRect.g_y = 50;
	WorkRect.g_w = (( WORD )( TextWindow->CellWidth * TextWindow->Terminal.x ));
	WorkRect.g_h = (( WORD )( TextWindow->CellHeight * TextWindow->Terminal.y ));

	MT_wind_calc( WC_BORDER, Kind, &WorkRect, Rect, Global );
	MT_wind_get_grect( 0, WF_WORKXYWH, &FullRect, Global );

	Rect->g_x = FullRect.g_x;
	Rect->g_y = FullRect.g_y;
}

WORD	NewBitmapTextWindow( WORD WinId, TEXT_WINDOW *TextWindow )
{
	WORD	D, Pxy[4];
	XY		Start, End;

#ifdef	DEBUG
	DebugMsg( Global, "NewBitmapTextWindow: EdDI = %x\n", EdDI );
	DebugMsg( Global, "                     VqExtnd[30] = %i\n", VqExtnd[30] );
	DebugMsg( Global, "                     ScreenColors = %lu\n", ScreenColors );
#endif
	if( EdDI >= 0x0120 && ( VqExtnd[30] & 0x0002 ) && ( ScreenColors == 0 || ScreenColors >= 256 ))
	{
#ifdef	DEBUG
		DebugMsg( Global, "NewBitmapTextWindow: v_open_bm()\n" );
#endif
		TextWindow->GcBitmap.magic = CBITMAP_MAGIC;
		TextWindow->GcBitmap.length = sizeof( GCBITMAP );
		TextWindow->GcBitmap.format = 0;
		TextWindow->GcBitmap.reserved = 0L;
		TextWindow->GcBitmap.addr = NULL;
		TextWindow->GcBitmap.width = 0;
		TextWindow->GcBitmap.bits = PX_PREF8 & PX_BITS;
		TextWindow->GcBitmap.px_format = PX_PREF8;
		TextWindow->GcBitmap.xmin = 0;
		TextWindow->GcBitmap.ymin = 0;
		TextWindow->GcBitmap.xmax = TextWindow->CellWidth * ( WORD ) TextWindow->Terminal.x;
		TextWindow->GcBitmap.ymax = TextWindow->CellHeight * ( WORD ) ( TextWindow->Terminal.y + TextWindow->PufLines );
		TextWindow->GcBitmap.ctab = v_create_ctab( TextWindow->VdiHandle, CSPACE_RGB, PX_PREF8 );;
		vq_ctab( TextWindow->VdiHandle, sizeof( COLOR_TAB ) + 256 * sizeof( COLOR_ENTRY ), TextWindow->GcBitmap.ctab );
		TextWindow->GcBitmap.itab = NULL;
		TextWindow->GcBitmap.reserved0 = 0L;
		TextWindow->GcBitmap.reserved1 = 0L;
		if(( TextWindow->BmHandle = v_open_bm( TextWindow->VdiHandle, &( TextWindow->GcBitmap ), 0, 0,
		                                       TextWindow->CellWidth * ( WORD ) TextWindow->Terminal.x, TextWindow->CellHeight * ( WORD ) ( TextWindow->Terminal.y + TextWindow->PufLines ))) == 0 )
			return( ERROR );
	}
	else
		if(( TextWindow->BmHandle = OpenBitmap( TextWindow->CellWidth * ( WORD ) TextWindow->Terminal.x, TextWindow->CellHeight * ( WORD ) ( TextWindow->Terminal.y + TextWindow->PufLines ), TextWindow->VdiHandle, &( TextWindow->Bitmap ))) <= 0 )
			return( ERROR );

	if( vq_gdos())
		vst_load_fonts(  TextWindow->BmHandle, 0 );
	vst_font( TextWindow->BmHandle, TextWindow->FontId );
	vst_arbpt32( TextWindow->BmHandle, TextWindow->FontPt, &D, &D, &D, &D );
	vst_color( TextWindow->BmHandle, TextWindow->FontColor );
	vst_effects( TextWindow->BmHandle, TextWindow->FontEffects );

	Start.x = 0;
	Start.y = 0;
	End.x = TextWindow->Terminal.x - 1;
	End.y = TextWindow->Terminal.y + TextWindow->PufLines - 1;

	Pxy[0] =	0;	Pxy[1] = 0;
	Pxy[2] = TextWindow->CellWidth * ( WORD ) TextWindow->Terminal.x;
	Pxy[3] = TextWindow->CellHeight * ( WORD )( TextWindow->Terminal.y + TextWindow->PufLines );

	vswr_mode( TextWindow->BmHandle, MD_REPLACE );
	vsf_color( TextWindow->BmHandle, TextWindow->WindowColor );
	vsf_perimeter( TextWindow->BmHandle, 0 );
	v_bar( TextWindow->BmHandle, Pxy );

	if( TextWindow->Invers )
	{
		Pxy[0] =	0;	Pxy[1] = 0;
		Pxy[2] = TextWindow->CellWidth * ( WORD ) TextWindow->Terminal.x;
		Pxy[3] = TextWindow->CellHeight * ( WORD )( TextWindow->Terminal.y + TextWindow->PufLines );
		vswr_mode( TextWindow->BmHandle, MD_XOR );
		vsf_color( TextWindow->BmHandle, 1 );
		v_bar( TextWindow->BmHandle, Pxy );
	}

	DrawEmulationTextWindow( TextWindow, &Start, &End );

	DrawBlockTextWindow( WinId, &( TextWindow->BlockStart ), &( TextWindow->BlockEnd ), 0, TextWindow );
	
	return( TextWindow->BmHandle );
}

void	ChangeColorTextWindow( WORD WinId, WORD FontColor, WORD WindowColor, WORD Global[15] )
{
	XY		Start, End;
	EVNT	Events;
	TEXT_WINDOW	*TextWindow = GetWindowData( WinId );

	MT_graf_mouse( M_SAVE, NULL, Global );
	MT_graf_mouse( BUSYBEE, NULL, Global );

	TextWindow->FontColor = FontColor;
	TextWindow->WindowColor = WindowColor;
	Start.x = 0;
	Start.y = 0;
	End.x = EMU_GetNCharMax( TextWindow->EmuData );
	End.y = EMU_GetNLine( TextWindow->EmuData ) - 1;
	DrawEmulationTextWindow( TextWindow, &Start, &End );
	Events.mwhich = MU_MESAG;
	Events.msg[0] = WM_REDRAW;
	Events.msg[1] = Global[2];
	Events.msg[2] = 0;
	Events.msg[3] = WinId;
	Events.msg[4] = TextWindow->WorkRect.g_x;
	Events.msg[5] = TextWindow->WorkRect.g_y;
	Events.msg[6] = TextWindow->WorkRect.g_w;
	Events.msg[7] = TextWindow->WorkRect.g_h;
	HandleMuMesagTextWindow( WinId, &Events, TextWindow, Global );
	MT_graf_mouse( M_RESTORE, NULL, Global );
}

void	ChangeFontTextWindow( WORD WinId, WORD FontId, LONG FontPt, WORD FontColor, WORD WindowColor, WORD Global[15] )
{
	WORD	D;
	EVNT	Evnt;
	GRECT	Rect;
	TEXT_WINDOW	*TextWindow = GetWindowData( WinId );

	MT_graf_mouse( M_SAVE, NULL, Global );
	MT_graf_mouse( BUSYBEE, NULL, Global );

	TextWindow->FontId = FontId;
	TextWindow->FontPt = FontPt;
	TextWindow->FontColor = FontColor;
	TextWindow->WindowColor = WindowColor;

	vst_font( TextWindow->VdiHandle, TextWindow->FontId );
	vst_arbpt32( TextWindow->VdiHandle, TextWindow->FontPt, &D, &D, &D, &D );
	vst_color( TextWindow->VdiHandle, TextWindow->FontColor );
	vst_effects( TextWindow->VdiHandle, TextWindow->FontEffects );
	GetFontInfo( TextWindow->VdiHandle, &( TextWindow->CellHeight ), &( TextWindow->dBasicLine ), &( TextWindow->CellWidth ));
	vst_font( TextWindow->BmHandle, TextWindow->FontId );
	vst_arbpt32( TextWindow->BmHandle, TextWindow->FontPt, &D, &D, &D, &D );
	vst_color( TextWindow->BmHandle, TextWindow->FontColor );
	vst_effects( TextWindow->BmHandle, TextWindow->FontEffects );

	if( vq_gdos())
		vst_unload_fonts( TextWindow->BmHandle, 0 );
	v_clsbm( TextWindow->BmHandle );
	if( TextWindow->GcBitmap.ctab )
	{
		v_delete_ctab( TextWindow->VdiHandle, TextWindow->GcBitmap.ctab );
		TextWindow->GcBitmap.ctab = NULL;
	}
	TextWindow->BmHandle = NewBitmapTextWindow( WinId, TextWindow );

	GetMaxTextWindow( WinId, TextWindow, &( TextWindow->FullRect ), Global );
	GetMaxTextWindow( WinId, TextWindow, &( TextWindow->NextFuller ), Global );

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
	HandleMuMesagTextWindow( WinId, &Evnt, TextWindow, Global );
	MT_graf_mouse( M_RESTORE, NULL, Global );
}

void	ChangeEmuTextWindow( WORD WinId, EMU_TYPE EmuType )
{
	TEXT_WINDOW	*TextWindow = GetWindowData( WinId );
	EMU_ChangeEmu( TextWindow->EmuData, EmuType );
}
void	ChangeKeyExportTextWindow( WORD WinId, WORD KeyExport )
{
	TEXT_WINDOW	*TextWindow = GetWindowData( WinId );
	TextWindow->KeyExport = KeyExport;
}
void	ChangeKeyImportTextWindow( WORD WinId, WORD KeyImport )
{
	TEXT_WINDOW	*TextWindow = GetWindowData( WinId );
	TextWindow->KeyImport = KeyImport;
	EMU_ChangeKeyImport( TextWindow->EmuData, KeyImport );
}
void	ChangeKeyFlagTextWindow( WORD WinId, WORD KeyFlag )
{
	TEXT_WINDOW	*TextWindow = GetWindowData( WinId );
	TextWindow->KeyFlag = KeyFlag;
	EMU_ChangeKey( TextWindow->EmuData, KeyFlag);
}

void	ChangePufLinesTextWindow( WORD WinId, LONG PufLines, WORD Global[15] )
{
	TEXT_WINDOW	*TextWindow = GetWindowData( WinId );

	MT_graf_mouse( M_SAVE, NULL, Global );
	MT_graf_mouse( BUSYBEE, NULL, Global );

	TextWindow->PufLines = PufLines;
	CursorOffTextWindow( WinId, TextWindow, Global);
	EMU_ChangePufLines( TextWindow->EmuData, PufLines, &( TextWindow->nLine ), &( TextWindow->Cursor ));
	if( TextWindow->Pos.y > TextWindow->nLine - TextWindow->WorkRect.g_h / TextWindow->CellHeight )
		TextWindow->Pos.y = TextWindow->nLine - TextWindow->WorkRect.g_h / TextWindow->CellHeight;
	if( TextWindow->BlockEnd.y >= TextWindow->nLine )
		TextWindow->BlockEnd.y = TextWindow->nLine - 1;
	if( vq_gdos())
		vst_unload_fonts( TextWindow->BmHandle, 0 );
	v_clsbm( TextWindow->BmHandle );
	if( TextWindow->GcBitmap.ctab )
	{
		v_delete_ctab( TextWindow->VdiHandle, TextWindow->GcBitmap.ctab );
		TextWindow->GcBitmap.ctab = NULL;
	}
	CursorOnTextWindow( WinId, TextWindow, Global);
	TextWindow->BmHandle = NewBitmapTextWindow( WinId, TextWindow );
	SetHSliderTextWindow( WinId, TextWindow, Global );
	SetVSliderTextWindow( WinId, TextWindow, Global );
/* Blockmarkierung „ndern */
	MT_graf_mouse( M_RESTORE, NULL, Global );
}

void	ChangeTabTextWindow( WORD WinId, XY *Tab )
{
	TEXT_WINDOW	*TextWindow = GetWindowData( WinId );
	EMU_ChangeTab( TextWindow->EmuData, Tab );
}
void	ChangeTerminalTextWindow( WORD WinId, XY *Terminal, WORD Global[15] )
{
	GRECT	Rect;
	EVNT	Evnt;
	TEXT_WINDOW	*TextWindow = GetWindowData( WinId );

	MT_graf_mouse( M_SAVE, NULL, Global );
	MT_graf_mouse( BUSYBEE, NULL, Global );

	TextWindow->Terminal.x = Terminal->x;
	TextWindow->Terminal.y = Terminal->y;

	CursorOffTextWindow( WinId, TextWindow, Global);
	EMU_ChangeTerminal( TextWindow->EmuData, Terminal, &( TextWindow->nLine ),  &( TextWindow->Cursor ));
	if( vq_gdos())
		vst_unload_fonts( TextWindow->BmHandle, 0 );
	v_clsbm( TextWindow->BmHandle );
	if( TextWindow->GcBitmap.ctab )
	{
		v_delete_ctab( TextWindow->VdiHandle, TextWindow->GcBitmap.ctab );
		TextWindow->GcBitmap.ctab = NULL;
	}
	TextWindow->BmHandle = NewBitmapTextWindow( WinId, TextWindow );
	GetMaxTextWindow( WinId, TextWindow, &( TextWindow->FullRect ), Global );
	GetMaxTextWindow( WinId, TextWindow, &( TextWindow->NextFuller ), Global );

	TextWindow->nCharMax = EMU_GetNCharMax( TextWindow->EmuData );

	AdjustTextWindow( WinId, TextWindow, Global );
	SetHSliderTextWindow( WinId, TextWindow, Global );
	SetVSliderTextWindow( WinId, TextWindow, Global );

	CursorOnTextWindow( WinId, TextWindow, Global);

	Evnt.mwhich = MU_MESAG;
	Evnt.msg[0] = WM_REDRAW;
	Evnt.msg[1] = Global[2];
	Evnt.msg[2] = 0;
	Evnt.msg[3] = WinId;
	Evnt.msg[4] = TextWindow->WorkRect.g_x;
	Evnt.msg[5] = TextWindow->WorkRect.g_y;
	Evnt.msg[6] = TextWindow->WorkRect.g_w;
	Evnt.msg[7] = TextWindow->WorkRect.g_h;
	HandleMuMesagTextWindow( WinId, &Evnt, TextWindow, Global );
	MT_graf_mouse( M_RESTORE, NULL, Global );
}


WORD	KontextTextWindow( WORD WinId, TEXT_WINDOW *TextWindow, WORD Global[15] )
{
	EVNT	lEvents;
	EVNTDATA	Ev;
	WORD	Selected;
	ULONG	Kontext = MenuKontextTextWindow( WinId, Global );

	MT_graf_mkstate( &Ev, Global );

	lEvents.mwhich = MU_MESAG;
	lEvents.msg[1] = Global[2];
	lEvents.msg[2] = 0;
	lEvents.msg[3] = WinId;
			
	if( Kontext & MENUE_KONTEXT_COPY )
		TreeAddr[POPUP_TEXT][POPUP_TEXT_COPY].ob_state &= ~DISABLED;
	else
		TreeAddr[POPUP_TEXT][POPUP_TEXT_COPY].ob_state |= DISABLED;

	if( Kontext & MENUE_KONTEXT_MARK_ALL )
		TreeAddr[POPUP_TEXT][POPUP_TEXT_MARK_ALL].ob_state &= ~DISABLED;
	else
		TreeAddr[POPUP_TEXT][POPUP_TEXT_MARK_ALL].ob_state |= DISABLED;

	if( Kontext & MENUE_KONTEXT_WINDOW_CYCLE )
		TreeAddr[POPUP_TEXT][POPUP_TEXT_CYC_WIND].ob_state &= ~DISABLED;
	else
		TreeAddr[POPUP_TEXT][POPUP_TEXT_CYC_WIND].ob_state |= DISABLED;

	if( Kontext & MENUE_KONTEXT_WINDOW_FULL )
		TreeAddr[POPUP_TEXT][POPUP_TEXT_FULL_WIND].ob_state &= ~DISABLED;
	else
		TreeAddr[POPUP_TEXT][POPUP_TEXT_FULL_WIND].ob_state |= DISABLED;

	Selected = Popup( TreeAddr[POPUP_TEXT], -1, Ev.x, Ev.y, Global );
	switch( Selected )
	{
		case	POPUP_TEXT_RX:
			lEvents.msg[0] = WIN_CMD;
			lEvents.msg[4] = RX;
			TextWindow->HandleUserTextWindow( WinId, &lEvents, TextWindow->UserData, Global );
			break;
		case	POPUP_TEXT_TX:
			lEvents.msg[0] = WIN_CMD;
			lEvents.msg[4] = TX;
			TextWindow->HandleUserTextWindow( WinId, &lEvents, TextWindow->UserData, Global );
			break;
		case	POPUP_TEXT_OPTIONS:
			lEvents.msg[0] = WIN_CMD;
			lEvents.msg[4] = WIN_KONTEXT_2;
			TextWindow->HandleUserTextWindow( WinId, &lEvents, TextWindow->UserData, Global );
			break;
		case	POPUP_TEXT_PASTE:
		{
			lEvents.msg[0] = WIN_CMD;
			lEvents.msg[4] = WIN_PASTE;
			HandleMuMesagTextWindow( WinId, &lEvents, TextWindow, Global );
			break;
		}
		case	POPUP_TEXT_COPY:
		{
			lEvents.msg[0] = WIN_CMD;
			lEvents.msg[4] = WIN_COPY;
			HandleMuMesagTextWindow( WinId, &lEvents, TextWindow, Global );
			break;
		}
		case	POPUP_TEXT_MARK_ALL:
		{
			lEvents.msg[0] = WIN_CMD;
			lEvents.msg[4] = WIN_MARK_ALL;
			HandleMuMesagTextWindow( WinId, &lEvents, TextWindow, Global );
			break;
		}
		case	POPUP_TEXT_CLOSE:
		{
			lEvents.msg[0] = WM_CLOSED;
			HandleMuMesagTextWindow( WinId, &lEvents, TextWindow, Global );
			break;
		}
		case	POPUP_TEXT_CYC_WIND:
		{
			WORD	w1, w2, w3, w4;
			MT_wind_get( 0, WF_TOP, &w1, &w2, &w3, &w4, Global );
			if( isWindow( w1 ))
			{
				do
				{
					if(( w1 = GetNextWindow( w1 )) == -1 )
						w1 = GetFirstWindow();
					if( isOpenWindow( w1 ))
						break;
				}
				while( 1 );
				MT_wind_set( w1, WF_TOP, 0, 0, 0, 0, Global );
			}
			break;
		}
		case	POPUP_TEXT_FULL_WIND:
		{
			lEvents.msg[0] = WM_FULLED;
			HandleMuMesagTextWindow( WinId, &lEvents, TextWindow, Global );
			break;
		}
		case	POPUP_TEXT_HELP:
		{
			StGuide_Action( TreeAddr[POPUP_TEXT], POPUP_TEXT, Global );
			break;
		}
	}
	return( E_OK );
}

void	OpenAlertTelnet( TEXT_WINDOW *TextWindow, WORD WinId, WORD Type )
{
	if( WinId > 0 )
	{
		MOD_WIN	**ModWin, *New, *Last = NULL;
		ModWin = &( TextWindow->ModWin );
		if(( New = malloc( sizeof( MOD_WIN ))) == NULL )
			return;
		New->WinId = WinId;
		New->Type = Type;
		New->next = NULL;
		if( Type == MODWIN_CLOSE_SESSION )
			TextWindow->CloseId = WinId;
		if( *ModWin )
		{
			Last = *ModWin;
			while( Last->next )
				Last = Last->next;
			Last->next = New;
		}
		else
			*ModWin = New;
		New->prev = Last;
	}
}
void	CloseAlertTelnet( void *TextWindow, WORD Button, WORD WinId, WORD Global[15] )
{
	WORD	Type = CloseAlert( &((( TEXT_WINDOW * ) TextWindow )->ModWin ), WinId );
	switch( Type )
	{
		case	MODWIN_CLOSE_SESSION:
		{
			(( TEXT_WINDOW * ) TextWindow )->CloseId = 0;
			if( Button != 1 )
				break;
		}
		case	MODWIN_CONNECTION_CLOSED:
		{
			EVNT	Events;
			Events.mwhich = MU_MESAG;
			Events.msg[0] = WIN_CMD;
			Events.msg[1] = Global[2];
			Events.msg[2] = 0;
			Events.msg[3] = (( TEXT_WINDOW * ) TextWindow )->WinId;
			Events.msg[4] = WIN_CLOSE;
			Events.msg[5] = WIN_CLOSE_WITHOUT_DEMAND;
			(( TEXT_WINDOW * ) TextWindow )->HandleUserTextWindow((( TEXT_WINDOW * ) TextWindow )->WinId, &Events, (( TEXT_WINDOW * ) TextWindow )->UserData, Global );
			break;
		}
	}
}
static WORD CloseAlert( MOD_WIN **ModWin, WORD WinId )
{
	MOD_WIN	*Del = *ModWin;
	WORD	Type;
	while( Del )
	{
		if( Del->WinId == WinId )
			break;
		Del = Del->next;
	}
	if( !Del )
		return( ERROR );

	if( Del->next )
		( Del->next )->prev = Del->prev;
	if( Del->prev )
		( Del->prev )->next = Del->next;
	else
		*ModWin = Del->next;
	Type = Del->Type;
	free( Del );
	return( Type );
}

