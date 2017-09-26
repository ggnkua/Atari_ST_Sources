#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<TOS.H>
#include	<VDICOL.H>
#include	<MT_AES.H>
#include	<STDDEF.H>
#include	<STDLIB.H>
#include	<STRING.H>
#include	<STDIO.H>
#include	<TIME.H>
#include	<MATH.H>

#include	<atarierr.h>
#ifdef	ICONNECT
#include	<iconnect\inet.h>
#include	<iconnect\sockinit.h>
#endif

#include	"DD.h"
#include	"main.h"
#include	RSCHEADER
#include	"Fsel.h"
#include	"Irc.h"
#include	"Help.h"
#include	"IConnect.h"
#include	"Menu.h"
#include	"Rsc.h"
#include	"ExtObj\TextObj.h"
#include	"TCP.h"
#include	"WDialog.h"
#include	"Window.h"
#include	"Wirc\Func.h"
#include	"WIrc\IrcFunc.h"
#include	"Wirc\WChat.h"
#include	"WIrc\WDccData.h"

#include	"EdScroll.h"
#include	"Keytab.h"
#include	"MapKey.h"

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern WORD	Global[15];
extern OBJECT	**TreeAddr;
extern WORD	isScroll;
extern WORD	SessionCounter;
extern BYTE	*DownloadPath;

/*-----------------------------------------------------------------------------*/
/* Lokale Variablen                                                            */
/*-----------------------------------------------------------------------------*/
static XTED	Xted;
static BYTE	Tmplt[EDITLEN+1], Txt[EDITLEN+1];

typedef	struct
{
	BYTE	*Nickname;
	BYTE	*Title;
	BYTE	*Filename;

	UWORD	Port;
	ULONG	IP;
	ULONG	Size;
	ULONG Block;
	ULONG	Out;

	ULONG	Worked;
	clock_t	LastUpdate;
	clock_t	TStart;

	WORD	WinId;
	WORD	TcpAppId;
	void	*TcpMsgPuf;

	MOD_WIN	*ModWin;

	FILE	*File;
	DIALOG_DATA	*DialogData;
	IRC_SESSION	*IrcSession;
}	DCC_DATA;

#define	MODWIN_FILE_EXIST				0x0001
#define	MODWIN_CONNECTION_CLOSED	0x0002
#define	MODWIN_CLOSE_CONNECTION		0x0003

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
static void	FreeDccData( DCC_DATA *DccData );

static WORD	OpenWindow( DCC_DATA *DccData, WORD Global[15] );
static WORD cdecl	HandleDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData );
static WORD	HndlMessageDialog( void *DialogData, EVNT *Events, WORD Global[15] );
static WORD	HndlTimerDialog( void *DialogData, WORD Global[15] );
static WORD	HndlCheckDialog( void *DialogData, EVNT *Events, WORD Global[15] );
static WORD HndlClsDialog( void *DialogData, WORD Global[15] );

static WORD cdecl	HandleGetDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData );
static WORD HndlClsGetDialog( void *DialogData, WORD Global[15] );

static void	OpenAlert( DCC_DATA *DccData, WORD WinId, WORD Type );
static void CloseAlert( void *UD, WORD Button, WORD WinId, WORD Global[15] );

/*-----------------------------------------------------------------------------*/
/* FreeDccData                                                                   */
/*-----------------------------------------------------------------------------*/
static void	FreeDccData( DCC_DATA *DccData )
{
	if( DccData->Nickname )
		free( DccData->Nickname );
	if( DccData->Title )
		free( DccData->Title );
	if( DccData->Filename )
		free( DccData->Filename );
	free( DccData );
}

