/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 *  Beware the SIGINT/SIGQUIT - right now they only work when you are read()ing
 *
 * $Header: signal.h,v 1.1 88/02/03 20:06:23 m68k Exp $
 *
 * $Log:	signal.h,v $
 * Revision 1.1  88/02/03  20:06:23  m68k
 * Initial revision
 * 
 */
#define	NSIG		12

#define	SIGNULL		0		/* The null signal */
#define	SIGALRM		1		/* If SIGALRM changes, change the value
					 * in lib/libc/atari/alrm_nasty.s too!
					 */
/* this block are just trap numbers.  I made up most of these names... */
#define SIGBUS		2
#define	SIGODD		3
#define SIGILL		4
#define SIGZDIV		5
#define SIGCHK		6
#define SIGTRAP		7
#define SIGPRIV		8
#define SIGTRACE	9


#define	SIGINT		10		/* ^C (struct tchars t_intc) */
#define	SIGQUIT		11		/* ^\ (struct tchars t_quitc) */

/* some values that Eunuchs programs seem to want */
#define SIGHUP	SIGNULL
#define SIGIOT	SIGNULL
#define SIGEMT	SIGNULL
#define SIGFPE	SIGNULL
#define SIGSEGV	SIGNULL
#define SIGSYS	SIGNULL
#define SIGTERM	SIGNULL

#define	SIG_DFL		((int (*)()) 0)
#define	SIG_IGN		((int (*)()) 1)
#define	BADSIG		((int (*)()) -1)

int	(*signal())();
