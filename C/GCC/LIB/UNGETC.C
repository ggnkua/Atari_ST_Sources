
/* unget one */

#include "std-guts.h"

void ungetc(c, f)
int c;
struct file * f;
{
#ifdef DEBUG
  char buf[32];

  sprintf(buf, " <'%c'", c);
  dbgstr(buf);
#endif
/* should probly do some error checking in here... */
  if (c != EOF)		/* trying to ungetc an EOF is a no-op */
	{
	f->buf_index--;
	f->buf[f->buf_index] = c;
	f->eof_p = 0;
	}
}
