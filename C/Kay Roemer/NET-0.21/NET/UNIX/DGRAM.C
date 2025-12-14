/*
 *	send(), recv(), socketpair() and connect(), select() and ioctl()
 *	routines for datagram unix sockets.
 *
 *	10/17/93, kay roemer.
 */
 
#include "config.h"
#include "file.h"
#include "signal.h"
#include "kerbind.h"
#include "sockerr.h"
#include "atarierr.h"
#include "socket.h"
#include "net.h"
#include "un.h"
#include "iov.h"
#include "util.h"

extern void	*memcpy (void *d, const void *s, unsigned long n);

long
unix_dgram_socketpair (so1, so2)
	struct socket *so1, *so2;
{
	struct un_data *undata1 = so1->data, *undata2 = so2->data;

	undata1->index2 = UN_INDEX (undata2);
	undata2->index2 = UN_INDEX (undata1);
	undata1->flags |= UN_ISCONNECTED;
	undata2->flags |= UN_ISCONNECTED;
	return 0;
}

long
unix_dgram_connect (so, addr, addrlen, nonblock)
	struct socket *so;
	struct sockaddr *addr;
	short addrlen, nonblock;
{
	struct un_data *undata = so->data;
	long r;

	r = un_namei (addr, addrlen, &undata->index2);
	if (r < 0) {
		undata->flags &= ~UN_ISCONNECTED;
		return r;
	}
	undata->flags |= UN_ISCONNECTED;
	return 0;
}

long
unix_dgram_send (so, iov, niov, nonblock, flags, addr, addrlen)
	struct socket *so;
	struct iovec *iov;
	short niov;
	short nonblock, flags;
	struct sockaddr *addr;
	short addrlen;
{
	struct un_data *dstdata, *srcdata = so->data;
	struct dgram_hdr header;
	long index, r, todo, nbytes;
	short cando, head, tail;
	char *buf;

	if (so->state != SS_ISUNCONNECTED)
		return ENOTCONN;

/* First get the socket to which we are sending the datagram. */

	if (srcdata->flags & UN_ISCONNECTED) {
		if (addr) return EISCONN;
		index = srcdata->index2;
	} else {
		if (!addr) return EDESTADDRREQ;
		r = un_namei (addr, addrlen, &index);
		if (r < 0) return r;
	}

	nbytes = iov_size (iov, niov);
	if (nbytes < 0) return EINVAL;
	else if (nbytes == 0) return 0;

/* Check for the existence of the spezified destination. Note that we need
   to do that again after sleep()'s, because there's no other way to decide
   whether the destination socket is still alive. This should be improved
   later. */

check:
	dstdata = un_lookup (index, so->type);
	if (!dstdata) {
		DEBUG (("unix: unix_send: destination not found"));
		return EINVAL;
	}

/* If the destination is connected, but not to the sending socket, the
   destination socket cannot receive the message. */

	if (dstdata->flags & UN_ISCONNECTED &&
	    (!(srcdata->flags & UN_ISBOUND) ||
	    dstdata->index2 != UN_INDEX (srcdata))) {
		DEBUG (("unix: unix_send: dst connected, but not to us"));
		return nbytes;
	}
	if (dstdata->sock->flags & SO_CANTRCVMORE ||
	    so->flags & SO_CANTSNDMORE) {
		DEBUG (("unix: unix_send: shut down"));
		p_kill (p_getpid (), SIGPIPE);
		return EPIPE;
	}		
	if (UN_FREE (dstdata) < nbytes + sizeof (header)) {
		if (nonblock) return 0;
		if (nbytes + sizeof (header) > dstdata->buflen)
			return EMSGSIZE;
		if (isleep (IO_Q, (long)dstdata->sock)) {
			DEBUG (("unix: unix_send: interrupted"));
			return EINTR;
		}
		if (so->state != SS_ISUNCONNECTED)
			return ENOTCONN;
		goto check;
	}

/* Store the length and sender of the message, 'cuz the reader will
   need it. Note that buf, head, tail and buflen are word aligned. */ 
	header.nbytes = (short)nbytes;
	header.sender = UN_INDEX (srcdata);
	un_store_header (dstdata, &header);
	
	head = dstdata->head;
	tail = dstdata->tail;

	for (; niov; ++iov, --niov) {
		todo = iov->iov_len;
		buf = iov->iov_base;
		while (todo > 0) {
			if (tail >= head) {
				cando = dstdata->buflen - tail;
			} else {
				cando = head - tail - 1;
			}
			if (cando > todo) cando = (short)todo;
			memcpy (&dstdata->buf[tail], buf, cando);
			tail += cando;
			buf  += cando;
			todo -= cando;
			if (tail >= dstdata->buflen) tail = 0;
		}
	}
	dstdata->tail = tail;
	
	so_wakersel (dstdata->sock);
	wake (IO_Q, (long)dstdata->sock);
	return nbytes;
}

