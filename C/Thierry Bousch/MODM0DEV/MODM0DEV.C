/*
 * modm0dev.c: Serial device driver for the modem1 port, dial-in
 * (/dev/ttyd0) and dial-out (/dev/cua0).
 * This is free software without any warranty; see the file "COPYING" for
 * details.
 *
 * This file must be compiled with 16-bit integers.
 *
 * Author:  Thierry Bousch (bousch@suntopo.matups.fr)
 * Version: 1.0 (oct 93)
 *
 * Revision history:
 *
 * 0.1	First working version. Very few ioctl's are implemented.
 * 0.2	Setting the terminal flags (break, echo...) is no longer a
 *	privileged instruction!
 *	Speed can be changed via ioctl's.
 *	We now raise the SIGHUP signal only when writing to a disconnected
 *	/dev/ttyd0, not when reading.
 * 0.3	Handles MFP error conditions, especially breaks. Fixed a bug in
 *	the RAISE macro (signals should work now).
 *	The dial-in and dial-out devices now have different tty structures,
 *	so they can be configured independently.
 *	The ioctl stuff has been cleaned.
 * 0.4	We used to check for the carrier (and control characters) only in
 *	cua_read and cua_write, so programs which didn't read from the
 *	standard input couldn't get signals. So we install a daemon which
 *	will check this periodically.
 * 0.5	Cleaned the cua_read/cua_write/daemon code; now signals can only
 *	be raised by the daemon, using the non-kernel Pkill().
 * 0.6	Much cleanup; select() stuff removed; added utility function for
 *	ioctl(FIONREAD/FIONWRITE). Fixed the assembly file also.
 *	Many bugfixes in the daemon code. Now hardware errors are logged
 *	even when the device isn't a controlling terminal.
 *	Added ioctls to read and modify soft_carrier and hangup_control.
 *	Moved code between modm0dev.c and modm0dev.h.
 * 0.7	^S/^Q weren't handled by the daemon, bummer. Rewrote this part.
 *	We also keep track of the connection number in a static register,
 *	so that we can track stale FILEPTR's.
 *	Complete rewrite of the mutual exclusion stuff; now there can be
 *	several FILEPTR's to /dev/ttyd0 (useful for talk); we use f->pos
 *	to store the expected connection_id, or 0 for the dial-out device.
 *	Added the dont_emit flag, to inform the interrupt routines that the
 *	terminal has been stopped or restarted (useful if the transmission
 *	buffer is big).
 *	Added support for the O_NDELAY flag, and a sanity check.
 *	The bytes_available() function now returns UNLIMITED for stale
 *	fileptrs, because read/write operations won't block.
 *	More checks in the installation procedure.
 * 0.8	Added select() support. Increased the time in some sleep-loops.
 *	The main program now simply terminates, instead of being a TSR.
 *	Added (optional) syslog support. Macro-ized some constants.
 * 0.9	Some tasks (closing the connection, hanging up) are deferred to
 *	the daemon in order to make open/close operations atomic.
 *	Shutdown should work now (the mdm_close() function used to be
 *	interruptible by a signal, thus causing the FILEPTR to be closed
 *	twice, and MiNT crashed with a fatal error).
 * 1.0	Always release the SEMA_MDM semaphore on hangup, without clearing
 *	p_curr_tty so that we can still send SIGHUPs.
 *	Get rid of the ttyd_opened variable, since mdm_tty.use_cnt contains
 *	the same information.
 *	Clear p_curr_tty on hangup when the signal can't be sent immediately
 *	(we want to kill the current process group, not the future ones
 *	which will control the terminal -- getty should work better now.)
 */

#define  MDM_VERSION	"1.0"

#include <minimal.h>
#include <string.h>
#include <stdlib.h>
#include <osbind.h>
#include <basepage.h>
#include <mintbind.h>
#include <signal.h>

#include "atarierr.h"
#include "filesys.h"
#include "modm0dev.h"

#ifdef USE_SYSLOG
#include <syslog.h>
#endif

/*
 * Constants for ioctl, missing in filesys.h
 */
 
#define T_TANDEM	0x1000
#define T_RTSCTS	0x2000
#define T_EVENP		0x4000	/* EVENP and ODDP are mutually exclusive */
#define T_ODDP		0x8000

#define TF_FLAGS	0xF000

/* some flags for TIOC[GS]FLAGS */
#define TF_STOPBITS	0x0003
#define TF_1STOP	0x0001
#define TF_15STOP	0x0002
#define	TF_2STOP	0x0003

#define TF_CHARBITS	0x000C
#define TF_8BIT		0
#define TF_7BIT		0x4
#define TF_6BIT		0x8
#define TF_5BIT		0xC

/*
 * kernel functions
 */

