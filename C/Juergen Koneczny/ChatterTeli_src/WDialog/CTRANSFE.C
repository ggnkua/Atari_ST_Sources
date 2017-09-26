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
#include	"..\Fsel.h"
#include	"..\Help.h"
#include	"..\Menu.h"
#include	"..\Window.h"
#include	"..\WDialog.h"

#include	"CGeneral.h"

#include	"..\EdScroll.h"
#include	"..\MapKey.h"

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
static WORD	cdecl	HandleDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD );

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern WORD	Global[15];
extern OBJECT	**TreeAddr;
extern WORD	isScroll;

/*-----------------------------------------------------------------------------*/
/* Globale Variablen                                                           */
/*-----------------------------------------------------------------------------*/
BYTE	*RxPath = NULL, *RxPara = NULL, *TxPath = NULL, *TxPara = NULL;

/*-----------------------------------------------------------------------------*/
/* Lokale Variablen                                                            */
/*-----------------------------------------------------------------------------*/
static DIALOG_DATA	Dialog =
{
	NULL,
	NULL,
	CTRANSFER,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL
};

static XTED	RxXted;
static BYTE	RxTmplt[EDITLEN+1], RxTxt[EDITLEN+1];
static XTED	RxDataXted;
static BYTE	RxDataTmplt[EDITLEN+1], RxDataTxt[EDITLEN+1];
static XTED	TxXted;
static BYTE	TxTmplt[EDITLEN+1], TxTxt[EDITLEN+1];
static XTED	TxDataXted;
static BYTE	TxDataTmplt[EDITLEN+1], TxDataTxt[EDITLEN+1];


void OpenCTransferDialog( WORD Global[15] )
{
	if( !Dialog.Dialog )
	{
		if( TreeAddr[CTRANSFER][CTRANSFER_RX].ob_spec.tedinfo->te_txtlen < EDITLEN + 1 )
			InitScrlted( &TreeAddr[CTRANSFER][CTRANSFER_RX], isScroll, &RxXted, RxTxt, RxTmplt, EDITLEN );
		if( TreeAddr[CTRANSFER][CTRANSFER_RX_DATA].ob_spec.tedinfo->te_txtlen < EDITLEN + 1 )
			InitScrlted( &TreeAddr[CTRANSFER][CTRANSFER_RX_DATA], isScroll, &RxDataXted, RxDataTxt, RxDataTmplt, EDITLEN );
		if( TreeAddr[CTRANSFER][CTRANSFER_TX].ob_spec.tedinfo->te_txtlen < EDITLEN + 1 )
			InitScrlted( &TreeAddr[CTRANSFER][CTRANSFER_TX], isScroll, &TxXted, TxTxt, TxTmplt, EDITLEN );
		if( TreeAddr[CTRANSFER][CTRANSFER_TX_DATA].ob_spec.tedinfo->te_txtlen < EDITLEN + 1 )
			InitScrlted( &TreeAddr[CTRANSFER][CTRANSFER_TX_DATA], isScroll, &TxDataXted, TxDataTxt, TxDataTmplt, EDITLEN );
		Dialog.Tree = TreeAddr[CTRANSFER];
		OpenDialog( TreeAddr[TITLES][TITLE_CTRANSFER].ob_spec.free_string, WIN_WDIALOG, HandleDialog, &Dialog, Global );
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
				DialogTree[CTRANSFER_OK].ob_state &= ~SELECTED;
				DialogTree[CTRANSFER_CANCEL].ob_state &= ~SELECTED;
				strcpy( DialogTree[CTRANSFER_RX].ob_spec.tedinfo->te_ptext, RxPath == NULL ? "" : RxPath );
				strcpy( DialogTree[CTRANSFER_TX].ob_spec.tedinfo->te_ptext, TxPath == NULL ? "" : TxPath );
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
		if( DialogTree[Obj].ob_type & 0x0100 )
		{
			StGuide_Action( DialogTree, CGENERAL, Global );
			return( 1 );
		}

		switch( Obj )
		{
			case	CTRANSFER_CANCEL:
				return( 0 );
			case	CTRANSFER_OK:
				if( RxPath )
				{
					free( RxPath );
					RxPath = NULL;
				}
				if( strlen( DialogTree[CTRANSFER_RX].ob_spec.tedinfo->te_ptext ))
					RxPath = strdup( DialogTree[CTRANSFER_RX].ob_spec.tedinfo->te_ptext );
				if( TxPath )
				{
					free( TxPath );
					TxPath = NULL;
				}
				if( strlen( DialogTree[CTRANSFER_TX].ob_spec.tedinfo->te_ptext ))
					TxPath = strdup( DialogTree[CTRANSFER_TX].ob_spec.tedinfo->te_ptext );
				return( 0 );
			case	CTRANSFER_RX:
			case	CTRANSFER_RX_TEXT:
				if( Clicks == 2 )
				{
					BYTE	*Path = Fsel( DialogTree[CTRANSFER_RX].ob_spec.tedinfo->te_ptext, "*", TreeAddr[TITLES][FSEL_RX].ob_spec.free_string, Global );
					if( Path )
					{
						strcpy( DialogTree[CTRANSFER_RX].ob_spec.tedinfo->te_ptext, Path );
						free( Path );
						DoRedraw( Dialog, &Rect, CTRANSFER_RX, Global );
					}
				}
				MT_wdlg_set_edit( Dialog, CTRANSFER_RX, Global );
				break;
			case	CTRANSFER_RX_DATA_TEXT:
				MT_wdlg_set_edit( Dialog, CTRANSFER_RX_DATA, Global );
				break;
			case	CTRANSFER_TX:
			case	CTRANSFER_TX_TEXT:
				if( Clicks == 2 )
				{
					BYTE	*Path = Fsel( DialogTree[CTRANSFER_TX].ob_spec.tedinfo->te_ptext, "*", TreeAddr[TITLES][FSEL_RX].ob_spec.free_string, Global );
					if( Path )
					{
						strcpy( DialogTree[CTRANSFER_TX].ob_spec.tedinfo->te_ptext, Path );
						free( Path );
						DoRedraw( Dialog, &Rect, CTRANSFER_TX, Global );
					}
				}
				MT_wdlg_set_edit( Dialog, CTRANSFER_TX, Global );
				break;
			case	CTRANSFER_TX_DATA_TEXT:
				MT_wdlg_set_edit( Dialog, CTRANSFER_TX_DATA, Global );
				break;
		}
	}
	return( 1 );
}
