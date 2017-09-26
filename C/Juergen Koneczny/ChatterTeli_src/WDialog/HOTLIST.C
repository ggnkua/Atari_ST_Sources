#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<VDICOL.H>
#include	<MT_AES.H>
#include  <STDDEF.H>
#include	<STDLIB.H>
#include  <STDIO.H>
#include	<STRING.H>

#include	<atarierr.h>

#include	"..\main.h"
#include	RSCHEADER
#include	"..\DD.h"
#include	"..\Help.h"
#include	"..\Menu.h"
#ifdef	IRC_CLIENT
#include	"..\Irc.h"
#endif
#ifdef	TELNET_CLIENT
#include	"..\Telnet.h"
#endif
#include	"..\WDialog.h"
#include	"..\Window.h"

#include	"Hotlist.h"
#include	"ListBox.h"
#include	"Options.h"

#include	"..\EdScroll.h"
#include	"..\MapKey.h"

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
static WORD	cdecl	HandleDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD );
static void HndlSlctLBoxItem( LBOX_ITEM *Item, WORD LastState );

static WORD	HandleDdDialog( void *DialogData, EVNT *Events, WORD Global[15] );
static WORD	HandleClsDialog( void *DialogData, WORD Global[15] );
static WORD	HndlMesagDialog( void *DialogData, EVNT *Events, WORD Global[15] );
static WORD	HandleHelpDialog( void *DialogData, EVNT *Events, WORD Global[15] );

static HT_ITEM	*ExistHtItem( BYTE *Name, HT_ITEM *HtList );
static void	DelHtItem( HT_ITEM *Del, HT_ITEM **HtList );

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern WORD	Global[15];
extern WORD	PwChar, PhChar, PwBox, PhBox;
extern OBJECT	**TreeAddr;
extern WORD	isScroll;
#ifdef	IRC_CLIENT
extern IRC	DefaultIrc;
#endif
#ifdef	TELNET_CLIENT
extern TELNET	DefaultTelnet;
#endif

/*-----------------------------------------------------------------------------*/
/* Globale Variablen                                                           */
/*-----------------------------------------------------------------------------*/
HT_ITEM	*HtList = NULL;
OBJECT	*HtPopup = NULL;

/*-----------------------------------------------------------------------------*/
/* Lokale Variablen                                                            */
/*-----------------------------------------------------------------------------*/
static DIALOG_DATA	Dialog =
{
	NULL,
	NULL,
	HOTLIST,
	HandleDdDialog,
	HandleClsDialog,
	HndlMesagDialog,
	NULL,
	HandleHelpDialog,
	NULL,
	NULL,
	NULL
};

static LBOX_DATA	ListBox =
{
	HndlSlctLBoxItem,
	NULL
};

static XTED	NameXted;
static BYTE	NameTmplt[EDITLEN+1], NameTxt[EDITLEN+1];

#ifdef	IRC_CLIENT
#define	NO_HOTLIST_ENTRY_V	18
#endif
#ifdef	TELNET_CLIENT
#define	NO_HOTLIST_ENTRY_V	16
#endif
#define	NO_HOTLIST_ENTRY_H	24
WORD	HotlistEntryCtrl[9] = { HOTLIST_ENTRY_BOX, HOTLIST_ENTRY_UP, HOTLIST_ENTRY_DOWN, HOTLIST_ENTRY_BACK_V, HOTLIST_ENTRY_SL_V, HOTLIST_ENTRY_LEFT, HOTLIST_ENTRY_RIGHT, HOTLIST_ENTRY_BACK_H, HOTLIST_ENTRY_SL_H };
#ifdef	IRC_CLIENT
WORD	HotlistEntryObjs[NO_HOTLIST_ENTRY_V] = { HOTLIST_ENTRY_0, HOTLIST_ENTRY_1, HOTLIST_ENTRY_2, 
    	                               HOTLIST_ENTRY_3, HOTLIST_ENTRY_4, HOTLIST_ENTRY_5, 
    	                               HOTLIST_ENTRY_6, HOTLIST_ENTRY_7, HOTLIST_ENTRY_8,
    	                               HOTLIST_ENTRY_9, HOTLIST_ENTRY_10, HOTLIST_ENTRY_11,
    	                               HOTLIST_ENTRY_12, HOTLIST_ENTRY_13, HOTLIST_ENTRY_14,
    	                               HOTLIST_ENTRY_15, HOTLIST_ENTRY_16, HOTLIST_ENTRY_17 };
