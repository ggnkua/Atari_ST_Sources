#include	<mt_mem.h>
#include	<TOS.H>>
#include	<STDDEF.H>
#include	<STDLIB.H>
#include	<STRING.H>
#include	<CTYPE.H>
#include	<stdio.h>

#include	<atarierr.h>

#ifdef	DRACONIS
#include	<stsocket.h>
#endif
#ifdef	ICONNECT
#include	<iconnect\inet.h>
#include	<iconnect\netdb.h>
#include	<iconnect\usis.h>
#endif

#include	"transprt.h"
#include	"iFusion.h"

#ifdef	DRACONIS
#include	"Draconis.h"
#endif

#include	"DM.h"
#include	"MM.h"

extern volatile int16	resolve_in_use;
static int16	ConfigFlag = 0;

static char	*Null = "0";

static char Email[40];
static char Realname[64];
static char PopUsername[64];
static char PopPass[64];
static char Hostname[16];
static char FtpProxy[16];
static char FtpProxyPort[16];
static char HttpProxy[16];
static char HttpProxyPort[16];
static char WaisProxy[16];
static char WaisProxyPort[16];
static char GopherProxy[16];
static char GopherProxyPort[16];
static char NewsProxy[16];
static char NewsProxyPort[16];
static char	PopServer[16];
static char	SmtpServer[16];
static char	NewsServer[16];

static char	*ErrText[] = {
"No error.", "Can't send, output buffer is full.", "No data available.", "EOF received from a remote host.",
"RESET received from a remote host.", "Unacceptable packet, sending RESET.",
"No more memory available.", "Connection refused by remote host.",
"TCP received SYN in window.", "Bad connection handle used.",
"The connection is in LISTEN state.", "No free CCBs available.",
"A packet matches no connection.", "Failure to connect to remote port.",
"Invalid TCP_close() requested.", "User timeout expired. Connection timed out.",
"DNS query, can't resolve hostname.", "Bad format in domain name / dotted quad.",
"Modem lost carrier signal.", "Hostname does not exist.", "Resolver reached work limit.",
"No nameserver found for query.", "DNS query, bad format received.",
"Destination host is unreachable.", "No address records found for hostname.",
"Routine is unavailable.", "Locked by another application.", "Error during fragmentation.",
"Time To Live exceeded, discarded.", "Problem with a parameter.",
"Input buffer is too small for data.", ""
};

static Options;

