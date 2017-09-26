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
#include	"..\Rsc.h"
#include	"..\Telnet.h"
#include	"..\Window.h"
#include	"..\WDialog.h"
#include	"..\W_Text.h"

#include	"W_Text.h"
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
static WORD		HandleCheckDialog( void *DialogData, EVNT *Events, WORD Global[15] );
static DIALOG_DATA	*GetDialogData( WORD WinId );

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern WORD	Global[15];
extern OBJECT	**TreeAddr;
extern TELNET DefaultTelnet;

typedef	struct
{
	WORD		WinId;
	BYTE		Title[128];
	OPT_DATA	*OptData;
}	KONTEXT;

void OpenKontextTextWindowDialog( WORD WinId, void *Data, WORD Global[15] )
{
	DIALOG_DATA	*D = GetDialogData( WinId );
	if( D )
		MT_wind_set( MT_wdlg_get_handle( D->Dialog, Global ), WF_TOP, 0, 0, 0, 0, Global );
	else
	{
		DIALOG_DATA	*Dialog = malloc( sizeof( DIALOG_DATA ));
		OPT_DATA		*OptData = malloc( sizeof( OPT_DATA ));
		if( !Dialog || !OptData )
			return;

		Dialog->UserData = malloc( sizeof( KONTEXT ));
		if( !Dialog->UserData )
			return;

		(( KONTEXT * )( Dialog->UserData ))->WinId = WinId;
		(( KONTEXT * )( Dialog->UserData ))->OptData = OptData;
		strcpy( (( KONTEXT * )( Dialog->UserData ))->Title, TreeAddr[TITLES][TITLE_TEXT].ob_spec.free_string );
		strcat( (( KONTEXT * )( Dialog->UserData ))->Title, (( TELNET * ) Data )->Host );

		Dialog->HndlDdDialog = HandleDdDialog;
		Dialog->HndlClsDialog = HandleClsDialog;
		Dialog->HndlMesagDialog = HndlMesagDialog;
		Dialog->HndlEditDialog = NULL;
		Dialog->HndlHelpDialog = HandleHelpDialog;
		Dialog->HndlTimerDialog = NULL;
		Dialog->HndlCheckDialog = HandleCheckDialog;

		OptData->Kat = OPT_VIEW;
		OptData->Tree = TreeAddr[TEXT];
		OptData->TreeIdx = TEXT;
		OptData->Obj = TEXT_OPTIONS;
		OptData->Button = TEXT_KAT;

		Dialog->Tree = CreateOptions( OptData, OPT_NO_HOST + OPT_NO_PORT, ( TELNET * ) Data );
		OpenDialog( (( KONTEXT * )( Dialog->UserData ))->Title, WIN_WDIALOG_OPTIONS, HandleDialog, Dialog, Global );
	}
}

static WORD cdecl	HandleDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD )
{
	OBJECT		*DialogTree;
	GRECT			Rect;
	DIALOG_DATA	*DialogData = ( DIALOG_DATA * ) MT_wdlg_get_udata( Dialog, Global );
	OPT_DATA		*OptData = (( KONTEXT * ) DialogData->UserData )->OptData;
	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );

	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_INIT:
			{
				DialogTree[TEXT_OK].ob_state &= ~SELECTED;
				DialogTree[TEXT_SET].ob_state &= ~SELECTED;
				DialogTree[TEXT_CANCEL].ob_state &= ~SELECTED;
				break;
			}
			case	HNDL_OPEN:
				HandleOptions( Dialog, OptData, Obj, Events, 0, Global );
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
				WORD	i = HandleOptions( Dialog, OptData, Obj, Events, *( WORD * ) UD, Global );
				if( i > 0 && ( DialogTree[TEXT_OK].ob_state & DISABLED ))
				{
					DialogTree[TEXT_OK].ob_state &= ~DISABLED;
					DialogTree[TEXT_OK].ob_flags |= SELECTABLE;
					DialogTree[TEXT_SET].ob_state &= ~DISABLED;
					DialogTree[TEXT_SET].ob_flags |= SELECTABLE;
					DoRedraw( Dialog, &Rect, NEW_OK, Global );
				}
				if( i < 0 && !( DialogTree[TEXT_OK].ob_state & DISABLED ))
				{
					DialogTree[TEXT_OK].ob_state |= DISABLED;
					DialogTree[TEXT_OK].ob_flags &= ~SELECTABLE;
					DialogTree[TEXT_SET].ob_state |= DISABLED;
					DialogTree[TEXT_SET].ob_flags &= ~SELECTABLE;
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
			StGuide_Action( DialogTree, TEXT, Global );
			return( 1 );
		}
		if( Obj == TEXT_KAT_TEXT )
			Obj = TEXT_KAT;
		switch( Obj )
		{
			case	TEXT_SET:
			{
				TELNET	*Telnet = malloc( sizeof( TELNET ));
				if( !Telnet )
					return( 0 );
				GetOptions( OptData, Telnet );
				TelnetOptions( Telnet, (( KONTEXT * ) DialogData->UserData )->WinId, DialogTree[TEXT_REPORT_CHANGE].ob_state & SELECTED, Global );
				DialogTree[TEXT_SET].ob_state &= ~SELECTED;
				DoRedraw( Dialog, &Rect, TEXT_SET, Global );
				break;
			}
			case	TEXT_OK:
			{
				TELNET	*Telnet = malloc( sizeof( TELNET ));
				if( !Telnet )
					return( 0 );
				GetOptions( OptData, Telnet );
				TelnetOptions( Telnet, (( KONTEXT * ) DialogData->UserData )->WinId, DialogTree[TEXT_REPORT_CHANGE].ob_state & SELECTED, Global );
				return( 0 );
			}
			case	TEXT_CANCEL:
				return( 0 );
			default:
				HandleOptions( Dialog, OptData, Obj, Events, 0, Global );
		}
	}
	return( 1 );
}

