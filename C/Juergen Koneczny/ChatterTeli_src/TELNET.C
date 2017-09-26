#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<TOS.H>
#include	<VDICOL.H>
#include	<MT_AES.H>
#include	<STDDEF.H>
#include	<STDARG.H>
#include	<STDLIB.H>
#include	<STRING.H>
#include	<STDIO.h>
#include	<TIME.H>

#include	<atarierr.h>
#include	<iconnect\sockinit.h>

#include	"main.h"
#include	RSCHEADER
#include	"IConnect.h"
#include	"TCP.h"
#include	"Telnet.h"
#include	"WDialog.h"
#include	"Window.h"
#include	"W_Text.h"

#include	"WDialog\W_Text.h"


#include	"MapKey.h"

#define	RXPUF_LEN	1024
/*-----------------------------------------------------------------------------*/
/* Strukturdefinitionen                                                        */
/*-----------------------------------------------------------------------------*/
typedef	struct	__telnet_data__
{
	TELNET	*Telnet;
	WORD		TcpAppId;
	WORD		EchoFlag;
	BYTE		*RxPuf;
	LONG		LenRxPuf;
	FILE		*ProtocolHandle;
} TELNET_DATA;

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern OBJECT	**TreeAddr;
extern TELNET	DefaultTelnet;
extern WORD	PingFlag;
extern BYTE	*ProtocolPath;
extern WORD AppendProtocolFlag;

extern WORD		SessionCounter;

/*-----------------------------------------------------------------------------*/
/* Lokale Variablen                                                            */
/*-----------------------------------------------------------------------------*/
/*static BYTE	*EmuName[4] = { "NETWORK-VIRTUAL-TERMINAL", "DEC-VT52", "DEC-VT100", "ANSI" };*/
static BYTE	*EmuName[4] = { "NETWORK-VIRTUAL-TERMINAL", "VT52", "VT100", "ANSI" };

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
static void DW( WORD WinId, WORD TcpAppId, WORD Code, WORD Opt, WORD Global[15] );
static LONG	DoOption( BYTE *Puf, LONG Len, WORD WinId, TELNET_DATA *TelnetData, WORD Global[15] );
static void	SendTerminalSize( WORD WinId, WORD TcpAppId, XY *Terminal, WORD Global[15] );
static LONG	CheckEscape( BYTE	**Puf, LONG Len );
void	ShortLogFilename( BYTE	*Filename );
void	OpenProtocol( TELNET_DATA	*TelnetData );

WORD	OpenTelnet( TELNET *Telnet, WORD Global[15] )
{
	TELNET_DATA	*New = malloc( sizeof( TELNET_DATA ));
	WORD	Ret;
	if( !New )
		return( 0 );
	MT_graf_mouse( M_SAVE, NULL, Global );
	MT_graf_mouse( BUSYBEE, NULL, Global );
	New->EchoFlag = 0;
	New->Telnet = Telnet;
	New->LenRxPuf = 0;
#ifdef	DEBUG
	DebugMsg( Global, "OpenTelnet: OpenTextWindow()\n" );
#endif
	Ret = OpenTextWindow( Telnet->EmuType, Telnet->KeyFlag, Telnet->KeyExport, Telnet->KeyImport, Telnet->PufLines, &( Telnet->Terminal ), &( Telnet->Tab ), Telnet->FontId, Telnet->FontPt, Telnet->FontColor, Telnet->FontEffects, Telnet->WindowColor, HandleTelnetWindow, Telnet->Host, New, Global );
#ifdef	DEBUG
	DebugMsg( Global, "OpenTelnet: OpenTextWindow() = %i\n", Ret );
#endif
	MT_graf_mouse( M_RESTORE, NULL, Global );
	return( Ret );
}

