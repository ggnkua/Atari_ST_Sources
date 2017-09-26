#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<TOS.H>
#include	<VDICOL.H>
#include	<MT_AES.H>
#include	<VDI.H>
#include	<STDDEF.H>
#include	<STDARG.H>
#include	<STDIO.H>
#include	<STDLIB.H>
#include	<STRING.H>
#include	<CTYPE.H>

#include	<av.h>
#include	<atarierr.h>

#include	"main.h"
#include	RSCHEADER
#include	"DD.h"
#include	"Help.h"
#include	"Menu.h"
#include	"Rsc.h"
#include	"WDialog.h"
#include	"Window.h"

#include	"MapKey.h"

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
static void	DropEditWdialog( DIALOG *Dialog, WORD Obj, BYTE *Puf, WORD Global[15] );
static WORD cdecl	HandleAlertDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData );
static WORD HndlClsAlertDialog( void *DialogData, WORD Global[15] );

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern WORD	Global[15], VdiHandle, AvAppId;
extern WORD	PwChar, PhChar, PwBox, PhBox;
extern OBJECT	**TreeAddr;
extern GRECT	ScreenRect;

/*-----------------------------------------------------------------------------*/
/* Lokale Variablen                                                            */
/*-----------------------------------------------------------------------------*/
static WORD	AlertIcon[3] = { ALERT_ICON_0, ALERT_ICON_1, ALERT_ICON_2 };
static WORD	AlertButton[3] = { ALERT_BUTTON_0, ALERT_BUTTON_1, ALERT_BUTTON_2 };
static WORD AlertLine[5] = { ALERT_LINE_0, ALERT_LINE_1, ALERT_LINE_2, ALERT_LINE_3, ALERT_LINE_4 };

typedef struct
{
	WORD	WinId;
	BYTE	*Titel;
	CLS_ALERT_DIALOG	ClsAlertDialog;
	void	*UserData;
}	ALERT_WINDOW;

void	DoRedraw( DIALOG *Dialog, GRECT *Rect, WORD Obj, WORD Global[15] )
{
	if( !isIconifiedWindow( MT_wdlg_get_handle( Dialog, Global )))
	{
		MT_wind_update( BEG_UPDATE, Global );
		MT_wdlg_redraw( Dialog, Rect, Obj, MAX_DEPTH, Global );
		MT_wind_update( END_UPDATE, Global );
	}
}

void	DoRedrawX( DIALOG *Dialog, GRECT *Rect, WORD Global[15], ... )
{
	va_list	Arg;
	WORD		Obj;
	if( !isIconifiedWindow( MT_wdlg_get_handle( Dialog, Global )))
	{
		MT_wind_update( BEG_UPDATE, Global );
		va_start( Arg, Global );
		while(( Obj = va_arg( Arg, WORD )) != EDRX )
			MT_wdlg_redraw( Dialog, Rect, Obj, MAX_DEPTH, Global );
		va_end( Arg );
		MT_wind_update( END_UPDATE, Global );
	}
}

/*-----------------------------------------------------------------------------*/
/* Fensterdialog ”ffnen                                                        */
/* Funktionsergebnis: Zeiger auf Dialog 0: Fehler                              */
/*  DialogTree:       Zeiger auf den Objektbaum                                */
/*  TitelStr:         Zeiger auf Titel des Dialogs                             */
/*  HandleDialog:     Service-Funktion fr Dialog                              */
/*  UserData:         Thread- und Dialog-abh„ngige Daten                       */
/*  Global:           Global-Feld des jeweiligen Threads                       */
/*-----------------------------------------------------------------------------*/
WORD	OpenDialog( BYTE *TitelStr, WORD Type, HNDL_OBJ HandleDialog, DIALOG_DATA *DialogData, WORD Global[15] )
{
	DIALOG	*Dialog;
	Dialog = MT_wdlg_create( HandleDialog, DialogData->Tree, DialogData, 0, DialogData, WDLG_BKGD, Global );
	if( Dialog )
		if( MT_wdlg_open( Dialog, TitelStr, NAME + MOVER + CLOSER + ICONIFIER, -1, -1, 0, DialogData, Global ))
		{
			if( TitelStr )
				MT_wind_set_string( MT_wdlg_get_handle( Dialog, Global ), WF_NAME, TitelStr, Global );
			if( NewWindow( MT_wdlg_get_handle( Dialog, Global ), Type, HandleWdialog, MenuKontextDialog, DialogData ) == E_OK )
			{
				DialogData->Dialog = Dialog;
				return( E_OK );
			}
		}
		else
			MT_wdlg_delete( Dialog, Global );
	return( ERROR );
}