/*-----------------------------------------------------------------------------*/
/* OpenWindow                                                                  */
/*-----------------------------------------------------------------------------*/
static WORD	OpenWindow( DCC_DATA *DccData, WORD Global[15] )
{
	DIALOG_DATA	*DialogData = malloc( sizeof( DIALOG_DATA ));
	BYTE	Puf[128];
	GRECT	Work, Curr;

	if( !DialogData )
		return( ENSMEM );

	DccData->DialogData = DialogData;
	DialogData->Dialog = NULL;
	DialogData->HndlDdDialog = NULL;
	DialogData->HndlClsDialog = HndlClsDialog;
	DialogData->HndlMesagDialog = HndlMessageDialog;
	DialogData->HndlTimerDialog = HndlTimerDialog;
	DialogData->HndlEditDialog = NULL;
	DialogData->HndlHelpDialog = NULL;
	DialogData->HndlCheckDialog = HndlCheckDialog;
	DialogData->UserData = DccData;
	DialogData->TreeIndex = DATA;
	if(( DialogData->Tree = CopyTree( TreeAddr[DATA] )) == NULL )
	{
		free( DialogData );
		return( ENSMEM );
	}
	ShortFileStrCpy( DialogData->Tree[DATA_FILE].ob_spec.free_string, DccData->Filename, strlen( DialogData->Tree[DATA_FILE].ob_spec.free_string ));

	if( DccData )
	{
		sprintf( DialogData->Tree[DATA_SIZE].ob_spec.free_string, "%s / -", Decimal( DccData->Size, Puf ));
		sprintf( DialogData->Tree[DATA_TIME].ob_spec.free_string, "- / -" );
		DialogData->Tree[DATA_SLDR].ob_width = 0;
	}
	else
	{
		sprintf( DialogData->Tree[DATA_SIZE].ob_spec.free_string, "-" );
		sprintf( DialogData->Tree[DATA_TIME].ob_spec.free_string, "-" );
		DialogData->Tree[DATA_SLDR_BACK].ob_flags |= HIDETREE;
	}
	sprintf( DialogData->Tree[DATA_CPS].ob_spec.free_string, "-" );

	Work.g_x = -1;
	Work.g_y = -1;
	Work.g_w = DialogData->Tree[ROOT].ob_width;
	Work.g_h = DialogData->Tree[ROOT].ob_height;
	MT_wind_calc( WC_BORDER, NAME + MOVER + CLOSER + SMALLER, &Work, &Curr, Global );
	PlaceIntelligent( &Curr );
	MT_wind_calc( WC_WORK, NAME + MOVER + CLOSER + SMALLER, &Curr, &Work, Global );

	if( OpenDialogX( DccData->Title, WIN_DATA_DCC, NAME + MOVER + CLOSER + SMALLER, Work.g_x, Work.g_y, HandleDialog, DialogData, Global ) != E_OK )
	{
		FreeTree( DialogData->Tree );
		free( DialogData );
		return( ERROR );
	}

	DccData->WinId = MT_wdlg_get_handle( DialogData->Dialog, Global );
	if(( DccData->TcpAppId = Tcp( Global )) <= 0 )
		return( ERROR );
	else
	{
		WORD	Msg[8];
		Msg[0] = TCP_CMD;
		Msg[1] = Global[2];
		Msg[2] = 0;
		Msg[3] = DccData->WinId;
		Msg[4] = TCP_init;
		while( MT_appl_write( DccData->TcpAppId, 16, Msg, Global ) != 1 );
		SessionCounter++;
	}
	return( E_OK );
}
/*-----------------------------------------------------------------------------*/
/* HandleDialog                                                                */
/*-----------------------------------------------------------------------------*/
static WORD cdecl	HandleDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData )
{
	OBJECT		*DialogTree;
	GRECT			Rect;
	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );
	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_CLSD:
			{
				DCC_DATA	*DccData = ( DCC_DATA * )(( DIALOG_DATA * ) UserData )->UserData;
				if( Events->msg[4] == WIN_CLOSE_WITHOUT_DEMAND )
				{
					WORD	Msg[8];
					Msg[0] = TCP_CMD;
					Msg[1] = Global[2];
					Msg[2] = 0;
					Msg[3] = DccData->WinId;
					Msg[4] = TCP_close;
					TcpMessage( Msg, &( DccData->TcpMsgPuf ), DccData->TcpAppId, Global );
#ifdef	DRACONIS
					{
						EVNT	Evnt;
						MT_shel_write( 72, 0, DccData->TcpAppId, NULL, NULL, Global );
						Evnt.mwhich = MU_MESAG;
						Evnt.msg[0] = TCP_ACK;
						Evnt.msg[1] = DccData->TcpAppId;
						Evnt.msg[2] = 0;
						Evnt.msg[3] = DccData->WinId;
						Evnt.msg[4] = TCP_close;
						HandleWindow( &Evnt, Global );
					}
#endif					
				}
				else
				{
					BYTE	Puf[ALERT_DIALOG_MAX_LEN + 1];
					ShortFileStrCpy( Puf, DccData->Filename, ALERT_DIALOG_MAX_LEN );
					OpenAlert( DccData, AlertDialogX( 1, TreeAddr[ALERTS][ALERT_CANCEL_DCCDATA].ob_spec.free_string, DccData->Title, CloseAlert, DccData, Global, 1, Puf ), MODWIN_CLOSE_CONNECTION );
				}
				return( 1 );
			}
		}
	}
	else
	{
	}
	return( 1 );
}