WORD	HandleTelnetWindow( WORD WinId, EVNT *Events, void *UserData, WORD Global[15] )
{
	TELNET_DATA *TelnetData = UserData;
	WORD	Msg[8];
	if( Events->mwhich & MU_MESAG )
	{
		switch( Events->msg[0] )
		{
			case	WIN_CMD:
			{
				if( Events->msg[4] == WIN_INIT )
				{
#ifdef	DEBUG
	DebugMsg( Global, "HandleTelnetWindow (WIN_INIT): Tcp()\n" );
#endif
					if(( TelnetData->TcpAppId = Tcp( Global )) <= 0 )
						return( ERROR );
#ifdef	DEBUG
	DebugMsg( Global, "HandleTelnetWindow (WIN_INIT): AppId = %i\n", TelnetData->TcpAppId );
#endif
					if( TelnetData->Telnet->ProtocolFlag )
						OpenProtocol( TelnetData );
					else
						TelnetData->ProtocolHandle = NULL;

					Msg[0] = TCP_CMD;
					Msg[1] = Global[2];
					Msg[2] = 0;
					Msg[3] = WinId;
					Msg[4] = TCP_init;
					MT_appl_write( TelnetData->TcpAppId, 16, Msg, Global );
					SessionCounter++;
					break;
				}
				if( Events->msg[4] == WIN_CLOSE )
				{
#ifdef	DEBUG
	DebugMsg( Global, "HandleTelnetWindow (WIN_CLOSE)\n" );
#endif
					if( Events->msg[5] == WIN_CLOSE_WITHOUT_DEMAND )
					{
						SetInfoTextWindow( WinId, TreeAddr[INFOS][TCP_DISCONNECT].ob_spec.free_string, Global );
#ifdef	DEBUG
	DebugMsg( Global, "HandleTelnetWindow (WIN_CLOSE): TCP_close\n" );
#endif
						Msg[0] = TCP_CMD;
						Msg[1] = Global[2];
						Msg[2] = 0;
						Msg[3] = WinId;
						Msg[4] = TCP_close;
						MT_appl_write( TelnetData->TcpAppId, 16, Msg, Global );
					}
					else
					{
						TEXT_WINDOW	*TextWindow = GetWindowData( WinId );
						if( !TextWindow->CloseId )
							OpenAlertTelnet( TextWindow, AlertDialog( 1, TreeAddr[ALERTS][CLOSE_SESSION].ob_spec.free_string, TelnetData->Telnet->Host, CloseAlertTelnet, TextWindow, Global ), MODWIN_CLOSE_SESSION );
					}
					return( E_OK );
				}
				if( Events->msg[4] == WIN_DEL )
				{
					EVNT	Events;
					WORD	KonId = ExistKontextTextWindow( WinId, Global );
#ifdef	DEBUG
	DebugMsg( Global, "HandleTelnetWindow (WIN_DEL)\n" );
#endif
					if( KonId )
					{
						Events.mwhich = MU_MESAG;
						Events.msg[0] = WM_CLOSED;
						Events.msg[1] = Global[2];
						Events.msg[2] = 0;
						Events.msg[3] = KonId;
						HandleWindow( &Events, Global );
					}
					FreeTelnet( TelnetData->Telnet );
					free( TelnetData );
					return( E_OK );
				}
				if( Events->msg[4] == WIN_KEY )
				{
					Msg[0] = TCP_CMD;
					Msg[1] = Global[2];
					Msg[2] = 0;
					Msg[3] = WinId;
					Msg[4] = TCP_out;
					if( Events->msg[5] == 13 )
					{
						*( BYTE ** )&( Msg[5] ) = malloc( 2 );
						( *( BYTE ** )&( Msg[5] ))[0] = '\r';
						( *( BYTE ** )&( Msg[5] ))[1] = '\n';
						Msg[7] = 2;
						MT_appl_write( TelnetData->TcpAppId, 16, Msg, Global );
						if( !TelnetData->EchoFlag )
							AppendBlockTextWindow( WinId, *( BYTE ** )&( Msg[5] ), 2, Global );
						return( E_OK );
					}		
					*( BYTE ** )&( Msg[5] ) = malloc( 1 );
					( *( BYTE ** )&( Msg[5] ))[0] = ( BYTE ) Events->msg[5];
					Msg[7] = 1;
					MT_appl_write( TelnetData->TcpAppId, 16, Msg, Global );
					if( TelnetData->ProtocolHandle )
						fwrite( *( BYTE ** )&( Msg[5] ), sizeof( char ), 1, TelnetData->ProtocolHandle );
					if( !TelnetData->EchoFlag )
						AppendBlockTextWindow( WinId, *( BYTE ** )&( Msg[5] ), 1, Global );
					return( E_OK );
				}
				if( Events->msg[4] == WIN_DRAGDROP )
				{
					DD_INFO	*DdInfo = *( DD_INFO ** )&( Events->msg[5] );
					if( DdInfo->format == '.TXT' )
					{
						BYTE	*Text = DdInfo->puf;
						LONG	Pos = 0;
						Msg[0] = TCP_CMD;
						Msg[1] = Global[2];
						Msg[2] = 0;
						Msg[3] = WinId;
						Msg[4] = TCP_out;
						while( Pos < DdInfo->size )
						{
							WORD	l = ( WORD ) strlen( Text );
							*( BYTE ** )( &Msg[5] ) = strdup( Text );
							if( !TelnetData->EchoFlag )
								AppendBlockTextWindow( WinId, *( BYTE ** )&( Msg[5] ), l, Global );
							Msg[7] =  l;
							MT_appl_write( TelnetData->TcpAppId, 16, Msg, Global );
							if( TelnetData->ProtocolHandle )
								fwrite( *( BYTE ** )( &Msg[5] ), sizeof( char ), l, TelnetData->ProtocolHandle );
							Pos += l + 1;
							Text += l + 1;
						}
					}
				}
				if( Events->msg[4] == WIN_KONTEXT_2 )
				{
					OpenKontextTextWindowDialog( WinId, TelnetData->Telnet, Global );
					return( E_OK );
				}
				if( Events->msg[4] == RX )
				{
					Msg[0] = TCP_CMD;
					Msg[1] = Global[2];
					Msg[2] = 0;
					Msg[3] = WinId;
					Msg[4] = TCP_rx;
					MT_appl_write( TelnetData->TcpAppId, 16, Msg, Global );
					return( E_OK );
				}
				if( Events->msg[4] == TX )
				{
					Msg[0] = TCP_CMD;
					Msg[1] = Global[2];
					Msg[2] = 0;
					Msg[3] = WinId;
					Msg[4] = TCP_tx;
					MT_appl_write( TelnetData->TcpAppId, 16, Msg, Global );
					return( E_OK );
				}
				break;
			}
			case	FONT_CHANGED:
			{
				if( !isMonospaceFont( Events->msg[4] ))
				{
					TEXT_WINDOW	*TextWindow = GetWindowData( WinId );
					OpenAlertTelnet( TextWindow, AlertDialog( 1, TreeAddr[ALERTS][FONT_NOT_MONO].ob_spec.free_string, TelnetData->Telnet->Host, CloseAlertTelnet, TextWindow, Global ), MODWIN_NORMAL );
				}
				else
				{
					if( Events->msg[4] > 0 )
						TelnetData->Telnet->FontId = Events->msg[4];
					if( Events->msg[5] > 0 )
						TelnetData->Telnet->FontPt = (( LONG ) Events->msg[5] ) << 16;
					if( Events->msg[6] != -1 )
						TelnetData->Telnet->FontColor = Events->msg[6];
					ChangeFontTextWindow( WinId, TelnetData->Telnet->FontId, TelnetData->Telnet->FontPt, TelnetData->Telnet->FontColor, TelnetData->Telnet->WindowColor, Global );
					ChangeKontextTextWindow( WinId, TelnetData->Telnet->FontId, TelnetData->Telnet->FontPt, TelnetData->Telnet->FontColor, Global );
				}
				return( E_OK );
			}
			case	COLOR_ID:
			{
				TelnetData->Telnet->WindowColor = Events->msg[5];
				ChangeColorTextWindow( WinId, TelnetData->Telnet->FontColor, TelnetData->Telnet->WindowColor, Global );
				ChangeKontextTextWindow( WinId, TelnetData->Telnet->FontId, TelnetData->Telnet->FontPt, TelnetData->Telnet->FontColor, Global );
				return( E_OK );
			}
			case	ICONNECT_ACK:
			{
				if( Events->msg[4] != E_OK )
				{
					SetInfoTextWindow( WinId, TreeAddr[INFOS][TCP_DISCONNECT].ob_spec.free_string, Global );
					Msg[0] = TCP_CMD;
					Msg[1] = Global[2];
					Msg[2] = 0;
					Msg[3] = WinId;
					Msg[4] = TCP_close;
					MT_appl_write( TelnetData->TcpAppId, 16, Msg, Global );
				}
				else
				{
					Msg[0] = TCP_CMD;
					Msg[1] = Global[2];
					Msg[2] = 0;
					Msg[3] = WinId;
					Msg[4] = TCP_socket;
					MT_appl_write( TelnetData->TcpAppId, 16, Msg, Global );
				}
				break;
			}
			case	TCP_CMD:
			{
				switch( Events->msg[4] )
				{
					case	TCP_closed:
					{
						TEXT_WINDOW	*TextWindow = GetWindowData( WinId );
						if( PingFlag )
							Cconout( '\a' );
						OpenAlertTelnet( TextWindow, AlertDialog( 1, TreeAddr[ALERTS][CONNECTION_CLOSED].ob_spec.free_string, TelnetData->Telnet->Host, CloseAlertTelnet, TextWindow, Global ), MODWIN_CONNECTION_CLOSED );
						break;
					}
					case	TCP_in:
					{
						LONG	PosRxPuf = 0, LenRxPuf = 0;
						BYTE	*RxPuf = malloc((( LONG ) Events->msg[7] ) + TelnetData->LenRxPuf );
						if( TelnetData->LenRxPuf )
						{
							memcpy( RxPuf, TelnetData->RxPuf, TelnetData->LenRxPuf );
							free( TelnetData->RxPuf );
						}
						if( TelnetData->ProtocolHandle )
							fwrite( *( BYTE ** )&( Events->msg[5] ), sizeof( char ), ( LONG ) Events->msg[7], TelnetData->ProtocolHandle );
						memcpy( &( RxPuf[TelnetData->LenRxPuf] ), *( BYTE ** )&( Events->msg[5] ), ( LONG ) Events->msg[7] );
						LenRxPuf = TelnetData->LenRxPuf + ( LONG ) Events->msg[7];
						TelnetData->LenRxPuf = 0;
						Msg[0] = TCP_ACK;
						Msg[1] = Global[2];
						Msg[2] = 0;
						Msg[3] = WinId;
						Msg[4] = TCP_in;
						*( long * )&( Msg[5] ) = *( long * )&( Events->msg[5] );
						MT_appl_write( TelnetData->TcpAppId, 16, Msg, Global );

						while( PosRxPuf < LenRxPuf )
						{
							if( RxPuf[PosRxPuf] == ( BYTE ) TELNET_IAC )
							{
								if( PosRxPuf + 1 < LenRxPuf && RxPuf[PosRxPuf+1] == ( BYTE ) TELNET_IAC )
								{
									memmove( &( RxPuf[PosRxPuf] ), &( RxPuf[PosRxPuf+1] ), LenRxPuf - PosRxPuf - 1 );
									LenRxPuf--;
									PosRxPuf++;
								}
								else	if( PosRxPuf + 1 < LenRxPuf )
								{
									UWORD	Cmd = 0xff & ( UWORD ) RxPuf[PosRxPuf+1];
									if( PosRxPuf )
									{
										LONG	Len = AppendBlockTextWindow( WinId, RxPuf, PosRxPuf, Global );
										memmove( RxPuf, &( RxPuf[Len] ), LenRxPuf - Len );
										PosRxPuf -= Len;
										LenRxPuf -= Len;
									}
									if( Cmd == TELNET_NOP )
									{
										LenRxPuf -= 2;
										memmove( &( RxPuf[PosRxPuf] ), &( RxPuf[PosRxPuf+2] ), LenRxPuf );
										continue;
									}
									else	if( Cmd == TELNET_DM )
									{
										LenRxPuf -= 2;
										memmove( &( RxPuf[PosRxPuf] ), &( RxPuf[PosRxPuf+2] ), LenRxPuf );
										continue;
									}
									else	if( Cmd == TELNET_B )
									{
										LenRxPuf -= 2;
										memmove( &( RxPuf[PosRxPuf] ), &( RxPuf[PosRxPuf+2] ), LenRxPuf );
										continue;
									}
									else	if( Cmd == TELNET_IP )
									{
										LenRxPuf -= 2;
										memmove( &( RxPuf[PosRxPuf] ), &( RxPuf[PosRxPuf+2] ), LenRxPuf );
										continue;
									}
									else	if( Cmd == TELNET_AO )
									{
										LenRxPuf -= 2;
										memmove( &( RxPuf[PosRxPuf] ), &( RxPuf[PosRxPuf+2] ), LenRxPuf );
										continue;
									}
									else	if( Cmd == TELNET_AYT )
									{
										LenRxPuf -= 2;
										memmove( &( RxPuf[PosRxPuf] ), &( RxPuf[PosRxPuf+2] ), LenRxPuf );
										continue;
									}
									else	if( Cmd == TELNET_EC )
									{
										LenRxPuf -= 2;
										memmove( &( RxPuf[PosRxPuf] ), &( RxPuf[PosRxPuf+2] ), LenRxPuf );
										continue;
									}
									else	if( Cmd == TELNET_EL )
									{
										LenRxPuf -= 2;
										memmove( &( RxPuf[PosRxPuf] ), &( RxPuf[PosRxPuf+2] ), LenRxPuf );
										continue;
									}
									else	if( Cmd == TELNET_GA )
									{
										LenRxPuf -= 2;
										memmove( &( RxPuf[PosRxPuf] ), &( RxPuf[PosRxPuf+2] ), LenRxPuf );
										continue;
									}
									else	if( Cmd == TELNET_SB )
									{
										LONG	Len = DoOption( &( RxPuf[PosRxPuf] ), LenRxPuf - PosRxPuf, WinId, TelnetData, Global );
										if( Len > 0 )
										{
											memmove( RxPuf, &( RxPuf[Len] ), LenRxPuf - Len );
											PosRxPuf -= Len;
											LenRxPuf -= Len;
											continue;
										}
										else
											break;
									}
									else	if( Cmd == TELNET_WILL )
									{
										if( PosRxPuf + 2 >= LenRxPuf )
											break;
										else
										{
											UWORD	a = 0xff & ( UWORD ) RxPuf[PosRxPuf+2];
/*printf("WILL %u\n", a);*/
											if( a == ECHO )
											{
												DW( WinId, TelnetData->TcpAppId, TELNET_DO, ECHO, Global );
												TelnetData->EchoFlag = 1;
											}
											else	if( a == SUPPRES_GO_AHEAD )
												DW( WinId, TelnetData->TcpAppId, TELNET_DO, SUPPRES_GO_AHEAD, Global );
											else	if( a == STATUS )
												DW( WinId, TelnetData->TcpAppId, TELNET_DO, STATUS, Global );
											else
												DW( WinId, TelnetData->TcpAppId, TELNET_DONT, a, Global );
											LenRxPuf -= 3;
											memmove( &( RxPuf[PosRxPuf] ), &( RxPuf[PosRxPuf+3] ), LenRxPuf );
											continue;
										}
									}
									else	if( Cmd == TELNET_WONT )
									{
										if( PosRxPuf + 2 >= LenRxPuf )
											break;
										else
										{
/*printf("WONT %u\n", 0xff & ( UWORD ) RxPuf[PosRxPuf+2]);*/
											LenRxPuf -= 3;
											memmove( &( RxPuf[PosRxPuf] ), &( RxPuf[PosRxPuf+3] ), LenRxPuf );
											continue;
										}
									}
									else	if( Cmd == TELNET_DO )
									{
										if( PosRxPuf + 2 >= LenRxPuf )
											break;
										else
										{
											UWORD	a = 0xff & ( UWORD ) RxPuf[PosRxPuf+2];
/*printf("DO %u\n", a );*/
											if( a == TRANSMIT_BINARY )
												DW( WinId, TelnetData->TcpAppId, TELNET_WILL, TRANSMIT_BINARY, Global );
											else	if( a == TERMINAL_TYPE )
												DW( WinId, TelnetData->TcpAppId, TELNET_WILL, TERMINAL_TYPE, Global );
											else	if( a == NAWS )
											{
												DW( WinId, TelnetData->TcpAppId, TELNET_WILL, NAWS, Global );
												SendTerminalSize( WinId, TelnetData->TcpAppId, &( TelnetData->Telnet->Terminal ), Global );
											}
											else
												DW( WinId, TelnetData->TcpAppId, TELNET_WONT, a, Global );
											LenRxPuf -= 3;
											memmove( &( RxPuf[PosRxPuf] ), &( RxPuf[PosRxPuf+3] ), LenRxPuf );
											continue;
										}
									}
									else	if( Cmd == TELNET_DONT )
									{
										if( PosRxPuf + 2 >= LenRxPuf )
											break;
										else
										{
/*printf("DONT %u\n", 0xff & ( UWORD ) RxPuf[PosRxPuf+2]);*/
											LenRxPuf -= 3;
											memmove( &( RxPuf[PosRxPuf] ), &( RxPuf[PosRxPuf+3] ), LenRxPuf );
											continue;
										}
									}
								}
								else
									break;
							}
							else
								PosRxPuf++;
						
							if( PosRxPuf == LenRxPuf )
							{
								LONG	Len = AppendBlockTextWindow( WinId, RxPuf, PosRxPuf, Global );
								memmove( RxPuf, &( RxPuf[Len] ), LenRxPuf - Len );
								PosRxPuf -= Len;
								LenRxPuf -= Len;
							}
						}

						if( LenRxPuf )
						{
							TelnetData->RxPuf = malloc( LenRxPuf );
							if( TelnetData->RxPuf )
							{
								TelnetData->LenRxPuf = LenRxPuf;
								memcpy( TelnetData->RxPuf, RxPuf, TelnetData->LenRxPuf );
							}
						}
						free( RxPuf );
						break;
					}
				}
				break;
			}
			case	TCP_ACK:
			{
				switch( Events->msg[4] )
				{
					case	TCP_init:
					{
						if( Events->msg[7] == E_OK )
						{
							EVNT Evnt;
							SetInfoTextWindow( WinId, TreeAddr[INFOS][TCP_INTERNET].ob_spec.free_string, Global );
							Evnt.mwhich = MU_MESAG;
							Evnt.msg[0] = ICONNECT_CMD;
							Evnt.msg[1] = Global[2];
							Evnt.msg[2] = 0;
							Evnt.msg[3] = WinId;
							HandleIConnect( &Evnt, Global );
							break;
						}
						if( Events->msg[7] == SE_NINSTALL )
						{
							TEXT_WINDOW	*TextWindow = GetWindowData( WinId );
							OpenAlertTelnet( TextWindow, AlertDialog( 1, TreeAddr[ALERTS][SOCKETS_NOT_INST].ob_spec.free_string, TelnetData->Telnet->Host, CloseAlertTelnet, TextWindow, Global ), MODWIN_CONNECTION_CLOSED );
						}
						else	if( Events->msg[7] == SE_NSUPP )
						{
							TEXT_WINDOW	*TextWindow = GetWindowData( WinId );
							OpenAlertTelnet( TextWindow, AlertDialog( 1, TreeAddr[ALERTS][SOCKETS_TOO_OLD].ob_spec.free_string, TelnetData->Telnet->Host, CloseAlertTelnet, TextWindow, Global ), MODWIN_CONNECTION_CLOSED );
						}
						break;
					}
					case	TCP_socket:
					{
						if( Events->msg[4] < 0 )
						{
							TEXT_WINDOW	*TextWindow = GetWindowData( WinId );
							OpenAlertTelnet( TextWindow, AlertDialog( 1, TreeAddr[ALERTS][SOCKET_FAILED].ob_spec.free_string, TelnetData->Telnet->Host, CloseAlertTelnet, TextWindow, Global ), MODWIN_CONNECTION_CLOSED );
							break;
						}
						SetInfoTextWindow( WinId, TreeAddr[INFOS][TCP_GETHOSTBYNAME].ob_spec.free_string, Global );
						Msg[0] = TCP_CMD;
						Msg[1] = Global[2];
						Msg[2] = 0;
						Msg[3] = WinId;
						Msg[4] = TCP_gethostbyname;
						*( BYTE ** )&( Msg[5] ) = TelnetData->Telnet->Host;
						MT_appl_write( TelnetData->TcpAppId, 16, Msg, Global );
						break;
					}
					case	TCP_gethostbyname:
					{
#ifndef	DEBUG_NO_CONNECTION
						if( Events->msg[7] == E_OK )
#endif
						{
							SetInfoTextWindow( WinId, TreeAddr[INFOS][TCP_CONNECT].ob_spec.free_string, Global );
							Msg[0] = TCP_CMD;
							Msg[1] = Global[2];
							Msg[2] = 0;
							Msg[3] = WinId;
							Msg[4] = TCP_connect;
							*( long * )&( Msg[5] ) = *( long * )&( Events->msg[5] );
							Msg[7] = TelnetData->Telnet->Port;
							MT_appl_write( TelnetData->TcpAppId, 16, Msg, Global );
						}
						else
						{
							TEXT_WINDOW	*TextWindow = GetWindowData( WinId );
							OpenAlertTelnet( TextWindow, AlertDialog( 1, TreeAddr[ALERTS][DNS_FAILED].ob_spec.free_string, TelnetData->Telnet->Host, CloseAlertTelnet, TextWindow, Global ), MODWIN_CONNECTION_CLOSED );
						}
						break;
					}
					case	TCP_connect:
					{
#ifndef	DEBUG_NO_CONNECTION
						if( Events->msg[7] == E_OK )
#endif
						{
							SetInfoTextWindow( WinId, TreeAddr[INFOS][TCP_ETABLISHED].ob_spec.free_string, Global );
							if( PingFlag )
								Cconout( '\a' );
						}
						else
						{
							TEXT_WINDOW	*TextWindow = GetWindowData( WinId );
							OpenAlertTelnet( TextWindow, AlertDialog( 1, TreeAddr[ALERTS][CONNECT_FAILED].ob_spec.free_string, TelnetData->Telnet->Host, CloseAlertTelnet, TextWindow, Global ), MODWIN_CONNECTION_CLOSED );
						}
						break;
					}
					case	TCP_close:
					{
						EVNT	Evnt;
						SessionCounter--;
						Evnt.mwhich = MU_MESAG;
						Evnt.msg[0] = ICONNECT_ACK;
						Evnt.msg[1] = Global[2];
						Evnt.msg[2] = 0;
						Evnt.msg[3] = WinId;
						HandleIConnect( &Evnt, Global );
						Evnt.mwhich = MU_MESAG;
						Evnt.msg[0] = WIN_ACK;
						Evnt.msg[1] = Global[2];
						Evnt.msg[2] = 0;
						Evnt.msg[3] = WinId;
						Evnt.msg[4] = WIN_CLOSE;
						HandleWindow( &Evnt, Global );
						if( TelnetData->ProtocolHandle )
							fclose( TelnetData->ProtocolHandle );
						break;
					}
					case	TCP_out:
					{
						free( *( BYTE ** )&( Events->msg[5] ));
						break;
					}
					case	TCP_rx:
					{
						TEXT_WINDOW	*TextWindow = GetWindowData( WinId );
						OpenAlertTelnet( TextWindow, AlertDialog( 1, TreeAddr[ALERTS][RX_START_FAILED].ob_spec.free_string, TelnetData->Telnet->Host, CloseAlertTelnet, TextWindow, Global ), MODWIN_NORMAL );
						break;
					}
					case	TCP_tx:
					{
						TEXT_WINDOW	*TextWindow = GetWindowData( WinId );
						OpenAlertTelnet( TextWindow, AlertDialog( 1, TreeAddr[ALERTS][TX_START_FAILED].ob_spec.free_string, TelnetData->Telnet->Host, CloseAlertTelnet, TextWindow, Global ), MODWIN_NORMAL );
						break;
					}
				}
				break;
			}
		}
		return( E_OK );
	}

	return( ERROR );
}

