/*
 *	Implementation of the socket device driver and the generic part
 *	of the socket layer. Most of the work is done in the domain
 *	specific parts of the socket layer.
 *
 *	09/30/93, kay roemer.
 */

#include "config.h" 
#include "file.h"
#include "kerbind.h"
#include "mintsock.h"
#include "atarierr.h"
#include "sockerr.h"
#include "socket.h"
#include "sockios.h"
#include "net.h"
#include "iov.h"

/* special (internal use only) ioctl() to get a handle's fileptr */
#define FD2FP		(('S' << 8) | 101)

/* hash a short to byte */
#define HASH(pid)	(((pid) ^ ((pid) >> 8)) & 0xff)

static long	sock_open	(FILEPTR *);
static long	sock_write	(FILEPTR *, char *, long);
static long	sock_read	(FILEPTR *, char *, long);
static long	sock_lseek	(FILEPTR *, long, short);
static long	sock_ioctl	(FILEPTR *, short, void *);
static long	sock_datime	(FILEPTR *, short *, short);
static long	sock_close	(FILEPTR *, short);
static long	sock_select	(FILEPTR *, long, short);
static void	sock_unselect	(FILEPTR *, long, short);

static long	socketcall	(FILEPTR *, struct generic_cmd *);

static long	sock_socket	(FILEPTR *, short, enum so_type, short);
static long	sock_socketpair	(FILEPTR *, short, enum so_type, short);
static long	sock_bind	(FILEPTR *, struct sockaddr *, short);
static long	sock_listen	(FILEPTR *, short);
static long	sock_accept	(FILEPTR *, struct sockaddr *, short *);
static long	sock_connect	(FILEPTR *, struct sockaddr *, short);
static long	sock_getsockname(FILEPTR *, struct sockaddr *, short *);
static long	sock_getpeername(FILEPTR *, struct sockaddr *, short *);
static long	sock_send	(FILEPTR *, char *, long, short);
static long	sock_sendto	(FILEPTR *, char *, long, short,
				struct sockaddr *, short);
static long	sock_recv	(FILEPTR *, char *, long, short);
static long	sock_recvfrom	(FILEPTR *, char *, long, short,
				struct sockaddr *, short *);
static long	sock_setsockopt	(FILEPTR *, short, short, void *, long);
static long	sock_getsockopt	(FILEPTR *, short, short, void *, long *);
static long	sock_shutdown	(FILEPTR *, short);
static long	sock_sendmsg	(FILEPTR *, struct msghdr *, short);
static long	sock_recvmsg	(FILEPTR *, struct msghdr *, short);

static long	so_getnewsock	(FILEPTR **);

struct devdrv sockdev = {
	sock_open, sock_write, sock_read, sock_lseek,
	sock_ioctl, sock_datime, sock_close,
	sock_select, sock_unselect,
	{ 0l, 0l, 0l }
};

struct dev_descr sockdev_descr = {
	&sockdev, 0, 0, (struct tty *)0,
	{ 0l, 0l, 0l, 0l }
};

/* stack of registered domains */
struct dom_ops	*alldomains = 0l;

/* used to check for interrupted system calls, see isleep() and sock_close() */
unsigned long intr[256];

