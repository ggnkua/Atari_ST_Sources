
#include <file.h>
#include "std-guts.h"
#include <errno.h>

long fseek(f, pos, mode)
struct file * f;
long pos;
int mode;
{
  long new_pos;

  f->eof_p = 0;					/* just in case */
  switch (mode)
	{
	case L_SET:  { new_pos = pos; break; };
	case L_INCR: { new_pos = f->file_position + f->buf_index + pos;
		       mode = L_SET;
		       break; };
	case L_XTND: { new_pos = 0; break; };
	default:     { errno = EBADARG ; return(-1); };
	};
#ifdef DEBUG
	fprintf(stderr, "fseek: %d,%d.  filepos %d, idx %d max %d\n",
		 pos, mode, f->file_position, f->buf_index, f->buf_max);
#endif
  if ((f->file_position <= new_pos) &&
      ((f->file_position + f->buf_max) > new_pos))	/* have it already? */
	{
	f->buf_index = new_pos - f->file_position;	/* yes, point at it */
#ifdef DEBUG
	fprintf(stderr, "  same buf: new idx %d\n", f->buf_index);
#endif
	return(0);
	}
  if (file_output_p(f))					/* output; flush buf */
	fflush(f);
  f->buf_index = f->buf_max = 0;	/* flush buf */
  new_pos = lseek(f->handle, new_pos, mode);
  if (new_pos >= 0)
	f->file_position = new_pos;
#ifdef DEBUG
  fprintf(stderr, "  seeked to %d\n", f->file_position);
#endif
  if (new_pos < 0)
	return (new_pos);
    else
	return (0);
}
