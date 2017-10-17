/*
 * Filename:     gs_func.c
 * Project:      GlueSTiK
 * 
 * Note:         Please send suggestions, patches or bug reports to me
 *               or the MiNT mailing list <mint@fishpool.com>.
 * 
 * Copying:      Copyright 1999 Frank Naumann <fnaumann@cs.uni-magdeburg.de>
 * 
 * Portions copyright 1997, 1998, 1999 Scott Bigham <dsb@cs.duke.edu>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#include <osbind.h>
#include <string.h>
#include <errno.h>
#include "config.h"
#include "sockets.h"
#include "netdb.h"
#include "gs_func.h"
#include "gs_mem.h"
#include "gs_stik.h"

#ifdef NETWORK
#ifdef LWIP

extern int errno;

int gs_xlate_error (int err, const char *funcname)
{
	int ret;
	
	switch (err)
	{
		case ENOSYS:
		case EOPNOTSUPP:
			ret = E_NOROUTINE;
			break;
		
		case EMFILE:
			ret = E_NOCCB;
			break;
		
		case EBADF:
		case ENOTSOCK:
			ret = E_BADHANDLE;
			break;
		
		case ENOMEM:
		case ESBLOCK:
			ret = E_NOMEM;
			break;
		
		case EBADARG:
		case EADDRINUSE:
		case EADDRNOTAVAIL:
			ret = E_PARAMETER;
			break;
		
		case ECONNRESET:
			ret = E_RRESET;
			break;
		
		case ETIMEDOUT:
			ret = E_CNTIMEOUT;
			break;
		
		case ECONNREFUSED:
			ret = E_REFUSE;
			break;
		
		case ENETDOWN:
		case ENETUNREACH:
		case EHOSTDOWN:
		case EHOSTUNREACH:
			ret = E_UNREACHABLE;
			break;
		
		default:
			ret = -1000 + err;
			break;
	}
	
# ifdef GS_DEBUG
	if (funcname)
	{
		struct get_err_text_param p = { ret };
		PRINT_DEBUG (("%s() returns %i (%s)",
			funcname, ret, do_get_err_text (p)));
	}
# endif
	
	return ret;
}

static long gs_read_socket (int fd, void *buf, int size)
{
	int ret, n, len, avail, bytes = 0;
	GS *gs = gs_get (fd);

	if (gs->flags & GS_NOSOCKET)
	{
		PRINT_DEBUG (("read_socket: bad handle"));
		return E_BADHANDLE;
	}

	while (size > 0)
  {
		ret = ioctlsocket (gs->sock_fd, FIONREAD, &n);
		if (ret < 0)
		{
			PRINT_DEBUG (("gs_read_socket: ioctlsocket(FIONREAD) returns %i (%i)", ret, errno));
			return gs_xlate_error (errno, "gs_read_socket");
		}
		len = (int)(gs->end_cache_read - gs->pos_cache_read);
		if (size > len + n)
		{
			PRINT_DEBUG (("gs_read_socket: only %i bytes available", len + n));
			return E_NODATA;
		}

		if (size <= len) /* data in cache */	
		{
			memcpy (buf, gs->pos_cache_read, size);
			gs->pos_cache_read += size;
			bytes += size;
			return (long)bytes;  
		}

		avail = GS_CACHE_SIZE - (int)(gs->end_cache_read - gs->cache_read);
    if (n > avail)
			n = avail;

		PRINT_DEBUG (("gs_read_socket: read(%i, %p, %i)", gs->sock_fd, (void *) gs->end_cache_read, n));

		ret = read (gs->sock_fd, gs->end_cache_read, n);
		if (ret < 0)
		{
			PRINT_DEBUG (("gs_read_socket: read() returns %i (%i)", ret, errno));
			return gs_xlate_error (errno, "gs_read");
		}
		gs->end_cache_read += ret;
		len = (int)(gs->end_cache_read - gs->pos_cache_read);
		if (size < len) /* data in cache */	
		{
			memcpy (buf, gs->pos_cache_read, size);
			gs->pos_cache_read += size;
			bytes += size;
			return (long)bytes;  
		}
		memcpy(buf, gs->pos_cache_read, len);
		size -= len;
		buf = (void *)((int)buf + len);
		bytes += len;
		gs->end_cache_read = gs->pos_cache_read = gs->cache_read;
  }
  
  return (long)bytes;
}