/* This comes first, because of the `inline' */
static inline long
socketcall (fp, call)
	FILEPTR *fp;
	struct generic_cmd *call;
{
	switch (call->cmd) {
	case SOCKET_CMD: {
		struct socket_cmd *c = (struct socket_cmd *)call;
		return sock_socket (fp, c->domain, c->type, c->protocol);
	}
	case SOCKETPAIR_CMD: {
		struct socketpair_cmd *c = (struct socketpair_cmd *)call;
		return sock_socketpair (fp, c->domain, c->type, c->protocol);
	}
	case BIND_CMD: {
		struct bind_cmd *c = (struct bind_cmd *)call;
		return sock_bind (fp, c->addr, c->addrlen);
	}
	case LISTEN_CMD: {
		struct listen_cmd *c = (struct listen_cmd *)call;
		return sock_listen (fp, c->backlog);
	}
	case ACCEPT_CMD: {
		struct accept_cmd *c = (struct accept_cmd *)call;
		return sock_accept (fp, c->addr, c->addrlen);
	}
	case CONNECT_CMD: {
		struct connect_cmd *c = (struct connect_cmd *)call;
		return sock_connect (fp, c->addr, c->addrlen);
	} 
	case GETSOCKNAME_CMD: {
		struct getsockname_cmd *c = (struct getsockname_cmd *)call;
		return sock_getsockname (fp, c->addr, c->addrlen);
	}
	case GETPEERNAME_CMD: {
		struct getpeername_cmd *c = (struct getpeername_cmd *)call;
		return sock_getpeername (fp, c->addr, c->addrlen);
	}
	case SEND_CMD: {
		struct send_cmd *c = (struct send_cmd *)call;
		return sock_send (fp, c->buf, c->buflen, c->flags);
	}
	case SENDTO_CMD: {
		struct sendto_cmd *c = (struct sendto_cmd *)call;
		return sock_sendto (fp, c->buf, c->buflen, c->flags,
				   c->addr, c->addrlen);
	}
	case RECV_CMD: {
		struct recv_cmd *c = (struct recv_cmd *)call;
		return sock_recv (fp, c->buf, c->buflen, c->flags);
	} 
	case RECVFROM_CMD: {
		struct recvfrom_cmd *c = (struct recvfrom_cmd *)call;
		return sock_recvfrom (fp, c->buf, c->buflen, c->flags,
				     c->addr, c->addrlen);
	}
	case SETSOCKOPT_CMD: {
		struct setsockopt_cmd *c = (struct setsockopt_cmd *)call;
		return sock_setsockopt (fp, c->level, c->optname,
					c->optval, c->optlen);
	}
	case GETSOCKOPT_CMD: {
		struct getsockopt_cmd *c = (struct getsockopt_cmd *)call;
		return sock_getsockopt (fp, c->level, c->optname,
					c->optval, c->optlen);
	}
	case SHUTDOWN_CMD: {
		struct shutdown_cmd *c = (struct shutdown_cmd *)call;
		return sock_shutdown (fp, c->how);
	}
	case SENDMSG_CMD: {
		struct sendmsg_cmd *c = (struct sendmsg_cmd *)call;
		return sock_sendmsg (fp, c->msg, c->flags);
	}
	case RECVMSG_CMD: {
		struct recvmsg_cmd *c = (struct recvmsg_cmd *)call;
		return sock_recvmsg (fp, c->msg, c->flags);
	}
	default:
		return EINVFN;
	}
}

static long
sock_open (fp)
	FILEPTR *fp;
{
	struct socket *so;
	
	so = so_create ();
	if (!so) {
		DEBUG (("sockdev: sock_open: out of memory"));
		return ENSMEM;
	}
	fp->devinfo = (long)so;		
	return 0;	 
}

static long
sock_write (fp, buf, buflen)
	FILEPTR *fp;
	char *buf;
	long buflen;
{
	struct socket *so = (struct socket *)fp->devinfo;
	struct iovec iov[1] = {{ buf, buflen }};

	if (so->state == SS_VIRGIN)
		return EINVAL;
	return (*so->ops->send) (so, iov, 1, fp->flags & O_NDELAY, 0, 0, 0);
}

static long
sock_read (fp, buf, buflen)
	FILEPTR *fp;
	char *buf;
	long buflen;
{
	struct socket *so = (struct socket *)fp->devinfo;
	struct iovec iov[1] = {{ buf, buflen }};
	
	if (so->state == SS_VIRGIN)
		return EINVAL;
	return (*so->ops->recv) (so, iov, 1, fp->flags & O_NDELAY, 0, 0, 0);
}

static long
sock_lseek (fp, where, whence)
	FILEPTR *fp;
	long where;
	short whence;
{
	return EACCDN;
}

