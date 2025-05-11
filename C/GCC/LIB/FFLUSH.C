
/* fflush */

#include <file.h>
#include "std-guts.h"

fflush (f)
struct file * f;
{
  if (f && f->open_p &&
	(((f->mode & 0x03) == O_WRONLY) || ((f->mode & 0x03) == O_RDWR)))	
	{
	int err;
	int len = f->buf_max;

	if (len > 0)
		{
#ifdef DEBUG
		char buf[64];

		sprintf(buf, "\r\n\r\nfflush: write(%d, %X, %d)\r\n\r\n",
				f->handle, &f->buf, len);
		dbgstr(buf);
#endif
		err = write(f->handle, &f->buf, len);
		if (err < 0)
			f->last_file_error = err;
		    else
			f->last_file_error = 0;
#ifdef DEBUG
		dbgstr("\r\n\r\nfflush: write complete\r\n\r\n");
#endif
		}
	f->file_position += len;
	f->buf_index = f->buf_max = 0;
	}
}
