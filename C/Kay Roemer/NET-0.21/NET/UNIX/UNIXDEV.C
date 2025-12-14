/*
 *	This file implements /dev/unix. It is intended for controlling
 *	the behavior of the unix domain layer and getting information
 *	about it. netstat(8) is implemented using this device.
 *
 *	12/15/93, kay roemer.
 */

#include "config.h"
#include "kerbind.h"
#include "file.h"
#include "atarierr.h"
#include "socket.h"
#include "net.h"
#include "un.h"
#include "util.h"

/* read() obtains this structure for every unix domain socket */
struct unix_info {
	short		proto;	 /* protcol numer, always 0 */
	short		flags;	 /* socket flags, SO_* */
	short		type;	 /* socket type, SOCK_DGRAM or SOCK_STREAM */
	short		state;	 /* socket state, SS_* */
	short		qlen;	 /* bytes in read buffer */
	short		addrlen; /* addrlen, 0 if no address */
	struct sockaddr_un addr; /* addr, only meaningful if addrlen > 0 */
};

static long	unixdev_open	(FILEPTR *);
static long	unixdev_write	(FILEPTR *, char *, long);
static long	unixdev_read	(FILEPTR *, char *, long);
static long	unixdev_lseek	(FILEPTR *, long, short);
static long	unixdev_ioctl	(FILEPTR *, short, void *);
static long	unixdev_datime	(FILEPTR *, short *, short);
static long	unixdev_close	(FILEPTR *, short);
static long	unixdev_select	(FILEPTR *, long, short);
static void	unixdev_unselect(FILEPTR *, long, short);

static DEVDRV unixdev = {
	unixdev_open, unixdev_write, unixdev_read,
	unixdev_lseek, unixdev_ioctl, unixdev_datime,
	unixdev_close, unixdev_select, unixdev_unselect
};

static struct dev_descr unixdev_descr = {
	&unixdev, 0, 0, 0
};

static char unixdev_name[] = "u:\\dev\\unix";

extern struct un_data *allundatas[UN_HASH_SIZE];


long
unixdev_init (void)
{
	long r;

	r = d_cntl (DEV_INSTALL, unixdev_name, &unixdev_descr);
	if (!r || r == EINVFN) {
		c_conws ("Cannot install unix device\r\n");
		return -1;
	}
	return 0;
}	

static long
unixdev_open (fp)
	FILEPTR *fp;
{
	/* Nothing to do */
	return 0;
}

static long
unixdev_write (fp, buf, nbytes)
	FILEPTR *fp;
	char *buf;
	long nbytes;
{
	return EACCDN;
}

static long
unixdev_read (fp, buf, nbytes)
	FILEPTR *fp;
	char *buf;
	long nbytes;
{
	struct un_data *unp = 0;	/* to keep gcc happy */
	struct unix_info info;
	int i, j;
	long copied, todo;
	extern void *memcpy (void *, const void *, unsigned long);

	if (nbytes <= 0) return 0;
	for (copied = 0; copied < nbytes; ++fp->pos) {
		for (i = fp->pos, j = 0; j < UN_HASH_SIZE && i >= 0; ++j) {
			unp = allundatas[j];
			for (; unp && --i >= 0; unp = unp->next);
		}
		if (j >= UN_HASH_SIZE) break;
		info.proto	= unp->proto;
		info.flags	= unp->sock->flags;
		info.type	= unp->sock->type;
		info.state	= unp->sock->state;
		info.addrlen	= unp->addrlen;
		info.addr	= unp->addr;
		if (info.type == SOCK_DGRAM) {
			struct dgram_hdr header = { 0, 0 };
			if (UN_USED (unp)) {
				un_read_header (unp, &header, 0);
			}
			info.qlen = header.nbytes;
		} else	info.qlen = UN_USED (unp);

		todo = MIN (sizeof (info), nbytes - copied);
		memcpy (&buf[copied], &info, todo);
		copied += todo;
	}
	return copied;
}

static long
unixdev_lseek (fp, where, whence)
	FILEPTR *fp;
	long where;
	short whence;
{
	int i, j;

	for (i = j = 0; j < UN_HASH_SIZE; ++j) {
		struct un_data *unp = allundatas[j];
		for (; unp; unp = unp->next, ++i);
	}	
	switch (whence) {
	case SEEK_SET:
		if (where < 0 || where > i)
			return ERANGE;
		fp->pos = where;
		return fp->pos;
		
	case SEEK_CUR:
		if (fp->pos + where < 0 || fp->pos + where > i)
			return ERANGE;
		fp->pos += where;
		return fp->pos;
		
	case SEEK_END:
		if (i + where < 0 || where > 0)
			return ERANGE;
		fp->pos = i + where;
		return fp->pos;
		
	default:
		return EINVFN;
	}
}

static long
unixdev_ioctl (fp, mode, buf)
	FILEPTR *fp;
	short mode;
	void *buf;
{
	switch (mode) {
	case FIONREAD:
		*(long *)buf = sizeof (struct unix_info);
		return 0;

	case FIONWRITE:
		*(long *)buf = 0;
		return 0;

	default:
		return EINVFN;
	}
}

static long
unixdev_datime (fp, timeptr, rwflag)
	FILEPTR *fp;
	short *timeptr;
	short rwflag;
{
	if (!rwflag) {
		timeptr[0] = t_gettime ();
		timeptr[1] = t_getdate ();
	}
	return 0;
}

static long
unixdev_close (fp, pid)
	FILEPTR *fp;
	short pid;
{
	/* Nothing to do */
	return 0;
}

static long
unixdev_select (fp, proc, mode)
	FILEPTR *fp;
	long proc;
	short mode;
{
	return 1;
}

static void
unixdev_unselect (fp, proc, mode)
	FILEPTR *fp;
	long proc;
	short mode;
{
	/* Nothing to do */
}
