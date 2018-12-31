/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

/* Contains the main loop initializations, and some system dependent
   type things, e.g. putting terminal in CBREAK mode, etc. */

#include "jove.h"
#include "fp.h"
#include "jctype.h"
#include "chars.h"
#include "disp.h"
#include "re.h"	/* for dosearch() */
#include "reapp.h"	/* for find_tag(), UseRE */
#include "sysprocs.h"
#include "rec.h"
#include "ask.h"
#include "extend.h"
#include "fmt.h"
#include "macros.h"
#include "marks.h"
#include "mouse.h"
#ifndef MAC	/* Mac does without! */
# include "paths.h"
#endif
#include "proc.h"
#include "screen.h"
#include "term.h"
#include "version.h"
#include "wind.h"

#ifdef IPROCS
# include "iproc.h"
#endif

#ifdef USE_SELECT
#  include <sys/time.h>
#  include "select.h"
#endif

#ifdef SCO	/* ??? what is this for? */
# include <sys/stream.h>
# include <sys/ptem.h>
#endif

#include <signal.h>
#include <errno.h>

#ifdef MAC
# include "mac.h"
#else /* !MAC */
# include <sys/stat.h>
#endif /* !MAC */

#ifdef MSDOS
# include <bios.h>
# include <dos.h>
# include <time.h>
# include <process.h>
# define SIGHUP	99
# if defined(__WATCOMC__)
#  include <malloc.h>	/* for _heapgrow */
# endif
#endif /* MSDOS */

#ifdef WIN32
# include <windows.h>	/* ??? is this needed? */
# undef FIONREAD	 /* This is defined but ioctl isn't so we cannot use it. */
#endif

#ifdef STACK_DECL	/* provision for setting up appropriate stack */
STACK_DECL
#endif

#ifdef MINT
#include <stdio.h>
extern char *fixpath proto((char *));
extern int __default_mode__;
long _stksize = 20000L;
#endif

private void
	UnsetTerm proto((bool)),
	DoKeys proto((bool firsttime)),
	ShowKeyStrokes proto((void));

#ifdef NONBLOCKINGREAD
private void	setblock proto((bool on));
#endif

#ifdef POSIX_SIGS
SIGHANDLERTYPE
setsighandler(signo, handler)	/* simulate BSD's safe signal() */
int	signo;
SIGHANDLERTYPE	handler;
{
	static struct sigaction	act;	/* static so unspecified fields are 0 */
	struct sigaction	oact;

	act.sa_handler = handler;
	sigemptyset(&act.sa_mask);
	sigaddset(&act.sa_mask, signo);
	sigaction(signo, &act, &oact);
	return oact.sa_handler;
}
#endif

bool	TimeDisplayed = YES;	/* is time actually displayed in modeline? */

#ifdef UNIX

/* set things up to update the modeline every UpdFreq seconds */

int	UpdFreq = 30;	/* VAR: how often to update modeline */
bool	InSlowRead = NO;

void
SetClockAlarm(unset)
bool	unset;	/* unset alarm if none needed */
{
	if (TimeDisplayed && UpdFreq != 0)
		(void) alarm((unsigned) (UpdFreq - (time((time_t *)NULL) % UpdFreq)));
	else if (unset)
		alarm((unsigned)0);
}

/* AlarmHandler gets all SIGALRMs.  It decides, based on InWaitChar,
 * whether this is an alarm for updating the mode line or for showing
 * keystrokes.  Theoretically, InWaitChar is a state variable that ought
 * to be reset in complain and other exceptional cases, but waitchar
 * is called often enough that it turns out to be self-correcting.
 */

private volatile bool	InWaitChar = NO;

/*ARGSUSED*/
private SIGRESTYPE
AlarmHandler(junk)
int	junk;	/* passed in on signal; of no interest */
{
	int save_errno = errno;	/* Subtle, but necessary! */

	resetsighandler(SIGALRM, AlarmHandler);
	if (InWaitChar) {
		if (InSlowRead) {
			InSlowRead = NO;
			ShowKeyStrokes();
			redisplay();
			InSlowRead = YES;
			InWaitChar = NO;	/* might as well allow modeline updates */
			SetClockAlarm(NO);
		} else {
			alarm((unsigned)1);	/* try again later */
		}
	} else {
		UpdModLine = YES;
		if (InSlowRead) {
			/* needed because of stupid BSD restartable I/O */
			InSlowRead = NO;
			redisplay();
			InSlowRead = YES;
		}
		SetClockAlarm(NO);
	}
	errno = save_errno;
	return SIGRESVALUE;
}

#endif /* UNIX */

bool	stickymsg;	/* the last message should stick around */

char	NullStr[] = "";
jmp_buf	mainjmp;

#ifdef USE_SELECT
fd_set	global_fd;	/* set of file descriptors of interest (for select) */
int	global_maxfd;
#endif

/* paths */

/* path of machine-independent library */
#ifdef SHAREDIR
char	ShareDir[FILESIZE] = SHAREDIR;
#else
char	ShareDir[FILESIZE];
#endif

/* VAR: directory/device to store tmp files */
#ifdef TMPDIR
char	TmpDir[FILESIZE] = TMPDIR;
#else
char	TmpDir[FILESIZE];
#endif

#ifdef SUBSHELL
char
	Shell[FILESIZE] = DFLTSHELL,	/* VAR: shell to use */
# ifdef MSFILESYSTEM
	ShFlags[sizeof(ShFlags)] = "/c";	/* VAR: flags to shell */
# else
	ShFlags[sizeof(ShFlags)] = "-c";	/* VAR: flags to shell */
# endif /* MSFILESYSTEM */
#endif

/* LibDir: path of machine-dependent library (for Portsrv and Recover) */

#if defined(SUBSHELL) || defined(PIPEPROCS)
# define NEED_LIBDIR	1
private char	LibDir[FILESIZE] = LIBDIR;
#endif

/* finish: handle bad-news signals.
 * It also handles internally generated requests for termination.
 * For most values of code (signal types) an attempt
 * is made to save the buffers for recovery by "recover".
 * For most values of code, this routine stops JOVE
 * by calling abort, which causes a core dump under UNIX.
 *
 * - code -1 is an internally generated request to die with an
 *   attempt to save the buffers.  It had better not be the code
 *   for some real signal (it cannot be one under UNIX).
 *
 * - code 0 is an internally generated request to die quietly.
 *   It had better not be the code for some real signal
 *   (it cannot be one under UNIX).  This is the only code
 *   for which buffers are not saved.
 *
 * - SIGINT is caused by the user hitting the INTR key.
 *   We give him a choice of death or continuation.
 *
 * - SIGHUP is caused by loss of connection.  This code and
 *   code 0 are the only ones which don't cause an abort.
 *   Generated by OS and by JOVE itself.
 */