#define TGETTIME	(*kernel->dos_tab[0x2c])
#define TGETDATE	(*kernel->dos_tab[0x2a])
#define YIELD		(*kernel->dos_tab[0xff])
#define PGETPID		(*kernel->dos_tab[0x10b])
#define PKILL		(*kernel->dos_tab[0x111])
#define FSELECT		(*kernel->dos_tab[0x11d])
#define PGETEUID	(*kernel->dos_tab[0x138])

#define NAP		(*kernel->nap)
#define SLEEP		(*kernel->sleep)
#define WAKE		(*kernel->wake)
#define WAKESELECT	(*kernel->wakeselect)

/* 
 * Debugging stuff
 */

#ifdef NDEBUG
#define DEBUG(x)
#define ALERT(x)
#define TRACE(x)
#define FATAL(x)
#else
#define DEBUG(x)	(*kernel->debug)x
#define ALERT(x)	(*kernel->alert)x
#define TRACE(x)	(*kernel->trace)x
#define FATAL(x)	(*kernel->fatal)x
#endif

/* daemon stack size */
#define D_STACK  512L

#define spl7()			\
({  register short retvalue;	\
    __asm__ volatile("		\
	movew sr,%0; 		\
	oriw  #0x0700,sr " 	\
    : "=d"(retvalue) 		\
    ); retvalue; })

#define spl(N)			\
({  				\
    __asm__ volatile("		\
	movew %0,sr " 		\
    :				\
    : "d"(N) ); })

/*
 * Symbols from modm0asm.s
 */
 
extern long old_evt_timer;
extern long old_txrint, old_rcvint, old_txerror, old_rxerror;
extern int dont_emit;
void dtr_on(void), dtr_off(void);
void rts_on(void), rts_off(void);
void carrier_monitor(void);
void txrint(void), rcvint(void), txerror(void), rxerror(void);
void clear_errors(void), check_errors(void);
void setstack(long sp);

/*
 * Forward definitions of the device driver functions
 */
 
long	cua_open	(FILEPTR *f);
long	cua_write	(FILEPTR *f, char *buf, long bytes);
long	cua_read	(FILEPTR *f, char *buf, long bytes);
long	cua_lseek	(FILEPTR *f, long where, int whence);
long	cua_ioctl	(FILEPTR *f, int mode, void *buf);
long	cua_datime	(FILEPTR *f, int *timeptr, int rwflag);
long	cua_close	(FILEPTR *f, int pid);
long	cua_select	(FILEPTR *f, long proc, int mode);
void	cua_unselect	(FILEPTR *f, long proc, int mode);

long	mdm_open	(FILEPTR *f);
long	mdm_write	(FILEPTR *f, char *buf, long bytes);
long	mdm_read	(FILEPTR *f, char *buf, long bytes);
long	mdm_lseek	(FILEPTR *f, long where, int whence);
long	mdm_ioctl	(FILEPTR *f, int mode, void *buf);
long	mdm_datime	(FILEPTR *f, int *timeptr, int rwflag);
long	mdm_close	(FILEPTR *f, int pid);
long	mdm_select	(FILEPTR *f, long proc, int mode);
void	mdm_unselect	(FILEPTR *f, long proc, int mode);

DEVDRV mdm_device = {
	mdm_open, mdm_write, mdm_read, mdm_lseek, mdm_ioctl,
	mdm_datime, mdm_close, mdm_select, mdm_unselect
};

DEVDRV cua_device = {
	cua_open, cua_write, cua_read, cua_lseek, cua_ioctl,
	cua_datime, cua_close, cua_select, cua_unselect
};

struct tty mdm_tty, cua_tty;

struct dev_descr mdm_devinfo = { &mdm_device,   0, O_TTY, &mdm_tty },
		 cua_devinfo = { &cua_device, 128, O_TTY, &cua_tty };

char	rx_buf_start[RX_BUF_LENGTH], 
	*rx_buf_end, 
	*rx_buf_tail;

/*
 * The "volatile" variables can be modified by an interrupt, so the
 * compiler will not optimize instructions containing them. This is
 * sometimes a problem: instructions like rx_buf_used-- and
 * tx_buf_used++ will translate into several assembly instructions,
 * and if an interrupt occurs inbetween, then we lose. This explains
 * the hacks in cua_read and cua_write to make them atomic.
 */

volatile char *rx_buf_head;
volatile long rx_buf_used;

char	tx_buf_start[TX_BUF_LENGTH], 
	*tx_buf_end, 
	*tx_buf_head;

volatile char *tx_buf_tail;
volatile long tx_buf_used;

volatile int hard_carrier;

/*
 * Which device is currently in use ? The "semaphore" variable contains
 * SEMA_MDM if data have been read from/written to the dial-in device,
 * SEMA_CUA if the dial-out device is open, and 0 otherwise. Once the
 * semaphore is owned (i.e. != 0) by one of the devices, it is released
 * on the last close of this device.
 */