WORD	OpenDialogX( BYTE *TitelStr, WORD Type, WORD Elements, WORD x, WORD y, HNDL_OBJ HandleDialog, DIALOG_DATA *DialogData, WORD Global[15] )
{
	DIALOG	*Dialog;
	Dialog = MT_wdlg_create( HandleDialog, DialogData->Tree, DialogData, 0, DialogData, WDLG_BKGD, Global );
	if( Dialog )
		if( MT_wdlg_open( Dialog, TitelStr, Elements, x, y, 0, DialogData, Global ))
		{
			if( TitelStr )
				MT_wind_set_string( MT_wdlg_get_handle( Dialog, Global ), WF_NAME, TitelStr, Global );
			if( NewWindow( MT_wdlg_get_handle( Dialog, Global ), Type, HandleWdialog, MenuKontextDialog, DialogData ) == E_OK )
			{
				DialogData->Dialog = Dialog;
				return( E_OK );
			}
		}
		else
			MT_wdlg_delete( Dialog, Global );
	return( ERROR );
}

/*-----------------------------------------------------------------------------*/
/* Fensterdialog schliežen *und* l”schen                                       */
/* Funktionsergebnis: -                                                        */
/*  Dialog:           Zeiger auf Dialog                                        */
/*  Global:           Global-Feld des jeweiligen Threads                       */
/*-----------------------------------------------------------------------------*/
void	CloseDialog( DIALOG_DATA *DialogData, WORD Global[15] )
{
	if( DialogData->Dialog )
	{
		WORD		i, j;
		MT_wdlg_close( DialogData->Dialog, &i, &j, Global );
		if( isIconifiedWindow( MT_wdlg_get_handle( DialogData->Dialog, Global )) ||
		    isAllIconifiedWindow( MT_wdlg_get_handle( DialogData->Dialog, Global )))
		{
			OBJECT	*DialogTree;
			GRECT		Rect;
			MT_wdlg_get_tree( DialogData->Dialog, &DialogTree, &Rect, Global );
			free( DialogTree );
		}

		DelWindow( MT_wdlg_get_handle( DialogData->Dialog, Global ));
		MT_wdlg_delete( DialogData->Dialog, Global );
		DialogData->Dialog = NULL;
	}
	if( DialogData->HndlClsDialog )
		DialogData->HndlClsDialog( DialogData, Global );
}

WORD	HandleWDialogIcon( WORD *Obj, DIALOG *Dialog, WORD Global[15] )
{
	OBJECT		*DialogTree;
	GRECT			Rect;
	WORD			a;
	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );

	if( DialogTree[*Obj].ob_type == G_CICON || DialogTree[*Obj].ob_type == G_ICON )
	{
		WORD	Parent;
		EVNTDATA	Ev;
		Parent = DialogTree[*Obj].ob_next;
		if( !(DialogTree[Parent].ob_flags & SELECTABLE ) && !(DialogTree[Parent].ob_flags & TOUCHEXIT ))
			return( 0 );
		if( !(DialogTree[Parent].ob_state & SELECTED ))
		{
			DialogTree[Parent].ob_state |= SELECTED;
			DoRedraw( Dialog, &Rect, Parent, Global );
		}
		do
		{
			MT_graf_mkstate( &Ev, Global );
			a = MT_objc_find( DialogTree, ROOT, MAX_DEPTH, Ev.x, Ev.y, Global );
			if( a != *Obj && a != Parent )
			{
				DialogTree[Parent].ob_state &= ~SELECTED;
				DoRedraw( Dialog, &Rect, Parent, Global );
				return( 1 );
			}
		}
		while( Ev.bstate & 1 );
		if( a == *Obj || a == Parent )
		{
			*Obj = Parent;
			return( 0 );
		}
	}
	return( 0 );
}