TELNET	*Url2Telnet( BYTE *Url )
{
	BYTE		Host[256], *Pos;
	TELNET	*Telnet = malloc( sizeof( TELNET ));

	if(( Pos = strchr( Url, '@' )) != NULL )
		strcpy( Host, Pos + 1 );
	else	if( strncmp( Url, "telnet://", 9 ) == 0 )
		strcpy( Host, &Url[9] );
	else	if( strncmp( Url, "telnet:", 7 ) == 0 )
		strcpy( Host, &Url[7] );

	if(( Pos = strchr( Host, ':' )) != NULL )
	{
		*Pos++ = 0;
		Telnet->Port = atoi( Pos );
	}
	else
		Telnet->Port = DefaultTelnet.Port;
	if(( Pos = strchr( Host, '/' )) != NULL )
		*Pos = 0;
	Telnet->Host = strdup( Host );

	Telnet->EmuType = DefaultTelnet.EmuType;
	Telnet->Terminal.x = DefaultTelnet.Terminal.x;
	Telnet->Terminal.y = DefaultTelnet.Terminal.y;
	Telnet->Tab.x = DefaultTelnet.Tab.x;
	Telnet->Tab.x = DefaultTelnet.Tab.x;
	Telnet->KeyFlag = DefaultTelnet.KeyFlag;
	Telnet->FontId = DefaultTelnet.FontId;
	Telnet->FontPt = DefaultTelnet.FontPt;
	Telnet->FontColor = DefaultTelnet.FontColor;
	Telnet->FontEffects = DefaultTelnet.FontEffects;
	Telnet->WindowColor = DefaultTelnet.WindowColor;
	Telnet->PufLines = DefaultTelnet.PufLines;
	Telnet->KeyExport = DefaultTelnet.KeyExport;
	Telnet->KeyImport = DefaultTelnet.KeyImport;

	return( Telnet );
}

