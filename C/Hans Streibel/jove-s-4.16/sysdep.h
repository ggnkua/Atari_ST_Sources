/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

/*
 * System Feature Selection: describe OS and C system to JOVE.  See sysdep.doc
 * for a better description of what the different #define feature symbols
 * mean.  If you add new ones, please keep the syntax of the first #ifdef, so
 * that "grep System: sysdep.h" catches the first line of all symbols.
 */

/* System: Solaris 2.0, SunOS 5.0 -- use SYSVR4 and GRANTPT_BUG */

/* System: Solaris 2.x, SunOS 5.x -- use SYSVR4 */

#ifdef SUNOS41	/* System: SunOS4.1 to 4.1.3 */
# define TERMIOS	1
# define USE_GETCWD	1
# define POSIX_UNISTD	1
# define USE_SELECT	1
# define PTYPROCS	1
# define BSD_PTYS	1
# define POSIX_PROCS	1
# define BSD_SIGS	1
# define JOB_CONTROL	1
# define BSD_SETPGRP	1
# define USE_KILLPG	1
# define USE_GETPWNAM	1
# define USE_GETHOSTNAME	1
# define NO_STRERROR	1
# define USE_FSYNC	1
# define USE_FSTAT	1
# define USE_FCHMOD	1
# define USE_CTYPE	1
#endif

#ifdef SUNOS40	/* System: SunOS4.0 to 4.0.3c */
/* Almost identical to SUNOS41, main difference is that SUNOS41 uses
 * POSIX_PROCS, this one uses BSD_WAIT/WAIT3, USE_MEMORY_H.
 * Beware: TERMIO under SunOS 4.0 does not allow VSUSP to be changed,
 * so we cannot use it.
 */
/* try to patch over <termios.h> problems */
# define TERMIOS	1
# define setsid()	/* SunOS 4.0 apparently has no concept of session */
# define cfgetospeed(p)	(CBAUD & (p)->c_cflag)
# define tcgetattr(fd, p)	ioctl((fd), TCGETS, (UnivPtr)(p))
# define tcsetattr(fd, oa, p)	ioctl((fd), (oa), (UnivPtr)(p))
/* fake values for "optional_actions" (oa) arg to tcsetattr */
#  define TCSANOW	TCSETS
#  define TCSADRAIN	TCSETSW
#  define TCSAFLUSH	TCSETSF
/* end of <termios.h> patches */

# define USE_GETCWD	1
# define USE_SELECT	1
# define PTYPROCS	1
# define BSD_PTYS	1
# define BSD_WAIT	1
# define WAIT3		1
# define BSD_SIGS	1
# define JOB_CONTROL	1
# define USE_VFORK	1
# define BSD_SETPGRP	1
# define USE_KILLPG	1
# define USE_GETPWNAM	1
# define USE_GETHOSTNAME	1
# define NO_STRERROR	1
# define USE_FSYNC	1
# define USE_FSTAT	1
# define USE_FCHMOD	1
# define USE_MEMORY_H	1
#endif

#ifdef SUNOS3	/* System: SunOS before 4.0, eg. 3.5. not recently tested */
/* This is very close to BSD4 */
# define SGTTY		1
# define USE_GETWD	1
# define USE_SELECT	1
# define PTYPROCS	1
# define BSD_PTYS	1
# define BSD_WAIT	1
# define WAIT3		1
# define BSD_SIGS	1
# define JOB_CONTROL	1
# define USE_VFORK	1
# define BSD_SETPGRP	1
# define USE_KILLPG	1
# define BSD_DIR	1
# define USE_GETPWNAM	1
# define SIGRESTYPE	int
# define SIGRESVALUE	0
# define USE_GETHOSTNAME	1
# define NO_STRERROR	1
# define USE_FSYNC	1
# define USE_FSTAT	1
# define USE_FCHMOD	1
/* # define USE_BCOPY	1 */
/* # define USE_INDEX	1 */
#endif

