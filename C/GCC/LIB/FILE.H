/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 * $Header: file.h,v 1.1 88/01/29 17:22:27 m68k Exp $
 *
 * $Log:	file.h,v $
 * Revision 1.1  88/01/29  17:22:27  m68k
 * Initial revision
 * 
 */

/*
 *  open
 */
#define	O_RDONLY		0x00
#define	O_WRONLY		0x01
#define	O_RDWR			0x02
#define	O_NDELAY		0	/* not implemented */
#define	O_APPEND		0x04
#define	O_CREAT			0x08
#define	O_TRUNC			0x10
#define	O_EXCL			0x20

/*
 * access
 */
#define	F_OK			0
#define	X_OK			1
#define	W_OK			2
#define	R_OK			4

/*
 * lseek
 */
#define	L_SET			0
#define	L_INCR			1
#define	L_XTND			2

/* defs for handle frob */

#define N_HANDLES	64

extern char __handle_stat[];

#define FH_UNKNOWN	0
#define FH_ISATTY	1
#define FH_ISAFILE	2

/* maybe more later */

