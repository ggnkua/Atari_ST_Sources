/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 *   This routine uses the verticla blank interupt queue to get it's timing
 * done.  This means that it probably depends on the resolution of the screen.
 * This was written on a machine with a b&w monitor so a 70Hz clock is
 * assumed - what needs to be added is some code that looks to see what
 * the resolution is, and sets the alarm time accordingly.
 *   If there is no room in the vbl queue then -1 is returned.  Note that
 * before the program terminates, this routine must be taken out of the
 * queue - to do this, _unalarm() is called from exit().  If alarm() is
 * not used in the program, the _unalarm() routine is a null one.
 *   This routine works by messing with the return pc (and sr) on the stack
 * when it gets called from the vbl interupt routine.  Also, the routine
 * checks to make sure a trap is not in progress by checking the __in_trap
 * variable (which *must* be set to one before a trap is done, and cleared
 * afer by the programmer - this is normally handled by the __*bios routines).
 * All this weirdness is done to ensure that the os is not disturbed while
 * it is doing stuff - therefor it is safe to do a longjmp() inside a signal
 * handling routine.
 *
 * $Header: alarm.c,v 1.1 88/02/03 22:37:51 m68k Exp $
 *
 * $Log:	alarm.c,v $
 * Revision 1.1  88/02/03  22:37:51  m68k
 * Initial revision
 * 
 */
/*
#include	<xbios.h>
#include	<gembios.h>
*/
#include	<osbind.h>
#include	<sysvars.h>

#define	HZ		(70)		/* how often we get called a second */
#define	CLK_VEC		0x100		/* the clock vector */

extern char	_in_trap;

static int	alrm_in_vblq = 0;
static int	alrm_timer();
static int	set_timer();

static long	alrmtime = 0;

int
alarm(n)
	int	n;
{
	long		oldticks;
	int		(*func)();

	oldticks = alrmtime ? (alrmtime + HZ - 1) / HZ : 0;
	alrmtime = 0;

	if (n) {
		alrmtime = n * HZ;
		if (!alrm_in_vblq)
			if ((short) Supexec(set_timer))
				return -1;
	}
	return oldticks;
}

void
_unalarm()
{
	if (alrm_in_vblq) {
		alrmtime = 0;
		/* don't call us any more */
		(void) Supexec(set_timer);
	}
}

/*
 * This routine should be as small as possible as it is called lots of times
 * (There isn't really an argument - it's just there so we can get the
 * address of the stack)
 */
int
alrm_timer(arg)
	int	arg;
{
	if (alrmtime && !--alrmtime)	/* rrriiinnnngggggggg! */
		if (_in_trap)		/* If we are in a trap, do nothing */
			alrmtime++;
		else {
			(void) set_timer();
			_alrm_nasty(&arg);
		}
	return 0;
}

/* This routine must be called in super mode */
static	int
set_timer()
{
	char	**func;
	int	i;

	func = *_vblqueue;
	i = *nvblq;
	if (alrm_in_vblq)
		while (i--)
			if (*func == (char *) alrm_timer) {
				*func = (char *) 0;
				alrm_in_vblq = 0;
				return 0;
			} else
				func++;
	else
		while (i--)
			if (!*func) {
				*func = (char *) alrm_timer;
				alrm_in_vblq = 1;
				return 0;
			} else
				func++;
	return 1;
}
