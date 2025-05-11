
/* this algorithm is due to Allan Pratt @ Atari.  Thanks Allan! */

#include <errno.h>
#include <osbind.h>
#include <file.h>

int isatty(handle)
int handle;
{
  int rc;
  long oldloc, seekval;

  if (handle < 0)
	return(1);
  if (handle < N_HANDLES)
	if (__handle_stat[handle] != FH_UNKNOWN)
		return(__handle_stat[handle] == FH_ISATTY);
  oldloc = Fseek (0L, handle, L_INCR);	/* seek zero bytes from current loc */
  if (seekval = Fseek (1L, handle, L_INCR))	/* try to seek ahead one byte */
    if ((seekval > 0) || (seekval == EBADARG))	/* out of range... */
      rc = 0;			/* file, not a tty */
    else 
      {
      errno = EBADF;		/* any other error returns "invalid handle" */
				/* because you can't tell */
      rc = 0;
      }
  else
    rc = 1;			/* yes, tty (Fseek returns 0 only for ttys) */
  Fseek(oldloc, handle, L_SET);		/* seek back to original location */
  if (handle < N_HANDLES)
	if (rc)
		__handle_stat[handle] = FH_ISATTY;
	    else
		__handle_stat[handle] = FH_ISAFILE;
  return (rc);			/* return true, false, or error */
}
