/* Scheme implementation intended for JACAL.
   Copyright (C) 1990, 1991, 1992, 1993, 1994 Aubrey Jaffer.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 1, or (at your option)
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

The author can be reached at jaffer@ai.mit.edu or
Aubrey Jaffer, 84 Pleasant St., Wakefield MA 01880
*/

#include <signal.h>
#include "scm.h"
#include "patchlvl.h"

void init_banner()
{
  fputs("SCM version ",stderr);
  fputs(SCMVERSION,stderr);
  fputs(", Copyright (C) 1990, 1991, 1992, 1993, 1994 Aubrey Jaffer.\n\
SCM comes with ABSOLUTELY NO WARRANTY; for details type `(terms)'.\n\
This is free software, and you are welcome to redistribute it\n\
under certain conditions; type `(terms)' for details.\n",stderr);
}

#if (__TURBOC__==1)
#define signal ssignal		/* Needed for TURBOC V1.0 */
#endif

/* SIGRETTYPE is the type that signal handlers return.  See <signal.h>*/

#ifdef RETSIGTYPE
# define SIGRETTYPE RETSIGTYPE
#else
# ifdef STDC_HEADERS
#  if (__TURBOC__==1)
#   define SIGRETTYPE int
#  else
#   define SIGRETTYPE void
#  endif
# else
#  ifdef linux
#   define SIGRETTYPE void
#  else
#   define SIGRETTYPE int
#  endif
# endif
#endif

#ifdef SIGHUP
static SIGRETTYPE hup_signal(sig)
int sig;
{
	signal(SIGHUP,hup_signal);
	wta(UNDEFINED,(char *)HUP_SIGNAL,"");
}
#endif
static SIGRETTYPE int_signal(sig)
int sig;
{
	sig = errno;
	signal(SIGINT,int_signal);
	if (ints_disabled) sig_deferred = 1;
	else han_sig();
	errno = sig;
}

/* If doesn't have SIGFPE, disable FLOATS for the rest of this file. */

#ifndef SIGFPE
#undef FLOATS
#endif

#ifdef FLOATS
static SIGRETTYPE fpe_signal(sig)
int sig;
{
	signal(SIGFPE,fpe_signal);
	wta(UNDEFINED,(char *)FPE_SIGNAL,"");
}
#endif
#ifdef SIGBUS
static SIGRETTYPE bus_signal(sig)
int sig;
{
	signal(SIGBUS,bus_signal);
	wta(UNDEFINED,(char *)BUS_SIGNAL,"");
}
#endif
#ifdef SIGSEGV			/* AMIGA lacks! */
static SIGRETTYPE segv_signal(sig)
int sig;
{
	signal(SIGSEGV,segv_signal);
	wta(UNDEFINED,(char *)SEGV_SIGNAL,"");
}
#endif
#ifdef atarist
# undef SIGALRM			/* only available via MiNT libs */
#endif
#ifdef GO32
# undef SIGALRM
#endif
#ifdef SIGALRM
static SIGRETTYPE alrm_signal(sig)
int sig;
{
	sig = errno;
	signal(SIGALRM,alrm_signal);
	if (ints_disabled) alrm_deferred = 1;
	else han_alrm();
	errno = sig;
}
static char s_alarm[] = "alarm";
SCM lalarm(i)
     SCM i;
{
  SCM j;
  ASSERT(INUMP(i) && (INUM(i) >= 0),i,ARG1,s_alarm);
  SYSCALL(j = MAKINUM(alarm(INUM(i))););
  return j;
}
#endif
#ifdef TICKS
unsigned int tick_count = 0, ticken = 0;
SCM *loc_tick_signal;
void tick_signal()
{
  if (ticken && NIMP(*loc_tick_signal)) {
    ticken = 0;
    apply(*loc_tick_signal,EOL,EOL);
  }
}
static char s_ticks[] = "ticks";
SCM lticks(i)
     SCM i;
{
  SCM j = ticken ? tick_count : 0;
  if (!UNBNDP(i)) ticken = tick_count = INUM(i);
  return MAKINUM(j);
}
#endif