# define TABLE_SIZE	128
static GS *table [TABLE_SIZE];

int gs_open (void)
{
	int fd;
	
	for (fd = 1; fd < TABLE_SIZE; fd++)
	{
		if (!table [fd])
		{
			GS *gs;
			
			gs = gs_mem_alloc (sizeof (*gs));
			if (!gs)
				return ENOMEM;
			
			bzero (gs, sizeof (*gs));

			gs->end_cache_read = gs->pos_cache_read = gs->cache_read;

			gs->flags = GS_NOSOCKET;
			
			table [fd] = gs;
			
			return fd;
		}
	}
	
	return EMFILE;
}

void gs_close (int fd)
{
	GS *gs = table [fd];

	PRINT_DEBUG (("gs_close(%i)", fd));
	
	if (gs)
	{
		if (!(gs->flags & GS_NOSOCKET))
			close (gs->sock_fd); 
		
		gs_mem_free (gs);
		
		table [fd] = NULL;
	}
}

GS *gs_get (int fd)
{
	if ((fd >= 0) && (fd < TABLE_SIZE))
		return table [fd];
	
	return NULL;
}

int gs_accept (int fd)
{
	GS *gs = gs_get (fd);
	struct sockaddr_in addr, addr2;
	socklen_t addr_size = sizeof (struct sockaddr_in);
	int in_fd;
	long fdflags;
	int ret;
	
	PRINT_DEBUG (("gs_accept(%i)", fd));
	
	if (!gs
		|| gs->flags & GS_NOSOCKET
		|| !(gs->flags & GS_LISTENING))
	{
		PRINT_DEBUG (("gs_accept: bad handle"));
		return E_BADHANDLE;
	}
	
	/* switch to non-blocking mode */
	fdflags = 1;
	ret = ioctlsocket (gs->sock_fd, FIONBIO, &fdflags);
	if (ret < 0)
	{
		PRINT_DEBUG (("gs_accept: ioctlsocket(FIONBIO) returns %i (%i)", ret, errno));
		return gs_xlate_error (errno, "gs_accept");
	}
	
	in_fd = accept (gs->sock_fd, (struct sockaddr *) &addr, &addr_size);
	
	/* restore flags */
	fdflags = 0;
	ret = ioctlsocket (gs->sock_fd, FIONBIO, &fdflags);
	if (ret < 0)
	{
		PRINT_DEBUG (("gs_accept: ioctlsocket(FIONBIO) returns %i (%i)", ret, errno));
		return gs_xlate_error (errno, "gs_accept");
	}
	
	if (in_fd < 0)
	{
		PRINT_DEBUG (("gs_accept: accept() returns %i (%i)", in_fd, errno));
		
		if (errno == EWOULDBLOCK)
		{
			PRINT_DEBUG (("gs_accept: no connections arrived; returning E_LISTEN"));
			return E_LISTEN;
		}
		
		return gs_xlate_error (errno, "gs_accept");
	}
	
	/* Fill in the CIB. Part of the data we need came back from accept();
	 * get the rest via getsockname().
	 */
	addr_size = sizeof (struct sockaddr_in);
	if ((ret = getsockname (in_fd, (struct sockaddr *) &addr2, &addr_size)) < 0)
	{
		PRINT_DEBUG (("gs_accept: getsockname() returns %i (%i)", ret, errno));
		return gs_xlate_error (errno, "gs_accept");
	}
	
	gs->cib.protocol = P_TCP;
	gs->cib.lport = addr2.sin_port;
	gs->cib.rport = addr.sin_port;
	gs->cib.rhost = addr.sin_addr.s_addr;
	gs->cib.lhost = addr2.sin_addr.s_addr;
	
	/* In STiK, an accept() "eats" the listen()'ed socket; we emulate that by
	 * closing it and replacing it with the newly accept()'ed socket.
	 */
	close (gs->sock_fd); 
	gs->sock_fd = in_fd;
	gs->flags &= ~GS_LISTENING;
	
	PRINT_DEBUG (("gs_accept: returns 0"));
	return 0;
}

