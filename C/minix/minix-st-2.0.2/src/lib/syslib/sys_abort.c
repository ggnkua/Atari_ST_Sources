#include "syslib.h"
#include <stdarg.h>
#include <unistd.h>

PUBLIC int sys_abort(int how, ...)
{
/* Something awful has happened.  Abandon ship. */

  message m;
  va_list ap;

  va_start(ap, how);
  if ((m.m1_i1 = how) == RBT_MONITOR) m.m1_p1 = va_arg(ap, char *);
  va_end(ap);

  return(_taskcall(SYSTASK, SYS_ABORT, &m));
}