#ifdef AIX3_2	/* System: IBM RS6000 running AIX 3.2 */
# define AIX		1
# define FULL_UNISTD	1
# define USE_GETWD	1
# define TERMIOS	1	/* uses termio struct for terminal modes */
# define USE_UNAME	1
# define USE_SELECT	1
# define USE_SELECT_H	1
# define PTYPROCS	1
# define BSD_PTYS	1
# define NO_EOF_FROM_PTY    1	/* BUG! */
# define POSIX_PROCS	1
# define WAIT3		1
# define POSIX_SIGS	1
# define JOB_CONTROL	1
# define USE_GETPWNAM	1
# define USE_UNAME	1
# define USE_FSYNC	1
# define USE_FSTAT	1
# define USE_FCHMOD	1
# define USE_CTYPE	1
#endif

#ifdef __QNX__	/* System: QNX OS for x86 family */
/* Note: this must be placed before BSDPOSIX ifdef (we define BSDPOSIX). */
# define BSDPOSIX	1
# define ONLCR		OPOST	/* how to do ONLCR */
# define USE_SELECT_H	1
#endif

#ifdef BSDPOSIX	/* System: Posix system with BSD flavouring for ptys */
/* System: BSDI, 386BSD, BSD4.4, NetBSD -- BSDPOSIX */
/* System: DEC Ultrix 4.2 -- BSDPOSIX */
/* System: DEC OSF/1 V1.3 -- BSDPOSIX + NO_TIOCREMOTE + NO_TIOCSIGNAL */
/* System: LINUX (MCC-Interim release) -- BSDPOSIX */
/* Also seems to work for SunOS4.1.3! */
# define TERMIOS	1
# define USE_GETCWD	1
# define FULL_UNISTD	1
# define USE_SELECT	1
# define PTYPROCS	1
# define BSD_PTYS	1
# define POSIX_PROCS	1
# define POSIX_SIGS	1
# define JOB_CONTROL	1
# define BSD_SETPGRP	1
# define USE_KILLPG	1
# define USE_GETPWNAM	1
# define USE_GETHOSTNAME	1
# define USE_FSYNC	1
# define USE_FSTAT	1
# define USE_FCHMOD	1
#endif

#ifdef IRIX
# define _BSD_COMPAT	1	/* Turn on BSD setpgrp and other neat things */
# define TERMIOS	1
# define USE_GETCWD	1
# define FULL_UNISTD	1
# define USE_SELECT	1
# define PTYPROCS	1
# define POSIX_PROCS	1
# define POSIX_SIGS	1
# define JOB_CONTROL	1
# ifdef IRIX4
   /* Should work for IRIX 4.0.4 back to 3.2 or 3.3.  This is a Posix system
    * with its own way of doing PTYS.  Older versions may need MIPS_CC_BUG
    * defined as well.
    */
#  define IRIX_PTYS	1
#  define NO_TIOCREMOTE	1
#  define SIGRESTYPE	int
#  define SIGRESVALUE	0
# else
   /* IRIX 5 and later */
#  define SVR4_PTYS	1
#  define NO_TIOCREMOTE	1
#  define NO_TIOCSIGNAL	1
#  define SIGRESTYPE	void
#  define SIGRESVALUE	/*void!*/
# endif
# define BSD_SETPGRP	1
# define USE_GETPWNAM	1
# define USE_KILLPG	1
# define USE_GETHOSTNAME	1
# define USE_CTYPE	1
#endif

#ifdef SYSVR4	/* System: System V, Release 4 and derivatives */
/* System: Consensys V4 -- use SYSVR4 and GRANTPT_BUG */
/* System: DEC OSF/1 V2.0 or later -- use SYSVR4 */
/* System: DEC OSF R1.3MK -- use SYSVR4 */
/* System: Solaris 2.0, SunOS 5.0 -- use SYSVR4 and GRANTPT_BUG */
/* System: Solaris 2.x, SunOS 5.x -- use SYSVR4 */
/* Note: some versions of System V Release 4 have a bug in that affects
 * interactive processes.  Examples include Consensys V4 and SunOS 5.0
 * also known as Solaris 5.0.  See the description of GRANTPT_BUG in
 * sysdep.doc
 */
