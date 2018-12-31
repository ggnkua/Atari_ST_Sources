/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

#include "jove.h"

#include "jctype.h"
#include "fp.h"
#include "re.h"
#include "disp.h"
#include "sysprocs.h"
#include "ask.h"
#include "delete.h"
#include "extend.h"
#include "fmt.h"
#include "insert.h"
#ifdef IPROCS
# include "iproc.h"
#endif
#include "marks.h"
#include "misc.h"
#include "move.h"
#include "proc.h"
#include "wind.h"

#include <signal.h>
#include <errno.h>

#ifdef MSDOS_PROCS
# include <io.h>
# ifndef MSC51
#  include <sys/stat.h>	/* for S_IWRITE and S_IREAD */
# endif
# include <process.h>
#endif /* WIN32 */

#ifdef POSIX_SIGS
# define SIGINTMASK_DECL	sigset_t sigintmask;
# define SIGINTMASK_INIT()	{ sigemptyset(&sigintmask); sigaddset(&sigintmask, SIGINT); }
# define SIGINT_BLOCK()	sigprocmask(SIG_BLOCK, &sigintmask, (sigset_t *)NULL)
# define SIGINT_UNBLOCK()	sigprocmask(SIG_UNBLOCK, &sigintmask, (sigset_t *)NULL)
#else /* !POSIX_SIGS */
# ifdef USE_SIGSET
#  define SIGINT_BLOCK()	sighold(SIGINT)
#  define SIGINT_UNBLOCK()	sigrelse(SIGINT)
# else /* !USE_SIGSET */
#  ifdef BSD_SIGS
#   define SIGINT_BLOCK()	sigsetmask(sigmask(SIGINT))
#   define SIGINT_UNBLOCK()	sigsetmask(0)
#  endif /* BSD_SIGS */
# endif /* !USE_SIGSET */
#endif /* !POSIX_SIGS */

/* This disgusting RE search string parses output from the GREP
   family, from the pdp11 compiler, pcc, and lint.  Jay (HACK)
   Fenlasen changed this to work for the lint errors. */
char	ErrFmtStr[256] = "^\\{\"\\|\\}\\([^:\"( \t]*\\)\\{\"\\, line \\|:\\|(\\} *\\([0-9][0-9]*\\)[:)]\
\\|::  *\\([^(]*\\)(\\([0-9]*\\))$\
\\|( \\([^(]*\\)(\\([0-9]*\\)) ),";	/* VAR: format string for parse errors */

struct error {
	Buffer		*er_buf;	/* Buffer error is in */
	LinePtr		er_mess,	/* Actual error message */
			er_text;	/* Actual error */
	int		er_char;	/* char pos of error */
	struct error	*er_prev,	/* List of errors */
			*er_next;
};

private struct error	*cur_error = NULL,
		*errorlist = NULL;

/* Eliminate any error records that contain dangling references to Lines.
 * We only eliminate error structs when either referent is recycled.
 * If it deleted, we keep it (dormant) in case it will be pasted back
 * into the same buffer.
 */

void
ChkErrorLines()
{
	register struct error	*e;
	struct error	*prev = NULL;

	for (e = errorlist; e != NULL; ) {
		struct error	*next = e->er_next;

		if (e->er_mess->l_dline == NULL_DADDR
		|| e->er_text->l_dline == NULL_DADDR)
		{
			/* dangling reference: delete */
			if (prev == NULL)
				errorlist = next;
			else
				prev->er_next = next;
			if (next != NULL)
				next->er_prev = prev;
			if (cur_error == e)
				cur_error = next;
			free((UnivPtr)e);
		} else {
			prev = e;
		}
		e = next;
	}
}

/* Add an error to the end of the list of errors.  This is used for
   parse-{C,LINT}-errors and for the spell-buffer command */

private struct error *
AddError(laste, errline, buf, line, charpos)
struct error	*laste;
LinePtr	errline,
	line;
Buffer	*buf;
int	charpos;
{
	struct error	*new = (struct error *) emalloc(sizeof *new);

	new->er_prev = laste;
	if (laste == NULL) {
		/* first time: free up old errors */
		if (errorlist != NULL)
			ErrFree();
		cur_error = errorlist = new;
	} else {
		laste->er_next = new;
	}
	new->er_next = NULL;
	new->er_buf = buf;
	new->er_text = line;
	new->er_char = charpos;
	new->er_mess = errline;

	return new;
}

