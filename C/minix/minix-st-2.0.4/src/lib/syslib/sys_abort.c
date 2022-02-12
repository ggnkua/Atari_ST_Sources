#include "syslib.h"
#include <stdarg.h>
#include <unistd.h>

PUBLIC int sys_abort(int how, ...)
{
/* Something awful has happened.  Abandon ship. */

  message m;
  va_list ap;

  va_start(ap, how);
  if ((m.m1_i1 = how) == RBT_MONITOR) {
	m.m1_i2 = va_arg(ap, int);
	m.m1_p1 = va_arg(ap, char *);
	m.m1_i3 = va_arg(ap, size_t);
  }
  va_end(ap);

  return(_taskcall(SYSTASK, SYS_ABORT, &m));
}
