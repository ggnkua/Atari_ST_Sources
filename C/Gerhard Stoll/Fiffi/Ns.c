#include	<mt_mem.h>
#include	<PORTAB.H>
#include <STDDEF.H>
#include	<TOS.H>
#include	<MT_AES.H>
#include <STDLIB.H>
#include <STDIO.H>
#include	<STRING.H>
#include <CTYPE.H>
#include <SETJMP.H>

#include "main.h"
#include	"Ns.h"
#include	"Window.h"
#include	"Url.h"
#include	"GemFtp.h"
#include "Fiffi.h"
#include "mapkey.h"
#include	"edscroll.h"

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern WORD		Global[15];
extern WORD		AppId;
extern WORD		magic_version;
extern LONG		magic_date;
extern OBJECT	**TreeAddr;
extern BYTE		**FstringAddr;

extern OBJECT	*HotlistPopupTree;

#ifdef	V120
extern BYTE		**HotlistName;
#endif
extern BYTE		**HotlistHost;
extern UWORD	*HotlistPort;	
extern BYTE		**HotlistUid;
extern BYTE		**HotlistPwd;
extern BYTE		**HotlistDir;
extern UWORD	ComPort;

/*-----------------------------------------------------------------------------*/
/* Service-Routine fÅr NewSession                                              */
/*-----------------------------------------------------------------------------*/
WORD	cdecl	HandleNewSessionDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD )
{
	OBJECT		*DialogTree;
	GRECT			Rect;
	static XTED	HostXted, UidXted, DirXted, PwdXted;
	static BYTE	HostTmplt[EditLen+1], HostTxt[EditLen+1], DirTmplt[EditLen+1], DirTxt[EditLen+1];
	static BYTE	UidTmplt[EditLen+1], UidTxt[EditLen+1];
	static BYTE	PwdTmplt[EditLen+1], PwdTxt[EditLen+1];

	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );

	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_CLSD:
			{
				return( 0 );
			}

			case	HNDL_INIT:
			{
				WORD	isScroll;
				DialogTree[NS_OK_I].ob_state |= DISABLED;
				DialogTree[NS_OK_I].ob_state &= ~SELECTED;
				DialogTree[NS_OK].ob_state |= DISABLED;
				DialogTree[NS_OK].ob_state &= ~SELECTED;
				DialogTree[NS_OK].ob_flags &= ~SELECTABLE;
				DialogTree[NS_CANCEL].ob_state &= ~SELECTED;
				DialogTree[NS_HOTLIST].ob_state &= ~SELECTED;
				DialogTree[NS_HOTLIST_I].ob_state &= ~SELECTED;
				
				if( magic_version && magic_date >= 0x19950829L )
					isScroll = 1;
				else
					isScroll = 0;

				if( !HostXted.xte_ptmplt )
					InitScrlted(&DialogTree[NS_HOST], isScroll, &HostXted, HostTxt, HostTmplt, EditLen);
				if( !UidXted.xte_ptmplt )
					InitScrlted(&DialogTree[NS_UID], isScroll, &UidXted, UidTxt, UidTmplt, EditLen);
				if( !PwdXted.xte_ptmplt )
					InitScrlted(&DialogTree[NS_PWD], isScroll, &PwdXted, PwdTxt, PwdTmplt, EditLen);
				if( !DirXted.xte_ptmplt )
					InitScrlted(&DialogTree[NS_DIR], isScroll, &DirXted, DirTxt, DirTmplt, EditLen);

				strcpy( HostTxt, "" );
				strcpy( DirTxt, "" );
				ltoa( ComPort, DialogTree[NS_PORT].ob_spec.tedinfo->te_ptext, 10 );
				strcpy( DialogTree[NS_UID].ob_spec.tedinfo->te_ptext, "" );
				strcpy( DialogTree[NS_PWD].ob_spec.tedinfo->te_ptext, "" );

				break;
			}
			
			case	HNDL_EDIT:
			{
				WORD	a, b;
				if( IsMenuKey( Events->key, &a, &b ))
					return( 0 );
				break;
			}
			case	HNDL_MESG:
			{
				if( Events->msg[0] == WM_ICONIFY )
				{
					if( !isIconifiedWindow( MT_wdlg_get_handle( Dialog, Global )))
					{
						DialogTree = malloc( 2 * sizeof( OBJECT ));
						if( !DialogTree )
						{
							MemErr( "Ns" );
							return( 0 );
						}
						memcpy( DialogTree, TreeAddr[ICONIFY], 2 * sizeof( OBJECT ));
						MT_wdlg_set_iconify( Dialog, ( GRECT *) &( Events->msg[4] ), NULL, DialogTree, ICONIFY_ICON, Global );
						IconifyWindow( MT_wdlg_get_handle( Dialog, Global ));
					}
					else
						MT_wind_set_grect( MT_wdlg_get_handle( Dialog, Global ), WF_CURRXYWH, ( GRECT *) &( Events->msg[4] ), Global );
				}
				if( Events->msg[0] == WM_UNICONIFY )
				{
					MT_wdlg_set_uniconify( Dialog, ( GRECT *) &( Events->msg[4] ), NULL, TreeAddr[NS], Global );
					UnIconifyWindow( MT_wdlg_get_handle( Dialog, Global ));
					free( DialogTree );
				}
				if( Events->msg[0] == WM_ALLICONIFY )
				{
					WORD	Msg[8];
					Msg[0] = WM_ALLICONIFY;
					Msg[1] = Global[2];
					Msg[2] = 0;
					Msg[3] = 0;
					Msg[4] = Events->msg[4]; Msg[5] = Events->msg[5]; Msg[6] = Events->msg[6];	Msg[7] = Events->msg[7];
					MT_appl_write( Global[2], 16, Msg, Global );
				}
				break;
			}

			case	HNDL_EDDN:
			{
				WORD	i;
				if( strlen( HostTxt ) && ( DialogTree[NS_OK].ob_state & DISABLED ))
				{
					DialogTree[NS_OK].ob_state &= ~DISABLED;
					DialogTree[NS_OK_I].ob_state &= ~DISABLED;
					DialogTree[NS_OK].ob_flags |= SELECTABLE;
					DoRedraw( Dialog, &Rect, NS_OK, Global );
				}
				if( !strlen( HostTxt ) && !( DialogTree[NS_OK].ob_state & DISABLED ))
				{
					DialogTree[NS_OK].ob_state |= DISABLED;
					DialogTree[NS_OK_I].ob_state |= DISABLED;
					DialogTree[NS_OK].ob_flags &= ~SELECTABLE;
					DoRedraw( Dialog, &Rect, NS_OK, Global );
				}
				break;
			}
		}
	}
	else
	{
		Obj &= 0x7fff;

		if( HandleIcon( &Obj, Dialog, Global ))
			return( 1 );

		if( DialogTree[Obj].ob_state & DISABLED )
		{
			DialogTree[Obj].ob_state &= ~SELECTED;
			return( 1 );
		}

		switch( Obj )
		{
			case	NS_PORT_DOWN:
			{
				WORD Keystate, i;
				LONG	Port, a = 1;
				if( MT_wdlg_get_edit( Dialog, &i, Global ) == NS_PORT )
					MT_wdlg_set_edit( Dialog, 0, Global );
				Keystate = (WORD) Kbshift( -1 );
				if( Keystate & KsSHIFT )
					a *= 10;
				if( Keystate & KsALT )
					a *= 100;
				Port = atol( DialogTree[NS_PORT].ob_spec.tedinfo->te_ptext );
				if( Port - a < 0 )
					a = Port;
				Port -= a;
				ltoa( Port, DialogTree[NS_PORT].ob_spec.tedinfo->te_ptext, 10 );
				DoRedraw( Dialog, &Rect, NS_PORT_BOX, Global ); 
				MT_wdlg_set_edit( Dialog, NS_PORT, Global );
				break;
			}
			case	NS_PORT_UP:
			{
				WORD Keystate, i;
				LONG	Port, a = 1;
				if( MT_wdlg_get_edit( Dialog, &i, Global ) == NS_PORT )
					MT_wdlg_set_edit( Dialog, 0, Global );
				Keystate = (WORD) Kbshift( -1 );
				if( Keystate & KsSHIFT )
					a *= 10;
				if( Keystate & KsALT )
					a *= 100;
				Port = atol( DialogTree[NS_PORT].ob_spec.tedinfo->te_ptext );
				if( Port + a > 65535L )
					a = 65535L - Port;
				Port += a;
				ltoa( Port, DialogTree[NS_PORT].ob_spec.tedinfo->te_ptext, 10 );
				DoRedraw( Dialog, &Rect, NS_PORT_BOX, Global ); 
				MT_wdlg_set_edit( Dialog, NS_PORT, Global );
				break;
			}
			case	NS_HOST_EDIT:	MT_wdlg_set_edit( Dialog, NS_HOST, Global ); break;
			case	NS_PORT_EDIT:	MT_wdlg_set_edit( Dialog, NS_PORT, Global ); break;
			case	NS_UID_EDIT:	MT_wdlg_set_edit( Dialog, NS_UID, Global ); break;
			case	NS_PWD_EDIT:	MT_wdlg_set_edit( Dialog, NS_PWD, Global ); break;
			case	NS_DIR_EDIT:	MT_wdlg_set_edit( Dialog, NS_DIR, Global ); break;
			case	NS_CANCEL:		return( 0 );
			case	NS_HOTLIST_I:	DialogTree[NS_HOTLIST].ob_state |= SELECTED;
										DoRedraw( Dialog, &Rect, NS_HOTLIST, Global );
			case	NS_HOTLIST:
			{
				MENU	Popup;
				WORD	x, y;
				WORD	a1, a2, a3, a4;
				if( MT_appl_getinfo( 9, &a1, &a2, &a3, &a4, Global ) && a2 )
				{
					Popup.mn_tree = HotlistPopupTree;
					Popup.mn_menu = 0;
					Popup.mn_item = 0;
					Popup.mn_scroll = 1;
					Popup.mn_keystate = 0;
					{
						EVNTDATA Ev;
						MT_graf_mkstate( &Ev, Global );
						x = Ev.x; y = Ev.y;
					}
					if( HotlistPopupTree )
					{
						MT_menu_popup( &Popup, x, y, &Popup, Global );
						if( Popup.mn_item > 0 )
						{
							MT_wdlg_set_edit( Dialog, 0, Global );
							strcpy( HostTxt, HotlistHost[Popup.mn_item-1] );
							ltoa( (ULONG) HotlistPort[Popup.mn_item-1], DialogTree[NS_PORT].ob_spec.tedinfo->te_ptext, 10 );
							if( HotlistUid[Popup.mn_item-1] )
								strcpy( DialogTree[NS_UID].ob_spec.tedinfo->te_ptext, HotlistUid[Popup.mn_item-1] );
							else
								strcpy( DialogTree[NS_UID].ob_spec.tedinfo->te_ptext, "" );
							if( HotlistPwd[Popup.mn_item-1] )
								strcpy( DialogTree[NS_PWD].ob_spec.tedinfo->te_ptext, HotlistPwd[Popup.mn_item-1] );
							else
								strcpy( DialogTree[NS_PWD].ob_spec.tedinfo->te_ptext, "");

							if( HotlistDir[Popup.mn_item-1] )
								strcpy( DirTxt, HotlistDir[Popup.mn_item-1] );
							else
								strcpy( DirTxt, "" );

							DialogTree[NS_OK].ob_state &= ~DISABLED;
							DialogTree[NS_OK_I].ob_state &= ~DISABLED;
							DialogTree[NS_OK].ob_flags |= SELECTABLE;
							DoRedrawX( Dialog, &Rect, Global, NS_HOST, NS_PORT, NS_PORT_BOX, NS_UID, 
							           NS_PWD, NS_DIR, NS_OK, EDRX );
							MT_wdlg_set_edit( Dialog, NS_HOST, Global );
						}
					}
				}
				DialogTree[NS_HOTLIST].ob_state &= ~SELECTED;
				DialogTree[NS_HOTLIST_I].ob_state &= ~SELECTED;
				DoRedraw( Dialog, &Rect, NS_HOTLIST, Global );

				break;				
			}
			
			case	NS_OK:
			{
				if( newGemFtp( MakeFtpUrl( DialogTree[NS_HOST].ob_spec.tedinfo->te_ptext,
				                            atoi( DialogTree[NS_PORT].ob_spec.tedinfo->te_ptext ),
				                            DialogTree[NS_UID].ob_spec.tedinfo->te_ptext,
				                            DialogTree[NS_PWD].ob_spec.tedinfo->te_ptext,
				                            DialogTree[NS_DIR].ob_spec.tedinfo->te_ptext ), Global ) <= 0 )
					MT_form_alert( 1, FstringAddr[THREAD_FAILED], Global );
				return( 0 );
			}
		}
	}
	return( 1 );
}
#ifdef	V110
void	InsertNsItem( BYTE *Host, WORD Port, BYTE *Uid, BYTE *Pwd, BYTE *Dir, DIALOG *Dialog )
{
	OBJECT	*DialogTree;
	GRECT		Rect;
	BYTE		*A, *B;

	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );

	strcpy( DialogTree[NS_HOST].ob_spec.tedinfo->te_ptext, Host );
	ltoa( (ULONG) Port, DialogTree[NS_PORT].ob_spec.tedinfo->te_ptext, 10 );
	if( Uid )
		strcpy( DialogTree[NS_UID].ob_spec.tedinfo->te_ptext, Uid );
	else
		strcpy( DialogTree[NS_UID].ob_spec.tedinfo->te_ptext, "" );
	if( Pwd )
		strcpy( DialogTree[NS_PWD].ob_spec.tedinfo->te_ptext, Pwd);
	else
		strcpy( DialogTree[NS_PWD].ob_spec.tedinfo->te_ptext, "");
	if( Dir )
		strcpy( DialogTree[NS_DIR].ob_spec.tedinfo->te_ptext, Dir );
	else
		strcpy( DialogTree[NS_DIR].ob_spec.tedinfo->te_ptext, "" );

	DialogTree[NS_OK].ob_state &= ~DISABLED;
	DialogTree[NS_OK_I].ob_state &= ~DISABLED;
	DialogTree[NS_OK].ob_flags |= SELECTABLE;
	DoRedrawX( Dialog, &Rect, Global, NS_HOST, NS_PORT, NS_PORT_BOX, NS_UID, 
	           NS_PWD, NS_DIR, NS_OK, EDRX );
	MT_wdlg_set_edit( Dialog, 0, Global );
	MT_wdlg_set_edit( Dialog, NS_HOST, Global );
}
#endif