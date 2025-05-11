
/* ftell */

#include "std-guts.h"

int ftell(f)
struct file * f;
{
  if (!f || !f->open_p)
	return(-1);
    else
	return(f->file_position + f->buf_index);
}