#define SEMA_NONE	0
#define SEMA_MDM	1
#define SEMA_CUA	2

int semaphore = 0;	/* no direction selected yet */
int sema_pid;		/* the process owning the semaphore */

/*
 * Daemon state flags
 */
 
#define CLOSING_CONN	0x1
#define HANGING_UP	0x2

int daemon_state = 0;

/*
 * Other global information
 */
 
int connection_id = 0;		/* initial state, no connection  */
struct tty *p_curr_tty = NULL;	/* which tty will get signals?   */
long _stksize = 2048L;		/* 2kb of stack should be enough */
long rx_sel = 0L, tx_sel = 0L;	/* selecting processes		 */
FILEPTR *rx_fsel, *tx_fsel;	/* the corresponding FILEPTRs	 */
int soft_carrier;		/* soft carrier flag		 */
int hangup_control;		/* hangup-on-close flag		 */
int rts_cts;			/* RTS/CTS control flag		 */
long rx_lowmark, rx_highmark;
long baudrate;
int parity, charstopbits;
struct kerinfo *kernel;

#if !defined(USE_SYSLOG) && !defined(NDEBUG)
int logfile;			/* where shall we log errors?	 */
#endif

/*
 * Various utility macros and functions
 */

#define ATOMIC(x) \
    do { int sr=spl7(); x; spl(sr); } while(0)

void flush_rx_buffer (void)
{
	ATOMIC(rx_buf_head = rx_buf_tail; rx_buf_used = 0L);
}

void flush_tx_buffer (void)
{
	ATOMIC(tx_buf_tail = tx_buf_head; tx_buf_used = 0L);
}

/* Get the semaphore (if possible) and make some initializations */

int get_semaphore (int sem)
{
	if (semaphore)
		return semaphore;	/* Impossible */
	semaphore = sem;
	sema_pid = PGETPID();

	clear_errors();
	/* Select the controlling tty structure (for signals) */
	p_curr_tty = (semaphore == SEMA_CUA) ? &cua_tty : &mdm_tty;
	return 0;			/* Success */
}

/* 
 * Hardware configuration functions: set speed, bits/char, parity,
 * and break handling.
 */

void set_baudrate (long speed)
{
	int a;

	switch (speed) {
	  case   300: a = 9; break;
	  case   600: a = 8; break;
	  case  1200: a = 7; break;
	  case  1800: a = 6; break;
	  case  2400: a = 4; break;
	  case  4800: a = 2; break;
	  case  9600: a = 1; break;
	  case 19200: a = 0; break;
	  default: return;
	}
	Rsconf(a,-1,-1,-1,-1,-1);
	baudrate = speed;
}
	  
void set_bits (int flags)
{
	unsigned char *ucr = (unsigned char *)(0xfffffa29UL);

	if (!(flags & TF_STOPBITS))	/* it would mean "synchronous" */
		flags |= TF_1STOP;	/* assume 1-stopbit mode */
	*ucr = (*ucr & 0x87) | (flags << 3);
	charstopbits = flags;
}

void set_parity (int flags)
{
	unsigned char *ucr = (unsigned char *)(0xfffffa29UL), tmp;
	
	tmp = *ucr & 0xf9;	/* clear bits 1 and 2 */
	if (flags == T_ODDP)
		*ucr = tmp | 4;	/* odd parity */
	else if (flags == T_EVENP)
		*ucr = tmp | 6;	/* even parity */
	else {	
		*ucr = tmp;	/* no parity */
		flags = 0;
	}
	parity = flags;
}

void break_condition (int flag)
{
	unsigned char *tsr = (unsigned char *)(0xfffffa2dUL);
	
	*tsr = flag ? (*tsr | 8) : (*tsr & ~8);
}

/* 
 * Are we connected? We need two macros for that; CONNECTED() has a little
 * delay, but is synchronous with the daemon. The REALLY_CONNECTED() macro
 * is only used by the daemon.
 */

#define REALLY_CONNECTED()	(soft_carrier || hard_carrier)
#define CONNECTED()		(connection_id % 2)

/*
 * Opening the device
 */
 
long cua_open (FILEPTR *f)
{
#ifdef SECURE_OPEN
	if (PGETEUID()) {
		DEBUG(("cua_open: only root can open this device"));
		return EACCDN;
	}
#endif
	if (get_semaphore(SEMA_CUA)) {
		DEBUG(("cua_open: serial interface is busy"));
		return EACCDN;
	}
	TRACE(("cua_open: dial-out device opened"));
	daemon_state |= HANGING_UP;
	/* f->pos = 0; */

	f->flags |= O_TTY;
	return 0;
}

long mdm_open (FILEPTR *f)
{
#ifdef SECURE_OPEN
	if (PGETEUID()) {
		DEBUG(("mdm_open: only root can open this device"));
		return EACCDN;
	}
#endif
	TRACE(("mdm_open: dial-in device opened"));
	/* For which connection_id is this fileptr valid ? */
	f->pos = CONNECTED() ? connection_id : connection_id+1;

	f->flags |= O_TTY;
	return 0;
}

