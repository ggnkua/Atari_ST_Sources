/* 
 * @(#)signal.h, XdLibs - SozobonX
 * last change
 *  -jerry: 1995/03/20
 */

#ifndef _SIGNAL_H
#define _SIGNAL_H


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


typedef void (*_Sigfunc)(long signum);

#define       SIG_DFL	((_Sigfunc)0L)
#define       SIG_IGN	((_Sigfunc)1L)
#define       SIG_ERR	((_Sigfunc)-1L)


/* sigaction: extended POSIX signal handling facility */

struct sigaction {
	_Sigfunc sa_handler;	/* pointer to signal handler */
	unsigned long	sa_mask;	/* additional signals masked during delivery */
	unsigned short	sa_flags;	/* signal specific flags */
	/* signal flags */
#define SA_NOCLDSTOP	1	/* don't send SIGCHLD when child stops */
};

#ifdef __MSHORT__

extern long gemdos();

#define signal(sig, handler) \
				(_Sigfunc)gemdos(0x112, (short)sig, (long)handler)
#define	sigblock(mask)		\
				gemdos(0x116, (unsigned long)(mask))
#define	sigsetmask(mask)	\
				gemdos(0x117, (unsigned long)(mask))
#define	sigpending() 			gemdos(0x123)
#define	sigreturn() 			gemdos(0x11a)
#define	sigaction(sig, act, oact) \
		gemdos(0x137, (short)(sig), (long)(act), (long)(oact))
#else

#include <osbind.h>
#define	signal(sig, handler)	(_Sigfunc)Psignal((sig), (handler))
#define	sigblock(mask)		Psigblock(mask)
#define	sigsetmask(mask)	Psigsetmask(mask)
#define	sigpending()		Psigpending()
#define	sigreturn()		Psigreturn()
#define	sigaction(sig, act, oact) \
				Psigaction((sig), (act), (oact))
#endif /* __MSHORT__ */

#endif /* _SIGNAL_H */