#endif
#ifdef	TELNET_CLIENT
WORD	HotlistEntryObjs[NO_HOTLIST_ENTRY_V] = { HOTLIST_ENTRY_0, HOTLIST_ENTRY_1, HOTLIST_ENTRY_2, 
    	                               HOTLIST_ENTRY_3, HOTLIST_ENTRY_4, HOTLIST_ENTRY_5, 
    	                               HOTLIST_ENTRY_6, HOTLIST_ENTRY_7, HOTLIST_ENTRY_8,
    	                               HOTLIST_ENTRY_9, HOTLIST_ENTRY_10, HOTLIST_ENTRY_11,
    	                               HOTLIST_ENTRY_12, HOTLIST_ENTRY_13, HOTLIST_ENTRY_14,
    	                               HOTLIST_ENTRY_15 };
#endif

static LIST_BOX	*LBox = NULL;

static OPT_DATA	OptData;

void OpenHotlistDialog( WORD Global[15] )
{
	if( !Dialog.Dialog )
	{
		if( TreeAddr[HOTLIST][HOTLIST_ENTRY_NAME].ob_spec.tedinfo->te_txtlen < EDITLEN + 1 )
			InitScrlted( &TreeAddr[HOTLIST][HOTLIST_ENTRY_NAME], isScroll, &NameXted, NameTxt, NameTmplt, EDITLEN );
		OptData.Tree = TreeAddr[HOTLIST];
		OptData.TreeIdx = HOTLIST;
		OptData.Obj = HOTLIST_OPTIONS;
		OptData.Button = HOTLIST_KAT;
#ifdef	IRC_CLIENT
		OptData.Kat = OPT_SESSION;
		Dialog.Tree = CreateOptions( &OptData, OPT_NO_ALL, &DefaultIrc );
#endif
#ifdef	TELNET_CLIENT
		OptData.Kat = OPT_TELNET;
		Dialog.Tree = CreateOptions( &OptData, OPT_NO_ALL, &DefaultTelnet );
#endif
		OpenDialog( TreeAddr[TITLES][TITLE_HOTLIST].ob_spec.free_string, WIN_WDIALOG, HandleDialog, &Dialog, Global );
	}
	else
		MT_wind_set( MT_wdlg_get_handle( Dialog.Dialog, Global ), WF_TOP, 0, 0, 0, 0, Global );
}