/* 
 * This is a terminal, thus seek() should always return 0 
 */

long cua_lseek (FILEPTR *f, long where, int whence)
{
	TRACE(("cua_lseek: returns always 0"));
	return 0;
}

#if 0
long mdm_lseek (FILEPTR *f, long where, int whence)
{
	return cua_lseek(f, where, whence);
}
#else
__asm__ (".stabs \"_mdm_lseek\", 5,0,0, _cua_lseek");
#endif

/*
 * Time and date -- always return the current time. Anyway, MiNT
 * will never call this function since we're a terminal (at least in
 * the current version).
 */

long cua_datime (FILEPTR *f, int *timeptr, int rwflag)
{
	if (rwflag) {
		DEBUG(("cua_datime: can't modify date/time"));
		return EACCDN;
	}
	TRACE(("cua_datime: read time and date"));
	*timeptr++ = TGETTIME();
	*timeptr   = TGETDATE();
	return 0;
}

#if 0
long mdm_datime (FILEPTR *f, int *timeptr, int rwflag)
{
	return cua_datime(f, timeptr, rwflag);
}
#else
__asm__ (".stabs \"_mdm_datime\", 5,0,0, _cua_datime");
#endif

/*
 * Closing the device. We shouldn't hang-up straight away, or data still
 * in the buffer could be lost.
 */
 
long cua_close (FILEPTR *f, int pid)
{
	if (f->links == 0) {
		TRACE(("cua_close: closing dial-out device"));
		p_curr_tty = NULL;
		semaphore = 0;
		daemon_state |= (CLOSING_CONN|HANGING_UP);
	}
	return 0;
}

long mdm_close (FILEPTR *f, int pid)
{
	if (p_curr_tty == &mdm_tty && mdm_tty.use_cnt == 0) {
		TRACE(("mdm_close: closing dial-in device"));
		p_curr_tty = NULL;
		semaphore = 0;
		daemon_state |= CLOSING_CONN;
		if (hangup_control)
			daemon_state |= HANGING_UP;
	}
	return 0;
}

/*
 * Utility function: returns the number of bytes which can be read from
 * or written to this device without blocking.
 */

long bytes_available (FILEPTR *f, int mode)
{
	if (daemon_state)
		return 0;			/* daemon is busy */
	if (f->pos) {
		if (semaphore == SEMA_CUA)
			return 0;		/* we don't own the stream */
		if (f->pos > connection_id)
			return 0;		/* no connection yet */
		if (f->pos < connection_id)
			return UNLIMITED;	/* stale fileptr */
	}
	return (mode==FIONREAD) ? rx_buf_used : (TX_BUF_LENGTH-tx_buf_used);
}

/*
 * Selecting and unselecting one of the devices.
 * BUG: there can be only one select'ing process in each direction; this
 * means that you cannot simultaneously select on the dial-in and dial-out
 * devices; fortunately, getty doesn't use select.
 */

long cua_select (FILEPTR *f, long proc, int mode)
{
	TRACE(("cua_select: mode %d", mode));
	if (mode == O_WRONLY) {
		if (tx_sel || bytes_available(f,FIONWRITE))
			return 1;
		TRACE(("cua_select: going to sleep -- can't write"));
		tx_sel = proc;
		tx_fsel = f;
		return 0;
	}
	if (mode == O_RDONLY) {
		if (rx_sel || bytes_available(f,FIONREAD))
			return 1;
		TRACE(("cua_select: going to sleep -- can't read"));
		rx_sel = proc;
		rx_fsel = f;
		return 0;
	}
	DEBUG(("cua_select: invalid mode"));
	return EINVFN;	
}

#if 0
long mdm_select (FILEPTR *f, long proc, int mode)
{
	return cua_select(f, proc, mode);
}
#else
__asm__ (".stabs \"_mdm_select\", 5,0,0, _cua_select");
#endif

void cua_unselect (FILEPTR *f, long proc, int mode)
{
	TRACE(("cua_unselect: mode %d", mode));
	if (mode == O_WRONLY)
		tx_sel = 0L;
	if (mode == O_RDONLY)
		rx_sel = 0L;
}

#if 0
void mdm_unselect (FILEPTR *f, long proc, int mode)
{
	return cua_unselect(f, proc, mode);
}
#else
__asm__ (".stabs \"_mdm_unselect\", 5,0,0, _cua_unselect");
#endif

/*
 * Reading from / writing to the device.
 *
 * Since it is a terminal, we know that "bytes" will always be a multiple
 * of four; but we check it anyway.
 */

