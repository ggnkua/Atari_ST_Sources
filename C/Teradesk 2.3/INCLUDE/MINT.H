/*
 * Teradesk. Copyright (c) 1993, 1994, 2002 W. Klaren.
 *
 * This file is part of Teradesk.
 *
 * Teradesk is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Teradesk is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Teradesk; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#ifndef __MINT__
#define __MINT__

typedef struct xattr
{
	unsigned short	mode;
	long	index;
	unsigned short	dev;
	unsigned short	rdev;
	unsigned short	nlink;
	unsigned short	uid;
	unsigned short	gid;
	long	size;
	long	blksize, nblocks;
	short	mtime, mdate;
	short	atime, adate;
	short	ctime, cdate;
	short	attr;
	short	reserved2;
	long	reserved3[2];
} XATTR;

/*
 * Character constants and defines for TTY's.
 */

#define MiNTEOF 0x0000ff1a

/*
 * Defines for tty_read.
 */

#define RAW	0
#define COOKED	0x1
#define NOECHO	0
#define ECHO	0x2
#define ESCSEQ	0x04

/*
 * Constants for Fcntl calls.
 */

#define F_DUPFD		0
#define F_GETFD		1
#define F_SETFD		2
#define FD_CLOEXEC	1
#define F_GETFL		3
#define F_SETFL		4
#define F_GETLK		5
#define F_SETLK		6
#define F_SETLKW	7

#define FSTAT		(('F'<< 8) | 0)
#define FIONREAD	(('F'<< 8) | 1)
#define FIONWRITE	(('F'<< 8) | 2)
#define TIOCGETP	(('T'<< 8) | 0)
#define TIOCSETP	(('T'<< 8) | 1)
#define TIOCSETN	TIOCSETP
#define TIOCGETC	(('T'<< 8) | 2)
#define TIOCSETC	(('T'<< 8) | 3)
#define TIOCGLTC	(('T'<< 8) | 4)
#define TIOCSLTC	(('T'<< 8) | 5)
#define TIOCGPGRP	(('T'<< 8) | 6)
#define TIOCSPGRP	(('T'<< 8) | 7)
#define TIOCFLUSH	(('T'<< 8) | 8)
#define TIOCSTOP	(('T'<< 8) | 9)
#define TIOCSTART	(('T'<< 8) | 10)
#define TIOCGWINSZ	(('T'<< 8) | 11)
#define TIOCSWINSZ	(('T'<< 8) | 12)
#define TIOCGXKEY	(('T'<< 8) | 13)
#define TIOCSXKEY	(('T'<< 8) | 14)
#define TIOCIBAUD	(('T'<< 8) | 18)
#define TIOCOBAUD	(('T'<< 8) | 19)
#define TIOCCBRK	(('T'<< 8) | 20)
#define TIOCSBRK	(('T'<< 8) | 21)
#define TIOCGFLAGS	(('T'<< 8) | 22)
#define TIOCSFLAGS	(('T'<< 8) | 23)
#define TIOCOUTQ	(('T'<< 8) | 24)

#define TCURSOFF	(('c'<< 8) | 0)
#define TCURSON		(('c'<< 8) | 1)
#define TCURSBLINK	(('c'<< 8) | 2)
#define TCURSSTEADY	(('c'<< 8) | 3)
#define TCURSSRATE	(('c'<< 8) | 4)
#define TCURSGRATE	(('c'<< 8) | 5)

#define PPROCADDR	(('P'<< 8) | 1)
#define PBASEADDR	(('P'<< 8) | 2)
#define PCTXTSIZE	(('P'<< 8) | 3)
#define PSETFLAGS	(('P'<< 8) | 4)
#define PGETFLAGS	(('P'<< 8) | 5)
#define PTRACESFLAGS	(('P'<< 8) | 6)
#define PTRACEGFLAGS	(('P'<< 8) | 7)
#define	P_ENABLE	(1 << 0)
#define	P_DOS		(1 << 1)
#define	P_BIOS		(1 << 2)
#define	P_XBIOS		(1 << 3)

#define PTRACEGO	(('P'<< 8) | 8)
#define PTRACEFLOW	(('P'<< 8) | 9)
#define PTRACESTEP	(('P'<< 8) | 10)
#define PTRACE11	(('P'<< 8) | 11)
#define PLOADINFO	(('P'<< 8) | 12)
#define	PFSTAT		(('P'<< 8) | 13)

struct ploadinfo
{
	short fnamelen;
	char *cmdlin, *fname;
};


#define SHMGETBLK	(('M'<< 8) | 0)
#define SHMSETBLK	(('M'<< 8) | 1)

/* terminal control constants (tty.sg_flags) */

#define T_CRMOD		0x0001
#define T_CBREAK	0x0002
#define T_ECHO		0x0004
#define T_RAW		0x0010

#define T_NOFLSH	0x0040
#define T_TOS		0x0080
#define T_TOSTOP	0x0100
#define T_XKEY		0x0200
#define T_TANDEM	0x1000
#define T_RTSCTS	0x2000
#define T_EVENP		0x4000
#define T_ODDP		0x8000

#define TF_FLAGS	0xF000

#define TF_STOPBITS	0x0003
#define TF_1STOP	0x0001
#define TF_15STOP	0x0002
#define	TF_2STOP	0x0003