void
get_FL_info(fname, lineno)
char	*fname,
	*lineno;
{
	putmatch(1, fname, (size_t)FILESIZE);
	putmatch(2, lineno, (size_t)FILESIZE);

	/* error had lineno followed fname, so switch the two */
	if (!jisdigit(lineno[0])) {
		char	tmp[FILESIZE];

		strcpy(tmp, lineno);
		strcpy(lineno, fname);
		strcpy(fname, tmp);
	}
}

/* Free up all the errors */

void
ErrFree()
{
	register struct error	*ep;

	for (ep = errorlist; ep != NULL; ep = ep->er_next)
		free((UnivPtr) ep);
	errorlist = cur_error = NULL;
}

/* Parse errors of the form specified in ErrFmtStr in the current
   buffer.  Do a show error of the first error.  This is neat because this
   will work for any kind of output that prints a file name and a line
   number on the same line. */

void
ErrParse()
{
	struct RE_block	re_blk;
	Bufpos	*bp;
	char	fname[FILESIZE],
		lineno[FILESIZE];
	int	lnum,
		last_lnum = -1;
	struct error	*ep = NULL;
	Buffer	*buf,
		*lastb = NULL;
	LinePtr	err_line = NULL;	/* avoid uninitialized complaint from gcc -W */

	ErrFree();		/* This is important! */
	ToFirst();
	perr_buf = curbuf;
	REcompile(ErrFmtStr, YES, &re_blk);
	/* Find a line with a number on it. */
	while ((bp = docompiled(FORWARD, &re_blk)) != NULL) {
		SetDot(bp);
		get_FL_info(fname, lineno);
		buf = do_find((Window *)NULL, fname, YES, YES);
		(void) chr_to_int(lineno, 10, NO, &lnum);
		if (buf != lastb) {
			lastb = buf;
			last_lnum = 1;		/* new file */
			err_line = buf->b_first;
		} else if (lnum == last_lnum)	/* one error per line is nicer */
			continue;
		err_line = next_line(err_line, lnum - last_lnum);
		ep = AddError(ep, curline, buf, err_line, 0);
		last_lnum = lnum;
	}
	if (cur_error != NULL)
		ShowErr();
}

private void
NeedErrors()
{
	if (cur_error == NULL)
		complain("No errors!");
}

private bool
ErrorHasReferents()
{
	return inlist(cur_error->er_buf->b_first, cur_error->er_text)
		&& inlist(perr_buf->b_first, cur_error->er_mess);
}

/* Go the the next error, if there is one.  Put the error buffer in
   one window and the buffer with the error in another window.
   It checks to make sure that the error actually exists. */

private void
ToError(forward)
bool	forward;
{
	register struct error	*e = cur_error;
	int	num = arg_value();

	NeedErrors();
	if ((forward? e->er_next : e->er_prev) == NULL) {
		s_mess("You're at the %s error.", forward ? "last" : "first");
	} else {
		while (--num >= 0 || !ErrorHasReferents()) {
			e = forward ? e->er_next : e->er_prev;
			if (e == NULL)
				break;
			cur_error = e;
		}
		ShowErr();
	}
}

void
NextError()
{
	ToError(YES);
}

void
PrevError()
{
	ToError(NO);
}

int	EWSize = 20;	/* VAR: percentage of screen to make the error window */

private void
set_wsize(wsize)
int	wsize;
{
	wsize = (LI * wsize) / 100;
	if (wsize >= 1 && !one_windp())
		WindSize(curwind, wsize - (curwind->w_height - 1));
}

/* Show the current error, i.e. put the line containing the error message
   in one window, and the buffer containing the actual error in another
   window. */

void
ShowErr()
{
	Window	*err_wind,
		*buf_wind;

	NeedErrors();
	if (!ErrorHasReferents()) {
		rbell();
		return;
	}
	err_wind = windbp(perr_buf);
	buf_wind = windbp(cur_error->er_buf);

	if (err_wind == NULL) {
		if (buf_wind != NULL) {
			SetWind(buf_wind);
			pop_wind(perr_buf->b_name, NO, -1);
			err_wind = curwind;
		} else {
			pop_wind(perr_buf->b_name, NO, -1);
			err_wind = curwind;
			pop_wind(cur_error->er_buf->b_name, NO, -1);
			buf_wind = curwind;
		}
	} else if (buf_wind == NULL) {
		SetWind(err_wind);
		pop_wind(cur_error->er_buf->b_name, NO, -1);
		buf_wind = curwind;
	}

	/* Put the current error message at the top of its Window */
	SetWind(err_wind);
	SetLine(cur_error->er_mess);
	SetTop(curwind, (curwind->w_line = cur_error->er_mess));
	set_wsize(EWSize);

	/* now go to the the line with the error in the other window */
	SetWind(buf_wind);
	DotTo(cur_error->er_text, cur_error->er_char);
}

