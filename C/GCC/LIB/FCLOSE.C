
/* fclose */

#include <file.h>
#include "std-guts.h"

int fclose (f)
struct file * f;
{
  if (f && f->open_p)
	{
	if (((f->mode & 0x03) == O_WRONLY) ||
	    ((f->mode & 0x03) == O_RDWR))
		{
/* see if buffer needs flushing */
		int len = f->buf_max;

		if (len > 0)
			write(f->handle, &f->buf, len);
		f->buf_index = f->buf_max = 0;
		}
	if ((f->handle > 2) || (!isatty(f->handle)))
		close(f->handle);
	}
  if (f)
	free(f);
  return(0);		/* really should check for err ... */
}
