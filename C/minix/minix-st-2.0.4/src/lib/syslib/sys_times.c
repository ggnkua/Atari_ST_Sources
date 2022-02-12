#include "syslib.h"

PUBLIC int sys_times(proc, ptr)
int proc;			/* proc whose times are needed */
clock_t ptr[5];			/* pointer to time buffer */
{
/* Fetch the accounting info for a proc. */
  message m;
  int r;

  m.m1_i1 = proc;
  m.m1_p1 = (char *)ptr;
  r = _taskcall(SYSTASK, SYS_TIMES, &m);
  ptr[0] = m.USER_TIME;
  ptr[1] = m.SYSTEM_TIME;
  ptr[2] = m.CHILD_UTIME;
  ptr[3] = m.CHILD_STIME;
  ptr[4] = m.BOOT_TICKS;
  return(r);
}