SIGRESTYPE
finish(code)
int	code;
{
	int save_errno = errno;	/* Subtle, but necessary! */
	bool	DelTmps = YES;		/* Usually we delete them. */

	if (code == SIGINT) {
		char	c;
#ifdef WIN32
		c = FatalErrorMessage("Fatal interrupt encountered. Abort?");
#else /* !WIN32 */
# ifdef PIPEPROCS
		bool	started;
# endif

		resetsighandler(SIGINT, finish);
		f_mess("Abort (Type 'n' if you're not sure)? ");
		Placur(ILI, min(CO - 2, calc_pos(mesgbuf, MAXCOLS)));
		flushscreen();
# ifdef UNIX
#  ifdef PIPEPROCS
		started = kbd_stop();
#  endif
		/*
		 * Yuk!  This doesn't deal with all cases, we really need a
		 * standard jove input routine that's lower than kbd_getch so
		 * that this can use it.  The code that this replaces was even
		 * more ugly.  What about nonblocking reads? -- MM.
		 */
#  ifdef NONBLOCKINGREAD
		setblock(YES);	/* turn blocking on (in case it was off) */
#  endif
		for (;;) {
			c = 'n';
			if (read(0, (UnivPtr) &c, sizeof(c)) < 0) {
				switch (errno) {
				case EINTR:
#  ifdef MINT
#  if EWOULDBLOCK != EINTR	/* aliases in System Vr4 */
				case EWOULDBLOCK:
#  endif
#  else
#  if EWOULDBLOCK != EAGAIN	/* aliases in System Vr4 */
				case EWOULDBLOCK:
#  endif
				case EAGAIN:
#  endif
				continue;
				}
			}
			break;
		}
#  ifdef PIPEPROCS
		if (started)
			kbd_strt();
#  endif /* PIPEPROCS */
# endif /* UNIX */
# ifdef MSDOS
		c = getrawinchar();
# endif /* MSDOS */
		message(NullStr);
#endif /* !WIN32 */
		if (c != 'y') {
			redisplay();
			errno = save_errno;
			return SIGRESVALUE;
		}
	}
	DisabledRedisplay = YES;
#ifndef MAC
	UnsetTerm(NO);
#endif
#ifdef PIPEPROCS
	kbd_kill();		/* kill the keyboard process */
#endif
#ifdef RECOVER
	if (code != 0) {
		static bool	Crashing = NO;	/* we are in the middle of crashing */

		if (!Crashing) {
			Crashing = YES;
			lsave();
			SyncRec();
			writef("JOVE CRASH!! (code %d; last errno %d)\n",
				code, save_errno);
			if (ModBufs(YES)) {
				writef("Your buffers have been saved.\n");
				writef("Use \"jove -r\" to have a look at them.\n");
				DelTmps = NO;	/* Don't delete anymore. */
			} else {
				writef("No buffers needed saving: you didn't lose any work.\n");
			}
		} else {
			writef("\r\nYou may have lost your work!\n");
		}
	}
#endif /* RECOVER */
	flushscreen();
	if (DelTmps) {
		tmpremove();
#ifdef RECOVER
		recremove();
#endif /* RECOVER */
	}
#ifdef UNIX
	if (code != 0 && code != SIGHUP)
		abort();
# ifdef USE_EXIT
	exit(0);
# else
	_exit(0);
# endif
#else /* !UNIX */
	exit(0);
#endif /* !UNIX */
	/*NOTREACHED*/
}

private char	smbuf[20],
		*bp = smbuf;
private int	nchars = 0;

#ifdef NONBLOCKINGREAD

# include <fcntl.h>

private void
setblock(on)	/* turn blocking on or off */
bool	on;
{
	static int blockf, nonblockf;
	static bool	first = YES;

	if (first) {
		int flags;

		first = NO;
		if ((flags = fcntl(0, F_GETFL, 0)) == -1)
			finish(SIGHUP);
# ifdef O_NONBLOCK	/* POSIX form */
		blockf = flags & ~O_NONBLOCK;	/* make sure O_NONBLOCK is off */
		nonblockf = flags | O_NONBLOCK;	/* make sure O_NONBLOCK is on */
# else	/* pre-POSIX form */
		blockf = flags & ~O_NDELAY;	/* make sure O_NDELAY is off */
		nonblockf = flags | O_NDELAY;	/* make sure O_NDELAY is on */
# endif
	}
	if (fcntl(0, F_SETFL, on ? blockf : nonblockf) == -1)
		finish(SIGHUP);
}

#endif /* NONBLOCKINGREAD */

/* To optimize screen refreshing, we try to detect if there is pending input.
 * If there is, we defer screen updating, hoping that when we eventually
 * do an update it will be more efficient.  To implement this, we use
 * charp to poll for pending input (from any source but macro body).
 * "InputPending" records the last value returned by charp, or what
 * was known by kbd_getch or kbd_ungetch.  Note that the kbd_* routines
 * only consider keyboard input, but charp considers other sources of
 * input.  These are the only routines that should set InputPending
 * (currently, a fudge to redisplay for the mac also sets it --
 * this should be fixed).
 *
 * This heuristic confuses the user if a command takes a long time:
 * the screen may be "frozen" in an inaccurate state until the command
 * completes.  The variable "SlowCmd" is a count of the nesting of slow
 * commands.  If it is positive, display updating is not pre-empted.
 * The macros PreEmptOutput() and CheapPreEmptOutput() implement the tests.
 */

int	SlowCmd = 0;	/* depth of nesting of slow commands */

bool	InputPending = NO;	/* is there input waiting to be processed? */

/* Inputp is used to jam a NUL-terminated string into JOVE's input stream.
 * It is used to feed each line of the joverc file, to fill in the default
 * make_cmd in compile-it, and to fill in the default i-search string.
 * To make this work, we prevent i-search and compile-it from using Inputp
 * when it is already in use.
 */
char	*Inputp = NULL;

/* kbd_ungetch must only be used to push back a character that
 * was just returned by kbd_getch.
 */
private ZXchar	kbdpeek = EOF;

void
kbd_ungetch(c)
ZXchar	c;
{
	InputPending = YES;
	kbdpeek = c;
}