/*-----------------------------------------------------------------------------*/
/* MessageWindow                                                               */
/*-----------------------------------------------------------------------------*/
static WORD	HndlMessageDialog( void *DialogData, EVNT *Events, WORD Global[15] )
{
	DCC_DATA	*DccData = ( DCC_DATA * )(( DIALOG_DATA * ) DialogData )->UserData;
	WORD		Msg[8];

	TcpMessage( NULL, &( DccData->TcpMsgPuf ), -1, Global );

	switch( Events->msg[0] )
	{
		case	THR_EXIT:
		{
			EVNT	lEvents;
			lEvents.mwhich = MU_MESAG;
			lEvents.msg[0] = TCP_ACK;
			lEvents.msg[1] = DccData->TcpAppId;
			lEvents.msg[2] = 0;
			lEvents.msg[3] = DccData->WinId;
			lEvents.msg[4] = TCP_close;
			return( HndlMessageDialog( DialogData, &lEvents, Global ));
			break;
		}
		case	TCP_CMD:
		{
			switch( Events->msg[4] )
			{
				case	TCP_closed:
					if( DccData->Worked != DccData->Size )
					{
						BYTE	Puf[ALERT_DIALOG_MAX_LEN + 1];
						ShortFileStrCpy( Puf, DccData->Filename, ALERT_DIALOG_MAX_LEN );
						OpenAlert( DccData, AlertDialogX( 1, TreeAddr[ALERTS][ALERT_ERROR_DCCDATA].ob_spec.free_string, DccData->Title, CloseAlert, DccData, Global, 1, Puf ), MODWIN_CONNECTION_CLOSED );
					}
					else
					{
						Msg[0] = TCP_CMD;
						Msg[1] = Global[2];
						Msg[2] = 0;
						Msg[3] = DccData->WinId;
						Msg[4] = TCP_close;
						TcpMessage( Msg, &( DccData->TcpMsgPuf ), DccData->TcpAppId, Global );
					}
					break;
				case	TCP_in:
				{
					OBJECT		*DialogTree;
					GRECT			Rect;
					BYTE			P1[128], P2[128];
					MT_wdlg_get_tree((( DIALOG_DATA * ) DialogData )->Dialog, &DialogTree, &Rect, Global );
					if( DccData->IrcSession )
					{
						LONG	i;
						memcpy( &i, *( BYTE ** )&( Events->msg[5] ), sizeof( ULONG ));
						Msg[0] = TCP_ACK;
						Msg[1] = Global[2];
						Msg[2] = 0;
						Msg[3] = DccData->WinId;
						Msg[4] = TCP_in;
						*( BYTE ** )&( Msg[5] ) = *( BYTE ** )&( Events->msg[5] );
						TcpMessage( Msg, &( DccData->TcpMsgPuf ), DccData->TcpAppId, Global );
						DccData->Worked = i;
						if( i == DccData->Out )
						{
							if( DccData->File )
							{
								BYTE	*Puf = malloc( DccData->Block );
								LONG	i;
								if(( i = fread( Puf, 1, DccData->Block, DccData->File )) < DccData->Block )
								{
									fclose( DccData->File );
									DccData->File = NULL;
								}
								Msg[0] = TCP_CMD;
								Msg[1] = Global[2];
								Msg[2] = 0;
								Msg[3] = DccData->WinId;
								Msg[4] = TCP_out;
								*( BYTE ** )&( Msg[5] ) = Puf;
								Msg[7] = i;
								TcpMessage( Msg, &( DccData->TcpMsgPuf ), DccData->TcpAppId, Global );
								DccData->Out += i;
							}
							else
							{
								Msg[0] = TCP_CMD;
								Msg[1] = Global[2];
								Msg[2] = 0;
								Msg[3] = DccData->WinId;
								Msg[4] = TCP_close;
								TcpMessage( Msg, &( DccData->TcpMsgPuf ), DccData->TcpAppId, Global );
							}
						}
					}
					else
					{
						if( fwrite( *( BYTE ** )&( Events->msg[5] ), 1, Events->msg[7], DccData->File ) != Events->msg[7] )
						{
							BYTE	Puf[ALERT_DIALOG_MAX_LEN + 1];
							ShortFileStrCpy( Puf, DialogTree[GET_NEW].ob_spec.tedinfo->te_ptext, ALERT_DIALOG_MAX_LEN );
							AlertDialogX( 1, TreeAddr[ALERTS][ALERT_SAVE_ERROR].ob_spec.free_string, DccData->Title, ( CLS_ALERT_DIALOG ) NULL, NULL, Global, 1, Puf );
							Msg[0] = TCP_CMD;
							Msg[1] = Global[2];
							Msg[2] = 0;
							Msg[3] = DccData->WinId;
							Msg[4] = TCP_close;
							TcpMessage( Msg, &( DccData->TcpMsgPuf ), DccData->TcpAppId, Global );
						}

						Msg[0] = TCP_ACK;
						Msg[1] = Global[2];
						Msg[2] = 0;
						Msg[3] = DccData->WinId;
						Msg[4] = TCP_in;
						*( BYTE ** )&( Msg[5] ) = *( BYTE ** )&( Events->msg[5] );
						TcpMessage( Msg, &( DccData->TcpMsgPuf ), DccData->TcpAppId, Global );
						DccData->Worked += Events->msg[7];
						Msg[0] = TCP_CMD;
						Msg[1] = Global[2];
						Msg[2] = 0;
						Msg[3] = DccData->WinId;
						Msg[4] = TCP_out;
						*( BYTE ** )&( Msg[5] ) = malloc( sizeof( ULONG ));
						memcpy( *( BYTE ** )&( Msg[5] ), &DccData->Worked, sizeof( ULONG ));
						Msg[7] = sizeof( ULONG );
						TcpMessage( Msg, &( DccData->TcpMsgPuf ), DccData->TcpAppId, Global );
					}
					if( DccData->Size )
					{
						sprintf((( DIALOG_DATA * ) DialogData )->Tree[DATA_SIZE].ob_spec.free_string, "%s / %s", Decimal( DccData->Size, P1 ), Decimal( DccData->Worked, P2 ));
						(( DIALOG_DATA * ) DialogData )->Tree[DATA_SLDR].ob_width = (( DIALOG_DATA * ) DialogData )->Tree[DATA_SLDR_BACK].ob_width * DccData->Worked / DccData->Size;
						DoRedrawX((( DIALOG_DATA * ) DialogData )->Dialog, &Rect, Global, DATA_SIZE_PARENT, DATA_SLDR, EDRX );
					}
					else
					{
						sprintf((( DIALOG_DATA * ) DialogData )->Tree[DATA_SIZE].ob_spec.free_string, "%s", Decimal( DccData->Worked, P2 ));
						DoRedraw((( DIALOG_DATA * ) DialogData )->Dialog, &Rect, DATA_SIZE_PARENT, Global );
					}
				}
				if(( clock() - DccData->LastUpdate ) / CLK_TCK >= 1 )
					HndlTimerDialog( DialogData, Global );
				break;
			}
			break;
		}
		case	TCP_ACK:
		{
			switch( Events->msg[4] )
			{
				case	TCP_init:
					Msg[0] = TCP_CMD;
					Msg[1] = Global[2];
					Msg[2] = 0;
					Msg[3] = DccData->WinId;
					Msg[4] = TCP_socket;
					TcpMessage( Msg, &( DccData->TcpMsgPuf ), DccData->TcpAppId, Global );
					break;
				case	TCP_socket:
					if( Events->msg[4] < 0 )
					{
						OpenAlert( DccData, AlertDialog( 1, TreeAddr[ALERTS][SOCKET_FAILED].ob_spec.free_string, DccData->Title, CloseAlert, DccData, Global ), MODWIN_CONNECTION_CLOSED );
						break;
					}
					else
					{
						if( DccData->IP )
						{
							Msg[0] = TCP_CMD;
							Msg[1] = Global[2];
							Msg[2] = 0;
							Msg[3] = DccData->WinId;
							Msg[4] = TCP_connect;
							*( long * )&( Msg[5] ) = DccData->IP;
							Msg[7] = DccData->Port;
							TcpMessage( Msg, &( DccData->TcpMsgPuf ), DccData->TcpAppId, Global );
						}
						else
						{
							Msg[0] = TCP_CMD;
							Msg[1] = Global[2];
							Msg[2] = 0;
							Msg[3] = DccData->WinId;
							Msg[4] = TCP_bind;
							TcpMessage( Msg, &( DccData->TcpMsgPuf ), DccData->TcpAppId, Global );
						}
					}
					break;
				case	TCP_connect:
				{
					if( Events->msg[7] == E_OK )
					{
						OBJECT		*DialogTree;
						GRECT			Rect;
						MT_wdlg_get_tree((( DIALOG_DATA * ) DialogData )->Dialog, &DialogTree, &Rect, Global );
						if( DccData->Size )
						{
							BYTE	Puf[128];
							sprintf((( DIALOG_DATA * ) DialogData )->Tree[DATA_SIZE].ob_spec.free_string, "%s / 0", Decimal( DccData->Size, Puf ));
							sprintf((( DIALOG_DATA * ) DialogData )->Tree[DATA_TIME].ob_spec.free_string, "- / 00:00:00" );
							DoRedrawX((( DIALOG_DATA * ) DialogData )->Dialog, &Rect, Global, DATA_SIZE_PARENT, DATA_TIME_PARENT, EDRX );
						}
						else
						{
							sprintf((( DIALOG_DATA * ) DialogData )->Tree[DATA_SIZE].ob_spec.free_string, "0" );
							sprintf((( DIALOG_DATA * ) DialogData )->Tree[DATA_TIME].ob_spec.free_string, "00:00:00" );
							DoRedrawX((( DIALOG_DATA * ) DialogData )->Dialog, &Rect, Global, DATA_SIZE_PARENT, DATA_TIME_PARENT, EDRX );
						}
						DccData->TStart = clock();
					}
					else
						OpenAlert( DccData, AlertDialog( 1, TreeAddr[ALERTS][CONNECT_FAILED].ob_spec.free_string, DccData->Title, CloseAlert, DccData, Global ), MODWIN_CONNECTION_CLOSED );
					break;
				}
				case	TCP_close:
				{
					EVNT	lEvents;
					SessionCounter--;
					lEvents.mwhich = MU_MESAG;
					lEvents.msg[0] = ICONNECT_ACK;
					lEvents.msg[1] = Global[2];
					lEvents.msg[2] = 0;
					lEvents.msg[3] = DccData->WinId;
					HandleIConnect( &lEvents, Global );
					return( 1 );
				}
				case	TCP_out:
				{
					free( *( BYTE ** )&( Events->msg[5] ));
					break;
				}
				case	TCP_bind:
				{
					if( Events->msg[7] > 0 )
					{
						BYTE	Puf[512];
						DccData->IP = *( long * )&( Events->msg[5] );
						DccData->Port = Events->msg[7];
						Msg[0] = TCP_CMD;
						Msg[1] = Global[2];
						Msg[2] = 0;
						Msg[3] = DccData->WinId;
						Msg[4] = TCP_accept;
						TcpMessage( Msg, &( DccData->TcpMsgPuf ), DccData->TcpAppId, Global );
						sprintf( Puf, "\001DCC SEND %s %lu %u %lu\001", ( strrchr( DccData->Filename, '\\' ) + 1 ), DccData->IP, DccData->Port, DccData->Size );
						SendMessage( DccData->IrcSession, GenerateMessage( Puf, DccData->Nickname, DccData->IrcSession, Global ), Global );
					}
					else
						OpenAlert( DccData, AlertDialog( 1, TreeAddr[ALERTS][CONNECT_FAILED].ob_spec.free_string, DccData->Title, CloseAlert, DccData, Global ), MODWIN_CONNECTION_CLOSED );
					break;
				}
				case	TCP_accept:
				{
					BYTE	Puf[128];
					OBJECT		*DialogTree;
					GRECT			Rect;
					MT_wdlg_get_tree((( DIALOG_DATA * ) DialogData )->Dialog, &DialogTree, &Rect, Global );
					DccData->TStart = clock();
					sprintf((( DIALOG_DATA * ) DialogData )->Tree[DATA_SIZE].ob_spec.free_string, "%s / 0", Decimal( DccData->Size, Puf ));
					sprintf((( DIALOG_DATA * ) DialogData )->Tree[DATA_TIME].ob_spec.free_string, "- / 00:00:00" );
					DoRedrawX((( DIALOG_DATA * ) DialogData )->Dialog, &Rect, Global, DATA_SIZE_PARENT, DATA_TIME_PARENT, EDRX );
					if(( DccData->File = fopen( DccData->Filename, "rb" )) == NULL )
					{
						BYTE	Puf[ALERT_DIALOG_MAX_LEN + 1];
						ShortFileStrCpy( Puf, DccData->Filename, ALERT_DIALOG_MAX_LEN );
						AlertDialogX( 1, TreeAddr[ALERTS][ALERT_READ_ERROR].ob_spec.free_string, DccData->Title, ( CLS_ALERT_DIALOG ) NULL, NULL, Global, 1, Puf );
					}
					else
					{
						BYTE	P1[128], P2[128];
						BYTE	*Puf = malloc( DccData->Block );
						LONG	i;
						if(( i = fread( Puf, 1, DccData->Block, DccData->File )) < DccData->Block )
						{
							fclose( DccData->File );
							DccData->File = NULL;
						}
						Msg[0] = TCP_CMD;
						Msg[1] = Global[2];
						Msg[2] = 0;
						Msg[3] = DccData->WinId;
						Msg[4] = TCP_out;
						*( BYTE ** )&( Msg[5] ) = Puf;
						Msg[7] = i;
						TcpMessage( Msg, &( DccData->TcpMsgPuf ), DccData->TcpAppId, Global );
						DccData->Out += i;
						sprintf((( DIALOG_DATA * ) DialogData )->Tree[DATA_SIZE].ob_spec.free_string, "%s / %s", Decimal( DccData->Size, P1 ), Decimal( DccData->Worked, P2 ));
						(( DIALOG_DATA * ) DialogData )->Tree[DATA_SLDR].ob_width = (( DIALOG_DATA * ) DialogData )->Tree[DATA_SLDR_BACK].ob_width * DccData->Worked / DccData->Size;
						DoRedrawX((( DIALOG_DATA * ) DialogData )->Dialog, &Rect, Global, DATA_SIZE_PARENT, DATA_SLDR, EDRX );
					}
					break;
				}
			}
			break;
		}
	}
	return( E_OK );
}

