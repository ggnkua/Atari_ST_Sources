/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

/* note: sysprocs.h must be included first */

extern char	ShcomBuf[LBSIZE];

extern char	*MakeName proto((char *command));

extern void
	isprocbuf proto((char *bufname)),
	get_FL_info proto((char *, char *)),
	ChkErrorLines proto((void)),
	ErrFree proto((void));

extern wait_status_t	UnixToBuf proto((int, char *, char *, char *));

/* flags for UnixToBuf: */
#define UTB_DISP	1	/* Display output? */
#define UTB_CLOBBER	2	/* (if UTB_DISP)  clear buffer at start? */
#define UTB_ERRWIN	4	/* (if UTB_DISP) make window size error-window-size? */
#define UTB_SH	8	/* shell command? */
#define UTB_FILEARG	16	/* pass curbuf->b_fname as $0? */

#ifndef MSDOS_PROCS
extern pid_t	ChildPid;	/* pid of any outstanding non-iproc process */
extern void	dowait proto((wait_status_t *status));
#endif

/* Commands: */

#ifdef SUBSHELL
extern void
	MakeErrors proto((void)),
	FilterRegion proto((void)),
	ShNoBuf proto((void)),
	ShToBuf proto((void)),
	ShellCom proto((void)),
	Shtypeout proto((void));
#endif
/*
 * Even if we don't have MakeErrors, the following are useful because we can
 * load an error file and parse it with these.
 */
extern void
	ErrParse proto((void)),
	ShowErr proto((void)),
	NextError proto((void)),
	PrevError proto((void));

#ifdef SPELL
extern void
	SpelBuffer proto((void)),
	SpelWords proto((void));
#endif

/* Variables: */

extern int	EWSize;			/* VAR: percentage of screen to make the error window */
extern char	ErrFmtStr[256];		/* VAR: format string for parse errors */
#ifdef SUBSHELL
extern bool	WtOnMk;			/* VAR: write files on compile-it command */
extern bool	WrapProcessLines;	/* VAR: wrap process lines at CO-1 chars */
#endif
