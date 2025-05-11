
/* fdopen */

#include <file.h>
#include "std-guts.h"

struct file * fdopen(handle, mode)
int handle;
char * mode;
{
  struct file * f;

  f = (struct file * )malloc(sizeof(struct file));
  f->handle = handle;

/* I guess we have to trust that the mode string passed in matches the
   one the handle was opened with ?!?  What a crock... */
  f->mode = _parse_open_options(mode); 
  f->file_position = 0;
/* should really check first... */
  f->eof_p = 0;
  f->buf_index = 0;
  f->buf_max = 0;
  f->open_p = 1;
  f->last_file_error = 0;

  return(f);
}
