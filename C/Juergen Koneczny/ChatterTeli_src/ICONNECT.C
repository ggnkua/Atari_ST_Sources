#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<TOS.H>
#include	<VDICOL.H>
#include	<MT_AES.H>
#include  <STDDEF.H>
#include	<STDLIB.H>
#include	<STRING.H>
#include	<stdio.h>

#include	<av.h>
#include	<atarierr.h>
#ifdef	DRACONIS
#include	<stsocket.h>
#endif
#ifdef	ICONNECT
#include	<icon_msg.h>
#endif

#include	"main.h"
#include	RSCHEADER
#include	"IConnect.h"
#include	"WDialog.h"
#include	"Window.h"

#include	"MapKey.h"

/*-----------------------------------------------------------------------------*/
/* Strukturdefinitionen                                                        */
/*-----------------------------------------------------------------------------*/
typedef	struct	_icon_client_
{
	struct _icon_client_	*next;
	struct _icon_client_	*prev;
	WORD	WinId;
}	ICON_CLIENT;

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
void static	IConnectFailed( WORD Global[15] );
void static	IConnectConnected( WORD Global[15] );

void CloseAlert_Failed( void *UserData, WORD Button, WORD WinId, WORD Global[15] );
void CloseAlert_New( void *UserData, WORD Button, WORD WinId, WORD Global[15] );
void CloseAlert_Connection( void *UserData, WORD Button, WORD WinId, WORD Global[15] );

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern WORD	Global[15], AvAppId;
extern OBJECT	**TreeAddr;
extern WORD	SessionCounter;

/*-----------------------------------------------------------------------------*/
/* Globale Variablen                                                           */
/*-----------------------------------------------------------------------------*/
WORD	IConnectFlag = 0;

/*-----------------------------------------------------------------------------*/
/* Lokale Variablen                                                            */
/*-----------------------------------------------------------------------------*/
static WORD	TimeOut;
static WORD Status = 0;
#ifdef	ICONNECT
static IConnectAppId;
static IConnectStarted = 0;
#endif
static ICON_CLIENT	*IconClient = NULL;
static BYTE *File = NULL;
static nConnect = 0;
static WORD	ConnectionId = 0;

#define	ICONNECT_NON						0x0000
#define	ICONNECT_AV_STARTPROG			0x0001
#define	ICONNECT_VA_PROGSTART			0x0002
#define	ICONNECT_STATUS_REQUEST 		0x0003
#define	ICONNECT_CONNECTION_REQUEST	0x0004
#define	ICONNECT_CONNECTING				0x0005
#define	ICONNECT_MANUEL					0x0006

#define	TIMEOUT	10
#define	TIMEWAIT	4
#define	MAGIC		0xfdec


