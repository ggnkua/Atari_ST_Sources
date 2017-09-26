#include	<mt_mem.h>
#include	<TOS.H>
#include	<STDDEF.H>
#include	<STDLIB.H>
#include	<stdio.h>
#include	<STRING.H>
#include	<EXT.H>
#ifdef	ICONNECT
#include	<iconnect\TYPES.H>
#endif

#include	<atarierr.h>

#ifdef	DRACONIS
#include	<stsocket.h>
#endif
#ifdef	ICONNECT
#include	<iconnect\sockinit.h>
#include	<stsocket.h>
#endif

#include	"transprt.h"
#include	"layer.h"
#include	"STiK.h"

#include	"iFusion.h"

#include	"Layer\IM.h"
#include	"Layer\PM.h"
#include	"Layer\RM.h"
#include	"Layer\SM.h"
#include	"Layer\TM.h"

#include	"Transprt\CM.h"
#include	"Transprt\DM.h"
#include	"Transprt\MM.h"
#include	"Transprt\TM.h"
#include	"Transprt\UM.h"

#ifdef	ICONNECT
#include	"Tcp\Tcp.h"
#endif

#define Con(a) Cconws(a)
#define crlf Con("\r\n")

volatile int16	resolve_in_use = 0;

#ifdef DEBUG
static volatile int16 DebugSemaphore = 0;
#endif

typedef struct
{
	int32	id;
	int32	value;
} COOKIE;

#ifdef	DRACONIS
typedef	CFG_OPT * cdecl ( *ST_GET_OPTIONS )( long fnc );
#endif

IF	*If;

static int32	search_stik_cookie( void );
static int32	install_cookie( void );
static int32	search_icip_cookie( void );

#ifdef	MILAN
static int32	search_CPU_cookie( void );
#endif

DRV_HDR *cdecl IF_get_dftab( char * str );
char	*Cv[101];
static CONFIG	Cfg =
{
	0,
	0L,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	NULL,
	NULL,
	Cv,
	0,
	0,
	0,
	0
};

DRV_LIST	DrvList = { MAGIC, IF_get_dftab, NULL, ( void * ) &Cfg, NULL };

TPL		Tpl =
{
#ifdef	DRACONIS
	"iFusion (STiK/STinG over Draconis)",
#endif
#ifdef	ICONNECT
	"iFusion (Draconis & STiK/STinG over IConnect)",
#endif
	"JÅrgen Koneczny",
	"01.00",
   IF_KRmalloc,
	IF_KRfree,
	IF_KRgetfree,
	IF_KRrealloc,
	IF_get_err_text,
	IF_getvstr,
	IF_carrier_detect,
	IF_TCP_open,
	IF_TCP_close,
	IF_TCP_send,
	IF_TCP_wait_state,
	IF_TCP_ack_wait,
	IF_UDP_open,
	IF_UDP_close,
	IF_UDP_send,
	IF_CNkick,
	IF_CNbyte_count,
	IF_CNget_char,
	IF_CNget_NDB,
	IF_CNget_block,
	IF_housekeep,
	IF_resolve,
	IF_ser_disable,
	IF_ser_enable,
	IF_set_flag,
	IF_clear_flag,
	IF_CNgetinfo,
	IF_on_port,
	IF_off_port,
	IF_setvstr,
	IF_query_port,
	IF_CNgets
};

STX	Stx =
{
#ifdef	DRACONIS
	"iFusion (STiK/STinG over Draconis)",
#endif
#ifdef	ICONNECT
	"iFusion (STiK/STinG over IConnect)",
#endif
	"JÅrgen Koneczny",
	"01.00",
	IF_set_dgram_ttl,
	IF_check_dgram_ttl,
	IF_load_routing_table,
	IF_set_sysvars,
	IF_query_chains,
	IF_IP_send,
	IF_IP_fetch,
	IF_IP_handler,
	IF_IP_discard,
	IF_PRTCL_announce,
	IF_PRTCL_get_parameters,
	IF_PRTCL_request,
	IF_PRTCL_release,
	IF_PRTCL_lookup,
	IF_TIMER_call,
	IF_TIMER_now,
	IF_TIMER_elapsed,
	IF_protect_exec,
	IF_get_route_entry,
	IF_set_route_entry
};