char	ShcomBuf[LBSIZE];

/* Make a buffer name given the command `command', i.e. "fgrep -n foo *.c"
   will return the buffer name "fgrep".  */

char *
MakeName(command)
char	*command;
{
	static char	bnm[50];
	register char	*cp = bnm,
			c;

	do {
		c = *command++;
	} while (jiswhite(c));
	while (cp < &bnm[sizeof(bnm) - 1] && c != '\0' && !jiswhite(c)) {
		*cp++ = c;
		c = *command++;
	}
	*cp = '\0';
	strcpy(bnm, basename(bnm));

	return bnm;
}

#ifdef SUBSHELL	/* the body is the rest of this file */

/* Run make, first writing all the modified buffers (if the WtOnMk flag is
   on), parse the errors, and go the first error. */

bool	WtOnMk = YES;		/* VAR: write files on compile-it command */
bool	WrapProcessLines = NO;	/* VAR: wrap process lines at CO-1 chars */

private void
	DoShell proto((char *, char *)),
	com_finish proto((wait_status_t, char *));

private char	make_cmd[LBSIZE] = "make";

void
MakeErrors()
{
	Window	*old = curwind;

	if (WtOnMk)
		put_bufs(NO);

	/* When we're not doing make or cc (i.e., the last command
	   was probably a grep or something) and the user just types
	   ^X ^E, he probably (possibly, hopefully, usually (in my
	   case)) doesn't want to do the grep again but rather wants
	   to do a make again; so we ring the bell and insert the
	   default command and let the person decide. */

	if (is_an_arg()
	|| !(sindex("make", make_cmd) || sindex("cc", make_cmd)))
	{
		if (!is_an_arg())
			rbell();
		/* insert the default for the user (Kludge: only if Inputp is free) */
		if (Inputp == NULL)
			Inputp = make_cmd;
		null_ncpy(make_cmd, ask(make_cmd, "Compilation command: "),
				sizeof (make_cmd) - 1);
	}
	com_finish(UnixToBuf(UTB_DISP|UTB_CLOBBER|UTB_ERRWIN|UTB_SH,
		MakeName(make_cmd), (char *)NULL, make_cmd), make_cmd);

	ErrParse();

	if (!cur_error)
		SetWind(old);
}

# ifdef SPELL

private void
SpelParse(bname)
char	*bname;
{
	Buffer	*buftospel,
		*wordsb;
	char	wordspel[100];
	Bufpos	*bp;
	struct error	*ep = NULL;

	ErrFree();		/* This is important! */

	buftospel = curbuf;
	wordsb = buf_exists(bname);
	if (wordsb == NULL)
		complain("Buffer %s is gone!", bname);
	perr_buf = wordsb;	/* This is important (buffer containing
				   error messages) */
	SetBuf(wordsb);
	ToFirst();
	f_mess("Finding misspelled words ... ");
	while (!lastp(curline)) {
		swritef(wordspel, sizeof(wordspel), "\\<%s\\>", linebuf);
		SetBuf(buftospel);
		ToFirst();
		while ((bp = dosearch(wordspel, FORWARD, NO)) != NULL) {
			SetDot(bp);
			ep = AddError(ep, wordsb->b_dot, buftospel,
					  curline, curchar);
		}
		SetBuf(wordsb);
		line_move(FORWARD, 1, NO);
	}
	add_mess("Done.");

	/* undo buffer switches that ought not to be reflected in current window */
	SetBuf(curwind->w_bufp);

	ShowErr();
}

void
SpelBuffer()
{
	char	*Spell = "Spell",
		com[100];
	Buffer	*savebp = curbuf;

	if (curbuf->b_fname == NULL)
		complain("no file name");
	if (IsModified(curbuf))
		SaveFile();
	swritef(com, sizeof(com), "spell %s", curbuf->b_fname);
	(void) UnixToBuf(UTB_DISP|UTB_CLOBBER|UTB_ERRWIN|UTB_SH,
		Spell, (char *)NULL, com);
	message("[Delete the irrelevant words and then type ^X ^C]");
	ToFirst();
	Recur();
	if (!valid_bp(savebp))
		complain("Buffer gone!");
	SetBuf(savebp);
	SpelParse(Spell);
}