static long
sock_ioctl (fp, cmd, buf)
	FILEPTR *fp;
	short cmd;
	void *buf;
{
	struct socket *so = (struct socket *)fp->devinfo;

	switch (cmd) {
	case SOCKETCALL:
		return socketcall (fp, (struct generic_cmd *)buf);

	case FD2FP:
		*(FILEPTR **)buf = fp;
		return 0;

	case SIOCSPGRP:
		so->pgrp = (short)*(long *)buf;
		return 0;

	case SIOCGPGRP:
		*(long *)buf = (long)so->pgrp;
		return 0;

	case F_SETLK:
	case F_SETLKW: {
		struct flock *lk = (struct flock *)buf;

		switch (lk->l_type) {
		case F_UNLCK:
			if (so->lockpid != p_getpid ()) return ELOCKED;
			if (fp->flags & O_LOCK) {
				fp->flags &= ~O_LOCK;
				wake (IO_Q, (long)&so->lockpid);
			} else {
				DEBUG (("sock_ioctl (F_UNLCK): not locked"));
				return ENSLOCK;
			}
			return 0;

		case F_RDLCK:
		case F_WRLCK:
			while (fp->flags & O_LOCK) {
				if (so->lockpid == p_getpid ()) return 0;
				if (cmd == F_SETLK) return ELOCKED;
				if (isleep (IO_Q, (long)&so->lockpid)) {
					return EINTR;
				}
			}
			fp->flags |= O_LOCK;
			so->lockpid = p_getpid ();
			return 0;

		default:
			return EINVAL;
		}
	}
	case F_GETLK: {
		struct flock *lk = (struct flock *)buf;

		if (fp->flags & O_LOCK) {
			lk->l_start = 0;
			lk->l_len = 0;
			lk->l_pid = so->lockpid;
			lk->l_type = F_WRLCK;
		} else	lk->l_type = F_UNLCK;
		return 0;
	}		
	default:
		if (so->state == SS_VIRGIN || so->state == SS_ISDISCONNECTED)
			return EINVAL;
		return (*so->ops->ioctl) (so, cmd, buf);
	}
}

static long
sock_datime (fp, timeptr, rwflag)
	FILEPTR *fp;
	short *timeptr;
	short rwflag;
{
	struct socket *so = (struct socket *)fp->devinfo;
	
	if (rwflag) {
		so->time = timeptr[0];
		so->date = timeptr[1];
	} else {
		timeptr[0] = so->time;
		timeptr[1] = so->date;
	}
	return 0;	
}

static long
sock_close (fp, pid)
	FILEPTR *fp;
	short pid;
{
	struct socket *so = (struct socket *)fp->devinfo;

/* Wake anyone waiting on the socket. */
	so_wakersel (so);
	so_wakewsel (so);
	wake (IO_Q, (long)so);
	
	if (fp->flags & O_LOCK && so->lockpid == pid) {
		fp->flags &= ~O_LOCK;
		wake (IO_Q, (long)&so->lockpid);
	}
	if (fp->links <= 0) {
		++intr[HASH(pid)];
		so_release (so);
		kfree (so);
	}
	return 0;
}

static long
sock_select (fp, proc, mode)
	FILEPTR *fp;
	long proc;
	short mode;
{
	struct socket *so = (struct socket *)fp->devinfo;

	if (so->state == SS_VIRGIN || so->state == SS_ISDISCONNECTED)
		return 1;
	return (*so->ops->select) (so, mode, proc);
}

static void
sock_unselect (fp, proc, mode)
	FILEPTR *fp;
	long proc;
	short mode;
{
	struct socket *so = (struct socket *)fp->devinfo;
	
	switch (mode) {
	case O_RDONLY:
		if (so->rsel == proc) so->rsel = 0;
		break;

	case O_WRONLY:
		if (so->wsel == proc) so->wsel = 0;
		break;
	}
}

static long
sock_socket (fp, domain, type, protocol)
	FILEPTR *fp;
	short domain;
	enum so_type type;
	short protocol;
{
	struct socket *so = (struct socket *)fp->devinfo;
	struct dom_ops *ops;
	long r;
	
	if (so->state != SS_VIRGIN)
		return EINVAL;

	for (ops = alldomains; ops; ops = ops->next)
		if (ops->domain == domain) break;
	if (!ops) {
		DEBUG (("sockdev: sock_socket: domain %d not supported",
			domain));
		return EAFNOSUPPORT;
	}

	switch (type) {
	case SOCK_DGRAM:
	case SOCK_STREAM:
	case SOCK_RAW:
	case SOCK_RDM:
	case SOCK_SEQPACKET:
		so->ops = ops;
		so->type = type;

		r = (*so->ops->attach) (so, protocol);
		if (r < 0) {
			DEBUG (("sockdev: sock_socket: failed to attach "
				"protocol data"));
			return r;
		}			
		so->state = SS_ISUNCONNECTED;
		return 0;

	default:
		DEBUG (("sockdev: sock_socket: no such socket type %d", type));
		return ESOCKTNOSUPPORT;
	}
}