long cua_read (FILEPTR *f, char *buf, long bytes)
{
	long left=bytes;
	char c;

	if (bytes<0 || bytes%4) {
		DEBUG(("cua_read: bytes out of range"));
		return ERANGE;
	}
	TRACE(("cua_read: read %ld bytes", bytes));
	while (left) {
		if (daemon_state != 0) {
			TRACE(("mdm_read: the daemon has something to do"));
			if (f->flags & O_NDELAY)  break;
			NAP(100);
			continue;
		}
		if (f->pos) {	/* dial-in fileptr? */
			if (semaphore == SEMA_CUA) {
				TRACE(("mdm_read: dial-out device in use"));
				if (f->flags & O_NDELAY)  break;
				NAP(1000);
				continue;
			}
			/* Too early? */
			if (f->pos > connection_id) {
				TRACE(("mdm_read: no connection yet"));
				if (f->flags & O_NDELAY)  break;
				NAP(100);
				continue;
			}
			/* Too late? */
			if (f->pos < connection_id) {
				DEBUG(("mdm_read: stale fileptr"));
				break;
			}
			/* All OK! grab the semaphore if possible */
			get_semaphore(SEMA_MDM);
		}
		/* Wait for data */
		if (rx_buf_used == 0) {
			TRACE(("cua_read: no data present in buffer"));
			if (f->flags & O_NDELAY)  break;
			NAP(100);
			continue;
		}
		c = *rx_buf_tail++;
		if (rx_buf_tail == rx_buf_end)
			rx_buf_tail = rx_buf_start;
		*buf++ = 0;
		*buf++ = 0;
		*buf++ = 0;
		*buf++ = c;
#if 0
		ATOMIC(rx_buf_used--);
#else
		__asm__ volatile ("subql #1, _rx_buf_used");
#endif
		left -= 4;	/* four bytes read */
	}
	return bytes - left;
}

#if 0
long mdm_read (FILEPTR *f, char *buf, long bytes)
{ 
	return cua_read(f, buf, bytes); 
}
#else
__asm__ (".stabs \"_mdm_read\", 5,0,0, _cua_read");
#endif

long cua_write (FILEPTR *f, char *buf, long bytes)
{
	long left=bytes;
	char c;
	
	if (bytes<0 || bytes%4) {
		DEBUG(("cua_write: bytes out of range"));
		return ERANGE;
	}
	TRACE(("cua_write: write %ld bytes", bytes));
	while (left) {
		if (daemon_state != 0) {
			TRACE(("mdm_write: the daemon has something to do"));
			if (f->flags & O_NDELAY)  break;
			NAP(100);
			continue;
		}
		if (f->pos) {	/* dial-in fileptr? */
			if (semaphore == SEMA_CUA) {
				TRACE(("mdm_write: dial-out device in use"));
				if (f->flags & O_NDELAY)  break;
				NAP(1000);
				continue;
			}
			/* Too early? */
			if (f->pos > connection_id) {
				TRACE(("mdm_write: no connection yet"));
				if (f->flags & O_NDELAY)  break;
				NAP(100);
				continue;
			}
			/* Too late? */
			if (f->pos < connection_id) {
				DEBUG(("mdm_write: stale fileptr"));
				break;
			}
			/* All OK! grab the semaphore if possible */
			get_semaphore(SEMA_MDM);
		}
		/* Wait to transmit data */
		if (tx_buf_used == TX_BUF_LENGTH) {
			TRACE(("cua_write: no room left in buffer"));
			if (f->flags & O_NDELAY)  break;
			NAP(100);
			continue;
		}
		buf += 3;	/* skip first three bytes */
		c = *buf++;	/* this one only is significant */
		*tx_buf_head++ = c;
		if (tx_buf_head == tx_buf_end)
			tx_buf_head = tx_buf_start;
#if 0
		ATOMIC(tx_buf_used++);
#else
		__asm__ volatile("addql #1, _tx_buf_used");
#endif
		left -= 4;	/* four bytes written */
	}
	return bytes - left;
}

#if 0
long mdm_write (FILEPTR *f, char *buf, long bytes)
{ 
	return cua_write(f, buf, bytes); 
}
#else
__asm__ (".stabs \"_mdm_write\", 5,0,0, _cua_write");
#endif

/*
 * Ioctl operations: we can flush the buffers or get/set the baudrate
 */
 
