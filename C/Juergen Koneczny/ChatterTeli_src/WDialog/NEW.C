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
#include	"..\Popup.h"
#ifdef	IRC_CLIENT
#include	"..\Irc.h"
#endif
#ifdef	TELNET_CLIENT
#include	"..\Telnet.h"
#endif
#include	"..\WDialog.h"
#include	"..\Window.h"

#include	"Hotlist.h"
#include	"New.h"
#include	"Options.h"

#include	"..\MapKey.h"

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
static WORD		cdecl	HandleDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD );
static WORD		HandleDdDialog( void *DialogData, EVNT *Events, WORD Global[15] );
static WORD		HandleClsDialog( void *DialogData, WORD Global[15] );
static WORD		HndlMesagDialog( void *DialogData, EVNT *Events, WORD Global[15] );
static WORD		HandleHelpDialog( void *DialogData, EVNT *Events, WORD Global[15] );

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern WORD	Global[15];
extern OBJECT	**TreeAddr;
#ifdef	IRC_CLIENT
extern IRC	DefaultIrc;
#endif
#ifdef	TELNET_CLIENT
extern TELNET	DefaultTelnet;
#endif
extern OBJECT	*HtPopup;

/*-----------------------------------------------------------------------------*/
/* Lokale Variablen                                                            */
/*-----------------------------------------------------------------------------*/
static DIALOG_DATA	Dialog =
{
	NULL,
	NULL,
	NEW,
	HandleDdDialog,
	HandleClsDialog,
	HndlMesagDialog,
	NULL,
	HandleHelpDialog,
	NULL,
	NULL,
	NULL
};

static OPT_DATA	OptData;

void OpenNewDialog( WORD Global[15] )
{
	if( !Dialog.Dialog )
	{
		OptData.Tree = TreeAddr[NEW];
		OptData.TreeIdx = NEW;
		OptData.Obj = NEW_OPTIONS;
		OptData.Button = NEW_KAT;
#ifdef	IRC_CLIENT
		OptData.Kat = OPT_SESSION;
		Dialog.Tree = CreateOptions( &OptData, OPT_NO_ALL, &DefaultIrc );
#endif
#ifdef	TELNET_CLIENT
		OptData.Kat = OPT_TELNET;
		Dialog.Tree = CreateOptions( &OptData, OPT_NO_ALL, &DefaultTelnet );
#endif
		OpenDialog( TreeAddr[TITLES][TITLE_NEW].ob_spec.free_string, WIN_WDIALOG, HandleDialog, &Dialog, Global );
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
				DialogTree[NEW_OK].ob_state |= DISABLED;
				DialogTree[NEW_OK_I].ob_state |= DISABLED;
				DialogTree[NEW_OK].ob_state &= ~SELECTED;
				DialogTree[NEW_OK].ob_flags &= ~SELECTABLE;
				DialogTree[NEW_CANCEL].ob_state &= ~SELECTED;
				DialogTree[NEW_HOTLIST].ob_state &= ~SELECTED;
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
			case	HNDL_EDCH:
			case	HNDL_EDDN:
			{
				WORD	i = HandleOptions( Dialog, &OptData, Obj, Events, *( WORD * ) UD, Global );
				if( i > 0 && ( DialogTree[NEW_OK].ob_state & DISABLED ))
				{
					DialogTree[NEW_OK_I].ob_state &= ~DISABLED;
					DialogTree[NEW_OK].ob_state &= ~DISABLED;
					DialogTree[NEW_OK].ob_flags |= SELECTABLE;
					DoRedraw( Dialog, &Rect, NEW_OK, Global );
				}
				else	if( i < 0 && !( DialogTree[NEW_OK].ob_state & DISABLED ))
				{
					DialogTree[NEW_OK_I].ob_state |= DISABLED;
					DialogTree[NEW_OK].ob_state |= DISABLED;
					DialogTree[NEW_OK].ob_flags &= ~SELECTABLE;
					DoRedraw( Dialog, &Rect, NEW_OK, Global );
				}
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
			StGuide_Action( DialogTree, NEW, Global );
			return( 1 );
		}
		if( Obj == NEW_KAT_TEXT )
			Obj = NEW_KAT;
		switch( Obj )
		{
			case	NEW_OK:
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
				return( 0 );
			}
			case	NEW_CANCEL:
#ifdef	DEBUG
	DebugMsg( Global, "HandleNewDialog: NEW_CANCEL\n" );
#endif
				return( 0 );
			case	NEW_HOTLIST:
			{
				WORD	x, y, Selected;
				if( HtPopup )
				{
					MT_objc_offset( DialogTree, NEW_HOTLIST, &x, &y, Global );			
					Selected = Popup( HtPopup, 0, x, y, Global );
					if( Selected >= 0 )
#ifdef	IRC_CLIENT
						NewOptions( Dialog, &OptData, GetIrcHotlist( Selected ), Global );
#endif
#ifdef	TELNET_CLIENT
						NewOptions( Dialog, &OptData, GetTelnetHotlist( Selected ), Global );
#endif
				}
				DialogTree[NEW_HOTLIST].ob_state &= ~SELECTED;
				DoRedraw( Dialog, &Rect, NEW_HOTLIST, Global );
				break;
			}
			default:
				HandleOptions( Dialog, &OptData, Obj, Events, 0, Global );
		}
	}
	return( 1 );
}

static WORD	HandleDdDialog( void *DialogData, EVNT *Events, WORD Global[15] )
{
	return( HandleDdOptions((( DIALOG_DATA * ) DialogData )->Dialog, &OptData, Events, Global ));
}

static WORD	HandleClsDialog( void *DialogData, WORD Global[15] )
{
#ifdef	DEBUG
	DebugMsg( Global, "NewDialog: HandleClsDialog()\n" );
#endif
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