static long
sock_socketpair (fp1, domain, type, protocol)
	FILEPTR *fp1;
	short domain;
	enum so_type type;
	short protocol;
{
	struct socket *so2, *so1 = (struct socket *)fp1->devinfo;
	FILEPTR *fp2;
	long fd2, r;

	r = sock_socket (fp1, domain, type, protocol);
	if (r < 0) {
		DEBUG (("sockdev: sock_socketpair: cannot create 1st socket"));
		return r;
	}
	fd2 = so_getnewsock (&fp2);
	if (fd2 < 0) {
		DEBUG (("sockdev: sock_socketpair: cannot alloc 2nd socket"));
		so_release (so1);
		return fd2;
	}
	r = sock_socket (fp2, domain, type, protocol);
	if (r < 0) {
		DEBUG (("sockdev: sock_socketpair: cannot create 2nd socket"));
		so_release (so1);
		f_close (fd2);
		return r;
	}	
	so2 = (struct socket *)fp2->devinfo;
	
	r = (*so1->ops->socketpair) (so1, so2);
	if (r < 0) {
		DEBUG (("sockdev: sock_socketpair: cannot connect the sockets"));
		so_release (so1);
		f_close (fd2);
		return r;
	}
	return fd2;	
}

static long
sock_bind (fp, addr, addrlen)
	FILEPTR *fp;
	struct sockaddr *addr;
	short addrlen;
{
	struct socket *so = (struct socket *)fp->devinfo;
	
	if (so->state == SS_VIRGIN || so->state == SS_ISDISCONNECTED)
		return EINVAL;
	return (*so->ops->bind) (so, addr, addrlen);
}

static long
sock_listen (fp, backlog)
	FILEPTR *fp;
	short backlog;
{
	struct socket *so = (struct socket *)fp->devinfo;
	long r;
	
	if (so->state != SS_ISUNCONNECTED)
		return EINVAL;

	if (backlog < 0) backlog = 0;
	r = (*so->ops->listen) (so, backlog);
	if (r < 0) {
		DEBUG (("sockdev: sock_listen: failing ..."));
		return r;
	}
	so->flags |= SO_ACCEPTCON;
	return 0;
}

static long
sock_accept (fp, addr, addrlen)
	FILEPTR *fp;
	struct sockaddr *addr;
	short *addrlen;
{
	struct socket *newso, *so = (struct socket *)fp->devinfo;
	FILEPTR *newfp;
	long newfd, r;
	
	if (so->state != SS_ISUNCONNECTED)
		return EINVAL;
		
	if (!(so->flags & SO_ACCEPTCON)) {
		DEBUG (("sockdev: sock_accept: socket not listening"));
		return EINVAL;
	}
		
	newfd = so_getnewsock (&newfp);
	if (newfd < 0) {
		DEBUG (("sockdev: sock_accept: cannot alloc fresh socket"));
		return newfd;
	}
	newso = (struct socket *)newfp->devinfo;
	newso->type = so->type;
	newso->ops = so->ops;

	r = (*so->ops->dup) (newso, so);
	if (r < 0) {
		DEBUG (("sockdev: sock_accept: failed to dup protocol data"));
		f_close (newfd);
		return r;
	}
	newso->state = SS_ISUNCONNECTED;

	r = (*so->ops->accept) (so, newso, fp->flags & O_NDELAY);
	if (r < 0) {
		DEBUG (("sockdev: sock_accept: cannot accept a connection"));
		f_close (newfd);
		return r;
	}
	if (addr) {
		r = (*newso->ops->getname) (newso, addr, addrlen, PEER_ADDR);
		if (r < 0) {
			DEBUG (("sockdev: sock_accept: getname failed"));
			*addrlen = 0;
		}
	}
	return newfd;
}