# define TERMIOS	1
# define USE_GETCWD	1
# define FULL_UNISTD	1
# define USE_SELECT	1
# define PTYPROCS	1
# define SVR4_PTYS	1
# define POSIX_PROCS	1
# define POSIX_SIGS	1
# define JOB_CONTROL	1
# define USE_UNAME	1
# define USE_GETPWNAM	1
# define USE_FSYNC	1
# define USE_FSTAT	1
# define USE_FCHMOD	1
# define REALSTDC	1
# define USE_CTYPE	1
#endif

#ifdef HPUX	/* System: Hewlett-Packard HP-UX 9.01 */
# define TERMIOS	1
# define USE_BSDTTYINCLUDE	1	/* No other way to turn off ^Y */
# define USE_GETCWD	1
# define FULL_UNISTD	1
# define USE_SELECT	1
# define PTYPROCS	1
# define BSD_PTYS	1
# define POSIX_PROCS	1
# define NO_EOF_FROM_PTY    1	/* BUG! */
# define POSIX_SIGS	1
# define JOB_CONTROL	1
# define USE_UNAME	1
# define DEFINE_PC_BC_UP_OSPEED	1	/* May be needed for all SYSVR2 */
#endif

#ifdef BSD4	/* System: Berkeley BSD4.x, 2.9, 2.10, MIPS RiscOS 4.x */
/* MIPS needs -systype bsd43, older releases (before 4.50?) may need
 * MIPS_CC_BUG defined as well.
 */
# define SGTTY		1
# define USE_GETWD	1
# define USE_SELECT	1
# define PTYPROCS	1
# define BSD_PTYS	1
# define BSD_WAIT	1
# define WAIT3		1
# define BSD_SIGS	1
# define JOB_CONTROL	1
# define USE_VFORK	1
# define BSD_SETPGRP	1
# define USE_KILLPG	1
# define BSD_DIR	1
# define SIGRESTYPE	int
# define SIGRESVALUE	0
# define USE_GETHOSTNAME	1
# define NO_STRERROR	1
# define USE_FSYNC	1
# define USE_FSTAT	1
# define USE_FCHMOD	1
# define USE_BCOPY	1
# define USE_INDEX	1
#endif

#ifdef MINT
# define TERMIOS	1
# define USE_GETWD	1
# define POSIX_UNISTD	1
# define USE_SELECT	1
# define PTYPROCS	1
# define BSD_PTYS	1
# define BSD_WAIT	1
# define WAIT3		1
# define POSIX_SIGS	1
# define POSIX_PROCS	1
# define JOB_CONTROL	1
# define USE_VFORK	1
# define BSD_SETPGRP	1
# define USE_GETPWNAM	1
# define USE_KILLPG	1
# define USE_GETHOSTNAME	1
# define USE_FSYNC	1
# define USE_FSTAT	1
/* # define USE_CTYPE	1 */	/* only rudimentary Support in Mint yet */
# define ISO_8859_1	1	/* I'm living in Germany... */
# define ONLCR		OPOST	/* korrekt? I didn't find ONLCR in the includes */
# define _BSD_SOURCE	1	/* this one is for /usr/include/unistd.h */
# define DEFINE_PC_BC_UP_OSPEED	1
# ifndef __STDC__
#  define __STDC__
# endif
# ifndef REALSTDC
#  define REALSTDC 1
# endif
#endif

#ifdef SCO	/* System: SCO ODT 3.0 */
# define TERMIOS	1
# define FULLUNISTD	1
# define USE_GETCWD	1
# define POSIX_UNISTD	1
# define USE_SELECT	1
# define PTYPROCS	1
# define BSD_PTYS	1
# define POSIX_PROCS	1
# define JOB_CONTROL	1
# define USE_UNAME	1
/* In SCO ODT 3.0, a wait() will never finish if SIGCHLD is being held.
 * We think that this is a bug.  It's rumoured to be "fixed" in the next
 * release.  JOVE's IPROCS code no longer triggers this bug.
 */
# define PTYPROCS	1
# define USE_CTYPE	1
#endif

