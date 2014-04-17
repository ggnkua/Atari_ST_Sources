#ifndef _SIGNAL_H_
#define _SIGNAL_H_

#define	NSIG		31		/* number of signals recognized */

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



#define SIG_DFL	0x0L
#define SIG_IGN	0x1L
#define SIG_ERR	0xFFFFFFFFL

#endif

