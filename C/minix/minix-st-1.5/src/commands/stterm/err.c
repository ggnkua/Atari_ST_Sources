#include <stdio.h>

extern int errno;
extern char *sys_errlist[];
extern char *i_am;

err(s)
char *s;
{
  fprintf(stderr, "%s failed to %s because %s (errno %d).\n",
	i_am, s, sys_errlist[errno], errno);

  exit(-1);
}
