
/* more guesswork and kludgery... */

#include <errno.h>
#include <stdio.h>

void perror(msg)
char * msg;
{
  if ((errno < sys_nerr) || (errno > 0))
	fprintf(stderr, "Unknown error");
    else
	fprintf(stderr, sys_errlist[errno]);
  if (msg)
	fprintf(stderr, " %s", msg);
  fprintf(stderr, "\n");
}