static long
sock_connect (fp, addr, addrlen)
	FILEPTR *fp;
	struct sockaddr *addr;
	short addrlen;
{
	struct socket *so = (struct socket *)fp->devinfo;
	
	switch (so->state) {
	case SS_ISUNCONNECTED:
	case SS_ISCONNECTING:
		if (so->flags & SO_ACCEPTCON) {
			DEBUG (("sockdev: sock_connect: attempt to connect "
				"a listening socket"));
			return EINVAL;
		}
		return (*so->ops->connect) (so, addr, addrlen,
					   fp->flags & O_NDELAY);

	case SS_ISCONNECTED:
/* Connectionless sockets can be connected serveral times. So their state
   must always be SS_ISUNCONNECTED. */
		DEBUG (("sockdev: sock_connect: already connected"));
		return EISCONN;
   		
	case SS_ISDISCONNECTING:
	case SS_ISDISCONNECTED:
	case SS_VIRGIN:
		DEBUG (("sockdev: sock_connect: socket cannot connect"));
		return EINVAL;

	default:
		DEBUG (("socketdev: so_connect: invalid socket state %d",
			so->state));
		return EINTRN;
	}
}

static long
sock_getsockname (fp, addr, addrlen)
	FILEPTR *fp;
	struct sockaddr *addr;
	short *addrlen;
{
	struct socket *so = (struct socket *)fp->devinfo;

	if (so->state == SS_VIRGIN || so->state == SS_ISDISCONNECTED)
		return EINVAL;
	return (*so->ops->getname) (so, addr, addrlen, SOCK_ADDR);
}

static long
sock_getpeername (fp, addr, addrlen)
	FILEPTR *fp;
	struct sockaddr *addr;
	short *addrlen;
{
	struct socket *so = (struct socket *)fp->devinfo;

	if (so->state == SS_VIRGIN || so->state == SS_ISDISCONNECTED)
		return EINVAL;
	return (*so->ops->getname) (so, addr, addrlen, PEER_ADDR);
}

static long
sock_send (fp, buf, buflen, flags)
	FILEPTR *fp;
	char *buf;
	long buflen;
	short flags;
{
	struct socket *so = (struct socket *)fp->devinfo;
	struct iovec iov[1] = {{ buf, buflen }};
	
	if (so->state == SS_VIRGIN)
		return EINVAL;
	return (*so->ops->send) (so, iov, 1, fp->flags & O_NDELAY, flags, 0, 0);
}

static long
sock_sendto (fp, buf, buflen, flags, addr, addrlen)
	FILEPTR *fp;
	char *buf;
	long buflen;
	short flags;
	struct sockaddr *addr;
	short addrlen;
{
	struct socket *so = (struct socket *)fp->devinfo;
	struct iovec iov[1] = {{ buf, buflen }};
	
	if (so->state == SS_VIRGIN)
		return EINVAL;
	return (*so->ops->send) (so, iov, 1, fp->flags & O_NDELAY, flags,
				addr, addrlen);
}

static long
sock_recv (fp, buf, buflen, flags)
	FILEPTR *fp;
	char *buf;
	long buflen;
	short flags;
{
	struct socket *so = (struct socket *)fp->devinfo;
	struct iovec iov[1] = {{ buf, buflen }};
	
	if (so->state == SS_VIRGIN)
		return EINVAL;
	return (*so->ops->recv) (so, iov, 1, fp->flags & O_NDELAY, flags, 0, 0);
}

static long
sock_recvfrom (fp, buf, buflen, flags, addr, addrlen)
	FILEPTR *fp;
	char *buf;
	long buflen;
	short flags;
	struct sockaddr *addr;
	short *addrlen;
{
 	struct socket *so = (struct socket *)fp->devinfo;
	struct iovec iov[1] = {{ buf, buflen }};
	
	if (so->state == SS_VIRGIN)
		return EINVAL;
	return (*so->ops->recv) (so, iov, 1, fp->flags & O_NDELAY, flags,
				addr, addrlen);
}