int16 cdecl	IF_resolve( char *inp, char **real, uint32 *lst, int16 len )
{
	int16	Ret = 0;
	while( resolve_in_use )
		Syield();

	resolve_in_use = 1;
#ifdef DEBUG
	DebugMsg( "resolve: %s\n", inp );
#endif
	if( inp && len >= 1 )
	{
#ifdef	DRACONIS
		struct	hostent	*he;
		if( isdigit( inp[0] ))
		{
#ifdef DEBUG
	DebugMsg( "resolve: Direktumwandlung fr Draconis\n" );
#endif
			*lst = inet_addr( inp );
			if( real )
			{
				*real = IF_KRmalloc( strlen( inp ) + 1 );
				if( *real )
					strcpy( *real, inp );
			}
			resolve_in_use = 0;
			return( 1 );
		}
#endif
#ifdef	ICONNECT
		hostent	*he;
#endif
		if(( he = gethostbyname( inp )) != NULL )
		{
			*lst = *( uint32* ) he->h_addr_list[0];
			if( real )
			{
				*real = IF_KRmalloc( strlen( inp ) + 1 );
				if( *real )
					strcpy( *real, inp );
			}
			Ret = 1;
		}
		else
			Ret = E_CANTRESOLVE;
	}
	else
		Ret = E_CANTRESOLVE;

	resolve_in_use = 0;
	return( Ret );
}
char *cdecl	IF_get_err_text( int16 error_code )
{
	if( error_code > 31 )
		error_code = 31;
	return(ErrText[( -1 ) * error_code]);
}
char *cdecl	IF_getvstr( char *specifier )
{
#ifdef	DRACONIS
	CFG_OPT *Opt = get_draconis_options();
	if( !Opt || Opt == -1L )
		return( NULL );
#endif
	if( !stricmp( specifier, "FTP_PROXY" ))
	{
		if( !ConfigFlag )
		{
#ifdef	DRACONIS
			return( strcpy( FtpProxy, Opt->ftp ));
#endif
#ifdef	ICONNECT
			USIS_REQUEST  ur; 
			ur.request = UR_PROXY_IP;
			ur.free1 = "ftp";
			ur.free2 = NULL;
			if( usis_query( &ur ) == UA_FOUND )
				return( strcpy( FtpProxy, inet_ntoa( ur.ip )));
			else
				return( Null );
#endif
		}
		return( FtpProxy );
	}
	if( !stricmp( specifier, "FTP_PROXY_PORT" ))
	{
		if( !ConfigFlag )
		{
#ifdef	DRACONIS
			return( strcpy( FtpProxyPort, Opt->ftp_port ));
#endif
#ifdef	ICONNECT
			USIS_REQUEST  ur; 
			ur.request = UR_PROXY_IP;
			ur.free1 = "ftp";
			ur.free2 = NULL;
			if( usis_query( &ur ) == UA_FOUND )
				return( itoa( ur.port, FtpProxyPort, 10 ));
			else
				return( Null );
#endif
		}
		return( FtpProxyPort );
	}
	if( !stricmp( specifier, "HTTP_PROXY" ))
	{
		if( !ConfigFlag )
		{
#ifdef	DRACONIS
			return( strcpy( HttpProxy, Opt->http ));
#endif
#ifdef	ICONNECT
			USIS_REQUEST  ur; 
			ur.request = UR_PROXY_IP;
			ur.free1 = "http";
			ur.free2 = NULL;
			if( usis_query( &ur ) == UA_FOUND )
				return( strcpy( HttpProxy, inet_ntoa( ur.ip )));
			else
				return( Null );
#endif
		}
		return( HttpProxy );
	}
	if( !stricmp( specifier, "HTTP_PROXY_PORT" ))
	{
		if( !ConfigFlag )
		{
#ifdef	DRACONIS
			return( strcpy( HttpProxyPort, Opt->http_port ));
#endif
#ifdef	ICONNECT
			USIS_REQUEST  ur; 
			ur.request = UR_PROXY_IP;
			ur.free1 = "http";
			ur.free2 = NULL;
			if( usis_query( &ur ) == UA_FOUND )
				return( itoa( ur.port, HttpProxyPort, 10 ));
			else
				return( Null );
#endif
		}
		return( HttpProxyPort );
	}
	if( !stricmp( specifier, "WAIS_PROXY" ))
	{
		if( !ConfigFlag )
		{
#ifdef	ICONNECT
			USIS_REQUEST  ur; 
			ur.request = UR_PROXY_IP;
			ur.free1 = "wais";
			ur.free2 = NULL;
			if( usis_query( &ur ) == UA_FOUND )
				return( strcpy( WaisProxy, inet_ntoa( ur.ip )));
			else
				return( Null );
#endif
		}
		return( WaisProxy );
	}
	if( !stricmp( specifier, "WAIS_PROXY_PORT" ))
	{
		if( !ConfigFlag )
		{
#ifdef	ICONNECT
			USIS_REQUEST  ur; 
			ur.request = UR_PROXY_IP;
			ur.free1 = "wais";
			ur.free2 = NULL;
			if( usis_query( &ur ) == UA_FOUND )
				return( itoa( ur.port, WaisProxyPort, 10 ));
			else
				return( Null );
#endif
		}
		return( WaisProxyPort );
	}
	if( !stricmp( specifier, "GOPHER_PROXY" ))
	{
		if( !ConfigFlag )
		{
#ifdef	DRACONIS
			return( strcpy( GopherProxy, Opt->gopher ));
#endif
#ifdef	ICONNECT
			USIS_REQUEST  ur; 
			ur.request = UR_PROXY_IP;
			ur.free1 = "gopher";
			ur.free2 = NULL;
			if( usis_query( &ur ) == UA_FOUND )
				return( strcpy( GopherProxy, inet_ntoa( ur.ip )));
			else
				return( Null );
#endif
		}
		return( GopherProxy );
	}
	if( !stricmp( specifier, "GOPHER_PROXY_PORT" ))
	{
		if( !ConfigFlag )
		{
#ifdef	DRACONIS
			return( strcpy( GopherProxyPort, Opt->gopher_port ));
#endif
#ifdef	ICONNECT
			USIS_REQUEST  ur; 
			ur.request = UR_PROXY_IP;
			ur.free1 = "gopher";
			ur.free2 = NULL;
			if( usis_query( &ur ) == UA_FOUND )
				return( itoa( ur.port, GopherProxyPort, 10 ));
			else
				return( Null );
#endif
		}
		return( GopherProxyPort );
	}
	if( !stricmp( specifier, "NEWS_PROXY" ) || !stricmp( specifier, "NNTP_PROXY" ))
	{
		if( !ConfigFlag )
		{
#ifdef	ICONNECT
			USIS_REQUEST  ur; 
			ur.request = UR_PROXY_IP;
			ur.free1 = "news";
			ur.free2 = NULL;
			if( usis_query( &ur ) == UA_FOUND )
				return( strcpy( NewsProxy, inet_ntoa( ur.ip )));
			else
				return( Null );
#endif
		}
		return( NewsProxy );
	}
	if( !stricmp( specifier, "NEWS_PROXY_PORT" ) || !stricmp( specifier, "NNTP_PROXY_PORT" ))
	{
		if( !ConfigFlag )
		{
#ifdef	ICONNECT
			USIS_REQUEST  ur; 
			ur.request = UR_PROXY_IP;
			ur.free1 = "news";
			ur.free2 = NULL;
			if( usis_query( &ur ) == UA_FOUND )
				return( itoa( ur.port, NewsProxyPort, 10 ));
			else
				return( Null );
#endif
		}
		return( NewsProxyPort );
	}
	if( !stricmp( specifier, "SMTP_SERVER" ) || !stricmp( specifier, "SMTP_HOST" ))
	{
		if( !ConfigFlag )
		{
#ifdef	DRACONIS
			return( strcpy( SmtpServer, Opt->smtpserver ));
#endif
#ifdef	ICONNECT
			USIS_REQUEST  ur; 
			ur.request = UR_SMTP_IP;
			ur.free1 = NULL;
			ur.free2 = NULL;
			if( usis_query( &ur ) == UA_FOUND )
				return( strcpy( SmtpServer, inet_ntoa( ur.ip )));
			else
				return( Null );
#endif
		}
		return( SmtpServer );
	}
	if( !stricmp( specifier, "POP_HOST" ))
	{
		if( !ConfigFlag )
		{
#ifdef	DRACONIS
			return( strcpy( PopServer, Opt->popserver ));
#endif
#ifdef	ICONNECT
			USIS_REQUEST  ur; 
			ur.request = UR_POP_IP;
			ur.free1 = NULL;
			ur.free2 = NULL;
			if( usis_query( &ur ) == UA_FOUND )
				return( strcpy( PopServer, inet_ntoa( ur.ip )));
			else
				return( Null );
#endif
		}
		return( PopServer );
	}
	if( !stricmp( specifier, "NNTP_SERVER" ) || !stricmp( specifier, "NNTP_HOST" ))
	{
		if( !ConfigFlag )
		{
#ifdef	ICONNECT
			USIS_REQUEST  ur; 
			ur.request = UR_NEWS_IP;
			ur.free1 = NULL;
			ur.free2 = NULL;
			if( usis_query( &ur ) == UA_FOUND )
				return( strcpy( NewsServer, inet_ntoa( ur.ip )));
			else
				return( Null );
#endif
		}
		return( NewsServer );
	}
	if( !stricmp( specifier, "EMAIL" ))
	{
		if( !ConfigFlag )
		{
#ifdef	DRACONIS
			return( strcpy( Email, Opt->email ));
#endif
#ifdef	ICONNECT
			USIS_REQUEST  ur; 
			ur.request = UR_EMAIL_ADDR;
			ur.free1 = NULL;
			ur.free2 = NULL;
			ur.result = Email;
			if( usis_query( &ur ) == UA_FOUND )
				return( Email );
			else
				return( Null );
#endif
		}
		return( Email );
	}
	if( !stricmp( specifier, "FULLNAME" ))
	{
		if( !ConfigFlag )
		{
#ifdef	ICONNECT
			USIS_REQUEST  ur; 
			ur.request = UR_REAL_NAME;
			ur.free1 = NULL;
			ur.free2 = NULL;
			ur.result = Realname;
			if( usis_query( &ur ) == UA_FOUND )
				return( Realname );
			else
				return( Null );
#endif
		}
		return( Realname );
	}
	if( !stricmp( specifier, "POP_USERNAME" ))
	{
		if( !ConfigFlag )
		{
#ifdef	DRACONIS
			return( strcpy( PopUsername, Opt->popuser ));
#endif
#ifdef	ICONNECT
			USIS_REQUEST  ur; 
			ur.request = UR_POP_USER;
			ur.free1 = NULL;
			ur.free2 = NULL;
			ur.result = PopUsername;
			if( usis_query( &ur ) == UA_FOUND )
				return( PopUsername );
			else
				return( Null );
#endif
		}
		return( PopUsername );
	}
	if( !stricmp( specifier, "POP_PASSWORD" ))
	{
		if( !ConfigFlag )
		{
#ifdef	DRACONIS
			return( strcpy( PopPass, Opt->mailpass ));
#endif
#ifdef	ICONNECT
			USIS_REQUEST  ur; 
			ur.request = UR_POP_PASS;
			ur.free1 = NULL;
			ur.free2 = NULL;
			ur.result = PopPass;
			if( usis_query( &ur ) == UA_FOUND )
				return( PopPass );
			else
				return( Null );
#endif
		}
		return( PopPass );
	}
	if( !stricmp( specifier, "HOSTNAME" ))
	{
		if( !ConfigFlag )
		{
#ifdef	DRACONIS
			return( strcpy( Hostname, Opt->host ));
#endif
#ifdef	ICONNECT
			USIS_REQUEST  ur; 
			ur.request = UR_LOCAL_IP;
			ur.free1 = NULL;
			ur.free2 = NULL;
			ur.result = NULL;
			if( usis_query( &ur ) == UA_FOUND )
				return( strcpy( Hostname, inet_ntoa( ur.ip )));
			else
				return( Null );
#endif
		}
		return( Hostname );
	}
/*	printf("%s\n",specifier);	*/
	return( Null );
}
int16 cdecl	IF_carrier_detect( void )
{
	return( 1 );
}