static WORD cdecl	HandleDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD )
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
				HT_ITEM	*Tmp = HtList;
				while( Tmp )
				{
					Tmp->selected = 0;
					Tmp = Tmp->next;
				}
				LBox = MT_lbox_create( DialogTree, SlctLBoxItem, SetLBoxItem, (LBOX_ITEM *) HtList,
					NO_HOTLIST_ENTRY_V, 0, HotlistEntryCtrl, HotlistEntryObjs, 
					LBOX_VERT + LBOX_AUTO + LBOX_AUTOSLCT + LBOX_REAL + LBOX_2SLDRS + LBOX_SNGL, 
					40, &ListBox, Dialog, NO_HOTLIST_ENTRY_H, 0, GetMaxLenHtItem( HtList ) + 2, 40, Global );

				DialogTree[HOTLIST_DEL_I].ob_state |= DISABLED;
				DialogTree[HOTLIST_DEL].ob_state |= DISABLED;
				DialogTree[HOTLIST_DEL].ob_flags &= ~SELECTABLE;
				strcpy( DialogTree[HOTLIST_ENTRY_NAME].ob_spec.tedinfo->te_ptext, "" );
				break;
			}
			case	HNDL_OPEN:
				HandleOptions( Dialog, &OptData, Obj, Events, 0, Global );
				break;

			case	HNDL_CLSD:
				return( 0 );
			case	HNDL_EDIT:
			{
				WORD	i = HandleOptions( Dialog, &OptData, Obj, Events, *( WORD * ) UD, Global );
				if( i == 0 && Obj == HNDL_EDIT )
					return( 0 );
				break;
			}
			case	HNDL_EDDN:
			{
				WORD	Cursor;
				if( MT_wdlg_get_edit( Dialog, &Cursor, Global ) == HOTLIST_ENTRY_NAME )
				{
					BYTE	*Str;
					HT_ITEM	*Item = HtList;
					if( strlen( DialogTree[HOTLIST_ENTRY_NAME].ob_spec.tedinfo->te_ptext ))
						Str = DialogTree[HOTLIST_ENTRY_NAME].ob_spec.tedinfo->te_ptext;
					if( strlen( Str ))
					{
						while( Item )
						{
							if( strncmp( Item->Name, Str, strlen( Str )) == 0 )
							{
								HT_ITEM *Tmp = ( HT_ITEM * ) MT_lbox_get_slct_item( LBox, Global );
								if( Tmp != Item )
								{
									if( Tmp )
										Tmp->selected = 0;
									Item->selected = 1;
									MT_lbox_set_asldr( LBox, MT_lbox_get_slct_idx( LBox, Global ), &Rect, Global );
									MT_lbox_update( LBox, &Rect, Global );
						
									if( Tmp )
										break;
#ifdef	IRC_CLIENT
									NewOptions( Dialog, &OptData, Item->Irc, Global );
#endif
#ifdef	TELNET_CLIENT
									NewOptions( Dialog, &OptData, Item->Telnet, Global );
#endif
									if( DialogTree[HOTLIST_DEL].ob_state & DISABLED )
									{
										DialogTree[HOTLIST_DEL_I].ob_state &= ~DISABLED;
										DialogTree[HOTLIST_DEL].ob_state &= ~DISABLED;
										DialogTree[HOTLIST_DEL].ob_flags |= SELECTABLE;
										DoRedraw( Dialog, &Rect, HOTLIST_DEL, Global );
									}
								}
								break;
							}
							Item = Item->next;
						}
					}
				}
			}
			case	HNDL_EDCH:
			{
				WORD	i = HandleOptions( Dialog, &OptData, Obj, Events, *( WORD * ) UD, Global );
				HT_ITEM	*Flag1, *Flag2;
				if( strlen( DialogTree[HOTLIST_ENTRY_NAME].ob_spec.tedinfo->te_ptext ))
					Flag1 = ExistHtItem( DialogTree[HOTLIST_ENTRY_NAME].ob_spec.tedinfo->te_ptext, HtList );
				else
					Flag1 = ( HT_ITEM * ) 4L;
				Flag2 = ( HT_ITEM * ) MT_lbox_get_slct_item( LBox, Global );
				if( i > 0 && !Flag1 && ( DialogTree[HOTLIST_ADD].ob_state & DISABLED ))
				{
					DialogTree[HOTLIST_ADD_I].ob_state &= ~DISABLED;
					DialogTree[HOTLIST_ADD].ob_state &= ~DISABLED;
					DialogTree[HOTLIST_ADD].ob_flags |= SELECTABLE;
					DoRedraw( Dialog, &Rect, HOTLIST_ADD, Global );
				}
				else	if(( i < 0 || Flag1 ) && !( DialogTree[HOTLIST_ADD].ob_state & DISABLED ))
				{
					DialogTree[HOTLIST_ADD_I].ob_state |= DISABLED;
					DialogTree[HOTLIST_ADD].ob_state |= DISABLED;
					DialogTree[HOTLIST_ADD].ob_flags &= ~SELECTABLE;
					DoRedraw( Dialog, &Rect, HOTLIST_ADD, Global );
				}
				
				if( i > 0 && Flag2 && ( DialogTree[HOTLIST_CHANGE].ob_state & DISABLED ))
				{
					DialogTree[HOTLIST_CHANGE_I].ob_state &= ~DISABLED;
					DialogTree[HOTLIST_CHANGE].ob_state &= ~DISABLED;
					DialogTree[HOTLIST_CHANGE].ob_flags |= SELECTABLE;
					DoRedraw( Dialog, &Rect, HOTLIST_CHANGE, Global );
				}
				else	if(( i < 0 || !Flag2 ) && !( DialogTree[HOTLIST_CHANGE].ob_state & DISABLED ))
				{
					DialogTree[HOTLIST_CHANGE_I].ob_state |= DISABLED;
					DialogTree[HOTLIST_CHANGE].ob_state |= DISABLED;
					DialogTree[HOTLIST_CHANGE].ob_flags &= ~SELECTABLE;
					DoRedraw( Dialog, &Rect, HOTLIST_CHANGE, Global );
				}
				break;
			}
		}
	}
	else
	{
		if( Clicks == 2 )
			Obj |= 0x8000;

		if( MT_lbox_do( LBox, Obj, Global ) == -1 )
		{
#ifdef	IRC_CLIENT
			IRC	*Irc = malloc( sizeof( IRC ));
			if( !Irc )
				return( 0 );
			GetOptions( &OptData, Irc );
			OpenIrc( Irc, Global );
#endif
#ifdef	TELNET_CLIENT
			TELNET	*Telnet = malloc( sizeof( TELNET ));
			if( !Telnet )
				return( 0 );
			GetOptions( &OptData, Telnet );
			OpenTelnet( Telnet, Global );
#endif
		}

		if( MT_lbox_get_slct_item( LBox, Global ))
		{
			if( DialogTree[HOTLIST_DEL].ob_state & DISABLED )
			{
				DialogTree[HOTLIST_DEL_I].ob_state &= ~DISABLED;
				DialogTree[HOTLIST_DEL].ob_state &= ~DISABLED;
				DialogTree[HOTLIST_DEL].ob_flags |= SELECTABLE;
				DoRedraw( Dialog, &Rect, HOTLIST_DEL, Global );
			}
		}
		else
		{
			if( !( DialogTree[HOTLIST_DEL].ob_state & DISABLED ))
			{
				DialogTree[HOTLIST_DEL_I].ob_state |= DISABLED;
				DialogTree[HOTLIST_DEL].ob_state |= DISABLED;
				DialogTree[HOTLIST_DEL].ob_flags &= ~SELECTABLE;
				DoRedraw( Dialog, &Rect, HOTLIST_DEL, Global );
			}
		}

		
		Obj &= 0x7fff;
		if( HandleWDialogIcon( &Obj, Dialog, Global ))
			return( 1 );

		if( DialogTree[Obj].ob_state & DISABLED )
		{
			DialogTree[Obj].ob_state &= ~SELECTED;
			return( 1 );
		}
		if( DialogTree[Obj].ob_type & 0x0100 )
		{
			StGuide_Action( DialogTree, HOTLIST, Global );
			return( 1 );
		}

		if( Obj == HOTLIST_KAT_TEXT )
			Obj = HOTLIST_KAT;
		switch( Obj )
		{
			case	HOTLIST_ENTRY_NAME_TEXT:
				MT_wdlg_set_edit( Dialog, HOTLIST_ENTRY_NAME, Global );
				break;

			case	HOTLIST_ADD:
			case	HOTLIST_CHANGE:
			{
				WORD		i, j;
				HT_ITEM	*New = malloc( sizeof( HT_ITEM ));
				if( !New )
					return( 0 );
#ifdef	IRC_CLIENT
				New->Irc = malloc( sizeof( IRC ));
				GetOptions( &OptData, New->Irc );
#endif
#ifdef	TELNET_CLIENT
				New->Telnet = malloc( sizeof( TELNET ));
				GetOptions( &OptData, New->Telnet );
#endif
				New->Name = strdup( DialogTree[HOTLIST_ENTRY_NAME].ob_spec.tedinfo->te_ptext );
				New->selected = 1;

				if( Obj == HOTLIST_CHANGE )
					DelHtItem(( HT_ITEM * ) MT_lbox_get_slct_item( LBox, Global ), &HtList );
				else
				{
					HT_ITEM	*Tmp = ( HT_ITEM * ) MT_lbox_get_slct_item( LBox, Global );
					if( Tmp )
						Tmp->selected = 0;
				}

				InsertHtItem( New, &HtList );
				UpdateHotlistPopup( HtList, &HtPopup );

				MT_lbox_set_items( LBox, ( LBOX_ITEM * ) HtList, Global );
				MT_lbox_set_bentries( LBox, GetMaxLenHtItem( HtList ) + 2, Global );
				MT_lbox_set_bsldr( LBox, MT_lbox_get_bfirst( LBox, Global ), &Rect, Global );
				DoRedraw( Dialog, &Rect, HOTLIST_ENTRY_BACK_H, Global );
				i = MT_lbox_get_slct_idx( LBox, Global );
				j = MT_lbox_get_afirst( LBox, Global );
				if( j > i || j + NO_HOTLIST_ENTRY_V < i )
					MT_lbox_set_asldr( LBox, i, &Rect, Global );
				else
					MT_lbox_set_asldr( LBox, j, &Rect, Global );
				MT_lbox_update( LBox, &Rect, Global );

				DialogTree[HOTLIST_ADD].ob_state &= ~SELECTED;
				DialogTree[HOTLIST_ADD].ob_state |= DISABLED;
				DialogTree[HOTLIST_ADD_I].ob_state |= DISABLED;
				DialogTree[HOTLIST_ADD].ob_flags &= ~SELECTABLE;
				DialogTree[HOTLIST_ADD_I].ob_flags &= ~SELECTABLE;
				DoRedraw( Dialog, &Rect, HOTLIST_ADD, Global );
				if( Obj == HOTLIST_ADD )
				{
					if( DialogTree[HOTLIST_CHANGE].ob_state & DISABLED )
					{
						DialogTree[HOTLIST_CHANGE_I].ob_state &= ~DISABLED;
						DialogTree[HOTLIST_CHANGE].ob_state &= ~DISABLED;
						DialogTree[HOTLIST_CHANGE].ob_flags |= SELECTABLE;
						DoRedraw( Dialog, &Rect, HOTLIST_CHANGE, Global );
					}
					if( DialogTree[HOTLIST_DEL].ob_state & DISABLED )
					{
						DialogTree[HOTLIST_DEL_I].ob_state &= ~DISABLED;
						DialogTree[HOTLIST_DEL].ob_state &= ~DISABLED;
						DialogTree[HOTLIST_DEL].ob_flags |= SELECTABLE;
						DoRedraw( Dialog, &Rect, HOTLIST_DEL, Global );
					}
				}

				if( Obj == HOTLIST_CHANGE )
				{
					DialogTree[HOTLIST_CHANGE].ob_state &= ~SELECTED;
					DoRedraw( Dialog, &Rect, HOTLIST_CHANGE, Global );
				}
				break;
			}
			case	HOTLIST_DEL:
			{
				WORD		Edit, Cursor;
				Edit = MT_wdlg_get_edit( Dialog, &Cursor, Global );
				MT_wdlg_set_edit( Dialog, 0, Global );
				DelHtItem(( HT_ITEM * ) MT_lbox_get_slct_item( LBox, Global ), &HtList );
				UpdateHotlistPopup( HtList, &HtPopup );

				MT_lbox_set_items( LBox, ( LBOX_ITEM * ) HtList, Global );
				MT_lbox_set_bentries( LBox, GetMaxLenHtItem( HtList ) + 2, Global );
				MT_lbox_set_bsldr( LBox, MT_lbox_get_bfirst( LBox, Global ), &Rect, Global );
				DoRedraw( Dialog, &Rect, HOTLIST_ENTRY_BACK_H, Global );
				MT_lbox_update( LBox, &Rect, Global );

#ifdef	IRC_CLIENT
				NewOptions( Dialog, &OptData, &DefaultIrc, Global );
#endif
#ifdef	TELNET_CLIENT
				NewOptions( Dialog, &OptData, &DefaultTelnet, Global );
#endif
				strcpy( DialogTree[HOTLIST_ENTRY_NAME].ob_spec.tedinfo->te_ptext, "" );
				DoRedraw( Dialog, &Rect, HOTLIST_ENTRY_NAME, Global );

				DialogTree[HOTLIST_CHANGE_I].ob_state |= DISABLED;
				DialogTree[HOTLIST_CHANGE].ob_state |= DISABLED;
				DialogTree[HOTLIST_CHANGE].ob_flags &= ~SELECTABLE;
				DialogTree[HOTLIST_DEL].ob_state &= ~SELECTED;
				DialogTree[HOTLIST_DEL_I].ob_state |= DISABLED;
				DialogTree[HOTLIST_DEL].ob_state |= DISABLED;
				DialogTree[HOTLIST_DEL].ob_flags &= ~SELECTABLE;
				DoRedrawX( Dialog, &Rect, Global, HOTLIST_CHANGE, HOTLIST_DEL, EDRX );
				MT_wdlg_set_edit( Dialog, Edit, Global );
				break;
			}
			default:
				HandleOptions( Dialog, &OptData, Obj, Events, 0, Global );
		}
	}
	return( 1 );
}
static void HndlSlctLBoxItem( LBOX_ITEM *Item, WORD LastState )
{
	HT_ITEM	*HtItem = ( HT_ITEM * ) Item;
	if( LastState == 0 )
	{
		OBJECT	*DialogTree;
		GRECT		Rect;
		WORD		Edit, Cursor;
		MT_wdlg_get_tree( Dialog.Dialog, &DialogTree, &Rect, Global );
		Edit = MT_wdlg_get_edit( Dialog.Dialog, &Cursor, Global );
		MT_wdlg_set_edit( Dialog.Dialog, 0, Global );
#ifdef	IRC_CLIENT
		NewOptions( Dialog.Dialog, &OptData, HtItem->Irc, Global );
#endif
#ifdef	TELNET_CLIENT
		NewOptions( Dialog.Dialog, &OptData, HtItem->Telnet, Global );
#endif
		strcpy( DialogTree[HOTLIST_ENTRY_NAME].ob_spec.tedinfo->te_ptext, HtItem->Name );
		DoRedraw( Dialog.Dialog, &Rect, HOTLIST_ENTRY_NAME, Global );
		if( !( DialogTree[HOTLIST_ADD].ob_state & DISABLED ))
		{
			DialogTree[HOTLIST_ADD_I].ob_state |= DISABLED;
			DialogTree[HOTLIST_ADD].ob_state |= DISABLED;
			DialogTree[HOTLIST_ADD].ob_flags &= ~SELECTABLE;
			DoRedraw( Dialog.Dialog, &Rect, HOTLIST_ADD, Global );
		}
		if( DialogTree[HOTLIST_CHANGE].ob_state & DISABLED )
		{
			DialogTree[HOTLIST_CHANGE_I].ob_state &= ~DISABLED;
			DialogTree[HOTLIST_CHANGE].ob_state &= ~DISABLED;
			DialogTree[HOTLIST_CHANGE].ob_flags |= SELECTABLE;
			DoRedraw( Dialog.Dialog, &Rect, HOTLIST_CHANGE, Global );
		}
		if( DialogTree[HOTLIST_DEL].ob_state & DISABLED )
		{
			DialogTree[HOTLIST_DEL_I].ob_state &= ~DISABLED;
			DialogTree[HOTLIST_DEL].ob_state &= ~DISABLED;
			DialogTree[HOTLIST_DEL].ob_flags |= SELECTABLE;
			DoRedraw( Dialog.Dialog, &Rect, HOTLIST_DEL, Global );
		}
		MT_wdlg_set_edit( Dialog.Dialog, Edit, Global );
	}
}