static long
sock_setsockopt (fp, level, optname, optval, optlen)
	FILEPTR *fp;
	short level, optname;
	void *optval;
	long optlen;
{
	struct socket *so = (struct socket *)fp->devinfo;

	if (so->state == SS_VIRGIN || so->state == SS_ISDISCONNECTED)
		return EINVAL;
	return (*so->ops->setsockopt) (so, level, optname, optval, optlen);
}

static long
sock_getsockopt (fp, level, optname, optval, optlen)
	FILEPTR *fp;
	short level, optname;
	void *optval;
	long *optlen;
{
	struct socket *so = (struct socket *)fp->devinfo;

	if (so->state == SS_VIRGIN || so->state == SS_ISDISCONNECTED) {
		DEBUG (("sockdev: sock_getsockopt: virgin state"));
		return EINVAL;
	}
	return (*so->ops->getsockopt) (so, level, optname, optval, optlen);
}

static long
sock_shutdown (fp, how)
	FILEPTR *fp;
	short how;
{
	struct socket *so = (struct socket *)fp->devinfo;
 
	if (so->state == SS_VIRGIN || so->state == SS_ISDISCONNECTED)
		return EINVAL;

	switch (how) {
	case 0:
		so->flags |= SO_CANTRCVMORE;
		break;
	case 1:
		so->flags |= SO_CANTSNDMORE;
		break;
	case 2:
		so->flags |= (SO_CANTRCVMORE|SO_CANTSNDMORE);
		break;
	}
	return (*so->ops->shutdown) (so, how);
}

static long
sock_sendmsg (fp, msg, flags)
	FILEPTR *fp;
	struct msghdr *msg;
	short flags;
{
	struct socket *so = (struct socket *)fp->devinfo;

	if (so->state == SS_VIRGIN)
		return EINVAL;

	if (msg->msg_accrights && msg->msg_accrightslen)
		return EINVAL;

	return (*so->ops->send) (so, msg->msg_iov, msg->msg_iovlen,
				fp->flags & O_NDELAY, flags,
				msg->msg_name, msg->msg_namelen);
}

static long
sock_recvmsg (fp, msg, flags)
	FILEPTR *fp;
	struct msghdr *msg;
	short flags;
{
	struct socket *so = (struct socket *)fp->devinfo;
	short namelen = msg->msg_namelen;
	long r;
	
	if (so->state == SS_VIRGIN)
		return EINVAL;

	if (msg->msg_accrights && msg->msg_accrightslen)
		msg->msg_accrightslen = 0;

	r = (*so->ops->recv) (so, msg->msg_iov, msg->msg_iovlen,
				fp->flags & O_NDELAY, flags,
				msg->msg_name, &namelen);
	msg->msg_namelen = namelen;
	return r;
}

/* socket utility functions */

/* Get a new filehandle with an associated fileptr and virgin socket.
 * Return the filehandle or an negative error code.
 * Return the fileptr in *fp.
 */
static long
so_getnewsock (fp)
	FILEPTR **fp;
{
	extern char sockdev_name[];
	long fd, r;

	fd = f_open (sockdev_name, O_RDWR);
	if (fd < 0) {
		DEBUG (("sockdev: so_getnewsock: cannot open %s", sockdev_name));
		return fd;
	}
	r = f_cntl (fd, (long)fp, FD2FP);
	if (r < 0) {
		DEBUG (("sockdev: so_getnewsock: f_cntl failed"));
		f_close (fd);
		return r;
	}
	return fd;
}

/* "Sleep and watch for interrupts"
 * Basically this does the same thing as the kernels sleep(), but
 * keeps track of calls to sock_close() that really dispose a socket
 * (links <= 0) while sleeping.
 * Returns true if there were 'disposing' calls to sock_close() during
 * the sleep concerning sockets owned by the process calling isleep().
 * If isleep() returns true, the function that did the isleep()
 * should not touch any objects that could have been freed by calls
 * to sock_close() (from a signal handler for instance) during the sleep.
 */
short
isleep (queue, cond)
	short queue;
	long cond;
{
	short pid = p_getpid ();
	unsigned long ointr = intr[HASH(pid)];

	sleep (queue, cond);
	return (ointr != intr[HASH(pid)]);
}
