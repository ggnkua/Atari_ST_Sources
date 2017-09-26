#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<TOS.H>
#include	<VDICOL.H>
#include	<MT_AES.H>
#include	<STDDEF.H>
#include	<STRING.H>
#include	<STDIO.H>
#include	<STDLIB.H>

#include	<atarierr.h>

#include	"main.h"
#include	RSCHEADER
#include	"Emulator.h"
#ifdef	IRC_CLIENT
#include	"Irc.h"
#endif
#ifdef	TELNET_CLIENT
#include	"Telnet.h"
#endif
#include	"WDialog\Hotlist.h"
#include	"Window.h"

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern OBJECT	**TreeAddr;

extern WORD	IConnectFlag;
extern WORD PingFlag;
extern WORD	SaveFlag;
extern volatile WORD	RecPufLen;

extern HT_ITEM	*HtList;
extern OBJECT *HtPopup;

#ifdef	IRC_CLIENT
extern BYTE	*DownloadPath, *UploadPath, *LogPath;
extern WORD IrcFlags;
#endif

#ifdef	TELNET_CLIENT
extern BYTE	*RxPath, *RxPara, *TxPath, *TxPara;
extern WORD	AppendProtocolFlag;
extern BYTE	*ProtocolPath;
#endif

/*-----------------------------------------------------------------------------*/
/* Globale Variablen                                                           */
/*-----------------------------------------------------------------------------*/
#ifdef	IRC_CLIENT
IRC	DefaultIrc =
{
	NULL,
	6667,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,

	1,
	10,
	1,
	10,
	1,
	10,
	1,
	10,

	1,
	10,
	1,
	0,
	
	1,
	10,
	1,
	0,

	100,
	1,
	1,
	0,
};
#endif
#ifdef	TELNET_CLIENT
TELNET	DefaultTelnet =
{
	NULL,
	23,
	1,
	1,
	0,
	9L << 16,
	0,
	NVT,
	{ 80, 25 },
	{ 3, 3 },
	0,
	25,
	0,
	0,
	0
};
#endif

/*-----------------------------------------------------------------------------*/
/* Lokale Variablen                                                            */
/*-----------------------------------------------------------------------------*/
static BYTE	*HomePathConfig = NULL, *DefaultPathConfig = NULL;
static BYTE	*PathConfig = INFNAME;

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
static void	GetFilenameConfig( void );