static WORD	HandleDdDialog( void *DialogData, EVNT *Events, WORD Global[15] )
{
	return( HandleDdOptions((( DIALOG_DATA * ) DialogData )->Dialog, &OptData, Events, Global ));
}

static WORD	HandleClsDialog( void *DialogData, WORD Global[15] )
{
	MT_lbox_delete( LBox, Global );
	DelOptions( &OptData );
	return( E_OK );
}

static WORD		HndlMesagDialog( void *DialogData, EVNT *Events, WORD Global[15] )
{
	return( HandleMesagOptions((( DIALOG_DATA * ) DialogData )->Dialog, &OptData, Events, Global ));
}
static WORD		HandleHelpDialog( void *DialogData, EVNT *Events, WORD Global[15] )
{
	return( HandleHelpOptions((( DIALOG_DATA * ) DialogData )->Dialog, &OptData, Events, Global ));
}


/*-----------------------------------------------------------------------------*/
/* Funktionen zur Verarbeitung der Hotlist                                     */
/*-----------------------------------------------------------------------------*/
void	InsertHtItem( HT_ITEM *New, HT_ITEM **HtList )
{
	New->prev = NULL;
	New->next = *HtList;
	if( *HtList )
		( *HtList )->prev = New;
	*HtList = New;
	SortHtItem( *HtList );
}