ZXchar
kbd_getch()
{
	register ZXchar	c;

	if (kbdpeek != EOF) {
		c = kbdpeek;
		kbdpeek = EOF;
		InputPending = nchars > 0;
		return c;
	}
#if NCHARS != UCHAR_ROOF
	do {
#endif
		while (nchars <= 0) {
			bp = smbuf;
#ifdef MSDOS
			*bp = getrawinchar();
			nchars = 1;
#else /* !MSDOS */
# ifdef WIN32
			if (!charp()) {
				redisplay();
				flushscreen();
			}
			nchars = getInputEvents(smbuf, sizeof(smbuf));
# else /* !WIN32 */
#  ifdef PTYPROCS
			/* Get a character from the keyboard, first checking for
			   any input from a process.  Handle that first, and then
			   deal with the terminal input. */
			{
				fd_set	reads;
				int
					nfds,
					fd;

				bp = smbuf;
				for (;;) {
					while (procs_to_reap)
							reap_procs();	/* synchronous process reaping */
					reads = global_fd;
					InSlowRead = YES;
					nfds = select(global_maxfd,
						&reads, (fd_set *)NULL, (fd_set *)NULL,
						(struct timeval *)NULL);
					InSlowRead = NO;
					if (nfds >= 0)
						break;

					if (errno != EINTR) {
						complain("\rerror in select: %s", strerror(errno));
						/* NOTREACHED */
					}
				}

				if (FD_ISSET(0, &reads)) {
					do {
						nchars = read(0, (UnivPtr) smbuf, sizeof(smbuf));
					} while (nchars < 0 && errno == EINTR);
					if (nchars <= 0)
						finish(SIGHUP);
					nfds -= 1;
				}
				for (fd=1; nfds != 0; fd += 1) {
					if (FD_ISSET(fd, &reads)) {
						nfds -= 1;
						read_pty_proc(fd);
						if (UpdModLine)
							redisplay();
					}
				}
			}
#  else /* !PTYPROCS */
#   ifdef PIPEPROCS
			if (NumProcs > 0) {
				/* Handle process input until kbd input arrives */
				struct header	header;
				size_t	n;

				InSlowRead = YES;
				n = f_readn(ProcInput, (char *) &header, sizeof(header));
				InSlowRead = NO;

				if (n != sizeof(header)) {
					raw_complain("\r\nError reading kbd process, expected %d, got %d bytes", sizeof header, n);
					finish(SIGHUP);
				}
				if (header.pid == kbd_pid) {
					/* data is from the keyboard process */
					nchars = f_readn(ProcInput, smbuf, (size_t)header.nbytes);
					if (nchars != header.nbytes) {
						raw_complain("\r\nError reading kbd process, expected %d, got %d bytes.", header.nbytes, nchars);
						finish(SIGHUP);
					}
				} else {
					/* data is from an interactive process */
					read_pipe_proc(header.pid, header.nbytes);
					if (NumProcs == 0)
						(void) kbd_stop();
					if (UpdModLine)
						redisplay();
				}
			} else /*...*/
#   endif /* PIPEPROCS */
			/*...*/ {
				do {
#   ifdef UNIX
					InSlowRead = YES;
#   endif
					nchars = read(0, (UnivPtr) smbuf, sizeof smbuf);
#   ifdef UNIX
					InSlowRead = NO;
#   endif
				} while (nchars < 0 && errno == EINTR);
				if (nchars <= 0)
					finish(SIGHUP);
			}
#  endif /* !PTYPROCS */
# endif /* !WIN32 */
#endif /* !MSDOS */
		}
		c = ZXRC(*bp++);
#if !defined(PCNONASCII) && !defined(MAC)	/* if not done elsewhere */
		if ((c & 0200) && MetaKey) {
			*--bp = c & ~0200;
			nchars += 1;
			c = ESC;
		}
#endif /* !defined(PCNONASCII) && !defined(MAC) */
		InputPending = --nchars > 0;
#if NCHARS != UCHAR_ROOF
	} while (c >= NCHARS);	/* discard c if it is a bad char */
#endif
	return c;
}

/* Returns YES if a character waiting (excluding macro body) */

bool
charp()
{
	if (InJoverc != 0 || kbdpeek != EOF || nchars > 0 || Inputp != NULL)
		return InputPending = YES;
#ifdef FIONREAD
	{
		/*
		 * Some manual pages, notably SunOS4.1.3 say 'c' should be
		 * 'long', but that's a lie -- it's an 'int' according to all
		 * kernels I've seen (including SunOS4.1.3) and most other
		 * manual pages.  At any rate, 'int' works correctly on 32- and
		 * 64-bit architectures, whereas long breaks on the 64
		 * bitters. -- MM.
		 */
		int c;

		if (ioctl(0, FIONREAD, (UnivPtr) &c) == -1)
			c = 0;
		return InputPending = c > 0;
	}
#else /* !FIONREAD */
# ifdef NONBLOCKINGREAD
	setblock(NO);		/* turn blocking off */
	nchars = read(0, (UnivPtr) smbuf, sizeof smbuf);	/* Is anything there? */
	setblock(YES);		/* turn blocking on */
	bp = smbuf;			/* make sure bp points to it */
	return InputPending = nchars > 0;	/* just say we found something */
# else /* !NONBLOCKINGREAD */
#  ifdef USE_SELECT
	{
		struct timeval	timer;
		fd_set	readfds;

		timer.tv_sec = 0;
		timer.tv_usec = 0;
		FD_ZERO(&readfds);
		FD_SET(0, &readfds);
		return InputPending = select(1,
			&readfds, (fd_set *)NULL, (fd_set *)NULL,
			&timer) > 0;
	}
#  else /* !USE_SELECT */
#   ifdef MSDOS
	return InputPending = rawkey_ready();
#   else /* !MSDOS */
#    ifdef MAC
	return InputPending = rawchkc();
#    else
#     ifdef WIN32
	return InputPending = inputEventWaiting(0);
#     else
	return InputPending = NO;	/* who knows? */
#     endif /* !WIN32 */
#    endif /* !MAC */
#   endif /* !MSDOS */
#  endif /* !USE_SELECT */
# endif /* !NONBLOCKINGREAD */
#endif /* !FIONREAD */
}

/*
 * Tries to pause for delay/10 seconds OR until a character is typed at the
 * keyboard.  This works well on systems with select() and not so well on the
 * rest.
 */

#ifdef MAC
# include <LoMem.h>	/* defines Ticks */
#endif

