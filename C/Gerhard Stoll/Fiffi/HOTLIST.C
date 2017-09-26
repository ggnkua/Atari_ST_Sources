#include	<mt_mem.h>
#include	<PORTAB.H>
#include <STDDEF.H>
#include	<TOS.H>
#include	<MT_AES.H>
#include	<VDI.H>
#include <STDLIB.H>
#include <STDIO.H>
#include	<STRING.H>
#include <CTYPE.H>
#include <SETJMP.H>

#include	<atarierr.h>

#include "main.h"
#include "Hotlist.h"
#include	"Window.h"
#include "GemFtp.h"
#include "Url.h"
#include "Fiffi.h"
#include "mapkey.h"
#include	"edscroll.h"
#include "dragdrop.h"

typedef struct _session_item
{
	struct	_session_item	*next;
	WORD		selected;
#ifdef	V120
	BYTE		*Name;
#endif
	BYTE		*Host;
	UWORD		Port;
	BYTE		*Uid;
	BYTE		*Pwd;
	BYTE		*Dir;
	BYTE		*Comment;
} SESSION_ITEM;

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern WORD		Global[15];
extern WORD		AppId;
extern WORD		VdiHandle;
extern WORD		magic_version;
extern LONG		magic_date;
extern OBJECT	**TreeAddr;
extern BYTE		**FstringAddr;

extern OBJECT	*HotlistPopupTree;
extern OBJECT	*HotlistSubmenuTree;

extern WORD		nHotlist;
#ifdef	V120
extern BYTE		**HotlistName;
#endif
extern BYTE		**HotlistHost;
extern UWORD	*HotlistPort;	
extern BYTE		**HotlistUid;
extern BYTE		**HotlistPwd;
extern BYTE		**HotlistDir;
extern BYTE		**HotlistComment;
extern UWORD	ComPort;

/*-----------------------------------------------------------------------------*/
/* Globale Variablen                                                           */
/*-----------------------------------------------------------------------------*/
LIST_BOX			*HtLbox;
SESSION_ITEM	*HtItems;

XTED		HostXted, UidXted, DirXted, PwdXted;
BYTE 		HostTmplt[EditLen+1], HostTxt[EditLen+1];
BYTE 		UidTmplt[EditLen+1], UidTxt[EditLen+1];
BYTE 		PwdTmplt[EditLen+1], PwdTxt[EditLen+1];
BYTE		DirTmplt[EditLen+1], DirTxt[EditLen+1];	

XTED		Com0Xted, Com1Xted, Com2Xted, Com3Xted;
BYTE		Com0Tmplt[EditLen+1], Com0Txt[EditLen+1];
BYTE		Com1Tmplt[EditLen+1], Com1Txt[EditLen+1];
BYTE		Com2Tmplt[EditLen+1], Com2Txt[EditLen+1];
BYTE		Com3Tmplt[EditLen+1], Com3Txt[EditLen+1];

#ifdef	V120
XTED		NameXted;
BYTE 		NameTmplt[EditLen+1], NameTxt[EditLen+1];
#endif
/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
void cdecl	SlctHtEntry( LIST_BOX *HtItems, OBJECT *DialogTree, LBOX_ITEM *Item, void *UD, WORD ObjIndex, WORD LastState );
void	SortSessionItem( SESSION_ITEM *HtItems );
WORD	Ht2SessionItem( SESSION_ITEM	**HtItems );
WORD	SessionItem2Ht( SESSION_ITEM *HtItem );
void	FreeSessionItem( SESSION_ITEM *Item );

/* Objekte der Listbox */
#define	NO_HT_ENTRY_V	16
#define	NO_HT_ENTRY_H	25
WORD	HtEntryCtrl[9] = { HT_ENTRY_BOX, HT_ENTRY_UP, HT_ENTRY_DOWN, HT_ENTRY_BACK_V, HT_ENTRY_SL_V, HT_ENTRY_LEFT, HT_ENTRY_RIGHT, HT_ENTRY_BACK_H, HT_ENTRY_SL_H };
WORD	HtEntryObjs[NO_HT_ENTRY_V] = { HT_ENTRY_0, HT_ENTRY_1, HT_ENTRY_2, 
    	                               HT_ENTRY_3, HT_ENTRY_4, HT_ENTRY_5, 
    	                               HT_ENTRY_6, HT_ENTRY_7, HT_ENTRY_8,
    	                               HT_ENTRY_9, HT_ENTRY_10, HT_ENTRY_11,
    	                               HT_ENTRY_12, HT_ENTRY_13, HT_ENTRY_14,
    	                               HT_ENTRY_15 };


