
/* return last error */

#include "std-guts.h"

int ferror(f)
struct file * f;
{
  if (f)
	return(f->last_file_error);
    else
	return(0);
}