WORD	HandleWdialog( WORD WinId, EVNT *Events, void *UserData, WORD Global[15] )
{
	DIALOG_DATA *DialogData = ( DIALOG_DATA * ) GetWindowData( WinId );
	if( !DialogData )
		return( ERROR );

	if( DialogData->HndlCheckDialog && DialogData->HndlCheckDialog( DialogData, Events, Global ) != E_OK )
		return( E_OK );

	if(( Events->mwhich & MU_MESAG ) && Events->msg[0] == WIN_CMD )
	{
		EVNT	Evnt;
		WORD	Cursor;
		if( Events->msg[4] == WIN_DRAGDROP )
		{
			DD_INFO	*DdInfo = *( DD_INFO ** )&( Events->msg[5] );
			WORD	Obj = MT_objc_find( DialogData->Tree, ROOT, MAX_DEPTH, DdInfo->mx, DdInfo->my, Global );
			if( Obj != -1 )
			{
				if( DialogData->Tree[Obj].ob_flags & EDITABLE )
				{
					if( DdInfo->format == '.TXT' )
						DropEditWdialog( DialogData->Dialog, Obj, (( BYTE * ) DdInfo->puf ), Global );
					else
						MT_form_alert( 1, TreeAddr[ALERTS][DD_ONLY_TEXT].ob_spec.free_string, Global );
				}
#ifdef	EDITOBJ
				else	if( DialogData->Tree[Obj].ob_type == G_EDIT )
				{
					BYTE		*Puf;
					LONG		PufLen, TextLen;
					OBJECT	*DialogTree;
					GRECT		Rect;
					MT_wdlg_get_tree( DialogData->Dialog, &DialogTree, &Rect, Global );
					if( mt_edit_cursor( DialogData->Tree, Obj, -1, -1, Global ) == 0 )
					{
						mt_edit_get_buf( DialogData->Tree, Obj, &Puf, &PufLen, &TextLen, Global );
						strcpy( Puf, ( BYTE * ) DdInfo->puf );
						mt_edit_set_buf( DialogData->Tree, Obj, Puf, PufLen, Global );
						mt_edit_set_cursor( DialogData->Tree, Obj, Puf + strlen( Puf ), Global );
						DoRedraw( DialogData->Dialog, &Rect, Obj, Global );
					}
				}
#endif
				else
				{
					if( DialogData->HndlDdDialog )
						DialogData->HndlDdDialog( DialogData, Events, Global );
				}
			}
			return( E_OK );
		}
		if( Events->msg[4] == WIN_COPY )
		{
			Evnt.mwhich = MU_KEYBD;
			Evnt.key = 0x2e03;
			Evnt.kstate = 0;
			if( MT_wdlg_get_edit( DialogData->Dialog, &Cursor, Global ))
				MT_wdlg_evnt( DialogData->Dialog, &Evnt, Global );
			else	if( DialogData->HndlEditDialog )
				DialogData->HndlEditDialog( DialogData, &Evnt, Global );
			return( E_OK );
		}
		if( Events->msg[4] == WIN_CUT )
		{
			Evnt.mwhich = MU_KEYBD;
			Evnt.key = 0x2d18;
			Evnt.kstate = 0;
			if( MT_wdlg_get_edit( DialogData->Dialog, &Cursor, Global ))
				MT_wdlg_evnt( DialogData->Dialog, &Evnt, Global );
			else	if( DialogData->HndlEditDialog )
				DialogData->HndlEditDialog( DialogData, &Evnt, Global );
			return( E_OK );
		}
		if( Events->msg[4] == WIN_PASTE )
		{
			Evnt.mwhich = MU_KEYBD;
			Evnt.key = 0x2f16;
			Evnt.kstate = 0;
			if( MT_wdlg_get_edit( DialogData->Dialog, &Cursor, Global ))
				MT_wdlg_evnt( DialogData->Dialog, &Evnt, Global );
			else	if( DialogData->HndlEditDialog )
				DialogData->HndlEditDialog( DialogData, &Evnt, Global );
			return( E_OK );
		}
		if( Events->msg[4] == WIN_MARK_ALL )
		{
			Evnt.mwhich = MU_KEYBD;
			Evnt.key = 0x1e01;
			Evnt.kstate = 0;
			if( MT_wdlg_get_edit( DialogData->Dialog, &Cursor, Global ))
				MT_wdlg_evnt( DialogData->Dialog, &Evnt, Global );
			else	if( DialogData->HndlEditDialog )
				DialogData->HndlEditDialog( DialogData, &Evnt, Global );
			return( E_OK );
		}
		if( Events->msg[4] == WIN_HELP )
		{
			StGuide_Action( DialogData->Tree, DialogData->TreeIndex, Global );
			return( E_OK );
		}
	}
	if(( Events->mwhich & MU_MESAG ) && Events->msg[0] == WM_ICONIFY )
	{
		OBJECT	*IconifyTree = malloc( 2 * sizeof( OBJECT ));
		if( !IconifyTree )
		{
			Cconout( '\g' );
			return( ENSMEM );
		}
		memcpy( IconifyTree, TreeAddr[ICONIFY], 2 * sizeof( OBJECT ));
		MT_wdlg_set_iconify( DialogData->Dialog, ( GRECT *) &( Events->msg[4] ), NULL, IconifyTree, ICONIFY_ICON, Global );
		IconifyWindow( MT_wdlg_get_handle( DialogData->Dialog, Global ));
		return( E_OK );
	}
	if(( Events->mwhich & MU_MESAG ) && Events->msg[0] == WM_UNICONIFY )
	{
		OBJECT	*IconifyTree;
		GRECT		Rect;
		WORD		Obj, Cursor;
		UnIconifyWindow( MT_wdlg_get_handle( DialogData->Dialog, Global ));
		Obj = MT_wdlg_get_edit( DialogData->Dialog, &Cursor, Global );
		MT_wdlg_get_tree( DialogData->Dialog, &IconifyTree, &Rect, Global );
		MT_wdlg_set_uniconify( DialogData->Dialog, ( GRECT *) &( Events->msg[4] ), NULL, DialogData->Tree, Global );
		free( IconifyTree );
		MT_wdlg_set_edit( DialogData->Dialog, 0, Global );
		return( E_OK );
	}
	if(( Events->mwhich & MU_MESAG ) && Events->msg[0] == AP_DRAGDROP )
	{
		BYTE	*Ret;
		LONG	Size;
		ULONG	FormatRcvr[8], Format;
		WORD	Obj = MT_objc_find( DialogData->Tree, ROOT, MAX_DEPTH, Events->mx, Events->my, Global );
		if( Obj != -1 )
		{
			if(( DialogData->Tree[Obj].ob_flags & EDITABLE ) || DialogData->Tree[Obj].ob_type == G_EDIT )
			{
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
					Evnt.mwhich = MU_MESAG;
					Evnt.msg[0] = WIN_CMD;
					Evnt.msg[1] = Global[2];
					Evnt.msg[2] = 0;
					Evnt.msg[3] = WinId;
					Evnt.msg[4] = WIN_DRAGDROP;
					*( DD_INFO ** )&( Evnt.msg[5] ) = &DdInfo;
					HandleWdialog( WinId, &Evnt, UserData, Global );
					free( Ret );
				}		
			}
			else
			{
				if( DialogData->HndlDdDialog )
					DialogData->HndlDdDialog( DialogData, Events, Global );
				else
					NoDragDrop( Events );
			}
		}
		return( E_OK );
	}

	if(( Events->mwhich & MU_MESAG ) && Events->msg[0] == BUBBLEGEM_REQUEST )
	{
		if( isIconifiedWindow( WinId ))
			Events->mwhich &= ~MU_MESAG;
		else	if( !DialogData->HndlHelpDialog )
		{
			WORD	Obj = MT_objc_find( DialogData->Tree, ROOT, MAX_DEPTH, Events->msg[4], Events->msg[5], Global );
			if( Obj != -1 )
			{
				BG_Action( DialogData->Tree, DialogData->TreeIndex, Obj, Events->msg[4], Events->msg[5], Global );
				Events->mwhich &= ~MU_MESAG;
			}
		}
		else
		{
			EVNT	lEvents;
			lEvents.mwhich = MU_BUTTON;
			lEvents.mx = Events->msg[4];
			lEvents.my = Events->msg[5];
			DialogData->HndlHelpDialog( DialogData, &lEvents, Global );
			Events->mwhich &= ~MU_MESAG;
		}
		
	}
	
	if(( Events->mwhich & MU_BUTTON ) && Events->mbutton == 1 )
	{
		WORD	Obj = MT_objc_find( DialogData->Tree, ROOT, MAX_DEPTH, Events->mx, Events->my, Global );
		if( Obj != -1 )
		{
			EVNTDATA	EvData;
			BYTE	*Start, *End;
			MT_graf_mkstate( &EvData, Global );
			
#ifdef	EDITOBJ
			if( DialogData->Tree[Obj].ob_type == G_EDIT )
				mt_edit_get_sel( DialogData->Tree, Obj, &Start, &End, Global );
			if( EvData.bstate == 1 && (( DialogData->Tree[Obj].ob_flags & EDITABLE ) && strlen( DialogData->Tree[Obj].ob_spec.tedinfo->te_ptext ) || 
			    DialogData->Tree[Obj].ob_type == G_EDIT && Start ))
#else
			if( EvData.bstate == 1 && ( DialogData->Tree[Obj].ob_flags & EDITABLE ) && strlen( DialogData->Tree[Obj].ob_spec.tedinfo->te_ptext ))
#endif
			{
				MOBLK	M1;
				EVNT	Ev;
				WORD	Cxy[4], Pxy[10], Dx = 0, Dy = 0, X = Events->mx, Y = Events->my, Flag = 0;
				GRECT	ObjRect;
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
				vs_clip( VdiHandle, 1, Cxy );
				vsl_udsty( VdiHandle, 0xaaaa );
				vsl_type( VdiHandle, 7 );
				vswr_mode( VdiHandle, MD_XOR );
				MT_objc_offset( DialogData->Tree, Obj, &ObjRect.g_x, &ObjRect.g_y, Global );
				ObjRect.g_w = DialogData->Tree[Obj].ob_width;
				ObjRect.g_h = DialogData->Tree[Obj].ob_height;
				Pxy[0] = ObjRect.g_x;	Pxy[1] = ObjRect.g_y;
				Pxy[2] = Pxy[0] + ObjRect.g_w;	Pxy[3] = Pxy[1];
				Pxy[4] = Pxy[2];	Pxy[5] = Pxy[1] + ObjRect.g_h;
				Pxy[6] = Pxy[0]; Pxy[7] = Pxy[5];
				Pxy[8] = Pxy[0]; Pxy[9] = Pxy[1];
				v_pline( VdiHandle, 5, Pxy );
				MT_graf_mouse( M_ON, NULL, Global );

				do
				{
					MT_EVNT_multi( MU_BUTTON + MU_M1, 1, 1, 0, &M1, NULL, 0, &Ev, Global );
					M1.m_x = Ev.mx;
					M1.m_y = Ev.my;
					if( Ev.mx < ObjRect.g_x || Ev.mx > ObjRect.g_x + ObjRect.g_w ||
					    Ev.my < ObjRect.g_y || Ev.my > ObjRect.g_y + ObjRect.g_h )
						Flag = 1;
					Dx = Ev.mx - X; Dy = Ev.my - Y;
					if( Dx || Dy )
					{
						MT_graf_mouse( M_OFF, NULL, Global );
						v_pline( VdiHandle, 5, Pxy );
						Pxy[0] += Dx;	Pxy[1] += Dy;
						Pxy[2] += Dx;	Pxy[3] += Dy;
						Pxy[4] += Dx;	Pxy[5] += Dy;
						Pxy[6] += Dx;	Pxy[7] += Dy;
						Pxy[8] += Dx;	Pxy[9] += Dy;
						v_pline( VdiHandle, 5, Pxy );
						X = Ev.mx; Y = Ev.my;
						MT_graf_mouse( M_ON, NULL, Global );
					}
				}
				while( !( Ev.mwhich & MU_BUTTON ));
				MT_graf_mouse( M_OFF, NULL, Global );
				v_pline( VdiHandle, 5, Pxy );
				vs_clip( VdiHandle, 0, Cxy );
				MT_graf_mouse( M_ON, NULL, Global );
				MT_graf_mouse( 259, NULL, Global );
				MT_wind_update( END_MCTRL, Global );
				MT_wind_update( END_UPDATE, Global );
				{
					WORD	DestWinId = MT_wind_find( Ev.mx, Ev.my, Global );
					WORD	AppId, w2, w3, w4;
					BYTE	*Puf;
					LONG	Len;
					if( DialogData->Tree[Obj].ob_type == G_EDIT )
					{
						Puf = Start;
						Len = End - Start;
					}
					else
					{
						Puf = strdup( DialogData->Tree[Obj].ob_spec.tedinfo->te_ptext );
						Len = strlen( Puf );
					}
					if( !Puf )
						return( ENSMEM );
					if( DestWinId != -1 /*&& DestWinId != WinId */ && Flag )
					{
						MT_wind_get( DestWinId, WF_OWNER, &AppId, &w2, &w3, &w4, Global );
						if( AppId != Global[2] )
							PutDragDrop( DestWinId, Ev.mx, Ev.my, Ev.kstate, AppId, '.TXT', Puf, Len, Global );
						else
						{
							EVNT	lEvent;
							DD_INFO	DdInfo;
							DdInfo.format = '.TXT';
							DdInfo.mx = Ev.mx;
							DdInfo.my = Ev.my;
							DdInfo.kstate = Ev.kstate;
							DdInfo.size = Len;
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
					if( DialogData->Tree[Obj].ob_type != G_EDIT )
						free( Puf );
				}
				return( E_OK );
			}
		}
	}
	if(( Events->mwhich & MU_BUTTON ) && Events->mbutton == 2 )
	{
		if( isIconifiedWindow( WinId ))
			Events->mwhich &= ~MU_MESAG;
		else	if( !DialogData->HndlHelpDialog )
		{
			WORD	Obj = MT_objc_find( DialogData->Tree, ROOT, MAX_DEPTH, Events->mx, Events->my, Global );
			if( Obj != -1 )
			{
				if( DialogData->Tree[Obj].ob_type & 0x0100 )
				{
				}
				else	if( BG_Action( DialogData->Tree, DialogData->TreeIndex, Obj, Events->mx, Events->my, Global ) == E_OK )
					Events->mwhich &= ~MU_BUTTON;
				else	if( DialogData->HndlMesagDialog )
				{
					EVNT	lEvent;
					lEvent.mwhich = MU_MESAG;
					lEvent.msg[0] = WIN_CMD;
					lEvent.msg[1] = Global[2];
					lEvent.msg[2] = 0;
					lEvent.msg[3] = WinId;
					lEvent.msg[4] = WIN_KONTEXT_1;
					if( DialogData->HndlMesagDialog( DialogData, &lEvent, Global ) == E_OK )
						Events->mwhich &= ~MU_BUTTON;
				}
			}
		}
		else
		{
			if( DialogData->HndlHelpDialog( DialogData, Events, Global ) == E_OK )
				Events->mwhich &= ~MU_BUTTON;
		}
	}
	if(( Events->mwhich & MU_KEYBD ) && Events->key == 0x6200 )
	{
		KeyEvent( Events->key );
		Events->mwhich &= ~MU_KEYBD;
	}

	if(( Events->mwhich & MU_KEYBD ) && DialogData->HndlEditDialog )
	{
		WORD	a, b;
#ifdef	IRC_CLIENT
/* Abfrage auf SmileKeys */
		if(( Events->kstate & KsALT ) && ( Events->kstate & KsSHIFT ))
		{
			WORD	Key = MapKey( Events->key ) & 0x00ff;
			if( Key == '(' || Key == ')' || Key == '/' || Key == ';' || Key == '.' )
				DialogData->HndlEditDialog( DialogData, Events, Global );
		}
#endif
		if( !((( Events->kstate & KsCONTROL ) || ( Events->kstate & KsALT )) && ( Events->kstate & KsSHIFT ) && isMenuKey( Events->key, &a, &b )))
			DialogData->HndlEditDialog( DialogData, Events, Global );
	}
	if((( Events->mwhich & MU_MESAG ) || ( Events->mwhich & MU_BUTTON )) && DialogData->HndlEditDialog )
		DialogData->HndlEditDialog( DialogData, Events, Global );

	if( Events->mwhich & MU_KEYBD )
	{
		WORD	a, b;
		if( !((( Events->kstate & KsCONTROL ) || ( Events->kstate & KsALT )) && ( Events->kstate & KsSHIFT ) && isMenuKey( Events->key, &a, &b )))
			if( MT_wdlg_evnt( DialogData->Dialog, Events, Global ) == 0 )
			{
				CloseDialog( DialogData, Global );
				return( E_OK );
			}
	}
	else
		if( MT_wdlg_evnt( DialogData->Dialog, Events, Global ) == 0 )
		{
			CloseDialog( DialogData, Global );
			return( E_OK );
		}

	if(( Events->mwhich & MU_MESAG ) && DialogData->HndlMesagDialog )
	{
		if( DialogData->HndlMesagDialog( DialogData, Events, Global ) != E_OK )
		{
			CloseDialog( DialogData, Global );
			return( E_OK );
		}
	}

	if(( Events->mwhich & MU_TIMER ) && DialogData->HndlTimerDialog )
		DialogData->HndlTimerDialog( DialogData, Global );

	return( ERROR );
}

ULONG	MenuKontextDialog( WORD WinId, WORD Global[15] )
{
	DIALOG_DATA *DialogData = ( DIALOG_DATA * ) GetWindowData( WinId );
	WORD		Cursor, Kind;
	ULONG		Ret = 0;
	if( MT_wdlg_get_edit( DialogData->Dialog, &Cursor, Global ))
	{
		Ret |= MENUE_KONTEXT_COPY;
		Ret |= MENUE_KONTEXT_CUT;
		Ret |= MENUE_KONTEXT_PASTE;
	}
	else	if( DialogData->HndlEditDialog )
	{
		Ret |= MENUE_KONTEXT_COPY;
		Ret |= MENUE_KONTEXT_CUT;
		Ret |= MENUE_KONTEXT_PASTE;
		Ret |= MENUE_KONTEXT_MARK_ALL;
	}

	Ret |= MENUE_KONTEXT_WINDOW_CYCLE;
	Ret |= MENUE_KONTEXT_WINDOW_CLOSE;

	MT_wind_get_int( WinId, WF_KIND, &Kind, Global );
	if( Kind & INFO )
		Ret |= MENUE_KONTEXT_WINDOW_FULL;
	return( Ret );
}

WORD	URL_Action( OBJECT *Tree, WORD Obj, WORD Global[15] )
{
	if( Tree[Obj].ob_type & 0x0200 )
	{
		WORD	Msg[8];
		Msg[0] = VA_START;
		Msg[1] = Global[2];
		Msg[2] = 0;
		*( BYTE **)&( Msg[3] ) = strcpy( Xmalloc( strlen( Tree[Obj].ob_spec.tedinfo->te_ptext ) + 1, RAM_READABLE ), Tree[Obj].ob_spec.tedinfo->te_ptext );
		Msg[5] = 0;
		Msg[6] = 0;
		Msg[7] = 0;
		MT_appl_write( AvAppId, 16, Msg, Global );
		return( 1 );
	}
	return( E_OK );
}

static void	DropEditWdialog( DIALOG *Dialog, WORD Obj, BYTE *Puf, WORD Global[15] )
{
	GRECT		Rect;
	OBJECT	*DialogTree;
	LONG 		i, j;
	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );
	MT_wdlg_set_edit( Dialog, 0, Global );

	i = strlen( DialogTree[Obj].ob_spec.tedinfo->te_ptext );
	j = 0;
	while( i < DialogTree[Obj].ob_spec.tedinfo->te_txtlen - 1 && j < strlen( Puf ))
	{
		if(( DialogTree[Obj].ob_spec.tedinfo->te_pvalid )[0/*i*/] == '9' && !isdigit( Puf[j] ))
		{
			j++;
		}
		else
		{
			( DialogTree[Obj].ob_spec.tedinfo->te_ptext )[i] = Puf[j];
			i++;
			j++;
		}
	}
	if( i < DialogTree[Obj].ob_spec.tedinfo->te_txtlen - 1 )
		( DialogTree[Obj].ob_spec.tedinfo->te_ptext )[i] = 0;
	DoRedraw( Dialog, &Rect, Obj, Global );
	MT_wdlg_set_edit( Dialog, Obj, Global );
}

