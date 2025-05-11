
/* fputc */

#include <file.h>
#include "std-guts.h"

int fputc(c, f)
char c;
struct file * f;
{
  if (!f || !f->open_p || ((f->mode & 0x03) == O_RDONLY)) return(EOF);
  if (f->buf_index >= BUFSIZE)
	fflush(f);
  f->buf[f->buf_index] = c;
  f->buf_index++;
  if (f->buf_max < f->buf_index)
	f->buf_max = f->buf_index;
  if (f->buf_index >= BUFSIZE)
	fflush(f);
  return(c & 0xFF);
}
