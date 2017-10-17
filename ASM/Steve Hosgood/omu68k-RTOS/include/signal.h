
#define NSIG	32

#define	SIGHUP	1	/* hangup */
#define	SIGINT	2	/* interrupt */
#define	SIGQUIT	3	/* quit */
#define	SIGILL	4	/* illegal instruction (not reset when caught) */

#define	SIGTRAP	5	/* trace trap (not reset when caught) */
#define	SIGIOT	6	/* IOT instruction */
#define	SIGEMT	7	/* EMT instruction */
#define	SIGFPE	8	/* floating point exception */
#define		KINTOVFT 0x1		/* integer overflow */
#define		KINTDIVT 0x2		/* integer divide by zero */
#define		KFLTOVFT 0x3		/* floating overflow */
#define		KFLTDIVT 0x4		/* floating/decimal divide by zero */
#define		KFLTUNDT 0x5		/* floating underflow */
#define		KDECOVFT 0x6		/* decimal overflow */
#define		KSUBRNGT 0x7		/* subscript out of range */
#define		KFLTOVFF 0x8		/* floating overflow fault */
#define		KFLTDIVF 0x9		/* divide by zero floating fault */
#define		KFLTUNDF 0xa		/* floating underflow fault */
#define	SIGKILL	9	/* kill (cannot be caught or ignored) */
#define	SIGBUS	10	/* bus error */
#define	SIGSEGV	11	/* segmentation violation */
#define	SIGSYS	12	/* bad argument to system call */
#define	SIGPIPE	13	/* write on a pipe with no one to read it */
#define	SIGALRM	14	/* alarm clock */
#define	SIGTERM	15	/* software termination signal from kill */

#define	SIGSTOP	17	/* sendable stop signal not from tty */
#define	SIGTSTP	18	/* stop signal from tty */
#define	SIGCONT	19	/* continue a stopped process */
#define	SIGCHLD	20	/* to parent on child stop or exit */
#define	SIGTTIN	21	/* to readers pgrp upon background tty read */
#define	SIGTTOU	22	/* like TTIN for output if (tp->t_local&LTOSTOP) */
#define SIGTINT	23	/* to pgrp on every input character if LINTRUP */
#define	SIGXCPU	24	/* exceeded CPU time limit */
#define	SIGXFSZ	25	/* exceeded file size limit */
#define SIGSTAT 26	/* status update requested */
#define SIGMOUS 27	/* mouse interrupt */

/*	OMU ADDITIONS for file events and process comunications		*/

#define	SIGEVFILE 28	/* Signal when a stream has data for the process
			 * Note only called when  process has set the
			 * file event enable bit map in the process table
			 * Using the onfile() function call.
			 * Works on TTY's and pipes normaly
			 */
#define	SIGEVCOMMS 29	/* Signal that can be sent to a process from another
			 * To indicate some event.
			 */

#ifndef KERNEL
int	(*signal())();
#endif

#define	BADSIG		(int (*)())-1
#define	SIG_DFL		(int (*)())0
#define	SIG_IGN		(int (*)())1
#ifdef KERNEL
#define	SIG_CATCH	(int (*)())2
#endif
#define	SIG_HOLD	(int (*)())3

#define	SIGISDEFER(x)	(((int)(x) & 1) != 0)
#define	SIGUNDEFER(x)	(int (*)())((int)(x) &~ 1)
#define	DEFERSIG(x)	(int (*)())((int)(x) | 1)

#define	SIGNUMMASK	0377		/* to extract pure signal number */
#define	SIGDOPAUSE	0400		/* do pause after setting action */
#define	SIGDORTI	01000		/* do ret+rti after setting action */
/* #endif JSC */

/* old fashioned unix stuff */
#ifdef KERNEL
#define SIGINS	SIGILL
#define SIGTRC	SIGTRAP
#define SIGFPT	SIGFPE
#define SIGKIL	SIGKILL
#define SIGSEG	SIGSEGV
#define SIGCLK	SIGALRM
#define SIGTRM	SIGTERM
#endif

/* Omu special signal mode */
#define	SIGMODEUNIX	0		/* Normal unix signal mode */
#define	SIGMODEOMU	1		/* Special OMU signal mode */

#define	MASKALLSIG	0xFFFFFFFF	/* Mask all signals */
#define	ENALLSIG	0		/* Enable all signals */