long cua_ioctl (FILEPTR *f, int mode, void *buf)
{
	long free;
	long new_baudrate;
	int flags, new_flags;

	if (mode == FIONREAD || mode == FIONWRITE) {
		free = bytes_available(f,mode);
		TRACE(("cua_ioctl(0x%x) returned %ld", mode, free));
		*(long *)buf = free;
	} 
	else if (mode == TIOCFLUSH) {
		TRACE(("cua_ioctl(TIOCFLUSH): clear buffers"));
		flush_rx_buffer();
		flush_tx_buffer();
	} 
	else if (mode == TIOCIBAUD || mode == TIOCOBAUD) {
		new_baudrate = *(long *)buf;
		*(long *)buf = baudrate;
		TRACE(("cua_ioctl(TIOC?BAUD): was %ld now %ld", 
			baudrate, new_baudrate));
		if (new_baudrate == 0)
			daemon_state |= HANGING_UP;
		else if (new_baudrate != baudrate && PGETEUID() == 0)
			set_baudrate(new_baudrate);
	}
	else if (mode == TIOCCBRK) {
		TRACE(("cua_ioctl(TIOCCBRK): clear break condition"));
		break_condition(0);
	}
	else if (mode == TIOCSBRK) {
		TRACE(("cua_ioctl(TIOCSBRK): set break condition"));
		break_condition(1);
	}
	else if (mode == TIOCGFLAGS || mode == TIOCSFLAGS) {
		flags = parity | charstopbits;
		if (rts_cts)
			flags |= T_RTSCTS;
		new_flags = *(int *)buf;
		*(int *)buf = flags;
		TRACE(("cua_ioctl(TIOCGFLAGS): flags were 0x%02x", flags));
		if (mode == TIOCSFLAGS && PGETEUID() == 0) {
			TRACE(("cua_ioctl(TIOCSFLAGS): new flags are 0x%02x",
				new_flags));
			set_bits(new_flags & (TF_CHARBITS|TF_STOPBITS));
			set_parity(new_flags & (T_ODDP|T_EVENP));
			rts_cts = !!(new_flags & T_RTSCTS);
		}
	}
#ifdef NON_OFFICIAL_IOCTLS
	else if (mode == TIOCGHUPCL || mode == TIOCSHUPCL) {
		new_flags = *(int *)buf;
		*(int *)buf = hangup_control;
		TRACE(("cua_ioctl(TIOCGHUPCL) returned %d", hangup_control));
		if (mode == TIOCSHUPCL && PGETEUID() == 0) {
			hangup_control = !!new_flags;
			TRACE(("cua_ioctl(TIOCSHUPCL) is now %d",
				hangup_control));
		}
	}
	else if (mode == TIOCGSOFTCAR || mode == TIOCSSOFTCAR) {
		new_flags = *(int *)buf;
		*(int *)buf = soft_carrier;
		TRACE(("cua_ioctl(TIOCGSOFTCAR) returned %d", soft_carrier));
		if (mode == TIOCSSOFTCAR && PGETEUID() == 0) {
			soft_carrier = !!new_flags;
			TRACE(("cua_ioctl(TIOCSSOFTCAR) is now %d",
				soft_carrier));
		}
	}
#endif
	else {
		TRACE(("cua_ioctl(0x%x): invalid mode", mode));
		return EINVFN;
	}
	return 0;
}

#if 0
long mdm_ioctl (FILEPTR *f, int mode, void *buf)
{
	return cua_ioctl(f, mode, buf);
}
#else
__asm__ (".stabs \"_mdm_ioctl\", 5,0,0, _cua_ioctl");
#endif

/*
 * Hardware error handlers, invoked by check_errors(). Note that they are
 * called by the daemon process, so they can only use non-kernel functions.
 */
 
#define Raise_And_Flush(sig)						\
    do {								\
    	flush_rx_buffer();						\
    	flush_tx_buffer();						\
    	if (p_curr_tty && p_curr_tty->pgrp) {				\
    		p_curr_tty->state &= ~TS_HOLD;				\
    		(void) Pkill(-(p_curr_tty->pgrp),(int)(sig)); }		\
    } while(0)

/*
 * Syslog(pri,s): logs message "s" with priority "pri"; this parameter is
 * ignored if USE_SYSLOG is not defined.
 */

#if defined(USE_SYSLOG)
#define Syslog(pri,s)			\
  do {					\
  	openlog(D_NAME,0,LOG_DAEMON);	\
  	syslog(pri, s);			\
  	closelog();			\
  } while(0)
#elif defined(NDEBUG)
#define Syslog(pri,s) /*nothing*/
#else
#define Syslog(pri,s) \
	Fwrite(logfile,strlen(s)+17,"SERIAL LINE 1: " s "\r\n")
#endif

void Underrun_Error (void)
{
	/*
	 * This is hardly an error, it just means that characters
	 * are not transmitted at full speed. So we do nothing.
	 */
}

void Overrun_Error (void)
{
	/*
	 * Reception error: a character received hasn't been treated fast
	 * enough, and has been overwritten by the next one.
	 * A serious error, but it doesn't deserve a signal.
	 */
	Syslog(LOG_ERROR, "Overrun error");
}

void Parity_Error (void)
{
	/*
	 * A character with bad parity has been received. Probably
	 * a bad modem configuration.
	 */
	Syslog(LOG_ERROR, "Parity error");
}