void
SpelWords()
{
	Buffer	*wordsb = curbuf;
	char	*buftospel = ask_buf((Buffer *)NULL, ALLOW_OLD | ALLOW_INDEX);

	SetBuf(do_select(curwind, buftospel));
	SpelParse(wordsb->b_name);
}

# endif /* SPELL */

void
ShToBuf()
{
	char	bnm[128],
		cmd[LBSIZE];

	strcpy(bnm, ask((char *)NULL, "Buffer: "));
	strcpy(cmd, ask(ShcomBuf, "Command: "));
	DoShell(bnm, cmd);
}

void
ShellCom()
{
	null_ncpy(ShcomBuf, ask(ShcomBuf, ProcFmt), (sizeof ShcomBuf) - 1);
	DoShell(MakeName(ShcomBuf), ShcomBuf);
}

void
ShNoBuf()
{
	null_ncpy(ShcomBuf, ask(ShcomBuf, ProcFmt), (sizeof ShcomBuf) - 1);
	com_finish(UnixToBuf(UTB_SH|UTB_FILEARG, (char *)NULL, (char *)NULL,
		ShcomBuf), ShcomBuf);
}

void
Shtypeout()
{
	wait_status_t	status;

	null_ncpy(ShcomBuf, ask(ShcomBuf, ProcFmt), (sizeof ShcomBuf) - 1);
	status = UnixToBuf(UTB_DISP|UTB_SH|UTB_FILEARG, (char *)NULL, (char *)NULL,
		ShcomBuf);
#ifdef MSDOS_PROCS
	if (status < 0)
		Typeout("[%s: not executed %d]", ShcomBuf, status);
	else if (status > 0)
		Typeout("[%s: exited with %d]", ShcomBuf, status);
	else if (!is_an_arg())
		Typeout("[%s: completed successfully]", ShcomBuf);
#else /* !MSDOS_PROCS */
	if (WIFSIGNALED(status))
		Typeout("[%s: terminated by signal %d]", ShcomBuf, WTERMSIG(status));
	else if (WIFEXITED(status) && WEXITSTATUS(status)!=0)
		Typeout("[%s: exited with %d]", ShcomBuf, WEXITSTATUS(status));
	else if (!is_an_arg())
		Typeout("[%s: completed successfully]", ShcomBuf);
#endif /* !MSDOS_PROCS */
	TOstop();
}

/* Run the shell command into `bnm'.  Empty the buffer except when we
   give a numeric argument, in which case it inserts the output at the
   current position in the buffer.  */

private void
DoShell(bnm, command)
char	*bnm,
	*command;
{
	Window	*savewp = curwind;

	com_finish(UnixToBuf(
		(is_an_arg()
			? UTB_DISP|UTB_SH|UTB_FILEARG
			: UTB_DISP|UTB_CLOBBER|UTB_SH|UTB_FILEARG),
		bnm, (char *)NULL, command), command);
	SetWind(savewp);
}

private void
com_finish(status, cmd)
wait_status_t	status;
char	*cmd;
{
#ifdef MSDOS_PROCS
	if (status < 0)
		s_mess("[%s: not executed %d]", cmd, status);
	else if (status > 0)
		s_mess("[%s: exited with %d]", cmd, status);
	else
		s_mess("[%s: completed successfully]", cmd);
#else /* !MSDOS_PROCS */
	if (WIFSIGNALED(status))
		s_mess("[%s: terminated by signal %d]", cmd, WTERMSIG(status));
	else if (WIFEXITED(status) && WEXITSTATUS(status)!=0)
		s_mess("[%s: exited with %d]", cmd, WEXITSTATUS(status));
	else
		s_mess("[%s: completed successfully]", cmd);
#endif /* !MSDOS_PROCS */
}

#ifndef MSDOS_PROCS

/* pid of any outstanding non-iproc process.
 * Note: since there is only room for one pid, there can be no more than
 * one running non-iproc process.
 */
pid_t	ChildPid;