# if 0
int gs_establish (int fd)
{
	GS *gs = gs_get (fd);
	fd_set wfs;
  struct timeval tv;
	int n;
	
	PRINT_DEBUG (("gs_establish(%i)", fd));
	
	if (!gs || gs->flags & GS_NOSOCKET || !(gs->flags & GS_PEND_OPEN))
	{
		PRINT_DEBUG (("gs_establish: bad handle"));
		return E_BADHANDLE;
	}
	
	FD_ZERO(&wfs);
	FD_SET(gs->sock_fd, &wfs);
	tv.tv_sec = 1;
	tv.tv_usec = 0;
	n = select(FD_SETSIZE, NULL, &wfs, NULL, &tv);		
	if (n > 0)
	{
		gs->flags &= ~GS_PEND_OPEN;
		
		PRINT_DEBUG (("gs_establish: returns 0"));
		return 0;
	}
	else if (n < 0)
	{
		PRINT_DEBUG (("gs_establish: select() returns %i (%i)", n, errno));
		return gs_xlate_error(errno, "gs_establish");
	}
	
	PRINT_DEBUG (("gs_establish: timeout"));
	return E_USERTIMEOUT;
}
# endif

long gs_connect (int fd, uint32 rhost, int16 rport, uint32 lhost, int16 lport)
{
	GS *gs = gs_get (fd);
	struct sockaddr_in laddr;
	struct sockaddr_in raddr;
	socklen_t addr_size = sizeof (struct sockaddr_in);
	int sock_fd;
	int retval;
# if 0
	long fdflags;
	int pending = 0;
# endif

	laddr.sin_family = AF_INET;
	laddr.sin_addr.s_addr = lhost;
	laddr.sin_port = lport;
	raddr.sin_family = AF_INET;
	raddr.sin_addr.s_addr = rhost;
	raddr.sin_port = rport;

	PRINT_DEBUG (("gs_connect(%i, {%s, %i}, {%s, %i}) [%x]",
		fd, inet_ntoa(raddr.sin_addr), rport, inet_ntoa(laddr.sin_addr), lport, gs ? gs->flags : 0xffff));
	
	if (!gs || !(gs->flags & GS_NOSOCKET))
	{
		PRINT_DEBUG (("gs_connect: bad handle"));
		return E_BADHANDLE;
	}
	
	sock_fd = socket (AF_INET, SOCK_STREAM, 0);
	if (sock_fd < 0)
	{
		PRINT_DEBUG (("gs_connect: socket() returns %i (%i)", sock_fd, errno));
		return gs_xlate_error (errno, "gs_connect");
	}
# if 0
	/* switch to non-blocking mode */
	fdflags = 1;
	retval = ioctlsocket (gs->sock_fd, FIONBIO, &fdflags);
	if (retval < 0)
	{
		PRINT_DEBUG (("gs_connect: ioctlsocket(FIONBIO) returns %i (%i)", retval, errno));
		return gs_xlate_error (errno, "gs_connect");
	}
# endif
	
	retval = bind (sock_fd, (struct sockaddr *) &laddr, addr_size);
	if (retval < 0)
	{
		PRINT_DEBUG (("gs_connect: bind() returns %i (%i)", retval, errno));
		return gs_xlate_error (errno, "gs_connect");
	}
	
	if (rhost == 0)
	{
		retval = listen (sock_fd, 5);
		if (retval < 0)
		{
			PRINT_DEBUG (("gs_connect: listen() returns %i (%i)", retval, errno));
			return gs_xlate_error (errno, "gs_connect");
		}
	}
	else
	{
		retval = connect (sock_fd, (struct sockaddr *) &raddr, addr_size);
# if 0
		if (retval == EINPROGRESS)
		{
			pending = 1;
		}
		else
# endif
		if (retval < 0)
		{
			PRINT_DEBUG (("gs_connect: connect() returns %i (%i)", retval, errno));
			return gs_xlate_error (errno, "gs_connect");
		}
	}
	
	/* Fill in the CIB. Data for the remote end was provided by the parms
	 * in the connect() case, and filled in as zero by the stub in the
	 * listen() case; data for the local end was probably changed by the
	 * bind(), so update it via getsockname().
	 */
	retval = getsockname (sock_fd, (struct sockaddr *) &laddr, &addr_size);
	if (retval < 0)
	{
		PRINT_DEBUG (("gs_connect: getsockname() returns %i (%i)", retval, errno));
		return gs_xlate_error (errno, "gs_connect");
	}
	
	gs->cib.protocol = P_TCP;
	gs->cib.rhost = raddr.sin_addr.s_addr;
	gs->cib.rport = raddr.sin_port;
	gs->cib.lhost = laddr.sin_addr.s_addr;
	gs->cib.lport = laddr.sin_port;
	
	gs->sock_fd = sock_fd;
	if (rhost == 0)
	{
		gs->flags = GS_LISTENING;
	}
	else
	{
# if 0
		gs->flags = pending ? GS_PEND_OPEN : 0;
# else
		gs->flags = 0;
# endif
	}
	
	PRINT_DEBUG (("gs_connect: returns 0 [%x]", gs->flags));
	return 0;
}

