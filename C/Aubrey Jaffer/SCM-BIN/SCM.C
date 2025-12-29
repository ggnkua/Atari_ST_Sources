/* Scheme implementation intended for JACAL.
   Copyright (C) 1990, 1991, 1992 Aubrey Jaffer.

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

#include <stdio.h>
#include <signal.h>
#include "scm.h"
#include "patchlvl.h"

void init_banner()
{
  fputs("SCM version ",stdout);
  fputs(SCMVERSION,stdout);
  intprint((long)PATCHLEVEL,10,stdout);
  puts(", Copyright (C) 1990, 1991, 1992 Aubrey Jaffer.\n\
SCM comes with ABSOLUTELY NO WARRANTY; for details type `(terms)'.\n\
This is free software, and you are welcome to redistribute it\n\
under certain conditions; type `(terms)' for details.");
}

#if (__TURBOC__==1)
#define signal ssignal		/* Needed for TURBOC V1.0 */
#endif

/* SIGRETTYPE is the type that signal handlers return.  See <signal.h>*/

#ifdef STDC_HEADERS
# if (__TURBOC__ == 1)
#  define SIGRETTYPE int
# else
#  define SIGRETTYPE void
# endif
#else
# define SIGRETTYPE int
#endif

#ifdef SIGHUP
SIGRETTYPE hup_signal(sig)
int sig;
{
	signal(SIGHUP,hup_signal);
	wta(UNDEFINED,(char *)HUP_SIGNAL,"");
}
#endif
SIGRETTYPE int_signal(sig)
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
SIGRETTYPE fpe_signal(sig)
int sig;
{
	signal(SIGFPE,fpe_signal);
	wta(UNDEFINED,(char *)FPE_SIGNAL,"");
}
#endif
#ifdef SIGBUS
SIGRETTYPE bus_signal(sig)
int sig;
{
	signal(SIGBUS,bus_signal);
	wta(UNDEFINED,(char *)BUS_SIGNAL,"");
}
#endif
#ifdef SIGSEGV			/* AMIGA lacks! */
SIGRETTYPE segv_signal(sig)
int sig;
{
	signal(SIGSEGV,segv_signal);
	wta(UNDEFINED,(char *)SEGV_SIGNAL,"");
}
#endif
#ifdef atarist
#undef SIGALRM			/* only available via MiNT libs */
#endif
#ifdef SIGALRM
SIGRETTYPE alrm_signal(sig)
int sig;
{
	sig = errno;
	signal(SIGALRM,alrm_signal);
	if (ints_disabled) alrm_deferred = 1;
	else han_alrm();
	errno = sig;
}
static char s_alarm[]="alarm";
SCM lalarm(i)
     SCM i;
{
  SCM j;
  ASSERT(INUMP(i) && (INUM(i) >= 0),i,ARG1,s_alarm);
  SYSCALL(j = MAKINUM(alarm(INUM(i))););
  return j;
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

void init_scm( display_banner )
  int display_banner;
{
  SCM i;
  stack_start_ptr = &i;		/* stack_start_ptr gets set */
  if (display_banner) init_banner();
  init_tables();
  init_storage();
  init_subrs();
  init_io();
  init_scl();
  init_features();
  init_time();
  init_repl();
#ifdef SIGALRM
  make_subr(s_alarm,tc7_subr_1,lalarm);
#endif
#ifdef REV2_PROCEDURES
  init_sc2();
#endif
  INITS;			/* call initialization of user extensions */
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
  oldalrm = signal(SIGALRM,alrm_signal);
#endif
#ifdef SIGPIPE
  oldpipe = signal(SIGPIPE,SIG_IGN);
#endif
}

/* This is used in preparation for a possible fork().  Ignore all
   signals before the fork so that child will catch only if it
   establishes a handler */
void ignore_signals()
{
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
}

void restore_signals()
{
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
#ifdef SIGALRM
 signal(SIGALRM,oldalrm);
#endif
#ifdef SIGPIPE
  signal(SIGPIPE,oldpipe);
#endif
}

int run_scm(display_banner,argc,argv)
int display_banner;
int argc;
char **argv;
{
  SCM i;
  init_scm( display_banner );
  init_signals();
  i = repl_driver(argc, argv);
  restore_signals();
  if (display_banner) puts(";EXIT");
  return (int)INUM(i);
}

#ifndef RTL
int main( argc, argv )
  int argc;
  char **argv;
{
  return run_scm( argc <= 1, argc, argv );
}
#endif
