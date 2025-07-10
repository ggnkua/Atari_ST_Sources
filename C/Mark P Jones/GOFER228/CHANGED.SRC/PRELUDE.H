/* --------------------------------------------------------------------------
 * prelude.h:   Copyright (c) Mark P Jones 1991-1993.   All rights reserved.
 *              See goferite.h for details and conditions of use etc...
 *              Gofer version 2.28 January 1993
 *
 * Basic data type definitions, prototypes and standard macros including
 * machine dependent variations...
 * ------------------------------------------------------------------------*/
#define const		  /* const is more trouble than it's worth,...	   */
#include <stdio.h>

/*---------------------------------------------------------------------------
 * To select a particular machine/compiler, just place a 1 in the appropriate
 * position in the following list and ensure that 0 appears in all other
 * positions:
 *
 * The letters UN in the comment field indicate that I have not personally
 * been able to test this configuration yet and I have not heard from anybody
 * else that has tried it.  If you run Gofer on one of these systems and it
 * works (or needs patches) please let me know so that I can fix it and
 * update the source.
 *-------------------------------------------------------------------------*/

#define ATARI	 0	/* Atari ST/STE/TT/Falcon using Lattice C 5.52  UN */
#define ATARIGCC 1 /* atari ST/STE/TT/Falcon using gnu cc 2.x */
#define TURBOC   0      /* For IBM PC, using Turbo C 1.5		   */
#define BCC	 0      /* For IBM PC, using Borland C++ 3.1		   */
#define SUNOS    0      /* For Sun 3/Sun 4 running SunOs 4.x		   */
#define MIPS	 0	/* For MIPS RC6280/Sony machine NWS-3870	UN */
#define NEXTSTEP 0      /* For NeXTstep 3.0 using NeXT cc		   */
#define NEXTGCC  0	/* For NeXTstep with gcc 2.x			   */
#define MINIX68K 0	/* For Minix68k with gcc			UN */
#define AMIGA    0	/* For Amiga using gcc 2.2.2			UN */
#define HPUX     0      /* For HPUX using gcc				UN */
#define LINUX    0      /* For Linux using gcc				UN */
#define DJGPP    0	/* For DJGPP version 1.09 (gcc2.2.2) and DOS 5.0   */
#define ZTC      0	/* For IBM PC (>= 386) Zortech C++ v3.0 (-mx)	   */
#define RISCOS   0	/* For Acorn DesktopC and RISCOS2 or 3		   */
#define ALPHA	 0	/* For DEC Alpha with OSF/1 (32 bit ints, no gofc) */
#define OS2      0	/* For IBM OS/2 2.0 using EMX GCC		   */
#define SVR4	 0	/* For SVR4 using GCC2.2			   */
#define ULTRIX   0      /* For DEC Ultrix 4.x using GCC2.3.3		   */
#define AIX	 0	/* For IBM AIX on RS/6000 using GCC		   */

/*---------------------------------------------------------------------------
 * To add a new machine/compiler, add a new macro line above, add the new
 * to the appropriate flags below and add a `machine specific' section in the
 * following section of this file.  Please send me details of any new machines
 * or compilers that you try so that I can pass them onto others!
 *
 *   UNIX          if the machine runs fairly standard Unix
 *   SMALL_GOFER   for 16 bit operation on a limited memory PC
 *   REGULAR_GOFER for 32 bit operation using largish default table sizes
 *   LARGE_GOFER   for 32 bit operation using larger default table sizes
 *   JMPBUF_ARRAY  if jmpbufs can be treated like arrays.
 *   DOS_IO        to use DOS style IO for terminal control
 *   TERMIO_IO     to use Unix termio for terminal control
 *   SGTTY_IO      to use Unix sgtty for terminal control
 *   BREAK_FLOATS  to use two integers to store a float (or double)
 *		   if SMALL_GOFER, then you *must* use BREAK_FLOATS == 1
 *		   (assumes sizeof(int)==2, sizeof(float)==4).
 *		   Otherwise, assuming sizeof(int)==sizeof(float)==4,
 *                 BREAK_FLOATS == 0 will give you floats  for floating pt,
 *		   BREAK_FLOATS == 1 will give you doubles for floating pt.
 *   HAS_FLOATS	   to indicate support for floating point
 *-------------------------------------------------------------------------*/

#define UNIX          (SUNOS  | NEXTSTEP | HPUX | NEXTGCC | ATARI | LINUX | \
		       MINIX68K |ALPHA | OS2 | SVR4 | ULTRIX | AIX | AMIGA | ATARIGCC )
#define SMALL_GOFER   (TURBOC | BCC)
#define REGULAR_GOFER (RISCOS | DJGPP | ZTC | ATARI | ATARIGCC )
#define LARGE_GOFER   (SUNOS  | NEXTSTEP | HPUX | NEXTGCC | LINUX | AMIGA | \
		       MINIX68K |ALPHA | OS2 | SVR4 | ULTRIX | AIX | ALPHA)
