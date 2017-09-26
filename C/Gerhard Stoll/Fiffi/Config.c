#include	<mt_mem.h>
#include	<PORTAB.H>
#include <STDLIB.H>
#include	<STRING.H>
#include <STDIO.H>
#include	<TOS.H>
#include	<MT_AES.H>
#include <CTYPE.H>
#include	<EXT.H>
#include <SETJMP.H>

#include <atarierr.h>

#include	"config.h"
#include "main.h"
#include	"Window.h"
#include	"Suffix.h"
#include "Fiffi.h"
#include "mapkey.h"
#include	"edscroll.h"


/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern WORD		Global[15];
extern WORD		AppId;
extern WORD		magic_version;
extern LONG		magic_date;
extern OBJECT	**TreeAddr;
extern BYTE		**FstringAddr;
extern WORD		nHotlist;
#ifdef	V120
extern BYTE		**HotlistName;
#endif
extern BYTE		**HotlistHost;
extern UWORD	*HotlistPort;	
extern BYTE		**HotlistUid;
extern BYTE		**HotlistPwd;
extern BYTE		**HotlistDir;
extern BYTE		**HotlistComment;
extern UWORD	ConfFlag;
extern UWORD   ShowFlag;
extern BYTE		*RxDir;
extern BYTE		*TxDir;
extern UWORD	ComPort;
extern UWORD	DataPortL;
extern UWORD	DataPortH;
extern UWORD	DataPort;
extern volatile	ULONG	BufLen;
extern UWORD	PasvFlag;
extern UWORD	TransferType;
extern UWORD	TransferTypeAuto;
extern SUF_ITEM	*SuffixList;
extern WORD		ChangeFilenameCase;
extern WORD		FileSelectorFlag;
extern GRECT	FtpWinPos[];
extern volatile ULONG FtpWinX;
extern volatile WORD	SortDirList;
extern BYTE *LogDir;
#ifdef	V110
extern volatile WORD	IConnect;
extern volatile WORD	KeepConnectionActive;
extern volatile WORD	KeepConnectionActiveTime;
#endif
#ifdef	V120
extern volatile WORD TransferPing;
extern volatile WORD	AppendProtocol;
#endif

/*-----------------------------------------------------------------------------*/
/* Globale Variablen                                                           */
/*-----------------------------------------------------------------------------*/
XTED	RxXted, TxXted, LogXted;
BYTE	RxTmplt[EditLen+1], RxTxt[EditLen+1];
BYTE	TxTmplt[EditLen+1], TxTxt[EditLen+1];
BYTE	LogTmplt[EditLen+1], LogTxt[EditLen+1];

/*-----------------------------------------------------------------------------*/
/* Lokale Variablen                                                            */
/*-----------------------------------------------------------------------------*/
#ifdef	V120
static BYTE	*HomePathConfig = NULL, *DefaultPathConfig = NULL;
static BYTE *PathConfig = "Fiffi.inf";
#endif


/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
#ifdef	V120
static void	GetFilenameConfig( void );
#endif

/*-----------------------------------------------------------------------------*/
/* Service-Routine fÅr Einstellungen                                           */
/*-----------------------------------------------------------------------------*/
WORD	cdecl HandleConf1Dialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD ) 
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
				WORD	isScroll;
				if( magic_version && magic_date >= 0x19950829L )
					isScroll = 1;
				else
					isScroll = 0;
				if( !RxXted.xte_ptmplt )
					InitScrlted(&DialogTree[CONF1_RX], isScroll, &RxXted, RxTxt, RxTmplt, EditLen);
				if( !TxXted.xte_ptmplt )
					InitScrlted(&DialogTree[CONF1_TX], isScroll, &TxXted, TxTxt, TxTmplt, EditLen);
				if( !LogXted.xte_ptmplt )
					InitScrlted(&DialogTree[CONF1_LOG], isScroll, &LogXted, LogTxt, LogTmplt, EditLen);

				if( RxDir )
					strcpy( RxTxt, RxDir );
				else
					strcpy( RxTxt, "" );
				DialogTree[CONF1_RX].ob_state &= ~DISABLED;
				DialogTree[CONF1_RX].ob_flags |= TOUCHEXIT;
				DialogTree[CONF1_RX].ob_flags |= EDITABLE;
				if( TxDir )
					strcpy( TxTxt, TxDir );
				else
					strcpy( TxTxt, "" );
				DialogTree[CONF1_TX].ob_state &= ~DISABLED;
				DialogTree[CONF1_TX].ob_flags |= TOUCHEXIT;
				DialogTree[CONF1_TX].ob_flags |= EDITABLE;

				if( LogDir )
					strcpy( LogTxt, LogDir );
				else
					strcpy( LogTxt, "" );
				DialogTree[CONF1_LOG].ob_state &= ~DISABLED;
				DialogTree[CONF1_LOG].ob_flags |= TOUCHEXIT;
				DialogTree[CONF1_LOG].ob_flags |= EDITABLE;

				ltoa( BufLen / 1024, DialogTree[CONF1_BUF].ob_spec.tedinfo->te_ptext, 10 );

				if( SortDirList & SORT_DIR_LIST_ON )
				{
					DialogTree[CONF1_SORT_ON].ob_state |= SELECTED;
					DialogTree[CONF1_SORT_DESK].ob_flags |= SELECTABLE;
					DialogTree[CONF1_SORT_DESK].ob_state &= ~DISABLED;
					if( SortDirList & SORT_DIR_LIST_DESKTOP )
						DialogTree[CONF1_SORT_DESK].ob_state |= SELECTED;
				}
				else
				{
					DialogTree[CONF1_SORT_ON].ob_state &= ~SELECTED;
					DialogTree[CONF1_SORT_DESK].ob_state &= ~SELECTED;
					DialogTree[CONF1_SORT_DESK].ob_state |= DISABLED;
					DialogTree[CONF1_SORT_DESK].ob_flags &= ~SELECTABLE;
				}
				if( ConfFlag & SaveConf )
					DialogTree[CONF1_SAVE_CONF].ob_state |= SELECTED;
				else
					DialogTree[CONF1_SAVE_CONF].ob_state &= ~SELECTED;
				if( ChangeFilenameCase )
					DialogTree[CONF1_LCASE_FLAG].ob_state |= SELECTED;
				else
					DialogTree[CONF1_LCASE_FLAG].ob_state &= ~SELECTED;
				if( ShowFlag )
					DialogTree[CONF1_SHOW_FLAG].ob_state |= SELECTED;
				else
					DialogTree[CONF1_SHOW_FLAG].ob_state &= ~SELECTED;
				if( FileSelectorFlag )
					DialogTree[CONF1_MAGIC_FS].ob_state |= SELECTED;
				else
					DialogTree[CONF1_MAGIC_FS].ob_state &= ~SELECTED;

#ifdef	V120
				if( TransferPing )
					DialogTree[CONF1_PING].ob_state |= SELECTED;
				else
					DialogTree[CONF1_PING].ob_state &= ~SELECTED;
				if( AppendProtocol )
					DialogTree[CONF1_APPEND].ob_state |= SELECTED;
				else
					DialogTree[CONF1_APPEND].ob_state &= ~SELECTED;
				if( ShowFlag )
				{
					DialogTree[CONF1_APPEND].ob_state &= ~DISABLED;
					DialogTree[CONF1_APPEND].ob_flags |= SELECTABLE;
				}
				else
				{
					DialogTree[CONF1_APPEND].ob_state |= DISABLED;
					DialogTree[CONF1_APPEND].ob_flags &= ~SELECTABLE;
				}
