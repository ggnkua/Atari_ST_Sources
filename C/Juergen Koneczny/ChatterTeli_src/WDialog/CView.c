#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<TOS.H>
#include	<VDI.H>
#include	<MT_AES.H>
#include <STDDEF.H>
#include	<STDLIB.H>
#include <STDIO.H>
#include	<STRING.H>

#include	<atarierr.h>

#include	"..\main.h"
#include	RSCHEADER
#include	"..\DD.h"
#include	"..\Emulator.h"
#include	"..\IConnect.h"
#include	"..\Menu.h"
#include	"..\Popup.h"
#include	"..\Telnet.h"
#include	"..\Window.h"
#include	"..\WDialog.h"
#include	"..\W_Text.h"

#include	"CView.h"

#include	"..\MapKey.h"

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
static WORD	cdecl	HandleDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD );
static WORD	HndlMesagDialog( DIALOG *Dialog, EVNT *Events, WORD Global[15] );
static void	GetFaceName( WORD FontId, LONG FontPt, WORD VdiHandle, BYTE *Puf );
static WORD	cdecl ColorUbCode( PARMBLK *ParmBlock );

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern WORD	Global[15], VdiHandle;
extern OBJECT	**TreeAddr;
WORD	FontId, FontColor, FontEffects, WindowColor;
extern WORD nFont;
LONG	FontPt;
extern TELNET	DefaultTelnet;
 WORD	KeyFlag;

/*-----------------------------------------------------------------------------*/
/* Lokale Variablen                                                            */
/*-----------------------------------------------------------------------------*/
static DIALOG_DATA	Dialog =
{
	NULL,
	NULL,
	CVIEW,
	NULL,
	NULL,
	HndlMesagDialog,
	NULL,
	NULL
};
static WORD	EmuTypeButton[2] = { POPUP_EMULATION_NVT, POPUP_EMULATION_VT52 };
static EMU_TYPE	EmuType;
static lKeyFlag;

static WORD lFontId, lFontEffects;
static LONG lFontPt;

static USERBLK	FontColorUserBlk =
{
	ColorUbCode,
	0L
};
static USERBLK	WindowColorUserBlk =
{
	ColorUbCode,
	0L
};

void OpenCViewDialog( WORD Global[15] )
{
	if( !Dialog.Dialog )
	{
		lFontId = FontId;
		lFontEffects = FontEffects;
		lFontPt = FontPt;

		TreeAddr[CVIEW][CVIEW_FONTCOLOR].ob_type = G_USERDEF;
		TreeAddr[CVIEW][CVIEW_FONTCOLOR].ob_spec.userblk = &FontColorUserBlk;
		FontColorUserBlk.ub_parm = FontColor;
		TreeAddr[CVIEW][CVIEW_WINDOWCOLOR].ob_type = G_USERDEF;
		TreeAddr[CVIEW][CVIEW_WINDOWCOLOR].ob_spec.userblk = &WindowColorUserBlk;
		WindowColorUserBlk.ub_parm = WindowColor;

		Dialog.Tree = TreeAddr[CVIEW];
		OpenDialog( TreeAddr[TITLES][TITLE_CVIEW].ob_spec.free_string, WIN_WDIALOG, HandleDialog, &Dialog, 0L, Global );
	}
	else
		MT_wind_set( MT_wdlg_get_handle( Dialog.Dialog, Global ), WF_TOP, 0, 0, 0, 0, Global );
}