WORD	WriteConfig( WORD Global[15] )
{
	FILE	*File = NULL;
	GetFilenameConfig();
	if( DefaultPathConfig )
		File = fopen( DefaultPathConfig, "w" );
	else	if( HomePathConfig )
		File = fopen( HomePathConfig, "w" );
	else
		File = fopen( PathConfig, "w" );

	if( File )
	{
		HT_ITEM	*Tmp = HtList;
/* --------------------------------------------------------------------------*/
		fprintf( File, "Id = %s %s\n", APPNAME, VERSION );
		fprintf( File, "Ping = %i\n", PingFlag );
		fprintf( File, "RecPufLen = %i\n", RecPufLen );
		fprintf( File, "SaveConfig = %i\n", SaveFlag );
		fprintf( File, "IConnect = %i\n", IConnectFlag );
#ifdef	IRC_CLIENT
		if( DownloadPath )
			fprintf( File, "Download = %s\n", DownloadPath );
		if( UploadPath )
			fprintf( File, "Upload = %s\n", UploadPath );
		if( LogPath )
			fprintf( File, "Log = %s\n", LogPath );
		fprintf( File, "IrcFlags = %i\n", IrcFlags );
		fprintf( File, "OutputFont = %i, %i\n", DefaultIrc.OutputFontId, DefaultIrc.OutputFontHt );
		fprintf( File, "InputFont = %i, %i\n", DefaultIrc.InputFontId, DefaultIrc.InputFontHt );
		fprintf( File, "ChannelFont = %i, %i\n", DefaultIrc.ChannelFontId, DefaultIrc.ChannelFontHt );
		fprintf( File, "UserFont = %i, %i\n", DefaultIrc.UserFontId, DefaultIrc.UserFontHt );
		{
			WORD	i;
			fprintf( File, "Colours = " );
			for( i = 0; i < COLOUR_MAX - 1; i++ )
				fprintf( File, "%i, ", DefaultIrc.ColourTable[i] );
			fprintf( File, "%i\n", DefaultIrc.ColourTable[i] );
		}
		fprintf( File, "IrcPort = %u\n", DefaultIrc.Port );
#ifndef	DEMO
		if( DefaultIrc.Nickname )
			fprintf( File, "Nickname = %s\n", DefaultIrc.Nickname );
		if( DefaultIrc.Username )
			fprintf( File, "Username = %s\n", DefaultIrc.Username );
		if( DefaultIrc.Realname )
			fprintf( File, "Realname = %s\n", DefaultIrc.Realname );
#endif
		if( DefaultIrc.Autojoin )
			fprintf( File, "Autojoin = %s\n", DefaultIrc.Autojoin );
		fprintf( File, "PingPong = %i\n", DefaultIrc.PingPong );
		fprintf( File, "CtcpReply = %i\n", DefaultIrc.CtcpReply );
		fprintf( File, "LogFlag = %i\n", DefaultIrc.LogFlag );
#ifndef	DEMO
		while( Tmp )
		{
			fprintf( File, "Hotlist = %s\n", Tmp->Name );
			fprintf( File, "%s\n", Tmp->Irc->Host );
			fprintf( File, "%s\n", Tmp->Irc->Nickname );
			fprintf( File, "%s\n", Tmp->Irc->Username );
			fprintf( File, "%s\n", Tmp->Irc->Realname );
			fprintf( File, "%s\n", Tmp->Irc->Password ? Tmp->Irc->Password : "" );
			fprintf( File, "%s\n", Tmp->Irc->Autojoin ? Tmp->Irc->Autojoin : "" );
			fprintf( File, "%u, %i, %i, %i, %i, %i, %i, %i, %i, %i, %li, %i, %i\n", Tmp->Irc->Port, Tmp->Irc->InputFontId, Tmp->Irc->InputFontHt, Tmp->Irc->OutputFontId, Tmp->Irc->OutputFontHt, Tmp->Irc->ChannelFontId, Tmp->Irc->ChannelFontHt, Tmp->Irc->UserFontId, Tmp->Irc->UserFontHt, Tmp->Irc->PingPong, Tmp->Irc->nLines, Tmp->Irc->LogFlag, Tmp->Irc->CtcpReply );
			{
				WORD	i;
				for( i = 0; i < COLOUR_MAX - 1; i++ )
					fprintf( File, "%i, ", Tmp->Irc->ColourTable[i] );
				fprintf( File, "%i\n", Tmp->Irc->ColourTable[i] );
			}
			Tmp = Tmp->next;
		}
#endif
#endif
#ifdef	TELNET_CLIENT
		fprintf( File, "Font = %i, %i, %i, %i, %i\n", DefaultTelnet.FontId, ( WORD )( DefaultTelnet.FontPt >> 16 ), DefaultTelnet.FontColor, DefaultTelnet.FontEffects, DefaultTelnet.WindowColor );

		{
			GRECT	Rect;
			WORD	i = 0;
			while( GetInitPosWindow( WIN_TEXT_WINDOW, i++, &Rect ) == E_OK )
				fprintf( File, "TextWindow = %i, %i, %i, %i\n", Rect.g_x, Rect.g_y, Rect.g_w, Rect.g_h );
		}

		fprintf( File, "TelnetPort = %u\n", DefaultTelnet.Port );
		fprintf( File, "Emulation = %i\n", DefaultTelnet.EmuType );
		fprintf( File, "Columns = %li\n", DefaultTelnet.Terminal.x );
		fprintf( File, "Rows = %li\n", DefaultTelnet.Terminal.y );
		fprintf( File, "HT = %li\n", DefaultTelnet.Tab.x );
		fprintf( File, "VT = %li\n", DefaultTelnet.Tab.y );
		fprintf( File, "KeyFlag = %i\n", DefaultTelnet.KeyFlag );
		fprintf( File, "PufLines = %li\n", DefaultTelnet.PufLines );
		fprintf( File, "KeyExport = %i\n", DefaultTelnet.KeyExport );
		fprintf( File, "KeyImport = %i\n", DefaultTelnet.KeyImport );
		fprintf( File, "ProtocolFlag = %i\n", DefaultTelnet.ProtocolFlag );
		if( RxPath )
			fprintf( File, "RxPath = %s\n", RxPath );
		if( RxPara )
			fprintf( File, "RxParameter = %s\n", RxPara );
		if( TxPath )
			fprintf( File, "TxPath = %s\n", TxPath );
		if( TxPara )
			fprintf( File, "TxParameter = %s\n", TxPara );
		fprintf( File, "AppendProtocol = %i\n", AppendProtocolFlag );
		if( ProtocolPath )
			fprintf( File, "ProtocolPath = %s\n", ProtocolPath );

/* --------------------------------------------------------------------------*/
		while( Tmp )
		{
			fprintf( File, "Hotlist = %s\n", Tmp->Name );
			fprintf( File, "%s\n", Tmp->Telnet->Host );
			fprintf( File, "%u, %i, %li, %i, %i, %i, %i, %li, %li, %li, %li, %i, %li, %i, %i, %i\n", Tmp->Telnet->Port, Tmp->Telnet->FontId, Tmp->Telnet->FontPt >> 16, Tmp->Telnet->FontColor, Tmp->Telnet->FontEffects, Tmp->Telnet->WindowColor, Tmp->Telnet->EmuType, Tmp->Telnet->Terminal.x, Tmp->Telnet->Terminal.y, Tmp->Telnet->Tab.x, Tmp->Telnet->Tab.y, Tmp->Telnet->KeyFlag, Tmp->Telnet->PufLines, Tmp->Telnet->KeyExport, Tmp->Telnet->KeyImport, Tmp->Telnet->ProtocolFlag ); 
			Tmp = Tmp->next;
		}
/* --------------------------------------------------------------------------*/
#endif
		fclose( File );
		return( E_OK );
	}
	MT_form_alert( 1, TreeAddr[ALERTS][ERROR_WRITING_CONFIG].ob_spec.free_string, Global );
	return( ERROR );
}