#ifdef	ICONNECT
long tcp_cookie [] =
{
	1L,
	0L,
	0L,
	0L,
	0L,
	0L,				/*  5 */
	0L,
	0L,
	0L,
	0L,
	0L,				/* 10 */
	0L,
	0L,
	0L,
	0L,
	(long) st_socket,		/* 15 */
	(long) st_closesocket,
	(long) st_connect,
	(long) st_bind,
	(long) st_write,
	(long) st_send,			/* 20 */
	(long) st_sendto,
	(long) st_sendmsg,
	(long) st_seek,
	(long) st_read,
	(long) st_recv,			/* 25 */
	(long) st_recvfrom,
	(long) st_recvmsg,
	0L,
	0L,
	(long) st_gethostid,		/* 30 */
	(long) st_sethostid,
	(long) st_getsockname,
	(long) st_getpeername,
	(long) st_gethostip,
	(long) st_sethostip,		/* 35 */
	(long) st_shutdown,
	0L,
	0L,
	0L,
	0L,				/* 40 */
	0L,
	0L,
	(long) st_socket_select,
	(long) st_set_options,
	(long) st_get_options,		/* 45 */
	(long) st_sock_accept,
	(long) st_sock_listen,
	(long) st_set_loginparams,
	(long) st_get_loginparams,
	0L,				/* 50 */
	0L,
	0L,
	0L,
	0L,
	0L,				/* 55 */
	0L,	 
	0L,
	0L,
	0L,
	0L,				/* 60 */
	0L,
	0L,
	0L,
	(long) st_get_connected,
	0L,				/* 65 */
	0L,
	0L,
	0L,
	0L,
	0L,				/* 70 */
	(long) st_get_dns,
	0L,
	0L,
	0L,
	(long) st_gethostbyname,	/* 75 */
	(long) st_gethostbyaddr,
	(long) st_gethostname,
	(long) st_getservbyname,
	(long) st_getservbyport,
	
  (long) st_setsockopt,     /* 80 */
  (long) st_getsockopt,
  
  (long) 0L,
  (long) 0L,
  (long) st_sockfcntl,
  (long) 0x00010007L,       /* 85 */
  0L
};
#endif

#define	CV_ERROR		-2
#define	CV_TOO_OLD	-1
#define	CV_OK			0
static int16	CheckVersion( void )
{
	char	Ver[] = VERSION;
	if( Ver[3] == 'b' || Ver[4] == 'b' || Ver[3] == 'a' || Ver[4] == 'a' )
	{
		/* Test for beta versions */
		return( CV_OK );
	}
	else
	{
#ifdef	MILAN
		COOKIE	*Cookie;
		Cookie = ( COOKIE * ) Supexec( search_CPU_cookie );
		if( !Cookie || Cookie->value != 60 )
			return( CV_ERROR );
#endif
		return( CV_OK );
	}
}

static void	DecodeName( char *DestName )
{
	char	Ver[] = VERSION;
	if( Ver[3] == 'b' || Ver[4] == 'b' || Ver[3] == 'a' || Ver[4] == 'a' )
	{
		strcpy( DestName, "Aplha/Beta-Release" );		
	}
	else
	{
#ifdef	MILAN
		strcpy( DestName, "Milan 060 Release" );
#else
		strcpy( DestName, "Release" );		
#endif
	}
}

