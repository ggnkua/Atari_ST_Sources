/*
 * lpdev.c: installs the "/dev/lp" device. It is a
 * buffered Centronics device. This program is free software; see the
 * file "COPYING" for details.
 *
 * This file must be compiled with 16-bit integers.
 *
 * Author:  Thierry Bousch (bousch@suntopo.matups.fr)
 * Version: 0.7 (June 1994)
 *
 * Revision history:
 *  0.1: First attempt, using SLEEP instead of NAP: it didn't work.
 *  0.2: Added version number, napping in lp_write(), and the TIOCFLUSH
 *        ioctl function. Cleaned up things a bit.
 *  0.3: Introduced spl7() and spl() to fix competition problems. Added
 *        a few tests before installation, to check that MiNT is running
 *        and the device is not already installed.
 *  0.4: Added file locking. This is completely untested, so be
 *        careful. More cleanup and sanity checks during installation.
 *        Modified the sleep conditions in lp_write and lp_select.
 *  0.5: Deleted the now unnecessary stuff about low and high water marks.
 *        More comments added.
 *  0.6: Added support for the O_NDELAY and O_LOCK flags, inlined spl7/spl.
 *        Moved the definitions to lpdev.h.
 *  0.7: ++Ulrich Kuehn
 *        added support for mint's xdd feature, call print_head() after
 *        napping in case an interrupt gets lost. Added the possibility
 *        to configure port sharing at compile time.
 */

#include "lpdev.h"
#define  LP_VERSION	"0.7"

/*
 * Global variables
 */
 
char *buffer_start, *buffer_end, *buffer_tail;
volatile char *buffer_head;
volatile long buffer_contents;
long selector = 0L;
struct kerinfo *kernel;
struct flock our_lock = { F_WRLCK, 0, 0L, 0L, -1 };

/*
 * Forward declarations of the device driver functions
 */

long	lp_open		(FILEPTR *f);
long	lp_write	(FILEPTR *f, char *buf, long bytes);
long	lp_read		(FILEPTR *f, char *buf, long bytes);
long	lp_lseek	(FILEPTR *f, long where, int whence);
long	lp_ioctl	(FILEPTR *f, int mode, void *buf);
long	lp_datime	(FILEPTR *f, int *timeptr, int rwflag);
long	lp_close	(FILEPTR *f, int pid);
long	lp_select	(FILEPTR *f, long proc, int mode);
void	lp_unselect	(FILEPTR *f, long proc, int mode);

DEVDRV lp_device = {
	lp_open, lp_write, lp_read, lp_lseek, lp_ioctl,
	lp_datime, lp_close, lp_select, lp_unselect
};

struct dev_descr devinfo = { &lp_device };

/* Initializes the circular buffer */
 
void reset_buffer (void)
{
	int sr = spl7();
	buffer_head = buffer_tail = buffer_start;
	buffer_end = buffer_start + BUFSIZE;
	buffer_contents = 0L;
	spl(sr);
}

/* Copyright information */

void Version (void)
{
	Cconws("Spooled Centronics device driver, by T.Bousch (version "
	LP_VERSION ").\r\n"
	"This program is FREE SOFTWARE, and comes with NO WARRANTY.\r\n"
	"See the file \"COPYING\" for more information.\r\n\r\n");
}

/* uk: moved this stuf here, so that it can be called on every
 *     open() call. This is used if CENTR_SHARING is defined
 */
long init_centr()
{
	Mfpint(0, new_centr_vector);
	Jenabint(0);
	return 0;
}


/* 
 * Installs everything, returns 0 on success. Must be executed in
 * supervisor mode.
 */
long install_things (void)
{
#ifndef XDD
	if (Syield() == EINVFN) {
		Cconws("lpdev: MiNT is not running\r\n");
		return EACCDN;
	}
	if (Fsfirst(DEVNAME, 0) == 0) {
		Cconws("lpdev: device \"" DEVNAME "\" already installed\r\n");
		return EACCDN;
	}
#endif

#ifndef CENTR_SHARING
	/* uk: Comment this out, as we better init the mfp stuff when it is
	 *     needed. That way we can have say a PLIP driver and this device
	 *     on the same computer; change is then possible just by changing
	 *     the cable...
	 *     But is this behavior a good idea???
	 */
	if (*(char*)0xFFFFFA09 &	/* IERB */
	    *(char*)0xFFFFFA15 & 1) {	/* IMRB */
		Cconws("lpdev: Centronics interrupt already in use\r\n\r\n");
		return EACCDN;
	}
#endif

	buffer_start = (char *)Malloc(BUFSIZE);
	if (!buffer_start) {
		Cconws("lpdev: not enough memory\r\n\r\n");
		return ENSMEM;
	}
	reset_buffer();

	kernel = (struct kerinfo *)Dcntl(DEV_INSTALL, DEVNAME, &devinfo);
	if ((long)kernel <= 0L) {
		Cconws("lpdev: unable to install device\r\n\r\n");
		return EACCDN;
	}
	/* Finally! */
	init_centr();
	return 0;
}

