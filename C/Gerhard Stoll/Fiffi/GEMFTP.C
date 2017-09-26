#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<atarierr.h>
#include <STDDEF.H>
#include	<TOS.H>
#include	<MT_AES.H>
#include <VDI.H>
#include <STDLIB.H>
#include <STDIO.H>
#include	<STRING.H>
#include <CTYPE.H>
#include <SETJMP.H>
#include	<TIME.H>
#include	<MATH.H>

#include <socket.h>
#include	<sockerr.h>
#include <sockinit.h>
#include <inet.h>
#ifdef	V120
#include	<usis.h>
#endif
#include	<AV.H>
#ifdef	DHST
#include	<DHST.h>
#endif
#ifdef	V110
#include	<ICON_MSG.H>
#endif
#ifdef	GEMScript
#include	<gscript.h>
#endif
#ifdef	NAES
#include	"Thread.h"
#endif
#include "ADAPTRSC.h"
#include "dragdrop.h"
#include "mapkey.h"
#include "edscroll.h"

#include "main.h"
#include	"Config.h"
#include "GemFtp.h"
#include	"Window.h"
#include	"Ftp.h"
#include	"List.h"
#include	"Url.h"
#include "Fiffi.h"
#ifdef	KEY
#include	"HotList.h"
#endif
#ifdef	V110
#include	"DD.h"
#endif
#ifdef	RECURSIV
#include	"Recursiv.h"
#endif

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern WORD	magic_version;
extern LONG	magic_date;
extern WORD Global[15];
extern WORD	PwChar, PhChar, PwBox, PhBox;
extern BYTE *RxDir;
extern BYTE	*TxDir;
extern WORD	FileSelectorFlag;
extern UWORD	DataPort;
extern UWORD	DataPortL;
extern UWORD	DataPortH;
extern UWORD	TransferType;
extern WORD	AvAppId;
#ifdef V110
volatile	extern WORD	IConnectStarted;
#endif
#ifdef	GEMScript
volatile extern WORD GsConnection;
#endif
extern WORD	AesFlags;
extern volatile WORD	SortDirList;

/*-----------------------------------------------------------------------------*/
/* Globale Variablen                                                           */
/*-----------------------------------------------------------------------------*/
ThreadInfoItem	*ThreadInfoGemFtp = NULL;
volatile	WORD	ThreadInfoItemSem = 0;
WORD		ChangeFilenameCase;
GRECT		FtpWinPos[32];
volatile	ULONG	FtpWinX;
#ifdef	V110
volatile	WORD	IConnect;
#endif
#ifdef	V120
volatile WORD	TransferPing;
#endif
#ifdef	NAES
WORD	GemFtpThreadAppId;
#endif

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
WORD			ThreadGemFtp( GemFtp *ThreadPara );
void			delThreadInfoGemFtp( WORD AppId, WORD Global[15] );
LONG cdecl	MainGemFtp( BYTE *Url );
WORD cdecl	HandleFtpDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD );
void			SetFtpSize( DIALOG *Dialog, GRECT *WinRect, GemFtp *GF );
WORD cdecl	SetFtpItem( LIST_BOX *Box, OBJECT *Tree, LBOX_ITEM *Item, WORD Index, void *user_data, GRECT *Rect, WORD Offset );
WORD cdecl	SetFtpDir( LIST_BOX *Box, OBJECT *Tree, LBOX_ITEM *Item, WORD Index, void *user_data, GRECT *Rect, WORD Offset );
void cdecl	SlctFtpItem( LIST_BOX *FtpList, OBJECT *DialogTree, LBOX_ITEM *Item, void *UD, WORD ObjIndex, WORD LastState );
WORD cdecl	HandleTrDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD );
WORD cdecl	HandleSeCancelDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD );
void			TrDialogHide( OBJECT *DialogTree, WORD	F );
WORD cdecl	HandleTrCancelDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD );
WORD cdecl	HandleDdDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD );
WORD cdecl	HandleFileDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD );
DIALOG		*OpenFileDialog( OBJECT *DialogTree, BYTE *Title, XTED *Xted, char *Tmplt, char *Txt, WORD Global[15], BYTE *File, BYTE *Path );
void			WriteStatusGemFtp( DIALOG *Dialog, BYTE *InfoPuf, BYTE *Text, WORD Global[15] );
void			AppendStatusGemFtp( DIALOG *Dialog, BYTE *InfoPuf, BYTE *Text, WORD Global[15] );
void			DisableButton( DIALOG *Dialog, OBJECT *DialogTree, WORD Global[15] );
void			EnableButton( DIALOG *Dialog, OBJECT *DialogTree, WORD Global[15] );
void			CalcTimeRateBar( time_t TStart, time_t TStartAll, time_t TAc, LONG Size, LONG SizeIs, LONG SizeAll, LONG SizeIsAll, DIALOG *Dialog, OBJECT *DialogTree, LONG FileOffset, LONG FileOffsetAll, WORD Global[15] );
void			Decimal( LONG Z, BYTE *Puf );
void			UnSetnFtpWin( WORD Id );
WORD			SetnFtpWin( void );
void			SetFtpPos( WORD Id, GRECT *Pos );
WORD			GetFtpPos( WORD Id, GRECT *Pos );
#ifdef	DHST
static 		LONG	SearchDhstCookie( void );
#endif
void			CopyFtpDirPath( GemFtp *GF );
#ifdef	GEMScript
WORD	cdecl	HandleGemScriptDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD );
#endif
#ifdef	V120
static void	ShortFileStrCpy( BYTE *Dest, BYTE *Source, WORD Len );
#endif

/* Objekte der Listbox */
#define	NO_FTP_DIR_V	64
#define	NO_FTP_DIR_H	128
#define	FtpWinMinW		32
#define	FtpWinMinH		22

WORD	FtpDirCtrl[9] = { FTP_DIR_BOX, FTP_DIR_UP, FTP_DIR_DOWN, FTP_DIR_BACK_V, FTP_DIR_SL_V, FTP_DIR_LEFT, FTP_DIR_RIGHT, FTP_DIR_BACK_H, FTP_DIR_SL_H };

WORD	FtpDirObjs[NO_FTP_DIR_V] = { FTP_DIR_0, FTP_DIR_1, FTP_DIR_2, FTP_DIR_3, 
    	FTP_DIR_4, FTP_DIR_5, FTP_DIR_6, FTP_DIR_7, FTP_DIR_8, FTP_DIR_9, 
    	FTP_DIR_10, FTP_DIR_11, FTP_DIR_12, FTP_DIR_13, FTP_DIR_14, FTP_DIR_15,
    	FTP_DIR_16, FTP_DIR_17, FTP_DIR_18, FTP_DIR_19, FTP_DIR_20, FTP_DIR_21, 
    	FTP_DIR_22, FTP_DIR_23, FTP_DIR_24, FTP_DIR_25, FTP_DIR_26, FTP_DIR_27,
    	FTP_DIR_28, FTP_DIR_29, FTP_DIR_30, FTP_DIR_31, FTP_DIR_32, FTP_DIR_33,
    	FTP_DIR_34, FTP_DIR_35, FTP_DIR_36, FTP_DIR_37, FTP_DIR_38, FTP_DIR_39,
    	FTP_DIR_40, FTP_DIR_41, FTP_DIR_42, FTP_DIR_43, FTP_DIR_44, FTP_DIR_45,
    	FTP_DIR_46, FTP_DIR_47, FTP_DIR_48, FTP_DIR_49, FTP_DIR_50, FTP_DIR_51,
    	FTP_DIR_52, FTP_DIR_53, FTP_DIR_54, FTP_DIR_55, FTP_DIR_56, FTP_DIR_57,
    	FTP_DIR_58, FTP_DIR_59, FTP_DIR_60, FTP_DIR_61, FTP_DIR_62, FTP_DIR_63 };
WORD	FtpDirIcons[NO_FTP_DIR_V] = { FTP_ICON_0, FTP_ICON_1, FTP_ICON_2, FTP_ICON_3, 
    	FTP_ICON_4, FTP_ICON_5, FTP_ICON_6, FTP_ICON_7, FTP_ICON_8, FTP_ICON_9, 
    	FTP_ICON_10, FTP_ICON_11, FTP_ICON_12, FTP_ICON_13, FTP_ICON_14, FTP_ICON_15,
    	FTP_ICON_16, FTP_ICON_17, FTP_ICON_18, FTP_ICON_19, FTP_ICON_20, FTP_ICON_21, 
    	FTP_ICON_22, FTP_ICON_23, FTP_ICON_24, FTP_ICON_25, FTP_ICON_26, FTP_ICON_27,
    	FTP_ICON_28, FTP_ICON_29, FTP_ICON_30, FTP_ICON_31, FTP_ICON_32, FTP_ICON_33,
    	FTP_ICON_34, FTP_ICON_35, FTP_ICON_36, FTP_ICON_37, FTP_ICON_38, FTP_ICON_39,
    	FTP_ICON_40, FTP_ICON_41, FTP_ICON_42, FTP_ICON_43, FTP_ICON_44, FTP_ICON_45,
    	FTP_ICON_46, FTP_ICON_47, FTP_ICON_48, FTP_ICON_49, FTP_ICON_50, FTP_ICON_51,
    	FTP_ICON_52, FTP_ICON_53, FTP_ICON_54, FTP_ICON_55, FTP_ICON_56, FTP_ICON_57,
    	FTP_ICON_58, FTP_ICON_59, FTP_ICON_60, FTP_ICON_61, FTP_ICON_62, FTP_ICON_63 };

#define	FtpWinMaxW		( NO_FTP_DIR_H + 22 )
#define	FtpWinMaxH		( NO_FTP_DIR_V + 5 )

/*-----------------------------------------------------------------------------*/
/* Neuen Thread fÅr GemFtp anlegen                                             */
/* Funktionsergebnis: 0: Fehler aufgetreten  Zeiger auf Thread-Struktur        */
/*-----------------------------------------------------------------------------*/
WORD	newGemFtp( BYTE *Url, WORD Global[15] )
{
	THREADINFO Thread;
	WORD	AppId;

	while( ThreadInfoItemSem )
		MT_appl_yield( Global );
	ThreadInfoItemSem = 1;

	Thread.proc = (void *) MainGemFtp;
	Thread.user_stack = NULL;
	Thread.stacksize = 16384L;
	Thread.mode = 0;
	Thread.res1 = 0L;

#ifdef	NAES
	if( AesFlags & GAI_MAGIC )
		AppId = MT_shel_write( SHW_THR_CREATE, 1, 0, (char *) &Thread, ( void * ) Url, Global );
	else
	{
		if( DOThread(( threadfun * ) MainGemFtp, ( long ) Url, 16384L, "Fiffi" ) >= 0 ) 
		{
			Psignal( SIGUSR1, WaitThreadAppId );
			Psigpause( 0L );
			AppId = GemFtpThreadAppId;
		}
		else
			AppId = 0;
	}
#else
	if( magic_version && magic_date >= 0x19960401L )
		AppId = MT_shel_write( SHW_THR_CREATE, 1, 0, (char *) &Thread, (void *) Url, Global );
	else
		AppId = 0;
#endif

	if( AppId != 0 )
	{
		ThreadInfoItem	*Tmp;
		Tmp = malloc( sizeof( ThreadInfoGemFtp ));
		if( !Tmp )
		{
			ThreadInfoItemSem = 0;
			return( ENSMEM );
		}
		Tmp->next = ThreadInfoGemFtp;
		ThreadInfoGemFtp = Tmp;
		ThreadInfoGemFtp->AppId = AppId;
#ifdef DEBUG
	DebugMsg( Global, "NewGemFtp [AppId = %i] = %i\n", Global[2], AppId );
	DebugMsg( Global, "\tThreadInfoGemFtp = %lx\n", Tmp );
#endif

#ifdef	GEMScript
		ThreadInfoGemFtp->MainWinId = -1;
		ThreadInfoGemFtp->Url = strdup( Url );
		if( !ThreadInfoGemFtp->Url )
		{
			ThreadInfoItemSem = 0;
			return( ENSMEM );
		}
#endif
	}
	ThreadInfoItemSem = 0;
	return( AppId );
}

/*-----------------------------------------------------------------------------*/
/* PrÅft, ob noch ein Thread GemFtp existiert                                  */
/* Funktionsergebnis: 0: Kein Thread  1: Es gibt noch mindestens einen Thread  */
/*-----------------------------------------------------------------------------*/
WORD	existThreadInfoGemFtp( void )
{
	if( ThreadInfoGemFtp )
		return( 1 );
	else
		return( 0 );
}

/*-----------------------------------------------------------------------------*/
/* Liefert die AppId des Eintrags n zurÅck                                     */
/*-----------------------------------------------------------------------------*/
WORD	GetThreadAppId( WORD n, WORD Global[15] )
{
	while( ThreadInfoItemSem )
		MT_appl_yield( Global );
	ThreadInfoItemSem = 1;
	{
		WORD	i = 0;
		ThreadInfoItem	*tmp = ThreadInfoGemFtp;
		while( tmp && i < n )
		{
			tmp = tmp->next;
			i++;
		}
		ThreadInfoItemSem = 0;
		if( !tmp )
			return( -1 );
		return( tmp->AppId );
	}
}

#ifdef	GEMScript
BYTE	*GetThreadUrl( WORD n, WORD Global[15] )
{
	while( ThreadInfoItemSem )
		MT_appl_yield( Global );
	ThreadInfoItemSem = 1;
	{
		WORD	i = 0;
		ThreadInfoItem *tmp = ThreadInfoGemFtp;
		while( tmp && i < n )
		{
			tmp = tmp->next;
			i++;
		}
	ThreadInfoItemSem = 0;
	if( !tmp )
		return( NULL );
	return( tmp->Url );
	}
}

void	SetThreadMainWindow( WORD AppId, WORD WinId )
{
	while( ThreadInfoItemSem )
		MT_appl_yield( Global );
	ThreadInfoItemSem = 1;
	{
		ThreadInfoItem *tmp = ThreadInfoGemFtp;
		while( tmp )
		{
			if( tmp->AppId == AppId )
			{
				tmp->MainWinId = WinId;
				break;
			}
			tmp = tmp->next;
		}
	}
	ThreadInfoItemSem = 0;
}
WORD	GetThreadMainWindow( WORD AppId )
{
	while( ThreadInfoItemSem )
		MT_appl_yield( Global );
	ThreadInfoItemSem = 1;
	{
		ThreadInfoItem *tmp = ThreadInfoGemFtp;
		while( tmp )
		{
			if( tmp->AppId == AppId )
				break;
			tmp = tmp->next;
		}
		ThreadInfoItemSem = 0;
		if( tmp )
			return( tmp->MainWinId );
		else
			return( -1 );
	}
}
#endif

/*-----------------------------------------------------------------------------*/
/* Lîscht die Thread-Struktur eines GemFtps                                    */
/* Funktionsergebnis: -                                                        */
/*-----------------------------------------------------------------------------*/
void	delThreadInfoGemFtp( WORD AppId, WORD Global[15] )
{
	ThreadInfoItem 	*o, *p;
	ThreadInfoItem	*del;

	while( ThreadInfoItemSem )
		MT_appl_yield( Global );
	ThreadInfoItemSem = 1;
	del = ThreadInfoGemFtp;
	while( del && del->AppId != AppId )
	{
		del = del->next;
	}
	if( !del )
	{
		ThreadInfoItemSem = 0;
		return;
	}

	p = ThreadInfoGemFtp;
	o = ThreadInfoGemFtp;
	while( p )
	{
		if( p == del )
			break;
		o = p;
		p = p->next;
	}
#ifdef DEBUG
	DebugMsg( Global, "del ThreadInfoGemFtp = %lx\n", del );
	DebugMsg( Global, "\tThreadInfoGemFtp = %lx\n", ThreadInfoGemFtp );
#endif
	if( del == ThreadInfoGemFtp )
	{
		ThreadInfoGemFtp = ThreadInfoGemFtp->next;
#ifdef DEBUG
	DebugMsg( Global, "New ThreadInfoGemFtp = %lx\n", ThreadInfoGemFtp );
#endif
	}
	else
	{
		o->next = del->next;
	}
#ifdef	GEMScript
	free( del->Url );
#endif
	free( del );
	ThreadInfoItemSem = 0;
}

/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
LONG cdecl	MainGemFtp( BYTE *Url )
{
	WORD		AppId;
	GemFtp	GF;

	GF.Url = Url;
#ifdef DEBUG
	DebugMsg( Global, "GemFtp gestartet Url = %s\n", Url );
#endif
	AppId = MT_appl_init( GF.Global );
#ifdef	NAES
		if(( AesFlags & GAI_MAGIC ) == 0 )
	{
		GemFtpThreadAppId = AppId;
		Pkill( Pgetppid(), SIGUSR1 );
	}
#endif

	if( AppId > 0 )
	{
		WORD		AesHandle, PwChar, PhChar, PwBox, PhBox, WorkOut[57];
#ifdef	NAES
		MT_menu_register( AppId, "  Fiffi-Thread", Global );
#endif
		AesHandle = MT_graf_handle( &PwChar, &PhChar, &PwBox, &PhBox, GF.Global );

#ifdef DEBUG
	DebugMsg( GF.Global, "GemFtp [AppId = %i]\n", AppId );
#endif

		if(( GF.VdiHandle = OpenScreenWk( AesHandle, WorkOut )) > 0 )
		{
			if( MT_rsrc_load( "Fiffi.rsc", GF.Global ))
			{		
				EVNT		Events;
				OBJECT	**TreeAddr;
				BYTE		**FstringAddr;

				DIALOG	*TrDialog = NULL, *WindowAlertDialog = 0L, *WindowInputTextDialog = 0L;
				DIALOG	*SeCancelDialog = NULL, *TrCancelDialog = 0L, *DdDialog = 0L, *FileDialog = 0L,
				         *DragDropFailedDialog = NULL;
#ifdef	KEY
				DIALOG	*InsertHtDialog = NULL, *DoubleHtDialog = NULL;
#endif
				BYTE		FtpDialogTitle[256], InfoPuf[256];
				BYTE		TeTxt[EditLen + 1], TeTmplt[EditLen + 1];
				XTED		Xted;
				WORD		InputTextStatus = 0;
				void		*FselDialog = 0L;
				WORD		FselButton, FselN, FselSortmode, FselHandle = 0, FselStatus = -1;
				BYTE		FselPath[PathLen], FselFile[10 * FileLen], *FselPattern;
				WORD		AlertStatus = 0;
				WORD		Msg[8], Quit = 1;
				BYTE		**FileNameList = NULL, **FileNameListNew = NULL, **PathList = NULL;
				BYTE		*LinkName = NULL;
				LONG		*FileSizeList = 0, FileSizeAll = 0, FileSizeAllIs = 0, FileSize = 0, FileSizeIs = 0;
				WORD		nFileNameList = 0;
				LONG		FileOffset = 0, FileOffsetAll = 0;
				OBJECT	*FtpDirPopup = NULL;
				WORD		FtpAppId = -1;
				WORD		CurrentFile = 0, Cmd[20], CmdFailed[20], nCmd = 0, ErrorFlag = 0;
				clock_t	TStartAll = 0, TStart = 0;
#ifdef	V110
				WORD		IConnectAppId = -1, IConnectFlag = 0, IConnectStatus = 0, IConnectTimer = 5, IConnectSession = 0;
				WORD		ShutdownFlag = 0;
				WORD		nItem;
#endif
#ifdef	GEMScript
				WORD		GsAppId = 0, GsFlag = 0;
				BYTE		*GsCmd;
				UWORD		GsTransferType = TransferType;
#endif
#ifdef	V120
				WORD		Shift;
#endif
#ifdef	RECURSIV
				BYTE		**DirList = NULL;
				WORD		nDirList = 0;
#endif
				InitRsrc( &TreeAddr, &FstringAddr, GF.Global );
				MT_shel_write( SHW_INFRECGN, 1, 0, 0L, 0L, GF.Global );

				{
					WORD	i;
					for( i = 0; i < NO_FTP_DIR_V; i++ )
					{
						TreeAddr[FTP][FtpDirObjs[i]].ob_spec.tedinfo->te_ptext = malloc( NO_FTP_DIR_H + 1);
						TreeAddr[FTP][FtpDirObjs[i]].ob_spec.tedinfo->te_txtlen = NO_FTP_DIR_H;
						memset( TreeAddr[FTP][FtpDirObjs[i]].ob_spec.tedinfo->te_ptext, ' ', NO_FTP_DIR_H );
						TreeAddr[FTP][FtpDirObjs[i]].ob_spec.tedinfo->te_ptext[NO_FTP_DIR_H] = 0;
					}
				}

#ifdef	GEMScript
				if( GsConnection )
				{
					WORD	Msg[8];
					MT_appl_read( AppId, 16, Msg, GF.Global );
					GsAppId = Msg[1];
					GsFlag = 1;
					GsCmd = *( BYTE **) &Msg[3];
					GsConnection = 0;
				}
#endif
				AvInit( "FIFFI   ", GF.Global );
				GF.FtpDialog = NULL;
				GF.FtpList = NULL;
				GF.FtpListBox = NULL;
				strcpy( FtpDialogTitle, FstringAddr[WIN_NAME] );

				if( sock_init() >= 0 )
				{
					ParseFtpUrl( Url, &( GF.Session ));
#ifdef	DHST
					{
						LONG	DhstAppId = ( LONG ) Supexec( SearchDhstCookie );
						if( DhstAppId )
						{
							DHSTINFO	*Tmp = Xmalloc( sizeof( DHSTINFO ), RAM_READABLE );
							if( Tmp )
							{
								BYTE	Dir[PathLen], Path[PathLen];
								Dgetpath( Dir, 0 );
								Path[0] = ( BYTE ) Dgetdrv() + 'A';
								Path[1] = ':';
								Path[2] = 0;
								strcat( Path, Dir );
								strcat( Path, "\\Fiffi.app" );
								Tmp->appname = Xmalloc( strlen( "Fiffi" ) +1, RAM_READABLE );
								strcpy( Tmp->appname, "Fiffi" );
								Tmp->apppath = Xmalloc( strlen( Path ) + 1, RAM_READABLE );
								strcpy( Tmp->apppath, Path );
								Tmp->docname = Xmalloc( strlen( Url ) + 1, RAM_READABLE );
								strcpy( Tmp->docname, Url );
								Tmp->docpath = Xmalloc( strlen( Url ) + 1, RAM_READABLE );
								strcpy( Tmp->docpath, Url );
								Msg[0] = DHST_ADD;
								Msg[1] = AppId;
								Msg[2] = 0;
								*( DHSTINFO ** ) (&Msg[3] ) = Tmp;
								MT_appl_write(( WORD ) DhstAppId, 16, Msg, GF.Global );
							}
						}
					}
#endif

/*					free( Url );	*/
					strcat( FtpDialogTitle, GF.Session.Host );
					FtpAppId = Ftp( AppId );
					if( FtpAppId > 0 )
					{
#ifdef	GEMScript
						if( GsFlag )
						{
							GF.FtpDialog = MT_wdlg_create( HandleGemScriptDialog, TreeAddr[GS], ( void * ) &GF, 0, ( void * ) &GF, WDLG_BKGD, GF.Global );
							MT_wdlg_open( GF.FtpDialog, FtpDialogTitle, NAME + MOVER + CLOSER + ICONIFIER + INFO, -1, -1, 0, ( void * ) &GF, GF.Global );
						}
						else
#endif
						{
							WORD	x = 0, y = 0;
							GRECT	FtpRect, Rect;
							MT_wind_get_grect( 0, WF_WORKXYWH, &FtpRect, GF.Global );
							GF.FtpDialog = MT_wdlg_create( HandleFtpDialog, TreeAddr[FTP], ( void * ) &GF, 0, ( void * ) &GF, WDLG_BKGD, GF.Global );

							MT_wdlg_open( GF.FtpDialog, FtpDialogTitle, NAME + MOVER + CLOSER + FULLER + ICONIFIER + INFO, 10000, 10000, 0, ( void * ) &GF, GF.Global );
							DisableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );
							MT_wdlg_close( GF.FtpDialog, &x, &y, GF.Global );

							GF.nFtpWin = SetnFtpWin();
							if( GetFtpPos( GF.nFtpWin, &Rect ))
							{
								GRECT	Work;
								if( Rect.g_x > FtpRect.g_x + FtpRect.g_w )
									Rect.g_x = FtpRect.g_x;
								if( Rect.g_y > FtpRect.g_y + FtpRect.g_h )
									Rect.g_y = FtpRect.g_y;
								MT_wind_calc( WC_WORK, NAME + MOVER + CLOSER + FULLER + ICONIFIER + INFO, &Rect, &Work, GF.Global );
								FtpRect.g_x = 0; FtpRect.g_y = 0;
								FtpRect.g_w = Rect.g_w;
								FtpRect.g_h = Rect.g_h;
								SetFtpSize( GF.FtpDialog, &FtpRect, &GF );
								MT_wdlg_open( GF.FtpDialog, FtpDialogTitle, NAME + MOVER + CLOSER + FULLER + ICONIFIER + INFO, Work.g_x, Work.g_y, 0, ( void * ) &GF, GF.Global );

/*{
WORD	Msg[8];
MT_wind_get_grect( MT_wdlg_get_handle( GF.FtpDialog, GF.Global ), WF_CURRXYWH, &Work, GF.Global );
Work.g_y = -250;
Msg[0] = WM_MOVED;
Msg[1] = AppId;
Msg[2] = 0;
Msg[3] = MT_wdlg_get_handle( GF.FtpDialog, GF.Global );
Msg[4] = Work.g_x;
Msg[5] = Work.g_y;
Msg[6] = Work.g_w;
Msg[7] = Work.g_h;
MT_appl_write( GF.Global[2], 16, Msg, GF.Global );
}*/


							}
							else
							{
								FtpRect.g_x = 0; FtpRect.g_y = 0; 
								FtpRect.g_w = FtpRect.g_w * 0.8;
								FtpRect.g_h = FtpRect.g_h * 0.8;
								SetFtpSize( GF.FtpDialog, &FtpRect, &GF );
								MT_wdlg_open( GF.FtpDialog, FtpDialogTitle, NAME + MOVER + CLOSER + FULLER + ICONIFIER + INFO, -1, -1, 0, ( void * ) &GF, GF.Global );
							}
							MT_wind_get_grect( MT_wdlg_get_handle( GF.FtpDialog, GF.Global ), WF_CURRXYWH, &Rect, GF.Global );
							SetFtpPos( GF.nFtpWin, &Rect );
							NewWindow( MT_wdlg_get_handle( GF.FtpDialog, GF.Global ), AppId, GF.Global );
#ifdef	GEMScript
							SetThreadMainWindow( AppId, MT_wdlg_get_handle( GF.FtpDialog, GF.Global ));
#endif
						}

#ifdef	GEMScript
						if( GsFlag )
						{
							Cmd[0] = GemFtp_OpenSession;
							Cmd[1] = GS_CONNECTION;
							Cmd[2] = 0;
						}
						else
						{
							if( *GF.Session.Dir == 0 )
							{
								Cmd[0] = GemFtp_OpenSession;
								Cmd[1] = GemFtp_Pwd;
								Cmd[2] = GemFtp_List;
								Cmd[3] = 0;
							}
							else
							{
								Cmd[0] = GemFtp_OpenSession;
								Cmd[1] = GemFtp_LinkCd;	CmdFailed[1] = 4;
								Cmd[2] = GemFtp_List;
								Cmd[3] = 0;
								Cmd[4] = GemFtp_LinkGet; CmdFailed[4] = 7;
								Cmd[5] = GemFtp_Shutdown;
								Cmd[6] = 0;
								Cmd[7] = GemFtp_LinkFailed;
								Cmd[8] = 0;
							}
						}
						LinkName = strdup( GF.Session.Dir );
						if( !LinkName )
							return( ENSMEM );
#else
						if( *GF.Session.Dir == 0 )
						{
							Cmd[0] = GemFtp_OpenSession;
							Cmd[1] = GemFtp_Pwd;
							Cmd[2] = GemFtp_List;
							Cmd[3] = 0;
						}
						else
						{
							LinkName = strdup( GF.Session.Dir );
							if( !LinkName )
								return( ENSMEM );
							Cmd[0] = GemFtp_OpenSession;
							Cmd[1] = GemFtp_LinkCd;	CmdFailed[1] = 4;
							Cmd[2] = GemFtp_List;
							Cmd[3] = 0;
							Cmd[4] = GemFtp_LinkGet; CmdFailed[4] = 7;
							Cmd[5] = GemFtp_Shutdown;
							Cmd[6] = 0;
							Cmd[7] = GemFtp_LinkFailed;
							Cmd[8] = 0;
						}
#endif
						nCmd = 0;
#ifdef	V110
#ifdef DEBUG
	DebugMsg( GF.Global, "ICONNECT\n" );
#endif
						WriteStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[WAITFORICONNECT], GF.Global );
						if(( IConnectAppId = MT_appl_find( "ICONNECT", GF.Global )) == -1 )
						{
#ifdef DEBUG
	DebugMsg( GF.Global, "ICONNECT noch nicht gestartet\n" );
#endif
							if( IConnect & ICONNECT_START )
							{
								BYTE	*Tmp;
#ifdef DEBUG
	DebugMsg( GF.Global, "ICONNECT: AV_STARTPROG\n" );
#endif
								Tmp = Xmalloc( 16, RAM_READABLE );
								strcpy( Tmp, "C:\\ICONFSET.CFG" );
								Msg[0] = AV_STARTPROG;
								Msg[1] = AppId;
								Msg[2] = 0;
								*((char**)(&Msg[3])) = Tmp;
								Msg[5] = 0;
								Msg[6] = 0;
								Msg[7] = -1234;
								MT_appl_write( AvAppId, 16, Msg, GF.Global );
							}
							else
							{
								Msg[0] = ICON_MSG;
								Msg[1] = AppId;
								Msg[2] = 0;
								Msg[3] = ICM_STATUS_REPLY;
								Msg[4] = ICMS_ONLINE;
								Msg[7] = -1234;
								MT_appl_write( AppId, 16, Msg, GF.Global );
							}
						}
						else
						{
#ifdef DEBUG
	DebugMsg( GF.Global, "ICONNECT bereits gestartet\n" );
#endif
							if( IConnect & ICONNECT_CONNECT )
							{
								Msg[0] = ICON_MSG;
								Msg[1] = AppId;
								Msg[2] = 0;
								Msg[3] = ICM_CONNECTION_REQUEST;
								Msg[4] = 0;
								Msg[5] = 0;
								Msg[6] = 0;
								Msg[7] = -1234;
								MT_appl_write( IConnectAppId, 16, Msg, GF.Global );
							}
							else
							{
								Msg[0] = ICON_MSG;
								Msg[1] = AppId;
								Msg[2] = 0;
								Msg[3] = ICM_STATUS_REPLY;
								Msg[4] = ICMS_ONLINE;
								Msg[7] = -1234;
								MT_appl_write( AppId, 16, Msg, GF.Global );
							}
						}
#else
						Msg[0] = GemFtp_Cmd;
						Msg[1] = AppId;
						Msg[2] = 0;
						MT_appl_write( AppId, 16, Msg, GF.Global );
#endif
					}
					else
						MT_form_alert( 1, FstringAddr[THREAD_FAILED], GF.Global );
				}
				else
				{
/* GEMScript ergÑnzen */
					WindowAlertDialog = WindowAlert( FtpDialogTitle, FstringAddr[SOCKETINTERFACE], 1, GF.Global );
					AlertStatus = SocketInit_Failed;
				}
/*
{
	WORD	i;
	GRECT	Rect;
	STR_ITEM	*Tmp;
	OBJECT	*DialogTree;
	MT_wdlg_get_tree( FileDialog, &DialogTree, &Rect, GF.Global );
	for( i = 0; i < 60; i++ )
	{
		Tmp = malloc( sizeof( STR_ITEM ));
		Tmp->selected = 0;
		Tmp->next = GF.FtpList;
		Tmp->str = malloc( 131 ); memset( Tmp->str, 'X', 30 ); Tmp->str[30] = 0; Tmp->str[0] = '-';
		GF.FtpList = Tmp;
	}
	MT_lbox_set_items( GF.FtpListBox, (LBOX_ITEM *)GF.FtpList, GF.Global );
	MT_lbox_set_bentries( GF.FtpListBox, strlen( Tmp->str ), GF.Global );
	MT_lbox_update( GF.FtpListBox, &Rect, GF.Global );
	EnableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );
}
*/
				while( Quit )
				{
					{
						WORD	w1, w2, w3, w4;
						MT_wind_get( 0, WF_TOP, &w1, &w2, &w3, &w4, Global );
						if( isWindow( w1 ))
						{
							Msg[0] = Main_Top;
							Msg[1] = AppId;
							Msg[2] = 0;
							MT_appl_write( Global[2], 16, Msg, GF.Global );
						}
					}

#ifdef	V110
					if( !IConnectSession && IConnect )
					{				
#ifdef DEBUG
	DebugMsg( GF.Global, "ICONNECT MT_EVNT_multi\n" );
#endif
						MT_EVNT_multi( MU_KEYBD + MU_BUTTON + MU_MESAG + MU_TIMER, 0x102, 3, 0, 0L, 0L, 1000L, &Events, GF.Global );
						if( MT_appl_find( "ICONNECT", GF.Global ) == -1 && IConnectAppId != -1 )
						{
#ifdef DEBUG
	DebugMsg( GF.Global, "ICONNECT lost\n" );
#endif
							AlertStatus = IConnect_Lost;
							WindowAlertDialog = WindowAlert( FtpDialogTitle, FstringAddr[ICONNECT_LOST], 1, GF.Global );
						}
					}
					else
					{
						if( !( FileSelectorFlag && FselDialog ))
							MT_EVNT_multi( MU_KEYBD + MU_BUTTON + MU_MESAG, 0x102, 3, 0, 0L, 0L, 0L, &Events, GF.Global );
						else
							Events.mwhich = 0;
					}
#else
					if( !( FileSelectorFlag && FselDialog ))
						MT_EVNT_multi( MU_KEYBD + MU_BUTTON + MU_MESAG, 0x102, 3, 0, 0L, 0L, 0L, &Events, GF.Global );
					else
						Events.mwhich = 0;
#endif
#ifdef DEBUG
	DebugMsg( GF.Global, "EVNT_multi()\n" );
#endif
/* FtpDialog ------------------------------------------------------------------*/
					if( GF.FtpDialog )
					{
						WORD	w, w1, w2, w3, w4;
#ifdef DEBUG
	DebugMsg( GF.Global, "FtpDialog\n" );
	DebugMsg( GF.Global, "which = %i\n", Events.mwhich );
	if( Events.mwhich & MU_MESAG )
	{
		DebugMsg( GF.Global, "0: %x\n", Events.msg[0] );
		DebugMsg( GF.Global, "1: %x\n", Events.msg[1] );
		DebugMsg( GF.Global, "2: %x\n", Events.msg[2] );
		DebugMsg( GF.Global, "3: %x\n", Events.msg[3] );
		DebugMsg( GF.Global, "4: %x\n", Events.msg[4] );
		DebugMsg( GF.Global, "4: %x\n", Events.msg[5] );
		DebugMsg( GF.Global, "5: %x\n", Events.msg[6] );
		DebugMsg( GF.Global, "6: %x\n", Events.msg[7] );
		DebugMsg( GF.Global, "7: %x\n", Events.msg[8] );
	}
#endif
						w = MT_wdlg_get_handle( GF.FtpDialog, GF.Global );
#ifdef	GEMScript
						if( !GsFlag && !isIconifiedWindow( w ))
#else
						if( !isIconifiedWindow( w ))
#endif
						{
/*							WORD	E = W_SIZER, CA, CB, D;
							LONG	ObSpec;
							GRECT	Rect;
							OBJECT	*DialogTree;
							MT_wind_get( 0, WF_TOP, &w1, &w2, &w3, &w4, GF.Global );
							MT_wdlg_get_tree( GF.FtpDialog, &DialogTree, &Rect, GF.Global );
							MT_wind_get( 0, WF_DCOLOR, &E, &CA, &CB, &D, GF.Global );
							ObSpec = DialogTree[FTP_W_SIZER].ob_spec.index;							
							ObSpec = ObSpec & 0xffff0000L;
							if( w == w1 )
								ObSpec |= CA;
							else
								ObSpec |= CB;
							if( DialogTree[FTP_W_SIZER].ob_spec.index != ObSpec )
							{
								DialogTree[FTP_W_SIZER].ob_spec.index = ObSpec;
								DoRedraw( GF.FtpDialog, &Rect, FTP_W_SIZER, GF.Global );
							}*/
						}
						if( MT_wdlg_evnt( GF.FtpDialog, &Events, GF.Global ) == 0 )
							continue;
					}
/* InsertHtDialog --------------------------------------------------------------*/
#ifdef	KEY
					if( InsertHtDialog )
						if( MT_wdlg_evnt( InsertHtDialog, &Events, GF.Global ) == 0 )
						{
							CloseDialog( InsertHtDialog, GF.Global );
							InsertHtDialog = NULL;
							if( TreeAddr[IHT][IHT_OK].ob_state & SELECTED )
							{
								if( ExistHtItem( GF.Session.Host ))
								{
									if( !DoubleHtDialog	)
										DoubleHtDialog = OpenDialog( TreeAddr[DHT], FtpDialogTitle, HandleDoubleHtDialog, GF.Global, GF.Global );
									else
									{
										Msg[0] = WM_TOPPED;
										Msg[1] = AppId;
										Msg[2] = 0;
										Msg[3] = MT_wdlg_get_handle( DoubleHtDialog, GF.Global );
										MT_appl_write( AppId, 16, Msg, GF.Global );
									}
								}
								else
								{
									if( InsertHtItem( GF.Session.Host, GF.Session.Host, GF.Session.Port, GF.Session.Uid, GF.Session.Pwd, GF.Session.Dir, NULL ) != E_OK )
										return( ERROR );
									Msg[0] = Main_UpdateMenu;
									Msg[1] = AppId;
									Msg[2] = 0;
									MT_appl_write( Global[2], 16, Msg, GF.Global );
								}
							}
							continue;
						}
					if( DoubleHtDialog )
						if( MT_wdlg_evnt( DoubleHtDialog, &Events, GF.Global ) == 0 )
						{
							CloseDialog( DoubleHtDialog, GF.Global );
							DoubleHtDialog = NULL;
							if( TreeAddr[DHT][DHT_OK].ob_state & SELECTED )
							{
								if( InsertHtItem( GF.Session.Host, GF.Session.Host, GF.Session.Port, GF.Session.Uid, GF.Session.Pwd, GF.Session.Dir, NULL ) != E_OK )
									return( ERROR );
								Msg[0] = Main_UpdateMenu;
								Msg[1] = AppId;
								Msg[2] = 0;
								MT_appl_write( Global[2], 16, Msg, GF.Global );
							}
							continue;
						}
#endif
/* DragDropFailedDialog ------------------------------------------------------*/
						if( DragDropFailedDialog )
							if( MT_wdlg_evnt( DragDropFailedDialog, &Events, Global ) == 0 )
							{
								CloseDialog( DragDropFailedDialog, Global );
								DragDropFailedDialog = NULL;
								continue;
							}
/* SeCancelDialog-------------------------------------------------------------*/
					if( SeCancelDialog )
						if( MT_wdlg_evnt( SeCancelDialog, &Events, GF.Global ) == 0 )
						{
							CloseDialog( SeCancelDialog, GF.Global );
							SeCancelDialog = NULL;
							continue;
						}
/* TrDialog ------------------------------------------------------------------*/
					if( TrDialog )
						if( MT_wdlg_evnt( TrDialog, &Events, GF.Global ) == 0 )
						{
							CloseDialog( TrDialog, GF.Global );
							TrDialog = NULL;
							continue;
						}
/* TrCancelDialog-------------------------------------------------------------*/
					if( TrCancelDialog )
						if( MT_wdlg_evnt( TrCancelDialog, &Events, GF.Global ) == 0 )
						{
							CloseDialog( TrCancelDialog, GF.Global );
							TrCancelDialog = NULL;
							continue;
						}
/* DdDialog ------------------------------------------------------------------*/
					if( DdDialog )
						if( MT_wdlg_evnt( DdDialog, &Events, GF.Global ) == 0 )
						{
							CloseDialog( DdDialog, GF.Global );
							DdDialog = NULL;
							continue;
						}
/* FileDialog ----------------------------------------------------------------*/
					if( FileDialog )
						if( MT_wdlg_evnt( FileDialog, &Events, GF.Global ) == 0 )
						{
							XATTR	Xattr;
							CloseDialog( FileDialog, GF.Global );
							FileDialog = NULL;
#ifdef	RESUME
							if( TreeAddr[FILE_D][FILE_RESUME].ob_state & SELECTED ||
							    TreeAddr[FILE_D][FILE_RESUME_ALL].ob_state & SELECTED ||
							    TreeAddr[FILE_D][FILE_REPLACE].ob_state & SELECTED ||
							    TreeAddr[FILE_D][FILE_JUMPOVER].ob_state & SELECTED ||
							    TreeAddr[FILE_D][FILE_RENAME].ob_state & SELECTED  || 
							    TreeAddr[FILE_D][FILE_REPLACE_ALL].ob_state & SELECTED ||
							    TreeAddr[FILE_D][FILE_JUMPOVER_AL].ob_state & SELECTED )
#else
							if( TreeAddr[FILE_D][FILE_REPLACE].ob_state & SELECTED ||
							    TreeAddr[FILE_D][FILE_JUMPOVER].ob_state & SELECTED ||
							    TreeAddr[FILE_D][FILE_RENAME].ob_state & SELECTED  || 
							    TreeAddr[FILE_D][FILE_REPLACE_ALL].ob_state & SELECTED ||
							    TreeAddr[FILE_D][FILE_JUMPOVER_AL].ob_state & SELECTED )
#endif
							{
#ifdef	RESUME
								if( TreeAddr[FILE_D][FILE_RESUME].ob_state & SELECTED )
								{
									nFileNameList++;
								}
								if( TreeAddr[FILE_D][FILE_RESUME].ob_state & SELECTED )
								{
									while( FileNameList[++nFileNameList] );
								}
#endif
								if( TreeAddr[FILE_D][FILE_REPLACE].ob_state & SELECTED )
								{
#ifdef	RESUME
									Fdelete( PathList[nFileNameList++] );
#else
									nFileNameList++;
#endif
								}
								if( TreeAddr[FILE_D][FILE_JUMPOVER].ob_state & SELECTED )
								{
									WORD	n = nFileNameList;
									free( FileNameList[n] );
									free( PathList[n] );
									while( FileNameList[n + 1] )
									{
										FileNameList[n] = FileNameList[n+1];
										PathList[n] = PathList[n+1];
										FileSizeList[n] = FileSizeList[n + 1];
										n++;
									}
									FileNameList[n] = NULL;
									Msg[0] = GemFtp_Cmd;
									Msg[1] = AppId;
									Msg[2] = 0;
									MT_appl_write( AppId, 16, Msg, GF.Global );
								}
								if( TreeAddr[FILE_D][FILE_RENAME].ob_state & SELECTED )
								{
									free( FileNameList[nFileNameList] );
									free( PathList[nFileNameList] );
									if( *( TreeAddr[FILE_D][FILE_NEW].ob_spec.tedinfo->te_ptext + 1 ) == ':' )
									{
										PathList[nFileNameList] = strdup( TreeAddr[FILE_D][FILE_NEW].ob_spec.tedinfo->te_ptext );
										if( !PathList[nFileNameList] )
											return( ENSMEM );
									}
									else
									{
										PathList[nFileNameList] = malloc( strlen( TreeAddr[FILE_D][FILE_NEW].ob_spec.tedinfo->te_ptext ) + strlen( TreeAddr[FILE_D][FILE_PATH].ob_spec.free_string ) + 1 );
										if( !PathList[nFileNameList] )
											return( ENSMEM );
										strcpy( PathList[nFileNameList], TreeAddr[FILE_D][FILE_PATH].ob_spec.free_string );
										strcat( PathList[nFileNameList], TreeAddr[FILE_D][FILE_NEW].ob_spec.tedinfo->te_ptext );
									}
								}
								if( TreeAddr[FILE_D][FILE_REPLACE_ALL].ob_state & SELECTED )
								{
#ifdef	RESUME
									while( FileNameList[nFileNameList] )
									{
										if( Fxattr( 0, PathList[nFileNameList], &Xattr ) == E_OK )
											Fdelete( PathList[nFileNameList] );
										nFileNameList++;
									}
#else
									while( FileNameList[++nFileNameList] );
#endif
								}
								if( TreeAddr[FILE_D][FILE_JUMPOVER_AL].ob_state & SELECTED )
								{
									while( FileNameList[nFileNameList] )
									{
										if( Fxattr( 0, PathList[nFileNameList], &Xattr ) == E_OK )
										{
											WORD	n = nFileNameList;
											free( FileNameList[n] );
											free( PathList[n] );
											while( FileNameList[n + 1] )
											{
												FileNameList[n] = FileNameList[n+1];
												PathList[n] = PathList[n+1];
												FileSizeList[n] = FileSizeList[n + 1];
												n++;
											}
											FileNameList[n] = NULL;
											continue;
										}
										nFileNameList++;
									}
									Msg[0] = GemFtp_Cmd;
									Msg[1] = AppId;
									Msg[2] = 0;
									MT_appl_write( AppId, 16, Msg, GF.Global );
								}
								while( FileNameList[nFileNameList] )
								{
									if( Fxattr( 0, PathList[nFileNameList], &Xattr ) == E_OK )
									{
										BYTE	Tmp[128], *Path, *File = strdup( strrchr( PathList[nFileNameList], '\\' ) + 1 );
										if( !File )
											return( ENSMEM );
										memset( Tmp, 0, 128 );
										strncpy( Tmp, PathList[nFileNameList], strrchr( PathList[nFileNameList], '\\' ) - PathList[nFileNameList] + 1 );
										Path = strdup( Tmp );
										if( !Path )
											return( ENSMEM );
										FileDialog = OpenFileDialog( TreeAddr[FILE_D], FtpDialogTitle, &Xted, TeTmplt, TeTxt, GF.Global, File, Path );
										free( File );
										free( Path );
										break;
									}
									nFileNameList++;
								}
								if( !FileNameList[nFileNameList] )
								{
									Msg[0] = GemFtp_Get_Start;
									Msg[1] = AppId;
									Msg[2] = 0;
									MT_appl_write( AppId, 16, Msg, GF.Global );
								}
							}
							else
							{
								STR_ITEM *Item = GF.FtpList;
								GRECT	Rect;
								OBJECT	*DialogTree;
								MT_wdlg_get_tree( GF.FtpDialog, &DialogTree, &Rect, GF.Global );
								while( Item )
								{
									Item->selected = 0;
									Item = Item->next;
								}
								MT_lbox_update( GF.FtpListBox, &Rect, GF.Global );
								AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[CANCEL], GF.Global );
								EnableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );
								if( FselDialog )
								{
									MT_fslx_close( FselDialog, GF.Global );
									FselDialog = NULL;
								}
								DelFileNameList( &FileNameList );
								DelFileNameList( &PathList );
								free( FileSizeList );
								FileNameList = NULL;
								PathList = NULL;
								FileSizeList = NULL;
								Msg[0] = GemFtp_Cmd;
								Msg[1] = AppId;
								Msg[2] = 0;
								MT_appl_write( AppId, 16, Msg, GF.Global );
							}
							continue;
						}
/* WindowAlertDialog ----------------------------------------------------------*/
					if( WindowAlertDialog )
						if( MT_wdlg_evnt( WindowAlertDialog, &Events, GF.Global ) == 0 )
						{
							CloseDialog( WindowAlertDialog, GF.Global );
							WindowAlertDialog = 0L;
#ifdef	V110
							if(( AlertStatus == IConnect_Failed ) ||
							   ( AlertStatus == IConnect_Lost ) ||
							   ( AlertStatus == SocketInit_Failed ) ||
								( AlertStatus == Socket_Failed && !(TreeAddr[ALERT][ALERT_BUTTON_0].ob_state & SELECTED )) ||
								( AlertStatus == GetHostByName_Failed ) ||
								( AlertStatus == Connect_Failed ) ||
								( AlertStatus == Login_Failed ))
#else
							if(( AlertStatus == SocketInit_Failed ) ||
								( AlertStatus == Socket_Failed && !(TreeAddr[ALERT][ALERT_BUTTON_0].ob_state & SELECTED )) ||
								( AlertStatus == GetHostByName_Failed ) ||
								( AlertStatus == Connect_Failed ) ||
								( AlertStatus == Login_Failed ))

#endif
							{
								Msg[0] = GemFtp_Shutdown;
								Msg[1] = AppId;
								Msg[2] = 0;
								MT_appl_write( AppId, 16, Msg, GF.Global );
							}
							
							if( AlertStatus == Socket_Failed && (TreeAddr[ALERT][ALERT_BUTTON_0].ob_state & SELECTED ))
							{
								if( IConnect & ICONNECT_START )
									IConnectStarted = 1;
								nCmd = 0;
								Msg[0] = GemFtp_Cmd;
								Msg[1] = AppId;
								Msg[2] = 0;
								MT_appl_write( AppId, 16, Msg, GF.Global );
							}

							if( AlertStatus == Link_Failed )
							{
								if( TreeAddr[ALERT][ALERT_BUTTON_0].ob_state & SELECTED )
								{
									Msg[0] = GemFtp_Shutdown;
									Msg[1] = AppId;
									Msg[2] = 0;
									MT_appl_write( AppId, 16, Msg, GF.Global );
								}
								else
								{
									GRECT	Rect;
									GetFtpPos( GF.nFtpWin, &Rect );
									MT_wind_open( MT_wdlg_get_handle( GF.FtpDialog, GF.Global ), &Rect, GF.Global );
									NewWindow( MT_wdlg_get_handle( GF.FtpDialog, GF.Global ), AppId, GF.Global );
									Cmd[0] = GemFtp_Pwd;
									Cmd[1] = GemFtp_List;
									Cmd[2] = 0;
									nCmd = 0;
									Msg[0] = GemFtp_Cmd;
									Msg[1] = AppId;
									Msg[2] = 0;
									MT_appl_write( AppId, 16, Msg, GF.Global );
								}
							}

							if( AlertStatus == Cwd_Failed )
							{
								Msg[0] = GemFtp_Cmd;
								Msg[1] = AppId;
								Msg[2] = 0;
								MT_appl_write( AppId, 16, Msg, GF.Global );
							}

							if( AlertStatus == Dele_Failed )
							{
								Msg[0] = GemFtp_List;
								Msg[1] = AppId;
								Msg[2] = 0;
								MT_appl_write( AppId, 16, Msg, GF.Global );
							}
							if( AlertStatus == Mkd_Failed )
							{
								EnableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );
							}
							if( AlertStatus == Rmd_Failed )
							{
								Msg[0] = GemFtp_List;
								Msg[1] = AppId;
								Msg[2] = 0;
								MT_appl_write( AppId, 16, Msg, GF.Global );
							}
							if( AlertStatus == Rn_Failed )
							{
								Msg[0] = GemFtp_List;
								Msg[1] = AppId;
								Msg[2] = 0;
								MT_appl_write( AppId, 16, Msg, GF.Global );
							}
							if( AlertStatus == Chmod_Failed )
							{
								Msg[0] = GemFtp_List;
								Msg[1] = AppId;
								Msg[2] = 0;
								MT_appl_write( AppId, 16, Msg, GF.Global );
							}
							if( AlertStatus == Stor_Failed )
							{
								Msg[0] = GemFtp_List;
								Msg[1] = AppId;
								Msg[2] = 0;
								MT_appl_write( AppId, 16, Msg, GF.Global );
							}
							continue;
						}
