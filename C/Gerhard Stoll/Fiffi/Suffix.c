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

#include	<atarierr.h>

#include "main.h"
#include "Suffix.h"
#include	"Window.h"
#include	"Config.h"
#include "Fiffi.h"
#include "mapkey.h"
#include	"edscroll.h"

typedef struct _suffix_item
{
	struct	_suffix_item	*next;
	WORD		selected;
	BYTE		*str;
	UWORD		mode;
} SUFFIX_ITEM;

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern WORD			Global[15];
extern WORD			AppId;
extern WORD			magic_version;
extern LONG			magic_date;
extern OBJECT		**TreeAddr;
extern BYTE			**FstringAddr;
extern SUF_ITEM	*SuffixList;
extern UWORD		TransferTypeAuto;
/*-----------------------------------------------------------------------------*/
/* Globale Variablen                                                           */
/*-----------------------------------------------------------------------------*/
LIST_BOX			*SuffixLbox;
SUFFIX_ITEM		*SuffixItem = NULL;
XTED				Xted;
BYTE 				Tmplt[EditLen+1], Txt[EditLen+1];

/* Objekte der Listbox */
#define	NO_SUFFIX_V	16
#define	NO_SUFFIX_H	17
WORD	SuffixCtrl[9] = { SUFFIX_BOX, SUFFIX_UP, SUFFIX_DOWN, SUFFIX_BACK, SUFFIX_SL, SUF_ENTRY_LEFT, SUF_ENTRY_RIGHT, SUF_ENTRY_BACK_H, SUF_ENTRY_SL_H };
WORD	SuffixObjs[NO_SUFFIX_V] = { SUFFIX_0, SUFFIX_1, SUFFIX_2, SUFFIX_3, SUFFIX_4, 
    	                            SUFFIX_5, SUFFIX_6, SUFFIX_7, SUFFIX_8, SUFFIX_9,
    	                            SUFFIX_10, SUFFIX_11, SUFFIX_12, SUFFIX_13, SUFFIX_14,
    	                            SUFFIX_15 };

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
void cdecl	SlctSuffix( LIST_BOX *Lbox, OBJECT *DialogTree, LBOX_ITEM *Item, void *UD, WORD ObjIndex, WORD LastState );
void			SortSuffixItem( SUFFIX_ITEM *ItemList );
WORD			ExistSuffixItem( BYTE *Ext );
WORD			Suf2SuffixItem( SUFFIX_ITEM	**SuffixItem );
WORD			Suffix2Suf( SUFFIX_ITEM *SuffixItem );
WORD			Suffix2Suf( SUFFIX_ITEM *SuffixItem );

