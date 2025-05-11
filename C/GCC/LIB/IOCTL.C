/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 *  A simple hack for ioctl - note that some fields of the structures are not
 * filled in.
 *
 * $Header: ioctl.c,v 1.1 88/02/03 22:58:56 m68k Exp $
 *
 * $Log:	ioctl.c,v $
 * Revision 1.1  88/02/03  22:58:56  m68k
 * Initial revision
 * 
 */
#include	<ioctl.h>
#include	<errno.h>
#include	"tchars.h"

int
ioctl(fd, func, arg)
	int	fd;
	int	func;
	char	*arg;
{
	struct sgttyb	*sg;
	struct tchars	*tc;
	struct ltchars	*ltc;

	if (!isatty(fd)) {
		errno = ENOTTY;
		return -1;
	}
	switch (func) {
	case TIOCGETP:
		sg = (struct sgttyb *) arg;
		sg->sg_ispeed = sg->sg_ospeed = B4800;
		sg->sg_erase = __tchars[TC_ERASE];
		sg->sg_kill = __tchars[TC_KILL];
		sg->sg_flags = __ttymode;
		break;

	case TIOCSETP:
		sg = (struct sgttyb *) arg;
		__tchars[TC_ERASE] = sg->sg_erase;
		__tchars[TC_KILL] = sg->sg_kill;
		__ttymode = sg->sg_flags;
		break;

	case TIOCGETC:
		tc = (struct tchars *) arg;
		tc->t_intrc = __tchars[TC_INTRC];
		tc->t_quitc = __tchars[TC_QUITC];
		tc->t_startc = TC_UNDEF;
		tc->t_stopc = TC_UNDEF;
		tc->t_eofc = __tchars[TC_EOFC];
		tc->t_brkc = __tchars[TC_BRKC];
		break;

	case TIOCSETC:
		tc = (struct tchars *) arg;
		__tchars[TC_INTRC] = tc->t_intrc;
		__tchars[TC_QUITC] = tc->t_quitc;
		__tchars[TC_EOFC] = tc->t_eofc;
		__tchars[TC_BRKC] = tc->t_brkc;
		break;

	case TIOCGLTC:
		ltc = (struct ltchars *) arg;
		ltc->t_suspc = TC_UNDEF;
		ltc->t_dsuspc = TC_UNDEF;
		ltc->t_rprntc = __tchars[TC_RPRNTC];
		ltc->t_flushc = TC_UNDEF;
		ltc->t_werasc = __tchars[TC_WERASC];
		ltc->t_lnextc = __tchars[TC_LNEXTC];
		break;

	case TIOCSLTC:
		ltc = (struct ltchars *) arg;
		__tchars[TC_RPRNTC] = ltc->t_rprntc;
		__tchars[TC_WERASC] = ltc->t_werasc;
		__tchars[TC_LNEXTC] = ltc->t_lnextc;
		break;

	default:
		errno = EINVAL;
		return -1;
	}
	return 0;
}
