/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 *   Signal routine - the signals are actually done by calling the _do_signal
 * routine - similiar to kill() I guess.
 *
 * $Header: signal.c,v 1.1 88/02/03 22:58:53 m68k Exp $
 *
 * $Log:	signal.c,v $
 * Revision 1.1  88/02/03  22:58:53  m68k
 * Initial revision
 * 
 */
#include	<signal.h>
#include	<errno.h>

#define	SIG_EXIT	10		/* exit code */

struct sigarray_str {
	int	(*s_func)();
};
static struct sigarray_str	sig_array[NSIG] = {
					SIG_DFL,	/* SIGNULL */
					SIG_DFL,	/* SIGINT */
					SIG_DFL,	/* SIGQUIT */
					SIG_DFL,	/* SIGALRM */
				};

int	(*
signal(sig, func))()
	int	sig;
	int	(*func)();
{
	int	(*oldfunc)();

	switch (sig) {
	case SIGINT:
		oldfunc = sig_array[SIGINT].s_func;
		sig_array[SIGINT].s_func = func;
		break;

	case SIGQUIT:
		oldfunc = sig_array[SIGQUIT].s_func;
		sig_array[SIGQUIT].s_func = func;
		break;

	case SIGALRM:
		oldfunc = sig_array[SIGALRM].s_func;
		sig_array[SIGALRM].s_func = func;
		break;

	default:
		errno = EINVAL;
		oldfunc = (int (*)()) -1;
	}
	return oldfunc;
}

void
_do_signal(sig)
	int	sig;
{
	int	(*func)();

	if (sig >= 0 && sig < NSIG) {
		func = sig_array[sig].s_func;
		if (func == SIG_DFL)
			switch (sig) {
			case SIGQUIT:
			case SIGINT:
			case SIGALRM:
				exit(SIG_EXIT + sig);
				break;
			}
		else if (func != SIG_IGN)
			(*func)(sig, 0);
		/* else ignore it */
	}
}