/*-----------------------------------------------------------------------------*/
/* Service-Routine fÅr Suffix                                                  */
/*-----------------------------------------------------------------------------*/
WORD	cdecl	HandleSuffixDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD )
{
	OBJECT			*DialogTree;
	GRECT				Rect;

	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );

	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_INIT:
			{
				WORD	isScroll, MaxLen;

				MaxLen =	Suf2SuffixItem( &SuffixItem );
				if( MaxLen < 0 )
				{
					MemErr( "Suffix" );
					return( 0 );
				}
				SortSuffixItem( SuffixItem );

				if(( SuffixLbox = MT_lbox_create( DialogTree, SlctSuffix, SetStrItem, 
				   ( LBOX_ITEM * ) SuffixItem, NO_SUFFIX_V, 0, SuffixCtrl, SuffixObjs, 
				   LBOX_VERT + LBOX_AUTO + LBOX_AUTOSLCT + LBOX_2SLDRS + LBOX_REAL + LBOX_SNGL + LBOX_SHFT, 
				   40, ( void * ) Dialog, Dialog, NO_SUFFIX_H, 0, MaxLen + 2, 40, Global )) == 0 )
					return( 0 );

				if( magic_version && magic_date >= 0x19950829L )
					isScroll = 1;
				else
					isScroll = 0;
				if( !Xted.xte_ptmplt )
					InitScrlted( &DialogTree[SUFFIX_EXT], isScroll, &Xted, Txt, Tmplt, EditLen);

				strcpy( DialogTree[SUFFIX_EXT].ob_spec.tedinfo->te_ptext, "" );
				DialogTree[SUFFIX_ASCII].ob_state &= ~SELECTED;
				DialogTree[SUFFIX_BIN].ob_state |= SELECTED;
				DialogTree[SUFFIX_ADD].ob_state &= ~SELECTED;
				DialogTree[SUFFIX_ADD].ob_state |= DISABLED;
				DialogTree[SUFFIX_ADD].ob_flags &= ~SELECTABLE;
				DialogTree[SUFFIX_ADD_I].ob_state &= ~TOUCHEXIT;
				DialogTree[SUFFIX_ADD_I].ob_state |= DISABLED;
				DialogTree[SUFFIX_CHANGE].ob_state &= ~SELECTED;
				DialogTree[SUFFIX_CHANGE].ob_state |= DISABLED;
				DialogTree[SUFFIX_CHANGE].ob_flags &= ~SELECTABLE;
				DialogTree[SUFFIX_CHANGE_I].ob_state &= ~TOUCHEXIT;
				DialogTree[SUFFIX_CHANGE_I].ob_state |= DISABLED;
				DialogTree[SUFFIX_DEL].ob_state &= ~SELECTED;
				DialogTree[SUFFIX_DEL].ob_state |= DISABLED;
				DialogTree[SUFFIX_DEL].ob_flags &= ~SELECTABLE;
				DialogTree[SUFFIX_DEL_I].ob_state &= ~TOUCHEXIT;
				DialogTree[SUFFIX_DEL_I].ob_state |= DISABLED;
				break;
			}
			case	HNDL_EDIT:
			{
				WORD	a, b;
				if( IsMenuKey( Events->key, &a, &b ))
					return( 0 );
				break;
			}
			case	HNDL_EDDN:
			{
#ifdef	V110
				if( strlen( DialogTree[SUFFIX_EXT].ob_spec.tedinfo->te_ptext ))
				{
					WORD			Idx = 0;
					STR_ITEM	*Item;
					while(( Item = ( STR_ITEM * ) MT_lbox_get_item( SuffixLbox, Idx, Global )) != NULL )
					{
						if( strncmp( Item->str, DialogTree[SUFFIX_EXT].ob_spec.tedinfo->te_ptext, strlen( DialogTree[SUFFIX_EXT].ob_spec.tedinfo->te_ptext )) == 0 )
						{
							SUFFIX_ITEM	*Tmp = SuffixItem;
#ifdef	V120
							if( Item->selected )
								break;
#endif
							while( Tmp )
							{
								Tmp->selected = 0; 
								Tmp = Tmp->next;
							}
							Item->selected = 1;
							MT_lbox_set_asldr( SuffixLbox, Idx, &Rect, Global );
							MT_lbox_update( SuffixLbox, &Rect, Global );
							if((( SUFFIX_ITEM * )Item )->mode == TT_Bin )
							{
								DialogTree[SUFFIX_ASCII].ob_state &= ~SELECTED;
								DialogTree[SUFFIX_BIN].ob_state |= SELECTED;
							}
							if( (( SUFFIX_ITEM * )Item )->mode == TT_Ascii )
							{
								DialogTree[SUFFIX_ASCII].ob_state |= SELECTED;
								DialogTree[SUFFIX_BIN].ob_state &= ~SELECTED;
							}
							DoRedrawX( Dialog, &Rect, Global, SUFFIX_ASCII, SUFFIX_BIN, EDRX );
							break;
						}
						Idx++;
					}
				}
#endif
				if( strlen( DialogTree[SUFFIX_EXT].ob_spec.tedinfo->te_ptext ) && 
				    !ExistSuffixItem( DialogTree[SUFFIX_EXT].ob_spec.tedinfo->te_ptext ))
				{
					if( DialogTree[SUFFIX_ADD].ob_state & DISABLED )
					{
						DialogTree[SUFFIX_ADD].ob_state &= ~DISABLED;
						DialogTree[SUFFIX_ADD].ob_flags |= SELECTABLE;
						DialogTree[SUFFIX_ADD_I].ob_state &= ~DISABLED;
						DialogTree[SUFFIX_ADD_I].ob_flags |= TOUCHEXIT;
						DoRedraw( Dialog, &Rect, SUFFIX_ADD, Global );
					}
				}
				else
				{
					if( DialogTree[SUFFIX_ADD].ob_flags & SELECTABLE )
					{
						DialogTree[SUFFIX_ADD].ob_state |= DISABLED;
						DialogTree[SUFFIX_ADD].ob_flags &= ~SELECTABLE;
						DialogTree[SUFFIX_ADD_I].ob_state |= DISABLED;
						DialogTree[SUFFIX_ADD_I].ob_flags &= ~TOUCHEXIT;
						DoRedraw( Dialog, &Rect, SUFFIX_ADD, Global );
					}
				}
				if( MT_lbox_get_slct_idx( SuffixLbox, Global ) != -1 )
				{
					if( DialogTree[SUFFIX_DEL].ob_state & DISABLED )
					{
						DialogTree[SUFFIX_DEL].ob_state &= ~DISABLED;
						DialogTree[SUFFIX_DEL].ob_flags |= SELECTABLE;
						DialogTree[SUFFIX_DEL_I].ob_state &= ~DISABLED;
						DialogTree[SUFFIX_DEL_I].ob_flags |= TOUCHEXIT;
						DoRedraw( Dialog, &Rect, SUFFIX_DEL, Global );
					}
				}
				else
				{
					if( DialogTree[SUFFIX_DEL].ob_flags & SELECTABLE )
					{
						DialogTree[SUFFIX_DEL].ob_state |= DISABLED;
						DialogTree[SUFFIX_DEL].ob_flags &= ~SELECTABLE;
						DialogTree[SUFFIX_DEL_I].ob_state |= DISABLED;
						DialogTree[SUFFIX_DEL_I].ob_flags &= ~TOUCHEXIT;
						DoRedraw( Dialog, &Rect, SUFFIX_DEL, Global );
					}
				}

				if( MT_lbox_get_slct_idx( SuffixLbox, Global ) != -1 &&
				    strlen( DialogTree[SUFFIX_EXT].ob_spec.tedinfo->te_ptext ))
				{
					if( DialogTree[SUFFIX_CHANGE].ob_state & DISABLED )
					{
						DialogTree[SUFFIX_CHANGE].ob_state &= ~DISABLED;
						DialogTree[SUFFIX_CHANGE].ob_flags |= SELECTABLE;
						DialogTree[SUFFIX_CHANGE_I].ob_state &= ~DISABLED;
						DialogTree[SUFFIX_CHANGE_I].ob_flags |= TOUCHEXIT;
						DoRedraw( Dialog, &Rect, SUFFIX_CHANGE, Global );
					}
				}
				else
				{
					if( DialogTree[SUFFIX_CHANGE].ob_flags & SELECTABLE )
					{
						DialogTree[SUFFIX_CHANGE].ob_state |= DISABLED;
						DialogTree[SUFFIX_CHANGE].ob_flags &= ~SELECTABLE;
						DialogTree[SUFFIX_CHANGE_I].ob_state |= DISABLED;
						DialogTree[SUFFIX_CHANGE_I].ob_flags &= ~TOUCHEXIT;
						DoRedraw( Dialog, &Rect, SUFFIX_CHANGE, Global );
					}
				}
				break;
			}
			case	HNDL_CLSD:
			{
				SUFFIX_ITEM	*Item;
				MT_lbox_delete( SuffixLbox, Global );
				while( SuffixItem )
				{
					Item = SuffixItem->next;
					if( SuffixItem->str )
						free( SuffixItem->str );
					free( SuffixItem );
					SuffixItem = Item;
				}
				return( 0 );
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
							MemErr( "Suffix" );
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
					MT_wdlg_set_uniconify( Dialog, ( GRECT *) &( Events->msg[4] ), NULL, TreeAddr[SUFFIX], Global );
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
		}
	}
	else
	{
		MT_lbox_do( SuffixLbox, Obj, Global );

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

		if( Obj == SUFFIX_DEL )
		{
			WORD	SlctIdx;
			if(( SlctIdx = MT_lbox_get_slct_idx( SuffixLbox, Global )) != -1 )
			{
				SUFFIX_ITEM	*Item, *DelItem = ( SUFFIX_ITEM *) MT_lbox_get_item( SuffixLbox, SlctIdx, Global );
				WORD			FirstVisIdx = MT_lbox_get_afirst( SuffixLbox, Global );
				WORD			MaxLen = 0;
				if( DelItem == SuffixItem )
					SuffixItem = DelItem->next;
				else
				{
					Item = ( SUFFIX_ITEM * ) MT_lbox_get_item( SuffixLbox, SlctIdx - 1, Global );
					Item->next = DelItem->next;
				}
				if( DelItem->str )
					free( DelItem->str );
				free( DelItem );

				Item = SuffixItem;
				while( Item )
				{
					if( strlen( Item->str ) > MaxLen )
						MaxLen = ( WORD ) strlen( Item->str );
					Item = Item->next;
				}

				MT_lbox_set_items( SuffixLbox, ( LBOX_ITEM * ) SuffixItem, Global );
				MT_lbox_set_asldr( SuffixLbox, FirstVisIdx, &Rect, Global );
				MT_lbox_set_bentries( SuffixLbox, MaxLen + 2, Global );
				MT_lbox_set_bsldr( SuffixLbox, 0, &Rect, Global );
				DoRedraw( Dialog, &Rect, SUF_ENTRY_BACK_H, Global );
				MT_lbox_update( SuffixLbox, &Rect, Global );

				strcpy( DialogTree[SUFFIX_EXT].ob_spec.tedinfo->te_ptext, "" );
				DoRedraw( Dialog, &Rect, SUFFIX_EXT, Global );
				MT_wdlg_set_edit( Dialog, 0, Global );
				MT_wdlg_set_edit( Dialog, SUFFIX_EXT, Global );

				if( DialogTree[SUFFIX_ADD].ob_flags & SELECTABLE )
				{
					DialogTree[SUFFIX_ADD].ob_state |= DISABLED;
					DialogTree[SUFFIX_ADD].ob_flags &= ~SELECTABLE;
					DialogTree[SUFFIX_ADD_I].ob_state |= DISABLED;
					DialogTree[SUFFIX_ADD_I].ob_flags &= ~TOUCHEXIT;
					DoRedraw( Dialog, &Rect, SUFFIX_ADD, Global );
				}
				if( DialogTree[SUFFIX_CHANGE].ob_flags & SELECTABLE )
				{
					DialogTree[SUFFIX_CHANGE].ob_state |= DISABLED;
					DialogTree[SUFFIX_CHANGE].ob_flags &= ~SELECTABLE;
					DialogTree[SUFFIX_CHANGE_I].ob_state |= DISABLED;
					DialogTree[SUFFIX_CHANGE_I].ob_flags &= ~TOUCHEXIT;
					DoRedraw( Dialog, &Rect, SUFFIX_CHANGE, Global );
				}
				DialogTree[SUFFIX_DEL].ob_state |= DISABLED;
				DialogTree[SUFFIX_DEL].ob_state &= ~SELECTED;
				DialogTree[SUFFIX_DEL].ob_flags |= SELECTABLE;
				DialogTree[SUFFIX_DEL_I].ob_state |= DISABLED;
				DialogTree[SUFFIX_DEL_I].ob_flags &= ~TOUCHEXIT;
				DoRedraw( Dialog, &Rect, SUFFIX_DEL, Global );
				if( Suffix2Suf( SuffixItem ) != E_OK )
				{
					MemErr( "Suffix" );
					return( 0 );
				}
			}
		}

		if( Obj == SUFFIX_ADD )
		{
			WORD	FirstVisIdx = MT_lbox_get_afirst( SuffixLbox, Global );
			WORD	SlctIdx, MaxLen = 0;
			SUFFIX_ITEM	*NewItem = malloc( sizeof( SUFFIX_ITEM )), *Item;
			if( !NewItem )
			{
				MemErr( "Suffix" );
				return( 0 );
			}
			NewItem->selected = 0;
			if( DialogTree[SUFFIX_ASCII].ob_state & SELECTED )
				NewItem->mode = TT_Ascii;
			if( DialogTree[SUFFIX_BIN].ob_state & SELECTED )
				NewItem->mode = TT_Bin;
			NewItem->str = strdup( DialogTree[SUFFIX_EXT].ob_spec.tedinfo->te_ptext );
			if( !NewItem->str )
			{
				MemErr( "Suffix" );
				return( 0 );
			}
			if( MT_lbox_get_slct_item( SuffixLbox, Global ))
				MT_lbox_get_slct_item( SuffixLbox, Global )->selected = 0;
			if( !SuffixItem )
			{
				SuffixItem = NewItem;
				NewItem->next = NULL;
			}
			else
			{
				NewItem->next = SuffixItem->next;
				SuffixItem->next = NewItem;
			}
			NewItem->selected = 1;
			SortSuffixItem( SuffixItem );
			Item = SuffixItem;
			while( Item )
			{
				if( strlen( Item->str ) > MaxLen )
					MaxLen = ( WORD ) strlen( Item->str );
				Item = Item->next;
			}
			MT_lbox_set_items( SuffixLbox, ( LBOX_ITEM * ) SuffixItem, Global );
			MT_lbox_set_asldr( SuffixLbox, FirstVisIdx, &Rect, Global );
			MT_lbox_set_bentries( SuffixLbox, MaxLen + 2, Global );
			MT_lbox_set_bsldr( SuffixLbox, 0, &Rect, Global );
			DoRedraw( Dialog, &Rect, SUF_ENTRY_BACK_H, Global );
			if( MT_lbox_get_afirst( SuffixLbox, Global ) + NO_SUFFIX_V > 
			   ( SlctIdx = MT_lbox_get_slct_idx( SuffixLbox, Global )))
				MT_lbox_set_asldr( SuffixLbox, SlctIdx + NO_SUFFIX_V / 2, &Rect, Global );
			MT_lbox_update( SuffixLbox, &Rect, Global );

			DialogTree[SUFFIX_ADD].ob_state &= ~SELECTED;
			DialogTree[SUFFIX_ADD].ob_state |= DISABLED;
			DialogTree[SUFFIX_ADD].ob_flags &= ~SELECTABLE;
			DialogTree[SUFFIX_ADD_I].ob_state |= DISABLED;
			DialogTree[SUFFIX_ADD_I].ob_flags &= ~TOUCHEXIT;
			DoRedraw( Dialog, &Rect, SUFFIX_ADD, Global );
			if( DialogTree[SUFFIX_CHANGE].ob_state & DISABLED )
			{
				DialogTree[SUFFIX_CHANGE].ob_state &= ~DISABLED;
				DialogTree[SUFFIX_CHANGE].ob_flags |= SELECTABLE;
				DialogTree[SUFFIX_CHANGE_I].ob_state &= ~DISABLED;
				DialogTree[SUFFIX_CHANGE_I].ob_flags |= TOUCHEXIT;
				DoRedraw( Dialog, &Rect, SUFFIX_CHANGE, Global );
			}
			if( DialogTree[SUFFIX_DEL].ob_state & DISABLED )
			{
				DialogTree[SUFFIX_DEL].ob_state &= ~DISABLED;
				DialogTree[SUFFIX_DEL].ob_flags |= SELECTABLE;
				DialogTree[SUFFIX_DEL_I].ob_state &= ~DISABLED;
				DialogTree[SUFFIX_DEL_I].ob_flags |= TOUCHEXIT;
				DoRedraw( Dialog, &Rect, SUFFIX_DEL, Global );
			}
			if( Suffix2Suf( SuffixItem ) != E_OK )
			{
				MemErr( "Suffix" );
				return( 0 );
			}
		}

		if( Obj == SUFFIX_CHANGE )
		{
			SUFFIX_ITEM	*SlctItem = ( SUFFIX_ITEM * ) MT_lbox_get_slct_item( SuffixLbox, Global ), *Item;
			if( SlctItem )
			{
				WORD	SlctIdx, FirstVisIdx, MaxLen = 0;
				if( SlctItem->str )
					free( SlctItem->str );
				SlctItem->str = strdup( DialogTree[SUFFIX_EXT].ob_spec.tedinfo->te_ptext );
				if( !SlctItem->str )
				{
					MemErr( "Suffix" );
					return( 0 );
				}
				if( DialogTree[SUFFIX_ASCII].ob_state & SELECTED )
					SlctItem->mode = TT_Ascii;
				if( DialogTree[SUFFIX_BIN].ob_state & SELECTED )
					SlctItem->mode = TT_Bin;

				Item = SuffixItem;
				while( Item )
				{
					if( strlen( Item->str ) > MaxLen )
						MaxLen = ( WORD ) strlen( Item->str );
					Item = Item->next;
				}

				FirstVisIdx = MT_lbox_get_afirst( SuffixLbox, Global );
				SlctIdx = MT_lbox_get_slct_idx( SuffixLbox, Global );
				if( FirstVisIdx > SlctIdx ||
				    FirstVisIdx + NO_SUFFIX_V < SlctIdx )
					MT_lbox_set_asldr( SuffixLbox, SlctIdx + NO_SUFFIX_V / 2, &Rect, Global );
				MT_lbox_set_bentries( SuffixLbox, MaxLen + 2, Global );
				MT_lbox_set_bsldr( SuffixLbox, 0, &Rect, Global );
				DoRedraw( Dialog, &Rect, SUF_ENTRY_BACK_H, Global );
				MT_lbox_update( SuffixLbox, &Rect, Global );

				DialogTree[SUFFIX_CHANGE].ob_state &= ~SELECTED;
				DoRedraw( Dialog, &Rect, SUFFIX_CHANGE, Global );
				if( Suffix2Suf( SuffixItem ) != E_OK )
				{
					MemErr( "Suffix" );
					return( 0 );
				}
			}
		}
	}
	return( 1 );
}