/*-----------------------------------------------------------------------------*/
/* HndlTimerDialog                                                             */
/*-----------------------------------------------------------------------------*/
static WORD	HndlTimerDialog( void *DialogData, WORD Global[15] )
{
	DCC_DATA	*DccData = ( DCC_DATA * )(( DIALOG_DATA * ) DialogData )->UserData;
	TcpMessage( NULL, &( DccData->TcpMsgPuf ), -1, Global );
	if( DccData->TStart && DccData->Worked > 0 )
	{
		OBJECT	*DialogTree;
		GRECT		Rect;
		BYTE		Puf[128];
		double	dT, h, m, s;
		clock_t	T = clock();
		
		MT_wdlg_get_tree((( DIALOG_DATA * ) DialogData )->Dialog, &DialogTree, &Rect, Global );
		dT = (( double )( T - DccData->TStart )) / (( double ) CLK_TCK );

		DccData->LastUpdate = clock();

		h = floor( dT / 3600.0 );
		m = floor( dT / 60.0 - h * 60 );
		s = floor( dT - h * 3600.0 - m * 60.0 );

		if( DccData->Size )
		{
			double	eT, eh, em, es;
			eT = (( double ) DccData->Size ) / ((( double ) DccData->Worked ) / dT );
			eh = floor( eT / 3600.0 );
			em = floor( eT / 60.0 - eh * 60 );
			es = floor( eT - eh * 3600.0 - em * 60.0 );

			sprintf((( DIALOG_DATA * ) DialogData )->Tree[DATA_TIME].ob_spec.free_string, "%02li:%02li:%02li / %02li:%02li:%02li", ( long ) eh, ( long ) em, ( long ) es, ( long ) h, ( long ) m, ( long ) s );
			DoRedraw((( DIALOG_DATA * ) DialogData )->Dialog, &Rect, DATA_TIME_PARENT, Global );
		}
		else
		{
			sprintf((( DIALOG_DATA * ) DialogData )->Tree[DATA_TIME].ob_spec.free_string, "%02li:%02li:%02li", ( long ) h, ( long ) m, ( long ) s );
			DoRedraw((( DIALOG_DATA * ) DialogData )->Dialog, &Rect, DATA_TIME_PARENT, Global );
		}
		if((( long ) dT ) > 0 )
		{
			sprintf((( DIALOG_DATA * ) DialogData )->Tree[DATA_CPS].ob_spec.free_string, "%s", Decimal( DccData->Worked / ( long ) dT, Puf ));
			DoRedraw((( DIALOG_DATA * ) DialogData )->Dialog, &Rect, DATA_CPS_PARENT, Global );
		}
	}
	return( E_OK );
}

