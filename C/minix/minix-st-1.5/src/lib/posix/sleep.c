/*  sleep(3)
 *
 *  Sleep(n) pauses for 'n' seconds by scheduling an alarm interrupt.
 *
 *  Changed to conform with POSIX      Terrence W. Holm      Oct. 1988
 */

#include <lib.h>
#include <signal.h>
#include <unistd.h>

PRIVATE void _alfun()
{				/* Used with sleep() below */
}

unsigned sleep(secs)
unsigned secs;
{
  unsigned current_secs;
  unsigned remaining_secs;
  void (*old_signal) ();

  if (secs == 0) return(0);

  current_secs = alarm(0);	/* Is there currently an alarm?  */

  if (current_secs == 0 || current_secs > secs) {
	old_signal = signal(SIGALRM, _alfun);

	alarm(secs);
	pause();
	remaining_secs = alarm(0);

	signal(SIGALRM, old_signal);

	if (current_secs > secs)
		alarm(current_secs - (secs - remaining_secs));

	return(remaining_secs);
  }

  /* Current_secs <= secs,  ie. alarm should occur before secs  */

  alarm(current_secs);
  pause();
  remaining_secs = alarm(0);

  alarm(remaining_secs);

  return(secs - (current_secs - remaining_secs));
}