static WORD	cdecl	HandleDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD )
{
	OBJECT		*DialogTree;
	GRECT			Rect;
	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );

	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_INIT:
			{
				EmuType = DefaultTelnet.EmuType;
				strcpy( DialogTree[CVIEW_EMULATION].ob_spec.free_string, TreeAddr[POPUP_EMULATION][EmuTypeButton[EmuType]].ob_spec.free_string );
				lKeyFlag = KeyFlag;
				if( KeyFlag & CURSOR_APPLICATION )
					strcpy( DialogTree[CVIEW_CURSOR].ob_spec.free_string, TreeAddr[POPUP_CURSOR][POPUP_CURSOR_APPLICATION].ob_spec.free_string );
				else
					strcpy( DialogTree[CVIEW_CURSOR].ob_spec.free_string, TreeAddr[POPUP_CURSOR][POPUP_CURSOR_NORMAL].ob_spec.free_string );
				if( KeyFlag & KEYPAD_APPLICATION )
					strcpy( DialogTree[CVIEW_KEYPAD].ob_spec.free_string, TreeAddr[POPUP_KEYPAD][POPUP_KEYPAD_APPLICATION].ob_spec.free_string );
				else
					strcpy( DialogTree[CVIEW_KEYPAD].ob_spec.free_string, TreeAddr[POPUP_KEYPAD][POPUP_KEYPAD_NORMAL].ob_spec.free_string );
				GetFaceName( lFontId, lFontPt, VdiHandle, DialogTree[CVIEW_FONTNAME].ob_spec.free_string );
				sprintf( DialogTree[CVIEW_COLUMNS].ob_spec.tedinfo->te_ptext, "%li", DefaultTelnet.Terminal.x );
				sprintf( DialogTree[CVIEW_ROWS].ob_spec.tedinfo->te_ptext, "%li", DefaultTelnet.Terminal.y );
				sprintf( DialogTree[CVIEW_TAB_H].ob_spec.tedinfo->te_ptext, "%li", DefaultTelnet.Tab.x );
				sprintf( DialogTree[CVIEW_TAB_V].ob_spec.tedinfo->te_ptext, "%li", DefaultTelnet.Tab.y );
				DialogTree[CVIEW_OK].ob_state &= ~SELECTED;
				DialogTree[CVIEW_CANCEL].ob_state &= ~SELECTED;
				break;
			}
			case	HNDL_OPEN:
				break;
			
			case	HNDL_CLSD:
				return( 0 );
			case	HNDL_EDIT:
			{
				break;
			}
			case	HNDL_EDCH:
			case	HNDL_EDDN:
			{
				break;
			}
		}
	}
	else
	{
		Obj &= 0x7fff;
		if( HandleWDialogIcon( &Obj, Dialog, Global ))
			return( 1 );

		if( DialogTree[Obj].ob_state & DISABLED )
		{
			DialogTree[Obj].ob_state &= ~SELECTED;
			return( 1 );
		}
	
		switch( Obj )
		{
			case	CVIEW_FONTNAME:
			{
				WORD	ChkBox;
				LONG	Id, Pt, Ratio = 1L << 16;
				void	*FontDialog;
				MT_graf_mouse( M_SAVE, NULL, Global );
				MT_graf_mouse( BUSYBEE, NULL, Global );
				FontDialog = MT_fnts_create( VdiHandle, 0, FNTS_BTMP + FNTS_OUTL + 
				                             FNTS_MONO, FNTS_3D, 
				                             "Teli - ein Telnet-Client fr IConnect", 
				                              NULL, Global );
				MT_graf_mouse( M_RESTORE, NULL, Global );
				if( FontDialog )
				{
					if( MT_fnts_do( FontDialog, 0, ( LONG ) lFontId, lFontPt, Ratio, &ChkBox, &Id, &Pt, &Ratio, Global ) == FNTS_OK )
					{
						if( Id != lFontId || lFontPt != Pt )
						{
							lFontId = ( WORD ) Id;
							lFontPt = Pt;
							GetFaceName( lFontId, lFontPt, VdiHandle, DialogTree[CVIEW_FONTNAME].ob_spec.free_string );
						}
					}
					MT_fnts_delete( FontDialog, VdiHandle, Global );
				}
				else
				{
					Cconout( '\a' );
					break;
				}

				DialogTree[CVIEW_FONTNAME].ob_state &= ~SELECTED;
				DoRedraw( Dialog, &Rect, CVIEW_FONTNAME, Global );
				break;
			}

			case	CVIEW_FONTCOLOR_TEXT:
			case	CVIEW_FONTCOLOR:
			{
				WORD	x, y, Color, Flag = 0;
				if( Obj == CVIEW_FONTCOLOR  )
				{
					x = Events->mx;
					y = Events->my;
					Flag = 1;
				}
				else
					MT_objc_offset( DialogTree, CVIEW_FONTCOLOR, &x, &y, Global );
				if(( Color = ColorPopup(( WORD ) FontColorUserBlk.ub_parm, Flag, x, y, Global )) != -1 )
				{
					FontColorUserBlk.ub_parm = Color;
					DoRedraw( Dialog, &Rect, CVIEW_FONTCOLOR_BOX, Global );
				}
				break;
			}
			case	CVIEW_WINDOWCOLOR_TEXT:
			case	CVIEW_WINDOWCOLOR:
			{
				WORD	x, y, Color, Flag = 0;
				if( Obj == CVIEW_WINDOWCOLOR  )
				{
					x = Events->mx;
					y = Events->my;
					Flag = 1;
				}
				else
					MT_objc_offset( DialogTree, CVIEW_WINDOWCOLOR, &x, &y, Global );
				if(( Color = ColorPopup(( WORD ) WindowColorUserBlk.ub_parm, Flag, x, y, Global )) != -1 )
				{
					WindowColorUserBlk.ub_parm = Color;
					DoRedraw( Dialog, &Rect, CVIEW_WINDOWCOLOR_BOX, Global );
				}
				break;
			}

			case	CVIEW_EMULATION_TEXT:
			case	CVIEW_EMULATION:
			{
				WORD	x, y, Selected;
				MT_objc_offset( DialogTree, CVIEW_EMULATION, &x, &y, Global );			
				Selected = Popup( TreeAddr[POPUP_EMULATION], EmuTypeButton[EmuType], x, y, Global );
				if( Selected != -1 )
				{
					EmuType = NVT;
					while( EmuTypeButton[EmuType] != Selected )
						EmuType++;
					strcpy( DialogTree[CVIEW_EMULATION].ob_spec.free_string, TreeAddr[POPUP_EMULATION][Selected].ob_spec.free_string );
					DoRedraw( Dialog, &Rect, CVIEW_EMULATION, Global );
				}
				break;
			}
			
			case	CVIEW_COLUMNS_EDIT:
				MT_wdlg_set_edit( Dialog, CVIEW_COLUMNS, Global );
				break;
			case	CVIEW_ROWS_EDIT:
				MT_wdlg_set_edit( Dialog, CVIEW_ROWS, Global );
				break;
			case	CVIEW_TAB_EDIT:
				MT_wdlg_set_edit( Dialog, CVIEW_TAB_H, Global );
				break;
			case	CVIEW_CURSOR_TEXT:
			case	CVIEW_CURSOR:
			{
				WORD	x, y, Selected;
				MT_objc_offset( DialogTree, CVIEW_CURSOR, &x, &y, Global );
				Selected = Popup( TreeAddr[POPUP_CURSOR], lKeyFlag & CURSOR_APPLICATION ? POPUP_CURSOR_APPLICATION : POPUP_CURSOR_NORMAL, x, y, Global );
				if( Selected != -1 )
				{
					lKeyFlag = ( Selected == POPUP_CURSOR_APPLICATION ? lKeyFlag | CURSOR_APPLICATION : lKeyFlag & ~CURSOR_APPLICATION );
					if( lKeyFlag & CURSOR_APPLICATION )
						strcpy( DialogTree[CVIEW_CURSOR].ob_spec.free_string, TreeAddr[POPUP_CURSOR][POPUP_CURSOR_APPLICATION].ob_spec.free_string );
					else
						strcpy( DialogTree[CVIEW_CURSOR].ob_spec.free_string, TreeAddr[POPUP_CURSOR][POPUP_CURSOR_NORMAL].ob_spec.free_string );
					DoRedraw( Dialog, &Rect, CVIEW_CURSOR, Global );
				}
				break;
			}
			case	CVIEW_KEYPAD_TEXT:
			case	CVIEW_KEYPAD:
			{
				WORD	x, y, Selected;
				MT_objc_offset( DialogTree, CVIEW_KEYPAD, &x, &y, Global );
				Selected = Popup( TreeAddr[POPUP_KEYPAD], lKeyFlag & KEYPAD_APPLICATION ? POPUP_KEYPAD_APPLICATION : POPUP_KEYPAD_NORMAL, x, y, Global );
				if( Selected != -1 )
				{
					lKeyFlag = ( Selected == POPUP_KEYPAD_APPLICATION ? lKeyFlag | KEYPAD_APPLICATION : lKeyFlag & ~KEYPAD_APPLICATION );
					if( lKeyFlag & KEYPAD_APPLICATION )
						strcpy( DialogTree[CVIEW_KEYPAD].ob_spec.free_string, TreeAddr[POPUP_KEYPAD][POPUP_KEYPAD_APPLICATION].ob_spec.free_string );
					else
						strcpy( DialogTree[CVIEW_KEYPAD].ob_spec.free_string, TreeAddr[POPUP_KEYPAD][POPUP_KEYPAD_NORMAL].ob_spec.free_string );
					DoRedraw( Dialog, &Rect, CVIEW_KEYPAD, Global );
				}
				break;
			}
			case	CVIEW_OK:
			{
				KeyFlag = lKeyFlag;
				if( atol( DialogTree[CVIEW_TAB_H].ob_spec.tedinfo->te_ptext ) < 1 )
				{
					int	r;
					r = wind_update( END_UPDATE );
					MT_form_alert( 1, TreeAddr[ALERTS][TAB_H].ob_spec.free_string, Global );
					if( r == 1 )
						wind_update( BEG_UPDATE );
					DialogTree[CVIEW_OK].ob_state &= ~SELECTED;
					DoRedraw( Dialog, &Rect, CVIEW_OK, Global );
					break;
				}
				if( atol( DialogTree[CVIEW_TAB_V].ob_spec.tedinfo->te_ptext ) < 1 )
				{
					int	r;
					r = wind_update( END_UPDATE );
					if( r == 1 )
						wind_update( BEG_UPDATE );
					MT_form_alert( 1, TreeAddr[ALERTS][TAB_V].ob_spec.free_string, Global );
					DialogTree[CVIEW_OK].ob_state &= ~SELECTED;
					DoRedraw( Dialog, &Rect, CVIEW_OK, Global );
					break;
				}
				DefaultTelnet.Tab.x = atol( DialogTree[CVIEW_TAB_H].ob_spec.tedinfo->te_ptext );
				DefaultTelnet.Tab.y = atol( DialogTree[CVIEW_TAB_V].ob_spec.tedinfo->te_ptext );
				DefaultTelnet.EmuType = EmuType;
				if( lFontId != FontId || lFontPt != FontPt || 
				    FontColorUserBlk.ub_parm != FontColor || WindowColorUserBlk.ub_parm != WindowColor )
				{
					FontId = lFontId;
					FontPt = lFontPt;
					FontColor = ( WORD ) FontColorUserBlk.ub_parm;
					WindowColor = ( WORD ) WindowColorUserBlk.ub_parm;
					ChangeFontTextWindow( Global );
				}
				DefaultTelnet.Terminal.x = atol( DialogTree[CVIEW_COLUMNS].ob_spec.tedinfo->te_ptext );
				DefaultTelnet.Terminal.y = atol( DialogTree[CVIEW_ROWS].ob_spec.tedinfo->te_ptext );
				return( 0 );
			}
			case	CVIEW_CANCEL:
				return( 0 );
		}
	}
	return( 1 );
}