void
SitFor(delay)
int	delay;
{
#ifdef MAC
	long
		start,
		end;

	Keyonly = YES;
	redisplay();
	start = Ticks;

	end = start + delay * 6;
	do ; while (!charp() && Ticks < end);

#else /* !MAC */

# ifndef MSDOS
	if (!charp()) {
#  ifdef USE_SELECT
		struct timeval	timer;
		fd_set	readfds;

		/* So messages that aren't error messages don't
		 * hang around forever.
		 * Gross that I had to snarf this from getch()
		 */
		if (!UpdMesg && !Asking && mesgbuf[0] && !stickymsg)
			message(NullStr);
		redisplay();

		timer.tv_sec = (delay / 10);
		timer.tv_usec = (delay % 10) * 100000;
		FD_ZERO(&readfds);
		FD_SET(0, &readfds);
		(void) select(1,
			&readfds, (fd_set *)NULL, (fd_set *)NULL,
			&timer);
#  else /* ! USE_SELECT */
#   ifdef WIN32
		redisplay();
		inputEventWaiting(delay*100);
#   else /* ! WIN32 */
		/* Pause by spitting NULs at the terminal.  Ugh! */
		static const int cps[] = {
			0,
			5,
			7,
			11,
			13,
			15,
			20,
			30,
			60,
			120,
			180,
			240,
			480,
			960,
			1920,
			1920,
		};
		register int	nchars,
				check_cnt;

		nchars = (delay * cps[ospeed]) / 10;
		check_cnt = ScrBufSize;
		redisplay();
		if (!NP) {
			while ((--nchars > 0) && !InputPending) {
				scr_putchar(PC);
				if (--check_cnt == 0) {
					check_cnt = ScrBufSize;
					(void) charp();
				}
			}
		}
#   endif /* !WIN32 */
#  endif /* !USE_SELECT */
	}
# else /* MSDOS */
	/* All time representations must wrap eventually.
	 * Since all delays are much less than a minute, we represent
	 * time as hundredths of a second past the minute we start.
	 * NOTE: this is a busy wait.  I know of no alternative.
	 */
	int	start,
		now,
		end;
	struct dostime_t tc;

	redisplay();
	_dos_gettime(&tc);
	start = tc.second * 100 + tc.hsecond;
	end = start + delay * 10;
	for (;;)  {
		if (charp())
			break;
		_dos_gettime(&tc);
		now = tc.second * 100 + tc.hsecond;
		if (now < start)
			now += 60 * 100;	/* must be in next minute */
		if (now >= end)
			break;
	}
# endif /* MSDOS */
#endif /* !MAC */
}

#define WAITCHAR_CURSOR_DOWN	1	/* during slow keying, cursor is after displayed prefix */

private char
	key_strokes[100],
	*keys_p = key_strokes;

private bool	in_ask_ks;

private volatile bool	slow_keying = NO;	/* for waitchar() */

void
cmd_sync()
{
	if (this_cmd != ARG_CMD) {
		clr_arg_value();
		last_cmd = this_cmd;
		slow_keying = NO;
		in_ask_ks = NO;
		keys_p = key_strokes;
	}
}

ZXchar
ask_ks()
{
	in_ask_ks = YES;
	keys_p = key_strokes;
	return waitchar();
}

void
add_stroke(c)
ZXchar	c;
{
	if (keys_p < &key_strokes[sizeof (key_strokes) - 1])
		*keys_p++ = c;
}

void
pp_key_strokes(buffer, size)
char	*buffer;
size_t	size;
{
	char
		*buf_end = buffer + size - 1,
		*kp = key_strokes;

	*buffer = '\0';
	while (kp != keys_p) {
		swritef(buffer, (size_t) (buf_end-buffer), "%p ", *kp++);
		buffer += strlen(buffer);
	}
}

private void
ShowKeyStrokes()
{
	char	buffer[100];

	slow_keying = YES;
	pp_key_strokes(buffer, sizeof (buffer));
	f_mess(in_ask_ks? ": %f %s" : "%s", buffer);
#ifdef WAITCHAR_CURSOR_DOWN
	Asking = YES;
	AskingWidth = strlen(mesgbuf);
#endif
}

#define N_SEC	1	/* will be precisely 1 second on 4.2 */

ZXchar
waitchar()
{
	ZXchar	c;
#ifdef WAITCHAR_CURSOR_DOWN
	bool	oldAsking;
	int	oldAskingWidth;
#endif

	/* short circuit, if we can */
	if (InJoverc || (!Interactive && in_macro()) || InputPending)
		return getch();

#ifdef WAITCHAR_CURSOR_DOWN
	oldAsking = Asking;
	oldAskingWidth = AskingWidth;
#endif

#ifdef MAC
	Keyonly = YES;
#endif
	if (!slow_keying) {
		/* not yet slow_keying */
#ifdef UNIX
		/* set up alarm */
		InWaitChar = YES;
		(void) alarm((unsigned) N_SEC);
#else /* !UNIX */
# ifdef WIN32
		if (!charp()) {
			if ((slow_keying = !inputEventWaiting(N_SEC*1000))) {
				ShowKeyStrokes();
			}
		}
# else /* !WIN32 */
		/* NOTE: busy wait (until char typed or timeout)! */
		time_t sw = N_SEC + time((time_t *)NULL);

		while (!slow_keying && !charp()) {
			if (time((time_t *)NULL) > sw) {
				/* transition to slow_keying */
#  ifdef MAC
				menus_off();
#  endif
				ShowKeyStrokes();
			}
		}
# endif /* !WIN32 */
#endif /* !UNIX */
#ifdef WAITCHAR_CURSOR_DOWN
	} else {
		/* Already slow_keying: presume bottom line has old keystrokes.
		 * Tell refresh(?) to place cursor at end of them.
		 */
		Asking = YES;
		AskingWidth = strlen(mesgbuf);
#endif
	}
	c = getch();
	if (slow_keying) {
		ShowKeyStrokes();
#ifdef UNIX
	} else {
		/* not yet slow_keying: tear down alarm */
		InWaitChar = NO;
		SetClockAlarm(YES);
#endif
	}

#ifdef WAITCHAR_CURSOR_DOWN
	Asking = oldAsking;
	AskingWidth = oldAskingWidth;
#endif
	return c;
}

private void
SetTerm()
{
#ifdef IBMPCDOS
	pcSetTerm();
#endif
	ttysetattr(YES);
#ifdef TERMCAP
	putpad(TI, 1);	/* Cursor addressing start */
	putpad(VS, 1);	/* Visual start */
	putpad(KS, 1);	/* Keypad mode start */
# ifdef MOUSE
	MouseOn();
# endif
#endif
#ifdef UNIX
	(void) chkmail(YES);	/* force it to check so we can be accurate */
#endif
}

private void
UnsetTerm(WarnUnwritten)
bool	WarnUnwritten;
{
#ifdef TERMCAP
# ifdef ID_CHAR
	INSmode(NO);
# endif /* ID_CHAR */
# ifdef MOUSE
	MouseOff();
# endif
	putpad(KE, 1);
	putpad(VE, 1);
	Placur(ILI, 0);
	putpad(CE, 1);
	putpad(TE, 1);
#else /* !TERMCAP */
	Placur(ILI, 0);
	clr_eoln();
#endif /* !TERMCAP */
	flushscreen();
#ifdef MSDOS
	pcUnsetTerm();
#endif
	ttysetattr(NO);
	if (WarnUnwritten && ModBufs(NO))
		raw_complain("[There are modified buffers]");
}

