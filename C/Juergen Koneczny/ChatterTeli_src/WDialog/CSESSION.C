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

/*-----------------------------------------------------------------------------*/
/* Lokale Variablen                                                            */
/*-----------------------------------------------------------------------------*/
static DIALOG_DATA	Dialog =
{
	NULL,
	NULL,
	CSESSION,
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

void OpenCSessionDialog( WORD Global[15] )
{
	if( !Dialog.Dialog )
	{
		OptData.Tree = TreeAddr[CSESSION];
		OptData.TreeIdx = CSESSION;
		OptData.Obj = CSESSION_OPTIONS;
		OptData.Button = CSESSION_KAT;
#ifdef	IRC_CLIENT
		OptData.Kat = OPT_SESSION;
		Dialog.Tree = CreateOptions( &OptData, OPT_NO_HOST + OPT_NO_PASSWORD + OPT_NN_REALNAME + OPT_NN_NICKNAME + OPT_NN_USERNAME, &DefaultIrc );
#endif
#ifdef	TELNET_CLIENT
		OptData.Kat = OPT_TELNET;
		Dialog.Tree = CreateOptions( &OptData, OPT_NO_HOST, &DefaultTelnet );
#endif
		OpenDialog( TreeAddr[TITLES][TITLE_CSESSION].ob_spec.free_string, WIN_WDIALOG, HandleDialog, &Dialog, Global );
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
#ifdef	TELNET_CLIENT
				DialogTree[CSESSION_OK].ob_state |= DISABLED;
				DialogTree[CSESSION_OK].ob_state &= ~SELECTED;
				DialogTree[CSESSION_OK].ob_flags &= ~SELECTABLE;
#endif
#ifdef	IRC_CLIENT
				DialogTree[CSESSION_OK].ob_state &= ~SELECTED;
#endif
				DialogTree[CSESSION_CANCEL].ob_state &= ~SELECTED;
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
#ifdef	TELNET_CLIENT
			case	HNDL_EDCH:
			case	HNDL_EDDN:
			{
				WORD	i = HandleOptions( Dialog, &OptData, Obj, Events, *( WORD * ) UD, Global );
				if( i > 0 && ( DialogTree[CSESSION_OK].ob_state & DISABLED ))
				{
					DialogTree[CSESSION_OK].ob_state &= ~DISABLED;
					DialogTree[CSESSION_OK].ob_flags |= SELECTABLE;
					DoRedraw( Dialog, &Rect, CSESSION_OK, Global );
				}
				else	if( i < 0 && !( DialogTree[CSESSION_OK].ob_state & DISABLED ))
				{
					DialogTree[CSESSION_OK].ob_state |= DISABLED;
					DialogTree[CSESSION_OK].ob_flags &= ~SELECTABLE;
					DoRedraw( Dialog, &Rect, CSESSION_OK, Global );
				}
				break;
			}
#endif
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
			StGuide_Action( DialogTree, CSESSION, Global );
			return( 1 );
		}

		if( Obj == CSESSION_KAT_TEXT )
			Obj = CSESSION_KAT;
		switch( Obj )
		{
			case	CSESSION_OK:
			{
#ifdef	IRC_CLIENT
				FreeContentIrc( &DefaultIrc );
				GetOptions( &OptData, &DefaultIrc );
#endif
#ifdef	TELNET_CLIENT
				TELNET	*Telnet = malloc( sizeof( TELNET ));
				if( !Telnet )
					return( 0 );
				GetOptions( &OptData, Telnet );

				DefaultTelnet.FontId = Telnet->FontId;
				DefaultTelnet.FontPt = Telnet->FontPt;
				DefaultTelnet.FontColor = Telnet->FontColor;
				DefaultTelnet.FontEffects = Telnet->FontEffects;
				DefaultTelnet.WindowColor = Telnet->WindowColor;
				DefaultTelnet.PufLines = Telnet->PufLines;
				DefaultTelnet.KeyExport = Telnet->KeyExport;
				DefaultTelnet.KeyImport = Telnet->KeyImport;

				DefaultTelnet.Port = Telnet->Port;

				DefaultTelnet.EmuType = Telnet->EmuType;
				DefaultTelnet.Terminal.x = Telnet->Terminal.x;
				DefaultTelnet.Terminal.y = Telnet->Terminal.y;
				DefaultTelnet.Tab.x = Telnet->Tab.x;
				DefaultTelnet.Tab.y = Telnet->Tab.y;
				DefaultTelnet.KeyFlag = Telnet->KeyFlag;
				DefaultTelnet.ProtocolFlag = Telnet->ProtocolFlag;

				FreeTelnet( Telnet );			
#endif
				return( 0 );
			}
			case	CSESSION_CANCEL:
				return( 0 );
			default:
				HandleOptions( Dialog, &OptData, Obj, Events, 0, Global );
		}
	}
	return( 1 );
}

static WORD	HandleClsDialog( void *DialogData, WORD Global[15] )
{
	DelOptions( &OptData );
	return( E_OK );
}

static WORD	HandleDdDialog( void *DialogData, EVNT *Events, WORD Global[15] )
{
	return( HandleDdOptions((( DIALOG_DATA * ) DialogData )->Dialog, &OptData, Events, Global ));
}
static WORD		HndlMesagDialog( void *DialogData, EVNT *Events, WORD Global[15] )
{
	return( HandleMesagOptions((( DIALOG_DATA * ) DialogData )->Dialog, &OptData, Events, Global ));
}
static WORD		HandleHelpDialog( void *DialogData, EVNT *Events, WORD Global[15] )
{
	return( HandleHelpOptions((( DIALOG_DATA * ) DialogData )->Dialog, &OptData, Events, Global ));
}