#ifdef	MILAN
static int32	search_CPU_cookie( void )
{
	long	id = '';
	COOKIE	*search;
	search = *(COOKIE **) 0x5a0;
	if ( search )
	{
		while ( search->id )
		{
			if ( search->id == ( id ^ 'JKIF' ))
				return(( int32 ) search );
			search++;
		}		
	}
	return( 0L );
}
static int32	search_MCH_cookie( void )
{
	long	id = 0x15060a0el;
	COOKIE	*search;
	search = *(COOKIE **) 0x5a0;
	if ( search )
	{
		while ( search->id )
		{
			if ( search->id == ( id ^ 'JKIF' ))
				return(( int32 ) search );
			search++;
		}		
	}
	return( 0L );
}
#endif
static int32	search_stik_cookie( void )
{
	COOKIE	*search;
	search = *(COOKIE **) 0x5a0;
	if ( search )
	{
		while ( search->id )
		{
			if ( search->id == 'STiK' )
				return(( int32 ) search );
			search++;
		}		
	}
	return( 0L );
}

static int32	search_icip_cookie( void )
{
	COOKIE	*search;
	search = *(COOKIE **) 0x5a0;
	if ( search )
	{
		while ( search->id )
		{
			if ( search->id == 'ICIP' )
				return(( int32 ) search );
			search++;
		}		
	}
	return( 0L );
}

static int32	install_cookie( void )
{
	COOKIE	*last = *(COOKIE **) 0x5a0;
	int32		i = 1;
	if( last )
	{
		while( last->id )
		{
			last++;
			i++;
		}
		if( i < last->value )
		{
			COOKIE	*ret = last;
			last++;
			last->id = 0L;
			last->value = ret->value;
			return(( int32 ) ret );
		}
		return( 0L );
	}
	return( 0L );
}

DRV_HDR *cdecl IF_get_dftab( char * str )
{
	if( !strcmp( str, TRANSPORT_DRIVER ))
		return(( DRV_HDR * ) &Tpl );
	else	if( !strcmp( str, MODULE_DRIVER ))
		return(( DRV_HDR * ) &Stx );
	else
		return( NULL );
}

void	set_client_ip( int32	client_ip )
{
	Cfg.client_ip = client_ip;
}

/* FÅr die Erfragung von Parametern der Draconis-Version */
#ifdef	DRACONIS
CFG_OPT *get_draconis_options( void )
{
	CFG_OPT	*Opt = NULL;
	COOKIE	*CookieD = ( COOKIE * ) Supexec( search_icip_cookie );
	if( CookieD )
	{
		int32	*w = ( int32 * ) CookieD->value;
		ST_GET_OPTIONS	st_get_options = w[45];
		Opt = st_get_options( 1L );
	}
	return( Opt );
}
#endif