#endif

				DialogTree[CONF1_OK].ob_state &= ~SELECTED;
				DialogTree[CONF1_OK].ob_state &= ~DISABLED;
				DialogTree[CONF1_OK].ob_flags |= SELECTABLE;
				DialogTree[CONF1_CANCEL].ob_state &= ~SELECTED;
				DialogTree[CONF1_CANCEL].ob_state &= ~DISABLED;
				DialogTree[CONF1_CANCEL].ob_flags |= SELECTABLE;
				break;
			}
			case	HNDL_CLSD:
				return( 0 );

			case	HNDL_EDIT:
			{
				WORD	a, b;
				if( IsMenuKey( Events->key, &a, &b ))
					return( 0 );
				break;
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
							MemErr( "Config" );
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
					MT_wdlg_set_uniconify( Dialog, ( GRECT *) &( Events->msg[4] ), NULL, TreeAddr[CONF1], Global );
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
		Obj &= 0x7fff;

		if( Obj == CONF1_TX_SET || Obj == CONF1_TX )
		{
			MT_wdlg_set_edit( Dialog, 0, Global );
			MT_wdlg_set_edit( Dialog, CONF1_TX, Global );
		}
		if( Obj == CONF1_RX_SET || Obj == CONF1_RX )
		{
			MT_wdlg_set_edit( Dialog, 0, Global );
			MT_wdlg_set_edit( Dialog, CONF1_RX, Global );
		}
		if( Obj == CONF1_LOG_SET || Obj == CONF1_LOG )
		{
			MT_wdlg_set_edit( Dialog, 0, Global );
			MT_wdlg_set_edit( Dialog, CONF1_LOG, Global );
		}
		if(( Obj == CONF1_SORT_ON ) && ( DialogTree[CONF1_SORT_ON].ob_state & SELECTED ))
		{
			DialogTree[CONF1_SORT_DESK].ob_flags |= SELECTABLE;
			DialogTree[CONF1_SORT_DESK].ob_state &= ~DISABLED;
			DoRedraw( Dialog, &Rect, CONF1_SORT_DESK, Global );
		}
		if(( Obj == CONF1_SORT_ON ) && !( DialogTree[CONF1_SORT_ON].ob_state & SELECTED ))
		{
			DialogTree[CONF1_SORT_DESK].ob_flags &= ~SELECTABLE;
			DialogTree[CONF1_SORT_DESK].ob_state |= DISABLED;
			DialogTree[CONF1_SORT_DESK].ob_state &= ~SELECTED;
			DoRedraw( Dialog, &Rect, CONF1_SORT_DESK, Global );
		}

		if( Obj == CONF1_RX && Clicks == 2 )
		{
			WORD	Msg[16];
			Msg[0] = Fsel_Msg;
			Msg[2] = 0;
			Msg[3] = Fsel_Open;
			Msg[4] = Fsel_Conf_Rx;
			MT_appl_write( AppId, 16, Msg, Global );
		}

		if( Obj == CONF1_TX && Clicks == 2)
		{
			WORD	Msg[16];
			Msg[0] = Fsel_Msg;
			Msg[2] = 0;
			Msg[3] = Fsel_Open;
			Msg[4] = Fsel_Conf_Tx;
			MT_appl_write( AppId, 16, Msg, Global );
		}
		if( Obj == CONF1_LOG && Clicks == 2)
		{
			WORD	Msg[16];
			Msg[0] = Fsel_Msg;
			Msg[2] = 0;
			Msg[3] = Fsel_Open;
			Msg[4] = Fsel_Conf_Log;
			MT_appl_write( AppId, 16, Msg, Global );
		}

		if(( Obj == CONF1_RX && Clicks == 2 ) || ( Obj == CONF1_TX && Clicks == 2 ) || 
		   ( Obj == CONF1_LOG && Clicks == 2 ))
		{
			MT_wdlg_set_edit( Dialog, 0, Global );
			DialogTree[CONF1_OK].ob_state |= DISABLED;
			DialogTree[CONF1_OK].ob_flags &= ~SELECTABLE;
			DialogTree[CONF1_CANCEL].ob_state |= DISABLED;
			DialogTree[CONF1_CANCEL].ob_flags &= ~SELECTABLE;
			DialogTree[CONF1_RX].ob_state |= DISABLED;
			DialogTree[CONF1_RX].ob_flags &= ~EDITABLE;
			DialogTree[CONF1_RX].ob_flags &= ~TOUCHEXIT;
			DialogTree[CONF1_TX].ob_state |= DISABLED;
			DialogTree[CONF1_TX].ob_flags &= ~EDITABLE;
			DialogTree[CONF1_TX].ob_flags &= ~TOUCHEXIT;
			DialogTree[CONF1_LOG].ob_state |= DISABLED;
			DialogTree[CONF1_LOG].ob_flags &= ~EDITABLE;
			DialogTree[CONF1_LOG].ob_flags &= ~TOUCHEXIT;
			DoRedrawX( Dialog, &Rect, Global, CONF1_OK, CONF1_CANCEL, CONF1_RX, 
			           CONF1_TX, CONF1_LOG, EDRX );
		}
		
		if( Obj == CONF1_BUF_DOWN )
		{
			WORD Keystate;
			LONG	Buf, a = 1;
			Keystate = (WORD) Kbshift( -1 );
			if( Keystate & KsSHIFT )
				a *= 10;
			if( Keystate & KsALT )
				a *= 100;
			Buf = atol( DialogTree[CONF1_BUF].ob_spec.tedinfo->te_ptext );
			Buf -= a;
			if( Buf < 1 )
				Buf = 1;
			ltoa( Buf, DialogTree[CONF1_BUF].ob_spec.tedinfo->te_ptext, 10 );
			DoRedraw( Dialog, &Rect, CONF1_BUF_BOX, Global ); 
		}
		if( Obj == CONF1_BUF_UP )
		{
			WORD Keystate;
			LONG	Buf, a = 1;
			Keystate = (WORD) Kbshift( -1 );
			if( Keystate & KsSHIFT )
				a *= 10;
			if( Keystate & KsALT )
				a *= 100;
			Buf = atol( DialogTree[CONF1_BUF].ob_spec.tedinfo->te_ptext );
			if( Buf + a > 31L )
				a = 31L - Buf;
			Buf += a;
			ltoa( Buf, DialogTree[CONF1_BUF].ob_spec.tedinfo->te_ptext, 10 );
			DoRedraw( Dialog, &Rect, CONF1_BUF_BOX, Global ); 
		}

#ifdef	V120
		if( Obj == CONF1_SHOW_FLAG && ( DialogTree[CONF1_SHOW_FLAG].ob_state & SELECTED ))
		{
			DialogTree[CONF1_APPEND].ob_state &= ~DISABLED;
			DialogTree[CONF1_APPEND].ob_flags |= SELECTABLE;
			DoRedraw( Dialog, &Rect, CONF1_APPEND, Global ); 
		}
		if( Obj == CONF1_SHOW_FLAG && !( DialogTree[CONF1_SHOW_FLAG].ob_state & SELECTED ))
		{
			DialogTree[CONF1_APPEND].ob_state |= DISABLED;
			DialogTree[CONF1_APPEND].ob_state &= ~SELECTED;
			DialogTree[CONF1_APPEND].ob_flags &= ~SELECTABLE;
			DoRedraw( Dialog, &Rect, CONF1_APPEND, Global ); 
		}
#endif

		if( Obj == CONF1_CANCEL )
			return( 0 );

		if( Obj == CONF1_OK )
		{
			BufLen = atol( DialogTree[CONF1_BUF].ob_spec.tedinfo->te_ptext ) * 1024;

			if( RxDir )
				free( RxDir );
			if( strlen( DialogTree[CONF1_RX].ob_spec.tedinfo->te_ptext ))
			{
				RxDir = malloc( strlen( DialogTree[CONF1_RX].ob_spec.tedinfo->te_ptext ) + 2 );
				if( !RxDir )
				{
					MemErr( "Config" );
					return( 0 );
				}
				strcpy( RxDir, DialogTree[CONF1_RX].ob_spec.tedinfo->te_ptext );
				if( RxDir[strlen( RxDir )-1] != '\\' )
					strcat( RxDir, "\\" );
			}
			else
				RxDir = 0L;

			if( TxDir )
				free( TxDir );
			if( strlen( DialogTree[CONF1_TX].ob_spec.tedinfo->te_ptext ))
			{
				TxDir = malloc( strlen( DialogTree[CONF1_TX].ob_spec.tedinfo->te_ptext ) + 2 );
				if( !TxDir )
				{
					MemErr( "Config" );
					return( 0 );
				}
				strcpy( TxDir, DialogTree[CONF1_TX].ob_spec.tedinfo->te_ptext );
				if( TxDir[strlen( TxDir )-1] != '\\' )
					strcat( TxDir, "\\" );
			}
			else
				TxDir = 0L;
			if( LogDir )
				free( LogDir );
			if( strlen( DialogTree[CONF1_LOG].ob_spec.tedinfo->te_ptext ))
			{
				LogDir = malloc( strlen( DialogTree[CONF1_LOG].ob_spec.tedinfo->te_ptext ) + 2 );
				if( !LogDir )
				{
					MemErr( "Config" );
					return( 0 );
				}
				strcpy( LogDir, DialogTree[CONF1_LOG].ob_spec.tedinfo->te_ptext );
				if( LogDir[strlen( LogDir )-1] != '\\' )
					strcat( LogDir, "\\" );
			}
			else
				LogDir = 0L;

			if( DialogTree[CONF1_SAVE_CONF].ob_state & SELECTED )
				ConfFlag |= SaveConf;
			else
				ConfFlag &= ~SaveConf;
			if( DialogTree[CONF1_LCASE_FLAG].ob_state & SELECTED )
				ChangeFilenameCase = 1;
			else
				ChangeFilenameCase = 0;
			if( DialogTree[CONF1_SHOW_FLAG].ob_state & SELECTED )
				ShowFlag = 1;
			else
				ShowFlag = 0;
			if( DialogTree[CONF1_MAGIC_FS].ob_state & SELECTED )
				FileSelectorFlag = 1;
			else
				FileSelectorFlag = 0;
			if( DialogTree[CONF1_SORT_ON].ob_state & SELECTED )
			{
				SortDirList = SORT_DIR_LIST_ON + SORT_DIR_LIST_BYNAME;
				if( DialogTree[CONF1_SORT_DESK].ob_state & SELECTED )
					SortDirList |= SORT_DIR_LIST_DESKTOP;
			}
			else
				SortDirList = 0;
#ifdef	V120
				if( DialogTree[CONF1_PING].ob_state & SELECTED )
					TransferPing = 1;
				else
					TransferPing = 0;
				if( DialogTree[CONF1_APPEND].ob_state & SELECTED )
					AppendProtocol = 1;
				else
					AppendProtocol = 0;
#endif
			return( 0 );
		}

	}
	return( 1 );

}