long gs_udp_open (int fd, uint32 rhost, int16 rport)
{
	GS *gs = gs_get (fd);
	struct sockaddr_in addr, addr2;
	socklen_t addr_size = sizeof (struct sockaddr_in);
	int sock_fd;
	int retval;
# if 0
	int pending = 0;
# endif

	addr.sin_family = AF_INET;
	addr.sin_addr.s_addr = rhost;
	addr.sin_port = rport;
	
	PRINT_DEBUG (("gs_udp_open(%i, %s, %i)", fd, inet_ntoa(addr.sin_addr), rport));
	
	if (!gs || !(gs->flags & GS_NOSOCKET))
	{
		PRINT_DEBUG (("gs_udp_open: bad handle"));
		return E_BADHANDLE;
	}
	
	sock_fd = socket (AF_INET, SOCK_DGRAM, 0);
	if (sock_fd < 0)
	{
		PRINT_DEBUG (("gs_udp_open: socket() returns %i (%i)", sock_fd, errno));
		return gs_xlate_error (errno, "gs_udp_open");
	}
	
	retval = connect (sock_fd, (struct sockaddr *) &addr, addr_size);
# if 0
	if (retval == EINPROGRESS)
	{
		pending = 1;
	}
	else
# endif
	if (retval < 0)
	{
		PRINT_DEBUG (("gs_udp_open: connect() returns %i (%i)", retval, errno));
		return gs_xlate_error (errno, "gs_udp_open");
	}
	
	/* Fill in the CIB. Part of the data we need came from our
	 * parameters; get the rest via getsockname().
	 */
	addr_size = sizeof (struct sockaddr_in);
	retval = getsockname (sock_fd, (struct sockaddr *) &addr2, &addr_size);
	if (retval < 0)
	{
		PRINT_DEBUG (("gs_udp_open: getsockame() returns %i (%i)", retval, errno));
		return gs_xlate_error (errno, "gs_udp_open");
	}
	
	gs->cib.protocol = P_TCP;
	gs->cib.lport = addr2.sin_port;
	gs->cib.rport = addr.sin_port;
	gs->cib.rhost = addr.sin_addr.s_addr;
	gs->cib.lhost = addr2.sin_addr.s_addr;
	
	gs->sock_fd = sock_fd;
# if 0
	gs->flags = pending ? GS_PEND_OPEN : 0;
# else
	gs->flags = 0;
# endif
	
	PRINT_DEBUG (("gs_udp_open: returns 0"));
	return 0;
}

long gs_wait (int fd, int timeout)
{
	GS *gs = gs_get (fd);
	fd_set rfs, wfs;
	struct timeval tv;
	int n;
	
	PRINT_DEBUG (("gs_wait(%i, %i) [%x]", fd, timeout, gs ? gs->flags : 0xffff));
	
	if (!gs || (gs->flags & GS_NOSOCKET))
	{
		PRINT_DEBUG (("gs_wait: bad handle"));
		return E_BADHANDLE;
	}
	
	if ((gs->flags & (GS_LISTENING
# if 0
				| GS_PEND_OPEN
# endif
				)) == 0)
	{
		PRINT_DEBUG (("gs_wait: returns E_NORMAL (LISTENING)"));
		return E_NORMAL;
	}

	tv.tv_sec = timeout;
	tv.tv_usec = 0;
	if (gs->flags & GS_LISTENING)
	{
		FD_ZERO(&rfs);
		FD_SET(gs->sock_fd, &rfs);
		n = select(FD_SETSIZE, &rfs, NULL, NULL, &tv);	
	}
	else
	{
		FD_ZERO(&wfs);
		FD_SET(gs->sock_fd, &wfs);
		n = select(FD_SETSIZE, NULL, &wfs, NULL, &tv);	
	}
	
	if (n > 0)
	{
		/* Finish establishing the connection.
		 */
		if (gs->flags & GS_LISTENING)
			n = gs_accept (fd);
# if 0
		else
			n = gs_establish (fd);
# endif
		if (n == 0)
		{
			PRINT_DEBUG (("gs_wait: returns 0"));
			return 0;
		}
		else
		{
			PRINT_DEBUG (("gs_wait:: gs_%s() returns %li",
				((gs->flags & GS_LISTENING) ? "accept" : "establish"), n));
			return n;
		}
	}
	else if (n == 0)
	{
		PRINT_DEBUG (("gs_wait: timeout"));
		return E_USERTIMEOUT;
	}
	
	PRINT_DEBUG (("gs_wait: select() returns %li (%i)", n, errno));
	return gs_xlate_error (errno, "gs_wait");
}

