
/* not sure exactly what this does... */

#include "std-guts.h"

clearerr(f)
struct file * f;
{
  f->last_file_error = 0;
}