void cdecl	SlctSuffix( LIST_BOX *Lbox, OBJECT *DialogTree, LBOX_ITEM *Item, void *UD, WORD ObjIndex, WORD LastState )
{
	DIALOG	*Dialog;
	GRECT		Rect;

	Dialog = ( DIALOG * ) UD;	
	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );
	if( Item->selected )
	{
		strcpy( DialogTree[SUFFIX_EXT].ob_spec.tedinfo->te_ptext, (( SUFFIX_ITEM * ) Item )->str );
		if((( SUFFIX_ITEM * ) Item )->mode == TT_Ascii )
		{
			DialogTree[SUFFIX_ASCII].ob_state |= SELECTED;
			DialogTree[SUFFIX_BIN].ob_state &= ~SELECTED;
		}
		if((( SUFFIX_ITEM * ) Item )->mode == TT_Bin )
		{
			DialogTree[SUFFIX_ASCII].ob_state &= ~SELECTED;
			DialogTree[SUFFIX_BIN].ob_state |= SELECTED;
		}
		DoRedrawX( Dialog, &Rect, Global, SUFFIX_EXT, SUFFIX_ASCII, SUFFIX_BIN, EDRX );

		if( DialogTree[SUFFIX_ADD].ob_flags & SELECTABLE )
		{
			DialogTree[SUFFIX_ADD].ob_state |= DISABLED;
			DialogTree[SUFFIX_ADD].ob_flags &= ~SELECTABLE;
			DialogTree[SUFFIX_ADD_I].ob_state |= DISABLED;
			DialogTree[SUFFIX_ADD_I].ob_flags &= ~TOUCHEXIT;
			DoRedraw( Dialog, &Rect, SUFFIX_ADD, Global );
		}
		if( DialogTree[SUFFIX_CHANGE].ob_state & DISABLED )
		{
			DialogTree[SUFFIX_CHANGE].ob_state &= ~DISABLED;
			DialogTree[SUFFIX_CHANGE].ob_flags |= SELECTABLE;
			DialogTree[SUFFIX_CHANGE_I].ob_state &= ~DISABLED;
			DialogTree[SUFFIX_CHANGE_I].ob_flags |= TOUCHEXIT;
			DoRedraw( Dialog, &Rect, SUFFIX_CHANGE, Global );
		}
		if( DialogTree[SUFFIX_DEL].ob_state & DISABLED )
		{
			DialogTree[SUFFIX_DEL].ob_state &= ~DISABLED;
			DialogTree[SUFFIX_DEL].ob_flags |= SELECTABLE;
			DialogTree[SUFFIX_DEL_I].ob_state &= ~DISABLED;
			DialogTree[SUFFIX_DEL_I].ob_flags |= TOUCHEXIT;
			DoRedraw( Dialog, &Rect, SUFFIX_DEL, Global );
		}
	}
	else
	{
		if( DialogTree[SUFFIX_CHANGE].ob_flags & SELECTABLE )
		{
			DialogTree[SUFFIX_CHANGE].ob_state |= DISABLED;
			DialogTree[SUFFIX_CHANGE].ob_flags &= ~SELECTABLE;
			DialogTree[SUFFIX_CHANGE_I].ob_state |= DISABLED;
			DialogTree[SUFFIX_CHANGE_I].ob_flags &= ~TOUCHEXIT;
			DoRedraw( Dialog, &Rect, SUFFIX_CHANGE, Global );
		}
		if( DialogTree[SUFFIX_DEL].ob_flags & SELECTABLE )
		{
			DialogTree[SUFFIX_DEL].ob_state |= DISABLED;
			DialogTree[SUFFIX_DEL].ob_flags &= ~SELECTABLE;
			DialogTree[SUFFIX_DEL_I].ob_state |= DISABLED;
			DialogTree[SUFFIX_DEL_I].ob_flags &= ~TOUCHEXIT;
			DoRedraw( Dialog, &Rect, SUFFIX_DEL, Global );
		}
		if( ExistSuffixItem( DialogTree[SUFFIX_EXT].ob_spec.tedinfo->te_ptext ))
		{
			if( DialogTree[SUFFIX_ADD].ob_flags & SELECTABLE )
			{
				DialogTree[SUFFIX_ADD].ob_state |= DISABLED;
				DialogTree[SUFFIX_ADD].ob_flags &= ~SELECTABLE;
				DialogTree[SUFFIX_ADD_I].ob_state |= DISABLED;
				DialogTree[SUFFIX_ADD_I].ob_flags &= ~TOUCHEXIT;
				DoRedraw( Dialog, &Rect, SUFFIX_ADD, Global );
			}
		}
		else
		{
			if( DialogTree[SUFFIX_ADD].ob_state & DISABLED )
			{
				DialogTree[SUFFIX_ADD].ob_state &= ~DISABLED;
				DialogTree[SUFFIX_ADD].ob_flags |= SELECTABLE;
				DialogTree[SUFFIX_ADD_I].ob_state &= ~DISABLED;
				DialogTree[SUFFIX_ADD_I].ob_flags |= TOUCHEXIT;
				DoRedraw( Dialog, &Rect, SUFFIX_ADD, Global );
			}
		}
	}
	MT_wdlg_set_edit( Dialog, 0, Global );
	MT_wdlg_set_edit( Dialog, SUFFIX_EXT, Global );
}