#ifdef JOB_CONTROL
void
PauseJove()
{
	UnsetTerm(YES);
#ifdef MINT
	(void) kill(getpid(), SIGTSTP);
#else
	(void) kill(0, SIGTSTP);
#endif /* MiNT */
	SetTerm();
# ifdef WINRESIZE
	/* Some systems (eg System V Release 4) don't give us SIGWINCHes
	 * that happen while we are away.
	 */
	ResizePending = YES;
# endif
	ClAndRedraw();
}
#endif /* JOB_CONTROL */

#ifdef SUBSHELL

# ifndef MSDOS
void
jcloseall()
{
	tmpclose();
#  ifdef RECOVER
	recclose();
#  endif
#  ifdef IPROCS
	closeiprocs();
#  endif
}
# endif /* !MSDOS */

void
Push()
{
# ifdef MSDOS_PROCS
#  ifdef MSDOS
	UnsetTerm(YES);
	if (spawnl(0, Shell, basename(Shell), (char *)NULL) == -1)
		s_mess("[Spawn failed %d]", errno);
	SetTerm();
#   ifdef WINRESIZE
	/* Some systems (eg System V Release 4) don't give us SIGWINCHes
	 * that happen while we are away.
	 */
	ResizePending = YES;
#   endif
	ClAndRedraw();
	getCWD();
#  else /* !MSDOS */
#   ifdef WIN32
	STARTUPINFO startinfo = { sizeof(STARTUPINFO) };
	PROCESS_INFORMATION procinfo;
	CreateProcess(Shell, NULL, NULL, NULL,
		FALSE, CREATE_NEW_CONSOLE,
		NULL, NULL,
		&startinfo, &procinfo);
#   endif /* WIN32 */
#  endif /* !MSDOS */
# else /* !MSDOS_PROCS */
	/* UNIX, or something like it */
	SIGHANDLERTYPE	old_int = setsighandler(SIGINT, SIG_IGN);
	int	forkerr = 0;
#  ifdef PIPEPROCS
	bool	started = kbd_stop();
#  endif

	UnsetTerm(YES);
	switch (ChildPid = fork()) {
	case -1:
		/* parent, fork failed */
		forkerr = errno;
		break;

	default:
		/* parent, fork worked */
		dowait((wait_status_t *) NULL);
		break;

	case 0:
		/* child */
		/* (void) setsighandler(SIGTERM, SIG_DFL); */
		(void) setsighandler(SIGINT, SIG_DFL);
		jcloseall();
		/* note that curbuf->bfname may be NULL */
		execl(Shell, basename(Shell), "-is", pr_name(curbuf->b_fname, NO),
			(char *)NULL);
		raw_complain("[Execl failed: %s]", strerror(errno));
		_exit(1);
		/*NOTREACHED*/
	}
	SetTerm();
#  ifdef WINRESIZE
	/* Some systems (eg System V Release 4) don't give us SIGWINCHes
	 * that happen while we are away.
	 */
	ResizePending = YES;
#  endif
	ClAndRedraw();
	(void) setsighandler(SIGINT, old_int);
	SetClockAlarm(NO);
#  ifdef PIPEPROCS
	if (started)
		kbd_strt();
#  endif
	if (forkerr != 0)
		complain("[Fork failed: %s]", strerror(errno));
# endif /* !MSDOS_PROCS */
}

#endif /* SUBSHELL */

/* adjust the tty to reflect possible change to JOVE variables */
void
tty_adjust()
{
	ttysetattr(YES);
#ifdef MOUSE
	MouseOn();	/* XtermMouse might have changed */
#endif
}

bool	Interactive = NO;	/* True when we invoke with the command handler? */

ZXchar
	peekchar = EOF,	/* holds pushed-back getch output */
	LastKeyStruck;	/* used by SelfInsert and friends */

bool
	MetaKey = NO;		/* VAR: this terminal has a meta key */

void
Ungetc(c)
ZXchar	c;
{
	peekchar = c;
}

ZXchar
getch()
{
	register ZXchar	c;

#ifndef MINT
	if (Inputp != NULL) {
		if ((c = ZXC(*Inputp++)) != '\0')
			return LastKeyStruck = c;
		Inputp = NULL;
	}
#else
	/* BUG? */
	/* ok, I don't understand what was going wrong with the code
	* above. Maybe nothing. But I compiled jove.c with -O2 and debugged
	* it with gdb.
	* After if ((c = ZXC(*Inputp++)) != '\0') we did NOT jump to the next
	* line - we didn't read the end character - but to the very
	* end of this function. Ok, there we have the same statement again
	* so maybe that's ok. But I'm a little bit confused about that
	* behavior. And because I had a bug in findcom, I rewrote this part.
	*/
	if (Inputp != NULL) {
		c = *Inputp++;
		c = ZXC(c);
		if (c != '\0') {
			LastKeyStruck = c;
			return (LastKeyStruck);
		}
		Inputp = NULL;
	}
#endif

	if (InJoverc) {
		/* somethings wrong if Inputp runs out while
		   we're reading a .joverc file. */
		complain("[command line too short]");
	}

#ifdef RECOVER
	if (ModCount >= SyncFreq) {
		ModCount = 0;
		SyncRec();
	}
#endif /* RECOVER */

	if ((c = peekchar) != EOF) {
		/* got input from pushback */
		peekchar = EOF;
	} else {
		if (!Interactive && (c = mac_getc()) != EOF) {
			/* got input from macro */
		} else {
			/* So messages that aren't error messages don't
			 * hang around forever.
			 * Note: this code is duplicated in SitFor()!
			 */
			if (!UpdMesg && !Asking && mesgbuf[0] != '\0' && !stickymsg)
				message(NullStr);
			redisplay();
			c = kbd_getch();
			if (!Interactive && InMacDefine)
				mac_putc(c);
		}
		add_stroke(c);
	}
	return LastKeyStruck = c;
}

#if defined(SUBSHELL) && defined(RECOVER)
private void
dorecover()
{
	char	Recover[FILESIZE];	/* path to recover program (in LibDir) */

	/* Since recover is a normal cooked mode program, reset the terminal */
	UnsetTerm(NO);
# ifdef PIPEPROCS
	kbd_kill();		/* kill the keyboard process */
# endif
	swritef(Recover, sizeof(Recover), "%s/recover", LibDir);
	execl(Recover, "recover", "-d", TmpDir, (char *) NULL);
	writef("%s: execl failed! %s\n", Recover, strerror(errno));
	flushscreen();
	_exit(-1);
	/* NOTREACHED */
}
#endif /* defined(SUBSHELL) && defined(RECOVER) */