#define TF_CHARBITS	0x000C
#define TF_8BIT		0
#define TF_7BIT		0x4
#define TF_6BIT		0x8
#define TF_5BIT		0xC

#define TS_ESC		0x00ff
#define TS_HOLD		0x1000
#define TS_COOKED	0x8000

/*
 * Structures for terminals.
 */

struct tchars
{
	char t_intrc;
	char t_quitc;
	char t_startc;
	char t_stopc;
	char t_eofc;
	char t_brkc;
};

struct ltchars
{
	char t_suspc;
	char t_dsuspc;
	char t_rprntc;
	char t_flushc;
	char t_werasc;
	char t_lnextc;
};

struct sgttyb
{
	char sg_ispeed;
	char sg_ospeed;
	char sg_erase;
	char sg_kill;
	unsigned short sg_flags;
};

struct winsize
{
	short	ws_row;
	short	ws_col;
	short	ws_xpixel;
	short	ws_ypixel;
};

struct xkey
{
	short	xk_num;
	char	xk_def[8];
};

struct tty
{
	short		pgrp;		/* process group of terminal */
	short		state;		/* terminal status, e.g. stopped */
	short		use_cnt;	/* number of times terminal is open */
	short		res1;		/* reserved for future expansion */
	struct sgttyb 	sg;
	struct tchars 	tc;
	struct ltchars 	ltc;
	struct winsize	wsiz;
	long		rsel;		/* selecting process for read */
	long		wsel;		/* selecting process for write */
	char		*xkey;		/* extended keyboard table */
	long		resrvd[3];	/* for future expansion */
};

/*
 * Signals.
 */

#define	NSIG		31		/* number of signals recognized */

#define	SIGNULL		0		/* not really a signal */
#define SIGHUP		1		/* hangup signal */
#define SIGINT		2		/* sent by ^C */
#define SIGQUIT		3		/* quit signal */
#define SIGILL		4		/* illegal instruction */
#define SIGTRAP		5		/* trace trap */
#define SIGABRT		6		/* abort signal */
#define SIGPRIV		7		/* privilege violation */
#define SIGFPE		8		/* divide by zero */
#define SIGKILL		9		/* cannot be ignored */
#define SIGBUS		10		/* bus error */
#define SIGSEGV		11		/* illegal memory reference */
#define SIGSYS		12		/* bad argument to a system call */
#define SIGPIPE		13		/* broken pipe */
#define SIGALRM		14		/* alarm clock */
#define SIGTERM		15		/* software termination signal */

#define SIGURG		16		/* urgent condition on I/O channel */
#define SIGSTOP		17		/* stop signal not from terminal */
#define SIGTSTP		18		/* stop signal from terminal */
#define SIGCONT		19		/* continue stopped process */
#define SIGCHLD		20		/* child stopped or exited */
#define SIGTTIN		21		/* read by background process */
#define SIGTTOU		22		/* write by background process */
#define SIGIO		23		/* I/O possible on a descriptor */
#define SIGXCPU		24		/* CPU time exhausted */
#define SIGXFSZ		25		/* file size limited exceeded */
#define SIGVTALRM	26		/* virtual timer alarm */
#define SIGPROF		27		/* profiling timer expired */
#define SIGWINCH	28		/* window size changed */
#define SIGUSR1		29		/* user signal 1 */
#define SIGUSR2		30		/* user signal 2 */

typedef void cdecl (*Sigfunc)( long signal );

#define SIG_DFL		((Sigfunc)0)
#define SIG_IGN		((Sigfunc)1)
#define SIG_ERR		((Sigfunc)-1)

#define sigmask(sig)	(1L << (sig))

/* Process functions. */

short Pgetpid(void);
short Pgetppid(void);
short Pgetpgrp(void);
short Psetpgrp(short pid, short grp);
short Pgetuid(void);
short Psetuid(short id);
short Pgetgid(void);
short Psetgid(short id);
short Pfork(void);
long Pwaitpid(short pid, short nohang, long *rusage);

/* Signal functions. */

short Pkill(short pid, short sig);
Sigfunc Psignal(short sig, Sigfunc handler);
unsigned long Psigblock(unsigned long mask);
unsigned long Psigsetmask(unsigned long mask);
void Psigreturn(void);
long Talarm(long seconds);
void Pause(void);

/* File functions. */

long Finstat( int f );
long Foutstat( int f );
long Fgetchar( int f, int mode );
long Fputchar( int f, long c, int mode );
long Pwait3(int flag, long *rusage);
int Fselect(unsigned int timeout, long *rfds, long *wfds, long *xfds);
long Fcntl(short fh, long arg, short cmd);
#define Fcntl(fh, arg, cmd)		Fcntl(fh, (long) arg, cmd)
int Dlock(int mode, int drive);

/* General functions. */

short Pdomain(short newdomain);
enum		/* Ssystem() codes */
{
	S_OSNAME,
	S_OSXNAME,
	S_OSVERSION,
	S_GETCOOKIE = 8,
	S_SETCOOKIE
};
long Ssystem(short mode, long arg1, long arg2);    /* GEMDOS 0x154 */

/* Standard library replacements. */

void sleep(unsigned short seconds);

#endif