#ifndef XDD
/*
 * The main routine is very simple now, it just calls install_things
 * and remains resident if everything went well
 */

int main()
{
	long ret;
	
	ret = Supexec(install_things);
	if (ret < 0)
		return ret;

	/* Installation is complete */
	Version();
	Ptermres(256L + _base->p_tlen + _base->p_dlen + _base->p_blen, 0);
	return -999;	/* never reached, just to make Gcc happy */
}

#else
/* uk: if this is linked and started as an externel device driver,
 *     the memory allocation stuff is already done and we are in
 *     super mode already.
 */
DEVDRV * xdd_main(struct kerinfo *k)
{
	long res;

	kernel = k;
	Version();
	res = install_things();
	if (res == 0)
		return (DEVDRV*)1;
	else
		return NULL;
}
#endif

/*
 * Will wake any process select'ing the printer;
 * this routine is called by the interrupt handler, but also when the
 * buffer is flushed.
 */

void wake_up (void)
{
	if (selector)
		WAKESELECT(selector);	/* wake selector */
}

/*
 * Sends as many bytes as possible (usually one) to the printer until
 * he gets busy. This routine is called by lp_write and by the
 * interrupt handler, so it _must_ be multi-thread. It will not work if
 * you remove the spl7()/spl() pair.
 *
 * On a more general note, it is safest to disable all interrupts before
 * modifying the volatile variables (buffer_contents and buffer_head).
 */

#define PRINTER_BUSY	(*(char*)0xFFFFFA01 & 1)

void print_head (void)
{
	int sr = spl7();
	while (!PRINTER_BUSY && buffer_contents) {
		print_byte( *buffer_head );
		--buffer_contents;
		if (++buffer_head >= buffer_end)
			buffer_head -= BUFSIZE;
	}
	spl(sr);
}

/*
 * Copies a linear buffer into the circular one. We assume that's there
 * enough room for this operation, ie
 * nbytes + buffer_contents <= BUFSIZE
 *
 * Note: the while() loop will be executed at most twice.
 * Note2: the instruction "buffer_contents += N" looks atomic, but it
 *   isn't (the Gcc outputs several assembly instructions). Therefore it
 *   must be wrapped in spl7()/spl().
 */

void print_tail (char *buf, long nbytes)
{
	long N;
	int sr;
	
	while (nbytes) {
		N = buffer_end - buffer_tail;
		if (N > nbytes)
			N = nbytes;
		bcopy (buf, buffer_tail, N);
		buf += N; nbytes -= N;
		sr = spl7();
		buffer_contents += N;
		spl(sr);
		buffer_tail += N;
		if (buffer_tail >= buffer_end)
			buffer_tail -= BUFSIZE;
	}
	print_head();	/* To initiate printing */
}

/*
 * Here are the actual device driver functions
 */
 
#define  LP_LOCKED	(our_lock.l_pid >= 0)

long lp_open (FILEPTR *f)
{
	TRACE(("lp: open device"));
#ifdef CENTR_SHARING
	/* uk: if port sharing is used, install the vector again, as it might
	 *     have been changed.
	 */
	init_centr();
#endif
	return 0;
}

long lp_close (FILEPTR *f, int pid)
{
	TRACE(("lp: close device"));
	if ((f->flags & O_LOCK) && our_lock.l_pid == pid) {
		TRACE(("lp: releasing lock on close"));
		f->flags &= ~O_LOCK;
		our_lock.l_pid = -1;
		WAKE(IO_Q, (long)&our_lock);
	}
	return 0;
}

long lp_read (FILEPTR *f, char *buf, long bytes)
{
	TRACE(("lp: foolish attempt to read"));
	return 0;
}

