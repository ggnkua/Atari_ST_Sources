#include	<mt_mem.h>
#include	<TOS.H>
#include	<STDDEF.H>
#include	<STDLIB.H>
#include	<stdio.h>
#include	<STRING.H>
#include	<EXT.H>
#include	<iconnect\TYPES.H>

#include	<atarierr.h>

#include	<iconnect\sockinit.h>
#include	<iconnect\inet.h>
#include	<iconnect\netdb.h>
#include	<iconnect\socket.h>
#include	<iconnect\sockios.h>
#include	<iconnect\usis.h>
#include	<iconnect\sfcntl.h>
#include	<iconnect\sockerr.h>

#include	"transprt.h"
#include	"iFusion.h"

#include	"Tcp\Tcp.h"

# define ST_NFDBITS		(8 * sizeof(unsigned long))
# define ST_FD_SETSIZE		(ST_FDSET_LONGS * ST_NFDBITS)

# define ST_FDELT(d)		(d / ST_NFDBITS)
# define ST_FDMASK(d)		(1L << (d % ST_NFDBITS))
# define ST_FD_SET(d, set)	((set)->fds_bits[ST_FDELT(d)] |= ST_FDMASK(d))
# define ST_FD_CLR(d, set)	((set)->fds_bits[ST_FDELT(d)] &= ~ST_FDMASK(d))
# define ST_FD_ISSET(d, set)	((set)->fds_bits[ST_FDELT(d)] & ST_FDMASK(d))
# define ST_FD_ZERO(set) 	memset(set, 0, sizeof(st_fd_set))

/* Extended Error values */
#define	ST_EAGAIN								 11	/* Do it again 								 */
#define	ST_EPROTO								 71	/* Protocol error */
#define	ST_ENOTSOCK							 88	/* Not a valid socket 				 */
#define	ST_EOPNOTSUPP						 95 /* Operation not supported     */
#define	ST_EADDRINUSE						 98	/* address is already in use 	 */
#define	ST_ENOBUFS								105
#define	ST_EISCONN								106 /* socket is already connected */
#define	ST_ENOTCONN							107	/* socket is not connected     */
#define	ST_EALREADY							114	/* operation in progress 			 */
#define	ST_EINPROGRESS						115	/* operation started					 */

#pragma warn -par

extern volatile int16	resolve_in_use;

static int16 map_it (int16 mint_sfd);
static int16 map_sfd (int16 sfd);
static int32 map_ret ( int32 ret );
static void map_fdset (int16 nfds, st_fd_set *st_fds, fd_set *mint_fds );
static int32 remap_fdset (int16 nsfd, fd_set *mint_fds, st_fd_set *st_fds );

static CFG_OPT	Opt;

static int16 map_it (int16 mint_sfd)
{
	if (mint_sfd < 0)
		return mint_sfd;
	else
		return mint_sfd + 0x1000 + 1;
}
static int16 map_sfd (int16 sfd)
{
	return sfd - 0x1000 - 1;
}

static int32 map_ret ( int32 ret )
{
	if( ret >= 0 )
		return( ret );
	switch(( int16 ) ret )
	{
/*		case	EAGAIN:
			return( -ST_EAGAIN );
		case	EPROTO:
			return( -ST_EPROTO );
*/		case	ENOTSOCK:
			return( -ST_ENOTSOCK );
		case	EOPNOTSUPP:
			return( -ST_EOPNOTSUPP );
		case	EADDRINUSE:
			return( -ST_EADDRINUSE );
/*		case	ENOBUFS:
			return( -ST_ENOBUFS );
*/		case	EISCONN:
			return( -ST_EISCONN );
		case	ENOTCONN:
			return( -ST_ENOTCONN );
		case	EALREADY:
			return( -ST_EALREADY );
		case	EINPROGRESS:
			return( -ST_EINPROGRESS );
		default:
			return( -1 );
	}
}