/* WindowInputTextDialog ------------------------------------------------------*/
					if( WindowInputTextDialog )
						if( MT_wdlg_evnt( WindowInputTextDialog, &Events, GF.Global ) == 0 )
						{
							WORD	Ok = 0;
							CloseDialog( WindowInputTextDialog, GF.Global );
							WindowInputTextDialog = 0L;
							if( TreeAddr[IT][IT_OK].ob_state & SELECTED )
								Ok = 1;
							if( InputTextStatus == InputText_GemFtp_Get )
							{
								if( Ok )
								{
									FileNameList = malloc( 2 * sizeof( BYTE * ));
									if( !FileNameList )
										return( ENSMEM );
									FileNameList[0] = malloc( strlen( TeTxt ) + 1 );
									if( !FileNameList[0] )
										return( ENSMEM );
									strcpy( FileNameList[0], TeTxt );
									FileNameList[1] = NULL;
									FileSizeList = malloc( sizeof( LONG ));
									if( !FileSizeList )
										return( ENSMEM );
									FileSizeList[0] = 0;
									Msg[0] = Fsel_Msg;
									Msg[1] = AppId;
									Msg[2] = 0;
									Msg[3] = Fsel_Open;
									Msg[4] = Fsel_GemFtp_Get;
									MT_appl_write( AppId, 16, Msg, GF.Global );
								}
								else
									EnableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );
							}
							if( InputTextStatus == InputText_GemFtp_Mv_New )
							{
								if( Ok )
								{
									FileNameListNew[nFileNameList] = malloc( strlen( TeTxt ) + 1 );
									if( !FileNameListNew[nFileNameList] )
										return( ENSMEM );
									strcpy( FileNameListNew[nFileNameList++], TeTxt );
									if( FileNameList[nFileNameList] )
									{
										strcpy( TeTxt, FileNameList[nFileNameList] );
										WindowInputTextDialog =	WindowInputText( FtpDialogTitle, FstringAddr[FTP_IT_MV_NEW], &Xted, TeTmplt, TeTxt, GF.Global	);
									}
									else
									{
										Msg[0] = Rn_Cmd;
										Msg[1] = AppId;
										Msg[2] = 0;
										(BYTE **) *( LONG *)&( Msg[3] ) = FileNameList;
										(BYTE **) *( LONG *)&( Msg[5] ) = FileNameListNew;
										MT_appl_write( FtpAppId, 16, Msg, GF.Global );
									}
								}
								else
								{
									DelFileNameList( &FileNameList );
									DelFileNameList( &FileNameListNew );
									EnableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );
								}
							}
							if( InputTextStatus == InputText_GemFtp_Mv_Old )
							{
								if( Ok )
								{
									FileNameList = malloc( 2 * sizeof( BYTE * ));
									if( !FileNameList )
										return( ENSMEM );
									FileNameList[0] = malloc( strlen( TeTxt ) + 1 );
									if( !FileNameList[0] )
										return( ENSMEM );
									strcpy( FileNameList[0], TeTxt );
									FileNameList[1] = NULL;
									FileNameListNew = calloc( 2, sizeof( BYTE * ));
									if( !FileNameListNew )
										return( ENSMEM );
									FileNameListNew[1] = NULL;
									nFileNameList = 0;
									strcpy( TeTxt, FileNameList[0] );
									WindowInputTextDialog =	WindowInputText( FtpDialogTitle, FstringAddr[FTP_IT_MV_NEW], &Xted, TeTmplt, TeTxt, GF.Global	);
									InputTextStatus = InputText_GemFtp_Mv_New;
								}
								else
									EnableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );
							}
							if( InputTextStatus == InputText_GemFtp_Rm )
							{
								if( Ok )
								{
									Msg[0] = Dele_Cmd;
									Msg[1] = AppId;
									Msg[2] = 0;
									FileNameList = malloc( 2 * sizeof( BYTE * ));
									if( !FileNameList )
										return( ENSMEM );
									FileNameList[0] = malloc( strlen( TeTxt ) + 1 );
									if( !FileNameList[0] )
										return( ENSMEM );
									strcpy( FileNameList[0], TeTxt );
									FileNameList[1] = NULL;
									(BYTE **) *( LONG *)&( Msg[3] ) = FileNameList;
									MT_appl_write( FtpAppId, 16, Msg, GF.Global );
								}
								else
									EnableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );
							}								
							if( InputTextStatus == InputText_GemFtp_Mkdir )
							{
								if( Ok )
								{
									WriteStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[MKD], GF.Global );
									Msg[0] = Mkd_Cmd;
									Msg[1] = AppId;
									Msg[2] = 0;
									(BYTE *) *( LONG *)&( Msg[3] ) = strdup( TeTxt );
									if( !(BYTE *) *( LONG *)&( Msg[3] ))
										return( ENSMEM );
									MT_appl_write( FtpAppId, 16, Msg, GF.Global );
								}
								else
									EnableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );
							}
							if( InputTextStatus == InputText_GemFtp_Rmdir )
							{
								if( Ok )
								{
									Msg[0] = Rmd_Cmd;
									Msg[1] = AppId;
									Msg[2] = 0;
									FileNameList = malloc( 2 * sizeof( BYTE * ));
									if( !FileNameList )
										return( ENSMEM );
									FileNameList[0] = strdup( TeTxt );
									if( !FileNameList[0] )
										return( ENSMEM );
									FileNameList[1] = NULL;
									(BYTE **) *( LONG *)&( Msg[3] ) = FileNameList;
									MT_appl_write( FtpAppId, 16, Msg, GF.Global );
								}
								else
									EnableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );
							}
							if( InputTextStatus == InputText_GemFtp_Cd )
							{
								if( Ok )
								{
									if( *TeTxt == '/' )
									{
										free( GF.Session.Dir );
										if( TeTxt[strlen( TeTxt )] == '/' )
											TeTxt[strlen( TeTxt )] = 0;
										GF.Session.Dir = strdup( TeTxt );
										if( !GF.Session.Dir )
											return( ENSMEM );
									}
									else
									{
										BYTE	*Tmp = strdup( GF.Session.Dir );
										if( !Tmp )
											return( ENSMEM );
										free( GF.Session.Dir );
										GF.Session.Dir = malloc( strlen( Tmp ) + strlen( TeTxt ) + 2 );
										if( !GF.Session.Dir )
											return( ENSMEM );
										strcpy( GF.Session.Dir, Tmp );
										if( GF.Session.Dir[strlen( GF.Session.Dir )-1] != '/' )
											strcat( GF.Session.Dir, "/" );
										strcat( GF.Session.Dir, TeTxt );
									}
									if( strcmp( TeTxt, ".." ) == 0 || strcmp( TeTxt, "." ) == 0 )
									{
										Cmd[0] = GemFtp_Cwd; CmdFailed[0] = 1;
										Cmd[1] = GemFtp_Pwd;
										Cmd[2] = GemFtp_List;
										Cmd[3] = 0;
										nCmd = 0;
									}
									else
									{
										Cmd[0] = GemFtp_Cwd;	CmdFailed[0] = 3;
										Cmd[1] = GemFtp_List;
										Cmd[2] = 0;
										Cmd[3] = GemFtp_CwdFailed;
										Cmd[4] = GemFtp_Pwd;
										Cmd[5] = GemFtp_List;
										Cmd[6] = 0;
										nCmd = 0;
									}
									Msg[0] = GemFtp_Cmd;
									Msg[1] = AppId;
									Msg[2] = 0;
									MT_appl_write( AppId, 16, Msg, GF.Global );
								}
								else
									EnableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );
							}
							if( InputTextStatus == InputText_GemFtp_Chmod_Mode )
							{
								if( Ok )
								{
									Msg[0] = Chmod_Cmd;
									Msg[1] = AppId;
									Msg[2] = 0;
									(BYTE **) *( LONG *)&( Msg[3] ) = FileNameList;
									(BYTE *) *( LONG *)&( Msg[5] ) = strdup( TeTxt );
									MT_appl_write( FtpAppId, 16, Msg, GF.Global );
								}
								else
								{
									DelFileNameList( &FileNameList );
									EnableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );
								}
							}
							if( InputTextStatus == InputText_GemFtp_Chmod_File )
							{
								if( Ok )
								{
									FileNameList = malloc( 2 * sizeof( BYTE * ));
									if( !FileNameList )
										return( ENSMEM );
									FileNameList[0] = strdup( TeTxt );
									if( !FileNameList[0] )
										return( ENSMEM );
									FileNameList[1] = NULL;
									memset( TeTxt, 0, EditLen );
									WindowInputTextDialog =	WindowInputText( FtpDialogTitle, FstringAddr[FTP_IT_CHMOD_MODE], &Xted, TeTmplt, TeTxt, GF.Global	);
									InputTextStatus = InputText_GemFtp_Chmod_Mode;
								}
								else
									EnableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );
							}
							continue;
						}
/* FselDialog -----------------------------------------------------------------*/
					if( FselDialog )
						if( FileSelectorFlag || !MT_fslx_evnt( FselDialog, &Events, FselPath, FselFile, &FselButton, &FselN, &FselSortmode, &FselPattern, GF.Global ))
						{
							if( FselStatus == Fsel_GemFtp_Get )
							{
								if( FselButton )
								{
									*( strrchr( FselPath, '\\' ) + 1 ) = 0;
									(BYTE *) *( LONG *)&( Msg[4] ) = strdup( FselPath );
									if( !(BYTE *) *( LONG *)&( Msg[4] ))
										return( ENSMEM );
									Msg[0] = GemFtp_Get_Prepare;
									Msg[1] = AppId;
									Msg[2] = 0;
									MT_appl_write( AppId, 16, Msg, GF.Global );
								}
								else
									EnableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );
								FselStatus = -1;
							}
							if( FselStatus == Fsel_File_Rename )
							{
								GRECT		Rect;
								OBJECT	*DialogTree;
								MT_wdlg_get_tree( FileDialog, &DialogTree, &Rect, GF.Global );
								if( strlen( FselFile ) && FselButton )
								{
									if( FileSelectorFlag )
										*( strrchr( FselPath, '\\' ) + 1 ) = 0;
									strcpy( DialogTree[FILE_NEW].ob_spec.tedinfo->te_ptext, FselPath );
									strcat( DialogTree[FILE_NEW].ob_spec.tedinfo->te_ptext, FselFile );
								}
								DialogTree[FILE_CANCEL].ob_state &= ~DISABLED;
								DialogTree[FILE_CANCEL].ob_flags |= SELECTABLE;
								DialogTree[FILE_REPLACE].ob_state &= ~DISABLED;
								DialogTree[FILE_REPLACE_I].ob_state &= ~DISABLED;
								DialogTree[FILE_REPLACE].ob_flags |= SELECTABLE;
								DialogTree[FILE_REPLACE_ALL].ob_state &= ~DISABLED;
								DialogTree[FILE_REPLACE_A_I].ob_state &= ~DISABLED;
								DialogTree[FILE_REPLACE_ALL].ob_flags |= SELECTABLE;
								DialogTree[FILE_JUMPOVER_AL].ob_state &= ~DISABLED;
								DialogTree[FILE_JUMPOVER_AI].ob_state &= ~DISABLED;
								DialogTree[FILE_JUMPOVER_AL].ob_flags |= SELECTABLE;
								DialogTree[FILE_RENAME].ob_state &= ~DISABLED;
								DialogTree[FILE_RENAME_I].ob_state &= ~DISABLED;
								DialogTree[FILE_RENAME].ob_flags |= SELECTABLE;
								DialogTree[FILE_NEW].ob_flags |= TOUCHEXIT;
								DialogTree[FILE_NEW].ob_state &= ~DISABLED;				
#ifdef	RESUME
								DialogTree[FILE_RESUME].ob_state &= ~DISABLED;
								DialogTree[FILE_RESUME].ob_flags |= SELECTABLE;
								DialogTree[FILE_RESUME_ALL].ob_state &= ~DISABLED;
								DialogTree[FILE_RESUME_ALL].ob_flags |= SELECTABLE;
#endif	
								if( strlen( DialogTree[FILE_NEW].ob_spec.tedinfo->te_ptext ))
								{
									DialogTree[FILE_RENAME].ob_flags |= SELECTABLE;
									DialogTree[FILE_RENAME].ob_state &= ~DISABLED;
								}
#ifdef	RESUME
								DoRedrawX( FileDialog, &Rect, GF.Global, FILE_NEW, FILE_RESUME, FILE_RESUME_ALL, FILE_REPLACE, 
								           FILE_JUMPOVER, FILE_RENAME, FILE_REPLACE_ALL, 
								           FILE_JUMPOVER_AL, FILE_CANCEL, EDRX ); 
#else
								DoRedrawX( FileDialog, &Rect, GF.Global, FILE_NEW, FILE_REPLACE, 
								           FILE_JUMPOVER, FILE_RENAME, FILE_REPLACE_ALL, 
								           FILE_JUMPOVER_AL, FILE_CANCEL, EDRX ); 
#endif
								MT_wdlg_set_edit( FileDialog, 0, GF.Global );
								MT_wdlg_set_edit( FileDialog, FILE_NEW, GF.Global );
							}
							if( FselStatus == Fsel_GemFtp_Put )
							{
								if( FselButton )
								{
#ifdef	RECURSIV
									BYTE	**TmpList, *Arg, *Tmp;
									WORD	i = 0, j;
									LONG	Len = 0;
									if( FileSelectorFlag )
									{
										FselN = 1;
										*( strrchr( FselPath, '\\' ) + 1 ) = 0;
									}
									if( FselN == 0 )
										FselN = 1;
									TmpList = malloc(( FselN + 2 ) * sizeof( BYTE * ));
									if( !TmpList )
										return( ENSMEM );
									TmpList[i] = malloc( strlen( FselFile ) + strlen( FselPath ) + 1 );
									if( !TmpList[i] )
										return( ENSMEM );
									strcpy( TmpList[i], FselPath );
									strcat( TmpList[i++], FselFile );
									while( --FselN )
									{
										MT_fslx_getnxtfile( FselDialog, FselFile, GF.Global );
										TmpList[i] = malloc( strlen( FselFile ) + strlen( FselPath ) + 1 );
										if( !TmpList[i] )
											return( ENSMEM );
										strcpy( TmpList[i], FselPath );
										strcat( TmpList[i++], FselFile );
									}
									TmpList[i] = NULL;
									for( j = 0; j < i; j++ )
										Len += strlen( TmpList[j] ) + 1;
									Arg = malloc( Len );
									if( !Arg )
										return( ENSMEM );
									Tmp = Arg;
									for( j = 0; j < i; j++ )
									{
										strcpy( Tmp, TmpList[j] );
										Tmp += strlen( Tmp ) + 1;
									}
									DelFileNameList( &TmpList );
									MT_graf_mouse( M_SAVE, NULL, GF.Global );
									MT_graf_mouse( BUSYBEE, NULL, GF.Global );
									GetRecursiv( Arg, j, &FileNameList, &PathList, &DirList );
									free( Arg );
									MT_graf_mouse( M_RESTORE, NULL, GF.Global );
									if( DirList || FileNameList )
									{
										DisableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );
										if( DirList[0] )
										{
											nDirList = 0;
											WriteStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[MKD], GF.Global );
											Msg[0] = Mkd_Cmd;
											Msg[1] = AppId;
											Msg[2] = 0;
											(BYTE *) *( LONG *)&( Msg[3] ) = strdup( DirList[nDirList++] );
											if( !(BYTE *) *( LONG *)&( Msg[3] ))
												return( ENSMEM );
											MT_appl_write( FtpAppId, 16, Msg, GF.Global );
										}
										else	if( FileNameList[0] )
										{
											Msg[0] = GemFtp_Put_Start;
											Msg[1] = AppId;
											Msg[2] = 0;
											MT_appl_write( AppId, 16, Msg, GF.Global );
										}
										else
										{
											AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[READY], GF.Global );
											EnableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );												
										}
									}
									else
									{
										AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[READY], GF.Global );
										EnableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );												
									}
#else
									WORD	n = 0;
									if( FileSelectorFlag )
									{
										FselN = 1;
										*( strrchr( FselPath, '\\' ) + 1 ) = 0;
									}
									FileNameList = malloc(( FselN + 1 ) * sizeof( BYTE * ));
									if( !FileNameList )
										return( ENSMEM );
									PathList = malloc(( FselN + 1 ) * sizeof( BYTE * ));
									if( !PathList )
										return( ENSMEM );
									FileNameList[n] = strdup( FselFile );
									if( !FileNameList[n] )
										return( ENSMEM );
									PathList[n] = malloc( strlen( FselFile ) + strlen( FselPath ) + 1 );
									if( !PathList[n] )
										return( ENSMEM );
									strcpy( PathList[n], FselPath );
									strcat( PathList[n++], FselFile );
									if( FselN == 0 )
										FselN = 1;
									while( --FselN )
									{
										MT_fslx_getnxtfile( FselDialog, FselFile, GF.Global );
										FileNameList[n] = strdup( FselFile );
										if( !FileNameList[n] )
											return( ENSMEM );
										PathList[n] = malloc( strlen( FselFile ) + strlen( FselPath ) + 2 );
										if( !PathList[n] )
											return( ENSMEM );
										strcpy( PathList[n], FselPath );
										strcat( PathList[n++], FselFile );
									}
									FileNameList[n] = NULL;
									PathList[n] = NULL;
									Msg[0] = GemFtp_Put_Start;
									Msg[1] = AppId;
									Msg[2] = 0;
									MT_appl_write( AppId, 16, Msg, GF.Global );