int	main( int ArgC, const char *ArgV[] )
{
	char		Out1[128], Out2[128], Out3[128], Version[] = VERSION;
	int16		ret;
	COOKIE	*CookieS = NULL;
#ifdef	ICONNECT
	COOKIE	*CookieD = NULL;
#endif

	strcpy( Out2, "Ω 1999, 2000 by JÅrgen Koneczny" );
	Con( "\33p" );
	strcpy( Out1, Tpl.module );
	strcat( Out1, " V" );
	strcat( Out1, Version );
	DecodeName( Out3 );
	while( strlen( Out1 ) < strlen( Out2 ) && strlen( Out1 ) < strlen( Out3 ))
		strcat( Out1, " " );
	Con( Out1 );
	Con( "\33q" );crlf;
	Con( Out2 );crlf;

	if(( ret = CheckVersion()) != CV_OK )
	{
		switch( ret )
		{
			case	CV_TOO_OLD:
				Con( "Version too old!" );crlf;
				Con( "iFusion not installed" );crlf;
			case	CV_ERROR:
				return( ERROR );
		}
	}

#ifndef	MILAN
	Con( "Registriert auf:" );crlf;
#endif
	Con( Out3 );crlf;

#ifdef	ICONNECT
	CookieS = ( COOKIE * ) Supexec( search_stik_cookie );
	CookieD = ( COOKIE * ) Supexec( search_icip_cookie );
	if( CookieS != NULL && CookieD != NULL )
	{
		Con( "Already installed" );crlf;
		if( Version[3] != 'b' && Version[4] != 'b' && Version[3] != 'a' && Version[4] != 'a' )
			return( ERROR );
	}	
	if( CookieD == NULL )
		CookieD = ( COOKIE * ) Supexec( install_cookie );
#endif	
#ifdef	DRACONIS
	if(( CookieS = ( COOKIE * ) Supexec( search_stik_cookie )) != NULL )
	{
		Con( "Already installed" );crlf;
		if( Version[3] != 'b' && Version[4] != 'b' && Version[3] != 'a' && Version[4] != 'a' )
			return( ERROR );
	}
#endif

	if( CookieS == NULL )
		CookieS = ( COOKIE * ) Supexec( install_cookie );

#ifdef	ICONNECT
	if( CookieS || CookieD )
#endif
#ifdef	DRACONIS
	if( CookieS )
#endif
	{
#ifdef	DRACONIS
		ret = get_connected();
		if( ret < 0 )
		{
			Con( "Sockets not installed." );crlf;
			Con( "Put DRACONLD.PRG in the AUTO-folder." );crlf;
		}
#endif
#ifdef	ICONNECT
		ret = sock_init();
		if( ret < 0 )
		{
			switch( ret )
			{
				case SE_NINSTALL:
					Con( "Sockets not installed." );crlf;
					Con( "Put SOCKETS.PRG in the AUTO-folder." );crlf;
					break;
				case SE_NSUPP:
					Con( "SOCKETS.PRG is too old." );crlf;
					break;
			}
		}
		else
#endif
		{
			IF	*tmp = malloc( 512 * sizeof( IF ));
			if( tmp )
			{
#ifdef	DRACONIS
				If = tmp - 4096 * sizeof( IF );
#endif
#ifdef	ICONNECT
				If = tmp;
#endif
				if( CookieS )
				{
					CookieS->id = 'STiK';
					CookieS->value = ( int32 ) &DrvList;
					Con( "STiK/STinG Driver" );crlf;
				}
#ifdef	ICONNECT
				if( CookieD )
				{
					CookieD->id = 'ICIP';
					CookieD->value = ( int32 ) &tcp_cookie;
					Con( "Draconis Driver" );crlf;
				}
#endif
				if( read_config() == E_OK )
				{
					Con( "iFusion.cfg loaded" );crlf;
				}
/* get_draconis_options();	*/
				Ptermres( _PgmSize, E_OK );
			}
			Con( "Sufficient memory" );crlf;
		}
	}
	Con( "iFusion not installed" );crlf;
	return( ERROR );
}

#ifdef DEBUG
static void	WriteDebugMsg( FILE *DebugHandle, char *Arg, va_list ap )
{
	char	Puf[8096];
	vsprintf( Puf, Arg, ap);
	if( DebugHandle )
		fwrite( Puf, sizeof( char ), strlen( Puf ), DebugHandle );
}
void	DebugMsg( char *Arg, ... )
{
	while( DebugSemaphore )
		Syield();
	DebugSemaphore = 1;
	{
		va_list	ap;
		FILE	*DebugHandle = NULL;
		va_start( ap, Arg );
		DebugHandle = fopen( "iFusion.log", "a+" );

		if( DebugHandle )
			WriteDebugMsg( DebugHandle, Arg, ap );
		if( DebugHandle )
			fclose( DebugHandle );
	}
	DebugSemaphore = 0;
}
void	DebugPuf( void *Puf, int32 len )
{
	while( DebugSemaphore )
		Syield();
	DebugSemaphore = 1;
	{
		FILE	*DebugHandle = NULL;
		DebugHandle = fopen( "iFusion.log", "a+" );
		if( DebugHandle )
		{
			fwrite( Puf, sizeof( char ), len, DebugHandle );
			fclose( DebugHandle );
		}
	}
	DebugSemaphore = 0;
}
#endif