long
unix_dgram_recv (so, iov, niov, nonblock, flags, addr, addrlen)
	struct socket *so;
	struct iovec *iov;
	short niov;
	short nonblock, flags;
	struct sockaddr *addr;
	short *addrlen;
{
	struct un_data *undata = so->data;
	struct dgram_hdr header;
	short head, tail, cando;
	long todo, nbytes;
	char *buf;
	
	if (so->flags & SO_CANTRCVMORE || so->state != SS_ISUNCONNECTED)
		return 0; /* EOF */

	nbytes = iov_size (iov, niov);
	if (nbytes < 0) return EINVAL;
	else if (nbytes == 0) return 0;

	while (!UN_USED (undata)) {
		if (nonblock) return 0;
		if (isleep (IO_Q, (long)so)) {
			DEBUG (("unix: unix_recv: interrupted"));
			return EINTR;
		}
		if (so->flags & SO_CANTRCVMORE || so->state != SS_ISUNCONNECTED)
			return 0; /* EOF */
	}
	un_read_header (undata, &header, 1);

	head = undata->head;
	tail = undata->tail;
	
	if (header.nbytes < 0) {
		FATAL (("unix: unix_recv: msg size < 0!!!"));
		return EINTRN;
	}
	for (nbytes = 0; niov; ++iov, --niov) {
		todo = iov->iov_len;
		buf = iov->iov_base;
		if (nbytes + todo > header.nbytes) {
			todo = header.nbytes - nbytes;
			if (!todo) break;
		}
		nbytes += todo;
		while (todo > 0) {
			if (tail >= head) {		
				cando = tail - head;
			} else {
				cando = undata->buflen - head;
			}
			if (cando > todo) cando = (short)todo;
			memcpy (buf, &undata->buf[head], cando);
			buf  += cando;
			head += cando;
			todo -= cando;
			if (head >= undata->buflen) head = 0;
		}
	}
	{
		long newhead = undata->head + header.nbytes;
		if (newhead >= undata->buflen)
			newhead -= undata->buflen;
		undata->head = (short)newhead;
	}
	if (addr && addrlen) {
		undata = un_lookup (header.sender, so->type);
		if (*addrlen > 0 && undata && undata->flags & UN_ISBOUND) {
			todo = MIN (*addrlen - 1, undata->addrlen);
			memcpy (addr, &undata->addr, todo);
			((struct sockaddr_un *)addr)->
				sun_path[todo - UN_PATH_OFFSET] = '\0';
			*addrlen = todo;
		} else {
			DEBUG (("unix_recv: cannot find address for sender"));
			*addrlen = 0;		
		}
	}
	so_wakewsel (so);
	wake (IO_Q, (long)so);
	return nbytes;
}

long
unix_dgram_select (so, how, proc)
	struct socket *so;
	short how;
	long proc;
{
	struct un_data *undata = so->data;
	
	switch (how) {
	case O_RDONLY:
		if (UN_USED (undata) || (so->flags & SO_CANTRCVMORE)) {
			return 1;
		} else {
			return so_rselect (so, proc);
		}
		
	case O_WRONLY:
		return 1; /* BUG */
		
	default:
		return 1;
	}
}

long
unix_dgram_ioctl (so, cmd, buf)
	struct socket *so;
	short cmd;
	void *buf;
{
	struct un_data *undata = so->data, *peerun = 0;

	switch (cmd) {
	case FIONREAD:
		if (so->flags & SO_CANTRCVMORE) {
			*(long *)buf = -1;
		} else {
			struct dgram_hdr header = { 0, 0 };

			if (UN_USED (undata)) {
				un_read_header (undata, &header, 0);
			}
			if (header.nbytes < 0) {
				FATAL (("unix: unix_ioctl (FIONREAD): paket "
					"size < 0!!!"));
			}
			*(long *)buf = header.nbytes;
		}
		return 0;
		
	case FIONWRITE:
		if (undata->flags & UN_ISCONNECTED) {
			peerun = un_lookup (undata->index2, so->type);
			if (!peerun) {
				*(long *)buf = -1;
				return 0;
			}
		}
		if (so->flags & SO_CANTSNDMORE ||
		    (peerun && peerun->sock->flags & SO_CANTRCVMORE)) {
			*(long *)buf = -1;
		} else if (peerun) {
			*(long *)buf = (UN_FREE (peerun) -
				sizeof (struct dgram_hdr));
		} else {
			*(long *)buf = 0; /* BUG */
		}
		return 0;
		
	default:
		return EINVFN;
	}
}

long
unix_dgram_getname (so, addr, addrlen, peer)
	struct socket *so;
	struct sockaddr *addr;
	short *addrlen, peer;
{
	struct un_data *undata = so->data;
	short todo;

	if (peer == PEER_ADDR) {
		if (undata->flags & UN_ISCONNECTED) {
			undata = un_lookup (undata->index2, so->type);
			if (!undata) {
				DEBUG (("unix_getname: cannot find peer"));
				return EINVAL;
			}
		} else {
			DEBUG (("unix_getname: not connected"));
			return ENOTCONN;
		}
	}
	if (addr && addrlen) {
		if (*addrlen < 0) {
			DEBUG (("unix_getname: invalid addresslen"));
			return EINVAL;
		}
		if (undata->flags & UN_ISBOUND) {
			todo = MIN (*addrlen - 1, undata->addrlen);
			memcpy (addr, &undata->addr, todo);
			((struct sockaddr_un *)addr)->
				sun_path[todo - UN_PATH_OFFSET] = '\0';
			*addrlen = todo;
		} else	*addrlen = 0;
	}
	return 0;
}