/*-----------------------------------------------------------------------------*/
/* Service-Routine fÅr Hotlist                                                 */
/*-----------------------------------------------------------------------------*/
WORD	cdecl	HandleHotlistDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD )
{
	OBJECT			*DialogTree;
	GRECT				Rect;

	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );

	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_CLSD:
			{
				SESSION_ITEM	*tmp;
				while( HtItems )
				{
					tmp = HtItems->next;
					FreeSessionItem( HtItems );
					free( HtItems );
					HtItems = tmp;
				}
				HtItems = NULL;
				MT_lbox_delete( HtLbox, Global );
				return( 0 );
			}

			case	HNDL_INIT:
			{
				WORD				i, MaxLen = 0, isScroll;
/* [GS] old:
				SESSION_ITEM	*tmp;
*/
				if(( MaxLen = Ht2SessionItem( &HtItems )) < 0 )
				{
					MemErr( "Hotlist" );
					return( 0 );
				}
				SortSessionItem( HtItems );

				if(( HtLbox = MT_lbox_create( DialogTree, SlctHtEntry, SetStrItem, (LBOX_ITEM *) HtItems,
					NO_HT_ENTRY_V, 0, HtEntryCtrl, HtEntryObjs, 
					LBOX_VERT + LBOX_AUTO + LBOX_AUTOSLCT + LBOX_REAL + LBOX_2SLDRS + LBOX_SNGL + LBOX_SHFT, 
					40, Dialog, Dialog, NO_HT_ENTRY_H, 0, MaxLen + 2, 40, Global )) == 0 )
					return( 0 );

				DialogTree[HT_ADD].ob_state &= ~SELECTED;
				DialogTree[HT_ADD].ob_state |= DISABLED;
				DialogTree[HT_ADD].ob_flags &= ~SELECTABLE;
				DialogTree[HT_ADD_I].ob_state &= ~TOUCHEXIT;
				DialogTree[HT_ADD_I].ob_state |= DISABLED;
				DialogTree[HT_CHANGE].ob_state &= ~SELECTED;
				DialogTree[HT_CHANGE].ob_state |= DISABLED;
				DialogTree[HT_CHANGE].ob_flags &= ~SELECTABLE;
				DialogTree[HT_CHANGE_I].ob_state &= ~TOUCHEXIT;
				DialogTree[HT_CHANGE_I].ob_state |= DISABLED;
				DialogTree[HT_DEL].ob_state &= ~SELECTED;
				DialogTree[HT_DEL].ob_state |= DISABLED;
				DialogTree[HT_DEL].ob_flags &= ~SELECTABLE;
				DialogTree[HT_DEL_I].ob_state &= ~TOUCHEXIT;
				DialogTree[HT_DEL_I].ob_state |= DISABLED;

				if( magic_version && magic_date >= 0x19950829L )
					isScroll = 1;
				else
					isScroll = 0;

#ifdef	V120
				if( !NameXted.xte_ptmplt )
					InitScrlted(&DialogTree[HT_NAME], isScroll, &NameXted, NameTxt, NameTmplt, EditLen);
#endif
				if( !HostXted.xte_ptmplt )
					InitScrlted(&DialogTree[HT_HOST], isScroll, &HostXted, HostTxt, HostTmplt, EditLen);
				if( !UidXted.xte_ptmplt )
					InitScrlted(&DialogTree[HT_UID], isScroll, &UidXted, UidTxt, UidTmplt, EditLen);
				if( !PwdXted.xte_ptmplt )
					InitScrlted(&DialogTree[HT_PWD], isScroll, &PwdXted, PwdTxt, PwdTmplt, EditLen);

				if( !Com0Xted.xte_ptmplt )
					InitScrlted(&DialogTree[HT_COM_0], isScroll, &Com0Xted, Com0Txt, Com0Tmplt, EditLen);
				if( !Com1Xted.xte_ptmplt )
					InitScrlted(&DialogTree[HT_COM_1], isScroll, &Com1Xted, Com1Txt, Com1Tmplt, EditLen);
				if( !Com2Xted.xte_ptmplt )
					InitScrlted(&DialogTree[HT_COM_2], isScroll, &Com2Xted, Com2Txt, Com2Tmplt, EditLen);
				if( !Com3Xted.xte_ptmplt )
					InitScrlted(&DialogTree[HT_COM_3], isScroll, &Com3Xted, Com3Txt, Com3Tmplt, EditLen);


				ltoa( ComPort, DialogTree[HT_PORT].ob_spec.tedinfo->te_ptext, 10 );
				strcpy( DialogTree[HT_UID].ob_spec.tedinfo->te_ptext, "" );
				strcpy( DialogTree[HT_PWD].ob_spec.tedinfo->te_ptext, "" );
				if( !DirXted.xte_ptmplt )
					InitScrlted(&DialogTree[HT_DIR], isScroll, &DirXted, DirTxt, DirTmplt, EditLen);

				strcpy( DialogTree[HT_COM_0].ob_spec.tedinfo->te_ptext, "" );
				strcpy( DialogTree[HT_COM_1].ob_spec.tedinfo->te_ptext, "" );
				strcpy( DialogTree[HT_COM_2].ob_spec.tedinfo->te_ptext, "" );
				strcpy( DialogTree[HT_COM_3].ob_spec.tedinfo->te_ptext, "" );
#ifdef	V120
				strcpy( NameTxt, "" );
#endif
				strcpy( HostTxt, "" );
				strcpy( DirTxt, "" );
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
							MemErr( "Hotlist" );
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
					MT_wdlg_set_uniconify( Dialog, ( GRECT *) &( Events->msg[4] ), NULL, TreeAddr[HT], Global );
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
#ifdef	V120
				if( MT_wdlg_get_edit( Dialog, &i, Global ) == HT_NAME &&
				    strlen( DialogTree[HT_NAME].ob_spec.tedinfo->te_ptext ))
				{
					WORD				Idx = 0;
					SESSION_ITEM	*Item;
					while(( Item = ( SESSION_ITEM * ) MT_lbox_get_item( HtLbox, Idx, Global )) != NULL )
					{
						if( strncmp( Item->Name, DialogTree[HT_NAME].ob_spec.tedinfo->te_ptext, strlen( DialogTree[HT_NAME].ob_spec.tedinfo->te_ptext )) == 0 )
						{
							SESSION_ITEM	*Tmp = HtItems;
							if( Item->selected )
								break;
							while( Tmp )
							{
								Tmp->selected = 0; 
								Tmp = Tmp->next;
							}
							Item->selected = 1;
							MT_lbox_set_asldr( HtLbox, Idx, &Rect, Global );
							MT_lbox_update( HtLbox, &Rect, Global );
							if( strlen( DialogTree[HT_HOST].ob_spec.tedinfo->te_ptext ) == 0 )
							{

								ltoa( Item->Port, DialogTree[HT_PORT].ob_spec.tedinfo->te_ptext, 10 );
								if( Item->Host )
									strcpy( DialogTree[HT_HOST].ob_spec.tedinfo->te_ptext, Item->Host );
								else
									strcpy( DialogTree[HT_HOST].ob_spec.tedinfo->te_ptext, "" );
								if( Item->Uid )
									strcpy( DialogTree[HT_UID].ob_spec.tedinfo->te_ptext, Item->Uid );
								else
									strcpy( DialogTree[HT_UID].ob_spec.tedinfo->te_ptext, "" );
								if( Item->Pwd )
								{
									strcpy( DialogTree[HT_PWD].ob_spec.tedinfo->te_ptext, Item->Pwd );
								}
								else
								{
									strcpy( DialogTree[HT_PWD].ob_spec.tedinfo->te_ptext, "" );
								}
								if( Item->Dir )
									strcpy( DialogTree[HT_DIR].ob_spec.tedinfo->te_ptext, Item->Dir );
								else
									strcpy( DialogTree[HT_DIR].ob_spec.tedinfo->te_ptext, "" );
#ifdef	V120
								strcpy( DialogTree[HT_COM_0].ob_spec.tedinfo->te_ptext, "" );
								strcpy( DialogTree[HT_COM_1].ob_spec.tedinfo->te_ptext, "" );
								strcpy( DialogTree[HT_COM_2].ob_spec.tedinfo->te_ptext, "" );
								strcpy( DialogTree[HT_COM_3].ob_spec.tedinfo->te_ptext, "" );
#endif
								if( Item->Comment )
								{
									sscanf( Item->Comment, "%[^'\n']%*c%[^'\n']%*c%[^'\n']%*c%s",
									        DialogTree[HT_COM_0].ob_spec.tedinfo->te_ptext,
									        DialogTree[HT_COM_1].ob_spec.tedinfo->te_ptext,
									        DialogTree[HT_COM_2].ob_spec.tedinfo->te_ptext,
									        DialogTree[HT_COM_3].ob_spec.tedinfo->te_ptext );
								}
#ifndef	V120
								else
								{
									strcpy( DialogTree[HT_COM_0].ob_spec.tedinfo->te_ptext, "" );
									strcpy( DialogTree[HT_COM_1].ob_spec.tedinfo->te_ptext, "" );
									strcpy( DialogTree[HT_COM_2].ob_spec.tedinfo->te_ptext, "" );
									strcpy( DialogTree[HT_COM_3].ob_spec.tedinfo->te_ptext, "" );
								}
#endif
								DoRedrawX( Dialog, &Rect, Global, HT_HOST, HT_PORT, HT_PWD, HT_PORT_BOX, 
								           HT_UID, HT_DIR, HT_COM_0, HT_COM_1, 
								           HT_COM_2, HT_COM_3, EDRX );
							}
							break;
						}
						Idx++;
					}
				}
#else
#ifdef	V110
				if( MT_wdlg_get_edit( Dialog, &i, Global ) == HT_HOST &&
				    strlen( DialogTree[HT_HOST].ob_spec.tedinfo->te_ptext ))
				{
					WORD				Idx = 0;
					SESSION_ITEM	*Item;
					while(( Item = ( SESSION_ITEM * ) MT_lbox_get_item( HtLbox, Idx, Global )) != NULL )
					{
						if( strncmp( Item->Host, DialogTree[HT_HOST].ob_spec.tedinfo->te_ptext, strlen( DialogTree[HT_HOST].ob_spec.tedinfo->te_ptext )) == 0 )
						{
							SESSION_ITEM	*Tmp = HtItems;
							while( Tmp )
							{
								Tmp->selected = 0; 
								Tmp = Tmp->next;
							}
							Item->selected = 1;
							MT_lbox_set_asldr( HtLbox, Idx, &Rect, Global );
							MT_lbox_update( HtLbox, &Rect, Global );

							ltoa( Item->Port, DialogTree[HT_PORT].ob_spec.tedinfo->te_ptext, 10 );
							if( Item->Uid )
								strcpy( DialogTree[HT_UID].ob_spec.tedinfo->te_ptext, Item->Uid );
							else
								strcpy( DialogTree[HT_UID].ob_spec.tedinfo->te_ptext, "" );
							if( Item->Pwd )
							{
								strcpy( DialogTree[HT_PWD].ob_spec.tedinfo->te_ptext, Item->Pwd );
							}
							else
							{
								strcpy( DialogTree[HT_PWD].ob_spec.tedinfo->te_ptext, "" );
							}
							if( Item->Dir )
								strcpy( DialogTree[HT_DIR].ob_spec.tedinfo->te_ptext, Item->Dir );
							else
								strcpy( DialogTree[HT_DIR].ob_spec.tedinfo->te_ptext, "" );
#ifdef	V120
							strcpy( DialogTree[HT_COM_0].ob_spec.tedinfo->te_ptext, "" );
							strcpy( DialogTree[HT_COM_1].ob_spec.tedinfo->te_ptext, "" );
							strcpy( DialogTree[HT_COM_2].ob_spec.tedinfo->te_ptext, "" );
							strcpy( DialogTree[HT_COM_3].ob_spec.tedinfo->te_ptext, "" );
#endif
							if( Item->Comment )
							{
								sscanf( Item->Comment, "%[^'\n']%*c%[^'\n']%*c%[^'\n']%*c%s",
								        DialogTree[HT_COM_0].ob_spec.tedinfo->te_ptext,
								        DialogTree[HT_COM_1].ob_spec.tedinfo->te_ptext,
								        DialogTree[HT_COM_2].ob_spec.tedinfo->te_ptext,
								        DialogTree[HT_COM_3].ob_spec.tedinfo->te_ptext );
							}
#ifndef	V120
							else
							{
								strcpy( DialogTree[HT_COM_0].ob_spec.tedinfo->te_ptext, "" );
								strcpy( DialogTree[HT_COM_1].ob_spec.tedinfo->te_ptext, "" );
								strcpy( DialogTree[HT_COM_2].ob_spec.tedinfo->te_ptext, "" );
								strcpy( DialogTree[HT_COM_3].ob_spec.tedinfo->te_ptext, "" );
							}
#endif
							DoRedrawX( Dialog, &Rect, Global, HT_PORT, HT_PWD, HT_PORT_BOX, 
							           HT_UID, HT_DIR, HT_COM_0, HT_COM_1, 
							           HT_COM_2, HT_COM_3, EDRX );
							break;
						}
						Idx++;
					}
				}
#endif
#endif
				if( strlen( DialogTree[HT_NAME].ob_spec.tedinfo->te_ptext ) && strlen( DialogTree[HT_HOST].ob_spec.tedinfo->te_ptext ) &&
				    !ExistHtItem( DialogTree[HT_NAME].ob_spec.tedinfo->te_ptext ))
				{
					if( DialogTree[HT_ADD].ob_state & DISABLED )
					{
						DialogTree[HT_ADD].ob_state &= ~DISABLED;
						DialogTree[HT_ADD].ob_flags |= SELECTABLE;
						DialogTree[HT_ADD_I].ob_state &= ~DISABLED;
						DialogTree[HT_ADD_I].ob_flags |= TOUCHEXIT;
						DoRedraw( Dialog, &Rect, HT_ADD, Global );
					}
				}
				else
				{
					if( DialogTree[HT_ADD].ob_flags & SELECTABLE )
					{
						DialogTree[HT_ADD].ob_state |= DISABLED;
						DialogTree[HT_ADD].ob_flags &= ~SELECTABLE;
						DialogTree[HT_ADD_I].ob_state |= DISABLED;
						DialogTree[HT_ADD_I].ob_flags &= ~TOUCHEXIT;
						DoRedraw( Dialog, &Rect, HT_ADD, Global );
					}
				}
				if( MT_lbox_get_slct_idx( HtLbox, Global ) != -1 )
				{
					if( DialogTree[HT_DEL].ob_state & DISABLED )
					{
						DialogTree[HT_DEL].ob_state &= ~DISABLED;
						DialogTree[HT_DEL].ob_flags |= SELECTABLE;
						DialogTree[HT_DEL_I].ob_state &= ~DISABLED;
						DialogTree[HT_DEL_I].ob_flags |= TOUCHEXIT;
						DoRedraw( Dialog, &Rect, HT_DEL, Global );
					}
				}
				else
				{
					if( DialogTree[HT_DEL].ob_flags & SELECTABLE )
					{
						DialogTree[HT_DEL].ob_state |= DISABLED;
						DialogTree[HT_DEL].ob_flags &= ~SELECTABLE;
						DialogTree[HT_DEL_I].ob_state |= DISABLED;
						DialogTree[HT_DEL_I].ob_flags &= ~TOUCHEXIT;
						DoRedraw( Dialog, &Rect, HT_DEL, Global );
					}
				}

				if( MT_lbox_get_slct_idx( HtLbox, Global ) != -1 &&
				    strlen( DialogTree[HT_HOST].ob_spec.tedinfo->te_ptext ))
				{
					if( DialogTree[HT_CHANGE].ob_state & DISABLED )
					{
						DialogTree[HT_CHANGE].ob_state &= ~DISABLED;
						DialogTree[HT_CHANGE].ob_flags |= SELECTABLE;
						DialogTree[HT_CHANGE_I].ob_state &= ~DISABLED;
						DialogTree[HT_CHANGE_I].ob_flags |= TOUCHEXIT;
						DoRedraw( Dialog, &Rect, HT_CHANGE, Global );
					}
				}
				else
				{
					if( DialogTree[HT_CHANGE].ob_flags & SELECTABLE )
					{
						DialogTree[HT_CHANGE].ob_state |= DISABLED;
						DialogTree[HT_CHANGE].ob_flags &= ~SELECTABLE;
						DialogTree[HT_CHANGE_I].ob_state |= DISABLED;
						DialogTree[HT_CHANGE_I].ob_flags &= ~TOUCHEXIT;
						DoRedraw( Dialog, &Rect, HT_CHANGE, Global );
					}
				}
				break;
			}
		}
	}
	else
	{

		if( Clicks == 2 )
			Obj |= 0x8000;

		if( MT_lbox_do( HtLbox, Obj, Global ) == -1 )
		{
			SESSION_ITEM	*tmp;
#ifndef	V110
			WORD				Msg[8], W, A, dummy;
#endif
			tmp = (SESSION_ITEM *) MT_lbox_get_slct_item( HtLbox, Global );
			if( newGemFtp( MakeFtpUrl( tmp->Host, tmp->Port, tmp->Uid, tmp->Pwd, tmp->Dir ), Global ) <= 0 )
				MT_form_alert( 1, FstringAddr[THREAD_FAILED], Global );
#ifndef	V110
			MT_wind_get( 0, WF_TOP, &W, &A, &dummy, &dummy, Global );
			Msg[0] = WM_CLOSED;
			Msg[3] = W;
			MT_appl_write( A, 16, Msg, Global );
#endif
		}

		Obj &= 0x7fff;

#ifdef	V110
		if( HandleIcon( &Obj, Dialog, Global ))
			return( 1 );
#endif

		if( DialogTree[Obj].ob_state & DISABLED )
		{
			DialogTree[Obj].ob_state &= ~SELECTED;
			return( 1 );
		}

		if( Obj == HT_PORT_DOWN )
		{
			WORD Keystate, i;
			LONG	Port, a = 1;
			if( MT_wdlg_get_edit( Dialog, &i, Global ) == HT_PORT )
				MT_wdlg_set_edit( Dialog, 0, Global );
			Keystate = (WORD) Kbshift( -1 );
			if( Keystate & KsSHIFT )
				a *= 10;
			if( Keystate & KsALT )
				a *= 100;
			Port = atol( DialogTree[HT_PORT].ob_spec.tedinfo->te_ptext );
			if( Port - a < 0 )
				a = Port;
			Port -= a;
			ltoa( Port, DialogTree[HT_PORT].ob_spec.tedinfo->te_ptext, 10 );
			DoRedraw( Dialog, &Rect, HT_PORT_BOX, Global ); 
			MT_wdlg_set_edit( Dialog, HT_PORT, Global );
		}

		if( Obj == HT_PORT_UP )
		{
			WORD Keystate, i;
			LONG	Port, a = 1;
			Keystate = (WORD) Kbshift( -1 );
			if( MT_wdlg_get_edit( Dialog, &i, Global ) == HT_PORT )
				MT_wdlg_set_edit( Dialog, 0, Global );
			if( Keystate & KsSHIFT )
				a *= 10;
			if( Keystate & KsALT )
				a *= 100;
			Port = atol( DialogTree[HT_PORT].ob_spec.tedinfo->te_ptext );
			if( Port + a > 65535L )
				a = 65535L - Port;
			Port += a;
			ltoa( Port, DialogTree[HT_PORT].ob_spec.tedinfo->te_ptext, 10 );
			DoRedraw( Dialog, &Rect, HT_PORT_BOX, Global ); 
			MT_wdlg_set_edit( Dialog, HT_PORT, Global );
		}
		
#ifdef	V120
		if( Obj == HT_NAME_EDIT )
			MT_wdlg_set_edit( Dialog, HT_NAME, Global );
#endif

		if( Obj == HT_HOST_EDIT )
			MT_wdlg_set_edit( Dialog, HT_HOST, Global );

		if( Obj == HT_UID_EDIT )
			MT_wdlg_set_edit( Dialog, HT_UID, Global );

		if( Obj == HT_PORT_EDIT )
			MT_wdlg_set_edit( Dialog, HT_PORT, Global );

		if( Obj == HT_DIR_EDIT )
			MT_wdlg_set_edit( Dialog, HT_DIR, Global );

		if( Obj == HT_PWD_EDIT  )
			MT_wdlg_set_edit( Dialog, HT_PWD, Global );

		if( Obj == HT_COM_EDIT )
			MT_wdlg_set_edit( Dialog, HT_COM_0, Global );

		if( Obj == HT_DEL )
		{
			WORD	SlctIdx;
			if(( SlctIdx = MT_lbox_get_slct_idx( HtLbox, Global )) != -1 )
			{
				SESSION_ITEM	*Item, *DelItem = ( SESSION_ITEM *) MT_lbox_get_item( HtLbox, SlctIdx, Global );
				WORD				MaxLen = 0, FirstVisIdx = MT_lbox_get_afirst( HtLbox, Global );
				
				if( DelItem == HtItems )
					HtItems = DelItem->next;
				else
				{
					Item = ( SESSION_ITEM * ) MT_lbox_get_item( HtLbox, SlctIdx - 1, Global );
					Item->next = DelItem->next;
				}
				FreeSessionItem( DelItem );
				free( DelItem );

				Item = HtItems;
				while( Item )
				{
					if( strlen( Item->Host ) > MaxLen )
						MaxLen = ( WORD ) strlen( Item->Host );
					Item = Item->next;
				}

				MT_lbox_set_items( HtLbox, ( LBOX_ITEM * ) HtItems, Global );
				MT_lbox_set_asldr( HtLbox, FirstVisIdx, &Rect, Global );
				MT_lbox_set_bentries( HtLbox, MaxLen, Global );
				MT_lbox_set_bsldr( HtLbox, 0, &Rect, Global );
				DoRedraw( Dialog, &Rect, HT_ENTRY_BACK_H, Global );
				MT_lbox_update( HtLbox, &Rect, Global );

#ifdef	V120
				strcpy( DialogTree[HT_NAME].ob_spec.tedinfo->te_ptext, "" );
#endif
				strcpy( DialogTree[HT_HOST].ob_spec.tedinfo->te_ptext, "" );
				strcpy( DialogTree[HT_PORT].ob_spec.tedinfo->te_ptext, "" );
				ltoa( ComPort, DialogTree[HT_PORT].ob_spec.tedinfo->te_ptext, 10 );
				strcpy( DialogTree[HT_UID].ob_spec.tedinfo->te_ptext, "" );
				strcpy( DialogTree[HT_PWD].ob_spec.tedinfo->te_ptext, "" );
				strcpy( DialogTree[HT_DIR].ob_spec.tedinfo->te_ptext, "" );
				strcpy( DialogTree[HT_COM_0].ob_spec.tedinfo->te_ptext, "" );
				strcpy( DialogTree[HT_COM_1].ob_spec.tedinfo->te_ptext, "" );
				strcpy( DialogTree[HT_COM_2].ob_spec.tedinfo->te_ptext, "" );
				strcpy( DialogTree[HT_COM_3].ob_spec.tedinfo->te_ptext, "" );
#ifdef	V120
				DoRedrawX( Dialog, &Rect, Global, HT_NAME, HT_PWD,
				           HT_HOST, HT_PORT_BOX, HT_UID, HT_DIR, 
				           HT_COM_0, HT_COM_1, HT_COM_2, HT_COM_3, EDRX );
#else
				DoRedrawX( Dialog, &Rect, Global, HT_PWD,
				           HT_HOST, HT_PORT_BOX, HT_UID, HT_DIR, 
				           HT_COM_0, HT_COM_1, HT_COM_2, HT_COM_3, EDRX );
#endif
				MT_wdlg_set_edit( Dialog, 0, Global );
#ifdef	V120
				MT_wdlg_set_edit( Dialog, HT_NAME, Global );
#else
				MT_wdlg_set_edit( Dialog, HT_HOST, Global );
#endif

				if( DialogTree[HT_ADD].ob_flags & SELECTABLE )
				{
					DialogTree[HT_ADD].ob_state |= DISABLED;
					DialogTree[HT_ADD].ob_flags &= ~SELECTABLE;
					DialogTree[HT_ADD_I].ob_state |= DISABLED;
					DialogTree[HT_ADD_I].ob_flags &= ~TOUCHEXIT;
					DoRedraw( Dialog, &Rect, HT_ADD, Global );
				}
				if( DialogTree[HT_CHANGE].ob_flags & SELECTABLE )
				{
					DialogTree[HT_CHANGE].ob_state |= DISABLED;
					DialogTree[HT_CHANGE].ob_flags &= ~SELECTABLE;
					DialogTree[HT_CHANGE_I].ob_state |= DISABLED;
					DialogTree[HT_CHANGE_I].ob_flags &= ~TOUCHEXIT;
					DoRedraw( Dialog, &Rect, HT_CHANGE, Global );
				}
				DialogTree[HT_DEL].ob_state |= DISABLED;
				DialogTree[HT_DEL].ob_state &= ~SELECTED;
				DialogTree[HT_DEL].ob_flags |= SELECTABLE;
				DialogTree[HT_DEL_I].ob_state |= DISABLED;
				DialogTree[HT_DEL_I].ob_flags &= ~TOUCHEXIT;
				DoRedraw( Dialog, &Rect, HT_DEL, Global );
			}
		}

		if( Obj == HT_ADD )
		{
			WORD	FirstVisIdx = MT_lbox_get_afirst( HtLbox, Global );
			WORD	SlctIdx, MaxLen = 0;
			SESSION_ITEM	*NewItem = malloc( sizeof( SESSION_ITEM )), *Item;
			if( !NewItem )
			{
				MemErr( "Hotlist" );
				return( 0 );
			}
			NewItem->selected = 0;
#ifdef	V120
			NewItem->Name = strdup( NameTxt );
			if( !NewItem->Name )
			{
				MemErr( "Hotlist" );
				return( 0 );
			}
#endif
			NewItem->Host = strdup( HostTxt );
			if( !NewItem->Host )
			{
				MemErr( "Hotlist" );
				return( 0 );
			}
			NewItem->Port = (WORD) atol( DialogTree[HT_PORT].ob_spec.tedinfo->te_ptext );
			if( strlen( DialogTree[HT_UID].ob_spec.tedinfo->te_ptext ))
			{
				NewItem->Uid = strdup( DialogTree[HT_UID].ob_spec.tedinfo->te_ptext );
				if( !NewItem->Uid )
				{
					MemErr( "Hotlist" );
					return( 0 );
				}
			}
			else
				NewItem->Uid = 0L;
			if( strlen( DialogTree[HT_PWD].ob_spec.tedinfo->te_ptext ))
			{
				NewItem->Pwd = strdup( DialogTree[HT_PWD].ob_spec.tedinfo->te_ptext );
				if( !NewItem->Pwd )
				{
					MemErr( "Hotlist" );
					return( 0 );
				}
			}
			else
				NewItem->Pwd = 0L;
			if( strlen( DirTxt ))
			{
				NewItem->Dir = strdup( DirTxt );
				if( !NewItem->Dir )
				{
					MemErr( "Hotlist" );
					return( 0 );
				}
			}
			else
				NewItem->Dir = 0L;
			if( strlen( DialogTree[HT_COM_0].ob_spec.tedinfo->te_ptext ) +
			    strlen( DialogTree[HT_COM_1].ob_spec.tedinfo->te_ptext ) +
			    strlen( DialogTree[HT_COM_2].ob_spec.tedinfo->te_ptext ) +
			    strlen( DialogTree[HT_COM_3].ob_spec.tedinfo->te_ptext ))
			{
				NewItem->Comment = malloc( strlen( DialogTree[HT_COM_0].ob_spec.tedinfo->te_ptext ) +
				                           strlen( DialogTree[HT_COM_1].ob_spec.tedinfo->te_ptext ) +
				                           strlen( DialogTree[HT_COM_2].ob_spec.tedinfo->te_ptext ) +
				                           strlen( DialogTree[HT_COM_3].ob_spec.tedinfo->te_ptext ) + 4 );
				if( !NewItem->Comment )
				{
					MemErr( "Hotlist" );
					return( 0 );
				}
				strcpy( NewItem->Comment, DialogTree[HT_COM_0].ob_spec.tedinfo->te_ptext );
				strcat( NewItem->Comment, "\n" );
				strcat( NewItem->Comment, DialogTree[HT_COM_1].ob_spec.tedinfo->te_ptext );
				strcat( NewItem->Comment, "\n" );
				strcat( NewItem->Comment, DialogTree[HT_COM_2].ob_spec.tedinfo->te_ptext );
				strcat( NewItem->Comment, "\n" );
				strcat( NewItem->Comment, DialogTree[HT_COM_3].ob_spec.tedinfo->te_ptext );
			}
			else
				NewItem->Comment = NULL;

			if( MT_lbox_get_slct_item( HtLbox, Global ))
				MT_lbox_get_slct_item( HtLbox, Global )->selected = 0;

			if( !HtItems )
			{
				HtItems = NewItem;
				NewItem->next = NULL;
			}
			else
			{
				NewItem->next = HtItems->next;
				HtItems->next = NewItem;
			}
			NewItem->selected = 1;
			SortSessionItem( HtItems );
			Item = HtItems;
			while( Item )
			{
				if( strlen( Item->Host ) > MaxLen )
					MaxLen = ( WORD ) strlen( Item->Host );
				Item = Item->next;
			}
			MT_lbox_set_items( HtLbox, ( LBOX_ITEM * ) HtItems, Global );
			MT_lbox_set_asldr( HtLbox, FirstVisIdx, &Rect, Global );
			MT_lbox_set_bentries( HtLbox, MaxLen + 2, Global );
			MT_lbox_set_bsldr( HtLbox, 0, &Rect, Global );
			DoRedraw( Dialog, &Rect, HT_ENTRY_BACK_H, Global );
			if( MT_lbox_get_afirst( HtLbox, Global ) + NO_HT_ENTRY_V > 
			   ( SlctIdx = MT_lbox_get_slct_idx( HtLbox, Global )))
				MT_lbox_set_asldr( HtLbox, SlctIdx + NO_HT_ENTRY_V / 2, &Rect, Global );
			MT_lbox_update( HtLbox, &Rect, Global );

			DialogTree[HT_ADD].ob_state &= ~SELECTED;
			DialogTree[HT_ADD].ob_state |= DISABLED;
			DialogTree[HT_ADD].ob_flags &= ~SELECTABLE;
			DialogTree[HT_ADD_I].ob_state |= DISABLED;
			DialogTree[HT_ADD_I].ob_flags &= ~TOUCHEXIT;
			DoRedraw( Dialog, &Rect, HT_ADD, Global );
			if( DialogTree[HT_CHANGE].ob_state & DISABLED )
			{
				DialogTree[HT_CHANGE].ob_state &= ~DISABLED;
				DialogTree[HT_CHANGE].ob_flags |= SELECTABLE;
				DialogTree[HT_CHANGE_I].ob_state &= ~DISABLED;
				DialogTree[HT_CHANGE_I].ob_flags |= TOUCHEXIT;
				DoRedraw( Dialog, &Rect, HT_CHANGE, Global );
			}
			if( DialogTree[HT_DEL].ob_state & DISABLED )
			{
				DialogTree[HT_DEL].ob_state &= ~DISABLED;
				DialogTree[HT_DEL].ob_flags |= SELECTABLE;
				DialogTree[HT_DEL_I].ob_state &= ~DISABLED;
				DialogTree[HT_DEL_I].ob_flags |= TOUCHEXIT;
				DoRedraw( Dialog, &Rect, HT_DEL, Global );
			}
		}

		if( Obj == HT_CHANGE )
		{
			SESSION_ITEM	*SlctItem = ( SESSION_ITEM * ) MT_lbox_get_slct_item( HtLbox, Global ), *Item;
			if( SlctItem )
			{
				WORD	SlctIdx, FirstVisIdx, MaxLen = 0;
				FreeSessionItem( SlctItem );
#ifdef	V120
				SlctItem->Name = strdup( NameTxt );	
				if( !SlctItem->Name )
				{
					MemErr( "Hotlist" );
					return( 0 );
				}
#endif
				SlctItem->Host = strdup( HostTxt );	
				if( !SlctItem->Host )
				{
					MemErr( "Hotlist" );
					return( 0 );
				}
				SlctItem->Port = (WORD) atol( DialogTree[HT_PORT].ob_spec.tedinfo->te_ptext );
				if( strlen( DialogTree[HT_UID].ob_spec.tedinfo->te_ptext ))
				{
					SlctItem->Uid = strdup( DialogTree[HT_UID].ob_spec.tedinfo->te_ptext );
					if( !SlctItem->Uid )
					{
						MemErr( "Hotlist" );
						return( 0 );
					}
				}
				else
					SlctItem->Uid = 0L;
				if( strlen( DialogTree[HT_PWD].ob_spec.tedinfo->te_ptext ))
				{
					SlctItem->Pwd = strdup( DialogTree[HT_PWD].ob_spec.tedinfo->te_ptext );
					if( !SlctItem->Pwd )
					{
						MemErr( "Hotlist" );
						return( 0 );
					}
				}
				else
					SlctItem->Pwd = 0L;
				if( strlen( DirTxt ))
				{
					SlctItem->Dir = strdup( DirTxt );
					if( !SlctItem->Dir )
					{
						MemErr( "Hotlist" );
						return( 0 );
					}
				}
				else
					SlctItem->Dir = 0L;
				if( strlen( DialogTree[HT_COM_0].ob_spec.tedinfo->te_ptext ) +
				    strlen( DialogTree[HT_COM_1].ob_spec.tedinfo->te_ptext ) +
				    strlen( DialogTree[HT_COM_2].ob_spec.tedinfo->te_ptext ) +
				    strlen( DialogTree[HT_COM_3].ob_spec.tedinfo->te_ptext ))
				{
					SlctItem->Comment = malloc( strlen( DialogTree[HT_COM_0].ob_spec.tedinfo->te_ptext ) +
					                           strlen( DialogTree[HT_COM_1].ob_spec.tedinfo->te_ptext ) +
					                           strlen( DialogTree[HT_COM_2].ob_spec.tedinfo->te_ptext ) +
					                           strlen( DialogTree[HT_COM_3].ob_spec.tedinfo->te_ptext ) + 4 );
					if( !SlctItem->Comment )
					{
						MemErr( "Hotlist" );
						return( 0 );
					}
					strcpy( SlctItem->Comment, DialogTree[HT_COM_0].ob_spec.tedinfo->te_ptext );
					strcat( SlctItem->Comment, "\n" );
					strcat( SlctItem->Comment, DialogTree[HT_COM_1].ob_spec.tedinfo->te_ptext );
					strcat( SlctItem->Comment, "\n" );
					strcat( SlctItem->Comment, DialogTree[HT_COM_2].ob_spec.tedinfo->te_ptext );
					strcat( SlctItem->Comment, "\n" );
					strcat( SlctItem->Comment, DialogTree[HT_COM_3].ob_spec.tedinfo->te_ptext );
				}
				else
					SlctItem->Comment = NULL;

				SortSessionItem( HtItems );

				Item = HtItems;
				while( Item )
				{
					if( strlen( Item->Host ) > MaxLen )
						MaxLen = ( WORD ) strlen( Item->Host );
					Item = Item->next;
				}
				FirstVisIdx = MT_lbox_get_afirst( HtLbox, Global );
				SlctIdx = MT_lbox_get_slct_idx( HtLbox, Global );
				if( FirstVisIdx > SlctIdx ||
				    FirstVisIdx + NO_HT_ENTRY_V < SlctIdx )
					MT_lbox_set_asldr( HtLbox, SlctIdx + NO_HT_ENTRY_V / 2, &Rect, Global );
				MT_lbox_set_bentries( HtLbox, MaxLen + 2, Global );
				MT_lbox_set_bsldr( HtLbox, 0, &Rect, Global );
				DoRedraw( Dialog, &Rect, HT_ENTRY_BACK_H, Global );
				MT_lbox_update( HtLbox, &Rect, Global );

				DialogTree[HT_CHANGE].ob_state &= ~SELECTED;
				DoRedraw( Dialog, &Rect, HT_CHANGE, Global );
			}		
		}
		if( Obj == HT_ADD || Obj == HT_DEL || Obj == HT_CHANGE )
		{
			WORD	Msg[8];
			if( SessionItem2Ht( HtItems ) != E_OK )
			{
				MemErr( "Hotlist" );
				return( 0 );
			}
			Msg[0] = Main_UpdateMenu;
			Msg[1] = AppId;
			Msg[2] = 0;
			MT_appl_write( Global[2], 16, Msg, Global );
		}
	}

	return( 1 );
}

