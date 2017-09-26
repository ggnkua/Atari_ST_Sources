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
#include	"..\IConnect.h"
#include	"..\Help.h"
#include	"..\Menu.h"
#include	"..\Telnet.h"
#include	"..\Window.h"
#include	"..\WDialog.h"

#include	"CIc.h"

#include	"..\MapKey.h"

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
static WORD	cdecl	HandleDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD );
static void HandleIConnectButtons( DIALOG *Dialog, OBJECT *DialogTree, GRECT *Rect );

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern WORD	Global[15];
extern OBJECT	**TreeAddr;
extern WORD	IConnectFlag;

/*-----------------------------------------------------------------------------*/
/* Lokale Variablen                                                            */
/*-----------------------------------------------------------------------------*/
static DIALOG_DATA	Dialog =
{
	NULL,
	NULL,
	CIC,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL
};

void OpenCIcDialog( WORD Global[15] )
{
	if( !Dialog.Dialog )
	{
		Dialog.Tree = TreeAddr[CIC];
		OpenDialog( TreeAddr[TITLES][TITLE_CIC].ob_spec.free_string, WIN_WDIALOG, HandleDialog, &Dialog, Global );
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
				if( IConnectFlag & ICONNECT_START )
					DialogTree[CIC_ICONNECT_START].ob_state |= SELECTED;
				else
					DialogTree[CIC_ICONNECT_START].ob_state &= ~SELECTED;
				if( IConnectFlag & ICONNECT_CONNECT )
					DialogTree[CIC_ICONNECT_CONNECT].ob_state |= SELECTED;
				else
					DialogTree[CIC_ICONNECT_CONNECT].ob_state &= ~SELECTED;
				if( IConnectFlag & ICONNECT_DISCONNECT )
					DialogTree[CIC_ICONNECT_DISCONNECT].ob_state |= SELECTED;
				else
					DialogTree[CIC_ICONNECT_DISCONNECT].ob_state &= ~SELECTED;
				if( IConnectFlag & ICONNECT_LAST )
				{
					DialogTree[CIC_ICONNECT_LAST].ob_state |= SELECTED;
					DialogTree[CIC_ICONNECT_QUIT].ob_state &= ~SELECTED;
				}
				else
				{
					DialogTree[CIC_ICONNECT_QUIT].ob_state |= SELECTED;
					DialogTree[CIC_ICONNECT_LAST].ob_state &= ~SELECTED;
				}
				DialogTree[CIC_OK].ob_state &= ~SELECTED;
				DialogTree[CIC_CANCEL].ob_state &= ~SELECTED;
				break;
			}
			case	HNDL_OPEN:
				HandleIConnectButtons( Dialog, DialogTree, &Rect );
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
	
		if( DialogTree[Obj].ob_type & 0x0100 )
		{
			StGuide_Action( DialogTree, CIC, Global );
			return( 1 );
		}

		switch( Obj )
		{
			case	CIC_ICONNECT_START:
			case	CIC_ICONNECT_CONNECT:
			case	CIC_ICONNECT_DISCONNECT:
				HandleIConnectButtons( Dialog, DialogTree, &Rect );
				break;
			case	CIC_OK:
			{
				if( DialogTree[CIC_ICONNECT_START].ob_state & SELECTED )
					IConnectFlag |= ICONNECT_START;
				else
					IConnectFlag &= ~ICONNECT_START;
				if( DialogTree[CIC_ICONNECT_CONNECT].ob_state & SELECTED )
					IConnectFlag |= ICONNECT_CONNECT;
				else
					IConnectFlag &= ~ICONNECT_CONNECT;
				if( DialogTree[CIC_ICONNECT_DISCONNECT].ob_state & SELECTED )
					IConnectFlag |= ICONNECT_DISCONNECT;
				else
					IConnectFlag &= ~ICONNECT_DISCONNECT;
				if( DialogTree[CIC_ICONNECT_LAST].ob_state & SELECTED )
					IConnectFlag |= ICONNECT_LAST;
				else
					IConnectFlag &= ~ICONNECT_LAST;
				return( 0 );
			}
			case	CIC_CANCEL:
				return( 0 );
		}
	}
	return( 1 );
}

static void HandleIConnectButtons( DIALOG *Dialog, OBJECT *DialogTree, GRECT *Rect )
{
	if(( DialogTree[CIC_ICONNECT_START].ob_state & SELECTED ) &&
		!( DialogTree[CIC_ICONNECT_DISCONNECT].ob_flags & SELECTABLE ))
	{
		DialogTree[CIC_ICONNECT_CONNECT].ob_flags |= SELECTABLE;
		DialogTree[CIC_ICONNECT_CONNECT].ob_state &= ~DISABLED;
		DialogTree[CIC_ICONNECT_DISCONNECT].ob_flags |= SELECTABLE;
		DialogTree[CIC_ICONNECT_DISCONNECT].ob_state &= ~DISABLED;
		DoRedrawX( Dialog, Rect, Global, CIC_ICONNECT_CONNECT, CIC_ICONNECT_DISCONNECT, EDRX );
	}	
	if( !( DialogTree[CIC_ICONNECT_START].ob_state & SELECTED ) &&
		( DialogTree[CIC_ICONNECT_DISCONNECT].ob_flags & SELECTABLE ))
	{
		DialogTree[CIC_ICONNECT_CONNECT].ob_flags &= ~SELECTABLE;
		DialogTree[CIC_ICONNECT_CONNECT].ob_state |= DISABLED;
		DialogTree[CIC_ICONNECT_DISCONNECT].ob_flags &= ~SELECTABLE;
		DialogTree[CIC_ICONNECT_DISCONNECT].ob_state |= DISABLED;
		DoRedrawX( Dialog, Rect, Global, CIC_ICONNECT_CONNECT, CIC_ICONNECT_DISCONNECT, EDRX );
	}
	if((( DialogTree[CIC_ICONNECT_DISCONNECT].ob_state & SELECTED ) && ( DialogTree[CIC_ICONNECT_DISCONNECT].ob_flags & SELECTABLE )) &&
	   !( DialogTree[CIC_ICONNECT_LAST].ob_flags & SELECTABLE ))
	{
		DialogTree[CIC_ICONNECT_QUIT].ob_flags |= SELECTABLE;
		DialogTree[CIC_ICONNECT_QUIT].ob_state &= ~DISABLED;
		DialogTree[CIC_ICONNECT_LAST].ob_flags |= SELECTABLE;
		DialogTree[CIC_ICONNECT_LAST].ob_state &= ~DISABLED;
		DoRedrawX( Dialog, Rect, Global, CIC_ICONNECT_QUIT, CIC_ICONNECT_LAST, EDRX );
	}
	if(( !( DialogTree[CIC_ICONNECT_DISCONNECT].ob_state & SELECTED ) || !( DialogTree[CIC_ICONNECT_DISCONNECT].ob_flags & SELECTABLE )) &&
	   ( DialogTree[CIC_ICONNECT_LAST].ob_flags & SELECTABLE ))
	{
		DialogTree[CIC_ICONNECT_QUIT].ob_flags &= ~SELECTABLE;
		DialogTree[CIC_ICONNECT_QUIT].ob_state |= DISABLED;
		DialogTree[CIC_ICONNECT_LAST].ob_flags &= ~SELECTABLE;
		DialogTree[CIC_ICONNECT_LAST].ob_state |= DISABLED;
		DoRedrawX( Dialog, Rect, Global, CIC_ICONNECT_QUIT, CIC_ICONNECT_LAST, EDRX );
	}
}