void	FreeTelnet( TELNET *Telnet )
{
	if( Telnet->Host )
		free( Telnet->Host );
	free( Telnet );
}

TELNET	*CopyTelnet( TELNET *Telnet )
{
	TELNET	*New = malloc( sizeof( TELNET ));
	if( !New )
		return( NULL );
	memcpy( New, Telnet, sizeof( TELNET ));

	if( Telnet->Host )
	{
		New->Host = strdup( Telnet->Host );
		if( !New->Host )
			return( NULL );
	}
	return( New );
}

void	TelnetOptions( TELNET *Telnet, WORD WinId, WORD Flag, WORD Global[15] )
{
	TEXT_WINDOW	*TextWindow = ( TEXT_WINDOW * ) GetWindowData( WinId );
	TELNET_DATA	*TelnetData = ( TELNET_DATA * ) TextWindow->UserData;

	if( Telnet->KeyExport != TelnetData->Telnet->KeyExport )
	{
		TelnetData->Telnet->KeyExport = Telnet->KeyExport;
		ChangeKeyExportTextWindow( WinId, Telnet->KeyExport );
	}
	if( Telnet->KeyImport != TelnetData->Telnet->KeyImport )
	{
		TelnetData->Telnet->KeyImport = Telnet->KeyImport;
		ChangeKeyImportTextWindow( WinId, Telnet->KeyImport );
	}
/*	if( Telnet->KeyFlag != TelnetData->Telnet->KeyFlag )*/
	{
		TelnetData->Telnet->KeyFlag = Telnet->KeyFlag;
		ChangeKeyFlagTextWindow( WinId, Telnet->KeyFlag );
	}
	if( Telnet->FontId != TelnetData->Telnet->FontId ||
	    Telnet->FontPt != TelnetData->Telnet->FontPt ||
	    Telnet->FontColor != TelnetData->Telnet->FontColor || 
	    Telnet->FontEffects != TelnetData->Telnet->FontEffects ||
	    Telnet->WindowColor != TelnetData->Telnet->WindowColor )
	{
		if( Telnet->FontId == TelnetData->Telnet->FontId &&
		    Telnet->FontPt == TelnetData->Telnet->FontPt )
		{
			TelnetData->Telnet->FontColor = Telnet->FontColor;
			TelnetData->Telnet->FontEffects = Telnet->FontEffects;
			TelnetData->Telnet->WindowColor = Telnet->WindowColor;
			ChangeColorTextWindow( WinId, Telnet->FontColor, Telnet->WindowColor, Global );
		}
		else
		{
			TelnetData->Telnet->FontColor = Telnet->FontColor;
			TelnetData->Telnet->FontEffects = Telnet->FontEffects;
			TelnetData->Telnet->WindowColor = Telnet->WindowColor;
			TelnetData->Telnet->FontId = Telnet->FontId;
			TelnetData->Telnet->FontPt = Telnet->FontPt;
			ChangeFontTextWindow( WinId, Telnet->FontId, Telnet->FontPt, Telnet->FontColor, Telnet->WindowColor, Global );
		}
	}
	if( Telnet->ProtocolFlag != TelnetData->Telnet->ProtocolFlag )
	{
		TelnetData->Telnet->ProtocolFlag = Telnet->ProtocolFlag;
		if( Telnet->ProtocolFlag )
			OpenProtocol( TelnetData );
		else
		{
			if( TelnetData->ProtocolHandle );
				fclose( TelnetData->ProtocolHandle );
			TelnetData->ProtocolHandle = NULL;
		}
	}

	if( Telnet->EmuType != TelnetData->Telnet->EmuType )
	{
		TelnetData->Telnet->EmuType = Telnet->EmuType;
		ChangeEmuTextWindow( WinId, Telnet->EmuType );
	}
	
	if( Telnet->PufLines != TelnetData->Telnet->PufLines )
	{
		TelnetData->Telnet->PufLines = Telnet->PufLines;
		ChangePufLinesTextWindow( WinId, Telnet->PufLines, Global );
	}
	if( Telnet->Tab.x != TelnetData->Telnet->Tab.x ||
	    Telnet->Tab.y != TelnetData->Telnet->Tab.y )
	{
		TelnetData->Telnet->Tab.x = Telnet->Tab.x;
		TelnetData->Telnet->Tab.y = Telnet->Tab.y;
		ChangeTabTextWindow( WinId, &( Telnet->Tab ));
/* Žnderung der Emulation an Server senden */
	}
	if( Telnet->Terminal.x != TelnetData->Telnet->Terminal.x ||
	    Telnet->Terminal.y != TelnetData->Telnet->Terminal.y )
	{
		TelnetData->Telnet->Terminal.x = Telnet->Terminal.x;
		TelnetData->Telnet->Terminal.y = Telnet->Terminal.y;
		ChangeTerminalTextWindow( WinId, &( Telnet->Terminal ), Global );
		if( Flag )
			SendTerminalSize( WinId, TelnetData->TcpAppId, &( TelnetData->Telnet->Terminal ), Global );
	}
	
	FreeTelnet( Telnet );
}