#define JMPBUF_ARRAY  (UNIX   | DJGPP | RISCOS | ZTC)
#define DOS_IO        (TURBOC | BCC | DJGPP | ZTC | ATARI)
#define TERMIO_IO     (LINUX  | HPUX | OS2 | SVR4)
#define SGTTY_IO      (SUNOS  | NEXTSTEP | NEXTGCC | AMIGA | MINIX68K | \
                       ALPHA  | ULTRIX | AIX | MIPS | ATARIGCC )
#define BREAK_FLOATS  (TURBOC | BCC)
#define HAS_FLOATS    (REGULAR_GOFER | LARGE_GOFER | BREAK_FLOATS)

/*---------------------------------------------------------------------------
 * The following flags should be set automatically according to builtin
 * compiler flags, but you might want to set them manually to avoid default
 * behaviour in some situations:
 *-------------------------------------------------------------------------*/

#ifdef  __GNUC__			/* look for GCC 2.x extensions	   */
#if     __GNUC__ >= 2 && !NEXTSTEP	/* NeXT cc lies and says it's 2.x  */
#define GCC_THREADED 1

/* WARNING: if you use the following optimisations to assign registers for
 * particular global variables, you should be very careful to make sure that
 * storage(RESET) is called after a longjump (usually resulting from an error
 * condition) and before you try to access the heap.  The current version of
 * main deals with this using everybody(RESET) at the head of the main read,
 * eval, print loop
 */

#ifdef  m68k				/* global registers on an m68k	   */
#define GLOBALcar	asm("a4")
#define GLOBALcdr	asm("a5")
#define GLOBALsp	asm("a3")
#endif

#ifdef  sparc				/* global registers on a sparc	   */
/* sadly, although the gcc documentation suggests that the following reg   */
/* assignments should be ok, experience shows (at least on Suns) that they */
/* are not -- it seems that atof() and friends spoil things.		   */
/*#define GLOBALcar	asm("g5")*/
/*#define GLOBALcdr	asm("g6")*/
/*#define GLOBALsp	asm("g7")*/
#endif

#endif
#endif

#ifndef GCC_THREADED
#define GCC_THREADED 0
#endif

/*---------------------------------------------------------------------------
 * Machine specific sections:
 * Include any machine specific declarations and define macros:
 *   local              prefix for locally defined functions
 *   far                prefix for far pointers
 *   allowBreak()       call to allow user to interrupt computation
 *   FOPEN_WRITE        fopen *text* file for writing
 *   FOPEN_APPEND       fopen *text* file for append
 *
 * N.B. `far' must be explicitly defined (usually to the empty string)
 *-------------------------------------------------------------------------*/

#ifdef __STDC__           /* To enable use of prototypes whenever possible */
#define Args(x) x
#else
#if (TURBOC | BCC | ZTC)  /* K&R 1 does not permit `defined(__STDC__)' ... */
#define Args(x) x
#else
#define Args(x) ()
#endif
#endif

#if (ATARI|ATARIGCC)
#define far
#endif

#if     (TURBOC | BCC)
#include <alloc.h>
#define local		   near pascal
extern  int  kbhit	   Args((void));
#define allowBreak()	   kbhit()
#define FOPEN_WRITE	   "wt"
#define FOPEN_APPEND	   "at"
#define farCalloc(n,s)	   farcalloc((unsigned long)n,(unsigned long)s)
#define sigProto(nm)	   int nm(void)
#define sigRaise(nm)	   nm()
#define sigHandler(nm)	   int nm()
#define sigResume	   return 1
#endif

#if     SUNOS
#include <malloc.h>
#define far
#define farCalloc(n,s)	   (Void *)valloc(((unsigned)n)*((unsigned)s))
#endif

#if     MIPS
#define far
#define farCalloc(n,s)	   (Void *)valloc(((unsigned)n)*((unsigned)s))
#endif

#if     (NEXTSTEP | NEXTGCC | AMIGA | MINIX68K | ULTRIX)
#include <stdlib.h>
#define far
#define farCalloc(n,s)	   (Void *)valloc(((unsigned)n)*((unsigned)s))
#endif

#if     (HPUX | DJGPP | ZTC | LINUX | ALPHA | OS2 | SVR4 | AIX)
#include <stdlib.h>
#define far
#endif

#if	RISCOS
#include <string.h>
#include <stdlib.h>
#include <signal.h>
#define  far
#define  isascii(c)	(((unsigned)(c))<128)
#define  Main		int
#define  MainDone	return 0;/*NOTUSED*/
extern   int access	Args((char *, int));
extern   int namecmp    Args((char *, char *));
#endif

#ifndef USE_READLINE
#define USE_READLINE  0
#endif
#ifndef allowBreak
#define allowBreak()
#endif
#ifndef local
#define local
#endif
#ifndef farCalloc
#define farCalloc(n,s)	   (Void *)calloc(((unsigned)n),((unsigned)s))
#endif
#ifndef FOPEN_WRITE
#define FOPEN_WRITE	   "w"
#endif
#ifndef FOPEN_APPEND
#define FOPEN_APPEND	   "a"
#endif
#ifndef sigProto
#define sigProto(nm)	   Void nm Args((int))
#define sigRaise(nm)	   nm(1)
#define sigHandler(nm)	   Void nm(sig_arg) int sig_arg;
#define sigResume	   return
#endif
#ifndef Main			/* to cope with systems that don't like	   */
#define Main		   Void /* main to be declared as returning Void   */
#endif
#ifndef MainDone
#define MainDone
#endif