long gs_canread (int fd)
{
	GS *gs = gs_get (fd);
	int r, n;
	
	PRINT_DEBUG (("gs_canread(%i)", fd));
	
	if (gs->flags & GS_NOSOCKET)
	{
		PRINT_DEBUG (("gs_canread: bad handle"));
		return E_BADHANDLE;
	}
	
	if ((gs->flags & GS_LISTENING) && gs_accept (fd) != 0)
	{
		PRINT_DEBUG (("gs_canread: no connection arrived"));
		return E_LISTEN;
	}
	
# if 0
	if ((gs->flags & GS_PEND_OPEN) && gs_establish (fd) != 0)
	{
		PRINT_DEBUG (("gs_canread: open in progress"));
		return 0;
	}
# endif
	
	r = ioctlsocket (gs->sock_fd, FIONREAD, &n);
	if (r < 0)
	{
		PRINT_DEBUG (("gs_canread: ioctlsocket(FIONREAD) returns %i (%i)", r, errno));
		return gs_xlate_error (errno, "gs_canread");
	}
 	n += (int)(gs->end_cache_read - gs->pos_cache_read);

	if (n == 0)
	{
		while(1)
		{
			fd_set rfs;
			struct timeval tv;
			tv.tv_sec = 1;
			tv.tv_usec = 0;
			FD_ZERO(&rfs);
			FD_SET(gs->sock_fd, &rfs);
			r = select(FD_SETSIZE, &rfs, NULL, NULL, &tv);	
			if (r < 0)
			{
				PRINT_DEBUG (("gs_canread: select() returns %i (%i)", r, errno));
				return gs_xlate_error (errno, "gs_canread");	
			}
 		 	else if((r > 0) && (FD_ISSET(gs->sock_fd, &rfs) != 0))
	 	 	{
				r = ioctlsocket (gs->sock_fd, FIONREAD, &n);
				if (r < 0)
				{
					PRINT_DEBUG (("gs_canread: ioctlsocket(FIONREAD) returns %i (%i)", r, errno));
					return gs_xlate_error (errno, "gs_canread");
				}
 				n += (int)(gs->end_cache_read - gs->pos_cache_read);
				if (n == 0)
				{
					PRINT_DEBUG (("gs_canread: EOF reached"));
					return E_EOF;
				}
 				break;
 			}
  	}
	}

	PRINT_DEBUG (("gs_canread: returns %i", n));
	return (long)n;
}

long gs_read_delim (int fd, char *buf, int len, char delim)
{
	int n = 0;
	long r;
	
	PRINT_DEBUG (("gs_read_delim(%i, %p, %i, %c)", fd, (void *) buf, len, delim));
	
	while (n < len - 1)
	{
		r = gs_read (fd, buf + n, 1);
		if (r < 0)
			return r;
		
		if (r == 0)
		{
			PRINT_DEBUG (("gs_read_delim: end of data"));
			
			return E_NODATA;
		}
		
		if (buf[n] == delim)
			break;
		
		n++;
		continue;
	}
	
	buf [n] = '\0';
	
	PRINT_DEBUG (("gs_read_delim: returns %i", n));
	return n;
}