void Frame_Error (void)
{
	/*
	 * A non-null character with a null stop-bit has been
	 * received. Probably a bad modem configuration.
	 */
	Syslog(LOG_ERROR, "Frame error");
}

void Break_Detected (void)
{
	/*
	 * Not an error, rather a "signal" sent by the remote
	 * user (a null character with a null stop-bit). It should
	 * flush the buffers and raise the SIGINT signal.
	 */
	Syslog(LOG_NOTICE, "Break condition detected");
	Raise_And_Flush(SIGINT);
}

void Buffer_Overflow (void)
{
	/*
	 * The reception buffer has wrapped around; this is a serious
	 * error, and should not happen if you use RTS/CTS.
	 * Maybe we should flush the rx buffer, since the data in it
	 * is likely to be corrupted.
	 */
	Syslog(LOG_ERROR, "Buffer overflow");
}

/*
 * This routine is called periodically (every 200 ms) by the daemon process.
 * It should check for hardware errors (and report them, maybe even raise
 * a signal), pending interrupt characters in the buffer (^C, ^S, etc.),
 * wake up selecting processes if necessary.
 *
 * According to the flags in daemon_state, it should also be able to wait
 * for a connection to terminate, and to hang-up.
 */

void check_signals (void)
{
	char c, *p, *end;
	int sig;

	/* Check for hardware errors */
	check_errors();

	/* Check for connection changes */
	if (semaphore != SEMA_CUA) {
		if (!CONNECTED() && REALLY_CONNECTED()) {
			Syslog(LOG_NOTICE, "Communication established");
			++connection_id;
		} else if (CONNECTED() && !REALLY_CONNECTED()) {
			Syslog(LOG_NOTICE, "Communication lost");
			++connection_id;
		}
	}
	if (!CONNECTED() && p_curr_tty == &mdm_tty) {
		semaphore = 0;
		if (mdm_tty.pgrp) {
			/* Kill the controlled process group */
			Raise_And_Flush(SIGHUP);
		} else {
			/* If we can't send signal now, never try again */
			p_curr_tty = NULL;
		}
	}
	/* Is this a controlling terminal in cooked mode? */
	if (rx_buf_used && p_curr_tty && p_curr_tty->pgrp &&
	   (p_curr_tty->state & TS_COOKED)) {
		/* Now check the rx buffer for control characters */
		p = rx_buf_tail;
		end = (char *)rx_buf_head;	/* to make GCC happy */
		while (p < end) {
			c = *p;
			sig = 0;
			if (c == p_curr_tty->tc.t_intrc)
				sig = SIGINT;
			else if (c == p_curr_tty->tc.t_quitc)
				sig = SIGQUIT;
			else if (c == p_curr_tty->ltc.t_suspc)
				sig = SIGTSTP;
			else if (c == p_curr_tty->tc.t_startc)
				p_curr_tty->state &= ~TS_HOLD;
			else if (c == p_curr_tty->tc.t_stopc)
				p_curr_tty->state |= TS_HOLD;
		
			if (sig) {
				Raise_And_Flush(sig);
				break;
			}
			if (++p == rx_buf_end)
				p = rx_buf_start;
		}
	}
	/* Update the hardware transmission flag */
	dont_emit = (p_curr_tty ? !!(p_curr_tty->state & TS_HOLD) : 0);

	/* Wake up the selecting processes, if any */
	if (tx_sel && bytes_available(tx_fsel,FIONWRITE))
		{ WAKESELECT(tx_sel); tx_sel = 0L; }
	if (rx_sel && bytes_available(rx_fsel,FIONREAD))
		{ WAKESELECT(rx_sel); rx_sel = 0L; }
		
	/* Have we got something to do? */
	if (daemon_state & CLOSING_CONN) {
		/* Wait for all bytes to be transmitted */
		dont_emit = 0;	/* paranoia */
		if (tx_buf_used == 0) {
			daemon_state &= ~CLOSING_CONN;
			flush_rx_buffer();
			break_condition(0);
		}
	}
	else if (daemon_state & HANGING_UP) {
		/* Hangup for 1.2 second */
		dtr_off();
		(void)Fselect(1200,0L,0L,0L);
		dtr_on();
		flush_rx_buffer();
		flush_tx_buffer();
		break_condition(0);
		daemon_state &= ~HANGING_UP;
	}
	/* Pooh, that was a lot of job! */		
}

/*
 * Installs all the interrupt routines, and initializes the RS232 port.
 */

