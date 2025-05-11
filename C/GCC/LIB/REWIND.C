
/* I sure hope this is right... */

#include "std-guts.h"
#include "file.h"

int rewind(f)
struct file * f;
{
  fflush(f);
  return(fseek(f, 0, L_SET));
}

