#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<TOS.H>
#include	<VDICOL.H>
#include	<MT_AES.H>
#include  <STDDEF.H>
#include	<STDLIB.H>
#include	<STDIO.H>
#include	<STRING.H>

#include	<atarierr.h>

#include	"..\main.h"
#include	RSCHEADER
#include	"..\Menu.h"
#include	"..\Window.h"
#include	"..\WDialog.h"

#include	"About.h"

#include	"..\MapKey.h"

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
	ABOUT,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL
};

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
static WORD	cdecl	HandleDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD );

void	OpenAboutDialog( WORD Global[15] )
{
	if( !Dialog.Dialog )
	{
		Dialog.Tree = TreeAddr[ABOUT];
#ifdef	DRACONIS
		TreeAddr[ABOUT][ABOUT_ICONNECT].ob_flags |= HIDETREE;
#endif
#ifdef	ICONNECT
		TreeAddr[ABOUT][ABOUT_DRACONIS].ob_flags |= HIDETREE;
#endif
		OpenDialog( TreeAddr[TITLES][TITLE_ABOUT].ob_spec.free_string, WIN_WDIALOG, HandleDialog, &Dialog, Global );
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
				sprintf( DialogTree[ABOUT_DATE].ob_spec.free_string, "%s", __DATE__ );
				sprintf( DialogTree[ABOUT_VERSION].ob_spec.free_string, "%s", VERSION );
				DialogTree[ABOUT_OK].ob_state &= ~SELECTED;
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
		if( URL_Action( DialogTree, Obj, Global ))
			return( 1 );
		switch( Obj )
		{
			case	ABOUT_OK:
				return( 0 );
		}
	}	
	return( 1 );
}