#ifdef _MSC_VER	/* System: Microsoft C for the IBM-PC under MSDOS or WIN32 */
# if defined(_WIN32) && !defined(WIN32)
#  define WIN32 _WIN32
# endif
# ifdef WIN32
#  define WINRESIZE	1
# else /* ! WIN32 => MSDOS */
#  define IBMPCDOS		1
#  define MALLOC_CACHE	1	/* DGROUP gets full otherwise */
#  if defined(M_I86LM)	/* large memory model */
#   define NBUF		62	/* NBUF*JBUFSIZ must be less than 64 kB */
#  else
#   define NBUF		3
#   define FAR_LINES	1	/* to squeeze larger files, distance Lines */
#  endif
# endif
# define REALSTDC	1	/* MS C only defines __STDC__ if you use /Za */
#endif

#ifdef ZTCDOS	/* System: Zortech C V3.0 for the IBM-PC under MSDOS */
# define IBMPCDOS		1
# define getch		jgetch	/* UGH!  Zortech steals from our namespace. */
# define MALLOC_CACHE	1	/* DGROUP gets full otherwise */
# define REALSTDC	1	/* close enough for us, but ZTCDOS doesn't define __STDC__ */
# ifdef M_I86LM		/* large memory model */
#  define NBUF		62	/* NBUF*JBUFSIZ must be less than 64 kB */
# else
#  define NBUF		3
#  define FAR_LINES	1	/* to squeeze larger files, distance Lines */
# endif
  /* (1) specify stack size, and
   * (2) request support of wildcards in command-line args (UGH!)
   */
# define STACK_DECL	unsigned int _stack = 0x2000; WILDCARDS
# define dostime_t	dos_time_t	/* is Zortech out of step? */
# define _dos_gettime	dos_gettime
#endif

#if defined(__WATCOMC__) && defined(MSDOS)	/* System: Watcom C V10.0 for the IBM-PC under MSDOS */
# define IBMPCDOS		1
# define MALLOC_CACHE	1	/* DGROUP gets full otherwise */
# define REALSTDC	1	/* close enough for us, but ZTCDOS doesn't define __STDC__ */
# ifdef M_I86LM		/* large memory model */
#  define NBUF		62	/* NBUF*JBUFSIZ must be less than 64 kB */
# else
#  define NBUF		3
#  define FAR_LINES	1	/* to squeeze larger files, distance Lines */
# endif
#endif

#ifdef __BORLANDC__	/* System: Borland C/C++ (v3.1) for the IBM-PC under MSDOS */
# define IBMPCDOS		1
# define MALLOC_CACHE	1	/* DGROUP gets full otherwise */
# define REALSTDC	1	/* close enough for us, but not strict ANSI */
# ifdef __LARGE__
#  define NBUF		62	/* NBUF*JBUFSIZ must be less than 64 kB */
#  define FAR_LINES 1	/* to squeeze larger files, distance Lines */
# else
#  ifdef __MEDIUM__
#    define NBUF	3
#    define FAR_LINES 1	/* to squeeze larger files, distance Lines */
#  endif
# endif
# define STACK_DECL	unsigned int _stklen = 0x2000;		/* Borland's way of specifying stack size */
#endif

/* All the systems marked with XXX_ are ones that this version of Jove (4.16)
 * has not been tested on.  4.15 was the transition from implicit #ifdefs
 * scattered throughout the code to feature-based ifdefs that MUST be
 * enabled in sysdep.h.  The #ifdef XXX_* below have been left in to provide a
 * guide to re-porting this version to those architectures.  If you do so
 * successfully, please send a copy of these changes to
 * jovehacks@cs.toronto.edu and we'll try to incorporate those changes above
 * and get rid of the XXX_.
 */

#ifdef XXX_M_XENIX	/* System: Microsoft or SCO Xenix */
/* #define NBUF	48 */	/* if we are on a 286, NBUF*JBUFSIZ must be less than 64 kB */
# define BSD_DIR	1
#endif

#ifdef XXX_SYSV		/* System: System V Rel. 2, System III */
# define TERMIO		1
# define USE_PWD
# define NONBLOCKINGREAD	1
# define USE_MEMORY_H	1
# define DIRENT_EMULATE	1	/* for truly old versions? */
#endif

#ifdef XXX_A_UX		/* System: A/UX on a MacII (Do *not* define "MAC") */
/* It might be better to try BSDPOSIX for newer A/UX. */
# define BSD_WAIT	1
# define BSD_DIR	1
# define WAIT3		1
# define BSD_SIGS	1	/* ??? */
# define USE_KILLPG	1
# define TERMIO		1	/* uses termio struct for terminal modes */
# define USE_GETHOSTNAME	1
# define USE_SELECT	1
#endif

