#ifndef _SIGNAL_H
#define _SIGNAL_H

#ifndef _COMPILER_H
#include <compiler.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#define	__NSIG		31		/* number of signals recognized */

#ifndef _POSIX_SOURCE
# define NSIG __NSIG
#endif /* _POSIX_SOURCE */

#define	SIGNULL		0		/* not really a signal */
#define SIGHUP		1		/* hangup signal */
#define SIGINT		2		/* sent by ^C */
#define SIGQUIT		3		/* quit signal */
#define SIGILL		4		/* illegal instruction */
#define SIGTRAP		5		/* trace trap */
#define SIGABRT		6		/* abort signal */
# define SIGIOT SIGABRT
#define SIGPRIV		7		/* privilege violation */
# define SIGEMT SIGPRIV
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

#ifndef AssemB

typedef void __CDECL (*__Sigfunc) __PROTO((int signum));
typedef short sig_atomic_t;

#define       SIG_DFL	((__Sigfunc)0L)
#define       SIG_IGN	((__Sigfunc)1L)
#define       SIG_ERR	((__Sigfunc)-1L)

__EXTERN __Sigfunc	signal	__PROTO((int sig, __Sigfunc func));
__EXTERN int		raise	__PROTO((int sig));
__EXTERN int		kill	__PROTO((int, int));
#ifndef _POSIX_SOURCE
__EXTERN int		killpg	__PROTO((int, int));
#endif /* _POSIX_SOURCE */

#define _SIGSET_INDEX(__sig)	(__sig / 32)
#define _SIGSET_BITPOS(__sig)	(__sig % 32)
#define _SIGSET_MAX_INDEX	(__NSIG / 32)

typedef struct {
  long __sigset_data[_SIGSET_MAX_INDEX + 1];
} sigset_t;

#ifdef __MINT__
# ifndef __STRICT_ANSI__
struct sigaction {
	__Sigfunc	sa_handler;	/* pointer to signal handler */
	sigset_t	sa_mask;	/* additional signals masked during delivery */
/* pain here... POSIX forces us to use int, we would prefer short */
	int 		sa_flags;	/* signal specific flags */
/* signal flags */
#define SA_NOCLDSTOP	1	/* don't send SIGCHLD when they stop */
};

#ifdef __MSHORT__
__EXTERN long	sigsetmask  __PROTO((long mask));
__EXTERN long	sigblock    __PROTO((long mask));
#else
__EXTERN int	sigsetmask  __PROTO((long mask));
__EXTERN int	sigblock    __PROTO((long mask));
#endif
__EXTERN int	sigaction   __PROTO((int, const struct sigaction *,
					struct sigaction *));
__EXTERN int	sigaddset   __PROTO((sigset_t *set, int signo));
__EXTERN int	sigdelset   __PROTO((sigset_t *set, int signo));
__EXTERN int	sigemptyset __PROTO((sigset_t *set));
__EXTERN int	sigfillset  __PROTO((sigset_t *set));
__EXTERN int	sigismember __PROTO((sigset_t *set, int signo));
__EXTERN int	sigpending  __PROTO((sigset_t *set));
__EXTERN int	sigprocmask __PROTO((int how, const sigset_t *set,
					sigset_t *oset));
__EXTERN int	sigsuspend  __PROTO((const sigset_t *sigmask));

/* values for "how" parameter to sigprocmask() */
#define SIG_BLOCK	0
#define SIG_UNBLOCK	1
#define SIG_SETMASK	2

#ifndef _POSIX_SOURCE
/* a mask for signals */
#define sigmask(__sig) (1L << (__sig))
#endif /* _POSIX_SOURCE */

# endif /* __STRICT_ANSI__ */
#endif /* __MINT__ */

#endif /* AssemB */

#ifdef __cplusplus
}
#endif

#endif /* _SIGNAL_H */
