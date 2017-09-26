#include	<mt_mem.h>
#include	<PORTAB.H>
#include <STDDEF.H>
#include	<TOS.H>
#include	<MT_AES.H>
#include <STDLIB.H>
#include <STDIO.H>
#include	<STRING.H>
#include <CTYPE.H>
#include <SETJMP.H>
#include <STDARG.H>
#ifdef	V120
#include	<TIME.H>
#endif

#include <atarierr.h>
#include	<types.h>
#include <sockerr.h>
#include <sockinit.h>
#include <socket.h>
#include	<sockios.h>
#include <sfcntl.h>
#include <in.h>
#include <inet.h>
#include <netdb.h>

#ifdef	GEMScript
#include	<gscript.h>
#endif

#include "main.h"
#include	"Suffix.h"
#include	"Config.h"
#include	"GemFtp.h"
#include "Ftp.h"
#include	"List.h"
#include	"Retr.h"
#include	"Stor.h"
#ifdef	NAES
#include "ADAPTRSC.h"
#include	"Thread.h"
#endif

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern UWORD		DataPort;
extern UWORD		DataPortL;
extern UWORD		DataPortH;
extern UWORD		PasvFlag;
extern UWORD		ShowFlag;
extern UWORD		TransferTypeAuto;
extern SUF_ITEM	*SuffixList;
extern volatile	ULONG		BufLen;
#ifdef	NAES
extern WORD	AesFlags;
#endif

/*-----------------------------------------------------------------------------*/
/* Globale Variablen                                                           */
/*-----------------------------------------------------------------------------*/
BYTE	*LogDir;
extern WORD	magic_version;
extern LONG	magic_date;
#ifdef	V110
volatile WORD	KeepConnectionActive;
volatile WORD	KeepConnectionActiveTime;
#endif
#ifdef	V120
volatile WORD	AppendProtocol;
#endif
#ifdef	NAES
WORD	FtpThreadAppId;
#endif
/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
LONG cdecl	ThreadFtp( LONG MainAppId );
WORD			SetType( int CmdSocket, FILE *MsgHandle, char *CmdPuf, WORD TM, BYTE *FileName, WORD GemFtpAppId, WORD Global[15] );

/* FTP-Funktionen -------------------------------------------------------------*/
int			RCmd( int CmdSocket, FILE *MsgHandle, char *CmdPuf, long CmdPufLen, WORD GemFtpAppId, WORD Global[15], char *cmdspec, ...);
int			RDataCmd( int CmdSocket, FILE *MsgHandle, char *CmdPuf, long CmdPufLen, 
				          int (*WorkDataStream)(), void **Work, WORD GemFtpAppId, WORD Flag, WORD Global[15],
				          char *cmdspec, ...);
int			TDataCmd( int CmdSocket, FILE *MsgHandle, char *CmdPuf, long CmdPufLen, 
				          int (*WorkDataStream)(), void **Work, WORD GemFtpAppId, WORD Global[15],
				          char *cmdspec, ...);
void			SendCmd( int CmdSocket, FILE *MsgHandle, char *cmdspec, va_list ap );
int			GetResponse( int CmdSocket, FILE *MsgHandle, char *CmdPuf, long CmdPufLen, WORD GemFtpAppId, WORD Global[15] );
int			GetDataStream( int DataSocket, FILE *MsgHandle, int (*WorkDataStream)(), void **Work, WORD GemFtpAppId, WORD Flag, WORD Global[15] );
int			PutDataStream( int DataSocket, int (*WorkDataStream)(), void **Work, WORD GemFtpAppId, WORD Global[15] );
int			OpenDataConnection( int CmdSocket, FILE *MsgHandle, char *CmdPuf, long CmdPufLen, int *Socket, WORD PasvFlag, WORD GemFtpAppId, WORD Global[15] );
int			AcceptDataConnection( int Socket, int *DataSocket, WORD PasvFlag );
int			GetPort( int CmdSocket, FILE *MsgHandle, char *CmdPuf, long CmdPufLen, sockaddr_in *Saddr, WORD GemFtpAppId, WORD Global[15] );
int			SendPort( int CmdSocket, FILE *MsgHandle, char *CmdPuf, long CmdPufLen, sockaddr_in *Saddr, WORD GemFtpAppId, WORD Global[15] );
void			SetLinger( int Socket );

LONG cdecl	ShowMessages( void );
#ifdef	V110
void	ShortLogFilename( BYTE	*Filename );
#endif

/*----------------------------------------------------------------------------------------*/ 
/* FTP-Sitzung einrichten                                                                 */
/*----------------------------------------------------------------------------------------*/ 
WORD	Ftp( LONG GemFtpAppId )
{
#ifdef	NAES
	WORD	AppId;
#endif
	THREADINFO Thread;
	Thread.proc = (void *) ThreadFtp;
	Thread.user_stack = NULL;
	Thread.stacksize = 4096L;
	Thread.mode = 0;
	Thread.res1 = 0L;

#ifdef	NAES
	if( AesFlags & GAI_MAGIC )
		return( shel_write( SHW_THR_CREATE, 1, 0, (char *) &Thread, (void *) GemFtpAppId ));
	else
	{
		if( DOThread(( threadfun * ) ThreadFtp, ( long ) GemFtpAppId, 4096L, "Fiffi" ) >= 0 ) 
		{
printf("Vor Ftp() Psigpause\n");
			Psignal( SIGUSR2, WaitThreadAppId );
			Psigpause( 0L );
			AppId = FtpThreadAppId;
		}
		else
			AppId = 0;
		return( AppId );
	}
#else
	if( magic_version && magic_date >= 0x19960401L )
		return( shel_write( SHW_THR_CREATE, 1, 0, (char *) &Thread, (void *) GemFtpAppId ));
	else
		return( 0 );
#endif
}