#ifdef XXX_OLDMIPS	/* System: MIPS-SYSV, Irix before 3.3. */
/* Older MIPS (UMIPS-SYSV, anything other than their 4.3 port before
 * RISCOS4.x) and SGI 4D OSes (anything before Irix3.3) have BSD style wait,
 * and directory routines if you link -lbsd and define -I/usr/include/bsd on
 * the compile line. But they have SysV style signals.  Jove was ported to the
 * SGI 68K boxes once, but it the mods seem to have been lost.
 */
# define BSD_WAIT	1	/* Berkeley style sys/wait.h */
# define BSD_DIR	1	/* Berkeley style dirent routines */
#endif

#ifdef XXX_MSC51	/* System: Microsoft C 5.1 on IBM PC under DOS*/
/* This hasn't been tested recently.  Consider stealing ZTCDOS settings. */
# define IBMPCDOS		1
# define NO_PTRPROTO	1
# define REALSTDC	1	/* well, almost */
# ifdef M_I86LM		/* large memory model */
#  define NBUF		62	/* NBUF*JBUFSIZ must be less than 64 kB */
# else
#  define SMALL		1
# endif
#endif

#ifdef THINK_C	/* System: Think C version 5.0 on the Macintosh */
# define MAC 1
# define REALSTDC	1	/* we hope */
# define MALLOC_CACHE	1   /* Only 32K of static space on Mac, so... */
  typedef long	off_t;
# define USE_GETCWD	1
# define USE_INO	1	/* we fake it */
  typedef int	dev_t;
  typedef int	ino_t;
# define DIRECTORY_ADD_SLASH 1
# define EOL	'\r'	/* end-of-line character for files */
# define WINRESIZE	1
# define AUTO_BUFS	1	/* slim down data segment */
#endif

/**************** Common Characteristics ****************/

#ifdef pdp11
/* On the PDP-11, UNIX allocates at least 8K for the stack.
 * In order not to waste this space, we allocate
 * a bunch of buffers as autos.
 */
# define AUTO_BUFS	1
#endif

#ifdef IBMPCDOS	/* Common characteristics for IBM-PC MS-DOS systems. */
# ifndef MSDOS
#  define MSDOS	1
# endif
# define PCNONASCII	0xFF	/* prefix for peculiar IBM PC key codes */
# define NO_JSTDOUT	1	/* don't use jstdout */
# define CODEPAGE437	1	/* Code Page 437 English display characters */
# define PCSCRATTR	1	/* exploit IBMPC screen attributes */
# define HIGHLIGHTING	1	/* highlighting is used for mark and scrollbar */
#endif

#ifdef MSDOS	/* Common characteristics for MS-DOS systems. */
# define MSDOS_PROCS	1	/* spawn et al */
# define FILENAME_CASEINSENSITIVE 1
# define USE_CRLF 1
# define DIRECTORY_ADD_SLASH 1
# define MSFILESYSTEM 1
#endif

#ifdef WIN32	/* Common characteristics for WIN32 systems. */
# define PCNONASCII	0xFF	/* prefix for peculiar IBM PC key codes */
# define NO_JSTDOUT	1	/* don't use jstdout */
# define CODEPAGE437	1	/* Code Page 437 English display characters */
# define PCSCRATTR	1	/* exploit IBMPC screen attributes */
# define HIGHLIGHTING	1	/* highlighting is used for mark and scrollbar */
# define MSDOS_PROCS	1	/* spawn et al */
# define FILENAME_CASEINSENSITIVE 1
# define USE_CRLF 1
# define DIRECTORY_ADD_SLASH 1
# define MSFILESYSTEM 1
#endif

/* The operating system (MSDOS, WIN32, or MAC) must be defined by this point. */
#if !(defined(MSDOS) || defined(WIN32) || defined(MAC))
# define UNIX	1	/* default to UNIX */
#endif