static void	DelHtItem( HT_ITEM *Del, HT_ITEM **HtList )
{
	if( Del->prev )
		( Del->prev )->next = Del->next;
	else
		*HtList = Del->next;
	
	if( Del->next )
		( Del->next )->prev = Del->prev;
	
#ifdef	IRC_CLIENT
	FreeIrc( Del->Irc );
#endif
#ifdef	TELNET_CLIENT
	FreeTelnet( Del->Telnet );
#endif
	free( Del->Name );
	free( Del );
}

void	SortHtItem( HT_ITEM *HtList )
{
	HT_ITEM	*A = HtList, *B;
	BYTE		*StrA, *StrB;

	WORD		Selected;
	BYTE		*Name;
#ifdef	IRC_CLIENT
	IRC		*Irc;
#endif
#ifdef	TELNET_CLIENT
	TELNET	*Telnet;
#endif
	while( A )
	{
		B = A->next;
		while( B )
		{
			StrA = A->Name;
			StrB = B->Name;
			while( 1 )
			{
				if( *StrA > *StrB )
				{
					Selected = A->selected;
					Name = A->Name;
#ifdef	IRC_CLIENT
					Irc = A->Irc;
#endif
#ifdef	TELNET_CLIENT
					Telnet = A->Telnet;
#endif

					A->selected = B->selected;
					A->Name = B->Name;
#ifdef	IRC_CLIENT
					A->Irc = B->Irc;
#endif
#ifdef	TELNET_CLIENT
					A->Telnet = B->Telnet;
#endif
					
					B->selected = Selected;
					B->Name = Name;
#ifdef	IRC_CLIENT
					B->Irc = Irc;
#endif
#ifdef	TELNET_CLIENT
					B->Telnet = Telnet;
#endif
					break;
				}
				if( *StrA < *StrB )
					break;

				StrA++;
				StrB++;
			}
			B = B->next;			       
		}
		A = A->next;
	}
}

