/*
 *	send(), recv(), socketpair(), connect(), select() and ioctl()
 *	routines for stream unix sockets.
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
extern long	unix_stream_getname (struct socket*, struct sockaddr *, short *,
				    short);


long
unix_stream_socketpair (so1, so2)
	struct socket *so1, *so2;
{
	so_sockpair (so1, so2);
	return 0;
}

long
unix_stream_connect (so, addr, addrlen, nonblock)
	struct socket *so;
	struct sockaddr *addr;
	short addrlen, nonblock;
{
	struct un_data *server_data;
	long r, index;

	if (so->state == SS_ISCONNECTING) return EALREADY;

	r = un_namei (addr, addrlen, &index);
	if (r < 0) return r;
	
	server_data = un_lookup (index, SOCK_STREAM);
	if (!server_data) {
		DEBUG (("unix: unix_connect: server not found"));
		return EINVAL;
	}
	r = so_connect (server_data->sock, so, server_data->backlog, nonblock);
	if (r < 0) {
		DEBUG (("unix: unix_connect: connection not finished"));
		return r;
	}
	return 0;
}

long
unix_stream_send (so, iov, niov, nonblock, flags, addr, addrlen)
	struct socket *so;
	struct iovec *iov;
	short niov;
	short nonblock, flags;
	struct sockaddr *addr;
	short addrlen;
{
	struct un_data *undata;
	char *buf;
	short cando;
	long todo, nbytes;
	
	switch (so->state) {
	case SS_ISCONNECTED:
		undata = so->conn->data;
		break;

	case SS_ISDISCONNECTING:
	case SS_ISDISCONNECTED:
		DEBUG (("unix: unix_send: broken connection"));
		p_kill (p_getpid (), SIGPIPE);
		return EPIPE;

	default:
		DEBUG (("unix: unix_send: not connected"));
		return ENOTCONN;
	}
	if (so->conn->flags & SO_CANTRCVMORE ||
	    so->flags & SO_CANTSNDMORE) {
		DEBUG (("unix: unix_send: shut down"));
		p_kill (p_getpid (), SIGPIPE);
		return EPIPE;
	}
	nbytes = iov_size (iov, niov);
	if (nbytes < 0) return EINVAL;		
	else if (nbytes == 0) return 0;

/* Now we know `iov' is valid, since iov_size returns < 0 if not */	
	while (!UN_FREE (undata)) {
		if (nonblock) return 0;
		if (isleep (IO_Q, (long)so->conn)) {
			DEBUG (("unix: unix_send: interrupted"));
			return EINTR;
		}
		if (so->state != SS_ISCONNECTED ||
		    so->conn->flags & SO_CANTRCVMORE ||
		    so->flags & SO_CANTSNDMORE) {
			DEBUG (("unix: unix_send: broken conn or shut down"));
			p_kill (p_getpid (), SIGPIPE);
			return EPIPE;
		}
	}
	for (nbytes = 0; niov; --niov, ++iov) {
		todo = iov->iov_len;
		buf = iov->iov_base;
		nbytes += todo;
		while (todo > 0) {
			short tail = undata->tail, head = undata->head;
			if (tail >= head) {
				cando = undata->buflen - tail;
				if (!head) --cando;
			} else {
				cando = head - tail - 1;
			}
			if (cando > todo) cando = (short)todo;
			if (cando) {
				memcpy (&undata->buf[tail], buf, cando);
				todo -= cando;
				buf  += cando;
				tail += cando;
				if (tail >= undata->buflen) tail = 0;
				undata->tail = tail;
			} else {
#ifdef USE_UNIX_TRANSFER_STYLE
				break;
#else
				if (nonblock) break;
				so_wakersel (so->conn);
				wake (IO_Q, (long)so->conn);
				if (isleep (IO_Q, (long)so->conn)) {
					DEBUG (("unix: unix_send: interrupt"));
					break;
				}
				if (so->state != SS_ISCONNECTED ||
				    so->conn->flags & SO_CANTRCVMORE ||
				    so->flags & SO_CANTSNDMORE) {
					DEBUG (("unix: unix_send: broken conn"
						" or shut down"));
					p_kill (p_getpid (), SIGPIPE);
					return EPIPE;
				}
#endif
			}
		}
		if (todo) {
			nbytes -= todo;
			break;
		}
	}
	if (nbytes) {
		so_wakersel (so->conn);
		wake (IO_Q, (long)so->conn);
	}
	return nbytes;
}