static WORD	HndlMesagDialog( DIALOG *Dialog, EVNT *Events, WORD Global[15] )
{
	if( Events->msg[0] == FONT_CHANGED )
	{
		if( !isMonospaceFont( Events->msg[4] ))
			MT_form_alert( 1, TreeAddr[ALERTS][FONT_NOT_MONO].ob_spec.free_string, Global );
		else
		{
			OBJECT	*DialogTree;
			GRECT		Rect;
			MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );
			if( Events->msg[4] > 0 )
				lFontId = Events->msg[4];
			if( Events->msg[5] > 0 )
				lFontPt = (( LONG ) Events->msg[5] ) << 16;
			if( Events->msg[6] != -1 )
				FontColorUserBlk.ub_parm = Events->msg[6];
			GetFaceName( lFontId, lFontPt, VdiHandle, DialogTree[CVIEW_FONTNAME].ob_spec.free_string );
			DoRedrawX( Dialog, &Rect, Global, CVIEW_FONTNAME, CVIEW_FONTCOLOR, CVIEW_WINDOWCOLOR, EDRX );
		}
		return( E_OK );
	}
	return( ERROR );
}

static void	GetFaceName( WORD FontId, LONG FontPt, WORD VdiHandle, BYTE *Puf )
{
	WORD	i;
	BYTE	Name[33], Pt[10];
	for( i = 1; i < nFont; i++ )
	{
		if( vqt_name( VdiHandle, i, Name ) == FontId )
		{
			strcpy( Puf, Name );
			itoa( ( WORD )( FontPt >> 16 ), Pt, 10 );
			if(( i = ( WORD ) strlen( Puf )) == 31 )
			{
				*strrchr( Puf, ' ' ) = 0;
				i = ( WORD ) strlen( Puf );
			}
			while( i < 38 - strlen( Pt ) - 2 )
				Puf[i++] = ' ';
			Puf[i] = 0;
			strcat( Puf, Pt );
			strcat( Puf, "pt" );
			return;
		}
	}
	strcpy( Puf, "" );
}