void cdecl	IF_housekeep( void )
{
}
void cdecl	IF_ser_disable( void )
{
}
void cdecl  IF_ser_enable( void )
{
}
int16 cdecl IF_set_flag( int16 flag )
{
	return( FALSE );
}
void cdecl	IF_clear_flag( int16 flag )
{
}
int16 cdecl	IF_on_port( char *port_name )
{
	return( FALSE );
}
void cdecl	IF_off_port( char *port_name )
{
}
int16	cdecl	IF_setvstr( char *specifier, char *value )
{
	return( FALSE );
}
int16 cdecl IF_query_port( char *port_name )
{
	return( FALSE );
}

int16	read_config( void )
{
	FILE	*handle = fopen( "iFusion.cfg", "r" );
	strcpy( FtpProxy, Null );
	strcpy( FtpProxyPort, Null );
	strcpy( HttpProxy, Null );
	strcpy( HttpProxyPort, Null );
	strcpy( WaisProxy, Null );
	strcpy( WaisProxyPort, Null );
	strcpy( GopherProxy, Null );
	strcpy( GopherProxyPort, Null );
	strcpy( NewsProxy, Null );
	strcpy( NewsProxyPort, Null );
	strcpy( SmtpServer, Null );
	strcpy( NewsServer, Null );
	strcpy( Email, Null );
	strcpy( Realname, Null );
	strcpy( PopUsername, Null );
	strcpy( PopPass, Null );
	strcpy( Hostname, Null );
	if( handle )
	{
		char	Line[512], Spec[64], Value[64];
		while( fgets( Line, 512, handle ))
		{
			sscanf( Line, "%s = %s\n", Spec, Value );
			if( !stricmp( Spec, "FTP_PROXY" ))
				strcpy( FtpProxy, Value );
			else	if( !stricmp( Spec, "FTP_PROXY_PORT" ))
				strcpy( FtpProxyPort, Value );
			else	if( !stricmp( Spec, "HTTP_PROXY" ))
				strcpy( HttpProxy, Value );
			else	if( !stricmp( Spec, "HTTP_PROXY_PORT" ))
				strcpy( HttpProxyPort, Value );
			else	if( !stricmp( Spec, "WAIS_PROXY" ))
				strcpy( WaisProxy, Value );
			else	if( !stricmp( Spec, "WAIS_PROXY_PORT" ))
				strcpy( WaisProxyPort, Value );
			else	if( !stricmp( Spec, "GOPHER_PROXY" ))
				strcpy( GopherProxy, Value );
			else	if( !stricmp( Spec, "GOPHER_PROXY_PORT" ))
				strcpy( GopherProxyPort, Value );
			else	if( !stricmp( Spec, "NEWS_PROXY" ) || !stricmp( Spec, "NNTP_PROXY" ))
				strcpy( NewsProxy, Value );
			else	if( !stricmp( Spec, "NEWS_PROXY_PORT" ) || !stricmp( Spec, "NNTP_PROXY_PORT" ))
				strcpy( NewsProxyPort, Value );
			else	if( !stricmp( Spec, "SMTP_SERVER" ) || !stricmp( Spec, "SMTP_HOST" ))
				strcpy( SmtpServer, Value );
			else	if( !stricmp( Spec, "POP_HOST" ))
				strcpy( PopServer, Value );
			else	if( !stricmp( Spec, "NNTP_SERVER" ) || !stricmp( Spec, "NNTP_HOST" ))
				strcpy( NewsServer, Value );
			else	if( !stricmp( Spec, "EMAIL" ))
				strcpy( Email, Value );
			else	if( !stricmp( Spec, "FULLNAME" ))
				strcpy( Realname, Value );
			else	if( !stricmp( Spec, "POP_USERNAME" ))
				strcpy( PopUsername, Value );
			else	if( !stricmp( Spec, "POP_PASSWORD" ))
				strcpy( PopPass, Value );
			else	if( !stricmp( Spec, "HOSTNAME" ))
				strcpy( Hostname, Value );
		}
		ConfigFlag = 1;
		fclose( handle );
		return( E_OK );
	}
	else
		return( ERROR );
}