#endif
								}
								else
									EnableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );
								FselStatus = -1;
							}
							if( !FileSelectorFlag )
								MT_fslx_close( FselDialog, GF.Global );
							FselDialog = 0L;
						}

					if( Events.mwhich & MU_TIMER )
					{
#ifdef	V110
						if( IConnect && !IConnectSession )
						{
#ifdef DEBUG
	DebugMsg( GF.Global, "ICONNECT MU_TIMER\n" );
#endif
							if( --IConnectTimer < 0 )
							{
#ifdef DEBUG
	DebugMsg( GF.Global, "ICONNECT ICM_STATUS_REQUEST\n" );
#endif
								Msg[0] = ICON_MSG;
								Msg[1] = AppId;
								Msg[2] = 0;
								Msg[3] = ICM_STATUS_REQUEST;
								Msg[4] = 0;
								Msg[5] = 0;
								Msg[6] = 0;
								Msg[7] = -1234;
								MT_appl_write( IConnectAppId, 16, Msg, GF.Global );
							}
							if( IConnectStatus == VA_PROGSTART )
							{
#ifdef DEBUG
	DebugMsg( GF.Global, "ICONNECT VA_PROGSTART\n" );
#endif
								if(( IConnectAppId = MT_appl_find( "ICONNECT", GF.Global )) != -1 )
								{
									if( IConnect & ICONNECT_CONNECT )
									{
										Msg[0] = ICON_MSG;
										Msg[1] = AppId;
										Msg[2] = 0;
										Msg[3] = ICM_STATUS_REQUEST;
										Msg[4] = 0;
										Msg[5] = 0;
										Msg[6] = 0;
										Msg[7] = -1234;
										MT_appl_write( IConnectAppId, 16, Msg, GF.Global );
									}
									else
									{
										Msg[0] = ICON_MSG;
										Msg[1] = AppId;
										Msg[2] = 0;
										Msg[3] = ICM_STATUS_REPLY;
										Msg[4] = ICMS_ONLINE;
										Msg[7] = -1234;
										MT_appl_write( AppId, 16, Msg, GF.Global );
									}
								}
								else
								{
									AlertStatus = IConnect_Failed;
									WindowAlertDialog = WindowAlert( FtpDialogTitle, FstringAddr[ICONNECT_FAILED], 1, GF.Global );
								}
								IConnectTimer = 5;
							}
							if( IConnectStatus == ICM_CONNECTION_REPLY )
							{
#ifdef DEBUG
	DebugMsg( GF.Global, "ICONNECT ICM_CONNECTION_REPLY\n" );
#endif
								IConnectFlag = 1;
								Msg[0] = ICON_MSG;
								Msg[1] = AppId;
								Msg[2] = 0;
								Msg[3] = ICM_STATUS_REQUEST;
								Msg[4] = 0;
								Msg[5] = 0;
								Msg[6] = 0;
								Msg[7] = -1234;
								MT_appl_write( IConnectAppId, 16, Msg, GF.Global );
								IConnectTimer = 5;
							}
							if( IConnectStatus == ICMS_CONNECTING )
							{
#ifdef DEBUG
	DebugMsg( GF.Global, "ICONNECT ICMS_CONNECTING\n" );
#endif
								if( WindowAlertDialog && AlertStatus == Socket_Failed )
									CloseDialog( WindowAlertDialog, GF.Global );
								IConnectFlag = 1;
								Msg[0] = ICON_MSG;
								Msg[1] = AppId;
								Msg[2] = 0;
								Msg[3] = ICM_STATUS_REQUEST;
								Msg[4] = 0;
								Msg[5] = 0;
								Msg[6] = 0;
								Msg[7] = -1234;
								MT_appl_write( IConnectAppId, 16, Msg, GF.Global );
								IConnectTimer = 5;
							}
							IConnectStatus = 0;
						}
#endif
					}

					if( Events.mwhich & MU_KEYBD )
					{
						WORD	w1, w2, w3, w4;
						MT_wind_get( 0, WF_TOP, &w1, &w2, &w3, &w4, GF.Global );
#ifdef	GEMScript
						if( GF.FtpDialog && w1 == MT_wdlg_get_handle( GF.FtpDialog, GF.Global ) && !GsFlag )
#else
						if( GF.FtpDialog && w1 == MT_wdlg_get_handle( GF.FtpDialog, GF.Global ))
#endif
						{
							WORD	Key;
							Key = MapKey( Events.key );
							if(( Key & 0xff ) == 'c' && ( Key & KbCONTROL ))
							{
								Msg[0] = VA_THAT_IZIT;
								Msg[1] = AppId;
								Msg[2] = 0;
								Msg[4] = VA_OB_CLIPBOARD;
								MT_appl_write( AppId, 16, Msg, GF.Global );
								continue;
							}
#ifdef	KEY
							/* Eine Verzeichnisebene hîher ( ctrl H or ctrl BS ) */
							if((( Key & 0xff ) == 'h' || ( Key & 0xff ) == 0x08 ) && ( Key & KbCONTROL ) &&
							  ( TreeAddr[FTP][FTP_CLOSER].ob_flags & SELECTABLE ))
#else
							if(( Key & 0xff ) == 'h' && ( Key & KbCONTROL ) &&
							  ( TreeAddr[FTP][FTP_CLOSER].ob_flags & SELECTABLE ))
#endif							  
							{
								Msg[0] = GemFtp_Cdup;
								Msg[1] = AppId;
								Msg[2] = 0;
								MT_appl_write( AppId, 16, Msg, GF.Global );
								continue;
							}
#ifdef	KEY
						/* hebt eine Selektion auf */
						if((( Key & 0xff ) == 'd'  && ( Key & KbCONTROL )) && !( Key & KbSHIFT ))
						{
							WORD	Slct = MT_lbox_get_slct_idx( GF.FtpListBox, GF.Global );
							WORD	Vis = MT_lbox_get_afirst ( GF.FtpListBox, GF.Global );
							GRECT	Rect, *RectP = NULL;

							if( Slct != -1 )
							{
								STR_ITEM	*Tmp = GF.FtpList;
								while( Tmp )
								{
									Tmp->selected = 0;
									Tmp = Tmp->next;
								}
								if( Slct >= Vis && Slct < Vis + TreeAddr[FTP][FTP_DIR_BOX].ob_height / PhChar )
								{
									if( !isIconifiedWindow( MT_wdlg_get_handle( GF.FtpDialog, GF.Global )))
									{
										OBJECT	*DialogTree;
										MT_wdlg_get_tree( GF.FtpDialog, &DialogTree, &Rect, GF.Global );
										RectP = &Rect;
										MT_lbox_update( GF.FtpListBox, RectP, GF.Global );
									}
								}
							}
							Events.key = 0;
						}
						if(( Key & 0xff ) == KbINSERT && ( Key & KbSCAN ))
						{
							if( !InsertHtDialog	)
								InsertHtDialog = OpenDialog( TreeAddr[IHT], FtpDialogTitle, HandleInsertHtDialog, GF.Global, GF.Global );
							else
							{
								Msg[0] = WM_TOPPED;
								Msg[1] = AppId;
								Msg[2] = 0;
								Msg[3] = MT_wdlg_get_handle( InsertHtDialog, GF.Global );
								MT_appl_write( AppId, 16, Msg, GF.Global );
							}
						}
/* [GS] 1.50a Start */
						if(( Key & 0xff ) == 'a' && ( Key & KbCONTROL ))
						{
							STR_ITEM	*Tmp = GF.FtpList;
							while( Tmp )
							{
								Tmp->selected = 1;
								Tmp = Tmp->next;
							}

							if( !isIconifiedWindow( MT_wdlg_get_handle( GF.FtpDialog, GF.Global )))
							{
								OBJECT	*DialogTree;
								GRECT	Rect, *RectP = NULL;
								
								MT_wdlg_get_tree( GF.FtpDialog, &DialogTree, &Rect, GF.Global );
								RectP = &Rect;
								MT_lbox_update( GF.FtpListBox, RectP, GF.Global );
							}
							Events.key = 0;
						}

						/* Ctrl-DEL */
						if(( Key & 0xff ) == 0x7f && ( Key & KbCONTROL ))
						{
							Msg[0] = GemFtp_Rm;
							Msg[1] = AppId;
							Msg[2] = 0;
							MT_appl_write( AppId, 16, Msg, GF.Global );
						}
/* Ende */
#endif
#ifdef	KEY
						/* Selektierte Datei/Verzeichnis wird geladen/geîffnet (Return/Enter) */
/* [GS] 1.50a Start */
						if( ( Key == 13 || Key == 0x400d) && ( TreeAddr[FTP][FTP_GET].ob_flags & SELECTABLE ))
/* Ende; alt:
						if( Key == 13 && ( TreeAddr[FTP][FTP_GET].ob_flags & SELECTABLE ))
*/
						{
							STR_ITEM	*Slct = NULL, *Tmp = GF.FtpList;
							while( Tmp )
							{
								if( Tmp->selected )
								{
									if( !Slct )
										Slct = Tmp;
									else
									{
										Slct = NULL;
										break;
									}
								}
								Tmp = Tmp->next;
							}
							if( Slct )
							{
								if( *( Slct->str ) == 'd' )
								{
									Msg[0] = GemFtp_Cd;
									Msg[1] = AppId;
									Msg[2] = 0;
									MT_appl_write( AppId, 16, Msg, GF.Global );
								}
								if( *( Slct->str ) == 'l' )
								{
									Msg[0] = GemFtp_Link;
									Msg[1] = AppId;
									Msg[2] = 0;
									MT_appl_write( AppId, 16, Msg, GF.Global );
								}
								if( *( Slct->str ) == '-' )
								{
									Msg[0] = GemFtp_Get;
									Msg[1] = AppId;
									Msg[2] = 0;
									MT_appl_write( AppId, 16, Msg, GF.Global );
								}
							}
							else
							{
								Msg[0] = GemFtp_Get;
								Msg[1] = AppId;
								Msg[2] = 0;
								MT_appl_write( AppId, 16, Msg, GF.Global );
							}
						}
						if(( Key & KbSCAN ) && ( TreeAddr[FTP][FTP_GET].ob_flags & SELECTABLE ))
						{
							if(( Key & 0xff ) == KbLEFT || ( Key & 0xff ) == KbRIGHT )
							{
								GRECT	Rect, *RectP = NULL;
								WORD	Vis, OldVis = MT_lbox_get_bfirst ( GF.FtpListBox, GF.Global );
								WORD	Index;

								if(( Key & 0xff ) == KbLEFT )
									Index = -1;
								if(( Key & 0xff ) == KbRIGHT )
									Index = +1;
								if( Key & KbSHIFT )
									Index *= MT_lbox_get_bvis( GF.FtpListBox, GF.Global );
								Vis = OldVis + Index;
								if( !isIconifiedWindow( MT_wdlg_get_handle( GF.FtpDialog, GF.Global )))
								{
									OBJECT	*DialogTree;
									MT_wdlg_get_tree( GF.FtpDialog, &DialogTree, &Rect, GF.Global );
									RectP = &Rect;
								}
								if( Vis != OldVis )
								{
									MT_lbox_set_bsldr( GF.FtpListBox, Vis, RectP, GF.Global );
									DoRedraw( GF.FtpDialog, RectP, FTP_DIR_BACK_H, GF.Global );
									MT_lbox_update( GF.FtpListBox, RectP, GF.Global );
								}
							}
							if(( Key & 0xff ) == KbUP || ( Key & 0xff ) == KbDOWN || ( Key & 0xff ) == KbHOME || ( Key & 0xff ) == 0x4f )
							{
								WORD	Slct, OldSlct = MT_lbox_get_slct_idx( GF.FtpListBox, GF.Global );
								WORD	Vis, OldVis = MT_lbox_get_afirst ( GF.FtpListBox, GF.Global );
								WORD	Index;
								GRECT	Rect, *RectP = NULL;

								if( OldSlct != -1 && !( Key & KbCONTROL ))
								{
									STR_ITEM	*Tmp = GF.FtpList;
									while( Tmp )
									{
										Tmp->selected = 0;
										Tmp = Tmp->next;
									}
								}

								if(( Key & 0xff ) == KbDOWN )
									Index = 1;
								if(( Key & 0xff ) == KbUP )
									Index = -1;
								if( Key & KbSHIFT )
									Index *= TreeAddr[FTP][FTP_DIR_BOX].ob_height / PhChar;

								if(( Key & 0xff ) == KbHOME && !( Key & KbSHIFT ))
									Index = -32000;
								if(( Key & 0xff ) == KbHOME && ( Key & KbSHIFT ) || ( Key & 0xff ) == 0x4f )
									Index = 32000;

								if( Key & KbCONTROL )
									Vis = OldVis + Index;
								else
								{
									Slct = OldSlct + Index;
									if( Slct < 0 )
										Slct = 0;
									if( Slct >= MT_lbox_cnt_items( GF.FtpListBox, GF.Global ))
										Slct = MT_lbox_cnt_items( GF.FtpListBox, GF.Global ) - 1;
									MT_lbox_get_item( GF.FtpListBox, Slct, GF.Global )->selected = 1;
									Vis = OldVis;
									if( Slct < Vis )
										Vis = Slct;
									if( Slct >= Vis + TreeAddr[FTP][FTP_DIR_BOX].ob_height / PhChar )
										Vis = Slct + 1 - TreeAddr[FTP][FTP_DIR_BOX].ob_height / PhChar;
								}

								if( Vis == - 1 )
									Vis = 0;
								if( Vis >= MT_lbox_cnt_items( GF.FtpListBox, GF.Global ))
									Vis = MT_lbox_cnt_items( GF.FtpListBox, GF.Global ) - 1;
								
								if( !isIconifiedWindow( MT_wdlg_get_handle( GF.FtpDialog, GF.Global )))
								{
									OBJECT	*DialogTree;
									MT_wdlg_get_tree( GF.FtpDialog, &DialogTree, &Rect, GF.Global );
									RectP = &Rect;
								}
								if( Vis != OldVis )
									MT_lbox_set_asldr( GF.FtpListBox, Vis, RectP, GF.Global );
								if( Vis != OldVis || Slct != OldSlct )
									MT_lbox_update( GF.FtpListBox, RectP, GF.Global );
							}
							
						}
#endif
						}
						KeyEvent( Events.key, GF.Global );
					}

					if( Events.mwhich & MU_MESAG )
					{
						switch( Events.msg[0] )
						{
/* AP_TERM --------------------------------------------------------------------*/
							case	AP_TERM:
								if( !SeCancelDialog )
									SeCancelDialog = OpenDialog( TreeAddr[SE_CANCEL], FtpDialogTitle, HandleSeCancelDialog, (void *) &GF, GF.Global );
								else
									MT_wind_set( MT_wdlg_get_handle( SeCancelDialog, GF.Global ), WF_TOP, 0, 0, 0, 0, GF.Global );
								break;
/* AP_DRAGDROP ----------------------------------------------------------------*/
							case	AP_DRAGDROP:
							{
								void	*OldSig;
								BYTE	Pipename[] = "U:\\PIPE\\DRAGDROP.AA";
								BYTE	*Data;
								ULONG	FormatRcvr[8], Format;
								LONG	Size;
								BYTE	Name[255];
								WORD	Fd;
								Pipename[18] = Events.msg[7] & 0x00ff;
								Pipename[17] = ( Events.msg[7] & 0xff00 ) >> 8;

#ifdef DEBUG
	DebugMsg( GF.Global, "AP_DRAGDROP\n" );
#endif
								if( Events.msg[3] != MT_wdlg_get_handle( GF.FtpDialog, GF.Global ))
								{
									Fd = ( WORD ) Fopen (Pipename, 2);
									if (Fd >= 0)
									{
										BYTE c = DD_NAK;
										Fwrite ((WORD) Fd, 1, &c);
										Fclose ((WORD) Fd);
									}
									break;
								}

								FormatRcvr[0] = 'ARGS';
								FormatRcvr[1] = 0;	FormatRcvr[2] = 0;	FormatRcvr[3] = 0;	FormatRcvr[4] = 0;
								FormatRcvr[5] = 0;	FormatRcvr[6] = 0;	FormatRcvr[7] = 0;

								if(( Fd = ddopen( Pipename, FormatRcvr, &OldSig )) != -1 )
								{
									while( ddrtry( Fd, Name, &Format, &Size) == 1 )
									{
										if( Format == 'ARGS' )
										{
											Data = malloc( Size * sizeof( BYTE ) + 1 );
											if( !Data )
												return( ENSMEM );
											ddreply( Fd, DD_OK );
											Fread( Fd, Size, Data );
											Data[Size] = 0;
										   if( TreeAddr[FTP][FTP_PUT].ob_flags & SELECTABLE )
											{
												WORD	n = parse_ARGS( Data );
#ifdef	RECURSIV
												MT_graf_mouse( M_SAVE, NULL, GF.Global );
												MT_graf_mouse( BUSYBEE, NULL, GF.Global );
												GetRecursiv( Data, n, &FileNameList, &PathList, &DirList );
												MT_graf_mouse( M_RESTORE, NULL, GF.Global );
												if( DirList || FileNameList )
												{
													DisableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );
													if( DirList[0] )
													{
														nDirList = 0;
														WriteStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[MKD], GF.Global );
														Msg[0] = Mkd_Cmd;
														Msg[1] = AppId;
														Msg[2] = 0;
														(BYTE *) *( LONG *)&( Msg[3] ) = strdup( DirList[nDirList++] );
														if( !(BYTE *) *( LONG *)&( Msg[3] ))
															return( ENSMEM );
														MT_appl_write( FtpAppId, 16, Msg, GF.Global );
													}
													else	if( FileNameList[0] )
													{
														Msg[0] = GemFtp_Put_Start;
														Msg[1] = AppId;
														Msg[2] = 0;
														MT_appl_write( AppId, 16, Msg, GF.Global );
													}
													else
													{
														AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[READY], GF.Global );
														EnableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );
													}
												}
												else
												{
													AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[READY], GF.Global );
													EnableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );												
												}
#else
												WORD	i = 0;
												BYTE	*c = Data;
												FileNameList = malloc(( n + 1 ) * sizeof( BYTE * ));
												if( !FileNameList )
													return( ENSMEM );
												PathList = malloc(( n + 1 ) * sizeof( BYTE * ));
												if( !PathList )
													return( ENSMEM );
												while( n )
												{
													if( strlen( strrchr( c, '\\' )) != 1 )
													{
														PathList[i] = strdup( c );
														if( !PathList[i] )
															return( ENSMEM );
														FileNameList[i++] = strdup( strrchr( c, '\\' ) + 1 );
														if( !FileNameList[i-1] )
															return( ENSMEM );
													}
													c += strlen( c ) + 1;
													n--;
												}
												PathList[i] = NULL;
												FileNameList[i] = NULL;
												if( FileNameList[0] == NULL )
												{
													free( FileNameList );
													free( PathList );
												}
												else
												{				
													DisableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );
													Msg[0] = GemFtp_Put_Start;
													Msg[1] = AppId;
													Msg[2] = 0;
													MT_appl_write( AppId, 16, Msg, GF.Global );
												}
#endif
											}
											else
											{
												if( !DdDialog )
													DdDialog = OpenDialog( TreeAddr[DD], FtpDialogTitle, HandleDdDialog, (void *) GF.Global, GF.Global );
												else
													MT_wind_set( MT_wdlg_get_handle( DdDialog, GF.Global ), WF_TOP, 0, 0, 0, 0, GF.Global );
											}
											free( Data );
											break;
										}
										else
											if( !ddreply( Fd, DD_EXT ))
												break;
									}
									ddclose( Fd, OldSig );
								}
								break;
							}
/* WM_ALLICONIFY --------------------------------------------------------------*/
								case	WM_ALLICONIFY:
									MT_appl_write( Global[2], 16, Events.msg, GF.Global );
									break;
/* THR_EXIT -------------------------------------------------------------------*/
							case	THR_EXIT:
#ifdef DEBUG
	DebugMsg( GF.Global, "THR_EXIT [AppId = %i] = %i\n", AppId, Events.msg[3] );
#endif
								FtpAppId = -1;
								Msg[0] = GemFtp_Shutdown;
								Msg[1] = AppId;
								Msg[2] = 0;
								MT_appl_write( AppId, 16, Msg, GF.Global );
								break;	
/* DHST-Protokoll -------------------------------------------------------------*/
#ifdef	DHST
							case	DHST_ACK:
							{
								DHSTINFO	*Tmp = *( DHSTINFO ** ) &( Events.msg[3] );
								if( Tmp )
								{
									Mfree( Tmp->appname );
									Mfree( Tmp->apppath );
									Mfree( Tmp->docname );
									Mfree( Tmp->docpath );
									Mfree( Tmp );
								}
								break;
							}
#endif
/* AV-Protokoll ---------------------------------------------------------------*/
							case	VA_PROTOSTATUS:
								break;
#ifdef	V110
							case	VA_PROGSTART:
								if( Events.msg[7] == -1234 )
									IConnectStatus = VA_PROGSTART;
								break;
#endif
							case	VA_THAT_IZIT:
								if( Events.msg[4] == VA_OB_FOLDER || Events.msg[4] == VA_OB_DRIVE )
								{
									BYTE	*Dir = strdup(( BYTE * ) *( LONG *)&( Events.msg[5] ));
									if( !Dir )
										return( ENSMEM );
									DisableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );
									GetFileNameList( FILE_ITEM + LINK_ITEM, GF.FtpList, &FileNameList );
									if( FileNameList )
									{
										GetFileSizeList( FILE_ITEM + LINK_ITEM, GF.FtpList, &FileSizeList );
										(BYTE *) *( LONG *)&( Msg[4] ) = strdup( Dir );
										if( !(BYTE *) *( LONG *)&( Msg[4] ))
											return( ENSMEM );
										Msg[0] = GemFtp_Get_Prepare;
										Msg[1] = AppId;
										Msg[2] = 0;
										MT_appl_write( AppId, 16, Msg, GF.Global );
									}
									else
									{
										EnableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );
									}
									free( Dir );
								}
								if( Events.msg[4] == VA_OB_TRASHCAN || Events.msg[4] == VA_OB_SHREDDER )
								{
									Msg[0] = GemFtp_Rm;
									Msg[1] = AppId;
									Msg[2] = 0;
									MT_appl_write( AppId, 16, Msg, GF.Global );
								}
								if( Events.msg[4] == VA_OB_CLIPBOARD )
								{
									WORD	i = 0;
									LONG	Size = 0;
									BYTE	*Puf;
									GetFileNameList( FILE_ITEM + DIR_ITEM, GF.FtpList, &FileNameList );
									if( FileNameList )
									{
										while( FileNameList[i] )
											Size += strlen( GF.Session.Dir ) + strlen( FileNameList[i++] ) + 3;
										Puf = malloc( Size + 1 );
										if( !Puf )
											return( ENSMEM );
										strcpy( Puf, "" );
										i = 0;
										while( FileNameList[i] )
										{
											strcat( Puf, GF.Session.Dir );
											strcat( Puf, "/" );
											strcat( Puf, FileNameList[i++] );
											strcat( Puf, "\r\n" );
										}
										ScrapDirCutTxt( Puf, GF.Global );
										free( Puf );
										DelFileNameList( &FileNameList );
									}
									else
										ScrapDirCutTxt( GF.Session.Dir, GF.Global );
								}
								break;
/******************************************************************************/
/* GEMScript                                                                  */
/******************************************************************************/
#ifdef	GEMScript
								case	GS_REQUEST:
								case	GS_ACK:
								case	GS_QUIT:
								case	GS_COMMAND:
								{
									Msg[0] = Events.msg[0];
									Msg[1] = Events.msg[1];
									Msg[2] = Events.msg[2];
									Msg[3] = Events.msg[3];
									Msg[4] = Events.msg[4];
									Msg[5] = Events.msg[5];
									Msg[6] = Events.msg[6];
									Msg[6] = -1;
									Msg[7] = Events.msg[7];
									MT_appl_write( Global[2], 16, Msg, GF.Global );
									break;
								}
								case	GS_CONNECTION:
								if( Events.msg[7] == Global[2] )
								{
									GsCmd = *( BYTE **) &Events.msg[3];
/* GEMScript: GetFront -----------------------------------------------------*/
									if( !stricmp( GsCmd, "getfront" ))
									{
										BYTE	*Ret;
										Ret = Xmalloc( strlen( GF.Session.Host ) + 2, RAM_READABLE );
										strcpy( Ret, GF.Session.Host );
										Ret[strlen( Ret )] = 0;
										Msg[0] = GS_ACK;
										Msg[1] = Global[2];
										Msg[2] = 0;
										*( BYTE **) &Msg[3] = GsCmd;
										*( BYTE **) &Msg[5] = Ret;
										Msg[7] = GSACK_OK;
										MT_appl_write( Events.msg[1], 16, Msg, GF.Global );
										break;
									}
/* GEMScript: tofront ---------------------------------------------------------*/
									if( !stricmp( GsCmd, "tofront" ))
									{
										MT_wind_set( MT_wdlg_get_handle( GF.FtpDialog, GF.Global ), WF_TOP, 0, 0, 0, 0, GF.Global );
										Msg[0] = GS_ACK;
										Msg[1] = AppId;
										Msg[2] = 0;
										*( BYTE ** ) &Msg[3] = GsCmd;
										*( BYTE ** ) &Msg[5] = NULL;
										Msg[7] = GSACK_OK;
										MT_appl_write( Events.msg[1], 16, Msg, Global );
										break;
									}

									if( !GsFlag )
									{
										BYTE	*Ret = Xmalloc( 4, RAM_READABLE );
										Ret[0] = '-';
										Ret[1] = '1';
										Ret[2] = 0;
										Ret[3] = 0;
										Msg[0] = GS_ACK;
										Msg[1] = AppId;
										Msg[2] = 0;
										*( BYTE **) &Msg[3] = GsCmd;
										*( BYTE **) &Msg[5] = Ret;
										Msg[7] = GSACK_ERROR;
										MT_appl_write( Events.msg[1], 16, Msg, Global );
										break;
									}
/* GEMScript: cd --------------------------------------------------------------*/
									if( !stricmp( GsCmd, "cd" ))
									{
										BYTE	*Para = GsCmd + strlen( GsCmd ) + 1;
										Para = Para + strlen( Para ) + 1;
/*										if( *Para == '/' )
										{	*/
											if( GF.Session.Dir )
												free( GF.Session.Dir );
											GF.Session.Dir = strdup( Para );
/*										} 
										else
										{
											BYTE	*Tmp;
											if( GF.Session.Dir )
											{
												Tmp = malloc( strlen( GF.Session.Dir ) + strlen( Para ) + 2 );
												strcpy( Tmp, GF.Session.Dir );
												free( GF.Session.Dir );
											}
											else
											{
												Tmp = malloc( strlen( Para ) + 1 );
												strcpy( Tmp, "" );
											}
											strcat( Tmp, "/" );
											strcat( Tmp, Para );
											GF.Session.Dir = Tmp;
										}
										if( GF.Session.Dir[strlen( GF.Session.Dir )] == '/' )
											GF.Session.Dir[strlen( GF.Session.Dir )] = 0;
*/
										WriteStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[CWD], GF.Global );
										AppendStatusGemFtp( GF.FtpDialog, InfoPuf, GF.Session.Dir, GF.Global );
										Msg[0] = Cwd_Cmd;
										Msg[1] = AppId;
										Msg[2] = 0;
										(BYTE *) *( LONG *)&( Msg[3] ) = GF.Session.Dir;
										MT_appl_write( FtpAppId, 16, Msg, GF.Global );
										break;
									}
/* GEMScript: close -----------------------------------------------------------*/
									if( !stricmp( GsCmd, "close" ))
									{
										BYTE	*Ret = Xmalloc( 3, RAM_READABLE );
										Msg[0] = GemFtp_Shutdown;
										Msg[1] = AppId;
										Msg[2] = 0;
										MT_appl_write( AppId, 16, Msg, GF.Global );
/* Das eventuell woanders hinpacken */
										strcpy( Ret, "0" );
										Ret[2] = 0;
										Msg[0] = GS_ACK;
										Msg[1] = Global[2];
										Msg[2] = 0;
										*( BYTE **) &Msg[3] = GsCmd;
										*( BYTE **) &Msg[5] = Ret;
										Msg[7] = GSACK_OK;
										MT_appl_write( GsAppId, 16, Msg, GF.Global );
										break;
									}
/* GEMScript: get -----------------------------------------------------------*/
									if( !stricmp( GsCmd, "get" ))
									{
										BYTE	*Para = GsCmd + strlen( GsCmd ) + 1;
										BYTE	*FileName, *LocalFileName, LocalDir[PathLen];
										LONG	Err;
										XATTR	Xattr;
										Para = Para + strlen( Para ) + 1;

										if( strrchr( Para, '/' ) == NULL )
											FileName = Para;
										else
											FileName = strrchr( Para, '/' ) + 1;

										LocalFileName = Para + strlen( Para ) + 1;
										if( *LocalFileName == 0 )
										{
											if( RxDir )
												strcpy( LocalDir, RxDir );
											else
												strcpy( LocalDir, "" );
											strcat( LocalDir, FileName );
										}
										else
										{
											strcpy( LocalDir, LocalFileName );
											if( strrchr( LocalFileName, '\\' ) == &LocalFileName[strlen( LocalFileName )+1])
												strcat( LocalDir, FileName );
										}
										
										if(( Err = Fxattr( 0, LocalDir, &Xattr )) == E_OK )
										{
										}
/* Hier öberprÅfung, ob Datei bereits existiert */										
										FileNameList = malloc( 2 * sizeof( BYTE * ));
										if( !FileNameList )
											return( ENSMEM );
										FileNameList[0] = strdup( Para );
										if( !FileNameList[0] )
											return( ENSMEM );
										FileNameList[1] = NULL;

										PathList = malloc( 2 * sizeof( BYTE * ));
										if( !PathList )
											return( ENSMEM );
										PathList[0] = strdup( LocalDir );
										if( !PathList[0] )
											return( ENSMEM );
										PathList[1] = NULL;
										nFileNameList = 1;										

										Msg[0] = GemFtp_Get_Start;
										Msg[1] = AppId;
										Msg[2] = 0;
										MT_appl_write( AppId, 16, Msg, GF.Global );
										break;
									}
/* GEMScript: ls -----------------------------------------------------------*/
									if( !stricmp( GsCmd, "ls" ))
									{
										BYTE	*Para = GsCmd + strlen( GsCmd ) + 1;
										STR_ITEM	*Item, *Tmp;
										Para = Para + strlen( Para ) + 1;
										
										Item = GF.FtpList;
										while( Item )
										{
											Tmp = Item->next;
											free( Item->str );
											free( Item );
											Item = Tmp;
										}
										GF.FtpList = NULL;

										WriteStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[LIST], GF.Global );
										if( *Para )
											AppendStatusGemFtp( GF.FtpDialog, InfoPuf, Para, GF.Global );
										Msg[0] = List_Cmd;
										Msg[1] = AppId;
										Msg[2] = 0;
										(STR_ITEM **) *( LONG *)&( Msg[3] ) = &(GF.FtpList);
										if( *Para )
											*( BYTE **) &Msg[5] = Para;
										else
											*( BYTE **) &Msg[5] = NULL;
										Msg[7] = GEMScriptSession;
										MT_appl_write( FtpAppId, 16, Msg, GF.Global );

										break;
									}
/* GEMScript: mkdir -----------------------------------------------------------*/
									if( !stricmp( GsCmd, "mkdir" ))
									{
										BYTE	*Para = GsCmd + strlen( GsCmd ) + 1;
										Para = Para + strlen( Para ) + 1;
										Msg[0] = Mkd_Cmd;
										Msg[1] = AppId;
										Msg[2] = 0;
										*(BYTE **) &( Msg[3] ) = strdup( Para );
										if( !*(BYTE **) &( Msg[3] ))
											return( ENSMEM );
										MT_appl_write( FtpAppId, 16, Msg, GF.Global );
										break;
									}
/* GEMScript: put -------------------------------------------------------------*/
									if( !stricmp( GsCmd, "put" ))
									{
										LONG	Err;
										BYTE	*Para = GsCmd + strlen( GsCmd ) + 1;
										BYTE	*FileName, *ServerFileName;
										XATTR	Xattr;
										Para = Para + strlen( Para ) + 1;
										if(( Err = Fxattr( 0, Para, &Xattr )) != E_OK )
										{
											BYTE	*Ret = Xmalloc( 7, RAM_READABLE );
											itoa(( WORD ) Err, Ret, 10 );
											Ret[strlen( Ret ) + 1] = 0;
											Msg[0] = GS_ACK;
											Msg[1] = AppId;
											Msg[2] = 0;
											*( BYTE **) &Msg[3] = GsCmd;
											*( BYTE **) &Msg[5] = Ret;
											Msg[7] = GSACK_ERROR;
											MT_appl_write( Events.msg[1], 16, Msg, Global );
											break;
										}
										FileName = Para;
										FileNameList = malloc( 2 * sizeof( BYTE * ));
										if( !FileNameList )
											return( ENSMEM );
										FileNameList[1] = NULL;
										PathList = malloc( 2 * sizeof( BYTE * ));
										if( !PathList )
											return( ENSMEM );
										PathList[0] = strdup( FileName );
										if( !PathList[0] )
											return( ENSMEM );
										PathList[1] = NULL;
										nFileNameList = 1;										
										if( strrchr( FileName, '\\' ) != NULL )
											ServerFileName = strrchr( FileName, '\\' ) + 1;
										else
											ServerFileName = FileName;
										Para = Para + strlen( Para ) + 1;
										if( *Para != 0 )
										{
											if( Para[strlen(Para)-1] == '/' )
											{
												FileNameList[0] = malloc( strlen( Para ) + strlen( ServerFileName ) + 1 );
												if( !FileNameList[0] )
													return( ENSMEM );
												strcpy( FileNameList[0], Para );
												strcat( FileNameList[0], ServerFileName );
											}
											else
												FileNameList[0] = strdup( Para );
										}
										else
											FileNameList[0] = strdup( ServerFileName );
										if( !FileNameList[0] )
											return( ENSMEM );
										Msg[0] = GemFtp_Put_Start;
										Msg[1] = AppId;
										Msg[2] = 0;
										MT_appl_write( AppId, 16, Msg, GF.Global );
										break;
									}
/* GEMScript: pwd -------------------------------------------------------------*/
									if( !stricmp( GsCmd, "pwd" ))
									{
										WriteStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[PWD], GF.Global );
										Msg[0] = Pwd_Cmd;
										Msg[1] = AppId;
										Msg[2] = 0;
										(BYTE **) *( LONG *)&( Msg[3] ) = &( GF.Session.Dir );
										MT_appl_write( FtpAppId, 16, Msg, GF.Global );
										break;
									}
/* GEMScript: rm -----------------------------------------------------------*/
									if( !stricmp( GsCmd, "rm" ))
									{
										BYTE	*Para = GsCmd + strlen( GsCmd ) + 1;
										Para = Para + strlen( Para ) + 1;
										Msg[0] = Dele_Cmd;
										Msg[1] = AppId;
										Msg[2] = 0;
										FileNameList = malloc( 2 * sizeof( BYTE * ));
										if( !FileNameList )
											return( ENSMEM );
										FileNameList[0] = strdup( Para );
										if( !FileNameList[0] )
											return( ENSMEM );
										FileNameList[1] = NULL;
										(BYTE **) *( LONG *)&( Msg[3] ) = FileNameList;
										MT_appl_write( FtpAppId, 16, Msg, GF.Global );
										break;
									}
