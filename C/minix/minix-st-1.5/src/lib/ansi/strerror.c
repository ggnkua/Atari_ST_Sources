#include <lib.h>
/* strerror - map error number to descriptive string
 *
 * This version is obviously somewhat Unix-specific.
 */

#include <string.h>

char *strerror(errnum)
int errnum;
{
  extern int sys_nerr;
  extern char *sys_errlist[];

  if (errnum > 0 && errnum < sys_nerr)
	return(sys_errlist[errnum]);
  else
	return("unknown error");
}