#ifdef SIGHUP
static SIGRETTYPE (*oldhup)();
#endif
static SIGRETTYPE (*oldint)();
#ifdef FLOATS
static SIGRETTYPE (*oldfpe)();
#endif
#ifdef SIGBUS
static SIGRETTYPE (*oldbus)();
#endif
#ifdef SIGSEGV			/* AMIGA lacks! */
static SIGRETTYPE (*oldsegv)();
#endif
#ifdef SIGALRM
static SIGRETTYPE (*oldalrm) ();
#endif
#ifdef SIGPIPE
static SIGRETTYPE (*oldpipe) ();
#endif

#ifdef SHORT_ALIGN
typedef short STACKITEM;
#else
typedef long STACKITEM;
#endif

void init_scm( iverbose )
  int iverbose;
{
  STACKITEM i;
  if (2 <= iverbose) init_banner();
  init_types();
  init_tables();
  init_storage(&i);		/* BASE(rootcont) gets set here */
  init_features();
  init_subrs();
  init_io();
  init_scl();
  init_eval();
  init_time();
  init_repl( iverbose );
  init_unif();
}

void init_signals()
{
  oldint = signal(SIGINT,int_signal);
#ifdef SIGHUP
  oldhup = signal(SIGHUP,hup_signal);
#endif
#ifdef FLOATS
  oldfpe = signal(SIGFPE,fpe_signal);
#endif
#ifdef SIGBUS
  oldbus = signal(SIGBUS,bus_signal);
#endif
#ifdef SIGSEGV			/* AMIGA lacks! */
  oldsegv = signal(SIGSEGV,segv_signal);
#endif
#ifdef SIGALRM
  alarm(0);			/* kill any pending ALRM interrupts */
  oldalrm = signal(SIGALRM,alrm_signal);
#endif
#ifdef SIGPIPE
  oldpipe = signal(SIGPIPE,SIG_IGN);
#endif
#ifdef ultrix
  siginterrupt(SIGINT,1);
  siginterrupt(SIGALRM,1);
  siginterrupt(SIGHUP,1);
  siginterrupt(SIGPIPE,1);
#endif /* ultrix */
}

/* This is used in preparation for a possible fork().  Ignore all
   signals before the fork so that child will catch only if it
   establishes a handler */
void ignore_signals()
{
#ifdef ultrix
  siginterrupt(SIGINT,0);
  siginterrupt(SIGALRM,0);
  siginterrupt(SIGHUP,0);
  siginterrupt(SIGPIPE,0);
#endif /* ultrix */
  signal(SIGINT,SIG_IGN);
#ifdef SIGHUP
  signal(SIGHUP,SIG_DFL);
#endif
#ifdef FLOATS
  signal(SIGFPE,SIG_DFL);
#endif
#ifdef SIGBUS
  signal(SIGBUS,SIG_DFL);
#endif
#ifdef SIGSEGV			/* AMIGA lacks! */
  signal(SIGSEGV,SIG_DFL);
#endif
  /* Some documentation claims that ALRMs are cleared accross forks.
     If this is not always true then the value returned by alarm(0)
     will have to be saved and unignore_signals() will have to
     reinstate it. */
  /* This code should be neccessary only if the forked process calls
     alarm() without establishing a handler:
     #ifdef SIGALRM
     oldalrm = signal(SIGALRM,SIG_DFL);
     #endif */
  /* These flushes are per warning in man page on fork(). */
  fflush(stdout);
  fflush(stderr);
}