static void DW( WORD WinId, WORD TcpAppId, WORD Code, WORD Opt, WORD Global[15] )
{
	WORD	Msg[8];
	Msg[0] = TCP_CMD;
	Msg[1] = Global[2];
	Msg[2] = 0;
	Msg[3] = WinId;
	Msg[4] = TCP_out;
	*( BYTE ** )&( Msg[5] ) = malloc( 3 );
	( *( BYTE ** )&( Msg[5] ))[0] = ( BYTE ) TELNET_IAC;
	( *( BYTE ** )&( Msg[5] ))[1] = ( BYTE ) Code;
	( *( BYTE ** )&( Msg[5] ))[2] = Opt;
	Msg[7] = 3;
	MT_appl_write( TcpAppId, 16, Msg, Global );
}

static LONG	DoOption( BYTE *Puf, LONG Len, WORD WinId, TELNET_DATA *TelnetData, WORD Global[15] )
{
	UWORD	a2;
	if( Len < 3 )
		return( 0 );
	a2 = 0xff & ( UWORD ) Puf[2];
/*	printf("Option %u\n",a2);*/
	if( a2 == TERMINAL_TYPE )
	{
		UWORD	a3, a4, a5;
		if( Len < 6 )
			return( 0 );
		a3 = 0xff & ( UWORD ) Puf[3];
		a4 = 0xff & ( UWORD ) Puf[4];
		a5 = 0xff & ( UWORD ) Puf[5];
		if( a3 == TERMINAL_TYPE_SEND && a4 == TELNET_IAC && a5 == TELNET_SE )
		{
			WORD	Msg[8];
			LONG	Len = strlen( EmuName[TelnetData->Telnet->EmuType] );
			BYTE	*Puf = malloc( 6 + Len );
			if( Puf )
			{
				Puf[0] = TELNET_IAC;
				Puf[1] = TELNET_SB;
				Puf[2] = TERMINAL_TYPE;
				Puf[3] = TERMINAL_TYPE_IS;
				strcpy( &( Puf[4] ), EmuName[TelnetData->Telnet->EmuType] );
				Puf[4 + Len] = TELNET_IAC;
				Puf[4 + Len + 1] = TELNET_SE;
				Msg[0] = TCP_CMD;
				Msg[1] = Global[2];
				Msg[2] = 0;
				Msg[3] = WinId;
				Msg[4] = TCP_out;
				*( BYTE ** )&( Msg[5] ) = Puf;
				Msg[7] = ( WORD ) Len + 6;
				MT_appl_write( TelnetData->TcpAppId, 16, Msg, Global );
/*				DW( WinId, TelnetData->TcpAppId, TELNET_WILL, TRANSMIT_BINARY, Global );
*/			}
		}
		return( 6 );
	}
	return( 3 );
}