#if (UNIX | DJGPP | RISCOS | ZTC)
#define ctrlbrk(bh)	   signal(SIGINT,bh)
#endif

/*---------------------------------------------------------------------------
 * General settings:
 *-------------------------------------------------------------------------*/

#define Void     void   /* older compilers object to: typedef void Void;   */
typedef unsigned Bool;
#define TRUE     1
#define FALSE    0
typedef char    *String;
typedef int      Int;
typedef long     Long;
typedef int      Char;
typedef unsigned Unsigned;

#ifndef STD_PRELUDE
#if     RISCOS
#define STD_PRELUDE	   "prelude"
#else
#define STD_PRELUDE	   "standard.prelude"
#endif
#endif

#define NUM_SYNTAX         100
#define NUM_SELECTS        100
#define NUM_FILES	   20
#define NUM_MODULES        64
#define NUM_FIXUPS         100
#define NUM_TUPLES         100
#define NUM_OFFSETS        1024
#define NUM_CHARS          256

/* Managing two different sized versions of Gofer has caused problems in
 * the past for people who tried to change one setting, but inadvertantly
 * modified the settings for a different size.  Now that we have three
 * sizes of Gofer, I think it's time to try a new scheme:
 */

#if     SMALL_GOFER			/* the McDonalds mentality :-)	   */
#define Pick(s,r,l)	   s
#endif
#if     REGULAR_GOFER
#define Pick(s,r,l)	   r
#endif
#if     LARGE_GOFER
#define Pick(s,r,l)	   l
#endif

#define NUM_TYCON          Pick(60,    160,        160)
#define NUM_NAME           Pick(625,   2000,       16000)
#define NUM_CLASSES        Pick(20,    40,         40)
#define NUM_INSTS          Pick(60,    100,        100)
#define NUM_INDEXES        Pick(700,   2000,       2000)
#define NUM_DICTS          Pick(400,   32000,      32000)
#define NUM_TEXT           Pick(7000,  20000,      80000)
#define NUM_TEXTH	   Pick(1,     10,         10)
#define NUM_TYVARS         Pick(800,   3000,       4000)
#define NUM_STACK          Pick(1800,  16000,      16000)
#define NUM_ADDRS          Pick(28000, 100000,     320000)
#define MINIMUMHEAP	   Pick(7500,  7500,       7500)
#define MAXIMUMHEAP	   Pick(32765, 0,          0)
#define DEFAULTHEAP        Pick(28000, 100000,     100000)
#define MAXPOSINT          Pick(32767, 2147483647, 2147483647)

#define minRecovery	   Pick(1000,  1000,       1000)
#define bitsPerWord	   Pick(16,    32,         32)
#define wordShift	   Pick(4,     5,          5)
#define wordMask	   Pick(15,    31,         31)

#define bitArraySize(n)    ((n)/bitsPerWord + 1)
#define placeInSet(n)      ((-(n)-1)>>wordShift)
#define maskInSet(n)       (1<<((-(n)-1)&wordMask))

#ifndef __GNUC__
#if !RISCOS
extern Int      strcmp     Args((String, String));
extern Int      strlen     Args((String));
extern char	*strcpy	   Args((String,String));
extern char     *strcat	   Args((String,String));
#endif
#endif
extern char	*getenv	   Args((char *));
extern int      system	   Args((const char *));
extern double   atof	   Args((char *));
extern char     *strchr    Args((char *,int));  /* test membership in str  */
extern Void     exit       Args((Int));
extern Void     internal   Args((String));
extern Void     fatal	   Args((String));

#if     HAS_FLOATS
#ifdef  NEED_MATH
#include <math.h>
#endif

#if	(REGULAR_GOFER | LARGE_GOFER) & BREAK_FLOATS
#define FloatImpType	   double
#define FloatPro	   double
#define FloatFMT           "%.9g"
#else
#define FloatImpType	   float
#define FloatPro	   double  /* type to use in prototypes		   */
				   /* strictly ansi (i.e. gcc) conforming  */
				   /* but breaks data hiding :-(	   */
#define FloatFMT	   "%g"
#endif
#else
#define FloatImpType	   int     /*dummy*/
#define FloatPro	   int
#define FloatFMT	   "%d"
#endif

#ifndef FILENAME_MAX	   /* should already be defined in an ANSI compiler*/
#define FILENAME_MAX 256
#else
#if     FILENAME_MAX < 256
#undef  FILENAME_MAX
#define FILENAME_MAX 256
#endif
#endif

#define DEF_EDITOR	   "vi"			/* replace with ((char *)0)*/
#define DEF_EDITLINE	   "vi +%d %s"		/* if no default editor rqd*/

/*-------------------------------------------------------------------------*/