static WORD		HandleClsDialog( void *DD, WORD Global[15] )
{
	DIALOG_DATA *DialogData = DD;
	DelOptions((( KONTEXT * )( DialogData->UserData ))->OptData );
	free((( KONTEXT * )( DialogData->UserData ))->OptData );
	free( DialogData->UserData );
	free( DialogData );
	return( E_OK );
}

static WORD	HandleDdDialog( void *DialogData, EVNT *Events, WORD Global[15] )
{
	OPT_DATA		*OptData = (( KONTEXT * ) (( DIALOG_DATA * ) DialogData )->UserData )->OptData;
	return( HandleDdOptions((( DIALOG_DATA * ) DialogData )->Dialog, OptData, Events, Global ));
}

static WORD		HndlMesagDialog( void *DialogData, EVNT *Events, WORD Global[15] )
{
	OPT_DATA		*OptData = (( KONTEXT * ) (( DIALOG_DATA * ) DialogData )->UserData )->OptData;
	return( HandleMesagOptions((( DIALOG_DATA * ) DialogData )->Dialog, OptData, Events, Global ));
}
static WORD		HandleHelpDialog( void *DialogData, EVNT *Events, WORD Global[15] )
{
	OPT_DATA		*OptData = (( KONTEXT * ) (( DIALOG_DATA * ) DialogData )->UserData )->OptData;
	return( HandleHelpOptions((( DIALOG_DATA * ) DialogData )->Dialog, OptData, Events, Global ));
}

static DIALOG_DATA	*GetDialogData( WORD WinId )
{
	WORD	i = GetFirstWindow();
	while( i != -1 )
	{
		if( GetTypeWindow( i ) == WIN_WDIALOG_OPTIONS )
		{
			DIALOG_DATA *DialogData = GetWindowData( i );
			KONTEXT		*Kontext = DialogData->UserData;
			if( Kontext->WinId == WinId )
				return( DialogData );
		}
		i = GetNextWindow( i );
	}
	return( NULL );
}

WORD	ExistKontextTextWindow( WORD WinId, WORD Global[15] )
{
	DIALOG_DATA	*DialogData = GetDialogData( WinId );
	if( DialogData )
		return( MT_wdlg_get_handle( DialogData->Dialog, Global ) );
	else
		return( 0 );
}

void	ChangeKontextTextWindow( WORD WinId, WORD FontId, LONG FontPt, WORD FontColor, WORD Global[15] )
{
	DIALOG_DATA	*D = GetDialogData( WinId );
	if( D )
		ChangeFontOptions( D->Dialog, (( KONTEXT * )( D->UserData ))->OptData, FontId, FontPt, FontColor, Global );
}

static WORD	HandleCheckDialog( void *DialogData, EVNT *Events, WORD Global[15] )
{
	DIALOG_DATA *DD = ( DIALOG_DATA * ) DialogData;
	WORD	WinId = (( KONTEXT * ) DD->UserData )->WinId;
	TEXT_WINDOW	*TextWindow = GetWindowData( WinId );
	if( TextWindow->ModWin )
	{
		if(( Events->mwhich & MU_MESAG ) && Events->msg[0] == WM_TOPPED )
		{
			MT_wind_set( TextWindow->ModWin->WinId, WF_TOP, 0, 0, 0, 0, Global );
			Events->mwhich &= ~MU_MESAG;
		}
		if( Events->mwhich & MU_BUTTON )
		{
			if( MT_wind_find( Events->mx, Events->my, Global ) != TextWindow->ModWin->WinId )
			{
				Events->mwhich &= ~MU_BUTTON;
				MT_wind_set( TextWindow->ModWin->WinId, WF_TOP, 0, 0, 0, 0, Global );
			}
		}
	}
	return( E_OK );
}

