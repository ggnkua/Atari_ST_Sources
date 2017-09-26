#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<TOS.H>
#include	<MT_AES.H>
#include <STDDEF.H>
#include	<STDLIB.H>
#include	<STDIO.H>
#include	<STRING.H>

#include	<atarierr.h>

#include	"..\main.h"
#include	RSCHEADER
#include	"..\IConnect.h"
#include	"..\Menu.h"
#include	"..\Window.h"
#include	"..\WDialog.h"

#include	"IConnect.h"

#include	"..\MapKey.h"

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
static WORD	cdecl	HandleDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD );
static WORD	ClsDialog( void *DialogData, WORD Global[15] );

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern WORD	Global[15];
extern OBJECT	**TreeAddr;

/*-----------------------------------------------------------------------------*/
/* Lokale Variablen                                                            */
/*-----------------------------------------------------------------------------*/
static DIALOG_DATA	Dialog =
{
	NULL,
	NULL,
	ICON,
	NULL,
	ClsDialog,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL
};

void	OpenIConnectDialog( WORD Global[15] )
{
	if( !Dialog.Dialog )
	{
		Dialog.Tree = TreeAddr[ICON];
		OpenDialog( TreeAddr[TITLES][TITLE_ICON].ob_spec.free_string, WIN_WDIALOG, HandleDialog, &Dialog, Global );
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
				DialogTree[ICON_OK].ob_state &= ~SELECTED;
				DialogTree[ICON_CANCEL].ob_state &= ~SELECTED;
				break;
			}
			case	HNDL_CLSD:
				return( 0 );
			case	HNDL_EDIT:
			{
				break;
			}
		}
	}
	else
	{
		Obj &= 0x7fff;
		switch( Obj )
		{
			case	ICON_OK:
			case	ICON_CANCEL:
				return( 0 );
		}
	}	
	return( 1 );
}

static WORD	ClsDialog( void *DialogData, WORD Global[15] )
{
	EVNT	Events;
	Events.mwhich = MU_MESAG;
	Events.msg[0] = ICONNECT_ACK;
	Events.msg[1] = Global[2];
	Events.msg[2] = 0;
	Events.msg[3] = -1;
	if( TreeAddr[ICON][ICON_OK].ob_state & SELECTED )
		Events.msg[4] = E_OK;
	else	if( TreeAddr[ICON][ICON_CANCEL].ob_state & SELECTED )
		Events.msg[4] = ERROR;
	else
		Events.msg[4] = -2;
	HandleIConnect( &Events, Global );
	return( E_OK );
}

void	CloseIConnectDialog( WORD Global[15] )
{
	if( Dialog.Dialog )
		CloseDialog( &Dialog, Global );
}