NDB *gs_readndb (int fd)
{
	GS *gs = gs_get (fd);
	NDB *ndb;
	int n, ret;
	
	PRINT_DEBUG (("gs_readndb(%i)", fd));
	
	if (gs->flags & GS_NOSOCKET)
	{
		PRINT_DEBUG (("gs_readndb: bad handle"));
		return NULL;
	}
	
	if ((gs->flags & GS_LISTENING) && gs_accept (fd) != 0)
	{
		PRINT_DEBUG (("gs_readndb: no connections arrived"));
		return NULL;
	}
	
# if 0
	if ((gs->flags & GS_PEND_OPEN) && gs_establish (fd) != 0)
	{
		PRINT_DEBUG (("gs_readndb: open in progress"));
		return NULL;
	}
# endif
	
	n = gs_canread (fd);
	if (n <= 0)
	{
		PRINT_DEBUG (("gs_readndb: no data available"));
		return NULL;
	}
	
	if (n > 65535)
		n = 65535;
	
	ndb = gs_mem_alloc (sizeof (*ndb));
	if (!ndb)
	{
		PRINT_DEBUG (("gs_readndb: no memory for NDB"));
		return NULL;
	}
	
	ndb->ptr = gs_mem_alloc (n);
	if (!ndb->ptr)
	{
		gs_mem_free (ndb);
		
		PRINT_DEBUG (("gs_readndb: no memory for data"));
		return NULL;
	}

	ret = (int)gs_read_socket (fd, ndb->ptr, n);	 
//	ret = read (gs->sock_fd, ndb->ptr, n);	
	if (ret < 0)
	{
		gs_mem_free (ndb->ptr);
		gs_mem_free (ndb);
		
		PRINT_DEBUG (("gs_readndb: read() returned %i", ret));
		return NULL;
	}
	
	ndb->ndata = ndb->ptr;
	ndb->len = n;
	ndb->next = 0;
	
	PRINT_DEBUG (("gs_readndb: read %i bytes, returns %p", n, (void *) ndb));
	return ndb;
}

long gs_write (int fd, char *buf, long buflen)
{
	GS *gs = gs_get (fd);
	int r;
//	int n;

	PRINT_DEBUG (("gs_write(%i, %p, %li)", fd, (void *) buf, buflen));
	
	if (gs->flags & GS_NOSOCKET)
	{
		PRINT_DEBUG (("gs_write: bad handle"));
		return E_BADHANDLE;
	}
	
	if ((gs->flags & GS_LISTENING) && gs_accept (fd) != 0)
	{
		PRINT_DEBUG (("gs_write: no connections arrived"));
		return E_LISTEN;
	}
	
# if 0
	/* This is kind of a lie, but at least it's an error code a STiK app
	 * will be prepared to deal with.
	 */
	if ((gs->flags & GS_PEND_OPEN) && gs_establish (fd) != 0)
	{
		PRINT_DEBUG (("gs_write: open in progress"));
		return E_OBUFFULL;
	}
# endif
	
	/* STiK has no provisions for writing part of a buffer and saving the
	 * rest for later; so make sure we can write the whole thing.
	 */
#if 0
	r = ioctlsocket (gs->sock_fd, FIONWRITE, &n);
	if (r < 0)
	{
		PRINT_DEBUG (("gs_write: ioctlsocket(FIONWRITE) returned %i (%i)", r, errno));
		return gs_xlate_error (errno, "gs_write");
	}

	if (n < (int)buflen)
	{
		PRINT_DEBUG (("gs_write: can only write %i bytes; returning E_OBUFFULL", n));
		return E_OBUFFULL;
	}
#endif
	
	/* Okay, we can safely write.
	 */
	r = write (gs->sock_fd, buf, (int)buflen);
	if (r < 0)
	{
		PRINT_DEBUG (("gs_write: write() returned %i (%i)", r, errno));
		return gs_xlate_error (errno, "gs_write");
	}
	
	/* Okay, according to the ioctlsocket(), we should have been able to
	 * write everything; warn if we didn't.
	 */
	if (r < (int)buflen)
		PRINT_DEBUG (("gs_write: only got %i of %li bytes", r, buflen));
	
	PRINT_DEBUG (("gs_write: returns E_NORMAL [%x]", gs->flags));
#if 0
	for(r = 0; r < (int)buflen; r++)
	{
		if(buf[r] == '\n')
			board_printf("\r\n");
		else
			board_printf("%c", (buf[r] >= ' ' && buf[r] < 127) ? buf[r] : '.');
	}
	if(buflen > 1)
		board_printf("\r\n");
#endif

	return E_NORMAL;
}