/* GEMScript: rmdir -----------------------------------------------------------*/
									if( !stricmp( GsCmd, "rmdir" ))
									{
										BYTE	*Para = GsCmd + strlen( GsCmd ) + 1;
										Para = Para + strlen( Para ) + 1;
										Msg[0] = Rmd_Cmd;
										Msg[1] = AppId;
										Msg[2] = 0;

										FileNameList = malloc( 2 * sizeof( BYTE * ));
										if( !FileNameList )
											return( ENSMEM );
										FileNameList[0] = strdup( Para );
										if( !FileNameList[0] )
											return( ENSMEM );
										FileNameList[1] = NULL;
										(BYTE **) *( LONG *)&( Msg[3] ) = FileNameList;
										MT_appl_write( FtpAppId, 16, Msg, GF.Global );
										break;
									}
/* GEMScript: type ------------------------------------------------------------*/
									if( !stricmp( GsCmd, "type" ))
									{
										BYTE	*Para = GsCmd + strlen( GsCmd ) + 1;
										BYTE	*Ret = Xmalloc( 3, RAM_READABLE );
										Para = Para + strlen( Para ) + 1;
										if( *Para &&
										  ( !stricmp( Para, "auto" ) || !stricmp( Para, "ascii" ) || !stricmp( Para, "binary" )))
										{
											if( !stricmp( Para, "auto" ))
												GsTransferType = TT_Auto;
											if( !stricmp( Para, "binary" ))
												GsTransferType = TT_Bin;
											if( !stricmp( Para, "ascii" ))
												GsTransferType = TT_Ascii;
											strcpy( Ret, "0" );
											Msg[7] = GSACK_OK;
										}
										else
										{
											strcpy( Ret, "1" );
											Msg[7] = GSACK_ERROR;
										}
										Ret[2] = 0;

										Msg[0] = GS_ACK;
										Msg[1] = Global[2];
										Msg[2] = 0;
										*( BYTE **) &Msg[3] = GsCmd;
										*( BYTE **) &Msg[5] = Ret;
										Msg[7] = GSACK_OK;
										MT_appl_write( GsAppId, 16, Msg, GF.Global );
										break;
									}
/* GEMScript: chmod -----------------------------------------------------------*/
									if( !stricmp( GsCmd, "chmod" ))
									{
										BYTE	*Mode = GsCmd + strlen( GsCmd ) + 1;
										BYTE	*Name = Mode + strlen( Mode ) + 1;
										FileNameList = malloc( 2 * sizeof( BYTE * ));
										if( !FileNameList )
											return( ENSMEM );
										FileNameList[0] = strdup( Name );
										if( !FileNameList[0] )
											return( ENSMEM );
										FileNameList[1] = NULL;
										MT_appl_write( FtpAppId, 16, Msg, GF.Global );
										Msg[0] = Chmod_Cmd;
										Msg[1] = AppId;
										Msg[2] = 0;
										(BYTE **) *( LONG *)&( Msg[3] ) = FileNameList;
										(BYTE *) *( LONG *)&( Msg[5] ) = Mode;
										MT_appl_write( FtpAppId, 16, Msg, GF.Global );
										break;
									}
								}
								break;
#endif
/******************************************************************************/
/* IConnect                                                                    */
/******************************************************************************/
#ifdef	V110
							case	ICON_MSG:
							{
								if( Events.msg[3] == ICM_STATUS_REPLY && Events.msg[7] == -1234 )
								{
									switch( Events.msg[4] )
									{
										case	ICMS_OFFLINE:
										{
#ifdef DEBUG
	DebugMsg( GF.Global, "ICONNECT ICMS_OFFLINE\n" );
#endif
											if( !IConnectFlag )
											{
												Msg[0] = ICON_MSG;
												Msg[1] = AppId;
												Msg[2] = 0;
												Msg[3] = ICM_CONNECTION_REQUEST;
												Msg[4] = 0;
												Msg[5] = 0;
												Msg[6] = 0;
												Msg[7] = -1234;
												MT_appl_write( IConnectAppId, 16, Msg, GF.Global );
											}
											else
											{
#ifdef	GEMScript
												if( GsFlag )
												{
													BYTE	*Ret = Xmalloc( 4, RAM_READABLE );
													strcpy( Ret, "-3" );
													Ret[3] = 0;
													Msg[0] = GS_ACK;
													Msg[1] = Global[2];
													Msg[2] = 0;
													*( BYTE **) &Msg[3] = GsCmd;
													*( BYTE **) &Msg[5] = Ret;
													Msg[7] = GSACK_ERROR;
													MT_appl_write( GsAppId, 16, Msg, GF.Global );
													Msg[0] = GemFtp_Shutdown;
													Msg[1] = AppId;
													Msg[2] = 0;
													MT_appl_write( AppId, 16, Msg, GF.Global );
													break;
												}
#endif
												if( !WindowAlertDialog )
												{
													AlertStatus = Socket_Failed;
													WindowAlertDialog = WindowAlert( FtpDialogTitle, FstringAddr[SOCKET_FAILED], 1, GF.Global );
												}
												IConnectSession = 1;
#ifdef	V120
												if(( IConnect & ICONNECT_START ) && !( IConnect & ICONNECT_CONNECT ))
												{
													WriteStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[WAITFORICONNECT], GF.Global );
													nCmd = 0;
													IConnectSession = 0;
													IConnectTimer = 5;
													IConnectFlag = 1;
													IConnectStatus = 0;
												}
#endif
											}
											break;
										}
										case	ICMS_CONNECTING:
										{
#ifdef DEBUG
	DebugMsg( GF.Global, "ICONNECT ICMS_CONNECTING\n" );
#endif
											IConnectStatus = ICMS_CONNECTING;
											IConnectStarted = 1;
											break;
										}
										case	ICMS_ONLINE:
										{
#ifdef DEBUG
	DebugMsg( GF.Global, "ICONNECT ICMS_ONLINE\n" );
#endif
											if( WindowAlertDialog && AlertStatus == Socket_Failed )
											{
												IConnectStarted = 1;
												CloseDialog( WindowAlertDialog, GF.Global );
											}
											IConnectSession = 1;
											nCmd = 0;
											Msg[0] = GemFtp_Cmd;
											Msg[1] = AppId;
											Msg[2] = 0;
											MT_appl_write( AppId, 16, Msg, GF.Global );
/*											IConnectStarted = 1;	*/
											break;
										}
										case	ICMS_CLOSING:
											break;
									}
								}

								if( Events.msg[3] == ICM_CONNECTION_REPLY && Events.msg[7] == -1234 )
								{
#ifdef DEBUG
	DebugMsg( GF.Global, "ICONNECT ICM_CONNECTION_REPLY\n" );
#endif
									IConnectStatus = ICM_CONNECTION_REPLY;
								}

								break;
							}
#endif
#ifdef	V110
							case	DragDropUrl:
							{
								if( DDUrl( Events.msg[3], Events.msg[4], Events.msg[5], *(BYTE **) &( Events.msg[6] ), GF.Global ) != E_OK )
								{
									free( *(BYTE **) &( Events.msg[6] ));
									if( !DragDropFailedDialog	)
										DragDropFailedDialog = OpenDialog( TreeAddr[DDF], FtpDialogTitle, HandleDragDropFailedDialog, GF.Global, GF.Global );
									else
									{
										Msg[0] = WM_TOPPED;
										Msg[1] = AppId;
										Msg[2] = 0;
										Msg[3] = MT_wdlg_get_handle( DragDropFailedDialog, GF.Global );
										MT_appl_write( AppId, 16, Msg, GF.Global );
									}
								}
								break;
							}
#endif
/* Fsel_Msg -------------------------------------------------------------------*/
							case	Fsel_Msg:
							{
								if( Events.msg[3] == Fsel_Open && Events.msg[4] == Fsel_GemFtp_Get )
								{
#ifdef	V120
									if( RxDir && Shift == 0 )
#else
									if( RxDir )
#endif
									{
										(BYTE *) *( LONG *)&( Msg[4] ) = strdup( RxDir );
										if( !(BYTE *) *( LONG *)&( Msg[4] ))
											return( ENSMEM );
										Msg[0] = GemFtp_Get_Prepare;
										Msg[1] = AppId;
										Msg[2] = 0;
										MT_appl_write( AppId, 16, Msg, GF.Global );
									}
									else
									{
#ifdef	V120
										RxDir ? strcpy( FselPath, RxDir ) : strcpy( FselPath, "" );
#else
										strcpy( FselPath, "" );
#endif
										strcpy( FselFile, "" );
										strcpy( FselPath, "*" );
										if( FileSelectorFlag )
											FselDialog = ( void * ) MT_fsel_exinput( FselPath, FselFile, &FselButton, FstringAddr[FS_TITLE_RX], GF.Global );
										else
											FselDialog = WindowFileselector( 0, FstringAddr[FS_TITLE_RX], FselPath, FselFile, &FselHandle, GF.Global );
										FselStatus = Fsel_GemFtp_Get;
									}
									break;
								}
								if( Events.msg[3] == Fsel_Open && Events.msg[4] == Fsel_GemFtp_Put )
								{
									if( TxDir )
										strcpy( FselPath, TxDir );
									else
										strcpy( FselPath, "" );
									strcpy( FselPath, "*" );
									strcpy( FselFile, "" );
									if( FileSelectorFlag )
										FselDialog = ( void * ) MT_fsel_exinput( FselPath, FselFile, &FselButton, FstringAddr[FS_TITLE_TX_FILE], GF.Global );
									else
										FselDialog = WindowFileselector( GETMULTI, FstringAddr[FS_TITLE_TX_FILE], FselPath, FselFile, &FselHandle, GF.Global );
									FselStatus = Fsel_GemFtp_Put;
									break;
								}
								if( Events.msg[3] == Fsel_Open && Events.msg[4] == Fsel_File_Rename )
								{
									strcpy( FselPath, TreeAddr[FILE_D][FILE_PATH].ob_spec.free_string );
									strcpy( FselFile, TreeAddr[FILE_D][FILE_OLD].ob_spec.free_string );
									if( FileSelectorFlag )
										FselDialog = ( void * ) MT_fsel_exinput( FselPath, FselFile, &FselButton, FstringAddr[FILE_FSEL_TITLE], GF.Global );
									else
										FselDialog = WindowFileselector( 0, FstringAddr[FILE_FSEL_TITLE], FselPath, FselFile, &FselHandle, GF.Global );
									FselStatus = Fsel_File_Rename;
									break;
								}
							}
/* Cmd ------------------------------------------------------------------------*/
							case	GemFtp_Cmd:
								if( Cmd[nCmd] )
								{
#ifdef	GEMScript
									if( Cmd[nCmd] == GS_CONNECTION )
									{
										BYTE	*Ret = Xmalloc( 7, RAM_READABLE );
										nCmd++;
										itoa( AppId, Ret, 10 );
										Ret[strlen( Ret ) + 1] = 0;
										Msg[0] = GS_ACK;
										Msg[1] = Global[2];
										Msg[2] = 0;
										*( BYTE **) &Msg[3] = GsCmd;
										*( BYTE **) &Msg[5] = Ret;
										Msg[7] = GSACK_ERROR;
										MT_appl_write( GsAppId, 16, Msg, GF.Global );
										break;
									}
#endif
									Msg[0] = Cmd[nCmd++];
									Msg[1] = AppId;
									Msg[2] = 0;
									MT_appl_write( AppId, 16, Msg, GF.Global );
								}
								break;
							case	GemFtp_CmdFailed:
								if( CmdFailed[nCmd-1] )
								{
									nCmd = CmdFailed[nCmd - 1];
									Msg[0] = GemFtp_Cmd;
									Msg[1] = AppId;
									Msg[2] = 0;
									MT_appl_write( AppId, 16, Msg, GF.Global );
								}
								break;
							case	GemFtp_OpenSession:
								Msg[0] = SocketInit_Cmd;
								Msg[1] = AppId;
								Msg[2] = 0;
								MT_appl_write( FtpAppId, 16, Msg, GF.Global );
								break;							
/* GemFtp_Link ----------------------------------------------------------------*/
							case	GemFtp_Link:
							{
								WORD		n = 0;
								STR_ITEM	*Item, *ItemSlct;
								Item = GF.FtpList;
								while( Item )
								{
									if( *( Item->str ) == 'l' && Item->selected )
									{
										ItemSlct = Item;
										n++;
									}
									Item = Item->next;
								}
								if( n == 1 )
								{
									BYTE	*Tmp = strdup( GF.Session.Dir ), *DirName;
									if( !Tmp )
										return( ENSMEM );
									free( GF.Session.Dir );
									GetFileName( ItemSlct, &DirName );
									GF.Session.Dir = malloc( strlen( Tmp ) + strlen( DirName ) + 2 );
									strcpy( GF.Session.Dir, Tmp );
									if( GF.Session.Dir[strlen( GF.Session.Dir )-1] != '/' )
										strcat( GF.Session.Dir, "/" );
									strcat( GF.Session.Dir, DirName );
									free( Tmp );
									free( DirName );
									Cmd[0] = GemFtp_Cwd;	CmdFailed[0] = 3;
									Cmd[1] = GemFtp_List;
									Cmd[2] =	0;
									Cmd[3] = GemFtp_Pwd;
									Cmd[4] = GemFtp_Get;
									Cmd[5] = 0;
									nCmd = 0;
									Msg[0] = GemFtp_Cmd;
									Msg[1] = AppId;
									Msg[2] = 0;
									MT_appl_write( AppId, 16, Msg, GF.Global );
								}
								break;
							}
/* GemFtp_LinkCD --------------------------------------------------------------*/
							case	GemFtp_LinkCd:
								WriteStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[LINK_ANA_DIR], GF.Global );
								AppendStatusGemFtp( GF.FtpDialog, InfoPuf, LinkName, GF.Global );
								Msg[0] = Cwd_Cmd;
								Msg[1] = AppId;
								Msg[2] = 0;
								(BYTE *) *( LONG *)&( Msg[3] ) = LinkName;
								MT_appl_write( FtpAppId, 16, Msg, GF.Global );
								break;
/* GemFtp_LinkGet -------------------------------------------------------------*/
							case	GemFtp_LinkGet:
								WriteStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[LINK_ANA_FILE], GF.Global );
								AppendStatusGemFtp( GF.FtpDialog, InfoPuf, LinkName, GF.Global );
								MT_wind_close( MT_wdlg_get_handle( GF.FtpDialog, GF.Global ), GF.Global );
								DelWindow( MT_wdlg_get_handle( GF.FtpDialog, GF.Global ), GF.Global );
								FileNameList = malloc( 2 * sizeof( BYTE * ));
								if( !FileNameList )
									return( ENSMEM );
								FileNameList[0] = strdup( LinkName );
								if( !FileNameList[0] )
									return( ENSMEM );
								FileNameList[1] = NULL;
								FileSizeList = malloc( sizeof( LONG ));
								if( !FileSizeList )
									return( ENSMEM );
								FileSizeList[0] = 0;
								free( LinkName );
								LinkName = NULL;
#ifdef	V120
								{
									EVNTDATA	ev;
									MT_graf_mkstate( &ev, GF.Global );
									if( ev.kstate & ( K_RSHIFT + K_LSHIFT ))
										Shift = 1;
									else
										Shift = 0;
								}
#endif
								Msg[0] = Fsel_Msg;
								Msg[1] = AppId;
								Msg[2] = 0;
								Msg[3] = Fsel_Open;
								Msg[4] = Fsel_GemFtp_Get;
								MT_appl_write( AppId, 16, Msg, GF.Global );
								break;
/* GemFtp_LinkFailed ----------------------------------------------------------*/
							case	GemFtp_LinkFailed:
							{
								WindowAlertDialog = WindowAlert( FstringAddr[WIN_NAME], FstringAddr[LINK_FAILED], 1, GF.Global );
								AlertStatus = Link_Failed;
								break;
							}
/* GemFtp_Get -----------------------------------------------------------------*/
							case	GemFtp_Get:
							{
#ifdef	V120
								EVNTDATA	ev;
								MT_graf_mkstate( &ev, GF.Global );
								if( ev.kstate & ( K_RSHIFT + K_LSHIFT ))
									Shift = 1;
								else
									Shift = 0;
#endif
								DisableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );
								GetFileNameList( FILE_ITEM + LINK_ITEM, GF.FtpList, &FileNameList );
								Cmd[0] = 0;
								nCmd = 0;
								if( FileNameList )
								{
									GetFileSizeList( FILE_ITEM + LINK_ITEM, GF.FtpList, &FileSizeList );
									Msg[0] = Fsel_Msg;
									Msg[1] = AppId;
									Msg[2] = 0;
									Msg[3] = Fsel_Open;
									Msg[4] = Fsel_GemFtp_Get;
									MT_appl_write( AppId, 16, Msg, GF.Global );
								}
								else
								{
									memset( TeTxt, 0, EditLen );
									WindowInputTextDialog =	WindowInputText( FtpDialogTitle, FstringAddr[FTP_IT_GET], &Xted, TeTmplt, TeTxt, GF.Global	);
									InputTextStatus = InputText_GemFtp_Get;
								}
								break;
							}
							case	GemFtp_Get_Prepare:
							{
								WORD	n = 0;
								BYTE	*Pos;
								XATTR	Xattr;
								while( FileNameList[n++] );
								n--;
								PathList = malloc(( n + 1 ) * sizeof( BYTE * ));
								if( !PathList )
									return( ENSMEM );
								n = 0;
								while( FileNameList[n] )
								{
									if(( Pos = strrchr( FileNameList[n], '/' )) == NULL ) 
										Pos = FileNameList[n];
									else
										Pos++;
									PathList[n] = malloc( strlen( (BYTE *) *( LONG *)&( Events.msg[4] ) ) +  strlen( Pos ) + 1 );
									if( !PathList[n] )
										return( ENSMEM );
									strcpy( PathList[n], (BYTE *) *( LONG *)&( Events.msg[4] ) );
									strcat( PathList[n], Pos );
									n++;
								}
								PathList[n] = NULL;
								free( (BYTE *) *( LONG *)&( Events.msg[4] ) );
								nFileNameList = 0;
								while( FileNameList[nFileNameList] )
								{
									if( Fxattr( 0, PathList[nFileNameList], &Xattr ) == E_OK )
									{
										BYTE	Tmp[PathLen], *Path, *File = strdup( strrchr( PathList[nFileNameList], '\\' ) + 1 );
										if( !File )
											return( ENSMEM );
										memset( Tmp, 0, PathLen );
										strncpy( Tmp, PathList[nFileNameList], strrchr( PathList[nFileNameList], '\\' ) - PathList[nFileNameList] + 1 );
										Path = strdup( Tmp );
										if( !Path )
											return( ENSMEM );
										FileDialog = OpenFileDialog( TreeAddr[FILE_D], FtpDialogTitle, &Xted, TeTmplt, TeTxt, GF.Global, File, Path );
										free( File );
										free( Path );
										break;
									}
									nFileNameList++;
								}
								if( !FileNameList[nFileNameList] )
								{
									Msg[0] = GemFtp_Get_Start;
									Msg[1] = AppId;
									Msg[2] = 0;
									MT_appl_write( AppId, 16, Msg, GF.Global );
								}
								break;
							}
							case	GemFtp_Get_Start:
							{
								WORD	n = 0;
								TStart = 0;
								TStartAll = 0;
								FileSize = 0;
								FileSizeIs = 0;
								FileSizeAll = 0;
								FileSizeAllIs = 0;
								FileOffset = 0;
								FileOffsetAll = 0;
								while( FileNameList[n] )
								{
									FileSizeAllIs += FileSizeList[n];
									n++;
								}
								if( n > 0 )
								{
									sprintf( TreeAddr[TR][TR_N_ALL].ob_spec.tedinfo->te_ptext, "%i", n );
									TrDialogHide( TreeAddr[TR], n == 1 ? 0 : 1 );
									TrDialog = OpenDialog( TreeAddr[TR], FtpDialogTitle, HandleTrDialog, ( void * ) GF.Global, GF.Global );
									Msg[0] = Retr_Cmd;
									Msg[1] = AppId;
									Msg[2] = 0;
									if( TreeAddr[FTP][FTP_TT_AUTO].ob_state & SELECTED )
										Msg[3] = TT_Auto;
									if( TreeAddr[FTP][FTP_TT_ASCII].ob_state & SELECTED )
										Msg[3] = TT_Ascii;
									if( TreeAddr[FTP][FTP_TT_BIN].ob_state & SELECTED )
										Msg[3] = TT_Bin;
#ifdef	GEMScript
									if( GsFlag )
										Msg[3] = GsTransferType;
#endif
									(BYTE **) *( LONG *)&( Msg[4] ) = FileNameList;
									(BYTE **) *( LONG *)&( Msg[6] ) = PathList;
									MT_appl_write( FtpAppId, 16, Msg, GF.Global );
								}
								else
								{
									AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[CANCEL], GF.Global );
									EnableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );
								}
								break;
							}
/* GemFtp_Put -----------------------------------------------------------------*/
							case	GemFtp_Put:
								DisableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );
								Msg[0] = Fsel_Msg;
								Msg[1] = AppId;
								Msg[2] = 0;
								Msg[3] = Fsel_Open;
								Msg[4] = Fsel_GemFtp_Put;
								MT_appl_write( AppId, 16, Msg, GF.Global );
								break;
							case	GemFtp_Put_Start:
							{
								WORD	i, n = 0;
								XATTR	Xattr;
								TStart = 0;
								TStartAll = 0;
								FileSize = 0;
								FileSizeIs = 0;
								FileSizeAll = 0;
								FileSizeAllIs = 0;
								FileOffset = 0;
								FileOffsetAll = 0;
								while( FileNameList[n++] );
								n--;
								FileSizeList = malloc( n * sizeof( LONG ));
								if( !FileSizeList )
									return( ENSMEM );
								for( i = 0; i < n; i++ )	
								{
									Fxattr( 0, PathList[i], &Xattr );
									FileSizeList[i] = Xattr.size;
									FileSizeAllIs += Xattr.size;
									if( ChangeFilenameCase && Dpathconf( PathList[i], 6 ) == 1 )
										strlwr( FileNameList[i] );
								}
								sprintf( TreeAddr[TR][TR_N_ALL].ob_spec.tedinfo->te_ptext, "%i", n );
								TrDialogHide( TreeAddr[TR], n == 1 ? 0 : 1 );
								TrDialog = OpenDialog( TreeAddr[TR], FtpDialogTitle, HandleTrDialog, (void *) GF.Global, GF.Global );
								Msg[0] = Stor_Cmd;
								Msg[1] = AppId;
								Msg[2] = 0;
								if( TreeAddr[FTP][FTP_TT_AUTO].ob_state & SELECTED )
									Msg[3] = TT_Auto;
								if( TreeAddr[FTP][FTP_TT_ASCII].ob_state & SELECTED )
									Msg[3] = TT_Ascii;
								if( TreeAddr[FTP][FTP_TT_BIN].ob_state & SELECTED )
									Msg[3] = TT_Bin;
#ifdef	GEMScript
									if( GsFlag )
										Msg[3] = GsTransferType;
#endif
								(BYTE **) *( LONG *)&( Msg[4] ) = FileNameList;
								(BYTE **) *( LONG *)&( Msg[6] ) = PathList;
								MT_appl_write( FtpAppId, 16, Msg, GF.Global );
								break;
							}
/* GemFtp_Mv ------------------------------------------------------------------*/
							case	GemFtp_Mv:
								DisableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );
								GetFileNameList( FILE_ITEM, GF.FtpList, &FileNameList );
								if( FileNameList )
								{
									WORD	n = 0;
									while( FileNameList[n++] )
										n++;
									FileNameListNew = calloc( n + 1, sizeof( BYTE * ));
									nFileNameList = 0;
									strcpy( TeTxt, FileNameList[0] );
									WindowInputTextDialog =	WindowInputText( FtpDialogTitle, FstringAddr[FTP_IT_MV_NEW], &Xted, TeTmplt, TeTxt, GF.Global	);
									InputTextStatus = InputText_GemFtp_Mv_New;
								}
								else
								{
									memset( TeTxt, 0, EditLen );
									WindowInputTextDialog =	WindowInputText( FtpDialogTitle, FstringAddr[FTP_IT_MV_OLD], &Xted, TeTmplt, TeTxt, GF.Global	);
									InputTextStatus = InputText_GemFtp_Mv_Old;
								}
								break;
/* GemFtp_Rm ------------------------------------------------------------------*/
							case	GemFtp_Rm:
								DisableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );
								GetFileNameList( FILE_ITEM, GF.FtpList, &FileNameList );
								if( FileNameList )
								{
									Msg[0] = Dele_Cmd;
									Msg[1] = AppId;
									Msg[2] = 0;
									(BYTE **) *( LONG *)&( Msg[3] ) = FileNameList;
									MT_appl_write( FtpAppId, 16, Msg, GF.Global );
								}
								else
								{
									memset( TeTxt, 0, EditLen );
									WindowInputTextDialog =	WindowInputText( FtpDialogTitle, FstringAddr[FTP_IT_RM], &Xted, TeTmplt, TeTxt, GF.Global	);
									InputTextStatus = InputText_GemFtp_Rm;
								}
								break;
/* GemFtp_Mkdir ---------------------------------------------------------------*/
							case	GemFtp_Mkdir:
								DisableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );
								memset( TeTxt, 0, EditLen );
								WindowInputTextDialog =	WindowInputText( FtpDialogTitle, FstringAddr[FTP_IT_MKDIR], &Xted, TeTmplt, TeTxt, GF.Global	);
								InputTextStatus = InputText_GemFtp_Mkdir;
								break;
/* GemFtp_Rmdir----------------------------------------------------------------*/
							case	GemFtp_Rmdir:
							{
								DisableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );
								GetFileNameList( DIR_ITEM, GF.FtpList, &FileNameList );
								if( FileNameList )
								{
									Msg[0] = Rmd_Cmd;
									Msg[1] = AppId;
									Msg[2] = 0;
									(BYTE **) *( LONG *)&( Msg[3] ) = FileNameList;
									MT_appl_write( FtpAppId, 16, Msg, GF.Global );
								}
								else
								{
									memset( TeTxt, 0, EditLen );
									WindowInputTextDialog =	WindowInputText( FtpDialogTitle, FstringAddr[FTP_IT_RMDIR], &Xted, TeTmplt, TeTxt, GF.Global	);
									InputTextStatus = InputText_GemFtp_Rmdir;
								}
								break;
							}
/* GemFtp_Cd ------------------------------------------------------------------*/
							case	GemFtp_Cd:
							{
								WORD		n = 0;
								STR_ITEM	*Item, *ItemSlct;
								DisableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );
								Item = GF.FtpList;
								while( Item )
								{
									if( *( Item->str ) == 'd' && Item->selected )
									{
										ItemSlct = Item;
										n++;
									}
									Item = Item->next;
								}
								if( n == 1 )
								{
									BYTE	*Tmp = strdup( GF.Session.Dir ), *DirName;
									if( !Tmp )
										return( ENSMEM );
									free( GF.Session.Dir );
									GetFileName( ItemSlct, &DirName );
									GF.Session.Dir = malloc( strlen( Tmp ) + strlen( DirName ) + 2 );
									strcpy( GF.Session.Dir, Tmp );
									if( GF.Session.Dir[strlen( GF.Session.Dir )-1] != '/' )
										strcat( GF.Session.Dir, "/" );
									strcat( GF.Session.Dir, DirName );
									if( strcmp( DirName, ".." ) == 0 || strcmp( DirName, "." ) == 0 )
									{
										Cmd[0] = GemFtp_Cwd; CmdFailed[0] = 1;
										Cmd[1] = GemFtp_Pwd;
										Cmd[2] = GemFtp_List;
										Cmd[3] = 0;
										nCmd = 0;
									}
									else
									{
										Cmd[0] = GemFtp_Cwd;	CmdFailed[0] = 3;
										Cmd[1] = GemFtp_List;
										Cmd[2] =	0;
										Cmd[3] = GemFtp_CwdFailed;
										Cmd[4] = GemFtp_Pwd;
										Cmd[5] = GemFtp_List;
										Cmd[6] = 0;
										nCmd = 0;
									}
									Msg[0] = GemFtp_Cmd;
									Msg[1] = AppId;
									Msg[2] = 0;
									MT_appl_write( AppId, 16, Msg, GF.Global );
									free( Tmp );
									free( DirName );
									break;
								}
								memset( TeTxt, 0, EditLen );
								WindowInputTextDialog =	WindowInputText( FtpDialogTitle, FstringAddr[FTP_IT_CD], &Xted, TeTmplt, TeTxt, GF.Global	);
								InputTextStatus = InputText_GemFtp_Cd;
								break;
							}
/* GemFtp_Cwd -----------------------------------------------------------------*/
							case	GemFtp_Cwd:
							{
								DisableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );
								WriteStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[CWD], GF.Global );
								AppendStatusGemFtp( GF.FtpDialog, InfoPuf, GF.Session.Dir, GF.Global );
								Msg[0] = Cwd_Cmd;
								Msg[1] = AppId;
								Msg[2] = 0;
								(BYTE *) *( LONG *)&( Msg[3] ) = GF.Session.Dir;
								MT_appl_write( FtpAppId, 16, Msg, GF.Global );
								break;
							}
							case	GemFtp_CwdFailed:
							{
								WindowAlertDialog = WindowAlert( FtpDialogTitle, FstringAddr[CWD_FAILED], 1, GF.Global );
								AlertStatus = Cwd_Failed;
								break;
							}
/* GemFtp_CdRoot --------------------------------------------------------------*/
							case	GemFtp_CdRoot:
							{
								DisableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );
								WriteStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[CDROOT], GF.Global );
								free( GF.Session.Dir );
								GF.Session.Dir = strdup( "/" );
								if( !GF.Session.Dir )
									return( ENSMEM );
/*								Cmd[0] = GemFtp_Pwd;
								Cmd[1] = GemFtp_List;
								Cmd[2] = 0;	*/

								Cmd[0] = GemFtp_List;
								Cmd[1] = 0;
								nCmd = 0;
								Msg[0] = Cwd_Cmd;
								Msg[1] = AppId;
								Msg[2] = 0;
								(BYTE *) *( LONG *)&( Msg[3] ) = GF.Session.Dir;
								MT_appl_write( FtpAppId, 16, Msg, GF.Global );
								break;
							}
/* GemFtp_Cdup ----------------------------------------------------------------*/
							case	GemFtp_Cdup:
								DisableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );
								WriteStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[CDUP], GF.Global );
								Cmd[0] = GemFtp_Pwd;
								Cmd[1] = GemFtp_List;
								Cmd[2] = 0;
								nCmd = 0;
								Msg[0] = Cdup_Cmd;
								Msg[1] = AppId;
								Msg[2] = 0;
								MT_appl_write( FtpAppId, 16, Msg, GF.Global );
								break;
/* GemFtp_Pwd -----------------------------------------------------------------*/
							case	GemFtp_Pwd:
								DisableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );
								WriteStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[PWD], GF.Global );
								Msg[0] = Pwd_Cmd;
								Msg[1] = AppId;
								Msg[2] = 0;
								(BYTE **) *( LONG *)&( Msg[3] ) = &( GF.Session.Dir );
								MT_appl_write( FtpAppId, 16, Msg, GF.Global );
								break;
/* GemFtp_List ----------------------------------------------------------------*/
							case	GemFtp_List:
							{
								GRECT		Rect, *RectP = NULL;
								OBJECT	*DialogTree;
								STR_ITEM	*Item, *Tmp;
								WORD		i;
								if( !isIconifiedWindow( MT_wdlg_get_handle( GF.FtpDialog, GF.Global )))
								{
									MT_wdlg_get_tree( GF.FtpDialog, &DialogTree, &Rect, GF.Global );
									RectP = &Rect;
								}
								WriteStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[LIST], GF.Global );
								AppendStatusGemFtp( GF.FtpDialog, InfoPuf, GF.Session.Dir, GF.Global );
								Item = GF.FtpList;
								while( Item )
								{
									Tmp = Item->next;
									free( Item->str );
									free( Item );
									Item = Tmp;
								}
								GF.FtpList = NULL;
								MT_lbox_set_items( GF.FtpListBox, 0L, GF.Global );
								MT_lbox_set_bentries( GF.FtpListBox, 0, GF.Global );
								MT_lbox_set_asldr( GF.FtpListBox, 0, RectP, GF.Global );
								MT_lbox_set_bsldr( GF.FtpListBox, 0, RectP, GF.Global );
								DoRedraw( GF.FtpDialog, RectP, FTP_DIR_BACK_H, GF.Global );
								MT_lbox_update( GF.FtpListBox, RectP, GF.Global );
								for( i = 0; i < NO_FTP_DIR_V; i++ )
									TreeAddr[FTP][FtpDirIcons[i]].ob_flags |= HIDETREE;
								DoRedraw( GF.FtpDialog, &Rect, FTP_ICON_BOX, GF.Global );
								DisableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );
								Msg[0] = List_Cmd;
								Msg[1] = AppId;
								Msg[2] = 0;
								(STR_ITEM **) *( LONG *)&( Msg[3] ) = &(GF.FtpList);
#ifdef	GEMScript
								*( BYTE **) &Msg[5] = NULL;
								Msg[7] = 0;
#endif
								MT_appl_write( FtpAppId, 16, Msg, GF.Global );
								break;
							}
/* GemFtp_Abor ----------------------------------------------------------------*/
							case	GemFtp_Abor:
								Msg[0] = Abor_Cmd;
								Msg[1] = AppId;
								Msg[2] = 0;
								MT_appl_write( FtpAppId, 16, Msg, GF.Global );
								break;