void
dowait(status)
wait_status_t	*status;	/* may be NULL */
{
# ifdef IPROCS
	while (DeadPid != ChildPid) {
		wait_status_t	w;
		pid_t	rpid = wait(&w);

		if (rpid == -1) {
			if (errno == ECHILD) {
				/* fudge what we hope is a bland value */
				byte_zero((UnivPtr)&DeadStatus, sizeof(wait_status_t));
				break;
			}
		} else {
			kill_off(rpid, w);
		}
	}
	DeadPid = 0;
	if (status != NULL)
		*status = DeadStatus;
# else
	wait_status_t	w;

	for (;;) {
		pid_t	rpid = wait(&w);

		if (rpid == -1) {
			if (errno == ECHILD) {
				/* fudge what we hope is a bland value */
				byte_zero((UnivPtr)&w, sizeof(wait_status_t));
				break;
			}
		} else if (rpid == ChildPid) {
			break;
		}
	}
	if (status != NULL)
		*status = w;
# endif
	ChildPid = 0;
}

#endif /* !MSDOS_PROCS */

/* Run the command cmd.  Output to the buffer named bnm (if not
   NULL), first erasing bnm (if UTB_DISP and UTB_CLOBBER), and
   redisplay (if UTB_DISP).  Leaves bnm as the current buffer and
   leaves any windows it creates lying around.  It's up to the
   caller to fix everything up after we're done.  (Usually there's
   nothing to fix up.)

   If bnm is non-NULL, the process output goes to that buffer.
   Furthermore, if UTB_DISP, the buffer is displayed in a window.
   If not UTB_DISP, the buffer is not given a window (of course it
   might already have one).  If UTB_DISP and UTB_CLOBBER, the buffer
   is emptied initially.  If UTB_DISP and UTB_ERRWIN, that window's
   size is as specified by the variable error-window-size.

   If bnm is NULL, the process output does not go to a buffer.  In this
   case, if UTB_DISP, it is displayed using Typeout; if not UTB_DISP,
   the output is discarded.

   Only if UTB_DISP and bnm is non-NULL are UTB_ERRWIN and
   UTB_CLOBBER meaningful. */

