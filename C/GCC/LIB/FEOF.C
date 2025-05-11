
/* feof */

#include "std-guts.h"

int feof (f)
struct file * f;
{
  return(!f || !f->open_p || f->eof_p);
}