void	ReadConfig( void )
{
	XATTR	Xattr;
	FILE	*File = NULL;

	GetFilenameConfig();

	if( DefaultPathConfig && Fxattr( 0, DefaultPathConfig, &Xattr ) == E_OK )
		File = fopen( DefaultPathConfig, "r" );
	else	if( HomePathConfig && Fxattr( 0, HomePathConfig, &Xattr ) == E_OK )
		File = fopen( HomePathConfig, "r" );
	else	if( Fxattr( 0, PathConfig, &Xattr ) == E_OK )
		File = fopen( PathConfig, "r" );
	if( File )
	{
		BYTE	*ConfigPuf = calloc( Xattr.size + 1, sizeof( BYTE )), *Pos;
		HT_ITEM	*HtItem;
#ifdef	IRC_CLIENT
		IRC	*Irc;
#endif
#ifdef	TELNET_CLIENT
		TELNET	*Telnet;
#endif
		int		Len;
		BYTE	Line1[256], Line2[256];
		double	Version = 0;
		if( ConfigPuf )
		{
			fread( ConfigPuf, sizeof( BYTE ), Xattr.size, File );

/* --------------------------------------------------------------------------*/
			if( strstr( ConfigPuf, "IConnect = " ) != NULL )
				sscanf( strstr( ConfigPuf, "IConnect = " ), "IConnect = %i\n", &IConnectFlag );
			if( strstr( ConfigPuf, "SaveConfig = " ) != NULL )
				sscanf( strstr( ConfigPuf, "SaveConfig = " ), "SaveConfig = %i\n", &SaveFlag );
			if( strstr( ConfigPuf, "RecPufLen = " ) != NULL )
				sscanf( strstr( ConfigPuf, "RecPufLen = " ), "RecPufLen = %i\n", &RecPufLen );

#ifdef	IRC_CLIENT
			if( strstr( ConfigPuf, "Id = " ) != NULL )
				sscanf( strstr( ConfigPuf, "Id = " ), "Id = %*s %lf\n", &Version );
			if( strstr( ConfigPuf, "Download = " ) != NULL )
			{
				WORD	Len;
				Len = ( WORD ) ( strchr( strstr( ConfigPuf, "Download = " ), '\n' ) - strstr( ConfigPuf, "Download = " ) + 1 );
				DownloadPath = malloc( Len );
				if( DownloadPath )
					sscanf( strstr( ConfigPuf, "Download = "), "Download = %s\n", DownloadPath );
			}
			if( strstr( ConfigPuf, "Upload = " ) != NULL )
			{
				WORD	Len;
				Len = ( WORD ) ( strchr( strstr( ConfigPuf, "Upload = " ), '\n' ) - strstr( ConfigPuf, "Upload = " ) + 1 );
				UploadPath = malloc( Len );
				if( UploadPath )
					sscanf( strstr( ConfigPuf, "Upload = "), "Upload = %s\n", UploadPath );
			}
			if( strstr( ConfigPuf, "Log = " ) != NULL )
			{
				WORD	Len;
				Len = ( WORD ) ( strchr( strstr( ConfigPuf, "Log = " ), '\n' ) - strstr( ConfigPuf, "Log = " ) + 1 );
				LogPath = malloc( Len );
				if( LogPath )
					sscanf( strstr( ConfigPuf, "Log = "), "Log = %s\n", LogPath );
			}
			if( strstr( ConfigPuf, "OutputFont = " ) != NULL )
				sscanf( strstr( ConfigPuf, "OutputFont = " ), "OutputFont = %i, %i\n", &DefaultIrc.OutputFontId, &DefaultIrc.OutputFontHt );
			if( strstr( ConfigPuf, "InputFont = " ) != NULL )
				sscanf( strstr( ConfigPuf, "InputFont = " ), "InputFont = %i, %i\n", &DefaultIrc.InputFontId, &DefaultIrc.InputFontHt );
			if( strstr( ConfigPuf, "ChannelFont = " ) != NULL )
				sscanf( strstr( ConfigPuf, "ChannelFont = " ), "ChannelFont = %i, %i\n", &DefaultIrc.ChannelFontId, &DefaultIrc.ChannelFontHt );
			if( strstr( ConfigPuf, "UserFont = " ) != NULL )
				sscanf( strstr( ConfigPuf, "UserFont = " ), "UserFont = %i, %i\n", &DefaultIrc.UserFontId, &DefaultIrc.UserFontHt );
			if( strstr( ConfigPuf, "Colours = " ) != NULL )
			{
				BYTE	*Pos = strstr( ConfigPuf, "Colours = " ) + strlen( "Colours = " );
				ReadColourTable( Version, Pos, DefaultIrc.ColourTable );
			}
			if( strstr( ConfigPuf, "PingPong = " ) != NULL )
				sscanf( strstr( ConfigPuf, "PingPong = " ), "PingPong = %i\n", &DefaultIrc.PingPong );
			if( strstr( ConfigPuf, "CtcpReply = " ) != NULL )
				sscanf( strstr( ConfigPuf, "CtcpReply = " ), "CtcpReply = %i\n", &DefaultIrc.CtcpReply );
			if( strstr( ConfigPuf, "LogFlag = " ) != NULL )
				sscanf( strstr( ConfigPuf, "LogFlag = " ), "LogFlag = %i\n", &DefaultIrc.LogFlag );
			if( strstr( ConfigPuf, "IrcFlags = " ) != NULL )
				sscanf( strstr( ConfigPuf, "IrcFlags = " ), "IrcFlags = %i\n", &IrcFlags );

			if( strstr( ConfigPuf, "IrcPort = " ) != NULL )
				sscanf( strstr( ConfigPuf, "IrcPort = " ), "IrcPort = %u\n", &DefaultIrc.Port );

#ifndef	DEMO
			if( strstr( ConfigPuf, "Nickname = " ) != NULL )
			{
				WORD	Len;
				Len = ( WORD ) ( strchr( strstr( ConfigPuf, "Nickname = " ), '\n' ) - strstr( ConfigPuf, "Nickname = " ) + 1 );
				DefaultIrc.Nickname = malloc( Len );
				if( DefaultIrc.Nickname )
					sscanf( strstr( ConfigPuf, "Nickname = "), "Nickname = %s\n", DefaultIrc.Nickname );
			}
			if( strstr( ConfigPuf, "Username = " ) != NULL )
			{
				WORD	Len;
				Len = ( WORD ) ( strchr( strstr( ConfigPuf, "Username = " ), '\n' ) - strstr( ConfigPuf, "Username = " ) + 1 );
				DefaultIrc.Username = malloc( Len );
				if( DefaultIrc.Username )
					sscanf( strstr( ConfigPuf, "Username = "), "Username = %s\n", DefaultIrc.Username );
			}
			if( strstr( ConfigPuf, "Realname = " ) != NULL )
			{
				WORD	Len;
				Len = ( WORD ) ( strchr( strstr( ConfigPuf, "Realname = " ), '\n' ) - strstr( ConfigPuf, "Realname = " ) + 1 );
				DefaultIrc.Realname = malloc( Len );
				if( DefaultIrc.Realname )
					sscanf( strstr( ConfigPuf, "Realname = "), "Realname = %[^\n]", DefaultIrc.Realname );
			}
#endif
			if( strstr( ConfigPuf, "Autojoin = " ) != NULL )
			{
				WORD	Len;
				Len = ( WORD ) ( strchr( strstr( ConfigPuf, "Autojoin = " ), '\n' ) - strstr( ConfigPuf, "Autojoin = " ) + 1 );
				DefaultIrc.Autojoin = malloc( Len );
				if( DefaultIrc.Autojoin )
					sscanf( strstr( ConfigPuf, "Autojoin = "), "Autojoin = %s\n", DefaultIrc.Autojoin );
			}
#ifndef	DEMO
			Pos = strstr( ConfigPuf, "Hotlist = " );
			while( Pos )
			{
				Irc = malloc( sizeof( IRC ));
				HtItem = malloc( sizeof( HT_ITEM ));
				if( !Irc || !HtItem )
					break;
				HtItem->Irc = Irc;
				sscanf( Pos, "Hotlist = %[^\n]%n", Line1, &Len );
				Pos += Len + 1;
				HtItem->Name = strdup( Line1 );
				if( !HtItem->Name )
					break;
				sscanf( Pos, "%[^\n]%n", Line1, &Len );
				Pos += Len + 1;
				Irc->Host = strdup( Line1 );
				if( !Irc->Host )
					break;
				sscanf( Pos, "%[^\n]%n", Line1, &Len );
				Pos += Len + 1;
				Irc->Nickname = strdup( Line1 );
				if( !Irc->Nickname )
					break;
				sscanf( Pos, "%[^\n]%n", Line1, &Len );
				Pos += Len + 1;
				Irc->Username = strdup( Line1 );
				if( !Irc->Username )
					break;
				sscanf( Pos, "%[^\n]%n", Line1, &Len );
				Pos += Len + 1;
				Irc->Realname = strdup( Line1 );
				if( !Irc->Realname )
					break;
				sscanf( Pos, "%[^\n]%n", Line1, &Len );
				Pos += Len + 1;
				if( strlen( Line1 ))
				{
					Irc->Password = strdup( Line1 );
					if( !Irc->Password )
						break;
				}
				else
					Irc->Password = NULL;
				if( Version >= 0.29 )
				{
					sscanf( Pos, "%[^\n]%n", Line1, &Len );
					Pos += Len + 1;
					if( strlen( Line1 ))
					{
						Irc->Autojoin = strdup( Line1 );
						if( !Irc->Autojoin )
							break;
					}
					else
						Irc->Autojoin = NULL;
				}
				else
					Irc->Autojoin = NULL;
				if( Version < 0.30 )
					sscanf( Pos, "%u, %i, %i, %i, %i, %i, %i, %i, %i, %i, %*i, %*i, %li\n%n", &Irc->Port, &Irc->InputFontId, &Irc->InputFontHt, &Irc->OutputFontId, &Irc->OutputFontHt, &Irc->ChannelFontId, &Irc->ChannelFontHt, &Irc->UserFontId, &Irc->UserFontHt, &Irc->PingPong, &Irc->nLines, &Len );
				else	if( Version < 1.1 )
				{
					sscanf( Pos, "%u, %i, %i, %i, %i, %i, %i, %i, %i, %i, %li\n%n", &Irc->Port, &Irc->InputFontId, &Irc->InputFontHt, &Irc->OutputFontId, &Irc->OutputFontHt, &Irc->ChannelFontId, &Irc->ChannelFontHt, &Irc->UserFontId, &Irc->UserFontHt, &Irc->PingPong, &Irc->nLines, &Len );
					Irc->LogFlag = 0;
					Irc->CtcpReply = 1;
				}
				else
					sscanf( Pos, "%u, %i, %i, %i, %i, %i, %i, %i, %i, %i, %li, %i, %i\n%n", &Irc->Port, &Irc->InputFontId, &Irc->InputFontHt, &Irc->OutputFontId, &Irc->OutputFontHt, &Irc->ChannelFontId, &Irc->ChannelFontHt, &Irc->UserFontId, &Irc->UserFontHt, &Irc->PingPong, &Irc->nLines, &Irc->LogFlag, &Irc->CtcpReply, &Len );
				Pos += Len;
				{
					BYTE	*Pos2 = Pos;
					ReadColourTable( Version, Pos2, Irc->ColourTable );
				}
/*				{
					WORD	i, j = COLOUR_MAX;

					if( Version >= 0.12 && Version < 0.21 )
						j = 13;
					if( Version >= 0.21 && Version < 1.1 )
						j = 16;
					
					for( i = 0; i < j; i++ )
					{
						Irc->ColourTable[i] = atoi( Pos );
						while( *Pos != '\n' )
						{
							if( *Pos == ',' )
								break;
							Pos++;
						}
						if( *Pos != ',' )
							break;
						Pos++;
					}
				}
*/				InsertHtItem( HtItem, &HtList );
				Pos = strstr( Pos, "Hotlist = " );
			}
			UpdateHotlistPopup( HtList, &HtPopup );
#endif
#endif
#ifdef	TELNET_CLIENT
			if( strstr( ConfigPuf, "Ping = " ) != NULL )
				sscanf( strstr( ConfigPuf, "Ping = " ), "Ping = %i\n", &PingFlag );

			if( strstr( ConfigPuf, "Font = " ) != NULL )
			{
				sscanf( strstr( ConfigPuf, "Font = " ), "Font = %i, %li, %i, %i, %i\n", &DefaultTelnet.FontId, &DefaultTelnet.FontPt, &DefaultTelnet.FontColor, &DefaultTelnet.FontEffects, &DefaultTelnet.WindowColor );
				DefaultTelnet.FontPt = ( DefaultTelnet.FontPt << 16 );
			}

			{
				BYTE	*Tmp = ConfigPuf;
				WORD	i = 0;
				GRECT	Rect;
				while(( Tmp = strstr( Tmp, "TextWindow = " )) != NULL )
				{
					sscanf( Tmp, "TextWindow = %i, %i, %i, %i\n", &Rect.g_x, &Rect.g_y, &Rect.g_w, &Rect.g_h );
					SetInitPosWindow( WIN_TEXT_WINDOW, &Rect );
					i++;	Tmp++;
				}
			}
			
			if( strstr( ConfigPuf, "TelnetPort = " ) != NULL )
				sscanf( strstr( ConfigPuf, "TelnetPort = " ), "TelnetPort = %u\n", &DefaultTelnet.Port );
			if( strstr( ConfigPuf, "Emulation = " ) != NULL )
				sscanf( strstr( ConfigPuf, "Emulation = " ), "Emulation = %i\n", &DefaultTelnet.EmuType );
			if( strstr( ConfigPuf, "Columns = " ) != NULL )
				sscanf( strstr( ConfigPuf, "Columns = " ), "Columns = %li\n", &DefaultTelnet.Terminal.x );
			if( strstr( ConfigPuf, "Rows = " ) != NULL )
				sscanf( strstr( ConfigPuf, "Rows = " ), "Rows = %li\n", &DefaultTelnet.Terminal.y );
			if( strstr( ConfigPuf, "HT = " ) != NULL )
				sscanf( strstr( ConfigPuf, "HT = " ), "HT = %li\n", &DefaultTelnet.Tab.x );
			if( strstr( ConfigPuf, "VT = " ) != NULL )
				sscanf( strstr( ConfigPuf, "VT = " ), "VT = %li\n", &DefaultTelnet.Tab.y );
			if( strstr( ConfigPuf, "KeyFlag = " ) != NULL )
				sscanf( strstr( ConfigPuf, "KeyFlag = " ), "KeyFlag = %i\n", &DefaultTelnet.KeyFlag );
			if( strstr( ConfigPuf, "PufLines = " ) != NULL )
				sscanf( strstr( ConfigPuf, "PufLines = " ), "PufLines = %li\n", &DefaultTelnet.PufLines );
			if( strstr( ConfigPuf, "KeyExport = " ) != NULL )
				sscanf( strstr( ConfigPuf, "KeyExport = " ), "KeyExport = %i\n", &DefaultTelnet.KeyExport );
			if( strstr( ConfigPuf, "KeyImport = " ) != NULL )
				sscanf( strstr( ConfigPuf, "KeyImport = " ), "KeyImport = %i\n", &DefaultTelnet.KeyImport );
			if( strstr( ConfigPuf, "ProtocolFlag = " ) != NULL )
				sscanf( strstr( ConfigPuf, "ProtocolFlag = " ), "ProtocolFlag = %i\n", &DefaultTelnet.ProtocolFlag );

			if( strstr( ConfigPuf, "RxPath = " ) != NULL )
			{
				WORD	Len;
				Len = ( WORD ) ( strchr( strstr( ConfigPuf, "RxPath = " ), '\n' ) - strstr( ConfigPuf, "RxPath = " ) + 1 );
				RxPath = malloc( Len );
				if( RxPath )
					sscanf( strstr( ConfigPuf, "RxPath = "), "RxPath = %s\n", RxPath );
			}
			if( strstr( ConfigPuf, "RxParameter = " ) != NULL )
			{
				WORD	Len;
				Len = ( WORD ) ( strchr( strstr( ConfigPuf, "RxParameter = " ), '\n' ) - strstr( ConfigPuf, "RxParameter = " ) + 1 );
				RxPara = malloc( Len );
				if( RxPara )
					sscanf( strstr( ConfigPuf, "RxParameter = "), "RxParameter = %s\n", RxPara );
			}
			if( strstr( ConfigPuf, "TxPath = " ) != NULL )
			{
				WORD	Len;
				Len = ( WORD ) ( strchr( strstr( ConfigPuf, "TxPath = " ), '\n' ) - strstr( ConfigPuf, "TxPath = " ) + 1 );
				TxPath = malloc( Len );
				if( TxPath )
					sscanf( strstr( ConfigPuf, "TxPath = "), "TxPath = %s\n", TxPath );
			}
			if( strstr( ConfigPuf, "TxParameter = " ) != NULL )
			{
				WORD	Len;
				Len = ( WORD ) ( strchr( strstr( ConfigPuf, "TxParameter = " ), '\n' ) - strstr( ConfigPuf, "TxParameter = " ) + 1 );
				TxPara = malloc( Len );
				if( TxPara )
					sscanf( strstr( ConfigPuf, "TxParameter = "), "TxParameter = %s\n", TxPara );
			}

			if( strstr( ConfigPuf, "AppendProtocol = " ) != NULL )
				sscanf( strstr( ConfigPuf, "AppendProtocol = " ), "AppendProtocol = %i\n", &AppendProtocolFlag );
			if( strstr( ConfigPuf, "ProtocolPath = " ) != NULL )
			{
				WORD	Len;
				Len = ( WORD ) ( strchr( strstr( ConfigPuf, "ProtocolPath = " ), '\n' ) - strstr( ConfigPuf, "ProtocolPath = " ) + 1 );
				ProtocolPath = malloc( Len );
				if( ProtocolPath )
					sscanf( strstr( ConfigPuf, "ProtocolPath = "), "ProtocolPath = %s\n", ProtocolPath );
			}

/* --------------------------------------------------------------------------*/

			Pos = strstr( ConfigPuf, "Hotlist = " );
			while( Pos )
			{
				Telnet = malloc( sizeof( TELNET ));
				HtItem = malloc( sizeof( HT_ITEM ));
				if( !Telnet || !HtItem )
					break;
				HtItem->Telnet = Telnet;
				sscanf( Pos, "Hotlist = %[^\n]%n", Line1, &Len );
				Pos += Len + 1;
				sscanf( Pos, "%[^\n]%n", Line2, &Len );
				Pos += Len + 1;
				HtItem->Name = strdup( Line1 );
				if( !HtItem->Name )
					break;
				Telnet->Host = strdup( Line2 );
				if( !Telnet->Host )
					break;
				sscanf( Pos, "%u, %i, %li, %i, %i, %i, %i, %li, %li, %li, %li, %i, %li, %i, %i, %i\n", &Telnet->Port, &Telnet->FontId, &Telnet->FontPt, &Telnet->FontColor, &Telnet->FontEffects, &Telnet->WindowColor, &Telnet->EmuType, &Telnet->Terminal.x, &Telnet->Terminal.y, &Telnet->Tab.x, &Telnet->Tab.y, &Telnet->KeyFlag, &Telnet->PufLines, &Telnet->KeyExport, &Telnet->KeyImport, &Telnet->ProtocolFlag );
				if( Telnet->ProtocolFlag > 1 )
					Telnet->ProtocolFlag = 0;
				Telnet->FontPt = ( Telnet->FontPt << 16 );
				InsertHtItem( HtItem, &HtList );
				Pos = strstr( Pos, "Hotlist = " );
			}
			UpdateHotlistPopup( HtList, &HtPopup );
#endif
			free( ConfigPuf );
		}
		fclose( File );
	}
	else
	{
#ifdef	IRC_CLIENT
		WORD	i;
		for( i = 0; i < COLOUR_MAX; i++ )
			DefaultIrc.ColourTable[i] = 1;
		DefaultIrc.ColourTable[COLOUR_MSG_BACK] = 0;
		DefaultIrc.ColourTable[COLOUR_INPUT_BACK] = 0;
		DefaultIrc.ColourTable[COLOUR_USER_BACK] = 0;
		DefaultIrc.ColourTable[COLOUR_CHANNEL_BACK] = 0;
#endif
	}
#ifdef	IRC_CLIENT
	if( !UploadPath || !DownloadPath || LogPath )
	{
		BYTE	Path[512];
		Path[0] = Dgetdrv() + 'A';
		Path[1] = ':';
		Dgetpath( &Path[2], 0 );
		if( !DownloadPath )
			DownloadPath = strdup( Path );
		if( !UploadPath )
			UploadPath = strdup( Path );
		if( !LogPath )
			LogPath = strdup( Path );
	}
#endif
}

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
		HomePathConfig = malloc( strlen( Home ) + 1 + strlen( INFNAME ) + 1 );
		if( !HomePathConfig )
			return;

		strcpy( HomePathConfig, Home );
		if( HomePathConfig[ strlen( HomePathConfig ) -1 ] != '\\' )
			strcat( HomePathConfig, "\\" );

		DefaultPathConfig = malloc( strlen( HomePathConfig ) + strlen( "defaults\\" ) + strlen( INFNAME ) + 1 );
		strcpy( DefaultPathConfig, HomePathConfig );
		strcat( DefaultPathConfig, "defaults\\" );

		if( Fxattr( 0, DefaultPathConfig, &Xattr ) == E_OK )
			strcat( DefaultPathConfig, INFNAME );
		else
		{
			free( DefaultPathConfig );
			DefaultPathConfig = NULL;
		}
		strcat( HomePathConfig, INFNAME );
	}
}