void cdecl	SlctHtEntry( LIST_BOX *HtLbox, OBJECT *DialogTree, LBOX_ITEM *Item, void *UD, WORD ObjIndex, WORD LastState )
{
	GRECT		Rect;
	SESSION_ITEM	*Entry = ( SESSION_ITEM * ) Item;
	DIALOG			*Dialog = ( DIALOG * ) UD;
	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );
	if( Item->selected )
	{
		MT_wdlg_set_edit( Dialog, 0, Global );
#ifdef	V120
		strcpy( NameTxt, Entry->Name );
#endif
		strcpy( HostTxt, Entry->Host );
		ltoa( (ULONG) Entry->Port, DialogTree[HT_PORT].ob_spec.tedinfo->te_ptext, 10 );
		if( Entry->Uid )
			strcpy( DialogTree[HT_UID].ob_spec.tedinfo->te_ptext, Entry->Uid );
		else
			strcpy( DialogTree[HT_UID].ob_spec.tedinfo->te_ptext, "" );
		if( Entry->Pwd )
			strcpy( DialogTree[HT_PWD].ob_spec.tedinfo->te_ptext, Entry->Pwd );
		else
			strcpy( DialogTree[HT_PWD].ob_spec.tedinfo->te_ptext, "" );
		if( Entry->Dir )
			strcpy( DirTxt, Entry->Dir );
		else
			strcpy( DirTxt, "" );
#ifdef	V120
		strcpy( DialogTree[HT_COM_0].ob_spec.tedinfo->te_ptext, "" );
		strcpy( DialogTree[HT_COM_1].ob_spec.tedinfo->te_ptext, "" );
		strcpy( DialogTree[HT_COM_2].ob_spec.tedinfo->te_ptext, "" );
		strcpy( DialogTree[HT_COM_3].ob_spec.tedinfo->te_ptext, "" );
#endif
		if( Entry->Comment )
		{
			sscanf( Entry->Comment, "%[^'\n']%*c%[^'\n']%*c%[^'\n']%*c%s",
			        DialogTree[HT_COM_0].ob_spec.tedinfo->te_ptext,
			        DialogTree[HT_COM_1].ob_spec.tedinfo->te_ptext,
			        DialogTree[HT_COM_2].ob_spec.tedinfo->te_ptext,
			        DialogTree[HT_COM_3].ob_spec.tedinfo->te_ptext );
		}
#ifndef	V120
		else
		{
			strcpy( DialogTree[HT_COM_0].ob_spec.tedinfo->te_ptext, "" );
			strcpy( DialogTree[HT_COM_1].ob_spec.tedinfo->te_ptext, "" );
			strcpy( DialogTree[HT_COM_2].ob_spec.tedinfo->te_ptext, "" );
			strcpy( DialogTree[HT_COM_3].ob_spec.tedinfo->te_ptext, "" );
		}
#endif
#ifdef	V120
		DoRedrawX( Dialog, &Rect, Global, HT_NAME, HT_HOST, HT_PORT, HT_PORT_BOX, HT_UID, HT_PWD,
		           HT_DIR, HT_COM_0, HT_COM_1, HT_COM_2, HT_COM_3, EDRX );
#else
		DoRedrawX( Dialog, &Rect, Global, HT_HOST, HT_PORT, HT_PORT_BOX, HT_UID, HT_PWD,
		           HT_DIR, HT_COM_0, HT_COM_1, HT_COM_2, HT_COM_3, EDRX );
#endif
		if( DialogTree[HT_ADD].ob_flags & SELECTABLE )
		{
			DialogTree[HT_ADD].ob_state |= DISABLED;
			DialogTree[HT_ADD].ob_flags &= ~SELECTABLE;
			DialogTree[HT_ADD_I].ob_state |= DISABLED;
			DialogTree[HT_ADD_I].ob_flags &= ~TOUCHEXIT;
			DoRedraw( Dialog, &Rect, HT_ADD, Global );
		}
		if( DialogTree[HT_CHANGE].ob_state & DISABLED )
		{
			DialogTree[HT_CHANGE].ob_state &= ~DISABLED;
			DialogTree[HT_CHANGE].ob_flags |= SELECTABLE;
			DialogTree[HT_CHANGE_I].ob_state &= ~DISABLED;
			DialogTree[HT_CHANGE_I].ob_flags |= TOUCHEXIT;
			DoRedraw( Dialog, &Rect, HT_CHANGE, Global );
		}
		if( DialogTree[HT_DEL].ob_state & DISABLED )
		{
			DialogTree[HT_DEL].ob_state &= ~DISABLED;
			DialogTree[HT_DEL].ob_flags |= SELECTABLE;
			DialogTree[HT_DEL_I].ob_state &= ~DISABLED;
			DialogTree[HT_DEL_I].ob_flags |= TOUCHEXIT;
			DoRedraw( Dialog, &Rect, HT_DEL, Global );
		}
#ifdef	V120
		MT_wdlg_set_edit( Dialog, HT_NAME, Global );
#else
		MT_wdlg_set_edit( Dialog, HT_HOST, Global );
#endif
#ifdef	V110
		{
			EVNTDATA Ev, EvO;
			MT_graf_mkstate( &Ev, Global );
			if( Ev.bstate & 1 )
			{
				WORD	Pxy[10], x, y, dx, dy, WinHandle;
				GRECT		Rect;

				MT_wind_update( BEG_MCTRL, Global );
				MT_graf_mouse( 258, NULL, Global );
				MT_graf_mouse( FLAT_HAND, NULL, Global );

				MT_wind_get_grect( 0, WF_WORKXYWH, &Rect, Global );
				Pxy[0] = Rect.g_x; Pxy[1] = Rect.g_y;
				Pxy[2] = Pxy[0] + Rect.g_w; Pxy[3] = Pxy[2] + Rect.g_h;
				vs_clip( VdiHandle, 0, Pxy );
				
				MT_objc_offset( DialogTree, ObjIndex, &x, &y, Global );
				vsl_udsty( VdiHandle, 0xaaaa );
				vsl_type( VdiHandle, 7 );
				vswr_mode( VdiHandle, MD_XOR );

				Pxy[0] = x; Pxy[1] = y;
				Pxy[2] = x + DialogTree[ObjIndex].ob_width; Pxy[3] = Pxy[1];
				Pxy[4] = Pxy[2]; Pxy[5] = Pxy[3] + DialogTree[ObjIndex].ob_height;
				Pxy[6] = Pxy[0]; Pxy[7] = Pxy[5];
				Pxy[8] = Pxy[0]; Pxy[9] = Pxy[1];

				MT_graf_mouse( M_OFF, NULL, Global );
				v_pline( VdiHandle, 5, Pxy );
				MT_graf_mouse( M_ON, NULL, Global );
				EvO.x = Ev.x; EvO.y = Ev.y;
				do
				{
					dx = Ev.x - EvO.x; dy = Ev.y - EvO.y;
					if( dx || dy )
					{
						MT_graf_mouse( M_OFF, NULL, Global );
						v_pline( VdiHandle, 5, Pxy );
						Pxy[0] += dx; Pxy[2] += dx; Pxy[4] += dx; Pxy[6] += dx; Pxy[8] += dx;
						Pxy[1] += dy; Pxy[3] += dy; Pxy[5] += dy; Pxy[7] += dy; Pxy[9] += dy;
						v_pline( VdiHandle, 5, Pxy );
						MT_graf_mouse( M_ON, NULL, Global );
						EvO.x = Ev.x; EvO.y = Ev.y;
					}
					MT_graf_mkstate( &Ev, Global );
				}
				while( Ev.bstate & 1 );
				MT_graf_mouse( M_OFF, NULL, Global );
				v_pline( VdiHandle, 5, Pxy );
				MT_graf_mouse( M_ON, NULL, Global );
				MT_graf_mouse( 259, NULL, Global );
				MT_wind_update( END_MCTRL, Global );

				{
					WORD	Msg[8];
					BYTE	*Url = MakeFtpUrl( Entry->Host, Entry->Port, Entry->Uid, Entry->Pwd, Entry->Dir );
					BYTE	*Urls;

#ifdef	V120
					if( Entry->Name )
					{
						Urls = malloc( strlen( Url ) + 1 + strlen( Entry->Name ) + 1 );
						strcpy( Urls, Url );
						strcpy( Urls + strlen( Urls ) + 1, Entry->Name );
					}
#else
					if( Entry->Comment )
					{
						Urls = malloc( strlen( Url ) + 1 + strlen( Entry->Comment ) + 1 );
						strcpy( Urls, Url );
						strcpy( Urls + strlen( Urls ) + 1, Entry->Comment );
					}
#endif
					else
					{
						Urls = malloc( strlen( Url ) + 2 );
						strcpy( Urls, Url );
						Urls[strlen( Urls ) + 1] = 0;
					}
					free( Url );
					Msg[0] = DragDropUrl;
					Msg[1] = AppId;
					Msg[2] = 0;
					Msg[3] = Ev.x;
					Msg[4] = Ev.y;
					Msg[5] = Ev.kstate;
					*(BYTE **) &( Msg[6] ) = Urls;
					MT_appl_write( AppId, 16, Msg, Global );
				}
			}
		}
#endif
	}
	else
	{
		if( DialogTree[HT_CHANGE].ob_flags & SELECTABLE )
		{
			DialogTree[HT_CHANGE].ob_state |= DISABLED;
			DialogTree[HT_CHANGE].ob_flags &= ~SELECTABLE;
			DialogTree[HT_CHANGE_I].ob_state |= DISABLED;
			DialogTree[HT_CHANGE_I].ob_flags &= ~TOUCHEXIT;
			DoRedraw( Dialog, &Rect, HT_CHANGE, Global );
		}
		if( DialogTree[HT_DEL].ob_flags & SELECTABLE )
		{
			DialogTree[HT_DEL].ob_state |= DISABLED;
			DialogTree[HT_DEL].ob_flags &= ~SELECTABLE;
			DialogTree[HT_DEL_I].ob_state |= DISABLED;
			DialogTree[HT_DEL_I].ob_flags &= ~TOUCHEXIT;
			DoRedraw( Dialog, &Rect, HT_DEL, Global );
		}
		if( ExistHtItem( DialogTree[HT_NAME].ob_spec.tedinfo->te_ptext ))
		{
			if( DialogTree[HT_ADD].ob_flags & SELECTABLE )
			{
				DialogTree[HT_ADD].ob_state |= DISABLED;
				DialogTree[HT_ADD].ob_flags &= ~SELECTABLE;
				DialogTree[HT_ADD_I].ob_state |= DISABLED;
				DialogTree[HT_ADD_I].ob_flags &= ~TOUCHEXIT;
				DoRedraw( Dialog, &Rect, HT_ADD, Global );
			}
		}
		else
		{
			if( DialogTree[HT_ADD].ob_state & DISABLED )
			{
				DialogTree[HT_ADD].ob_state &= ~DISABLED;
				DialogTree[HT_ADD].ob_flags |= SELECTABLE;
				DialogTree[HT_ADD_I].ob_state &= ~DISABLED;
				DialogTree[HT_ADD_I].ob_flags |= TOUCHEXIT;
				DoRedraw( Dialog, &Rect, HT_ADD, Global );
			}
		}
	}
}