wait_status_t
UnixToBuf(flags, bnm, InFName, cmd)
	int	flags;	/* bunch of booleans: see UTB_* in proc.h */
	char	*bnm;	/* buffer name (NULL means none) */
	char	*InFName;	/* name of file for process stdin (NULL means none) */
	char	*cmd;	/* command to run */
{
#ifndef MSDOS_PROCS
	int	p[2];
	wait_status_t	status;
	SIGHANDLERTYPE	old_int;
#else /* MSDOS_PROCS */
	char	cmdbuf[129];
	int	status;
	char	pnbuf[FILESIZE];
	char	*pipename;
#endif /* MSDOS_PROCS */
	bool	eof;
	char	*argv[7];	/* worst case: /bin/sh sh -cf "echo $1" $1 $1 NULL */
	char	**ap = argv;
	File	*fp;
#ifdef SIGINTMASK_DECL
	SIGINTMASK_DECL

	SIGINTMASK_INIT();
#endif

	SlowCmd += 1;;
	if (flags & UTB_SH) {
			*ap++ = Shell;
			*ap++ = basename(Shell);
			*ap++ = ShFlags;
			*ap++ = cmd;
#ifdef MSDOS_PROCS
			/* Kludge alert!
			 * UNIX-like DOS shells and command.com-like DOS shells
			 * seem to differ seem to differ on two points:
			 * - UNIX-like shells use "-" to start flags whereas
			 *   command.com-like shells use "/".
			 * - UNIX-like shells seem to require that the argument to
			 *   $SHELL -c be quoted to cause it to be taken as a single argument.
			 *   command.com-like shells seem to automatically use the rest
			 *   of the arguments.  This is not an issue under real UNIX
			 *   since arguments are passed already broken down.
			 *
			 * E.g., your shell comand: echo foo
			 *         jove runs: command /c echo foo     OK
			 *         jove runs: sh -c echo foo          Oops! sh just runs "echo"
			 *         jove runs: sh -c "echo foo"        Ah, now I get it.
			 *
			 * We use the first character of ShFlags to distinguish
			 * which kind of shell we are dealing with!
			 */
			if (ShFlags[0] == '-') {
				swritef(cmdbuf, sizeof(cmdbuf), "\"%s\"", cmd);
				ap[-1] = cmdbuf;
				/* ??? can we usefully jam in a copy or two of current filename? */
			}
#else /* !MSDOS_PROCS */
			/* Two copies of the file name are passed to the shell:
			 * The Cshell uses the first as a definition of $1.
			 * Most versions of the Bourne shell use the second as a
			 * definition of $1.  (Unfortunately, these same versions
			 * of the Bourne shell take the first as their own name
			 * for error reporting.)
			 */
			if (flags & UTB_FILEARG) {
				char	*fn = pr_name(curbuf->b_fname, NO);

				*ap++ = fn;	/* NOTE: NULL simply terminates argv */
				*ap++ = fn;
			}
#endif /* !MSDOS_PROCS */
	} else {
		*ap++ = cmd;
		*ap++ = basename(cmd);
	}
	*ap++ = NULL;

	if (access(argv[0], X_OK) != 0) {
		complain("[Couldn't access %s: %s]", argv[0], strerror(errno));
		/* NOTREACHED */
	}
	if (flags & UTB_DISP) {
		if (bnm != NULL) {
			if (flags & UTB_CLOBBER) {
				isprocbuf(bnm);
				pop_wind(bnm, YES, B_PROCESS);
			} else {
				pop_wind(bnm, NO, B_FILE);
			}
			set_wsize(flags & UTB_ERRWIN? EWSize : 0);
			message("Starting up...");
			redisplay();
		} else {
			TOstart(argv[0]);
			Typeout("Starting up...");
			TOstart(argv[0]);	/* overwrite "Starting up..." */
		}
	}
	/* Now I will attempt to describe how I deal with signals during
	   the execution of the shell command.  My desire was to be able
	   to interrupt the shell command AS SOON AS the window pops up.
	   So, if we have SIGINT_BLOCK (i.e., a modern signal mechanism)
	   I hold SIGINT, meaning if we interrupt now, we will eventually
	   see the interrupt, but not before we are ready for it.  We
	   fork, the child releases the interrupt, it then sees the
	   interrupt, and so exits.  Meanwhile the parent ignores the
	   signal, so if there was a pending one, it's now lost.

	   Without SIGINT_BLOCK, the best behavior you can expect is that
	   when you type ^] too soon after the window pops up, it may
	   be ignored.  The behavior BEFORE was that it would interrupt
	   JOVE and then you would have to continue JOVE and wait a
	   little while longer before trying again.  Now that is fixed,
	   in that you just have to type it twice. */

#ifndef MSDOS_PROCS
	dopipe(p);

# ifdef SIGINT_BLOCK
	SIGINT_BLOCK();
# else
	old_int = setsighandler(SIGINT, SIG_IGN),
# endif

# ifdef USE_VFORK
	ChildPid = vfork();
# else
	ChildPid = fork();
# endif

	if (ChildPid == -1) {
		int	fork_errno = errno;

		pipeclose(p);
# ifdef SIGINT_UNBLOCK
		SIGINT_UNBLOCK();
# else
		(void) setsighandler(SIGINT, old_int),
# endif
		complain("[Fork failed: %s]", strerror(fork_errno));
	}
	if (ChildPid == 0) {
# ifdef USE_VFORK
		/* There are several other forks in Jove, but this is
		 * the only one we execute often enough to make it worth
		 * using a vfork.  This assumes a system with vfork also
		 * has BSD signals!
		 */
		(void) setsighandler(SIGINT, SIG_DFL);
#  ifdef SIGINT_UNBLOCK
		SIGINT_UNBLOCK();
#  endif
# else /* !USE_VFORK */
		(void) setsighandler(SIGINT, SIG_DFL);
#  ifdef SIGINT_UNBLOCK
		SIGINT_UNBLOCK();
#  endif
# endif /* !USE_VFORK */
		(void) close(0);
		(void) open(InFName==NULL? "/dev/null" : InFName, 0);
		(void) close(1);
		(void) dup(p[1]);
		(void) close(2);
		(void) dup(p[1]);
		pipeclose(p);
		jcloseall();
		execv(argv[0], &argv[1]);
		raw_complain("Execl failed: %s", strerror(errno));
		_exit(1);
	}
# ifdef SIGINT_BLOCK
	old_int = setsighandler(SIGINT, SIG_IGN);	/* got to do this eventually */
# endif
	(void) close(p[1]);
	fp = fd_open(argv[1], F_READ, p[0], iobuff, LBSIZE);
#else /* MSDOS_PROCS*/
	{
		int	oldi = dup(0),
			oldo = dup(1),
			olde = dup(2);
		bool	InFailure;
		int	ph;

		swritef(pnbuf, sizeof(pnbuf), "%s/%s", TmpDir, "jpXXXXXX");
		pipename = mktemp(pnbuf);
		if ((ph = creat(pipename, S_IWRITE|S_IREAD)) < 0)
			complain("cannot make pipe for filter: %s", strerror(errno));
		close(1);
		close(2);
		dup(ph);
		dup(ph);
		close(ph);

		close(0);
		InFailure = InFName != NULL && open(InFName, 0) < 0;
		if (!InFailure)
			status = spawnv(0, argv[0], &argv[1]);

		close(0);
		close(1);
		close(2);
		dup(oldi);
		dup(oldo);
		dup(olde);
		close(oldi);
		close(oldo);
		close(olde);

		if (InFailure)
			complain("[filter input failed]");
		if (status < 0)
			s_mess("[Spawn failed %d]", errno);
		ph = open(pipename, 0);
		if (ph < 0)
			complain("[cannot reopen pipe]", strerror(errno));
		fp = fd_open(argv[1], F_READ, ph, iobuff, LBSIZE);
	}

#endif /* MSDOS_PROCS */

	do {
		int	wrap_col = WrapProcessLines ? CO-1 : LBSIZE;
#ifdef UNIX
		InSlowRead = YES;
#endif
		eof = f_gets(fp, genbuf, (size_t)LBSIZE);
#ifdef UNIX
		InSlowRead = NO;
#endif
		if (bnm != NULL) {
			ins_str_wrap(genbuf, YES, wrap_col);
			if (!eof)
				LineInsert(1);
			if ((flags & UTB_DISP) && fp->f_cnt <= 0) {
				message("Chugging along...");
				redisplay();
			}
		} else if (flags & UTB_DISP)
			Typeout("%s", genbuf);
	} while (!eof);
	if (flags & UTB_DISP)
		DrawMesg(NO);
	close_file(fp);
#ifndef MSDOS_PROCS
	dowait(&status);
# ifdef SIGINT_UNBLOCK
	SIGINT_UNBLOCK();
# endif
	(void) setsighandler(SIGINT, old_int);
#else /* MSDOS_PROCS */
	unlink(pipename);
	getCWD();
# ifdef WINRESIZE
	ResizePending = YES;   /* In case subproc did a MODE command or something */
# endif
#endif /* MSDOS_PROCS */
	SlowCmd -= 1;;
	return status;
}

