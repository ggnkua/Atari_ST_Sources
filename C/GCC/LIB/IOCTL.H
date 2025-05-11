/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 *  Some fields in these structures are igored, like the t_suspc/dsuspc and
 * t_startc/stopc and t_flushc.  Should add an extra field somewhere for
 * an extra erase character so both ^H and ^? would work.
 *
 * $Header: ioctl.h,v 1.1 88/02/03 20:14:16 m68k Exp $
 *
 * $Log:	ioctl.h,v $
 * Revision 1.1  88/02/03  20:14:16  m68k
 * Initial revision
 * 
 */
#ifndef	_IOCTL_
# define _IOCTL_

#define	TIOCGETP	0x0000		/* sgttyb */
#define	TIOCSETP	0x0001
#define	TIOCGETC	0x0002		/* tchars */
#define	TIOCSETC	0x0003
#define	TIOCGLTC	0x0004		/* ltchars */
#define	TIOCSLTC	0x0005

struct tchars {
	char	t_intrc;
	char	t_quitc;
	char	t_startc;
	char	t_stopc;
	char	t_eofc;
	char	t_brkc;
};

struct ltchars {
	char	t_suspc;
	char	t_dsuspc;
	char	t_rprntc;
	char	t_flushc;
	char	t_werasc;
	char	t_lnextc;
};

#define	CRMOD		0x0001
#define	CBREAK		0x0002
#define	ECHO		0x0004
#define	XTABS		0x0008
#define	RAW		0x0010
#define	LCASE		0x0000		/* does nothing (and never will!) */
#define	TANDEM		0x0000		/* not needed */

/* Only ones that are likely to be used are here */
#define	B300		0
#define	B1200		1
#define	B2400		2
#define	B4800		3
#define	B6900		4

struct sgttyb {
	char	sg_ispeed;
	char	sg_ospeed;
	char	sg_erase;
	char	sg_kill;
	short	sg_flags;
};
#endif	/* _IOCTL_ */