void	FreeSessionItem( SESSION_ITEM *Item )
{
#ifdef	V120
	if( Item->Name )	free( Item->Name );
#endif
	if( Item->Host )	free( Item->Host );
	if( Item->Uid )	free( Item->Uid );
	if( Item->Pwd )	free( Item->Pwd );
	if( Item->Dir )	free( Item->Dir );
	if( Item->Comment )	free( Item->Comment );
}
#ifdef	V110
void	FreeSession( SESSION	*Session )
{
#ifdef	V120
	if( Session->Name )	free( Session->Name );
#endif
	if( Session->Host )	free( Session->Host );
	if( Session->Uid )	free( Session->Uid );
	if( Session->Pwd )	free( Session->Pwd );
	if( Session->Dir )	free( Session->Dir );
	if( Session->Comment )	free( Session->Comment );
}
#endif

void	SortSessionItem( SESSION_ITEM *HtItems )
{
	SESSION_ITEM	tmp, *tmp1, *tmp2;
	BYTE	*a, *b;
	
	if( !HtItems )
		return;

	tmp1 = HtItems;
	while( tmp1 )
	{
		tmp2 = tmp1->next;
		while( tmp2 )
		{
#ifdef	V120
			a = tmp1->Name;
			b = tmp2->Name;
#else
			a = tmp1->Host;
			b = tmp2->Host;
#endif
			while( *a != 0x0 && *b != 0x0 )
			{
#ifdef	V120
				if( *a < *b )
#else
				if( tolower((int) *a ) < tolower((int) *b ))
#endif
					break;
					
#ifdef	V120
				if( *b < *a )
#else
				if(( tolower((int) *b ) < tolower((int) *a )) ||
				  ( *a != *b  && ( tolower((int) *b ) == tolower((int) *a )) && islower((int) *b )))
#endif
				{
					tmp.selected = tmp1->selected;
#ifdef	V120
					tmp.Name = tmp1->Name;
#endif
					tmp.Host = tmp1->Host;
					tmp.Port = tmp1->Port;
					tmp.Uid = tmp1->Uid;
					tmp.Pwd = tmp1->Pwd;
					tmp.Dir = tmp1->Dir;
					tmp.Comment = tmp1->Comment;

					tmp1->selected = tmp2->selected;
#ifdef	V120
					tmp1->Name = tmp2->Name;
#endif
					tmp1->Host = tmp2->Host;
					tmp1->Port = tmp2->Port;
					tmp1->Uid = tmp2->Uid;
					tmp1->Pwd = tmp2->Pwd;
					tmp1->Dir = tmp2->Dir;
					tmp1->Comment = tmp2->Comment;

					tmp2->selected = tmp.selected;
#ifdef	V120
					tmp2->Name = tmp.Name;
#endif
					tmp2->Host = tmp.Host;
					tmp2->Port = tmp.Port;
					tmp2->Uid = tmp.Uid;
					tmp2->Pwd = tmp.Pwd;
					tmp2->Dir = tmp.Dir;
					tmp2->Comment = tmp.Comment;
					break;
				}
				a++; b++;
			}
			tmp2 = tmp2->next;
		}
		tmp1 = tmp1->next;
	}
}