void
ShowVersion()
{
#ifndef MINT
	s_mess("Jonathan's Own Version of Emacs (%s)", jversion);
#else
	s_mess("Jonathan's Own Version of Emacs (%s) - ported by Hans Streibel", jversion);
#endif
}

private void
UNIX_cmdline(argc, argv)
int	argc;
char	*argv[];
{
	int	lineno = 0,
		nwinds = 1;
	char	*pattern = NULL;
	Buffer	*b;

	while (argc > 1) {
		switch (argv[1][0]) {
		case '+':
			if ('0' <= argv[1][1] && argv[1][1] <= '9') {
				(void) chr_to_int(&argv[1][1], 10, NO, &lineno);
				break;
			} else switch (argv[1][1]) {
			case '\0':
				/* goto end of file just like some people's favourite editor */
				lineno = -1;
				break;
			case '/':	/* search for pattern */
				/* check if syntax is +/pattern or +/ pattern */
				if (argv[1][2] != 0) {
					pattern = &argv[1][2];
				} else {
					argv += 1;
					argc -= 1;
					if (argv[1] != 0)
						pattern = &argv[1][0];
				}
				break;
			default:
				error("Invalid switch %s",argv[1]);
				break;
			}
			break;
		case '-':
			switch (argv[1][1]) {
			case 'd':	/* Ignore current directory path */
			case 'l':	/* Ignore libdir path */
			case 's':	/* Ignore sharedir path */
				argv += 1;
				argc -= 1;
				break;

			case 'J':	/* Ignore jove.rc in SHAREDIR */
			case 'j':	/* Ignore ~/.joverc */
				break;
			case 'p':	/* parse errors in file */
				argv += 1;
				argc -= 1;
				if (argv[1] != NULL) {
					SetBuf(do_find(curwind, argv[1], YES, YES));
					ErrParse();
					nwinds = 0;
				}
				break;
			case 't':	/* find tag */
				/* check if syntax is -tTag or -t Tag */
				if (argv[1][2] != '\0') {
					find_tag(&(argv[1][2]), YES);
				} else {
					argv += 1;
					argc -= 1;
					if (argv[1] != NULL)
						find_tag(argv[1], YES);
				}
				break;

			case 'w':	/* multiple windows */
				if (argv[1][2] == '\0')
					nwinds += 1;
				else {
					int	n;

					(void) chr_to_int(&argv[1][2], 10, NO, &n);
					nwinds += -1 + n;
				}
				(void) div_wind(curwind, nwinds - 1);
				break;
			default:
				error("Invalid switch %s",argv[1]);
				break;
			}
			break;
		default:
			{
			bool	force = (nwinds > 0 || lineno != 0 || pattern != NULL);

			minib_add(argv[1], force);
			b = do_find(nwinds > 0 ? curwind : (Window *) NULL,
				    argv[1], force, YES);
			if (force) {
				SetABuf(curbuf);
				SetBuf(b);
				if (lineno > 0)
					SetLine(next_line(curbuf->b_first, lineno - 1));
				else if (lineno == -1)
					SetLine(curbuf->b_last);
				if (pattern != NULL) {
					Bufpos	*bufp;

					if ((bufp = dosearch(pattern, FORWARD, UseRE)) != NULL
					|| (bufp = dosearch(pattern, BACKWARD, UseRE)) != NULL)
						SetDot(bufp);
					else
						complain("Couldn't match pattern in file.");
				}
				if (nwinds > 1)
					NextWindow();
				if (nwinds > 0)
					nwinds -= 1;
			}
			lineno = 0;
			pattern = NULL;
			}
			break;
		}
		argv += 1;
		argc -= 1;
	}
}

#ifdef STDARGS
void
error(const char *fmt, ...)
#else
/*VARARGS1*/ void
error(fmt, va_alist)
	const char	*fmt;
	va_dcl
#endif
{
	va_list	ap;

	if (fmt) {
		va_init(ap, fmt);
		format(mesgbuf, sizeof mesgbuf, fmt, ap);
		va_end(ap);
		UpdMesg = YES;
	}
	rbell();
	longjmp(mainjmp, JMP_ERROR);
}

#ifdef STDARGS
void
complain(const char *fmt, ...)
#else
/*VARARGS1*/ void
complain(fmt, va_alist)
	const char	*fmt;
	va_dcl
#endif
{
	va_list	ap;

	if (fmt) {
		va_init(ap, fmt);
		format(mesgbuf, sizeof mesgbuf, fmt, ap);
		va_end(ap);
		UpdMesg = YES;
	}
	rbell();
	longjmp(mainjmp, JMP_COMPLAIN);
}

/* format and display a message without using the normal display mechanisms */

#ifdef STDARGS
void
raw_complain(const char *fmt, ...)
#else
/*VARARGS1*/ void
raw_complain(fmt, va_alist)
	const char	*fmt;
	va_dcl
#endif
{
	char	buf[MESG_SIZE];
	va_list	ap;

	va_init(ap, fmt);
	format(buf, sizeof(buf) - 2, fmt, ap);
	va_end(ap);
	strcat(buf, "\r\n");	/* \r *may* be redundant */
	(void) write(2, (UnivConstPtr)buf, strlen(buf));
}

#ifdef STDARGS
void
confirm(const char *fmt, ...)
#else
/*VARARGS1*/ void
confirm(fmt, va_alist)
	const char	*fmt;
	va_dcl
#endif
{
	va_list	ap;

	va_init(ap, fmt);
	format(mesgbuf, sizeof mesgbuf, fmt, ap);
	va_end(ap);
	if (!yes_or_no_p("%s", mesgbuf))
		longjmp(mainjmp, JMP_COMPLAIN);
}

/* Recursive edit.
 * Guarantee: current buffer will still be current and
 * it will be in the current window.  If not, complain!
 */

int	RecDepth = 0;

void
Recur()
{
	Buffer	*b = curbuf;
	Mark	*m;

	m = MakeMark(curline, curchar);

	RecDepth += 1;
	UpdModLine = YES;
	DoKeys(NO);	/* NO means not first time */
	UpdModLine = YES;
	RecDepth -= 1;
	if (!valid_bp(b))
		complain("Buffer gone!");
	tiewind(curwind, b);
	SetBuf(b);
	if (!is_an_arg())
		ToMark(m);
	DelMark(m);
}

private int	iniargc;	/* main sets these for DoKeys() */
private char	**iniargv;

