/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

#include <errno.h>

#include "jove.h"

#ifdef UNIX /* the body is the rest of the file */

#include "fp.h"

#ifdef BIFF
# include <sys/stat.h>
#endif

#include "chars.h"
#include "term.h"	/* ospeed */
#include "ttystate.h"
#include "util.h"


#ifdef SGTTY
struct sgttyb	sg[2];
#endif

#ifdef TERMIO
struct termio	sg[2];
#endif

#ifdef TERMIOS
struct termios	sg[2];
#endif

#ifdef USE_TIOCSLTC
struct ltchars	ls[2];
#endif /* USE_TIOCSLTC */

#ifdef SGTTY

# ifdef TIOCGETC
struct tchars	tc[2];
# endif

# ifdef LPASS8	/* use 4.3BSD's LPASS8 instead of raw for meta-key */
int	lmword[2];		/* local mode word */
# endif

#endif /* SGTTY */


/* Set tty to original (if !n) or JOVE (if n) modes.
 * This is designed to be idempotent: it can be called
 * several times with the same argument without damage.
 */

bool	OKXonXoff = NO;	/* VAR: XON/XOFF can be used as ordinary chars */
ZXchar	IntChar = CTL(']');	/* VAR: ttysetattr sets this to generate SIGINT */

#ifdef BIFF
bool	DisBiff = NO;		/* VAR: turn off/on biff with entering/exiting jove */
#endif /* BIFF */