WORD	HandleIConnect( EVNT *Events, WORD Global[15] )
{
	WORD	Msg[8];
	if( Events->mwhich & MU_TIMER )
	{
		if( Status && --TimeOut == 0 )
		{
#ifdef	DRACONIS
			if( get_connected() == 2 )
				IConnectConnected( Global );
			else
				TimeOut = TIMEOUT;
#endif
#ifdef	ICONNECT
			switch( Status )
			{
				case	ICONNECT_AV_STARTPROG:
				{
					AlertDialog( 1, TreeAddr[ALERTS][ICONNECT_NO_AV].ob_spec.free_string, APPNAME, CloseAlert_Failed, 0L, Global );
					break;
				}
				case	ICONNECT_VA_PROGSTART:
				{
					Status = ICONNECT_NON;
					if(( IConnectAppId = MT_appl_find( "ICONNECT", Global )) == -1 )
						AlertDialog( 1, TreeAddr[ALERTS][ICONNECT_NOT_DESKTOP].ob_spec.free_string, APPNAME, CloseAlert_Failed, 0L, Global );
					else
					{
						Status = ICONNECT_STATUS_REQUEST;
						TimeOut = TIMEOUT;
						Msg[0] = ICON_MSG;
						Msg[1] = Global[2];
						Msg[2] = 0;
						Msg[3] = ICM_STATUS_REQUEST;
						Msg[4] = 0;
						Msg[5] = 0;
						Msg[6] = 0;
						Msg[7] = MAGIC;
						MT_appl_write( IConnectAppId, 16, Msg, Global );
					}
					break;
				}
				case	ICONNECT_STATUS_REQUEST:
				{
					Status = ICONNECT_NON;
					if(( IConnectAppId = MT_appl_find( "ICONNECT", Global )) == -1 )
						AlertDialog( 1, TreeAddr[ALERTS][ICONNECT_LOST].ob_spec.free_string, APPNAME, CloseAlert_New, 0L, Global );
					else
						AlertDialog( 1, TreeAddr[ALERTS][ICONNECT_TOO_OLD].ob_spec.free_string, APPNAME, CloseAlert_Failed, 0L, Global );
					break;
				}
				case	ICONNECT_CONNECTION_REQUEST:
				{
					Status = ICONNECT_NON;
					if(( IConnectAppId = MT_appl_find( "ICONNECT", Global )) == -1 )
						AlertDialog( 1, TreeAddr[ALERTS][ICONNECT_LOST].ob_spec.free_string, APPNAME, CloseAlert_New, 0L, Global );
					break;
				}
				case	ICONNECT_CONNECTING:
				{
					Status = ICONNECT_CONNECTING;
					TimeOut = TIMEOUT;
					Msg[0] = ICON_MSG;
					Msg[1] = Global[2];
					Msg[2] = 0;
					Msg[3] = ICM_STATUS_REQUEST;
					Msg[4] = 0;
					Msg[5] = 0;
					Msg[6] = 0;
					Msg[7] = MAGIC;
					MT_appl_write( IConnectAppId, 16, Msg, Global );
					break;
				}
				case	ICONNECT_MANUEL:
				{
					Msg[0] = ICON_MSG;
					Msg[1] = Global[2];
					Msg[2] = 0;
					Msg[3] = ICM_STATUS_REQUEST;
					Msg[4] = 0;
					Msg[5] = 0;
					Msg[6] = 0;
					Msg[7] = MAGIC;
					MT_appl_write( IConnectAppId, 16, Msg, Global );
				}
			}
#endif
		}
	}
	if( Events->mwhich & MU_MESAG )
	{
		switch( Events->msg[0] )
		{
			case	ICONNECT_CMD:
			{
				ICON_CLIENT	*Tmp = malloc( sizeof( ICON_CLIENT ));
				if( !Tmp )
					return( ENSMEM );
				Tmp->next = IconClient;
				Tmp->prev = NULL;
				if( IconClient )
					IconClient->prev = Tmp;
				IconClient = Tmp;
				Tmp->WinId = Events->msg[3];
				Status = ICONNECT_NON;
#ifdef	DRACONIS
				if( get_connected() == 2 )
					IConnectConnected( Global );
				else
				{
					ConnectionId = AlertDialog( 1, TreeAddr[ALERTS][ICONNECT_CONNECTION].ob_spec.free_string, APPNAME, CloseAlert_Connection, 0L, Global );
					Status = ICONNECT_MANUEL;
					TimeOut = TIMEOUT;
				}
#endif
#ifdef	ICONNECT
				IConnectAppId = MT_appl_find( "ICONNECT", Global );

				if( IConnectAppId == -1 && !( IConnectFlag & ICONNECT_START ))
				{
					if( ConnectionId )
					{
						EVNT	Events;
						Events.mwhich = MU_MESAG;
						Events.msg[0] = WM_TOPPED;
						Events.msg[1] = Global[2];
						Events.msg[2] = 0;
						Events.msg[3] = ConnectionId;
						HandleWindow( &Events, Global );
					}
					else
						ConnectionId = AlertDialog( 1, TreeAddr[ALERTS][ICONNECT_CONNECTION].ob_spec.free_string, APPNAME, CloseAlert_Connection, 0L, Global );
				}
				else	if( IConnectAppId == -1 && ( IConnectFlag & ICONNECT_START ))
				{
					Status = ICONNECT_AV_STARTPROG;
					TimeOut = TIMEOUT;
					File = Xmalloc( 16, RAM_READABLE );
					strcpy( File, "C:\\ICONFSET.CFG" );
					Msg[0] = AV_STARTPROG;
					Msg[1] = Global[2];
					Msg[2] = 0;
					*((char**)(&Msg[3])) = File;
					Msg[5] = 0;
					Msg[6] = 0;
					Msg[7] = MAGIC;
					MT_appl_write( AvAppId, 16, Msg, Global );
				}
				else
				{
					Status = ICONNECT_STATUS_REQUEST;
					TimeOut = TIMEOUT;
					Msg[0] = ICON_MSG;
					Msg[1] = Global[2];
					Msg[2] = 0;
					Msg[3] = ICM_STATUS_REQUEST;
					Msg[4] = 0;
					Msg[5] = 0;
					Msg[6] = 0;
					Msg[7] = MAGIC;
					MT_appl_write( IConnectAppId, 16, Msg, Global );
				}
#endif
				Events->mwhich &= ~MU_MESAG;
				break;
			}
			
			case	ICONNECT_ACK:
			{
#ifdef	DRACONIS
				if( Events->msg[3] == -1 )
				{
					if( Events->msg[4] == E_OK )
						IConnectConnected( Global );
					else
						IConnectFailed( Global );
					break;
				}
				else
				{
					if( IconClient )
					{
						ICON_CLIENT *Tmp = IconClient;
						while( Tmp )
						{
							if( Tmp->WinId == Events->msg[3] )
							{
								nConnect--;
								if( Tmp->next )
									( Tmp->next )->prev = Tmp->prev;
								if( Tmp->prev )
									( Tmp->prev )->next = Tmp->next;
								if( IconClient == Tmp )
									IconClient = Tmp->next;
								free( Tmp );
								if( !IconClient )
								{
									EVNT	Events;
									Events.mwhich = MU_MESAG;
									Events.msg[0] = WM_CLOSED;
									Events.msg[1] = Global[2];
									Events.msg[2] = 0;
									Events.msg[3] = ConnectionId;
									Events.msg[4] = WIN_CLOSE_WITHOUT_DEMAND;
									HandleWindow( &Events, Global );
								}
								break;
							}
							Tmp = Tmp->next;
						}
					}
				}
#endif
#ifdef	ICONNECT
				if( Events->msg[3] == -1 )
				{
					if( Events->msg[4] == E_OK || ( Status == ICONNECT_MANUEL && Events->msg[4] != ERROR ))
					{
						if(( IConnectAppId = MT_appl_find( "ICONNECT", Global )) == -1 )
						{
							if( ConnectionId )
							{
								EVNT	Events;
								Events.mwhich = MU_MESAG;
								Events.msg[0] = WM_TOPPED;
								Events.msg[1] = Global[2];
								Events.msg[2] = 0;
								Events.msg[3] = ConnectionId;
								HandleWindow( &Events, Global );
							}
							else
								ConnectionId = AlertDialog( 1, TreeAddr[ALERTS][ICONNECT_CONNECTION].ob_spec.free_string, APPNAME, CloseAlert_Connection, 0L, Global );
						}
						else
						{
							Status = ICONNECT_STATUS_REQUEST;
							TimeOut = TIMEOUT;
							Msg[0] = ICON_MSG;
							Msg[1] = Global[2];
							Msg[2] = 0;
							Msg[3] = ICM_STATUS_REQUEST;
							Msg[4] = 0;
							Msg[5] = 0;
							Msg[6] = 0;
							Msg[7] = MAGIC;
							MT_appl_write( IConnectAppId, 16, Msg, Global );
						}
						
					}
					else
					{
						Status = ICONNECT_NON;
						IConnectFailed( Global );
					}
					break;
				}
				else
				{
					if( IconClient )
					{
						ICON_CLIENT *Tmp = IconClient;
						while( Tmp )
						{
							if( Tmp->WinId == Events->msg[3] )
							{
								nConnect--;
								if( Tmp->next )
									( Tmp->next )->prev = Tmp->prev;
								if( Tmp->prev )
									( Tmp->prev )->next = Tmp->next;
								if( IconClient == Tmp )
									IconClient = Tmp->next;
								free( Tmp );
								if( !IconClient )
								{
									EVNT	Events;
									Events.mwhich = MU_MESAG;
									Events.msg[0] = WM_CLOSED;
									Events.msg[1] = Global[2];
									Events.msg[2] = 0;
									Events.msg[3] = ConnectionId;
									Events.msg[4] = WIN_CLOSE_WITHOUT_DEMAND;
									HandleWindow( &Events, Global );
								}
								break;
							}
							Tmp = Tmp->next;
						}
					}
				}
				if(( SessionCounter == 0 && ( IConnectFlag & ICONNECT_DISCONNECT ) && ( IConnectFlag & ICONNECT_LAST ) && IConnectStarted ) ||
				   ( SessionCounter == -1 && ( IConnectFlag & ICONNECT_DISCONNECT ) && !( IConnectFlag & ICONNECT_LAST ) && IConnectStarted ))
				{
					IConnectStarted = 0;
					Msg[0] = ICON_MSG;
					Msg[1] = Global[2];
					Msg[2] = 0;
					Msg[3] = ICM_SHUTDOWN_REQUEST;
					Msg[4] = 0;
					Msg[5] = 0;
					Msg[6] = 0;
					Msg[7] = 0;
					MT_appl_write( IConnectAppId, 16, Msg, Global );
				}
				break;
#endif
			}
			
			case	VA_PROGSTART:
			{
				if( File )
				{
					Mfree( File );
					File = NULL;
				}
				Status = ICONNECT_VA_PROGSTART;
				TimeOut = TIMEWAIT;
				break;
			}
			
#ifdef	ICONNECT
			case	ICON_MSG:
			{
				if( Events->msg[3] == ICM_STATUS_REPLY )
				{
					if( Events->msg[4] == ICMS_OFFLINE && ( IConnectFlag & ICONNECT_CONNECT ))
					{
						if( Status == ICONNECT_CONNECTING )
						{
							Status = ICONNECT_NON;
							if( ConnectionId )
							{
								EVNT	Events;
								Events.mwhich = MU_MESAG;
								Events.msg[0] = WM_TOPPED;
								Events.msg[1] = Global[2];
								Events.msg[2] = 0;
								Events.msg[3] = ConnectionId;
								HandleWindow( &Events, Global );
							}
							else
								ConnectionId = AlertDialog( 1, TreeAddr[ALERTS][ICONNECT_CONNECTION].ob_spec.free_string, APPNAME, CloseAlert_Connection, 0L, Global );
						}
						else
						{
							Status = ICONNECT_CONNECTION_REQUEST;
							TimeOut = TIMEOUT;
							Msg[0] = ICON_MSG;
							Msg[1] = Global[2];
							Msg[2] = 0;
							Msg[3] = ICM_CONNECTION_REQUEST;
							Msg[4] = 0;
							Msg[5] = 0;
							Msg[6] = 0;
							Msg[7] = MAGIC;
							MT_appl_write( IConnectAppId, 16, Msg, Global );
						}
					}
					else	if( Events->msg[4] == ICMS_OFFLINE && !( IConnectFlag & ICONNECT_CONNECT ))
					{
						if( Status != ICONNECT_MANUEL )
						{
							Status = ICONNECT_MANUEL;
							if( ConnectionId )
							{
								EVNT	Events;
								Events.mwhich = MU_MESAG;
								Events.msg[0] = WM_TOPPED;
								Events.msg[1] = Global[2];
								Events.msg[2] = 0;
								Events.msg[3] = ConnectionId;
								HandleWindow( &Events, Global );
							}
							else
								ConnectionId = AlertDialog( 1, TreeAddr[ALERTS][ICONNECT_CONNECTION].ob_spec.free_string, APPNAME, CloseAlert_Connection, 0L, Global );
						}
						TimeOut = TIMEWAIT;
					}
					else	if( Events->msg[4] == ICMS_CONNECTING )
					{
						if( Status == ICONNECT_MANUEL )
						{
						}
						IConnectStarted = 1;
						TimeOut = TIMEWAIT;
						Status = ICONNECT_CONNECTING;
					}
					else	if( Events->msg[4] == ICMS_ONLINE )
					{
						Status = ICONNECT_NON;
						IConnectConnected( Global );
					}
					else	if( Events->msg[4] == ICMS_CLOSING )
					{
						Status = ICONNECT_NON;
						if( ConnectionId )
						{
							EVNT	Events;
							Events.mwhich = MU_MESAG;
							Events.msg[0] = WM_TOPPED;
							Events.msg[1] = Global[2];
							Events.msg[2] = 0;
							Events.msg[3] = ConnectionId;
							HandleWindow( &Events, Global );
						}
						else
							ConnectionId = AlertDialog( 1, TreeAddr[ALERTS][ICONNECT_CONNECTION].ob_spec.free_string, APPNAME, CloseAlert_Connection, 0L, Global );
					}
				}
				if( Events->msg[3] == ICM_CONNECTION_REPLY )
				{
					if( Events->msg[4] == ICMC_CONNECTING )
					{
						TimeOut = TIMEWAIT;
						Status = ICONNECT_CONNECTING;
					}
					if( Events->msg[4] == ICMC_NOT_OFFLINE )
					{
						TimeOut = TIMEWAIT;
						Status = ICONNECT_CONNECTING;
					}
				}
				break;
			}
#endif
		}
	}
	return( E_OK );
}