private void
DoKeys(firsttime)
bool	firsttime;
{
	jmp_buf	savejmp;

	push_env(savejmp);

	switch (setjmp(mainjmp)) {
	case 0:
		if (firsttime)
			UNIX_cmdline(iniargc, iniargv);
		break;

	case JMP_QUIT:
		if (RecDepth == 0) {
			if (ModMacs()) {
				rbell();
				if (!yes_or_no_p("Some MACROS haven't been saved; leave anyway? "))
					break;
			}
			if (ModBufs(NO)) {
				rbell();
				if (!yes_or_no_p("Some buffers haven't been saved; leave anyway? "))
					break;
			}
#ifdef IPROCS
			if (!KillProcs())
				break;	/* user chickened out */
#endif
		}
		pop_env(savejmp);
		return;

	case JMP_ERROR:
		getDOT();	/* God knows what state linebuf was in */
		/*FALLTHROUGH*/
	case JMP_COMPLAIN:
		{
		gc_openfiles();		/* close any files we left open */
		stickymsg = YES;
		unwind_macro_stack();
		Asking = NO;
		curwind->w_bufp = curbuf;
		DisabledRedisplay = NO;
		SlowCmd = 0;
		redisplay();
		break;
		}
	}

	this_cmd = last_cmd = OTHER_CMD;

	for (;;) {
#ifdef MAC
		setjmp(auxjmp);
#endif
		cmd_sync();
#ifdef MAC
		HiliteMenu(0);
		EventCmd = NO;
		menus_on();
#endif
		dispatch(getch());
	}
}

private char **
scanvec(args, str)
register char	**args,
		*str;
{
	while (*args) {
		if (strcmp(*args, str) == 0)
			return args;
		args += 1;
	}
	return NULL;
}

#ifdef WINRESIZE
/*ARGSUSED*/
SIGRESTYPE
win_reshape(junk)
int	junk;	/* passed in when invoked by a signal; of no interest */
{
	int save_errno = errno;	/* Subtle, but necessary! */

	ResizePending = YES;
#ifdef UNIX
	resetsighandler(SIGWINCH, win_reshape);
	if (InSlowRead) {
		/* needed because of stupid BSD restartable I/O */
		InSlowRead = NO;
		redisplay();
		InSlowRead = YES;
	}
#else
	redisplay();
#endif
	errno = save_errno;
	return SIGRESVALUE;
}
#endif /* WINRESIZE */

private bool
carefulcpy(to, from, maxsize, mess, raw)
char	*to,*from;
size_t	maxsize;
char	*mess;
bool	raw;
{
	if (from != NULL) {
		char	*ugh;

		if (strlen(from) >= maxsize)
			ugh = "too long";
		else if (*from == '\0')
			ugh = "empty";
		else {
			strcpy(to, from);
			return YES;
		}
		if (raw) {
			raw_complain("\r\n%s %s", mess, ugh);
		} else {
			swritef(mesgbuf, sizeof mesgbuf, "%s %s", mess, ugh);
			message(mesgbuf);
		}
	}
	return NO;
}

private void
dojovercs(dosys, dousr)
bool	dosys;
bool	dousr;
{
	char	Joverc[FILESIZE];
#ifdef MINT
	char *envptr;
#endif

	if (dosys) {
		swritef(Joverc, sizeof(Joverc), "%s/jove.rc", ShareDir);
		(void) joverc(Joverc);	/* system wide jove.rc */
	}

	if (dousr) {
#ifdef MSFILESYSTEM
		/* We don't want to run the same rc file twice */
		if (!dosys || strcmp(HomeDir, ShareDir) != 0) {
			swritef(Joverc, sizeof(Joverc), "%s/jove.rc", HomeDir);
			(void) joverc(Joverc);	/* jove.rc in home directory */
		}
#else
# ifndef MINT
		swritef(Joverc, sizeof(Joverc), "%s/.joverc", HomeDir);
		(void) joverc(Joverc);	/* .joverc in home directory */
# else
		envptr = getenv("JOVERC");
		if( envptr ) {
			strcpy(Joverc, envptr);
			fixpath(Joverc);
			(void) joverc(Joverc);
		} else {
			struct stat statbuf;
			int ret;
			swritef(Joverc, sizeof(Joverc), "%s/.joverc", HomeDir);
			ret = stat(Joverc, &statbuf);
			if( ret || (statbuf.st_mode&S_IFDIR) ) {
				swritef(Joverc, sizeof(Joverc), "%s/jove.rc", HomeDir);
			}
			(void) joverc(Joverc);
		}
#endif
#endif
	}
}