WORD	AlertDialogX( WORD DefaultButton, BYTE *Str, BYTE *Titel, CLS_ALERT_DIALOG CloseAlertDialog, void *UserData, WORD Global[15], WORD nPar, ... )
{
	va_list VaList;
	BYTE	*Par[20];
	WORD	Line = 0, i = 4, j = 0, k, LineLen = 0, ButtonLen = 0, Button = 0;
	WORD	Icon = Str[1] - '0';
	DIALOG_DATA *DialogData = malloc( sizeof( DIALOG_DATA ));
	ALERT_WINDOW *AlertWindow;

	if( nPar )
	{
		va_start( VaList, x );
		for( k = 0; k < nPar; k++ )
			Par[k] = va_arg( VaList, BYTE * );
		va_end( VaList );
	}
	if( !DialogData )
		return( ENSMEM );
	if(( AlertWindow = malloc( sizeof( ALERT_WINDOW ))) == NULL )
	{
		free( DialogData );
		return( ENSMEM );
	}

	if(( DialogData->Tree = CopyTree( TreeAddr[ALERT] )) == NULL )
	{
		free( DialogData );
		free( AlertWindow );
		return( ENSMEM );
	}

	AlertWindow->Titel = NULL;
	AlertWindow->UserData = UserData;
	if( Titel )
		AlertWindow->Titel = strdup( Titel );
	AlertWindow->ClsAlertDialog = CloseAlertDialog;

	DialogData->Dialog = NULL;
	DialogData->HndlDdDialog = NULL;
	DialogData->HndlClsDialog = HndlClsAlertDialog;
	DialogData->HndlMesagDialog = NULL;
	DialogData->HndlTimerDialog = NULL;
	DialogData->HndlEditDialog = NULL;
	DialogData->HndlHelpDialog = NULL;
	DialogData->HndlCheckDialog = NULL;
	DialogData->UserData = AlertWindow;
	DialogData->TreeIndex = ALERT;

	DialogData->Tree[AlertIcon[0]].ob_flags |= HIDETREE;
	DialogData->Tree[AlertIcon[1]].ob_flags |= HIDETREE;
	DialogData->Tree[AlertIcon[2]].ob_flags |= HIDETREE;
	DialogData->Tree[AlertButton[0]].ob_flags |= HIDETREE;
	DialogData->Tree[AlertButton[1]].ob_flags |= HIDETREE;
	DialogData->Tree[AlertButton[2]].ob_flags |= HIDETREE;
	if( Icon != 0 )
	{
		DialogData->Tree[AlertIcon[Icon-1]].ob_flags &= ~HIDETREE;
		DialogData->Tree[AlertIcon[Icon-1]].ob_y = DialogData->Tree[AlertIcon[0]].ob_y;
	}
	memset( DialogData->Tree[AlertButton[0]].ob_spec.free_string, 0, strlen( DialogData->Tree[AlertButton[0]].ob_spec.free_string ));
	memset( DialogData->Tree[AlertButton[1]].ob_spec.free_string, 0, strlen( DialogData->Tree[AlertButton[1]].ob_spec.free_string ));
	memset( DialogData->Tree[AlertButton[2]].ob_spec.free_string, 0, strlen( DialogData->Tree[AlertButton[2]].ob_spec.free_string ));
	memset( DialogData->Tree[AlertLine[0]].ob_spec.free_string, 0, strlen( DialogData->Tree[AlertLine[0]].ob_spec.free_string ));
	memset( DialogData->Tree[AlertLine[1]].ob_spec.free_string, 0, strlen( DialogData->Tree[AlertLine[1]].ob_spec.free_string ));
	memset( DialogData->Tree[AlertLine[2]].ob_spec.free_string, 0, strlen( DialogData->Tree[AlertLine[2]].ob_spec.free_string ));
	memset( DialogData->Tree[AlertLine[3]].ob_spec.free_string, 0, strlen( DialogData->Tree[AlertLine[3]].ob_spec.free_string ));
	memset( DialogData->Tree[AlertLine[4]].ob_spec.free_string, 0, strlen( DialogData->Tree[AlertLine[4]].ob_spec.free_string ));

	while( Str[i] != ']' )
	{
		if( Str[i] == '|' )
		{
			j = 0;
			Line++;
		}
		else	if( Str[i] == '%' )
		{
			WORD	Arg = Str[++i] - '0';
			k = 0;
			while( Par[Arg][k] != 0 )
				DialogData->Tree[AlertLine[Line]].ob_spec.free_string[j++] = Par[Arg][k++];
		}
		else
			( DialogData->Tree[AlertLine[Line]].ob_spec.free_string )[j++] = Str[i];
		i++;
	}
	i += 2;
	Line++;
	for( j = 0; j < Line; j++ )
	{
		k = strlen( DialogData->Tree[AlertLine[j]].ob_spec.free_string );
		if( k > LineLen )
			LineLen = k;
	}
	DialogData->Tree[ROOT].ob_width = DialogData->Tree[AlertLine[0]].ob_x + ( LineLen + 2 ) * PwChar;

	if( Button == DefaultButton - 1 )
		DialogData->Tree[AlertButton[Button]].ob_state &= ~WHITEBAK;

	while( Str[i] != ']' )
	{
		WORD	Pos = -1;
		j = 0;
		DialogData->Tree[AlertButton[Button]].ob_flags &= ~HIDETREE;
		while( Str[i] != ']' && Str[i++] != '|' )
		{
			( DialogData->Tree[AlertButton[Button]].ob_spec.free_string )[j++] = Str[i-1];
			if( Pos == -1 && Str[i-1] != ' ' )
			{
				Pos = j - 1;
				DialogData->Tree[AlertButton[Button]].ob_state |= ( 0xff00 & ( Pos << 8 ));
			}
				
		}
		DialogData->Tree[AlertButton[Button]].ob_width = ( strlen( DialogData->Tree[AlertButton[Button]].ob_spec.free_string ) + 2 ) * PwChar;
		Button++;
	}
	if( DefaultButton != 0 )
		DialogData->Tree[AlertButton[DefaultButton-1]].ob_flags |= DEFAULT;
	for( j = 0; j < Button; j++ )
		ButtonLen += strlen( DialogData->Tree[AlertButton[j]].ob_spec.free_string );
	ButtonLen += Button * 4;
	if( DialogData->Tree[AlertButton[0]].ob_x + ButtonLen * PwChar > DialogData->Tree[ROOT].ob_width )
		DialogData->Tree[ROOT].ob_width = DialogData->Tree[AlertButton[0]].ob_x + ButtonLen * PwChar;
	j = DialogData->Tree[ROOT].ob_width - 2 * PwChar;
	for( i = Button - 1; i >= 0; i-- )
	{
		DialogData->Tree[AlertButton[i]].ob_x = j - DialogData->Tree[AlertButton[i]].ob_width;
		j -= DialogData->Tree[AlertButton[i]].ob_width + 2 * PwChar;
	}

	DialogData->Tree[ROOT].ob_height = DialogData->Tree[AlertLine[0]].ob_y + ( Line + 3 ) * PhChar + PhChar/2;
	DialogData->Tree[AlertButton[0]].ob_y = DialogData->Tree[AlertLine[0]].ob_y + ( Line + 1 ) * PhChar + PhChar/2;
	DialogData->Tree[AlertButton[1]].ob_y = DialogData->Tree[AlertLine[0]].ob_y + ( Line + 1 ) * PhChar + PhChar/2;
	DialogData->Tree[AlertButton[2]].ob_y = DialogData->Tree[AlertLine[0]].ob_y + ( Line + 1 ) * PhChar + PhChar/2;

	if( OpenDialogX( AlertWindow->Titel, WIN_ALERT_WINDOW, NAME + MOVER, -1, -1, HandleAlertDialog, DialogData, Global ) != E_OK )
	{
		FreeTree( DialogData->Tree );
		free( DialogData->UserData );
		free( DialogData );
		return( ERROR );
	}
	return(( AlertWindow->WinId = MT_wdlg_get_handle( DialogData->Dialog, Global )));
}