WORD	cdecl HandleConf2Dialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD ) 
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
				if( IConnect & ICONNECT_DISCONNECT_LAST_SESSION )
				{
					DialogTree[CONF2_ICON_DIS1].ob_state &= ~SELECTED;
					DialogTree[CONF2_ICON_DIS2].ob_state |= SELECTED;
				}
				else
				{
					DialogTree[CONF2_ICON_DIS1].ob_state |= SELECTED;
					DialogTree[CONF2_ICON_DIS2].ob_state &= ~SELECTED;
				}
				if(( IConnect & ICONNECT_DISCONNECT ) || ( IConnect & ICONNECT_DISCONNECT_LAST_SESSION ))
				{
					DialogTree[CONF2_ICON_DIS].ob_state |= SELECTED;
					DialogTree[CONF2_ICON_DIS1].ob_state &= ~DISABLED;
					DialogTree[CONF2_ICON_DIS1].ob_flags |= SELECTABLE;
					DialogTree[CONF2_ICON_DIS2].ob_state &= ~DISABLED;
					DialogTree[CONF2_ICON_DIS2].ob_flags |= SELECTABLE;
				}
				else
				{
					DialogTree[CONF2_ICON_DIS].ob_state &= ~SELECTED;
					DialogTree[CONF2_ICON_DIS1].ob_state |= DISABLED;
					DialogTree[CONF2_ICON_DIS1].ob_flags &= ~SELECTABLE;
					DialogTree[CONF2_ICON_DIS2].ob_state |= DISABLED;
					DialogTree[CONF2_ICON_DIS2].ob_flags &= ~SELECTABLE;
				}
				if( IConnect & ICONNECT_CONNECT )
				{
					DialogTree[CONF2_ICON_CON].ob_state |= SELECTED;
					DialogTree[CONF2_ICON_DIS].ob_state &= ~DISABLED;
					DialogTree[CONF2_ICON_DIS].ob_flags |= SELECTABLE;
				}
				else
				{
					DialogTree[CONF2_ICON_CON].ob_state &= ~SELECTED;
/*					DialogTree[CONF2_ICON_DIS].ob_state |= DISABLED;
					DialogTree[CONF2_ICON_DIS].ob_flags &= ~SELECTABLE;
					DialogTree[CONF2_ICON_DIS1].ob_state |= DISABLED;
					DialogTree[CONF2_ICON_DIS1].ob_flags &= ~SELECTABLE;
					DialogTree[CONF2_ICON_DIS2].ob_state |= DISABLED;
					DialogTree[CONF2_ICON_DIS2].ob_flags &= ~SELECTABLE;	*/
				}
				if( IConnect & ICONNECT_START )
				{
					DialogTree[CONF2_ICON_START].ob_state |= SELECTED;
					DialogTree[CONF2_ICON_CON].ob_state &= ~DISABLED;
					DialogTree[CONF2_ICON_CON].ob_flags |= SELECTABLE;
				}
				else
				{
					DialogTree[CONF2_ICON_START].ob_state &= ~SELECTED;
					DialogTree[CONF2_ICON_CON].ob_state |= DISABLED;
					DialogTree[CONF2_ICON_CON].ob_flags &= ~SELECTABLE;
					DialogTree[CONF2_ICON_DIS].ob_state |= DISABLED;
					DialogTree[CONF2_ICON_DIS].ob_flags &= ~SELECTABLE;
					DialogTree[CONF2_ICON_DIS1].ob_state |= DISABLED;
					DialogTree[CONF2_ICON_DIS1].ob_flags &= ~SELECTABLE;
					DialogTree[CONF2_ICON_DIS2].ob_state |= DISABLED;
					DialogTree[CONF2_ICON_DIS2].ob_flags &= ~SELECTABLE;
				}
				ltoa( ComPort, DialogTree[CONF2_COM].ob_spec.tedinfo->te_ptext, 10 );
				ltoa( DataPortL, DialogTree[CONF2_DATA_L].ob_spec.tedinfo->te_ptext, 10 );
				ltoa( DataPortH, DialogTree[CONF2_DATA_H].ob_spec.tedinfo->te_ptext, 10 );
				if( PasvFlag )
					DialogTree[CONF2_PASV_FLAG].ob_state |= SELECTED;
				else
					DialogTree[CONF2_PASV_FLAG].ob_state &= ~SELECTED;
				if( TransferType == TT_Auto )
					DialogTree[CONF2_TT_AUTO].ob_state |= SELECTED;
				if( TransferType == TT_Ascii )
					DialogTree[CONF2_TT_ASCII].ob_state |= SELECTED;
				if( TransferType == TT_Bin )
					DialogTree[CONF2_TT_BIN].ob_state |= SELECTED;
				if( TransferTypeAuto == TT_Ascii )
					DialogTree[CONF2_TT_ASCII_A].ob_state |= SELECTED;
				if( TransferTypeAuto == TT_Bin )
					DialogTree[CONF2_TT_BIN_A].ob_state |= SELECTED;
				if( KeepConnectionActive == 0 )
				{
					DialogTree[CONF2_NOOP].ob_state &= ~SELECTED;
					DialogTree[CONF2_NOOP_UP].ob_state |= DISABLED;
					DialogTree[CONF2_NOOP_UP].ob_flags &= ~TOUCHEXIT;
					DialogTree[CONF2_NOOP_DOWN].ob_state |= DISABLED;
					DialogTree[CONF2_NOOP_DOWN].ob_flags &= ~TOUCHEXIT;
					DialogTree[CONF2_NOOP_TIME].ob_state |= DISABLED;
					DialogTree[CONF2_NOOP_TIME].ob_flags &= ~EDITABLE;
				}
				else
				{
					DialogTree[CONF2_NOOP].ob_state |= SELECTED;
					DialogTree[CONF2_NOOP_UP].ob_state &= ~DISABLED;
					DialogTree[CONF2_NOOP_UP].ob_flags |= TOUCHEXIT;
					DialogTree[CONF2_NOOP_DOWN].ob_state &= ~DISABLED;
					DialogTree[CONF2_NOOP_DOWN].ob_flags |= TOUCHEXIT;
					DialogTree[CONF2_NOOP_TIME].ob_state &= ~DISABLED;
					DialogTree[CONF2_NOOP_TIME].ob_flags |= EDITABLE;
				}
				itoa( KeepConnectionActiveTime / 60, DialogTree[CONF2_NOOP_TIME].ob_spec.tedinfo->te_ptext, 10 );
				DialogTree[CONF2_OK].ob_state &= ~SELECTED;
				DialogTree[CONF2_CANCEL].ob_state &= ~SELECTED;
				break;
			}
			case	HNDL_OPEN:
				MT_wdlg_set_edit( Dialog, 0, Global );
				break;
			case	HNDL_CLSD:
				return( 0 );
			case	HNDL_EDIT:
			{
				WORD	a, b;
				if( IsMenuKey( Events->key, &a, &b ))
					return( 0 );
				break;
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
							MemErr( "Config" );
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
					MT_wdlg_set_uniconify( Dialog, ( GRECT *) &( Events->msg[4] ), NULL, TreeAddr[CONF2], Global );
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
		Obj &= 0x7fff;
		if( Obj == CONF2_COM_DOWN )
		{
			WORD Keystate, i;
			LONG	Port, a = 1;
			if( MT_wdlg_get_edit( Dialog, &i, Global ) == CONF2_COM )
				MT_wdlg_set_edit( Dialog, 0, Global );
			Keystate = (WORD) Kbshift( -1 );
			if( Keystate & KsSHIFT )
				a *= 10;
			if( Keystate & KsALT )
				a *= 100;
			Port = atol( DialogTree[CONF2_COM].ob_spec.tedinfo->te_ptext );
			if( Port - a < 0 )
				a = Port;
			Port -= a;
			ltoa( Port, DialogTree[CONF2_COM].ob_spec.tedinfo->te_ptext, 10 );
			DoRedraw( Dialog, &Rect, CONF2_COM_BOX, Global ); 
			MT_wdlg_set_edit( Dialog, CONF2_COM, Global );
		}

		if( Obj == CONF2_COM_UP )
		{
			WORD Keystate, i;
			LONG	Port, a = 1;
			if( MT_wdlg_get_edit( Dialog, &i, Global ) == CONF2_COM )
				MT_wdlg_set_edit( Dialog, 0, Global );
			Keystate = (WORD) Kbshift( -1 );
			if( Keystate & KsSHIFT )
				a *= 10;
			if( Keystate & KsALT )
				a *= 100;
			Port = atol( DialogTree[CONF2_COM].ob_spec.tedinfo->te_ptext );
			if( Port + a > 65535L )
				a = 65535L - Port;
			Port += a;
			ltoa( Port, DialogTree[CONF2_COM].ob_spec.tedinfo->te_ptext, 10 );
			DoRedraw( Dialog, &Rect, CONF2_COM_BOX, Global ); 
			MT_wdlg_set_edit( Dialog, CONF2_COM, Global );
		}
		
		if( Obj == CONF2_DATA_LUP )
		{
			WORD Keystate, i;
			LONG	Port, a = 1;
			if( MT_wdlg_get_edit( Dialog, &i, Global ) == CONF2_DATA_L )
				MT_wdlg_set_edit( Dialog, 0, Global );
			Keystate = (WORD) Kbshift( -1 );
			if( Keystate & KsSHIFT )
				a *= 10;
			if( Keystate & KsALT )
				a *= 100;
			Port = atol( DialogTree[CONF2_DATA_L].ob_spec.tedinfo->te_ptext );
			if( Port + a > 65535L )
				a = 65535L - Port;
			Port += a;
			if( Port > atol( DialogTree[CONF2_DATA_H].ob_spec.tedinfo->te_ptext ))
				Port = atol( DialogTree[CONF2_DATA_H].ob_spec.tedinfo->te_ptext );
			ltoa( Port, DialogTree[CONF2_DATA_L].ob_spec.tedinfo->te_ptext, 10 );
			DoRedraw( Dialog, &Rect, CONF2_DATA_L_BOX, Global );
			MT_wdlg_set_edit( Dialog, CONF2_DATA_L, Global );
		}

		if( Obj == CONF2_DATA_LDOWN )
		{
			WORD Keystate, i;
			LONG	Port, a = 1;
			if( MT_wdlg_get_edit( Dialog, &i, Global ) == CONF2_DATA_L )
				MT_wdlg_set_edit( Dialog, 0, Global );
			Keystate = (WORD) Kbshift( -1 );
			if( Keystate & KsSHIFT )
				a *= 10;
			if( Keystate & KsALT )
				a *= 100;
			Port = atol( DialogTree[CONF2_DATA_L].ob_spec.tedinfo->te_ptext );
			if( Port - a < 0 )
				a = Port;
			Port -= a;
			ltoa( Port, DialogTree[CONF2_DATA_L].ob_spec.tedinfo->te_ptext, 10 );
			DoRedraw( Dialog, &Rect, CONF2_DATA_L_BOX, Global ); 
			MT_wdlg_set_edit( Dialog, CONF2_DATA_L, Global );
		}

		if( Obj == CONF2_DATA_HUP )
		{
			WORD Keystate, i;
			LONG	Port, a = 1;
			if( MT_wdlg_get_edit( Dialog, &i, Global ) == CONF2_DATA_H )
				MT_wdlg_set_edit( Dialog, 0, Global );
			Keystate = (WORD) Kbshift( -1 );
			if( Keystate & KsSHIFT )
				a *= 10;
			if( Keystate & KsALT )
				a *= 100;
			Port = atol( DialogTree[CONF2_DATA_H].ob_spec.tedinfo->te_ptext );
			if( Port + a > 65535L )
				a = 65535L - Port;
			Port += a;
			ltoa( Port, DialogTree[CONF2_DATA_H].ob_spec.tedinfo->te_ptext, 10 );
			DoRedraw( Dialog, &Rect, CONF2_DATA_H_BOX, Global ); 
			MT_wdlg_set_edit( Dialog, CONF2_DATA_H, Global );
		}

		if( Obj == CONF2_DATA_HDOWN )
		{
			WORD Keystate, i;
			LONG	Port, a = 1;
			if( MT_wdlg_get_edit( Dialog, &i, Global ) == CONF2_DATA_H )
				MT_wdlg_set_edit( Dialog, 0, Global );
			Keystate = (WORD) Kbshift( -1 );
			if( Keystate & KsSHIFT )
				a *= 10;
			if( Keystate & KsALT )
				a *= 100;
			Port = atol( DialogTree[CONF2_DATA_H].ob_spec.tedinfo->te_ptext );
			if( Port - a < 0 )
				a = Port;
			Port -= a;
			if( Port < atol( DialogTree[CONF2_DATA_L].ob_spec.tedinfo->te_ptext ))
				Port = atol( DialogTree[CONF2_DATA_L].ob_spec.tedinfo->te_ptext );
			ltoa( Port, DialogTree[CONF2_DATA_H].ob_spec.tedinfo->te_ptext, 10 );
			DoRedraw( Dialog, &Rect, CONF2_DATA_H_BOX, Global ); 
			MT_wdlg_set_edit( Dialog, CONF2_DATA_H, Global );
		}

		if( Obj == CONF2_NOOP_UP )
		{
			WORD	Keystate, i;
			WORD	Time, a = 1;
			if( MT_wdlg_get_edit( Dialog, &i, Global ) == CONF2_NOOP_TIME )
				MT_wdlg_set_edit( Dialog, 0, Global );
			Keystate = (WORD) Kbshift( -1 );
			if( Keystate & KsSHIFT )
				a *= 10;
			if( Keystate & KsALT )
				a *= 100;
			Time = atoi( DialogTree[CONF2_NOOP_TIME].ob_spec.tedinfo->te_ptext );
			if( Time + a > 99 )
				a = 99 - Time;
			Time += a;
			itoa( Time, DialogTree[CONF2_NOOP_TIME].ob_spec.tedinfo->te_ptext, 10 );
			DoRedraw( Dialog, &Rect, CONF2_NOOP_BOX, Global ); 
			MT_wdlg_set_edit( Dialog, CONF2_NOOP_TIME, Global );
		}
		if( Obj == CONF2_NOOP_DOWN )
		{
			WORD	Keystate, i;
			WORD	Time, a = 1;
			if( MT_wdlg_get_edit( Dialog, &i, Global ) == CONF2_NOOP_TIME )
				MT_wdlg_set_edit( Dialog, 0, Global );
			Keystate = (WORD) Kbshift( -1 );
			if( Keystate & KsSHIFT )
				a *= 10;
			if( Keystate & KsALT )
				a *= 100;
			Time = atoi( DialogTree[CONF2_NOOP_TIME].ob_spec.tedinfo->te_ptext );
			if( Time - a < 1 )
				a = Time - 1;
			Time -= a;
			itoa( Time, DialogTree[CONF2_NOOP_TIME].ob_spec.tedinfo->te_ptext, 10 );
			DoRedraw( Dialog, &Rect, CONF2_NOOP_BOX, Global ); 
			MT_wdlg_set_edit( Dialog, CONF2_NOOP_TIME, Global );
		}

		if( Obj == CONF2_ICON_START || Obj == CONF2_ICON_DIS )
		{
			if( DialogTree[CONF2_ICON_DIS].ob_state & SELECTED )
			{
				DialogTree[CONF2_ICON_DIS1].ob_state &= ~DISABLED;
				DialogTree[CONF2_ICON_DIS1].ob_flags |= SELECTABLE;
				DialogTree[CONF2_ICON_DIS2].ob_state &= ~DISABLED;
				DialogTree[CONF2_ICON_DIS2].ob_flags |= SELECTABLE;
			}
			else
			{
				DialogTree[CONF2_ICON_DIS1].ob_state |= DISABLED;
				DialogTree[CONF2_ICON_DIS1].ob_flags &= ~SELECTABLE;
				DialogTree[CONF2_ICON_DIS2].ob_state |= DISABLED;
				DialogTree[CONF2_ICON_DIS2].ob_flags &= ~SELECTABLE;
			}

			if( DialogTree[CONF2_ICON_START].ob_state & SELECTED )
			{
				DialogTree[CONF2_ICON_CON].ob_state &= ~DISABLED;
				DialogTree[CONF2_ICON_CON].ob_flags |= SELECTABLE;
				DialogTree[CONF2_ICON_DIS].ob_state &= ~DISABLED;
				DialogTree[CONF2_ICON_DIS].ob_flags |= SELECTABLE;
			}
			else
			{
				DialogTree[CONF2_ICON_CON].ob_state |= DISABLED;
				DialogTree[CONF2_ICON_CON].ob_flags &= ~SELECTABLE;
				DialogTree[CONF2_ICON_DIS].ob_state |= DISABLED;
				DialogTree[CONF2_ICON_DIS].ob_flags &= ~SELECTABLE;
				DialogTree[CONF2_ICON_DIS1].ob_state |= DISABLED;
				DialogTree[CONF2_ICON_DIS1].ob_flags &= ~SELECTABLE;
				DialogTree[CONF2_ICON_DIS2].ob_state |= DISABLED;
				DialogTree[CONF2_ICON_DIS2].ob_flags &= ~SELECTABLE;
			}
			DoRedrawX( Dialog, &Rect, Global, CONF2_ICON_CON, CONF2_ICON_DIS, CONF2_ICON_DIS1, 
			           CONF2_ICON_DIS2, EDRX );
		}

		if( Obj == CONF2_NOOP )
		{
			if( DialogTree[CONF2_NOOP].ob_state & SELECTED )
			{
				DialogTree[CONF2_NOOP_UP].ob_state &= ~DISABLED;
				DialogTree[CONF2_NOOP_UP].ob_flags |= TOUCHEXIT;
				DialogTree[CONF2_NOOP_DOWN].ob_state &= ~DISABLED;
				DialogTree[CONF2_NOOP_DOWN].ob_flags |= TOUCHEXIT;
				DialogTree[CONF2_NOOP_TIME].ob_state &= ~DISABLED;
				DialogTree[CONF2_NOOP_TIME].ob_flags |= EDITABLE;
				MT_wdlg_set_edit( Dialog, CONF2_NOOP_TIME, Global );
			}
			else
			{
				WORD	i;
				if( MT_wdlg_get_edit( Dialog, &i, Global ) == CONF2_NOOP_TIME )
					MT_wdlg_set_edit( Dialog, 0, Global );
				DialogTree[CONF2_NOOP_UP].ob_state |= DISABLED;
				DialogTree[CONF2_NOOP_UP].ob_flags &= ~TOUCHEXIT;
				DialogTree[CONF2_NOOP_DOWN].ob_state |= DISABLED;
				DialogTree[CONF2_NOOP_DOWN].ob_flags &= ~TOUCHEXIT;
				DialogTree[CONF2_NOOP_TIME].ob_state |= DISABLED;
				DialogTree[CONF2_NOOP_TIME].ob_flags &= ~EDITABLE;
			}
			DoRedrawX( Dialog, &Rect, Global, CONF2_NOOP_DOWN, CONF2_NOOP_TIME, CONF2_NOOP_UP, EDRX );
		}

		if( Obj == CONF2_CANCEL )
			return( 0 );

		if( Obj == CONF2_OK )
		{
			if( DialogTree[CONF2_ICON_START].ob_state & SELECTED )
				IConnect |= ICONNECT_START;
			else
				IConnect &= ~ICONNECT_START;
			if( DialogTree[CONF2_ICON_CON].ob_state & SELECTED )
				IConnect |= ICONNECT_CONNECT;
			else
				IConnect &= ~ICONNECT_CONNECT;
			if( DialogTree[CONF2_ICON_DIS].ob_state & SELECTED )
			{
				if( DialogTree[CONF2_ICON_DIS1].ob_state & SELECTED )
				{
					IConnect |= ICONNECT_DISCONNECT;
					IConnect &= ~ICONNECT_DISCONNECT_LAST_SESSION;
				}
				if( DialogTree[CONF2_ICON_DIS2].ob_state & SELECTED )
					IConnect |= ICONNECT_DISCONNECT_LAST_SESSION;
			}
			else
			{
				IConnect &= ~ICONNECT_DISCONNECT;
				IConnect &= ~ICONNECT_DISCONNECT_LAST_SESSION;
			}

			ComPort = atoi( DialogTree[CONF2_COM].ob_spec.tedinfo->te_ptext );
			DataPortL = atoi( DialogTree[CONF2_DATA_L].ob_spec.tedinfo->te_ptext );
			DataPortH = atoi( DialogTree[CONF2_DATA_H].ob_spec.tedinfo->te_ptext );
			if( DialogTree[CONF2_PASV_FLAG].ob_state & SELECTED )
				PasvFlag = 1;
			else
				PasvFlag = 0;
			if( DialogTree[CONF2_TT_AUTO].ob_state & SELECTED )
				TransferType = TT_Auto;
			if( DialogTree[CONF2_TT_BIN].ob_state & SELECTED )
				TransferType = TT_Bin;
			if( DialogTree[CONF2_TT_ASCII].ob_state & SELECTED )
				TransferType = TT_Ascii;
			if( DialogTree[CONF2_TT_BIN_A].ob_state & SELECTED )
				TransferTypeAuto = TT_Bin;
			if( DialogTree[CONF2_TT_ASCII_A].ob_state & SELECTED )
				TransferTypeAuto = TT_Ascii;
			if( DialogTree[CONF2_NOOP].ob_state & SELECTED )
				KeepConnectionActive = 1;
			else
				KeepConnectionActive = 0;
			KeepConnectionActiveTime = atoi( DialogTree[CONF2_NOOP_TIME].ob_spec.tedinfo->te_ptext ) * 60;
			return( 0 );
		}

	}
	return( 1 );
}