WORD	Ht2SessionItem( SESSION_ITEM	**HtItems )
{
	WORD				i, MaxLen = 0;
	SESSION_ITEM	*tmp;

	*HtItems = NULL;

	for( i = 0; i < nHotlist; i++ )
	{
		tmp = malloc( sizeof( SESSION_ITEM ));
		if( !tmp )
			return( ENSMEM );
		tmp->selected = 0;
		tmp->next = *HtItems;
#ifdef	V120
		tmp->Name = strdup( HotlistName[i] );
		if( !tmp->Name )
			return( ENSMEM );
#endif
		tmp->Host = strdup( HotlistHost[i] );
		if( !tmp->Host )
			return( ENSMEM );
		tmp->Port = HotlistPort[i];
		if( HotlistUid[i] )
		{
			tmp->Uid = strdup( HotlistUid[i] );
			if( !tmp->Uid )
				return( ENSMEM );
		}
		else
			tmp->Uid = NULL;
		if( HotlistPwd[i] )
		{
			tmp->Pwd = strdup( HotlistPwd[i] );
			if( !tmp->Pwd )
				return( ENSMEM );
		}
		else
			tmp->Pwd = NULL;
		if( HotlistDir[i] )
		{
			tmp->Dir = strdup( HotlistDir[i] );
			if( !tmp->Dir )
				return( ENSMEM );
		}	
		else
			tmp->Dir = 0L;
		if( HotlistComment[i] )
		{
			tmp->Comment = strdup( HotlistComment[i] );
			if( !tmp->Comment )
				return( ENSMEM );
		}
		else
			tmp->Comment = NULL;
		*HtItems = tmp;	
			
#ifdef	V120
		if( strlen( HotlistName[i] ) > MaxLen )
			MaxLen = (WORD) strlen( HotlistName[i] );
#else
		if( strlen( HotlistHost[i] ) > MaxLen )
			MaxLen = (WORD) strlen( HotlistHost[i] );
#endif
	}
	return( MaxLen );
}