void static	IConnectConnected( WORD Global[15] )
{
	EVNT	Events;
	ICON_CLIENT *Tmp = IconClient;
	if( ConnectionId )
	{
		Events.mwhich = MU_MESAG;
		Events.msg[0] = WM_CLOSED;
		Events.msg[1] = Global[2];
		Events.msg[2] = 0;
		Events.msg[3] = ConnectionId;
		Events.msg[4] = WIN_CLOSE_WITHOUT_DEMAND;
		HandleWindow( &Events, Global );
	}
	while( Tmp )
	{
		Events.mwhich = MU_MESAG;
		Events.msg[0] = ICONNECT_ACK;
		Events.msg[1] = Global[2];
		Events.msg[2] = 0;
		Events.msg[3] = Tmp->WinId;
		Events.msg[4] = E_OK;
		HandleWindow( &Events, Global );
		nConnect++;
		IconClient = Tmp->next;
		free( Tmp );
		Tmp = IconClient;
	}
	IconClient = NULL;
}

void static	IConnectFailed( WORD Global[15] )
{
	EVNT	Events;
	ICON_CLIENT *Tmp = IconClient;
	while( Tmp )
	{
		Events.mwhich = MU_MESAG;
		Events.msg[0] = ICONNECT_ACK;
		Events.msg[1] = Global[2];
		Events.msg[2] = 0;
		Events.msg[3] = Tmp->WinId;
		Events.msg[4] = ERROR;
		HandleWindow( &Events, Global );
		IconClient = Tmp->next;
		free( Tmp );
		Tmp = IconClient;
	}
	IconClient = NULL;
}

