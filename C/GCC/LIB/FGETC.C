
/* fgetc */

#include <file.h>
#include "std-guts.h"

int fgetc(f)
struct file * f;
{

  if (!f) return(EOF);
  if (f->eof_p) return(EOF);
  if (!f->open_p) return(EOF);
  if ((f->mode & 0x03) == O_WRONLY) return(EOF);
  if (f->buf_max > f->buf_index)
	{
	int result = f->buf[f->buf_index] & 0xFF;

	f->buf_index++;
/*
#ifdef DEBUG
	fprintf(stderr, " >%02X", result);
#endif
*/
	return(result);
	}

/* ok, get a new buf */
  f->file_position += f->buf_max;	/* base pos for next buf */
  f->buf_max = read(f->handle, &f->buf, BUFSIZE);
  f->buf_index = 0;
  if (f->buf_max <= f->buf_index)	/* didn't get anything? */
	{
	f->eof_p = 1;			/* remember the eof */
	if (f->buf_max < 0)
		f->last_file_error = f->buf_max;
	    else
		f->last_file_error = 0;
#ifdef DEBUG
	fprintf(stderr, "fgetc(%X)->EOF\r\n", f);
#endif
	return(EOF);
	}
    else
	{
	int result = f->buf[f->buf_index] & 0xFF;

	f->buf_index++;
#ifdef DEBUG
	fprintf(stderr, "fgetc(%X)->%02X\r\n", f, result);
#endif
	return(result);
	}
}