WORD	SessionItem2Ht( SESSION_ITEM *HtItems )
{
	SESSION_ITEM	*tmp;
	WORD				i, n = 0; 

	for( i = 0; i < nHotlist; i++ )
	{
#ifdef	V120
		free( HotlistName[i] );
#endif
		free( HotlistHost[i] );
		if( HotlistUid[i] )
			free( HotlistUid[i] );
		if( HotlistPwd[i] )
			free( HotlistPwd[i] );
		if( HotlistDir[i] )
			free( HotlistDir[i] );
		if( HotlistComment[i] )
			free( HotlistComment[i] );
#ifdef	V120
		free( HotlistName);
#endif
		free( HotlistHost);
		free( HotlistPort );
		free( HotlistUid );
		free( HotlistPwd );
		free( HotlistDir );
		free( HotlistComment );
	}
	tmp = HtItems;
	while( tmp )
	{
		n++;
		tmp = tmp->next;
	}
	nHotlist = n;
#ifdef	V120
	HotlistName = malloc( n * sizeof( LONG ));
	if( !HotlistName )
		return( ENSMEM );
#endif
	HotlistHost = malloc( n * sizeof( LONG ));
	HotlistPort = malloc( n * sizeof( WORD ));
	HotlistUid = malloc( n * sizeof( LONG ));
	HotlistPwd = malloc( n * sizeof( LONG ));
	HotlistDir = malloc( n * sizeof( LONG ));
	HotlistComment = malloc( n * sizeof( LONG ));
	if( !HotlistHost || !HotlistPort || !HotlistUid || !HotlistPwd ||
	    !HotlistDir || !HotlistComment )
		return( ENSMEM );
	tmp = HtItems;
	for( i = 0; i < n; i++ )
	{
#ifdef	V120
		HotlistName[i] = strlen( tmp->Name ) > 0 ? strdup( tmp->Name ) : strdup( tmp->Host );
		if( !HotlistName[i] )
			return( ENSMEM );
#endif
		HotlistHost[i] = strdup( tmp->Host );
		if( !HotlistHost[i] )
			return( ENSMEM );
		HotlistPort[i] = tmp->Port;
		if( tmp->Uid )
		{
			HotlistUid[i] = strdup( tmp->Uid );
			if( !HotlistUid[i] )
				return( ENSMEM );
		}
		else
			HotlistUid[i] = 0L;
		if( tmp->Pwd )
		{
			HotlistPwd[i] = strdup( tmp->Pwd );
			if( !HotlistPwd[i] )
				return( ENSMEM );
		}
		else
			HotlistPwd[i] = 0L;
		if( tmp->Dir )
		{
			HotlistDir[i] = strdup( tmp->Dir );
			if( !HotlistDir[i] )
				return( ENSMEM );
		}
		else
			HotlistDir[i] = 0L;
		if( tmp->Comment )
		{
			HotlistComment[i] = strdup( tmp->Comment );
			if( !HotlistComment[i] )
				return( ENSMEM );
		}
		else
			HotlistComment[i] = NULL;
		tmp = tmp->next;
	}

	return( E_OK );
}
WORD	InsertHtItem( BYTE *Name, BYTE *Host, WORD Port, BYTE *Uid, BYTE *Pwd, BYTE *Dir, BYTE *Comment )
{
	if( ExistHtItem( Name ))
	{
		WORD	i = 0;
		while( strcmp( HotlistName[i++], Name ) != 0 );
		{
			i--;
			HotlistPort[i] = Port;
			if( HotlistUid[i] )
				free( HotlistUid[i] );

			if( Name )
			{
				HotlistName[i] = strdup( Name );
				if( !HotlistName[i] )
					return( ENSMEM );
			}
			if( Uid )
			{
				HotlistUid[i] = strdup( Uid );
				if( !HotlistUid[i] )
					return( ENSMEM );
			}
			else
				HotlistUid[i] = NULL;
			if( HotlistPwd[i] )
				free( HotlistPwd[i] );
			if( Pwd )
			{
				HotlistPwd[i] = strdup( Pwd );
				if( !HotlistPwd[i] )
					return( ENSMEM );
			}
			else
				HotlistPwd[i] = NULL;
			if( HotlistDir[i] )
				free( HotlistDir[i] );
			if( Dir )
			{
				HotlistDir[i] = strdup( Dir );
				if( !HotlistDir[i] )
					return( ENSMEM );
			}
			else
				HotlistDir[i] = NULL;

			if( HotlistComment[i] )
				free( HotlistComment[i] );
			if( Comment )
			{
				HotlistComment[i] = malloc( strlen( Comment ) + 1 + 4 );
				if( !HotlistComment[i] )
					return( ENSMEM );
				strcpy( HotlistComment[i], Comment );
				strcat( HotlistComment[i], "\n\n\n\n" );
			}
			else
				HotlistComment[i] = NULL;
		}
		return( E_OK );
	}
	else
	{
		SESSION_ITEM	*HtItems, *tmp;
		if( Ht2SessionItem( &HtItems ) < 0 )
			return( ENSMEM );

		tmp = malloc( sizeof( SESSION_ITEM ));
		if( !tmp )
			return( ENSMEM );
		tmp->next = HtItems;

#ifdef	V120
		tmp->Name = strdup( Name );
		if( !tmp->Name )
			return( ENSMEM );
#endif
		tmp->Host = strdup( Host );
		if( !tmp->Host )
			return( ENSMEM );
		tmp->Port = Port;
		if( Uid )
		{
			tmp->Uid = strdup( Uid );
			if( !tmp->Uid )
				return( ENSMEM );
		}
		else
			tmp->Uid = NULL;
		if( Pwd )
		{
			tmp->Pwd = strdup( Pwd );
			if( !tmp->Pwd )
				return( ENSMEM );
		}
		else
			tmp->Pwd = NULL;
		if( Dir )
		{
			tmp->Dir = strdup( Dir );
			if( !tmp->Dir )
				return( ENSMEM );
		}
		else
			tmp->Dir = NULL;

		if( Comment )
		{
			tmp->Comment = strdup( Comment );
			if( !tmp->Comment )
				return( ENSMEM );
		}
		else
			tmp->Comment = NULL;
									
		HtItems = tmp;
		SortSessionItem( HtItems );
		SessionItem2Ht( HtItems );
		while( HtItems )
		{
			tmp = HtItems;
			HtItems = tmp->next;
			FreeSessionItem( tmp );
			free( tmp );
		}
	}
	return( E_OK );
}