#ifdef UNIX	/* Common characteristics for UNIX systems. */
/* Our defaults tend to be conservative and lean towards pure SYSV */
# define USE_INO	1
# define TERMCAP	1
# define WINRESIZE	1
# define MOUSE		1
# if !(defined(NO_IPROCS) || defined(PIPEPROCS) || defined(PTYPROCS))
#  define PIPEPROCS	1	/* use pipes */
# endif
# if !defined(TERMIOS) && !defined(SGTTY)
#  define TERMIO	1	/* uses termio struct for terminal modes */
# endif
/* At the moment, the PTY code mandates having select().  One day, this might
 * change.
 */
# if defined(PTYPROCS) && !defined(USE_SELECT)
   sysdep.h: Sorry, PTYPROCS requires the select() system call.  You must
   either define USE_SELECT or undefine PTYPROCS.
# endif
# if defined(SIGCLD) && !defined(SIGCHLD)
#  define SIGCHLD	SIGCLD
# endif
#endif /* UNIX */

/*************************************************************************
 *
 * The things below here aren't meant to be tuned, but are included here
 * because they're dependent on the things defined earlier in the file.
 */
#ifdef USE_BCOPY
# define byte_copy(from, to, len)	bcopy((UnivConstPtr)(from), (UnivPtr)(to), (size_t)(len))
# define byte_zero(s, n)	bzero((UnivPtr)(s), (size_t)(n))
#endif

#ifndef byte_copy
# ifdef USE_MEMORY_H
#  include <memory.h>
# endif
# define byte_copy(from, to, count)	memcpy((UnivPtr)(to), (UnivConstPtr)(from), (size_t)(count))
# define byte_zero(s, n)		memset((UnivPtr)(s), 0, (size_t)(n))
#endif

#ifdef USE_INDEX
# define strchr		index
# define strrchr	rindex
#endif

#ifdef FULL_UNISTD
# define POSIX_UNISTD	1
#endif

/* SSIZE_T: result type of read() and write() */
#ifdef FULL_UNISTD
# define SSIZE_T    ssize_t
#endif

#ifndef SSIZE_T
# define SSIZE_T    int
#endif

/* Determine if really ANSI C */
#ifdef __STDC__
# if __STDC__ > 0
#  define REALSTDC 1
# endif
#endif

/* Determine number of buffers and the size of a buffer
 * (and hence the maximum length of a line, among other things).
 */

#ifdef SMALL
# ifndef NBUF
#  define NBUF		3
# endif
# ifndef JLGBUFSIZ
#  define JLGBUFSIZ	9
# endif
#endif

#ifndef NBUF
# define NBUF 64
#endif

#ifndef JLGBUFSIZ
# define JLGBUFSIZ 10
#endif

#define JBUFSIZ	(1<<JLGBUFSIZ)


#ifndef NCHARS
# define NCHARS 0400
#endif

#ifndef EOL
# define EOL	'\n'	/* end-of-line character for files */
#endif

#ifndef MSDOS	/* maximum path length (including '\0') */
# define FILESIZE	256
#else /* MSDOS */
# define FILESIZE	128	/* currently, 2+1+64+3+1+3+1 == 80 ought to be OK */
#endif /* MSDOS */

#ifndef SIGRESTYPE	/* default to void, correct for most modern systems */
# define SIGRESTYPE	void
# define SIGRESVALUE	/*void!*/
#endif

/* daddr: tmp file index type (see temp.h)
 *
 * On a system which limits JOVE to a very small data segment,
 * it may be worthwhile limiting daddr to a short.  This reduces
 * the size of a Line descriptor, but reduces the addressable size
 * of the temp file.  This is reasonable on a PDP-11 and perhaps
 * an iAPX*86.
 * NOTE: logically, daddr is unsigned, but a signed type will work
 * if you cannot use an unsigned type.
 */

#ifdef SMALL
  typedef unsigned short	daddr;
#else
  typedef unsigned long	daddr;
#endif /* SMALL */

#define NULL_DADDR		((daddr) 0)

#ifndef CHAR_BITS
# define CHAR_BITS	8	/* factor to convert sizeof => bits */
#endif

#define DDIRTY	((daddr)1 << (sizeof(daddr)*CHAR_BITS - 1))	/* daddr dirty flag */