void	SortSuffixItem( SUFFIX_ITEM *ItemList )
{
	SUFFIX_ITEM	*Item, *CmpItem;
	BYTE		*Str, *CmpStr, *TmpStr;
	WORD		TmpMode, TmpSelected;

	Item = ItemList;
	while( Item )
	{
		CmpItem = Item->next;
		while( CmpItem )
		{
			Str = Item->str;
			CmpStr = CmpItem->str;
			while( !( *Str == ' ' && *( Str + 1) == ' ' ) &&
			       !( *CmpStr == ' ' && *( CmpStr + 1) == ' ' ))
			{
				if( *Str > *CmpStr )
				{
					TmpStr = Item->str;
					TmpMode = Item->mode;
					TmpSelected = Item->selected;
					Item->str = CmpItem->str;
					Item->mode = CmpItem->mode;
					Item->selected = CmpItem->selected;
					CmpItem->str = TmpStr;
					CmpItem->mode = TmpMode;
					CmpItem->selected = TmpSelected;
					break;
				}
				if( *Str < *CmpStr )
					break;

				Str++;
				CmpStr++;
			}
			CmpItem = CmpItem->next;
		}
		Item = Item->next;
	}
}

WORD	ExistSuffixItem( BYTE *Ext )
{
	SUFFIX_ITEM	*Item = SuffixItem;
	while( Item )
	{
		if( strcmp( Item->str, Ext ) == 0 )
			return( 1 );
		Item = Item->next;
	}
	return( 0 );
}