static WORD cdecl	HandleAlertDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData )
{
	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_CLSD:
				if( Events->msg[4] == WIN_CLOSE_WITHOUT_DEMAND )
					return( 0 );
				else
					return( 1 );
		}
	}
	else
		return( 0 );
	return( 1 );
}
static WORD HndlClsAlertDialog( void *DialogData, WORD Global[15] )
{
	ALERT_WINDOW	*AlertWindow = ( ALERT_WINDOW * )(( DIALOG_DATA * ) DialogData )->UserData;
	WORD	Button = 0;
	if((( DIALOG_DATA * ) DialogData )->Tree[AlertButton[0]].ob_state & SELECTED )
		Button = 1;
	else	if((( DIALOG_DATA * ) DialogData )->Tree[AlertButton[1]].ob_state & SELECTED )
		Button = 2;
	else	if((( DIALOG_DATA * ) DialogData )->Tree[AlertButton[2]].ob_state & SELECTED )
		Button = 3;
	if( AlertWindow->ClsAlertDialog )
		AlertWindow->ClsAlertDialog( AlertWindow->UserData, Button, AlertWindow->WinId, Global );
	if( AlertWindow->Titel )
		free( AlertWindow->Titel );
	free( AlertWindow );
	FreeTree( (( DIALOG_DATA * ) DialogData )->Tree );
	free( DialogData );
	return( E_OK );
}