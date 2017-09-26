
/****************************************************************************/
/*									    */
/*		    S i g n a l   H e a d e r   F i l e			    */
/*		    -----------------------------------			    */
/*									    */
/*	Copyright 1982 by Digital Research, Inc.  All rights reserved.	    */
/*									    */
/*	Define the "signal" arguments, so anyone using the function will    */
/*	not get compile-time errors.  Some functions are not implemented.   */
/*									    */
/****************************************************************************/
#define	NSIG	16			/* 16 simulated signals		    */
#define	SIGHUP	 1			/* Hangup			    */
#define	SIGINT	 2			/* Interrupt (^C)		    */
#define	SIGQUIT	 3			/* Quit signal			    */
#define	SIGILL	 4			/* Illegal Instruction trap	    */
#define	SIGTRAP	 5			/* Trace Trap			    */
#define	SIGIOT	 6			/* IOT instruction (on PDP-11)	    */
#define	SIGEMT	 7			/* EMT instruction (TRAP on 68k)    */
#define	SIGFPE	 8			/* Floating point exception	    */
#define	SIGKILL	 9			/* Kill (cannot be intercepted)	    */
#define	SIGBUS	10			/* BUSERR (non-ex memory reference) */
#define	SIGSEGV	11			/* Segmentation (MMU) violation	    */
#define	SIGSYS	12			/* Bad argument to system call	    */
#define	SIGPIPE	13			/* Write on a broken pipe	    */
#define	SIGALRM	14			/* Alarm clock (what a name!)	    */
#define	SIGTERM	15			/* Software termination signal 	    */
					/************************************/
#define	BADSIG	(-1L)			/* Error return			    */
#define	SIG_DFL	(0L)			/* Default action on signal call    */
#define	SIG_IGN (1L)			/* Ignore			    */
					/************************************/