void CloseAlert_Failed( void *UserData, WORD Button, WORD WinId, WORD Global[15] )
{
	IConnectFailed( Global );
}
void CloseAlert_New( void *UserData, WORD Button, WORD WinId, WORD Global[15] )
{
	if( ConnectionId )
	{
		EVNT	Events;
		Events.mwhich = MU_MESAG;
		Events.msg[0] = WM_TOPPED;
		Events.msg[1] = Global[2];
		Events.msg[2] = 0;
		Events.msg[3] = ConnectionId;
		HandleWindow( &Events, Global );
	}
	else
		ConnectionId = AlertDialog( 1, TreeAddr[ALERTS][ICONNECT_CONNECTION].ob_spec.free_string, APPNAME, CloseAlert_Connection, 0L, Global );
}

void CloseAlert_Connection( void *UserData, WORD Button, WORD WinId, WORD Global[15] )
{
	EVNT	Events;
	ConnectionId = 0;
	Events.mwhich = MU_MESAG;
	Events.msg[0] = ICONNECT_ACK;
	Events.msg[1] = Global[2];
	Events.msg[2] = 0;
	Events.msg[3] = -1;
	if( Button == 1 )
		Events.msg[4] = E_OK;
	else	if( Button == 2 )
		Events.msg[4] = ERROR;
	else
		return;
	HandleIConnect( &Events, Global );
}