static HT_ITEM	*ExistHtItem( BYTE *Name, HT_ITEM *HtList )
{
	while( HtList )
	{
		if( strcmp( HtList->Name, Name ) == 0 )
			return( HtList );
		HtList = HtList->next;
	}
	return( NULL );
}

WORD	GetMaxLenHtItem( HT_ITEM *HtList )
{
	WORD	MaxLen = 0, i;
	HT_ITEM	*Tmp = HtList;
	while( Tmp )
	{
		if(( i = ( WORD ) strlen( Tmp->Name )) > MaxLen )
			MaxLen = i;
		Tmp = Tmp->next;
	}
	return( MaxLen );
}

/*-----------------------------------------------------------------------------*/
/* Funktionen zur Verwaltung des Hotlist-Popups                                */
/*-----------------------------------------------------------------------------*/
void	UpdateHotlistPopup( HT_ITEM *HtList, OBJECT **HtPopup )
{
	WORD	nEntry = 0, i, Len = GetMaxLenHtItem( HtList );
	HT_ITEM	*Tmp = HtList;
	OBJECT	*Popup;
	if( *HtPopup )
	{
		i = 0;
		Popup = *HtPopup;
		do
		{
			free( Popup[++i].ob_spec.free_string );
		}
		while( Popup[i].ob_next != 0 );
		free( Popup );
		*HtPopup = NULL;
	}

	while( Tmp )
	{
		nEntry++;
		Tmp = Tmp->next;
	}
	if( !nEntry )
		return;
	Popup = malloc( sizeof( OBJECT ) * ( nEntry + 1 ));
	if( !Popup )
		return;
	memcpy( Popup, TreeAddr[POPUP_HOTLIST], sizeof( OBJECT ));
	Popup[0].ob_next = -1;
	Popup[0].ob_head = 1;
	Popup[0].ob_tail = nEntry;
	Popup[0].ob_width =  ( Len + 3 ) * PwChar;
	Popup[0].ob_height = nEntry * PhChar;
	Tmp = HtList;
	for( i = 0; i < nEntry; i++ )
	{
		memcpy( &( Popup[i+1] ), &( TreeAddr[POPUP_HOTLIST][1] ), sizeof( OBJECT ));
		Popup[i+1].ob_next = i+2;
		Popup[i+1].ob_head = -1;
		Popup[i+1].ob_tail = -1;
		Popup[i+1].ob_y = i * PhChar;
		Popup[i+1].ob_width = ( Len + 3 ) * PwChar;
		Popup[i+1].ob_spec.free_string = malloc(( Len + 3 ) * sizeof( BYTE ) + 1 );
		if( !Popup[i+1].ob_spec.free_string )
			return;
		strcpy( Popup[i+1].ob_spec.free_string, "  " );
		strcat( Popup[i+1].ob_spec.free_string, Tmp->Name );
		Tmp = Tmp->next;
	}
	Popup[i].ob_next = 0;
	*HtPopup = Popup;
	InstallHtPopup();
}

#ifdef	IRC_CLIENT
IRC	*GetIrcHotlist( WORD n )
#endif
#ifdef	TELNET_CLIENT
TELNET	*GetTelnetHotlist( WORD n )
#endif
{
	HT_ITEM	*Tmp = HtList;
	WORD	i = 1;
	while( Tmp )
	{
		if( i++ == n )
#ifdef	IRC_CLIENT
			return( Tmp->Irc );
#endif
#ifdef	TELNET_CLIENT
			return( Tmp->Telnet );
#endif
		Tmp = Tmp->next;
	}
	return ( NULL );
}