void unignore_signals()
{
  signal(SIGINT,int_signal);
#ifdef SIGHUP
  signal(SIGHUP,hup_signal);
#endif
#ifdef FLOATS
  signal(SIGFPE,fpe_signal);
#endif
#ifdef SIGBUS
  signal(SIGBUS,bus_signal);
#endif
#ifdef SIGSEGV			/* AMIGA lacks! */
  signal(SIGSEGV,segv_signal);
#endif
#ifdef SIGALRM
  signal(SIGALRM,alrm_signal);
#endif
#ifdef ultrix
  siginterrupt(SIGINT,1);
  siginterrupt(SIGALRM,1);
  siginterrupt(SIGHUP,1);
  siginterrupt(SIGPIPE,1);
#endif /* ultrix */
}

void restore_signals()
{
#ifdef ultrix
  siginterrupt(SIGINT,0);
  siginterrupt(SIGALRM,0);
  siginterrupt(SIGHUP,0);
  siginterrupt(SIGPIPE,0);
#endif /* ultrix */
  signal(SIGINT,oldint);
#ifdef SIGHUP
  signal(SIGHUP,oldhup);
#endif
#ifdef FLOATS
  signal(SIGFPE,oldfpe);
#endif
#ifdef SIGBUS
  signal(SIGBUS,oldbus);
#endif
#ifdef SIGSEGV			/* AMIGA lacks! */
  signal(SIGSEGV,oldsegv);
#endif
#ifdef SIGPIPE
  signal(SIGPIPE,oldpipe);
#endif
#ifdef SIGALRM
  alarm(0);			/* kill any pending ALRM interrupts */
  signal(SIGALRM,oldalrm);
#endif
}

extern char **execargv;
int run_scm(argc,argv,iverbose,initpath)
int argc;
char **argv;
int iverbose;
char *initpath;
{
  SCM i;
  do {
    init_scm( iverbose );
    progargs = EOL;
    i = argc;
    while (i--)
      progargs = cons(makfromstr(argv[i],
				 (sizet)strlen(argv[i])), progargs);
#ifdef SIGALRM
    make_subr(s_alarm,tc7_subr_1,lalarm);
#endif
#ifdef TICKS
    loc_tick_signal = &CDR(sysintern("ticks-interrupt", UNDEFINED));
    make_subr(s_ticks,tc7_subr_1o,lticks);
#endif
#ifdef INITS
    INITS;			/* call initialization of extensions files */
#endif
    init_signals();
    i = repl_driver(initpath);
    restore_signals();
#ifdef TICKS
    ticken = 0;
#endif
#ifdef FINALS
    FINALS;			/* call shutdown of extensions files */
#endif				/* for compatability with older modules */
    /* call finalization of user extensions */
    while (num_finals--) (finals[num_finals])();
    final_repl();
    free_storage();			/* free all allocated memory */
#ifndef THINK_C
# ifndef __WATCOMC__
#  ifndef GO32
    if (execargv) {
      execvp(execargv[0],execargv);
      perror(execargv[0]);
      return errno;
    }
#  endif
# endif
#endif
    if (i) break;
    if (2 <= iverbose) fputs(";RESTART\n",stderr);
  } while (!0);
  if (2 <= iverbose) fputs(";EXIT\n",stderr);
  fflush(stderr);
  return (int)INUM(i);
}

#ifndef RTL
char *getenv();
int main( argc, argv )
     int argc;
     char **argv;
{
#ifdef IMPLINIT
  char *initpath = IMPLINIT;
#else
  char *initpath = "";
#endif
#ifndef nosve
  if (getenv("SCM_INIT_PATH")) initpath = getenv("SCM_INIT_PATH");
#endif
#ifndef NOSETBUF
# ifndef GO32
#  ifndef _DCC
#   ifndef ultrix
#    ifndef __WATCOMC__
#     ifndef THINK_C
#      if (__TURBOC__ != 1)
  if (isatty(fileno(stdin))) setbuf(stdin,0); /* turn off stdin buffering */
#      endif
#     endif
#    endif
#   endif
#  endif
# endif
#endif
  return run_scm(argc, argv,
		 (isatty(fileno(stdin)) && isatty(fileno(stdout)))
		 ? (argc <= 1) ? 2 : 1 : 0,
		 initpath);
}
#endif
