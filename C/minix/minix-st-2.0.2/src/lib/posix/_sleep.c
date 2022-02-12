/*  sleep(3)
 *
 *  Sleep(n) pauses for 'n' seconds by scheduling an alarm interrupt.
 *
 *  Changed to conform with POSIX      Terrence W. Holm      Oct. 1988
 */

#include <lib.h>
#define sleep _sleep
#include <signal.h>
#include <unistd.h>

FORWARD _PROTOTYPE( void _alfun, (int signo) );

PRIVATE void _alfun(signo)
int signo;
{
/* Dummy signal handler used with sleep() below. */
}

PUBLIC unsigned sleep(secs)
unsigned secs;
{
  unsigned current_secs;
  unsigned remaining_secs;
  struct sigaction act, oact;
  sigset_t ss;

  if (secs == 0) return(0);

  current_secs = alarm(0);	/* is there currently an alarm?  */

  if (current_secs == 0 || current_secs > secs) {
	act.sa_flags = 0;
	act.sa_mask = 0;
	act.sa_handler = _alfun;
	sigaction(SIGALRM, &act, &oact);

	alarm(secs);
	sigemptyset(&ss);
	sigsuspend(&ss);
	remaining_secs = alarm(0);

	sigaction(SIGALRM, &oact, (struct sigaction *) NULL);

	if (current_secs > secs)
		alarm(current_secs - (secs - remaining_secs));

	return(remaining_secs);
  }

  /* Current_secs <= secs,  ie. alarm should occur before secs.  */

  alarm(current_secs);
  pause();
  remaining_secs = alarm(0);

  alarm(remaining_secs);

  return(secs - (current_secs - remaining_secs));
}