/*-----------------------------------------------------------------------------*/
/* HndlCheckDialog                                                             */
/*-----------------------------------------------------------------------------*/
static WORD	HndlCheckDialog( void *DialogData, EVNT *Events, WORD Global[15] )
{
	DCC_DATA	*DccData = ( DCC_DATA * )(( DIALOG_DATA * ) DialogData )->UserData;
	if( DccData->ModWin )
	{
		WORD	WinId = DccData->ModWin->WinId, Ret;
		WORD	TopWinId, TopAppId, Dummy;
		MT_wind_get( 0, WF_TOP, &TopWinId, &TopAppId, &Dummy, &Dummy, Global );
		if( TopWinId == DccData->WinId )
			MT_wind_set_int( WinId, WF_TOP, 0, Global );
		if( Events->mwhich & MU_MESAG )
		{
			switch( Events->msg[0] )
			{
				case	WM_CLOSED:
					if( Events->msg[3] != WinId && Events->msg[4] != WIN_CLOSE_WITHOUT_DEMAND )
					{
						Events->mwhich &= ~MU_MESAG;
						Ret = ERROR;
					}
					break;
				case	WM_ONTOP:
				case	WM_TOPPED:
					if( Events->msg[3] != WinId && Events->msg[4] != WIN_CLOSE_WITHOUT_DEMAND )
					{
						MT_wind_set_int( WinId, WF_TOP, 0, Global );
						Events->mwhich &= ~MU_MESAG;
					}
					break;
			}
		}
		if( Events->mwhich & MU_BUTTON )
		{
			WORD	Id = MT_wind_find( Events->mx, Events->my, Global );
			if( WinId != Id )
			{
				Events->mwhich &= ~MU_BUTTON;
				MT_wind_set_int( WinId, WF_TOP, 0, Global );
			}
		}
	}
	return( E_OK );
}