/* GemFtp_Path_Popup ----------------------------------------------------------*/
							case	GemFtp_Path_Popup:
							{
								GRECT		Rect;
								OBJECT	*DialogTree;
								MENU		Popup;
								WORD		x, y, n, i;
								BYTE		*Path, *Token, *Start, **PathPuf;
								WORD	a1, a2, a3, a4;
								if( MT_appl_getinfo( 9, &a1, &a2, &a3, &a4, GF.Global ) && a2 )
								{
									MT_wdlg_get_tree( GF.FtpDialog, &DialogTree, &Rect, GF.Global );
#ifdef	V120
									if( strcmp( GF.Session.Dir, "/" ) && !( GF.Session.Dir[1] == ':' && GF.Session.Dir[3] == 0 ))
#else
									if( strcmp( GF.Session.Dir, "/" ))
#endif
									{
										Path = strdup( GF.Session.Dir );
										if( !Path )
											return( ENSMEM );
										Token = Path;
										n = 0;
										while( *Token )
										{
											if( *Token == '/' )
											n++;
											Token++;
										}
										if( n > 0 )
											n++;
										i = n;
										PathPuf = malloc( i * sizeof( void * ));
										if( !PathPuf )
											return( ENSMEM );
										Token = Path;
										Start = Token;
										while( i )
										{
											while( *Token != '/' && *Token != 0 )
												Token++;
											if( Token > Start )
											{
												PathPuf[--i] = malloc( Token - Start + 1 );
												if( !PathPuf[i] )
													return( ENSMEM );
												memset( PathPuf[i], 0, Token - Start + 1 );
												strncpy( PathPuf[i], Start, Token - Start );
											}
											else
											{
												PathPuf[--i] = malloc( 2 );
												if( !PathPuf[i] )
													return( ENSMEM );
												strcpy( PathPuf[i], "/" );
											}
											Start = Token + 1;
											Token = Token + 1;
										}
										free( Path );
										CreatePopupTree( &( FtpDirPopup ), n, PathPuf );
										Popup.mn_tree = FtpDirPopup;
										Popup.mn_menu = 0;
										Popup.mn_item = 0;
										Popup.mn_scroll = 1;
										Popup.mn_keystate = 0;
										MT_objc_offset( DialogTree, FTP_DIR_PATH, &x, &y, GF.Global );
/* [GS] 1.50a */
										x = Events.msg[3];
/* End; old:
										x = x + ( DialogTree[FTP_DIR_PATH].ob_width - ( FtpDirPopup )[POPUP_BOX].ob_width ) / 2;
*/
										MT_menu_popup( &Popup, x, y, &Popup, GF.Global );
										if( Popup.mn_item > 0 )
										{
											WORD	Len = 0;
											for( i = n - 1; i >= Popup.mn_item - 1; i-- )
											Len += ( WORD ) strlen( PathPuf[i] + 1 );
											Len++;
#ifdef	V120
											Len += 2;
#endif
											Path = malloc( Len );
											if( !Path )
												return( ENSMEM );
											memset( Path, 0 ,Len );
											for( i = n - 1; i >= Popup.mn_item - 1; i-- )
											{
#ifdef	V120
												if( GF.Session.Dir[1] == ':' && i == n - 2 )
													strcat( Path, "/" );
#endif
												if( i < n - 2 )
													strcat( Path, "/" );
												strcat( Path, PathPuf[i] );
											}
#ifdef	V120
											if( Path[1] == ':' && Path[2] == 0 )
												strcat( Path, "/" );
#endif											
											if( strcmp( GF.Session.Dir, Path ))
											{
												free( GF.Session.Dir );
												GF.Session.Dir = Path;
												Cmd[0] = GemFtp_Cwd;	CmdFailed[0] = 3;
												Cmd[1] = GemFtp_List;
												Cmd[2] = 0;
												Cmd[3] = GemFtp_Pwd;
												Cmd[4] = GemFtp_List;
												Cmd[5] = 0;
												nCmd = 0;
												Msg[0] = GemFtp_Cmd;
												Msg[1] = AppId;
												Msg[2] = 0;
												MT_appl_write( AppId, 16, Msg, GF.Global );
											}
										}
										for( i = 0; i < n; i++ )
											free( PathPuf[i] );
										free( PathPuf );
										}
									}
									break;
								}
/* GemFtp_Shutdown ------------------------------------------------------------*/
							case	GemFtp_Shutdown:
								if( Events.msg[1] != AppId )
									break;
								WriteStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[CLOSE_SESSION], GF.Global );
								if( TrCancelDialog )
								{
									Msg[0] = WM_CLOSED;
									Msg[1] = AppId;
									Msg[2] = 0;
									Msg[3] = MT_wdlg_get_handle( TrCancelDialog, GF.Global );
									MT_appl_write( AppId, 16, Msg, GF.Global );
									Msg[0] = GemFtp_Shutdown;
									Msg[1] = AppId;
									Msg[2] = 0;
									MT_appl_write( AppId, 16, Msg, GF.Global );
									break;
								}
#ifdef	KEY
								if( InsertHtDialog )
								{
									Msg[0] = WM_CLOSED;
									Msg[1] = AppId;
									Msg[2] = 0;
									Msg[3] = MT_wdlg_get_handle( InsertHtDialog, GF.Global );
									MT_appl_write( AppId, 16, Msg, GF.Global );
									Msg[0] = GemFtp_Shutdown;
									Msg[1] = AppId;
									Msg[2] = 0;
									MT_appl_write( AppId, 16, Msg, GF.Global );
									break;
								}
								if( DoubleHtDialog )
								{
									Msg[0] = WM_CLOSED;
									Msg[1] = AppId;
									Msg[2] = 0;
									Msg[3] = MT_wdlg_get_handle( DoubleHtDialog, GF.Global );
									MT_appl_write( AppId, 16, Msg, GF.Global );
									Msg[0] = GemFtp_Shutdown;
									Msg[1] = AppId;
									Msg[2] = 0;
									MT_appl_write( AppId, 16, Msg, GF.Global );
									break;
								}
#endif
								if( DragDropFailedDialog )
								{
									Msg[0] = WM_CLOSED;
									Msg[1] = AppId;
									Msg[2] = 0;
									Msg[3] = MT_wdlg_get_handle( DragDropFailedDialog, GF.Global );
									MT_appl_write( AppId, 16, Msg, GF.Global );
									Msg[0] = GemFtp_Shutdown;
									Msg[1] = AppId;
									Msg[2] = 0;
									MT_appl_write( AppId, 16, Msg, GF.Global );
									break;
								}
								if( TrDialog )
								{
									Msg[0] = WM_CLOSED;
									Msg[1] = AppId;
									Msg[2] = 0;
									Msg[3] = MT_wdlg_get_handle( TrDialog, GF.Global );
									MT_appl_write( AppId, 16, Msg, GF.Global );
									Msg[0] = GemFtp_Shutdown;
									Msg[1] = AppId;
									Msg[2] = 0;
									MT_appl_write( AppId, 16, Msg, GF.Global );
								}
								if( DdDialog )
								{
									Msg[0] = WM_CLOSED;
									Msg[1] = AppId;
									Msg[2] = 0;
									Msg[3] = MT_wdlg_get_handle( DdDialog, GF.Global );
									MT_appl_write( AppId, 16, Msg, GF.Global );
									Msg[0] = GemFtp_Shutdown;
									Msg[1] = AppId;
									Msg[2] = 0;
									MT_appl_write( AppId, 16, Msg, GF.Global );
									break;
								}
								if( FileDialog )
								{
									Msg[0] = WM_CLOSED;
									Msg[1] = AppId;
									Msg[2] = 0;
									Msg[3] = MT_wdlg_get_handle( FileDialog, GF.Global );
									MT_appl_write( AppId, 16, Msg, GF.Global );
									Msg[0] = GemFtp_Shutdown;
									Msg[1] = AppId;
									Msg[2] = 0;
									MT_appl_write( AppId, 16, Msg, GF.Global );
									break;
								}
								if( WindowAlertDialog )
								{
									Msg[0] = WM_CLOSED;
									Msg[1] = AppId;
									Msg[2] = 0;
									Msg[3] = MT_wdlg_get_handle( WindowAlertDialog, GF.Global );
									MT_appl_write( AppId, 16, Msg, GF.Global );
									Msg[0] = GemFtp_Shutdown;
									Msg[1] = AppId;
									Msg[2] = 0;
									MT_appl_write( AppId, 16, Msg, GF.Global );
									break;
								}
								if( WindowInputTextDialog )
								{
									Msg[0] = WM_CLOSED;
									Msg[1] = AppId;
									Msg[2] = 0;
									Msg[3] = MT_wdlg_get_handle( WindowInputTextDialog, GF.Global );
									MT_appl_write( AppId, 16, Msg, GF.Global );
									Msg[0] = GemFtp_Shutdown;
									Msg[1] = AppId;
									Msg[2] = 0;
									MT_appl_write( AppId, 16, Msg, GF.Global );
									break;
								}
								if( FtpAppId != -1 )
								{
									Msg[0] = Abor_Cmd;
									Msg[1] = AppId;
									Msg[2] = 0;
									MT_appl_write( FtpAppId, 16, Msg, GF.Global );
									Msg[0] = Ftp_Quit;
									Msg[1] = AppId;
									Msg[2] = 0;
									MT_appl_write( FtpAppId, 16, Msg, GF.Global );
									if( !ShutdownFlag )
									{
										Msg[0] = GemFtp_Shutdown;
										Msg[1] = AppId;
										Msg[2] = 0;
										MT_appl_write( AppId, 16, Msg, GF.Global );
										ShutdownFlag = 1;
									}
									break;
								}
								if( GF.FtpDialog )
								{
									STR_ITEM	*Del = GF.FtpList, *Tmp;
#ifdef	GEMScript
									if( GF.FtpListBox )
#endif
									MT_lbox_delete( GF.FtpListBox, GF.Global );
									CloseDialog( GF.FtpDialog, GF.Global );
									UnSetnFtpWin( GF.nFtpWin );
									GF.FtpDialog = NULL;
									while( Del )
									{
										free( Del->str );
										Tmp = Del;
										Del = Del->next;
										free( Tmp );
									}
									GF.FtpList = NULL;
									Msg[0] = GemFtp_Shutdown;
									Msg[1] = AppId;
									Msg[2] = 0;
									MT_appl_write( AppId, 16, Msg, GF.Global );
									break;
								}
								Quit = 0;
								break;
/* GemFtp_Close ---------------------------------------------------------------*/
/*							case	GemFtp_Close:
								if( !SeCancelDialog )
									SeCancelDialog = OpenDialog( TreeAddr[SE_CANCEL], FtpDialogTitle, HandleSeCancelDialog, (void *) &GF, GF.Global );
								else
									MT_wind_set( MT_wdlg_get_handle( SeCancelDialog, GF.Global ), WF_TOP, 0, 0, 0, 0, GF.Global );
								break;	*/
/* GemFtp_Close_Transfer ------------------------------------------------------*/
							case	GemFtp_Close_Transfer:
								if( Events.msg[1] != AppId )
									break;
								if( !TrCancelDialog )
									TrCancelDialog = OpenDialog( TreeAddr[TR_CANCEL], FtpDialogTitle, HandleTrCancelDialog, (void *) GF.Global, GF.Global );
								else
									MT_wind_set( MT_wdlg_get_handle( TrCancelDialog, GF.Global ), WF_TOP, 0, 0, 0, 0, GF.Global );
								break;
/* GemFtp_Chmod ---------------------------------------------------------------*/
							case	GemFtp_Chmod:
								DisableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );
								GetFileNameList( FILE_ITEM, GF.FtpList, &FileNameList );
								if( FileNameList )
								{
									memset( TeTxt, 0, EditLen );
									WindowInputTextDialog =	WindowInputText( FtpDialogTitle, FstringAddr[FTP_IT_CHMOD_MODE], &Xted, TeTmplt, TeTxt, GF.Global	);
									InputTextStatus = InputText_GemFtp_Chmod_Mode;
								}
								else
								{
									memset( TeTxt, 0, EditLen );
									WindowInputTextDialog =	WindowInputText( FtpDialogTitle, FstringAddr[FTP_IT_CHMOD_FILE], &Xted, TeTmplt, TeTxt, GF.Global	);
									InputTextStatus = InputText_GemFtp_Chmod_File;
								}
								break;
/* SocketInit -----------------------------------------------------------------*/
							case	SocketInit_Failed:
							{
#ifdef	GEMScript
								if( GsFlag )
								{
									BYTE	*Ret = Xmalloc( 4, RAM_READABLE );
									strcpy( Ret, "-2" );
									Ret[3] = 0;
									Msg[0] = GS_ACK;
									Msg[1] = Global[2];
									Msg[2] = 0;
									*( BYTE **) &Msg[3] = GsCmd;
									*( BYTE **) &Msg[5] = Ret;
									Msg[7] = GSACK_OK;
									MT_appl_write( GsAppId, 16, Msg, GF.Global );
									Msg[0] = GemFtp_Shutdown;
									Msg[1] = AppId;
									Msg[2] = 0;
									MT_appl_write( AppId, 16, Msg, GF.Global );
									break;
								}
#endif
								WindowAlertDialog = WindowAlert( FtpDialogTitle, FstringAddr[SOCKETINTERFACE], 1, GF.Global );
								AlertStatus = SocketInit_Failed;
								break;
							}
							case	SocketInit_Ok:
							{
								WriteStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[OPEN_SESSION], GF.Global );
								Msg[0] = OpenConnect_Cmd;
								Msg[1] = AppId;
								Msg[2] = 0;
								(BYTE *) *( LONG *)&( Msg[3] ) = GF.Session.Host;
								Msg[5] = GF.Session.Port;
								MT_appl_write( FtpAppId, 16, Msg, GF.Global );
								break;
							}
/* OpenConnect ----------------------------------------------------------------*/
							case	Socket_Failed:
#ifdef	GEMScript
								if( GsFlag )
								{
									BYTE	*Ret = Xmalloc( 4, RAM_READABLE );
									strcpy( Ret, "-3" );
									Ret[3] = 0;
									Msg[0] = GS_ACK;
									Msg[1] = Global[2];
									Msg[2] = 0;
									*( BYTE **) &Msg[3] = GsCmd;
									*( BYTE **) &Msg[5] = Ret;
									Msg[7] = GSACK_ERROR;
									MT_appl_write( GsAppId, 16, Msg, GF.Global );

									Msg[0] = GemFtp_Shutdown;
									Msg[1] = AppId;
									Msg[2] = 0;
									MT_appl_write( AppId, 16, Msg, GF.Global );
									break;
								}
#endif
								if( !WindowAlertDialog )
								{
									AlertStatus = Socket_Failed;
									WindowAlertDialog = WindowAlert( FtpDialogTitle, FstringAddr[SOCKET_FAILED], 1, GF.Global );
								}
#ifdef	V120
								if(( IConnect & ICONNECT_START ) && !( IConnect & ICONNECT_CONNECT ))
								{
									WriteStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[WAITFORICONNECT], GF.Global );
									nCmd = 0;
									IConnectFlag = 1;
									IConnectSession = 0;
									IConnectTimer = 5;
									IConnectStatus = 0;
								}
#endif
								break;
							case	GetHostByName:
#ifdef	V110
								IConnectSession = 1;
#endif
								WriteStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[GETHOSTBYNAME], GF.Global );
								break;
							case	GetHostByName_Failed:
#ifdef	GEMScript
								if( GsFlag )
								{
									BYTE	*Ret = Xmalloc( 4, RAM_READABLE );
									strcpy( Ret, "-4" );
									Ret[3] = 0;
									Msg[0] = GS_ACK;
									Msg[1] = Global[2];
									Msg[2] = 0;
									*( BYTE **) &Msg[3] = GsCmd;
									*( BYTE **) &Msg[5] = Ret;
									Msg[7] = GSACK_OK;
									MT_appl_write( GsAppId, 16, Msg, GF.Global );
									Msg[0] = GemFtp_Shutdown;
									Msg[1] = AppId;
									Msg[2] = 0;
									MT_appl_write( AppId, 16, Msg, GF.Global );
									break;
								}
#endif
								AlertStatus = GetHostByName_Failed;
								WindowAlertDialog = WindowAlert( FtpDialogTitle, FstringAddr[DNS_FAILED], 1, GF.Global );
								break;
							case	Connect:
								AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[READY], GF.Global );
								WriteStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[CONNECT], GF.Global );
								break;							
							case	Connect_Failed:
#ifdef	GEMScript
								if( GsFlag )
								{
									BYTE	*Ret = Xmalloc( 4, RAM_READABLE );
									strcpy( Ret, "-5" );
									Ret[3] = 0;
									Msg[0] = GS_ACK;
									Msg[1] = Global[2];
									Msg[2] = 0;
									*( BYTE **) &Msg[3] = GsCmd;
									*( BYTE **) &Msg[5] = Ret;
									Msg[7] = GSACK_OK;
									MT_appl_write( GsAppId, 16, Msg, GF.Global );
									Msg[0] = GemFtp_Shutdown;
									Msg[1] = AppId;
									Msg[2] = 0;
									MT_appl_write( AppId, 16, Msg, GF.Global );
									break;
								}
#endif
								AlertStatus = Connect_Failed;
								WindowAlertDialog = WindowAlert( FtpDialogTitle, FstringAddr[CONNECT_FAILED], 1, GF.Global );
								break;							
							case	OpenConnect_Ok:
								AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[READY], GF.Global );
								WriteStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[LOGIN], GF.Global );
#ifdef	V120
								if( strcmp( GF.Session.Uid, "anonymous" ) == 0 && strlen( GF.Session.Pwd ) == 0 )
								{
									USIS_REQUEST	Usis;
									Usis.result = malloc( 256 * sizeof( BYTE ));
									if( Usis.result )
									{
										Usis.request = UR_EMAIL_ADDR;
										free( GF.Session.Pwd );
										if( usis_query( &Usis ) == UA_FOUND )
											GF.Session.Pwd = strdup( Usis.result );
										else
											GF.Session.Pwd = strdup( "" );
										free( Usis.result );
									}
								}
#endif
								Msg[0] = Login_Cmd;
								Msg[1] = AppId;
								Msg[2] = 0;
								(BYTE *) *( LONG *)&( Msg[3] ) = GF.Session.Uid;
								(BYTE *) *( LONG *)&( Msg[5] ) = GF.Session.Pwd;
								MT_appl_write( FtpAppId, 16, Msg, GF.Global );
								break;
/* Login ----------------------------------------------------------------------*/
							case	Login_Failed:
								if( Events.msg[3] != ABORT )
								{
#ifdef	GEMScript
								if( GsFlag )
								{
									BYTE	*Ret = Xmalloc( 4, RAM_READABLE );
									strcpy( Ret, "-6" );
									Ret[3] = 0;
									Msg[0] = GS_ACK;
									Msg[1] = Global[2];
									Msg[2] = 0;
									*( BYTE **) &Msg[3] = GsCmd;
									*( BYTE **) &Msg[5] = Ret;
									Msg[7] = GSACK_OK;
									MT_appl_write( GsAppId, 16, Msg, GF.Global );
									Msg[0] = GemFtp_Shutdown;
									Msg[1] = AppId;
									Msg[2] = 0;
									MT_appl_write( AppId, 16, Msg, GF.Global );
									break;
								}
#endif
									WindowAlertDialog = WindowAlert( FtpDialogTitle, FstringAddr[LOGIN_FAILED], 1, GF.Global );
									AlertStatus = Login_Failed;
								}
								else
								{
									Msg[0] = GemFtp_Shutdown;
									Msg[1] = AppId;
									Msg[2] = 0;
									MT_appl_write( AppId, 16, Msg, GF.Global );
								}
								break;
							case	Login_Ok:
#ifdef DEBUG
	DebugMsg( GF.Global, "GemFtp: Login_Ok\n" );
#endif
								AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[READY], GF.Global );
								Msg[0] = GemFtp_Cmd;
								Msg[1] = AppId;
								Msg[2] = 0;
								MT_appl_write( AppId, 16, Msg, GF.Global );
								break;
/* Cwd_Msg --------------------------------------------------------------------*/
							case	Cwd_Failed:
								AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[ERR], GF.Global );
#ifdef	GEMScript
								if( GsFlag )
								{
									BYTE	*Ret = Xmalloc( 7, RAM_READABLE );
									itoa( Events.msg[3], Ret, 10 );
									Ret[strlen( Ret ) + 1] = 0;
									Msg[0] = GS_ACK;
									Msg[1] = Global[2];
									Msg[2] = 0;
									*( BYTE **) &Msg[3] = GsCmd;
									*( BYTE **) &Msg[5] = Ret;
									Msg[7] = GSACK_ERROR;
									MT_appl_write( GsAppId, 16, Msg, GF.Global );
									break;
								}
#endif
								if( Events.msg[3] == 550 && GF.Session.Dir[strlen( GF.Session.Dir )-1] == '/' )
								{
									if( Cmd[0] == GemFtp_OpenSession )
									{
										Cmd[0] = GemFtp_LinkFailed;
										Cmd[1] = 0;
										nCmd = 0;
									}
									else
									{
										Cmd[0] = GemFtp_CwdFailed;
										Cmd[1] = GemFtp_Pwd;
										Cmd[2] = GemFtp_List;
										Cmd[3] = 0;
										nCmd = 0;
									}
									Msg[0] = GemFtp_Cmd;
									Msg[1] = AppId;
									Msg[2] = 0;
									MT_appl_write( AppId, 16, Msg, GF.Global );
									break;
								}
								Msg[0] = GemFtp_CmdFailed;
								Msg[1] = AppId;
								Msg[2] = 0;
								MT_appl_write( AppId, 16, Msg, GF.Global );
								break;
							case	Cwd_Ok:
								if( LinkName )
								{
									free( LinkName );
									LinkName = NULL;
								}
								AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[READY], GF.Global );
#ifdef	GEMScript
								if( GsFlag )
								{
									BYTE	*Ret = Xmalloc( 3, RAM_READABLE );
									strcpy( Ret, "0" );
									Ret[2] = 0;
									Msg[0] = GS_ACK;
									Msg[1] = Global[2];
									Msg[2] = 0;
									*( BYTE **) &Msg[3] = GsCmd;
									*( BYTE **) &Msg[5] = Ret;
									Msg[7] = GSACK_OK;
									MT_appl_write( GsAppId, 16, Msg, GF.Global );
									break;
								}
#endif
								if( strlen( GF.Session.Dir ) > 1 && GF.Session.Dir[strlen( GF.Session.Dir ) - 1] == '/' && GF.Session.Dir[strlen( GF.Session.Dir ) - 2] != ':' )
									GF.Session.Dir[strlen( GF.Session.Dir )-1] = 0;
								if( GF.Session.Dir[strlen( GF.Session.Dir ) - 1] == '.' &&
								    GF.Session.Dir[strlen( GF.Session.Dir ) - 2] == '/' )
								{
									if( strlen( GF.Session.Dir ) > 2 )
										GF.Session.Dir[strlen( GF.Session.Dir ) - 2 ] = 0;
									else
										GF.Session.Dir[1] = 0;
								}
								if( GF.Session.Dir[strlen( GF.Session.Dir ) - 1] == '.' &&
								    GF.Session.Dir[strlen( GF.Session.Dir ) - 2] == '.' &&
								    GF.Session.Dir[strlen( GF.Session.Dir ) - 3] == '/' )
								{
									if( strlen( GF.Session.Dir ) > 3 )
									{
										BYTE	*Pos;
										GF.Session.Dir[strlen( GF.Session.Dir ) - 3] = 0;
										Pos = strrchr( GF.Session.Dir, '/' );
										if( Pos )
											if( Pos != GF.Session.Dir )
												*Pos = 0;
											else
												*( Pos + 1 ) = 0;
									}
									else
										GF.Session.Dir[1] = 0;
								} 
								CopyFtpDirPath( &GF );
								Msg[0] = GemFtp_Cmd;
								Msg[1] = AppId;
								Msg[2] = 0;
								MT_appl_write( AppId, 16, Msg, GF.Global );
								break;
/* Cdup_Msg -------------------------------------------------------------------*/
							case	Cdup_Failed:
								Con( "Error: CDUP" );crlf;
								break;
							case	Cdup_Ok:
							{
								BYTE		*Pos, *Tmp = strdup( GF.Session.Dir );
								if( !Tmp )
									return( ENSMEM );
								free( GF.Session.Dir );
								AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[READY], GF.Global );

								Pos = strrchr( Tmp, '/' );
								if( Pos != Tmp )
								{
									*Pos = 0;
									GF.Session.Dir = strdup( Tmp );
								}
								else
									GF.Session.Dir = strdup( "/" );
								if( !GF.Session.Dir )
									return( ENSMEM );
								free( Tmp );
								CopyFtpDirPath( &GF );
								Msg[0] = GemFtp_Cmd;
								Msg[1] = AppId;
								Msg[2] = 0;
								MT_appl_write( AppId, 16, Msg, GF.Global );
								break;
							}
/* Pwd_Msg --------------------------------------------------------------------*/
							case	Pwd_Ok:
							{
#ifdef	GEMScript
								if( GsFlag )
								{
									BYTE	*Ret = Xmalloc( strlen( GF.Session.Dir ) + 1, RAM_READABLE );
									strcpy( Ret, GF.Session.Dir );
									Ret[strlen( Ret ) + 1] = 0;
									Msg[0] = GS_ACK;
									Msg[1] = Global[2];
									Msg[2] = 0;
									*( BYTE **) &Msg[3] = GsCmd;
									*( BYTE **) &Msg[5] = Ret;
									Msg[7] = GSACK_OK;
									MT_appl_write( GsAppId, 16, Msg, GF.Global );
									AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[READY], GF.Global );
									break;
								}
#endif
								AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[READY], GF.Global );
								CopyFtpDirPath( &GF );
								Msg[0] = GemFtp_Cmd;
								Msg[1] = AppId;
								Msg[2] = 0;
								MT_appl_write( AppId, 16, Msg, GF.Global );
								break;
							}
							case	Pwd_Failed:
								Con( "Error: Pwd" );crlf;
								break;
/* List_Msg -------------------------------------------------------------------*/
							case	List_Update:
#ifdef	GEMScript
							if( !GsFlag )
#endif
							{
								WORD		Len = 0;
								STR_ITEM	*Tmp;
								GRECT		Rect, *RectP = NULL;
								OBJECT	*DialogTree;
								WORD		n = 0;
								if( !isIconifiedWindow( MT_wdlg_get_handle( GF.FtpDialog, GF.Global )))
								{
									MT_wdlg_get_tree( GF.FtpDialog, &DialogTree, &Rect, GF.Global );
									RectP = &Rect;
								}
								if( MT_lbox_get_items( GF.FtpListBox, GF.Global ) == NULL )
								{
									MT_lbox_set_items( GF.FtpListBox, (LBOX_ITEM *) GF.FtpList, GF.Global );
									nItem = 0;
								}
								MT_lbox_set_asldr( GF.FtpListBox, 0, RectP, GF.Global );

								Tmp = GF.FtpList;
								while( Tmp )
								{
									if( Tmp->str[1] == ' ' )
									{
										if( strlen( Tmp->str ) > Len )
											Len = ( WORD ) strlen( Tmp->str );
										n++;
									}
									Tmp = Tmp->next;
								}
								if( Len > MT_lbox_get_bentries( GF.FtpListBox, GF.Global ))
								{
									MT_lbox_set_bentries( GF.FtpListBox, Len, GF.Global );
									MT_lbox_set_bsldr( GF.FtpListBox, 0, RectP, GF.Global );
									DoRedraw( GF.FtpDialog, RectP, FTP_DIR_BACK_H, GF.Global );
								}
								if( nItem <= TreeAddr[FTP][FTP_DIR_BOX].ob_height / PhChar || ( SortDirList & SORT_DIR_LIST_ON ))
									MT_lbox_update( GF.FtpListBox, RectP, GF.Global );
								nItem = n;
							}
							break;
							case	List_Ok:
#ifdef	GEMScript
								if( GsFlag )
								{
									STR_ITEM	*Item = GF.FtpList;
									BYTE	*Ret, *Tmp;
									long	Len = 0;

									while( Item )
									{
										Len += strlen( Item->str ) + 1;
										Item = Item->next;
									}
									Ret = Xmalloc( Len + 1, RAM_READABLE);
									if( !Ret )
										return( ENSMEM );

									Item = GF.FtpList;
									Tmp = Ret;
									while( Item )
									{
										strcpy( Tmp, Item->str );
										Item = Item->next;
										Tmp = Tmp + strlen( Tmp ) + 1;
									}
									*Tmp = 0;
									Msg[0] = GS_ACK;
									Msg[1] = Global[2];
									Msg[2] = 0;
									*( BYTE **) &Msg[3] = GsCmd;
									*( BYTE **) &Msg[5] = Ret;
									Msg[7] = GSACK_OK;
									MT_appl_write( GsAppId, 16, Msg, GF.Global );
									AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[READY], GF.Global );
									break;
								}
#endif
								AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[READY], GF.Global );
								EnableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );
								break;
							case	List_Abort:
								AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[CANCEL], GF.Global );
								EnableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );
								break;
/* Retr_Msg ------------------------------------------------------------------*/
							case	Retr_Ok:
							{
								STR_ITEM	*Item;
								GRECT		Rect, *RectP;
								OBJECT	*DialogTree;
#ifdef	V120
								if( TransferPing )
									Cconout( '\a' );
#endif
								TStartAll = 0;
								CloseDialog( TrDialog, GF.Global );
								TrDialog = NULL;
								if( !isIconifiedWindow( MT_wdlg_get_handle( GF.FtpDialog, GF.Global )))
								{
									MT_wdlg_get_tree( GF.FtpDialog, &DialogTree, &Rect, GF.Global );
									RectP = &Rect;
								}
								DelFileNameList( &FileNameList );
								DelFileNameList( &PathList );
								free( FileSizeList );
								Item = GF.FtpList;
								while( Item )
								{
									Item->selected = 0;
									Item = Item->next;
								}
								MT_lbox_update( GF.FtpListBox, RectP, GF.Global );
								EnableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );
								if( ErrorFlag == Retr_Failed )
								{
									Msg[0] = GemFtp_CmdFailed;
									Msg[1] = AppId;
									Msg[2] = 0;
									MT_appl_write( AppId, 16, Msg, GF.Global );
								}
								else
								{
									Msg[0] = GemFtp_Cmd;
									Msg[1] = AppId;
									Msg[2] = 0;
									MT_appl_write( AppId, 16, Msg, GF.Global );
								}
								break;
							}
							case	Retr_File_Ok:
							{
								WORD	SysShell, Type;
								BYTE	Puf[9];
								AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[READY], GF.Global );
								MT_appl_search( 2, Puf, &Type, &SysShell, GF.Global );
								Msg[0] = SH_WDRAW;
								Msg[1] = AppId;
								Msg[2] = 0;
								Msg[3] = *( PathList[Events.msg[5]] ) - 'A';
								MT_shel_write( SHW_BROADCAST, 0, 0, ( BYTE * ) Msg, 0L, GF.Global );
#ifdef	GEMScript
								if( GsFlag )
								{
									BYTE	*Ret = Xmalloc( 3, RAM_READABLE );
									strcpy( Ret, "0" );
									Ret[2] = 0;
									Msg[0] = GS_ACK;
									Msg[1] = Global[2];
									Msg[2] = 0;
									*( BYTE **) &Msg[3] = GsCmd;
									*( BYTE **) &Msg[5] = Ret;
									Msg[7] = GSACK_OK;
									MT_appl_write( GsAppId, 16, Msg, GF.Global );
								}
#endif
								break;
							}
							case	Retr_File_Update:
							{
								GRECT		Rect;
								OBJECT	*DialogTree;
								if( TStartAll == 0 )
								TStartAll = clock();
								TStart = clock();
								FileSize = 0;
								FileOffset = 0;
								FileSizeIs = FileSizeList[Events.msg[5]];
								CurrentFile = Events.msg[5];
								MT_wdlg_get_tree( TrDialog, &DialogTree, &Rect, GF.Global );
								WriteStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[RETR], GF.Global );
								AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FileNameList[Events.msg[5]], GF.Global );
								if( Events.msg[6] == TT_Bin )
									AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[TR_BIN], GF.Global );
								if( Events.msg[6] == TT_Ascii )
									AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[TR_ASC], GF.Global );
								ShortFileStrCpy( DialogTree[TR_FILE].ob_spec.tedinfo->te_ptext, FileNameList[Events.msg[5]], DialogTree[TR_FILE].ob_spec.tedinfo->te_txtlen );
								ShortFileStrCpy( DialogTree[TR_PATH].ob_spec.tedinfo->te_ptext, PathList[Events.msg[5]], DialogTree[TR_PATH].ob_spec.tedinfo->te_txtlen );
								sprintf( DialogTree[TR_N].ob_spec.tedinfo->te_ptext, "%i", Events.msg[5] + 1 );
								if( FileSizeIs > 0 )
									Decimal( FileSizeIs, TreeAddr[TR][TR_SIZE_IS].ob_spec.tedinfo->te_ptext );
								else
									strcpy( TreeAddr[TR][TR_SIZE_IS].ob_spec.tedinfo->te_ptext, "-" );
								if( FileSizeAllIs > 0 )
									Decimal( FileSizeAllIs, TreeAddr[TR][TR_SIZE_ALL_IS].ob_spec.tedinfo->te_ptext );
								else
									strcpy( TreeAddr[TR][TR_SIZE_ALL_IS].ob_spec.tedinfo->te_ptext, "-" );
								DoRedrawX( TrDialog, &Rect, GF.Global, TR_FILE, TR_PATH, TR_N, TR_SIZE_IS, TR_SIZE_ALL_IS, EDRX );
								CalcTimeRateBar( TStart, TStartAll, clock(), FileSize, FileSizeIs, FileSizeAll, FileSizeAllIs, TrDialog, TreeAddr[TR], FileOffset, FileOffsetAll, GF.Global );
								if( !( AesFlags & GAI_3D ))
									DoRedraw( TrDialog, &Rect, 0, GF.Global );
								break;
							}
#ifdef	RESUME
							case	Retr_File_Resume:
								AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[RESUME_FILE], GF.Global );
								FileOffset += *( LONG * ) &Events.msg[3];
								FileOffsetAll += *( LONG * ) &Events.msg[3];
								break;
#endif
							case	Retr_Update:
							{
								GRECT		Rect;
								OBJECT	*DialogTree;
								MT_wdlg_get_tree( TrDialog, &DialogTree, &Rect, GF.Global );
								FileSize += Events.msg[4];
								FileSizeAll += Events.msg[4];
								if( FileSizeList[CurrentFile] == 0 )
								{
									FileSizeAllIs += Events.msg[4];
									Decimal( FileSizeAllIs, TreeAddr[TR][TR_SIZE_ALL_IS].ob_spec.tedinfo->te_ptext );
									DoRedraw( TrDialog, &Rect, TR_SIZE_ALL_IS, GF.Global );
								}
								CalcTimeRateBar( TStart, TStartAll, clock(), FileSize, FileSizeIs, FileSizeAll, FileSizeAllIs, TrDialog, TreeAddr[TR], FileOffset, FileOffsetAll, GF.Global );
								if( !( AesFlags & GAI_3D ))
									DoRedraw( TrDialog, &Rect, 0, GF.Global );
								break;
							}
							case	Retr_Abort:
								AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[CANCEL], GF.Global );
								Msg[0] = GemFtp_Cmd;
								Msg[1] = AppId;
								Msg[2] = 0;
								MT_appl_write( AppId, 16, Msg, GF.Global );
								break;
							case	Retr_Failed:
								AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[ERR], GF.Global );
								ErrorFlag = Retr_Failed;
