
/* fputs */

#include "std-guts.h"

void fputs(s, f)
char * s;
struct file * f;
{
  char c;

  for ( ; (c = *s++) ; )
	fputc(c, f);
  if (isatty(f->handle))
	fflush(f);
}