void install_things (void)
{
	int sr;
	long old_ssp;
	
	old_ssp = Super(0L);
	sr = spl7();

	/* First, initialize the buffers */
	rx_buf_head = rx_buf_tail = rx_buf_start;
	tx_buf_tail = tx_buf_head = tx_buf_start;
	rx_buf_end = rx_buf_start + RX_BUF_LENGTH;
	tx_buf_end = tx_buf_start + TX_BUF_LENGTH;
	rx_lowmark  = RX_BUF_LENGTH * 1/8;
	rx_highmark = RX_BUF_LENGTH * 7/8; 

	/* Then, install the interrupt routines */
	Jdisint(2);			    /* MFP interrupt #2 disabled */
	old_evt_timer = (long) Setexc(0x100, carrier_monitor);
	old_txerror = (long)Setexc(0x49, txerror);  /* MFP interrupt #9  */
	old_txrint  = (long)Setexc(0x4A, txrint);   /* MFP interrupt #10 */
	old_rxerror = (long)Setexc(0x4B, rxerror);  /* MFP interrupt #11 */
	old_rcvint  = (long)Setexc(0x4C, rcvint);   /* MFP interrupt #12 */

	/* Initialize the serial port */
	set_baudrate(INITIAL_SPEED);
	set_bits(INITIAL_FLAGS & (TF_CHARBITS|TF_STOPBITS));
	set_parity(INITIAL_FLAGS & (T_ODDP|T_EVENP));
	rts_cts = !!(INITIAL_FLAGS & T_RTSCTS);
	soft_carrier = INITIAL_SOFTCAR;
	hangup_control = INITIAL_HUPCL;
	break_condition(0);

	spl(sr);
	Super(old_ssp);
}

/* Copyright information */

void Version (void)
{
	Cconws("Serial port 1 device driver (version " MDM_VERSION 
	", compiled " __DATE__ ") by T.Bousch\r\n"
	"This program is FREE SOFTWARE, and comes with NO WARRANTY.\r\n"
	"Read the file COPYING for more information.\r\n"
#ifdef USE_SYSLOG
	"SYSLOG version\r\n"
#endif
	);
}

/*
 * The daemon process; it executes in non-kernel mode, so it cannot use
 * kernel functions (apart from WAKESELECT).
 */

void modm0_daemon (long bp)
{
	setstack(bp + D_STACK - 16L);	/* abandon 16 bytes for security */
	Psigblock(0x7fffffffUL);  	/* mask all maskable signals */
#if !defined(USE_SYSLOG) && !defined(NDEBUG)
	logfile = Fopen(LOGFILE, O_WRONLY);
#endif
	Super(0L);

	while(1) {
		(void)Fselect(200, 0L, 0L, 0L);  /* sleep 200 ms */
		check_signals();
	}
}

/*
 * Main routine. It would be nice if we could pass arguments on the command
 * line, but it's not possible if we include <minimal.h>, and we don't want
 * to add ~15kb to the code only for that. If you don't like the default
 * settings, change them in modm0dev.h and recompile. Or use stty.
 */

int main()
{
	BASEPAGE *b;

	if (Syield() == EINVFN) {
		Cconws("modm0dev: MiNT is not running\r\n");
		return EACCDN;
	}
	if (!Fsfirst(MDM_DEVNAME,0) || !Fsfirst(CUA_DEVNAME,0)) {
		Cconws("modm0dev: device already installed\r\n");
		return EACCDN;
	}
	/*
	 * The daemon won't work properly if not super-user
	 */
	if (Pgeteuid()) {
		Cconws("modm0dev: must be root to execute this program\r\n");
		return EACCDN;
	}
	kernel = (struct kerinfo *)
		Dcntl(DEV_INSTALL, MDM_DEVNAME, &mdm_devinfo);
	if ((long)kernel <= 0L) {
		Cconws("modm0dev: can't install " MDM_DEVNAME "\r\n");
		return EACCDN;
	}
	if (Dcntl(DEV_INSTALL, CUA_DEVNAME, &cua_devinfo) <= 0L) {
		Cconws("modm0dev: can't install " CUA_DEVNAME "\r\n");
		Fdelete(MDM_DEVNAME);
		return EACCDN;
	}
	/*
	 * Install the daemon (just like in Stephen Henson's Minixfs).
	 * If something goes wrong, it is probably an out of memory
	 * error.
	 */
	b = (BASEPAGE *) Pexec(5, 0L, "", 0L);
	if ((long)b <= 0L)
		goto no_memory;
	Mshrink(b, D_STACK);
	b->p_tbase = (char *)modm0_daemon;	/* start address */
	b->p_hitpa = (char *)b + D_STACK;	/* top of block  */
	if (Pexec(104, D_NAME, b, 0L) < 0L)
		goto no_memory;
	Version();
	install_things();
#if 1
	/* There's no need to keep the program resident, since all its
	 * memory is also owned by the daemon. So we simply exit. */
	return 0;
#else
	Ptermres(256L + _base->p_tlen + _base->p_dlen + _base->p_blen, 0);
#endif
	/* Fall through if Ptermres() failed */
no_memory:
	Cconws("modm0dev: running out of memory\r\n");
	Fdelete(MDM_DEVNAME); 
	Fdelete(CUA_DEVNAME);
	return ENSMEM;
}