void
ttysetattr(n)
bool	n;	/* also used as subscript! */
{
	static bool	prev_n = NO;

	if (!prev_n) {
		/* Previously, the tty was not in JOVE mode.
		 * Find out the current settings:
		 * do the ioctls or whatever to fill in NO half
		 * of each appropriate tty state pair.
		 * NOTE: the nested tangle of ifdefs is intended to follow
		 * the structure of the definitions in ttystate.c.
		 */
#ifdef SGTTY
		(void) gtty(0, &sg[NO]);
#endif

#ifdef TERMIO
		(void) ioctl(0, TCGETA, (UnivPtr) &sg[NO]);
#endif

#ifdef TERMIOS
		(void) tcgetattr(0, &sg[NO]);
#endif

#ifdef USE_TIOCSLTC
		(void) ioctl(0, TIOCGLTC, (UnivPtr) &ls[NO]);
#endif /* USE_TIOCSLTC */

#ifdef SGTTY

# ifdef TIOCGETC
		(void) ioctl(0, TIOCGETC, (UnivPtr) &tc[NO]);
# endif

# ifdef LPASS8	/* use 4.3BSD's LPASS8 instead of raw for meta-key */
		(void) ioctl(0, TIOCLGET, (UnivPtr) &lmword[NO]);
# endif

#endif /* SGTTY */

/* extract some info from results */

#if defined(TERMIO) || defined(TERMIOS)
# ifdef TAB3
		TABS = (sg[NO].c_oflag & TABDLY) != TAB3;
# endif
# ifdef TERMIOS
		ospeed = cfgetospeed(&sg[NO]);
# else /* ! TERMIOS */
#  ifdef CBAUD
		ospeed = sg[NO].c_cflag & CBAUD;
#  else /* ! CBAUD */
		ospeed = B9600;	/* XXX */
#  endif /* CBAUD */
# endif /* TERMIOS */
#endif /* defined(TERMIO) || defined(TERMIOS) */

#ifdef SGTTY
		TABS = !(sg[NO].sg_flags & XTABS);
		ospeed = sg[NO].sg_ospeed;
#endif /* SGTTY */
	}

	/* Fill in YES half of each appropriate tty state pair.
	 * They are filled in as late as possible so that each will
	 * reflect the latest settings of controling variables.
	 * NOTE: the nested tangle of ifdefs is intended to follow
	 * the structure of the definitions in ttystate.c.
	 */

	sg[YES] = sg[NO];

#ifdef SGTTY
	sg[YES].sg_flags &= ~(XTABS|ECHO|CRMOD);
# ifdef LPASS8
	sg[YES].sg_flags |= CBREAK;
# else
	sg[YES].sg_flags |= (MetaKey ? RAW : CBREAK);
# endif
#endif

#if defined(TERMIO) || defined(TERMIOS)
	if (OKXonXoff)
		sg[YES].c_iflag &= ~(IXON | IXOFF);
	sg[YES].c_iflag &= ~(INLCR|ICRNL|IGNCR | (MetaKey? ISTRIP : 0));
	sg[YES].c_lflag &= ~(ICANON|ECHO);
	sg[YES].c_oflag &= ~(OPOST);

	/* Set all those c_cc elements that we must.
	 * For peculiar systems, one might wish to predefine JVDISABLE
	 * in the configuration.  For example, on some unnamed
	 * versions of the Convex OS, it would be good to
	 * define it as (sg[YES].c_cc[VDISABLE]), saving a system call.
	 * Note that the only uses of JDISABLE are in this block,
	 * so the macro may safely refer to things in this context.
	 */
	{
# ifndef JVDISABLE
#  ifdef _POSIX_VDISABLE
#   define JVDISABLE	_POSIX_VDISABLE
#  else /* !_POSIX_VDISABLE */
#   ifdef _PC_VDISABLE
		/* Cache the result of fpathconf to reduce the number of syscalls.
		 * We don't handle the error return (-1) because there isn't
		 * anything better to do with it.
		 */
		cc_t	jvd = fpathconf(0, _PC_VDISABLE);
#    define JVDISABLE	jvd
#   else /* !_PC_VDISABLE */
#    define JVDISABLE	0
#   endif /* !_PC_VDISABLE */
#  endif /* !_POSIX_VDISABLE */
# endif /* JVDISABLE */

		sg[YES].c_cc[VINTR] = IntChar;

# ifdef VQUIT
		sg[YES].c_cc[VQUIT] = JVDISABLE;
# endif
		/* VERASE, VKILL, VEOL2 irrelevant */
		/* Beware aliasing! VMIN is VEOF and VTIME is VEOL */
# ifdef VSWTCH
		sg[YES].c_cc[VSWTCH] = JVDISABLE;
# endif

		/* Under at least one system (SunOS 4.0), <termio.h>
		 * mistakenly defines the extra V symbols of <termios.h>
		 * without extending the c_cc array in struct termio
		 * to hold them!  This is why the following goo is doubly
		 * ifdefed.  It turns out that we don't use <termio.h>
		 * on SunOS 4.0, so the problem may be moot.
		 */

# ifdef TERMIOS
#  ifdef VSUSP
		sg[YES].c_cc[VSUSP] = JVDISABLE;
#  endif
#  ifdef VDSUSP
		sg[YES].c_cc[VDSUSP] = JVDISABLE;
#  endif
#  ifdef VDISCARD
		/* ??? Under Solaris 2.1 needs VDISCARD disabled, or it will
		 * be processed by the tty driver, but not under SysVR4!
		 */
		sg[YES].c_cc[VDISCARD] = JVDISABLE;	/* flush output */
#  endif
#  ifdef VLNEXT
		sg[YES].c_cc[VLNEXT] = JVDISABLE;	/* literal next char */
#  endif
# endif /* TERMIOS */

		sg[YES].c_cc[VMIN] = 1;
		sg[YES].c_cc[VTIME] = 1;
	}
#endif /* defined(TERMIO) || defined(TERMIOS) */

#ifdef USE_TIOCSLTC
	ls[YES] = ls[NO];
	ls[YES].t_suspc = (char) -1;
	ls[YES].t_dsuspc = (char) -1;
	ls[YES].t_flushc = (char) -1;
	ls[YES].t_lnextc = (char) -1;
#endif /* USE_TIOCSLTC */

#ifdef SGTTY

# ifdef TIOCGETC
	tc[YES] = tc[NO];
	tc[YES].t_intrc = IntChar;
	tc[YES].t_quitc = (char) -1;
	if (OKXonXoff) {
		tc[YES].t_stopc = (char) -1;
		tc[YES].t_startc = (char) -1;
	}
# endif

# ifdef LPASS8	/* use 4.3BSD's LPASS8 instead of raw for meta-key */
	lmword[YES] = lmword[NO];

	if (MetaKey)
		lmword[YES] |= LPASS8;

#  ifdef LLITOUT
	/* ??? under what conditions should we turn on LLITOUT flag? */
#  endif /* LLITOUT */

#  ifdef LTILDE
	if (Hazeltine)
		lmword[YES] &= ~LTILDE;
#  endif /* LTILDE */

# endif /* LPASS8 */

#endif /* SGTTY */

	/* Set tty state according to appropriate entry of each state pair.
	 * NOTE: the nested tangle of ifdefs is intended to follow
	 * the structure of the definitions in ttystate.c.
	 */

#ifdef SGTTY
#  ifdef TIOCSETN
	(void) ioctl(0, TIOCSETN, (UnivPtr) &sg[n]);
#  else
	(void) stty(0, &sg[n]);
#  endif
#endif

#ifdef TERMIO
	do ; while (ioctl(0, TCSETAW, (UnivPtr) &sg[n]) < 0 && errno == EINTR);
#endif

#ifdef TERMIOS
	do ; while (tcsetattr(0, TCSADRAIN, &sg[n]) < 0 && errno == EINTR);
#endif

#ifdef USE_TIOCSLTC
	(void) ioctl(0, TIOCSLTC, (UnivPtr) &ls[n]);
#endif /* USE_TIOCSLTC */

#ifdef SGTTY

# ifdef TIOCGETC
	(void) ioctl(0, TIOCSETC, (UnivPtr) &tc[n]);
# endif

# ifdef LPASS8	/* use 4.3BSD's LPASS8 instead of raw for meta-key */
	(void) ioctl(0, TIOCLSET, (UnivPtr) &lmword[n]);	/* local mode word */
# endif

#endif /* SGTTY */

#ifdef BIFF

	/* biff state is an honorary part of the tty state.
	 * On the other hand, it is different from the rest of the state
	 * since we only want to examine the setting if DisBiff
	 * has been set by the user.  For this reason, the code is
	 * somewhat more intricate.
	 */
	{
#		define BS_UNEXAMINED	0	/* we don't know if biff is enabled */
#		define BS_DISABLED	1	/* we have disabled biff */
#		define BS_UNCHANGED	2	/* we didn't disable biff */
		static int	biff_state = BS_UNEXAMINED;

		static struct stat	tt_stat;
# if !defined(USE_FSTAT) || !defined(USE_FCHMOD)
		static char	*tt_name = NULL;	/* name of the control tty */
		extern char	*ttyname proto((int));	/* for systems w/o fstat */
# endif

		if (n && DisBiff) {
			/* biff supression is our business */
			if (biff_state == BS_UNEXAMINED) {
				/* and we haven't looked after it */
				biff_state = BS_UNCHANGED;	/* at least so far */
				if (
# ifdef USE_FSTAT
					fstat(0, &tt_stat) != -1
# else
					((tt_name != NULL) || (tt_name = ttyname(0)) != NULL)
					&& stat(tt_name, &tt_stat) != -1
# endif
				&& (tt_stat.st_mode & S_IEXEC))
				{
					/* so let's suppress it */
# ifdef USE_FCHMOD
					(void) fchmod(0, tt_stat.st_mode & ~S_IEXEC);
					biff_state = BS_DISABLED;
# else
					if ((tt_name != NULL || (tt_name = ttyname(0)) != NULL)
					&& chmod(tt_name, tt_stat.st_mode & ~S_IEXEC) != -1)
					{
						/* Note: only change biff_state if we were able to
						 * get the tt_name -- this prevents the other
						 * chmod from blowing up.
						 */
						biff_state = BS_DISABLED;
					}
# endif
				}
			}
		} else {
			/* any biff suppression should be undone */
			if (biff_state == BS_DISABLED) {
				/* and we did suppress it, so we enable it */
# ifdef USE_FCHMOD
				(void) fchmod(0, tt_stat.st_mode);
# else
				(void) chmod(tt_name, tt_stat.st_mode);
# endif
			}
			biff_state = BS_UNEXAMINED;	/* it's out of our hands */
		}
#		undef BS_UNEXAMINED
#		undef BS_DISABLED
#		undef BS_UNCHANGED
	}

#endif /* BIFF */
	prev_n = n;
}