WORD	ExistHtItem( BYTE *Name )
{
	WORD	i;
	for( i = 0; i < nHotlist; i++ )
	{
		if( strcmp( HotlistName[i], Name ) == 0 )
			return( 1 );
	}
	return( 0 );
}

#if	defined( KEY ) || defined( V110 )
void	UpdateHotlistDialog( DIALOG *Dialog )
{
	SESSION_ITEM *tmp;
	WORD	MaxLen = 0;
	OBJECT			*DialogTree;
	GRECT				Rect;
	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );

	while( HtItems )
	{
		tmp = HtItems;
		HtItems = HtItems->next;
		FreeSessionItem( tmp );
		free( tmp );
	}

	Ht2SessionItem( &HtItems );
	MT_lbox_set_items( HtLbox, (LBOX_ITEM *) HtItems, Global );
	tmp = HtItems;

	while( tmp )
	{
		if( strlen( tmp->Host ) > MaxLen )
			MaxLen = (WORD) strlen( tmp->Host );
		tmp = tmp->next;
	}
	if( HtItems )
	{
		SortSessionItem( HtItems );
		MT_lbox_set_bentries( HtLbox, MaxLen, Global );
		DoRedraw( Dialog, &Rect, HT_ENTRY_BACK_H, Global );
	}
	MT_lbox_update( HtLbox, &Rect, Global );
}
#endif