/*-----------------------------------------------------------------------------*/
/* HndlClsDialog                                                               */
/*-----------------------------------------------------------------------------*/
static WORD HndlClsDialog( void *DialogData, WORD Global[15] )
{
	DCC_DATA	*DccData = ( DCC_DATA * )(( DIALOG_DATA * ) DialogData )->UserData;
	EVNT	lEvents;
	while( DccData->ModWin )
	{
		lEvents.mwhich = MU_MESAG;
		lEvents.msg[0] = WM_CLOSED;
		lEvents.msg[1] = Global[2];
		lEvents.msg[2] = 0;
		lEvents.msg[3] = DccData->ModWin->WinId;
		lEvents.msg[4] = WIN_CLOSE_WITHOUT_DEMAND;
		HandleWindow( &lEvents, Global );
	}
	if( DccData->File )
	{
		WORD	Msg[8];
		fclose( DccData->File );
		Msg[0] = SH_WDRAW;
		Msg[1] = Global[2];
		Msg[2] = 0;
		Msg[3] = *( DccData->Filename ) - 'A';
		MT_shel_write( SHW_BROADCAST, 0, 0, ( BYTE * ) Msg, 0L, Global );
	}
	FreeTree((( DIALOG_DATA *) DialogData)->Tree );
	free( DialogData );
	FreeDccData( DccData );
	return( E_OK );
}

/*-----------------------------------------------------------------------------*/
/* StartDccTx                                                                  */
/*-----------------------------------------------------------------------------*/
WORD	StartDccTx( IRC_SESSION *IrcSession, BYTE *Nickname, ULONG Size, BYTE *File, ULONG Filesize, WORD Global[15] )
{
	DCC_DATA	*DccData = malloc( sizeof( DCC_DATA ));
	BYTE	Title[128];
	if( !DccData )
		return( ENSMEM );
	if(( DccData->Nickname = strdup( Nickname )) == NULL )
	{
		free( DccData );
		return( ENSMEM );
	}
	if(( DccData->Filename = strdup( File )) == NULL )
	{
		free( DccData->Nickname );
		free( DccData );
		return( ENSMEM );
	}

	sprintf( Title, "%s %s", TreeAddr[TITLES][TITLE_WINDOW].ob_spec.free_string, Nickname );
	DccData->Title = strdup( Title );

	DccData->Port = 0;
	DccData->IP = 0;
	DccData->TcpMsgPuf = NULL;
	DccData->ModWin = NULL;
	DccData->LastUpdate = 0;
	DccData->Worked = 0;
	DccData->Size = Filesize;
	DccData->Block = Size;
	DccData->TStart = 0;
	DccData->File = NULL;
	DccData->DialogData = NULL;
	DccData->IrcSession = IrcSession;
	DccData->File = NULL;
	DccData->Out = 0;

	if( OpenWindow( DccData, Global ) != E_OK )
		MT_form_alert( 1, TreeAddr[ALERTS][MEMORY].ob_spec.free_string, Global );
	
	return( E_OK );
}

/*-----------------------------------------------------------------------------*/
/* AskDccRx                                                                    */
/*-----------------------------------------------------------------------------*/
WORD	AskDccRx( IRC *Irc, BYTE *Nickname, BYTE *File, UWORD Port, ULONG IP, ULONG Size, WORD Global[15] )
{
	DIALOG_DATA	*DialogData;
	BYTE	Title[128];
	DCC_DATA	*DccData = malloc( sizeof( DCC_DATA ));
	if( !DccData )
		return( ENSMEM );
	if(( DccData->Nickname = strdup( Nickname )) == NULL )
	{
		free( DccData );
		return( ENSMEM );
	}
	DccData->Port = Port;
	DccData->IP = IP;
	DccData->TcpMsgPuf = NULL;
	DccData->ModWin = NULL;
	DccData->LastUpdate = 0;
	DccData->Worked = 0;
	DccData->Size = Size;
	DccData->TStart = 0;
	DccData->File = NULL;
	DccData->DialogData = NULL;
	DccData->Filename = NULL;
	DccData->IrcSession = NULL;

	sprintf( Title, "%s %s", TreeAddr[TITLES][TITLE_WINDOW].ob_spec.free_string, Nickname );
	DccData->Title = strdup( Title );

	if( TreeAddr[GET][GET_NEW].ob_spec.tedinfo->te_txtlen < EDITLEN + 1 )
		InitScrlted( &TreeAddr[GET][GET_NEW], isScroll, &Xted, Txt, Tmplt, EDITLEN );
	if(( DialogData = malloc( sizeof( DIALOG_DATA ))) == NULL )
	{
		FreeDccData( DccData );
		return( ENSMEM );
	}

	DialogData->Dialog = NULL;
	DialogData->HndlDdDialog = NULL;
	DialogData->HndlClsDialog = HndlClsGetDialog;
	DialogData->HndlMesagDialog = NULL;
	DialogData->HndlTimerDialog = NULL;
	DialogData->HndlEditDialog = NULL;
	DialogData->HndlHelpDialog = NULL;
	DialogData->HndlCheckDialog = HndlCheckDialog;
	DialogData->UserData = DccData;
	DialogData->TreeIndex = GET;
	DccData->DialogData = DialogData;
	if(( DialogData->Tree = CopyTree( TreeAddr[GET] )) == NULL )
	{
		free( DialogData );
		return( ENSMEM );
	}
	sprintf( DialogData->Tree[GET_NICK].ob_spec.free_string, "%s (%s)", Nickname, inet_ntoa( IP ));
	strcpy( DialogData->Tree[GET_FILE].ob_spec.free_string, File );
	Size ? Decimal( Size, DialogData->Tree[GET_SIZE].ob_spec.free_string ) : strcpy( DialogData->Tree[GET_SIZE].ob_spec.free_string, "?" );

	strcpy( DialogData->Tree[GET_NEW].ob_spec.tedinfo->te_ptext, DownloadPath );
	if( DownloadPath[strlen(DownloadPath)-1] != '\\' )
		strcat( DialogData->Tree[GET_NEW].ob_spec.tedinfo->te_ptext, "\\" );
	strcat( DialogData->Tree[GET_NEW].ob_spec.tedinfo->te_ptext, File );
	if( OpenDialogX( DccData->Title, WIN_ALERT_WINDOW, NAME + MOVER, -1, -1, HandleGetDialog, DialogData, Global ) != E_OK )
	{
		FreeTree( DialogData->Tree );
		free( DialogData );
		return( ERROR );
	}

	return( E_OK );
}