/* Determine the number of characters to buffer at each baud rate.  The
   lower the number, the quicker the response when new input arrives.  Of
   course the lower the number, the more prone the program is to stop in
   output.  Decide what matters most to you. This sets ScrBufSize to the right
   number or chars, and initializes `jstdout'.  */

void
settout()
{
	int	speed_chars;

	static const struct {
		unsigned int bsize;
		unsigned int brate;
	} speeds[] = {

#ifdef B0
		{ 1, B0 },
#endif
#ifdef B50
		{ 1, B50 },
#endif
#ifdef B75
		{ 1, B75 },
#endif
#ifdef B110
		{ 1, B110 },
#endif
#ifdef B134
		{ 1, B134 },
#endif
#ifdef B150
		{ 1, B150 },
#endif
#ifdef B200
		{ 1, B200 },
#endif
#ifdef B300
		{ 2, B300 },
#endif
#ifdef B600
		{ 4, B600 },
#endif
#ifdef B900
		{ 6, B900 },
#endif
#ifdef B1200
		{ 8, B1200 },
#endif
#ifdef B1800
		{ 16, B1800 },
#endif
#ifdef B2400
		{ 32, B2400 },
#endif
#ifdef B3600
		{ 64, B3600 },
#endif
#ifdef B4800
		{ 128, B4800 },
#endif
#ifdef B7200
		{ 256, B7200 },
#endif
#ifdef B9600
		{ 256, B9600 },
#endif
#ifdef EXTA
		{ 512, EXTA },
#endif
#ifdef B19200
		{ 512, B19200 },
#endif
#ifdef EXTB
		{ 1024, EXTB },
#endif
#ifdef B38400
		{ 1024, B38400 },
#endif
#ifdef EXT
		{ 1024, EXT }
#endif
};
	int i;
	for (i = 0; ; i++) {
		if (i == elemsof(speeds)) {
			speed_chars = 512;
			ospeed = B9600;	/* XXX */
			break;
		}
		if (speeds[i].brate == (unsigned short) ospeed) {
			speed_chars = speeds[i].bsize;
			break;
		}
	}

	flushscreen();		/* flush the one character buffer */
	ScrBufSize = min(MAXTTYBUF, speed_chars * max(LI / 24, 1));
#ifndef NO_JSTDOUT
	jstdout = fd_open("/dev/tty", F_WRITE|F_LOCKED, 1, (char *)NULL, ScrBufSize);
#endif
}

void
ttsize()
{
	/* ??? We really ought to wait until the screen is big enough:
	 * at least three lines high (one line each for buffer, mode,
	 * and message) and at least twelve columns wide (eight for
	 * line number, one for content, two for overflow indicators,
	 * and one blank at end).
	 */
#ifdef TIOCGWINSZ
	struct winsize win;

	if (ioctl(0, TIOCGWINSZ, (UnivPtr) &win) == 0
	&& win.ws_col >= 12
	&& win.ws_row >= 3)
	{
		CO = min(win.ws_col, MAXCOLS);
		LI = win.ws_row;
	}
#else /* !TIOCGWINSZ */
# ifdef BTL_BLIT
	struct jwinsize jwin;

	if (ioctl(0, JWINSIZE, (UnivPtr) &jwin) == 0
	&& jwin.bytesx >= 12
	&& jwin.bytesy >= 3)
	{
		CO = min(jwin.bytesx, MAXCOLS);
		LI = jwin.bytesy;
	}
# endif /* BTL_BLIT */
#endif /* !TIOCGWINSZ */
	ILI = LI - 1;
}

#endif /* UNIX */