WORD	Suf2SuffixItem( SUFFIX_ITEM	**SuffixItem )
{
	WORD			MaxLen = 0;
	SUF_ITEM		*SufItem = SuffixList;
	SUFFIX_ITEM	*Tmp;
	
	*SuffixItem = NULL;
	
	while( SufItem )
	{
		Tmp = malloc( sizeof( SUFFIX_ITEM ));
		if( !Tmp )
			return( ENSMEM );
		Tmp->str = strdup( SufItem->str );
		if( !Tmp->str )
			return( ENSMEM );
		if( strlen( Tmp->str ) > MaxLen )
			MaxLen = ( WORD ) strlen( Tmp->str );
		Tmp->mode = SufItem->mode;
		Tmp->selected = 0;
		Tmp->next = *SuffixItem;
		*SuffixItem = Tmp;
		SufItem = SufItem->next;
	}	
	return( MaxLen );
}

WORD	Suffix2Suf( SUFFIX_ITEM *SuffixItem )
{
	SUF_ITEM	*Tmp;
	SUFFIX_ITEM	*Item = SuffixItem;
	while( SuffixList )
	{
		Tmp = SuffixList;
		SuffixList = Tmp->next;
		if( Tmp->str );
			free( Tmp->str );
		free( Tmp );
	}
	while( Item )
	{
		Tmp = malloc( sizeof( SUF_ITEM ));
		if( !Tmp )
			return( ENSMEM );
		Tmp->str = strdup( Item->str );
		if( !Tmp->str )
			return( ENSMEM );
		Tmp->mode = Item->mode;
		Tmp->next = SuffixList;
		SuffixList = Tmp;
		Item = Item->next;
	}
	return( E_OK );
}