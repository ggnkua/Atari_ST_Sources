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
#ifdef	IRC_CLIENT
#include	"Irc.h"
#endif

#include	"..\Edscroll.h"
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
#ifdef	IRC_CLIENT
extern WORD	IrcFlags;
#endif

/*-----------------------------------------------------------------------------*/
/* Globale Variablen                                                           */
/*-----------------------------------------------------------------------------*/
WORD	PingFlag = 0;
WORD	SaveFlag	= 0;
WORD	AppendProtocolFlag = 0;
BYTE	*ProtocolPath = NULL;
volatile WORD	RecPufLen = 8192;

#ifdef	IRC_CLIENT
BYTE	*UploadPath	= NULL;
BYTE	*DownloadPath = NULL;
BYTE	*LogPath = NULL;
#endif

/*-----------------------------------------------------------------------------*/
/* Lokale Variablen                                                            */
/*-----------------------------------------------------------------------------*/
#ifdef	TELNET_CLIENT
static XTED	Xted;
static BYTE	Tmplt[EDITLEN+1], Txt[EDITLEN+1];
#endif
#ifdef	IRC_CLIENT
static XTED	XtedUpload;
static BYTE	TmpltUpload[EDITLEN+1], TxtUpload[EDITLEN+1];
static XTED	XtedDownload;
static BYTE	TmpltDownload[EDITLEN+1], TxtDownload[EDITLEN+1];
static XTED	XtedLog;
static BYTE	TmpltLog[EDITLEN+1], TxtLog[EDITLEN+1];
#endif

static DIALOG_DATA	Dialog =
{
	NULL,
	NULL,
	CGENERAL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL
};