long
unix_stream_recv (so, iov, niov, nonblock, flags, addr, addrlen)
	struct socket *so;
	struct iovec *iov;
	short niov;
	short nonblock, flags;
	struct sockaddr *addr;
	short *addrlen;
{
	struct un_data *undata = so->data;
	char *buf;
	short cando;
	long todo, nbytes;
	
	switch (so->state) {
	case SS_ISCONNECTED:
	case SS_ISDISCONNECTING:
		break;
		
	case SS_ISDISCONNECTED:
		return 0; /* EOF */

	default:
		DEBUG (("unix: unix_recv: not connected"));
		return ENOTCONN;
	}
	if (so->flags & SO_CANTRCVMORE) return 0; /* EOF */

	nbytes = iov_size (iov, niov);
	if (nbytes < 0) return EINVAL;
	else if (nbytes == 0) return 0;

	while (!UN_USED (undata)) {
		if (nonblock || so->state != SS_ISCONNECTED)
			return 0; /* EOF */
		if (isleep (IO_Q, (long)so)) {
			DEBUG (("unix: unix_recv: interrupted"));
			return EINTR;
		}
		if (so->state == SS_ISDISCONNECTED ||
		    so->flags & SO_CANTRCVMORE)
			return 0; /* EOF */
	}
	for (nbytes = 0; niov; ++iov, --niov) {
		todo = iov->iov_len;
		buf = iov->iov_base;
		nbytes += todo;
		while (todo > 0) {
			short tail = undata->tail, head = undata->head;
			if (tail >= head) {
				cando = tail - head;
			} else {
				cando = undata->buflen - head;
			}
			if (cando > todo) cando = (short)todo;
			if (cando) {
				memcpy (buf, &undata->buf[head], cando);
				todo -= cando;
				buf  += cando;
				head += cando;
				if (head >= undata->buflen) head = 0;
				undata->head = head;
			} else {
#ifdef USE_UNIX_TRANSFER_STYLE
				break;
#else
				if (nonblock || so->state == SS_ISDISCONNECTING)
					break;
				so_wakewsel (so);
				wake (IO_Q, (long)so);
				if (isleep (IO_Q, (long)so)) {
					DEBUG (("unix: unix_recv: interrupt"));
					break;
				}
				if (so->state == SS_ISDISCONNECTED ||
				    so->flags & SO_CANTRCVMORE)
					break;
#endif
			}
		}
		if (todo) {
			nbytes -= todo;
			break;
		}
	}
	if (addr && addrlen) {
		long r = unix_stream_getname (so, addr, addrlen, PEER_ADDR);
		if (r < 0) *addrlen = 0;
	}
	if (nbytes) {
		so_wakewsel (so);
		wake (IO_Q, (long)so);
	}
	return nbytes;
}

long
unix_stream_select (so, how, proc)
	struct socket *so;
	short how;
	long proc;
{
	struct un_data *undata;
	
	switch (how) {
	case O_RDONLY:
		undata = so->data;
		if (so->flags & SO_CANTRCVMORE) {
			/* read EOF */
			return 1;
		}
		if (so->flags & SO_ACCEPTCON) {
			/* Wait for clients */
			return (so->iconn_q ? 1 : so_rselect (so, proc));
		}
		if (UN_USED (undata)) {
			return 1;
		}
		if (so->state != SS_ISCONNECTED) {
			/* Read EOF */
			return 1;
		}
		/* Wait for data */
		return so_rselect (so, proc);
		
	case O_WRONLY:
		switch (so->state) {
		case SS_ISCONNECTING:
			/* Wait for connect() to finish. */
			return so_wselect (so, proc);

		case SS_ISCONNECTED:
			if (so->conn->flags & SO_CANTRCVMORE ||
			    so->flags & SO_CANTSNDMORE) {
				/* writes will fail */
				return 1;
			}
			undata = so->conn->data;
			if (UN_FREE (undata)) {
				return 1;
			} else {
				return so_wselect (so, proc);
			}
			
		default:
			/* Not connected, writes fail. */
			return 1;
		}

	default:
		return 1;
	}
}

long
unix_stream_ioctl (so, cmd, buf)
	struct socket *so;
	short cmd;
	void *buf;
{
	struct un_data *undata;

	switch (cmd) {
	case FIONREAD:
/* We need not check for SO_CANTRCVMORE, because setting this flag
   flushes all data and you will get zero anyway. */
		undata = so->data;
		if (so->flags & SO_ACCEPTCON) {
			*(long *)buf = so->iconn_q ? 1 : 0;
			return EINVAL;
		}
		if (UN_USED (undata) || so->state == SS_ISCONNECTED) {
			*(long *)buf = UN_USED (undata);
		} else {
			*(long *)buf = -1;
		}
		return 0;
		
	case FIONWRITE:
		if (so->flags & SO_ACCEPTCON) {
			*(long *)buf = 0;
			return EINVAL;
		}
		if (so->state != SS_ISCONNECTED ||
		    so->conn->flags & SO_CANTRCVMORE ||
		    so->flags & SO_CANTSNDMORE) {
			*(long *)buf = -1;
		} else {
			undata = so->conn->data;
			*(long *)buf = UN_USED (undata);
		}
		return 0;
		
	default:
		return EINVFN;
	}
}

long
unix_stream_getname (so, addr, addrlen, peer)
	struct socket *so;
	struct sockaddr *addr;
	short *addrlen, peer;
{
	struct un_data *undata;
	short todo;
	
	if (peer == PEER_ADDR) {
		if (so->state != SS_ISCONNECTED) {
			DEBUG (("unix_getname: not connected"));
			return ENOTCONN;
		}
		undata = so->conn->data;
	} else {
		undata = so->data;
	}
	if (addr && addrlen) {
		if (*addrlen < 0) {
			DEBUG (("unix_getname: invalid addresslen"));
			return EINVAL;
		}
		if (undata->flags & UN_ISBOUND) {
			todo = MIN (undata->addrlen, *addrlen - 1);
			memcpy (addr, &undata->addr, todo);
			((struct sockaddr_un *)addr)->
				sun_path[todo - UN_PATH_OFFSET] = '\0';
			*addrlen = todo;
		} else	*addrlen = 0;
	}
	return 0;
}