int16 cdecl st_bind(int32 fnc, int16 sfd, struct sockaddr *address, int16 addrlen)
{
#ifdef DEBUG
	DebugMsg( "bind: handle=%i\n", sfd );
#endif
	return( bind( map_sfd( sfd ), address, addrlen ));
}

int16 cdecl st_closesocket	(int32 fnc, int16 sfd)
{
	return( sclose( map_sfd( sfd )));
}

int16 cdecl st_connect (int32 fnc, int16 sfd, struct sockaddr *servaddr, int16 addrlen)
{
	int16	r;
#ifdef DEBUG
	DebugMsg( "connect: handle=%i, ip=%lx, port=%i\n", sfd, servaddr->sin_addr, servaddr->sin_port );
#endif
	r = connect( map_sfd( sfd ), servaddr, addrlen ); 
#ifdef DEBUG
	DebugMsg( "connect: %i\n", r );
#endif
	return( r );
}

uint32 cdecl st_get_dns (int32 fnc, int16 no)
{
	printf("st_get_dns\n");
}

void cdecl st_get_loginparams	(int32 fnc, char *user, char *pass)
{
	printf("st_get_loginparams\n");
}
int16 cdecl st_get_connected (int32 fnc)
{
	return( 2 );
}

CFG_OPT * cdecl st_get_options (int32 fnc)
{
	USIS_REQUEST  ur;
	char	Puf[128];
#ifdef DEBUG
	DebugMsg( "st_get_options\n" );
#endif

	ur.request = UR_PROXY_IP;
	ur.free1 = "http";
	ur.free2 = NULL;
	if( usis_query( &ur ) == UA_FOUND )
	{
		strcpy( Opt.http, inet_ntoa( ur.ip ));
		itoa( ur.port, Opt.http_port, 10 );
	}
	ur.request = UR_PROXY_IP;
	ur.free1 = "ftp";
	ur.free2 = NULL;
	if( usis_query( &ur ) == UA_FOUND )
	{
		strcpy( Opt.ftp, inet_ntoa( ur.ip ));
		itoa( ur.port, Opt.ftp_port, 10 );
	}
	ur.request = UR_PROXY_IP;
	ur.free1 = "gopher";
	ur.free2 = NULL;
	if( usis_query( &ur ) == UA_FOUND )
	{
		strcpy( Opt.gopher, inet_ntoa( ur.ip ));
		itoa( ur.port, Opt.gopher_port, 10 );
	}

	ur.request = UR_POP_IP;
	ur.free1 = NULL;
	ur.free2 = NULL;
	if( usis_query( &ur ) == UA_FOUND )
		strcpy( Opt.popserver, inet_ntoa( ur.ip ));
	ur.request = UR_SMTP_IP;
	ur.free1 = NULL;
	ur.free2 = NULL;
	if( usis_query( &ur ) == UA_FOUND )
		strcpy( Opt.smtpserver, inet_ntoa( ur.ip ));
	
	ur.request = UR_EMAIL_ADDR;
	ur.free1 = NULL;
	ur.free2 = NULL;
	ur.result = Puf;
	if( usis_query( &ur ) == UA_FOUND )
	{
		strncpy( Opt.email, Puf, 42 );
		Opt.email[42] = 0;
	}
	ur.request = UR_POP_USER;
	ur.free1 = NULL;
	ur.free2 = NULL;
	ur.result = Puf;
	if( usis_query( &ur ) == UA_FOUND )
	{
		strncpy( Opt.popuser, Puf, 42 );
		Opt.popuser[42] = 0;
	}
	ur.request = UR_POP_PASS;
	ur.free1 = NULL;
	ur.free2 = NULL;
	ur.result = Puf;
	if( usis_query( &ur ) == UA_FOUND )
	{
		int16	i;
		strncpy( Opt.mailpass, Puf, 42 );
		Opt.mailpass[42] = 0;
		for( i = 0; i < 42; i += 2 )
		{
			if( Opt.mailpass[i] != 0 )
				Opt.mailpass[i] ^= 244;
			else
				break;
			if( Opt.mailpass[i+1] != 0 )
				Opt.mailpass[i+1] ^= 248;
			else
				break;
		}
		
	}
#ifdef DEBUG
	DebugMsg( "http: %s:%s\n", Opt.http, Opt.http_port );
	DebugMsg( "EMail: %s\n", Opt.email );
	DebugMsg( "POP-User: %s\n", Opt.popuser );
	DebugMsg( "POP-Passwd: %s\n", Opt.mailpass );
	DebugMsg( "POP-Server: %s\n", Opt.popserver );
#endif
	return( &Opt );
}