/*----------------------------------------------------------------------------------------*/ 
/* HandleDoubleHtDialog                                                                   */
/*----------------------------------------------------------------------------------------*/ 
#if	defined( KEY ) || defined( V110 )
WORD cdecl	HandleDoubleHtDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD )
{
	OBJECT	*DialogTree;
	GRECT		Rect;

	WORD 		*Global;
	Global = (WORD *) UD;

	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );

	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_INIT:
			{
				DialogTree[DHT_OK].ob_state &= ~SELECTED;
				DialogTree[DHT_CANCEL].ob_state &= ~SELECTED;
				break;
			}
			case	HNDL_MESG:
			{
				if( Events->msg[0] == WM_ICONIFY )
				{
					RSHDR 	*Rsh;
					OBJECT	**TreeAddr;
					Rsh = *((RSHDR **)( &(Global[7] )));	
					TreeAddr = (OBJECT **)(((UBYTE *)Rsh) + Rsh->rsh_trindex);
					if( !isIconifiedWindow( MT_wdlg_get_handle( Dialog, Global )))
					{
						DialogTree = malloc( 2 * sizeof( OBJECT ));
						if( !DialogTree )
						{
							MemErr( "DoubleHt" );
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
					RSHDR 	*Rsh;
					OBJECT	**TreeAddr;
					Rsh = *((RSHDR **)( &(Global[7] )));
					TreeAddr = (OBJECT **)(((UBYTE *)Rsh) + Rsh->rsh_trindex);
					MT_wdlg_set_uniconify( Dialog, ( GRECT *) &( Events->msg[4] ), NULL, TreeAddr[DHT], Global );
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
			case	HNDL_CLSD:
				return( 0 );
		}
	}
	else
	{
		Obj &= 0x7fff;
		if( Obj == DHT_OK || Obj == DHT_CANCEL )
			return( 0 );
	}
	return( 1 );
}
#endif

/*----------------------------------------------------------------------------------------*/ 
/* HandleInsertDialog                                                                     */
/*----------------------------------------------------------------------------------------*/ 
#ifdef	KEY
WORD cdecl	HandleInsertHtDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD )
{
	OBJECT	*DialogTree;
	GRECT		Rect;

	WORD 		*Global;
	Global = (WORD *) UD;

	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );

	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_INIT:
			{
				DialogTree[IHT_OK].ob_state &= ~SELECTED;
				DialogTree[IHT_CANCEL].ob_state &= ~SELECTED;
				break;
			}
			case	HNDL_MESG:
			{
				if( Events->msg[0] == WM_ICONIFY )
				{
					RSHDR 	*Rsh;
					OBJECT	**TreeAddr;
					Rsh = *((RSHDR **)( &(Global[7] )));	
					TreeAddr = (OBJECT **)(((UBYTE *)Rsh) + Rsh->rsh_trindex);
					if( !isIconifiedWindow( MT_wdlg_get_handle( Dialog, Global )))
					{
						DialogTree = malloc( 2 * sizeof( OBJECT ));
						if( !DialogTree )
						{
							MemErr( "InsertHt" );
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
					RSHDR 	*Rsh;
					OBJECT	**TreeAddr;
					Rsh = *((RSHDR **)( &(Global[7] )));
					TreeAddr = (OBJECT **)(((UBYTE *)Rsh) + Rsh->rsh_trindex);
					MT_wdlg_set_uniconify( Dialog, ( GRECT *) &( Events->msg[4] ), NULL, TreeAddr[IHT], Global );
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
			case	HNDL_CLSD:
				return( 0 );
		}
	}
	else
	{
		Obj &= 0x7fff;
		if( Obj == IHT_OK || Obj == IHT_CANCEL )
			return( 0 );
	}
	return( 1 );
}
#endif