static void	SendTerminalSize( WORD WinId, WORD TcpAppId, XY *Terminal, WORD Global[15] )
{
	BYTE	*Tmp = malloc( 4 ), *Puf;
	LONG	Len;
	WORD	Msg[8];
	Tmp[1] = 0xff & Terminal->x;
	Tmp[0] = ( 0xff00 & Terminal->x ) >> 8;
	Tmp[3] = 0xff & Terminal->y;
	Tmp[2] = ( 0xff00 & Terminal->y ) >> 8;
	Len = CheckEscape( &Tmp, 4 );
	Puf = malloc( 5 + Len );
	Puf[0] = TELNET_IAC;
	Puf[1] = TELNET_SB;
	Puf[2] = NAWS;
	memcpy( &( Puf[3] ), Tmp, Len );
	Puf[Len + 3] = TELNET_IAC;
	Puf[Len + 4] = TELNET_SE;
	free( Tmp );
	Msg[0] = TCP_CMD;
	Msg[1] = Global[2];
	Msg[2] = 0;
	Msg[3] = WinId;
	Msg[4] = TCP_out;
	*( BYTE ** )&( Msg[5] ) = Puf;
	Msg[7] = ( WORD ) Len + 5;
	MT_appl_write( TcpAppId, 16, Msg, Global );
/*printf("Terminal-Gr”že gesendet\n");*/
}