long lp_datime (FILEPTR *f, int *timeptr, int rwflag)
{
	if (rwflag) {
		DEBUG(("lp: can't modify date/time"));
		return EACCDN;
	}
	TRACE(("lp: read time and date"));
	*timeptr++ = TGETTIME();
	*timeptr   = TGETDATE();
	return 0;
}

long lp_lseek (FILEPTR *f, long where, int whence)
{
	TRACE(("lp: foolish attempt to seek"));
	if (whence < 0 || whence > 2)
		return EINVFN;
	return where ? ERANGE : 0L;
}

long lp_ioctl (FILEPTR *f, int mode, void *buf)
{
	struct flock *g;

	if (mode == FIONREAD) {
		TRACE(("lp: ioctl(FIONREAD)"));
		*(long *)buf = 0L;
	}
	else if (mode == FIONWRITE) {
		TRACE(("lp: ioctl(FIONWRITE)"));
		*(long *)buf = BUFSIZE - buffer_contents;
	}
	else if (mode == TIOCFLUSH) {
		TRACE(("lp: clear buffer"));
		reset_buffer();
		wake_up();	/* Wake up any select'ing process */
	}
	else if (mode == F_GETLK) {
		g = (struct flock *) buf;

		if (LP_LOCKED) {
			TRACE(("lp: get_lock succeeded"));
			*g = our_lock;
		} else {
			TRACE(("lp: get_lock failed"));
			g->l_type = F_UNLCK;
		}
	}
	else if (mode == F_SETLK || mode == F_SETLKW) {
		g = (struct flock *) buf;

		switch (g->l_type) {
		case F_UNLCK:
		    if (!(f->flags & O_LOCK) || g->l_pid != our_lock.l_pid) {
			DEBUG(("lp: no such lock"));
			return ENSLOCK;
		    } else {
			TRACE(("lp: remove lock"));
			f->flags &= ~O_LOCK;
			our_lock.l_pid = -1;
			WAKE(IO_Q, (long)&our_lock);
		    }
		    return 0;
		case F_RDLCK:
		    TRACE(("lp: read locks are ignored"));
		    return 0;
		case F_WRLCK:
		    while (LP_LOCKED) {
			DEBUG(("lp: conflicting locks"));
			if (mode == F_SETLK) {
				*g = our_lock;
				return ELOCKED;
			}
			SLEEP(IO_Q, (long)&our_lock);
		    }
		    TRACE(("lp: set lock"));
		    f->flags |= O_LOCK;
		    our_lock.l_pid = g->l_pid;
		    return 0;
		default:
		    DEBUG(("lp: invalid lock type"));
		    return EINVFN;
		}
	}
	else {
		DEBUG(("lp: invalid ioctl mode"));
		return EINVFN;
	}
	return 0;
}

long lp_write (FILEPTR *f, char *buf, long bytes)
{
	long _bytes = bytes;
	long N;
	int  ndel = (f->flags & O_NDELAY);	/* don't wait */

	while (bytes) {
		N = BUFSIZE - buffer_contents;
		/*
		 * If the data won't fit into the buffer,
		 * and if the buffer itself is almost full, we won't
		 * be able to copy much. So we better sleep a bit (unless
		 * the O_NDELAY flag is set).
		 */
		if (N < bytes && N < BUFSIZE/4 && !ndel) {
			TRACE(("lp: napping in lp_write"));
			NAP(200);	/* let's wait 200 milliseconds */

			/* uk: to prevent lost interrupts stopping the driver
			 *     start printing again. If the device is still busy, it
			 *     does not harm.
			 */
			print_head();
			continue;	/* and try again */
		}
		if (bytes < N)
			N = bytes;
		/* Now N contains the number of bytes we want to copy
		 * into the circular buffer */
		print_tail(buf, N);
		buf += N;
		bytes -= N;
		/*
		 * If the O_NDELAY flag is set, we don't make a second
		 * attempt to write the remaining "bytes" bytes.
		 */
		if (ndel)  break;
	}
	TRACE(("lp: wrote %ld bytes, skipped %ld", _bytes-bytes, bytes));
	return _bytes - bytes;
}

/* Bug: only one process can select the printer */

long lp_select (FILEPTR *f, long proc, int mode)
{
	if (buffer_contents == BUFSIZE && !selector) {
		TRACE(("lp: select returned 0"));
		selector = proc;
		return 0;
	}
	TRACE(("lp: select returned 1"));
	return 1;
}

void lp_unselect (FILEPTR *f, long proc, int mode)
{
	TRACE(("lp: unselect"));
	selector = 0L;
}