LONG cdecl	ThreadFtp( LONG MainAppId )
{
	WORD	Global[15], AppId;

#ifdef DEBUG
	DebugMsg( Global, "ThreadFtp gestartet von AppId = %li\n", MainAppId );
#endif
	AppId = MT_appl_init( Global );
#ifdef	NAES
	if(( AesFlags & GAI_MAGIC ) == 0 )
	{
		FtpThreadAppId = AppId;
		Pkill( Pgetppid(), SIGUSR2 );
		printf("%i\n", Pgetppid());
		printf("ThreadFtp() Nach Pkill()\n");
	}
#endif
	if( AppId > 0 )
	{
		WORD	Msg[8], Ret, Quit = 1;
#ifdef	V110
		WORD	Connection = 0;
#endif
		EVNT	Events;
		int	CmdSocket = 0;
		char	*CmdPuf, *ProtoPuf = NULL;
		FILE	*MsgHandle = NULL;
#ifdef DEBUG
	DebugMsg( Global, "ThreadFtp [AppId = %i]\n", AppId );
#endif
		MT_menu_register( AppId, "  Fiffi-Thread", Global );
		CmdPuf = malloc( CMDPUFLEN );
		if( !CmdPuf )
			return( ENSMEM );
		while( Quit )
		{
#ifdef	V110
			if( KeepConnectionActive && Connection)
				MT_EVNT_multi( MU_MESAG + MU_TIMER, 0, 0, 0, 0L, 0L, (( LONG )( KeepConnectionActiveTime  )) * 1000, &Events, Global );
			else
				MT_EVNT_multi( MU_MESAG, 0, 0, 0, 0L, 0L, 0L, &Events, Global );
#else
			MT_EVNT_multi( MU_MESAG, 0, 0, 0, 0L, 0L, 0L, &Events, Global );
#endif
#ifdef	V110
			if( Events.mwhich & MU_TIMER )
			{
				Ret = RCmd( CmdSocket, MsgHandle, CmdPuf, CMDPUFLEN, Events.msg[1], Global, "NOOP" );
			}
#endif
			if( Events.mwhich & MU_MESAG )
			{
				switch( Events.msg[0] )
				{
/* GEMScript -----------------------------------------------------------------*/
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
									Msg[7] = Events.msg[7];
									MT_appl_write(( WORD ) AppId, 16, Msg, Global );
									break;
								}
#endif
/* Ftp_Msg --------------------------------------------------------------------*/
					case	Ftp_Quit:
						if( Events.msg[1] != ( WORD ) MainAppId )
							break;
#ifdef DEBUG
	DebugMsg( Global, "ThreadFtp: Ftp_Quit\n" );
#endif
						if( CmdSocket )
						{
							RCmd( CmdSocket, MsgHandle, CmdPuf, CMDPUFLEN, Events.msg[1], Global, "QUIT" );
							shutdown( CmdSocket, 2 );
							sclose( CmdSocket );
						}
						if( MsgHandle )
						{
							fclose( MsgHandle );
							free( ProtoPuf );
						}

						free( CmdPuf );						
						Quit = 0;
						break;
/* SocketInit_Cmd -------------------------------------------------------------*/
					case	SocketInit_Cmd:
#ifdef DEBUG
	DebugMsg( Global, "ThreadFtp: SocketInit\n" );
#endif
						Msg[1] = AppId;
						Msg[2] = 0;
						if(( Ret = sock_init()) < 0 )
						{
							Msg[0] = SocketInit_Failed;
							Msg[3] = Ret;
						}
						else
							Msg[0] = SocketInit_Ok;
						MT_appl_write( Events.msg[1], 16, Msg, Global );
						break;
/* OpenConnect_Cmd ------------------------------------------------------------*/
					case	OpenConnect_Cmd:
					{
						hostent		*He;
						sockaddr_in	SockAddrIn;
#ifdef DEBUG
	DebugMsg( Global, "ThreadFtp: OpenConnect\n" );
#endif
						Msg[1] = AppId;
						Msg[2] = 0;
						if(( CmdSocket = socket( AF_INET, SOCK_STREAM, IPPROTO_TCP )) < 0 )
						{
							Msg[0] = Socket_Failed;
							MT_appl_write( Events.msg[1], 16, Msg, Global );
							break;
						}
						Msg[0] = GetHostByName;
						MT_appl_write( Events.msg[1], 16, Msg, Global );
#ifdef DEBUG
	DebugMsg( Global, "ThreadFtp: GetHostByName\n" );
#endif
						if(( He = gethostbyname( *( BYTE **) &( Events.msg[3] ))) == 0L ||
						     !He->h_addr )
						{
							Msg[0] = GetHostByName_Failed;
							MT_appl_write( Events.msg[1], 16, Msg, Global );
							break;
						}
						if( ShowFlag )
						{
							BYTE	Filename[PathLen];
							if( LogDir )
								strcpy( Filename, LogDir );
							else
								strcpy( Filename, "" );
							strcat( Filename, *( BYTE **) &( Events.msg[3] ));
							strcat( Filename, ".log" );
#ifdef	V110
							ShortLogFilename( Filename );
#endif
#ifdef	V120
							if( AppendProtocol )
								MsgHandle = fopen( Filename, "ab" );
							else
								MsgHandle = fopen( Filename, "wb" );
#else
							MsgHandle = fopen( Filename, "ab" );
#endif
							if( MsgHandle )
							{
#ifdef	V120
								time_t timer;
#endif
								ProtoPuf = malloc( BufLen );
								setbuf( MsgHandle, ProtoPuf );
#ifdef	V120
								time( &timer );
								fprintf( MsgHandle, "\n*** %s\n", ctime( &timer ));
#endif
							}
						}
#ifdef DEBUG
	DebugMsg( Global, "ThreadFtp: Connect\n" );
#endif
						Msg[0] = Connect;
						MT_appl_write( Events.msg[1], 16, Msg, Global );
						SockAddrIn.sin_family = AF_INET;
						SockAddrIn.sin_port = Events.msg[5];
						SockAddrIn.sin_addr = *(ulong *) He->h_addr;
						if( connect( CmdSocket, &SockAddrIn, (int) sizeof( sockaddr_in )) != E_OK )
							Msg[0] = Connect_Failed;
						else
							Msg[0] = OpenConnect_Ok;
						Msg[1] = AppId;
						MT_appl_write( Events.msg[1], 16, Msg, Global );
						break;
					}
/* Login_Cmd ------------------------------------------------------------------*/
					case	Login_Cmd:
#ifdef DEBUG
	DebugMsg( Global, "ThreadFtp: Login\n" );
#endif
						Ret = GetResponse( CmdSocket, MsgHandle, CmdPuf, CMDPUFLEN, Events.msg[1], Global );
#ifdef DEBUG
	DebugMsg( Global, "ThreadFtp: Login Ret=%i\n",Ret );
#endif
						if( Ret == 220 )
							Ret = RCmd( CmdSocket, MsgHandle, CmdPuf, CMDPUFLEN, Events.msg[1], Global, "USER %s", (BYTE *) *( LONG *)&( Events.msg[3] ));
						if( Ret == 331 )
							Ret = RCmd( CmdSocket, MsgHandle, CmdPuf, CMDPUFLEN, Events.msg[1], Global, "PASS %s", (BYTE *) *( LONG *)&( Events.msg[5] ));
						Msg[1] = AppId;
						Msg[2] = 0;
#ifdef DEBUG
	DebugMsg( Global, "ThreadFtp: Login RCmd=%i\n",Ret );
#endif
						if( Ret == 230 )
						{
							Msg[0] = Login_Ok;
#ifdef	V110
							Connection = 1;
#endif
						}
						else
						{
							Msg[0] = Login_Failed;
							Msg[3] = Ret;
						}
						MT_appl_write( Events.msg[1], 16, Msg, Global );
						break;
/* Cwd_Msg --------------------------------------------------------------------*/
					case	Cwd_Cmd:
						Ret = RCmd( CmdSocket, MsgHandle, CmdPuf, CMDPUFLEN, Events.msg[1], Global, "CWD %s", (BYTE *) *( LONG *)&( Events.msg[3] ));
						Msg[1] = AppId;
						Msg[2] = 0;
						if( Ret < 0 || Ret >= 300 )
						{
							Msg[0] = Cwd_Failed;
							Msg[3] = Ret;
						}
						else
							Msg[0] = Cwd_Ok;
						MT_appl_write( Events.msg[1], 16, Msg, Global );
						break;
/* Cdup_Msg -------------------------------------------------------------------*/
					case	Cdup_Cmd:
						Ret = RCmd( CmdSocket, MsgHandle, CmdPuf, CMDPUFLEN, Events.msg[1], Global, "CDUP" );
						Msg[1] = AppId;
						Msg[2] = 0;
						if( Ret < 0 || Ret >= 300 )
						{
							Msg[0] = Cdup_Failed;
							Msg[3] = Ret;
						}
						else
							Msg[0] = Cdup_Ok;
						MT_appl_write( Events.msg[1], 16, Msg, Global );
						break;
/* Pwd_Msg --------------------------------------------------------------------*/
					case	Pwd_Cmd:
						Ret = RCmd( CmdSocket, MsgHandle, CmdPuf, CMDPUFLEN, Events.msg[1], Global, "PWD" );
						Msg[1] = AppId;
						Msg[2] = 0;
						if( Ret < 0 || Ret >= 300 )
						{
							Msg[0] = Pwd_Failed;
							Msg[3] = Ret;
						}
						else
						{
							BYTE	*Pos, *End, **DirPuf;
							Msg[0] = Pwd_Ok;
							Pos = CmdPuf + 5;
							End = strchr( Pos, 0x22 );
							*End = 0;
							DirPuf = (BYTE **) *( LONG *)&( Events.msg[3] );
							if( *DirPuf )
								free( *DirPuf );
							*DirPuf = malloc( End - Pos + 1 );
							if( !( *DirPuf ))
								return( ENSMEM );
							strcpy( *DirPuf, Pos );
#ifdef	V120
							{
								BYTE	*c;
								while(( c = strchr( *DirPuf, '\\' )) != NULL )
									*c = '/';
							}
#endif
						}
						MT_appl_write( Events.msg[1], 16, Msg, Global );
						break;
/* List_Msg -------------------------------------------------------------------*/
					case	List_Cmd:
						Ret = RCmd( CmdSocket, MsgHandle, CmdPuf, CMDPUFLEN, Events.msg[1], Global, "TYPE A");
						if( Ret >= 0 && Ret < 300 || Ret == 504 )	/* 504: Anpassung an T-Online */
#ifdef	GEMScript
							if( *( BYTE **) &Events.msg[5] )
								Ret = RDataCmd( CmdSocket, MsgHandle, CmdPuf, CMDPUFLEN, 
								                WorkRList, (void **) *( LONG *)&( Events.msg[3] ), Events.msg[1], Events.msg[7], Global,
								                "LIST %s", *( BYTE **) &Events.msg[5] );
							else
								Ret = RDataCmd( CmdSocket, MsgHandle, CmdPuf, CMDPUFLEN, 
								                WorkRList, (void **) *( LONG *)&( Events.msg[3] ), Events.msg[1], Events.msg[7], Global,
								                "LIST" );
#else
							Ret = RDataCmd( CmdSocket, MsgHandle, CmdPuf, CMDPUFLEN, 
							                WorkRList, (void **) *( LONG *)&( Events.msg[3] ), Events.msg[1], Global,
							                "LIST" );
#endif
						Msg[1] = AppId;
						Msg[2] = 0;
						if( Ret < 0 || Ret >= 300 )
						{
							if( Ret == ABORT )
								Msg[0] = List_Abort;
							else
								Msg[0] = List_Failed;
							Msg[3] = Ret;
						}
						else
							Msg[0] = List_Ok;
						MT_appl_write( Events.msg[1], 16, Msg, Global );
						break;
/* Retr_Msg -------------------------------------------------------------------*/
					case	Retr_Cmd:
					{
						BYTE	**FileList = (BYTE **) *( LONG *)&( Events.msg[4] );
						BYTE	**DirList = (BYTE **) *( LONG *)&( Events.msg[6] );
						WORD	i = 0;
						Msg[1] = AppId;
						Msg[2] = 0;
						while( FileList[i] )
						{
#ifdef	RESUME
							XATTR	Xattr;
							if( Fxattr( 0, DirList[i], &Xattr ) == E_OK )
							{
								Msg[0] = Retr_File_Update;
								Msg[5] = i;
								Msg[6] = SetType( CmdSocket, MsgHandle, CmdPuf, Events.msg[3], FileList[i], Events.msg[1], Global );
								MT_appl_write( Events.msg[1], 16, Msg, Global );
								Msg[0] = Retr_File_Resume;
								*(( LONG * ) &Msg[3] ) = Xattr.size;
								MT_appl_write( Events.msg[1], 16, Msg, Global );
								Ret = RDataCmd( CmdSocket, MsgHandle, CmdPuf, CMDPUFLEN, 
								                WorkRFile, ( void ** )&( DirList[i] ), Events.msg[1], 0, Global,
								                "REST %li\r\nRETR %s", Xattr.size, FileList[i] );
							}
							else
							{
								Msg[0] = Retr_File_Update;
								Msg[5] = i;
								Msg[6] = SetType( CmdSocket, MsgHandle, CmdPuf, Events.msg[3], FileList[i], Events.msg[1], Global );
								MT_appl_write( Events.msg[1], 16, Msg, Global );
								Ret = RDataCmd( CmdSocket, MsgHandle, CmdPuf, CMDPUFLEN, 
								                WorkRFile, ( void ** )&( DirList[i] ), Events.msg[1], 0, Global,
								                "RETR %s", FileList[i] );
							}
#else
							Msg[0] = Retr_File_Update;
							Msg[5] = i;
							Msg[6] = SetType( CmdSocket, MsgHandle, CmdPuf, Events.msg[3], FileList[i], Events.msg[1], Global );
							MT_appl_write( Events.msg[1], 16, Msg, Global );
							Ret = RDataCmd( CmdSocket, MsgHandle, CmdPuf, CMDPUFLEN, 
							                WorkRFile, ( void ** )&( DirList[i] ), Events.msg[1], 0, Global,
							                "RETR %s", FileList[i] );
#endif
							Msg[1] = AppId;
							Msg[2] = 0;
							Msg[5] = i;
							if( Ret == ABORT )
							{
								Msg[0] = Retr_Abort;
								Msg[4] = Ret;
								MT_appl_write( Events.msg[1], 16, Msg, Global );
								break;
							}
							if( Ret < 0 || Ret >= 300 )
							{
								Msg[0] = Retr_Failed;
								Msg[4] = Ret;
							}
							else
								Msg[0] = Retr_File_Ok;
							MT_appl_write( Events.msg[1], 16, Msg, Global );
							i++;
						}
						Msg[0] = Retr_Ok;
						MT_appl_write( Events.msg[1], 16, Msg, Global );
						break;
					}
/* Stor_Msg -------------------------------------------------------------------*/
					case	Stor_Cmd:
					{
						BYTE	**FileList = (BYTE **) *( LONG *)&( Events.msg[4] );
						BYTE	**DirList = (BYTE **) *( LONG *)&( Events.msg[6] );
						WORD	i = 0;
						Msg[1] = AppId;
						Msg[2] = 0;
						while( FileList[i] )
						{
							Msg[0] = Stor_File_Update;
							Msg[5] = i;
							Msg[6] = SetType( CmdSocket, MsgHandle, CmdPuf, Events.msg[3], FileList[i], Events.msg[1], Global );
							MT_appl_write( Events.msg[1], 16, Msg, Global );
							Ret = TDataCmd( CmdSocket, MsgHandle, CmdPuf, CMDPUFLEN, 
							                WorkTFile, ( void ** )&( DirList[i] ), Events.msg[1], Global,
							                "STOR %s", FileList[i] );
							Msg[1] = AppId;
							Msg[2] = 0;
							Msg[5] = i;
							if( Ret == ABORT )
							{
								Msg[0] = Stor_Abort;
								Msg[4] = Ret;
								MT_appl_write( Events.msg[1], 16, Msg, Global );
								break;
							}
							if( Ret < 0 || Ret >= 300 )
							{
								Msg[0] = Stor_Failed;
								Msg[4] = Ret;
								MT_appl_write( Events.msg[1], 16, Msg, Global );
								break;
							}
							Msg[0] = Stor_File_Ok;
							Msg[5] = i;
							MT_appl_write( Events.msg[1], 16, Msg, Global );
							i++;
						}
						if( Ret >= 0 && Ret < 300 || Ret == ABORT )
						{
							Msg[0] = Stor_Ok;
							MT_appl_write( Events.msg[1], 16, Msg, Global );
						}
						break;
					}
/* Rn_Msg ---------------------------------------------------------------------*/
					case	Rn_Cmd:
					{
						BYTE	**FileList, **FileListNew;
						WORD	i = 0;
						FileList = (BYTE **) *( LONG *)&( Events.msg[3] );
						FileListNew = (BYTE **) *( LONG *)&( Events.msg[5] );
						Msg[1] = AppId;
						Msg[2] = 0;
						while( FileList[i] )
						{
							Msg[0] = Rn_Update;
							Msg[5] = i;
							MT_appl_write( Events.msg[1], 16, Msg, Global );
							Ret = RCmd( CmdSocket, MsgHandle, CmdPuf, CMDPUFLEN, Events.msg[1], Global, "RNFR %s", FileList[i] );
							if( Ret < 0 || Ret >= 400 )
							{
								Msg[0] = Rn_Failed;
								Msg[4] = Ret;
								Msg[5] = i;
								MT_appl_write( Events.msg[1], 16, Msg, Global );
								break;
							}
							else
							{
								Ret = RCmd( CmdSocket, MsgHandle, CmdPuf, CMDPUFLEN, Events.msg[1], Global, "RNTO %s", FileListNew[i] );
								if( Ret < 0 || Ret >= 300 )
								{
									Msg[0] = Rn_Failed;
									Msg[4] = Ret;
									Msg[5] = i;
									MT_appl_write( Events.msg[1], 16, Msg, Global );
									break;
								}
								else
								{
									Msg[0] = Rn_File_Ok;
									Msg[5] = i;
									MT_appl_write( Events.msg[1], 16, Msg, Global );
								}
							}
							i++;
						}
						if( Ret >= 0 && Ret < 300 )
						{
							Msg[0] = Rn_Ok;
							MT_appl_write( Events.msg[1], 16, Msg, Global );
						}
						break;
					}
/* Dele_Msg -------------------------------------------------------------------*/
					case	Dele_Cmd:
					{
						BYTE	**FileList;
						WORD	i = 0;
						FileList = (BYTE **) *( LONG *)&( Events.msg[3] );
						Msg[1] = AppId;
						Msg[2] = 0;
						while( FileList[i] )
						{	
							Msg[0] = Dele_Update;
							Msg[5] = i;
							MT_appl_write( Events.msg[1], 16, Msg, Global );
							Ret = RCmd( CmdSocket, MsgHandle, CmdPuf, CMDPUFLEN, Events.msg[1], Global, "DELE %s", FileList[i] );
							if( Ret < 0 || Ret >= 300 )
							{
								Msg[0] = Dele_Failed;
								Msg[4] = Ret;
								Msg[5] = i;
								MT_appl_write( Events.msg[1], 16, Msg, Global );
								break;
							}
							else
							{
								Msg[0] = Dele_File_Ok;
								Msg[5] = i;
								MT_appl_write( Events.msg[1], 16, Msg, Global );
							}
							i++;
						}
						if( Ret >= 0 && Ret < 300 )
						{
							Msg[0] = Dele_Ok;
							Msg[1] = AppId;
							Msg[2] = 0;
							MT_appl_write( Events.msg[1], 16, Msg, Global );
						}
						break;
					}
/* Mkd_Msg --------------------------------------------------------------------*/
					case	Mkd_Cmd:
						Ret = RCmd( CmdSocket, MsgHandle, CmdPuf, CMDPUFLEN, Events.msg[1], Global, "MKD %s", (BYTE *) *( LONG *)&( Events.msg[3] ));
						Msg[1] = AppId;
						Msg[2] = 0;
						if( Ret < 0 || Ret >= 300 )
						{
							Msg[0] = Mkd_Failed;
							Msg[3] = Ret;
						}
						else
							Msg[0] = Mkd_Ok;
						MT_appl_write( Events.msg[1], 16, Msg, Global );
						break;
/* Rmd_Cmd --------------------------------------------------------------------*/
					case	Rmd_Cmd:
					{
						BYTE	**FileList;
						WORD	i = 0;
						FileList = (BYTE **) *( LONG *)&( Events.msg[3] );
						while( FileList[i] )
						{
							Msg[0] = Rmd_Update;
							Msg[1] = AppId;
							Msg[2] = 0;
							Msg[5] = i;
							MT_appl_write( Events.msg[1], 16, Msg, Global );
							Ret = RCmd( CmdSocket, MsgHandle, CmdPuf, CMDPUFLEN, Events.msg[1], Global, "RMD %s", FileList[i] );
							if( Ret < 0 || Ret >= 300 )
							{
								Msg[0] = Rmd_Failed;
								Msg[1] = AppId;
								Msg[2] = 0;
								Msg[4] = Ret;
								Msg[5] = i;
								MT_appl_write( Events.msg[1], 16, Msg, Global );
								break;
							}
							else
							{
								Msg[0] = Rmd_Dir_Ok;
								Msg[1] = AppId;
								Msg[2] = 0;
								Msg[5] = i;
								MT_appl_write( Events.msg[1], 16, Msg, Global );
							}
							i++;
						}
						if( Ret >= 0 && Ret < 300 )
						{
							Msg[0] = Rmd_Ok;
							Msg[1] = AppId;
							Msg[2] = 0;
							MT_appl_write( Events.msg[1], 16, Msg, Global );
						}
						break;
					}
/* Chmod_Msg ------------------------------------------------------------------*/
					case	Chmod_Cmd:
					{
						BYTE	**FileList, *Mode;
						WORD	i = 0;
						FileList = (BYTE **) *( LONG *)&( Events.msg[3] );
						Mode = (BYTE *) *( LONG *)&( Events.msg[5] );
						Msg[1] = AppId;
						Msg[2] = 0;
						while( FileList[i] )
						{	
							Msg[0] = Chmod_Update;
							Msg[5] = i;
							MT_appl_write( Events.msg[1], 16, Msg, Global );
							Ret = RCmd( CmdSocket, MsgHandle, CmdPuf, CMDPUFLEN, Events.msg[1], Global, "SITE CHMOD %s %s", Mode, FileList[i] );
							if( Ret < 0 || Ret >= 300 )
							{
								Msg[0] = Chmod_Failed;
								Msg[4] = Ret;
								Msg[5] = i;
								(BYTE *) *( LONG *)&( Msg[6] ) = Mode;
								MT_appl_write( Events.msg[1], 16, Msg, Global );
								break;
							}
							else
							{
								Msg[0] = Chmod_File_Ok;
								Msg[5] = i;
								MT_appl_write( Events.msg[1], 16, Msg, Global );
							}
							i++;
						}
						if( Ret >= 0 && Ret < 300 )
						{
							Msg[0] = Chmod_Ok;
							Msg[1] = AppId;
							Msg[2] = 0;
							(BYTE *) *( LONG *)&( Msg[6] ) = Mode;
							MT_appl_write( Events.msg[1], 16, Msg, Global );
						}
						break;
					}
/*-----------------------------------------------------------------------------*/
				}
			}
		}
#ifdef DEBUG
	DebugMsg( Global, "ThreadFtp [AppId = %i] beendet\n", AppId );
#endif
/*		MT_appl_exit( Global );	*/
		return( 0 );
	}
	else
	{
		Con( "Ftp: MT_appl_init() failed" ); crlf;
		return( -1 );
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* SetType                                                                                */
/*----------------------------------------------------------------------------------------*/ 
WORD	SetType( int CmdSocket, FILE *MsgHandle, char *CmdPuf, WORD TM, BYTE *FileName, WORD GemFtpAppId, WORD Global[15] )
{
	WORD	Ret = TM;
	if( TM == TT_Auto )
	{
		SUF_ITEM	*Item = SuffixList;
		BYTE	*Start;
		while( Item )
		{
			Start = FileName + strlen( FileName ) - strlen( Item->str );
			if( strcmp( Start, Item->str ) == 0 )
				break;
			Item = Item->next;
		}
		if( !Item )
			Ret = TransferTypeAuto;
		else
		{
			if( Item->mode == TT_Bin )
				Ret = TT_Bin;
			if( Item->mode == TT_Ascii )
				Ret = TT_Ascii;
		}
	}
	if( Ret == TT_Bin )
		RCmd( CmdSocket, MsgHandle, CmdPuf, CMDPUFLEN, GemFtpAppId, Global, "TYPE I");
	if( Ret == TT_Ascii )
		RCmd( CmdSocket, MsgHandle, CmdPuf, CMDPUFLEN, GemFtpAppId, Global, "TYPE A");
	return( Ret );
}
/*----------------------------------------------------------------------------------------*/ 
/* RCmd                                                                                   */
/*----------------------------------------------------------------------------------------*/ 
int	RCmd( int CmdSocket, FILE *MsgHandle, char *CmdPuf, long CmdPufLen, WORD GemFtpAppId, WORD Global[15], char *cmdspec, ...)
{
	va_list	ap;
	int		Ret;

	va_start( ap, cmdspec );
	SendCmd( CmdSocket, MsgHandle, cmdspec, ap );
	va_end(ap);
	Ret = GetResponse( CmdSocket, MsgHandle, CmdPuf, CmdPufLen, GemFtpAppId, Global );
	return( Ret );
}

/*----------------------------------------------------------------------------------------*/ 
/* RDataCmd                                                                               */
/*----------------------------------------------------------------------------------------*/ 
int	RDataCmd( int CmdSocket, FILE *MsgHandle, char *CmdPuf, long CmdPufLen, 
		          int (*WorkDataStream)( BYTE **DataPuf, FILE **Handle, LONG *DataPufLen, LONG *DataPufOffset, void **Work, WORD GemFtpAppId, WORD Global[15] ), void **Work, WORD GemFtpAppId, WORD Flag, WORD Global[15],
		          char *cmdspec, ...)
{
	va_list	ap;
	int		Ret, DataSocket, Socket;
	WORD		P = PasvFlag;

	va_start( ap, cmdspec );
	Ret = OpenDataConnection( CmdSocket, MsgHandle, CmdPuf, CmdPufLen, &Socket, PasvFlag, GemFtpAppId, Global );
	if( Ret >= 300 )	/* Anpassung an T-Online und germany.net */
	{
		Ret = OpenDataConnection( CmdSocket, MsgHandle, CmdPuf, CmdPufLen, &Socket, 0, GemFtpAppId, Global );
		P = 0;
	}

	if( Ret < 0 || Ret >= 300 )
		return( Ret );

	SendCmd( CmdSocket, MsgHandle, cmdspec, ap );
	
	Ret = GetResponse( CmdSocket, MsgHandle, CmdPuf, CmdPufLen, GemFtpAppId, Global );
#ifdef	RESUME
	if( Ret == 350 )
		Ret = GetResponse( CmdSocket, MsgHandle, CmdPuf, CmdPufLen, GemFtpAppId, Global );
#endif
	if( Ret < 0 || Ret >= 300 )
	{
		sclose( Socket );
		return( Ret );
	}

	{
		LONG	L = 0;
		sscanf( CmdPuf, "%*[^(](%li bytes)", &L );
		if( L > 0 )
		{
			WORD	Msg[8];
			Msg[0] = Retr_Get_Size;
			Msg[1] = Global[2];
			Msg[2] = 0;

			*(( LONG * ) &Msg[3] ) = L;
			MT_appl_write( GemFtpAppId, 16, Msg, Global );
		}
	}
	Ret = AcceptDataConnection( Socket, &DataSocket, P );
	if( Ret < 0 )
		return( Ret );
	Ret = GetDataStream( DataSocket, MsgHandle, WorkDataStream, Work, GemFtpAppId, Flag, Global );

	shutdown( DataSocket, 2 );
	sclose( DataSocket );

	if( Ret == ABORT )
	{
		Ret = RCmd( CmdSocket, MsgHandle, CmdPuf, CMDPUFLEN, GemFtpAppId, Global, "ABOR" );
		if( Ret == 226 )
			Ret = GetResponse( CmdSocket, MsgHandle, CmdPuf, CmdPufLen, GemFtpAppId, Global );
		return( ABORT );
	}

	if( Ret < 0 )
		return( Ret );

	Ret = GetResponse( CmdSocket, MsgHandle, CmdPuf, CmdPufLen, GemFtpAppId, Global );
	return( Ret );
}

/*----------------------------------------------------------------------------------------*/ 
/* TDataCmd                                                                               */
/*----------------------------------------------------------------------------------------*/ 
int	TDataCmd( int CmdSocket, FILE *MsgHandle, char *CmdPuf, long CmdPufLen, 
		          int (*WorkDataStream)(), void **Work, WORD GemFtpAppId, WORD Global[15],
		          char *cmdspec, ...)
{
	va_list	ap;
	int		Ret, DataSocket, Socket;
	WORD		P = PasvFlag;

	va_start( ap, cmdspec );

	Ret = OpenDataConnection( CmdSocket, MsgHandle, CmdPuf, CmdPufLen, &Socket, PasvFlag, GemFtpAppId, Global );
	if( Ret >= 300 )	/* Anpassung an T-Online und germandy.net */
	{
		Ret = OpenDataConnection( CmdSocket, MsgHandle, CmdPuf, CmdPufLen, &Socket, 0, GemFtpAppId, Global );
		P = 0;
	}
	if( Ret < 0 || Ret >= 300 )
		return( Ret );
	
	SendCmd( CmdSocket, MsgHandle, cmdspec, ap );
	
	Ret = GetResponse( CmdSocket, MsgHandle, CmdPuf, CmdPufLen, GemFtpAppId, Global );
	if( Ret < 0 || Ret >= 300 )
	{
		sclose( Socket );
		return( Ret );
	}

	Ret = AcceptDataConnection( Socket, &DataSocket, P );
	if( Ret < 0 )
		return( Ret );

	Ret = PutDataStream( DataSocket, WorkDataStream, Work, GemFtpAppId, Global );

	shutdown( DataSocket, 2 );
	sclose( DataSocket );

	if( Ret == ABORT )
	{
		GetResponse( CmdSocket, MsgHandle, CmdPuf, CmdPufLen, GemFtpAppId, Global );
		RCmd( CmdSocket, MsgHandle, CmdPuf, CMDPUFLEN, GemFtpAppId, Global, "ABOR" );
		return( ABORT );
	}

	if( Ret < 0 )
		return( Ret );

	Ret = GetResponse( CmdSocket, MsgHandle, CmdPuf, CmdPufLen, GemFtpAppId, Global );
	return( Ret );

}
/*----------------------------------------------------------------------------------------*/ 
/* OpenDataConnection                                                                     */
/*----------------------------------------------------------------------------------------*/ 
int	OpenDataConnection( int CmdSocket, FILE *MsgHandle, char *CmdPuf, long CmdPufLen, int *Socket, WORD PasvFlag, WORD GemFtpAppId, WORD Global[15] )
{
	sockaddr_in	Saddr;
	int			LenSaddr, Ret;

	if( PasvFlag )
	{
		Ret = GetPort( CmdSocket, MsgHandle, CmdPuf, CmdPufLen, &Saddr, GemFtpAppId, Global );
		if( Ret < 0 || Ret >= 300 )
			return( Ret );
		*Socket = socket( AF_INET, SOCK_STREAM, 0 );
		if( *Socket < 0 )
			return( *Socket );
		if(( Ret = connect( *Socket, &Saddr, (int) sizeof( sockaddr_in ))) != E_OK )
			return( Ret );
		return( Ret );
	}
	else
	{
		*Socket = socket( AF_INET, SOCK_STREAM, 0 );
		if( *Socket < 0 )
			return( *Socket );

		SetLinger( *Socket );

		Saddr.sin_family = AF_INET;
		Saddr.sin_addr = gethostid();

/* Ich weiž nich wieso, aber IConnect mag es anscheinend lieber, den Port
   selbst zu vergeben. Tritt auf, wenn Fiffi zweimal w„hrend der selben 
   IConnect-Verbindung gestartet wird. */
		do
		{
			Saddr.sin_port = DataPort++;
			if( DataPort > DataPortH )
				DataPort = DataPortL;
		}
		while( bind( *Socket, &Saddr, ( int ) sizeof( sockaddr_in )) == EADDRINUSE );
		Ret = listen( *Socket, 1 );
		if( Ret < 0 )
		{
			sclose( *Socket );
			return( Ret );
		}

		LenSaddr = ( int ) sizeof( sockaddr_in );
		getsockname( *Socket, &Saddr, &LenSaddr );
		Ret = SendPort( CmdSocket, MsgHandle, CmdPuf, CmdPufLen, &Saddr, GemFtpAppId, Global );
		if( Ret < 0 || Ret >= 300 )
			sclose( *Socket );
		return( Ret );
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* AcceptDataConnection                                                                   */
/*----------------------------------------------------------------------------------------*/ 
int	AcceptDataConnection( int Socket, int *DataSocket, WORD PasvFlag )
{
	if( PasvFlag )
	{
		*DataSocket = Socket;
		return( *DataSocket );
	}
	else
	{
		sockaddr_in	Saddr;
		int	len = ( int ) sizeof( sockaddr_in );
		*DataSocket = accept( Socket, &Saddr, &len );
		sclose( Socket );
		if( *DataSocket < 0 )
			return( *DataSocket );

		SetLinger( *DataSocket );
		return( *DataSocket );
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* SetLinger                                                                              */
/*----------------------------------------------------------------------------------------*/ 
void	SetLinger( int Socket )
{
/*	linger	Linger;
	int		LingerLen;
	LingerLen = (int) sizeof( linger );
	Linger.l_onoff = 1;
	Linger.l_linger = 0;
	setsockopt( Socket, SOL_SOCKET, SO_LINGER, &Linger, &LingerLen);	*/
}

/*----------------------------------------------------------------------------------------*/ 
/* GetPort                                                                                */
/*----------------------------------------------------------------------------------------*/ 
int	GetPort( int CmdSocket, FILE *MsgHandle, char *CmdPuf, long CmdPufLen, sockaddr_in *Saddr, WORD GemFtpAppId, WORD Global[15] )
{
	int				i, Ret, D[6];
	unsigned char	N[6];
	char				*Pos;
	
	Ret = RCmd( CmdSocket, MsgHandle, CmdPuf, CmdPufLen, GemFtpAppId, Global, "PASV" );
	if( Ret == 227 )
	{
		for( Pos = &CmdPuf[3]; ; Pos++ )
		{
			if( *Pos == '\0' )
				return( ERROR );
			if( isdigit( *Pos ))
				break;
		}
		sscanf( Pos, "%d,%d,%d,%d,%d,%d", &D[0], &D[1], &D[2], &D[3], &D[4], &D[5] );
		for( i = 0; i < 6; i++ )
			N[i] = (unsigned char) ( D[i] & 0xff );
		Saddr->sin_family = AF_INET;
		memcpy( &Saddr->sin_addr, &N[0], (size_t) 4 );
		memcpy( &Saddr->sin_port, &N[4], (size_t) 2 );
		return( Ret );
	}
	else
		return( Ret );
}
/*----------------------------------------------------------------------------------------*/ 
/* SendPort                                                                               */
/*----------------------------------------------------------------------------------------*/ 
int	SendPort( int CmdSocket, FILE *MsgHandle, char *CmdPuf, long CmdPufLen, sockaddr_in *Saddr, WORD GemFtpAppId, WORD Global[15] )
{
	char	*a, *p;
	int	Ret;
	
	a = (char *) &Saddr->sin_addr;
	p = (char *) &Saddr->sin_port;
#define UC(x) (int) (((int) x) & 0xff)

	Ret = RCmd( CmdSocket, MsgHandle, CmdPuf, CmdPufLen, GemFtpAppId, Global, "PORT %d,%d,%d,%d,%d,%d",
	            UC(a[0]), UC(a[1]), UC(a[2]), UC(a[3]), UC(p[0]), UC(p[1]));
	return( Ret );
}

/*----------------------------------------------------------------------------------------*/ 
/* SendCmd                                                                            */
/*----------------------------------------------------------------------------------------*/ 
void	SendCmd( int CmdSocket, FILE *MsgHandle, char *cmdspec, va_list ap )
{
	char	command[256];

	vsprintf(command, cmdspec, ap);
	strcat( command, "\r\n" );
	send( CmdSocket, command, ( int ) strlen( command ), 0 );
	if( MsgHandle )
	{
		if( strncmp( command, "PASS ", strlen( "PASS" )) == 0 )
		{
			WORD	i;
			for( i = ( WORD ) strlen( "PASS " ); i < ( WORD ) strlen( command ) - 2; i++ )
				command[i] = '*';
		}
		fwrite( command, sizeof( char ), strlen( command ), MsgHandle );
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* GetResponse                                                                            */
/*----------------------------------------------------------------------------------------*/ 
int	GetResponse( int CmdSocket, FILE *MsgHandle, char *CmdPuf, long CmdPufLen, WORD GemFtpAppId, WORD Global[15] )
{
	WORD	Msg[8];
	long	Ret;
	memset( CmdPuf, 0, CmdPufLen - 1 );
	do
	{
		sfcntl( CmdSocket, F_SETFL, O_NONBLOCK );
		while(( Ret = recv( CmdSocket, CmdPuf, CmdPufLen - 1, MSG_PEEK )) == EWOULDBLOCK )
		{
			if( MT_appl_read( -1, 16, Msg, Global ) && 
			    Msg[0] == Abor_Cmd && Msg[1] == GemFtpAppId )
			    {
					sfcntl( CmdSocket, F_SETFL, O_NONBLOCK );
					return( ABORT );
			    }
		
		}
		sfcntl( CmdSocket, F_SETFL, O_NONBLOCK );

		if( Ret >= 0 )
		{
			char	*t = CmdPuf;
			CmdPuf[Ret] = 0;
			while( t )
			{
				if( isdigit( *t) &&
				    isdigit( *( t + 1 )) &&
				    isdigit( *( t + 2 )) &&
				    *(t + 3 ) == ' ' && strstr( t, "\n" ))
				{
					Ret = recv( CmdSocket, CmdPuf, strstr( t, "\n" ) + 1 - CmdPuf, 0 );
					if( MsgHandle )
						fwrite( CmdPuf, sizeof( char ), Ret, MsgHandle );
					return( atoi( t ));
				}
				t = strstr( t, "\n" );
				if( t )
					t += 1;
			}
		}
	}
	while( Ret >= 0 );
	return(( int ) Ret );
}

/*----------------------------------------------------------------------------------------*/ 
/* GetDataStream                                                                          */
/*----------------------------------------------------------------------------------------*/ 
int	GetDataStream( int DataSocket, FILE *MsgHandle,
		int (*WorkDataStream)( FILE *MsgHandle, FILE **Handle, BYTE **DataPuf, LONG *DataPufLen, LONG *DataPufOffset, void **Work, WORD GemFtpAppId, WORD Flag, WORD Global[15] ), 
		void **Work, WORD GemFtpAppId, WORD Flag, WORD Global[15] )
{
	long	DataPufLen = 0, DataPufOffset = 0, Ret;
	char	*DataPuf = NULL;
	FILE	*Handle = NULL;
	WORD	Msg[8];

	sfcntl( DataSocket, F_SETFL, O_NONBLOCK );
	do
	{
		Ret = WorkDataStream( MsgHandle, &Handle, &DataPuf, &DataPufLen, &DataPufOffset, Work, GemFtpAppId, Flag, Global );
		if( Ret != E_OK )
			break;
		do
		{
			if( MT_appl_read( -1, 16, Msg, Global ) && 
			    Msg[0] == Abor_Cmd && Msg[1] == GemFtpAppId )
			{
				Ret = ABORT;
			}
			else
				Ret = recv( DataSocket, DataPuf + DataPufOffset, DataPufLen - DataPufOffset, 0 );
		}
		while( Ret == EWOULDBLOCK );
		DataPufLen = Ret;
	}
	while( Ret >= 0 );
	sfcntl( DataSocket, F_SETFL, 0 );

	if( Ret == ECONNRESET || Ret == -1 )
	{
		long	r = 0;
		WorkDataStream( MsgHandle, &Handle, &DataPuf, &r, &DataPufOffset, Work, GemFtpAppId, Flag, Global );
		return( 0 );
	}
	if( Ret == ABORT )
	{
		long	r = 0;
		WorkDataStream( MsgHandle, &Handle, &DataPuf, &r, &DataPufOffset, Work, GemFtpAppId, Flag, Global );
		return(( int ) Ret );
	}
	return(( int ) Ret );
}

/*----------------------------------------------------------------------------------------*/ 
/* PutDataStream                                                                          */
/*----------------------------------------------------------------------------------------*/ 
int	PutDataStream( int DataSocket, 
		int (*WorkDataStream)( FILE **Handle, BYTE **DataPuf, LONG *DataPufLen, LONG *DataPufOffset, void **Work, WORD GemFtpAppId, WORD Global[15] ), 
		void **Work, WORD GemFtpAppId, WORD Global[15] )
{
	long	DataPufLen, PufOffset, Ret = 0, BytesToTx;
	char	*DataPuf = NULL;
	int	OptLen = ( int ) sizeof( long );
	FILE	*Handle = NULL;
	while( 1 )
	{
		Ret = WorkDataStream( &Handle, &DataPuf, &DataPufLen, &PufOffset, Work, GemFtpAppId, Global );
		if( Ret == EOF )
		{
			do
			{
				getsockopt( DataSocket, SOL_SOCKET, SO_SNDBUF, &BytesToTx, &OptLen );
			}
			while( BytesToTx > 0 );
			MT_evnt_timer( 1000L, Global );
			return( E_OK );
		}
		if( Ret != E_OK )
			break;
		if(( Ret = send( DataSocket, DataPuf, ( int ) DataPufLen, 0 )) < 0 )
			break;
		do
		{
			getsockopt( DataSocket, SOL_SOCKET, SO_SNDBUF, &BytesToTx, &OptLen );
		}
/*		while( BytesToTx > 0 );	*/
		while( BytesToTx > DataPufLen );
		PufOffset += DataPufLen;
	}
	return((int) Ret );
}

#ifdef	V110
void	ShortLogFilename( BYTE	*Filename )
{
	LONG	MaxLen;
	BYTE	*StartFilename;
	BYTE	Path[256];

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
#endif