static LONG	CheckEscape( BYTE	**Puf, LONG Len )
{
	long	i = 0;
	while( i <= Len )
	{
		if(( *Puf )[i] == ( BYTE ) TELNET_IAC )
		{
			BYTE	*Tmp = malloc( Len + 1 );
			if( !Tmp )
				return( Len );
			memcpy( Tmp, *Puf, i + 1 );
			memcpy( &( Tmp[i+2] ), &(( *Puf )[i+1]), Len - i );
			free( *Puf );
			*Puf = Tmp;
			Len++;
			i++;
		}
		i++;
	}
	return( Len );
}

void	OpenProtocol( TELNET_DATA	*TelnetData )
{
	BYTE	Filename[512];
	time_t timer;
	if( ProtocolPath )
	{
		strcpy( Filename, ProtocolPath );
		if( Filename[strlen( Filename )-1] != '\\' )
			strcat( Filename, "\\" );
	}
	else
		strcpy( Filename, "" );
	strcat( Filename, TelnetData->Telnet->Host );
	strcat( Filename, ".log" );
	ShortLogFilename( Filename );
	if( AppendProtocolFlag )
		TelnetData->ProtocolHandle = fopen( Filename, "ab" );
	else
		TelnetData->ProtocolHandle = fopen( Filename, "wb" );
	time( &timer );
	fprintf( TelnetData->ProtocolHandle, "\n*** %s\n", ctime( &timer ));
}

void	ShortLogFilename( BYTE	*Filename )
{
	LONG	MaxLen;
	BYTE	*StartFilename;
	BYTE	Path[512];

	if(( StartFilename = strrchr( Filename, '\\' )) == NULL )
		StartFilename = Filename;

	strcpy( Path, Filename );
	if( strrchr( Path, '\\' ) != NULL )
		*( strrchr( Path, '\\' )) = 0;
	MaxLen = Dpathconf( Path, 3 );
	if( strlen( StartFilename ) > MaxLen )
	{
		*( StartFilename + MaxLen - 4 ) = 0;
		strcat( StartFilename, ".log" );
	}
}