#ifdef	GEMScript
								if( GsFlag )
								{
									BYTE	*Ret = Xmalloc( 7, RAM_READABLE );
									itoa( Events.msg[4], Ret, 10 );
									Ret[strlen( Ret ) + 1] = 0;
									Msg[0] = GS_ACK;
									Msg[1] = Global[2];
									Msg[2] = 0;
									*( BYTE **) &Msg[3] = GsCmd;
									*( BYTE **) &Msg[5] = Ret;
									Msg[7] = GSACK_ERROR;
									MT_appl_write( GsAppId, 16, Msg, GF.Global );
								}
#endif
								break;
							case	Retr_Get_Size:
								if( TrDialog && FileSizeList[CurrentFile] == 0 ) /* Evtl. bei V1.0x ergÑnzen */
								{
									GRECT		Rect;
									OBJECT	*DialogTree;
									MT_wdlg_get_tree( TrDialog, &DialogTree, &Rect, GF.Global );
									FileSizeList[CurrentFile] = *( LONG * ) &Events.msg[3];
/*									FileSizeList[CurrentFile] = Events.msg[3];
									FileSizeList[CurrentFile] = FileSizeList[CurrentFile] << 16;
									FileSizeList[CurrentFile] += Events.msg[4];	*/
									FileSizeIs = FileSizeList[CurrentFile];
									FileSizeAllIs += FileSizeIs;
									Decimal( FileSizeIs, TreeAddr[TR][TR_SIZE_IS].ob_spec.tedinfo->te_ptext );
									Decimal( FileSizeAllIs, TreeAddr[TR][TR_SIZE_ALL_IS].ob_spec.tedinfo->te_ptext );
									DoRedrawX( TrDialog, &Rect, GF.Global, TR_SIZE_IS, TR_SIZE_ALL_IS, EDRX );
									if( !( AesFlags & GAI_3D ))
										DoRedraw( TrDialog, &Rect, 0, GF.Global );
								}
								break;
/* Stor_Msg ------------------------------------------------------------------*/
							case	Stor_Ok:
#ifdef	V120
							if( TransferPing )
								Cconout( '\a' );
#endif
								TStartAll = 0;
								CloseDialog( TrDialog, GF.Global );
								TrDialog = NULL;
								DelFileNameList( &FileNameList );
								DelFileNameList( &PathList );
								free( FileSizeList );
#ifdef	GEMScript
								if( GsFlag )
									break;
#endif
								Msg[0] = GemFtp_List;
								Msg[1] = AppId;
								Msg[2] = 0;
								MT_appl_write( AppId, 16, Msg, GF.Global );
								break;
							case	Stor_File_Ok:
#ifdef	GEMScript
								if( GsFlag )
								{
									BYTE	*Ret = Xmalloc( 3, RAM_READABLE );
									strcpy( Ret, "0" );
									Ret[2] = 0;
									Msg[0] = GS_ACK;
									Msg[1] = Global[2];
									Msg[2] = 0;
									*( BYTE **) &Msg[3] = GsCmd;
									*( BYTE **) &Msg[5] = Ret;
									Msg[7] = GSACK_OK;
									MT_appl_write( GsAppId, 16, Msg, GF.Global );
								}
#endif
								AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[READY], GF.Global );
								break;
							case	Stor_File_Update:
							{
								GRECT		Rect;
								OBJECT	*DialogTree;
								if( TStartAll == 0 )
									TStartAll = clock();
								TStart = clock();
								FileSize = 0;
								FileOffset = 0;
								FileSizeIs = FileSizeList[Events.msg[5]];
								MT_wdlg_get_tree( TrDialog, &DialogTree, &Rect, GF.Global );
								WriteStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[STOR], GF.Global );
								AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FileNameList[Events.msg[5]], GF.Global );
								if( Events.msg[6] == TT_Bin )
									AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[TR_BIN], GF.Global );
								if( Events.msg[6] == TT_Ascii )
									AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[TR_ASC], GF.Global );
								ShortFileStrCpy( DialogTree[TR_FILE].ob_spec.tedinfo->te_ptext, FileNameList[Events.msg[5]], DialogTree[TR_FILE].ob_spec.tedinfo->te_txtlen );
								ShortFileStrCpy( DialogTree[TR_PATH].ob_spec.tedinfo->te_ptext, PathList[Events.msg[5]], DialogTree[TR_PATH].ob_spec.tedinfo->te_txtlen );
								sprintf( DialogTree[TR_N].ob_spec.tedinfo->te_ptext, "%i", Events.msg[5] + 1 );
								if( FileSizeIs > 0 )
									Decimal( FileSizeIs, TreeAddr[TR][TR_SIZE_IS].ob_spec.tedinfo->te_ptext );
								else
									strcpy( DialogTree[TR_SIZE_IS].ob_spec.tedinfo->te_ptext, "-" );
								if( FileSizeAllIs > 0 )
									Decimal( FileSizeAllIs, TreeAddr[TR][TR_SIZE_ALL_IS].ob_spec.tedinfo->te_ptext );
								else
									strcpy( TreeAddr[TR][TR_SIZE_ALL_IS].ob_spec.tedinfo->te_ptext, "-" );
								DoRedrawX( TrDialog, &Rect, GF.Global, TR_FILE, TR_PATH, TR_N, TR_SIZE_IS, TR_SIZE_ALL_IS, EDRX );
								CalcTimeRateBar( TStart, TStartAll, clock(), FileSize, FileSizeIs, FileSizeAll, FileSizeAllIs, TrDialog, TreeAddr[TR], FileOffset, FileOffsetAll, GF.Global );
								if( !( AesFlags & GAI_3D ))
									DoRedraw( TrDialog, &Rect, 0, GF.Global );
								break;
							}
							case	Stor_Update:
							{
								GRECT		Rect;
								OBJECT	*DialogTree;
								MT_wdlg_get_tree( TrDialog, &DialogTree, &Rect, GF.Global );
								FileSize += Events.msg[4];
								FileSizeAll += Events.msg[4];
								CalcTimeRateBar( TStart, TStartAll, clock(), FileSize, FileSizeIs, FileSizeAll, FileSizeAllIs, TrDialog, TreeAddr[TR], FileOffset, FileOffsetAll, GF.Global );
								if( !( AesFlags & GAI_3D ))
									DoRedraw( TrDialog, &Rect, 0, GF.Global );
								break;
							}
							case	Stor_Abort:
								AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[CANCEL], GF.Global );
								break;
							case	Stor_Failed:
								TStartAll = 0;
								CloseDialog( TrDialog, GF.Global );
								TrDialog = NULL;
								DelFileNameList( &FileNameList );
								DelFileNameList( &PathList );
								free( FileSizeList );
#ifdef	GEMScript
								if( GsFlag )
								{
									BYTE	*Ret = Xmalloc( 7, RAM_READABLE );
									itoa( Events.msg[4], Ret, 10 );
									Ret[strlen( Ret ) + 1] = 0;
									Msg[0] = GS_ACK;
									Msg[1] = Global[2];
									Msg[2] = 0;
									*( BYTE **) &Msg[3] = GsCmd;
									*( BYTE **) &Msg[5] = Ret;
									Msg[7] = GSACK_ERROR;
									MT_appl_write( GsAppId, 16, Msg, GF.Global );
									AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[ERR], GF.Global );
									break;
								}
#endif
								AlertStatus = Stor_Failed;
								WindowAlertDialog = WindowAlert( FtpDialogTitle, FstringAddr[STOR_FAILED], 1, GF.Global );
								AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[ERR], GF.Global );
								break;
/* Rn_Msg --------------------------------------------------------------------*/
							case	Rn_Ok:
								DelFileNameList( &FileNameList );
								DelFileNameList( &FileNameListNew );
								Msg[0] = GemFtp_List;
								Msg[1] = AppId;
								Msg[2] = 0;
								MT_appl_write( AppId, 16, Msg, GF.Global );
								break;
							case	Rn_Update:
								WriteStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[RN], GF.Global );
								AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FileNameList[Events.msg[5]], GF.Global );
								WriteStatusGemFtp( GF.FtpDialog, InfoPuf, " -> ", GF.Global );
								AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FileNameListNew[Events.msg[5]], GF.Global );
								break;
							case	Rn_File_Ok:
								AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[READY], GF.Global );
								break;
							case	Rn_Failed:
								DelFileNameList( &FileNameList );
								DelFileNameList( &FileNameListNew );
								WindowAlertDialog = WindowAlert( FtpDialogTitle, FstringAddr[MV_FAILED], 1, GF.Global );
								AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[ERR], GF.Global );
								AlertStatus = Rn_Failed;
								break;
/* Dele_Msg ------------------------------------------------------------------*/
							case	Dele_Ok:
								DelFileNameList( &FileNameList );
#ifdef	GEMScript
								if( GsFlag )
								{
									BYTE	*Ret = Xmalloc( 3, RAM_READABLE );
									strcpy( Ret, "0" );
									Ret[2] = 0;
									Msg[0] = GS_ACK;
									Msg[1] = Global[2];
									Msg[2] = 0;
									*( BYTE **) &Msg[3] = GsCmd;
									*( BYTE **) &Msg[5] = Ret;
									Msg[7] = GSACK_OK;
									MT_appl_write( GsAppId, 16, Msg, GF.Global );
									break;
								}
#endif
								Msg[0] = GemFtp_List;
								Msg[1] = AppId;
								Msg[2] = 0;
								MT_appl_write( AppId, 16, Msg, GF.Global );
								break;
							case	Dele_Update:
								WriteStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[DELE], GF.Global );
								AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FileNameList[Events.msg[5]], GF.Global );
								break;
							case	Dele_File_Ok:
								AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[READY], GF.Global );
								break;
							case	Dele_Failed:
								DelFileNameList( &FileNameList );
#ifdef	GEMScript
								if( GsFlag )
								{
									BYTE	*Ret = Xmalloc( 7, RAM_READABLE );
									itoa( Events.msg[4], Ret, 10 );
									Ret[strlen( Ret ) + 1] = 0;
									Msg[0] = GS_ACK;
									Msg[1] = Global[2];
									Msg[2] = 0;
									*( BYTE **) &Msg[3] = GsCmd;
									*( BYTE **) &Msg[5] = Ret;
									Msg[7] = GSACK_ERROR;
									MT_appl_write( GsAppId, 16, Msg, GF.Global );
									AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[ERR], GF.Global );
									break;
								}
#endif
								AlertStatus = Dele_Failed;
								WindowAlertDialog = WindowAlert( FtpDialogTitle, FstringAddr[RM_FAILED], 1, GF.Global );
								AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[ERR], GF.Global );
								break;
/* Mkd_Msg --------------------------------------------------------------------*/
							case	Mkd_Ok:
#ifdef	GEMScript
								if( GsFlag )
								{
									BYTE	*Ret = Xmalloc( 3, RAM_READABLE );
									strcpy( Ret, "0" );
									Ret[2] = 0;
									Msg[0] = GS_ACK;
									Msg[1] = Global[2];
									Msg[2] = 0;
									*( BYTE **) &Msg[3] = GsCmd;
									*( BYTE **) &Msg[5] = Ret;
									Msg[7] = GSACK_OK;
									MT_appl_write( GsAppId, 16, Msg, GF.Global );
									break;
								}
#endif
#ifdef	RECURSIV
								if( DirList )
								{
									if( DirList[nDirList] )
									{
										Msg[0] = Mkd_Cmd;
										Msg[1] = AppId;
										Msg[2] = 0;
										(BYTE *) *( LONG *)&( Msg[3] ) = strdup( DirList[nDirList++] );
										if( !(BYTE *) *( LONG *)&( Msg[3] ))
											return( ENSMEM );
										MT_appl_write( FtpAppId, 16, Msg, GF.Global );
									}
									else
									{
										DelFileNameList( &DirList );
										if( FileNameList[0] )
										{
											Msg[0] = GemFtp_Put_Start;
											Msg[1] = AppId;
											Msg[2] = 0;
											MT_appl_write( AppId, 16, Msg, GF.Global );
										}
										else
										{
											AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[READY], GF.Global );
											EnableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );												
										}
									}
									break;
								}
#endif
								AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[READY], GF.Global );
								Msg[0] = GemFtp_List;
								Msg[1] = AppId;
								Msg[2] = 0;
								MT_appl_write( AppId, 16, Msg, GF.Global );
								break;
							case	Mkd_Failed:
#ifdef	GEMScript
								if( GsFlag )
								{
									BYTE	*Ret = Xmalloc( 7, RAM_READABLE );
									itoa( Events.msg[3], Ret, 10 );
									Ret[strlen( Ret ) + 1] = 0;
									Msg[0] = GS_ACK;
									Msg[1] = Global[2];
									Msg[2] = 0;
									*( BYTE **) &Msg[3] = GsCmd;
									*( BYTE **) &Msg[5] = Ret;
									Msg[7] = GSACK_ERROR;
									MT_appl_write( GsAppId, 16, Msg, GF.Global );
									AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[ERR], GF.Global );
									break;
								}
#endif
#ifdef	RECURSIV
								if( DirList )
								{
									if( Events.msg[3] == 553 || Events.msg[3] == 521 )
									{
										if( DirList[nDirList] )
										{
											Msg[0] = Mkd_Cmd;
											Msg[1] = AppId;
											Msg[2] = 0;
											(BYTE *) *( LONG *)&( Msg[3] ) = strdup( DirList[nDirList++] );
											if( !(BYTE *) *( LONG *)&( Msg[3] ))
												return( ENSMEM );
											MT_appl_write( FtpAppId, 16, Msg, GF.Global );
										}
										else
										{
											DelFileNameList( &DirList );
											if( FileNameList[0] )
											{
												Msg[0] = GemFtp_Put_Start;
												Msg[1] = AppId;
												Msg[2] = 0;
												MT_appl_write( AppId, 16, Msg, GF.Global );
											}
											else
											{
												AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[READY], GF.Global );
												EnableButton( GF.FtpDialog, TreeAddr[FTP], GF.Global );												
											}
										}
										break;
									}
									else
									{
										DelFileNameList( &DirList );
										if( FileNameList )
										{
											DelFileNameList( &FileNameList );
											DelFileNameList( &PathList );
										}
									}
								}
#endif
								WindowAlertDialog = WindowAlert( FtpDialogTitle, FstringAddr[MKD_FAILED], 1, GF.Global );
								AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[ERR], GF.Global );
								AlertStatus = Mkd_Failed;
								break;
/* Rmd_Msg --------------------------------------------------------------------*/
							case	Rmd_Ok:
								DelFileNameList( &FileNameList );
#ifdef	GEMScript
								if( GsFlag )
								{
									BYTE	*Ret = Xmalloc( 3, RAM_READABLE );
									strcpy( Ret, "0" );
									Ret[2] = 0;
									Msg[0] = GS_ACK;
									Msg[1] = Global[2];
									Msg[2] = 0;
									*( BYTE **) &Msg[3] = GsCmd;
									*( BYTE **) &Msg[5] = Ret;
									Msg[7] = GSACK_OK;
									MT_appl_write( GsAppId, 16, Msg, GF.Global );
									break;
								}
#endif
								Msg[0] = GemFtp_List;
								Msg[1] = AppId;
								Msg[2] = 0;
								MT_appl_write( AppId, 16, Msg, GF.Global );
								break;
							case	Rmd_Update:
								WriteStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[RMD], GF.Global );
								AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FileNameList[Events.msg[5]], GF.Global );
								break;
							case	Rmd_Dir_Ok:
								AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[READY], GF.Global );
								break;
							case	Rmd_Failed:
								DelFileNameList( &FileNameList );
#ifdef	GEMScript
								if( GsFlag )
								{
									BYTE	*Ret = Xmalloc( 7, RAM_READABLE );
									itoa( Events.msg[3], Ret, 10 );
									Ret[strlen( Ret ) + 1] = 0;
									Msg[0] = GS_ACK;
									Msg[1] = Global[2];
									Msg[2] = 0;
									*( BYTE **) &Msg[3] = GsCmd;
									*( BYTE **) &Msg[5] = Ret;
									Msg[7] = GSACK_ERROR;
									MT_appl_write( GsAppId, 16, Msg, GF.Global );
									AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[ERR], GF.Global );
									break;
								}
#endif
								AlertStatus = Rmd_Failed;
								WindowAlertDialog = WindowAlert( FtpDialogTitle, FstringAddr[RMD_FAILED], 1, GF.Global );
								AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[ERR], GF.Global );
								break;
/* Chmod_Msg ------------------------------------------------------------------*/
							case	Chmod_Ok:
								DelFileNameList( &FileNameList );
								free((BYTE *) *( LONG *)&( Events.msg[6] ));
#ifdef	GEMScript
								if( GsFlag )
								{
									BYTE	*Ret = Xmalloc( 3, RAM_READABLE );
									strcpy( Ret, "0" );
									Ret[2] = 0;
									Msg[0] = GS_ACK;
									Msg[1] = Global[2];
									Msg[2] = 0;
									*( BYTE **) &Msg[3] = GsCmd;
									*( BYTE **) &Msg[5] = Ret;
									Msg[7] = GSACK_OK;
									MT_appl_write( GsAppId, 16, Msg, GF.Global );
									break;
								}
#endif
								Msg[0] = GemFtp_List;
								Msg[1] = AppId;
								Msg[2] = 0;
								MT_appl_write( AppId, 16, Msg, GF.Global );
								break;
							case	Chmod_Update:
								WriteStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[CHMOD], GF.Global );
								AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FileNameList[Events.msg[5]], GF.Global );
								break;
							case	Chmod_Failed:
								DelFileNameList( &FileNameList );
								free((BYTE *) *( LONG *)&( Events.msg[6] ));
#ifdef	GEMScript
								if( GsFlag )
								{
									BYTE	*Ret = Xmalloc( 7, RAM_READABLE );
									itoa( Events.msg[3], Ret, 10 );
									Ret[strlen( Ret ) + 1] = 0;
									Msg[0] = GS_ACK;
									Msg[1] = Global[2];
									Msg[2] = 0;
									*( BYTE **) &Msg[3] = GsCmd;
									*( BYTE **) &Msg[5] = Ret;
									Msg[7] = GSACK_ERROR;
									MT_appl_write( GsAppId, 16, Msg, GF.Global );
									AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[ERR], GF.Global );
									break;
								}
#endif
								AlertStatus = Chmod_Failed;
								WindowAlertDialog = WindowAlert( FtpDialogTitle, FstringAddr[CHMOD_FAILED], 1, GF.Global );
								AppendStatusGemFtp( GF.FtpDialog, InfoPuf, FstringAddr[ERR], GF.Global );
								break;
						}
					}
				}
				if( AvAppId >= 0 )
					AvExit( AvAppId, GF.Global );
				{
					WORD	i;
					for( i = 0; i < NO_FTP_DIR_V; i++ )
						free( TreeAddr[FTP][FtpDirObjs[i]].ob_spec.tedinfo->te_ptext );
				}
				MT_rsrc_free( GF.Global );
			}
			else
				MT_form_alert( 1, "[3][Error: Can't load rsc!][Cancel]", GF.Global );
			v_clsvwk ( GF.VdiHandle );
		}
		else
			MT_form_alert( 1, "[3][Error: OpenScreenWk()][Cancel]", GF.Global );

#ifdef DEBUG
	DebugMsg( GF.Global, "GemFtp [AppId = %i] beendet\n", AppId );
#endif
#ifdef	NAES
		if(( AesFlags & GAI_MAGIC ) == 0 )
		{
			WORD	Msg[8];
			Msg[0] = THR_EXIT;
			Msg[1] = AppId;
			Msg[2] = 0;
			Msg[3] = AppId;
			Msg[4] = 0;
			Msg[5] = 0;
			MT_appl_write( Global[2], 16, Msg, GF.Global );
		}
#endif
		
/*		MT_appl_exit( GF.Global );	*/
	}
	else
	{
		Con( "Error: MT_appl_init() failed" ); crlf;
	}
	free( Url );
	return( 0 );
}

/*----------------------------------------------------------------------------------------*/ 
/* HandleFtpDialog                                                                        */
/*----------------------------------------------------------------------------------------*/ 
WORD	cdecl	HandleFtpDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD )
{
	OBJECT	*DialogTree;
	GRECT		Rect;

	GemFtp 	*GF;
	GF = (GemFtp *) UD;
#ifdef DEBUG
	DebugMsg( GF->Global, "HandleFtpDialog(): %i\n", Obj );
#endif
	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, GF->Global );

	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_CLSD:
			{
				WORD	Msg[8];
				Msg[0] = AP_TERM;
				Msg[1] = GF->Global[2];
				Msg[2] = 0;
				MT_appl_write( GF->Global[2], 16, Msg, GF->Global );
				return( 1 );
			}
			case	HNDL_MOVE:
			{
				GRECT	Rect;
				MT_wind_get_grect( MT_wdlg_get_handle( GF->FtpDialog, GF->Global ), WF_CURRXYWH, &Rect, GF->Global );
				SetFtpPos( GF->nFtpWin, &Rect );
				break;
			}
			case	HNDL_INIT:
			{
				if(( GF->FtpListBox = MT_lbox_create( DialogTree, 
					SlctFtpItem, SetFtpItem, /*(LBOX_ITEM *)*/ NULL,
					NO_FTP_DIR_V, 0, FtpDirCtrl, FtpDirObjs, 
					LBOX_VERT + LBOX_AUTO + LBOX_AUTOSLCT + LBOX_REAL + LBOX_TOGGLE + LBOX_SHFT + LBOX_2SLDRS, 
					40, ( void * ) GF , Dialog, NO_FTP_DIR_H, 0, 0, 40, GF->Global )) == 0 )
					return( 0 );

				if( TransferType == TT_Auto )
					DialogTree[FTP_TT_AUTO].ob_state |= SELECTED;
				if( TransferType == TT_Bin )
					DialogTree[FTP_TT_BIN].ob_state |= SELECTED;
				if( TransferType == TT_Ascii )
					DialogTree[FTP_TT_ASCII].ob_state |= SELECTED;
				strcpy( DialogTree[FTP_DIR_PATH].ob_spec.tedinfo->te_ptext, "" );
				break;
			}
			case	HNDL_MESG:
			{
				if( Events->msg[0] == WM_FULLED )
				{
					GRECT	TmpRect, WinRect, ScreenRect;
					WORD	WinHandle = MT_wdlg_get_handle( Dialog, GF->Global );
					MT_wind_get_grect( WinHandle, WF_WORKXYWH, &TmpRect, GF->Global );
					if( TmpRect.g_w == FtpWinMaxW * PwChar &&
					    TmpRect.g_h == FtpWinMaxH * PhChar )
					{
						TmpRect.g_w = FtpWinMinW * PwChar;
						TmpRect.g_h = FtpWinMinH * PhChar;
					}
					else
					{
						TmpRect.g_w = FtpWinMaxW * PwChar;
						TmpRect.g_h = FtpWinMaxH * PhChar;
					}
					MT_wind_calc( WC_BORDER, NAME + MOVER + CLOSER + FULLER + INFO + ICONIFIER, &TmpRect, &WinRect, GF->Global );
					MT_wind_get_grect( 0, WF_CURRXYWH, &ScreenRect, GF->Global );
					if( WinRect.g_x + WinRect.g_w > ScreenRect.g_w )
						WinRect.g_w = ScreenRect.g_w - WinRect.g_x;
					if( WinRect.g_y + WinRect.g_h > ScreenRect.g_y + ScreenRect.g_h )
						WinRect.g_h = ScreenRect.g_y + ScreenRect.g_h - WinRect.g_y;
					SetFtpSize( Dialog, &WinRect, GF );
					break;
				}
				if( Events->msg[0] == WM_ICONIFY )
				{
					RSHDR 	*Rsh;
					OBJECT	**TreeAddr;
					Rsh = *((RSHDR **)( &(GF->Global[7] )));	
					TreeAddr = (OBJECT **)(((UBYTE *)Rsh) + Rsh->rsh_trindex);
					if( !isIconifiedWindow( MT_wdlg_get_handle( Dialog, GF->Global )))
					{
						DialogTree = malloc( 2 * sizeof( OBJECT ));
						if( !DialogTree )
						{
							MemErr( "GemFtp" );
							return( 0 );
						}
						memcpy( DialogTree, TreeAddr[ICONIFY], 2 * sizeof( OBJECT ));
						MT_wdlg_set_iconify( Dialog, ( GRECT *) &( Events->msg[4] ), NULL, DialogTree, ICONIFY_ICON, GF->Global );
						IconifyWindow( MT_wdlg_get_handle( Dialog, GF->Global ));
					}
					else
						MT_wind_set_grect( MT_wdlg_get_handle( Dialog, Global ), WF_CURRXYWH, ( GRECT *) &( Events->msg[4] ), GF->Global );
				}
				if( Events->msg[0] == WM_UNICONIFY )
				{
					RSHDR 	*Rsh;
					OBJECT	**TreeAddr;
					Rsh = *((RSHDR **)( &(GF->Global[7] )));	
					TreeAddr = (OBJECT **)(((UBYTE *)Rsh) + Rsh->rsh_trindex);
					MT_wdlg_set_uniconify( Dialog, ( GRECT *) &( Events->msg[4] ), NULL, TreeAddr[FTP], GF->Global );
					UnIconifyWindow( MT_wdlg_get_handle( Dialog, GF->Global ));
					free( DialogTree );
				}
				if( Events->msg[0] == WM_ALLICONIFY )
				{
					WORD	Msg[8];
					Msg[0] = WM_ALLICONIFY;
					Msg[1] = GF->Global[2];
					Msg[2] = 0;
					Msg[3] = 0;
					Msg[4] = Events->msg[4]; Msg[5] = Events->msg[5]; Msg[6] = Events->msg[6];	Msg[7] = Events->msg[7];
					MT_appl_write( GF->Global[2], 16, Msg, GF->Global );
				}
				break;
			}
		}
	}
	else
	{
		WORD		Msg[8];
		{
			WORD 	i;
			for( i = 0; i < NO_FTP_DIR_V; i++ )
				if( FtpDirIcons[i] == ( Obj & 0x7fff ))
				{
					Obj = FtpDirObjs[i];
					break;
				}
		}

		if( Clicks == 2 )
			Obj |= 0x8000;

		if( MT_lbox_do( (LIST_BOX) GF->FtpListBox, Obj, GF->Global ) == -1 )
		{
			WORD		SlctObj, SlctIndex;
			STR_ITEM	*SlctItem;
			SlctObj = Obj & 0x7fff;
			SlctIndex = SlctObj - FTP_DIR_0 + MT_lbox_get_afirst( GF->FtpListBox, GF->Global );
			SlctItem = ( STR_ITEM * ) MT_lbox_get_item( GF->FtpListBox, SlctIndex, GF->Global );
			if( *( SlctItem->str ) == 'd' )
			{
				STR_ITEM	*Item;
				Item = GF->FtpList;
				while( Item )
				{
					if( Item != SlctItem )
						Item->selected = 0;
					Item = Item->next;
				}
				Msg[0] = GemFtp_Cd;
				Msg[1] = GF->Global[2];
				Msg[2] = 0;
				MT_appl_write( GF->Global[2], 16, Msg, GF->Global );
			}
			if( *( SlctItem->str ) == 'l' )
			{
				Msg[0] = GemFtp_Link;
				Msg[1] = GF->Global[2];
				Msg[2] = 0;
				MT_appl_write( GF->Global[2], 16, Msg, GF->Global );
			}
			if( *( SlctItem->str ) == '-' )
			{
				Msg[0] = GemFtp_Get;
				Msg[1] = GF->Global[2];
				Msg[2] = 0;
				MT_appl_write( GF->Global[2], 16, Msg, GF->Global );
			}
			return( 1 );
		}

		Obj &= 0x7fff;
		if( HandleIcon( &Obj, Dialog, Global ))
			return( 1 );
		
/* FTP_DIR_PATH ---------------------------------------------------------------*/
		if( Obj == FTP_DIR_PATH )
		{
/* [GS] 1.50a */
			EVNTDATA ev;
			
			MT_graf_mkstate ( &ev, GF->Global );
/* End */

			Msg[0] = GemFtp_Path_Popup;
			Msg[1] = GF->Global[2];
			Msg[2] = 0;
/* [GS] 1.50a */
			Msg[3] = ev.x;
/* End */
			MT_appl_write( GF->Global[2], 16, Msg, GF->Global );
		}

/* FTP_GET --------------------------------------------------------------------*/
		if( Obj == FTP_GET )
		{
			Msg[0] = GemFtp_Get;
			Msg[1] = GF->Global[2];
			Msg[2] = 0;
			MT_appl_write( GF->Global[2], 16, Msg, GF->Global );
			DialogTree[FTP_GET].ob_state &= ~SELECTED;
			DoRedraw( Dialog, &Rect, FTP_GET, GF->Global );
		}
/* FTP_PUT --------------------------------------------------------------------*/
		if( Obj == FTP_PUT )
		{
			Msg[0] = GemFtp_Put;
			Msg[1] = GF->Global[2];
			Msg[2] = 0;
			MT_appl_write( GF->Global[2], 16, Msg, GF->Global );
			DialogTree[FTP_PUT].ob_state &= ~SELECTED;
			DoRedraw( Dialog, &Rect, FTP_PUT, GF->Global );
		}
/* FTP_MV ---------------------------------------------------------------------*/
		if( Obj == FTP_MV )
		{
			Msg[0] = GemFtp_Mv;
			Msg[1] = GF->Global[2];
			Msg[2] = 0;
			MT_appl_write( GF->Global[2], 16, Msg, GF->Global );
			DialogTree[FTP_MV].ob_state &= ~SELECTED;
			DoRedraw( Dialog, &Rect, FTP_MV, GF->Global );
		}
/* FTP_RM ---------------------------------------------------------------------*/
		if( Obj == FTP_RM )
		{
			Msg[0] = GemFtp_Rm;
			Msg[1] = GF->Global[2];
			Msg[2] = 0;
			MT_appl_write( GF->Global[2], 16, Msg, GF->Global );
			DialogTree[FTP_RM].ob_state &= ~SELECTED;
			DoRedraw( Dialog, &Rect, FTP_RM, GF->Global );
		}
/* FTP_MKDIR ------------------------------------------------------------------*/
		if( Obj == FTP_MKDIR )
		{
			Msg[0] = GemFtp_Mkdir;
			Msg[1] = GF->Global[2];
			Msg[2] = 0;
			MT_appl_write( GF->Global[2], 16, Msg, GF->Global );
			DialogTree[FTP_MKDIR].ob_state &= ~SELECTED;
			DoRedraw( Dialog, &Rect, FTP_MKDIR, GF->Global );
		}
/* FTP_RMDIR ------------------------------------------------------------------*/
		if( Obj == FTP_RMDIR )
		{
			Msg[0] = GemFtp_Rmdir;
			Msg[1] = GF->Global[2];
			Msg[2] = 0;
			MT_appl_write( GF->Global[2], 16, Msg, GF->Global );
			DialogTree[FTP_RMDIR].ob_state &= ~SELECTED;
			DoRedraw( Dialog, &Rect, FTP_RMDIR, GF->Global );
		}
/* FTP_CD ---------------------------------------------------------------------*/
		if( Obj == FTP_CD )
		{
			Msg[0] = GemFtp_Cd;
			Msg[1] = GF->Global[2];
			Msg[2] = 0;
			MT_appl_write( GF->Global[2], 16, Msg, GF->Global );
			DialogTree[FTP_CD].ob_state &= ~SELECTED;
			DoRedraw( Dialog, &Rect, FTP_CD, GF->Global );
		}
/* FTP_CHMOD ------------------------------------------------------------------*/
		if( Obj == FTP_CHMOD )
		{
			Msg[0] = GemFtp_Chmod;
			Msg[1] = GF->Global[2];
			Msg[2] = 0;
			MT_appl_write( GF->Global[2], 16, Msg, GF->Global );
			DialogTree[FTP_CHMOD].ob_state &= ~SELECTED;
			DoRedraw( Dialog, &Rect, FTP_CHMOD, GF->Global );
		}
/* FTP_CLOSER -----------------------------------------------------------------*/
		if( Obj == FTP_CLOSER )
		{
			if( Clicks == 2 )
				Msg[0] = GemFtp_CdRoot;
			else
				Msg[0] = GemFtp_Cdup;
			Msg[1] = GF->Global[2];
			Msg[2] = 0;
			MT_appl_write( GF->Global[2], 16, Msg, GF->Global );
			DialogTree[FTP_CLOSER].ob_state &= ~SELECTED;
			DoRedraw( Dialog, &Rect, FTP_CLOSER, GF->Global );
		}
/* FTP_SLCT_ALL ---------------------------------------------------------------*/
		if( Obj == FTP_SLCT_ALL )
		{
			STR_ITEM	*Item;
			Item = GF->FtpList;
			while( Item )
			{
				Item->selected = 1;
				Item = Item->next;
			}
			MT_lbox_update( GF->FtpListBox, &Rect, GF->Global );
			DialogTree[FTP_SLCT_ALL].ob_state &= ~SELECTED;
			DoRedraw( Dialog, &Rect, FTP_SLCT_ALL, GF->Global );
		}
/* FTP_SLCT_NON ---------------------------------------------------------------*/
		if( Obj == FTP_SLCT_NON )
		{
			STR_ITEM	*Item;
			Item = GF->FtpList;
			while( Item )
			{
				Item->selected = 0;
				Item = Item->next;
			}
			MT_lbox_update( GF->FtpListBox, &Rect, GF->Global );
			DialogTree[FTP_SLCT_NON].ob_state &= ~SELECTED;
			DoRedraw( Dialog, &Rect, FTP_SLCT_NON, GF->Global );
		}

		if( Obj == FTP_W_SIZER )
		{
			WORD		WinHandle = MT_wdlg_get_handle( Dialog, GF->Global );
			WORD		HMin, WMin, x ,y;
			GRECT		WinRect;
			MT_wind_update( BEG_MCTRL, GF->Global );
			MT_graf_mouse( 258, NULL, GF->Global );
			MT_graf_mouse( FLAT_HAND, NULL, GF->Global );
			MT_wind_get_grect( WinHandle, WF_CURRXYWH, &WinRect, GF->Global );
			MT_objc_offset( DialogTree, ROOT, &x, &y, GF->Global );
			WMin = FtpWinMinW * PwChar + x - WinRect.g_x;
			HMin = FtpWinMinH * PhChar - PhChar/2 + y - WinRect.g_y;
			MT_graf_rubberbox( WinRect.g_x, WinRect.g_y, WMin, HMin, &WinRect.g_w, &WinRect.g_h, GF->Global );
			SetFtpSize( Dialog, &WinRect, GF );
			{
				GRECT	Rect;
				MT_wind_get_grect( MT_wdlg_get_handle( GF->FtpDialog, GF->Global ), WF_CURRXYWH, &Rect, GF->Global );
				SetFtpPos( GF->nFtpWin, &Rect );
			}			
			MT_graf_mouse( 259, NULL, GF->Global );
			MT_wind_update( END_MCTRL, GF->Global );
		}
		
#ifdef	V110
		if( Obj == FTP_URL )
		{
			WORD	Pxy[10], dx, dy, Msg[8];
			GRECT	Rect;
			EVNTDATA Ev, EvO;
			MT_graf_mkstate( &Ev, GF->Global );
			MT_wind_update( BEG_MCTRL, GF->Global );
			MT_graf_mouse( 258, NULL, GF->Global );
			MT_graf_mouse( FLAT_HAND, NULL, GF->Global );
			MT_wind_get_grect( 0, WF_WORKXYWH, &Rect, GF->Global );
			Pxy[0] = Rect.g_x; Pxy[1] = Rect.g_y;
			Pxy[2] = Pxy[0] + Rect.g_w; Pxy[3] = Pxy[2] + Rect.g_h;
			vs_clip( GF->VdiHandle, 0, Pxy );

			MT_objc_offset( DialogTree, FTP_URL, &Pxy[0], &Pxy[1], GF->Global );
			Pxy[2] = Pxy[0] + DialogTree[FTP_URL].ob_width; Pxy[3] = Pxy[1];
			Pxy[4] = Pxy[2]; Pxy[5] = Pxy[3] + DialogTree[FTP_URL].ob_height;
			Pxy[6] = Pxy[0]; Pxy[7] = Pxy[5];
			Pxy[8] = Pxy[0]; Pxy[9] = Pxy[1];
			vsl_udsty( GF->VdiHandle, 0xaaaa );
			vsl_type( GF->VdiHandle, 7 );
			vswr_mode( GF->VdiHandle, MD_XOR );
			MT_graf_mouse( M_OFF, NULL, GF->Global );
			v_pline( GF->VdiHandle, 5, Pxy );
			MT_graf_mouse( M_ON, NULL, GF->Global );
			EvO.x = Ev.x; EvO.y = Ev.y;
			do
			{
				dx = Ev.x - EvO.x; dy = Ev.y - EvO.y;
				if( dx || dy )
				{
					MT_graf_mouse( M_OFF, NULL, GF->Global );
					v_pline( GF->VdiHandle, 5, Pxy );
					Pxy[0] += dx; Pxy[2] += dx; Pxy[4] += dx; Pxy[6] += dx; Pxy[8] += dx;
					Pxy[1] += dy; Pxy[3] += dy; Pxy[5] += dy; Pxy[7] += dy; Pxy[9] += dy;
					v_pline( GF->VdiHandle, 5, Pxy );
					MT_graf_mouse( M_ON, NULL, GF->Global );
					EvO.x = Ev.x; EvO.y = Ev.y;
				}
				MT_graf_mkstate( &Ev, GF->Global );
			}
			while( Ev.bstate & 1 );
			MT_graf_mouse( M_OFF, NULL, GF->Global );
			v_pline( GF->VdiHandle, 5, Pxy );
			MT_graf_mouse( M_ON, NULL, GF->Global );
			MT_graf_mouse( 259, NULL, GF->Global );
			MT_wind_update( END_MCTRL, GF->Global );
			
			{
/*				BYTE	*Urls = malloc( strlen( GF->Url ) + 2 );
				strcpy( Urls, GF->Url );
				Urls[ strlen( Urls ) + 1 ] = 0;	*/
				BYTE	*Urls = MakeFtpUrl( GF->Session.Host, GF->Session.Port, GF->Session.Uid, GF->Session.Pwd, GF->Session.Dir );
				Msg[0] = DragDropUrl;
				Msg[1] = GF->Global[2];
				Msg[2] = 0;
				Msg[3] = Ev.x;
				Msg[4] = Ev.y;
				Msg[5] = Ev.kstate;
				*(BYTE **) &( Msg[6] ) = Urls;
			}
			MT_appl_write( GF->Global[2], 16, Msg, GF->Global );
		}
#endif		
	}
	return( 1 );
}