WORD	ReadConfig()
{
#ifdef	V120
	XATTR	Xattr;
#else
	BYTE	Env[]="HOME", *EnvValue, *Filename;
#endif

	FILE	*File = NULL;

	nHotlist = 0;
	HotlistHost = 0L;
	HotlistPort = 0L;	
	HotlistUid = 0L;
	HotlistPwd = 0L;
	HotlistDir = 0L;
	HotlistComment = NULL;
	RxDir = 0L;
	TxDir = 0L;
	ConfFlag = 0;
	ComPort = 21;
	DataPortL = 2048;
	DataPort = DataPortL;
	DataPortH = 2148;
	BufLen = 8192L;
	PasvFlag = 1;
	ShowFlag = 0;
	TransferType = TT_Auto;
	TransferTypeAuto = TT_Bin;
	{
		WORD	i;
		for( i = 0; i < 32; i++ )
		{
			FtpWinPos[i].g_w = -1;
			FtpWinPos[i].g_h = -1;
		}
		FtpWinX = 0;
	}
	ChangeFilenameCase = 1;
	SortDirList = 0;
	FileSelectorFlag = 0;
	LogDir = NULL;
#ifdef	V110
	IConnect = 0;
	KeepConnectionActive = 0;
	KeepConnectionActiveTime = 240;
#endif
#ifdef	V120
	TransferPing = 0;
	AppendProtocol = 1;
#endif
#ifdef	V120
	GetFilenameConfig();
	if( DefaultPathConfig && Fxattr( 0, DefaultPathConfig, &Xattr ) == E_OK )
		File = fopen( DefaultPathConfig, "r" );
	else	if( HomePathConfig && Fxattr( 0, HomePathConfig, &Xattr ) == E_OK )
		File = fopen( HomePathConfig, "r" );
	else	if( PathConfig && Fxattr( 0, PathConfig, &Xattr ) == E_OK )
		File = fopen( PathConfig, "r" );
	if( File )
	{
		BYTE	*Puf;
#else
	EnvValue = getenv( Env );
	Filename = malloc(( EnvValue ? strlen( EnvValue ) * sizeof( BYTE ) : 0 ) + 1 + strlen( "Fiffi.inf" ) + 1 );
	if( !Filename )
		return( ENSMEM );
	if( EnvValue )
		strcpy( Filename, EnvValue );
	else
		strcpy( Filename, "" );
	if( EnvValue && Filename[ strlen( Filename ) - 1 ] != '\\' )
		strcat( Filename, "\\" );
	strcat( Filename, "Fiffi.inf" );
	if(( File = fopen( Filename, "r" )) != NULL )
	{
		XATTR	Xattr;
		BYTE	*Puf;
		Fxattr( 0, Filename, &Xattr );
#endif
		Puf = malloc( Xattr.size * sizeof( BYTE ));
		if( !Puf )
			return( ENSMEM );
		fread( Puf, sizeof( BYTE ), Xattr.size, File );
		fclose( File );
		if( strstr( Puf, "SaveConfigAuto = " ) != NULL )
			sscanf( strstr( Puf, "SaveConfigAuto = " ), "SaveConfigAuto = %i", &ConfFlag );
		if( strstr( Puf, "CommandPort = " ) != NULL )
			sscanf( strstr( Puf, "CommandPort = " ), "CommandPort = %i", &ComPort );
		if( strstr( Puf, "DataPortLow = " ) != NULL )
		{
			sscanf( strstr( Puf, "DataPortLow = " ), "DataPortLow = %i", &DataPortL );
			DataPort = DataPortL;
		}
		if( strstr( Puf, "DataPortHigh = " ) != NULL )
			sscanf( strstr( Puf, "DataPortHigh = " ), "DataPortHigh = %i", &DataPortH );
		if( strstr( Puf, "Passiv = " ) != NULL )
			sscanf( strstr( Puf, "Passiv = " ), "Passiv = %i", &PasvFlag );
		if( strstr( Puf, "ShowMessages = " ) != NULL )
			sscanf( strstr( Puf, "ShowMessages = " ), "ShowMessages = %i", &ShowFlag );
		if( strstr( Puf, "TransferType = " ) != NULL )
			sscanf( strstr( Puf, "TransferType = " ), "TransferType = %i", &TransferType );
		if( strstr( Puf, "TransferTypeAuto = " ) != NULL )
			sscanf( strstr( Puf, "TransferTypeAuto = " ), "TransferTypeAuto = %i", &TransferTypeAuto );
		if( strstr( Puf, "BufLen = " ) != NULL )
			sscanf( strstr( Puf, "BufLen = " ), "BufLen = %li", &BufLen );
		if( strstr( Puf, "ReceiveDirectory = " ) != NULL )
		{
			WORD	Len;
			Len = ( WORD ) ( strchr( strstr( Puf, "ReceiveDirectory = " ), '\n' ) - strstr( Puf, "ReceiveDirectory = " ) + 1 );
			RxDir = malloc( Len );
			if( !RxDir )
				return( ENSMEM );
			sscanf( strstr( Puf, "ReceiveDirectory = "), "ReceiveDirectory = %s\n", RxDir );
		}
		if( strstr( Puf, "TransferDirectory = " ) != NULL )
		{
			WORD	Len;
			Len = ( WORD ) ( strchr( strstr( Puf, "TransferDirectory = " ), '\n' ) - strstr( Puf, "TransferDirectory = " ) + 1 );
			TxDir = malloc( Len );
			if( !TxDir )
				return( ENSMEM );
			sscanf( strstr( Puf, "TransferDirectory = "), "TransferDirectory = %s\n", TxDir );
		}
		if( strstr( Puf, "LogDirectory = " ) != NULL )
		{
			WORD	Len;
			Len = ( WORD ) ( strchr( strstr( Puf, "LogDirectory = " ), '\n' ) - strstr( Puf, "LogDirectory = " ) + 1 );
			LogDir = malloc( Len );
			if( !LogDir )
				return( ENSMEM );
			sscanf( strstr( Puf, "LogDirectory = "), "LogDirectory = %s\n", LogDir );
		}

		{
			BYTE	*P = Puf;
			while( strstr( P, "FtpWindowPos = ") != NULL )
			{
				WORD	i, j;
				sscanf( P, "FtpWindowPos = %i,", &i );
				sscanf( P, "FtpWindowPos = %i,%i,%i,%i,%i\n", &j, &FtpWinPos[i].g_x, &FtpWinPos[i].g_y, &FtpWinPos[i].g_w, &FtpWinPos[i].g_h );
				P++;
			}
		}
		if( strstr( Puf, "ChangeFilenameCase = " ) != NULL )
			sscanf( strstr( Puf, "ChangeFilenameCase = " ), "ChangeFilenameCase = %i", &ChangeFilenameCase );
		if( strstr( Puf, "SortDirList = " ) != NULL )
			sscanf( strstr( Puf, "SortDirList = " ), "SortDirList = %i", &SortDirList );
		if( strstr( Puf, "FileSelector = " ) != NULL )
			sscanf( strstr( Puf, "FileSelector = " ), "FileSelector = %i", &FileSelectorFlag );
#ifdef	V110
		if( strstr( Puf, "IConnect = " ) != NULL )
			sscanf( strstr( Puf, "IConnect = " ), "IConnect = %i", &IConnect );
		if( strstr( Puf, "KeepConnectionActive = " ) != NULL )
			sscanf( strstr( Puf, "KeepConnectionActive = " ), "KeepConnectionActive = %i", &KeepConnectionActive );
		if( strstr( Puf, "KeepConnectionActiveTime = " ) != NULL )
			sscanf( strstr( Puf, "KeepConnectionActiveTime = " ), "KeepConnectionActiveTime = %i", &KeepConnectionActiveTime );
#endif
#ifdef	V120
		if( strstr( Puf, "TransferPing = " ) != NULL )
			sscanf( strstr( Puf, "TransferPing = " ), "TransferPing = %i", &TransferPing );
		if( strstr( Puf, "AppendProtocol = " ) != NULL )
			sscanf( strstr( Puf, "AppendProtocol = " ), "AppendProtocol = %i", &AppendProtocol );
#endif
		if( strstr( Puf, "SuffixList =" ) != NULL )
		{
			BYTE	*Tmp = strstr( Puf, "SuffixList =\n" ) + strlen( "SuffixList =\n" );
			SUF_ITEM	*TmpItem;
			WORD	Len;
			while( strncmp( Tmp, "\n= SuffixList", strlen( "\n= SuffixList" )) != 0 )
			{
				TmpItem = malloc( sizeof( SUF_ITEM ));
				if( !TmpItem )
					return( ENSMEM );
				Len = ( WORD ) ( strchr( strstr( Tmp, "Suffix = " ), '\n' ) - strstr( Tmp, "Suffix = " ) + 1 );
				TmpItem->str = malloc( Len );
				if( !TmpItem->str )
					return( ENSMEM );
				sscanf(( Tmp = strstr( Tmp, "Suffix = " )), "Suffix = %s", TmpItem->str );
				sscanf(( Tmp = strstr( Tmp, "Mode = " )), "Mode = %i", &TmpItem->mode );
				TmpItem->next = SuffixList;
				SuffixList = TmpItem;
				Tmp = strchr( Tmp, '\n' );
			}
		}
		if( strstr( Puf, "Hotlist =" ) != NULL )
		{
			BYTE	*Tmp = strstr( Puf, "Hotlist =\n" ) + strlen( "Hotlist =\n" );
			BYTE	*End = strstr( Puf, "= Hotlist\n" );
			BYTE	Comment1[64], Comment2[64], Comment3[64], Comment4[64];
			WORD	Len, i;
			nHotlist = 0;
			while( Tmp < End && ( Tmp = strstr( Tmp, "Host = " )) != NULL )
			{
				Tmp += strlen( "Host = " );
				nHotlist++;
			}
#ifdef	V120
			HotlistName = malloc( nHotlist * sizeof( BYTE * ));
			if( !HotlistName )
				return( ENSMEM );
#endif
			HotlistHost = malloc( nHotlist * sizeof( BYTE * ));
			HotlistPort = malloc( nHotlist * sizeof( WORD ));
			HotlistUid = malloc( nHotlist * sizeof( BYTE * ));
			HotlistPwd = malloc( nHotlist * sizeof( BYTE * ));
			HotlistDir = malloc( nHotlist * sizeof( BYTE * ));
			HotlistComment = malloc( nHotlist * sizeof( BYTE * ));
			if( !HotlistHost || !HotlistPort || !HotlistUid || 
			    !HotlistPwd || !HotlistPwd || !HotlistComment )
				return( ENSMEM );
			Tmp = strstr( Puf, "Hotlist =\n" ) + strlen( "Hotlist =\n" );

			for( i = 0; i < nHotlist; i++ )
			{
				BYTE	*End = strstr( Tmp + 1, "Host = " );
				if( !End )
					End = strstr( Tmp + 1, "= Hotlist" );
				if( strstr( Tmp, "Host = " ) != NULL && strstr( Tmp, "Host = " ) < End )
				{
					Tmp = strstr( Tmp, "Host = " );
					Len = ( WORD ) ( strchr( strstr( Tmp, "Host = " ), '\n' ) - strstr( Tmp, "Host = " ) + 1 );
					HotlistHost[i] = malloc( Len );
					if( !HotlistHost[i] )
						return( ENSMEM );
					sscanf( Tmp, "Host = %s", HotlistHost[i] );
				}
				else
					HotlistHost[i] = NULL;
#ifdef	V120
				if( strstr( Tmp, "Name = " ) != NULL && strstr( Tmp, "Name = " ) < End )
				{
					Tmp = strstr( Tmp, "Name = " );
					Len = ( WORD ) ( strchr( strstr( Tmp, "Name = " ), '\n' ) - strstr( Tmp, "Name = " ) + 1 );
					HotlistName[i] = malloc( Len );
					if( !HotlistName[i] )
						return( ENSMEM );
					sscanf( Tmp, "Name = %[^'\n''\r']", HotlistName[i] );
				}
				else	if( HotlistHost[i] )
					HotlistName[i] = strdup( HotlistHost[i] );
				else
					HotlistName[i] = NULL;
				
#endif
				if( strstr( Tmp, "Port = " ) != NULL && strstr( Tmp, "Port = " ) < End )
				{
					Tmp = strstr( Tmp, "Port = " );
					sscanf( Tmp, "Port = %u", &HotlistPort[i] );
				}
				if( strstr( Tmp, "Uid = " ) != NULL && strstr( Tmp, "Uid = " ) < End )
				{
					Tmp = strstr( Tmp, "Uid = " );
					Len = ( WORD ) ( strchr( strstr( Tmp, "Uid = " ), '\n' ) - strstr( Tmp, "Uid = " ) + 1 );
					HotlistUid[i] = malloc( Len );
					if( !HotlistUid[i] )
						return( ENSMEM );
					sscanf( Tmp, "Uid = %s", HotlistUid[i] );
				}
				else
					HotlistUid[i] = NULL;
				if( strstr( Tmp, "Pwd = " ) != NULL && strstr( Tmp, "Pwd = " ) < End )
				{
					WORD	j;
					Tmp = strstr( Tmp, "Pwd = " );
					Len = ( WORD ) ( strchr( strstr( Tmp, "Pwd = " ), '\n' ) - strstr( Tmp, "Pwd = " ) + 1 );
					HotlistPwd[i] = malloc( Len );
					if( !HotlistPwd[i] )
						return( ENSMEM );
					sscanf( Tmp, "Pwd = %s", HotlistPwd[i] );
					for( j = 0; j < strlen( HotlistPwd[i] ); j++ )
						HotlistPwd[i][j] = HotlistPwd[i][j] ^ 255;
				}
				else
					HotlistPwd[i] = NULL;
				if( strstr( Tmp, "Dir = " ) != NULL && strstr( Tmp, "Dir = " ) < End )
				{
					Tmp = strstr( Tmp, "Dir = " );
					Len = ( WORD ) ( strchr( strstr( Tmp, "Dir = " ), '\n' ) - strstr( Tmp, "Dir = " ) + 1 );
					HotlistDir[i] = malloc( Len );
					if( !HotlistDir[i] )
						return( ENSMEM );
					sscanf( Tmp, "Dir = %s", HotlistDir[i] );
				}
				else
					HotlistDir[i] = NULL;
				memset( Comment1, 0, 64 );
				memset( Comment2, 0, 64 );
				memset( Comment3, 0, 64 );
				memset( Comment4, 0, 64 );
				if( strstr( Tmp, "Comment1 = " ) != NULL && strstr( Tmp, "Comment1 = " ) < End )
				{
					Tmp = strstr( Tmp, "Comment1 = " );
					Len = ( WORD ) ( strchr( Tmp, '\n' ) - Tmp + 1 );
					sscanf( Tmp, "Comment1 = %[^'\n']", Comment1 );
				}
				if( strstr( Tmp, "Comment2 = " ) != NULL && strstr( Tmp, "Comment2 = " ) < End )
				{
					Tmp = strstr( Tmp, "Comment2 = " );
					Len = ( WORD ) ( strchr( Tmp, '\n' ) - Tmp + 1 );
					sscanf( Tmp, "Comment2 = %[^'\n']", Comment2 );
				}
				if( strstr( Tmp, "Comment3 = " ) != NULL && strstr( Tmp, "Comment3 = " ) < End )
				{
					Tmp = strstr( Tmp, "Comment3 = " );
					Len = ( WORD ) ( strchr( Tmp, '\n' ) - Tmp + 1 );
					sscanf( Tmp, "Comment3 = %[^'\n']", Comment3 );
				}
				if( strstr( Tmp, "Comment4 = " ) != NULL && strstr( Tmp, "Comment4 = " ) < End )
				{
					Tmp = strstr( Tmp, "Comment4 = " );
					Len = ( WORD ) ( strchr( Tmp, '\n' ) - Tmp + 1 );
					sscanf( Tmp, "Comment4 = %[^'\n']", Comment4 );
				}
				if( strlen( Comment1 ) + strlen( Comment2 ) + strlen( Comment3 ) + strlen( Comment4 ))
				{
					HotlistComment[i] = malloc( strlen( Comment1 ) + strlen( Comment2 ) + strlen( Comment3 ) + strlen( Comment4 ) + 5 );
					if( !HotlistComment[i] )
						return( ENSMEM );
					strcpy( HotlistComment[i], Comment1 );
					strcat( HotlistComment[i], "\n" );
					strcat( HotlistComment[i], Comment2 );
					strcat( HotlistComment[i], "\n" );
					strcat( HotlistComment[i], Comment3 );
					strcat( HotlistComment[i], "\n" );
					strcat( HotlistComment[i], Comment4 );
				}
				else
					HotlistComment[i] = NULL;

				Tmp = strstr( Tmp, "Host = " );
			}
		}
		free( Puf );
	}
#ifndef	V120
	free( Filename );
#endif
	return( E_OK );
}

WORD	WriteConfig()
{
#ifndef	V120
	BYTE	Env[]="HOME", *EnvValue, *Filename;
#endif
	FILE	*File = NULL;
	WORD	i, Msg[8];
	SUF_ITEM	*Item;
	
#ifdef	V120
	GetFilenameConfig();
	if( DefaultPathConfig )
		File = fopen( DefaultPathConfig, "w" );
	else	if( HomePathConfig )
		File = fopen( HomePathConfig, "w" );
	else
		File = fopen( PathConfig, "w" );

	if( !File )
		return( 0 );
#else
	EnvValue = getenv( Env );
	Filename = malloc(( EnvValue ? strlen( EnvValue ) * sizeof( BYTE ) : 0 ) + 1 + strlen( "Fiffi.inf" ) + 1 );
	if( !Filename )
		return( ENSMEM );
	if( EnvValue )
		strcpy( Filename, EnvValue );
	else
		strcpy( Filename, "" );
	if( EnvValue && Filename[ strlen( Filename ) - 1 ] != '\\' )
		strcat( Filename, "\\" );
	strcat( Filename, "Fiffi.inf" );
	if(( File = fopen( Filename, "w+" )) == NULL )
	{
		free( Filename );
		return( 0 );
	}
#endif
	fprintf( File, "SaveConfigAuto = %i\n", ConfFlag );
	fprintf( File, "CommandPort = %i\n", ComPort );
	fprintf( File, "DataPortLow = %i\n", DataPortL );
	fprintf( File, "DataPortHigh = %i\n", DataPortH );
	fprintf( File, "Passiv = %i\n", PasvFlag );
	fprintf( File, "ShowMessages = %i\n", ShowFlag );
	fprintf( File, "TransferType = %i\n", TransferType );
	fprintf( File, "TransferTypeAuto = %i\n", TransferTypeAuto );
	fprintf( File, "BufLen = %li\n", BufLen );
	if( RxDir )
		fprintf( File, "ReceiveDirectory = %s\n", RxDir );
	if( TxDir )
		fprintf( File, "TransferDirectory = %s\n", TxDir );
	if( LogDir )
		fprintf( File, "LogDirectory = %s\n", LogDir );

	for( i = 0; i < 32; i++ )
		if( FtpWinPos[i].g_w != -1 && FtpWinPos[i].g_h != -1 )
			fprintf( File, "FtpWindowPos = %i,%i,%i,%i,%i\n", i, FtpWinPos[i].g_x, FtpWinPos[i].g_y, FtpWinPos[i].g_w, FtpWinPos[i].g_h );

	fprintf( File, "ChangeFilenameCase = %i\n", ChangeFilenameCase );
	fprintf( File, "SortDirList = %i\n", SortDirList );
	fprintf( File, "FileSelector = %i\n", FileSelectorFlag );
#ifdef	V110
	fprintf( File, "IConnect = %i\n", IConnect );
	fprintf( File, "KeepConnectionActive = %i\n", KeepConnectionActive );
	fprintf( File, "KeepConnectionActiveTime = %i\n", KeepConnectionActiveTime );
#endif
#ifdef	V120
	fprintf( File, "TransferPing = %i\n", TransferPing );
	fprintf( File, "AppendProtocol = %i\n", AppendProtocol );
#endif
	Item = SuffixList;
	if( Item )
	{
		fprintf( File, "SuffixList =\n" );
		while( Item )
		{
			fprintf( File, "Suffix = %s\n", Item->str );
			fprintf( File, "Mode = %i\n", Item->mode );
			Item = Item->next;
		}
		fprintf( File, "= SuffixList\n" );
	}

	if( nHotlist )
	{
		fprintf( File, "Hotlist =\n" );
		for( i = 0; i < nHotlist; i++ )
		{
			fprintf( File, "Host = %s\n", HotlistHost[i] );
#ifdef	V120
			fprintf( File, "Name = %s\n", HotlistName[i] );
#endif
			fprintf( File, "Port = %u\n", HotlistPort[i] );
			if( HotlistUid[i] && strlen( HotlistUid[i] ))
				fprintf( File, "Uid = %s\n", HotlistUid[i] );
			if( HotlistPwd[i] && strlen( HotlistPwd[i] ))
			{
				WORD	j;
				BYTE	*Crypt = strdup( HotlistPwd[i] );
				if( !Crypt )
					return( ENSMEM );
				for( j = 0; j < strlen( HotlistPwd[i] ); j++ )
					Crypt[j] = Crypt[j] ^ 255;
				fprintf( File, "Pwd = %s\n", Crypt );
				free( Crypt );
			}
			if( HotlistDir[i] && strlen( HotlistDir[i] ))
				fprintf( File, "Dir = %s\n", HotlistDir[i] );
			if( HotlistComment[i] && strlen( HotlistComment[i] ))
			{
				BYTE	Comment1[64], Comment2[64], Comment3[64], Comment4[64];
				memset( Comment1, 0, 64 );
				memset( Comment2, 0, 64 );
				memset( Comment3, 0, 64 );
				memset( Comment4, 0, 64 );
				sscanf( HotlistComment[i], "%[^'\n']%*c%[^'\n']%*c%[^'\n']%*c%s", Comment1, Comment2, Comment3, Comment4 );
				if( Comment1[0] )
					fprintf( File, "Comment1 = %s\n", Comment1 );
				if( Comment2[0] )
					fprintf( File, "Comment2 = %s\n", Comment2 );
				if( Comment3[0] )
					fprintf( File, "Comment3 = %s\n", Comment3 );
				if( Comment4[0] )
					fprintf( File, "Comment4 = %s\n", Comment4 );
			}	
		}
		fprintf( File, "= Hotlist\n" );
	}

	fclose( File );
#ifndef	V120
	Msg[0] = SH_WDRAW;
	Msg[1] = AppId;
	Msg[2] = 0;
	Msg[3] = *Filename - 'A';
	MT_shel_write( SHW_BROADCAST, 0, 0, ( BYTE * ) Msg, 0L, Global );
#endif
	return( 1 );
}

#ifdef	V120
static void	GetFilenameConfig( void )
{
	BYTE	*Home;

	if( HomePathConfig )
		free( HomePathConfig );
	if( DefaultPathConfig )
		free( DefaultPathConfig );
	HomePathConfig = NULL;
	DefaultPathConfig = NULL;

	Home = getenv( "HOME" );
	if( Home )
	{
		XATTR	Xattr;
		HomePathConfig = malloc( strlen( Home ) + 1 + strlen( "Fiffi.inf" ) + 1 );
		if( !HomePathConfig )
			return;

		strcpy( HomePathConfig, Home );
		if( HomePathConfig[ strlen( HomePathConfig ) -1 ] != '\\' )
			strcat( HomePathConfig, "\\" );

		DefaultPathConfig = malloc( strlen( HomePathConfig ) + strlen( "defaults\\" ) + strlen( "Fiffi.inf" ) + 1 );
		strcpy( DefaultPathConfig, HomePathConfig );
		strcat( DefaultPathConfig, "defaults\\" );

		if( Fxattr( 0, DefaultPathConfig, &Xattr ) == E_OK )
			strcat( DefaultPathConfig, "Fiffi.inf" );
		else
		{
			free( DefaultPathConfig );
			DefaultPathConfig = NULL;
		}
		strcat( HomePathConfig, "Fiffi.inf" );
	}
}
#endif