/*-----------------------------------------------------------------------------*/
/* HandleGetDialog                                                             */
/*-----------------------------------------------------------------------------*/
static WORD cdecl	HandleGetDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData )
{
	OBJECT		*DialogTree;
	GRECT			Rect;
	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );
	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_EDIT:
			{
				break;
			}
			case	HNDL_CLSD:
				if( Events->msg[4] == WIN_CLOSE_WITHOUT_DEMAND )
					return( 0 );
				else
					return( 1 );
			case	HNDL_EDDN:
			{
				if( strlen( DialogTree[GET_NEW].ob_spec.tedinfo->te_ptext ))
				{
					if( DialogTree[GET_OK].ob_state & DISABLED )
					{
						DialogTree[GET_OK].ob_state &= ~DISABLED;
						DialogTree[GET_OK].ob_flags |= SELECTABLE;
						DoRedraw( Dialog, &Rect, GET_OK, Global );
					}
				}
				else
				{
					if( DialogTree[GET_OK].ob_flags & SELECTABLE )
					{
						DialogTree[GET_OK].ob_state |= DISABLED;
						DialogTree[GET_OK].ob_flags &= ~SELECTABLE;
						DoRedraw( Dialog, &Rect, GET_OK, Global );
					}
				}
				break;
			}
		}
	}
	else
	{
		DCC_DATA	*DccData = ( DCC_DATA * )((( DIALOG_DATA * ) UserData )->UserData );
		switch( Obj )
		{
			case	GET_NEW:
				if( Clicks == 2 )
				{
					BYTE	*Path;
					MT_wdlg_set_edit( Dialog, 0, Global );
					Path = Fsel( DialogTree[GET_NEW].ob_spec.tedinfo->te_ptext, "*", TreeAddr[TITLES][FSEL_NEWDOWNLOAD].ob_spec.free_string, Global );
					if( Path )
					{
						strcpy( DialogTree[GET_NEW].ob_spec.tedinfo->te_ptext, Path );
						free( Path );
						DoRedraw( Dialog, &Rect, GET_NEW, Global );
					}
					MT_wdlg_set_edit( Dialog, GET_NEW, Global );
				}
				break;
			case	GET_CANCEL:
				FreeDccData( DccData );
				return( 0 );
			case	GET_OK:
			{
				XATTR	Xattr;
				if( Fxattr( 0, DialogTree[GET_NEW].ob_spec.tedinfo->te_ptext, &Xattr ) == E_OK )
				{
					BYTE	Puf[ALERT_DIALOG_MAX_LEN + 1];
					DialogTree[GET_OK].ob_state &= ~SELECTED;
					DoRedraw( Dialog, &Rect, GET_OK, Global );
					ShortFileStrCpy( Puf, DialogTree[GET_NEW].ob_spec.tedinfo->te_ptext, ALERT_DIALOG_MAX_LEN );
					OpenAlert( DccData, AlertDialogX( 1, TreeAddr[ALERTS][ALERT_FILE_EXIST].ob_spec.free_string, DccData->Title, CloseAlert, DccData, Global, 1, Puf ), MODWIN_FILE_EXIST );
					break;
				}
				else
				{
					if(( DccData->File = fopen( DialogTree[GET_NEW].ob_spec.tedinfo->te_ptext, "wb" )) == NULL )
					{
						BYTE	Puf[ALERT_DIALOG_MAX_LEN + 1];
						ShortFileStrCpy( Puf, DialogTree[GET_NEW].ob_spec.tedinfo->te_ptext, ALERT_DIALOG_MAX_LEN );
						AlertDialogX( 1, TreeAddr[ALERTS][ALERT_SAVE_ERROR].ob_spec.free_string, DccData->Title, ( CLS_ALERT_DIALOG ) NULL, NULL, Global, 1, Puf );
					}
					else
					{
						DccData->Filename = strdup( DialogTree[GET_NEW].ob_spec.tedinfo->te_ptext );
						if( OpenWindow( DccData, Global ) != E_OK )
							MT_form_alert( 1, TreeAddr[ALERTS][MEMORY].ob_spec.free_string, Global );
					}
					return( 0 );
				}
			}
		}
	}
	return( 1 );
}
/*-----------------------------------------------------------------------------*/
/* HandleClsGetDialog                                                          */
/*-----------------------------------------------------------------------------*/
static WORD HndlClsGetDialog( void *DialogData, WORD Global[15] )
{
	FreeTree((( DIALOG_DATA *) DialogData)->Tree );
	free( DialogData );
	return( E_OK );
}