void	SetFtpSize( DIALOG *Dialog, GRECT *WinRect, GemFtp *GF )
{
	WORD		Dx, Dy, i, NH, NV;
	WORD		FVa = 0, FVb = 0, Bb = 0;
	GRECT		TreeRect, Rect;
	OBJECT	*DialogTree;

	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, GF->Global );

	MT_wind_calc( WC_WORK, NAME + MOVER + CLOSER + FULLER + ICONIFIER + INFO, WinRect, &TreeRect, GF->Global );
	TreeRect.g_w = ( WORD ) ( floor((( double ) TreeRect.g_w + PwChar / 2 ) / (( double ) PwChar ) ) * (( double ) PwChar ));
	TreeRect.g_h = ( WORD ) ( floor((( double ) TreeRect.g_h + PhChar / 2 ) / (( double ) PhChar ) ) * (( double ) PhChar )) - PhChar/2;
	if( TreeRect.g_w < FtpWinMinW * PwChar )
		TreeRect.g_w = FtpWinMinW * PwChar;
	if( TreeRect.g_w > FtpWinMaxW * PwChar )
		TreeRect.g_w = FtpWinMaxW * PwChar;
	if( TreeRect.g_h < FtpWinMinH * PhChar - PhChar/2 )
		TreeRect.g_h = FtpWinMinH * PhChar - PhChar/2;
	if( TreeRect.g_h > FtpWinMaxH * PhChar - PhChar/2 )
		TreeRect.g_h = FtpWinMaxH * PhChar - PhChar/2;
	Dx = TreeRect.g_w - DialogTree->ob_width;
	Dy = TreeRect.g_h - DialogTree->ob_height;
	DialogTree->ob_width = TreeRect.g_w;
	DialogTree->ob_height = TreeRect.g_h;
	DialogTree[FTP_BUTTON_BOX].ob_x += Dx;
	DialogTree[FTP_BUTTON_BOX].ob_height += Dy;
	DialogTree[FTP_DIR_BOX].ob_width += Dx;
	DialogTree[FTP_DIR_BOX].ob_height += Dy;
	DialogTree[FTP_URL].ob_y += Dy;
	DialogTree[FTP_ICON_BOX].ob_width += Dx;
	DialogTree[FTP_ICON_BOX].ob_height += Dy;
	DialogTree[FTP_DIR_PATH].ob_width += Dx;
	DialogTree[FTP_SLCT_ALL_BOX].ob_x += Dx;
	DialogTree[FTP_SLCT_NON_BOX].ob_x += Dx;
	DialogTree[FTP_DIR_UP].ob_x += Dx;
	DialogTree[FTP_DIR_SL_V].ob_height = 0;
	DialogTree[FTP_DIR_BACK_V].ob_x += Dx;
	DialogTree[FTP_DIR_BACK_V].ob_height += Dy;
	DialogTree[FTP_DIR_DOWN].ob_x += Dx;
	DialogTree[FTP_DIR_DOWN].ob_y += Dy;
	DialogTree[FTP_DIR_LEFT].ob_y += Dy;
	DialogTree[FTP_DIR_SL_H].ob_width = 0;
	DialogTree[FTP_DIR_BACK_H].ob_width += Dx;
	DialogTree[FTP_DIR_BACK_H].ob_y += Dy;
	DialogTree[FTP_DIR_RIGHT].ob_x += Dx;
	DialogTree[FTP_DIR_RIGHT].ob_y += Dy;
	if( GF->FtpListBox )
	{
		FVa = MT_lbox_get_afirst( GF->FtpListBox, GF->Global );
		FVb = MT_lbox_get_bfirst( GF->FtpListBox, GF->Global );
		Bb = MT_lbox_get_bentries( GF->FtpListBox, GF->Global );
		MT_lbox_delete( GF->FtpListBox, GF->Global );
	}
	NH = DialogTree[FTP_DIR_BOX].ob_width / PwChar;
	if( NH > NO_FTP_DIR_H )
		NH = NO_FTP_DIR_H;
	NV = DialogTree[FTP_DIR_BOX].ob_height / PhChar;
	if( NV > NO_FTP_DIR_V )
		NV = NO_FTP_DIR_V;
	for( i = 0; i < NO_FTP_DIR_V; i++ )
	{
		if( i >= NV )
		{
			DialogTree[FtpDirObjs[i]].ob_flags |= HIDETREE;
			DialogTree[FtpDirIcons[i]].ob_flags |= HIDETREE;
		}
		else
		{
			DialogTree[FtpDirObjs[i]].ob_flags &= ~HIDETREE;
			DialogTree[FtpDirIcons[i]].ob_flags &= ~HIDETREE;
		}
		DialogTree[FtpDirObjs[i]].ob_width += Dx;
	}
	GF->FtpListBox = MT_lbox_create( DialogTree, 
			SlctFtpItem, SetFtpItem, (LBOX_ITEM *) GF->FtpList,
			NV, FVa, FtpDirCtrl, FtpDirObjs, 
			LBOX_VERT + LBOX_AUTO + LBOX_AUTOSLCT + LBOX_REAL + LBOX_TOGGLE + LBOX_SHFT + LBOX_2SLDRS, 
			40, ( void * ) GF, Dialog, NH, FVb, Bb, 40, GF->Global );
	DialogTree[FTP_W_SIZER].ob_x += Dx;
	DialogTree[FTP_W_SIZER].ob_y += Dy;	
	MT_wdlg_set_size( Dialog, &TreeRect, GF->Global );
	DoRedraw( Dialog, &TreeRect, ROOT, GF->Global );
}

/*----------------------------------------------------------------------------------------*/ 
/* SlctFtpItem                                                                             */
/*----------------------------------------------------------------------------------------*/ 
void	cdecl	SlctFtpItem( LIST_BOX *Box, OBJECT *DialogTree, LBOX_ITEM *SlctItem, void *UD, WORD ObjIndex, WORD LastState )
{
	GemFtp 	*GF = ( GemFtp * ) UD;
	EVNTDATA Ev, EvO;
	MT_graf_mkstate( &Ev, GF->Global );
	if( Ev.bstate & 1 && SlctItem->selected )
	{
		WORD		x, y, dx, dy;
		WORD		*Pxy, nSlct = 0, Slct, i, j, WinHandle;
		STR_ITEM	*Item = GF->FtpList;
		GRECT		Rect;
		i = 0;
		while( Item )
		{
			if( Item == ( STR_ITEM * ) SlctItem )
			{
				Slct = i;
			}
			if( Item->selected )
				nSlct++;
			Item = Item->next;
			i++;
		}
		Pxy = malloc( nSlct * 10 * sizeof( WORD ));
		if( !Pxy )
			return;

		MT_wind_update( BEG_MCTRL, GF->Global );
		MT_graf_mouse( 258, NULL, GF->Global );
		MT_graf_mouse( FLAT_HAND, NULL, GF->Global );

		MT_wind_get_grect( 0, WF_WORKXYWH, &Rect, GF->Global );
		Pxy[0] = Rect.g_x; Pxy[1] = Rect.g_y;
		Pxy[2] = Pxy[0] + Rect.g_w; Pxy[3] = Pxy[2] + Rect.g_h;
		vs_clip( GF->VdiHandle, 0, Pxy );

		MT_objc_offset( DialogTree, ObjIndex, &x, &y, GF->Global );
		vsl_udsty( GF->VdiHandle, 0xaaaa );
		vsl_type( GF->VdiHandle, 7 );
		vswr_mode( GF->VdiHandle, MD_XOR );

		MT_graf_mouse( M_OFF, NULL, GF->Global );
		j = 0; Item = GF->FtpList;
		for( i = 0; i < nSlct; i++ )
		{
			while( !( Item->selected ))
			{
				j++;
				Item = Item->next;
			}
			Pxy[10*i] = x - DialogTree[FTP_ICON_0].ob_width; Pxy[10*i + 1] = y + ( j - Slct ) * DialogTree[ObjIndex].ob_height;
			Pxy[10*i + 2] = x + DialogTree[ObjIndex].ob_width; Pxy[10*i + 3] = Pxy[10*i + 1];
			Pxy[10*i + 4] = Pxy[10*i + 2]; Pxy[10*i + 5] = Pxy[10*i + 3] + DialogTree[ObjIndex].ob_height;
			Pxy[10*i + 6] = Pxy[10*i]; Pxy[10*i + 7] = Pxy[10*i + 5];
			Pxy[10*i + 8] = Pxy[10*i]; Pxy[10*i + 9] = Pxy[10*i + 1];
			v_pline( GF->VdiHandle, 5, &Pxy[10*i]);
			Item = Item->next;
			j++;
		}
		MT_graf_mouse( M_ON, NULL, GF->Global );
		EvO.x = Ev.x; EvO.y = Ev.y;
		do
		{
			dx = Ev.x - EvO.x; dy = Ev.y - EvO.y;
			if( dx || dy )
			{
				MT_graf_mouse( M_OFF, NULL, GF->Global );
				for( i = 0; i < nSlct; i++ )
					v_pline( GF->VdiHandle, 5, &Pxy[10*i]);
				for( i = 0; i < nSlct; i++ )
				{
					for( j = 0; j < 10; j += 2 )
					{
						Pxy[10*i + j] += dx; Pxy[10*i + j+1] += dy;
					}
					v_pline( GF->VdiHandle, 5, &Pxy[10*i]);
				}
				MT_graf_mouse( M_ON, NULL, GF->Global );
				EvO.x = Ev.x; EvO.y = Ev.y;
			}
			MT_graf_mkstate( &Ev, GF->Global );
		}
		while( Ev.bstate & 1 );
		MT_graf_mouse( M_OFF, NULL, GF->Global );
		for( i = 0; i < nSlct; i++ )
			v_pline( GF->VdiHandle, 5, &Pxy[10*i]);
		MT_graf_mouse( M_ON, NULL, GF->Global );

		if(( WinHandle = MT_wind_find( Ev.x, Ev.y, GF->Global )) != -1 )
		{
			WORD	w1, w2, w3, w4, Msg[8];

			MT_wind_get( WinHandle, WF_OWNER, &w1, &w2, &w3, &w4, GF->Global );
			Msg[0] = AV_WHAT_IZIT;
			Msg[1] = GF->Global[2];
			Msg[2] = 0;
			Msg[3] = Ev.x;
			Msg[4] = Ev.y;
			MT_appl_write( AvAppId, 16, Msg, GF->Global );
		}

		MT_graf_mouse( 259, NULL, GF->Global );
		MT_wind_update( END_MCTRL, GF->Global );
		free( Pxy );
	}

}

WORD cdecl	SetFtpItem( LIST_BOX *Box, OBJECT *Tree, LBOX_ITEM *Item, WORD Index, void *UD, GRECT *Rect, WORD Offset )
{
	BYTE		*ptext;
	BYTE		*str;
	GemFtp 	*GF = ( GemFtp * ) UD;
	WORD		IconObj = 0;
	RSHDR 	*Rsh;
	OBJECT	**TreeAddr;

	Rsh = *((RSHDR **)( &GF->Global[7] ));	
	TreeAddr = (OBJECT **)(((UBYTE *)Rsh) + Rsh->rsh_trindex);

	ptext = Tree[Index].ob_spec.tedinfo->te_ptext;
	
	while( FtpDirObjs[IconObj] != Index )
		IconObj++;

	if( Item )
	{
		if( strcmp( "", ((STR_ITEM *) Item)->str ))
			if( Item->selected )
				Tree[Index].ob_state |= SELECTED;
			else
				Tree[Index].ob_state &= ~SELECTED;
		else
			Tree[Index].ob_state &= ~SELECTED;
			
		str = ((STR_ITEM *)Item)->str;

		if( str[1] != ' ' )
			return( Index );

		if( Item->selected )
			Tree[FtpDirIcons[IconObj]].ob_state |= SELECTED;
		else
			Tree[FtpDirIcons[IconObj]].ob_state &= ~SELECTED;
		if( *str == 'd' )
			Tree[FtpDirIcons[IconObj]].ob_spec.ciconblk = TreeAddr[ICONS][ICON_DIR].ob_spec.ciconblk;
		if( *str == '-' )
			Tree[FtpDirIcons[IconObj]].ob_spec.ciconblk = TreeAddr[ICONS][ICON_FILE].ob_spec.ciconblk;
		if( *str == 'l' )
			Tree[FtpDirIcons[IconObj]].ob_spec.ciconblk = TreeAddr[ICONS][ICON_LINK].ob_spec.ciconblk;
		if( Tree[FtpDirIcons[IconObj]].ob_flags & HIDETREE )
			Tree[FtpDirIcons[IconObj]].ob_flags &= ~HIDETREE;
		
		if( Rect )
			DoRedraw( GF->FtpDialog, Rect, FtpDirIcons[IconObj], GF->Global );
		else
		{
			GRECT		R;
			OBJECT	*T;
			MT_wdlg_get_tree( GF->FtpDialog, &T, &R, GF->Global );
			DoRedraw( GF->FtpDialog, &R, FtpDirIcons[IconObj], GF->Global );
		}

		str += 2;
		if( Offset <= strlen( str ))
		{
			str += Offset;
			
			while( *ptext && *str )
				*ptext++ = *str++;
		}
	}
	else
	{
		Tree[FtpDirIcons[IconObj]].ob_flags |= HIDETREE;
		Tree[Index].ob_state &= ~SELECTED;
	}
	
	while( *ptext )
		*ptext++ = ' ';
	
	return( Index );
}


/*----------------------------------------------------------------------------------------*/ 
/* HandleSeCancelDialog                                                                   */
/*----------------------------------------------------------------------------------------*/ 
WORD cdecl	HandleSeCancelDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD )
{
	OBJECT	*DialogTree;
	GRECT		Rect;

	GemFtp 	*GF;
	GF = (GemFtp *) UD;

	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, GF->Global );

	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_INIT:
			{
				DialogTree[SE_CANCEL_YES].ob_state &= ~SELECTED;
				DialogTree[SE_CANCEL_NO].ob_state &= ~SELECTED;
				break;
			}
			case	HNDL_MESG:
			{
				if( Events->msg[0] == WM_ICONIFY )
				{
					RSHDR 	*Rsh;
					OBJECT	**TreeAddr;
					Rsh = *((RSHDR **)( &(GF->Global[7] )));	
					TreeAddr = (OBJECT **)(((UBYTE *)Rsh) + Rsh->rsh_trindex);
					if( !isIconifiedWindow( MT_wdlg_get_handle( Dialog, GF->Global )))
					{
						DialogTree = malloc( 2 * sizeof( OBJECT ));
						if( !DialogTree )
						{
							MemErr( "GemFtp" );
							return( 0 );
						}
						memcpy( DialogTree, TreeAddr[ICONIFY], 2 * sizeof( OBJECT ));
						MT_wdlg_set_iconify( Dialog, ( GRECT *) &( Events->msg[4] ), NULL, DialogTree, ICONIFY_ICON, GF->Global );
						IconifyWindow( MT_wdlg_get_handle( Dialog, GF->Global ));
					}
					else
						MT_wind_set_grect( MT_wdlg_get_handle( Dialog, GF->Global ), WF_CURRXYWH, ( GRECT *) &( Events->msg[4] ), GF->Global );
				}
				if( Events->msg[0] == WM_UNICONIFY )
				{
					RSHDR 	*Rsh;
					OBJECT	**TreeAddr;
					Rsh = *((RSHDR **)( &(GF->Global[7] )));
					TreeAddr = (OBJECT **)(((UBYTE *)Rsh) + Rsh->rsh_trindex);
					MT_wdlg_set_uniconify( Dialog, ( GRECT *) &( Events->msg[4] ), NULL, TreeAddr[FTP], GF->Global );
					UnIconifyWindow( MT_wdlg_get_handle( Dialog, GF->Global ));
					free( DialogTree );
				}
				if( Events->msg[0] == WM_ALLICONIFY )
				{
					WORD	Msg[8];
					Msg[0] = WM_ALLICONIFY;
					Msg[1] = GF->Global[2];
					Msg[2] = 0;
					Msg[3] = 0;
					Msg[4] = Events->msg[4]; Msg[5] = Events->msg[5]; Msg[6] = Events->msg[6];	Msg[7] = Events->msg[7];
					MT_appl_write( GF->Global[2], 16, Msg, GF->Global );
				}
				break;
			}
			case	HNDL_CLSD:
				return( 0 );
		}
	}
	else
	{
		Obj &= 0x7fff;
		switch( Obj )
		{
			case	SE_CANCEL_YES:
			{
				WORD	Msg[8];
				Msg[0] = GemFtp_Shutdown;
				Msg[1] = GF->Global[2];
				Msg[2] = 0;
				MT_appl_write( GF->Global[2], 16, Msg, GF->Global );
				return( 0 );
			}
			case	SE_CANCEL_NO:
			{
				return( 0 );
			}
		}

	}
	return( 1 );
}