long gs_read (int fd, char *buf, long buflen)
{
	GS *gs = gs_get (fd);
	long n;
	int r;
	
//	PRINT_DEBUG (("gs_read(%i, %p, %li)", fd, (void *) buf, buflen));
	
	if (gs->flags & GS_NOSOCKET)
	{
		PRINT_DEBUG (("gs_read: bad handle"));
		
		return E_BADHANDLE;
	}
	
	if ((gs->flags & GS_LISTENING) && gs_accept (fd) != 0)
	{
		PRINT_DEBUG (("gs_read: no connections arrived"));
		
		return E_LISTEN;
	}
	
# if 0
	if ((gs->flags & GS_PEND_OPEN) && gs_establish (fd) != 0)
	{
		PRINT_DEBUG (("gs_read: open in progress"));
		
		return E_NODATA;
	}
# endif
	
#if 1
	if((int)(gs->end_cache_read - gs->pos_cache_read) == 0)
	{
		/* STiK has no provisions for reading less than a full buffer's worth
		 * of data; make sure we can fill the buffer.
		 */
		n = gs_canread (fd);
		if (n < 0)
			return n;
	
		if (n < buflen)
		{
			PRINT_DEBUG (("gs_read: only %li bytes available", n));
		
			return E_NODATA;
		}
	}

	/* Okay, we can safely read.
	 */
	n = gs_read_socket (fd, buf, (int)buflen);	 
	if (n < 0)
		return n;
	r = (int)n;
	
#else
	/* STiK has no provisions for reading less than a full buffer's worth
	 * of data; make sure we can fill the buffer.
	 */
	n = gs_canread (fd);
	if (n < 0)
		return n;
	
	if (n < buflen)
	{
		PRINT_DEBUG (("gs_read: only %li bytes available", n));
		
		return E_NODATA;
	}
	
	/* Okay, we can safely read.
	 */
	r = read (gs->sock_fd, buf, (int)buflen);
	if (r < 0)
	{
		PRINT_DEBUG (("gs_read: read() returns %i (%i)", r, errno));
		return gs_xlate_error (errno, "gs_read");
	}
#endif
	
	/* Okay, according to the ioctlsocket(), we should have been able to
	 * fill the entire buffer; warn if we didn't.
	 */
	if (r < buflen)
		PRINT_DEBUG (("gs_read: unable to read all %li bytes", buflen));

//	PRINT_DEBUG (("gs_read: returns %li (%i)", buflen, r));	

#if 0
	for(r = 0; r < (int)buflen; r++)
	{
		if(buf[r] == '\n')
			board_printf("\r\n");
		else
			board_printf("%c", (buf[r] >= ' ' && buf[r] < 127) ? buf[r] : '.');
	}
	if(buflen > 1)
		board_printf("\r\n");
#endif

	return buflen;
}

int gs_resolve (char *dn, char **rdn, uint32 *alist, int16 lsize)
{
	struct hostent *host;
	int ret;
	char **raddr;

	PRINT_DEBUG (("gs_resolve(\"%s\", %p, %p, %i)", dn, rdn, alist, lsize));

	host = gethostbyname (dn);
	if(host == NULL)
	{
		extern int h_errno;
		
		switch (h_errno)
		{
			case HOST_NOT_FOUND:
				ret = E_NOHOSTNAME;
				break;
			case NO_DATA:
				ret = E_DNSNOADDR;
				break;
			case TRY_AGAIN:
			case NO_RECOVERY:
			default:
				ret = E_CANTRESOLVE;
				break;
		}
		
		PRINT_DEBUG (("gs_resolve: h_errno = %d -> %i", h_errno, ret));
		goto out;
	}

	if (rdn)
	{
		PRINT_DEBUG (("gs_resolve: Copying name: \"%s\"", host->h_name));
		
		*rdn = gs_mem_alloc (strlen (host->h_name) + 1);
		strcpy (*rdn, host->h_name);
	}
	
	/* BUG:  assumes addresses returned have type struct in_addr
	 */
	for (ret = 0, raddr = host->h_addr_list; *raddr && ret < lsize; ret++, raddr++)
	{
		struct in_addr addr;
		addr.s_addr = ((struct in_addr *) (*raddr))->s_addr;

		PRINT_DEBUG (("gs_resolve: Copying address %s to array element %i",
			inet_ntoa(addr), ret));
		
		alist [ret] = addr.s_addr;
	}

out:
	PRINT_DEBUG (("gs_resolve: returns %i", ret));
	return ret;
}

#endif /* LWIP */
#endif /* NETWORK */

