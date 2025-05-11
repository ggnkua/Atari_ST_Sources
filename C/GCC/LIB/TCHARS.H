/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 *  The TC defines are indices into the __tchars array.
 *
 * $Header: tchars.h,v 1.1 88/02/03 22:58:50 m68k Exp $
 *
 * $Log:	tchars.h,v $
 * Revision 1.1  88/02/03  22:58:50  m68k
 * Initial revision
 * 
 */
#define	TC_ERASE	0
#define	TC_KILL		1
#define	TC_INTRC	2
#define	TC_QUITC	3
#define	TC_EOFC		4
#define	TC_BRKC		5
#define	TC_RPRNTC	6
#define	TC_WERASC	7
#define	TC_LNEXTC	8
#define TC_RUBOUT	9
#define	TC_UNDEF	-1

extern	char	__tchars[];
extern	int	__ttymode;