/*----------------------------------------------------------------------------------------*/ 
/* HandleTrDialog                                                                         */
/*----------------------------------------------------------------------------------------*/ 
WORD	cdecl	HandleTrDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD )
{
	OBJECT	*DialogTree;
	GRECT		Rect;
	WORD 		*Global;
	Global = ( WORD * ) UD;

	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );

	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_INIT:
			{
				strcpy( DialogTree[TR_FILE].ob_spec.tedinfo->te_ptext, "" );
				strcpy( DialogTree[TR_PATH].ob_spec.tedinfo->te_ptext, "" );
				strcpy( DialogTree[TR_SIZE_IS].ob_spec.tedinfo->te_ptext, "-" );
				sprintf( DialogTree[TR_N].ob_spec.tedinfo->te_ptext, "%i", 0 );
				sprintf( DialogTree[TR_SIZE].ob_spec.tedinfo->te_ptext, "%i", 0 );
				strcpy( DialogTree[TR_SIZE_IS].ob_spec.tedinfo->te_ptext, "-" );
				sprintf( DialogTree[TR_SIZE_ALL].ob_spec.tedinfo->te_ptext, "%i", 0 );
				strcpy( DialogTree[TR_SIZE_ALL_IS].ob_spec.tedinfo->te_ptext, "-" );
				strcpy( DialogTree[TR_RATE].ob_spec.tedinfo->te_ptext, "-" );
				strcpy( DialogTree[TR_RATE_ALL].ob_spec.tedinfo->te_ptext, "-" );
				strcpy( DialogTree[TR_TIME].ob_spec.tedinfo->te_ptext, "00:00:00" );
				strcpy( DialogTree[TR_TIME_ALL].ob_spec.tedinfo->te_ptext, "00:00:00" );
				strcpy( DialogTree[TR_TIME_EST].ob_spec.tedinfo->te_ptext, "--:--:--" );
				strcpy( DialogTree[TR_TIME_ALL_EST].ob_spec.tedinfo->te_ptext, "--:--:--" );
				DialogTree[TR_SL].ob_width = 0;
				DialogTree[TR_SL_ALL].ob_width = 0;
				break;
			}
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
					RSHDR 	*Rsh;
					OBJECT	**TreeAddr;
					Rsh = *((RSHDR **)( &Global[7] ));
					TreeAddr = (OBJECT **)(((UBYTE *)Rsh) + Rsh->rsh_trindex);
					if( !isIconifiedWindow( MT_wdlg_get_handle( Dialog, Global )))
					{
						DialogTree = malloc( 2 * sizeof( OBJECT ));
						if( !DialogTree )
						{
							MemErr( "GemFtp" );
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
					RSHDR 	*Rsh;
					OBJECT	**TreeAddr;
					Rsh = *((RSHDR **)( &Global[7] ));	
					TreeAddr = (OBJECT **)(((UBYTE *)Rsh) + Rsh->rsh_trindex);
					MT_wdlg_set_uniconify( Dialog, ( GRECT *) &( Events->msg[4] ), NULL, TreeAddr[TR], Global );
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
			case	HNDL_CLSD:
			{
				if( Events->msg[1] != Global[2] )
				{
					WORD	Msg[8];
					Msg[0] = GemFtp_Close_Transfer;
					Msg[1] = Global[2];
					Msg[2] = 0;
					MT_appl_write( Global[2], 16, Msg, Global );
					return( 1 );
				}
				else
					return( 0 );
			}
		}
	}
	else
	{
		Obj &= 0x7fff;
		switch( Obj )
		{
		}

	}
	return( 1 );
}
/*----------------------------------------------------------------------------------------*/ 
/* TrDialogHide(): Anzeige fÅr mehrere Dateien im Transfer-Dialog verstecken oder zeigen  */
/*----------------------------------------------------------------------------------------*/ 
void	TrDialogHide( OBJECT *DialogTree, WORD	F )
{
	if( F )
	{
		DialogTree[TR_HIDE_N].ob_flags &= ~HIDETREE;
		DialogTree[TR_N].ob_flags &= ~HIDETREE;
		DialogTree[TR_N_ALL].ob_flags &= ~HIDETREE;
		DialogTree[TR_SL_ALL].ob_flags &= ~HIDETREE;
		DialogTree[TR_BACK_ALL].ob_flags &= ~HIDETREE;
		DialogTree[TR_HIDE_ALL].ob_flags &= ~HIDETREE;
		DialogTree[TR_SIZE_ALL].ob_flags &= ~HIDETREE;
		DialogTree[TR_SIZE_ALL_IS].ob_flags &= ~HIDETREE;
		DialogTree[TR_RATE_ALL].ob_flags &= ~HIDETREE;
		DialogTree[TR_TIME_ALL].ob_flags &= ~HIDETREE;
		DialogTree[TR_TIME_ALL_EST].ob_flags &= ~HIDETREE;
	}
	else
	{
		DialogTree[TR_HIDE_N].ob_flags |= HIDETREE;
		DialogTree[TR_N].ob_flags |= HIDETREE;
		DialogTree[TR_N_ALL].ob_flags |= HIDETREE;
		DialogTree[TR_SL_ALL].ob_flags |= HIDETREE;
		DialogTree[TR_BACK_ALL].ob_flags |= HIDETREE;
		DialogTree[TR_HIDE_ALL].ob_flags |= HIDETREE;
		DialogTree[TR_SIZE_ALL].ob_flags |= HIDETREE;
		DialogTree[TR_SIZE_ALL_IS].ob_flags |= HIDETREE;
		DialogTree[TR_RATE_ALL].ob_flags |= HIDETREE;
		DialogTree[TR_TIME_ALL].ob_flags |= HIDETREE;
		DialogTree[TR_TIME_ALL_EST].ob_flags |= HIDETREE;
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* HandleTrCancelDialog                                                                   */
/*----------------------------------------------------------------------------------------*/ 
WORD cdecl	HandleTrCancelDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD )
{
	OBJECT	*DialogTree;
	GRECT		Rect;
	WORD 		*Global;
	Global = ( WORD * ) UD;

	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );

	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_INIT:
			{
				DialogTree[TR_CANCEL_YES].ob_state &= ~SELECTED;
				DialogTree[TR_CANCEL_NO].ob_state &= ~SELECTED;
				break;
			}
			case	HNDL_MESG:
			{
				if( Events->msg[0] == WM_ICONIFY )
				{
					RSHDR 	*Rsh;
					OBJECT	**TreeAddr;
					Rsh = *((RSHDR **)( &Global[7] ));	
					TreeAddr = (OBJECT **)(((UBYTE *)Rsh) + Rsh->rsh_trindex);
					if( !isIconifiedWindow( MT_wdlg_get_handle( Dialog, Global )))
					{
						DialogTree = malloc( 2 * sizeof( OBJECT ));
						if( !DialogTree )
						{
							MemErr( "GemFtp" );
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
					RSHDR 	*Rsh;
					OBJECT	**TreeAddr;
					Rsh = *((RSHDR **)( &Global[7] ));	
					TreeAddr = (OBJECT **)(((UBYTE *)Rsh) + Rsh->rsh_trindex);
					MT_wdlg_set_uniconify( Dialog, ( GRECT *) &( Events->msg[4] ), NULL, TreeAddr[TR_CANCEL], Global );
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
			case	HNDL_CLSD:
				return( 0 );
		}
	}
	else
	{
		Obj &= 0x7fff;
		switch( Obj )
		{
			case	TR_CANCEL_YES:
			{
				WORD	Msg[8];
				Msg[0] = GemFtp_Abor;
				Msg[1] = Global[2];
				Msg[2] = 0;
				MT_appl_write( Global[2], 16, Msg, Global );
				return( 0 );
			}
			case	TR_CANCEL_NO:
			{
				return( 0 );
			}
		}

	}
	return( 1 );
}

/*----------------------------------------------------------------------------------------*/ 
/* HandleDdDialog                                                                         */
/*----------------------------------------------------------------------------------------*/ 
WORD cdecl	HandleDdDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD )
{
	OBJECT	*DialogTree;
	GRECT		Rect;
	WORD 		*Global;
	Global = ( WORD * ) UD;
	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );
	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_INIT:
			{
				DialogTree[DD_CANCEL].ob_state &= ~SELECTED;
				break;
			}
			case	HNDL_MESG:
			{
				if( Events->msg[0] == WM_ICONIFY )
				{
					RSHDR 	*Rsh;
					OBJECT	**TreeAddr;
					Rsh = *((RSHDR **)( &Global[7] ));	
					TreeAddr = (OBJECT **)(((UBYTE *)Rsh) + Rsh->rsh_trindex);
					if( !isIconifiedWindow( MT_wdlg_get_handle( Dialog, Global )))
					{
						DialogTree = malloc( 2 * sizeof( OBJECT ));
						if( !DialogTree )
						{
							MemErr( "GemFtp" );
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
					RSHDR 	*Rsh;
					OBJECT	**TreeAddr;
					Rsh = *((RSHDR **)( &Global[7] ));	
					TreeAddr = (OBJECT **)(((UBYTE *)Rsh) + Rsh->rsh_trindex);
					MT_wdlg_set_uniconify( Dialog, ( GRECT *) &( Events->msg[4] ), NULL, TreeAddr[DD], Global );
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
			case	HNDL_CLSD:
				return( 0 );
		}
	}
	else
	{
		Obj &= 0x7fff;
		switch( Obj )
		{
			case	DD_CANCEL:
				return( 0 );
		}

	}
	return( 1 );
}

/*----------------------------------------------------------------------------------------*/ 
/* HandleFileDialog                                                                       */
/*----------------------------------------------------------------------------------------*/ 
DIALOG	*OpenFileDialog( OBJECT *DialogTree, BYTE *Title, XTED *Xted, char *Tmplt, char *Txt, WORD Global[15], BYTE *File, BYTE *Path )
{
	WORD		isScroll;
	if( magic_version >= 3 )
		isScroll = 1;
	else
		isScroll = 0;
	if( DialogTree[FILE_NEW].ob_spec.tedinfo->te_tmplen != EditLen + 1 )
		InitScrlted( &DialogTree[FILE_NEW], isScroll, Xted, Txt, Tmplt, EditLen);

	strcpy( DialogTree[FILE_PATH].ob_spec.free_string, Path );
	strcpy( DialogTree[FILE_OLD].ob_spec.free_string, File );
	strcpy( DialogTree[FILE_NEW].ob_spec.tedinfo->te_ptext, File );

	return( OpenDialog( DialogTree, Title, HandleFileDialog, ( void * ) Global, Global ));
}
/*----------------------------------------------------------------------------------------*/ 
/* HandleFileDialog                                                                       */
/*----------------------------------------------------------------------------------------*/ 
WORD cdecl	HandleFileDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD )
{
	OBJECT	*DialogTree;
	GRECT		Rect;
	WORD 		*Global;
	Global = (WORD *) UD;
	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );
	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_INIT:
			{
				DialogTree[FILE_CANCEL].ob_state &= ~SELECTED;
				DialogTree[FILE_REPLACE].ob_state &= ~SELECTED;
				DialogTree[FILE_REPLACE].ob_flags |= SELECTABLE;
				DialogTree[FILE_RENAME_I].ob_state |= DISABLED;
				DialogTree[FILE_RENAME].ob_state &= ~SELECTED;
				DialogTree[FILE_RENAME].ob_state |= DISABLED;
				DialogTree[FILE_RENAME].ob_flags |= SELECTABLE;
				DialogTree[FILE_REPLACE_ALL].ob_state &= ~SELECTED;
				DialogTree[FILE_REPLACE_ALL].ob_flags |= SELECTABLE;
				DialogTree[FILE_JUMPOVER_AL].ob_state &= ~SELECTED;
				DialogTree[FILE_JUMPOVER_AL].ob_flags |= SELECTABLE;
				DialogTree[FILE_JUMPOVER].ob_state &= ~SELECTED;
				DialogTree[FILE_JUMPOVER].ob_flags |= SELECTABLE;
#ifdef	RESUME
				DialogTree[FILE_RESUME].ob_state &= ~SELECTED;
				DialogTree[FILE_RESUME_ALL].ob_state &= ~SELECTED;
#else
				DialogTree[FILE_RESUME].ob_flags |= HIDETREE;
				DialogTree[FILE_RESUME_ALL].ob_flags |= HIDETREE;
#endif
				break;
			}
			case	HNDL_EDIT:
			{
				WORD	a, b;
				if( IsMenuKey( Events->key, &a, &b ))
					return( 0 );
				break;
			}
			case	HNDL_EDDN:
			{
				if( strlen( DialogTree[FILE_NEW].ob_spec.tedinfo->te_ptext ) &&
				    DialogTree[FILE_RENAME].ob_state & DISABLED )
				{
					DialogTree[FILE_RENAME_I].ob_state &= ~DISABLED;
					DialogTree[FILE_RENAME].ob_state &= ~DISABLED;
					DialogTree[FILE_RENAME].ob_flags |= SELECTABLE;
					DoRedraw( Dialog, &Rect, FILE_RENAME, Global );
				}
				if( !strlen( DialogTree[FILE_NEW].ob_spec.tedinfo->te_ptext ) &&
				    DialogTree[FILE_RENAME].ob_flags & SELECTABLE )
				{
					DialogTree[FILE_RENAME_I].ob_state |= DISABLED;
					DialogTree[FILE_RENAME].ob_state |= DISABLED;
					DialogTree[FILE_RENAME].ob_flags &= ~SELECTABLE;
					DoRedraw( Dialog, &Rect, FILE_RENAME, Global );
				}
				break;
			}
			case	HNDL_MESG:
			{
				if( Events->msg[0] == WM_ICONIFY )
				{
					RSHDR 	*Rsh;
					OBJECT	**TreeAddr;
					Rsh = *((RSHDR **)( &Global[7] ));	
					TreeAddr = (OBJECT **)(((UBYTE *)Rsh) + Rsh->rsh_trindex);
					if( !isIconifiedWindow( MT_wdlg_get_handle( Dialog, Global )))
					{
						DialogTree = malloc( 2 * sizeof( OBJECT ));
						if( !DialogTree )
						{
							MemErr( "GemFtp" );
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
					RSHDR 	*Rsh;
					OBJECT	**TreeAddr;
					Rsh = *((RSHDR **)( &Global[7] ));	
					TreeAddr = (OBJECT **)(((UBYTE *)Rsh) + Rsh->rsh_trindex);
					MT_wdlg_set_uniconify( Dialog, ( GRECT *) &( Events->msg[4] ), NULL, TreeAddr[FILE_D], Global );
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
			case	HNDL_CLSD:
				return( 0 );
		}
	}
	else
	{
		Obj &= 0x7fff;
		if( HandleIcon( &Obj, Dialog, Global ))
			return( 1 );

		if( DialogTree[Obj].ob_state & DISABLED )
		{
			DialogTree[Obj].ob_state &= ~SELECTED;
			return( 1 );
		}


		switch( Obj )
		{
			case	FILE_NEW:
			{
				if( Clicks == 2 )
				{
					WORD	Msg[8];
					DialogTree[FILE_REPLACE].ob_flags &= ~SELECTABLE;
					DialogTree[FILE_REPLACE].ob_state |= DISABLED;
					DialogTree[FILE_REPLACE_I].ob_state |= DISABLED;
					DialogTree[FILE_JUMPOVER].ob_flags &= ~SELECTABLE;
					DialogTree[FILE_JUMPOVER].ob_state |= DISABLED;
					DialogTree[FILE_JUMPOVER_I].ob_state |= DISABLED;
					DialogTree[FILE_REPLACE_ALL].ob_flags &= ~SELECTABLE;
					DialogTree[FILE_REPLACE_ALL].ob_state |= DISABLED;
					DialogTree[FILE_JUMPOVER_AL].ob_flags &= ~SELECTABLE;
					DialogTree[FILE_JUMPOVER_AL].ob_state |= DISABLED;
					DialogTree[FILE_RENAME].ob_flags &= ~SELECTABLE;
					DialogTree[FILE_RENAME].ob_state |= DISABLED;
					DialogTree[FILE_RENAME_I].ob_state |= DISABLED;
					DialogTree[FILE_CANCEL].ob_flags &= ~SELECTABLE;
					DialogTree[FILE_CANCEL].ob_state |= DISABLED;
					DialogTree[FILE_NEW].ob_flags &= ~TOUCHEXIT;				
					DialogTree[FILE_NEW].ob_state |= DISABLED;				
#ifdef	RESUME
					DialogTree[FILE_RESUME].ob_flags &= ~SELECTABLE;
					DialogTree[FILE_RESUME].ob_state |= DISABLED;
					DialogTree[FILE_RESUME_ALL].ob_flags &= ~SELECTABLE;
					DialogTree[FILE_RESUME_ALL].ob_state |= DISABLED;
					DoRedrawX( Dialog, &Rect, Global, FILE_NEW, FILE_RESUME, FILE_RESUME_ALL, FILE_REPLACE, FILE_JUMPOVER, FILE_RENAME, 
					           FILE_REPLACE_ALL, FILE_JUMPOVER_AL, FILE_CANCEL, EDRX );
#else
					DoRedrawX( Dialog, &Rect, Global, FILE_NEW, FILE_REPLACE, FILE_JUMPOVER, FILE_RENAME, 
					           FILE_REPLACE_ALL, FILE_JUMPOVER_AL, FILE_CANCEL, EDRX );
#endif
					Msg[0] = Fsel_Msg;
					Msg[1] = Global[2];
					Msg[2] = 0;
					Msg[3] = Fsel_Open;
					Msg[4] = Fsel_File_Rename;
					MT_appl_write( Global[2], 16, Msg, Global );
				}
				break;
			}
			default:	return( 0 );
		}

	}
	return( 1 );
}

/*----------------------------------------------------------------------------------------*/ 
/* WriteStatusGemFtp                                                                      */
/*----------------------------------------------------------------------------------------*/ 
void	WriteStatusGemFtp( DIALOG *Dialog, BYTE *InfoPuf, BYTE *Text, WORD Global[15] )
{
	strcpy( InfoPuf, " " );
	AppendStatusGemFtp( Dialog, InfoPuf, Text, Global );
}

/*----------------------------------------------------------------------------------------*/ 
/* AppendStatusGemFtp                                                                     */
/*----------------------------------------------------------------------------------------*/ 
void	AppendStatusGemFtp( DIALOG *Dialog, BYTE *InfoPuf, BYTE *Text, WORD Global[15] )
{
	strcat( InfoPuf, Text );
	if( Dialog )
		MT_wind_set_string( MT_wdlg_get_handle( Dialog, Global ), WF_INFO, InfoPuf, Global );
}

/*----------------------------------------------------------------------------------------*/ 
/* EnableButton                                                                           */
/*----------------------------------------------------------------------------------------*/ 
void	EnableButton( DIALOG	*Dialog, OBJECT *DialogTree, WORD Global[15] )
{
	GRECT		Rect;
	OBJECT	*D;
	WORD		i;
	MT_wdlg_get_tree( Dialog, &D, &Rect, Global );
	if( DialogTree[FTP_CLOSER].ob_state & DISABLED )
	{
		DialogTree[FTP_CLOSER].ob_state &= ~DISABLED;
		DialogTree[FTP_CLOSER].ob_flags |= SELECTABLE;
		DoRedraw( Dialog, &Rect, FTP_CLOSER_BOX, Global );
	}
	if( DialogTree[FTP_SLCT_ALL].ob_state & DISABLED )
	{
		DialogTree[FTP_SLCT_ALL].ob_state &= ~DISABLED;
		DialogTree[FTP_SLCT_ALL].ob_flags |= SELECTABLE;
		DoRedraw( Dialog, &Rect, FTP_SLCT_ALL_BOX, Global );
	}
	if( DialogTree[FTP_SLCT_NON].ob_state & DISABLED )
	{
		DialogTree[FTP_SLCT_NON].ob_state &= ~DISABLED;
		DialogTree[FTP_SLCT_NON].ob_flags |= SELECTABLE;
		DoRedraw( Dialog, &Rect, FTP_SLCT_NON_BOX, Global );
	}
	if( DialogTree[FTP_DIR_PATH].ob_state & DISABLED )
	{
		DialogTree[FTP_DIR_PATH].ob_state &= ~DISABLED;
		DialogTree[FTP_DIR_PATH].ob_flags |= TOUCHEXIT;
		DoRedraw( Dialog, &Rect, FTP_DIR_PATH, Global );
	}
	if( DialogTree[FTP_DIR_UP].ob_state & DISABLED )
	{
		DialogTree[FTP_DIR_UP].ob_state &= ~DISABLED;
		DialogTree[FTP_DIR_UP].ob_flags |= TOUCHEXIT;
		DoRedraw( Dialog, &Rect, FTP_DIR_UP, Global );
	}
	if( DialogTree[FTP_DIR_SL_V].ob_state & DISABLED )
	{
		DialogTree[FTP_DIR_SL_V].ob_state &= ~DISABLED;
		DialogTree[FTP_DIR_SL_V].ob_flags |= TOUCHEXIT;
		DoRedraw( Dialog, &Rect, FTP_DIR_SL_V, Global );
	}
	if( DialogTree[FTP_DIR_BACK_V].ob_state & DISABLED )
	{
		DialogTree[FTP_DIR_BACK_V].ob_state &= ~DISABLED;
		DialogTree[FTP_DIR_BACK_V].ob_flags |= TOUCHEXIT;
		DoRedraw( Dialog, &Rect, FTP_DIR_BACK_V, Global );
	}
	if( DialogTree[FTP_DIR_DOWN].ob_state & DISABLED )
	{
		DialogTree[FTP_DIR_DOWN].ob_state &= ~DISABLED;
		DialogTree[FTP_DIR_DOWN].ob_flags |= TOUCHEXIT;
		DoRedraw( Dialog, &Rect, FTP_DIR_DOWN, Global );
	}
	if( DialogTree[FTP_DIR_LEFT].ob_state & DISABLED )
	{
		DialogTree[FTP_DIR_LEFT].ob_state &= ~DISABLED;
		DialogTree[FTP_DIR_LEFT].ob_flags |= TOUCHEXIT;
		DoRedraw( Dialog, &Rect, FTP_DIR_LEFT, Global );
	}
	if( DialogTree[FTP_DIR_SL_H].ob_state & DISABLED )
	{
		DialogTree[FTP_DIR_SL_H].ob_state &= ~DISABLED;
		DialogTree[FTP_DIR_SL_H].ob_flags |= TOUCHEXIT;
		DoRedraw( Dialog, &Rect, FTP_DIR_SL_H, Global );
	}
	if( DialogTree[FTP_DIR_BACK_H].ob_state & DISABLED )
	{
		DialogTree[FTP_DIR_BACK_H].ob_state &= ~DISABLED;
		DialogTree[FTP_DIR_BACK_H].ob_flags |= TOUCHEXIT;
		DoRedraw( Dialog, &Rect, FTP_DIR_BACK_H, Global );
	}
	if( DialogTree[FTP_DIR_RIGHT].ob_state & DISABLED )
	{
		DialogTree[FTP_DIR_RIGHT].ob_state &= ~DISABLED;
		DialogTree[FTP_DIR_RIGHT].ob_flags |= TOUCHEXIT;
		DoRedraw( Dialog, &Rect, FTP_DIR_RIGHT, Global );
	}
	if( DialogTree[FTP_GET].ob_state & DISABLED )
	{
		DialogTree[FTP_GET_I].ob_state &= ~DISABLED;
		DialogTree[FTP_GET].ob_state &= ~DISABLED;
		DialogTree[FTP_GET].ob_flags |= SELECTABLE;
		DoRedraw( Dialog, &Rect, FTP_GET, Global );
	}
	if( DialogTree[FTP_PUT].ob_state & DISABLED )
	{
		DialogTree[FTP_PUT_I].ob_state &= ~DISABLED;
		DialogTree[FTP_PUT].ob_state &= ~DISABLED;
		DialogTree[FTP_PUT].ob_flags |= SELECTABLE;
		DoRedraw( Dialog, &Rect, FTP_PUT, Global );
	}
	if( DialogTree[FTP_MV].ob_state & DISABLED )
	{
		DialogTree[FTP_MV_I].ob_state &= ~DISABLED;
		DialogTree[FTP_MV].ob_state &= ~DISABLED;
		DialogTree[FTP_MV].ob_flags |= SELECTABLE;
		DoRedraw( Dialog, &Rect, FTP_MV, Global );
	}
	if( DialogTree[FTP_RM].ob_state & DISABLED )
	{
		DialogTree[FTP_RM_I].ob_state &= ~DISABLED;
		DialogTree[FTP_RM].ob_state &= ~DISABLED;
		DialogTree[FTP_RM].ob_flags |= SELECTABLE;
		DoRedraw( Dialog, &Rect, FTP_RM, Global );
	}
	if( DialogTree[FTP_MKDIR].ob_state & DISABLED )
	{
		DialogTree[FTP_MKDIR_I].ob_state &= ~DISABLED;
		DialogTree[FTP_MKDIR].ob_state &= ~DISABLED;
		DialogTree[FTP_MKDIR].ob_flags |= SELECTABLE;
		DoRedraw( Dialog, &Rect, FTP_MKDIR, Global );
	}
	if( DialogTree[FTP_RMDIR].ob_state & DISABLED )
	{
		DialogTree[FTP_RMDIR_I].ob_state &= ~DISABLED;
		DialogTree[FTP_RMDIR].ob_state &= ~DISABLED;
		DialogTree[FTP_RMDIR].ob_flags |= SELECTABLE;
		DoRedraw( Dialog, &Rect, FTP_RMDIR, Global );
	}
	if( DialogTree[FTP_CD].ob_state & DISABLED )
	{
		DialogTree[FTP_CD_I].ob_state &= ~DISABLED;
		DialogTree[FTP_CD].ob_state &= ~DISABLED;
		DialogTree[FTP_CD].ob_flags |= SELECTABLE;
		DoRedraw( Dialog, &Rect, FTP_CD, Global );
	}
	if( DialogTree[FTP_CHMOD].ob_state & DISABLED )
	{
		DialogTree[FTP_CHMOD_I].ob_state &= ~DISABLED;
		DialogTree[FTP_CHMOD].ob_state &= ~DISABLED;
		DialogTree[FTP_CHMOD].ob_flags |= SELECTABLE;
		DoRedraw( Dialog, &Rect, FTP_CHMOD, Global );
	}

	if( DialogTree[FTP_TT_AUTO].ob_state & DISABLED )
	{
		DialogTree[FTP_TT_AUTO].ob_flags |= SELECTABLE;
		DialogTree[FTP_TT_AUTO].ob_state &= ~DISABLED;
		DialogTree[FTP_TT_BIN].ob_flags |= SELECTABLE;
		DialogTree[FTP_TT_BIN].ob_state &= ~DISABLED;
		DialogTree[FTP_TT_ASCII].ob_flags |= SELECTABLE;
		DialogTree[FTP_TT_ASCII].ob_state &= ~DISABLED;
		DoRedrawX( Dialog, &Rect, Global, FTP_TT_AUTO, FTP_TT_BIN, FTP_TT_ASCII, EDRX );
	}

	if( DialogTree[FtpDirObjs[0]].ob_state & DISABLED )
	{
		for( i = 0; i < NO_FTP_DIR_V; i++ )
		{
			DialogTree[FtpDirObjs[i]].ob_state &= ~DISABLED;
			DialogTree[FtpDirObjs[i]].ob_flags |= TOUCHEXIT;
			DialogTree[FtpDirIcons[i]].ob_state &= ~DISABLED;
			DialogTree[FtpDirIcons[i]].ob_flags |= TOUCHEXIT;
			DoRedraw( Dialog, &Rect, FtpDirObjs[i], Global );
			DoRedraw( Dialog, &Rect, FtpDirIcons[i], Global );
		}
/*		DoRedraw( Dialog, &Rect, FTP_ICON_BOX, Global );
		DoRedraw( Dialog, &Rect, FTP_DIR_BOX, Global );	*/
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* DisableButton                                                                          */
/*----------------------------------------------------------------------------------------*/ 
void	DisableButton( DIALOG *Dialog, OBJECT *DialogTree, WORD Global[15] )
{
	GRECT		Rect;
	OBJECT	*D;
	WORD		i;
	MT_wdlg_get_tree( Dialog, &D, &Rect, Global );
	if( DialogTree[FTP_CLOSER].ob_flags & SELECTABLE )
	{
		DialogTree[FTP_CLOSER].ob_state |= DISABLED;
		DialogTree[FTP_CLOSER].ob_flags &= ~SELECTABLE;
		DoRedraw( Dialog, &Rect, FTP_CLOSER, Global );
	}
	if( DialogTree[FTP_DIR_PATH].ob_flags & TOUCHEXIT )
	{
		DialogTree[FTP_DIR_PATH].ob_state |= DISABLED;
		DialogTree[FTP_DIR_PATH].ob_flags &= ~TOUCHEXIT;
		DoRedraw( Dialog, &Rect, FTP_DIR_PATH, Global );
	}
	if( DialogTree[FTP_SLCT_ALL].ob_flags & SELECTABLE )
	{
		DialogTree[FTP_SLCT_ALL].ob_state |= DISABLED;
		DialogTree[FTP_SLCT_ALL].ob_flags &= ~SELECTABLE;
		DoRedraw( Dialog, &Rect, FTP_SLCT_ALL, Global );
	}
	if( DialogTree[FTP_SLCT_NON].ob_flags & SELECTABLE )
	{
		DialogTree[FTP_SLCT_NON].ob_state |= DISABLED;
		DialogTree[FTP_SLCT_NON].ob_flags &= ~SELECTABLE;
		DoRedraw( Dialog, &Rect, FTP_SLCT_NON, Global );
	}

	if( DialogTree[FTP_DIR_UP].ob_flags & TOUCHEXIT )
	{
		DialogTree[FTP_DIR_UP].ob_state |= DISABLED;
		DialogTree[FTP_DIR_UP].ob_flags &= ~TOUCHEXIT;
		DoRedraw( Dialog, &Rect, FTP_DIR_UP, Global );
	}
	if( DialogTree[FTP_DIR_SL_V].ob_flags & TOUCHEXIT )
	{
		DialogTree[FTP_DIR_SL_V].ob_state |= DISABLED;
		DialogTree[FTP_DIR_SL_V].ob_flags &= ~TOUCHEXIT;
		DoRedraw( Dialog, &Rect, FTP_DIR_SL_V, Global );
	}
	if( DialogTree[FTP_DIR_BACK_V].ob_flags & TOUCHEXIT )
	{
		DialogTree[FTP_DIR_BACK_V].ob_state |= DISABLED;
		DialogTree[FTP_DIR_BACK_V].ob_flags &= ~TOUCHEXIT;
		DoRedraw( Dialog, &Rect, FTP_DIR_BACK_V, Global );
	}
	if( DialogTree[FTP_DIR_DOWN].ob_flags & TOUCHEXIT )
	{
		DialogTree[FTP_DIR_DOWN].ob_state |= DISABLED;
		DialogTree[FTP_DIR_DOWN].ob_flags &= ~TOUCHEXIT;
		DoRedraw( Dialog, &Rect, FTP_DIR_DOWN, Global );
	}
	if( DialogTree[FTP_DIR_LEFT].ob_flags & TOUCHEXIT )
	{
		DialogTree[FTP_DIR_LEFT].ob_state |= DISABLED;
		DialogTree[FTP_DIR_LEFT].ob_flags &= ~TOUCHEXIT;
		DoRedraw( Dialog, &Rect, FTP_DIR_LEFT, Global );
	}
	if( DialogTree[FTP_DIR_SL_H].ob_flags & TOUCHEXIT )
	{
		DialogTree[FTP_DIR_SL_H].ob_state |= DISABLED;
		DialogTree[FTP_DIR_SL_H].ob_flags &= ~TOUCHEXIT;
		DoRedraw( Dialog, &Rect, FTP_DIR_SL_H, Global );
	}
	if( DialogTree[FTP_DIR_BACK_H].ob_flags & TOUCHEXIT )
	{
		DialogTree[FTP_DIR_BACK_H].ob_state |= DISABLED;
		DialogTree[FTP_DIR_BACK_H].ob_flags &= ~TOUCHEXIT;
		DoRedraw( Dialog, &Rect, FTP_DIR_BACK_H, Global );
	}
	if( DialogTree[FTP_DIR_RIGHT].ob_flags & TOUCHEXIT )
	{
		DialogTree[FTP_DIR_RIGHT].ob_state |= DISABLED;
		DialogTree[FTP_DIR_RIGHT].ob_flags &= ~TOUCHEXIT;
		DoRedraw( Dialog, &Rect, FTP_DIR_RIGHT, Global );
	}

	if( DialogTree[FTP_GET].ob_flags & SELECTABLE )
	{
		DialogTree[FTP_GET_I].ob_state |= DISABLED;
		DialogTree[FTP_GET].ob_state |= DISABLED;
		DialogTree[FTP_GET].ob_flags &= ~SELECTABLE;
		DoRedraw( Dialog, &Rect, FTP_GET, Global );
	}
	if( DialogTree[FTP_PUT].ob_flags & SELECTABLE )
	{
		DialogTree[FTP_PUT_I].ob_state |= DISABLED;
		DialogTree[FTP_PUT].ob_state |= DISABLED;
		DialogTree[FTP_PUT].ob_flags &= ~SELECTABLE;
		DoRedraw( Dialog, &Rect, FTP_PUT, Global );
	}
	if( DialogTree[FTP_MV].ob_flags & SELECTABLE )
	{
		DialogTree[FTP_MV_I].ob_state |= DISABLED;
		DialogTree[FTP_MV].ob_state |= DISABLED;
		DialogTree[FTP_MV].ob_flags &= ~SELECTABLE;
		DoRedraw( Dialog, &Rect, FTP_MV, Global );
	}
	if( DialogTree[FTP_RM].ob_flags & SELECTABLE )
	{
		DialogTree[FTP_RM_I].ob_state |= DISABLED;
		DialogTree[FTP_RM].ob_state |= DISABLED;
		DialogTree[FTP_RM].ob_flags &= ~SELECTABLE;
		DoRedraw( Dialog, &Rect, FTP_RM, Global );
	}
	if( DialogTree[FTP_MKDIR].ob_flags & SELECTABLE )
	{
		DialogTree[FTP_MKDIR_I].ob_state |= DISABLED;
		DialogTree[FTP_MKDIR].ob_state |= DISABLED;
		DialogTree[FTP_MKDIR].ob_flags &= ~SELECTABLE;
		DoRedraw( Dialog, &Rect, FTP_MKDIR, Global );
	}
	if( DialogTree[FTP_RMDIR].ob_flags & SELECTABLE )
	{
		DialogTree[FTP_RMDIR_I].ob_state |= DISABLED;
		DialogTree[FTP_RMDIR].ob_state |= DISABLED;
		DialogTree[FTP_RMDIR].ob_flags &= ~SELECTABLE;
		DoRedraw( Dialog, &Rect, FTP_RMDIR, Global );
	}
	if( DialogTree[FTP_CD].ob_flags & SELECTABLE )
	{
		DialogTree[FTP_CD_I].ob_state |= DISABLED;
		DialogTree[FTP_CD].ob_state |= DISABLED;
		DialogTree[FTP_CD].ob_flags &= ~SELECTABLE;
		DoRedraw( Dialog, &Rect, FTP_CD, Global );
	}
	if( DialogTree[FTP_CHMOD].ob_flags & SELECTABLE )
	{
		DialogTree[FTP_CHMOD_I].ob_state |= DISABLED;
		DialogTree[FTP_CHMOD].ob_state |= DISABLED;
		DialogTree[FTP_CHMOD].ob_flags &= ~SELECTABLE;
		DoRedraw( Dialog, &Rect, FTP_CHMOD, Global );
	}

	if( DialogTree[FTP_TT_AUTO].ob_flags & SELECTABLE )
	{
		DialogTree[FTP_TT_AUTO].ob_flags &= ~SELECTABLE;
		DialogTree[FTP_TT_AUTO].ob_state |= DISABLED;
		DialogTree[FTP_TT_BIN].ob_flags &= ~SELECTABLE;
		DialogTree[FTP_TT_BIN].ob_state |= DISABLED;
		DialogTree[FTP_TT_ASCII].ob_flags &= ~SELECTABLE;
		DialogTree[FTP_TT_ASCII].ob_state |= DISABLED;
		DoRedrawX( Dialog, &Rect, Global, FTP_TT_AUTO, FTP_TT_BIN, FTP_TT_ASCII, EDRX );
	}

	if( DialogTree[FtpDirObjs[0]].ob_flags & TOUCHEXIT )
	{
		for( i = 0; i < NO_FTP_DIR_V; i++ )
		{
			DialogTree[FtpDirObjs[i]].ob_state |= DISABLED;
			DialogTree[FtpDirObjs[i]].ob_flags &= ~TOUCHEXIT;
			DialogTree[FtpDirIcons[i]].ob_state |= DISABLED;
			DialogTree[FtpDirIcons[i]].ob_flags &= ~TOUCHEXIT;
			DoRedraw( Dialog, &Rect, FtpDirObjs[i], Global );
			DoRedraw( Dialog, &Rect, FtpDirIcons[i], Global );
		}
/*		DoRedraw( Dialog, &Rect, FTP_ICON_BOX, Global );
		DoRedraw( Dialog, &Rect, FTP_DIR_BOX, Global );	*/
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* CalcTimeRate                                                                           */
/*----------------------------------------------------------------------------------------*/ 
void	CalcTimeRateBar( time_t TStart, time_t TStartAll, time_t TAc, LONG Size, LONG SizeIs, LONG SizeAll, LONG SizeIsAll, DIALOG *Dialog, OBJECT *DialogTree, LONG FileOffset, LONG FileOffsetAll, WORD Global[15] )
{
	double	DiffT, s, m, h, e;
	GRECT		Rect;
	OBJECT	*D;
	WORD		WidthMax;
	MT_wdlg_get_tree( Dialog, &D, &Rect, Global );
	WidthMax = DialogTree[TR_BACK].ob_width;
	DiffT = (( double )( TAc - TStart )) / (( double ) CLK_TCK );
	h = floor( DiffT / 3600.0 );
	m = floor( DiffT / 60.0 - h * 60 );
	s = floor( DiffT - h * 3600.0 - m * 60.0 );
	if( TStart )
		sprintf( DialogTree[TR_TIME].ob_spec.tedinfo->te_ptext, "%02li:%02li:%02li", ( long ) h, ( long ) m, ( long ) s );
	if( Size > 0 )
		Decimal(( long )( Size / DiffT ), DialogTree[TR_RATE].ob_spec.tedinfo->te_ptext );
	else
		strcpy( DialogTree[TR_RATE].ob_spec.tedinfo->te_ptext, "-" );
	if( SizeIs > 0 && Size > 0 )
	{
		e = ( DiffT / ( double )( Size )) * ( double ) ( SizeIs - FileOffset );
		h = floor( e / 3600.0 );
		m = floor( e / 60.0 - h * 60 );
		s = floor( e - h * 3600.0 - m * 60.0 );
		sprintf( DialogTree[TR_TIME_EST].ob_spec.tedinfo->te_ptext, "%02li:%02li:%02li", ( long ) h, ( long ) m, ( long ) s );
		DialogTree[TR_SL].ob_width = ( WORD ) floor( (( double ) ( Size + FileOffset )) / ((double ) ( SizeIs )) * (( double ) WidthMax ));
		if( DialogTree[TR_SL].ob_width > WidthMax )
			DialogTree[TR_SL].ob_width = WidthMax;
	}
	else
	{
		strcpy( DialogTree[TR_TIME_EST].ob_spec.tedinfo->te_ptext, "--:--:--");
		DialogTree[TR_SL].ob_width = 0;
		DoRedraw( Dialog, &Rect, TR_BACK, Global );
	}

	DiffT = (( double )( TAc - TStartAll )) / (( double ) CLK_TCK );
	h = floor( DiffT / 3600.0 );
	m = floor( DiffT / 60.0 - h * 60 );
	s = floor( DiffT - h * 3600.0 - m * 60.0 );
	if( TStartAll )
		sprintf( DialogTree[TR_TIME_ALL].ob_spec.tedinfo->te_ptext, "%02li:%02li:%02li", ( long ) h, ( long ) m, ( long ) s );
	if( SizeAll > 0 )
		Decimal(( long )( SizeAll / DiffT ), DialogTree[TR_RATE_ALL].ob_spec.tedinfo->te_ptext );
	else
		strcpy( DialogTree[TR_RATE_ALL].ob_spec.tedinfo->te_ptext, "-" );

	if( SizeIsAll > 0 && SizeAll > 0 )
	{
		e = ( DiffT / ( double ) SizeAll ) * ( double ) ( SizeIsAll - FileOffsetAll );
		h = floor( e / 3600.0 );
		m = floor( e / 60.0 - h * 60 );
		s = floor( e - h * 3600.0 - m * 60.0 );
		sprintf( DialogTree[TR_TIME_ALL_EST].ob_spec.tedinfo->te_ptext, "%02li:%02li:%02li", ( long ) h, ( long ) m, ( long ) s );
		DialogTree[TR_SL_ALL].ob_width = ( WORD ) floor( (( double ) SizeAll + FileOffsetAll ) / ((double ) SizeIsAll ) * (( double ) WidthMax ));
		if( DialogTree[TR_SL_ALL].ob_width > WidthMax )
			DialogTree[TR_SL_ALL].ob_width = WidthMax;
	}
	else
	{
		strcpy( DialogTree[TR_TIME_ALL_EST].ob_spec.tedinfo->te_ptext, "--:--:--");
		DialogTree[TR_SL_ALL].ob_width = 0;
	}

	Decimal( Size + FileOffset, DialogTree[TR_SIZE].ob_spec.tedinfo->te_ptext );
	Decimal( SizeAll + FileOffsetAll, DialogTree[TR_SIZE_ALL].ob_spec.tedinfo->te_ptext );
	DoRedrawX( Dialog, &Rect, Global, TR_SL, TR_SL_ALL, TR_SIZE, TR_RATE, 
	           TR_TIME, TR_TIME_EST, TR_SIZE_ALL, TR_RATE_ALL, TR_TIME_ALL, 
	           TR_TIME_ALL_EST, EDRX );
}

void	Decimal( LONG Z, BYTE *Puf )
{
	BYTE	Str[10];
	WORD	Stellen, Punkte, i, j, k = 0;
	sprintf(Str, "%li", Z );
	Stellen = ( WORD )strlen( Str );
	Punkte = ( Stellen - 1 ) / 3;
	j = Stellen + Punkte;
	Puf[j + 1] = 0;
	for( i = Stellen; i >= 0; i-- )
	{
		if( k == 4 || k == 7 )
			Puf[j--] = '.';
		Puf[j--] = Str[i];
		k++;
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* Funktionen zur Speicherung der Fensterposition des FTP-Fensters                        */
/*----------------------------------------------------------------------------------------*/ 
WORD	SetnFtpWin( void )
{
	WORD 	i;
	for( i = 0; i < 32; i++ )
	{
		ULONG	x = 1;
		if( !(( x << i ) & FtpWinX ))
		{
			FtpWinX |= ( x << i );
			return( i );
		}
	}
	return( 31 );
}
void	UnSetnFtpWin( WORD i )
{
	FtpWinX &= ~( 1L << i );
}
void	SetFtpPos( WORD Id, GRECT *Pos )
{
	FtpWinPos[1L<<Id].g_x = Pos->g_x;
	FtpWinPos[1L<<Id].g_y = Pos->g_y;
	FtpWinPos[1L<<Id].g_w = Pos->g_w;
	FtpWinPos[1L<<Id].g_h = Pos->g_h;
}
WORD	GetFtpPos( WORD Id, GRECT *Pos )
{
	if( FtpWinPos[1L<<Id].g_w != -1 && FtpWinPos[1L<<Id].g_h != -1 )
	{
		Pos->g_x = FtpWinPos[1L<<Id].g_x;
		Pos->g_y = FtpWinPos[1L<<Id].g_y;
		Pos->g_w = FtpWinPos[1L<<Id].g_w;
		Pos->g_h = FtpWinPos[1L<<Id].g_h;
		return( 1 );
	}
	else
		return( 0 );
}


#ifdef	DHST
static LONG	SearchDhstCookie( void )
{
	typedef struct
	{
		LONG	id;
		LONG	value;
	} COOKIE;
	COOKIE	*search;
	
	search = *(COOKIE **) 0x5a0;
	
	if ( search )
	{
		while ( search->id )
		{
			if ( search->id == 'DHST' )
				return( search->value );
			search++;
		}		
	}
	return( 0L );
}
#endif

void	CopyFtpDirPath( GemFtp *GF )
{
	GRECT		Rect;
	OBJECT	*DialogTree;
	BYTE		*Pos = strrchr( GF->Session.Dir, '/' );

	MT_wdlg_get_tree( GF->FtpDialog, &DialogTree, &Rect, GF->Global );
	if( !Pos )
	{
		Pos = GF->Session.Dir;
	}
#ifdef	V120
#endif
	if( *( Pos + 1 ))
		Pos++;
	strcpy( DialogTree[FTP_DIR_PATH].ob_spec.tedinfo->te_ptext, Pos );
	DoRedraw( GF->FtpDialog, &Rect, FTP_DIR_PATH, GF->Global );
}

#ifdef	GEMScript
WORD	cdecl	HandleGemScriptDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD )
{
	OBJECT	*DialogTree;
	GRECT		Rect;

	GemFtp 	*GF;
	GF = (GemFtp *) UD;
	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, GF->Global );

	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_CLSD:
			{
				WORD	Msg[8];
				Msg[0] = AP_TERM;
				Msg[1] = GF->Global[2];
				Msg[2] = 0;
				MT_appl_write( GF->Global[2], 16, Msg, GF->Global );
				return( 1 );
			}
			case	HNDL_INIT:
			{
				break;
			}
			case	HNDL_MESG:
			{
				if( Events->msg[0] == WM_ICONIFY )
				{
					RSHDR 	*Rsh;
					OBJECT	**TreeAddr;
					Rsh = *((RSHDR **)( &(GF->Global[7] )));	
					TreeAddr = (OBJECT **)(((UBYTE *)Rsh) + Rsh->rsh_trindex);
					if( !isIconifiedWindow( MT_wdlg_get_handle( Dialog, GF->Global )))
					{
						DialogTree = malloc( 2 * sizeof( OBJECT ));
						if( !DialogTree )
						{
							MemErr( "GemFtp" );
							return( 0 );
						}
						memcpy( DialogTree, TreeAddr[ICONIFY], 2 * sizeof( OBJECT ));
						MT_wdlg_set_iconify( Dialog, ( GRECT *) &( Events->msg[4] ), NULL, DialogTree, ICONIFY_ICON, GF->Global );
						IconifyWindow( MT_wdlg_get_handle( Dialog, GF->Global ));
					}
					else
						MT_wind_set_grect( MT_wdlg_get_handle( Dialog, Global ), WF_CURRXYWH, ( GRECT *) &( Events->msg[4] ), GF->Global );
				}
				if( Events->msg[0] == WM_UNICONIFY )
				{
					RSHDR 	*Rsh;
					OBJECT	**TreeAddr;
					Rsh = *((RSHDR **)( &(GF->Global[7] )));	
					TreeAddr = (OBJECT **)(((UBYTE *)Rsh) + Rsh->rsh_trindex);
					MT_wdlg_set_uniconify( Dialog, ( GRECT *) &( Events->msg[4] ), NULL, TreeAddr[GS], GF->Global );
					UnIconifyWindow( MT_wdlg_get_handle( Dialog, GF->Global ));
					free( DialogTree );
				}
				if( Events->msg[0] == WM_ALLICONIFY )
				{
					WORD	Msg[8];
					Msg[0] = WM_ALLICONIFY;
					Msg[1] = GF->Global[2];
					Msg[2] = 0;
					Msg[3] = 0;
					Msg[4] = Events->msg[4]; Msg[5] = Events->msg[5]; Msg[6] = Events->msg[6];	Msg[7] = Events->msg[7];
					MT_appl_write( GF->Global[2], 16, Msg, GF->Global );
				}
				break;
			}
		}
	}
	else
	{
		if( Clicks == 2 )
			Obj |= 0x8000;
	}
	return( 1 );
}
#endif

#ifdef	V120
static void	ShortFileStrCpy( BYTE *Dest, BYTE *Source, WORD Len )
{
	if( strlen( Source ) <= Len )
		strcpy( Dest, Source );
	else
	{
		BYTE	*FilenamePos, *Pos;
		BYTE	*Filename = malloc( Len );
		BYTE	*Save = malloc( strlen( Source ) + 1 );

		if( !Save || !Filename )
		{
			strcpy( Dest, "" );
			return;
		}
		strcpy( Save, Source );
		
		strncpy( Dest, Source, 3 );
		strcpy( Dest + 3, "" );
		strcat( Dest, "...");

		Pos = Source + strlen( Source );
		FilenamePos = Pos;
		while( Pos > Source )
		{
			if( strlen( Pos ) > Len - strlen( Dest ))
				break;
			if( *Pos == '\\' || *Pos == '/' )
				FilenamePos = Pos;
			Pos--;
		}
		strcat( Dest, FilenamePos );
		free( Filename );
	}
}
#endif