int
main(argc, argv)
int	argc;
char	*argv[];
{
	char	**argp;
#ifdef MINT
	char *envptr;
#endif

#ifdef AUTO_BUFS
	/* allocate these usually static buffers on the stack:
	 * preserves addressability on some systems.
	 */
	char	s_iobuff[LBSIZE],
		s_genbuf[LBSIZE],
		s_linebuf[LBSIZE];

	iobuff = s_iobuff;
	genbuf = s_genbuf;
	linebuf = s_linebuf;
#endif

#ifdef MINT
	__default_mode__ |= _IOBIN;
#endif

#ifdef MAC
	MacInit();		/* initializes all */
	argc = getArgs(&argv);
#endif

#if defined(__WATCOMC__) && defined(FAR_LINES)
	/* Watcom C under DOS won't grow the near heap after any far
	 * allocation, so we must bump it up to the full 64K now.
	 */
	_heapgrow();
#endif

	iniargc = argc;
	iniargv = argv;

	if (setjmp(mainjmp)) {
		ttysetattr(NO);
		writef("\nAck! I can't deal with error \"%s\" now.\n", mesgbuf);
		flushscreen();
		return 1;
	}

#if defined(USE_CTYPE) && !defined(NO_SETLOCALE)
	/* make ctype reflect "native environment" */
	locale_adjust();
#endif

	getTERM();	/* Get terminal. */
#ifndef MAC	/* no environment in MacOS */
	if (getenv("METAKEY"))
		MetaKey = YES;
#endif
	ttysetattr(YES);
	ttsize();

#ifdef UNIX
# ifdef WINRESIZE
	(void) setsighandler(SIGWINCH, win_reshape);
# endif
#endif

#ifdef MAC
	InitEvents();
#endif

	d_cache_init();		/* initialize the disk buffer cache */

	make_scr();
	flushscreen();	/* kludge: prevent interleaving output with diagnostic */
	mac_init();	/* Initialize Macros */
	winit();	/* Initialize Window */
#ifdef PTYPROCS
# ifdef SIGCHLD
	(void) setsighandler(SIGCHLD, sigchld_handler);
# endif
#endif
#ifdef USE_SELECT
	FD_ZERO(&global_fd);
	FD_SET(0, &global_fd);
	global_maxfd = 1;
#endif
	buf_init();

	if ((argp = scanvec(argv, "-d")) != NULL && chkCWD(argp[1]))
		setCWD(argp[1]);
	else
		getCWD();	/* After we setup curbuf in case we have to getwd() */

#ifdef MAC
	HomeDir = gethome();
#else /* !MAC */
# ifdef MINT
	envptr = getenv("HOME");
	if( !envptr )
		HomeDir = "/";
	else {
		HomeDir = emalloc((size_t)(strlen(envptr)+1+10));	/* c:/ -> /dev/c + Reserve */
		strcpy(HomeDir, envptr);
		fixpath(HomeDir);
	}
# else
	HomeDir = getenv("HOME");
# endif
	if (HomeDir == NULL) {
# ifdef MSDOS
		HomeDir = copystr(pwd());	/* guess at current (initial) directory */
# else
#  ifdef WIN32
		/* Following are set up automatically by NT on logon. */
		char *homedrive = getenv("HOMEDRIVE");
		char *homepath = getenv("HOMEPATH");

		if (homedrive != NULL && homepath != NULL) {
			HomeDir = emalloc(strlen(homedrive) + strlen(homepath) + 1);
			strcpy(HomeDir, homedrive);
			strcat(HomeDir, homepath);
		} else {
			HomeDir = copystr(pwd());
		}
#  else /* !WIN32 */
		HomeDir = "/";
#  endif /* !WIN32 */
# endif /* !MSDOS */
	}
#endif /* !MAC */
	HomeLen = strlen(HomeDir);

	InitKeymaps();

	settout();	/* not until we know baudrate */
	SetTerm();

#ifndef MAC	/* no environment in MacOS */
	/* Handle overrides for ShareDir and LibDir.
	 * We take care to use the last specification.
	 * Even if we don't use LibDir, we accept it.
	 */
	 {
		char
			*so = getenv("JOVESHARE");
# ifdef NEED_LIBDIR
		char
			*lo = getenv("JOVELIB");
# endif

		for (argp = argv; argp[0] != NULL && argp[1] != NULL; argp++) {
			if (strcmp(*argp, "-s") == 0)
				so = *++argp;
# ifdef NEED_LIBDIR
			else if (strcmp(*argp, "-l") == 0)
				lo = *++argp;
			else if (strcmp(*argp, "-ls") == 0 || strcmp(*argp, "-sl") == 0)
				lo = so = *++argp;
# endif
		}
# ifdef MINT
		if (so != NULL) {
			if (!carefulcpy(ShareDir, so, sizeof(ShareDir)-9, "ShareDir", YES))
				finish(0);
			fixpath(ShareDir);
		}
# else
		if (so != NULL)
			if (!carefulcpy(ShareDir, so, sizeof(ShareDir)-9, "ShareDir", YES))
				finish(0);
# endif
# ifdef NEED_LIBDIR
#  ifdef MINT
		if (lo != NULL) {
			if (!carefulcpy(LibDir, lo, sizeof(LibDir)-9, "LibDir", YES))
				finish(0);
			fixpath(LibDir);
		}
#  else
		if (lo != NULL)
			if (!carefulcpy(LibDir, lo, sizeof(LibDir)-9, "LibDir", YES))
				finish(0);
#  endif
#  ifdef PIPEPROCS
		swritef(Portsrv, sizeof(Portsrv), "%s/portsrv", LibDir);
#  endif
# endif /* NEED_LIBDIR */
	}
#endif /* !MAC */

	ShowVersion();	/* but the 'carefulcpy's which follow might overwrite it */

	/* import the temporary file path from the environment
	   and fix the string, so that we can append a slash
	   safely	*/
#ifdef MSFILESYSTEM
	carefulcpy(TmpDir, getenv("TEMP"), sizeof(TmpDir), "TEMP", NO);
#endif
#if !defined(MAC) && !defined(MINT)	/* no environment in MacOS */
	carefulcpy(TmpDir, getenv("TMPDIR"), sizeof(TmpDir), "TMPDIR", NO);
#else	/* MINT */
	if( (envptr=getenv("TMP")) && *envptr )
		carefulcpy(TmpDir, envptr, sizeof(TmpDir), "TMP", NO);
	else if( (envptr=getenv("TMPDIR")) && *envptr )
		carefulcpy(TmpDir, envptr, sizeof(TmpDir), "TMPDIR", NO);
	else if( (envptr=getenv("TEMPDIR")) && *envptr )
		carefulcpy(TmpDir, envptr, sizeof(TmpDir), "TEMPDIR", NO);
#endif
#ifdef MINT
	fixpath(TmpDir);
#else
	{
		char	*cp = &TmpDir[strlen(TmpDir)];

		do ; while (cp != TmpDir && (*--cp == '/'
#ifdef MSFILESYSTEM
			|| *cp == '\\'
#endif
			));
		cp[1] = '\0';
	}
#endif

#ifdef SUBSHELL
# ifdef MSFILESYSTEM	/* ??? Is this the right test? */
	carefulcpy(Shell, getenv("COMSPEC"), sizeof(Shell), "COMSPEC", NO);
	/* SHELL, if present in DOS environment, will take precedence over COMSPEC */
# endif /* MSFILESYSTEM */
	carefulcpy(Shell, getenv("SHELL"), sizeof(Shell), "SHELL", NO);
# ifdef MINT
	fixpath(Shell);
# endif
#endif /* SUBSHELL */

#ifdef UNIX
	carefulcpy(Mailbox, getenv("MAIL"), sizeof(Mailbox), "MAIL", NO);
# ifdef MINT
	fixpath(Mailbox);
# endif
#endif

	dojovercs(scanvec(argv, "-J") == NULL, scanvec(argv, "-j") == NULL);

#if defined(SUBSHELL) && defined(RECOVER)
	if (scanvec(argv, "-r") != NULL)
		dorecover();
#endif

#ifdef UNIX
# ifndef DEBUGCRASH
	(void) setsighandler(SIGHUP, finish);
	(void) setsighandler(SIGINT, finish);
#  ifdef SIGBUS
	(void) setsighandler(SIGBUS, finish);
#  endif /* SIGBUS */
	(void) setsighandler(SIGSEGV, finish);
	(void) setsighandler(SIGPIPE, finish);
	/* ??? Why should we ignore SIGTERM? */
	/* (void) setsighandler(SIGTERM, SIG_IGN); */
# endif /* DEBUGCRASH */
	(void) setsighandler(SIGALRM, AlarmHandler);
	SetClockAlarm(NO);
#endif /* UNIX */
	ClAndRedraw();
	flushscreen();
	RedrawDisplay();	/* start the redisplay process. */
	DoKeys(YES);
	finish(0);
	/* NOTREACHED*/
}
