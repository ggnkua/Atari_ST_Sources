/*
 * signals.h -- signals for the Atari ST.
 *
 * Copyright (c) 1986-1987, Mark Williams Company, Chicago
 * This file and its contents may not be copied or distributed
 * without permission.
 */

#ifndef	 SIG_H
#define	 SIG_H
/*
 * arguments to signal
 */
#define SIG_DFL	((int(*)())0)
#define SIG_IGN	((int(*)())1)

/*
 * M68000 machine exceptions
 */
#define SIGBUS	2			/* Bus error */
#define SIGADDR	3			/* Address error */
#define SIGILL	4			/* Illegal instruction */
#define SIGDIV	5			/* Zero divide */
#define SIGCHK	6			/* chk instruction */
#define SIGOVF	7			/* trapv instruction */
#define SIGPRIV	8			/* Privilege violation */
#define SIGTRAC	9			/* Trace trap */
#define SIGLINA	10			/* 1010 emulation */
#define SIGLINF	11			/* line 1111 emulation */

/*
 * M68000 trap instructions
 */
#define SIGT0	32			/* trap $0 */
#define SIGT1	33			/* trap $1 */
#define SIGT2	34			/* trap $2 */
#define SIGT3	35			/* trap $3 */
#define SIGT4	36			/* trap $4 */
#define SIGT5	37			/* trap $5 */
#define SIGT6	38			/* trap $6 */
#define SIGT7	39			/* trap $7 */
#define SIGT8	40			/* trap $8 */
#define SIGT9	41			/* trap $9 */
#define SIGT10	42			/* trap $10 */
#define SIGT11	43			/* trap $11 */
#define SIGT12	44			/* trap $12 */
#define SIGT13	45			/* trap $13 */
#define SIGT14	46			/* trap $14 */
#define SIGT15	47			/* trap $15 */

/*
 * GEM-DOS aliases
 */
#define SIGDOS	SIGT1			/* GEM-DOS vector */
#define SIGGEM	SIGT2			/* AES/VDI/GSX vector */
#define SIGBIOS	SIGT13			/* BIOS vector */
#define SIGXBIOS SIGT14			/* XBIOS vector */

/*
 * COHERENT/V7 assignments, unassigned traps
 */
#define SIGHUP	SIGT3			/* Hangup */
#define	SIGINT	SIGT4			/* Interrupt */
#define SIGQUIT	SIGT5			/* Quit */
#define SIGALRM	SIGT6			/* Alarm */
#define SIGTERM	SIGT7			/* Software termination signal */
#define SIGREST	SIGT8			/* Restart */
#define SIGSYS	SIGT9			/* Bad argument to system call */
#define	SIGPIPE	SIGT10			/* Write to pipe with no readers */
#define SIGKILL	SIGT11			/* Kill */
#define SIGTRAP	SIGT12			/* Breakpoint */
#define	SIGSEGV	SIGBUS			/* Segmentation violation */

#define NSIG	48

/*
 * GEM-DOS logical vectors.
 *
 * These cannot be set with signal() because they are called in an
 * unusual way, and must return in the same manner.
 * They are included for completeness.
 */
#define ETVTIMER	256
#define ETVCRITIC	257
#define ETVTERM		258

/*
 * For the benefit of user programs:
 */
int	(*signal())();

#endif

/* End of signal.h */
