/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 *  These to keep track of the current special characters and tty mode.
 *
 * $Header: tchars.c,v 1.1 88/02/03 22:58:46 m68k Exp $
 *
 * $Log:	tchars.c,v $
 * Revision 1.1  88/02/03  22:58:46  m68k
 * Initial revision
 * 
 */
#include	<ioctl.h>
#include	"tchars.h"

int	__ttymode = CRMOD|ECHO|XTABS;
char	__tchars[10] = {
			010,		/* TC_ERASE - ^H */
			025,		/* TC_KILL - ^U */
			003,		/* TC_INTRC - ^C */
			034,		/* TC_QUITC - ^\ */
			032,		/* TC_EOFC - ^Z */
			TC_UNDEF,	/* TC_BRKC - undefined */
			022,		/* TC_RPRNTC - ^R */
			027,		/* TC_WREASC - ^W */
			026,		/* TC_LNEXTC - ^V */
			0177		/* TC_RUBOUT - RUB */
		};