void OpenCGeneralDialog( WORD Global[15] )
{
	if( !Dialog.Dialog )
	{
#ifdef	IRC_CLIENT
		if( TreeAddr[CGENERAL][CGENERAL_UPLOAD].ob_spec.tedinfo->te_txtlen < EDITLEN + 1 )
			InitScrlted( &TreeAddr[CGENERAL][CGENERAL_UPLOAD], isScroll, &XtedUpload, TxtUpload, TmpltUpload, EDITLEN );
		if( TreeAddr[CGENERAL][CGENERAL_DOWNLOAD].ob_spec.tedinfo->te_txtlen < EDITLEN + 1 )
			InitScrlted( &TreeAddr[CGENERAL][CGENERAL_DOWNLOAD], isScroll, &XtedDownload, TxtDownload, TmpltDownload, EDITLEN );
		if( TreeAddr[CGENERAL][CGENERAL_LOG].ob_spec.tedinfo->te_txtlen < EDITLEN + 1 )
			InitScrlted( &TreeAddr[CGENERAL][CGENERAL_LOG], isScroll, &XtedLog, TxtLog, TmpltLog, EDITLEN );
#endif
#ifdef	TELNET_CLIENT
		if( TreeAddr[CGENERAL][CGENERAL_PROTOCOL].ob_spec.tedinfo->te_txtlen < EDITLEN + 1 )
			InitScrlted( &TreeAddr[CGENERAL][CGENERAL_PROTOCOL], isScroll, &Xted, Txt, Tmplt, EDITLEN );
#endif
		Dialog.Tree = TreeAddr[CGENERAL];
		OpenDialog( TreeAddr[TITLES][TITLE_GENERAL].ob_spec.free_string, WIN_WDIALOG, HandleDialog, &Dialog, Global );
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
				DialogTree[CGENERAL_OK].ob_state &= ~SELECTED;
				DialogTree[CGENERAL_CANCEL].ob_state &= ~SELECTED;
#ifdef	IRC_CLIENT
				strcpy( DialogTree[CGENERAL_DOWNLOAD].ob_spec.tedinfo->te_ptext, DownloadPath == NULL ? "" : DownloadPath );
				strcpy( DialogTree[CGENERAL_UPLOAD].ob_spec.tedinfo->te_ptext, UploadPath == NULL ? "" : UploadPath );
				strcpy( DialogTree[CGENERAL_LOG].ob_spec.tedinfo->te_ptext, LogPath == NULL ? "" : LogPath );
				( IrcFlags & WINDOW_OVERWRITE ) ? ( DialogTree[CGENERAL_OVERWRITE].ob_state |= SELECTED ) : ( DialogTree[CGENERAL_OVERWRITE].ob_state &= ~SELECTED );
				( IrcFlags & WINDOW_INTELLIGENT ) ? ( DialogTree[CGENERAL_WINDOW].ob_state |= SELECTED ) : ( DialogTree[CGENERAL_WINDOW].ob_state &= ~SELECTED );
				( IrcFlags & WINDOW_TOPLEFT ) ? ( DialogTree[CGENERAL_WINDOWTOPLEFT].ob_state |= SELECTED ) : ( DialogTree[CGENERAL_WINDOWTOPLEFT].ob_state &= ~SELECTED );
				( IrcFlags & WINDOW_ONLY ) ? ( DialogTree[CGENERAL_WINDOWONLY].ob_state |= SELECTED ) : ( DialogTree[CGENERAL_WINDOWONLY].ob_state &= ~SELECTED );
				( IrcFlags & WINDOW_INTELLIGENT ) ? ( DialogTree[CGENERAL_WINDOW].ob_state |= SELECTED ) : ( DialogTree[CGENERAL_WINDOW].ob_state &= ~SELECTED );
				( IrcFlags & WINDOW_TOPWITHNICK ) ? ( DialogTree[CGENERAL_TOPWITHNICK].ob_state |= SELECTED ) : ( DialogTree[CGENERAL_TOPWITHNICK].ob_state &= ~SELECTED );
				( IrcFlags & APPEND_OWNNICK ) ? ( DialogTree[CGENERAL_OWNNICK].ob_state |= SELECTED ) : ( DialogTree[CGENERAL_OWNNICK].ob_state &= ~SELECTED );
				( IrcFlags & AUTO_CHANNEL ) ? ( DialogTree[CGENERAL_AUTOCHANNEL].ob_state |= SELECTED ) : ( DialogTree[CGENERAL_AUTOCHANNEL].ob_state &= ~SELECTED );
				( IrcFlags & AUTO_NAMES ) ? ( DialogTree[CGENERAL_AUTONAMES].ob_state |= SELECTED ) : ( DialogTree[CGENERAL_AUTONAMES].ob_state &= ~SELECTED );
				( IrcFlags & APPEND_LOG ) ? ( DialogTree[CGENERAL_LOG_APPEND].ob_state |= SELECTED ) : ( DialogTree[CGENERAL_LOG_APPEND].ob_state &= ~SELECTED );
				( IrcFlags & USE_SMICONS ) ? ( DialogTree[CGENERAL_SMICONS].ob_state |= SELECTED ) : ( DialogTree[CGENERAL_LOG_APPEND].ob_state &= ~SELECTED );
#endif
#ifdef	TELNET_CLIENT
				strcpy( DialogTree[CGENERAL_PROTOCOL].ob_spec.tedinfo->te_ptext, ProtocolPath == NULL ? "" : ProtocolPath );
				AppendProtocolFlag ? ( DialogTree[CGENERAL_PROTOCOL_APPEND].ob_state |= SELECTED ) : ( DialogTree[CGENERAL_PROTOCOL_APPEND].ob_state &= ~SELECTED );
				PingFlag ? ( DialogTree[CGENERAL_PING].ob_state |= SELECTED ) : ( DialogTree[CGENERAL_PING].ob_state &= ~SELECTED );
				sprintf( DialogTree[CGENERAL_RPUF].ob_spec.tedinfo->te_ptext, "%i", RecPufLen );
#endif
				SaveFlag ? ( DialogTree[CGENERAL_SAVE].ob_state |= SELECTED ) : ( DialogTree[CGENERAL_SAVE].ob_state &= ~SELECTED );
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
#ifdef	TELNET_CLIENT
			case	CGENERAL_RPUF_TEXT:
				MT_wdlg_set_edit( Dialog, CGENERAL_RPUF, Global );
				break;
			case	CGENERAL_PROTOCOL:
			case	CGENERAL_PROTOCOL_TEXT:
				if( Clicks == 2 )
				{
					BYTE	*Path;
					MT_wdlg_set_edit( Dialog, 0, Global );
					Path = Fsel( DialogTree[CGENERAL_PROTOCOL].ob_spec.tedinfo->te_ptext, "*", TreeAddr[TITLES][FSEL_PROTOCOL].ob_spec.free_string, Global );
					if( Path )
					{
						*( strrchr( Path, ( int ) '\\' ) + 1 ) = 0;
						strcpy( DialogTree[CGENERAL_PROTOCOL].ob_spec.tedinfo->te_ptext, Path );
						free( Path );
						DoRedraw( Dialog, &Rect, CGENERAL_PROTOCOL, Global );
					}
				}
				MT_wdlg_set_edit( Dialog, CGENERAL_PROTOCOL, Global );
				break;
#endif			
#ifdef	IRC_CLIENT
			case	CGENERAL_DOWNLOAD:
			case	CGENERAL_DOWNLOAD_TEXT:
				if( Clicks == 2 )
				{
					BYTE	*Path;
					MT_wdlg_set_edit( Dialog, 0, Global );
					Path = Fsel( DialogTree[CGENERAL_DOWNLOAD].ob_spec.tedinfo->te_ptext, "*", TreeAddr[TITLES][FSEL_DOWNLOAD].ob_spec.free_string, Global );
					if( Path )
					{
						*( strrchr( Path, ( int ) '\\' ) + 1 ) = 0;
						strcpy( DialogTree[CGENERAL_DOWNLOAD].ob_spec.tedinfo->te_ptext, Path );
						free( Path );
						DoRedraw( Dialog, &Rect, CGENERAL_DOWNLOAD, Global );
					}
				}
				MT_wdlg_set_edit( Dialog, CGENERAL_DOWNLOAD, Global );
				break;
			case	CGENERAL_UPLOAD:
			case	CGENERAL_UPLOAD_TEXT:
				if( Clicks == 2 )
				{
					BYTE	*Path;
					MT_wdlg_set_edit( Dialog, 0, Global );
					Path = Fsel( DialogTree[CGENERAL_UPLOAD].ob_spec.tedinfo->te_ptext, "*", TreeAddr[TITLES][FSEL_UPLOAD].ob_spec.free_string, Global );
					if( Path )
					{
						*( strrchr( Path, ( int ) '\\' ) + 1 ) = 0;
						strcpy( DialogTree[CGENERAL_UPLOAD].ob_spec.tedinfo->te_ptext, Path );
						free( Path );
						DoRedraw( Dialog, &Rect, CGENERAL_UPLOAD, Global );
					}
				}
				MT_wdlg_set_edit( Dialog, CGENERAL_UPLOAD, Global );
				break;
			case	CGENERAL_LOG:
			case	CGENERAL_LOG_TEXT:
				if( Clicks == 2 )
				{
					BYTE	*Path;
					MT_wdlg_set_edit( Dialog, 0, Global );
					Path = Fsel( DialogTree[CGENERAL_LOG].ob_spec.tedinfo->te_ptext, "*", TreeAddr[TITLES][FSEL_LOG].ob_spec.free_string, Global );
					if( Path )
					{
						*( strrchr( Path, ( int ) '\\' ) + 1 ) = 0;
						strcpy( DialogTree[CGENERAL_LOG].ob_spec.tedinfo->te_ptext, Path );
						free( Path );
						DoRedraw( Dialog, &Rect, CGENERAL_LOG, Global );
					}
				}
				MT_wdlg_set_edit( Dialog, CGENERAL_LOG, Global );
				break;
#endif
			case	CGENERAL_OK:
			{
				( DialogTree[CGENERAL_SAVE].ob_state & SELECTED ) ? ( SaveFlag = 1 ) : ( SaveFlag = 0 );
#ifdef	IRC_CLIENT

				( DialogTree[CGENERAL_OVERWRITE].ob_state & SELECTED ) ? ( IrcFlags |= WINDOW_OVERWRITE ) : ( IrcFlags &= ~WINDOW_OVERWRITE );
				( DialogTree[CGENERAL_WINDOW].ob_state & SELECTED ) ? ( IrcFlags |= WINDOW_INTELLIGENT ) : ( IrcFlags &= ~WINDOW_INTELLIGENT );
				( DialogTree[CGENERAL_WINDOWTOPLEFT].ob_state & SELECTED ) ? ( IrcFlags |= WINDOW_TOPLEFT ) : ( IrcFlags &= ~WINDOW_TOPLEFT );
				( DialogTree[CGENERAL_WINDOWONLY].ob_state & SELECTED ) ? ( IrcFlags |= WINDOW_ONLY ) : ( IrcFlags &= ~WINDOW_ONLY );
				( DialogTree[CGENERAL_TOPWITHNICK].ob_state & SELECTED ) ? ( IrcFlags |= WINDOW_TOPWITHNICK ) : ( IrcFlags &= ~WINDOW_TOPWITHNICK );
				( DialogTree[CGENERAL_OWNNICK].ob_state & SELECTED ) ? ( IrcFlags |= APPEND_OWNNICK ) : ( IrcFlags &= ~APPEND_OWNNICK );
				( DialogTree[CGENERAL_AUTOCHANNEL].ob_state & SELECTED ) ? ( IrcFlags |= AUTO_CHANNEL ) : ( IrcFlags &= ~AUTO_CHANNEL );
				( DialogTree[CGENERAL_AUTONAMES].ob_state & SELECTED ) ? ( IrcFlags |= AUTO_NAMES ) : ( IrcFlags &= ~AUTO_NAMES );
				( DialogTree[CGENERAL_LOG_APPEND].ob_state & SELECTED ) ? ( IrcFlags |= APPEND_LOG ) : ( IrcFlags &= ~APPEND_LOG );
				( DialogTree[CGENERAL_SMICONS].ob_state & SELECTED ) ? ( IrcFlags |= USE_SMICONS ) : ( IrcFlags &= ~USE_SMICONS );
				if( DownloadPath )
					free( DownloadPath );
				DownloadPath = NULL;
				if( UploadPath )
					free( UploadPath );
				UploadPath = NULL;
				if( LogPath )
					free( LogPath );
				LogPath = NULL;
				if( strlen( DialogTree[CGENERAL_DOWNLOAD].ob_spec.tedinfo->te_ptext ))
					DownloadPath = strdup( DialogTree[CGENERAL_DOWNLOAD].ob_spec.tedinfo->te_ptext );
				if( strlen( DialogTree[CGENERAL_UPLOAD].ob_spec.tedinfo->te_ptext ))
					UploadPath = strdup( DialogTree[CGENERAL_UPLOAD].ob_spec.tedinfo->te_ptext );
				if( strlen( DialogTree[CGENERAL_LOG].ob_spec.tedinfo->te_ptext ))
					LogPath = strdup( DialogTree[CGENERAL_LOG].ob_spec.tedinfo->te_ptext );
#endif
#ifdef	TELNET_CLIENT
				( DialogTree[CGENERAL_PING].ob_state & SELECTED ) ? ( PingFlag = 1 ) : ( PingFlag = 0 );
				( DialogTree[CGENERAL_PROTOCOL_APPEND].ob_state & SELECTED ) ? ( AppendProtocolFlag = 1 ) : ( AppendProtocolFlag = 0 );
				RecPufLen = atol( DialogTree[CGENERAL_RPUF].ob_spec.tedinfo->te_ptext );
				if( RecPufLen < 1 )
					RecPufLen = 1;
				if( ProtocolPath )
				{
					free( ProtocolPath );
					ProtocolPath = NULL;
				}
				if( strlen( DialogTree[CGENERAL_PROTOCOL].ob_spec.tedinfo->te_ptext ))
					ProtocolPath = strdup( DialogTree[CGENERAL_PROTOCOL].ob_spec.tedinfo->te_ptext );
#endif
				return( 0 );
			}
			case	CGENERAL_CANCEL:
				return( 0 );
		}
	}
	return( 1 );
}