struct hostent *	cdecl st_gethostbyname (int32 fnc, char *name)
{
	hostent	*he;
#ifdef DEBUG
	DebugMsg( "st_gethostbyname: %s\n", name );
#endif
	while( resolve_in_use )
		Syield();
	resolve_in_use = 1;
	he = gethostbyname( name );
	resolve_in_use = 0;
	return( he );
}

struct hostent *	cdecl st_gethostbyaddr (int32 fnc, char *haddr, int16 len, int16 type)
{
	printf("st_gethostbyaddr\n");
}

int16 cdecl st_gethostname (int32 fnc, char *name, int16 namelen)
{
#ifdef DEBUG
	DebugMsg( "gethostname\n" );
#endif
	return( gethostname( name, namelen ));
}

int32 cdecl st_gethostid (int32 fnc)
{
	printf("st_gethostid\n");
}

int32	cdecl st_gethostip (int32 fnc)
{
	printf("st_gethostip\n");
}

struct servent * cdecl st_getservbyname (int32 fnc, char *name, char *proto)
{
#ifdef DEBUG
	DebugMsg( "getservbyname: %s %s\n", name, proto );
#endif
	if( !proto )	/* wegen Fehler bei drtelnet */
		return( getservbyname( name, "tcp" ));
	if( !strcmp( name, "pop-3" ))	/* wegen Fehler bei Marathon */
		return( getservbyname( "pop3", proto ));
	return( getservbyname( name, proto ));
}

struct servent * cdecl st_getservbyport (int32 fnc, int16 port, char *proto)
{
	printf("st_getservbyport\n");
}

int16 cdecl st_getsockname (int32 fnc, int16 sfd, struct sockaddr *addr, int16 *namelen)
{
	return( getsockname( map_sfd( sfd ), addr, namelen ));
}

int16	cdecl st_getpeername (int32 fnc, int16 sfd, struct sockaddr *addr, int16 *namelen)
{
	printf("st_getpeername\n");
}

size_t cdecl st_read	(char *fnc, int16 sfd, void *buf, size_t len)
{
	printf("st_read\n");
}

size_t cdecl st_recv	(char *fnc, int16 sfd, void * buf, size_t len, uint16 flags)
{
	void	static *zwbuf = NULL;
	int32 r;
#ifdef DEBUG
	DebugMsg( "st_recv: handle=%i -> %i, len=%li, flags=%i\n", sfd, map_sfd( sfd ), len, flags );
#endif
	if( !buf )
	{
		zwbuf = malloc( len );
		buf = zwbuf;
	}
	if ( !buf )
		return( ENSMEM );
	r = recv( map_sfd( sfd ), buf, len, flags );
#ifdef DEBUG
	DebugMsg( "st_recv: %li\n", r );
	if( r > 0 )
		DebugPuf(buf,r);
#endif
	if( zwbuf )
		free( zwbuf );
	return( map_ret( r ));
}

size_t cdecl st_recvfrom (char *fnc, int16 sfd, void * buf, size_t len, unsigned flags, struct sockaddr *addr, int16 *addr_len)
{
#ifdef DEBUG
	DebugMsg( "st_recvfrom: handle=%i, flags=%i\n", sfd, flags );
#endif
	return( recvfrom( map_sfd( sfd ), buf, len, flags, addr, addr_len ));
}