void	ChangeCViewDialog( WORD Global[15] )
{
	if( Dialog.Dialog )
	{
		OBJECT	*DialogTree;
		GRECT		Rect;
		MT_wdlg_get_tree( Dialog.Dialog, &DialogTree, &Rect, Global );
		lFontId = FontId;
		lFontPt = FontPt;
		lFontEffects = FontEffects;
		FontColorUserBlk.ub_parm = FontColor;
		WindowColorUserBlk.ub_parm = WindowColor;
		GetFaceName( FontId, FontPt, VdiHandle, DialogTree[CVIEW_FONTNAME].ob_spec.free_string );
		DoRedrawX( Dialog.Dialog, &Rect, Global, CVIEW_FONTNAME, CVIEW_FONTCOLOR, CVIEW_WINDOWCOLOR, EDRX );
	}
}

static WORD	cdecl ColorUbCode( PARMBLK *ParmBlock )
{
	WORD	Cxy[4], Pxy[4];

	Cxy[0] = ParmBlock->pb_xc;
	Cxy[1] = ParmBlock->pb_yc;
	Cxy[2] = Cxy[0] + ParmBlock->pb_wc - 1;
	Cxy[3] = Cxy[1] + ParmBlock->pb_hc - 1;
	vs_clip( VdiHandle, 1, Cxy );

	vswr_mode( VdiHandle, MD_REPLACE );
	vsf_perimeter( VdiHandle, 0 );
	vsf_interior( VdiHandle, FIS_SOLID );

	Pxy[0] = ParmBlock->pb_x + 1;
	Pxy[1] = ParmBlock->pb_y + 1;
	Pxy[2] = Pxy[0] + ParmBlock->pb_w - 3;
	Pxy[3] = Pxy[1] + ParmBlock->pb_h - 3;

	vsf_color( VdiHandle, ( WORD ) ParmBlock->pb_parm );
	v_bar( VdiHandle, Pxy );

	vs_clip( VdiHandle, 0, Cxy );
	return( 0 );
}
