
/* fileno */

#include "std-guts.h"

int fileno (f)
struct file * f;
{
  return(f->handle);
}