size_t cdecl st_recvmsg (char *fnc, int16 sfd, struct msghdr *msg, uint16 flags)
{
	printf("st_recvmsg\n");
}

int16 cdecl st_seek (char *fnc, int16 sfd, size_t offset, int16 whence)
{
	printf("st_seek\n");
}

size_t cdecl st_send (char *fnc, int16 sfd, void *buf, size_t len, uint16 flags)
{
#ifdef DEBUG
	DebugMsg( "st_send: handle=%i\n%s\n", sfd, buf );
#endif
	Syield();
	return( map_ret( send( map_sfd( sfd ), buf, len, flags )));
}

size_t cdecl st_sendto (char *fnc, int16 sfd, void *buf, size_t len, uint16 flags, struct sockaddr *addr, int16 addr_len)
{
#ifdef DEBUG
	DebugMsg( "st_sendto: handle=%i\n", sfd );
#endif
	Syield();
	return( sendto( map_sfd( sfd ), buf, len, flags, addr, addr_len ));
}

size_t cdecl st_sendmsg (char *fnc, int16 sfd, struct msghdr *msg, uint16 flags)
{
	printf("st_sendmsg\n");
}

void cdecl st_set_loginparams	(int32 fnc, char *user, char *pass)
{
	printf("st_loginparams\n");
}

void cdecl st_set_options (int32 fnc, CFG_OPT *opt_ptr)
{
	printf("st_set_options\n");
}

int16 cdecl st_sethostid (int32 fnc, int32 new_id)
{
	printf("st_sethostid\n");
	
	return EINVFN;
}

int16 cdecl st_sethostip (int32 fnc, int32 new_id)
{
	printf("st_sethostip\n");
	
	return EINVFN;
}

int16 cdecl st_shutdown (int32 fnc, int16 sfd, int16 how)
{
	Syield();
	return( map_ret( shutdown( map_sfd( sfd ), how )));
}

int16 cdecl st_sock_accept (int32 fnc, int16 sfd, struct sockaddr *addr, int16 *addr_len)
{
#ifdef DEBUG
	DebugMsg( "accept: handle=%i\n", sfd );
#endif
	Syield();
	return( map_ret( map_it( accept( map_sfd( sfd ), addr, addr_len ))));
}

int16 cdecl st_sock_listen	(int32 fnc, int16 sfd, int16 backlog)
{
#ifdef DEBUG
	DebugMsg( "listen: handle=%i\n", sfd );
#endif
	return( listen( map_sfd( sfd ), backlog ));
}

int16 cdecl st_socket (int32 fnc, int16 domain, int16 type, int16 protocol)
{
	int16	r;
	r = map_it( socket( domain, type, protocol ));
#ifdef DEBUG
	DebugMsg( "st_socket: %i -> %i\n", map_sfd( r ), r );
#endif
	return( map_ret( r ));
}