/*-----------------------------------------------------------------------------*/
/* OpenAlert                                                                   */
/*-----------------------------------------------------------------------------*/
static void	OpenAlert( DCC_DATA *DccData, WORD WinId, WORD Type )
{
	if( WinId > 0 )
	{
		MOD_WIN	**ModWin, *New, *Last = NULL;
		ModWin = &( DccData->ModWin );
		if(( New = malloc( sizeof( MOD_WIN ))) == NULL )
			return;
		New->WinId = WinId;
		New->Type = Type;
		New->next = NULL;
		if( *ModWin )
		{
			Last = *ModWin;
			while( Last->next )
				Last = Last->next;
			Last->next = New;
		}
		else
			*ModWin = New;
		New->prev = Last;
		if( Type == MODWIN_CONNECTION_CLOSED && DccData->DialogData )
			DccData->DialogData->HndlTimerDialog = NULL;
	}
}

/*-----------------------------------------------------------------------------*/
/* CloseAlert                                                                   */
/*-----------------------------------------------------------------------------*/
static void CloseAlert( void *UD, WORD Button, WORD WinId, WORD Global[15] )
{
	DCC_DATA	*DccData = ( DCC_DATA * ) UD;
	if( DccData )
	{
		MOD_WIN	**ModWin = &( DccData->ModWin );
		MOD_WIN	*Del = *ModWin;
		WORD	Type;
		while( Del )
		{
			if( Del->WinId == WinId )
				break;
			Del = Del->next;
		}
		if( !Del )
			return;

		if( Del->next )
			( Del->next )->prev = Del->prev;
		if( Del->prev )
			( Del->prev )->next = Del->next;
		else
			*ModWin = Del->next;
		Type = Del->Type;
		free( Del );
		switch( Type )
		{
			case	MODWIN_FILE_EXIST:
			{
				EVNT	lEvents;
				if( Button == 1 )
				{
					WORD	WinId = MT_wdlg_get_handle( DccData->DialogData->Dialog, Global );
					if(( DccData->File = fopen( DccData->DialogData->Tree[GET_NEW].ob_spec.tedinfo->te_ptext, "wb" )) == NULL )
					{
						BYTE	Puf[ALERT_DIALOG_MAX_LEN + 1];
						ShortFileStrCpy( Puf, DccData->DialogData->Tree[GET_NEW].ob_spec.tedinfo->te_ptext, ALERT_DIALOG_MAX_LEN );
						AlertDialogX( 1, TreeAddr[ALERTS][ALERT_SAVE_ERROR].ob_spec.free_string, DccData->Title, ( CLS_ALERT_DIALOG ) NULL, NULL, Global, 1, Puf );
					}
					else
					{
						DccData->Filename = strdup( DccData->DialogData->Tree[GET_NEW].ob_spec.tedinfo->te_ptext );
						if( OpenWindow( DccData, Global ) != E_OK )
							MT_form_alert( 1, TreeAddr[ALERTS][MEMORY].ob_spec.free_string, Global );
					}
					lEvents.mwhich = MU_MESAG;
					lEvents.msg[0] = WM_CLOSED;
					lEvents.msg[1] = Global[2];
					lEvents.msg[2] = 0;
					lEvents.msg[3] = WinId;
					lEvents.msg[4] = WIN_CLOSE_WITHOUT_DEMAND;
					HandleWindow( &lEvents, Global );
				}
				else	if( Button != 2 )
				{
					lEvents.mwhich = MU_MESAG;
					lEvents.msg[0] = WM_CLOSED;
					lEvents.msg[1] = Global[2];
					lEvents.msg[2] = 0;
					lEvents.msg[3] = MT_wdlg_get_handle( DccData->DialogData->Dialog, Global );
					lEvents.msg[4] = WIN_CLOSE_WITHOUT_DEMAND;
					HandleWindow( &lEvents, Global );
					FreeDccData( DccData );
				}
				break;
			}
			case	MODWIN_CLOSE_CONNECTION:
			{
				if( Button != 1 )
					break;
			}
			case	MODWIN_CONNECTION_CLOSED:
			{
				WORD	Msg[8];
				Msg[0] = TCP_CMD;
				Msg[1] = Global[2];
				Msg[2] = 0;
				Msg[3] = DccData->WinId;
				Msg[4] = TCP_close;
				TcpMessage( Msg, &( DccData->TcpMsgPuf ), DccData->TcpAppId, Global );
#ifdef	DRACONIS
				{
					EVNT	Evnt;
					MT_shel_write( 22, 0, DccData->TcpAppId, NULL, NULL, Global );
					Evnt.mwhich = MU_MESAG;
					Evnt.msg[0] = TCP_ACK;
					Evnt.msg[1] = DccData->TcpAppId;
					Evnt.msg[2] = 0;
					Evnt.msg[3] = DccData->WinId;
					Evnt.msg[4] = TCP_close;
					HandleWindow( &Evnt, Global );
				}
#endif					
				break;
			}
		}
	}
}