/* Send the current region to CMD and insert the output from the
   command into OUT_BUF. */

private void
RegToUnix(outbuf, cmd, wrap)
Buffer	*outbuf;
char	*cmd;
bool	wrap;
{
	Mark	*m = CurMark();
	static char	tnambuf[FILESIZE];
	char	*tname;
	Window	*save_wind = curwind;
	volatile wait_status_t	status;
	volatile bool	err = NO;
	bool	old_wrap = WrapProcessLines;
	File	*volatile fp;
	jmp_buf	sav_jmp;

	swritef(tnambuf, sizeof(tnambuf), "%s/%s", TmpDir, "jfXXXXXX");
	tname = mktemp(tnambuf);
	fp = open_file(tname, iobuff, F_WRITE, YES);
	push_env(sav_jmp);
	if (setjmp(mainjmp) == 0) {
		WrapProcessLines = wrap;
		putreg(fp, m->m_line, m->m_char, curline, curchar, YES);
		DelReg();
		f_close(fp);
		status = UnixToBuf(UTB_SH|UTB_FILEARG, outbuf->b_name, tname, cmd);
	} else {
		f_close(fp);
		err = YES;
	}
	pop_env(sav_jmp);
	WrapProcessLines = old_wrap;

	(void) unlink(tname);
	SetWind(save_wind);
	if (!err)
		com_finish(status, cmd);
}

void
FilterRegion()
{
	static char FltComBuf[LBSIZE];

	null_ncpy(FltComBuf, ask(FltComBuf, ": %f (through command) "),
		  (sizeof FltComBuf) - 1);
	RegToUnix(curbuf, FltComBuf, NO);
	this_cmd = UNDOABLECMD;
}

void
isprocbuf(bnm)
char	*bnm;
{
	Buffer	*bp;

	if ((bp = buf_exists(bnm)) != NULL && bp->b_type != B_PROCESS)
		confirm("Over-write buffer %s? ", bnm);
}

#endif /* SUBSHELL */