static void map_fdset (int16 nsfd, st_fd_set *st_fds, fd_set *mint_fds )
{
	int16 i;
	FD_ZERO (mint_fds);
	for (i = 0; i < map_sfd( nsfd ); i++)
	{
		if (ST_FD_ISSET ( i, st_fds))
		{
			if( i < FD_SETSIZE )
			{
#ifdef DEBUG
	DebugMsg( "map: %i -> %i\n", map_it( i ), i );
#endif
				FD_SET ( i, mint_fds);
			}
		}
	}
}
static int32 remap_fdset (int16 nsfd, fd_set *mint_fds, st_fd_set *st_fds )
{
	int16 i, r = 0;
	ST_FD_ZERO (st_fds);
	for (i = 0; i < map_sfd( nsfd ); i++)
	{
		if (FD_ISSET (i, mint_fds))
		{
/*			if( map_it( i ) < ST_FD_SETSIZE )	*/
			{
#ifdef DEBUG
	DebugMsg( "remap: %i -> %i\n", i, map_it( i ));
#endif
				ST_FD_SET ( i, st_fds);
				r = i;
			}
		}
	}
	return( r );
}
int16 cdecl st_socket_select (int32 fnc, int16 nfds, st_fd_set *readfds, st_fd_set *writefds, st_fd_set *exceptfds, struct timeval *timeout)
{
	fd_set rfds, wfds, efds;
	fd_set *rptr = NULL, *wptr = NULL, *eptr = NULL;
	int16 r, a = 0, b = 0;
#ifdef DEBUG
	DebugMsg( "st_socket_select: handle=%i\n", nfds );
	if( timeout )
		DebugMsg( "timeout != NULL\n" );
	if( readfds )
		DebugMsg( "readfds != NULL\n" );
	if( writefds )
		DebugMsg( "writefds != NULL\n" );
	if( exceptfds )
		DebugMsg( "exceptfds != NULL\n" );
#endif

	if (readfds)
	{
		rptr = &rfds;
		map_fdset (nfds, readfds, rptr);
	}
	if (writefds)
	{
		wptr = &wfds;
		map_fdset (nfds, writefds, wptr);
	}
	if (exceptfds)
	{
		eptr = &efds;
		map_fdset (nfds, exceptfds, eptr);
	}

	r = select ( map_sfd( nfds ), rptr, wptr, NULL, timeout);
	if (readfds)
	{
		a = remap_fdset (nfds, rptr,readfds);
		if( a > b )
			b = a;
	}
	if (writefds)
	{
		a = remap_fdset (nfds, wptr,writefds);
		if( a > b )
			b = a;
	}
	if (exceptfds)
	{
		int16	i;
		for( i = 1; i < map_sfd( nfds ); i++ )
		{
			if( FD_ISSET( i, eptr ))
			{
				char	c;
/*				int16	p = send( i , &c, 0, 0 );	*/
				int16	p, q;
				q = sfcntl( i, F_GETFL, 0 );
				sfcntl( i, F_SETFL, O_NDELAY );
				p = recv( i , &c, 1, MSG_PEEK );
				sfcntl( i, F_SETFL, q );
#ifdef DEBUG
				DebugMsg( "Test: %i = %i\n", i, p );
#endif
				if( p < 0 )
				{
					FD_SET( i, eptr );
					r++;
				}
				else
					FD_CLR( i, eptr );
				sfcntl( i, F_SETFL, 0 );
			}
		}
		a = remap_fdset (nfds, eptr,exceptfds);	
		if( a > b )
			b = a;
	}
	if( !r )
	{
		if( readfds )
			ST_FD_ZERO( readfds );
		if( writefds )
			ST_FD_ZERO( writefds );
	}
#ifdef DEBUG
	DebugMsg( "st_socket_select: %i %i -> %i\n", r, b, map_it( b ));
#endif
	if( r < 0 )
		return( map_ret( r ));
	else
		return( map_it( b ));
}
size_t cdecl st_write (int32 fnc, int16 sfd, void *buf, size_t len)
{
	printf("st_write\n");
	
	return EINVFN;
}

int16	cdecl st_getsockopt (int16 sfd, int16 level, int16 optname, char *optval, int16 *optlen)
{
	printf("st_getsockopt\n");
	
	return EINVFN;
}
int16 cdecl st_setsockopt (int16 sfd, int16 level, int16 optname, char *optval, int16 optlen)
{
	printf("st_setsockopt\n");
}
int32 cdecl st_sockfcntl (int16 sfd, int16 cmd, int32 args)
{
#ifdef DEBUG
	DebugMsg( "st_sockfcntl: %i -> %i cmd = %i, arg = %li\n", sfd, map_sfd( sfd ), cmd, args);
#endif
	return( map_ret( sfcntl( map_sfd( sfd ), cmd, args )));
}

#pragma warn +par
